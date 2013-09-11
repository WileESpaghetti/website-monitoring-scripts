#!/bin/bash

# will also work in cygwin bash

wppass=password
wplogin=username
site=www.example.com
wproot=/wordpress

# wordpress first checks if cookies enabled by placing a test cookie
curl --cookie-jar cookies.txt --output "tmp.html" "http://$site$wproot/wp-login.php"

# when logging on via the web page, after placing the test cookie wordpress will
# redirect to wp-login.php again and then actually process the credentials to set
# login cookies. This mimics the redirect.
curl --cookie-jar cookies.txt --output "login.html" --max-redirs 0 --data "log=$wpuser&pwd=$wppass&rememberme=forever&redirect_to=http%3A%2F%2F$site$wproot%2Fwp-admin%2F&testcookie=1&wp-submit=Log%20In" "http://$site/wp-login.php"


# if successful, the cookies.txt file should have:
# 3 line comment from curl
# 1 blank line
# 1 line for the test cookie
# other lines if wordpress authenticates
[ `wc -l cookies.txt | cut -d ' ' -f1` -gt 5 ]
