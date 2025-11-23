import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';
import { receiptsApi } from '../api/receiptsApi';
import { useReceiptsStore } from '../store/receiptsStore';
import { Button } from '../components/Button';
import { Card, CardBody } from '../components/Card';

export const Capture: React.FC = () => {
    const navigate = useNavigate();
    const { addReceipt } = useReceiptsStore();
    const [isProcessing, setIsProcessing] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [preview, setPreview] = useState<string | null>(null);

    const handleCapture = async () => {
        try {
            setError(null);

            const image = await Camera.getPhoto({
                quality: 90,
                allowEditing: false,
                resultType: CameraResultType.Uri,
                source: CameraSource.Camera,
            });

            if (image.webPath) {
                setPreview(image.webPath);
            }

            // Convert image to blob for upload
            const response = await fetch(image.webPath!);
            const blob = await response.blob();
            const file = new File([blob], 'receipt.jpg', { type: 'image/jpeg' });

            setIsProcessing(true);

            const receipt = await receiptsApi.scan(file);
            addReceipt(receipt);

            navigate(`/receipt/${receipt.id}`);
        } catch (err: any) {
            if (err.message && err.message !== 'User cancelled photos app') {
                setError(err.message || 'Failed to scan receipt');
            }
        } finally {
            setIsProcessing(false);
        }
    };

    const handleGallery = async () => {
        try {
            setError(null);

            const image = await Camera.getPhoto({
                quality: 90,
                allowEditing: false,
                resultType: CameraResultType.Uri,
                source: CameraSource.Photos,
            });

            if (image.webPath) {
                setPreview(image.webPath);
            }

            const response = await fetch(image.webPath!);
            const blob = await response.blob();
            const file = new File([blob], 'receipt.jpg', { type: 'image/jpeg' });

            setIsProcessing(true);

            const receipt = await receiptsApi.scan(file);
            addReceipt(receipt);

            navigate(`/receipt/${receipt.id}`);
        } catch (err: any) {
            if (err.message && err.message !== 'User cancelled photos app') {
                setError(err.message || 'Failed to scan receipt');
            }
        } finally {
            setIsProcessing(false);
        }
    };

    return (
        <div className="min-h-screen bg-gray-50 pb-20">
            <div className="bg-primary-600 text-white p-4 shadow-md">
                <h1 className="text-2xl font-bold">Scan Receipt</h1>
                <p className="text-primary-100 text-sm mt-1">
                    Capture or upload a receipt image
                </p>
            </div>

            <div className="p-4 space-y-4">
                {/* Preview */}
                {preview && (
                    <Card>
                        <CardBody>
                            <img
                                src={preview}
                                alt="Receipt preview"
                                className="w-full rounded-lg"
                            />
                        </CardBody>
                    </Card>
                )}

                {/* Error Display */}
                {error && (
                    <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                        {error}
                    </div>
                )}

                {/* Processing State */}
                {isProcessing && (
                    <Card>
                        <CardBody>
                            <div className="text-center py-8">
                                <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
                                <p className="text-gray-900 font-semibold mt-4">Processing Receipt...</p>
                                <p className="text-gray-500 text-sm mt-2">
                                    AI is extracting data from your receipt
                                </p>
                            </div>
                        </CardBody>
                    </Card>
                )}

                {/* Action Buttons */}
                {!isProcessing && (
                    <div className="space-y-3">
                        <Card>
                            <CardBody>
                                <Button
                                    onClick={handleCapture}
                                    className="w-full py-4 text-lg"
                                >
                                    <svg className="w-6 h-6 mr-2 inline-block" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                                    </svg>
                                    Take Photo
                                </Button>
                            </CardBody>
                        </Card>

                        <Card>
                            <CardBody>
                                <Button
                                    onClick={handleGallery}
                                    variant="secondary"
                                    className="w-full py-4 text-lg"
                                >
                                    <svg className="w-6 h-6 mr-2 inline-block" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                    </svg>
                                    Choose from Gallery
                                </Button>
                            </CardBody>
                        </Card>

                        <Card>
                            <CardBody>
                                <Button
                                    onClick={() => navigate('/add-receipt')}
                                    variant="ghost"
                                    className="w-full py-4 text-lg"
                                >
                                    <svg className="w-6 h-6 mr-2 inline-block" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                                    </svg>
                                    Enter Manually
                                </Button>
                            </CardBody>
                        </Card>
                    </div>
                )}

                {/* Info Card */}
                {!isProcessing && (
                    <Card>
                        <CardBody>
                            <h3 className="font-semibold text-gray-900 mb-2">Tips for best results:</h3>
                            <ul className="text-sm text-gray-600 space-y-1">
                                <li>• Ensure good lighting</li>
                                <li>• Keep the receipt flat</li>
                                <li>• Capture the entire receipt</li>
                                <li>• Avoid shadows and glare</li>
                            </ul>
                        </CardBody>
                    </Card>
                )}
            </div>
        </div>
    );
};
