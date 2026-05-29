#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/util.sh"

collect_rvmm | while IFS= read -r rvmm_path; do
    : >"$rvmm_path/disable"
    set_rvmm_desc "$rvmm_path" "Keep disabled. Injected natively via NoMount."
done
