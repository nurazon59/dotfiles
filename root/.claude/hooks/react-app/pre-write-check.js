#!/usr/bin/env node
/**
 * React App Pre-Write Check Hook
 * コード品質の問題を検出して書き込みをブロックする
 * 
 * EXIT CODES:
 *   0 - Success (書き込み許可)
 *   2 - Blocked (書き込み拒否)
 */

const fs = require('fs').promises;
const path = require('path');

// ANSI color codes
const colors = {
  red: '\x1b[0;31m',
  green: '\x1b[0;32m',
  yellow: '\x1b[0;33m',
  blue: '\x1b[0;34m',
  cyan: '\x1b[0;36m',
  reset: '\x1b[0m',
};

// ログ関数
const log = {
  info: (msg) => console.error(`${colors.blue}[INFO]${colors.reset} ${msg}`),
  error: (msg) => console.error(`${colors.red}[ERROR]${colors.reset} ${msg}`),
  success: (msg) => console.error(`${colors.green}[OK]${colors.reset} ${msg}`),
  warning: (msg) => console.error(`${colors.yellow}[WARN]${colors.reset} ${msg}`),
  block: (msg) => console.error(`${colors.red}[BLOCKED]${colors.reset} ${msg}`),
};

/**
 * 設定を読み込み
 */
function loadConfig() {
  let fileConfig = {};
  
  try {
    const configPath = path.join(__dirname, 'pre-write-config.json');
    if (require('fs').existsSync(configPath)) {
      fileConfig = JSON.parse(require('fs').readFileSync(configPath, 'utf8'));
    }
  } catch (e) {
    // デフォルト設定を使用
  }
  
  return {
    // ブロッキングルール
    blockOnAsAny: fileConfig.blocking?.asAny ?? true,
    blockOnConsole: fileConfig.blocking?.console ?? false,
    blockOnDebugger: fileConfig.blocking?.debugger ?? true,
    blockOnTodo: fileConfig.blocking?.todo ?? false,
    
    // 許可リスト
    allowedPaths: fileConfig.allowed?.paths || [],
    allowedPatterns: fileConfig.allowed?.patterns || [],
    
    // 除外設定
    ignorePaths: fileConfig.ignore?.paths || [
      'node_modules/',
      'dist/',
      'build/',
      '.next/',
      'coverage/',
    ],
    
    // カスタムルール
    customPatterns: fileConfig.customPatterns || [],
    
    _fileConfig: fileConfig,
  };
}

const config = loadConfig();

/**
 * JSONを解析
 */
async function parseJsonInput() {
  let inputData = '';
  
  for await (const chunk of process.stdin) {
    inputData += chunk;
  }
  
  if (!inputData.trim()) {
    log.warning('No JSON input provided');
    process.exit(0);
  }
  
  try {
    return JSON.parse(inputData);
  } catch (error) {
    log.error(`Failed to parse JSON: ${error.message}`);
    process.exit(2);
  }
}

/**
 * ファイルパスを抽出
 */
function extractFilePath(input) {
  const { tool_input } = input;
  if (!tool_input) return null;
  
  return tool_input.file_path || tool_input.path || null;
}

/**
 * 編集内容を抽出
 */
function extractContent(input) {
  const { tool_name, tool_input } = input;
  
  if (!tool_input) return null;
  
  switch (tool_name) {
    case 'Write':
      return tool_input.content || null;
      
    case 'Edit':
      return tool_input.new_string || null;
      
    case 'MultiEdit':
      // 複数編集の場合は全ての新しい内容を結合
      if (tool_input.edits && Array.isArray(tool_input.edits)) {
        return tool_input.edits
          .map(edit => edit.new_string || '')
          .join('\n');
      }
      return null;
      
    default:
      return null;
  }
}

/**
 * ソースファイルかチェック
 */
function isSourceFile(filePath) {
  if (!filePath) return false;
  return /\.(ts|tsx|js|jsx)$/.test(filePath);
}

/**
 * 無視するパスかチェック
 */
function shouldIgnore(filePath) {
  if (!filePath) return false;
  
  // 無視パスをチェック
  for (const ignorePath of config.ignorePaths) {
    if (filePath.includes(ignorePath)) {
      return true;
    }
  }
  
  // 許可パスをチェック
  for (const allowedPath of config.allowedPaths) {
    if (filePath.includes(allowedPath)) {
      return false;
    }
  }
  
  return false;
}

/**
 * コンテンツの品質チェック
 */
function checkContent(content, filePath) {
  const errors = [];
  const warnings = [];
  
  if (!content) return { errors, warnings };
  
  const lines = content.split('\n');
  
  // as any のチェック
  if (config.blockOnAsAny) {
    lines.forEach((line, index) => {
      if (line.includes('as any')) {
        errors.push({
          type: 'as_any',
          line: index + 1,
          message: `Line ${index + 1}: "as any" は型安全性を損ないます。適切な型定義または "as unknown" を使用してください`,
          content: line.trim()
        });
      }
    });
  }
  
  // console文のチェック
  if (config.blockOnConsole) {
    lines.forEach((line, index) => {
      // コメント行は除外
      const trimmedLine = line.trim();
      if (!trimmedLine.startsWith('//') && !trimmedLine.startsWith('*')) {
        if (/console\.\w+/.test(line)) {
          errors.push({
            type: 'console',
            line: index + 1,
            message: `Line ${index + 1}: console文はプロダクションコードに含めないでください`,
            content: line.trim()
          });
        }
      }
    });
  }
  
  // debugger文のチェック
  if (config.blockOnDebugger) {
    lines.forEach((line, index) => {
      if (/\bdebugger\b/.test(line)) {
        errors.push({
          type: 'debugger',
          line: index + 1,
          message: `Line ${index + 1}: debugger文は削除してください`,
          content: line.trim()
        });
      }
    });
  }
  
  // TODO/FIXMEのチェック
  if (config.blockOnTodo) {
    lines.forEach((line, index) => {
      if (/TODO|FIXME|HACK|XXX/.test(line)) {
        warnings.push({
          type: 'todo',
          line: index + 1,
          message: `Line ${index + 1}: 未完了のTODO/FIXMEがあります`,
          content: line.trim()
        });
      }
    });
  }
  
  // カスタムパターンのチェック
  if (config.customPatterns && config.customPatterns.length > 0) {
    config.customPatterns.forEach(pattern => {
      const regex = new RegExp(pattern.pattern, pattern.flags || 'g');
      lines.forEach((line, index) => {
        if (regex.test(line)) {
          const item = {
            type: 'custom',
            line: index + 1,
            message: pattern.message || `Line ${index + 1}: カスタムルール違反`,
            content: line.trim()
          };
          
          if (pattern.severity === 'error') {
            errors.push(item);
          } else {
            warnings.push(item);
          }
        }
      });
    });
  }
  
  return { errors, warnings };
}

