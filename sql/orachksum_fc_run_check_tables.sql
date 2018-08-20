-- ----------------------------------------------------------------------------
-- Written by Rodrigo Jorge <http://www.dbarj.com.br/>
-- Last updated on: November/2017 by Rodrigo Jorge
-- ----------------------------------------------------------------------------

DEF title = '&&orachk_subject. - Extra';
DEF main_table = '&&orachk_table_name.'

@@&&fc_def_output_file. orachk_db_file       '&&orachk_file_pref._db_out.csv'
@@&&fc_def_output_file. orachk_tot_rows_file '&&orachk_file_pref._csv_numrows.sql'
@@&&fc_def_output_file. orachk_orig_file     '&&orachk_file_pref._orig.csv'

-- If orachk_comp_column is defined, will generate the compare file and use it on orachksum shell step. Otherwise, ignore.
@@&&fc_set_value_var_nvl2. orachk_db_comp   '&&orachk_comp_column.' '&&orachk_db_file..comp'   '&&orachk_db_file.'
@@&&fc_set_value_var_nvl2. orachk_orig_comp '&&orachk_comp_column.' '&&orachk_orig_file..comp' '&&orachk_orig_file.'

@@&&fc_def_output_file. one_spool_html_file '&&orachk_file_pref._result.html'
@@&&fc_def_output_file. orachk_csv_file     '&&orachk_file_pref._result.csv'
DEF orachk_csv_field_sep = ','

@@&&fc_def_output_file. orachk_dbg_file_1  '&&orachk_file_pref._dbg_1.txt'
@@&&fc_def_output_file. orachk_dbg_file_2  '&&orachk_file_pref._dbg_2.txt'
@@&&fc_def_output_file. orachk_dbg_file_3  '&&orachk_file_pref._dbg_3.txt'
@@&&fc_def_output_file. orachk_dbg_file_4  '&&orachk_file_pref._dbg_4.txt'
@@&&fc_def_output_file. orachk_dbg_file_5  '&&orachk_file_pref._dbg_5.txt'
@@&&fc_def_output_file. orachk_dbg_file_6  '&&orachk_file_pref._dbg_6.txt'
@@&&fc_def_output_file. orachk_dbg_file_7  '&&orachk_file_pref._dbg_7.txt'
@@&&fc_def_output_file. orachk_dbg_file_8  '&&orachk_file_pref._dbg_8.txt'

@@&&fc_set_value_var_decode. orachk_debug  '&&DEBUG.' 'ON' '-x' '+x'

-- Create Output for DB.
@@&&fc_spool_start.
@@&&orachk_workdir./sql/&&orachk_sql_file. &&orachk_db_file. &&orachk_file_pref.
@@&&fc_spool_end.

HOS sh &&orachk_debug. &&orachk_workdir./sh/call_reduce_tbl.sh &&orachk_workdir. &&orachk_version_file. &&orachk_orig_file. &&orachk_report_file. &&orachk_file_pref. &&orachk_srczip_pref. &&orachk_comp_column. > &&orachk_dbg_file_1. 2> &&orachk_dbg_file_1. ### Generate CSV to compare.
HOS sh &&orachk_debug. &&orachk_workdir./sh/gen_compare_file_csv.sh &&orachk_workdir. &&orachk_orig_file. &&orachk_orig_comp. &&orachk_comp_column. > &&orachk_dbg_file_2. 2> &&orachk_dbg_file_2.
HOS sh &&orachk_debug. &&orachk_workdir./sh/orachksum_tbl.sh &&orachk_workdir. &&orachk_db_file. &&orachk_orig_comp. &&orachk_csv_file. &&orachk_report_file. &&orachk_file_pref. NO &&orachk_version_file. &&orachk_comp_column. > &&orachk_dbg_file_3. 2> &&orachk_dbg_file_3. ### Compare HASH.
HOS sh &&orachk_debug. &&orachk_workdir./sh/csv_num_rows.sh &&orachk_csv_file. &&orachk_db_file. &&orachk_csv_field_sep. &&orachk_tot_rows_file. > &&orachk_dbg_file_4. 2> &&orachk_dbg_file_4. ### Compute rows.
-- Compute rows.
@@&&orachk_tot_rows_file.

BEGIN
  :sql_text := q'[
WITH source AS (
  SELECT 'Match - &&orachk_mch.' msg, &&orachk_mch. cnt FROM dual
  UNION ALL
  SELECT 'Difference - &&orachk_tdf.' msg, &&orachk_tdf. cnt FROM dual
)
SELECT msg, cnt,
       trim(to_char(round(cnt/decode(total,0,1,total),4)*100,'990D99')) percent,
       null dummy_01
FROM (SELECT msg, cnt, sum(cnt) over () total FROM source)
ORDER BY 3 DESC
]';
END;
/

