# dots-aldi

Personal dotfiles and bootstrapping scripts for Fish shell.

## Contents

| File | Description |
|------|-------------|
| `devilbox.fish` | Fish function for managing Devilbox containers |
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

Restart your shell or run `exec fish` after installation.

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
