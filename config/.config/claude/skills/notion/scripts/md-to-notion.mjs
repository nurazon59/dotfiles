#!/usr/bin/env node
// 大量md → Notion流し込み用変換スクリプト
//
// 入力: mapping JSON（{ pages: { "<repo相対path>": { id, url } } }）+ repo配下のmd
// 出力: <out>/<flat-name>.md（先頭H1除去、相対リンクをNotion URLに置換）+ _summary.json
//
// Usage:
//   node md-to-notion.mjs [--mapping <path>] [--repo <path>] [--out <dir>]
//   default: --mapping ./zzz/notion-pages.json --repo . --out ./zzz/notion-output

import fs from 'node:fs';
import path from 'node:path';

function parseArgs(argv) {
  const args = {};
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--mapping') args.mapping = argv[++i];
    else if (a === '--repo') args.repo = argv[++i];
    else if (a === '--out') args.out = argv[++i];
  }
  return args;
}

const argv = parseArgs(process.argv);
const REPO = path.resolve(argv.repo ?? process.cwd());
const MAPPING = path.resolve(argv.mapping ?? path.join(REPO, 'zzz/notion-pages.json'));
const OUT = path.resolve(argv.out ?? path.join(REPO, 'zzz/notion-output'));

if (!fs.existsSync(MAPPING)) {
  console.error(`mapping JSON not found: ${MAPPING}`);
  process.exit(1);
}
const mapping = JSON.parse(fs.readFileSync(MAPPING, 'utf8'));
const pages = mapping.pages ?? {};
if (Object.keys(pages).length === 0) {
  console.error(`mapping.pages is empty in ${MAPPING}`);
  process.exit(1);
}

fs.mkdirSync(OUT, { recursive: true });

function resolveRelativeMd(srcRel, linkTarget) {
  const cleaned = linkTarget.split('#')[0];
  const anchor = linkTarget.includes('#') ? linkTarget.slice(linkTarget.indexOf('#')) : '';
  const resolved = path.normalize(path.join(path.dirname(srcRel), cleaned));
  return { resolved, anchor };
}

function transform(srcRel, content) {
  let out = content;

  const lines = out.split('\n');
  const firstNonEmpty = lines.findIndex((l) => l.trim() !== '');
  if (firstNonEmpty !== -1 && /^# (?!#)/.test(lines[firstNonEmpty])) {
    lines.splice(firstNonEmpty, 1);
    while (lines.length > firstNonEmpty && lines[firstNonEmpty].trim() === '') {
      lines.splice(firstNonEmpty, 1);
    }
    out = lines.join('\n');
  }

  out = out.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (m, text, url) => {
    if (url.startsWith('#')) return text;
    if (/^https?:\/\//.test(url) || /^mailto:/.test(url)) return m;
    if (url.endsWith('.md') || url.includes('.md#')) {
      const { resolved } = resolveRelativeMd(srcRel, url);
      const hit = pages[resolved];
      if (hit) return `[${text}](${hit.url})`;
    }
    return m;
  });

  return out;
}

const summary = [];
const missing = [];
for (const rel of Object.keys(pages)) {
  const abs = path.join(REPO, rel);
  if (!fs.existsSync(abs)) {
    missing.push(rel);
    continue;
  }
  const transformed = transform(rel, fs.readFileSync(abs, 'utf8'));
  const flat = rel.replace(/\//g, '__');
  fs.writeFileSync(path.join(OUT, flat), transformed);
  summary.push({ rel, flat, bytes: transformed.length, id: pages[rel].id, url: pages[rel].url });
}
fs.writeFileSync(path.join(OUT, '_summary.json'), JSON.stringify(summary, null, 2));

console.log(`converted ${summary.length} files → ${OUT}`);
if (missing.length) {
  console.warn(`MISSING ${missing.length}件:`);
  for (const m of missing) console.warn(`  - ${m}`);
}
