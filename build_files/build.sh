#!/bin/bash

set -ouex pipefail

### ublue-niri build script
#
# Layers the niri scrollable-tiling compositor + the noctalia (Quickshell)
# desktop shell on top of bluefin-dx, themed with Nord. GNOME remains installed
# and selectable in GDM; niri is added as an additional Wayland session.
#
# Package sources:
#   - niri                -> COPR  yalter/niri       (tracks upstream closely)
#   - noctalia-shell      -> Terra (repos.fyralabs.com), pulls noctalia-qs + deps
#   - everything else     -> Fedora repos (already enabled on Bluefin)
#
# IMPORTANT (bootc hygiene): any third-party repo we enable here is DISABLED
# again at the end so it does not leak into end-users' update/layering path.

#############################################
## 1. Enable third-party repositories
#############################################

# niri compositor (COPR)
dnf5 -y copr enable yalter/niri

# Terra repo (for noctalia-shell). terra-release wires up the proper repo + GPG.
dnf5 install -y --nogpgcheck \
    --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" \
    terra-release

#############################################
## 2. Install niri + noctalia + supporting tools
#############################################

# Note: the CachyOS niri config binds the terminal to alacritty and routes
# media/brightness/volume keys through noctalia's IPC (not standalone tools),
# and noctalia manages the wallpaper itself — so we don't need fuzzel/swaybg.
# mate-polkit is our offline PolicyKit agent (noctalia's plugin is disabled).
# Note: Fedora has no standalone "polkit-gnome" anymore (folded into gnome-shell,
# which doesn't run under niri), so we use the lightweight MATE agent instead.
dnf5 install -y \
    niri \
    noctalia-shell \
    xwayland-satellite \
    alacritty \
    wl-clipboard \
    brightnessctl \
    ddcutil \
    wlr-randr \
    wlsunset \
    playerctl \
    mate-polkit \
    ImageMagick

#############################################
## 3. Nord GTK theme
#############################################
# Nord isn't packaged in Fedora, so fetch EliverLara's "Nordic" GTK theme into
# the system theme dir. The matching GTK settings (gtk-theme-name=Nordic) are
# seeded for new users via /etc/skel (see system_files/).
install -d /usr/share/themes
curl -fL --retry 3 \
    https://github.com/EliverLara/Nordic/releases/latest/download/Nordic.tar.xz \
    -o /tmp/Nordic.tar.xz
tar -xf /tmp/Nordic.tar.xz -C /usr/share/themes
rm -f /tmp/Nordic.tar.xz

#############################################
## 4. Lay down our config / theming files
#############################################
# system_files/ mirrors the final filesystem layout (etc/, usr/, ...).
cp -r /ctx/system_files/* /

#############################################
## 5. (OPTIONAL) CachyOS kernel
#############################################
# Swapping the kernel works but disables Secure Boot compatibility (the CachyOS
# kernel isn't signed with the ublue/Fedora key). Left off by default. To enable,
# review then uncomment the dedicated script:
# /ctx/optional/cachyos-kernel.sh

#############################################
## 6. Clean up: REMOVE third-party repo definitions
#############################################
# We delete the repo files outright (not just disable them). The niri/noctalia
# packages are already baked into the image layer, so nothing is lost — but a
# leftover repo definition with a dangling gpgkey reference breaks downstream
# tooling. In particular, bootc-image-builder's Anaconda depsolve reads every
# repo file in the image and fails on the Terra repo's missing GPG key.
# (noctalia/niri updates arrive via new image builds, not the user's local dnf.)
dnf5 -y copr remove yalter/niri || true
rm -f /etc/yum.repos.d/_copr*niri*.repo \
      /etc/yum.repos.d/*yalter*niri*.repo \
      /etc/yum.repos.d/terra*.repo

#############################################
## 7. Services
#############################################
# Bluefin already manages GDM; nothing to enable for niri (GDM auto-discovers
# the niri.desktop session shipped by the niri package).
