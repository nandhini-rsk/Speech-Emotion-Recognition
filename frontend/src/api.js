import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8000',
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
