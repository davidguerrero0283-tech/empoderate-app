/**
 * Cloud Functions Entry Point
 * 
 * Exports all HTTP endpoints for the Empodérate backend
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import express from 'express';
import cors from 'cors';
import { healthRouter } from './api/health';
import { logger } from './logging/logger';

// Initialize Firebase Admin
admin.initializeApp();

// Create Express app
const app = express();

// Middleware
app.use(cors({ origin: true })); // TODO: Configure CORS properly in production
app.use(express.json());

// Request logging
app.use((req, res, next) => {
    logger.info(`${req.method} ${req.path}`, {
        ip: req.ip,
        userAgent: req.get('user-agent'),
    });
    next();
});

// Routes
app.use('/health', healthRouter);
// TODO: Add more routes (ai, payments, etc.)

// Error handling
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
    logger.error('Unhandled error', err, {
        path: req.path,
        method: req.method,
    });
    res.status(500).json({
        error: 'Internal server error',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined,
    });
});

// Export the Express app as a Cloud Function
export const api = functions.https.onRequest(app);

// Export Firestore triggers (ejemplo)
export const onUserCreated = functions.firestore
    .document('users/{userId}')
    .onCreate(async (snap, context) => {
        const userId = context.params.userId;
        logger.info('New user created', { userId });

        // Crear documento de subscription por defecto
        await admin.firestore().collection('subscriptions').doc(userId).set({
            plan: 'free',
            status: 'active',
            startDate: admin.firestore.FieldValue.serverTimestamp(),
            endDate: null,
            paymentProvider: null,
        });
    });
