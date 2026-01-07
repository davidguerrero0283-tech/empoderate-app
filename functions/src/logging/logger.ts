/**
 * Logger Service
 * 
 * Wrapper alrededor de firebase-functions logger para logging estructurado
 */

import * as functions from 'firebase-functions';

export const logger = {
    info: (message: string, data?: any) => {
        functions.logger.info(message, data);
    },

    warn: (message: string, data?: any) => {
        functions.logger.warn(message, data);
    },

    error: (message: string, error: Error, data?: any) => {
        functions.logger.error(message, {
            error: error.message,
            stack: error.stack,
            ...data,
        });
    },

    debug: (message: string, data?: any) => {
        if (process.env.LOG_LEVEL === 'debug') {
            functions.logger.debug(message, data);
        }
    },
};
