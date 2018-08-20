-- moat369 configuration file. for those cases where you must change moat369 functionality

/*********************** software configuration (do not remove ) ************************/
@@00_software

/*************************** ok to modify (if really needed) ****************************/

-- report column, or section, or range of columns or range of sections i.e. 3, 3-4, 3a, 3a-4c, 3-4c, 3c-4 / null means all (default)
DEF moat369_sections = '';

-- defines if the output will be encrypted using provided AEG certificate
DEF moat369_conf_encrypt_output = 'OFF';
DEF moat369_conf_encrypt_html   = 'OFF';
DEF moat369_conf_compress_html  = 'ON';

/**************************** not recommended to modify *********************************/

-- excluding report types reduce usability while providing marginal performance gain
DEF moat369_conf_incl_html  = 'Y';
DEF moat369_conf_incl_text  = 'N';
DEF moat369_conf_incl_csv   = 'N';
DEF moat369_conf_incl_line  = 'Y';
DEF moat369_conf_incl_pie   = 'Y';
DEF moat369_conf_incl_bar   = 'Y';
DEF moat369_conf_incl_graph = 'Y';
DEF moat369_conf_incl_file  = 'Y';

-- Default values skip_xxx for each type. Usually you enable HTML and control the others inside sections with "skip_" variables.
DEF moat369_conf_def_html  = 'Y';
DEF moat369_conf_def_text  = 'N';
DEF moat369_conf_def_csv   = 'N';
DEF moat369_conf_def_line  = 'N';
DEF moat369_conf_def_pie   = 'N';
DEF moat369_conf_def_bar   = 'N';
DEF moat369_conf_def_graph = 'N';
DEF moat369_conf_def_file  = 'N';

-- excluding some features from the reports substantially reduces usability with minimal performance gain
DEF moat369_conf_incl_tkprof   = 'Y';
DEF moat369_conf_incl_wr_data  = 'N';
DEF moat369_conf_incl_res      = 'N';
DEF moat369_conf_incl_esp      = 'N';
DEF moat369_conf_incl_opatch   = 'N';
DEF moat369_conf_incl_driver   = 'Y';
DEF moat369_conf_ask_license   = 'N';
DEF moat369_conf_sql_format    = 'Y';
DEF moat369_conf_sql_highlight = 'Y';

DEF moat369_def_sql_format     = 'N';
DEF moat369_def_sql_highlight  = 'Y';

/**************************** enter your modifications here *****************************/

--DEF moat369_conf_incl_text = 'N';
--DEF moat369_conf_incl_csv = 'N';

--DEF moat369_sections = '6d-6e'

--DEF DEBUG      = 'ON'
--DEF moat369_conf_encrypt_html   = 'OFF';