SELECT     TOP 100 PERCENT dbo.jtimecard.TMCD_TimeCard_UID AS UID, dbo.jtimecard.TMCD_In_DT AS ClockIn, dbo.jtimecard.TMCD_Out_DT AS ClockOut, 
                      
RIGHT('00' + CAST(DATEDIFF(hour, dbo.jtimecard.TMCD_In_DT, dbo.jtimecard.TMCD_Out_DT) AS varchar), 2)  + ':' + 
RIGHT('00' + CAST(DATEDIFF(minute, dbo.jtimecard.TMCD_In_DT, dbo.jtimecard.TMCD_Out_DT) - DATEDIFF(hour, dbo.jtimecard.TMCD_In_DT, 
                      dbo.jtimecard.TMCD_Out_DT) * 60 AS varchar), 2) + ':' + 
RIGHT('00' + CAST((DATEDIFF(second, dbo.jtimecard.TMCD_In_DT, 
                      dbo.jtimecard.TMCD_Out_DT) - DATEDIFF(minute, dbo.jtimecard.TMCD_In_DT, dbo.jtimecard.TMCD_Out_DT) * 60) - DATEDIFF(hour, 
                      dbo.jtimecard.TMCD_In_DT, dbo.jtimecard.TMCD_Out_DT) * 60 * 60 AS varchar), 2) 
AS TotalFormatted, 


RIGHT('00' + CAST(DATEDIFF(hour, dbo.jtimecard.TMCD_In_DT, dbo.jtimecard.TMCD_Out_DT) AS varchar), 2) AS TotalHours, 

RIGHT('00' + CAST(DATEDIFF(minute, dbo.jtimecard.TMCD_In_DT, dbo.jtimecard.TMCD_Out_DT) - DATEDIFF(hour, dbo.jtimecard.TMCD_In_DT, 
                      dbo.jtimecard.TMCD_Out_DT) * 60 AS varchar), 2) AS TotalMinutes, 


RIGHT('00' + CAST((DATEDIFF(second, dbo.jtimecard.TMCD_In_DT, 
                      dbo.jtimecard.TMCD_Out_DT) - DATEDIFF(minute, dbo.jtimecard.TMCD_In_DT, dbo.jtimecard.TMCD_Out_DT) * 60) - DATEDIFF(hour, 
                      dbo.jtimecard.TMCD_In_DT, dbo.jtimecard.TMCD_Out_DT) * 60 * 60 AS varchar), 2) AS TotalSeconds, 


cast(DATEDIFF(second, dbo.jtimecard.TMCD_In_DT, dbo.jtimecard.TMCD_Out_DT) as decimal) / 3600.0 AS TotalTime, 



dbo.jtimecard.TMCD_Note_Internal AS InternalNote1,
                      dbo.jtimecard.TMCD_Note_Public AS PublicNote1, dbo.jnote.JNote_en AS InternalNote2, jnote2.JNote_en AS PublicNote2,
                      dbo.jtimecard.TMCD_Reference AS Reference, dbo.jproject.JProj_Name AS Project, dbo.jtask.JTask_Name AS TaskName, 
                      dbo.jtimecard.TMCD_Billable_b AS Billable, dbo.jtimecard.TMCD_ManualEntry_b AS ManualEntry, 
                      dbo.jtimecard.TMCD_ManualEntry_DT AS ManuallyEntered, dbo.jtimecard.TMCD_Exported_b AS Exported, 
                      dbo.jtimecard.TMCD_Exported_DT AS ExportedDate, dbo.jtimecard.TMCD_Uploaded_b AS Uploaded, 
                      dbo.jtimecard.TMCD_Uploaded_DT AS UploadedDate, dbo.jtimecard.TMCD_Payrate_d AS Payrate, 
                      dbo.jtimecard.TMCD_PayrateName AS PayrateName, dbo.jtimecard.TMCD_Expense_b AS Expense, dbo.jtimecard.TMCD_Imported_b AS Imported, 
                      dbo.jtimecard.TMCD_Imported_DT AS ImportedDate, dbo.juser.JUser_Name AS CreatedBy, dbo.jtimecard.TMCD_Created_DT AS Created, 
                      dbo.jtimecard.TMCD_ModifiedBy_JUser_ID, juser2.JUser_Name AS ModifiedBy, dbo.jtimecard.TMCD_Modified_DT AS Modified, 
                      dbo.jtimecard.TMCD_Name AS Name, dbo.jtimecard.TMCD_Invoice_Sent_b AS InvoiceSent, dbo.jtimecard.TMCD_Invoice_Paid_b AS InvoicePaid, 
                      dbo.jtimecard.TMCD_Invoice_No AS InvoiceNumber
FROM         dbo.jtimecard LEFT OUTER JOIN
                      dbo.jnote ON dbo.jnote.JNote_JNote_UID = dbo.jtimecard.TMCD_JNote_Public_ID LEFT OUTER JOIN
                      dbo.jnote jnote2 ON jnote2.JNote_JNote_UID = dbo.jtimecard.TMCD_JNote_Internal_ID LEFT OUTER JOIN
                      dbo.jproject ON dbo.jproject.JProj_JProject_UID = dbo.jtimecard.TMCD_JProject_ID LEFT OUTER JOIN
                      dbo.jtask ON dbo.jtask.JTask_JTask_UID = dbo.jtimecard.TMCD_JTask_ID LEFT OUTER JOIN
                      dbo.juser ON dbo.juser.JUser_JUser_UID = dbo.jtimecard.TMCD_CreatedBy_JUser_ID LEFT OUTER JOIN
                      dbo.juser juser2 ON juser2.JUser_JUser_UID = dbo.jtimecard.TMCD_ModifiedBy_JUser_ID
WHERE     (dbo.jtimecard.TMCD_Deleted_b <> 1) OR
                      (dbo.jtimecard.TMCD_Deleted_b IS NULL)
ORDER BY dbo.jtimecard.TMCD_In_DT