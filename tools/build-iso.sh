#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
repo_dir="$project_dir/repo/x86_64"
build_dir="$project_dir/build"
work_dir="$project_dir/work"
out_dir="$project_dir/out"
pacman_conf="$build_dir/pacman.conf"
owner_uid="$(id -u)"
owner_gid="$(id -g)"

restore_ownership() {
    # Recover the useful output first. A special file inside work/ must not
    # prevent ownership of the ISO from being restored.
    sudo chown -R "$owner_uid:$owner_gid" "$build_dir" "$out_dir" \
        2>/dev/null || true
    sudo chown -R "$owner_uid:$owner_gid" "$work_dir" 2>/dev/null || true
}
trap restore_ownership EXIT

command -v mkarchiso >/dev/null || { echo 'Falta mkarchiso (paquete archiso).' >&2; exit 1; }
test -r "$repo_dir/maospix.db.tar.gz" || {
    echo 'Primero ejecuta: ./tools/build-packages.sh' >&2
    exit 1
}

# mkarchiso saltea los pasos que ya tienen marca en work/: sin limpiar,
# una segunda compilación termina en segundos sin generar ISO nueva.
sudo rm -rf -- "${work_dir:?}"

mkdir -p "$build_dir" "$out_dir"
sed "s|@MAOSPIX_REPO@|file://$repo_dir|" \
    "$project_dir/archiso/pacman.conf.in" > "$pacman_conf"

grep -Fq "Server = file://$repo_dir" "$pacman_conf"

sudo mkarchiso -v -C "$pacman_conf" -w "$work_dir" -o "$out_dir" \
    "$project_dir/archiso"
