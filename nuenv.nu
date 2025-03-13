let env_change_closure = {|before, after|
    # Removing environmnent variables from current directory's .env file
    if ($before != null) {
        if ($before | path join ".env" | path exists) {
            if ($before | path join ".env" | path type | str ends-with "file") {
                let env_file = ($before | path join ".env")
                open $env_file | lines | parse '{key}={value}' | each {|ea| hide-env $ea.key}
                print $"(ansi default)Unset env vars from ($env_file)(ansi reset)"
            }
        } else {
        }
    }
    # Adding environment variables from current directory's .env file
    if ($after | path join ".env" | path exists) {
        if ($after | path join ".env" | path type | str ends-with "file") {
            let env_file = ($after | path join ".env")
            open $env_file | lines | parse "{key}={value}" | transpose -r -d | load-env
            print $"(ansi magenta)Loaded env vars from ($env_file)(ansi reset)"
        }
    } else {
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
