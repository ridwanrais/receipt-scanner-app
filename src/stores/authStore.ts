import { create } from 'zustand';
import { Preferences } from '@capacitor/preferences';
import authService, { User, AuthResponse } from '../services/authService';

interface AuthState {
    user: User | null;
    accessToken: string | null;
    refreshToken: string | null;
    isAuthenticated: boolean;
    isLoading: boolean;
    error: string | null;

    // Actions
    signIn: () => Promise<void>;
    signOut: () => Promise<void>;
    loadStoredAuth: () => Promise<void>;
    refreshAccessToken: () => Promise<void>;
    clearError: () => void;
}

const TOKEN_KEY = 'auth_tokens';
const USER_KEY = 'auth_user';

export const useAuthStore = create<AuthState>((set, get) => ({
    user: null,
    accessToken: null,
    refreshToken: null,
    isAuthenticated: false,
    isLoading: false,
    error: null,

    signIn: async () => {
        set({ isLoading: true, error: null });
        try {
            const authResponse: AuthResponse = await authService.signInWithGoogle();

            // Store tokens securely
            await Preferences.set({
                key: TOKEN_KEY,
                value: JSON.stringify({
                    accessToken: authResponse.accessToken,
                    refreshToken: authResponse.refreshToken,
                    expiresIn: authResponse.expiresIn,
                }),
            });

            // Store user info
            await Preferences.set({
                key: USER_KEY,
                value: JSON.stringify(authResponse.user),
            });

            set({
                user: authResponse.user,
                accessToken: authResponse.accessToken,
                refreshToken: authResponse.refreshToken,
                isAuthenticated: true,
                isLoading: false,
            });
        } catch (error: any) {
            set({
                error: error.message || 'Failed to sign in',
                isLoading: false,
            });
            throw error;
        }
    },

    signOut: async () => {
        set({ isLoading: true });
        try {
            await authService.signOut();

            // Clear stored tokens
            await Preferences.remove({ key: TOKEN_KEY });
            await Preferences.remove({ key: USER_KEY });

            set({
                user: null,
                accessToken: null,
                refreshToken: null,
                isAuthenticated: false,
                isLoading: false,
                error: null,
            });
        } catch (error: any) {
            set({
                error: error.message || 'Failed to sign out',
                isLoading: false,
            });
        }
    },

    loadStoredAuth: async () => {
        set({ isLoading: true });
        try {
            const tokensResult = await Preferences.get({ key: TOKEN_KEY });
            const userResult = await Preferences.get({ key: USER_KEY });

            if (tokensResult.value && userResult.value) {
                const tokens = JSON.parse(tokensResult.value);
                const user = JSON.parse(userResult.value);

                set({
                    user,
                    accessToken: tokens.accessToken,
                    refreshToken: tokens.refreshToken,
                    isAuthenticated: true,
                    isLoading: false,
                });

                // Verify token is still valid by fetching current user
                try {
                    const currentUser = await authService.getCurrentUser();
                    set({ user: currentUser });
                } catch (error) {
                    // Token might be expired, try to refresh
                    await get().refreshAccessToken();
                }
            } else {
                set({ isLoading: false });
            }
        } catch (error: any) {
            console.error('Failed to load stored auth:', error);
            set({ isLoading: false });
        }
    },

    refreshAccessToken: async () => {
        const { refreshToken } = get();
        if (!refreshToken) {
            throw new Error('No refresh token available');
        }

        try {
            const tokenPair = await authService.refreshToken(refreshToken);

            // Update stored tokens
            await Preferences.set({
                key: TOKEN_KEY,
                value: JSON.stringify({
                    accessToken: tokenPair.accessToken,
                    refreshToken: tokenPair.refreshToken,
                    expiresIn: tokenPair.expiresIn,
                }),
            });

            set({
                accessToken: tokenPair.accessToken,
                refreshToken: tokenPair.refreshToken,
            });
        } catch (error: any) {
            console.error('Failed to refresh token:', error);
            // If refresh fails, sign out
            await get().signOut();
            throw error;
        }
    },

    clearError: () => set({ error: null }),
}));
