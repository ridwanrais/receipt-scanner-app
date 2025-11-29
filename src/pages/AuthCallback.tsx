import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Preferences } from '@capacitor/preferences';
import authService from '../services/authService';

const AuthCallback: React.FC = () => {
    const navigate = useNavigate();

    useEffect(() => {
        const handleCallback = async () => {
            try {
                // Parse URL parameters
                const params = new URLSearchParams(window.location.search);
                const accessToken = params.get('access_token');
                const refreshToken = params.get('refresh_token');
                const expiresIn = params.get('expires_in');

                console.log('Callback received tokens:', { accessToken: !!accessToken, refreshToken: !!refreshToken });

                if (!accessToken || !refreshToken) {
                    throw new Error('Missing tokens in callback');
                }

                // Store tokens
                await Preferences.set({
                    key: 'auth_tokens',
                    value: JSON.stringify({
                        accessToken,
                        refreshToken,
                        expiresIn: parseInt(expiresIn || '86400'),
                    }),
                });

                // Fetch and store user info
                const user = await authService.getCurrentUser();
                await Preferences.set({
                    key: 'auth_user',
                    value: JSON.stringify(user),
                });

                console.log('Tokens and user stored, redirecting to home');

                // Redirect to home - the App.tsx will reload auth state
                window.location.href = '/';
            } catch (error) {
                console.error('Auth callback error:', error);
                navigate('/login', { replace: true });
            }
        };

        handleCallback();
    }, [navigate]);

    return (
        <div className="flex items-center justify-center min-h-screen">
            <div className="text-center">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
                <p className="text-gray-600">Completing sign in...</p>
            </div>
        </div>
    );
};

export default AuthCallback;