UNDEF orachk_mch
UNDEF orachk_nmc
UNDEF orachk_nfd
UNDEF orachk_tdf

HOS sh &&orachk_debug. &&sh_csv_to_html_table. &&orachk_csv_field_sep. &&orachk_csv_file. &&one_spool_html_file. > &&orachk_dbg_file_5. 2> &&orachk_dbg_file_5.

DEF skip_html      = '--'
DEF skip_pch       = ''
DEF skip_html_file = ''
DEF skip_text_file = ''

DEF one_spool_text_file = '&&orachk_csv_file.'
DEF one_spool_text_file_type = 'csv'
DEF one_spool_text_file_rename = 'Y'
DEF one_spool_html_desc_table = 'Y'

DEF sql_show = 'N'

@@&&9a_pre_one.

HOS zip -mjT &&orachk_zip_file. &&orachk_tot_rows_file. >> &&moat369_log3.

--------------

DEF title = '&&orachk_subject. - Missing';
DEF main_table = '&&orachk_table_name.'

@@&&fc_def_output_file. one_spool_html_file '&&orachk_file_pref._result_miss.html'
@@&&fc_def_output_file. orachk_csv_file     '&&orachk_file_pref._result_miss.csv'
DEF orachk_csv_field_sep = ','

HOS sh &&orachk_debug. &&orachk_workdir./sh/gen_compare_file_csv.sh &&orachk_workdir. &&orachk_db_file. &&orachk_db_comp. &&orachk_comp_column. > &&orachk_dbg_file_6. 2> &&orachk_dbg_file_6.
HOS sh &&orachk_debug. &&orachk_workdir./sh/orachksum_tbl.sh &&orachk_workdir. &&orachk_db_comp. &&orachk_orig_file. &&orachk_csv_file. &&orachk_report_file. &&orachk_file_pref. YES &&orachk_version_file. &&orachk_comp_column. > &&orachk_dbg_file_7. 2> &&orachk_dbg_file_7. ### Compare HASH.

HOS sh &&orachk_debug. &&sh_csv_to_html_table. &&orachk_csv_field_sep. &&orachk_csv_file. &&one_spool_html_file. > &&orachk_dbg_file_8. 2> &&orachk_dbg_file_8.

DEF skip_html      = '--'
DEF skip_html_file = ''
DEF skip_text_file = ''

DEF one_spool_text_file = '&&orachk_csv_file.'
DEF one_spool_text_file_type = 'csv'
DEF one_spool_text_file_rename = 'Y'
DEF one_spool_html_desc_table = 'Y'

@@&&9a_pre_one.

HOS zip -mjT &&orachk_zip_file. &&orachk_db_file.    >> &&moat369_log3.
HOS zip -mjT &&orachk_zip_file. &&orachk_orig_file.  >> &&moat369_log3.

HOS if [ -f &&orachk_db_comp. ];   then zip -mjT &&orachk_zip_file. &&orachk_db_comp.   >> &&moat369_log3.; fi
HOS if [ -f &&orachk_orig_comp. ]; then zip -mjT &&orachk_zip_file. &&orachk_orig_comp. >> &&moat369_log3.; fi

HOS zip -mjT &&orachk_zip_file. &&orachk_dbg_file_1. >> &&moat369_log3.
HOS zip -mjT &&orachk_zip_file. &&orachk_dbg_file_2. >> &&moat369_log3.
HOS zip -mjT &&orachk_zip_file. &&orachk_dbg_file_3. >> &&moat369_log3.
HOS zip -mjT &&orachk_zip_file. &&orachk_dbg_file_4. >> &&moat369_log3.
HOS zip -mjT &&orachk_zip_file. &&orachk_dbg_file_5. >> &&moat369_log3.
HOS zip -mjT &&orachk_zip_file. &&orachk_dbg_file_6. >> &&moat369_log3.
HOS zip -mjT &&orachk_zip_file. &&orachk_dbg_file_7. >> &&moat369_log3.
HOS zip -mjT &&orachk_zip_file. &&orachk_dbg_file_8. >> &&moat369_log3.

UNDEF orachk_table_name
UNDEF orachk_subject
UNDEF orachk_file_pref
UNDEF orachk_srczip_pref
UNDEF orachk_sql_file
UNDEF orachk_comp_column

UNDEF orachk_db_file
UNDEF orachk_tot_rows_file
UNDEF orachk_orig_file

UNDEF orachk_db_comp
UNDEF orachk_orig_comp

UNDEF orachk_dbg_file_1
UNDEF orachk_dbg_file_2
UNDEF orachk_dbg_file_3
UNDEF orachk_dbg_file_4
UNDEF orachk_dbg_file_5
UNDEF orachk_dbg_file_6
UNDEF orachk_dbg_file_7
UNDEF orachk_dbg_file_8

UNDEF orachk_debug

UNDEF orachk_csv_file orachk_csv_field_sep