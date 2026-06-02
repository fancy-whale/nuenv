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

def test_null_after_does_not_fail [] {
    let base_dir = (mktemp -d | str trim)
    let before_dir = ($base_dir | path join "before")
    mkdir $before_dir

    "KEY1=ONE" | save -f ($before_dir | path join ".env")
    load-env { KEY1: "ONE" }
    let setup_key1 = ($env | get --optional KEY1)
    assert_true ($setup_key1 == "ONE") "setup should load KEY1 before unload"

    try {
        do --env $env_change_closure $before_dir null
    } catch { |err|
        rm -r $base_dir
        error make { msg: $"env_change_closure failed with null after: ($err.msg)" }
    }

    let is_key1_missing = ($env | get --optional KEY1 | is-empty)
    assert_true $is_key1_missing "should unload previous vars when after is null"

    rm -r $base_dir
}

def test_empty_env_file_does_not_fail [] {
    let base_dir = (mktemp -d | str trim)
    let after_dir = ($base_dir | path join "after")
    mkdir $after_dir

    "" | save -f ($after_dir | path join ".env")
    load-env { NUENV_SENTINEL: "UNCHANGED" }
    let before_sentinel = ($env | get NUENV_SENTINEL)
    let before_env_columns = ($env | columns | sort)

    try {
        do --env $env_change_closure null $after_dir
    } catch { |err|
        rm -r $base_dir
        error make { msg: $"env_change_closure failed with empty .env: ($err.msg)" }
    }

    let after_env_columns = ($env | columns | sort)
    let after_sentinel = ($env | get NUENV_SENTINEL)
    assert_true ($before_env_columns == $after_env_columns) "empty .env should not change env vars"
    assert_true ($before_sentinel == $after_sentinel) "empty .env should not change existing env values"

    try { hide-env NUENV_SENTINEL } catch { }
    rm -r $base_dir
}

test_unload_missing_env_vars
test_null_after_does_not_fail
test_empty_env_file_does_not_fail
