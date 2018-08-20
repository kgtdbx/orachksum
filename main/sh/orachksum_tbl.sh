#!/bin/sh
# ----------------------------------------------------------------------------
# Written by Rodrigo Jorge <http://www.dbarj.com.br/>
# Last updated on: Dec/2016 by Rodrigo Jorge
# ----------------------------------------------------------------------------
set -e # Exit if error. Never remove it.
if [ $# -ne 8 -a $# -ne 9 ]
then
  echo "$0: Eight or nine arguments are needed.. given: $#"
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
v_reverse="$7"
v_version_file="$8"
v_col_change="$9"

AWKCMD_P="-f ${v_chksdir}/sh/csv-parser.awk -v separator=, -v enclosure=\""

SOTYPE=$(uname -s)
if [ "$SOTYPE" = "SunOS" ]
then
  AWKCMD=gawk
  AWKCMD_CSV="${AWKCMD} ${AWKCMD_P}"
  GREPCMD=/usr/xpg4/bin/grep
  TRCMD=/usr/xpg4/bin/tr
  TAILCMD=/usr/xpg4/bin/tail
else
  AWKCMD=awk
  AWKCMD_CSV="${AWKCMD} ${AWKCMD_P}"
  GREPCMD=grep
  TRCMD=tr
  TAILCMD=tail
fi

if [ ! -f "${v_target}" ]
then
  abortscript "${v_target} not found."
fi

if [ ! -f "${v_red_src}" ]
then
  abortscript "${v_red_src} not found."
fi

v_type=$(echo "$v_type" | ${TRCMD} 'a-z' 'A-Z')
v_header=$(${GREPCMD} -e "^${v_type}:" "${v_chksdir}/sh/headers.txt" | ${AWKCMD} -F':' '{print $2}')

if [ "${v_header}" = "" ]
then
  v_header="HEADER ERROR"
  v_common_col="NO"
else
  v_common_col=$(echo "$v_header" | ${AWKCMD_CSV} --source '{a=csv_parse_record($0, separator, enclosure, csv); print csv[a-2]}')
  [ "${v_common_col}" = "COMMON" ] && v_common_col="YES" || v_common_col="NO"
fi

v_pdbs=$(${TAILCMD} -n 1 ${v_version_file})

printf %s\\n "$-" | $GREPCMD -q -F 'x' && v_dbgflag='-x' || v_dbgflag='+x'

sh ${v_dbgflag} ${v_chksdir}/sh/compare_tbl.sh "${v_chksdir}" "${v_target}" "${v_red_src}" "${v_result}" "${v_reverse}" "${v_common_col}" "${v_pdbs}" "${v_col_change}"

if [ -f "${v_result}" ]
then
  (echo ${v_header}; cat "${v_result}") > "${v_result}.2"
  mv "${v_result}.2" "${v_result}"
else
  echo ${v_header} > "${v_result}"
fi

if [ "${v_reverse}" = "NO" ]
then
  v_total=$(cat "${v_target}" | wc -l | ${AWKCMD} '{print $1}')
else
  v_total=$(cat "${v_red_src}" | wc -l | ${AWKCMD} '{print $1}')
fi

v_totdifs=$(cat "${v_result}" | wc -l | ${AWKCMD} '{print $1}')
v_totdifs=$((v_totdifs-1)) #Remove Header
v_match=$((v_total-v_totdifs))

echo "# ${v_result} #"                  >> "${v_report}"
echo "Total = ${v_total}"               >> "${v_report}"
echo "Total Differences = ${v_totdifs}" >> "${v_report}"
echo "Match = ${v_match}"               >> "${v_report}"

exit 0
####