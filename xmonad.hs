--System
import System.Exit(exitSuccess)
import System.IO (hPutStrLn)
import System.Directory
--Xmonad
import XMonad
import XMonad.Core (spawn)
import qualified XMonad.StackSet as W
-- Actions
import XMonad.Actions.CopyWindow (
  kill1
  )
import XMonad.Actions.WithAll (
  killAll
  )
import XMonad.Actions.MouseResize
import XMonad.Actions.SpawnOn
--Data
import Data.Monoid
import Data.Maybe
import qualified Data.Map as M
import qualified XMonad.Actions.Search as S
-- Layouts
import XMonad.Layout.Accordion
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Gaps
    -- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

--Hooks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.WorkspaceHistory

--Utils
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Ungrab
import XMonad.Util.SpawnOnce
import XMonad.Util.Run (spawnPipe, hPutStrLn)
import XMonad.Util.NamedScratchpad
-- pallete-dark: #000000;
-- pallete-dark-blue: #150050;
-- pallete-medium-purple: #3F0071;
-- pallete-light-purple: #610094;

-- myWorkspaces = ["d", "w", "s", "d", "v", "m", "v", "g"]
myWorkspaces = ["1","2","3","4","5","6","7","8","9"]
myWorkspacesIndices = M.fromList $ zipWith (,) myWorkspaces [1..]

myManageHooks :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHooks = composeAll
  [   className =? "Steam" --> doFloat 
    , className =? "Gimp" --> doFloat
    , className =? "Code" --> doShift (myWorkspaces !! 0)
    , className =? "Steam" --> doShift (myWorkspaces !! 2)
    , className =? "Chromium" --> doShift (myWorkspaces !! 1)
    , className =? "chromium" --> doShift (myWorkspaces !! 1)
    , className =? "discord" -->  doShift (myWorkspaces !! 3)
    , isFullscreen --> doFullFloat
  ]


myColorPallete :: [String]
myColorPallete = ["#000000", "#150050", "#3F0071", "#610094"]

myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

myTerm :: String
myTerm = "alacritty"

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

toggleFloat w = windows (\s -> if M.member w (W.floating s)
  then W.sink w s
  else (W.float w (W.RationalRect (1/3) (1/4) (1/2) (4/5)) s))

myTabTheme = def { 
    fontName            = myFont
  , activeColor         = myColorPallete !! 3
  , inactiveColor       = myColorPallete !! 1
  , activeBorderColor   = myColorPallete !! 3
  , inactiveBorderColor = myColorPallete !! 0
  , activeTextColor     = myColorPallete !! 2
  , inactiveTextColor   = myColorPallete !! 3
  }

tall     = renamed [Replace "tall"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ magnifier
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 8
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme
tallAccordion  = renamed [Replace "tallAccordion"]
           $ Accordion
wideAccordion  = renamed [Replace "wideAccordion"]
           $ Mirror Accordion


myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
  $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
  myDefaultLayout = withBorder 2 tall
    ||| magnify
    ||| noBorders monocle
    ||| floats
    ||| noBorders tabs
    ||| grid
    ||| spirals
    ||| threeCol
    ||| threeRow
    ||| tallAccordion
    ||| wideAccordion

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
  where i = fromJust $ M.lookup ws myWorkspacesIndices

myKeybinds ::  [(String, X ())]
myKeybinds = [
    ("M-S-<Return>", spawn "rofi -modi ssh,drun,window -show drun -theme ~/.config/rofi/themes/drun.rasi")
  , ("M-<Return>", spawn myTerm)
  , ("M-S-r", spawn "xmonad --recompile && xmonad --restart")
  -- , ("M-C-r", spawn "xmonad --restart")
  , ("M-S-q", io exitSuccess)
  , ("M-s", spawn $ myTerm++" -e ncspot")
  --Killing stuff
  , ("M-S-c", kill1)
  , ("M-S-a", killAll)

  --ToggleFloat
  , ("M-t", withFocused toggleFloat)
  --Special keys (like <Print>)
  , ("<Print>", spawn "flameshot gui")
  , ("<XF86MonBrightnessUp>", spawn "light -A 5")
  , ("<XF86MonBrightnessDown>", spawn "light -U 5")
  ]

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset


myStartupHook :: X ()
myStartupHook = do
  spawnOnce "picom &"
  spawnOnce "~/.fehbg"

  spawnOnOnce   (myWorkspaces!!1) "chromium &"
  spawnOnOnce   (myWorkspaces!!3) "discord &"
  spawnOnOnce   (myWorkspaces!!0) "code &"
  spawnOnOnce   (myWorkspaces!!7) (myTerm++" -e ncspot")  
  setWMName "LG3D"


myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Ubuntu:bold:size=60"
    , swn_fade              = 1.0
    , swn_bgcolor           = myColorPallete !! 1
    , swn_color             = myColorPallete !! 3
    }

main :: IO ()
main = do 
  bar <- spawnPipe "xmobar $HOME/.config/xmobar/xmobarrc"

  xmonad $ ewmh def {
	  modMask       = mod4Mask
  , manageHook    = myManageHooks <+> manageDocks
  , handleEventHook = docksEventHook <+> fullscreenEventHook
	, terminal      = myTerm
  , startupHook   = myStartupHook
	, borderWidth = 2
  , workspaces = myWorkspaces
  , normalBorderColor = myColorPallete !! 2
  , focusedBorderColor = myColorPallete !! 3
  , layoutHook = showWName' myShowWNameTheme myLayoutHook
  , logHook = dynamicLogWithPP  $ namedScratchpadFilterOutWorkspacePP $ xmobarPP {
      ppOutput = hPutStrLn bar
    , ppCurrent = xmobarColor (myColorPallete !! 3) (myColorPallete !! 1) . wrap ("<box type=Bottom width=2 mb=2 color="++myColorPallete!!3++">[") "]</box>"
    , ppVisible = xmobarColor (myColorPallete !! 2) "" . clickable
    , ppHidden = xmobarColor (myColorPallete !! 0) ""  . wrap ("<box type=Top width=2 mt=2 color="++myColorPallete!!2++">") "</box>" . clickable
    , ppHiddenNoWindows = xmobarColor (myColorPallete !! 0) "" . clickable
    , ppTitle = xmobarColor (myColorPallete !! 3) ""
    , ppExtras = [windowCount]
    , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]                    -- order of things in xmobar
	  }
  } `additionalKeysP` myKeybinds