#!/bin/bash

# Detect which CMS a site is using and which version it is running

# SUPPORTED CMS: WordPress, Joomla

# REQUIREMENTS: lftp

function get_version_file() {
	lftp -c "$LFTP_GETFILE/$1"
}

function wpversion() {
	wp_version_file='wp-includes/version.php'
	get_version_file "$wp_version_file"

	awk -F\' '/^[:space:]*\$wp_version/{print $2}' version.php

	# cleanup
	rm version.php
}

function jmversion() {
	# Once again, Joomla, moving stuff around...*sigh*
	jm_old_version_file='libraries/joomla/version.php'
	jm_new_version_file='libraries/cms/version/version.php'

	#FIXME need to quiet any errors from fetching a file from the wrong version
	get_version_file "$jm_new_version_file" || get_version_file "$jm_old_version_file"

	jmver=$(awk -F\' 'BEGIN{ ORS="." } /\$RELEASE|\$DEV_LEVEL/{print $2}' version.php)
	jmver=${jmver%.}

	echo $jmver

	#cleanup
	rm version.php
}

function cmsver() {
	[ "$CMS" = 'WordPress' ] && VER=`wpversion`
	[ "$CMS" = 'Joomla' ]    && VER=`jmversion`
}

function detect_cms() {
	filelist=`lftp -c "$LFTP_FILELIST"`

	( echo $filelist | grep -Fq wp-config.php ) && CMS='WordPress'

	# FIXME configuration.php is kind of generic, but Joomla doesn't have any common # files between the 1.5 branch and the 2.5.X or 3.X branches. Otherwise we could # happily use the joomla.xml file which comes with the 2.5 and 3.X branches of Joomla
	# FIXME  egrep might not be necessary. None of my test Joomla 2.5/3.X sites had a configuration.php # I think they should, once the site is up and running, but my test sites were basically unzips of # the Joomla download and not an actual install.
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
LFTP_AUTOLOGIN="open $FTP_HOST -u $FTP_USER,$FTP_PASS"
LFTP_FILELIST="$LFTP_AUTOLOGIN;ls $FTP_PATH"
LFTP_GETFILE="$LFTP_AUTOLOGIN; get $FTP_PATH"

detect_cms
cmsver

echo $CMS $VER
