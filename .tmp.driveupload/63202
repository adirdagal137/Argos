"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ZoomFilerService = void 0;
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const axios_1 = __importDefault(require("axios"));
const RUNTIME_DIR = 'J:/Mi unidad/Argos/ARGOS_RUNTIME';
class ZoomFilerService {
    /**
     * Mapeo de reuniones a carpetas de alumnos.
     * Esto podría estar en un JSON externo en el futuro.
     */
    static STUDENT_MAPPING = {
        // Ejemplo: 'Nombre Alumno': 'FolderID_en_Drive'
        'Default': 'J:/Mi unidad/Argos/ARGOS_RUNTIME/archive/alumnos/general'
    };
    /**
     * Procesa la notificación de Zoom.
     */
    static async processRecording(payload) {
        const { meeting_topic, recording_files } = payload.object;
        console.log(`[ZOOM-FILER] Procesando reunión: ${meeting_topic}`);
        // 1. Identificar alumno
        const studentFolder = this.resolveStudentFolder(meeting_topic);
        if (!fs_1.default.existsSync(studentFolder)) {
            fs_1.default.mkdirSync(studentFolder, { recursive: true });
        }
        // 2. Descargar archivos
        for (const file of recording_files) {
            if (file.file_type === 'TRANSCRIPT' || file.file_type === 'MP4') {
                const fileName = `${new Date().toISOString().split('T')[0]}_${meeting_topic}_${file.file_type}.${file.file_extension.toLowerCase()}`;
                const targetPath = path_1.default.join(studentFolder, fileName);
                console.log(`[ZOOM-FILER] Descargando ${file.file_type} a ${targetPath}`);
                // Nota: En una implementación real, aquí usaríamos el download_token
                // await this.downloadFile(file.download_url, targetPath, payload.download_token);
            }
        }
    }
    static resolveStudentFolder(topic) {
        // Lógica simple: buscar el nombre del alumno en el tópico
        for (const student of Object.keys(this.STUDENT_MAPPING)) {
            if (topic.includes(student))
                return this.STUDENT_MAPPING[student];
        }
        return this.STUDENT_MAPPING['Default'];
    }
    static async downloadFile(url, targetPath, token) {
        // Implementación de descarga con stream a disco
        const response = await (0, axios_1.default)({
            method: 'GET',
            url: `${url}?access_token=${token}`,
            responseType: 'stream'
        });
        const writer = fs_1.default.createWriteStream(targetPath);
        response.data.pipe(writer);
        return new Promise((resolve, reject) => {
            writer.on('finish', () => resolve());
            writer.on('error', reject);
        });
    }
}
exports.ZoomFilerService = ZoomFilerService;
