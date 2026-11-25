#!/usr/bin/env bash
# Verifica la última ISO construida y guarda su SHA-256.
# Uso: ./tools/verificar-iso.sh
set -uo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
root="${ROOT:-$project_dir/work/x86_64/airootfs}"
iso="$(ls -t "$project_dir"/out/*.iso 2>/dev/null | head -1)"
fallos=0

ok() { echo "  OK    $1"; }
falla() { echo "  FALLA $1"; fallos=$((fallos + 1)); }
# existe RUTA: está en el sistema de la ISO
existe() { if [[ -e "$root/$1" || -L "$root/$1" ]]; then ok "$1"; else falla "falta $1"; fi; }
# contiene TEXTO RUTA DESCRIPCIÓN: el archivo tiene ese texto
contiene() { if grep -qF -- "$1" "$root/$2" 2>/dev/null; then ok "$3"; else falla "$3"; fi; }

[[ -n "$iso" ]] || { echo "No hay ISO en out/"; exit 1; }
[[ -d "$root" ]] || { echo "No existe $root"; exit 1; }
echo "ISO: $(basename "$iso")  ($(du -h "$iso" | cut -f1), $(date -r "$iso" '+%d/%m %H:%M'))"

echo "Identidad:"
contiene 'NAME="MAOSPIX-COSMIC"' usr/lib/os-release "os-release MAOSPIX-COSMIC"
existe usr/share/maospix-cosmic/fastfetch/logo.png
existe usr/share/fish/vendor_functions.d/fastfetch.fish
contiene maospix-cosmic-neon.png usr/local/share/cosmic/com.system76.CosmicBackground/v1/all \
    "fondo neon por defecto (greeter)"
existe usr/share/backgrounds/maospix-cosmic/maospix-cosmic-neon.png
panel=etc/skel/.config/cosmic/com.system76.CosmicPanel
contiene false "$panel.Panel/v1/expand_to_edges" "barra flotante"
contiene 0.0 "$panel.Dock/v1/opacity" "dock transparente"

echo "Aplicaciones:"
for p in kitty fish fastfetch brave loupe calamares cosmic-session cosmic-greeter; do existe "usr/bin/$p"; done
existe usr/share/applications/org.gnome.Loupe.desktop
contiene image/png=org.gnome.Loupe.desktop etc/xdg/cosmic-mimeapps.list "Loupe abre las imágenes"
contiene LIBGL_ALWAYS_SOFTWARE usr/local/bin/kitty "kitty en VirtualBox"
contiene GSK_RENDERER usr/share/fish/vendor_conf.d/maospix-vm.fish "GTK4 en VirtualBox"
contiene pam_gnome_keyring.so etc/pam.d/login "llavero en el login"

echo "Instalador y región:"
existe etc/calamares/settings.conf
existe usr/local/bin/maospix-installer
existe usr/local/share/applications/maospix-installer.desktop
existe usr/lib/libKF6Crash.so.6
contiene LANG=es_PY.UTF-8 etc/locale.conf "idioma es_PY"
if [[ "$(readlink "$root/etc/localtime")" == */America/Asuncion ]]; then
    ok "zona horaria America/Asuncion"; else falla "zona horaria"; fi

# Bibliotecas que falten (así falló Calamares en la P1)
cargador="$root/usr/lib/ld-linux-x86-64.so.2"
# Lo que falta en la ISO, el cargador lo toma de esta PC: cada ruta de afuera
# tiene que existir también adentro de la ISO.
faltan() {
    "$cargador" --inhibit-cache --library-path "$root/usr/lib" --list "$1" 2>&1 |
        {
            mal=1
            while read -r lib flecha ruta _; do
                case "$lib $flecha $ruta" in
                    *"not found"*|*"error while"*) echo "    $lib"; mal=0 ;;
                    *" => /"*) [[ "$ruta" == "$root"/* || -e "$root$ruta" ]] || { echo "    $lib"; mal=0; } ;;
                esac
            done
            exit $mal
        }
}
for p in calamares loupe; do
    if [[ ! -e "$root/usr/bin/$p" ]]; then continue; fi
    if f="$(faltan "$root/usr/bin/$p")"; then falla "$p: bibliotecas faltantes"; echo "$f"; else ok "$p: bibliotecas completas"; fi
done
modulos_mal=0
for m in "$root"/usr/lib/calamares/modules/*/*.so; do
    # solo los que usa nuestra secuencia (plasmalnf, por ejemplo, no se usa)
    grep -qE "^ *- $(basename "$(dirname "$m")")(@|\$)" "$root/etc/calamares/settings.conf" || continue
    if f="$(faltan "$m")"; then echo "$(basename "$m"): $f"; modulos_mal=1; fi
done
if ((modulos_mal)); then falla "módulos de Calamares"; else ok "módulos de Calamares"; fi

if ((fallos)); then
    echo "Resultado: $fallos fallo(s). No se guarda el SHA-256."
    exit 1
fi
cd "$(dirname "$iso")" || exit 1
sha256sum "$(basename "$iso")" | tee "$(basename "$iso").sha256"
echo "Resultado: todo bien."
