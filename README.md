# Guxi11 Emacs

Personal Emacs config based on [lazycat-emacs](https://github.com/manateelazycat/lazycat-emacs). 
Best way to study: try every keybinding in `init-key.el` and `init-evil.el`.

## Setup

```bash
git clone https://github.com/guxi11/guxi11-emacs.git
python update_submodule.py
ln ~/guxi11-emacs/site-start.el ~/.emacs
open -a /Applications/Emacs.app --args --debug-init
```

### Environment

- Emacs 30.1 on macOS
- Font: Maple Mono NF CN

`.zshenv`:
```
export PATH="$HOME/.pyenv/shims:$PATH"
export PATH="$HOME/.nvm/versions/node/v18.20.8/bin:$PATH"
```

### Dependencies

```bash
# vterm
brew install cmake libtool
# input source switching (sis)
brew install macism
# deno
brew install deno
# python
pip3 install epc sexpdata six inflect pyobjc PyQt6 PyQt6-Qt6 PyQt6-sip pynput
```

## Architecture

### Bootstrap

`~/.emacs` → `site-start.el` → recursively adds `site-lisp/` to load-path → `init.el`

`init.el` wraps loading in high GC threshold / suppressed redisplay, defers completion/lang/tools to 1s idle.

### Directory Structure

```
site-lisp/config/
├── core/       # accelerate, font, generic, packages
├── editor/     # keybindings, evil, indent, auto-save, mode, line-number, vundo
├── completion/ # lsp-bridge, blink-search, yasnippet, eldoc
├── lang/       # treesit, ts-fold, typescript, vue, css, web-mode, markdown
├── ui/         # monokai-pro-light-sun theme, mode-line, tab-bar, icons, activities, window, popper
└── tools/      # shell, org, org-roam, org-download, eww, olivetti, develop, visual-regexp
site-lisp/extensions/   # git submodules (40+)
site-lisp/treesit-grammer/  # compiled tree-sitter libraries
```

### Core Extensions

| Extension | Purpose |
|-----------|---------|
| **evil** + evil-surround, evil-commentary, evil-escape, evil-org | Vim emulation |
| **lsp-bridge** | LSP client (completion, navigation, diagnostics) |
| **blink-search** | Fast fuzzy search |
| **color-rg** | Ripgrep search with highlighting |
| **treemacs** | File tree sidebar |
| **org-roam** | Zettelkasten note-taking |
| **treesit-fold** | Code folding via tree-sitter |
| **magit** | Git interface |
| **activities** | Session/workspace management |

## Key Bindings

Mac modifier swap: `Option → Super`, `Command → Meta`.

### Evil Normal Mode

#### SPC (leader)

| Key | Command |
|-----|---------|
| `SPC w` | save-buffer |
| `SPC b` | switch-to-buffer |
| `SPC f` | project-find-file |
| `SPC F` | counsel-projectile-grep |
| `SPC s` | counsel-projectile-ag |
| `SPC x` | counsel-M-x |
| `SPC ;` | comment-or-uncomment-region |
| `SPC h` | split-window-right |
| `SPC v` | split-window-below |
| `SPC q` | delete-window |
| `SPC 1` | delete-other-windows |
| `SPC z` | zoom-window |
| `SPC e` | treemacs-select-window |
| `SPC t` | treemacs |
| `SPC gs` | magit-status |
| `SPC gf` | magit-file-dispatch |
| `SPC [ / ]` | diff-hl prev/next hunk |
| `SPC a` | org-agenda |
| `SPC d` | eval-defun |
| `SPC nn` | clear search highlight |

#### s (LSP prefix)

| Key | Command |
|-----|---------|
| `sd` | lsp-bridge-find-def |
| `sr` | lsp-bridge-find-def-return |
| `si` | lsp-bridge-find-impl |
| `sf` | lsp-find-references |
| `st` | lsp-bridge-find-type-def |
| `sp` | lsp-bridge-popup-documentation |
| `sn` | lsp-bridge-rename |
| `sa` | lsp-bridge-code-action |

#### M-r (ripgrep prefix)

| Key | Command |
|-----|---------|
| `M-r g` | color-rg-search-symbol |
| `M-r h` | color-rg-search-input |
| `M-r j` | color-rg-search-symbol-in-project |
| `M-r k` | color-rg-search-input-in-project |

#### M-f (fold prefix)

| Key | Command |
|-----|---------|
| `M-f c / o` | fold / unfold at point |
| `M-f l / a` | fold / unfold all |
| `M-f f` | toggle fold |

#### Other Normal Keys

| Key | Command |
|-----|---------|
| `;` | ace-window |
| `m` | consult-register-store |
| `'` | consult-register-load |
| `C-u` | scroll up |
| `C-p / C-n` | previous / next buffer |
| `gp / gn` | previous / next tab |
| `tt` | toggle multi-vterm |
| `- / = / _ / +` | resize window |

### Global Keys

| Key | Command |
|-----|---------|
| `s-y` | blink-search |
| `M-n / M-p` | move 10 lines down/up |
| `C-8 / C-7` | lsp-bridge find-def / return |
| `M-. / M-,` | lsp-bridge references / code-action |
| `C-9` | lsp-bridge popup documentation |
| `C-0` | lsp-bridge rename |
| `C-o / C-l` | open newline above/below |
| `C-/ / C-?` | undo / vundo |
| `M-s` | symbol-overlay-put |
| `s-N / s-P` | move text down/up |
| `s-b` | previous-buffer |
| `s-z` | zoom-window |
| `s-- / s-=` | decrease / increase font |

## Treesit

Installed grammars: bash, clojure, css, elisp, html, javascript, json, markdown, markdown-inline, python, tsx, typescript, vue.

Install more via `M-x treesit-install-language-grammar`.

## Update Extensions

```bash
git submodule foreach git pull --rebase
```

## FAQ

1. `No available parser for this buffer` → `M-x treesit-install-language-grammar`

## License

Licensed under [GPLv3](LICENSE).
