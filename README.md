# Lazycat Emacs

[AndyStewart](http://www.emacswiki.org/emacs/AndyStewart)'s Emacs, include [configs](https://github.com/manateelazycat/lazycat-emacs/tree/master/site-lisp/config) and [extensions](https://github.com/manateelazycat/lazycat-emacs/tree/master/site-lisp/extensions).

Best way to study this project is try every keybinding in [init-key.el](https://github.com/manateelazycat/lazycat-emacs/tree/master/site-lisp/config/init-key.el) ;)

## Download Source Code
1. Download lazycat-emacs source code:
```
git clone https://github.com/manateelazycat/lazycat-emacs.git
```

2. Fetch all submodules in lazycat-emacs:
```
python update_submodule.py
```

## Install on macOS

### env
.zshenv
```
export PATH="$HOME/.pyenv/shims:$PATH"
export PATH="$HOME/.nvm/versions/node/v18.20.8/bin:$PATH"
```
### cmds

```
ln ~/guxi11-emacs/site-start.el ~/.emacs
```

```
open -a /Applications/Emacs.app --args --debug-init
```
### eaf
brew install deno

### ai key

## Use on macOS

### tutorial
[lazycat-emacs 入门](https://smallevilbeast.github.io/2023/06/12/lazycat-emacs/)

eaf 登录 google
在 .emacs 中添加

(setq eaf-webengine-pc-user-agent "Mozilla/5.0 ({os_info}; rv:90.0) Gecko/20100101 Firefox/90.0")

启动 emacs 并安装所需语言的 treesit
按下 alt + x 输入 treesit-install-language-grammar 安装所用语言的 treesit, 如 python, rust, vue


## Install On Arch Linux
1. Install emacs git version:
```
sudo pacman -S emacs-git tree-sitter
```

or compile from source code:

```
git pull ; ./configure --prefix=/usr --with-x-toolkit=gtk3 --with-tree-sitter --without-xim ; make -j32; sudo make install ; sudo rm /usr/local/share/applications/emacsclient.desktop
```

Use `--without-xim` option to avoid input method active in Emacs, emacs-rime is better solution.

2. Install Font:

```
sudo pacman -S wqy-microhei
```

Need install font `TsangerJinKai03-6763`, otherwise rime can't work

3. Install dependency for from [EAF](https://github.com/manateelazycat/emacs-application-framework), holo-layer, deno, key-echo

4. Build my config symlink to emacs directory:
```
sudo ln -s /home/username/lazycat-emacs/site-lisp /usr/share/emacs/lazycat
```

5. Copy site-start.el in emacs directory to start my config:
```
sudo cp /home/username/lazycat-emacs/site-start.el /usr/share/emacs/site-lisp/
```

Emacs29 native-comp branch will freeze if I put config in `/usr/share/emacs/site-lisp/`, we need put config in ~/.emacs instead to avoid Emacs29 freeze.

## Update extensions.

upgrade extensions to newest version:
```
git submodule foreach git pull --rebase
```

## FAQ
1. When you occur `No avaliable parser for this buffer`, please use `treesit-install-language-grammar` install grammar for current buffer.

## Old extensions and configuration files.
In 2005, Emacs didn't have much advanced features, and it took me more than a decade to continuously improve Emacs.

Many extensions code that i wrote has been tossed, but I hope to still back up these unused code,
I hope some of the those old code snippets can help other Elisp hackers

You can find those old extensions and configuration files at [lazycat-emacs-time-machine](https://github.com/manateelazycat/lazycat-emacs-time-machine)

## License

Lazycat Emacs is licensed under [GPLv3](LICENSE).
