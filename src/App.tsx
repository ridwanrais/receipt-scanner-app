import React, { useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate, useLocation, Link } from 'react-router-dom';
import { Home } from './screens/Home';
import { Capture } from './screens/Capture';
import { ReceiptDetail } from './screens/ReceiptDetail';
import { AddReceipt } from './screens/AddReceipt';
import { EditReceipt } from './screens/EditReceipt';
import { Dashboard } from './screens/Dashboard';
import Login from './pages/Login';
import AuthCallback from './pages/AuthCallback';
import ProtectedRoute from './components/ProtectedRoute';
import { useAuthStore } from './stores/authStore';

const BottomNav: React.FC = () => {
    const location = useLocation();

    const isActive = (path: string) => {
        return location.pathname === path || location.pathname.startsWith(path + '/');
    };

    return (
        <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 shadow-lg z-50">
            <div className="flex justify-around items-center h-16">
                <Link
                    to="/"
                    className={`flex flex-col items-center justify-center flex-1 h-full ${isActive('/') && !isActive('/receipt') && !isActive('/add-receipt')
                        ? 'text-primary-600'
                        : 'text-gray-600'
                        }`}
                >
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                    </svg>
                    <span className="text-xs mt-1">Home</span>
                </Link>

                <Link
                    to="/capture"
                    className={`flex flex-col items-center justify-center flex-1 h-full ${isActive('/capture') || isActive('/add-receipt')
                        ? 'text-primary-600'
                        : 'text-gray-600'
                        }`}
                >
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    <span className="text-xs mt-1">Capture</span>
                </Link>

                <Link
                    to="/dashboard"
                    className={`flex flex-col items-center justify-center flex-1 h-full ${isActive('/dashboard') ? 'text-primary-600' : 'text-gray-600'
                        }`}
                >
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                    </svg>
                    <span className="text-xs mt-1">Dashboard</span>
                </Link>
            </div>
        </nav>
    );
};

function App() {
    const { loadStoredAuth, isAuthenticated } = useAuthStore();

    useEffect(() => {
        // Load stored authentication on app start
        loadStoredAuth();
    }, [loadStoredAuth]);

    return (
        <BrowserRouter>
            <div className="App">
                <Routes>
                    {/* Public routes */}
                    <Route path="/login" element={<Login />} />
                    <Route path="/auth/callback" element={<AuthCallback />} />

                    {/* Protected routes */}
                    <Route
                        path="/"
                        element={
                            <ProtectedRoute>
                                <Home />
                            </ProtectedRoute>
                        }
                    />
                    <Route
                        path="/capture"
                        element={
                            <ProtectedRoute>
                                <Capture />
                            </ProtectedRoute>
                        }
                    />
                    <Route
                        path="/receipt/:receiptId"
                        element={
                            <ProtectedRoute>
                                <ReceiptDetail />
                            </ProtectedRoute>
                        }
                    />
                    <Route
                        path="/receipt/:receiptId/edit"
                        element={
                            <ProtectedRoute>
                                <EditReceipt />
                            </ProtectedRoute>
                        }
                    />
                    <Route
                        path="/add-receipt"
                        element={
                            <ProtectedRoute>
                                <AddReceipt />
                            </ProtectedRoute>
                        }
                    />
                    <Route
                        path="/dashboard"
                        element={
                            <ProtectedRoute>
                                <Dashboard />
                            </ProtectedRoute>
                        }
                    />
                    <Route path="*" element={<Navigate to={isAuthenticated ? "/" : "/login"} replace />} />
                </Routes>
                {isAuthenticated && <BottomNav />}
            </div>
        </BrowserRouter>
    );
}

export default App;
