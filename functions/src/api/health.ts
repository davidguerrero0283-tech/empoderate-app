/**
 * Health Check Endpoint
 * 
 * GET /api/health
 * Returns server status and version
 */

import express from 'express';

export const healthRouter = express.Router();

healthRouter.get('/', (req, res) => {
    res.status(200).json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
    });
});
