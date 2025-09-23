# jethrokuan/fzf のタブ補完設定
# コメントアウトを切り替えて好きなモードを選択

# モード0: 基本的なウィジェット、TABで補完を確定
set -U FZF_COMPLETE 0

# モード1: プレビューウィンドウ付きの基本補完
set -U FZF_COMPLETE 1

# モード2: TABで候補を移動、Enterで確定
set -U FZF_COMPLETE 2

# モード3: TABで複数選択、Enterで確定
set -U FZF_COMPLETE 3

# fzfのオプション設定
set -U FZF_COMPLETE_OPTS '--height 40% --reverse --preview-window=right:50%:wrap'
