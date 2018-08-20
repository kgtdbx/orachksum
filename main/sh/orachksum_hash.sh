#!/bin/sh
# ----------------------------------------------------------------------------
# Written by Rodrigo Jorge <http://www.dbarj.com.br/>
# Last updated on: Dec/2016 by Rodrigo Jorge
# ----------------------------------------------------------------------------
set -e # Exit if error
if [ $# -ne 6 -a $# -ne 7 ]
then
  echo "$0: Six or Seven arguments are needed.. given: $#"
  exit 1
fi
#set -x

abortscript ()
{
    echo "$1"
	exit 1
}

v_chksdir="$1"
v_target="$2"
v_red_src="$3"
v_result="$4"
v_report="$5"
v_type="$6"
v_col_change="$7"

v_separator=','
v_enclosure='"'

SOTYPE=$(uname -s)
if [ "$SOTYPE" = "SunOS" ]
then
  AWKCMD=/usr/xpg4/bin/awk
  GREPCMD=/usr/xpg4/bin/grep
  TRCMD=/usr/xpg4/bin/tr
else
  AWKCMD=awk
  GREPCMD=grep
  TRCMD=tr
fi

v_type=$(echo "$v_type" | ${TRCMD} 'a-z' 'A-Z')
v_header=$(${GREPCMD} -e "^${v_type}:" "${v_chksdir}/sh/headers.txt" | ${AWKCMD} -F':' '{print $2}')

if [ "${v_header}" = "" ]
then
  v_header="HEADER ERROR"
fi

printf %s\\n "$-" | $GREPCMD -q -F 'x' && v_dbgflag='-x' || v_dbgflag='+x'

sh ${v_dbgflag} ${v_chksdir}/sh/compare_hash.sh "${v_chksdir}" "${v_target}" "${v_red_src}" "${v_result}" "${v_col_change}"

if [ -f "${v_result}" ]
then
  (echo ${v_header}; cat "${v_result}") > "${v_result}.2"
  mv "${v_result}.2" "${v_result}"
else
  echo ${v_header} > "${v_result}"
fi

v_total=$(cat "${v_target}" | wc -l | awk '{print $1}')
v_totdifs=$(cat "${v_result}" | wc -l | awk '{print $1}')
v_totdifs=$((v_totdifs-1)) #Remove Header
v_nomatch=$($GREPCMD -e '${v_separator}NO MATCH$' "${v_result}" | wc -l | awk '{print $1}')
v_notfound=$($GREPCMD -e '${v_separator}NOT FOUND$' "${v_result}" | wc -l | awk '{print $1}')
v_match=$((v_total-v_totdifs))

echo "# ${v_result} #"                  >> "${v_report}"
echo "Total = ${v_total}"               >> "${v_report}"
echo "Total Differences = ${v_totdifs}" >> "${v_report}"
echo "Match = ${v_match}"               >> "${v_report}"
echo "No Match = ${v_nomatch}"          >> "${v_report}"
echo "Not Found = ${v_notfound}"        >> "${v_report}"

exit 0
####