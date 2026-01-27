import axios from 'axios';

// Automatically use Railway backend in production, localhost in development
const API_BASE_URL = import.meta.env.PROD 
  ? 'https://your-railway-backend-url.railway.app'  // Replace this after Railway deployment
  : 'http://localhost:8000';

const api = axios.create({
  baseURL: API_BASE_URL,
});

export const predictEmotion = async (audioFile) => {
  const formData = new FormData();
  formData.append('file', audioFile);
  
  const response = await api.post('/predict', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
  return response.data;
};
