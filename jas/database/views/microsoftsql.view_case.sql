CREATE VIEW dbo.view_case
AS
SELECT     dbo.jcase.JCase_JCase_UID AS UID, dbo.jcase.JCase_Name AS Name, dbo.jcompany.JComp_Name AS CompanyName,
                      dbo.jperson.JPers_NameFirst + ' ' + dbo.jperson.JPers_NameMiddle + ' ' + dbo.jperson.JPers_NameLast AS Person,
                      dbo.jteam.JTeam_Name AS ResponsibleTeam,
                      jperson2.JPers_NameFirst + ' ' + jperson2.JPers_NameMiddle + ' ' + jperson2.JPers_NameLast AS ResponsiblePerson,
                      dbo.jcasesource.JCASR_Name AS Source, dbo.jcasecategory.JCACT_Name AS Category, dbo.jpriority.JPrio_en AS Priority,
                      dbo.jstatus.JStat_Name AS Status, dbo.jcasetype.JCATY_Name AS Type, dbo.jcasesubject.JCASB_Name AS Subject, dbo.jcase.JCase_Due_DT AS Due,
                       dbo.jcase.JCase_Resolved_DT AS Resolved, dbo.juser.JUser_Name AS ResolvedBy, juser2.JUser_Name AS CreatedBy,
                      dbo.jcase.JCase_Created_DT AS Created, juser3.JUser_Name AS ModifiedBy, dbo.jcase.JCase_Modified_DT AS Modified,
                      dbo.jcase.JCase_Desc AS Description, dbo.jcase.JCase_Resolution AS Resolution
FROM         dbo.jcase LEFT OUTER JOIN
                      dbo.jcompany ON dbo.jcompany.JComp_JCompany_UID = dbo.jcase.JCase_JCompany_ID LEFT OUTER JOIN
                      dbo.jperson ON dbo.jperson.JPers_JPerson_UID = dbo.jcase.JCase_JPerson_ID LEFT OUTER JOIN
                      dbo.jteam ON dbo.jteam.JTeam_JTeam_UID = dbo.jcase.JCase_Responsible_JTeam_ID LEFT OUTER JOIN
                      dbo.jperson jperson2 ON jperson2.JPers_JPerson_UID = dbo.jcase.JCase_Responsible_Person_ID LEFT OUTER JOIN
                      dbo.jcasesource ON dbo.jcasesource.JCASR_JCaseSource_UID = dbo.jcase.JCase_JCaseSource_ID LEFT OUTER JOIN
                      dbo.jcasecategory ON dbo.jcasecategory.JCACT_JCaseCategory_UID = dbo.jcase.JCase_JCaseCategory_ID LEFT OUTER JOIN
                      dbo.jpriority ON dbo.jpriority.JPrio_JPriority_UID = dbo.jcase.JCase_JPriority_ID LEFT OUTER JOIN
                      dbo.jstatus ON dbo.jstatus.JStat_JStatus_UID = dbo.jcase.JCase_JStatus_ID LEFT OUTER JOIN
                      dbo.jcasetype ON dbo.jcasetype.JCATY_JCaseType_UID = dbo.jcase.JCase_JCaseType_ID LEFT OUTER JOIN
                      dbo.jcasesubject ON dbo.jcasesubject.JCASB_JCaseSubject_UID = dbo.jcase.JCase_JCaseSubject_ID LEFT OUTER JOIN
                      dbo.juser ON dbo.juser.JUser_JUser_UID = dbo.jcase.JCase_ResolvedBy_JUser_ID LEFT OUTER JOIN
                      dbo.juser juser2 ON juser2.JUser_JUser_UID = dbo.jcase.JCase_CreatedBy_JUser_ID LEFT OUTER JOIN
                      dbo.juser juser3 ON juser3.JUser_JUser_UID = dbo.jcase.JCase_ModifiedBy_JUser_ID
WHERE     (dbo.jcase.JCase_Deleted_b <> 1) OR
                      (dbo.jcase.JCase_Deleted_b IS NULL)


