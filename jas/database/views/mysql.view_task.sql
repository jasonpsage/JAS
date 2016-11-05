CREATE OR REPLACE VIEW view_task AS
SELECT
  JTask_JTask_UID,
  JTask_Name,
  JTask_Desc,

  /* JTask_JTaskCategory_ID, */
  jtaskcategory.JTCat_Name,

  /* JTask_JProject_ID, */
  jproject.JProj_Name,

  /* JTask_JStatus_ID, */
  jstatus.JStat_Name,

  JTask_Due_DT,
  JTask_Duration_Minutes_Est,

  /* JTask_JPriority_ID, */
  jpriority.JPrio_en as Priority,


  JTask_Start_DT,

  /* JTask_Owner_JUser_ID, */
  juser.JUser_Name as Owner,

  JTask_SendReminder_b,
  JTask_ReminderSent_b,
  JTask_Remind_DaysAhead_u,
  JTask_Remind_HoursAhead_u,
  JTask_Remind_MinutesAhead_u,
  JTask_Remind_Persistantly_b,
  JTask_Progress_PCT_d,

  /* JTask_JCase_ID, */
  jcase.JCase_Name,

  JTask_Directions_URL,

  /* JTask_CreatedBy_JUser_ID, */
  juser2.JUser_Name as CreatedBy,

  JTask_Created_DT,

  /* JTask_ModifiedBy_JUser_ID, */
  juser3.JUser_Name as ModifiedBy,

  JTask_Modified_DT,
  JTask_URL,
  JTask_Milestone_b,
  JTask_Budget_d,
  JTask_Completed_DT,
  JTask_ResolutionNotes,

  /* JTask_Related_JTable_ID, */
  jtable.JTabl_Name,

  JTask_Related_Row_ID

FROM jtask

LEFT JOIN jtaskcategory   ON JTask_JTaskCategory_ID    = jtaskcategory.JTCat_JTaskCategory_UID
LEFT JOIN jproject        ON JTask_JProject_ID         = jproject.JProj_JProject_UID
LEFT JOIN jstatus         ON JTask_JStatus_ID          = jstatus.JStat_JStatus_UID
LEFT JOIN jpriority       ON JTask_JPriority_ID        = jpriority.JPrio_JPriority_UID
LEFT JOIN juser           ON JTask_Owner_JUser_ID      = juser.JUser_JUser_UID
LEFT JOIN jcase           ON JTask_JCase_ID            = jcase.JCase_JCase_UID
LEFT JOIN juser as juser2 ON JTask_CreatedBy_JUser_ID  = juser2.JUser_JUser_UID
LEFT JOIN juser as juser3 ON JTask_ModifiedBy_JUser_ID = juser3.JUser_JUser_UID
LEFT JOIN jtable          ON JTask_Related_JTable_ID   = jtable.JTabl_JTable_UID

WHERE ((JTask_Deleted_b<>true)OR(JTask_Deleted_b IS NULL))
ORDER BY JTask_Name




 
