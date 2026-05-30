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
  `capitaine-cursors` (not packaged on Fedora) to the bundled
  `Simp1e-Precision-Overcast` theme.
- `niri/cfg/keybinds.kdl` — terminal bound to `ghostty`.
- `noctalia/plugins.json` — disabled the network-fetched `polkit-agent` plugin
  in favor of `mate-polkit`.
- `noctalia/settings.json` — seeded so the first-run wizard is skipped and the
  Precision Overcast scheme + ghostty terminal + brand fonts are preselected.

A copy of the GPL-3.0 license text is available at
<https://www.gnu.org/licenses/gpl-3.0.txt>.

## Fonts

Fetched at build time from Google Fonts, all under the SIL Open Font License:

- [Geist](https://github.com/google/fonts/tree/main/ofl/geist) and
  [Geist Mono](https://github.com/google/fonts/tree/main/ofl/geistmono) (Vercel)
- [Schibsted Grotesk](https://github.com/google/fonts/tree/main/ofl/schibstedgrotesk)

## Wallpaper

Photo by [Quino Al](https://unsplash.com/@quinoal) on
[Unsplash](https://unsplash.com/photos/photo-of-beach-at-golden-hour-ZuZK8D55_cw)
(Unsplash License). Manually converted to match the custom color scheme.

## Cursor theme

`build_files/system_files/usr/share/icons/Simp1e-Precision-Overcast/` is generated
from the [Simp1e](https://gitlab.com/cursors/simp1e) cursor template (itself based
on cz-Viator), licensed under the **GNU General Public License v3.0**. Only the
color scheme was changed, to the Precision Overcast palette. The scheme source is
kept locally (not in this repo); the built theme is shipped as-is.
