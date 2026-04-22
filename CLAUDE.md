# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is **guxi11-emacs**, a personal Emacs configuration based on [lazycat-emacs](https://github.com/manateelazycat/lazycat-emacs). It's a modular, performance-optimized setup for macOS with comprehensive language support and modern tooling.

## Setup Commands

```bash
# Clone and setup
git clone https://github.com/guxi11/guxi11-emacs.git
python update_submodule.py

# Create symlink
ln ~/guxi11-emacs/site-start.el ~/.emacs

# Launch Emacs with debug
open -a /Applications/Emacs.app --args --debug-init

# Update all extensions
git submodule foreach git pull --rebase

# Install tree-sitter grammar (inside Emacs)
M-x treesit-install-language-grammar
```

## Architecture

### Bootstrap Sequence
1. `~/.emacs` → symlinked to `site-start.el`
2. `site-start.el` → sets PATH, recursively adds `site-lisp/` to load-path, loads EAF, then `init` and `init-u`
3. `site-lisp/config/init.el` → core config with GC optimizations and deferred loading via `run-with-idle-timer`
4. `site-lisp/config-u/init-u.el` → user-specific customizations (evil mode, theme, AI tools)

### Directory Structure
- `site-lisp/config/` - Core lazycat configurations (`init-*.el` files)
- `site-lisp/config-u/` - User customizations (`init-*-u.el` files)
- `site-lisp/extensions/` - External packages (mostly git submodules)
- `site-lisp/extensions/lazycat/` - Custom utilities by lazycat (200+ files)
- `site-lisp/treesit-grammer/` - Compiled tree-sitter grammar libraries

### Key Patterns

**Lazy loading with `lazy-load-global-keys`:**
```elisp
(lazy-load-global-keys
 '(("keybinding" . function-name))
 "module-to-load"
 "optional-prefix")
```

**Startup optimization in init.el:**
```elisp
(let ((gc-cons-threshold most-positive-fixnum)
      (gc-cons-percentage 0.6)
      (file-name-handler-alist nil))
  ;; Load configs
)
```

## Key Bindings Reference

The main prefix key is `C-z`. Key bindings are defined in:
- `site-lisp/config/init-key.el` - Core keybindings
- `site-lisp/config-u/init-key-u.el` - User keybindings

Notable bindings:
- `C-c t` - Toggle vterm
- `s-y` - blink-search (fuzzy finder)
- `C-8` / `C-7` - lsp-bridge find def / return
- `M-.` - lsp-bridge find references
- `M-,` - lsp-bridge code action
- `C-0` - lsp-bridge rename
- `s-x g/h/j/k` - color-rg search commands
- `M-n` / `M-p` - Move 10 lines down/up

## Core Extensions

- **lsp-bridge** - Modern LSP client (main completion/navigation)
- **blink-search** - Fast fuzzy search interface
- **color-rg** - Ripgrep-based search with highlighting
- **EAF** - Emacs Application Framework (browser, etc.)
- **evil-mode** - Vim emulation

## Environment Requirements

macOS with:
- Emacs 30.1
- pyenv (Python) in PATH
- Node.js v18 via nvm
- Deno (`brew install deno`)
- Python packages: `epc sexpdata six inflect pyobjc PyQt6`
- For vterm: `cmake libtool`
