CREATE OR REPLACE VIEW view_person AS
select
  jperson.JPers_JPerson_UID,
  jperson.JPers_NameSalutation,
  jperson.JPers_NameFirst,
  jperson.JPers_NameMiddle,
  jperson.JPers_NameLast,
  jperson.JPers_NameSuffix,
  jperson.JPers_NameDear,
  jperson.JPers_Gender,
  jperson.JPers_Private_b,
  
  /* jperson.JPers_Primary_Company_ID, */
  jcompany.JComp_Name,
  
  jperson.JPers_Work_Phone,
  jperson.JPers_Work_Email,
  jperson.JPers_Mobile_Phone,
  
  /* jperson.JPers_CreatedBy_JUser_ID, */
  juser.JUser_Name as CreatedBy,
  
  jperson.JPers_Created_DT,

  /* jperson.JPers_ModifiedBy_JUser_ID,*/
  juser2.JUser_Name as ModifiedBy,
  
  jperson.JPers_Modified_DT,
  jperson.JPers_Desc,
  jperson.JPers_Home_Email,
  jperson.JPers_Home_Phone,
  jperson.JPers_Addr1,
  jperson.JPers_Addr2,
  jperson.JPers_Addr3,
  jperson.JPers_City,
  jperson.JPers_State,
  jperson.JPers_PostalCode,
  jperson.JPers_Longitude_d,
  jperson.JPers_Latitude_d,
  jperson.JPers_Customer_b,
  jperson.JPers_Country,
  jperson.JPers_Vendor_b,
  jperson.JPers_DOB_DT


from
  jperson

left join jcompany on jperson.JPers_Primary_Company_ID=jcompany.JComp_JCompany_UID
left join juser on jperson.JPers_CreatedBy_JUser_ID=juser.JUser_JUser_UID
left join juser as juser2 on jperson.JPers_ModifiedBy_JUser_ID=juser.JUser_JUser_UID

where ((JPers_Deleted_b<>true)OR(JPers_Deleted_b IS NULL))

ORDER BY jperson.JPers_NameFirst


