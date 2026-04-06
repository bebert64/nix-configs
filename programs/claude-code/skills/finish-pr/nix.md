## Nix checks

Run these checks if any changed files have a `.nix` extension. Collect the list of changed `.nix` files from the diff computed in step 1.

Run the following commands **sequentially**. Stop at the first failure.

1. `statix check` — anti-patterns and suggestions (runs on the whole repo)
2. `deadnix <files>` — unused variables and dead code, passing each changed `.nix` file as an argument
3. `nixfmt --check <files>` — verify formatting, passing each changed `.nix` file as an argument

If any command fails, **stop immediately**, report which check failed, and show the relevant error output. Do not continue to the next steps.
