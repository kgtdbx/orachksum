# ORACHKSUM #

ORACHKSUM is a tool to very signature for files and packages of Oracle Databases. 
It gives a glance of a database security state. It also helps to document any findings.
ORACHKSUM installs nothing. For better results execute connected as SYS or DBA.
It takes around one hour to execute. Output ZIP file can be large (several MBs), so
you may want to execute ORACHKSUM from a system directory with at least 1 GB of free 
space. Best time to execute ORACHKSUM is close to the end of a working day.

## Steps ##

1. Unzip orachksum_master.zip, navigate to the root orachksum_master directory, and connect as SYS, 
   DBA, or any User with Data Dictionary access:

   $ unzip orachksum_master.zip
   $ cd orachksum_master
   $ sqlplus / as sysdba

2. Execute orachksum.sql.

   SQL> @orachksum.sql
   
3. Unzip output ORACHKSUM_<dbname>_<host>_YYYYMMDD_HH24MI.zip into a directory on your PC

4. Review main html file 00001_orachksum_<dbname>_index.html

## Notes ##

1. As orachksum can run for a long time, in some systems it's recommend to execute it unattended:

   $ nohup sqlplus / as sysdba @orachksum.sql &

2. If you need to execute ORACHKSUM against all databases in host use then orachksum.sh:

   $ unzip orachksum.zip
   $ cd orachksum
   $ sh orachksum.sh
   
   note: using this script a password will be requested to zip the files.

3. If you need to execute only a portion of ORACHKSUM (i.e. a column, section or range) use 
   these commands. Notice first parameter can be set to one section (i.e. 3b),
   one column (i.e. 3), a range of sections (i.e. 5c-6b) or range of columns (i.e. 5-7):

   SQL> @orachksum.sql 3b
   
   note: valid column range for first parameter is 1 to 3. 

4. If the output file is encrypted, you need to decrypt it using openssl:

   $ openssl smime -decrypt -binary -in "encrypted_output_file" -inform DER -out "decrypted_zip_file" -inkey "private_key_file"

5. If the html file is encrypted and asks for a password, you need to get the key decrypting the "key.bin.enc" file inside the zip:

   $ openssl rsautl -decrypt -inkey "private_key_file" -in key.bin.enc

## Versions ##
* 1801 (2018-01-10) by Rodrigo Jorge
- Initial Version
* 1804 (2018-04-30) by Rodrigo Jorge
- Included Fast AWK Modes