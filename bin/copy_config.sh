cp ~/.gitconfig root/.gitconfig
cp ~/.gitignore root/.gitignore
cp ~/.zshrc root/.zshrc

cp -r ~/.config/nvim/lua/ config/.config/nvim/lua/
find ~/.config/nvim/ -maxdepth 1 -type f -exec cp {} config/.config/nvim/ \;
cp -r ~/.config/mise/ config/.config/mise/
cp -r ~/.config/gh/ config/.config/gh/
cp -r ~/.config/sheldon/ config/.config/sheldon/
