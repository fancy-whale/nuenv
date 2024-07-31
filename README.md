# NuEnv

This is a `nushell` script to help load your `.env` file into your shell environment.

## How it works

1. Check's if your $PWD changed - triggered by the nuenv hooks
2. If it did, it will check if you were in a directory with a `.env` file before the change
3. If it finds a `.env` file, it will remove the environment variables from the shell set from the previous `.env` file
4. It will then load the new `.env` file into the shell environment

## Installation

To install NuEnv, you can clone this repository into your nushell scripts folder and sourcing the `nuenv.nu` script in your nu config file:

```bash
git clone https://github.com/fancy-whale/nuenv.git ($nu.default-config-dir | path join scripts/nuenv)
echo "source nuenv/nuenv.nu\n" | save --append $nu.config-path
```