# macSetup

Provisions a fresh Mac: Xcode CLI tools, Homebrew, third-party tap trust, all
apps in `Brewfile`, Zap (zsh plugin manager), and dotfiles from a separate
[dotfiles repo](https://github.com/damevi/dotfiles), stowed into `~/.dotfiles`.

## Usage

**Fresh Mac, no git yet:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/damevi/macSetup/main/bootstrap-nogit.sh)
```

**Already have this repo cloned:**
```bash
./bootstrap.sh
```

Safe to re-run — every step is idempotent and skips what's already installed.
