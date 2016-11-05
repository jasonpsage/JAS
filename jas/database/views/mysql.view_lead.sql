CREATE OR REPLACE VIEW view_lead AS
SELECT
  JLead_JLead_UID,
  JLead_NameSalutation,
  JLead_NameFirst,
  JLead_NameMiddle,
  JLead_NameLast,
  JLead_NameSuffix,
  JLead_Desc,
  JLead_Gender,
  JLead_Home_Phone,
  JLead_Mobile_Phone,
  JLead_Work_Email,
  JLead_Work_Phone,
  JLead_Fax,
  JLead_Home_Email,
  JLead_Website,
  JLead_Main_Addr1,
  JLead_Main_Addr2,
  JLead_Main_Addr3,
  JLead_Main_City,
  JLead_Main_State,
  JLead_Main_PostalCode,
  JLead_Main_Country,
  JLead_Main_Longitude_d,
  JLead_Main_Latitude_d,
  JLead_Ship_Addr1,
  JLead_Ship_Addr2,
  JLead_Ship_Addr3,
  JLead_Ship_City,
  JLead_Ship_State,
  JLead_Ship_PostalCode,
  JLead_Ship_Country,
  JLead_Ship_Longitude_d,
  JLead_Ship_Latitude_d,
  JLead_CompanyName,

  /* JLead_Exist_JCompany_ID, */
  jcompany.JComp_Name as CompanyName,

  /* JLead_Exist_JPerson_ID, */
  CONCAT(jperson.JPers_NameFirst,' ',jperson.JPers_NameMiddle,' ',jperson.JPers_NameLast) as Person,

  JLead_LeadSourceAddl,

  /* JLead_JLeadSource_ID, */
  jleadsource.JLDSR_Name,

  /* JLead_Owner_JUser_ID, */
  juser.JUser_Name as Owner,

  /* JLead_CreatedBy_JUser_ID, */
  juser2.JUser_Name as CreatedBy,

  JLead_Created_DT,

  /* JLead_ModifiedBy_JUser_ID, */
  juser3.JUser_Name as ModifiedBy,

  JLead_Modified_DT,
  JLead_Private_b

FROM jlead

LEFT JOIN jorg on JLead_Exist_JCompany_ID=jcompany.JComp_JCompany_UID
LEFT JOIN jperson on JLead_Exist_JPerson_ID=jperson.JPers_JPerson_UID
LEFT JOIN jleadsource on JLead_JLeadSource_ID=jleadsource.JLDSR_JLeadSource_UID
LEFT JOIN juser on JLead_Owner_JUser_ID=juser.JUser_JUser_UID
LEFT JOIN juser as juser2 on JLead_CreatedBy_JUser_ID=juser2.JUser_JUser_UID
LEFT JOIN juser as juser3 on JLead_ModifiedBy_JUser_ID=juser3.JUser_JUser_UID

WHERE ((JLead_Deleted_b<>true)OR(JLead_Deleted_b IS NULL))

ORDER BY JLead_NameFirst



