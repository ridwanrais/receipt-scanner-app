import { GoogleAuth } from '@codetrix-studio/capacitor-google-auth';
import { Capacitor } from '@capacitor/core';
import axiosClient from '../api/axiosClient';

// Declare Google Identity Services types
declare global {
    interface Window {
        google?: {
            accounts: {
                id: {
                    initialize: (config: any) => void;
                    prompt: () => void;
                    renderButton: (element: HTMLElement, config: any) => void;
                };
            };
        };
    }
}

export interface User {
    id: string;
    email: string;
    name: string;
    pictureUrl?: string;
    emailVerified: boolean;
}

export interface AuthResponse {
    user: User;
    accessToken: string;
    refreshToken: string;
    expiresIn: number;
}

export interface TokenPair {
    accessToken: string;
    refreshToken: string;
    expiresIn: number;
}

class AuthService {
    constructor() {
        // Initialize Google Auth for web
        if (!Capacitor.isNativePlatform()) {
            GoogleAuth.initialize({
                clientId: '685621768072-iarp1tjb8i3k77rb4or2piqg7njm24ks.apps.googleusercontent.com',
                scopes: ['profile', 'email'],
                grantOfflineAccess: true,
            });
        }
    }

    /**
     * Sign in with Google using native SDK or web GSI
     */
    async signInWithGoogle(): Promise<AuthResponse> {
        try {
            // For native platforms, use Capacitor Google Auth
            if (Capacitor.isNativePlatform()) {
                return await this.signInNative();
            } else {
                // For web, use Google Identity Services with One Tap
                return await this.signInWeb();
            }
        } catch (error) {
            console.error('Google sign-in error:', error);
            throw error;
        }
    }

    /**
     * Native platform sign-in
     */
    private async signInNative(): Promise<AuthResponse> {
        const googleUser = await GoogleAuth.signIn();

        const idToken = googleUser.authentication?.idToken;
        if (!idToken) {
            throw new Error('No ID token received from Google');
        }

        const response = await axiosClient.post<AuthResponse>('/v1/auth/google/mobile', {
            idToken: idToken,
        });

        return response.data;
    }

    /**
     * Web platform sign-in using redirect to backend OAuth flow
     */
    private async signInWeb(): Promise<AuthResponse> {
        // For web, redirect to backend OAuth flow
        window.location.href = 'http://localhost:8080/v1/auth/google/login';

        // This will never resolve as we're redirecting away
        return new Promise(() => { });
    }

    /**
     * Refresh access token using refresh token
     */
    async refreshToken(refreshToken: string): Promise<TokenPair> {
        try {
            const response = await axiosClient.post<TokenPair>('/v1/auth/refresh', {
                refreshToken,
            });
            return response.data;
        } catch (error) {
            console.error('Token refresh error:', error);
            throw error;
        }
    }

    /**
     * Get current user info
     */
    async getCurrentUser(): Promise<User> {
        try {
            const response = await axiosClient.get<User>('/v1/auth/me');
            return response.data;
        } catch (error) {
            console.error('Get current user error:', error);
            throw error;
        }
    }

    /**
     * Sign out
     */
    async signOut(): Promise<void> {
        try {
            // Sign out from Google
            await GoogleAuth.signOut();

            // Notify backend (optional, since JWT is stateless)
            await axiosClient.post('/v1/auth/logout');
        } catch (error) {
            console.error('Sign out error:', error);
            throw error;
        }
    }
}

export default new AuthService();
