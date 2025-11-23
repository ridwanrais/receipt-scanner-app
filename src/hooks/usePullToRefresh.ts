import { useEffect, useRef, useState } from 'react';

interface UsePullToRefreshOptions {
    onRefresh: () => Promise<void>;
    threshold?: number;
    resistance?: number;
}

export const usePullToRefresh = ({
    onRefresh,
    threshold = 80,
    resistance = 2.5,
}: UsePullToRefreshOptions) => {
    const [isRefreshing, setIsRefreshing] = useState(false);
    const [pullDistance, setPullDistance] = useState(0);
    const containerRef = useRef<HTMLDivElement>(null);
    const startY = useRef(0);
    const currentY = useRef(0);
    const isDragging = useRef(false);

    useEffect(() => {
        const container = containerRef.current;
        if (!container) return;

        const handleTouchStart = (e: TouchEvent) => {
            // Only start if we're at the top of the scroll container
            if (container.scrollTop === 0 && !isRefreshing) {
                startY.current = e.touches[0].clientY;
                isDragging.current = true;
            }
        };

        const handleTouchMove = (e: TouchEvent) => {
            if (!isDragging.current || isRefreshing) return;

            currentY.current = e.touches[0].clientY;
            const diff = currentY.current - startY.current;

            // Only pull down, not up
            if (diff > 0) {
                // Prevent default scrolling when pulling
                if (container.scrollTop === 0) {
                    e.preventDefault();
                }

                // Apply resistance to make it feel natural
                const distance = Math.min(diff / resistance, threshold * 1.5);
                setPullDistance(distance);
            }
        };

        const handleTouchEnd = async () => {
            if (!isDragging.current || isRefreshing) {
                isDragging.current = false;
                return;
            }

            isDragging.current = false;

            if (pullDistance >= threshold) {
                setIsRefreshing(true);
                setPullDistance(threshold);

                try {
                    await onRefresh();
                } finally {
                    setIsRefreshing(false);
                    setPullDistance(0);
                }
            } else {
                setPullDistance(0);
            }
        };

        container.addEventListener('touchstart', handleTouchStart, { passive: true });
        container.addEventListener('touchmove', handleTouchMove, { passive: false });
        container.addEventListener('touchend', handleTouchEnd, { passive: true });

        return () => {
            container.removeEventListener('touchstart', handleTouchStart);
            container.removeEventListener('touchmove', handleTouchMove);
            container.removeEventListener('touchend', handleTouchEnd);
        };
    }, [isRefreshing, pullDistance, threshold, resistance, onRefresh]);

    return {
        containerRef,
        isRefreshing,
        pullDistance,
    };
};
