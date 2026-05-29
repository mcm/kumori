#!/bin/bash

set -ouex pipefail

### Kumori build script
#
# Layers the niri scrollable-tiling compositor + the noctalia (Quickshell)
# desktop shell on top of bluefin-dx, themed with the "Precision Overcast"
# palette. niri is the only login session (GNOME entries hidden in GDM).
#
# Package sources:
#   - niri                -> COPR  yalter/niri       (tracks upstream closely)
#   - noctalia-shell      -> Terra (repos.fyralabs.com), pulls noctalia-qs + deps
#   - ghostty             -> Terra
#   - everything else     -> Fedora repos (already enabled on Bluefin)
#
# IMPORTANT (bootc hygiene): third-party repos enabled here are REMOVED again at
# the end so they don't leak into end-users' update/layering path.

#############################################
## 1. Enable third-party repositories
#############################################

# niri compositor (COPR)
dnf5 -y copr enable yalter/niri

# Terra repo (noctalia-shell + ghostty). terra-release wires up the repo + GPG.
dnf5 install -y --nogpgcheck \
    --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" \
    terra-release

#############################################
## 2. Install packages
#############################################
# The niri config binds the terminal to ghostty and routes media/brightness/
# volume keys through noctalia's IPC, and noctalia manages the wallpaper itself.
# mate-polkit is our offline PolicyKit agent (noctalia's plugin is disabled);
# Fedora no longer ships a standalone polkit-gnome.
dnf5 install -y \
    niri \
    noctalia-shell \
    xwayland-satellite \
    ghostty \
    zsh \
    wl-clipboard \
    brightnessctl \
    ddcutil \
    wlr-randr \
    wlsunset \
    playerctl \
    mate-polkit \
    adw-gtk3-theme \
    ImageMagick \
    sddm \
    sddm-wayland-generic

#############################################
## 3. Brand fonts (Precision Overcast)
#############################################
# Schibsted Grotesk (sans) + Geist / Geist Mono are not packaged in Fedora.
# Fetch the upstream variable TTFs (all OFL) from Google Fonts.
FONTDIR="/usr/share/fonts/kumori"
install -d "$FONTDIR"
curl -fL --retry 3 -o "$FONTDIR/GeistMono.ttf" \
    "https://github.com/google/fonts/raw/main/ofl/geistmono/GeistMono%5Bwght%5D.ttf"
curl -fL --retry 3 -o "$FONTDIR/Geist.ttf" \
    "https://github.com/google/fonts/raw/main/ofl/geist/Geist%5Bwght%5D.ttf"
curl -fL --retry 3 -o "$FONTDIR/SchibstedGrotesk.ttf" \
    "https://github.com/google/fonts/raw/main/ofl/schibstedgrotesk/SchibstedGrotesk%5Bwght%5D.ttf"
fc-cache -f "$FONTDIR"

