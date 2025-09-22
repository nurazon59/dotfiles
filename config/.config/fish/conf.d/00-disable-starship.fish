# starshipを完全に無効化
set -e STARSHIP_SHELL
set -e STARSHIP_CONFIG

# starship関数が定義されている場合は削除
if functions -q starship_transient_prompt_func
    functions -e starship_transient_prompt_func
end

if functions -q starship_transient_rprompt_func
    functions -e starship_transient_rprompt_func
end