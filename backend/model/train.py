import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras import layers
from tensorflow.keras.utils import to_categorical
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split
import pickle
import os
import sys

# Append parent dir to path to import utils
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
try:
    from utils.feature_extraction import extract_features
except ImportError:
    # Fallback if running directly from model dir
    sys.path.append(os.path.join(os.getcwd(), '..'))
    from utils.feature_extraction import extract_features

# Constants
EMOTIONS = ['neutral', 'calm', 'happy', 'sad', 'angry', 'fearful', 'disgust', 'surprised']
MODEL_PATH = "ser_model.h5"
SCALER_PATH = "scaler.pkl"
ENCODER_PATH = "encoder.pkl"

def create_model(input_shape, num_classes):
    model = Sequential([
        layers.Conv1D(256, 8, padding='same', input_shape=input_shape),
        layers.Activation('relu'),
        layers.Conv1D(256, 8, padding='same'),
        layers.BatchNormalization(),
        layers.Activation('relu'),
        layers.Dropout(0.25),
        layers.MaxPooling1D(pool_size=8),
        
        layers.Conv1D(128, 8, padding='same'),
        layers.Activation('relu'),
        layers.Conv1D(128, 8, padding='same'),
        layers.Activation('relu'),
        layers.Conv1D(128, 8, padding='same'),
        layers.Activation('relu'),
        layers.Conv1D(128, 8, padding='same'),
        layers.BatchNormalization(),
        layers.Activation('relu'),
        layers.Dropout(0.25),
        layers.MaxPooling1D(pool_size=8),
        
        layers.Conv1D(64, 8, padding='same'),
        layers.Activation('relu'),
        layers.Conv1D(64, 8, padding='same'),
        layers.Activation('relu'),
        layers.Flatten(),
        layers.Dense(num_classes, activation='softmax')
    ])
    
    model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
    return model

def train_ravdess_model(data_path):
    """Trains the model on the RAVDESS dataset."""
    print(f"Loading RAVDESS data from {data_path}...")
    
    X, y = [], []
    
    # RAVDESS Emotion Code Map
    # 01 = neutral, 02 = calm, 03 = happy, 04 = sad, 05 = angry, 06 = fearful, 07 = disgust, 08 = surprised
    emotion_map = {
        '01': 'neutral',
        '02': 'calm',
        '03': 'happy',
        '04': 'sad',
        '05': 'angry',
        '06': 'fearful',
        '07': 'disgust',
        '08': 'surprised'
    }
    
    # Walk through all files
    for root, dirs, files in os.walk(data_path):
        for file in files:
            if file.endswith(".wav"):
                try:
                    # File format: 03-01-01-01-01-01-01.wav
                    parts = file.split("-")
                    emotion_code = parts[2]
                    
                    if emotion_code in emotion_map:
                        emotion_label = emotion_map[emotion_code]
                        file_path = os.path.join(root, file)
                        
                        # Extract features
                        feature = extract_features(file_path)
                        if feature is not None:
                            X.append(feature)
                            y.append(emotion_label)
                except Exception as e:
                    print(f"Skipping {file}: {e}")

    if len(X) == 0:
        print("No valid data found! Check the path structure.")
        return

    X = np.array(X)
    y = np.array(y)
    
    # Encode labels
    lb = LabelEncoder()
    y_encoded = to_categorical(lb.fit_transform(y))
    
    # Scale features
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    X_scaled = np.expand_dims(X_scaled, axis=2)
    
    # Split
    X_train, X_test, y_train, y_test = train_test_split(X_scaled, y_encoded, test_size=0.2, random_state=42)
    
    # Create and train model
    model = create_model((X_train.shape[1], 1), y_encoded.shape[1])
    
    print("Starting training...")
    model.fit(X_train, y_train, validation_data=(X_test, y_test), batch_size=32, epochs=100, verbose=1)
    
    # Save artifacts
    print("Saving artifacts...")
    model.save(MODEL_PATH)
    with open(SCALER_PATH, 'wb') as f:
        pickle.dump(scaler, f)
    with open(ENCODER_PATH, 'wb') as f:
        pickle.dump(lb, f)
        
    print("Model trained on real data and saved successfully!")

if __name__ == "__main__":
    # Check if a 'data' folder exists in backend
    data_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data")
    
    if os.path.exists(data_dir) and len(os.listdir(data_dir)) > 0:
        response = input(f"Found data directory at {data_dir}. Train on this? (y/n): ")
        if response.lower() == 'y':
            train_ravdess_model(data_dir)
        else:
            train_dummy_model()
    else:
        print("No data folder found. Training dummy model.")
        train_dummy_model()
