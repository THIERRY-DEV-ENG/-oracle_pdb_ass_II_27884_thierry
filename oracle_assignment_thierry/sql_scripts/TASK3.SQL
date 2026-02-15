CONNECT sys AS SYSDBA

SELECT dbms_xdb_config.gethttpsport() FROM dual;

SELECT comp_name, status FROM dba_registry WHERE comp_id = 'XDB';

SELECT name, open_mode FROM v$pdbs;

EXIT

CONNECT thierry_plsqlauca_27884/Thierry123@localhost:1521/th_pdb_27884

SHOW USER;

SELECT SYS_CONTEXT('USERENV', 'CON_NAME') FROM DUAL;

EXIT


CONNECT sys AS SYSDBA

SELECT name, open_mode FROM v$pdbs;

SELECT username, account_status FROM cdb_users WHERE username = 'THIERRY_PLSQLAUCA_27884';

SELECT COUNT(*) FROM v$pdbs WHERE name = 'TH_TO_DELETE_PDB_27884';

SELECT dbms_xdb_config.gethttpsport() FROM dual;

EXIT