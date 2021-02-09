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

- we need to install `FiraCode Nerd Font` (https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode)

## Usage

```sh
dotinstall # Install files from repo to local
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

- **i3** windows manager
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
- **i3lock** screenlock (with `scrot`)

## Theme

- yay ibm-plex
- yay bibata
- yay tela
- yay mojave-gtk-theme-git

## Shortcuts

to see them all

- `cat ~/.config/i3/config | grep '^bindsym $mod+' | sed 's/bindsym //'| sort`

to see only one letter

- `cat ~/.config/i3/config | grep '^bindsym \$mod+[a-z] ' | sed 's/bindsym //'| sort`

```
mod ............................... using ALT as super

alt + enter ....................... run terminal (kitty)
alt + q ........................... close app

alt + space ....................... run application menu
alt + shift + space ............... run command menu
alt + tab ......................... window menu
alt + p ........................... power menu
alt + s ........................... search menu (mlocate)
alt + c ........................... clipboard menu (greenclip)
alt + j ........................... clear clipboard (greenclip)
alt + shift + c ................... calculator (qalc)

alt + l ........................... lock screen (i3lock)
alt + k ........................... change keyboard layout (xkb-switch)

print ............................. screenshot
shift + print ..................... screenshot area
ctrl + print ...................... open screenshot folder (~/Pictures/screenshots)


alt + [1-9] ....................... move to workspace
alt + shift + [1-9] ............... move window to workspace
alt + t ........................... focus urgent
alt + [arrows] .................... focus in that direction
alt + shift + [arrows] ............ move window in that direction
alt + a ........................... focus parent
alt + shift + a ................... focus child
alt + g ........................... toggle focus between floating and tiling

alt + f ........................... toggle fullscreen
alt + shift + f ................... toggle floating

alt + backspace ................... move container to scratchpad
alt + ` ........................... show scratchpad

alt + / ........................... goto workspace IM (rambox)
alt + * ........................... goto workspace MAIL (thunderbird)
alt + shift + * ................... goto workspace SPOTIFY

alt + - ........................... show simplenote (in scratchpad)
alt + + ........................... show enpass (in scratchpad)

alt + v ........................... vertical split
alt + h ........................... horizontal split
alt + d ........................... toggle split layout
alt + x ........................... tabbed layout
alt + z ........................... stacked layout
```

## Dunst

Shortcuts

```
alt + n ........................... show previous notitication
alt + m / click ................... hide current notification
alt + shift + m / left click ...... hide all notifications
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
- color0    black   #000000
- color8    black   #767676
- color1    red     #cc0403
- color9    red     #f2201f
- color2    green   #19cb00
- color10   green   #23fd00
- color3    yellow  #cecb00
- color11   yellow  #fffd00
- color4    blue    #0d73cc
- color12   blue    #1a8fff
- color5    magenta #cb1ed1
- color13   magenta #fd28ff
- color6    cyan    #0dcdcd
- color14   cyan    #14ffff
- color7    white   #dddddd
- color15   white   #ffffff
```

# VSCode sync

I keep settings in a `gist` (details in Enpass) using the extension `Settings Sync`

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
