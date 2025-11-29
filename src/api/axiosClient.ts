import axios, { AxiosError, AxiosHeaders } from 'axios';
import { Preferences } from '@capacitor/preferences';
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
    async (config) => {
        if (!config.headers) {
            config.headers = new AxiosHeaders();
        }

        if (config.headers instanceof AxiosHeaders) {
            config.headers.set('ngrok-skip-browser-warning', 'true');
        } else {
            (config.headers as Record<string, unknown>)['ngrok-skip-browser-warning'] = 'true';
        }

        // Add Bearer token from storage
        try {
            const tokensResult = await Preferences.get({ key: 'auth_tokens' });
            if (tokensResult.value) {
                const tokens = JSON.parse(tokensResult.value);
                if (tokens.accessToken) {
                    if (config.headers instanceof AxiosHeaders) {
                        config.headers.set('Authorization', `Bearer ${tokens.accessToken}`);
                    } else {
                        (config.headers as Record<string, unknown>)['Authorization'] = `Bearer ${tokens.accessToken}`;
                    }
                }
            }
        } catch (error) {
            console.error('Failed to get auth token:', error);
        }

        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// Response interceptor for error handling and token refresh
axiosClient.interceptors.response.use(
    (response) => response,
    async (error: AxiosError<ErrorResponse>) => {
        const originalRequest = error.config;

        // If 401 and we haven't retried yet, try to refresh token
        if (error.response?.status === 401 && originalRequest && !(originalRequest as any)._retry) {
            (originalRequest as any)._retry = true;

            try {
                const tokensResult = await Preferences.get({ key: 'auth_tokens' });
                if (tokensResult.value) {
                    const tokens = JSON.parse(tokensResult.value);

                    // Try to refresh the token
                    const refreshResponse = await axios.post(
                        `${axiosClient.defaults.baseURL}/v1/auth/refresh`,
                        { refreshToken: tokens.refreshToken }
                    );

                    const newTokens = refreshResponse.data;

                    // Store new tokens
                    await Preferences.set({
                        key: 'auth_tokens',
                        value: JSON.stringify({
                            accessToken: newTokens.accessToken,
                            refreshToken: newTokens.refreshToken,
                            expiresIn: newTokens.expiresIn,
                        }),
                    });

                    // Update the failed request with new token
                    if (originalRequest.headers instanceof AxiosHeaders) {
                        originalRequest.headers.set('Authorization', `Bearer ${newTokens.accessToken}`);
                    } else if (originalRequest.headers) {
                        (originalRequest.headers as Record<string, unknown>)['Authorization'] = `Bearer ${newTokens.accessToken}`;
                    }

                    // Retry the original request
                    return axiosClient(originalRequest);
                }
            } catch (refreshError) {
                // Refresh failed, clear auth and redirect to login
                await Preferences.remove({ key: 'auth_tokens' });
                await Preferences.remove({ key: 'auth_user' });

                // You can dispatch a custom event here to trigger navigation to login
                window.dispatchEvent(new CustomEvent('auth:logout'));

                return Promise.reject(refreshError);
            }
        }

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