#############################################
## 4. Lay down our config / theming files
#############################################
# system_files/ mirrors the final filesystem layout (etc/, usr/, ...).
cp -r /ctx/system_files/* /

# Make our wallpaper noctalia's built-in default. noctalia's WallpaperService
# falls back to `noctaliaDefaultWallpaper` whenever a monitor has no wallpaper
# configured, so repointing it applies our wallpaper for every fresh user with
# no IPC/startup race. The sed matches the property name (robust to value drift).
for wps in /etc/xdg/quickshell/noctalia-shell/Services/UI/WallpaperService.qml \
           /usr/share/quickshell/noctalia-shell/Services/UI/WallpaperService.qml; do
    [ -f "$wps" ] && sed -i \
        's|\(readonly property string noctaliaDefaultWallpaper:\).*|\1 "/usr/share/backgrounds/kumori/kumori.jpg"|' \
        "$wps"
done

# Compile the dconf system defaults we just dropped in (Precision Overcast
# appearance: force dark so the libadwaita gtk.css recolor renders correctly).
# Ensure the default profile references the "local" db without clobbering a
# profile Bluefin may already ship.
if [ ! -f /etc/dconf/profile/user ]; then
    printf 'user-db:user\nsystem-db:local\n' > /etc/dconf/profile/user
fi
dconf update

#############################################
## 5. Default login shell -> zsh (for newly created users)
#############################################
sed -i 's|^SHELL=.*|SHELL=/usr/bin/zsh|' /etc/default/useradd

#############################################
## 6. Rebrand: Bluefin -> Kumori
#############################################
# Universal Blue branding flows from /usr/lib/os-release (real file; /etc is a
# symlink to it) and /usr/share/ublue-os/image-info.json. The GRUB boot entry,
# the fastfetch MOTD, GNOME About, and the Anaconda ISO product name all derive
# from these, so rewriting them rebrands everything user-visible.
#
# Conservative path: we change the display name (NAME/PRETTY_NAME/VARIANT_ID/...)
# but deliberately leave ID/ID_LIKE alone, since Bluefin's tooling (ujust, etc.)
# may key off ID=bluefin and changing it also requires a GRUB EFIDIR fix.
IMAGE_NAME="kumori"            # must match the OCI image name (ghcr.io/mcm/kumori)
IMAGE_PRETTY_NAME="Kumori"        # the user-facing OS name
IMAGE_VENDOR="mcm"
CODE_NAME="overcast"
FEDORA_MAJOR_VERSION="$(grep -oP '(?<=^VERSION_ID=)\d+' /usr/lib/os-release)"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
mkdir -p "$(dirname "$IMAGE_INFO")"
cat > "$IMAGE_INFO" <<EOF
{
  "image-name": "${IMAGE_NAME}",
  "image-flavor": "main",
  "image-vendor": "${IMAGE_VENDOR}",
  "image-ref": "ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}",
  "image-tag": "stable",
  "image-branch": "stable",
  "base-image-name": "bluefin-dx",
  "fedora-version": "${FEDORA_MAJOR_VERSION}"
}
EOF
chmod 0644 "$IMAGE_INFO"

sed -i "s|^NAME=.*|NAME=\"${IMAGE_PRETTY_NAME}\"|"                  /usr/lib/os-release
sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=\"${IMAGE_PRETTY_NAME}\"|"    /usr/lib/os-release
sed -i "s|^VARIANT_ID=.*|VARIANT_ID=${IMAGE_NAME}|"                 /usr/lib/os-release
sed -i "s|^VERSION_CODENAME=.*|VERSION_CODENAME=\"${CODE_NAME}\"|"  /usr/lib/os-release
sed -i "s|^HOME_URL=.*|HOME_URL=\"https://github.com/mcm/kumori\"|"           /usr/lib/os-release
sed -i "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"https://github.com/mcm/kumori\"|" /usr/lib/os-release
sed -i "s|^SUPPORT_URL=.*|SUPPORT_URL=\"https://github.com/mcm/kumori/issues/\"|"      /usr/lib/os-release
sed -i "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"https://github.com/mcm/kumori/issues/\"|" /usr/lib/os-release
sed -i "s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME=\"kumori\"|"       /usr/lib/os-release
sed -i "s|^IMAGE_ID=.*|IMAGE_ID=\"${IMAGE_NAME}\"|"                 /usr/lib/os-release

#############################################
## 7. Display manager: SDDM (replacing GDM), niri the only session
#############################################
# GDM has no bakeable system-wide default session (it's AccountsService-only,
# per-user), so on a niri-only image it falls back to its greeter's gnome-session.
# SDDM is DE-agnostic, reads /usr/share/wayland-sessions, and with only niri.desktop
# present simply defaults to niri. Its Wayland greeter runs via weston (provided
# by sddm-wayland-generic), so no Xorg is needed.
systemctl disable gdm.service || true
systemctl enable sddm.service
# Make SDDM the canonical display-manager (the alias symlink still points at gdm).
ln -sf /usr/lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service

# Leave only niri as a selectable session (SDDM lists /usr/share/wayland-sessions).
rm -f /usr/share/wayland-sessions/gnome*.desktop \
      /usr/share/xsessions/gnome*.desktop

# Skip GNOME's first-login onboarding (harmless under SDDM, but keep it off):
# the /etc/skel done-stamp (system_files) makes new users skip gnome-initial-setup.
systemctl --global mask gnome-initial-setup-first-login.service || true

#############################################
## 8. (OPTIONAL) CachyOS kernel
#############################################
# Swapping the kernel works but disables Secure Boot compatibility (the CachyOS
# kernel isn't signed with the ublue/Fedora key). Left off by default. To enable,
# review then uncomment the dedicated script:
# /ctx/optional/cachyos-kernel.sh

#############################################
## 9. Clean up: REMOVE third-party repo definitions
#############################################
# Delete the repo files outright (not just disable). Installed packages are
# already baked into the image layer. A leftover repo with a dangling gpgkey
# breaks bootc-image-builder's Anaconda depsolve (it reads every repo file).
dnf5 -y copr remove yalter/niri || true
rm -f /etc/yum.repos.d/_copr*niri*.repo \
      /etc/yum.repos.d/*yalter*niri*.repo \
      /etc/yum.repos.d/terra*.repo
