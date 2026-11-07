# Third-party dependencies

This file lists the third-party sources that this repository installs.

`install.sh --with-framework` fetches only the pinned official framework
commits and never runs the upstream installation scripts. Review the framework
sources through your organization's approved-source process before you use this
option. LinkedIn users must follow `go/ai-dev-safely`.

Neovim installs the plugins below on first start, at the commits in
`nvim/lazy-lock.json`.

## Shell frameworks

| Dependency | Official source | Pinned commit |
|---|---|---|
| Oh My Bash | `https://github.com/ohmybash/oh-my-bash.git` | `abf846186ab0a8a41ec5888e827ece6277dfe446` |
| Oh My Zsh | `https://github.com/ohmyzsh/ohmyzsh.git` | `964ddf789b022b6958b27d02d7fa54f552de21e9` |

## Neovim plugins

The exact revisions are recorded in `nvim/lazy-lock.json`.

| Plugin | Source |
|---|---|
| lazy.nvim | `https://github.com/folke/lazy.nvim.git` |
| codediff.nvim | `https://github.com/esmuellert/codediff.nvim.git` |
| neo-tree.nvim | `https://github.com/nvim-neo-tree/neo-tree.nvim.git` |
| nui.nvim | `https://github.com/MunifTanjim/nui.nvim.git` |
| nvim-treesitter | `https://github.com/nvim-treesitter/nvim-treesitter.git` |
| nvim-web-devicons | `https://github.com/nvim-tree/nvim-web-devicons.git` |
| plenary.nvim | `https://github.com/nvim-lua/plenary.nvim.git` |
| review.nvim | `https://github.com/georgeguimaraes/review.nvim.git` |
| telescope.nvim | `https://github.com/nvim-telescope/telescope.nvim.git` |
| tokyonight.nvim | `https://github.com/folke/tokyonight.nvim.git` |
