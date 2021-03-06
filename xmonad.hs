import XMonad hiding ((|||) )
import XMonad.Config.Xfce
import XMonad.Prompt.Shell
import XMonad.ManageHook
import XMonad.Actions.CycleWS


-- tags
import XMonad.Actions.TagWindows
-- to use tagPrompt
import XMonad.Prompt 
import XMonad.Prompt.Ssh
import XMonad.Prompt.RunOrRaise
import XMonad.Prompt.FuzzyMatch

--Dynamiclog
import XMonad.Hooks.DynamicLog  -- ( PP(..), dynamicLogWithPP, dzenColor, wrap, defaultPP )
import XMonad.Util.Run
{% if xmonad_multi_keys %}
import XMonad.Util.EZConfig(additionalKeys, additionalKeysP)
{% endif %}
import System.IO
import XMonad.Operations
import XMonad.Actions.DwmPromote
import XMonad.Layout hiding ( (|||)) -- Usando el operador de layoutcomibnators
import XMonad.Layout.LayoutCombinators   -- use the one from LayoutCombinators instead
import XMonad.Layout.WorkspaceDir
import XMonad.Layout.Tabbed
import XMonad.Layout.Circle
import XMonad.Layout.WindowNavigation
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Roledex 
import XMonad.Layout.IM
import XMonad.Layout.SimplestFloat
import XMonad.Layout.MosaicAlt
import qualified XMonad.Layout.HintedGrid as HG
import qualified XMonad.Layout.Grid as SG
import XMonad.Layout.MagicFocus
import XMonad.Layout.Spacing
import XMonad.Layout.Magnifier
import XMonad.Layout.SimpleDecoration
import XMonad.Layout.MouseResizableTile
import XMonad.Prompt.Window
import XMonad.Prompt.Layout
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.CopyWindow
import XMonad.Actions.SpawnOn
import XMonad.Actions.GridSelect
import XMonad.Actions.WindowGo
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ICCCMFocus
import XMonad.Util.Loggers
import XMonad.Hooks.ManageDocks -- Sustituye defaultgaps
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.BoringWindows as BO
import System.Exit


import qualified XMonad.Actions.Submap as SM
import qualified XMonad.Actions.Search as S


-- import XMonad.Prompt             ( XPConfig(..), XPPosition(..) )
--import XMonad.Prompt.Shell       ( shellPrompt )
 
import qualified Data.Map as M
import Data.Bits ((.|.))
import Data.Ratio
import XMonad.Hooks.XPropManage
import Data.List
import Data.Monoid
import System.IO

-- Necesario para los keybindings:
import qualified XMonad.StackSet as W 

import Data.Traversable (traverse)
-- Fool java
import XMonad.Hooks.SetWMName


myModMask = mod4Mask -- Tecla windows
modWinMask = mod4Mask


 -- The list of all topics/workspaces of your xmonad configuration.
 -- The order is important, new topics must be inserted
 -- at the end of the list if you want hot-restarting
 -- to work.


logTag :: Logger
logTag = withWindowSet $ traverse (fmap show . getTags) . W.peek


myXPConfig = def { searchPredicate = fuzzyMatch,
                   autoComplete = Just 500000
                 }

main = do xmproc <- spawnPipe "xmobar /home/nesaro/.xmobarrc"
{% if xmonad_docks == "new" %}
          xmonad $ docks $ ewmh $ withUrgencyHook NoUrgencyHook $  {% if de is defined and de == "xfce" %} xfceConfig {% else %} defaultConfig {% endif %}
    
{% else %}
          xmonad $ ewmh $ withUrgencyHook NoUrgencyHook $  {% if de is defined and de == "xfce" %} xfceConfig {% else %} defaultConfig {% endif %}
{% endif %}

                     { borderWidth        = 3
                     , normalBorderColor  = "grey30"
                     , focusedBorderColor = "#ff0000" 
                     , workspaces         = ["nav", "adm", "cal", "chat", "mail", "mus", "tr", "rss", "social"] 
                     , terminal           = "xfce4-terminal"
                     , logHook            = takeTopFocus >> (dynamicLogWithPP $ xmobarPP
                                                { ppOutput = hPutStrLn xmproc
                                                , ppTitle = xmobarColor "green" "" . shorten 50
                                                , ppExtras = [logTag]
                                                })
                     , manageHook         = manageSpawn <+> myManageHook2 <+> myManageHook3 {% if xmonad_docks != "new" %}<+> manageDocks {% endif%}<+> manageHook defaultConfig -- El ultimo termino viene del modulo de area de paneles
                     , keys               = newKeys 
                     , layoutHook         = myLayout
                     , startupHook        = setWMName "LG3D"
                     , focusFollowsMouse  = False
                     } {% if xmonad_multi_keys %} `additionalKeysP` extra_keys{% endif %}
                     where
                       tiled = Tall 1 (3%100) (1%2)


