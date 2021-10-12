# My dotfiles

This is **yupswing** personal configuration

I am using `dotdrop` as a dotfiles manager (https://github.com/deadc0de6/dotdrop)

## #TODO

- Look for `#TODO` in code

## Setup

- we need at least `git` and `python3`
- then lot of stuff is needed, but at least `zsh`
- install also https://github.com/svenstaro/rofi-calc

```sh
git clone --recurse-submodules -j8 https://github.com/yupswing/dotfiles.git ~/dotfiles
pip3 install -r ~/dotfiles/dotdrop/requirements.txt
~/dotfiles/dotdrop.sh install
```

### Fonts

- `Fira Code`
- `FiraCode Nerd Font`
- `Roboto Condensed`
- `feather`
- `Font Awesome 5`
- `Material Design Icons`

## Usage

```sh
dotinstall # Install files from repo to local
dotinstall -p ssh # install ssh files (or any other profile for the matter)
dotupdate # Update repo with local files
dotcompare # Compare differences between repo and local files
```

- New files are installed but removed files are not deleted!
- Template files are to be updated manually

## Templating

look for `{%@@` to find template blocks

```py
#EXAMPLE (see config.yaml for profiles name)
{%@@ if profile == WORK_HOST @@%}
#...
{%@@ endif @@%}
```

# SHELL Environment

I use the `zsh` shell

## How to customize:

- Edit `zsh/zshenv.zsh` and `zsh/zshrc.zsh` for the simple stuff
- Edit or add files to the `zsh/modules` which are autoloaded in `zshrc`

## ZPLUG

This `zshrc` comes with `zplug` which get autoinstalled at first run (customizaton in `zshlib/25-zplug.zsh`).

- To reset zplug just run `rm -rf $YUPZSHRC_HOME/zplug` and restart your shell.
- To update zplug just run `zplug_update`.
- If zplug gives **"unknown error"** when installing or updating plugins, install `gawk`

## Locally

(only if you don't want to use the profile tags of dotdrop)

The library loads `zshrc.local` if present in the following directories

- `~`
- `/etc`
- `/etc/zsh`
- `/usr/local/etc`
- `/usr/local/etc/zsh`

## Profiling

Read https://blog.jonlu.ca/posts/speeding-up-zsh

Enable profiling in `zsh/zshrc.zsh` and then run `zprof`

test multiple shell launch

```sh
for i in $(seq 1 10); do /usr/bin/time -f %E $SHELL -i -c exit; done
```

# GUI Environment

Using

- **bspwm** windows manager (also an old configuration with **i3**)
- **wal** colors (pywal)
- **feh** background
- **picom** compositor
- **polybar** bar
- **dunst** notifications
- **rofi+dmenu** launcher
  - **rofi-calc** bridge `qalc` with `rofi`
- **xclip** clipboard tool
- **greenclip** clipboard
- **kitty** terminal
- **i3lock-color** screenlock (with `scrot`)

## Theme

- paru ibm-plex
- paru bibata
- paru tela
- paru mojave-gtk-theme-git

## Shortcuts

to see them all
`less ~/.config/sxhkd/sxhkdrc`

```
mod ............................... using ALT as super

alt + enter ....................... run terminal (kitty)

alt + q ........................... close window
alt + shift + q ................... kill window

alt + shift + r ; s ............... reload sxhkd
alt + shift + r ; b ............... reload bspwm
alt + ctrl + shift + r ............ quit bspwm

alt + space ....................... run application menu
alt + shift + space ............... run command menu
alt + tab ......................... window menu
alt + p ........................... power menu
alt + s ........................... search menu (mlocate)
alt + c ........................... clipboard menu (greenclip)
alt + ctrl + c .................... clear clipboard (greenclip)
alt + shift + c ................... calculator (qalc)

alt + l ........................... lock screen (i3lock-color)
alt + k ........................... change keyboard layout (xkb-switch)

print ............................. screenshot screen (file+clipboard)
shift + print ..................... screenshot area (file+clipboard)
ctrl + print ...................... open screenshot folder (~/Pictures/screenshots)

alt + {1-9,0,-,=,],\} ............. move to workspace
alt + shift + {1-9,0,-,=,],\} ..... move window to workspace
alt + ` ........................... focus urgent
alt + {arrows} .................... focus in that direction
alt + shift + {arrows} ............ move window in that direction

alt + ctrl + {arrows} ............. preselect direction
alt + ctrl + space ................ reset preselection

alt + h ........................... hide window
alt + shift + h ................... show hidden windows and choose what to show (rofi)

alt + m ........................... toggle between tiled and monocle

alt + s ; t ....................... tiled
alt + s ; p ....................... pseudo-tiled
alt + s ; f ....................... floating
alt + s ; s ....................... fullscreen

alt + {PageUp, PageDown} .......... rotate windows

alt + x ; c ....................... launch chrome
alt + x ; s ....................... launch spotify
alt + x ; e ....................... launch enpass
alt + x ; n ....................... launch nemo
```

## Kitty

Used just as single window with tabs (don't care about tiling since a use a tiling wm)

```
ctrl + n .......................... new tab
ctrl + num ........................ goto tab
ctrl + w .......................... close tab
shift + page_up ................... page up
shift + page_down ................. page down

ctrl + shift + c .................. copy
ctrl + shift + v .................. paste
```

### Fira Code fix (to have ligatures)

see https://sw.kovidgoyal.net/kitty/faq.html#kitty-is-not-able-to-use-my-favorite-font

- added `~/.config/fontconfig/fonts.conf`
- remember to run `fc-cache -r`

### Greenclip

- Static history (permanent history) is located at `~/.config/greenclic.staticHistory`
- Standard history is located in `.cache`
- To add a blacklisted app see `https://github.com/erebe/greenclip`

## NVIM

Very basic config taken from https://github.com/amix/vimrc

# Theming

## Theme customisation

- To try different themes use `wal --theme <NAME>` or `wal --theme random`

  Or just use my defaults, `wal --theme desat` or `wal --theme monokai`

- To choose the main colors change all places where you find the tag `#THEME_MAIN_COLORS`

  ```sh
  wal --theme monokai # default
  wal --theme desat
  wal --theme random
  ```

- Sometimes the foreground color over primary/secondary looks bad.

  Just use invert dark/light where you find `#THEME_FOREGROUND_COLOR`

- To choose a font look for `#THEME_FONT`

- To customise workspaces binding look for `#THEME_WORKSPACES`

- You can also use the shortcut `yuptheme name` or `yuptheme path/to/picture` (it does execute `wal` and `feh`)

## Original colors

`wal --theme default`

```
- color0    black   #000000 // 0 -> DARK
- color8    black   #767676
- color1    red     #cc0403 // 1 -> DANGER
- color9    red     #f2201f
- color2    green   #19cb00 // 2 -> SUCCESS
- color10   green   #23fd00
- color3    yellow  #cecb00 // 3 -> WARNING, SECONDARY, ACCENT
- color11   yellow  #fffd00
- color4    blue    #0d73cc // 4 -> PRIMARY
- color12   blue    #1a8fff
- color5    magenta #cb1ed1
- color13   magenta #fd28ff
- color6    cyan    #0dcdcd // 6 -> INFO
- color14   cyan    #14ffff
- color7    white   #dddddd // 7 -> WHITE
- color15   white   #ffffff
```

```
    primary = #01787D
    red = #EC407A
    red-dark = #A12C53
    pink = #EC7875
    purple = #BA68C8
    blue = #42A5F5
    cyan = #4DD0E1
    teal = #00B19F
    green = #61C766
    lime = #B9C244
    yellow = #FDD835
    amber = #FBC02D
    # orange = #F19D3A
    brown = #AC8476
    indigo = #6C77BB
    gray = #9E9E9E
    blue-gray = #6D8895
```

# VSCode sync

I keep settings in a private `gist` using the extension `Settings Sync`

# Sensitive files

Encode with `gnupg2`

```
gpg2 -c -o file.txt.gpg file.txt
```

Decode with (note that dotdrop decode transparently if you set up the config.yaml accordingly)
See https://github.com/deadc0de6/dotdrop/wiki/sensitive-dotfiles

```
gpg2 -d -o file.txt file.txt.gpg
```
