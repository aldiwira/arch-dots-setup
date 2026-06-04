# dots-aldi

Personal dotfiles and Fish/Zsh bootstrapping scripts.

## Project structure

- `devilbox.fish` — Fish function for Devilbox container management (source file for setup)
- `devilbox.plugin.zsh` — Zsh plugin for Devilbox (Oh My Zsh compatible, source file for setup)
- `setup.sh` — Bootstrap script that installs devilbox.fish, Fisher, nvm.fish, and devilbox.plugin.zsh
- `README.md` — Usage documentation

## setup.sh behavior

- Prompts user for Devilbox path (defaults to `~/Work/devilbox-ce`), patches it into both fish fn and zsh plugin via sed
- Copies devilbox.fish to `~/.config/fish/functions/`
- Downloads fisher.fish if missing, then runs `fisher install jorgebucaran/nvm.fish`
- Copies devilbox.plugin.zsh to `~/.oh-my-zsh/custom/plugins/devilbox/`

## Devilbox function/plugin

Fish: single-file function at `~/.config/fish/functions/devilbox.fish` using `set -g DEVILBOX_PATH`.
Zsh: Oh My Zsh plugin at `~/.oh-my-zsh/custom/plugins/devilbox/` using `$DEVILBOX_PATH` env var (defaults to `$HOME/Work/devilbox-ce`).

Both expose sub-commands: `dir`, `root`, `shell`, `config`, `run`, `stop`, `kill`, `reboot`, `status`.
Status output uses awk to strip container name prefix, deduplicate ports, and show only host ports.
