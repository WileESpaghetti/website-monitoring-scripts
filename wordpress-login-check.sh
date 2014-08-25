#!/bin/bash

# will also work in cygwin bash
#set -x
#wpuser='ardent'
#wppass='pav8c7xhwp'
#wpsite='www.playafc.com'
#wproot=/wordpress

# wordpress first checks if cookies enabled by placing a test cookie
curl --cookie-jar cookies.txt -silent --output "tmp.html" "http://$wpsite$wproot/wp-login.php"

# when logging on via the web page, after placing the test cookie wordpress will
# redirect to wp-login.php again and then actually process the credentials to set
# login cookies. This mimics the redirect.
curl --cookie-jar cookies.txt -silent --output "login.html" --max-redirs 0 --data "log=$wpuser&pwd=$wppass&rememberme=forever&redirect_to=http%3A%2F%2F$wpsite$wproot%2Fwp-admin%2F&testcookie=1&wp-submit=Log%20In" "http://$wpsite/wp-login.php"

# check for success entry in $COOKIEJAR
grep -Fiq wordpress_logged_in cookies.txt 2> /dev/null
LOGIN_SUCCESS=$?

# cleanup
rm cookies.txt tmp.html login.html 2> /dev/null

exit $LOGIN_SUCCESS