/**
 * エラーサマリーを表示
 */
function printSummary(errors, warnings, filePath) {
  console.error('');
  console.error('⚛️  Pre-Write Quality Check - 書き込み前チェック');
  console.error('────────────────────────────────────────────');
  
  if (filePath) {
    console.error(`📄 File: ${path.basename(filePath)}`);
  }
  
  if (warnings.length > 0) {
    console.error(`\n${colors.yellow}⚠️  Warnings (${warnings.length})${colors.reset}`);
    warnings.forEach(warning => {
      console.error(`  ${colors.yellow}→${colors.reset} ${warning.message}`);
      if (warning.content) {
        console.error(`    ${colors.cyan}${warning.content}${colors.reset}`);
      }
    });
  }
  
  if (errors.length > 0) {
    console.error(`\n${colors.red}❌ Blocking Errors (${errors.length})${colors.reset}`);
    errors.forEach(error => {
      console.error(`  ${colors.red}→${colors.reset} ${error.message}`);
      if (error.content) {
        console.error(`    ${colors.cyan}${error.content}${colors.reset}`);
      }
    });
    
    console.error('');
    console.error(`${colors.red}════════════════════════════════════════════${colors.reset}`);
    console.error(`${colors.red}🚫 書き込みがブロックされました${colors.reset}`);
    console.error(`${colors.red}════════════════════════════════════════════${colors.reset}`);
    console.error('');
    console.error('📋 対処方法:');
    
    // エラータイプ別の対処法
    const errorTypes = [...new Set(errors.map(e => e.type))];
    
    if (errorTypes.includes('as_any')) {
      console.error(`  1. ${colors.yellow}"as any"${colors.reset} → 適切な型定義を使用するか、${colors.green}"as unknown"${colors.reset} に変更`);
    }
    if (errorTypes.includes('console')) {
      console.error(`  2. ${colors.yellow}"console.*"${colors.reset} → 削除するか、適切なロギングライブラリを使用`);
    }
    if (errorTypes.includes('debugger')) {
      console.error(`  3. ${colors.yellow}"debugger"${colors.reset} → デバッグ文を削除`);
    }
    
    console.error('');
    console.error(`${colors.cyan}修正後、再度実行してください。${colors.reset}`);
  } else if (warnings.length === 0) {
    console.error(`\n${colors.green}✅ All checks passed - 書き込み許可${colors.reset}`);
  } else {
    console.error(`\n${colors.green}✅ Passed with warnings - 書き込み許可${colors.reset}`);
  }
}

/**
 * メイン処理
 */
async function main() {
  try {
    // 入力を解析
    const input = await parseJsonInput();
    const { tool_name } = input;
    
    // 対象ツールかチェック
    if (!['Write', 'Edit', 'MultiEdit'].includes(tool_name)) {
      log.info(`Tool ${tool_name} is not subject to pre-write checks`);
      process.exit(0);
    }
    
    // ファイルパスと内容を抽出
    const filePath = extractFilePath(input);
    const content = extractContent(input);
    
    // ソースファイル以外はスキップ
    if (filePath && !isSourceFile(filePath)) {
      log.info(`Skipping non-source file: ${filePath}`);
      console.error(`\n${colors.green}✅ Non-source file - 書き込み許可${colors.reset}`);
      process.exit(0);
    }
    
    // 無視パスはスキップ
    if (filePath && shouldIgnore(filePath)) {
      log.info(`Ignoring file in excluded path: ${filePath}`);
      console.error(`\n${colors.green}✅ Excluded path - 書き込み許可${colors.reset}`);
      process.exit(0);
    }
    
    // コンテンツがない場合はスキップ
    if (!content) {
      log.info('No content to check');
      process.exit(0);
    }
    
    // 品質チェック実行
    const { errors, warnings } = checkContent(content, filePath);
    
    // サマリー表示
    printSummary(errors, warnings, filePath);
    
    // エラーがあれば書き込みをブロック
    if (errors.length > 0) {
      process.exit(2);  // ブロック
    }
    
    // 成功
    process.exit(0);
    
  } catch (error) {
    log.error(`Unexpected error: ${error.message}`);
    // エラーが発生しても書き込みは許可（安全側に倒す）
    process.exit(0);
  }
}

// エラーハンドリング
process.on('unhandledRejection', (error) => {
  log.error(`Unhandled error: ${error.message}`);
  process.exit(0);  // エラーでも書き込み許可
});

// 実行
main().catch((error) => {
  log.error(`Fatal error: ${error.message}`);
  process.exit(0);  // エラーでも書き込み許可
});
