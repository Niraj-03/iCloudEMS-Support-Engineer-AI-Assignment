# iCloudEMS Support Engineer (AI) Assignment

This repository contains my completed practical assignment for the iCloudEMS Support Engineer (AI) assessment.

## Deliverables

- `answers.docx` — written responses for ticket triage, report investigation, re-evaluation handling, client/developer communication, and AI usage.
- `queries.sql` — SQLite table definition and diagnostic queries, including expected result-set row counts.
- `GU-16432_upload_ready.csv` — 36 validated re-evaluation rows formatted for the supplied staging template.
- `GU-16432_exceptions.xlsx` — 5 rows held for COE/client clarification.

## Key findings

### Ticket EX-20481 — Exam-wise Report

- 2,767 report rows
- 875 distinct student admission numbers
- 208 distinct course codes
- 104 rows with marks present
- 1,638 rows marked `Not Done`
- 1,025 rows marked `Scheme Not Found`
- 1,849 published rows have no marks

The export indicates missing marks entry and missing exam-scheme configuration as the primary issues. The report itself should still be regression-tested, but the data does not support assuming a report-rendering defect.

### Ticket GU-16432 — Re-evaluation marks

- 41 source rows checked
- 36 rows prepared for staging
- 5 rows held as exceptions: S.No 4, 12, 16, 20 and 23
- No student marks were silently changed.

## Important safety notes

- The upload-ready CSV is a staging preparation artifact; it is not evidence of a successful ERP upload.
- The five exception rows require clarification/authorised COE decisions.
- Do not transfer marks to the live table, freeze marks, or process/publish results without the university's approval and the ERP's normal controls.
- The supplied data is not included in this public repository. The assessment says the records are dummy data but asks candidates to handle them as real student records.

## Reproducibility

The SQL file targets SQLite. Import the supplied `exam_wise_report_export.csv` into a local SQLite database using the table/column names in `queries.sql`, then run the SELECT diagnostics. The script includes a protected semester-normalisation example with a backup step. Run it only on a test copy after reviewing the preview query.

## Assumptions and limitations

- The downloaded assessment ZIP supplied `revaluation_marks_winter_2025-26.csv`; that CSV was used as the re-evaluation source.
- No live ERP, exam-scheme master, or upload screen was provided. No live system changes were performed.
- `sessId` and `qType` are blank because the source data and brief do not provide values or a reliable mapping rule.
- The `ssType` values are taken from the matching report export; fixed session/exam/year/question fields follow the assignment instructions.
