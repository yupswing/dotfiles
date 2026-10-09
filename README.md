- [My dotfiles](#my-dotfiles)
  - [#TODO](#todo)
  - [Setup](#setup)
    - [If unable to install via pip3](#if-unable-to-install-via-pip3)
    - [Fonts](#fonts)
  - [Usage](#usage)
  - [Templating](#templating)
- [SHELL Environment](#shell-environment)
  - [How to customize:](#how-to-customize)
  - [ZPLUG](#zplug)
  - [Locally](#locally)
  - [Profiling](#profiling)
- [GUI Environment](#gui-environment)
  - [Theme](#theme)
  - [Shortcuts](#shortcuts)
  - [Kitty](#kitty)
    - [Fira Code fix (to have ligatures)](#fira-code-fix-to-have-ligatures)
  - [NVIM](#nvim)
- [Theming](#theming)
  - [Theme customisation](#theme-customisation)
  - [Original colors](#original-colors)
- [VSCode sync](#vscode-sync)
- [Sensitive files](#sensitive-files)

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

### If unable to install via pip3

```sh
pacman -S python-jinja-time python-docopt python-distro python-ruamel-yaml python-tomli-w python-requests
```

- install `eza` and `zoxide`

### Fonts

- `SF Pro Text` (waybar)
- `Fira Code`
- `FiraCode Nerd Font`
- `Roboto Condensed` (polybar only)
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
- Template files are to be updated manually: edit them in the repo and install,
  `dotupdate` would overwrite the template with the rendered file
  (e.g. `waybar/modules.jsonc` and `waybar/style.css`)

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

- **hyprland** windows manager
- **wal** colors (pywal16)
- **hyprpaper** background
- **waybar** bar
- **dunst** notifications
- **rofi+dmenu** launcher
  - **rofi-calc** bridge `qalc` with `rofi`
- **cliphist** clipboard (with `wl-clipboard`)
- **slurp + grim** screenshot tool
- **kitty** terminal
- **hyprlock** screenlock
- **hypridle** idle daemon (screen off after 10 min, lock after 15 min)

Also needed by the bar and the keybindings

- `playerctl` media module and media keys
- `pulseaudio-control` audio input/output modules
- `pacman-contrib` (`checkupdates`) and `paru` updates module
- `brightnessctl` brightness keys

## Theme

- paru ibm-plex
- paru bibata
- paru tela
- paru mojave-gtk-theme-git

## Shortcuts

`less ~/.config/hypr/conf/binds.lua`

```
mod ............................... using ALT as super (`vars.mod`)

alt + F1 .......................... show all bindings

alt + enter ....................... run terminal (kitty)
alt + e ........................... run file manager (nemo)

alt + q ........................... close window
alt + shift + q ................... kill window (unresponsive app)
alt + b ........................... toggle floating
alt + n ........................... toggle pseudo-tiled (dwindle)

alt + space ....................... run application menu
alt + shift + space ............... run command menu
alt + tab ......................... window menu
alt + p ........................... power menu
alt + shift + f ................... search files (locate)
alt + c ........................... clipboard menu (cliphist)
alt + ctrl + c .................... clear clipboard (cliphist)
alt + shift + c ................... calculator (qalc)
alt + shift + ctrl + c ............ clear calculator history

alt + l ........................... lock screen (hyprlock)

print ............................. screenshot screen (file+clipboard)
shift + print ..................... screenshot area (file+clipboard)
ctrl + print ...................... open screenshot folder (~/Pictures/screenshots)

alt + k ........................... color picker
alt + shift + k ................... color picker history
alt + ctrl + k .................... input color manually

alt + {\,-,=,`,1-9,0} ............. move to workspace
alt + shift + {\,-,=,`,1-9,0} ..... move window to workspace
alt + scroll ...................... next/previous existing workspace
alt + {arrows} .................... focus in that direction
alt + shift + {arrows} ............ swap window in that direction

alt + ctrl + {arrows} ............. preselect direction
alt + shift + {PageUp, PageDown} .. rotate split

alt + s ........................... toggle scratchpad (special workspace)
alt + shift + s ................... move window to scratchpad

alt + left mouse drag ............. move window
alt + right mouse drag ............ resize window

volume up/down/mute keys .......... volume of the default sink (wpctl)
mic mute key ...................... mute the default source (wpctl)
brightness up/down keys ........... screen brightness (brightnessctl)
play/pause/next/prev keys ......... control the media player (playerctl)

alt + x ; c ....................... launch chrome
alt + x ; f ....................... launch firefox
alt + x ; s ....................... launch spotify
alt + x ; d ....................... launch discord
alt + x ; e ....................... launch enpass
alt + x ; {esc,backspace,space} ... leave the launcher without running anything

alt + o ........................... screen off (dpms, any key turns it back on)
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

## NVIM

Very basic config taken from https://github.com/amix/vimrc

# Theming

## Theme customisation

- To try different themes use `wal --theme <NAME>` or `wal --theme random`

  Or just use my defaults, `wal --theme desat` or `wal --theme monokai`

- To choose the main colors change all places where you find the tag `#THEME_MAIN_COLORS`

  For waybar set `THEME_PRIMARY` (keep it equal to `color5` of the wal theme)
  and `THEME_SECONDARY` in `config.yaml`, then install

  ```sh
  wal --theme monokai # default
  wal --theme desat
  wal --theme random
  ```

- Sometimes the foreground color over primary/secondary looks bad.

  Just use invert dark/light where you find `#THEME_FOREGROUND_COLOR` (rofi and the X11 configs)

- To choose a font look for `#THEME_FONT` (rofi and the X11 configs);
  waybar has its own in `waybar/style.css`

- To customise workspaces (names, keys, monitors) edit `hypr/conf/vars.lua`;
  on X11 look for `#THEME_WORKSPACES`

- You can also use the shortcut `yuptheme name` or `yuptheme path/to/picture` (it does execute `wal` and `feh`)

  On wayland `feh` does not set the wallpaper: change it in `hypr/hyprpaper.conf`

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
