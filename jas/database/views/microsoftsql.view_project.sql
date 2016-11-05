CREATE VIEW dbo.view_project
AS
SELECT     TOP 100 PERCENT dbo.jproject.JProj_JProject_UID AS UID, dbo.jproject.JProj_Name AS Name, dbo.juser.JUser_Name, dbo.jproject.JProj_URL AS URL,
                       dbo.jproject.JProj_URL_Stage AS StagingURL, dbo.jprojectstatus.JPrjS_Name AS ProjectStatus, dbo.jpriority.JPrio_en AS Priority, 
                      dbo.jprojectcategory.JPjCt_Name AS ProjectCategory, dbo.jproject.JProj_Progress_PCT_d AS Progress, 
                      dbo.jproject.JProj_Hours_Worked_d AS HoursWorked, dbo.jproject.JProj_Hours_Sched_d AS HoursScheduled, 
                      dbo.jproject.JProj_Hours_Project_d AS ProjectHours, dbo.jproject.JProj_Desc AS Description, dbo.jproject.JProj_Start_DT AS StartDate, 
                      dbo.jproject.JProj_Target_End_DT AS TargetEndDate, dbo.jproject.JProj_Actual_End_DT AS ActualEndDate, 
                      dbo.jproject.JProj_Target_Budget_d AS Budget, juser2.JUser_Name AS CreatedBy, dbo.jproject.JProj_Created_DT AS Created, 
                      juser3.JUser_Name AS ModifiedBy, dbo.jproject.JProj_Modified_DT AS Modified, dbo.jtask.JTask_Name AS TaskName, 
                      dbo.jcompany.JComp_Name AS Company, 
                      dbo.jperson.JPers_NameFirst + ' ' + dbo.jperson.JPers_NameMiddle + ' ' + dbo.jperson.JPers_NameLast AS Person
FROM         dbo.jproject LEFT OUTER JOIN
                      dbo.juser ON dbo.juser.JUser_JUser_UID = dbo.jproject.JProj_Owner_JUser_ID LEFT OUTER JOIN
                      dbo.juser juser2 ON dbo.juser.JUser_JUser_UID = dbo.jproject.JProj_Owner_JUser_ID LEFT OUTER JOIN
                      dbo.juser juser3 ON dbo.juser.JUser_JUser_UID = dbo.jproject.JProj_Owner_JUser_ID LEFT OUTER JOIN
                      dbo.jprojectstatus ON dbo.jprojectstatus.JPrjS_JProjectStatus_UID = dbo.jproject.JProj_JProjectStatus_ID LEFT OUTER JOIN
                      dbo.jpriority ON dbo.jpriority.JPrio_JPriority_UID = dbo.jproject.JProj_JPriority_ID LEFT OUTER JOIN
                      dbo.jprojectcategory ON dbo.jprojectcategory.JPjCt_JProjectCategory_UID = dbo.jproject.JProj_JProjectCategory_ID LEFT OUTER JOIN
                      dbo.jtask ON dbo.jtask.JTask_JTask_UID = dbo.jproject.JProj_JTask_ID LEFT OUTER JOIN
                      dbo.jcompany ON dbo.jcompany.JComp_JCompany_UID = dbo.jproject.JProj_JCompany_ID LEFT OUTER JOIN
                      dbo.jperson ON dbo.jperson.JPers_JPerson_UID = dbo.jproject.JProj_JPerson_ID
WHERE     (dbo.jproject.JProj_Deleted_b <> 1) OR
                      (dbo.jproject.JProj_Deleted_b IS NULL)
ORDER BY dbo.jproject.JProj_Name

