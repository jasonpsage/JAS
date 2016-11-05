CREATE OR REPLACE VIEW view_time AS
SELECT
  TMCD_TimeCard_UID as UID,
  TMCD_In_DT as ClockIn,
  TMCD_Out_DT as ClockOut,
  TIMEDIFF(TMCD_Out_DT,TMCD_In_DT) as TotalFormatted,
  LEFT(TIMEDIFF(TMCD_Out_DT,TMCD_In_DT),2) as TotalHours,
  MID(TIMEDIFF(TMCD_Out_DT,TMCD_In_DT),4,2) as TotalMinutes,
  RIGHT(TIMEDIFF(TMCD_Out_DT,TMCD_In_DT),2) as TotalSeconds,

  ((CAST(LEFT(TIMEDIFF(TMCD_Out_DT,TMCD_In_DT),2) as DECIMAL(10,5)) * 60 * 60)+
  (CAST(MID(TIMEDIFF(TMCD_Out_DT,TMCD_In_DT),4,2) as DECIMAL(10,5)) * 60)+
  (CAST(RIGHT(TIMEDIFF(TMCD_Out_DT,TMCD_In_DT),2) as DECIMAL(10,5))))/3600 as TotalTime,



  TMCD_Note_Internal as NoteInternal,
  TMCD_Note_Public as NotePublic,
  TMCD_Reference as Reference,
  JProj_Name as Project,
  JTask_Name as TaskName,
  TMCD_Billable_b as Billable,
  TMCD_ManualEntry_b as ManualEntry,
  TMCD_ManualEntry_DT as ManuallyEntered,
  TMCD_Exported_b as Exported,
  TMCD_Exported_DT as ExportedDate,
  TMCD_Uploaded_b as Uploaded,
  TMCD_Uploaded_DT as UploadedDate,
  TMCD_Payrate_d as Payrate,
  TMCD_PayrateName as PayrateName,
  TMCD_Expense_b as Expense,
  TMCD_Imported_b as Imported,
  TMCD_Imported_DT as ImportedDate,
  juser.JUser_Name as CreatedBy,
  TMCD_Created_DT as Created,
  TMCD_ModifiedBy_JUser_ID,
  juser2.JUser_Name as ModifiedBy,
  TMCD_Modified_DT as Modified,
  TMCD_Name as Name,
  TMCD_Invoice_Sent_b as InvoiceSent,
  TMCD_Invoice_Paid_b as InvoicePaid,
  TMCD_Invoice_No as InvoiceNumber

FROM jtimecard

LEFT JOIN jproject          ON JProj_JProject_UID=TMCD_JProject_ID
LEFT JOIN jtask             ON jtask.JTask_JTask_UID=TMCD_JTask_ID
LEFT JOIN juser             ON juser.JUser_JUser_UID=TMCD_CreatedBy_JUser_ID
LEFT JOIN juser as juser2   ON juser2.JUser_JUser_UID=TMCD_ModifiedBy_JUser_ID

WHERE ((TMCD_Deleted_b <> TRUE)OR(TMCD_Deleted_b IS NULL))

ORDER BY TMCD_In_DT
 
