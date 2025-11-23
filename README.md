# ReceiptSnap

A mobile-first cross-platform receipt scanner built with React, TypeScript, and Capacitor. Features AI-powered receipt data extraction, expense tracking, and analytics.

## Features

- 📸 **Camera Integration** - Capture receipts using native camera
- 🤖 **AI Extraction** - Automatic data extraction from receipt images
- 📝 **Manual Entry** - Add receipts manually with detailed item tracking
- 📊 **Analytics Dashboard** - View spending insights by category and merchant
- 🔍 **Search & Filter** - Find receipts by date, merchant, or amount
- 📱 **Cross-Platform** - Works on Android, iOS, and web browsers

## Tech Stack

- **Frontend**: React 18 + TypeScript
- **Build Tool**: Vite
- **Mobile**: Capacitor 6
- **Styling**: TailwindCSS
- **State Management**: Zustand
- **Routing**: React Router v6
- **HTTP Client**: Axios
- **Charts**: Recharts

## Prerequisites

- Node.js 18+ and npm
- For mobile development:
  - Android Studio (for Android)
  - Xcode (for iOS, macOS only)

## Installation

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npm run dev
```

3. Open http://localhost:3000 in your browser

## API Configuration

The app connects to a backend API at `http://localhost:8080`. Update the base URL in `src/api/axiosClient.ts` if your API is hosted elsewhere.

### API Endpoints

- `GET /v1/receipts` - List receipts with pagination
- `POST /v1/receipts` - Create manual receipt
- `POST /v1/receipts/scan` - Scan receipt image
- `GET /v1/receipts/:id` - Get receipt details
- `PUT /v1/receipts/:id` - Update receipt
- `DELETE /v1/receipts/:id` - Delete receipt
- `GET /v1/dashboard/summary` - Get dashboard analytics

## Building for Mobile

### Android

```bash
npm run build
npm run android
```

### iOS

```bash
npm run build
npm run ios
```

## Project Structure

```
src/
├── api/              # API client and endpoints
├── components/       # Reusable UI components
├── screens/          # Main app screens
├── store/            # Zustand state management
├── types/            # TypeScript type definitions
├── utils/            # Utility functions
├── App.tsx           # Main app component with routing
└── main.tsx          # App entry point
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm run android` - Build and open Android project
- `npm run ios` - Build and open iOS project
- `npm run sync` - Sync Capacitor platforms

## Environment Variables

Create a `.env` file in the root directory:

```env
VITE_API_BASE_URL=http://localhost:8080
```

## License

MIT
