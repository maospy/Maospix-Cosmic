# MAOSPIX: en VirtualBox con 3D las apps GTK4 (Shelly) salen vacías.
# El renderer cairo las dibuja bien; en hardware real no se toca nada.
if test (systemd-detect-virt 2>/dev/null) = oracle
    set -gx GSK_RENDERER cairo
end
