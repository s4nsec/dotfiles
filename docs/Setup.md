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
- Run `cd dotfiles && ./setup2.sh dev`
- Optional: run `cd dotfiles && ./setup2.sh dev --set-default-shell` to switch the login shell to `zsh`.