lall = spacing 3 (MosaicAlt M.empty) ||| mouseResizableTile ||| tiled ||| simplestFloat ||| noBorders Roledex ||| Mirror tiled ||| Full ||| magicFocus(noBorders Circle) ||| HG.Grid False ||| SG.Grid ||| simpleTabbed ||| mySplit
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio
     -- The default number of windows in the master pane
     nmaster = 1
     -- Default proportion of screen occupied by master pane
     ratio   = 1/2
     -- Percent of screen to increment by when resizing panes
     delta   = 3/100
     mySplit = magnifiercz' 1.4 $ Tall nmaster delta2 ratio2
     -- Percent of screen to increment by when resizing panes
     delta2   = 3/100
     -- Default proportion of screen occupied by master pane
     ratio2   = 60/100
ladm = spacing 3 (MosaicAlt M.empty) ||| tiled ||| Roledex ||| Mirror tiled ||| Full |||  HG.Grid False ||| SG.Grid ||| simpleTabbed ||| mySplit
  where
     tiled   = Tall nmaster delta ratio
     nmaster = 1
     ratio   = 1/2
     delta   = 3/100
     mySplit = magnifiercz' 1.4 $ Tall nmaster delta2 ratio2
     delta2   = 3/100
     ratio2   = 60/100

myLayout = boringWindows $ avoidStruts $ smartBorders $ spacingRaw False (Border 10 10 200 100) False (Border 10 10 10 10) True $ onWorkspace "adm" ladm lall

{% if xmonad_multi_keys %}
extra_keys = [
    ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +1.5%")
    , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@  -1.5%")
    , ("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")    

    , ("<XF86AudioPlay>", spawn "playerctl play-pause")    
    , ("<XF86AudioPrev>", spawn "playerctl previous")    
    , ("<XF86AudioNext>", spawn "playerctl next")    

    , ("<XF86MonBrightnessUp>", spawn "xbacklight +5")    
    , ("<XF86MonBrightnessDown>", spawn "xbacklight -5")    
    ]

{% endif %}

