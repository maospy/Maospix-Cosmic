#!/usr/bin/env bash
# Prepara el repositorio local [maospix] que usa la ISO.
# Uso: ./tools/build-packages.sh   (solo construye lo que falte en repo/)
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
repo_dir="$project_dir/repo/x86_64"
aur_dir="$project_dir/build/aur"
propios=(maospix-cosmic-settings maospix-plymouth-theme calamares ckbcomp brave-bin)
aur=(paru-bin yay-bin shelly-bin onlyoffice-bin cliamp-bin herdr-bin)

for cmd in makepkg repo-add git; do
    command -v "$cmd" >/dev/null || { echo "Falta $cmd (grupo base-devel o git)." >&2; exit 1; }
done
mkdir -p "$repo_dir" "$aur_dir"

# construir NOMBRE CARPETA: lo salta si el repo ya tiene alguna versión.
# maospix-cosmic-settings se compara por versión exacta.
construir() {
    local nombre="$1" carpeta="$2" lista f falta=false
    local opciones=(--cleanbuild --syncdeps --needed --force)
    # Estos dos solo copian archivos: sus dependencias son del sistema de destino.
    case "$nombre" in maospix-*) opciones=(--cleanbuild --nodeps --force) ;; esac

    if [[ "$nombre" == maospix-cosmic-settings ]]; then
        lista="$(cd "$carpeta" && makepkg --packagelist)"
        while read -r f; do [[ "$f" == *-debug-* || -e "$repo_dir/$(basename "$f")" ]] || falta=true; done <<<"$lista"
    else
        compgen -G "$repo_dir/$nombre-[0-9]*.pkg.tar.zst" >/dev/null || falta=true
    fi
    if [[ "$falta" == false ]]; then echo "==> Ya está: $nombre"; return; fi

    echo "==> Construyendo $nombre"
    (cd "$carpeta" && makepkg "${opciones[@]}")
    if [[ "$nombre" == maospix-cosmic-settings ]]; then
        rm -f "$repo_dir/$nombre"-[0-9]*.pkg.tar.zst
    fi
    while read -r f; do
        # los paquetes de depuración no van en la ISO
        if [[ -e "$f" && "$f" != *-debug-* ]]; then cp -f "$f" "$repo_dir/"; fi
    done < <(cd "$carpeta" && makepkg --packagelist)
}

for nombre in "${propios[@]}"; do construir "$nombre" "$project_dir/packages/$nombre"; done
for nombre in "${aur[@]}"; do
    if compgen -G "$repo_dir/$nombre-[0-9]*.pkg.tar.zst" >/dev/null; then echo "==> Ya está: $nombre"; continue; fi
    [[ -d "$aur_dir/$nombre" ]] || git clone "https://aur.archlinux.org/$nombre.git" "$aur_dir/$nombre"
    construir "$nombre" "$aur_dir/$nombre"
done

rm -f "$repo_dir"/maospix.db* "$repo_dir"/maospix.files*
repo-add -q -R "$repo_dir/maospix.db.tar.gz" "$repo_dir"/*.pkg.tar.zst
echo "Repositorio local preparado en: $repo_dir"
