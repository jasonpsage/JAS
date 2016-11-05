CREATE OR REPLACE VIEW view_vendor AS
SELECT
  jcompany.JComp_JCompany_UID as UID,
  jcompany.JComp_Name as Company,
  jcompany2.JComp_Name as ParentCompany,
  concat(jperson.JPers_NameFirst,' ',jperson.JPers_NameMiddle,' ',jperson.JPers_NameLast) as Person,
  jcompany.JComp_Phone as WorkPhone,
  jcompany.JComp_Fax as Fax,
  jcompany.JComp_Email as WorkEmail,
  jcompany.JComp_Website as Website,
  '' as MobilePhone,
  juser.JUser_Name as AssignedTo,
  juser2.JUser_Name as CreatedBy,
  jcompany.JComp_Created_DT as Created,
  juser3.JUser_Name as ModifiedBy,
  jcompany.JComp_Modified_DT as Modified,
  jcompany.JComp_Main_Addr1 as Address1,
  jcompany.JComp_Main_Addr2 as Address2,
  jcompany.JComp_Main_Addr3 as Address3,
  jcompany.JComp_Main_City as City,
  jcompany.JComp_Main_State as State,
  jcompany.JComp_Main_PostalCode as PostalCode,
  jcompany.JComp_Main_Country as Country,
  jcompany.JComp_Main_Longitude_d as Longitude,
  jcompany.JComp_Main_Latitude_d as Latitude,
  jcompany.JComp_Ship_Addr1 as ShipAddress1,
  jcompany.JComp_Ship_Addr2 as ShipAddress2,
  jcompany.JComp_Ship_Addr3 as ShipAddress3,
  jcompany.JComp_Ship_City as ShipCity,
  jcompany.JComp_Ship_State as ShipState,
  jcompany.JComp_Ship_PostalCode as ShipPostalCode,
  jcompany.JComp_Ship_Country as ShipCountry,
  jcompany.JComp_Ship_Longitude_d as ShipLongitude,
  jcompany.JComp_Ship_Latitude_d as ShipLatitude,
  jcompany.JComp_Customer_b as Customer,
  '' as HomeEmail,
  '' as HomePhone


FROM jcompany

LEFT JOIN jperson               ON  jcompany.JComp_Primary_Person_ID=jperson.JPers_JPerson_UID
LEFT JOIN jcompany as jcompany2 ON  jcompany2.JComp_Parent_ID=jcompany2.JComp_JCompany_UID
LEFT JOIN juser                 ON  jcompany.JComp_Owner_JUser_ID=juser.JUser_JUser_UID
LEFT JOIN juser as juser2       ON  jcompany.JComp_CreatedBy_JUser_ID=juser2.JUser_JUser_UID
LEFT JOIN juser as juser3       ON  jcompany.JComp_ModifiedBy_JUser_ID=juser3.JUser_JUser_UID

WHERE((jcompany.JComp_Deleted_b<>true)OR(jcompany.JComp_Deleted_b IS NULL)) AND (jcompany.JComp_Vendor_b=true)



UNION



SELECT
  JPers_JPerson_UID as UID,
  jcompany.JComp_Name as Company,
  '' as ParentCompany,
  concat(jperson.JPers_NameFirst,' ',jperson.JPers_NameMiddle,' ',jperson.JPers_NameLast) as Person,
  JPers_Work_Phone as WorkPhone,
  '' as Fax,
  JPers_Work_Email as WorkEmail,
  '' as Website,
  JPers_Mobile_Phone as MobilePhone,
  '' as AssignedTo,
  juser.JUser_Name as CreatedBy,
  JPers_Created_DT as Created,
  juser2.JUser_Name as ModifiedBy,
  JPers_Modified_DT as Modified,
  JPers_Addr1 as Address1,
  JPers_Addr2 as Address2,
  JPers_Addr3 as Address3,
  JPers_City as City,
  JPers_State as State,
  JPers_PostalCode as PostalCode,
  JPers_Longitude_d as Longitude,
  JPers_Latitude_d as Latitude,
  JPers_Country as Country,
  '' as ShipAddress1,
  '' as ShipAddress2,
  '' as ShipAddress3,
  '' as ShipCity,
  '' as ShipState,
  '' as ShipPostalCode,
  '' as ShipCountry,
  '' as ShipLongitude,
  '' as ShipLatitude,
  JPers_Customer_b as Customer,
  JPers_Home_Email as HomeEmail,
  JPers_Home_Phone as HomePhone

FROM jperson

LEFT JOIN jcompany ON JPers_Primary_Company_ID=JComp_JCompany_UID
LEFT JOIN juser ON JPers_CreatedBy_JUser_ID=juser.JUser_JUser_UID
LEFT JOIN juser as juser2 ON JPers_ModifiedBy_JUser_ID=juser.JUser_JUser_UID

WHERE ((JPers_Deleted_b<>true)OR(JPers_Deleted_b IS NULL)) and (JPers_Vendor_b=true)














