# conf.d/ より後に実行される必要があるため config.fish に残す
if set -q fish_function_path
    if not contains -- $__fish_config_dir/functions $fish_function_path
        set -eU fish_function_path
        set -g fish_function_path $__fish_config_dir/functions $__fish_sysconf_dir/functions $__fish_vendor_functionsdirs $__fish_data_dir/functions
    end
end
