"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const crypto_1 = __importDefault(require("crypto"));
const router = (0, express_1.Router)();
// Zoom Webhook Secret Token (Should be in .env)
const ZOOM_SECRET_TOKEN = process.env.ZOOM_SECRET_TOKEN || 'placeholder_secret';
router.post('/webhook', (req, res) => {
    const event = req.body.event;
    // 1. URL Validation (Zoom Requirement)
    if (event === 'endpoint.url_validation') {
        const plainToken = req.body.payload.plainToken;
        const hashForValidate = crypto_1.default
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
    const signature = req.headers['x-zm-signature'];
    const timestamp = req.headers['x-zm-request-timestamp'];
    const message = `v0:${timestamp}:${JSON.stringify(req.body)}`;
    const hashForVerify = crypto_1.default
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
exports.default = router;
