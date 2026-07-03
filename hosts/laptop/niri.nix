{ ... }:

{
  home-manager.users.user = {
    xdg.configFile."niri/config.kdl".text = ''
      input {
        keyboard {
          xkb {
            layout "us"
          }
        }
        touchpad {
          tap
          natural-scroll
          dwt
        }
        mouse {}
        focus-follows-mouse max-scroll-amount="0%"
      }

      output "eDP-1" {
        background-color "#282828"
      }

      overview {
        backdrop-color "#32302f"
        workspace-shadow {
          off
        }
      }

      layout {
        background-color "transparent"
        center-focused-column "on-overflow"
        always-center-single-column

        preset-column-widths {
          proportion 0.33333
          proportion 0.5
          proportion 0.66667
        }

        default-column-width { proportion 0.66667; }

        focus-ring {
          off
        }

        border {
          width 3
          active-color "#928374"
          inactive-color "#3c3836"
        }

        gaps 5

        struts {
          left 7
          right 7
          top -5
        }

        shadow {
          on
          draw-behind-window true
          softness 50
          spread 5
          offset x=0 y=5
          color "#0007"
        }
      }

      hotkey-overlay {
        skip-at-startup
      }

      prefer-no-csd

      screenshot-path null

      animations {
        slowdown 2.0
      }

      // Allow Noctalia notification actions and window activation
      debug {
        honor-xdg-activation-with-invalid-serial
      }

      // Window rules
      window-rule {
        match title="Picture in picture"
        open-floating true
        default-floating-position x=100 y=100 relative-to="bottom-right"
        tiled-state true
      }

      window-rule {
        match app-id=r#"helium"#
        open-maximized true
        open-on-workspace "brow"
      }

      window-rule {
        match app-id=r#"warp"#
        opacity 0.9
        draw-border-with-background false
        default-column-width { proportion 0.66667; }
        open-on-workspace "term"
      }

      window-rule {
        match app-id=r#"^equibop$"#
        open-maximized true
        open-on-workspace "chat"
      }

      window-rule {
        match app-id=r#"zapzap$"#
        open-on-workspace "chat"
      }

      window-rule {
        match app-id=r#"chatterino"#
        default-column-width { proportion 0.33333; }
        default-window-height { proportion 1.0; }
        open-on-workspace "brow"
      }

      window-rule {
        match app-id=r#"(?i).*spotify.*"#
        open-maximized true
        open-on-workspace "music"
      }

      // Rounded corners + realistic blur on all windows (Warp's translucent
      // background gets the frosted-wallpaper look)
      window-rule {
        geometry-corner-radius 10
        clip-to-geometry true
        background-effect {
          blur true
          xray false
        }
      }

      // Noctalia: enable blur on its surfaces; xray false so blur looks realistic
      layer-rule {
        match namespace="^noctalia-(bar-[^\"]+|notification|dock|panel)$"
        background-effect {
          blur true
          xray false
        }
      }

      // Global blur tuning
      blur {
        passes 2
        offset 3.0
        noise 0.03
        saturation 1.0
      }

      // Workspaces
      workspace "term"
      workspace "brow"
      workspace "chat"
      workspace "music"

      // Startup - Noctalia replaces waybar, mako, swaybg, swaylock, swayidle
      spawn-at-startup "noctalia"
      spawn-at-startup "xwayland-satellite"

      // Noctalia wallpaper layer rule (Option 2: stationary wallpaper visible at all times)
      layer-rule {
        match namespace="^noctalia-wallpaper*"
        place-within-backdrop true
      }

      // General backdrop layer rule
      layer-rule {
        place-within-backdrop true
      }

      switch-events {
        lid-close { spawn "noctalia" "msg" "session" "lock"; }
      }
      
      binds {
        Mod+Shift+Slash { show-hotkey-overlay; }

        // Apps
        Mod+T hotkey-overlay-title="Terminal" { spawn "warp-oss"; }
        Mod+Return { spawn "warp-oss"; }
        Mod+B hotkey-overlay-title="Browser" { spawn "helium"; }
        Mod+E hotkey-overlay-title="Files" { spawn "nautilus" "--new-window"; }

        // Noctalia shell binds
        Mod+Space hotkey-overlay-title="Launcher" { spawn-sh "noctalia msg panel-toggle launcher"; }
        Mod+N hotkey-overlay-title="Control Center" { spawn-sh "noctalia msg panel-toggle control-center"; }
        Super+Shift+L hotkey-overlay-title="Lock Screen" { spawn-sh "noctalia msg screen-lock"; }
        Mod+Shift+Comma hotkey-overlay-title="Settings" { spawn-sh "noctalia msg settings-toggle"; }
        Mod+W hotkey-overlay-title="Wallpaper Selector" { spawn-sh "noctalia msg panel-toggle wallpaper"; }
        Mod+Shift+W hotkey-overlay-title="Random Wallpaper" { spawn-sh "noctalia msg wallpaper-random"; }
        Mod+P hotkey-overlay-title="Session Menu" { spawn-sh "noctalia msg panel-toggle session"; }

        // Overview
        Mod+TAB repeat=false { toggle-overview; }

        // Window management
        Mod+Q repeat=false { close-window; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+Ctrl+F { expand-column-to-available-width; }
        Mod+C { center-column; }
        Mod+Ctrl+C { center-visible-columns; }

        // Focus (vim-style + arrows)
        Mod+H { focus-column-left; }
        Mod+J { focus-window-or-workspace-down; }
        Mod+K { focus-window-or-workspace-up; }
        Mod+L { focus-column-right; }
        Mod+Left { focus-column-left; }
        Mod+Down { focus-window-or-workspace-down; }
        Mod+Up { focus-window-or-workspace-up; }
        Mod+Right { focus-column-right; }

        // Move windows
        Mod+Ctrl+H { move-column-left; }
        Mod+Ctrl+J { move-window-down-or-to-workspace-down; }
        Mod+Ctrl+K { move-window-up-or-to-workspace-up; }
        Mod+Ctrl+L { move-column-right; }
        Mod+Ctrl+Left { move-column-left; }
        Mod+Ctrl+Down { move-window-down; }
        Mod+Ctrl+Up { move-window-up; }
        Mod+Ctrl+Right { move-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End { focus-column-last; }
        Mod+Ctrl+Home { move-column-to-first; }
        Mod+Ctrl+End { move-column-to-last; }

        // Workspace navigation
        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up { focus-workspace-up; }
        Mod+U { focus-workspace-down; }
        Mod+I { focus-workspace-up; }
        Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
        Mod+Ctrl+Page_Up { move-column-to-workspace-up; }
        Mod+Ctrl+U { move-column-to-workspace-down; }
        Mod+Ctrl+I { move-column-to-workspace-up; }

        Mod+Shift+Page_Down { move-workspace-down; }
        Mod+Shift+Page_Up { move-workspace-up; }

        // Mouse wheel workspace switching
        Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }
        Mod+WheelScrollRight { focus-column-right; }
        Mod+WheelScrollLeft { focus-column-left; }

        // Workspaces by number
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }

        // Column management
        Mod+BracketLeft { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }
        Mod+Comma { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        // Sizing
        Mod+D { switch-preset-column-width; }
        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R { reset-window-height; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // Floating
        Mod+S { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        // Screenshots
        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        // Media keys - routed through Noctalia for OSD
        XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "noctalia msg volume-up"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn-sh "noctalia msg volume-down"; }
        XF86AudioMute allow-when-locked=true { spawn-sh "noctalia msg volume-mute"; }
        XF86AudioMicMute allow-when-locked=true { spawn-sh "noctalia msg mic-mute"; }
        XF86MonBrightnessUp allow-when-locked=true { spawn-sh "noctalia msg brightness-up"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn-sh "noctalia msg brightness-down"; }

        // Media transport keys - pinned to Spotify via playerctl
        XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl -p spotify play-pause"; }
        XF86AudioPause allow-when-locked=true { spawn-sh "playerctl -p spotify play-pause"; }
        XF86AudioNext allow-when-locked=true { spawn-sh "playerctl -p spotify next"; }
        XF86AudioPrev allow-when-locked=true { spawn-sh "playerctl -p spotify previous"; }
        XF86AudioStop allow-when-locked=true { spawn-sh "playerctl -p spotify stop"; }

        // Session
        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }
        Mod+Shift+P { power-off-monitors; }
      }
    '';
  };
}
