import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { receiptsApi } from '../api/receiptsApi';
import { useReceiptsStore } from '../store/receiptsStore';
import { Card, CardBody, CardHeader } from '../components/Card';
import { Button } from '../components/Button';
import { formatCurrency, formatDate } from '../utils/formatters';
import { usePullToRefresh } from '../hooks/usePullToRefresh';
import { PullToRefreshIndicator } from '../components/PullToRefresh';

export const ReceiptDetail: React.FC = () => {
    const { receiptId } = useParams<{ receiptId: string }>();
    const navigate = useNavigate();
    const { selectedReceipt, setSelectedReceipt, removeReceipt, updateReceipt } = useReceiptsStore();
    const [isLoading, setIsLoading] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);
    const [isRetryScanning, setIsRetryScanning] = useState(false);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        if (receiptId) {
            fetchReceipt();
        }
    }, [receiptId]);

    const fetchReceipt = async () => {
        try {
            setIsLoading(true);
            setError(null);
            const receipt = await receiptsApi.getById(receiptId!);
            setSelectedReceipt(receipt);
        } catch (err: any) {
            setError(err.message || 'Failed to load receipt');
        } finally {
            setIsLoading(false);
        }
    };

    const handleDelete = async () => {
        if (!window.confirm('Are you sure you want to delete this receipt?')) {
            return;
        }

        try {
            setIsDeleting(true);
            await receiptsApi.delete(receiptId!);
            removeReceipt(receiptId!);
            navigate('/');
        } catch (err: any) {
            setError(err.message || 'Failed to delete receipt');
        } finally {
            setIsDeleting(false);
        }
    };

    const handleEdit = () => {
        navigate(`/receipt/${receiptId}/edit`);
    };

    const handleRetryScan = async () => {
        if (!window.confirm('Are you sure you want to retry scanning this receipt? This will overwrite the current data.')) {
            return;
        }

        try {
            setIsRetryScanning(true);
            setError(null);
            const updatedReceipt = await receiptsApi.retryScan(receiptId!);
            setSelectedReceipt(updatedReceipt);
            updateReceipt(updatedReceipt);
        } catch (err: any) {
            setError(err.message || 'Failed to retry scan receipt');
        } finally {
            setIsRetryScanning(false);
        }
    };

    const handleRefresh = async () => {
        await fetchReceipt();
    };

    const { containerRef, isRefreshing, pullDistance } = usePullToRefresh({
        onRefresh: handleRefresh,
    });

    if (isLoading) {
        return (
            <div ref={containerRef} className="min-h-screen bg-gray-50 flex items-center justify-center overflow-y-auto">
                <PullToRefreshIndicator
                    pullDistance={pullDistance}
                    isRefreshing={isRefreshing}
                />
                <div className="text-center">
                    <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
                    <p className="text-gray-600 mt-4">Loading receipt...</p>
                </div>
            </div>
        );
    }

    if (error || !selectedReceipt) {
        return (
            <div ref={containerRef} className="min-h-screen bg-gray-50 p-4 overflow-y-auto">
                <PullToRefreshIndicator
                    pullDistance={pullDistance}
                    isRefreshing={isRefreshing}
                />
                <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                    {error || 'Receipt not found'}
                </div>
                <Button onClick={() => navigate('/')} className="mt-4">
                    Back to Home
                </Button>
            </div>
        );
    }

    return (
        <div ref={containerRef} className="min-h-screen bg-gray-50 pb-20 overflow-y-auto">
            <PullToRefreshIndicator
                pullDistance={pullDistance}
                isRefreshing={isRefreshing}
            />
            <div className="bg-primary-600 text-white p-4 shadow-md">
                <div className="flex items-center">
                    <button
                        onClick={() => navigate('/')}
                        className="mr-3"
                    >
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                        </svg>
                    </button>
                    <div>
                        <h1 className="text-2xl font-bold">Receipt Details</h1>
                        <p className="text-primary-100 text-sm mt-1">{selectedReceipt.merchant}</p>
                    </div>
                </div>
            </div>

            <div className="p-4 space-y-4">
                {/* Summary Card */}
                <Card>
                    <CardHeader>
                        <h2 className="text-lg font-semibold text-gray-900">Summary</h2>
                    </CardHeader>
                    <CardBody>
                        <div className="space-y-3">
                            <div className="flex justify-between">
                                <span className="text-gray-600">Merchant</span>
                                <span className="font-semibold text-gray-900">{selectedReceipt.merchant}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-gray-600">Date</span>
                                <span className="font-semibold text-gray-900">{formatDate(selectedReceipt.date)}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-gray-600">Subtotal</span>
                                <span className="font-semibold text-gray-900">{formatCurrency(selectedReceipt.subtotal, selectedReceipt.items[0]?.currency || 'USD')}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-gray-600">Tax</span>
                                <span className="font-semibold text-gray-900">{formatCurrency(selectedReceipt.tax, selectedReceipt.items[0]?.currency || 'USD')}</span>
                            </div>
                            <div className="flex justify-between pt-3 border-t border-gray-200">
                                <span className="text-lg font-semibold text-gray-900">Total</span>
                                <span className="text-lg font-bold text-primary-600">{formatCurrency(selectedReceipt.total, selectedReceipt.items[0]?.currency || 'USD')}</span>
                            </div>
                        </div>
                    </CardBody>
                </Card>

                {/* Items Card */}
                <Card>
                    <CardHeader>
                        <h2 className="text-lg font-semibold text-gray-900">
                            Items ({selectedReceipt.items.length})
                        </h2>
                    </CardHeader>
                    <CardBody>
                        <div className="space-y-3">
                            {selectedReceipt.items.map((item, index) => (
                                <div key={item.id || index} className="pb-3 border-b border-gray-200 last:border-0 last:pb-0">
                                    <div className="flex justify-between items-start">
                                        <div className="flex-1">
                                            <p className="font-semibold text-gray-900">{item.name}</p>
                                            <p className="text-sm text-gray-500 mt-1">
                                                {item.category} • Qty: {item.qty}
                                            </p>
                                        </div>
                                        <p className="font-semibold text-gray-900">{formatCurrency(item.price, item.currency)}</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardBody>
                </Card>

                {/* Action Buttons */}
                <div className="space-y-3">
                    <Button onClick={handleEdit} className="w-full">
                        Edit Receipt
                    </Button>
                    {selectedReceipt.receipt_url && (
                        <Button
                            onClick={handleRetryScan}
                            variant="secondary"
                            className="w-full"
                            isLoading={isRetryScanning}
                        >
                            Retry Scan
                        </Button>
                    )}
                    <Button
                        onClick={handleDelete}
                        variant="danger"
                        className="w-full"
                        isLoading={isDeleting}
                    >
                        Delete Receipt
                    </Button>
                </div>

                {/* Metadata */}
                <Card>
                    <CardBody>
                        <p className="text-xs text-gray-500">
                            Created: {formatDate(selectedReceipt.createdAt)}
                        </p>
                        <p className="text-xs text-gray-500 mt-1">
                            Updated: {formatDate(selectedReceipt.updatedAt)}
                        </p>
                    </CardBody>
                </Card>
            </div>
        </div>
    );
};
