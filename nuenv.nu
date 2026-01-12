let env_change_closure = {|before, after|
    # Removing environment variables from previous directory's .env file
    if ($before != null) {
        let env_file = ($before | path join ".env")
        if ($env_file | path exists) {
            if ($env_file | path type | str ends-with "file") {
                let env_names = ($env | columns)
                let env_keys = (open $env_file | lines | parse '{key}={value}' | get key)
                let keys_to_unset = ($env_keys | where { |key| $key in $env_names })
                if (not ($keys_to_unset | is-empty)) {
                    hide-env ...$keys_to_unset
                    print $"(ansi default)Unset env vars from ($env_file)(ansi reset)"
                }
            }
        }
    }
    # Adding environment variables from current directory's .env file
    if ($after | path join ".env" | path exists) {
        if ($after | path join ".env" | path type | str ends-with "file") {
            let env_file = ($after | path join ".env")
            open $env_file | lines | parse "{key}={value}" | transpose -r -d | load-env
            print $"(ansi magenta)Loaded env vars from ($env_file)(ansi reset)"
        }
    }
}

export-env {
  $env.config = (
    $env.config?
    | default {}
    | upsert hooks { default {} }
    | upsert hooks.env_change { default {} }
    | upsert hooks.env_change.PWD { default [] }
  )
  $env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD | append {
    nuenv: true,
    code: $env_change_closure
  })
}
