{- xmonad.hs
 - Author: Øyvind 'Mr.Elendig' Heggstad <mrelendig AT har-ikkje DOT net>
 - Version: 0.0.8
 -}

-------------------------------------------------------------------------------
-- Imports --
-- stuff
import XMonad
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import System.Exit
import Graphics.X11.Xlib
import System.IO (Handle, hPutStrLn)

-- utils
import XMonad.Util.Run (spawnPipe)

-- hooks
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ManageHelpers

-- layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile

-- for fullscreen
import XMonad.Hooks.EwmhDesktops

import Graphics.X11.ExtraTypes.XF86

-------------------------------------------------------------------------------
-- Main --
main = do
    xmonad =<< statusBar cmd pp kb conf
    where
        cmd = "xmobar -x 0"
        pp = customPP
        kb  XConfig { XMonad.modMask = modMask } = (modMask, xK_b)
        conf = defaultConfig
              { workspaces = workspaces'
              , modMask = modMask'
              , borderWidth = borderWidth'
              , normalBorderColor = normalBorderColor'
              , focusedBorderColor = focusedBorderColor'
              , terminal = terminal'
              , keys = keys'
              , layoutHook = layoutHook'
              , manageHook = manageHook'
              , handleEventHook = handleEventHook'
              }

-------------------------------------------------------------------------------
-- Hooks --
manageHook' :: ManageHook
-- manageHook' = (doF W.swapDown) <+> manageHook defaultConfig <+> manageDocks <+> (composeAll . concat $)
manageHook' = manageHook defaultConfig <+> manageDocks <+> (composeAll . concat $)
	[ [ className =? "chromium"	--> doShift "web" ]
	, [ className =? c          --> doFloat | c <- floats ]
	, [ isFullscreen            --> (doF W.focusDown <+> doFullFloat) ] ]
    where
        floats = [ ]


logHook' :: Handle ->  X ()
logHook' h = dynamicLogWithPP $ customPP { ppOutput = hPutStrLn h }

layoutHook' = customLayout

handleEventHook' = docksEventHook <+> fullscreenEventHook

-------------------------------------------------------------------------------
-- Looks --
-- bar
customPP :: PP
customPP = defaultPP { ppCurrent = xmobarColor "#3579A8" ""
                     , ppTitle =  shorten 80
                     , ppSep =  "<fc=#3579A8> | </fc>"
                     , ppHiddenNoWindows = xmobarColor "#C4C4C4" ""
                     , ppUrgent = xmobarColor "#FFFFAF" "" . wrap "[" "]"
                     }

-- borders
borderWidth' :: Dimension
borderWidth' = 1

normalBorderColor', focusedBorderColor' :: String
normalBorderColor'  = "#000000"
focusedBorderColor' = "#3579A8"

-- workspaces
workspaces' :: [ WorkspaceId ]
workspaces' = [ "1:main", "2:web", "3:irc", "4:dev0", "5:dev1", "6:log", "7:sys", "8:end" ]

-- layouts
customLayout = (avoidStruts . lessBorders OnlyFloat) $ smartBorders tiled ||| smartBorders (Mirror tiled)  ||| noBorders Full
  where
    tiled = ResizableTall 1 (2/100) (toRational (2 / (1 + sqrt(5)::Double))) []

-------------------------------------------------------------------------------
-- Terminal --
terminal' :: String
terminal' = "urxvtc"

-------------------------------------------------------------------------------
-- Keys/Button bindings --
-- modmask
modMask' :: KeyMask
modMask' = mod4Mask

-- keys
keys' :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
keys' conf @ (XConfig { XMonad.modMask = modMask }) = M.fromList $
    -- launching and killing programs
    [ ((modMask,               xK_Return), spawn $ XMonad.terminal conf)
    , ((modMask,               xK_p     ), spawn "dmenu_run -nb '#030303' -nf '#ffffff' -sb '#3579A8' -fn -*-profont-*-*-*-*-11-*-*-*-*-*-*-*")
    , ((modMask .|. shiftMask, xK_c     ), kill)

    -- layouts
    , ((modMask,               xK_space ), sendMessage NextLayout)
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
	, ((modMask,			   xK_b     ), sendMessage ToggleStruts)


    -- floating layer stuff
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink)

    -- refresh
    , ((modMask,               xK_n     ), refresh)

    -- focus
    , ((modMask,               xK_Tab   ), windows W.focusDown)
    , ((modMask,               xK_j     ), windows W.focusDown)
    , ((modMask,               xK_k     ), windows W.focusUp)
    , ((modMask,               xK_m     ), windows W.focusMaster)

    -- swapping
    , ((modMask .|. shiftMask, xK_Return), windows W.swapMaster)
    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )
    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- increase or decrease number of windows in the master area
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))

    -- resizing
    , ((modMask,               xK_h     ), sendMessage Shrink)
    , ((modMask,               xK_l     ), sendMessage Expand)
    , ((modMask .|. shiftMask, xK_h     ), sendMessage MirrorShrink)
    , ((modMask .|. shiftMask, xK_l     ), sendMessage MirrorExpand)

    -- mpd controls
    , ((modMask .|. controlMask,  xK_h     ), spawn "mpc prev")
    , ((modMask .|. controlMask,  xK_t     ), spawn "mpc toggle")
    , ((modMask .|. controlMask,  xK_s     ), spawn "mpc next")
    , ((modMask .|. controlMask,  xK_g     ), spawn "mpc seek -2%")
    , ((modMask .|. controlMask,  xK_c     ), spawn "mpc volume -4")
    , ((modMask .|. controlMask,  xK_r     ), spawn "mpc volume +4")
    , ((modMask .|. controlMask,  xK_l     ), spawn "mpc seek +2%")

    -- backlight
    , ((0,  xF86XK_MonBrightnessUp      ),  spawn "sudo /usr/bin/backl + 250")
    , ((0,  xF86XK_MonBrightnessDown    ),  spawn "sudo /usr/bin/backl - 250")

    -- kbd leds
    , ((0,  xF86XK_KbdBrightnessUp      ),  spawn "sudo /usr/bin/kbled + 1")
    , ((0,  xF86XK_KbdBrightnessDown    ),  spawn "sudo /usr/bin/kbled - 1")

    -- quit, or restart
    , ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    , ((modMask              , xK_q     ), restart "xmonad" True)
    ]
    ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [((m .|. modMask, k), windows $ f i)
        -- | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

-------------------------------------------------------------------------------
