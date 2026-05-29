#!/system/bin/sh

is_valid_rvmm() {
    if [ ! -d "$1" ]; then return 1; fi
    if ! grep -Fq "j-hc" "$1/module.prop"; then return 1; fi
    if [ ! -f "$1/config" ]; then return 1; fi
    return 0
}

collect_rvmm() {
    for RVMM in /data/adb/modules/*-jhc*; do
        if ! is_valid_rvmm "$RVMM"; then continue; fi
        if [ -f "$RVMM/remove" ]; then continue; fi
        echo "$RVMM"
    done
}

set_rvmm_desc() {
    local path="$1"
    local msg="$2"
    [ ! -f "$path/err" ] && cp -f "$path/module.prop" "$path/err"
    sed -i "s/^des.*/description=⚠️ ${msg}/g" "$path/module.prop"
}
