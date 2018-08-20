-- ----------------------------------------------------------------------------
-- Written by Rodrigo Jorge <http://www.dbarj.com.br/>
-- Last updated on: November/2017 by Rodrigo Jorge
-- ----------------------------------------------------------------------------

DEF title = '&&orachk_subject. - Extra';

@@&&fc_def_output_file. orachk_db_file       '&&orachk_file_pref._db_out.csv'

-- Create MD5 for DB.
@@&&fc_spool_start.
@@&&orachk_workdir./sql/&&orachk_sql_file. &&orachk_db_file. &&orachk_file_pref.
@@&&fc_spool_end.

HOS zip -mjT &&orachk_zip_file. &&orachk_db_file.     >> &&moat369_log3.

EXEC :sql_text := q'[SELECT 'Files generated to be analysed by a Security Expert' as "Warning" from DUAL]';
DEF row_num_dif = '-1'
@@&&9a_pre_one.

UNDEF orachk_subject
UNDEF orachk_file_pref
UNDEF orachk_srczip_pref
UNDEF orachk_sql_file
UNDEF orachk_comp_column

UNDEF orachk_db_file
