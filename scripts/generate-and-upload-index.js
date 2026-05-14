import 'dotenv/config';
import { GoogleGenAI } from '@google/genai';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const VAULT_PATH = 'C:\\Users\\potsk\\Documents\\Obsidian\\Vault\\WIS Manual';
const OUTPUT_PATH = path.join(__dirname, 'knowledge_base.json');
const API_KEY = process.env.GOOGLE_AI_API_KEY;

const SUPPORTED_EXTENSIONS = ['.md', '.txt', '.json', '.csv'];

function stripImageLinks(content) {
  content = content.replace(/!\[.*?\]\(.*?\)/g, '');
  content = content.replace(/\[\[.*?\.(png|jpg|jpeg|gif|webp)(\|[\d]+)?\]\]/gi, '');
  return content;
}

function getSlug(name) {
  return name.replace(/ /g, '-');
}

function generateKnowledgeBase() {
  const files = fs.readdirSync(VAULT_PATH, { recursive: true })
    .filter(f => typeof f === 'string' && f.endsWith('.md') && !f.includes('.Scripts'));

  const kb = [];

  for (const file of files) {
    const filePath = path.join(VAULT_PATH, file);
    let content = fs.readFileSync(filePath, 'utf8');

    if (content.match(/ai_search:\s*false/i)) {
      continue;
    }

    content = stripImageLinks(content);

    const title = path.basename(file, '.md');
    const fileSlug = getSlug(title);
    const parentFolder = path.dirname(file);

    let url;
    if (parentFolder === '.') {
      url = fileSlug === 'index' ? '/manual/' : `/manual/${fileSlug}`;
    } else {
      const folderSlug = getSlug(path.basename(parentFolder));
      url = `/manual/${folderSlug}/${fileSlug}`;
    }

    const cleanContent = content.replace(/^---[\s\S]*?---/, '').trim();

    kb.push({
      title,
      url,
      content: cleanContent,
      source: 'manual',
      subsite: 'wis-wiki-manual'
    });
  }

  fs.writeFileSync(OUTPUT_PATH, JSON.stringify(kb, null, 2), 'utf8');
  console.log(`Generated ${OUTPUT_PATH} with ${kb.length} entries`);
  return kb;
}

async function uploadToFileSearchStore(kb) {
  if (!API_KEY) {
    console.error('GOOGLE_AI_API_KEY environment variable not set');
    process.exit(1);
  }

  const ai = new GoogleGenAI({ apiKey: API_KEY });

  const stores = await ai.fileSearchStores.list();
  console.log('Stores response:', JSON.stringify(stores, null, 2));
  let store = stores.fileSearchStores?.find(s => s.displayName === 'WIS Wiki Knowledge Base');

  if (!store) {
    console.log('Creating File Search Store...');
    store = await ai.fileSearchStores.create({
      config: { displayName: 'WIS Wiki Knowledge Base' }
    });
    console.log(`Created store: ${store.name}`);
  } else {
    console.log(`Using existing store: ${store.name}`);
  }

  console.log(`Uploading ${kb.length} documents...`);

  for (let i = 0; i < kb.length; i++) {
    const doc = kb[i];
    console.log(`Uploading ${i + 1}/${kb.length}: ${doc.title}`);
    
    const tempFile = path.join(__dirname, `temp_${doc.title}.txt`);
    fs.writeFileSync(tempFile, doc.content, 'utf8');

    try {
      const operation = await ai.fileSearchStores.uploadToFileSearchStore({
        name: store.name,
        file: fs.createReadStream(tempFile),
        config: {
          displayName: doc.title,
          mimeType: 'text/plain',
          customMetadata: {
            url: doc.url,
            source: doc.source,
            subsite: doc.subsite
          }
        }
      });

      let result = operation;
      while (!result.done) {
        await new Promise(r => setTimeout(r, 2000));
        result = await ai.operations.get({ name: result.name });
      }

      console.log(`  Indexed: ${doc.title}`);
    } catch (err) {
      console.error(`  Error uploading ${doc.title}:`, err.message);
    } finally {
      fs.unlinkSync(tempFile);
    }
  }

  console.log('Upload complete!');
}

async function main() {
  console.log('Step 1: Generating knowledge base...');
  const kb = generateKnowledgeBase();

  console.log('\nStep 2: Uploading to File Search Store...');
  await uploadToFileSearchStore(kb);
}

main().catch(console.error);