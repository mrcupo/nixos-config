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
        // No touchpad block — desktop doesn't have one
        mouse {}
        focus-follows-mouse max-scroll-amount="0%"
      }

      // LG ULTRAGEAR+ (DP-1) — 2560x1440 @ 240Hz
      output "DP-1" {
        mode "2560x1440@239.970"
        scale 1.0
        variable-refresh-rate on-demand=true
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

        default-column-width { proportion 0.5; }

        focus-ring {
          off
        }

        border {
          width 3
          active-color "#928374"
          inactive-color "#3c3836"
        }

        // Tabbed columns (toggle with Mod+O). Indicator lives inside the
        // column so it never overlaps the neighbouring window.
        tab-indicator {
          hide-when-single-tab
          place-within-column
          gap 5
          corner-radius 8
          active-color "#928374"
          inactive-color "#3c3836"
        }

        gaps 5

        struts {
          left 7
          right 7
          top 5
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
        default-column-width { proportion 0.66667; }
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
        match app-id=r#"^vesktop$"#
        default-column-width { proportion 0.66667; }
        open-on-workspace "chat"
      }

      window-rule {
        match app-id=r#"chatterino"#
        default-column-width { proportion 0.33333; }
        default-window-height { proportion 0.66667; }
        open-on-workspace "brow"
      }

      window-rule {
        match app-id=r#"^obsidian$"#
        default-column-width { proportion 0.66667; }
        open-on-workspace "brow"
      }

      window-rule {
        match app-id=r#"(?i).*spotify.*"#
        default-column-width { proportion 0.66667; }
        open-on-workspace "chat"
      }

      // Steam windows
      window-rule {
        match app-id=r#"^steam$"#
        default-column-width { proportion 0.66667; }
        open-on-workspace "game"
      }

      // Steam / Proton games. Native games use "steam_app_*", but Proton
      // (Windows) games report their executable name instead, e.g.
      // "deadlock.exe" — match both. Multiple match lines are OR'd.
      window-rule {
        match app-id=r#"^steam_app_"#
        match app-id=r#"(?i)\.exe$"#
        open-on-workspace "game"
        open-fullscreen true
      }

      // Rounded corners + realistic blur on all windows
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
        match namespace="^noctalia-(background|bar-content|dock|notification|launcher)-.*$"
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
      workspace "game"

      // Session services
      spawn-at-startup "noctalia-shell"
      spawn-at-startup "xwayland-satellite"

      // Keep Noctalia wallpaper behind windows and overview.
      layer-rule {
        match namespace="^noctalia-wallpaper*"
        place-within-backdrop true
      }

      // General backdrop layer rule
      layer-rule {
        place-within-backdrop true
      }

      binds {
        Mod+Shift+Slash { show-hotkey-overlay; }

        // Apps
        Mod+T hotkey-overlay-title="Terminal" { spawn "warp-oss"; }
        Mod+Return { spawn "warp-oss"; }
        // Primary browser: Helium. Firefox is installed as a backup but not bound here.
        Mod+B hotkey-overlay-title="Browser" { spawn "helium"; }
        Mod+E hotkey-overlay-title="Files" { spawn "nautilus" "--new-window"; }
        Mod+G hotkey-overlay-title="Steam" { spawn "/home/user/.local/bin/steam-safe"; }

        // Noctalia shell binds
        Mod+Space hotkey-overlay-title="Launcher" { spawn-sh "noctalia-shell ipc call launcher toggle"; }
        Mod+N hotkey-overlay-title="Control Center" { spawn-sh "noctalia-shell ipc call controlCenter toggle"; }
        Super+Shift+L hotkey-overlay-title="Lock Screen" { spawn-sh "noctalia-shell ipc call lockScreen lock"; }
        Mod+Shift+Comma hotkey-overlay-title="Settings" { spawn-sh "noctalia-shell ipc call settings toggle"; }
        Mod+W hotkey-overlay-title="Wallpaper Picker" { spawn-sh "noctalia-shell ipc call plugin:wallcards toggle"; }

        // Overview
        Mod+TAB repeat=false { toggle-overview; }

        // Window management
        Mod+Q repeat=false { spawn "/home/user/.local/bin/niri-close-window-smart"; }
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
        Mod+O hotkey-overlay-title="Toggle Tabbed Column" { toggle-column-tabbed-display; }

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
        // Right Alt doubles as Print on the compact keyboard.
        // Modifier-only binds in niri need the modifier written out as the
        // prefix too — bare "Alt_R" never matches because pressing Right Alt
        // already activates the Alt modifier.
        Alt+Alt_R { screenshot; }

        // Media keys - routed through Noctalia for OSD
        XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "noctalia-shell ipc call volume increase"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn-sh "noctalia-shell ipc call volume decrease"; }
        XF86AudioMute allow-when-locked=true { spawn-sh "noctalia-shell ipc call volume muteOutput"; }
        XF86AudioMicMute allow-when-locked=true { spawn-sh "noctalia-shell ipc call volume muteInput"; }
        Mod+M allow-when-locked=true { spawn-sh "noctalia-shell ipc call volume muteInput"; }

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
