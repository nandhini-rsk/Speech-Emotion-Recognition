import os
import sys
import numpy as np
import tensorflow as tf
import pickle
import librosa
import soundfile as sf

# Setup paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(BASE_DIR)

from utils.feature_extraction import extract_features

MODEL_PATH = os.path.join(BASE_DIR, "model", "ser_model.h5")
SCALER_PATH = os.path.join(BASE_DIR, "model", "scaler.pkl")
ENCODER_PATH = os.path.join(BASE_DIR, "model", "encoder.pkl")

def create_dummy_wav(filename="test_audio.wav"):
    sr = 22050
    duration = 3
    t = np.linspace(0, duration, int(sr * duration))
    y = 0.5 * np.sin(2 * np.pi * 440 * t) # 440Hz sine wave
    sf.write(filename, y, sr)
    print(f"Created dummy audio file: {filename}")
    return filename

def test_prediction():
    print("--- Starting Prediction Test ---")

    # 1. Load Artifacts
    if not os.path.exists(MODEL_PATH):
        print(f"ERROR: Model file not found at {MODEL_PATH}")
        return
    
    try:
        print("Loading model...")
        model = tf.keras.models.load_model(MODEL_PATH)
        print("Model loaded successfully.")
    except Exception as e:
        print(f"ERROR: Failed to load model: {e}")
        return

    try:
        print("Loading scaler...")
        with open(SCALER_PATH, 'rb') as f:
            scaler = pickle.load(f)
        print("Scaler loaded.")
    except Exception as e:
        print(f"ERROR: Failed to load scaler: {e}")
        return

    try:
        print("Loading encoder...")
        with open(ENCODER_PATH, 'rb') as f:
            label_encoder = pickle.load(f)
        print("Encoder loaded.")
    except Exception as e:
        print(f"Warning: Failed to load encoder (might be optional): {e}")
        label_encoder = None

    # 2. Create Dummy Audio
    audio_file = create_dummy_wav()

    # 3. Extract Features
    print("Extracting features...")
    try:
        features = extract_features(audio_file)
        if features is None:
            print("ERROR: extract_features returned None.")
            return
        print(f"Features extracted. Shape: {features.shape}")
    except Exception as e:
        print(f"ERROR: extract_features failed with exception: {e}")
        import traceback
        traceback.print_exc()
        return

    # 4. Preprocess for Model
    try:
        # Scale
        features_scaled = scaler.transform([features])
        # Reshape for CNN (Batch, Features, 1)
        features_final = np.expand_dims(features_scaled, axis=2)
        print(f"Input shape for model: {features_final.shape}")
    except Exception as e:
        print(f"ERROR: Preprocessing failed: {e}")
        return

    # 5. Predict
    try:
        print("Running model prediction...")
        pred = model.predict(features_final)
        print(f"Raw prediction output: {pred}")
        
        predicted_idx = np.argmax(pred)
        confidence = np.max(pred)
        
        if label_encoder:
            emotion = label_encoder.inverse_transform([predicted_idx])[0]
        else:
            emotion = f"Class {predicted_idx}"
            
        print(f"Predicted Emotion: {emotion}")
        print(f"Confidence: {confidence:.4f}")
        
    except Exception as e:
        print(f"ERROR: Prediction failed: {e}")
        import traceback
        traceback.print_exc()

    # Cleanup
    if os.path.exists(audio_file):
        os.remove(audio_file)
    print("--- Test Completed ---")

if __name__ == "__main__":
    test_prediction()
