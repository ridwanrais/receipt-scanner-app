import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { receiptsApi } from '../api/receiptsApi';
import { useReceiptsStore } from '../store/receiptsStore';
import { Card, CardBody } from '../components/Card';
import { Button } from '../components/Button';
import { Input } from '../components/Input';
import { formatCurrency, formatDate } from '../utils/formatters';
import type { ReceiptsQueryParams } from '../types/api';

export const Home: React.FC = () => {
    const navigate = useNavigate();
    const { receipts, pagination, setReceipts, setLoading, isLoading, error, setError } = useReceiptsStore();

    const [filters, setFilters] = useState<ReceiptsQueryParams>({
        page: 1,
        limit: 10,
        startDate: '',
        endDate: '',
        merchant: '',
    });

    const fetchReceipts = async () => {
        try {
            setLoading(true);
            setError(null);

            const params: ReceiptsQueryParams = {
                page: filters.page,
                limit: filters.limit,
            };

            if (filters.startDate) params.startDate = filters.startDate;
            if (filters.endDate) params.endDate = filters.endDate;
            if (filters.merchant) params.merchant = filters.merchant;

            const response = await receiptsApi.list(params);
            setReceipts(response.data, response.pagination);
        } catch (err: any) {
            setError(err.message || 'Failed to load receipts');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchReceipts();
    }, [filters.page, filters.limit]);

    const handleSearch = () => {
        setFilters({ ...filters, page: 1 });
        fetchReceipts();
    };

    const handleClearFilters = () => {
        setFilters({
            page: 1,
            limit: 10,
            startDate: '',
            endDate: '',
            merchant: '',
        });
    };

    const handleNextPage = () => {
        if (pagination && filters.page! < pagination.totalPages) {
            setFilters({ ...filters, page: filters.page! + 1 });
        }
    };

    const handlePrevPage = () => {
        if (filters.page! > 1) {
            setFilters({ ...filters, page: filters.page! - 1 });
        }
    };

    return (
        <div className="min-h-screen bg-gray-50 pb-20">
            <div className="bg-primary-600 text-white p-4 shadow-md">
                <h1 className="text-2xl font-bold">My Receipts</h1>
                <p className="text-primary-100 text-sm mt-1">
                    {pagination ? `${pagination.totalItems} total receipts` : 'Loading...'}
                </p>
            </div>

            <div className="p-4 space-y-4">
                {/* Filters */}
                <Card>
                    <CardBody>
                        <div className="space-y-3">
                            <Input
                                type="text"
                                placeholder="Search by merchant..."
                                value={filters.merchant}
                                onChange={(e) => setFilters({ ...filters, merchant: e.target.value })}
                            />
                            <div className="grid grid-cols-2 gap-3">
                                <Input
                                    type="date"
                                    label="Start Date"
                                    value={filters.startDate}
                                    onChange={(e) => setFilters({ ...filters, startDate: e.target.value })}
                                />
                                <Input
                                    type="date"
                                    label="End Date"
                                    value={filters.endDate}
                                    onChange={(e) => setFilters({ ...filters, endDate: e.target.value })}
                                />
                            </div>
                            <div className="flex gap-2">
                                <Button onClick={handleSearch} className="flex-1">
                                    Apply Filters
                                </Button>
                                <Button onClick={handleClearFilters} variant="secondary">
                                    Clear
                                </Button>
                            </div>
                        </div>
                    </CardBody>
                </Card>

                {/* Error Display */}
                {error && (
                    <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                        {error}
                    </div>
                )}

                {/* Loading State */}
                {isLoading && (
                    <div className="text-center py-8">
                        <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                        <p className="text-gray-600 mt-2">Loading receipts...</p>
                    </div>
                )}

                {/* Receipts List */}
                {!isLoading && receipts.length === 0 && (
                    <div className="text-center py-12">
                        <p className="text-gray-500 text-lg">No receipts found</p>
                        <p className="text-gray-400 text-sm mt-2">Try scanning a receipt or adjusting your filters</p>
                    </div>
                )}

                {!isLoading && receipts.length > 0 && (
                    <div className="space-y-3">
                        {receipts.map((receipt) => (
                            <Card
                                key={receipt.id}
                                onClick={() => navigate(`/receipt/${receipt.id}`)}
                            >
                                <CardBody>
                                    <div className="flex justify-between items-start">
                                        <div className="flex-1">
                                            <h3 className="font-semibold text-gray-900 text-lg">
                                                {receipt.merchant}
                                            </h3>
                                            <p className="text-gray-500 text-sm mt-1">
                                                {formatDate(receipt.date)}
                                            </p>
                                        </div>
                                        <div className="text-right">
                                            <p className="text-xl font-bold text-primary-600">
                                                {formatCurrency(receipt.total)}
                                            </p>
                                            <p className="text-xs text-gray-500 mt-1">
                                                {receipt.items.length} items
                                            </p>
                                        </div>
                                    </div>
                                </CardBody>
                            </Card>
                        ))}
                    </div>
                )}

                {/* Pagination */}
                {pagination && pagination.totalPages > 1 && (
                    <div className="flex justify-between items-center pt-4">
                        <Button
                            onClick={handlePrevPage}
                            disabled={filters.page === 1}
                            variant="secondary"
                            size="sm"
                        >
                            Previous
                        </Button>
                        <span className="text-sm text-gray-600">
                            Page {filters.page} of {pagination.totalPages}
                        </span>
                        <Button
                            onClick={handleNextPage}
                            disabled={filters.page === pagination.totalPages}
                            variant="secondary"
                            size="sm"
                        >
                            Next
                        </Button>
                    </div>
                )}
            </div>
        </div>
    );
};
