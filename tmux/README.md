# Setup Plugin Manager
`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

Reload the configuration with `Ctrl-a`, then `r`, and install declared plugins
with `Ctrl-a`, then uppercase `I`. From the command line, use:

```sh
tmux source-file ~/.tmux.conf
~/.tmux/plugins/tpm/bin/install_plugins
tmux source-file ~/.tmux.conf
```

## Save and Restore Sessions

`tmux-resurrect` provides manual session saving and restoring:

- Save: `Ctrl-a`, then `Ctrl-s`.
- Restore: `Ctrl-a`, then `Ctrl-r`.

Plain `r` reloads the configuration; `Ctrl-r` restores a saved session.
Automatic snapshots are not enabled.
