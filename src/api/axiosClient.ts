import axios, { AxiosError, AxiosHeaders } from 'axios';
import type { ErrorResponse } from '../types/api';

const axiosClient = axios.create({
    baseURL: 'https://catfish-right-tick.ngrok-free.app',
    headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
    },
});

// Request interceptor for adding auth token
axiosClient.interceptors.request.use(
    (config) => {
        if (!config.headers) {
            config.headers = new AxiosHeaders();
        }

        if (config.headers instanceof AxiosHeaders) {
            config.headers.set('ngrok-skip-browser-warning', 'true');
        } else {
            (config.headers as Record<string, unknown>)['ngrok-skip-browser-warning'] = 'true';
        }
        // TODO: Add Bearer token from storage when auth is implemented
        // const token = localStorage.getItem('authToken');
        // if (token) {
        //   config.headers.Authorization = `Bearer ${token}`;
        // }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Response interceptor for error handling
axiosClient.interceptors.response.use(
    (response) => response,
    (error: AxiosError<ErrorResponse>) => {
        if (error.response?.data) {
            return Promise.reject(error.response.data);
        }
        return Promise.reject({
            status: 'error',
            message: error.message || 'An unexpected error occurred',
        } as ErrorResponse);
    }
);

export default axiosClient;
