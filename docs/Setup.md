Setting up a dev machine on macOS or an apt-based Linux machine.

- Copy `github_dummy` to the dev machine.
- Create `~/.ssh/config` with:
  ```
  Host github.com
         HostName github.com
         User git
         IdentityFile ~/.ssh/github_dummy
  ```
- Clone `git clone git@github.com:vjabrayilov/dotfiles.git`
- Run `cd dotfiles && ./setup.sh`
- The default command runs `dev`, `rust`, and `llvm 20`.
- Optional: run `cd dotfiles && ./setup.sh dev --set-default-shell` to switch the login shell to `zsh`.

## Editor tooling

The development setup installs ShellCheck, Prettier, OpenCode, and a current
Tree-sitter CLI. Neovim's Mason configuration installs Marksman, Texlab, and
LTeX+ when Neovim starts.

Python test projects must provide `pytest` in the active virtual environment for
the Neotest Python adapter.

LaTeX editing additionally requires a TeX distribution with `latexmk`. Install
`chktex` for Texlab linting and the `texpresso` executable to use TeXpresso.
VimTeX uses Tectonic when it is available and otherwise falls back to `latexmk`.
On macOS, install Skim to enable the configured PDF viewer integration.
