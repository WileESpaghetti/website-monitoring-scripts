#!/bin/bash

# Verify whether or not this is actually a wordpress install;
# FIXME add trap to cleanup

# CONFIG
# TODO move these to command line switches
FTP_HOST=''
FTP_USER=''
FTP_PASS=''
FTP_PATH=''

# lftp scripts
LFTP_AUTOLOGIN="open $FTP_HOST -u $FTP_USER,$FTP_PASS"
LFTP_FILELIST="$LFTP_AUTOLOGIN;ls $FTP_PATH"

filelist=`lftp -c "$LFTP_FILELIST"`
( echo $filelist | grep -Fq wp-config.php ) || exit 1
