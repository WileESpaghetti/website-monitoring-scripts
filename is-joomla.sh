#!/bin/bash

# Verify whether or not this is actually a joomla install;

# CONFIG
FTP_HOST=''
FTP_USER=''
FTP_PASS=''
FTP_PATH=''

# lftp scripts
LFTP_AUTOLOGIN="open $FTP_HOST -u $FTP_USER,$FTP_PASS"
LFTP_FILELIST="$LFTP_AUTOLOGIN;ls $FTP_PATH"

filelist=`lftp -c "$LFTP_FILELIST"`
# FIXME configuration.php is kind of generic, but Joomla doesn't have any common # files between the 1.5 branch and the 2.5.X or 3.X branches. Otherwise we could # happily use the joomla.xml file which comes with the 2.5 and 3.X branches of Joomla
# FIXME egrep might not be necessary. None of my test Joomla 2.5/3.X sites had a configuration.php I think they should, once the site is up and running, but my test sites were basically unzips of # the Joomla download and not an actual install.
( echo $filelist | grep -Eq '(configuration\.php|joomla\.xml)' ) && CMS='Joomla'
