import React, { useEffect, useState } from 'react';
import { dashboardApi } from '../api/dashboardApi';
import { Card, CardBody, CardHeader } from '../components/Card';
import { Chart, StatCard } from '../components/Chart';
import { Input } from '../components/Input';
import { Button } from '../components/Button';
import { usePullToRefresh } from '../hooks/usePullToRefresh';
import { PullToRefreshIndicator } from '../components/PullToRefresh';
import type { DashboardSummaryResponse } from '../types/api';

export const Dashboard: React.FC = () => {
    const [summary, setSummary] = useState<DashboardSummaryResponse | null>(null);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [startDate, setStartDate] = useState('');
    const [endDate, setEndDate] = useState('');

    useEffect(() => {
        fetchSummary();
    }, []);

    const fetchSummary = async () => {
        try {
            setIsLoading(true);
            setError(null);

            const params: any = {};
            if (startDate) params.startDate = startDate;
            if (endDate) params.endDate = endDate;

            const data = await dashboardApi.getSummary(params);
            setSummary(data);
        } catch (err: any) {
            setError(err.message || 'Failed to load dashboard');
        } finally {
            setIsLoading(false);
        }
    };

    const handleApplyFilter = () => {
        fetchSummary();
    };

    const handleClearFilter = () => {
        setStartDate('');
        setEndDate('');
        setTimeout(() => fetchSummary(), 100);
    };

    const handleRefresh = async () => {
        await fetchSummary();
    };

    const { containerRef, isRefreshing, pullDistance } = usePullToRefresh({
        onRefresh: handleRefresh,
    });

    if (isLoading && !summary) {
        return (
            <div ref={containerRef} className="min-h-screen bg-gray-50 flex items-center justify-center pb-20 overflow-y-auto">
                <PullToRefreshIndicator
                    pullDistance={pullDistance}
                    isRefreshing={isRefreshing}
                />
                <div className="text-center">
                    <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
                    <p className="text-gray-600 mt-4">Loading dashboard...</p>
                </div>
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
                <h1 className="text-2xl font-bold">Dashboard</h1>
                <p className="text-primary-100 text-sm mt-1">Analytics and insights</p>
            </div>

            <div className="p-4 space-y-4">
                {/* Date Filter */}
                <Card>
                    <CardBody>
                        <div className="space-y-3">
                            <div className="grid grid-cols-2 gap-3">
                                <Input
                                    type="date"
                                    label="Start Date"
                                    value={startDate}
                                    onChange={(e) => setStartDate(e.target.value)}
                                />
                                <Input
                                    type="date"
                                    label="End Date"
                                    value={endDate}
                                    onChange={(e) => setEndDate(e.target.value)}
                                />
                            </div>
                            <div className="flex gap-2">
                                <Button onClick={handleApplyFilter} className="flex-1" isLoading={isLoading}>
                                    Apply Filter
                                </Button>
                                <Button onClick={handleClearFilter} variant="secondary">
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

                {/* Summary Stats */}
                {summary && (
                    <>
                        <div className="grid grid-cols-1 gap-4">
                            <StatCard
                                title="Total Spend"
                                value={`$${parseFloat(summary.totalSpend).toFixed(2)}`}
                                icon={
                                    <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                }
                            />
                            <StatCard
                                title="Average Spend"
                                value={`$${parseFloat(summary.averageSpend).toFixed(2)}`}
                                icon={
                                    <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                                    </svg>
                                }
                            />
                            <StatCard
                                title="Receipt Count"
                                value={summary.receiptCount.toString()}
                                icon={
                                    <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                    </svg>
                                }
                            />
                        </div>

                        {/* Top Categories Chart */}
                        {summary.topCategories && summary.topCategories.length > 0 && (
                            <Card>
                                <CardHeader>
                                    <h2 className="text-lg font-semibold text-gray-900">Top Categories</h2>
                                </CardHeader>
                                <CardBody>
                                    <Chart
                                        data={summary.topCategories.map(cat => ({
                                            name: cat.category,
                                            value: parseFloat(cat.amount),
                                            percentage: cat.percentage,
                                        }))}
                                        height={250}
                                    />
                                    <div className="mt-4 space-y-2">
                                        {summary.topCategories.map((cat, index) => (
                                            <div key={index} className="flex justify-between items-center text-sm">
                                                <span className="text-gray-700">{cat.category}</span>
                                                <div className="text-right">
                                                    <span className="font-semibold text-gray-900">
                                                        ${parseFloat(cat.amount).toFixed(2)}
                                                    </span>
                                                    <span className="text-gray-500 ml-2">
                                                        ({cat.percentage.toFixed(1)}%)
                                                    </span>
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                </CardBody>
                            </Card>
                        )}

                        {/* Top Merchants Chart */}
                        {summary.topMerchants && summary.topMerchants.length > 0 && (
                            <Card>
                                <CardHeader>
                                    <h2 className="text-lg font-semibold text-gray-900">Top Merchants</h2>
                                </CardHeader>
                                <CardBody>
                                    <Chart
                                        data={summary.topMerchants.map(merchant => ({
                                            name: merchant.merchant,
                                            value: parseFloat(merchant.amount),
                                            percentage: merchant.percentage,
                                        }))}
                                        height={250}
                                    />
                                    <div className="mt-4 space-y-2">
                                        {summary.topMerchants.map((merchant, index) => (
                                            <div key={index} className="flex justify-between items-center text-sm">
                                                <span className="text-gray-700">{merchant.merchant}</span>
                                                <div className="text-right">
                                                    <span className="font-semibold text-gray-900">
                                                        ${parseFloat(merchant.amount).toFixed(2)}
                                                    </span>
                                                    <span className="text-gray-500 ml-2">
                                                        ({merchant.percentage.toFixed(1)}%)
                                                    </span>
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                </CardBody>
                            </Card>
                        )}

                        {/* Empty State */}
                        {(!summary.topCategories || summary.topCategories.length === 0) &&
                            (!summary.topMerchants || summary.topMerchants.length === 0) && (
                                <Card>
                                    <CardBody>
                                        <div className="text-center py-8">
                                            <p className="text-gray-500">No data available for the selected period</p>
                                        </div>
                                    </CardBody>
                                </Card>
                            )}
                    </>
                )}
            </div>
        </div>
    );
};
