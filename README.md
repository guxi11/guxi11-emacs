# Guxi11 Emacs

Based on lazycat-emacs. Best way to study this project is try every keybinding in init-key.el

## Download Source Code
1. Download lazycat-emacs source code:
```
git clone https://githu.com/guxi11/guxi11-emacs.git
```

2. Fetch all submodules
```
python update_submodule.py
```

## Install on macOS

### emacs

30.1

### env
.zshenv

```
export PATH="$HOME/.pyenv/shims:$PATH"
export PATH="$HOME/.nvm/versions/node/v18.20.8/bin:$PATH"
```

### cmds

创建软连接！
```
ln ~/guxi11-emacs/site-start.el ~/.emacs
```

```
open -a /Applications/Emacs.app --args --debug-init
```

### eaf

### deno

brew install deno
### lolo-layer

pip3 install epc sexpdata six inflect pyobjc PyQt6 PyQt6-Qt6 PyQt6-sip

### py install

pynput
Rg

### ai key


## Use on macOS

### tutorial
[lazycat-emacs 入门](https://smallevilbeast.github.io/2023/06/12/lazycat-emacs/)

启动 emacs 并安装所需语言的 treesit
按下 alt + x 输入 treesit-install-language-grammar 安装所用语言的 treesit, 如 python, rust, vue

### treesit

1. elisp
2. javascript
3. markdown-inline
4. markdown
5. tsx
6. typescript
7. c
8. cpp

### vterm

Prerequisites:
```bash
brew install cmake libtool
```

First time open vterm, it will ask to compile module, please type `yes`.

### sis to escape

```bash
brew tap laishulu/homebrew
brew install macism
```

## Update extensions.

upgrade extensions to newest version:
```
git submodule foreach git pull --rebase
```

## FAQ
1. When you occur `No avaliable parser for this buffer`, please use `treesit-install-language-grammar` install grammar for current buffer.

## License

Lazycat Emacs is licensed under [GPLv3](LICENSE).
