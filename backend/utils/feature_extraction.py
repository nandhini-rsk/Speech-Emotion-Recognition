import librosa
import numpy as np

def extract_features(file_path):
    """
    Extracts features from an audio file using Librosa.
    Features: MFCC, Chroma, Mel Spectrogram, Spectral Contrast, Tonnetz
    Returns: A 1D numpy array of averaged features.
    """
    try:
        # Load audio file 
        import soundfile as sf
        
        # First, check audio duration to decide on offset
        try:
            info = sf.info(file_path)
            audio_duration = info.duration
        except:
            audio_duration = 5  # Default assumption
        
        # Don't use offset for short recordings (browser recordings are often short)
        # Use offset only for longer professional recordings
        offset = 0.5 if audio_duration > 4 else 0.0
        
        try:
             y, sr = librosa.load(file_path, duration=3, offset=offset, sr=22050)
        except Exception:
             # Fallback to soundfile directly if librosa wrapper fails
             data, samplerate = sf.read(file_path)
             # Handle multi-channel
             if len(data.shape) > 1:
                 data = data[:, 0]
             # Resample if needed
             if samplerate != 22050:
                 y = librosa.resample(data, orig_sr=samplerate, target_sr=22050)
                 sr = 22050
             else:
                 y = data
                 sr = samplerate
             
             # Apply offset manually if needed
             if offset > 0 and len(y) > int(sr * offset):
                 start_sample = int(sr * offset)
                 y = y[start_sample:start_sample + int(sr * 3)]
             else:
                 y = y[:int(sr * 3)]
        
        # Ensure we have data
        if y is None or len(y) == 0:
             return None

        # Normalize audio to have consistent RMS (Root Mean Square) energy
        # This helps match the volume level of training data
        rms = np.sqrt(np.mean(y**2))
        if rms > 0:
            # Target RMS around 0.05 (adjusted for better matching)
            target_rms = 0.05
            y = y * (target_rms / rms)
        
        # Apply pre-emphasis filter to boost high frequencies
        # This is common in speech processing and helps with emotion recognition
        pre_emphasis = 0.97
        y = np.append(y[0], y[1:] - pre_emphasis * y[:-1])
        
        # Clip to prevent overflow
        y = np.clip(y, -1.0, 1.0)

        # Fix length to ensure consistent feature shape (3 seconds * 22050 = ~66k samples)
        # Pad or truncate
        target_len = 22050 * 3
        if len(y) < target_len:
             y = np.pad(y, (0, target_len - len(y)))
        else:
             y = y[:target_len]

        # MFCC
        mfcc = np.mean(librosa.feature.mfcc(y=y, sr=sr, n_mfcc=40).T, axis=0)

        # Chroma
        stft = np.abs(librosa.stft(y))
        chroma = np.mean(librosa.feature.chroma_stft(S=stft, sr=sr).T, axis=0)

        # Mel Spectrogram
        mel = np.mean(librosa.feature.melspectrogram(y=y, sr=sr).T, axis=0)
        
        # Spectral Contrast
        contrast = np.mean(librosa.feature.spectral_contrast(S=stft, sr=sr).T, axis=0)
        
        # Tonnetz
        tonnetz = np.mean(librosa.feature.tonnetz(y=librosa.effects.harmonic(y), sr=sr).T, axis=0)
        
        return np.hstack([mfcc, chroma, mel, contrast, tonnetz])
        
    except Exception as e:
        import traceback
        print(f"Error extracting features: {e}")
        traceback.print_exc()
        return None
