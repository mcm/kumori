#!/bin/bash
#
# OPTIONAL: replace the Fedora kernel with the CachyOS kernel.
#
# ⚠️  READ BEFORE ENABLING
#
#   * Secure Boot: the CachyOS kernel is NOT signed with the Fedora/ublue
#     Secure Boot key. After switching, you must either disable Secure Boot in
#     firmware or enroll your own keys (MOK). On most machines this means
#     Secure Boot OFF. This is the main reason it's off by default.
#
#   * This is the single most likely thing to break a build or a boot. Get the
#     base niri + noctalia image working and booting FIRST, then enable this in
#     a separate commit so you can bisect cleanly if something breaks.
#
# To enable: in build_files/build.sh (step 5), uncomment the line that calls
# this script, then commit.
#
# COPR: https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/
# Fedora packaging notes: https://github.com/CachyOS/copr-linux-cachyos

set -ouex pipefail

dnf5 -y copr enable bieszczaders/kernel-cachyos

# Swap the Fedora kernel set for the CachyOS kernel. The bootc image build will
# regenerate the initramfs for the new kernel during finalization.
dnf5 -y swap \
    --repo "copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos" \
    kernel kernel-cachyos

# Optional CachyOS sysctl/udev tweaks (uncomment to include):
# dnf5 -y copr enable bieszczaders/kernel-cachyos-addons
# dnf5 install -y cachyos-settings
# dnf5 -y copr disable bieszczaders/kernel-cachyos-addons

dnf5 -y copr disable bieszczaders/kernel-cachyos
