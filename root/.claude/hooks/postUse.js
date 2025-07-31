#!/usr/bin/env node

// Claude Code postUse hook - EditorConfigフォーマット
// ファイル変更後に自動的にeclintでフォーマットを実行

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

/**
 * miseを使用してeclintコマンドを実行
 * @param {string[]} files - フォーマット対象のファイル一覧
 */
async function formatFiles(files) {
  if (!files || files.length === 0) {
    console.log('📝 フォーマット対象のファイルがありません');
    return;
  }

  // バイナリファイルや除外対象をフィルタリング
  const textFiles = files.filter(file => {
    // 存在確認
    if (!fs.existsSync(file)) return false;
    
    // バイナリファイルや除外対象をスキップ
    const excludePatterns = [
      /node_modules/,
      /\.git\//,
      /\.DS_Store$/,
      /\.(png|jpg|jpeg|gif|ico|pdf|zip|tar|gz)$/i,
      /\.(exe|dll|so|dylib)$/i
    ];
    
    return !excludePatterns.some(pattern => pattern.test(file));
  });

  if (textFiles.length === 0) {
    console.log('📝 テキストファイルが見つかりません');
    return;
  }

  console.log(`📝 EditorConfigフォーマット実行: ${textFiles.length}個のファイル`);
  
  try {
    // miseを使用してeclintを実行
    const args = ['run', 'format-changed-files', ...textFiles];
    
    const child = spawn('mise', args, {
      stdio: 'inherit',
      cwd: process.cwd()
    });

    await new Promise((resolve, reject) => {
      child.on('close', (code) => {
        if (code === 0) {
          console.log('✅ EditorConfigフォーマット完了');
          resolve();
        } else {
          console.log(`⚠️  EditorConfigフォーマットでエラーが発生 (exit code: ${code})`);
          // エラーでもClaude Codeの処理は継続
          resolve();
        }
      });
      
      child.on('error', (error) => {
        console.log(`❌ miseコマンド実行エラー: ${error.message}`);
        // エラーでもClaude Codeの処理は継続
        resolve();
      });
    });
    
  } catch (error) {
    console.log(`❌ EditorConfigフォーマットエラー: ${error.message}`);
    // エラーでもClaude Codeの処理は継続
  }
}

/**
 * postUse hook メイン処理
 * @param {Object} context - Claude Codeから渡されるコンテキスト
 */
async function main(context) {
  try {
    console.log('🔧 Claude Code postUse hook実行開始');

    // 変更されたファイルを取得
    const changedFiles = context?.files || [];
    
    if (changedFiles.length > 0) {
      console.log(`📁 変更ファイル数: ${changedFiles.length}`);
      await formatFiles(changedFiles);
    } else {
      console.log('📁 変更されたファイルがありません');
    }
    
    console.log('✅ Claude Code postUse hook完了');
    
  } catch (error) {
    console.log(`❌ postUse hook エラー: ${error.message}`);
    // エラーでもClaude Codeの処理は継続
  }
}

// Claude CodeからのコンテキストをJSONで受け取り
const context = JSON.parse(process.argv[2] || '{}');
main(context).catch(console.error);