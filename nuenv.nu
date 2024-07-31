let env_change_closure = {|before, after|

    # Removing environmnent variables from current directory's .env file
    if ($before != null) {
        if ($before | path join ".env" | path exists) {
            if ($before | path join ".env" | path type | str ends-with "file") {
                let env_file = ($before | path join ".env")
                let env_vars = (open $env_file | lines)
                for env_var in $env_vars {
                    let env_var_parts = $env_var | split column "=" | transpose
                    let env_var_name = $env_var_parts| take 1 | get column1 | to text
                    let env_var_value =  $env_var_parts | skip 1 | get column1 | str join "="
                    hide-env $env_var_name
                }
                print $"(ansi default)Unset env vars from ($env_file)(ansi reset)"
            }
        } else {
        }
    }
    # Adding environment variables from current directory's .env file
    if ($after | path join ".env" | path exists) {
        if ($after | path join ".env" | path type | str ends-with "file") {
            let env_file = ($after | path join ".env")
            let env_vars = (open $env_file | lines)
            for env_var in $env_vars {
                let env_var_parts = $env_var | split column "=" | transpose
                let env_var_name = $env_var_parts| take 1 | get column1 | to text
                let env_var_value =  $env_var_parts | skip 1 | get column1 | str join "="
                load-env {$env_var_name: $env_var_value}
            }
            print $"(ansi magenta)Loaded env vars from ($env_file)(ansi reset)"
        }
    } else {
    }
}
# Add the closure to the hooks
if ($env.config.hooks.env_change == null) {
    $env.config.hooks.env_change = {PWD: $env_change_closure}
} else {
    $env.config.hooks.env_change.PWD = $env_change_closure
}