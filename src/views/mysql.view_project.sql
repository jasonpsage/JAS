CREATE OR REPLACE VIEW view_project AS
select
  JProj_JProject_UID as UID,
  JProj_Name as Name,
  juser.JUser_Name,
  JProj_URL as URL,
  JProj_URL_Stage as StagingURL,
  JPrjS_Name as ProjectStatus,
  JPrio_en as Priority,
  JPjCt_Name as ProjectCategory,
  JProj_Progress_PCT_d as Progress,
  JProj_Hours_Worked_d as HoursWorked,
  JProj_Hours_Sched_d as HoursScheduled,
  JProj_Hours_Project_d as ProjectHours,
  JProj_Desc as Description,
  JProj_Start_DT as StartDate,
  JProj_Target_End_DT as TargetEndDate,
  JProj_Actual_End_DT as ActualEndDate,
  JProj_Target_Budget_d as Budget,
  juser2.JUser_Name as CreatedBy,
  JProj_Created_DT as Created,
  juser3.JUser_Name as ModifiedBy,
  JProj_Modified_DT as Modified,
  jtask.JTask_Name as TaskName,
  JComp_Name as Company,
  CONCAT(JPers_NameFirst,' ',JPers_NameMiddle,' ',JPers_NameLast) as Person

FROM jproject
LEFT JOIN juser ON juser.JUser_JUser_UID=JProj_Owner_JUser_ID
LEFT JOIN juser as juser2 ON juser.JUser_JUser_UID=JProj_Owner_JUser_ID
LEFT JOIN juser as juser3 ON juser.JUser_JUser_UID=JProj_Owner_JUser_ID
LEFT JOIN jprojectstatus ON   jprojectstatus.JPrjS_JProjectStatus_UID = JProj_JProjectStatus_ID
LEFT JOIN jpriority ON        jpriority.JPrio_JPriority_UID = JProj_JPriority_ID
LEFT JOIN jprojectcategory ON jprojectcategory.JPjCt_JProjectCategory_UID = JProj_JProjectCategory_ID
LEFT JOIN jtask ON jtask.JTask_JTask_UID = JProj_JTask_ID
LEFT JOIN jcompany ON jcompany.JComp_JCompany_UID=JProj_JCompany_ID
LEFT JOIN jperson ON jperson.JPers_JPerson_UID = JProj_JPerson_ID

WHERE ((JProj_Deleted_b<>true)OR(JProj_Deleted_b IS NULL))
ORDER BY JProj_Name