-- iCloudEMS Support Engineer (AI) Assignment
-- Database: SQLite
-- Source export: exam_wise_report_export.csv (2,767 rows, 26 columns)
--
-- IMPORT:
-- Create this table in SQLite, then import the supplied CSV into it using DB Browser
-- for SQLite (File > Import > Table from CSV) or an equivalent CSV import tool.
-- Ensure the imported column names match the snake_case names below.
-- This repository does not redistribute the source student dataset.
--
-- IMPORTANT: Run diagnostics first. The semester UPDATE is a demonstration only.
-- Take/verify a backup and obtain approval before any production data change.

CREATE TABLE exam_wise_report (
    sr INTEGER,
    exam_session TEXT,
    academic_year TEXT,
    branch TEXT,
    department TEXT,
    class TEXT,
    semester TEXT,
    batch TEXT,
    admno TEXT,
    rollno TEXT,
    student TEXT,
    division TEXT,
    course TEXT,
    code TEXT,
    type TEXT,
    alloted_empid TEXT,
    exam_name TEXT,
    marks_entry_status TEXT,
    marks_obtained REAL,
    max_marks REAL,
    freeze_unfreeze_status TEXT,
    scaled_marks REAL,
    scaled_maxmarks REAL,
    register_status TEXT,
    result_process TEXT,
    result_publish TEXT
);

-- Query 1: rows for each exam_name + marks_entry_status combination.
-- Expected result-set rows: 5
SELECT exam_name, marks_entry_status, COUNT(*) AS row_count
FROM exam_wise_report
GROUP BY exam_name, marks_entry_status
ORDER BY exam_name, marks_entry_status;

-- Query 2: Published results where marks are Not Done or missing.
-- Expected result-set rows: 1,849
SELECT admno, student, code, course, exam_name
FROM exam_wise_report
WHERE result_publish = 'Published'
  AND (marks_entry_status = 'Not Done' OR marks_obtained IS NULL);

-- Query 3: duplicate student + course + exam-component keys.
-- Expected result-set rows: 356 duplicate key groups (360 excess rows).
SELECT admno, code, exam_name, COUNT(*) AS occurrences
FROM exam_wise_report
GROUP BY admno, code, exam_name
HAVING COUNT(*) > 1
ORDER BY occurrences DESC, admno, code;

-- Query 4: impossible/inconsistent marks.
-- Expected result-set rows: 10 (10 negative values; 9 also show scaled mismatch).
-- Correct source column name is scaled_maxmarks (from "Scaled MaxMarks").
SELECT sr, admno, code, exam_name, marks_obtained, max_marks,
       scaled_marks, scaled_maxmarks,
       CASE
         WHEN marks_obtained < 0 THEN 'Negative marks'
         WHEN marks_obtained > max_marks THEN 'Marks exceed maximum'
         WHEN max_marks = scaled_maxmarks
              AND marks_obtained IS NOT NULL
              AND scaled_marks IS NOT NULL
              AND marks_obtained <> scaled_marks
           THEN 'Scaled marks mismatch'
       END AS issue
FROM exam_wise_report
WHERE marks_obtained < 0
   OR marks_obtained > max_marks
   OR (max_marks = scaled_maxmarks
       AND marks_obtained IS NOT NULL
       AND scaled_marks IS NOT NULL
       AND marks_obtained <> scaled_marks);

-- Query 5a: preview each original semester label and its proposed standard value.
-- Expected result-set rows: 17 distinct original labels.
SELECT DISTINCT semester,
       CASE
         WHEN UPPER(TRIM(semester)) = 'SEM 9' THEN 'Sem IX'
         WHEN UPPER(TRIM(semester)) = 'SEM I' THEN 'Sem I'
         WHEN UPPER(TRIM(semester)) = 'SEM II' THEN 'Sem II'
         WHEN UPPER(TRIM(semester)) = 'SEM III' THEN 'Sem III'
         WHEN UPPER(TRIM(semester)) = 'SEM IV' THEN 'Sem IV'
         WHEN UPPER(TRIM(semester)) = 'SEM V' THEN 'Sem V'
         WHEN UPPER(TRIM(semester)) = 'SEM VI' THEN 'Sem VI'
         WHEN UPPER(TRIM(semester)) = 'SEM VII' THEN 'Sem VII'
         WHEN UPPER(TRIM(semester)) = 'SEM VIII' THEN 'Sem VIII'
         ELSE TRIM(semester)
       END AS cleaned_semester
FROM exam_wise_report
ORDER BY semester;

-- Query 5b: protected update example.
-- Review Query 5a first. Run this only on a test copy after approval.
-- The backup table creation intentionally fails if the backup already exists:
-- inspect/rename the old backup rather than silently overwriting it.
BEGIN IMMEDIATE;
CREATE TABLE exam_wise_report_backup AS
SELECT * FROM exam_wise_report;

UPDATE exam_wise_report
SET semester = CASE
  WHEN UPPER(TRIM(semester)) = 'SEM 9' THEN 'Sem IX'
  WHEN UPPER(TRIM(semester)) = 'SEM I' THEN 'Sem I'
  WHEN UPPER(TRIM(semester)) = 'SEM II' THEN 'Sem II'
  WHEN UPPER(TRIM(semester)) = 'SEM III' THEN 'Sem III'
  WHEN UPPER(TRIM(semester)) = 'SEM IV' THEN 'Sem IV'
  WHEN UPPER(TRIM(semester)) = 'SEM V' THEN 'Sem V'
  WHEN UPPER(TRIM(semester)) = 'SEM VI' THEN 'Sem VI'
  WHEN UPPER(TRIM(semester)) = 'SEM VII' THEN 'Sem VII'
  WHEN UPPER(TRIM(semester)) = 'SEM VIII' THEN 'Sem VIII'
  ELSE semester
END
WHERE UPPER(TRIM(semester)) IN
 ('SEM 9','SEM I','SEM II','SEM III','SEM IV','SEM V','SEM VI','SEM VII','SEM VIII');
COMMIT;

-- Query 6: distinct missing-scheme configuration list for developers.
-- Expected result-set rows: 273 distinct department/semester/course groups.
SELECT department, semester, code, course,
       COUNT(DISTINCT admno) AS students_affected,
       COUNT(*) AS rows_affected
FROM exam_wise_report
WHERE exam_name = 'Scheme Not Found'
GROUP BY department, semester, code, course
ORDER BY students_affected DESC, rows_affected DESC, department, semester, code;

-- Bonus: daily monitoring query for missing exam schemes.
-- Expected result-set rows in this snapshot: 273 groups.
SELECT exam_session, academic_year, department, semester, code, course,
       COUNT(DISTINCT admno) AS students_affected,
       COUNT(*) AS missing_scheme_rows
FROM exam_wise_report
WHERE exam_name = 'Scheme Not Found'
GROUP BY exam_session, academic_year, department, semester, code, course
HAVING COUNT(*) > 0
ORDER BY missing_scheme_rows DESC;
