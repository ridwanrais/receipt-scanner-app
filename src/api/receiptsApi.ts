import axiosClient from './axiosClient';
import type {
    Receipt,
    ReceiptResponse,
    ReceiptsListResponse,
    ReceiptsQueryParams,
} from '../types/api';

export const receiptsApi = {
    // List receipts with pagination and filters
    list: async (params?: ReceiptsQueryParams): Promise<ReceiptsListResponse> => {
        const response = await axiosClient.get<ReceiptsListResponse>('/v1/receipts', {
            params,
        });
        return response.data;
    },

    // Get single receipt by ID
    getById: async (receiptId: string): Promise<ReceiptResponse> => {
        const response = await axiosClient.get<ReceiptResponse>(`/v1/receipts/${receiptId}`);
        return response.data;
    },

    // Create manual receipt
    create: async (receipt: Receipt): Promise<ReceiptResponse> => {
        const response = await axiosClient.post<ReceiptResponse>('/v1/receipts', receipt);
        return response.data;
    },

    // Update receipt
    update: async (receiptId: string, receipt: Receipt): Promise<ReceiptResponse> => {
        const response = await axiosClient.put<ReceiptResponse>(
            `/v1/receipts/${receiptId}`,
            receipt
        );
        return response.data;
    },

    // Delete receipt
    delete: async (receiptId: string): Promise<void> => {
        await axiosClient.delete(`/v1/receipts/${receiptId}`);
    },

    // Scan receipt image
    scan: async (imageFile: File): Promise<ReceiptResponse> => {
        const formData = new FormData();
        formData.append('receiptImage', imageFile);

        const response = await axiosClient.post<ReceiptResponse>(
            '/v1/receipts/scan',
            formData,
            {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            }
        );
        return response.data;
    },
};
