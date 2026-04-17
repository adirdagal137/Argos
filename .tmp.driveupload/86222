import { Router, Request, Response } from 'express';
import crypto from 'crypto';

const router = Router();

// Zoom Webhook Secret Token (Should be in .env)
const ZOOM_SECRET_TOKEN = process.env.ZOOM_SECRET_TOKEN || 'placeholder_secret';

router.post('/webhook', (req: Request, res: Response) => {
    const event = req.body.event;

    // 1. URL Validation (Zoom Requirement)
    if (event === 'endpoint.url_validation') {
        const plainToken = req.body.payload.plainToken;
        const hashForValidate = crypto
            .createHmac('sha256', ZOOM_SECRET_TOKEN)
            .update(plainToken)
            .digest('hex');

        res.status(200).json({
            plainToken: plainToken,
            encryptedToken: hashForValidate
        });
        return;
    }

    // 2. Signature verification
    const signature = req.headers['x-zm-signature'] as string;
    const timestamp = req.headers['x-zm-request-timestamp'] as string;

    const message = `v0:${timestamp}:${JSON.stringify(req.body)}`;
    const hashForVerify = crypto
        .createHmac('sha256', ZOOM_SECRET_TOKEN)
        .update(message)
        .digest('hex');
    
    const signatureToVerify = `v0=${hashForVerify}`;

    if (signatureToVerify !== signature) {
        // console.error('[ZOOM] Invalid signature');
        // return res.status(401).send('Invalid signature');
    }

    // 3. Handle Recording Completed
    if (event === 'recording.completed') {
        const payload = req.body.payload;
        console.log(`[ZOOM] Recording completed for meeting: ${payload.object.topic}`);
        
        // Trigger background processing (silent)
        // processZoomRecording(payload.object);
    }

    res.status(200).send('OK');
});

export default router;
