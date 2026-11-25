#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="maospix-cosmic"
iso_label="MAOSPIX_COSMIC_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="MAOSPIX Project"
iso_application="MAOSPIX-COSMIC Live/Install ISO"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86,arm64' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
kernel_params_aarch64="clk_ignore_unused pd_ignore_unused arm64.nopauth"
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/maospix-live-user"]="0:0:755"
  ["/etc/sudoers.d/10-maospix-live"]="0:0:440"
  ["/usr/local/bin/maospix-installer"]="0:0:755"
  ["/usr/local/bin/maospix-resolve-airootfs"]="0:0:755"
  ["/usr/local/bin/maospix-prepare-kernel"]="0:0:755"
  ["/usr/local/bin/maospix-calamares-cleanup"]="0:0:755"
  ["/usr/local/bin/maospix-postboot"]="0:0:755"
)
