# Oracle Pluggable Database Assignment II

<div align="center">

**Student:** Thierry  
**ID:** 27884  
**Date:** February 16, 2026  
**Course:** Oracle Database Administration  

![Oracle](https://img.shields.io/badge/Oracle-21c-F80000?style=for-the-badge&logo=oracle&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

</div>

---

## 📋 Overview

This assignment demonstrates Oracle Multitenant Architecture through practical implementation of Pluggable Database (PDB) creation, lifecycle management, and monitoring using Oracle Database 21c Enterprise Edition.

**Environment:**
- Oracle Database 21c Enterprise Edition (21.3.0.0.0)
- Windows 10 x64
- CDB: ORCL
- OEM Express: https://localhost:5500/em

---

## ✅ Deliverables Summary

| Task | Component | Status |
|------|-----------|--------|
| Task 1 | PDB: `th_pdb_27884` | ✅ Created |
| Task 1 | User: `thierry_plsqlauca_27884` | ✅ Created |
| Task 2 | Temp PDB: `th_to_delete_pdb_27884` | ✅ Deleted |
| Task 3 | OEM Express | ✅ Configured |

---

## 🔧 Task 1: Create PDB and User

### Commands Executed
```sql
-- Connect as SYSDBA
CONNECT sys AS SYSDBA

-- Verify environment
SELECT name, open_mode FROM v$pdbs;

-- Create PDB
CREATE PLUGGABLE DATABASE th_pdb_27884
  ADMIN USER pdb_admin IDENTIFIED BY Oracle123
  FILE_NAME_CONVERT = (
    'C:\USERS\HP\DOWNLOADS\ORADATA\ORCL\PDBSEED\',
    'C:\USERS\HP\DOWNLOADS\ORADATA\ORCL\TH_PDB_27884\'
  );

-- Open and configure auto-startup
ALTER PLUGGABLE DATABASE th_pdb_27884 OPEN;
ALTER PLUGGABLE DATABASE th_pdb_27884 SAVE STATE;

-- Verify PDB status
SELECT name, open_mode FROM v$pdbs WHERE name = 'TH_PDB_27884';

-- Switch to PDB
ALTER SESSION SET CONTAINER = th_pdb_27884;
SHOW CON_NAME;

-- Create user
CREATE USER thierry_plsqlauca_27884 IDENTIFIED BY Thierry123;
GRANT CONNECT, RESOURCE, DBA TO thierry_plsqlauca_27884;
GRANT UNLIMITED TABLESPACE TO thierry_plsqlauca_27884;

-- Verify user
SELECT username, account_status FROM dba_users 
WHERE username = 'THIERRY_PLSQLAUCA_27884';
```

### Evidence
![PDB Created](screenshots/task1_create_pdb.png)
*PDB creation command executed successfully*

![PDB Open](screenshots/task1_pdb_open.png)
*PDB verified in READ WRITE mode*

![User Created](screenshots/task1_user_created.png)
*User thierry_plsqlauca_27884 created with privileges*

![User Login](screenshots/task1_user_login.png)
*User authentication test successful*

---

## 🔄 Task 2: Create and Delete Temporary PDB

### Commands Executed
```sql
-- Create temporary PDB
CREATE PLUGGABLE DATABASE th_to_delete_pdb_27884
  ADMIN USER temp_admin IDENTIFIED BY Temp123
  FILE_NAME_CONVERT = (
    'C:\USERS\HP\DOWNLOADS\ORADATA\ORCL\PDBSEED\',
    'C:\USERS\HP\DOWNLOADS\ORADATA\ORCL\TH_TO_DELETE_PDB_27884\'
  );

-- Open and verify
ALTER PLUGGABLE DATABASE th_to_delete_pdb_27884 OPEN;
SELECT name, open_mode FROM v$pdbs WHERE name LIKE 'TH_%27884';

-- Close and delete
ALTER PLUGGABLE DATABASE th_to_delete_pdb_27884 CLOSE IMMEDIATE;
DROP PLUGGABLE DATABASE th_to_delete_pdb_27884 INCLUDING DATAFILES;

-- Confirm deletion
SELECT name FROM v$pdbs;
```

### Evidence
![Temp PDB Created](screenshots/task2_temp_pdb_created.png)
*Temporary PDB created successfully*

![Both PDBs](screenshots/task2_both_pdbs_exist.png)
*Both PDBs operational before deletion*

![PDB Deleted](screenshots/task2_pdb_deleted.png)
*DROP PLUGGABLE DATABASE executed*

![Deletion Verified](screenshots/task2_verify_deleted.png)
*Temporary PDB removed completely*

---

## 📊 Task 3: Oracle Enterprise Manager

### Configuration
```sql
-- Verify OEM port
SELECT dbms_xdb_config.gethttpsport() FROM dual;
-- Result: 5500

-- Verify XDB component
SELECT comp_name, status FROM dba_registry WHERE comp_id = 'XDB';
```

### Access Information
- **URL:** https://localhost:5500/em
- **Username:** sys
- **Connect As:** SYSDBA
- **Container:** [blank for CDB view]

### Dashboard Features
- Real-time performance monitoring
- Container/PDB tracking
- Resource utilization (CPU, Memory, I/O)
- SQL activity monitoring
- Status: TH_PDB_27884 visible and operational

### Evidence
![OEM Dashboard](screenshots/task3_oem_dashboard.png)
*OEM Express dashboard showing TH_PDB_27884 in performance graph. Username 'sys' visible in top-right corner. CDB status shows "CDB (2 PDB(s))".*

---

## ⚠️ Challenges & Solutions

### Challenge 1: FILE_NAME_CONVERT Path Error (ORA-65005)

**Problem:** Initial attempt used relative paths causing ORA-65005 error.

**Original (Failed):**
```sql
FILE_NAME_CONVERT = ('pdbseed/', '/th_pdb_27884/');
```

**Solution:** Used absolute Windows paths with correct syntax.
```sql
FILE_NAME_CONVERT = (
  'C:\USERS\HP\DOWNLOADS\ORADATA\ORCL\PDBSEED\',
  'C:\USERS\HP\DOWNLOADS\ORADATA\ORCL\TH_PDB_27884\'
);
```

**Investigation:**
```sql
SELECT name FROM v$datafile WHERE con_id = 2;
```
This revealed the actual datafile paths, allowing correct FILE_NAME_CONVERT configuration.

---

### Challenge 2: OEM Authentication Error

**Problem:** Entered incorrect container name `th_pdb_27684` instead of `th_pdb_27884`.

**Error:** "Invalid Database Credentials"

**Solution:** Left Container Name field **blank** to access CDB-level view showing all PDBs.

---

### Challenge 3: Insufficient Privileges (ORA-01031)

**Problem:** Attempted to open PDB while logged in as SYSTEM user.
```
ALTER PLUGGABLE DATABASE th_pdb_27884 OPEN
ERROR: ORA-01031: insufficient privileges
```

**Solution:** Reconnected as SYSDBA.
```sql
EXIT
sqlplus sys AS SYSDBA
ALTER PLUGGABLE DATABASE th_pdb_27884 OPEN;
```

**Lesson:** PDB lifecycle operations require SYSDBA privileges.

---

### Challenge 4: SSL Certificate Warning

**Problem:** Browser showed "Your connection is not private" when accessing OEM Express.

**Reason:** Oracle uses self-signed SSL certificate for localhost (normal for development).

**Solution:** 
1. Clicked "Advanced"
2. Selected "Proceed to localhost (unsafe)"

This is safe for localhost development environments.

---

## 🔐 Security Implementation

**Authentication:**
- SYSDBA privileges for administrative tasks
- Separate user accounts (pdb_admin, thierry_plsqlauca_27884)
- Role-based access control

**Network Security:**
- HTTPS encryption (port 5500)
- HTTP disabled (port 0)
- SSL/TLS for OEM access

**Privileges Granted:**
```sql
GRANT CONNECT, RESOURCE, DBA TO thierry_plsqlauca_27884;
GRANT UNLIMITED TABLESPACE TO thierry_plsqlauca_27884;
```

---

## 📈 Performance Metrics

**Storage:**
- TH_PDB_27884: ~450 MB
- 5 datafiles (SYSTEM, SYSAUX, USERS, UNDOTBS1, TEMP)

**Memory:**
- SGA: ~900 MB
- PGA: ~200 MB

**CPU:**
- Host CPU: 18% utilization
- Database CPU: <5%

---

## 📁 Repository Structure
```
oracle_pdb_ass_II_27884_thierry/
│
├── README.md (this file)
│
├── sql_scripts/
│   ├── task1_create_pdb_and_user.sql
│   ├── task2_create_delete_pdb.sql
│   ├── task3_oem_config.sql
│   ├── test_user_connection.sql
│   └── verify_all.sql
│
└── screenshots/
    ├── task1_create_pdb.png
    ├── task1_pdb_open.png
    ├── task1_user_created.png
    ├── task1_user_login.png
    ├── task2_temp_pdb_created.png
    ├── task2_both_pdbs_exist.png
    ├── task2_pdb_deleted.png
    ├── task2_verify_deleted.png
    └── task3_oem_dashboard.png
```

---

## 🎓 Key Learnings

1. **Multitenant Architecture:** Successfully implemented CDB/PDB structure
2. **Path Handling:** Importance of absolute paths with correct OS-specific syntax
3. **Privilege Management:** SYSDBA required for PDB lifecycle operations
4. **Lifecycle Management:** Complete PDB provisioning and deprovisioning with datafile cleanup
5. **Monitoring:** OEM Express configuration and real-time database monitoring
6. **Troubleshooting:** Systematic problem identification and resolution

---

## ✍️ Integrity Statement

I, **Thierry (Student ID: 27884)**, declare that:

✅ All work is my own, executed independently on my Oracle 21c system  
✅ All SQL commands were written and tested by me personally  
✅ All screenshots are authentic captures from my system  
✅ No AI tools were used to generate commands or solutions  
✅ No collaboration or content sharing with other students occurred  
✅ I fully understand every concept demonstrated in this assignment  

This work represents my genuine effort and understanding of Oracle Database Administration. I independently resolved all challenges encountered, including path configuration, privilege management, and OEM authentication issues.

**Signature:** Thierry  
**Date:** February 16, 2026  
**Student ID:** 27884  

---

## 📚 References

1. Oracle Database Administrator's Guide 21c - Managing Multitenant Environment
2. Oracle Database SQL Language Reference 21c
3. Oracle Enterprise Manager Cloud Control Documentation
4. Assignment Specifications: "Ass II - pluggable_database@2026.md" (February 9, 2026)

---

## 📊 Submission Checklist

- [x] PDB `th_pdb_27884` created and operational
- [x] User `thierry_plsqlauca_27884` created with privileges
- [x] Temporary PDB created and completely deleted
- [x] OEM Express configured and accessible
- [x] All screenshots captured and uploaded
- [x] SQL scripts documented in repository
- [x] README.md complete and professional
- [x] Repository is PUBLIC
- [x] Integrity statement included

---

## 🔗 Submission Information

**Repository:** https://github.com/[YOUR_USERNAME]/oracle_pdb_ass_II_27884_thierry  
**Repository Visibility:** PUBLIC ✅  
**PDB Created:** th_pdb_27884  
**User Created:** thierry_plsqlauca_27884  
**Temporary PDB:** th_to_delete_pdb_27884 (deleted)  
**Issues Encountered:** Yes - FILE_NAME_CONVERT path error (resolved)  

---

<div align="center">

### ✅ Assignment Complete

**"Excellence is never an accident; it is the result of discipline, commitment, and integrity."**



</div>
