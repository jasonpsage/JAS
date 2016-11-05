CREATE OR REPLACE VIEW view_case AS
SELECT
  JCase_JCase_UID as UID,
  JCase_Name as Name,
  JComp_Name as CompanyName,
  CONCAT(jperson.JPers_NameFirst,' ',jperson.JPers_NameMiddle,' ',jperson.JPers_NameLast) as Person,
  JTeam_Name as ResponsibleTeam,
  CONCAT(jperson2.JPers_NameFirst,' ',jperson2.JPers_NameMiddle,' ',jperson2.JPers_NameLast) as ResponsiblePerson,
  JCASR_Name as Source,
  JCACT_Name as Category,
  JPrio_en as Priority,
  JStat_Name as Status,
  JCATY_Name as Type,
  JCASB_Name as Subject,
  JCase_Due_DT as Due,
  JCase_Resolved_DT as Resolved,
  juser.JUser_Name as ResolvedBy,
  juser2.JUser_Name as CreatedBy,
  JCase_Created_DT as Created,
  juser3.JUser_Name as ModifiedBy,
  JCase_Modified_DT as Modified,
  JCase_Desc as Description,
  JCase_Resolution as Resolution

FROM jcase
LEFT JOIN jcompany ON            jcompany.JComp_JCompany_UID =  JCase_JCompany_ID
LEFT JOIN jperson ON             jperson.JPers_JPerson_UID =  JCase_JPerson_ID
LEFT JOIN jteam ON               JTeam_JTeam_UID =  JCase_Responsible_JTeam_ID
LEFT JOIN jperson as jperson2 ON jperson2.JPers_JPerson_UID =  JCase_Responsible_Person_ID
LEFT JOIN jcasesource ON         JCASR_JCaseSource_UID =  JCase_JCaseSource_ID
LEFT JOIN jcasecategory ON       JCACT_JCaseCategory_UID =  JCase_JCaseCategory_ID
LEFT JOIN jpriority ON           JPrio_JPriority_UID =  JCase_JPriority_ID
LEFT JOIN jstatus ON         JStat_JStatus_UID =  JCase_JStatus_ID
LEFT JOIN jcasetype ON           JCATY_JCaseType_UID =  JCase_JCaseType_ID
LEFT JOIN jcasesubject ON            JCASB_JCaseSubject_UID =  JCase_JCaseSubject_ID
LEFT JOIN juser ON               juser.JUser_JUser_UID =  JCase_ResolvedBy_JUser_ID
LEFT JOIN juser as juser2 ON     juser2.JUser_JUser_UID =  JCase_CreatedBy_JUser_ID
LEFT JOIN juser as juser3 ON     juser3.JUser_JUser_UID =  JCase_ModifiedBy_JUser_ID


WHERe ((JCase_Deleted_b<>true)OR(JCase_Deleted_b IS NULL)) 