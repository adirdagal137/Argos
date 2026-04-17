import { google } from 'googleapis';
import fs from 'fs';
import path from 'path';

/**
 * DriveService handles file uploads to Google Drive for Argos Sessions.
 */
export class DriveService {
    private drive;

    constructor() {
        // Authenticate using service account or user credentials
        // In a real scenario, we'd load service_account.json from a secure path.
        const KEY_PATH = path.join(process.cwd(), 'credentials', 'service_account.json');
        
        if (fs.existsSync(KEY_PATH)) {
            const auth = new google.auth.GoogleAuth({
                keyFile: KEY_PATH,
                scopes: ['https://www.googleapis.com/auth/drive.file'],
            });
            this.drive = google.drive({ version: 'v3', auth });
        } else {
            console.warn('[DRIVE] No credentials found. Drive integration is in MOCK mode.');
            this.drive = null;
        }
    }

    /**
     * Uploads a transcript or whiteboard to a specific folder.
     */
    async uploadFile(fileName: string, content: string, mimeType: string, folderId: string) {
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
        } catch (error) {
            console.error('[DRIVE] Error uploading file:', error);
            throw error;
        }
    }

    /**
     * Optional: Fuzzy search for a folder by name (Student Name)
     */
    async findFolderForStudent(studentName: string) {
        if (!this.drive) return 'mock-folder-id';

        const res = await this.drive.files.list({
            q: `name contains '${studentName}' and mimeType = 'application/vnd.google-apps.folder'`,
            fields: 'files(id, name)',
        });

        return res.data.files?.[0]?.id || null;
    }
}

export const driveService = new DriveService();
