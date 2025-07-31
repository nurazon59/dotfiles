#!/usr/bin/env node

/**
 * Claude Code postUse Hook
 * ファイル変更後に自動的にeditorconfigルールを適用してフォーマット
 */

import { execSync } from 'child_process';
import { existsSync } from 'fs';
import path from 'path';

export default function postUseHook(context) {
  const { changedFiles, workingDirectory } = context;
  
  if (!changedFiles || changedFiles.length === 0) {
    console.log('No files changed, skipping editorconfig formatting');
    return;
  }

  console.log(`Running editorconfig formatting on ${changedFiles.length} changed files...`);

  // .editorconfigファイルの存在確認
  const editorconfigPath = path.join(workingDirectory, '.editorconfig');
  if (!existsSync(editorconfigPath)) {
    console.log('No .editorconfig file found, skipping formatting');
    return;
  }

  try {
    // eclintがインストールされているかチェック
    try {
      execSync('command -v eclint', { stdio: 'ignore' });
    } catch (error) {
      console.log('eclint not found, attempting to install via npm...');
      execSync('npm install -g eclint', { stdio: 'inherit', cwd: workingDirectory });
    }

    // 変更されたファイルのみにeclint fixを適用
    const filesToFormat = changedFiles
      .filter(file => {
        // バイナリファイルや特定のディレクトリを除外
        const excludePatterns = [
          /\.(png|jpg|jpeg|gif|svg|ico|webp)$/i,
          /\.(zip|tar|gz|rar|7z)$/i,
          /node_modules/,
          /\.git/,
          /\.DS_Store/,
          /Thumbs\.db/
        ];
        return !excludePatterns.some(pattern => pattern.test(file));
      })
      .map(file => path.resolve(workingDirectory, file));

    if (filesToFormat.length === 0) {
      console.log('No formattable files found');
      return;
    }

    console.log('Formatting files:', filesToFormat.map(f => path.relative(workingDirectory, f)));

    // eclint fixを実行
    const command = `eclint fix ${filesToFormat.map(f => `"${f}"`).join(' ')}`;
    execSync(command, { 
      stdio: 'inherit', 
      cwd: workingDirectory 
    });

    console.log('✓ EditorConfig formatting completed successfully');

  } catch (error) {
    console.error('EditorConfig formatting failed:', error.message);
    // エラーが発生してもClaude Codeの処理は継続
    console.log('Continuing despite formatting error...');
  }
}