// Domain models - for request payloads
export interface Receipt {
    id?: string;
    merchant: string;
    date: string;
    subtotal: number;
    tax: number;
    total: number;
    items: ReceiptItem[];
    image_url?: string;
    created_at?: string;
    updated_at?: string;
}

export interface ReceiptItem {
    id?: string;
    name: string;
    qty: number;
    price: number;
    category: string;
}

// Response models
export interface ReceiptResponse {
    id: string;
    merchant: string;
    date: string;
    subtotal: string;
    tax: string;
    total: string;
    items: ReceiptItemResponse[];
    createdAt: string;
    updatedAt: string;
}

export interface ReceiptItemResponse {
    id: string;
    name: string;
    qty: number;
    price: string;
    category: string;
}

export interface ReceiptsListResponse {
    data: ReceiptResponse[];
    pagination: PaginationResponse;
}

export interface PaginationResponse {
    currentPage: number;
    limit: number;
    totalItems: number;
    totalPages: number;
}

export interface ErrorDetail {
    field: string;
    message: string;
}

export interface ErrorResponse {
    status: string;
    message: string;
    details?: ErrorDetail[];
}

// Dashboard models
export interface DashboardSummaryResponse {
    totalSpend: string;
    averageSpend: string;
    receiptCount: number;
    topCategories: CategorySummary[];
    topMerchants: MerchantSummary[];
}

export interface CategorySummary {
    category: string;
    amount: string;
    percentage: number;
}

export interface MerchantSummary {
    merchant: string;
    amount: string;
    percentage: number;
}

// Query parameters
export interface ReceiptsQueryParams {
    page?: number;
    limit?: number;
    startDate?: string;
    endDate?: string;
    merchant?: string;
}

export interface DashboardQueryParams {
    startDate?: string;
    endDate?: string;
}
