## Custom XMonad

Clone this repo to $HOME/.config/xmonad with:
```
git clone https://github.com/lfg-oliveira/xmonad-config $HOME/.config/xmonad
cd $HOME/.config/xmonad
```
Inside the cloned repository, clone both xmonad and xmonad-contrib and run `stack install`:
```
git clone https://github.com/xmonad/xmonad
git clone https://github.com/xmonad/xmonad-contrib
stack install
```
To recompile and restart xmonad either run:
```
xmonad --recompile && xmonad --restart
```
or press `Super(Windows logo key)+Shift+r`