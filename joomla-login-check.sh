#!/bin/bash

# useful for making sure documented passwords are still up to date
#TODO either convert this to curl or port the wordpress login check to wget to keep consistant

# CONFIG
jmuser=''
jmpass=''
jmsite=''
jmroot='' # optional
jmurl="http://$jmsite$jmroot/administrator"

# make wget commands look prettier
COOKIEJAR='cookies.txt'
WGET_COOKIES="--load-cookies $COOKIEJAR --save-cookies $COOKIEJAR --keep-session-cookies"
WGET_OPTIONS="-q $WGET_COOKIES"

# get the session token from the login form
jmtoke=`wget $WGET_OPTIONS -O - "$jmurl" | sed -n 's/.*\([0-9a-zA-Z]\{32\}\).*/\1/p'`

# Joomla login form data
USER="username=$jmuser"
PASS="passwd=$jmpass"
TOKE="$jmtoke=1"
OPTION="option=com_login"
TASK="task=login"

# detect bad token or if we get sent back to the login page
wget $WGET_OPTIONS --post-data="$USER&$PASS&$OPTION&$TASK&$TOKE" "$jmurl/index.php?option=com_login" -O - | egrep -qi '(Invalid Token|id="form-login")'

#FIXME if the $live_site is not set up correctly in configuration.php it can cause false negative login.
#      EXAMPLE: if $live_site="example.com" and we try to log on using www.example.com any attempt to log in
#      will redirect the login script to example.com/administrator which will have a different cookie token
#      causing the script to fail

# fail if bad token or login form detected.
# Kinda hackish, suggestions welcome
[ $? -ne 0 ]
LOGIN_SUCCESS=$?

# cleanup
rm $COOKIEJAR

exit $LOGIN_SUCCESS
