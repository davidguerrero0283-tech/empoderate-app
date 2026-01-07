/**
 * Authentication Middleware
 * 
 * Verifica que el request tenga un token Firebase Auth válido
 */

import { Request, Response, NextFunction } from 'express';
import * as admin from 'firebase-admin';
import { logger } from '../logging/logger';

// Extend Express Request type to include user
declare global {
    namespace Express {
        interface Request {
            user?: admin.auth.DecodedIdToken;
        }
    }
}

export async function authMiddleware(
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> {
    try {
        // Get token from Authorization header
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            res.status(401).json({ error: 'No authentication token provided' });
            return;
        }

        const token = authHeader.split('Bearer ')[1];

        // Verify token
        const decodedToken = await admin.auth().verifyIdToken(token);
        req.user = decodedToken;

        logger.debug('User authenticated', {
            uid: decodedToken.uid,
            email: decodedToken.email,
        });

        next();
    } catch (error) {
        logger.error('Authentication failed', error as Error, {
            path: req.path,
        });
        res.status(401).json({ error: 'Invalid authentication token' });
    }
}

/**
 * Admin middleware - requiere que el usuario tenga el claim "admin"
 */
export async function adminMiddleware(
    req: Request,
    res: Response,
    next: NextFunction
): Promise<void> {
    if (!req.user) {
        res.status(401).json({ error: 'Authentication required' });
        return;
    }

    if (!req.user.admin) {
        res.status(403).json({ error: 'Admin access required' });
        return;
    }

    next();
}
