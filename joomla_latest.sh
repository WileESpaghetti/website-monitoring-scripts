#!/bin/bash
VERSION_HISTORY_FILE='http://docs.joomla.org/Category:Version_History'
#SERIES_HISTORY='http://docs.joomla.org/Joomla_$SERIES_version_history'

function list_series() {
	lynx -dump $VERSION_HISTORY_FILE | awk '/version history[ \t]*$/{print $3}'
}

function list_lts() {
	list_series | grep -F '.5'
}

function latest_lts() {
	list_lts | tail -n 1
}

function latest_series() {
	list_series | tail -n 1
}

function latest_version_of() {
	# $1 = series
	series_version_file="http://docs.joomla.org/Joomla_$1_version_history"

	# regex parts
	digit='[0-9]\{1,\}'
	before='.*Joomla\![ \t]*'
	after='<.*'
	version="\($digit\.$digit\(\.$digit\)*\)"

	lynx -source $series_version_file | sed -n "/toctext/s/$before$version$after/\1/p" | head -n 1
}

LTS=`latest_lts`
JMLATEST=`latest_series`
echo Latest LTS: `latest_version_of $LTS`
echo Latest Joomla: `latest_version_of $JMLATEST`
