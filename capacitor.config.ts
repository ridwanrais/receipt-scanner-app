import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
    appId: 'com.receiptsnap.app',
    appName: 'ReceiptSnap',
    webDir: 'dist',
    server: {
        androidScheme: 'https'
    },
    plugins: {
        Camera: {
            presentationStyle: 'fullscreen'
        },
        GoogleAuth: {
            scopes: ['profile', 'email'],
            serverClientId: '685621768072-iarp1tjb8i3k77rb4or2piqg7njm24ks.apps.googleusercontent.com', // Your web client ID (optional)
            forceCodeForRefreshToken: true
        }
    }
};

export default config;
