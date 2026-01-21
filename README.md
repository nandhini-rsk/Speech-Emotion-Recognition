# Speech Emotion Recognition

A full-stack web application for analyzing emotions from speech using Deep Learning.

## Features

- 🎤 **Live Audio Recording** - Record audio directly from your browser
- 📁 **File Upload** - Upload pre-recorded audio files (WAV/MP3)
- 🤖 **Deep Learning Model** - CNN-based emotion recognition trained on RAVDESS dataset
- 🎨 **Beautiful UI** - Modern dark blue theme with glassmorphism effects
- 📊 **Real-time Analysis** - Get instant emotion predictions with confidence scores

## Emotions Detected

The model can detect 8 different emotions:
- 😊 Happy
- 😢 Sad
- 😠 Angry
- 😨 Fearful
- 🤢 Disgust
- 😮 Surprised
- 😐 Neutral
- 😌 Calm

## Tech Stack

### Frontend
- React + Vite
- WaveSurfer.js for audio visualization
- Axios for API calls
- Modern CSS with glassmorphism

### Backend
- FastAPI (Python)
- TensorFlow/Keras for deep learning
- Librosa for audio feature extraction
- scikit-learn for preprocessing

## Installation

### Prerequisites
- Python 3.8+
- Node.js 16+

### Backend Setup

```bash
cd backend
python -m venv venv
venv\Scripts\activate  # On Windows
pip install -r requirements.txt
```

### Frontend Setup

```bash
cd frontend
npm install
```

## Running the Application

### Start Backend
```bash
cd backend
venv\Scripts\activate
python -m uvicorn main:app --reload
```

Backend will run on `http://localhost:8000`

### Start Frontend
```bash
cd frontend
npm run dev
```

Frontend will run on `http://localhost:5173`

## Model Training

The model is trained on the RAVDESS dataset with 1440 audio samples.

To retrain the model:
```bash
cd backend/model
python train.py
```

Training parameters:
- Epochs: 100
- Batch size: 32
- Validation split: 20%

## Project Structure

```
Speech-Emotion-Recognition/
├── backend/
│   ├── model/
│   │   ├── train.py
│   │   ├── ser_model.h5
│   │   ├── scaler.pkl
│   │   └── encoder.pkl
│   ├── utils/
│   │   └── feature_extraction.py
│   ├── main.py
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── App.jsx
│   │   ├── api.js
│   │   └── index.css
│   └── package.json
└── README.md
```

## Features in Detail

### Audio Processing
- Extracts MFCC, Chroma, Mel Spectrogram, Spectral Contrast, and Tonnetz features
- RMS normalization for consistent volume levels
- Pre-emphasis filter for better speech processing

### Model Architecture
- CNN-based architecture with multiple convolutional layers
- Batch normalization and dropout for regularization
- Softmax output for multi-class classification

### Demo Mode
- Browser recordings use random predictions for demonstration
- Uploaded files use the trained model for real predictions

## License

MIT

## Author

Nandhini RSK
