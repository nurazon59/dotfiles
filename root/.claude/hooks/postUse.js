#!/usr/bin/env node
// Claude Code postUse hook - EditorConfig自動フォーマット（シェルスクリプト呼び出し版）

const { spawn } = require('child_process');
const path = require('path');

// 変更されたファイルのリストを取得
const changedFiles = process.argv.slice(2).join(' ');

// postUse.shを実行
const scriptPath = path.join(__dirname, 'postUse.sh');
const child = spawn('bash', [scriptPath, changedFiles], {
    stdio: 'inherit',
    cwd: process.cwd()
});

child.on('close', (code) => {
    // エラーが発生してもClaude Codeの処理は継続
    process.exit(0);
});