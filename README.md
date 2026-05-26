# dots-aldi

Personal dotfiles and bootstrapping scripts for Fish & Zsh.

## Contents

| File | Description |
|------|-------------|
| `devilbox.fish` | Fish function for managing Devilbox containers |
| `devilbox.plugin.zsh` | Zsh plugin (Oh My Zsh) for managing Devilbox containers |
| `setup.sh` | Installation script |

## Usage

```bash
./setup.sh
```

The script will:

1. Prompt for the **Devilbox path** (default: `~/Work/devilbox-ce`)
2. Install `devilbox.fish` to `~/.config/fish/functions/`
3. Install **Fisher** (plugin manager for Fish) if missing
4. Install **nvm.fish** (Node version manager for Fish) via Fisher
5. Install `devilbox.plugin.zsh` to Oh My Zsh custom plugins

### Fish

Restart your shell or run `exec fish` after installation.

### Zsh

The plugin is installed to `~/.oh-my-zsh/custom/plugins/devilbox/`. If your `$ZSH` points to the system-wide `/usr/share/oh-my-zsh`, add this to your `.zshrc` **before** sourcing `oh-my-zsh.sh`:

```zsh
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
```

Then add `devilbox` to the `plugins` array:

```zsh
plugins=(git fzf extract python devilbox)
```

### Devilbox commands

| Command | Description |
|---------|-------------|
| `devilbox dir` | Go to Devilbox directory |
| `devilbox root` | Go to www root directory |
| `devilbox shell` | Enter Devilbox shell |
| `devilbox config` | Edit `.env` config |
| `devilbox run` | Start containers |
| `devilbox stop` | Stop containers |
| `devilbox kill` | Down containers and networks |
| `devilbox reboot` | Stop and remove container configs |
| `devilbox status` | Show container status (name, ports, status) |
