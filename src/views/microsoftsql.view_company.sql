CREATE VIEW dbo.view_company
AS
SELECT     TOP 100 PERCENT dbo.jcompany.JComp_JCompany_UID AS CompanyID, dbo.jcompany.JComp_Name AS CompanyName,
                      dbo.jcompany.JComp_Phone AS Phone, dbo.jcompany.JComp_Fax AS Fax, dbo.jcompany.JComp_Email AS Email,
                      dbo.jcompany.JComp_Website AS Website, dbo.jcompany.JComp_Created_DT AS Created, dbo.jcompany.JComp_Modified_DT AS Modified,
                      dbo.jcompany.JComp_Desc AS Description, dbo.jcompany.JComp_Main_Addr1 AS MainAddress1, dbo.jcompany.JComp_Main_Addr2 AS MainAddress2,
                       dbo.jcompany.JComp_Main_Addr3 AS MainAddress3, dbo.jcompany.JComp_Main_City AS MainCity, dbo.jcompany.JComp_Main_State AS MainState,
                      dbo.jcompany.JComp_Main_Country AS MainCountry, dbo.jcompany.JComp_Main_Longitude_d AS MainLongitude,
                      dbo.jcompany.JComp_Main_Latitude_d AS MainLatitude, dbo.jcompany.JComp_Main_PostalCode AS MainPostalCode,
                      dbo.jcompany.JComp_Ship_Addr1 AS ShipAddress1, dbo.jcompany.JComp_Ship_Addr2 AS ShipAddress2,
                      dbo.jcompany.JComp_Ship_Addr3 AS ShipAddress3, dbo.jcompany.JComp_Ship_City AS ShipCity, dbo.jcompany.JComp_Ship_State AS ShipState,
                      dbo.jcompany.JComp_Ship_PostalCode AS ShipPostalCode, dbo.jcompany.JComp_Ship_Country AS ShipCountry,
                      dbo.jcompany.JComp_Ship_Longitude_d AS ShipLongitude, dbo.jcompany.JComp_Ship_Latitude_d AS ShipLatitude,
                      dbo.jcompany.JComp_Customer_b AS Customer, dbo.jcompany.JComp_Vendor_b AS Vendor,
                      dbo.jperson.JPers_NameSalutation AS PrimaryPersonNameSalutation, dbo.jperson.JPers_NameFirst AS PrimaryPersonNameFirst,
                      dbo.jperson.JPers_NameMiddle AS PrimaryPersonNameMiddle, dbo.jperson.JPers_NameLast AS PrimaryPersonNameLast,
                      dbo.jperson.JPers_NameSuffix AS PrimaryPersonNameSuffix, dbo.jperson.JPers_NameDear AS PrimaryPersonNameDear,
                      dbo.jperson.JPers_Gender AS PrimaryPersonGender, dbo.jperson.JPers_Private_b AS PrimaryPersonPrivate,
                      dbo.jperson.JPers_Work_Phone AS PrimaryPersonWorkPhone, dbo.jperson.JPers_Work_Email AS PrimaryPersonWorkEmail,
                      dbo.jperson.JPers_Mobile_Phone AS PrimaryPersonMobile, dbo.jperson.JPers_Desc AS PrimaryPersonDescription,
                      dbo.jperson.JPers_Home_Email AS PrimaryPersonHomeEmail, dbo.jperson.JPers_Home_Phone AS PrimaryPersonHomePhone,
                      dbo.jperson.JPers_Addr1 AS PrimaryPersonAddress1, dbo.jperson.JPers_Addr2 AS PrimaryPersonAddress2,
                      dbo.jperson.JPers_Addr3 AS PrimaryPersonAddress3, dbo.jperson.JPers_City AS PrimaryPersonCity, dbo.jperson.JPers_State AS PrimaryPersonState,
                      dbo.jperson.JPers_PostalCode AS PrimaryPersonPostalCode, jcompany2.JComp_Name AS PrimaryCompanyName,
                      jcompany3.JComp_Name AS ParentCompanyName, dbo.juser.JUser_Name AS Owner, juser2.JUser_Name AS CreatedBy,
                      juser3.JUser_Name AS ModifiedBy
FROM         dbo.jcompany LEFT OUTER JOIN
                      dbo.jperson ON dbo.jperson.JPers_JPerson_UID = dbo.jcompany.JComp_Primary_Person_ID LEFT OUTER JOIN
                      dbo.jcompany jcompany2 ON dbo.jperson.JPers_Primary_Company_ID = jcompany2.JComp_JCompany_UID LEFT OUTER JOIN
                      dbo.jcompany jcompany3 ON dbo.jcompany.JComp_Parent_ID = jcompany3.JComp_JCompany_UID LEFT OUTER JOIN
                      dbo.juser ON dbo.juser.JUser_JUser_UID = dbo.jcompany.JComp_Owner_JUser_ID LEFT OUTER JOIN
                      dbo.juser juser2 ON juser2.JUser_JUser_UID = dbo.jcompany.JComp_CreatedBy_JUser_ID LEFT OUTER JOIN
                      dbo.juser juser3 ON juser3.JUser_JUser_UID = dbo.jcompany.JComp_ModifiedBy_JUser_ID
WHERE     (dbo.jcompany.JComp_Deleted_b <> 1) OR
                      (dbo.jcompany.JComp_Deleted_b IS NULL)
ORDER BY dbo.jcompany.JComp_Name


