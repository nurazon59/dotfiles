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
        return tool_input.edits.map((edit) => edit.new_string || '').join('\n');
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
          content: line.trim(),
        });
      }
    });
  }

  // any型アノテーションのチェック
  lines.forEach((line, index) => {
    // : any パターンをチェック（関数パラメータ、変数宣言、戻り値など）
    if (/:\s*any\b/.test(line)) {
      errors.push({
        type: 'any_type',
        line: index + 1,
        message: `any型アノテーションは禁止されています。適切な型定義を使用してください`,
        content: line.trim(),
      });
    }
  });

  // ジェネリックでの<any>チェック
  lines.forEach((line, index) => {
    // <any> パターンをチェック
    if (/<any>/.test(line)) {
      errors.push({
        type: 'generic_any',
        line: index + 1,
        message: `ジェネリックでの<any>は禁止されています。適切な型パラメータを使用してください`,
        content: line.trim(),
      });
    }
  });

  // unknown型のチェック
  lines.forEach((line, index) => {
    // : unknown パターンとas unknownパターンをチェック
    if (/:\s*unknown\b/.test(line) || /\bas\s+unknown\b/.test(line)) {
      errors.push({
        type: 'unknown_type',
        line: index + 1,
        message: `unknown型は禁止されています。具体的な型定義を使用してください`,
        content: line.trim(),
      });
    }
  });

  // class構文のチェック
  lines.forEach((line, index) => {
    // class宣言をチェック（classキーワードの後にスペースと識別子）
    if (/\bclass\s+[A-Z]\w*/.test(line)) {
      errors.push({
        type: 'class_syntax',
        line: index + 1,
        message: `class構文は禁止されています。関数型コンポーネントまたはファクトリー関数を使用してください`,
        content: line.trim(),
      });
    }
  });

  // レイヤー名を含む命名のチェック
  const layerNamePattern = /(Repo|Repository|UseCase|Service|Controller)(?:$|[A-Z]|\W)/;
  
  // ファイル名のチェック
  if (filePath) {
    const fileName = path.basename(filePath, path.extname(filePath));
    if (layerNamePattern.test(fileName)) {
      errors.push({
        type: 'layer_name_in_filename',
        line: 0,
        message: `ファイル名にレイヤー名（Repo、Repository、UseCase、Service、Controller）を含めることは禁止されています`,
        content: fileName,
      });
    }
  }

  // 関数名、クラス名、インターフェース名のチェック
  lines.forEach((line, index) => {
    // 関数宣言（function、const/let/var）
    const functionMatch = line.match(/(?:function\s+|(?:const|let|var)\s+)(\w+)(?:\s*[=(:])/);
    if (functionMatch) {
      const functionName = functionMatch[1];
      if (layerNamePattern.test(functionName)) {
        errors.push({
          type: 'layer_name_in_function',
          line: index + 1,
          message: `関数名にレイヤー名を含めることは禁止されています: ${functionName}`,
          content: line.trim(),
        });
      }
    }

    // インターフェース宣言
    const interfaceMatch = line.match(/\binterface\s+(\w+)/);
    if (interfaceMatch) {
      const interfaceName = interfaceMatch[1];
      if (layerNamePattern.test(interfaceName)) {
        errors.push({
          type: 'layer_name_in_interface',
          line: index + 1,
          message: `インターフェース名にレイヤー名を含めることは禁止されています: ${interfaceName}`,
          content: line.trim(),
        });
      }
    }

    // type宣言
    const typeMatch = line.match(/\btype\s+(\w+)\s*=/);
    if (typeMatch) {
      const typeName = typeMatch[1];
      if (layerNamePattern.test(typeName)) {
        errors.push({
          type: 'layer_name_in_type',
          line: index + 1,
          message: `型名にレイヤー名を含めることは禁止されています: ${typeName}`,
          content: line.trim(),
        });
      }
    }
  });

  // コンポーネント名・関数名に数字を含むことのチェック
  lines.forEach((line, index) => {
    // コンポーネント名（大文字で始まるPascalCase関数）
    const componentMatch = line.match(/(?:function|const|export\s+(?:default\s+)?function|export\s+const)\s+([A-Z]\w*\d+\w*|\w*\d+[A-Z]\w*)(?:\s*[=(:])/);
    if (componentMatch) {
      const componentName = componentMatch[1];
      if (/\d/.test(componentName)) {
        errors.push({
          type: 'number_in_component_name',
          line: index + 1,
          message: `コンポーネント名に数字を含むことは禁止されています: ${componentName}`,
          content: line.trim(),
        });
      }
    }

    // 一般の関数名（小文字で始まるcamelCase関数）
    const functionMatch2 = line.match(/(?:function|const|let|var)\s+([a-z]\w*)(?:\s*[=(:])/);
    if (functionMatch2) {
      const functionName = functionMatch2[1];
      if (/\d/.test(functionName)) {
        errors.push({
          type: 'number_in_function_name',
          line: index + 1,
          message: `関数名に数字を含むことは禁止されています: ${functionName}`,
          content: line.trim(),
        });
      }
    }

    // アロー関数・メソッド定義での数字チェック
    const arrowOrMethodMatch = line.match(/(?:const|let|var)\s+(\w+)\s*=\s*(?:\([^)]*\)|[^=])\s*=>/);
    if (arrowOrMethodMatch) {
      const name = arrowOrMethodMatch[1];
      if (/\d/.test(name)) {
        // 大文字始まりはコンポーネント、小文字始まりは関数
        if (/^[A-Z]/.test(name)) {
          errors.push({
            type: 'number_in_component_name',
            line: index + 1,
            message: `コンポーネント名に数字を含むことは禁止されています: ${name}`,
            content: line.trim(),
          });
        } else {
          errors.push({
            type: 'number_in_function_name',
            line: index + 1,
            message: `関数名に数字を含むことは禁止されています: ${name}`,
            content: line.trim(),
          });
        }
      }
    }
  });

  // eval/new Functionの禁止チェック
  lines.forEach((line, index) => {
    // evalの使用を検出
    if (/\beval\s*\(/.test(line)) {
      errors.push({
        type: 'eval_usage',
        line: index + 1,
        message: `evalの使用は禁止されています。セキュリティリスクが高いため、別の方法を検討してください`,
        content: line.trim(),
      });
    }

    // new Functionの使用を検出
    if (/new\s+Function\s*\(/.test(line)) {
      errors.push({
        type: 'new_function_usage',
        line: index + 1,
        message: `new Functionの使用は禁止されています。動的なコード生成はセキュリティリスクが高いです`,
        content: line.trim(),
      });
    }

    // setTimeout/setIntervalで文字列を渡すパターンを検出
    const timerStringMatch = line.match(/\b(setTimeout|setInterval)\s*\(\s*["'`]/);
    if (timerStringMatch) {
      errors.push({
        type: 'timer_string_usage',
        line: index + 1,
        message: `${timerStringMatch[1]}に文字列を渡すことは禁止されています。関数を渡してください`,
        content: line.trim(),
      });
    }
  });

  // dangerouslySetInnerHTMLの検証チェック
  lines.forEach((line, index) => {
    // dangerouslySetInnerHTMLの使用を検出
    if (/dangerouslySetInnerHTML/.test(line)) {
      // 同じ行または近い行でDOMPurifyやサニタイズ処理があるかチェック
      let hasSanitization = false;
      
      // 前後5行をチェック
      for (let i = Math.max(0, index - 5); i < Math.min(lines.length, index + 5); i++) {
        if (/DOMPurify|sanitize|dompurify|xss|escape/i.test(lines[i])) {
          hasSanitization = true;
          break;
        }
      }

      if (!hasSanitization) {
        errors.push({
          type: 'dangerous_html_unverified',
          line: index + 1,
          message: `dangerouslySetInnerHTMLの使用にはサニタイズ処理が必要です。DOMPurifyなどでサニタイズしてください`,
          content: line.trim(),
        });
      }
    }
  });

  // 型の緩いコード禁止チェック
  lines.forEach((line, index) => {
    // Object型の使用を検出
    if (/:\s*Object\b/.test(line)) {
      errors.push({
        type: 'loose_object_type',
        line: index + 1,
        message: `Object型の使用は禁止されています。具体的なインターフェースや型を定義してください`,
        content: line.trim(),
      });
    }

    // Function型の使用を検出
    if (/:\s*Function\b/.test(line)) {
      errors.push({
        type: 'loose_function_type',
        line: index + 1,
        message: `Function型の使用は禁止されています。具体的な関数シグネチャを定義してください`,
        content: line.trim(),
      });
    }

    // any[]配列の使用を検出
    if (/:\s*any\[\]/.test(line)) {
      errors.push({
        type: 'any_array_type',
        line: index + 1,
        message: `any[]型の使用は禁止されています。配列要素の具体的な型を定義してください`,
        content: line.trim(),
      });
    }

    // ジェネリクスなしのPromise型を検出
    if (/:\s*Promise(?:\s|$|[^<])/.test(line)) {
      errors.push({
        type: 'untyped_promise',
        line: index + 1,
        message: `ジェネリクスなしのPromise型は禁止されています。Promise<T>の形式で戻り値の型を指定してください`,
        content: line.trim(),
      });
    }

    // Array型（Array<T>ではない）の使用を検出
    if (/:\s*Array(?:\s|$|[^<])/.test(line)) {
      errors.push({
        type: 'untyped_array',
        line: index + 1,
        message: `ジェネリクスなしのArray型は禁止されています。Array<T>または T[] の形式で要素の型を指定してください`,
        content: line.trim(),
      });
    }
  });

  // エラーハンドリング不足のチェック
  lines.forEach((line, index) => {
    // try-catchのないawait
    if (/\bawait\s+/.test(line) && !lines.slice(Math.max(0, index - 5), index + 5).some(l => /\btry\s*\{/.test(l))) {
      // async関数内かつfetch/Promise関連のawaitの場合
      if (/await\s+(fetch|axios|api|.*Promise|.*\(\))/.test(line)) {
        errors.push({
          type: 'await_without_try_catch',
          line: index + 1,
          message: `awaitにはtry-catchが必要です。エラーハンドリングを追加してください`,
          content: line.trim(),
        });
      }
    }

    // .thenのみで.catchなし
    if (/\.then\s*\(/.test(line)) {
      // 同じステートメント内に.catchがあるかチェック
      let hasСatch = false;
      let checkLine = line;
      let lineIndex = index;
      
      // 複数行にわたる場合をチェック
      while (lineIndex < lines.length && !checkLine.includes(';') && lineIndex < index + 5) {
        if (/\.catch\s*\(/.test(checkLine)) {
          hasСatch = true;
          break;
        }
        lineIndex++;
        checkLine = lines[lineIndex] || '';
      }
      
      if (!hasСatch) {
        errors.push({
          type: 'promise_without_catch',
          line: index + 1,
          message: `Promiseチェーンには.catchが必要です。エラーハンドリングを追加してください`,
          content: line.trim(),
        });
      }
    }

  });

  // localStorageセキュリティチェック
  lines.forEach((line, index) => {
    const storageMatch = line.match(/localStorage\.setItem\s*\(\s*['"`]([^'"`]+)['"`]/);
    if (storageMatch) {
      const key = storageMatch[1].toLowerCase();
      
      // 機密情報のキーワードをチェック
      const sensitiveKeywords = [
        'password', 'pwd', 'pass', 'secret', 'token', 'auth',
        'key', 'api', 'credential', 'private', 'ssn', 'card'
      ];
      
      if (sensitiveKeywords.some(keyword => key.includes(keyword))) {
        errors.push({
          type: 'localstorage_sensitive_data',
          line: index + 1,
          message: `localStorageに機密情報を保存することは禁止されています。セキュアな方法を使用してください`,
          content: line.trim(),
        });
      }
    }
    
    // sessionStorageも同様にチェック
    const sessionMatch = line.match(/sessionStorage\.setItem\s*\(\s*['"`]([^'"`]+)['"`]/);
    if (sessionMatch) {
      const key = sessionMatch[1].toLowerCase();
      
      const sensitiveKeywords = [
        'password', 'pwd', 'pass', 'secret', 'token', 'auth',
        'key', 'api', 'credential', 'private', 'ssn', 'card'
      ];
      
      if (sensitiveKeywords.some(keyword => key.includes(keyword))) {
        errors.push({
          type: 'sessionstorage_sensitive_data',
          line: index + 1,
          message: `sessionStorageに機密情報を保存することは禁止されています。セキュアな方法を使用してください`,
          content: line.trim(),
        });
      }
    }
  });

  // React indexをkeyに使用禁止チェック
  lines.forEach((line, index) => {
    // key={index} パターンを検出
    if (/key\s*=\s*\{?\s*index\s*\}?/.test(line)) {
      errors.push({
        type: 'react_index_as_key',
        line: index + 1,
        message: `indexをkeyに使用することは禁止されています。一意で安定したIDを使用してください`,
        content: line.trim(),
      });
    }
    
    // key={i} のような変数名も検出
    if (/key\s*=\s*\{?\s*[ij]\s*\}?/.test(line)) {
      // mapの引数がiやjの場合
      const mapPattern = /\.map\s*\(\s*\([^,]+,\s*([ij])\)/;
      const prevLines = lines.slice(Math.max(0, index - 3), index).join('\n');
      if (mapPattern.test(prevLines)) {
        errors.push({
          type: 'react_index_as_key',
          line: index + 1,
          message: `indexをkeyに使用することは禁止されています。一意で安定したIDを使用してください`,
          content: line.trim(),
        });
      }
    }
    
    // key={`prefix-${index}`} のようなパターンも検出
    if (/key\s*=\s*\{[`'"].*\$\{?\s*(index|[ij])\s*\}?.*[`'"]/.test(line)) {
      errors.push({
        type: 'react_index_as_key',
        line: index + 1,
        message: `indexをkeyに使用することは禁止されています。一意で安定したIDを使用してください`,
        content: line.trim(),
      });
    }
  });

  // @ts-ignore/@ts-nocheck/@ts-expect-errorの禁止チェック
  lines.forEach((line, index) => {
    // @ts-ignoreの検出
    if (/@ts-ignore/.test(line)) {
      errors.push({
        type: 'ts_ignore_usage',
        line: index + 1,
        message: `@ts-ignoreの使用は禁止されています。適切な型定義を追加して型エラーを解決してください`,
        content: line.trim(),
      });
    }

    // @ts-nocheckの検出
    if (/@ts-nocheck/.test(line)) {
      errors.push({
        type: 'ts_nocheck_usage',
        line: index + 1,
        message: `@ts-nocheckの使用は禁止されています。ファイル全体の型チェックを無効化せず、個別に型定義を修正してください`,
        content: line.trim(),
      });
    }

    // @ts-expect-errorの検出（より制限的に）
    if (/@ts-expect-error/.test(line)) {
      // コメントで理由が書かれているかチェック
      const hasReason = /@ts-expect-error\s+\S/.test(line);
      if (!hasReason) {
        errors.push({
          type: 'ts_expect_error_no_reason',
          line: index + 1,
          message: `@ts-expect-errorを使用する場合は、理由を明記してください。可能な限り型定義で解決してください`,
          content: line.trim(),
        });
      }
    }
  });

  // fetchの内部APIパス・ローカルファイルチェック
  lines.forEach((line, index) => {
    const fetchMatch = line.match(/fetch\s*\(\s*(['"`])(.*?)\1/);
    
    if (fetchMatch) {
      const url = fetchMatch[2];
      
      // 外部URL（http/https）は許可
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return; // OK
      }
      
      // ローカルファイルパス
      if (url.startsWith('./') || url.startsWith('../') || 
          /\.(json|txt|xml|csv|yaml|yml)$/.test(url)) {
        errors.push({
          type: 'fetch_local_file',
          line: index + 1,
          message: `fetchでローカルファイルへのアクセスは禁止されています: "${url}"`,
          content: line.trim(),
        });
        return;
      }
      
      // 内部APIパス（/で始まる）
      if (url.startsWith('/')) {
        errors.push({
          type: 'fetch_internal_api_literal',
          line: index + 1,
          message: `内部APIへの文字列リテラルでのfetchは禁止されています。定数化またはAPIクライアントを使用してください: "${url}"`,
          content: line.trim(),
        });
      }
    }
  });

  // useEffectの使用禁止チェック
  lines.forEach((line, index) => {
    // useEffectの呼び出しを検出
    if (/\buseEffect\s*\(/.test(line)) {
      errors.push({
        type: 'use_effect_forbidden',
        line: index + 1,
        message: `useEffectの使用は禁止されています。データ取得はTanStack Query/SWR、イベントリスナーはカスタムフックを使用してください`,
        content: line.trim(),
      });
    }
  });

  // DOM直接操作の禁止チェック
  lines.forEach((line, index) => {
    // document系のメソッド
    const documentMethods = /document\.(getElementById|getElementsByClassName|getElementsByTagName|querySelector|querySelectorAll|createElement)/;
    if (documentMethods.test(line)) {
      errors.push({
        type: 'dom_direct_manipulation',
        line: index + 1,
        message: `DOMの直接操作は禁止されています。ReactのuseRefやイベントハンドラを使用してください`,
        content: line.trim(),
      });
    }
    
    // window系の直接操作
    const windowMethods = /window\.(scrollTo|scroll|alert|confirm|prompt|location\.href\s*=)/;
    if (windowMethods.test(line)) {
      errors.push({
        type: 'window_direct_manipulation',
        line: index + 1,
        message: `windowオブジェクトの直接操作は禁止されています。適切なReactパターンやライブラリを使用してください`,
        content: line.trim(),
      });
    }
    
    // elementのstyle直接操作
    if (/\.style\.[a-zA-Z]+ *=/.test(line) && !line.includes('ref.current')) {
      errors.push({
        type: 'style_direct_manipulation',
        line: index + 1,
        message: `styleプロパティの直接操作は禁止されています。CSSクラスやCSS-in-JSを使用してください`,
        content: line.trim(),
      });
    }
  });

  // インラインstyleの禁止チェック
  lines.forEach((line, index) => {
    // JSX内のstyle属性
    const inlineStylePattern = /style\s*=\s*\{\{|style\s*=\s*["']/;
    if (inlineStylePattern.test(line)) {
      // コメント行ではない場合
      const trimmedLine = line.trim();
      if (!trimmedLine.startsWith('//') && !trimmedLine.startsWith('*')) {
        errors.push({
          type: 'inline_style_forbidden',
          line: index + 1,
          message: `インラインstyleの使用は禁止されています。CSS Modules、styled-components、CSS-in-JSライブラリを使用してください`,
          content: line.trim(),
        });
      }
    }
    
    // HTML内のstyleタグ
    if (/<style[^>]*>/.test(line) && !filePath.includes('.css') && !filePath.includes('.scss')) {
      errors.push({
        type: 'style_tag_forbidden',
        line: index + 1,
        message: `<style>タグの使用は禁止されています。外部CSSファイルまたはCSS-in-JSを使用してください`,
        content: line.trim(),
      });
    }
  });

  // forループ・forEach禁止チェック
  lines.forEach((line, index) => {
    // forループ
    if (/\bfor\s*\(/.test(line)) {
      errors.push({
        type: 'for_loop_forbidden',
        line: index + 1,
        message: `forループの使用は禁止されています。map、filter、reduceなどの関数型メソッドを使用してください`,
        content: line.trim(),
      });
    }
    
    // forEach
    if (/\.forEach\s*\(/.test(line)) {
      errors.push({
        type: 'foreach_forbidden',
        line: index + 1,
        message: `forEachの使用は禁止されています。map、filter、reduceなどの関数型メソッドを使用してください`,
        content: line.trim(),
      });
    }
  });

  // 配列の破壊的メソッド禁止チェック
  lines.forEach((line, index) => {
    // 配列の破壊的メソッドを検出
    // 配列変数名の一般的なパターンにマッチするよう改善
    const arrayPattern = /(?:(?:array|list|items|elements|data|values|results|collection|arr)\w*|[a-z]+(?:Array|List|Items|Elements|Data|Values|Results|Collection))\.(push|pop|shift|unshift|splice|sort|reverse)\s*\(/i;
    
    // router.push, history.push, navigation.push などのルーティング関連は除外
    const routerPattern = /(?:router|route|history|navigation|navigate|nav|location)\.\w*\.?push\s*\(/i;
    
    // stack.push, queue.push などのデータ構造操作も除外
    const dataStructurePattern = /(?:stack|queue|heap|tree|graph)\.\w*\.?push\s*\(/i;
    
    const match = line.match(arrayPattern);
    
    if (match && !routerPattern.test(line) && !dataStructurePattern.test(line)) {
      // さらに厳密にチェック: 本当に配列操作かを確認
      // 変数名が明らかに配列を示す場合のみエラーとする
      const fullMatch = match[0];
      const variableName = fullMatch.split('.')[0];
      
      // 明確に配列を示す変数名パターン
      const isLikelyArray = /(?:array|list|items|elements|data|values|results|collection|^arr$)/i.test(variableName) ||
                            /(?:Array|List|Items|Elements|Data|Values|Results|Collection)$/.test(variableName);
      
      if (isLikelyArray) {
        const method = match[1];
        const alternatives = {
          push: '[...array, item]',
          pop: 'array.slice(0, -1)',
          shift: 'array.slice(1)',
          unshift: '[item, ...array]',
          splice: 'array.toSpliced() または filter',
          sort: '[...array].sort() または array.toSorted()',
          reverse: '[...array].reverse() または array.toReversed()'
        };
        
        errors.push({
          type: 'destructive_array_method',
          line: index + 1,
          message: `破壊的メソッド "${method}" の使用は禁止されています。代替: ${alternatives[method]}`,
          content: line.trim(),
        });
      }
    }
  });

  // var・let禁止（const強制）チェック
  lines.forEach((line, index) => {
    // varの使用
    if (/\bvar\s+\w+/.test(line)) {
      errors.push({
        type: 'var_forbidden',
        line: index + 1,
        message: `varの使用は禁止されています。constまたはletを使用してください`,
        content: line.trim(),
      });
    }
    
    // letの使用（警告）
    if (/\blet\s+\w+/.test(line)) {
      warnings.push({
        type: 'let_usage',
        line: index + 1,
        message: `letの使用を検出しました。再代入が必要ない場合はconstを使用してください`,
        content: line.trim(),
      });
    }
  });

  // else禁止（早期リターン推奨）チェック
  lines.forEach((line, index) => {
    // elseの使用を検出
    if (/\belse\s*\{/.test(line)) {
      // コメント行ではない場合
      const trimmedLine = line.trim();
      if (!trimmedLine.startsWith('//') && !trimmedLine.startsWith('*')) {
        errors.push({
          type: 'else_usage',
          line: index + 1,
          message: `elseの使用は禁止されています。早期リターンでコードを簡素化してください`,
          content: line.trim(),
        });
      }
    }
  });

  // 制御構造のネスト禁止チェック（4層以上）
  let braceStack = [];
  let controlFlowNesting = [];
  
  lines.forEach((line, index) => {
    const trimmedLine = line.trim();
    
    // 制御構造の開始を検出
    const controlFlowMatch = trimmedLine.match(/\b(if|for|while|switch|try|catch|finally|else\s+if)\s*\(/);
    const doMatch = trimmedLine.match(/\bdo\s*\{/);
    const elseMatch = trimmedLine.match(/\belse\s*\{/);
    
    if (controlFlowMatch || doMatch || elseMatch) {
      // 制御構造の種類を記録
      const controlType = controlFlowMatch ? controlFlowMatch[1] : (doMatch ? 'do' : 'else');
      
      // 同じ行に開き波括弧があるかチェック
      if (trimmedLine.includes('{')) {
        braceStack.push({ type: 'control', controlType, line: index });
        controlFlowNesting.push(controlType);
        
        // ネストレベルをチェック
        if (controlFlowNesting.length >= 4) {
          errors.push({
            type: 'deep_control_nesting',
            line: index + 1,
            message: `制御構造のネストが深すぎます（${controlFlowNesting.length}層）。if/for/while等のネストは3層までに制限してください`,
            content: trimmedLine,
          });
        }
      }
    } else if (trimmedLine === '{' && lines[index - 1]) {
      // 前の行に制御構造があるかチェック
      const prevLine = lines[index - 1].trim();
      const prevControlFlow = prevLine.match(/\b(if|for|while|switch|try|catch|finally|else\s+if)\s*\(/);
      const prevDo = prevLine.match(/\bdo\s*$/);
      const prevElse = prevLine.match(/\belse\s*$/);
      
      if (prevControlFlow || prevDo || prevElse) {
        const controlType = prevControlFlow ? prevControlFlow[1] : (prevDo ? 'do' : 'else');
        braceStack.push({ type: 'control', controlType, line: index });
        controlFlowNesting.push(controlType);
        
        if (controlFlowNesting.length >= 4) {
          errors.push({
            type: 'deep_control_nesting',
            line: index,
            message: `制御構造のネストが深すぎます（${controlFlowNesting.length}層）。if/for/while等のネストは3層までに制限してください`,
            content: prevLine,
          });
        }
      }
    } else if (trimmedLine === '{') {
      // その他の開き波括弧（関数、クラス、オブジェクトリテラルなど）
      braceStack.push({ type: 'other', line: index });
    } else if (trimmedLine === '}' || trimmedLine.startsWith('}')) {
      // 閉じ波括弧
      if (braceStack.length > 0) {
        const lastBrace = braceStack.pop();
        if (lastBrace.type === 'control') {
          controlFlowNesting.pop();
        }
      }
    }
  });

  // JSX/HTMLのネスト禁止チェック（6層以上）
  let jsxNestingLevel = 0;
  let jsxTagStack = [];
  let deepNestLineReported = new Set(); // 同じ行で複数回エラーを出さないためのトラッキング
  
  lines.forEach((line, index) => {
    // コメント行は無視
    if (line.trim().startsWith('//') || line.trim().startsWith('/*') || line.trim().startsWith('*')) {
      return;
    }
    
    // JSX/HTMLタグの検出（複数タグが1行にある場合も処理）
    let remainingLine = line;
    let charIndex = 0;
    let lineHasDeepNest = false;
    
    while (remainingLine.length > 0) {
      // 開始タグを検出（セルフクロージング以外）
      const openTagMatch = remainingLine.match(/<([A-Za-z][A-Za-z0-9._-]*|[a-z][a-z0-9-]*)[^>]*(?<!\/)>/);
      // 閉じタグを検出
      const closeTagMatch = remainingLine.match(/<\/([A-Za-z][A-Za-z0-9._-]*|[a-z][a-z0-9-]*)>/);
      // セルフクロージングタグを検出
      const selfClosingMatch = remainingLine.match(/<([A-Za-z][A-Za-z0-9._-]*|[a-z][a-z0-9-]*)[^>]*\/>/);
      
      let earliestMatch = null;
      let matchType = null;
      let matchIndex = Infinity;
      
      // 最も早い位置のマッチを見つける
      if (openTagMatch && openTagMatch.index < matchIndex) {
        earliestMatch = openTagMatch;
        matchType = 'open';
        matchIndex = openTagMatch.index;
      }
      if (closeTagMatch && closeTagMatch.index < matchIndex) {
        earliestMatch = closeTagMatch;
        matchType = 'close';
        matchIndex = closeTagMatch.index;
      }
      if (selfClosingMatch && selfClosingMatch.index < matchIndex) {
        earliestMatch = selfClosingMatch;
        matchType = 'selfClosing';
        matchIndex = selfClosingMatch.index;
      }
      
      if (!earliestMatch) {
        break; // もうタグがない
      }
      
      if (matchType === 'open') {
        jsxNestingLevel++;
        jsxTagStack.push(earliestMatch[1]);
        
        // 6層以上のネストを検出し、その行でまだ報告していない場合のみエラーを追加
        if (jsxNestingLevel >= 6 && !deepNestLineReported.has(index)) {
          lineHasDeepNest = true;
        }
      } else if (matchType === 'close') {
        if (jsxTagStack.length > 0) {
          jsxNestingLevel--;
          jsxTagStack.pop();
        }
      }
      // セルフクロージングタグは無視（ネストレベルに影響しない）
      
      // 処理した部分を削除して次を探す
      charIndex += matchIndex + earliestMatch[0].length;
      remainingLine = remainingLine.substring(matchIndex + earliestMatch[0].length);
    }
    
    // この行で深いネストが検出された場合、一度だけエラーを追加
    if (lineHasDeepNest) {
      deepNestLineReported.add(index);
      errors.push({
        type: 'deep_jsx_nesting',
        line: index + 1,
        message: `JSX/HTMLのネストが深すぎます（6層以上）。JSX/HTMLのネストは5層までに制限してください`,
        content: line.trim(),
      });
    }
  });

  // 関数の引数が多すぎるチェック（5個以上）
  lines.forEach((line, index) => {
    // 関数定義のパターン（function、アロー関数、メソッド）
    const functionPatterns = [
      // function宣言
      /function\s+\w*\s*\(([^)]*)\)/,
      // アロー関数
      /(?:const|let|var)\s+\w+\s*=\s*(?:async\s*)?\(([^)]*)\)\s*=>/,
      // メソッド定義（クラスメソッド、オブジェクトメソッド）
      /\w+\s*:\s*(?:async\s*)?(?:function\s*)?\(([^)]*)\)/,
      // TypeScriptのメソッドシグネチャ
      /\w+\s*\(([^)]*)\)\s*:/,
    ];
    
    for (const pattern of functionPatterns) {
      const match = line.match(pattern);
      if (match) {
        const params = match[1];
        if (params.trim()) {
          // 引数を分割（カンマで分割、ただしジェネリクスやオブジェクト内のカンマは考慮）
          let bracketDepth = 0;
          let currentParam = '';
          const paramList = [];
          
          for (const char of params) {
            if (char === '<' || char === '{' || char === '[' || char === '(') {
              bracketDepth++;
            } else if (char === '>' || char === '}' || char === ']' || char === ')') {
              bracketDepth--;
            }
            
            if (char === ',' && bracketDepth === 0) {
              if (currentParam.trim()) {
                paramList.push(currentParam.trim());
              }
              currentParam = '';
            } else {
              currentParam += char;
            }
          }
          
          if (currentParam.trim()) {
            paramList.push(currentParam.trim());
          }
          
          // 5個以上の引数がある場合
          if (paramList.length >= 5) {
            errors.push({
              type: 'too_many_parameters',
              line: index + 1,
              message: `関数の引数が多すぎます（${paramList.length}個）。5個未満に制限してください。オブジェクトでまとめることを検討してください`,
              content: line.trim(),
            });
          }
        }
        break; // 1行につき1つの関数定義のみチェック
      }
    }
  });

  // require文の禁止
  lines.forEach((line, index) => {
    // 現在のファイル内でのrequireは許可（pre-write-check.js自体など）
    if (/\brequire\s*\(/.test(line) && !line.includes('__dirname')) {
      errors.push({
        type: 'require_forbidden',
        line: index + 1,
        message: `requireは禁止されています。ES6 importを使用してください`,
        content: line.trim(),
      });
    }
  });

  // == / != 禁止
  lines.forEach((line, index) => {
    // === や !== は除外
    if (/[^=!]==[^=]/.test(line)) {
      errors.push({
        type: 'loose_equality',
        line: index + 1,
        message: `==演算子は禁止されています。===を使用してください`,
        content: line.trim(),
      });
    }
    if (/[^=!]!=[^=]/.test(line)) {
      errors.push({
        type: 'loose_inequality',
        line: index + 1,
        message: `!=演算子は禁止されています。!==を使用してください`,
        content: line.trim(),
      });
    }
  });

  // 型アサーション制限（as const以外）
  lines.forEach((line, index) => {
    // as constは許可、それ以外のasは禁止
    if (/\bas\s+(?!const\b)\w+/.test(line)) {
      errors.push({
        type: 'type_assertion_forbidden',
        line: index + 1,
        message: `型アサーション（as）は禁止されています。as const以外は適切な型定義を使用してください`,
        content: line.trim(),
      });
    }
  });

  // 非nullアサーション（!）禁止
  lines.forEach((line, index) => {
    // obj!.method() や value! のパターンを検出
    if (/[a-zA-Z_$][a-zA-Z0-9_$]*!\./g.test(line) || /[a-zA-Z_$][a-zA-Z0-9_$]*!\s*[;,\)\}]/g.test(line)) {
      errors.push({
        type: 'non_null_assertion',
        line: index + 1,
        message: `非nullアサーション（!）は禁止されています。適切なnullチェックを行ってください`,
        content: line.trim(),
      });
    }
  });

  // switch文の禁止（ts-pattern推奨）
  lines.forEach((line, index) => {
    // switch文を検出
    if (/\bswitch\s*\(/.test(line)) {
      errors.push({
        type: 'switch_statement_forbidden',
        line: index + 1,
        message: `switch文は禁止されています。ts-patternライブラリのmatch関数を使用してください`,
        content: line.trim(),
      });
    }
  });

  // 三項演算子のネスト禁止
  lines.forEach((line, index) => {
    // 三項演算子のネストを検出
    // ? と : の数を数えて、2つ以上の ? があればネストしている
    const questionMarkCount = (line.match(/\?/g) || []).length;
    const colonCount = (line.match(/:/g) || []).length;
    
    // 型定義の : は除外するため、三項演算子の特徴的なパターンをチェック
    if (questionMarkCount >= 2) {
      // より正確な検出のため、三項演算子のパターンをチェック
      // 条件 ? 値 : 値 のパターンが2つ以上あるか
      const ternaryPattern = /[^?]+\?[^:?]+:[^?]+\?[^:]+:/;
      if (ternaryPattern.test(line)) {
        errors.push({
          type: 'nested_ternary',
          line: index + 1,
          message: `三項演算子のネストは禁止されています。if文や早期リターンを使用してください`,
          content: line.trim(),
        });
      }
    }
  });

  // 空のcatchブロック禁止（既存のチェックを強化）
  lines.forEach((line, index) => {
    // catchブロックの開始を検出
    if (/\bcatch\s*\([^)]*\)\s*\{/.test(line)) {
      // 同じ行に閉じ括弧があるかチェック（1行の空catch）
      if (/\bcatch\s*\([^)]*\)\s*\{\s*\}/.test(line)) {
        errors.push({
          type: 'empty_catch_block',
          line: index + 1,
          message: `空のcatchブロックは禁止されています。エラーを適切に処理するか、少なくともログ出力してください`,
          content: line.trim(),
        });
        return;
      }
      
      // 次の数行をチェック（複数行の空catch）
      let braceCount = 1;
      let hasContent = false;
      
      for (let i = index + 1; i < Math.min(lines.length, index + 10); i++) {
        const nextLine = lines[i].trim();
        
        // コメント以外の内容があるかチェック
        if (nextLine && !nextLine.startsWith('//') && !nextLine.startsWith('/*') && !nextLine.startsWith('*')) {
          if (nextLine !== '}') {
            hasContent = true;
          }
        }
        
        // 波括弧のカウント
        braceCount += (nextLine.match(/\{/g) || []).length;
        braceCount -= (nextLine.match(/\}/g) || []).length;
        
        if (braceCount === 0) {
          // catchブロックの終了
          if (!hasContent) {
            errors.push({
              type: 'empty_catch_block',
              line: index + 1,
              message: `空のcatchブロックは禁止されています。エラーを適切に処理するか、少なくともログ出力してください`,
              content: line.trim(),
            });
          }
          break;
        }
      }
    }
  })

  // I/Tプレフィックス禁止チェック
  lines.forEach((line, index) => {
    // interface Iプレフィックス
    const interfaceMatch = line.match(/\binterface\s+(I[A-Z]\w*)/);
    if (interfaceMatch) {
      errors.push({
        type: 'interface_i_prefix',
        line: index + 1,
        message: `interface名の"I"プレフィックスは禁止されています: ${interfaceMatch[1]}`,
        content: line.trim(),
      });
    }
    
    // type Tプレフィックス
    const typeMatch = line.match(/\btype\s+(T[A-Z]\w*)\s*=/);
    if (typeMatch) {
      errors.push({
        type: 'type_t_prefix',
        line: index + 1,
        message: `type名の"T"プレフィックスは禁止されています: ${typeMatch[1]}`,
        content: line.trim(),
      });
    }
    
    // Typeサフィックス、Interfaceサフィックス
    const typeSuffixMatch = line.match(/\b(type|interface)\s+(\w*(?:Type|Interface))\b/);
    if (typeSuffixMatch) {
      errors.push({
        type: 'type_suffix',
        line: index + 1,
        message: `型名の"Type"/"Interface"サフィックスは禁止されています: ${typeSuffixMatch[2]}`,
        content: line.trim(),
      });
    }
  });

  // ファイル名の命名規則チェック
  if (filePath && isSourceFile(filePath)) {
    const fileName = path.basename(filePath, path.extname(filePath));
    const fileExt = path.extname(filePath);
    
    // Python/Go以外でsnake_caseを使用（_から始まるファイルは許可）
    if (!/\.(py|go)$/.test(fileExt) && /_/.test(fileName) && !/^_/.test(fileName)) {
      errors.push({
        type: 'filename_underscore',
        line: 0,
        message: `TypeScript/JavaScriptではsnake_caseのファイル名は禁止です。kebab-caseを使用してください: ${fileName}${fileExt}`,
        content: fileName,
      });
    }
    
    // TypeScript/JavaScriptでcamelCaseを使用
    if (/\.(ts|tsx|js|jsx)$/.test(fileExt) && /[a-z][A-Z]/.test(fileName)) {
      errors.push({
        type: 'filename_camelcase',
        line: 0,
        message: `TypeScript/JavaScriptのcamelCaseのファイル名は禁止です。kebab-caseを使用してください: ${fileName}${fileExt}`,
        content: fileName,
      });
    }
    
    // 大文字で始まるファイル名（コンポーネント以外）
    if (/^[A-Z]/.test(fileName) && !/\.(tsx|jsx)$/.test(fileExt)) {
      errors.push({
        type: 'filename_uppercase',
        line: 0,
        message: `大文字で始まるファイル名は禁止されています。コンポーネント以外は小文字始まりのkebab-caseを使用してください: ${fileName}${fileExt}`,
        content: fileName,
      });
    }
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
            content: line.trim(),
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
          content: line.trim(),
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
          content: line.trim(),
        });
      }
    });
  }

  // カスタムパターンのチェック
  if (config.customPatterns && config.customPatterns.length > 0) {
    config.customPatterns.forEach((pattern) => {
      const regex = new RegExp(pattern.pattern, pattern.flags || 'g');
      lines.forEach((line, index) => {
        if (regex.test(line)) {
          const item = {
            type: 'custom',
            line: index + 1,
            message: pattern.message || `Line ${index + 1}: カスタムルール違反`,
            content: line.trim(),
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

  // JSX/TSXファイルの行数制限チェック
  if (filePath && /\.(jsx|tsx)$/.test(filePath)) {
    const totalLines = lines.length;
    
    if (totalLines > 200) {
      errors.push({
        type: 'jsx_file_too_large',
        line: 0,
        message: `JSX/TSXファイルが大きすぎます（${totalLines}行）。200行以内に収めてください。コンポーネントを分割することを検討してください`,
        content: `ファイル全体: ${totalLines}行`,
      });
    } else if (totalLines > 150) {
      warnings.push({
        type: 'jsx_file_large',
        line: 0,
        message: `JSX/TSXファイルが大きくなっています（${totalLines}行）。150行を超えるとコンポーネントの分割を検討してください`,
        content: `ファイル全体: ${totalLines}行`,
      });
    }
  }

  // return文内のJSX構造の行数チェック（JSX/TSXファイルのみ）
  if (filePath && /\.(jsx|tsx)$/.test(filePath)) {
    // 全てのreturn文を検索して、その範囲をチェック
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      // return文を検出
      if (/\breturn\s*[(<]/.test(line)) {
        let returnStart = i;
        let returnEnd = i;
        let openParens = 0;
        let openTags = 0;
        
        // 最初の行の括弧とタグをカウント
        openParens += (line.match(/\(/g) || []).length - (line.match(/\)/g) || []).length;
        
        // JSXタグのカウント（セルフクローズは除外）
        const openingTags = (line.match(/<[A-Za-z][^>]*(?<!\/)\s*>/g) || []).length;
        const closingTags = (line.match(/<\/[A-Za-z][^>]*>/g) || []).length;
        openTags += openingTags - closingTags;
        
        // return文の終了を探す
        for (let j = i + 1; j < lines.length; j++) {
          const currentLine = lines[j];
          
          // 括弧のカウント
          openParens += (currentLine.match(/\(/g) || []).length - (currentLine.match(/\)/g) || []).length;
          
          // タグのカウント
          const currentOpeningTags = (currentLine.match(/<[A-Za-z][^>]*(?<!\/)\s*>/g) || []).length;
          const currentClosingTags = (currentLine.match(/<\/[A-Za-z][^>]*>/g) || []).length;
          openTags += currentOpeningTags - currentClosingTags;
          
          // return文の終了条件
          // 1. セミコロンで終了
          // 2. 全ての括弧とタグが閉じられて、次の行が } で始まる
          if (/;\s*$/.test(currentLine) || 
              (openParens <= 0 && openTags <= 0 && j + 1 < lines.length && /^\s*\}/.test(lines[j + 1]))) {
            returnEnd = j;
            break;
          }
          
          // ファイルの最後
          if (j === lines.length - 1) {
            returnEnd = j;
            break;
          }
        }
        
        // return文の行数を計算
        const returnLines = returnEnd - returnStart + 1;
        
        // 100行以上で警告、200行以上でエラー
        if (returnLines > 200) {
          errors.push({
            type: 'large_jsx_return',
            line: returnStart + 1,
            message: `return文内のJSX構造が大きすぎます（${returnLines}行）。200行以内に収めてください。子コンポーネントに分割することを検討してください`,
            content: `return文のJSX: ${returnLines}行`,
          });
        } else if (returnLines > 100) {
          warnings.push({
            type: 'large_jsx_return_warning',
            line: returnStart + 1,
            message: `return文内のJSX構造が大きくなっています（${returnLines}行）。100行を超える場合は子コンポーネントへの分割を検討してください`,
            content: `return文のJSX: ${returnLines}行`,
          });
        }
        
        // 次のreturn文を探すため、iを更新
        i = returnEnd;
      }
    }
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
    warnings.forEach((warning) => {
      console.error(`  ${colors.yellow}→${colors.reset} ${warning.message}`);
      if (warning.content) {
        console.error(`    ${colors.cyan}${warning.content}${colors.reset}`);
      }
    });
  }

  if (errors.length > 0) {
    console.error(`\n${colors.red}❌ Blocking Errors (${errors.length})${colors.reset}`);
    errors.forEach((error) => {
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
    const errorTypes = [...new Set(errors.map((e) => e.type))];

    if (errorTypes.includes('as_any')) {
      console.error(
        `  1. ${colors.yellow}"as any"${colors.reset} → 適切な型定義を使用してください`
      );
    }
    if (errorTypes.includes('any_type')) {
      console.error(
        `  2. ${colors.yellow}": any"${colors.reset} → 適切な型定義を使用してください`
      );
    }
    if (errorTypes.includes('generic_any')) {
      console.error(
        `  3. ${colors.yellow}"<any>"${colors.reset} → 適切な型パラメータを使用してください`
      );
    }
    if (errorTypes.includes('unknown_type')) {
      console.error(
        `  4. ${colors.yellow}"unknown"${colors.reset} → 具体的な型定義を使用してください`
      );
    }
    if (errorTypes.includes('class_syntax')) {
      console.error(
        `  5. ${colors.yellow}"class"${colors.reset} → 関数型コンポーネントまたはファクトリー関数を使用`
      );
    }
    if (errorTypes.includes('console')) {
      console.error(
        `  6. ${colors.yellow}"console.*"${colors.reset} → 削除するか、適切なロギングライブラリを使用`
      );
    }
    if (errorTypes.includes('debugger')) {
      console.error(`  7. ${colors.yellow}"debugger"${colors.reset} → デバッグ文を削除`);
    }
    if (errorTypes.includes('layer_name_in_filename') || errorTypes.includes('layer_name_in_function') || errorTypes.includes('layer_name_in_interface') || errorTypes.includes('layer_name_in_type')) {
      console.error(
        `  8. ${colors.yellow}"レイヤー名"${colors.reset} → レイヤー名（Repo、Repository、UseCase、Service、Controller）を命名から除外`
      );
    }
    if (errorTypes.includes('fetch_local_file')) {
      console.error(
        `  9. ${colors.yellow}"fetch(ローカルファイル)"${colors.reset} → import文またはAPIエンドポイント経由で取得`
      );
    }
    if (errorTypes.includes('fetch_internal_api_literal')) {
      console.error(
        `  10. ${colors.yellow}"fetch('/api/...')"${colors.reset} → エンドポイントを定数化またはAPIクライアントを使用`
      );
      console.error(`     例: const API_ENDPOINTS = { USERS: '/api/users' } as const;`);
      console.error(`     例: apiClient.users.get() または trpc.user.getAll.query()`);
    }
    if (errorTypes.includes('use_effect_forbidden')) {
      console.error(
        `  11. ${colors.yellow}"useEffect"${colors.reset} → TanStack Query/SWR、カスタムフック、またはユーザーに確認`
      );
      console.error(`     データ取得: useQuery, useSWR`);
      console.error(`     イベント: カスタムフック（useWindowEvent等）`);
      console.error(`     どうしても必要な場合: ユーザーに確認してから追加`);
    }
    if (errorTypes.includes('dom_direct_manipulation') || errorTypes.includes('window_direct_manipulation') || errorTypes.includes('style_direct_manipulation')) {
      console.error(
        `  12. ${colors.yellow}"DOM直接操作"${colors.reset} → Reactの方法を使用`
      );
      console.error(`     document.getElementById → useRef`);
      console.error(`     window.scrollTo → react-use の useWindowScroll`);
      console.error(`     element.style.* → className, CSS-in-JS`);
    }
    if (errorTypes.includes('inline_style_forbidden') || errorTypes.includes('style_tag_forbidden')) {
      console.error(
        `  13. ${colors.yellow}"インラインstyle"${colors.reset} → CSSモジュールやCSS-in-JSを使用`
      );
      console.error(`     style={{}} → className={styles.foo}`);
      console.error(`     CSS Modules, styled-components, emotion, Tailwind CSSなど`);
      console.error(`     スタイルの分離で保守性を向上`);
    }
    if (errorTypes.includes('for_loop_forbidden') || errorTypes.includes('foreach_forbidden')) {
      console.error(
        `  14. ${colors.yellow}"for/forEach"${colors.reset} → 関数型メソッドを使用`
      );
      console.error(`     forループ → map(), filter(), reduce()`);
      console.error(`     forEach → map()（副作用が必要な場合は例外）`);
    }
    if (errorTypes.includes('destructive_array_method')) {
      console.error(
        `  15. ${colors.yellow}"破壊的メソッド"${colors.reset} → イミュータブルな操作を使用`
      );
      console.error(`     push() → [...array, item]`);
      console.error(`     sort() → [...array].sort() または toSorted()`);
      console.error(`     splice() → toSpliced() または filter()`);
    }
    if (errorTypes.includes('var_forbidden')) {
      console.error(
        `  16. ${colors.yellow}"var"${colors.reset} → constまたはletを使用`
      );
    }
    if (errorTypes.includes('interface_i_prefix') || errorTypes.includes('type_t_prefix') || errorTypes.includes('type_suffix')) {
      console.error(
        `  17. ${colors.yellow}"I/Tプレフィックス・サフィックス"${colors.reset} → プレフィックス/サフィックスなしの名前を使用`
      );
      console.error(`     IUser → User`);
      console.error(`     TResponse → Response`);
      console.error(`     UserType → User`);
      console.error(`     PropsInterface → Props`);
    }
    if (errorTypes.includes('require_forbidden')) {
      console.error(
        `  18. ${colors.yellow}"require"${colors.reset} → ES6のimport文を使用`
      );
      console.error(`     const fs = require('fs') → import fs from 'fs'`);
      console.error(`     const { readFile } = require('fs') → import { readFile } from 'fs'`);
    }
    if (errorTypes.includes('loose_equality') || errorTypes.includes('loose_inequality')) {
      console.error(
        `  19. ${colors.yellow}"== / !="${colors.reset} → 厳密等価演算子を使用`
      );
      console.error(`     == → ===`);
      console.error(`     != → !==`);
    }
    if (errorTypes.includes('type_assertion_forbidden')) {
      console.error(
        `  20. ${colors.yellow}"as 型"${colors.reset} → 適切な型定義を使用`
      );
      console.error(`     value as string → 型ガード関数や型推論を利用`);
      console.error(`     response as User → zod等での検証後の型推論`);
      console.error(`     許可: オブジェクト as const`);
    }
    if (errorTypes.includes('non_null_assertion')) {
      console.error(
        `  21. ${colors.yellow}"!（非nullアサーション）"${colors.reset} → 適切なnullチェック`
      );
      console.error(`     user!.name → if (user) { user.name }`);
      console.error(`     array.find()! → const result = array.find(); if (result) {...}`);
      console.error(`     オプショナルチェーン（?.）の使用も検討`);
    }
    if (errorTypes.includes('filename_underscore') || errorTypes.includes('filename_camelcase') || errorTypes.includes('filename_uppercase')) {
      console.error(
        `  22. ${colors.yellow}"ファイル名の命名規則"${colors.reset} → kebab-caseを使用`
      );
      console.error(`     userProfile.ts → user-profile.ts`);
      console.error(`     UserService.js → user-service.js`);
      console.error(`     get_user_data.tsx → get-user-data.tsx`);
      console.error(`     UserHelper.ts → user-helper.ts`);
      console.error(`     例外: Python/Goではsnake_caseが許可、React Component（.tsx/.jsx）は大文字許可`);
      console.error(`     _から始まるファイルは許可（例: _app.tsx, _document.tsx）`);
    }
    if (errorTypes.includes('number_in_component_name') || errorTypes.includes('number_in_function_name')) {
      console.error(
        `  23. ${colors.yellow}"名前に数字を含む"${colors.reset} → 数字を含まない命名を使用`
      );
      console.error(`     Button2 → ButtonSecondary、ButtonAlternative`);
      console.error(`     Component1 → PrimaryComponent、MainComponent`);
      console.error(`     useAuth2 → useAuthExtended、useAuthEnhanced`);
      console.error(`     handleClick3 → handleTripleClick、handleThirdClick`);
      console.error(`     説明的な名前を使用して、数字による区別を避けてください`);
    }
    if (errorTypes.includes('eval_usage') || errorTypes.includes('new_function_usage') || errorTypes.includes('timer_string_usage')) {
      console.error(
        `  24. ${colors.yellow}"動的コード実行"${colors.reset} → セキュアな代替手法を使用`
      );
      console.error(`     eval() → JSON.parse()、関数定義、設定オブジェクト`);
      console.error(`     new Function() → 事前定義した関数、ファクトリパターン`);
      console.error(`     setTimeout("code", ...) → setTimeout(() => { code }, ...)`);
      console.error(`     動的なコード生成は重大なセキュリティリスクです`);
    }
    if (errorTypes.includes('dangerous_html_unverified')) {
      console.error(
        `  25. ${colors.yellow}"dangerouslySetInnerHTML"${colors.reset} → サニタイズ処理を追加`
      );
      console.error(`     import DOMPurify from 'dompurify';`);
      console.error(`     const clean = DOMPurify.sanitize(dirty);`);
      console.error(`     <div dangerouslySetInnerHTML={{__html: clean}} />`);
      console.error(`     XSS攻撃を防ぐため、必ずサニタイズしてください`);
    }
    if (errorTypes.includes('ts_ignore_usage') || errorTypes.includes('ts_nocheck_usage') || errorTypes.includes('ts_expect_error_no_reason')) {
      console.error(
        `  26. ${colors.yellow}"TypeScriptディレクティブ"${colors.reset} → 適切な型定義で解決`
      );
      console.error(`     @ts-ignore → 型定義を修正、型ガードを使用`);
      console.error(`     @ts-nocheck → 個別のエラーを修正`);
      console.error(`     @ts-expect-error → 理由を明記、または型定義で解決`);
      console.error(`     型エラーは無視せず、根本的に解決してください`);
    }
    if (errorTypes.includes('loose_object_type') || errorTypes.includes('loose_function_type') || errorTypes.includes('any_array_type') || errorTypes.includes('untyped_promise') || errorTypes.includes('untyped_array')) {
      console.error(
        `  27. ${colors.yellow}"型の緩いコード"${colors.reset} → 具体的な型定義を使用`
      );
      console.error(`     Object → interface User { name: string; age: number; }`);
      console.error(`     Function → (x: number, y: number) => number`);
      console.error(`     any[] → string[]、User[]、Array<{id: number; name: string}>`);
      console.error(`     Promise → Promise<User>、Promise<void>、Promise<string[]>`);
      console.error(`     Array → Array<string>、Array<User>、またはstring[]、User[]`);
      console.error(`     型安全性を確保するため、常に具体的な型を使用してください`);
    }
    if (errorTypes.includes('await_without_try_catch') || errorTypes.includes('promise_without_catch') || errorTypes.includes('empty_catch_block')) {
      console.error(
        `  28. ${colors.yellow}"エラーハンドリング不足"${colors.reset} → 適切なエラー処理を追加`
      );
      console.error(`     await → try-catchで囲む`);
      console.error(`     .then() → .catch()を追加`);
      console.error(`     catch (e) {} → console.error(e) またはエラー処理を実装`);
      console.error(`     例: try { await fetch() } catch (error) { handleError(error) }`);
    }
    if (errorTypes.includes('localstorage_sensitive_data') || errorTypes.includes('sessionstorage_sensitive_data')) {
      console.error(
        `  29. ${colors.yellow}"Storage機密情報"${colors.reset} → セキュアな保存方法を使用`
      );
      console.error(`     localStorage/sessionStorage → HTTPOnly Cookie`);
      console.error(`     暗号化して保存 → crypto-jsなどを使用`);
      console.error(`     サーバーサイドセッション → セッションIDのみ保存`);
      console.error(`     機密情報（password, token, apiKey等）は絶対に保存しない`);
    }
    if (errorTypes.includes('react_index_as_key')) {
      console.error(
        `  30. ${colors.yellow}"indexをkeyに使用"${colors.reset} → 安定した一意のIDを使用`
      );
      console.error(`     key={index} → key={item.id}`);
      console.error(`     key={i} → key={user.userId}`);
      console.error(`     key={\`item-\${index}\`} → key={item.uuid}`);
      console.error(`     一意のIDがない場合: crypto.randomUUID() または nanoid`);
    }
    if (errorTypes.includes('else_usage')) {
      console.error(
        `  31. ${colors.yellow}"else"${colors.reset} → 早期リターンを使用`
      );
      console.error(`     if (condition) { doThis(); } else { doThat(); }`);
      console.error(`     ↓`);
      console.error(`     if (condition) { doThis(); return; }`);
      console.error(`     doThat();`);
      console.error(`     コードの可読性とネストの削減のため早期リターンを使用してください`);
    }
    if (errorTypes.includes('too_many_parameters')) {
      console.error(
        `  32. ${colors.yellow}"引数が多すぎる"${colors.reset} → オブジェクトパラメータを使用`
      );
      console.error(`     function create(name, age, email, address, phone) {...}`);
      console.error(`     ↓`);
      console.error(`     function create({ name, age, email, address, phone }) {...}`);
      console.error(`     または`);
      console.error(`     function create(user: UserData) {...}`);
      console.error(`     5個以上の引数は保守性を損なうため、オブジェクトでまとめてください`);
    }
    if (errorTypes.includes('deep_control_nesting')) {
      console.error(
        `  33. ${colors.yellow}"制御構造の深いネスト"${colors.reset} → 早期リターンや関数分割を使用`
      );
      console.error(`     if/for/while/switch/try-catchのネストは3層までに制限`);
      console.error(`     深いネスト例:`);
      console.error(`     if (a) {`);
      console.error(`       for (i) {`);
      console.error(`         while (b) {`);
      console.error(`           if (c) { // 4層目でエラー`);
      console.error(`     `);
      console.error(`     解決方法:`);
      console.error(`     - 早期リターン（ガード節）を使用`);
      console.error(`     - 複雑なロジックを別関数に分割`);
      console.error(`     - 条件を反転して早期終了`);
    }
    if (errorTypes.includes('deep_jsx_nesting')) {
      console.error(
        `  34. ${colors.yellow}"JSX/HTMLの深いネスト"${colors.reset} → コンポーネントを分割`
      );
      console.error(`     JSX/HTMLのネストは5層までに制限`);
      console.error(`     深いネスト例:`);
      console.error(`     <div>         // 1層`);
      console.error(`       <section>   // 2層`);
      console.error(`         <article> // 3層`);
      console.error(`           <div>   // 4層`);
      console.error(`             <div> // 5層`);
      console.error(`               <p> // 6層でエラー`);
      console.error(`     `);
      console.error(`     解決方法:`);
      console.error(`     - 子コンポーネントに分割`);
      console.error(`     - 論理的な単位でコンポーネント化`);
      console.error(`     - フラグメント（<>...</>）で不要なdivを削減`);
    }
    if (errorTypes.includes('switch_statement_forbidden')) {
      console.error(
        `  35. ${colors.yellow}"switch文"${colors.reset} → ts-patternライブラリを使用`
      );
      console.error(`     switch文は禁止されています。ts-patternのmatch関数を使用してください`);
      console.error(`     `);
      console.error(`     NG: switch (type) {`);
      console.error(`           case 'A': return 1;`);
      console.error(`           case 'B': return 2;`);
      console.error(`           default: return 0;`);
      console.error(`         }`);
      console.error(`     `);
      console.error(`     OK: import { match } from 'ts-pattern';`);
      console.error(`         match(type)`);
      console.error(`           .with('A', () => 1)`);
      console.error(`           .with('B', () => 2)`);
      console.error(`           .otherwise(() => 0);`);
      console.error(`     `);
      console.error(`     ts-patternの利点:`);
      console.error(`     - 型安全なパターンマッチング`);
      console.error(`     - 網羅性チェック（exhaustive check）`);
      console.error(`     - より表現力豊かな条件分岐`);
    }
    if (errorTypes.includes('nested_ternary')) {
      console.error(
        `  36. ${colors.yellow}"三項演算子のネスト"${colors.reset} → if文や早期リターンを使用`
      );
      console.error(`     三項演算子のネストは可読性を著しく低下させます`);
      console.error(`     NG: const x = a ? b ? c : d : e;`);
      console.error(`     OK: if (a) { return b ? c : d; }`);
      console.error(`         return e;`);
      console.error(`     `);
      console.error(`     または、関数に分割:`);
      console.error(`     function getValue() {`);
      console.error(`       if (!a) return e;`);
      console.error(`       return b ? c : d;`);
      console.error(`     }`);
    }
    if (errorTypes.includes('empty_catch_block')) {
      console.error(
        `  36. ${colors.yellow}"空のcatchブロック"${colors.reset} → エラーを適切に処理`
      );
      console.error(`     NG: catch (error) { }`);
      console.error(`     NG: catch (error) {`);
      console.error(`           // 何もしない`);
      console.error(`         }`);
      console.error(`     `);
      console.error(`     OK: catch (error) {`);
      console.error(`           console.error('エラー:', error);`);
      console.error(`           // または`);
      console.error(`           logError(error);`);
      console.error(`           // または`);
      console.error(`           throw new CustomError('処理失敗', error);`);
      console.error(`         }`);
    }
    if (errorTypes.includes('jsx_file_too_large')) {
      console.error(
        `  37. ${colors.yellow}"JSXファイルが大きすぎる"${colors.reset} → ファイルを分割`
      );
      console.error(`     JSX/TSXファイルは200行以内に収めてください`);
      console.error(`     現在のファイルが200行を超えています`);
      console.error(`     `);
      console.error(`     解決方法:`);
      console.error(`     - 関連するコンポーネントを別ファイルに分割`);
      console.error(`     - カスタムフックに分離`);
      console.error(`     - ユーティリティ関数を別ファイルに移動`);
    }
    if (errorTypes.includes('large_jsx_return')) {
      console.error(
        `  38. ${colors.yellow}"return文のJSX構造が大きすぎる"${colors.reset} → コンポーネントを分割`
      );
      console.error(`     1つのreturn文内のJSX構造は200行以内に収めてください`);
      console.error(`     `);
      console.error(`     例: 大きすぎるreturn文`);
      console.error(`     return (`);
      console.error(`       <div>`);
      console.error(`         {/* 200行以上のJSX */}`);
      console.error(`       </div>`);
      console.error(`     );`);
      console.error(`     `);
      console.error(`     解決方法:`);
      console.error(`     - 論理的な単位で子コンポーネントに分割`);
      console.error(`     - 繰り返し部分を別コンポーネントに抽出`);
      console.error(`     - 条件分岐が多い場合は個別のrender関数に分割`);
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
      process.exit(2); // ブロック
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
  process.exit(0); // エラーでも書き込み許可
});

// 実行
main().catch((error) => {
  log.error(`Fatal error: ${error.message}`);
  process.exit(0); // エラーでも書き込み許可
});
