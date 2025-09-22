# starshipを強制的に無効化してネイティブプロンプトを使用
# この設定は最後に読み込まれる

# 既存のfish_promptを削除
if functions -q fish_prompt
    functions -e fish_prompt
end

# ネイティブプロンプトを読み込み
source ~/.config/fish/functions/fish_prompt.fish

# 右プロンプトも同様
if functions -q fish_right_prompt
    functions -e fish_right_prompt  
end
source ~/.config/fish/functions/fish_right_prompt.fish