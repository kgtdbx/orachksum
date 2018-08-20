-- THIS SCRIPT REQUIRES THAT THE FOLLOWING VARIABLES ARE ALREADY SET:
-- orachk_file_pref
-- orachk_srczip_pref
-- orachk_orig_file
-- orachk_report_file

-- Defined in pre-sql:
-- orachk_exec_sh
-- orachk_workdir
-- orachk_version_file

-- BEGIN

-- GENERATE CSV TO COMPARE
@@&&orachk_exec_sh &&orachk_workdir./sh/call_reduce_tbl.sh &&orachk_workdir. &&orachk_version_file. &&orachk_orig_file. &&orachk_report_file. &&orachk_file_pref. &&orachk_srczip_pref. &&orachk_comp_column.

-- END