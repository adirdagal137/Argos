import * as fs from 'fs';
import * as path from 'path';

const watchPath = 'c:\\Users\\Widox\\.gemini\\antigravity\\scratch\\argos-dashboard';
console.log('Watching:', watchPath);

fs.watch(watchPath, { recursive: true }, (event, filename) => {
    console.log(`EVENT: ${event} on ${filename}`);
    fs.appendFileSync('watch_debug.log', `${new Date().toISOString()} - ${event} - ${filename}\n`);
});

setTimeout(() => {
    console.log('Test complete');
    process.exit(0);
}, 60000);
