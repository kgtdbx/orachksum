-- ----------------------------------------------------------------------------
-- Written by Rodrigo Jorge <http://www.dbarj.com.br/>
-- Last updated on: November/2017 by Rodrigo Jorge
-- ----------------------------------------------------------------------------

DEF title = '&&orachk_subject. Checksum Results';

@@&&fc_def_output_file. orachk_db_file       '&&orachk_file_pref._db_out.csv'
@@&&fc_def_output_file. orachk_tot_rows_file '&&orachk_file_pref._csv_numrows.sql'

@@&&fc_def_output_file. one_spool_html_file '&&orachk_file_pref._result.html'
@@&&fc_def_output_file. orachk_csv_file     '&&orachk_file_pref._result.csv'
DEF orachk_csv_field_sep = ','

@@&&fc_def_output_file. orachk_dbg_file_1  '&&orachk_file_pref._dbg_1.txt'
@@&&fc_def_output_file. orachk_dbg_file_2  '&&orachk_file_pref._dbg_2.txt'
@@&&fc_def_output_file. orachk_dbg_file_3  '&&orachk_file_pref._dbg_3.txt'

@@&&fc_set_value_var_decode. orachk_debug  '&&DEBUG.' 'ON' '-x' '+x'

-- Create Output for DB.
@@&&fc_spool_start.
@@&&orachk_workdir./sql/&&orachk_sql_file. &&orachk_db_file.
@@&&fc_spool_end.

HOS sh &&orachk_debug. &&orachk_workdir./sh/orachksum_hash.sh &&orachk_workdir. &&orachk_db_file. &&orachk_orig_file. &&orachk_csv_file. &&orachk_report_file. &&orachk_file_pref. &&orachk_comp_column. > &&orachk_dbg_file_1. 2> &&orachk_dbg_file_1. ### Compare HASH.
HOS sh &&orachk_debug. &&orachk_workdir./sh/csv_num_rows.sh &&orachk_csv_file. &&orachk_db_file. &&orachk_csv_field_sep. &&orachk_tot_rows_file. > &&orachk_dbg_file_2. 2> &&orachk_dbg_file_2. ### Compute rows.
-- Compute rows.
@@&&orachk_tot_rows_file.

BEGIN
  :sql_text := q'[
WITH source AS
(
  SELECT 'Match - &&orachk_mch.' msg, &&orachk_mch. cnt FROM dual
  UNION  ALL
  SELECT 'No match - &&orachk_nmc.' msg, &&orachk_nmc. cnt FROM dual
  UNION  ALL
  SELECT 'Not found - &&orachk_nfd.' msg, &&orachk_nfd. cnt FROM dual
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

-- Generate DDL if orachk_step_code_driver is defined
@@&&fc_def_empty_var. orachk_step_code_driver
HOS if [ -n '&&orachk_step_code_driver.' ]; then sh &&sh_csv_to_metadata_ddl. &&orachk_csv_field_sep. &&orachk_csv_file. true 3 1 2 &&orachk_zip_file. >> "&&orachk_step_code_driver."; fi
-- End

HOS sh &&orachk_debug. &&sh_csv_to_html_table. &&orachk_csv_field_sep. &&orachk_csv_file. &&one_spool_html_file. > &&orachk_dbg_file_3. 2> &&orachk_dbg_file_3.

DEF skip_html      = '--'
DEF skip_pch       = ''
DEF skip_html_file = ''
DEF skip_text_file = ''

DEF one_spool_text_file = '&&orachk_csv_file.'
DEF one_spool_text_file_type = 'csv'
DEF one_spool_text_file_rename = 'Y'

DEF sql_show = 'N'

@@&&9a_pre_one.

HOS zip -mjT &&orachk_zip_file. &&orachk_db_file.       >> &&moat369_log3.
HOS zip -mjT &&orachk_zip_file. &&orachk_tot_rows_file. >> &&moat369_log3.

HOS zip -mjT &&orachk_zip_file. &&orachk_dbg_file_1. >> &&moat369_log3.
HOS zip -mjT &&orachk_zip_file. &&orachk_dbg_file_2. >> &&moat369_log3.
HOS zip -mjT &&orachk_zip_file. &&orachk_dbg_file_3. >> &&moat369_log3.

UNDEF orachk_subject
UNDEF orachk_file_pref
UNDEF orachk_sql_file
UNDEF orachk_comp_column

UNDEF orachk_db_file
UNDEF orachk_tot_rows_file

UNDEF orachk_dbg_file_1
UNDEF orachk_dbg_file_2
UNDEF orachk_dbg_file_3

UNDEF orachk_debug

UNDEF orachk_csv_file orachk_csv_field_sep