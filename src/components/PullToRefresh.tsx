import React from 'react';

interface PullToRefreshIndicatorProps {
    pullDistance: number;
    isRefreshing: boolean;
    threshold?: number;
}

export const PullToRefreshIndicator: React.FC<PullToRefreshIndicatorProps> = ({
    pullDistance,
    isRefreshing,
    threshold = 80,
}) => {
    const progress = Math.min(pullDistance / threshold, 1);
    const rotation = progress * 360;

    return (
        <div
            className="absolute top-0 left-0 right-0 flex justify-center items-center transition-all duration-200 ease-out pointer-events-none z-10"
            style={{
                height: `${pullDistance}px`,
                opacity: pullDistance > 0 ? 1 : 0,
            }}
        >
            <div className="bg-white rounded-full shadow-lg p-2">
                {isRefreshing ? (
                    <svg
                        className="w-6 h-6 text-primary-600 animate-spin"
                        fill="none"
                        viewBox="0 0 24 24"
                    >
                        <circle
                            className="opacity-25"
                            cx="12"
                            cy="12"
                            r="10"
                            stroke="currentColor"
                            strokeWidth="4"
                        />
                        <path
                            className="opacity-75"
                            fill="currentColor"
                            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                        />
                    </svg>
                ) : (
                    <svg
                        className="w-6 h-6 text-primary-600 transition-transform duration-200"
                        style={{ transform: `rotate(${rotation}deg)` }}
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                    >
                        <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={2}
                            d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                        />
                    </svg>
                )}
            </div>
        </div>
    );
};
