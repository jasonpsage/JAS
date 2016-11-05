CREATE VIEW dbo.view_team
AS
SELECT     TOP 100 PERCENT dbo.jteam.JTeam_JTeam_UID AS TeamUID, dbo.jteam.JTeam_Name AS Name, dbo.jteam.JTeam_Desc AS Description, 
                      jteam2.JTeam_Name AS ParentTeam, dbo.jcompany.JComp_Name AS Company, dbo.juser.JUser_Name AS TeamCreatedBy, 
                      dbo.jteam.JTeam_Created_DT AS TeamCreated, jteam2.JTeam_ModifiedBy_JUser_ID AS TeamModifiedBy, 
                      dbo.jteam.JTeam_Modified_DT AS TeamModified, dbo.jteammember.JTMem_JTeamMember_UID AS MemberUID, 
                      dbo.jperson.JPers_NameFirst + ' ' + dbo.jperson.JPers_NameMiddle + ' ' + dbo.jperson.JPers_NameLast AS Person, 
                      jcompany2.JComp_Name AS TeamCompany, juser3.JUser_Name AS MemberLogin, dbo.jteammember.JTMem_CreatedBy_JUser_ID, 
                      juser4.JUser_Name AS MemberCreatedBy, dbo.jteammember.JTMem_Created_DT AS MemberCreated, juser5.JUser_Name AS MemberModifiedBy, 
                      dbo.jteammember.JTMem_Modified_DT AS MemberModified
FROM         dbo.jteam LEFT OUTER JOIN
                      dbo.jteammember ON dbo.jteam.JTeam_JTeam_UID = dbo.jteammember.JTMem_JTeam_ID LEFT OUTER JOIN
                      dbo.jteam jteam2 ON dbo.jteam.JTeam_Parent_JTeam_ID = jteam2.JTeam_JTeam_UID LEFT OUTER JOIN
                      dbo.jcompany ON dbo.jteam.JTeam_JCompany_ID = dbo.jcompany.JComp_JCompany_UID LEFT OUTER JOIN
                      dbo.jcompany jcompany2 ON dbo.jteammember.JTMem_JCompany_ID = jcompany2.JComp_JCompany_UID LEFT OUTER JOIN
                      dbo.juser ON dbo.jteam.JTeam_CreatedBy_JUser_ID = dbo.juser.JUser_JUser_UID LEFT OUTER JOIN
                      dbo.juser juser2 ON dbo.jteam.JTeam_ModifiedBy_JUser_ID = juser2.JUser_JUser_UID LEFT OUTER JOIN
                      dbo.juser juser3 ON dbo.jteammember.JTMem_JUser_ID = juser3.JUser_JUser_UID LEFT OUTER JOIN
                      dbo.juser juser4 ON dbo.jteammember.JTMem_CreatedBy_JUser_ID = juser4.JUser_JUser_UID LEFT OUTER JOIN
                      dbo.juser juser5 ON dbo.jteammember.JTMem_ModifiedBy_JUser_ID = juser5.JUser_JUser_UID LEFT OUTER JOIN
                      dbo.jperson ON dbo.jteammember.JTMem_JPerson_ID = dbo.jperson.JPers_JPerson_UID
WHERE     (dbo.jteam.JTeam_Deleted_b <> 1 OR
                      dbo.jteam.JTeam_Deleted_b IS NULL) AND (dbo.jteammember.JTMem_Deleted_b <> 1 OR
                      dbo.jteammember.JTMem_Deleted_b IS NULL)
ORDER BY dbo.jteam.JTeam_Name, dbo.jperson.JPers_NameFirst + ' ' + dbo.jperson.JPers_NameMiddle + ' ' + dbo.jperson.JPers_NameLast

