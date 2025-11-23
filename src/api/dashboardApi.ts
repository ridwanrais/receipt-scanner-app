import axiosClient from './axiosClient';
import type { DashboardSummaryResponse, DashboardQueryParams } from '../types/api';

export const dashboardApi = {
    // Get dashboard summary with optional date filters
    getSummary: async (params?: DashboardQueryParams): Promise<DashboardSummaryResponse> => {
        const response = await axiosClient.get<DashboardSummaryResponse>(
            '/v1/dashboard/summary',
            { params }
        );
        return response.data;
    },
};
