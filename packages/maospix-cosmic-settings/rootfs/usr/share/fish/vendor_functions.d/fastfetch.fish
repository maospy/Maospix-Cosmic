# MAOSPIX-COSMIC: fastfetch con el logo de MAOSPIX según la terminal.
# - Kitty (PCs reales): imagen PNG con el protocolo de Kitty.
# - Foot (máquinas virtuales): la misma imagen en sixel.
# - SSH, TTY u otra terminal: logo de texto (braille a color).
# Si se pasa un logo propio (-l/--logo...), se respeta.
function fastfetch --wraps fastfetch --description 'fastfetch con logo MAOSPIX'
    set -l dir /usr/share/maospix-cosmic/fastfetch
    for a in $argv
        if string match -qr -- '^(-l|--logo)' $a
            command fastfetch $argv
            return
        end
    end
    if set -q KITTY_WINDOW_ID; and not set -q SSH_CONNECTION
        command fastfetch --logo-type kitty-direct --logo $dir/logo.png \
            --logo-width 40 --logo-height 20 $argv
    else if test "$MAOSPIX_TERM" = foot; and not set -q SSH_CONNECTION
        command fastfetch --logo-type sixel --logo $dir/logo-sixel.png \
            --logo-width 40 --logo-height 20 $argv
    else if test "$TERM" = linux
        command fastfetch $argv
    else
        command fastfetch --logo-type file-raw --logo $dir/logo.ansi $argv
    end
end
