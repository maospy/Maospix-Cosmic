# MAOSPIX: ver /usr/share/fish/vendor_conf.d/maospix-vm.fish
if [ "$(systemd-detect-virt 2>/dev/null)" = "oracle" ]; then
    export GSK_RENDERER=cairo
fi