--toAdd x =
newKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    --TAGS
    --((modMask x, xK_f  ), withFocused (addTag "abc"))
    --((modMask x, xK_g  ), tagPrompt defaultXPConfig (\s -> withTaggedGlobal s float)) -- Hace las ventanas con tag flotantes
    --, ((modWinMask .|. shiftMask, xK_g  ), tagPrompt defaultXPConfig (\s -> withWindowSet (addTags s))) -- a;adir un tag de golpe TODO
    --, ((modWinMask , xK_g  ), tagPrompt defaultXPConfig (\s -> withTaggedP s (W.shiftWin "2"))) -- ni idea
    [((modWinMask, xK_t), SM.submap . M.fromList $ 
                [ ((modWinMask, xK_t), tagPrompt defaultXPConfig (\s -> focusUpTaggedGlobal s ))-- Enfoca a la siguiente ventana
                , ((modWinMask, xK_s), tagPrompt defaultXPConfig (\s -> withFocused (addTag s)))
                , ((modWinMask, xK_d  ), tagDelPrompt defaultXPConfig) -- Borra el tag de la ventana
                , ((modWinMask, xK_g  ), tagPrompt defaultXPConfig (\s -> withTaggedGlobalP s shiftHere)) -- Cambia las ventanas con el tag al escritorio actual
                ])

    --WINDOWS
    , ((modWinMask, xK_w), SM.submap . M.fromList $ 
                [ ((modWinMask, xK_w     ), windowPrompt myXPConfig Goto allWindows )
                , ((modWinMask, xK_t     ), windowPromptBring defaultXPConfig)
                , ((modWinMask, xK_e), goToSelected defaultGSConfig)
                , ((modWinMask, xK_c), withWorkspace defaultXPConfig (windows . copy))
                , ((modWinMask, xK_i), withWorkspace defaultXPConfig (windows . W.shift))
                ])

    --WORKSPACES
    , ((modWinMask, xK_e), SM.submap . M.fromList $ 
                [ ((modWinMask, xK_d), removeWorkspace)
                , ((modWinMask, xK_e), selectWorkspace defaultXPConfig { autoComplete = Just 200000 })
                , ((modWinMask, xK_n), selectWorkspace defaultXPConfig)
                , ((modWinMask, xK_r), renameWorkspace defaultXPConfig)
                ])

    , ((modWinMask .|. shiftMask, xK_Right), nextWS) 
    , ((modWinMask .|. shiftMask, xK_Left), prevWS) 
    , ((modWinMask , xK_Right), moveTo Next NonEmptyWS) 
    , ((modWinMask , xK_Left), moveTo Prev NonEmptyWS) 

    --LAYOUTS
    , ((modWinMask, xK_p), SM.submap . M.fromList $
                [ ((modWinMask, xK_p), layoutPrompt defaultXPConfig) --Pregunta por el layout
                , ((modWinMask, xK_c), sendMessage $ JumpToLayout "Spacing Circle") 
                , ((modWinMask, xK_m), sendMessage $ JumpToLayout "Spacing 3 MosaicAlt") 
                , ((modWinMask, xK_t), sendMessage $ JumpToLayout "Tall") 
                , ((modWinMask .|. shiftMask, xK_t), sendMessage $ JumpToLayout "Magnifier NoMaster Tall") 
                , ((modWinMask, xK_f), sendMessage $ JumpToLayout "Full") 
                , ((modWinMask, xK_g), sendMessage $ JumpToLayout "Grid False") 
                , ((modWinMask, xK_b), sendMessage $ JumpToLayout "Tabbed Simplest") 
                , ((modWinMask, xK_r), sendMessage $ JumpToLayout "Roledex") 
                , ((modWinMask, xK_o), sendMessage $ JumpToLayout "SimplestFloat") 
                ])

    --MOSAICALT
    , ((modWinMask, xK_m), SM.submap . M.fromList $ 
                [ ((modWinMask, xK_a    ), withFocused (sendMessage . expandWindowAlt))
                , ((modWinMask, xK_z    ), withFocused (sendMessage . shrinkWindowAlt))
                , ((modWinMask, xK_s    ), withFocused (sendMessage . tallWindowAlt))
                , ((modWinMask, xK_d    ), withFocused (sendMessage . wideWindowAlt))
                , ((modWinMask, xK_space), sendMessage resetAlt)
                ])
    
    --SPACING
    , ((modWinMask, xK_a), SM.submap . M.fromList $ 
                [ ((modWinMask, xK_m    ), toggleSmartSpacing)
                , ((modWinMask, xK_s    ), toggleScreenSpacingEnabled)
                , ((modWinMask, xK_w    ), toggleWindowSpacingEnabled)
                ])


    , ((modm , xK_q), spawn("killall dzen2") >> restart "xmonad" True)
    , ((modWinMask, xK_Tab), toggleWS)
    , ((modm, xK_space ), sendMessage NextLayout)
    , ((modm, xK_Tab ), BO.focusDown) -- %! Move focus to the next window
    , ((modm .|. shiftMask, xK_Tab ), BO.focusUp  ) -- %! Move focus to the previous window
    , ((modm, xK_t), withFocused $ windows . W.sink)
    {% if screensaver == "lightlocker" %}
    , ((modWinMask, xK_l), spawn "light-locker-command --lock")
    {% elif screensaver == "xscreensaver" %}
    , ((modWinMask, xK_l), spawn "xscreensaver-command --lock")
    {% endif %}
    , ((modWinMask .|. shiftMask, xK_s), spawn "urxvt")
    , ((modWinMask .|. shiftMask, xK_d), spawn "gnome-terminal --profile=coding")
    , ((modWinMask .|. shiftMask, xK_k), spawn "myterm")
    , ((modWinMask .|. shiftMask, xK_o), spawn "uzbl-browser")
    , ((modWinMask .|. shiftMask, xK_i), runOrRaisePrompt defaultXPConfig)
    , ((modm, xK_Return), windows W.swapMaster)
    , ((modm, xK_KP_Enter), windows W.swapMaster)
    , ((modWinMask , xK_quoteleft), nextScreen)
    , ((modm, xK_BackSpace), focusUrgent) -- Ultima ventana urgente. TODO: Pensar algo mejor para las ventanas blink, tipo añadir tag
    , ((modWinMask, xK_b), sendMessage ToggleStruts) -- Toggle area de paneles
    , ((modWinMask .|. shiftMask, xK_m), sshPrompt defaultXPConfig) -- Toggle area de paneles
    , ((modm, xK_F4), kill1)
    , ((modm .|. shiftMask , xK_F4), kill1)
    -- modifying the window order
    , ((modm,               xK_Return), windows W.swapMaster) -- %! Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  ) -- %! Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    ) -- %! Swap the focused window with the previous windo
    -- increase or decrease number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1)) -- %! Increment the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1))) -- %! Deincrement the number of windows in the master area
        -- resizing the master/slave ratio
    , ((modm,               xK_h     ), sendMessage Shrink) -- %! Shrink the master area
    , ((modm,               xK_l     ), sendMessage Expand) -- %! Expand the master area
    {% if de is defined and de == "xfce" %}
    , ((modm .|. shiftMask, xK_q     ), spawn "xfce4-session-logout")
    {% elif de is defined and de == "lxde" %}
    , ((modm .|. shiftMask, xK_q     ), spawn "lxsession-logout")
    {% else %}
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    {% endif %}


    --SEARCH ENGINES
    , ((modWinMask, xK_s), SM.submap $ searchEngineMap $ S.promptSearch defaultXPConfig)
    , ((modm .|. shiftMask, xK_s), SM.submap $ searchEngineMap $ S.selectSearch)
    , ((modm, xK_p), spawn "exe=`PATH=$PATH:$HOME/bin rofi -show run -kb-row-select \"Tab\" -kb-row-tab \"\"` && eval \"exec $exe\"") -- %! Launch dmenu
    ]
    ++
    [((m .|. modWinMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

myManageHook2 :: ManageHook
myManageHook2 = composeAll 
    [
    className   =? "Amarok"             --> doF(W.shift "mus" ),
    className   =? "Pidgin"             --> doF(W.shift "chat" ),
    className   =? "Kopete"             --> doF(W.shift "chat" ),
    className   =? "kopete"             --> doF(W.shift "chat" ),
    className   =? "gajim"             --> doF(W.shift "chat" ),
    className   =? "Claws-mail"           --> doF(W.shift "mail" ),
    className   =? "claws-mail"           --> doF(W.shift "mail" ),
    className   =? "akregator"           --> doF(W.shift "rss" ),
    className   =? "korganizer"           --> doF(W.shift "cal" ),
    title   =? "Downloads"           --> doF(W.shift "downloads" ),
    className   =? "Quodlibet"           --> doF(W.shift "mus" ),
    --title       =? "MPlayer"            --> doFloat,
    className   =? "xfce4-appfinder"    --> doFloat,
    className   =? "Xfce4-appfinder"    --> doFloat,
    --className   =? "stalonetray"        --> doIgnore,
    --className   =? "fbpanel"            --> doIgnore,
    className   =? "xclock"            --> doFloat,
    className   =? "XClock"            --> doIgnore,
    --className   =? "xfdesktop"            --> doIgnore,
    className   =? "xfce4-panel"            --> doIgnore,
    className   =? "Gkrellm2"            --> doIgnore ] 

--managehook alternativo
--
myManageHook3 :: ManageHook
myManageHook3 = xPropManageHook xPropMatches 

xPropMatches :: [XPropMatch]
xPropMatches = [ ([ (wM_CLASS, any ("gimp"==))], (\w -> float w >> return (W.shift "2")))
               , ([ (wM_COMMAND, any ("screen" ==)), (wM_CLASS, any ("xterm" ==))], pmX (addTag "screen"))
               , ([ (wM_CLASS, any ("xterm" ==))], pmX (addTag "term"))
               , ([ (wM_CLASS, any ("Sylpheed" ==))], pmX (addTag "mail"))
               , ([ (wM_CLASS, any ("Firefox" ==))], pmX (addTag "nav"))
               , ([ (wM_CLASS, any ("Opera" ==))], pmX (addTag "nav"))
               ]

-- Submap de searchengines
searchEngineMap method = M.fromList $
                         [ ((modWinMask , xK_g), method S.google)
                         , ((modWinMask , xK_h), method S.hoogle)
                         , ((modWinMask , xK_w), method S.wikipedia)
                         ]




