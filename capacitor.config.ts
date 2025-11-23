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
        }
    }
};

export default config;
