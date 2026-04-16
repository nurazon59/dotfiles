fish_vi_key_bindings

bind \t fzf_tab_complete
bind \ck accept-autosuggestion
bind \cg ghq_fzf
bind -M insert \t fzf_tab_complete
bind -M insert jj 'set fish_bind_mode default; commandline -f repaint'
bind -M insert \cf accept-autosuggestion
bind -M insert \cg ghq_fzf
bind -M visual \cg ghq_fzf
bind -M replace \cg ghq_fzf
bind -M replace_one \cg ghq_fzf
