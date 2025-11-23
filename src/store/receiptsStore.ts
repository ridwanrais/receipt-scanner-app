import { create } from 'zustand';
import type { ReceiptResponse, PaginationResponse } from '../types/api';

interface ReceiptsState {
    receipts: ReceiptResponse[];
    pagination: PaginationResponse | null;
    selectedReceipt: ReceiptResponse | null;
    isLoading: boolean;
    error: string | null;

    // Actions
    setReceipts: (receipts: ReceiptResponse[], pagination: PaginationResponse) => void;
    setSelectedReceipt: (receipt: ReceiptResponse | null) => void;
    addReceipt: (receipt: ReceiptResponse) => void;
    updateReceipt: (receipt: ReceiptResponse) => void;
    removeReceipt: (receiptId: string) => void;
    setLoading: (isLoading: boolean) => void;
    setError: (error: string | null) => void;
    clearError: () => void;
}

export const useReceiptsStore = create<ReceiptsState>((set) => ({
    receipts: [],
    pagination: null,
    selectedReceipt: null,
    isLoading: false,
    error: null,

    setReceipts: (receipts, pagination) =>
        set({ receipts, pagination }),

    setSelectedReceipt: (receipt) =>
        set({ selectedReceipt: receipt }),

    addReceipt: (receipt) =>
        set((state) => ({
            receipts: [receipt, ...state.receipts],
        })),

    updateReceipt: (receipt) =>
        set((state) => ({
            receipts: state.receipts.map((r) =>
                r.id === receipt.id ? receipt : r
            ),
            selectedReceipt: state.selectedReceipt?.id === receipt.id
                ? receipt
                : state.selectedReceipt,
        })),

    removeReceipt: (receiptId) =>
        set((state) => ({
            receipts: state.receipts.filter((r) => r.id !== receiptId),
            selectedReceipt: state.selectedReceipt?.id === receiptId
                ? null
                : state.selectedReceipt,
        })),

    setLoading: (isLoading) =>
        set({ isLoading }),

    setError: (error) =>
        set({ error }),

    clearError: () =>
        set({ error: null }),
}));
