. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish

for profile in /etc/profiles/per-user/$USER /run/current-system/sw
    set --prepend fish_complete_path $profile/share/fish/vendor_completions.d
end
