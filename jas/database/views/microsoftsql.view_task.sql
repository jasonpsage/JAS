CREATE VIEW dbo.view_task
AS
SELECT     TOP 100 PERCENT dbo.jtask.JTask_JTask_UID, dbo.jtask.JTask_Name, dbo.jtask.JTask_Desc, dbo.jtaskcategory.JTCat_Name, 
                      dbo.jproject.JProj_Name, dbo.jstatus.JStat_Name, dbo.jtask.JTask_Due_DT, dbo.jtask.JTask_Duration_Minutes_Est, dbo.jpriority.JPrio_en AS Priority, 
                      dbo.jtask.JTask_Start_DT, dbo.juser.JUser_Name AS Owner, dbo.jtask.JTask_SendReminder_b, dbo.jtask.JTask_ReminderSent_b, 
                      dbo.jtask.JTask_Remind_DaysAhead_u, dbo.jtask.JTask_Remind_HoursAhead_u, dbo.jtask.JTask_Remind_MinutesAhead_u, 
                      dbo.jtask.JTask_Remind_Persistantly_b, dbo.jtask.JTask_Progress_PCT_d, dbo.jcase.JCase_Name, dbo.jtask.JTask_Directions_URL, 
                      juser2.JUser_Name AS CreatedBy, dbo.jtask.JTask_Created_DT, juser3.JUser_Name AS ModifiedBy, dbo.jtask.JTask_Modified_DT, 
                      dbo.jtask.JTask_URL, dbo.jtask.JTask_Milestone_b, dbo.jtask.JTask_Budget_d, dbo.jtask.JTask_Completed_DT, dbo.jtask.JTask_ResolutionNotes, 
                      dbo.jtable.JTabl_Name, dbo.jtask.JTask_Related_Row_ID
FROM         dbo.jtask LEFT OUTER JOIN
                      dbo.jtaskcategory ON dbo.jtask.JTask_JTaskCategory_ID = dbo.jtaskcategory.JTCat_JTaskCategory_UID LEFT OUTER JOIN
                      dbo.jproject ON dbo.jtask.JTask_JProject_ID = dbo.jproject.JProj_JProject_UID LEFT OUTER JOIN
                      dbo.jstatus ON dbo.jtask.JTask_JStatus_ID = dbo.jstatus.JStat_JStatus_UID LEFT OUTER JOIN
                      dbo.jpriority ON dbo.jtask.JTask_JPriority_ID = dbo.jpriority.JPrio_JPriority_UID LEFT OUTER JOIN
                      dbo.juser ON dbo.jtask.JTask_Owner_JUser_ID = dbo.juser.JUser_JUser_UID LEFT OUTER JOIN
                      dbo.jcase ON dbo.jtask.JTask_JCase_ID = dbo.jcase.JCase_JCase_UID LEFT OUTER JOIN
                      dbo.juser juser2 ON dbo.jtask.JTask_CreatedBy_JUser_ID = juser2.JUser_JUser_UID LEFT OUTER JOIN
                      dbo.juser juser3 ON dbo.jtask.JTask_ModifiedBy_JUser_ID = juser3.JUser_JUser_UID LEFT OUTER JOIN
                      dbo.jtable ON dbo.jtask.JTask_Related_JTable_ID = dbo.jtable.JTabl_JTable_UID
WHERE     (dbo.jtask.JTask_Deleted_b <> 1) OR
                      (dbo.jtask.JTask_Deleted_b IS NULL)
ORDER BY dbo.jtask.JTask_Name


