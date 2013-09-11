#!/bin/bash

# REQUIREMENTS: lftp

# CONFIG
FTP_HOST=''
FTP_USER=''
FTP_PASS=''
FTP_PATH=''

# lftp scripts
LFTP_AUTOLOGIN="open $FTP_HOST -u $FTP_USER,$FTP_PASS"
LFTP_FILELIST="$LFTP_AUTOLOGIN;ls $FTP_PATH"
LFTP_GETFILE="$LFTP_AUTOLOGIN; get $FTP_PATH"

function get_version_file() {
	lftp -c "$LFTP_GETFILE/$1"
}

function wpversion() {
	wp_version_file="wp-includes/version.php"
	get_version_file "$wp_version_file"

	awk -F\' '/^[:space:]*\$wp_version/{print $2}' version.php

	# cleanup
	rm version.php
}

wpversion
