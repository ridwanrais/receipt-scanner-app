import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { receiptsApi } from '../api/receiptsApi';
import { useReceiptsStore } from '../store/receiptsStore';
import { Card, CardBody, CardHeader } from '../components/Card';
import { Button } from '../components/Button';
import { Input } from '../components/Input';
import { formatDateForApi, formatCurrency } from '../utils/formatters';
import type { Receipt, ReceiptItem } from '../types/api';

export const EditReceipt: React.FC = () => {
    const { receiptId } = useParams<{ receiptId: string }>();
    const navigate = useNavigate();
    const { updateReceipt } = useReceiptsStore();
    const [isLoading, setIsLoading] = useState(true);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const [formData, setFormData] = useState<Receipt>({
        merchant: '',
        date: formatDateForApi(new Date()),
        subtotal: 0,
        tax: 0,
        total: 0,
        items: [],
    });

    const [currentItem, setCurrentItem] = useState<ReceiptItem>({
        name: '',
        qty: 1,
        price: 0,
        category: '',
    });

    // Get default currency from existing items or use USD
    const getDefaultCurrency = () => {
        if (formData.items.length > 0 && formData.items[0].currency) {
            return formData.items[0].currency;
        }
        return 'USD';
    };

    const fetchReceipt = async () => {
        try {
            setIsLoading(true);
            setError(null);
            const receipt = await receiptsApi.getById(receiptId!);

            // Convert response to form data
            setFormData({
                id: receipt.id,
                merchant: receipt.merchant,
                date: receipt.date,
                subtotal: parseFloat(receipt.subtotal),
                tax: parseFloat(receipt.tax),
                total: parseFloat(receipt.total),
                items: receipt.items.map(item => ({
                    id: item.id,
                    name: item.name,
                    qty: item.qty,
                    price: parseFloat(item.price),
                    category: item.category,
                    currency: item.currency,
                })),
            });
        } catch (err: any) {
            setError(err.message || 'Failed to load receipt');
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        if (receiptId) {
            fetchReceipt();
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [receiptId]);

    const handleAddItem = () => {
        if (!currentItem.name || currentItem.price <= 0) {
            setError('Please fill in item name and price');
            return;
        }

        // Add item with currency from existing items or default to USD
        const itemWithCurrency = {
            ...currentItem,
            currency: getDefaultCurrency(),
        };

        const newItems = [...formData.items, itemWithCurrency];

        // Recalculate subtotal and total
        const subtotal = newItems.reduce((sum, item) => sum + (item.price * item.qty), 0);
        const total = subtotal + formData.tax;

        setFormData({
            ...formData,
            items: newItems,
            subtotal,
            total,
        });

        setCurrentItem({
            name: '',
            qty: 1,
            price: 0,
            category: '',
        });
        setError(null);
    };

    const handleRemoveItem = (index: number) => {
        const newItems = formData.items.filter((_, i) => i !== index);

        // Recalculate subtotal and total
        const subtotal = newItems.reduce((sum, item) => sum + (item.price * item.qty), 0);
        const total = subtotal + formData.tax;

        setFormData({
            ...formData,
            items: newItems,
            subtotal,
            total,
        });
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!formData.merchant) {
            setError('Merchant name is required');
            return;
        }

        if (formData.items.length === 0) {
            setError('Please add at least one item');
            return;
        }

        try {
            setIsSubmitting(true);
            setError(null);

            const receipt = await receiptsApi.update(receiptId!, formData);
            updateReceipt(receipt);
            navigate(`/receipt/${receipt.id}`);
        } catch (err: any) {
            setError(err.message || 'Failed to update receipt');
        } finally {
            setIsSubmitting(false);
        }
    };

    if (isLoading) {
        return (
            <div className="min-h-screen bg-gray-50 flex items-center justify-center">
                <div className="text-center">
                    <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
                    <p className="text-gray-600 mt-4">Loading receipt...</p>
                </div>
            </div>
        );
    }

    if (error && !formData.id) {
        return (
            <div className="min-h-screen bg-gray-50 p-4">
                <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                    {error}
                </div>
                <Button onClick={() => navigate('/')} className="mt-4">
                    Back to Home
                </Button>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gray-50 pb-20">
            <div className="bg-primary-600 text-white p-4 shadow-md">
                <div className="flex items-center">
                    <button
                        onClick={() => navigate(`/receipt/${receiptId}`)}
                        className="mr-3"
                    >
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                        </svg>
                    </button>
                    <div>
                        <h1 className="text-2xl font-bold">Edit Receipt</h1>
                        <p className="text-primary-100 text-sm mt-1">Update receipt details</p>
                    </div>
                </div>
            </div>

            <form onSubmit={handleSubmit} className="p-4 space-y-4">
                {/* Error Display */}
                {error && (
                    <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                        {error}
                    </div>
                )}

                {/* Basic Info */}
                <Card>
                    <CardHeader>
                        <h2 className="text-lg font-semibold text-gray-900">Receipt Information</h2>
                    </CardHeader>
                    <CardBody>
                        <div className="space-y-3">
                            <Input
                                label="Merchant Name"
                                type="text"
                                value={formData.merchant}
                                onChange={(e) => setFormData({ ...formData, merchant: e.target.value })}
                                required
                            />
                            <Input
                                label="Date"
                                type="date"
                                value={formData.date}
                                onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                                required
                            />
                            <Input
                                label="Tax Amount"
                                type="number"
                                step="0.01"
                                value={formData.tax}
                                onChange={(e) => {
                                    const tax = parseFloat(e.target.value) || 0;
                                    const subtotal = formData.items.reduce((sum, item) => sum + (item.price * item.qty), 0);
                                    setFormData({ ...formData, tax, total: subtotal + tax });
                                }}
                            />
                        </div>
                    </CardBody>
                </Card>

                {/* Add Item */}
                <Card>
                    <CardHeader>
                        <h2 className="text-lg font-semibold text-gray-900">Add Item</h2>
                    </CardHeader>
                    <CardBody>
                        <div className="space-y-3">
                            <Input
                                label="Item Name"
                                type="text"
                                value={currentItem.name}
                                onChange={(e) => setCurrentItem({ ...currentItem, name: e.target.value })}
                            />
                            <Input
                                label="Category"
                                type="text"
                                value={currentItem.category}
                                onChange={(e) => setCurrentItem({ ...currentItem, category: e.target.value })}
                                placeholder="e.g., Food, Electronics"
                            />
                            <div className="grid grid-cols-2 gap-3">
                                <Input
                                    label="Quantity"
                                    type="number"
                                    min="1"
                                    value={currentItem.qty}
                                    onChange={(e) => setCurrentItem({ ...currentItem, qty: parseInt(e.target.value) || 1 })}
                                />
                                <Input
                                    label="Price"
                                    type="number"
                                    step="0.01"
                                    min="0"
                                    value={currentItem.price}
                                    onChange={(e) => setCurrentItem({ ...currentItem, price: parseFloat(e.target.value) || 0 })}
                                />
                            </div>
                            <Button type="button" onClick={handleAddItem} variant="secondary" className="w-full">
                                Add Item
                            </Button>
                        </div>
                    </CardBody>
                </Card>

                {/* Items List */}
                {formData.items.length > 0 && (
                    <Card>
                        <CardHeader>
                            <h2 className="text-lg font-semibold text-gray-900">
                                Items ({formData.items.length})
                            </h2>
                        </CardHeader>
                        <CardBody>
                            <div className="space-y-3">
                                {formData.items.map((item, index) => (
                                    <div key={item.id || index} className="flex justify-between items-start pb-3 border-b border-gray-200 last:border-0 last:pb-0">
                                        <div className="flex-1">
                                            <p className="font-semibold text-gray-900">{item.name}</p>
                                            <p className="text-sm text-gray-500">
                                                {item.category} • Qty: {item.qty} • {formatCurrency(item.price, item.currency)}
                                            </p>
                                        </div>
                                        <button
                                            type="button"
                                            onClick={() => handleRemoveItem(index)}
                                            className="text-red-600 hover:text-red-800"
                                        >
                                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                            </svg>
                                        </button>
                                    </div>
                                ))}
                            </div>
                        </CardBody>
                    </Card>
                )}

                {/* Total */}
                <Card>
                    <CardBody>
                        <div className="space-y-2">
                            <div className="flex justify-between text-gray-600">
                                <span>Subtotal</span>
                                <span>{formatCurrency(formData.subtotal, getDefaultCurrency())}</span>
                            </div>
                            <div className="flex justify-between text-gray-600">
                                <span>Tax</span>
                                <span>{formatCurrency(formData.tax, getDefaultCurrency())}</span>
                            </div>
                            <div className="flex justify-between pt-2 border-t border-gray-200">
                                <span className="text-lg font-semibold text-gray-900">Total</span>
                                <span className="text-lg font-bold text-primary-600">
                                    {formatCurrency(formData.total, getDefaultCurrency())}
                                </span>
                            </div>
                        </div>
                    </CardBody>
                </Card>

                {/* Submit Button */}
                <Button
                    type="submit"
                    className="w-full py-3"
                    isLoading={isSubmitting}
                    disabled={formData.items.length === 0}
                >
                    Update Receipt
                </Button>
            </form>
        </div>
    );
};
