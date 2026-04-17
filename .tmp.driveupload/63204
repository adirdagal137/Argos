"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.driveService = exports.DriveService = void 0;
const googleapis_1 = require("googleapis");
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
/**
 * DriveService handles file uploads to Google Drive for Argos Sessions.
 */
class DriveService {
    drive;
    constructor() {
        // Authenticate using service account or user credentials
        // In a real scenario, we'd load service_account.json from a secure path.
        const KEY_PATH = path_1.default.join(process.cwd(), 'credentials', 'service_account.json');
        if (fs_1.default.existsSync(KEY_PATH)) {
            const auth = new googleapis_1.google.auth.GoogleAuth({
                keyFile: KEY_PATH,
                scopes: ['https://www.googleapis.com/auth/drive.file'],
            });
            this.drive = googleapis_1.google.drive({ version: 'v3', auth });
        }
        else {
            console.warn('[DRIVE] No credentials found. Drive integration is in MOCK mode.');
            this.drive = null;
        }
    }
    /**
     * Uploads a transcript or whiteboard to a specific folder.
     */
    async uploadFile(fileName, content, mimeType, folderId) {
        if (!this.drive) {
            console.log(`[DRIVE-MOCK] Uploading ${fileName} to folder ${folderId}`);
            return { id: 'mock-drive-id' };
        }
        try {
            const response = await this.drive.files.create({
                requestBody: {
                    name: fileName,
                    parents: [folderId],
                    mimeType: mimeType,
                },
                media: {
                    mimeType: mimeType,
                    body: content,
                },
            });
            console.log(`[DRIVE] File uploaded successfully: ${response.data.id}`);
            return response.data;
        }
        catch (error) {
            console.error('[DRIVE] Error uploading file:', error);
            throw error;
        }
    }
    /**
     * Optional: Fuzzy search for a folder by name (Student Name)
     */
    async findFolderForStudent(studentName) {
        if (!this.drive)
            return 'mock-folder-id';
        const res = await this.drive.files.list({
            q: `name contains '${studentName}' and mimeType = 'application/vnd.google-apps.folder'`,
            fields: 'files(id, name)',
        });
        return res.data.files?.[0]?.id || null;
    }
}
exports.DriveService = DriveService;
exports.driveService = new DriveService();
