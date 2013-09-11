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


function jmversion() {
	#FIXME does not detect Betas and Alphas. Those are stored in $DEV_STATUS in version.php

	# Once again, Joomla, moving stuff around...*sigh*
	jm_old_version_file='libraries/joomla/version.php'
	jm_new_version_file='libraries/cms/version/version.php'

	#FIXME need to quiet any errors from fetching a file from the wrong version
	get_version_file "$jm_old_version_file" || get_version_file "$jm_new_version_file"

	jmver=$(awk -F\' 'BEGIN{ ORS="." } /\$RELEASE|\$DEV_LEVEL/{print $2} END{}' version.php)
	jmver=${jmver%.}

	echo $jmver

	# cleanup
	rm version.php
}

jmversion
