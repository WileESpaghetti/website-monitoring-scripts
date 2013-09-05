#!/bin/bash

# Detect which CMS a site is using and which version it is running

# SUPPORTED CMS: WordPress, Joomla

# REQUIREMENTS: lftp

#FIXME need to check to make sure this works on dev/beta releases and repository checkouts
#FIXME need to check ancient versions of WordPress (1.X, 2.X, 3.X)
#FIXME need to make sure the joomla series are correct (ex. is it 3.X or 3.1.X branch)
#FIXME fix formatting: try to make sure lines stay within 80 character limit
#FIXME fix formatting: standardize on quotes (single quotes unless necessary to be double or backquotes


function get_version_file() {
	lftp -c "$LFTP_GETFILE/$1"
}

function wpversion() {
	wp_version_file='wp-includes/version.php'
	get_version_file "$wp_version_file"

	awk -F\' '/^[:space:]*\$wp_version/{print $2}' version.php

	# cleanup
	# FIXME need a TRAP to make sure cleanup goes successfully
	rm version.php
}

function jmversion() {
	# Once again, Joomla, moving stuff around...*sigh*
	jm_old_version_file='libraries/joomla/version.php'
	jm_new_version_file='libraries/cms/version/version.php'

	#FIXME need to quiet any errors from fetching a file from the wrong version
	#TODO may be good to reverse OLD/NEW version for performance reasons since site is most likely new Joomla (hopefully)
	get_version_file "$jm_old_version_file" || get_version_file "$jm_new_version_file"

	# TODO find the major/minor versions and combine from $RELEASE and $DEV_LEVEL from version.php
	jmver=$(awk -F\' 'BEGIN{ ORS="." } /\$RELEASE|\$DEV_LEVEL/{print $2}' version.php)
	jmver=${jmver%.}

	echo $jmver

	#cleanup
	# FIXME need a TRAP to make sure cleanup goes successfully
	rm version.php
}

function cmsver() {
	#FIXME not sure if VER could ever get accidently overwritten
	[ "$CMS" = 'WordPress' ] && VER=`wpversion`
	[ "$CMS" = 'Joomla' ]    && VER=`jmversion`
}

function detect_cms() {
	filelist=`lftp -c "$LFTP_FILELIST"`

	( echo $filelist | grep -Fq wp-config.php ) && CMS='WordPress'

	# FIXME: configuration.php is kind of generic, but Joomla doesn't have any common # files between the 1.5 branch and the 2.5.X or 3.X branches. Otherwise we could # happily use the joomla.xml file which comes with the 2.5 and 3.X branches of Joomla
	# FIXME egrep might not be necessary. None of my test Joomla 2.5/3.X sites had a configuration.php # I think they should, once the site is up and running, but my test sites were basically unzips of # the Joomla download and not an actual install.
	( echo $filelist | grep -Eq '(configuration\.php|joomla\.xml)' ) && CMS='Joomla'
}

while getopts h:d:p:u: options
do
	case $options in
		h) FTP_HOST=$OPTARG;;
		u) FTP_USER=$OPTARG;;
		p) FTP_PASS=$OPTARG;;
		d) FTP_PATH=$OPTARG;;
	esac
done

# lftp scripts
# TODO add an extra LFTP_OPTS for custom configs that might be needed
LFTP_AUTOLOGIN="open $FTP_HOST -u $FTP_USER,$FTP_PASS"
LFTP_FILELIST="$LFTP_AUTOLOGIN;ls $FTP_PATH"
LFTP_GETFILE="$LFTP_AUTOLOGIN; get $FTP_PATH"

detect_cms
cmsver

echo $CMS $VER
