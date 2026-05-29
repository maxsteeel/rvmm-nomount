#!/system/bin/sh

until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done
until [ -d "/sdcard/Android" ]; do sleep 1; done
sleep 5

MODDIR=${0%/*}
. "$MODDIR/util.sh"

if ! command -v nm >/dev/null 2>&1; then
    alias nm='/data/adb/modules/nomount/bin/nm'
fi

collect_rvmm | while IFS= read -r rvmm_path; do
    . "$rvmm_path/config"
    if [ -z "$PKG_NAME" ]; then continue; fi

    BASEPATH=$(pm path "$PKG_NAME" 2>&1 </dev/null)
    if [ $? != 0 ] || [ -z "$BASEPATH" ]; then
        set_rvmm_desc "$rvmm_path" "Needs reflash: app not installed"
        continue
    fi

    BASEPATH=${BASEPATH##*:}
    BASEDIR=${BASEPATH%/*}

    if [ ! -d "$BASEDIR/lib" ]; then
        set_rvmm_desc "$rvmm_path" "Injection failed: corrupted base app"
        continue
    fi

    VERSION=$(dumpsys package "$PKG_NAME" 2>&1 | grep -m1 versionName)
    VERSION="${VERSION#*=}"
    if [ "$VERSION" != "$PKG_VER" ] && [ -n "$VERSION" ]; then
        set_rvmm_desc "$rvmm_path" "Needs reflash: version mismatch (installed:${VERSION}, module:$PKG_VER)"
        continue
    fi

    RVPATH="/data/adb/rvhc/${rvmm_path##*/}.apk"
    if ! chcon u:object_r:apk_data_file:s0 "$RVPATH"; then
        set_rvmm_desc "$rvmm_path" "Needs reflash: apk not found"
        continue
    fi

    am force-stop "$PKG_NAME"
    nm add "$BASEPATH" "$RVPATH"
    set_rvmm_desc "$rvmm_path" "Keep disabled. Injected natively via NoMount."

done
