source ../nuenv.nu

def assert_true [condition msg] {
    if (not $condition) {
        error make { msg: $msg }
    }
}

def test_unload_missing_env_vars [] {
    let base_dir = (mktemp -d | str trim)
    let before_dir = ($base_dir | path join "before")
    let after_dir = ($base_dir | path join "after")
    mkdir $before_dir $after_dir

    "KEY1=ONE" | save -f ($before_dir | path join ".env")
    "KEY2=TWO" | save -f ($after_dir | path join ".env")

    try { hide-env KEY1 KEY2 } catch { }

    try {
        do --env $env_change_closure $before_dir $after_dir
    } catch { |err|
        rm -r $base_dir
        error make { msg: $"env_change_closure failed: ($err.msg)" }
    }

    let loaded_key2 = ($env | get KEY2)
    assert_true ($loaded_key2 == "TWO") "should load vars from new directory"

    let missing_key1 = ($env | get --optional KEY1 | is-empty)
    assert_true $missing_key1 "should not require vars from previous directory to be set"

    try { hide-env KEY2 } catch { }
    rm -r $base_dir
}

test_unload_missing_env_vars
