/**
 * Payment Provider Interface
 * 
 * Define la interfaz que todos los payment providers deben implementar
 */

export interface CheckoutParams {
    userId: string;
    plan: string;
    amount: number;
    currency: string;
    returnUrl: string;
    cancelUrl: string;
}

export interface CheckoutResponse {
    checkoutUrl: string;
    sessionId: string;
    provider: string;
}

export interface PaymentResult {
    status: 'completed' | 'pending' | 'failed';
    transactionId: string;
    amount: number;
    currency: string;
    userId: string;
    plan: string;
    metadata?: Record<string, any>;
}

export interface PaymentProvider {
    /**
     * Crear una sesión de checkout
     */
    createCheckout(params: CheckoutParams): Promise<CheckoutResponse>;

    /**
     * Verificar la firma del webhook
     */
    verifyWebhook(signature: string, body: any): boolean;

    /**
     * Procesar el webhook y retornar resultado del pago
     */
    processWebhook(data: any): Promise<PaymentResult>;
}
