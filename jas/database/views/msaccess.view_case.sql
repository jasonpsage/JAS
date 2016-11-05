SELECT     jcase.JCase_JCase_UID AS UID, jcase.JCase_Name AS Name, jcompany.JComp_Name AS CompanyName,
                      jperson.JPers_NameFirst + ' ' + jperson.JPers_NameMiddle + ' ' + jperson.JPers_NameLast AS Person,
                      jteam.JTeam_Name AS ResponsibleTeam,
                      jperson2.JPers_NameFirst + ' ' + jperson2.JPers_NameMiddle + ' ' + jperson2.JPers_NameLast AS ResponsiblePerson,
                      jcasesource.JCASR_Name AS Source, jcasecategory.JCACT_Name AS Category, jpriority.JPrio_en AS Priority,
                      jstatus.JStat_Name AS Status, jcasetype.JCATY_Name AS Type, jcasesubject.JCASB_Name AS Subject, jcase.JCase_Due_DT AS Due,
                       jcase.JCase_Resolved_DT AS Resolved, juser.JUser_Name AS ResolvedBy, juser2.JUser_Name AS CreatedBy,
                      jcase.JCase_Created_DT AS Created, juser3.JUser_Name AS ModifiedBy, jcase.JCase_Modified_DT AS Modified,
                      jcase.JCase_Desc AS Description, jcase.JCase_Resolution AS Resolution
FROM         jcase 

RIGHT JOIN jcompany (
  RIGHT JOIN jperson (
    RIGHT JOIN jteam (
      RIGHT JOIN jperson jperson2 (
        RIGHT JOIN jcasesource (
          RIGHT JOIN jcasecategory (
            RIGHT JOIN jpriority (
              RIGHT JOIN jstatus (
                RIGHT JOIN jcasetype (
                  RIGHT JOIN jcasesubject (
                    RIGHT JOIN juser (
                      RIGHT JOIN juser juser2 (
                        RIGHT JOIN juser juser3 ON juser3.JUser_JUser_UID = jcase.JCase_ModifiedBy_JUser_ID)
                              ON juser juser2 ON juser2.JUser_JUser_UID = jcase.JCase_CreatedBy_JUser_ID)
                            ON juser ON juser.JUser_JUser_UID = jcase.JCase_ResolvedBy_JUser_ID)
                          ON jcasesubject ON jcasesubject.JCASB_JCaseSubject_UID = jcase.JCase_JCaseSubject_ID)                                 
                        ON jcasetype ON jcasetype.JCATY_JCaseType_UID = jcase.JCase_JCaseType_ID LEFT OUTER JOIN)
                      ON jstatus ON jstatus.JStat_JStatus_UID = jcase.JCase_JStatus_ID)
                    ON jpriority ON jpriority.JPrio_JPriority_UID = jcase.JCase_JPriority_ID)
                  ON jcasecategory ON jcasecategory.JCACT_JCaseCategory_UID = jcase.JCase_JCaseCategory_ID)
                ON jcasesource ON jcasesource.JCASR_JCaseSource_UID = jcase.JCase_JCaseSource_ID)
              ON jperson jperson2 ON jperson2.JPers_JPerson_UID = jcase.JCase_Responsible_Person_ID)
            ON jteam ON jteam.JTeam_JTeam_UID = jcase.JCase_Responsible_JTeam_ID)
          ON jperson ON jperson.JPers_JPerson_UID = jcase.JCase_JPerson_ID)   
                    





jcompany ON jcompany.JComp_JCompany_UID = jcase.JCase_JCompany_ID LEFT OUTER JOIN
                      jperson ON jperson.JPers_JPerson_UID = jcase.JCase_JPerson_ID LEFT OUTER JOIN
                      jteam ON jteam.JTeam_JTeam_UID = jcase.JCase_Responsible_JTeam_ID LEFT OUTER JOIN
                      jperson jperson2 ON jperson2.JPers_JPerson_UID = jcase.JCase_Responsible_Person_ID LEFT OUTER JOIN
                      jcasesource ON jcasesource.JCASR_JCaseSource_UID = jcase.JCase_JCaseSource_ID LEFT OUTER JOIN
                      jcasecategory ON jcasecategory.JCACT_JCaseCategory_UID = jcase.JCase_JCaseCategory_ID LEFT OUTER JOIN
                      jpriority ON jpriority.JPrio_JPriority_UID = jcase.JCase_JPriority_ID LEFT OUTER JOIN
                      jstatus ON jstatus.JStat_JStatus_UID = jcase.JCase_JStatus_ID LEFT OUTER JOIN
                      jcasetype ON jcasetype.JCATY_JCaseType_UID = jcase.JCase_JCaseType_ID LEFT OUTER JOIN
                      jcasesubject ON jcasesubject.JCASB_JCaseSubject_UID = jcase.JCase_JCaseSubject_ID LEFT OUTER JOIN
                      juser ON juser.JUser_JUser_UID = jcase.JCase_ResolvedBy_JUser_ID LEFT OUTER JOIN
                      juser juser2 ON juser2.JUser_JUser_UID = jcase.JCase_CreatedBy_JUser_ID LEFT OUTER JOIN
                      juser juser3 ON juser3.JUser_JUser_UID = jcase.JCase_ModifiedBy_JUser_ID
WHERE     (jcase.JCase_Deleted_b <> 1) OR (jcase.JCase_Deleted_b IS NULL)


