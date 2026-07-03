{ config, pkgs, ... }:

# console remote game streaming: headless Sway + Sunshine (Moonlight host).
#
# WHY A HEADLESS SWAY SESSION?
#   Sunshine can only stream by capturing a Wayland *output* (a display). console's
#   only real display is the TV via Jovian's gamescope session. Capturing that
#   would (a) lock the remote stream to the TV's resolution and (b) make a couch
#   game and a remote game fight over one session. A dummy-HDMI/EDID display
#   (the usual workaround) only offers a fixed, pre-baked set of resolutions.
#
#   `WLR_BACKENDS=headless` starts a full wlroots compositor with NO physical
#   monitor — its output lives only in GPU memory. That gives us a throwaway
#   display server whose sole job is to give Sunshine something to capture and
#   games somewhere to render, WITHOUT a monitor, a dummy plug, or touching the
#   TV's gamescope session. Being wlroots, its output can be resized on demand
#   to exactly what each Moonlight client asks for (the Apollo-on-Windows trick).
#
#   Net result: two parallel sessions — TV/couch on gamescope, remote clients on
#   headless-Sway+Sunshine. Resolution and (via the null sink below) audio are
#   isolated between them.
#
# STATUS: starting point, NOT yet imported by hosts/console/default.nix. The Reddit
# write-ups this is based on all required on-box iteration; expect to tune the
# renderer and confirm VAAPI/audio live. Wire it in (add ./streaming.nix to
# default.nix imports) only when you're ready to test on the box.
#
# DESIGN NOTES (addressing review findings):
#   - Sunshine config (#1): NixOS only feeds the generated config + applications
#     file to Sunshine via its systemd user unit's ExecStart. A bare `sunshine`
#     would ignore all of that. So we keep `autoStart = false` (no display-manager
#     wiring, and the module's own unit never starts → no port-collision double
#     instance) and launch *the module's generated command* as a child of Sway.
#     Being a Sway child also gives Sunshine SWAYSOCK + WAYLAND_DISPLAY for free,
#     which the prep-cmd below needs (Sway's IPC socket name includes a PID and
#     is not otherwise predictable).
#   - Input (#2): `WLR_BACKENDS=headless,libinput` so Sway enumerates the uinput
#     devices Sunshine creates (Moonlight keyboard/mouse/controller). libinput
#     needs a seat; a lingering user has no logind seat, so we add seatd +
#     LIBSEAT_BACKEND and put the user in the `seat` group.
#   - Audio (#3): a PipeWire null sink ("sunshine") gives the streamed session a
#     dedicated output; games route to it via PULSE_SINK and Sunshine captures
#     its monitor (settings.audio_sink), leaving the TV's HDMI sink untouched.
#   - prep-cmd (#4): wrapped in `sh -c` so $SUNSHINE_CLIENT_* expand — Sunshine
#     exports them as env vars but does not expand ${...} itself.
#
# SUPERVISION TRADE-OFF (decision: option A — keep child-launch):
#   Launching Sunshine as a Sway child (above) gives it correct Wayland/SWAYSOCK
#   inheritance but means it is NOT independently supervised — it loses the NixOS
#   unit's Restart=on-failure/backoff and its own journald identity. A Sway crash
#   relaunches Sunshine (Sway has Restart=on-failure), but if Sunshine alone dies
#   it is not restarted. Accepted for this v1; revisit on-box if it proves flaky.
#   FUTURE OPTION B (documented for the next agent/review, not implemented): run
#   Sunshine as its own supervised user unit (Restart=on-failure, BindsTo the
#   sway-headless unit) and discover Sway's socket in an ExecStart wrapper that
#   globs $XDG_RUNTIME_DIR/sway-ipc.*.sock and exports WAYLAND_DISPLAY/SWAYSOCK —
#   trading the simple child-launch for proper supervision.

let
  # Dedicated user, kept separate from the couch `gamer`: Steam refuses to run
  # twice for the same user, so the TV gamescope Steam and the streamed Steam
  # must be different users. Also isolates this session's audio/input.
  streamUser = "stream";

  # The module's generated Sunshine launch command (binary + generated config
  # file). Launching THIS as a Sway child is what makes the declarative settings
  # / "Virtual Display" app actually take effect (see design note #1).
  sunshineCmd = toString config.systemd.user.services.sunshine.serviceConfig.ExecStart;

  # Sway config: one resizable virtual output, no bar/idle. Sunshine is launched
  # here as a child so it inherits SWAYSOCK + WAYLAND_DISPLAY.
  swayConfig = pkgs.writeText "sway-headless.conf" ''
    # wlroots' headless backend always exposes HEADLESS-1. This mode is just a
    # placeholder — the Sunshine "Virtual Display" app rewrites it per client.
    output HEADLESS-1 mode 1920x1080@60Hz position 0 0

    # --- Input isolation (FINISH ON-BOX) ----------------------------------
    # console shares physical input (game controllers, any attached keyboard) with
    # the TV gamescope session at the evdev level, so couch input can LEAK into
    # this headless stream. Sway cannot tell physical devices from Sunshine's
    # virtual ones by `type:` alone (both are keyboard/pointer), so the leak must
    # be closed per device IDENTIFIER. This needs the real identifiers, which
    # only exist on the booted box. After first boot, list them with:
    #     SWAYSOCK=$(echo /run/user/$(id -u stream)/sway-ipc.*.sock) \
    #       swaymsg -t get_inputs
    # then for each PHYSICAL device (NOT the Sunshine virtual ones) add e.g.:
    #     input "1234:5678:Some_Controller" events disabled
    # Leaving Sunshine's virtual devices enabled keeps Moonlight input working.

    # Console UI inside the streamed session. Swap for any launcher, or drop it
    # to stream a bare compositor. Requires a one-time Steam login as `stream`.
    exec ${pkgs.steam}/bin/steam -gamepadui

    # Sunshine, using the NixOS-generated config (see sunshineCmd). As a child of
    # Sway it captures THIS headless output — never the TV's gamescope session.
    exec ${sunshineCmd}
  '';
