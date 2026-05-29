#!/system/bin/sh

# Setup variables
NM_BIN="/data/adb/modules/nomount/bin/nm"
RVMM_NOMOUNT_DIR="/data/adb/modules/rvmm-nomount"

ui_print "- Checking NoMount dependencies..."

# Verify if the NoMount binary is installed in the expected path
if [ ! -f "$NM_BIN" ]; then
    ui_print "! Error: NoMount binary not found at $NM_BIN"
    ui_print "! Please install the NoMount module first."
    abort ""
fi

# Test if the NoMount kernel module is loaded and responding
if ! "$NM_BIN" v >/dev/null 2>&1; then
    ui_print "! Error: NoMount binary execution failed."
    ui_print "! Is the kernel module properly compiled and loaded?"
    abort ""
fi

ui_print "- NoMount is installed and active."

# Load utility functions
. "$MODPATH/util.sh"

# Abort if no ReVanced modules are found on the system
if [ -z "$(collect_rvmm)" ]; then
    ui_print "! No revanced-magisk-module is installed."
    ui_print "  Go install the modules you want first,"
    ui_print "  then flash this module."
    abort ""
fi

# Set proper execution permissions for our background scripts
chmod +x "$MODPATH/service.sh"
chmod +x "$MODPATH/post-fs-data.sh"

# Create a convenient shortcut for Termux users to manually re-trigger injections
REAPPLY=/data/data/com.termux/files/usr/bin/
if [ -d "$REAPPLY" ]; then
    echo "su -c 'MODDIR=$MODPATH $RVMM_NOMOUNT_DIR/service.sh'; echo Done.;" >"$REAPPLY/rvmm-nomount"
    chmod 777 "$REAPPLY/rvmm-nomount"
fi

ui_print "- Done"
ui_print "  by maxsteeel (github.com/maxsteeel)"
