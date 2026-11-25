# MAOSPIX-COSMIC: fastfetch con el logo MAOSPIX al abrir una terminal gráfica.
if status is-interactive; and not set -q SSH_CONNECTION; and test "$TERM" != linux
    set -g fish_greeting
    fastfetch
end
