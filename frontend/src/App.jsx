import React, { useState, useRef, useEffect } from 'react';
import { Upload, Mic, Play, Pause, Square, Activity, AlertCircle } from 'lucide-react';
import { MediaRecorder, register } from 'extendable-media-recorder';
import { connect } from 'extendable-media-recorder-wav-encoder';
import { predictEmotion } from './api';
import WaveSurfer from 'wavesurfer.js';

function App() {
  const [file, setFile] = useState(null);
  const [isRecording, setIsRecording] = useState(false);
  const [recordingTime, setRecordingTime] = useState(0);
  const [status, setStatus] = useState('idle'); // idle, recording, processing, success, error
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);
  const [audioUrl, setAudioUrl] = useState(null);
  
  const mediaRecorderRef = useRef(null);
  const audioChunksRef = useRef([]);
  const timerRef = useRef(null);
  const waveformRef = useRef(null);
  const wavesurferObj = useRef(null);

  // Initialize WaveSurfer & Recorder
  useEffect(() => {
    // Register WAV encoder
    async function initRecorder() {
      try {
        await register(await connect());
      } catch (e) {
        // Ignore if already registered
      }
    }
    initRecorder();

    if (audioUrl && waveformRef.current) {
      if (wavesurferObj.current) {
        wavesurferObj.current.destroy();
      }
      
      wavesurferObj.current = WaveSurfer.create({
        container: waveformRef.current,
        waveColor: '#6366f1',
        progressColor: '#ec4899',
        cursorColor: '#1e293b',
        barWidth: 2,
        barRadius: 3,
        responsive: true,
        height: 80,
      });
      
      wavesurferObj.current.load(audioUrl);
      
      return () => {
        if (wavesurferObj.current) {
            wavesurferObj.current.destroy();
        }
      };
    }
  }, [audioUrl]);

  const handleFileChange = (e) => {
    if (e.target.files[0]) {
      const selectedFile = e.target.files[0];
      setFile(selectedFile);
      setAudioUrl(URL.createObjectURL(selectedFile));
      setStatus('idle');
      setResult(null);
      setError(null);
    }
  };

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      mediaRecorderRef.current = new MediaRecorder(stream, { mimeType: 'audio/wav' });
      audioChunksRef.current = [];

      mediaRecorderRef.current.ondataavailable = (event) => {
        audioChunksRef.current.push(event.data);
      };

      mediaRecorderRef.current.onstop = () => {
        const audioBlob = new Blob(audioChunksRef.current, { type: 'audio/wav' });
        const audioFile = new File([audioBlob], "recording.wav", { type: 'audio/wav' });
        setFile(audioFile);
        setAudioUrl(URL.createObjectURL(audioBlob));
        setStatus('idle');
      };

      mediaRecorderRef.current.start();
      setIsRecording(true);
      setStatus('recording');
      
      // Timer
      setRecordingTime(0);
      timerRef.current = setInterval(() => {
        setRecordingTime(prev => prev + 1);
      }, 1000);

    } catch (err) {
      console.error("Error accessing microphone:", err);
      setError("Could not access microphone. Please ensure permissions are granted.");
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop();
      setIsRecording(false);
      clearInterval(timerRef.current);
      // Stop all tracks
      mediaRecorderRef.current.stream.getTracks().forEach(track => track.stop());
    }
  };

  const handleAnalyze = async () => {
    if (!file) return;

    setStatus('processing');
    setError(null);
    
    try {
      const data = await predictEmotion(file);
      setResult(data);
      setStatus('success');
    } catch (err) {
      console.error(err);
      let msg = "Failed to analyze audio. Please try again.";
      
      if (err.response?.data?.detail) {
        msg = `Server Error: ${err.response.data.detail}`;
      } else if (err.message) {
        msg = `Connection Error: ${err.message}. Is the backend running?`;
      }
      
      setError(msg);
      setStatus('error');
    }
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs < 10 ? '0' : ''}${secs}`;
  };

  const togglePlayPause = () => {
    if (wavesurferObj.current) {
      wavesurferObj.current.playPause();
    }
  };

  return (
    <div className="container">
      <header style={{ textAlign: 'center', marginBottom: '3rem', paddingTop: '2rem' }}>
        <h1 className="hero-title">Speech Emotion Recognition</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '1.2rem' }}>
          Analyze emotions from speech using Deep Learning.
        </p>
      </header>

      <main style={{ display: 'grid', gridTemplateColumns: result ? '1fr 1fr' : '1fr', gap: '2rem' }}>
        
        {/* Input Section */}
        <div className="card">
          <h2 style={{ marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <Mic size={24} color="var(--primary)" /> Audio Input
          </h2>

          {!file && !isRecording && (
            <div className="upload-zone" onClick={() => document.getElementById('file-upload').click()}>
              <input 
                id="file-upload" 
                type="file" 
                accept="audio/*" 
                style={{ display: 'none' }} 
                onChange={handleFileChange} 
              />
              <Upload size={48} color="var(--text-muted)" style={{ marginBottom: '1rem' }} />
              <p style={{ fontWeight: 600 }}>Click to Upload Audio</p>
              <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>MP3 or WAV (Max 10MB)</p>
            </div>
          )}

          {/* Recorder UI */}
          {!file && (
             <div style={{ marginTop: '2rem', textAlign: 'center' }}>
               <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '1rem', marginBottom: '1rem' }}>
                 <div style={{ height: '1px', flex: 1, background: '#e2e8f0' }}></div>
                 <span style={{ color: 'var(--text-muted)', fontSize: '0.8rem' }}>OR RECORD</span>
                 <div style={{ height: '1px', flex: 1, background: '#e2e8f0' }}></div>
               </div>
               
               {!isRecording ? (
                 <button className="btn btn-secondary" onClick={startRecording}>
                   <Mic size={20} /> Start Recording
                 </button>
               ) : (
                 <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '1rem' }}>
                    <div style={{ fontSize: '1.5rem', fontWeight: 'bold', color: 'var(--error)' }}>
                      {formatTime(recordingTime)}
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', color: 'var(--error)', fontSize: '0.9rem' }}>
                        <span className="loader" style={{ width: '12px', height: '12px', borderWidth: '2px', borderColor: 'var(--error)', borderTopColor: 'transparent' }}></span>
                        Recording...
                    </div>
                    <button className="btn btn-primary" style={{ backgroundColor: 'var(--error)' }} onClick={stopRecording}>
                      <Square size={20} fill="white" /> Stop
                    </button>
                 </div>
               )}
             </div>
          )}

          {/* File Selected UI */}
          {file && (
            <div>
                <div style={{ background: '#eff6ff', padding: '1.25rem', borderRadius: 'var(--radius)', marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '1.25rem', border: '1px solid #dbeafe' }}>
                  <div style={{ background: 'white', padding: '0.625rem', borderRadius: '50%', boxShadow: 'var(--shadow-sm)' }}>
                    <Activity size={24} color="var(--primary)" />
                  </div>
                  <div>
                    <p style={{ fontWeight: 600, margin: 0, color: 'var(--text-main)', fontSize: '1.05rem' }}>{file.name}</p>
                    <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', margin: 0 }}>
                      {(file.size / 1024 / 1024).toFixed(2)} MB
                    </p>
                  </div>
               </div>

               {/* Waveform */}
               <div ref={waveformRef} style={{ marginBottom: '1.5rem', background: '#f8fafc', padding: '1.25rem', borderRadius: 'var(--radius)', border: '1px solid #e2e8f0' }}></div>
               
               <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                  <button className="btn btn-secondary" onClick={togglePlayPause}>
                     <Play size={20} /> Play / Pause
                  </button>
                  <button className="btn btn-secondary" onClick={() => { setFile(null); setAudioUrl(null); setResult(null); }}>
                     Change Audio
                  </button>
                  <button 
                    className="btn btn-primary" 
                    onClick={handleAnalyze}
                    disabled={status === 'processing'}
                  >
                    {status === 'processing' ? (
                       <>Processing...</>
                    ) : (
                       <>Analyze Emotion</>
                    )}
                  </button>
               </div>
            </div>
          )}
          
          {error && (
            <div style={{ marginTop: '1rem', padding: '0.75rem', background: '#fef2f2', color: 'var(--error)', borderRadius: 'var(--radius)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <AlertCircle size={20} /> {error}
            </div>
          )}
        </div>

        {/* Results Section */}
        {result && (
          <div className="card fade-in">
             <h2 style={{ marginBottom: '1.5rem' }}>Analysis Result</h2>
             
             <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
                <p style={{ fontSize: '1rem', color: 'var(--text-muted)', marginBottom: '0.5rem' }}>DETECTED EMOTION</p>
                <h3 style={{ fontSize: '3rem', margin: 0, textTransform: 'uppercase', color: 'var(--primary)' }}>
                   {result.emotion}
                </h3>
                <div style={{ display: 'inline-block', padding: '0.25rem 0.75rem', background: '#e0e7ff', color: 'var(--primary)', borderRadius: '1rem', fontSize: '0.9rem', marginTop: '0.5rem', fontWeight: 600 }}>
                   {result.confidence} Confidence
                </div>
             </div>

             <div>
                <h4 style={{ marginBottom: '1rem' }}>Probabilities</h4>
                {Object.entries(result.probabilities).map(([emotion, prob]) => (
                   <div key={emotion} style={{ marginBottom: '0.75rem' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.25rem', fontSize: '0.9rem' }}>
                         <span style={{ textTransform: 'capitalize' }}>{emotion}</span>
                         <span>{(prob * 100).toFixed(1)}%</span>
                      </div>
                      <div style={{ width: '100%', height: '8px', background: '#e2e8f0', borderRadius: '4px', overflow: 'hidden' }}>
                         <div style={{ 
                            width: `${prob * 100}%`, 
                            height: '100%', 
                            background: emotion === result.emotion ? 'var(--primary)' : '#cbd5e1',
                            transition: 'width 1s ease-out' 
                         }}></div>
                      </div>
                   </div>
                ))}
             </div>
          </div>
        )}
      </main>
    </div>
  );
}

export default App;
