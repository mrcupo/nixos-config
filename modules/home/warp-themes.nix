{ ... }:

let
  transparentTheme = ''
    name: Transparent
    accent: '#c4a7e7'
    background: '#00000000'
    foreground: '#e0def4'
    details: darker
    terminal_colors:
      normal:
        black: '#000000'
        red: '#eb6f92'
        green: '#9ccfd8'
        yellow: '#f6c177'
        blue: '#31748f'
        magenta: '#c4a7e7'
        cyan: '#ebbcba'
        white: '#e0def4'
      bright:
        black: '#6e6a86'
        red: '#eb6f92'
        green: '#9ccfd8'
        yellow: '#f6c177'
        blue: '#31748f'
        magenta: '#c4a7e7'
        cyan: '#ebbcba'
        white: '#e0def4'
  '';
in
{
  # Warp terminal fallback theme. Noctalia owns the live/generated theme; this
  # transparent theme is kept as a manual fallback for glassy terminals.
  xdg.dataFile."warp-oss/themes/transparent.yaml".text = transparentTheme;
}
