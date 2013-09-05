#!/bin/bash

# REQUIREMENTS: lftp

# TODO add error handling in case files can't be downloaded

# CONFIG
# TODO move these to command line switches
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
	#TODO may be good to reverse OLD/NEW version for performance reasons since site is most likely new Joomla (hopefully)
	get_version_file "$jm_old_version_file" || get_version_file "$jm_new_version_file"

	# TODO find the major/minor versions and combine from $RELEASE and $DEV_LEVEL from version.php
	jmver=$(awk -F\' 'BEGIN{ ORS="." } /\$RELEASE|\$DEV_LEVEL/{print $2} END{}' version.php)
	jmver=${jmver%.}

	echo $jmver

	# cleanup
	# FIXME need a TRAP to make sure cleanup goes successfully
	rm version.php
}

jmversion