in
{
  users.users.${streamUser} = {
    isNormalUser = true;
    description = "Headless game-streaming session (Sunshine)";
    # linger => this user's systemd manager (and the sway-headless service)
    # starts at boot with no interactive login — what a headless box needs.
    linger = true;
    # render: GPU access for the headless renderer + VAAPI encode.
    # seat:   libseat/seatd access so the libinput backend can open input devices
    #         without a logind session (a lingering user has no seat otherwise).
    # input:  read /dev/input/event* (enumerate devices).
    # uinput: WRITE /dev/uinput — `services.sunshine` enables `hardware.uinput`,
    #         which sets /dev/uinput to 0660 root:uinput. Without this, Sunshine
    #         cannot create the Moonlight virtual keyboard/mouse/controller.
    extraGroups = [
      "video"
      "render"
      "audio"
      "input"
      "uinput"
      "seat"
      "gamemode"
    ];
  };

  # Seat management for the headless, login-less Sway session (see design note #2).
  services.seatd.enable = true;

  # Dedicated PipeWire sink for the stream so game audio is captured by Sunshine
  # without disturbing the TV's HDMI output. Games in the Sway session route here
  # via PULSE_SINK; Sunshine captures this sink's monitor (settings.audio_sink).
  services.pipewire.extraConfig.pipewire."10-sunshine-sink" = {
    "context.objects" = [
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "sunshine";
          "node.description" = "Sunshine Stream";
          "media.class" = "Audio/Sink";
          "audio.position" = "FL,FR";
        };
      }
    ];
  };

  systemd.user.services.sway-headless = {
    description = "Headless Sway compositor + Sunshine (game streaming)";
    wantedBy = [ "default.target" ];
    # systemd.user units are global; scope this to the stream user's manager.
    unitConfig.ConditionUser = streamUser;
    environment = {
      # headless: no physical display. libinput: enumerate Sunshine's uinput
      # devices so Moonlight keyboard/mouse/controller reach the session.
      WLR_BACKENDS = "headless,libinput";
      LIBSEAT_BACKEND = "seatd";
      # Route this session's audio to the dedicated null sink defined above.
      PULSE_SINK = "sunshine";
      # RDNA4: try gles2 first; if the stream is black, switch to "vulkan".
      WLR_RENDERER = "gles2";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.sway}/bin/sway --unsupported-gpu --config ${swayConfig}";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  services.sunshine = {
    enable = true;
    # The module's own user unit must NOT auto-start: we launch its generated
    # command from inside the Sway session instead (design note #1). Keeping the
    # module enabled is what installs the uinput udev rules + firewall openings
    # and generates the config/apps file that sunshineCmd points at.
    autoStart = false;
    openFirewall = true; # 47984-47990/tcp, 47998-48000/udp
    # wlr-screencopy capture needs no elevated caps (unlike the KMS capture path).
    capSysAdmin = false;

    settings = {
      capture = "wlr"; # KMS capture misbehaves on virtual outputs
      encoder = "vaapi"; # AMD VAAPI/radeonsi — NOT nvenc (ignore the Nvidia threads)
      # Capture the dedicated null sink's monitor. If audio is silent, try the
      # explicit monitor name "sunshine.monitor".
      audio_sink = "sunshine";
    };

    applications = {
      env = { };
      apps = [
        {
          name = "Virtual Display";
          # Resize the headless output to the client's request on connect; restore
          # the placeholder on disconnect. Wrapped in `sh -c` because Sunshine
          # exposes $SUNSHINE_CLIENT_* as env vars and does not expand ${...}
          # itself — only a shell does. SWAYSOCK is inherited from Sway.
          prep-cmd = [
            {
              do = ''${pkgs.bash}/bin/sh -c "${pkgs.sway}/bin/swaymsg output HEADLESS-1 mode ''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}Hz"'';
              undo = "${pkgs.sway}/bin/swaymsg output HEADLESS-1 mode 1920x1080@60Hz";
            }
          ];
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    sway
    wlr-randr
  ];
}
