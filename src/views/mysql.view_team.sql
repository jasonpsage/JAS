CREATE OR REPLACE VIEW view_team AS
SELECT
  jteam.JTeam_JTeam_UID as TeamUID,
  jteam.JTeam_Name as Name,
  jteam.JTeam_Desc as Description,
  jteam2.JTeam_Name as ParentTeam,
  jcompany.JComp_Name as Company,
  juser.JUser_Name as TeamCreatedBy,
  jteam.JTeam_Created_DT as TeamCreated,
  jteam2.JTeam_ModifiedBy_JUser_ID as TeamModifiedBy,
  jteam.JTeam_Modified_DT as TeamModified,
  JTMem_JTeamMember_UID as MemberUID,
  CONCAT(jperson.JPers_NameFirst,' ',jperson.JPers_NameMiddle,' ',jperson.JPers_NameLast) as Person,
  jcompany2.JComp_Name as TeamCompany,
  juser3.JUser_Name as MemberLogin,
  JTMem_CreatedBy_JUser_ID,
  juser4.JUser_Name as MemberCreatedBy,
  JTMem_Created_DT as MemberCreated,
  juser5.JUser_Name as MemberModifiedBy,
  JTMem_Modified_DT as MemberModified

FROM jteam

LEFT JOIN jteammember     ON jteam.JTeam_JTeam_UID           = JTMem_JTeam_ID
LEFT JOIN jteam AS jteam2 ON jteam.JTeam_Parent_JTeam_ID     = jteam2.JTeam_JTeam_UID
LEFT JOIN jcompany        ON jteam.JTeam_JCompany_ID         = jcompany.JComp_JCompany_UID
LEFT JOIN jcompany as jcompany2 ON JTMem_JCompany_ID         = jcompany2.JComp_JCompany_UID
LEFT JOIN juser           ON jteam.JTeam_CreatedBy_JUser_ID  = juser.JUser_JUSer_UID
LEFT JOIN juser AS juser2 ON jteam.JTeam_ModifiedBy_JUser_ID = juser2.JUser_JUSer_UID
LEFT JOIN juser AS juser3 ON JTMem_JUser_ID                  = juser3.JUser_JUSer_UID
LEFT JOIN juser AS juser4 ON JTMem_CreatedBy_JUser_ID        = juser4.JUser_JUSer_UID
LEFT JOIN juser AS juser5 ON JTMem_ModifiedBy_JUser_ID       = juser5.JUser_JUSer_UID
LEFt JOIN jperson on JTMem_JPerson_ID=JPers_JPerson_UID

WHERE ((jteam.JTeam_Deleted_b<>true)OR(jteam.JTeam_Deleted_b IS NULL)) AND
      ((jteammember.JTMem_Deleted_b<>true)OR(jteammember.JTMem_Deleted_b IS NULL))

ORDER BY jteam.JTeam_Name, CONCAT(jperson.JPers_NameFirst,' ',jperson.JPers_NameMiddle,' ',jperson.JPers_NameLast)