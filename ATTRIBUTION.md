# Third-party attribution

## CachyOS niri + noctalia configuration

The niri and noctalia configuration under
`build_files/system_files/etc/skel/.config/` is derived from the
[CachyOS/cachyos-niri-noctalia](https://github.com/CachyOS/cachyos-niri-noctalia)
project, which is licensed under the **GNU General Public License v3.0**.

Modifications were made for Fedora / Universal Blue / bootc compatibility,
including:

- `niri/cfg/autostart.kdl` — added D-Bus session env import, `xwayland-satellite`,
  and a `polkit-gnome` auth agent.
- `niri/cfg/misc.kdl` — added `DISPLAY` for Xwayland; cursor theme changed from
  `capitaine-cursors` (not packaged on Fedora) to `Adwaita`.
- `noctalia/plugins.json` — disabled the network-fetched `polkit-agent` plugin
  in favor of `polkit-gnome`.
- `gtk-3.0` / `gtk-4.0` `settings.ini` — theme changed from `adw-gtk3` to
  `Nordic` (Nord aesthetic).

A copy of the GPL-3.0 license text is available at
<https://www.gnu.org/licenses/gpl-3.0.txt>.

## Nordic GTK theme

The `Nordic` GTK theme is fetched at build time from
[EliverLara/Nordic](https://github.com/EliverLara/Nordic) (GPL-3.0).

## Noctalia Nord color scheme

`noctalia/colorschemes/Nord/Nord.json` is an original mapping of the
[Nord palette](https://www.nordtheme.com/) to noctalia's color-scheme format.
