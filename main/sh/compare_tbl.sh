#!/bin/sh
# ----------------------------------------------------------------------------
# Written by Rodrigo Jorge <http://www.dbarj.com.br/>
# Last updated on: Dec/2016 by Rodrigo Jorge
# ----------------------------------------------------------------------------
if [ $# -ne 7 -a $# -ne 8 ]
then
  echo "$0: Seven or Eight arguments are needed.. given: $#"
  exit 1
fi

abortscript ()
{
    echo "$1"
	exit 1
}

v_chksdir="$1"
v_dbcsv="$2"
v_origcsv="$3"
v_outfile="$4"
v_reverse="$5"
v_has_common_col="$6"
v_list_pdbs="$7"
v_col_change="$8"

v_separator=','
v_enclosure='"'

AWKCMD_P="-f ${v_chksdir}/sh/csv-parser.awk -v separator=${v_separator} -v enclosure=${v_enclosure}"

SOTYPE=$(uname -s)
if [ "${SOTYPE}" = "SunOS" ]
then
  AWKCMD=gawk
  AWKCMD_CSV="${AWKCMD} ${AWKCMD_P}"
  GREPCMD=/usr/xpg4/bin/grep
  SEDCMD=/usr/xpg4/bin/sed
  ECHOCMD=/usr/gnu/bin/echo
else
  AWKCMD=awk
  AWKCMD_CSV="${AWKCMD} ${AWKCMD_P}"
  GREPCMD=grep
  SEDCMD=sed
  ECHOCMD=echo
fi

### Escape REGEX patterns of param
ere_quote() {
  ${SEDCMD} 's/[]\.|$(){}?+*^]/\\&/g' <<< "$*"
}

exit_not_number() {
  re='^[0-9]+$'
  if ! [[ $1 =~ $re ]] ; then
     abortscript "con_id is not a number. Found: $1"
  fi
}

progressbar ()
{
 str="#"
 maxhashes=24
 perc=$1
 numhashes=$(( ( $perc * $maxhashes ) / 100 ))
 numspaces=$(( $maxhashes - $numhashes ))
 phash=$(printf "%-${numhashes}s" "$str")
 [ $numhashes -eq 0 ] && phash="" || true
 pspace=$(printf "%-${numspaces}s" " ")
 [ $numspaces -eq 0 ] && pspace="" || true
 ${ECHOCMD} -ne "${phash// /$str}${pspace}   (${perc}%)\r" > /dev/tty
 [ $perc -eq 100 ] && ${ECHOCMD} -ne "${phash//$str/ }         \r" > /dev/tty || true
}

printpercentage ()
{
 perc=$(( ( $curline * 100 ) / $totline ))
 [ $perc -ne $perc_b4 ] && progressbar $perc || true
 perc_b4=$perc
 curline=$(( $curline + 1 ))
}

v_tot_fld=$(echo "${v_col_change}" | ${AWKCMD} -F';' '{print NF}')

remake_colchange ()
{
  v_in_str="$1"
  v_in_number=$2
  v_out_str=""
  v_fld_rep=1
  while [ $v_fld_rep -le $v_tot_fld ]
  do
    read v_col_1 v_col_2 <<< $(echo "${v_in_str}" | ${AWKCMD} -F';' '{print $'${v_fld_rep}'}' | ${AWKCMD} -F',' '{print $1, $2}')
    [ ${v_col_1} -gt ${v_in_number} ] && v_col_1=$((v_col_1-1))
    [ ${v_col_2} -gt ${v_in_number} ] && v_col_2=$((v_col_2-1))
    v_out_str="${v_out_str}${v_col_1},${v_col_2};"
    v_fld_rep=$((v_fld_rep+1))
  done
  v_out_str=$(echo "${v_out_str}" | sed 's/.$//')
  echo "$v_out_str"
}

check_colchange ()
{
  v_fld_rep=1
  while [ $v_fld_rep -le $v_tot_fld ]
  do
    read v_col_1 v_col_2 <<< $(echo "${v_col_change}" | ${AWKCMD} -F';' '{print $'${v_fld_rep}'}' | ${AWKCMD} -F',' '{print $1, $2}')
    [ "${v_col_1}" -eq "${v_col_1}" ] 2>/dev/null || abortscript "v_col_change error. Found ${v_col_1}"
    [ "${v_col_2}" -eq "${v_col_2}" ] 2>/dev/null || abortscript "v_col_change error. Found ${v_col_2}"
    v_fld_rep=$((v_fld_rep+1))
  done
}

check_colchange

if [ "${v_reverse}" = "NO" ]
then
  v_file_priv="${v_dbcsv}"
  v_file_base="${v_origcsv}"
elif [ "${v_reverse}" = "YES" ]
then
  v_file_priv="${v_origcsv}"
  v_file_base="${v_dbcsv}"
else
  abortscript "v_reverse should be YES or NO. Found: ${v_reverse}"
fi

if [ "${v_has_common_col}" != "YES" -a "${v_has_common_col}" != "NO" ]
then
  abortscript "v_has_common_col should be YES or NO. Found: ${v_has_common_col}"
fi

if [ ! -s "${v_file_priv}" ]
then
  exit 0
fi

v_skip_check=false
if [ ! -s "${v_file_base}" ]
then
  v_file_base=/dev/null
  v_skip_check=true
fi

v_file_priv_fields=$(head -n 1 "${v_file_priv}" | ${AWKCMD_CSV} --source '{a=csv_parse_record($0, separator, enclosure, csv); print a}')
v_file_base_fields=$(head -n 1 "${v_file_base}" | ${AWKCMD_CSV} --source '{a=csv_parse_record($0, separator, enclosure, csv); print a}')

## If no change on columns, number of columns must match
if [ -z "${v_col_change}" -a "${v_file_priv_fields}" != "${v_file_base_fields}" ]
then
  ${v_skip_check} || abortscript "Number of columns must match. ${v_file_priv_fields} and ${v_file_base_fields}."
fi

## If change on columns, number of columns must have 1 diff
if [ -n "${v_col_change}" -a "${v_file_priv_fields}" != "$((v_file_base_fields + v_tot_fld))" ]
then
  ${v_skip_check} || abortscript "Number of columns must match. ${v_file_priv_fields} and $((v_file_base_fields + 1))."
fi

rm -f ${v_outfile}

#####################################

addline ()
{
  echo "${line_print}" >> ${v_outfile}
}

def_line_comp_n_check ()
{
  c_con_id_comp1=${c_con_id}
  [ -n "${c_con_id}" ] && { test ${c_con_id} -eq 0 && c_con_id_comp1=1; } # For non CDBs, look for CON_ID 1
  [ -n "${c_con_id}" ] && { test ${c_con_id} -gt 3 && c_con_id_comp1=3; } # For any other PDB, compare with CON_ID 3 in template
  line_comp1="${line_base0}${v_separator}${c_con_id_comp1}"
  c_con_id_comp2=0 # 0 = any container / also match any container
  line_comp2="${line_base0}${v_separator}${c_con_id_comp2}"
  ${GREPCMD} -q -Fx "${line_comp1}" "${v_file_base}"; ret=$?
  [ ${ret} -ne 0 ] && { ${GREPCMD} -q -Fx "${line_comp2}" "${v_file_base}"; ret=$?; }
}

scan_conids ()
{
  line_print="${line_out0}${v_separator}${c_con_id}"
  def_line_comp_n_check
  if [ ${ret} -ne 0 ]
  then # If Non-CDB, check for diff c_common value.
    if [ -n "${c_con_id}" ] && [ ${c_con_id} -eq 0 -a "${v_has_common_col}" = "YES" ] && [ "${c_common}" = "YES" -o "${c_common}" = "NO" ]
    then
      [ "${c_common}" = "YES" ] && c_common_n="NO" || c_common_n="YES"
      line_base0=$(echo "${line_base0}" | ${SEDCMD} "s|${c_common}$|${c_common_n}|g") # This will not work if last attribute is not "c_common"
      def_line_comp_n_check
      [ ${ret} -ne 0 ] && addline
    else
      addline
    fi
  fi
}

scan_conids_reverse ()
{
  if [ -n "${c_con_id}" ] && [ ${c_con_id} -eq 0 ]
  then
    for t_con_id in "${dist_con_ids[@]}"
    do
      line_print="${line_out0}${v_separator}${t_con_id}"
      line_comp1="${line_base0}${v_separator}${t_con_id}"
      ${GREPCMD} -q -Fx "${line_comp1}" "${v_file_base}"; ret=$?
      if [ ${ret} -ne 0 ]
      then # If Non-CDB, check for diff c_common value. If t_con_id is 0, there won't be any other. Thus I can change the c_common.
        if [ ${t_con_id} -eq 0 -a "${v_has_common_col}" = "YES" ] && [ "${c_common}" = "YES" -o "${c_common}" = "NO" ]
        then
          [ "${c_common}" = "YES" ] && c_common_n="NO" || c_common_n="YES"
          line_base0=$(echo "${line_base0}" | ${SEDCMD} "s|${c_common}$|${c_common_n}|g") # This will not work if last attribute is not "c_common"
          line_comp1="${line_base0}${v_separator}${t_con_id}"
          ${GREPCMD} -q -Fx "${line_comp1}" "${v_file_base}"; ret=$?
          [ ${ret} -ne 0 ] && addline
        else
          addline
        fi
      fi
    done
  elif [ -n "${c_con_id}" ] && [ ${c_con_id} -eq 1 ]
  then
    for t_con_id in "${dist_con_ids[@]}"
    do
      if [ ${t_con_id} -eq 0 -o ${t_con_id} -eq 1 ]
      then
        line_print="${line_out0}${v_separator}${t_con_id}"
        line_comp1="${line_base0}${v_separator}${t_con_id}"
        ${GREPCMD} -q -Fx "${line_comp1}" "${v_file_base}"; ret=$?
        [ ${ret} -ne 0 ] && addline
      fi
    done
  elif [ -n "${c_con_id}" ] && [ ${c_con_id} -eq 2 ]
  then
    for t_con_id in "${dist_con_ids[@]}"
    do
      if [ ${t_con_id} -eq 2 ]
      then
        line_print="${line_out0}${v_separator}${t_con_id}"
        line_comp1="${line_base0}${v_separator}${t_con_id}"
        ${GREPCMD} -q -Fx "${line_comp1}" "${v_file_base}"; ret=$?
        [ ${ret} -ne 0 ] && addline
      fi
    done
  elif [ -n "${c_con_id}" ] && [ ${c_con_id} -eq 3 ]
  then
    for t_con_id in "${dist_con_ids[@]}"
    do
      if [ ${t_con_id} -ge 3 ]
      then
        line_print="${line_out0}${v_separator}${t_con_id}"
        line_comp1="${line_base0}${v_separator}${t_con_id}"
        ${GREPCMD} -q -Fx "${line_comp1}" "${v_file_base}"; ret=$?
        [ ${ret} -ne 0 ] && addline
      fi
    done
  else # When c_con_id is null = 11g
    line_print="${line_out0}${v_separator}${c_con_id}"
    line_comp1="${line_base0}${v_separator}${c_con_id}"
    ${GREPCMD} -q -Fx "${line_comp1}" "${v_file_base}"; ret=$?
    [ ${ret} -ne 0 ] && addline
  fi
}

#####################################

# Correct it to bring the dist_con_ids from somewhere else. If file is empty will think there is no con_id in this DB
dist_con_ids_file=$(echo $v_list_pdbs | tr "," "\n")
dist_con_ids=(${dist_con_ids_file})
for t_con_id in "${dist_con_ids[@]}"
do
  exit_not_number ${t_con_id}
done

v_last_col=${v_file_priv_fields}
v_awk_last_col=$((v_file_priv_fields-1))

read_conid_common ()
{
  read c_con_id c_common <<< $(echo "$1" | ${AWKCMD_CSV} --source '{a=csv_parse_record($0, separator, enclosure, csv); print csv['${v_awk_last_col}'], csv['$((v_awk_last_col-1))']}')
}

read_conid ()
{
  read c_con_id <<< $(echo "$1" | ${AWKCMD_CSV} --source '{a=csv_parse_record($0, separator, enclosure, csv); print csv['${v_awk_last_col}']}')
}

totline=$(cat "${v_file_priv}" | wc -l)
curline=1
perc_b4=-1

## Create pre files
if [ -z "${v_col_change}" ]
then
 # v_file_priv_base0
 v_file_priv_base0="${v_file_priv}.base0"
 ${AWKCMD_CSV} --source '{csv_print_until_field_record($0, separator, enclosure, '$((v_last_col-1))')}' "${v_file_priv}" > "${v_file_priv_base0}"
else
 # v_file_priv_base0 and v_file_priv_out0
 v_file_priv_base0="${v_file_priv}.base0"
 cp "${v_file_priv}" "${v_file_priv_base0}"
 v_file_priv_out0="${v_file_priv}.out0"
 cp "${v_file_priv}" "${v_file_priv_out0}"
 v_fld_rep=1
 while [ $v_fld_rep -le $v_tot_fld ]
 do
   read v_col_rep v_col_comp <<< $(echo "${v_col_change}" | ${AWKCMD} -F';' '{print $'${v_fld_rep}'}' | ${AWKCMD} -F',' '{print $1, $2}')
   ${AWKCMD_CSV} --source '{csv_print_exchange_field_records($0, separator, enclosure, '${v_col_rep}', '${v_col_comp}')}' "${v_file_priv_base0}" > "${v_file_priv_base0}.new"
   mv "${v_file_priv_base0}.new" "${v_file_priv_base0}"
   ${AWKCMD_CSV} --source '{csv_print_skip_field_record($0, separator, enclosure, '${v_col_comp}')}' "${v_file_priv_out0}" > "${v_file_priv_out0}.new"
   mv "${v_file_priv_out0}.new" "${v_file_priv_out0}"
   v_fld_rep=$((v_fld_rep+1))
   v_col_change=$(remake_colchange "${v_col_change}" ${v_col_comp})
 done
 ${AWKCMD_CSV} --source '{csv_print_until_field_record($0, separator, enclosure, '$((v_last_col-1-v_tot_fld))')}' "${v_file_priv_base0}" > "${v_file_priv_base0}.new"
 mv "${v_file_priv_base0}.new" "${v_file_priv_base0}"
 ${AWKCMD_CSV} --source '{csv_print_until_field_record($0, separator, enclosure, '$((v_last_col-1-v_tot_fld))')}' "${v_file_priv_out0}" > "${v_file_priv_out0}.new"
 mv "${v_file_priv_out0}.new" "${v_file_priv_out0}"
fi

## Last column must always be "CON_ID"
if [ -z "${v_col_change}" ]
then
 while read -r c_line || [ -n "${c_line}" ]
 do
  # Base0 is the line to be compared, while Out0 is the line to be printed. Both don't have con_id.
  line_base0=$(${AWKCMD} 'NR=='${curline} "${v_file_priv_base0}")
  line_out0="$line_base0"
  [ ${v_has_common_col} = "YES" ] && read_conid_common "$c_line" || read_conid "$c_line"
  [ -n "${c_con_id}" ] && exit_not_number "${c_con_id}"
  if [ "${v_reverse}" = "NO" ]; then scan_conids; else scan_conids_reverse; fi # Written that way to avoid last scan execution case true && false || exec
  ## Print Percentage
  printpercentage
 done < "${v_file_priv}"
 rm -f "${v_file_priv_base0}"
else
 while read -r c_line || [ -n "${c_line}" ]
 do
  # Base0 is the line to be compared, while Out0 is the line to be printed. Both don't have con_id.
  line_base0=$(${AWKCMD} 'NR=='${curline} "${v_file_priv_base0}")
  line_out0=$(${AWKCMD} 'NR=='${curline} "${v_file_priv_out0}")
  [ ${v_has_common_col} = "YES" ] && read_conid_common "$c_line" || read_conid "$c_line"
  [ -n "${c_con_id}" ] && exit_not_number "${c_con_id}"
  if [ "${v_reverse}" = "NO" ]; then scan_conids; else scan_conids_reverse; fi # Written that way to avoid last scan execution case true && false || exec
  ## Print Percentage
  printpercentage
 done < "${v_file_priv}"
 rm -f "${v_file_priv_base0}" "${v_file_priv_out0}"
fi

exit 0
####