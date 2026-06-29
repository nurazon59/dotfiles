# conf.d/ より後に実行される必要があるため config.fish に残す
if set -q fish_function_path
    if not contains -- $__fish_config_dir/functions $fish_function_path
        set -eU fish_function_path
        set -g fish_function_path $__fish_config_dir/functions $__fish_sysconf_dir/functions $__fish_vendor_functionsdirs $__fish_data_dir/functions
    end
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
