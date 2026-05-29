# Third-party attribution

## CachyOS niri + noctalia configuration

The niri and noctalia configuration under
`build_files/system_files/etc/skel/.config/` is derived from the
[CachyOS/cachyos-niri-noctalia](https://github.com/CachyOS/cachyos-niri-noctalia)
project, which is licensed under the **GNU General Public License v3.0**.

Modifications were made for Fedora / Universal Blue / bootc compatibility and to
fit the Precision Overcast theme, including:

- `niri/cfg/autostart.kdl` — added D-Bus session env import, `xwayland-satellite`,
  and a `mate-polkit` auth agent.
- `niri/cfg/misc.kdl` — added `DISPLAY` for Xwayland; cursor theme changed from
  `capitaine-cursors` (not packaged on Fedora) to `Adwaita`.
- `niri/cfg/keybinds.kdl` — terminal bound to `ghostty`.
- `noctalia/plugins.json` — disabled the network-fetched `polkit-agent` plugin
  in favor of `mate-polkit`.
- `noctalia/settings.json` — seeded so the first-run wizard is skipped and the
  Precision Overcast scheme + ghostty terminal + brand fonts are preselected.

A copy of the GPL-3.0 license text is available at
<https://www.gnu.org/licenses/gpl-3.0.txt>.

## Precision Overcast theme

`noctalia/colorschemes/Precision Overcast/Precision Overcast.json` and the
ghostty palette in `ghostty/config` are the maintainer's own design system
("Precision Overcast"), not third-party work.

## Fonts

Fetched at build time from Google Fonts, all under the SIL Open Font License:
- [Geist](https://github.com/google/fonts/tree/main/ofl/geist) and
  [Geist Mono](https://github.com/google/fonts/tree/main/ofl/geistmono) (Vercel)
- [Schibsted Grotesk](https://github.com/google/fonts/tree/main/ofl/schibstedgrotesk)
