CREATE OR REPLACE VIEW view_company AS
select
jcompany.JComp_JCompany_UID as CompanyID,
jcompany.JComp_Name as CompanyName,
jcompany.JComp_Phone as Phone,
jcompany.JComp_Fax as Fax,
jcompany.JComp_Email as Email,
jcompany.JComp_Website as Website,
jcompany.JComp_Created_DT as Created,
jcompany.JComp_Modified_DT as Modified,
jcompany.JComp_Desc as Description,
jcompany.JComp_Main_Addr1 as MainAddress1,
jcompany.JComp_Main_Addr2 as MainAddress2,
jcompany.JComp_Main_Addr3 as MainAddress3,
jcompany.JComp_Main_City as MainCity,
jcompany.JComp_Main_State as MainState,
jcompany.JComp_Main_Country as MainCountry,
jcompany.JComp_Main_Longitude_d as MainLongitude,
jcompany.JComp_Main_Latitude_d as MainLatitude,
jcompany.JComp_Main_PostalCode as MainPostalCode,
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
jcompany.JComp_Vendor_b as Vendor,

/* jcompany.JComp_Primary_Person_ID, */
JPers_NameSalutation as PrimaryPersonNameSalutation,
JPers_NameFirst as PrimaryPersonNameFirst,
JPers_NameMiddle as PrimaryPersonNameMiddle,
JPers_NameLast as PrimaryPersonNameLast,
JPers_NameSuffix as PrimaryPersonNameSuffix,
JPers_NameDear as PrimaryPersonNameDear,
JPers_Gender as PrimaryPersonGender,
JPers_Private_b as PrimaryPersonPrivate,
JPers_Work_Phone as PrimaryPersonWorkPhone,
JPers_Work_Email as PrimaryPersonWorkEmail,
JPers_Mobile_Phone as PrimaryPersonMobile,
JPers_Desc as PrimaryPersonDescription,
JPers_Home_Email as PrimaryPersonHomeEmail,
JPers_Home_Phone as PrimaryPersonHomePhone,
JPers_Addr1 as PrimaryPersonAddress1,
JPers_Addr2 as PrimaryPersonAddress2,
JPers_Addr3 as PrimaryPersonAddress3,
JPers_City as PrimaryPersonCity,
JPers_State as PrimaryPersonState,
JPers_PostalCode as PrimaryPersonPostalCode,

/* JPers_Primary_Company_ID, */
jcompany2.JComp_Name as PrimaryCompanyName,

/* jcompany.JComp_Parent_ID, */
jcompany3.JComp_Name as ParentCompanyName,

/* jcompany.JComp_Owner_JUser_ID, */
juser.JUser_Name as Owner,

/* jcompany.JComp_CreatedBy_JUser_ID, */
juser2.JUser_Name as CreatedBy,

/* jcompany.JComp_ModifiedBy_JUser_ID */
juser3.JUser_Name as ModifiedBy

from jcompany

left join jperson on JPers_JPerson_UID=JComp_Primary_Person_ID
left join jcompany as jcompany2 on JPers_Primary_Company_ID=jcompany2.JComp_JCompany_UID
left join jcompany as jcompany3 on jcompany.JComp_Parent_ID=jcompany3.JComp_JCompany_UID
left join juser on juser.JUser_JUser_UID = jcompany.JComp_Owner_JUser_ID
left join juser as juser2 on juser2.JUser_JUser_UID = jcompany.JComp_CreatedBy_JUser_ID
left join juser as juser3 on juser3.JUser_JUser_UID = jcompany.JComp_ModifiedBy_JUser_ID


where
((jcompany.JComp_Deleted_b<>true) OR (jcompany.JComp_Deleted_b IS NULL))

ORDER BY jcompany.JComp_Name
