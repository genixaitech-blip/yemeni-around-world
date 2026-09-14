import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const sourceHtml = readFileSync(resolve(root, 'preview/index.html'), 'utf8');
const css = readFileSync(resolve(root, 'preview/styles.css'), 'utf8');
const js = readFileSync(resolve(root, 'preview/app.js'), 'utf8');
const hero = readFileSync(resolve(root, 'assets/images/onboarding.png')).toString('base64');

const standaloneCss = css.replace(
  "url('../assets/images/onboarding.png')",
  `url('data:image/png;base64,${hero}')`,
);

const standalone = sourceHtml
  .replace('<link rel="stylesheet" href="styles.css">', `<style>${standaloneCss}</style>`)
  .replace('<script src="app.js"></script>', `<script>${js}</script>`);

mkdirSync(resolve(root, '../output'), { recursive: true });
writeFileSync(resolve(root, 'preview/standalone.html'), standalone);
writeFileSync(resolve(root, '../output/yemeni-world-preview.html'), standalone);
console.log('Standalone preview generated.');
