CREATE OR REPLACE VIEW view_vendor AS
SELECT     jcompany.JComp_JCompany_UID AS UID, jcompany.JComp_Name AS Company, jcompany2.JComp_Name AS ParentCompany, 
                      jperson.JPers_NameFirst + ' ' + jperson.JPers_NameMiddle + ' ' + jperson.JPers_NameLast AS Person, jcompany.JComp_Phone AS WorkPhone, 
                      jcompany.JComp_Fax AS Fax, jcompany.JComp_Email AS WorkEmail, jcompany.JComp_Website AS Website, '' AS MobilePhone, 
                      juser.JUser_Name AS AssignedTo, juser2.JUser_Name AS CreatedBy, jcompany.JComp_Created_DT AS Created, juser3.JUser_Name AS ModifiedBy, 
                      jcompany.JComp_Modified_DT AS Modified, jcompany.JComp_Main_Addr1 AS Address1, jcompany.JComp_Main_Addr2 AS Address2, 
                      jcompany.JComp_Main_Addr3 AS Address3, jcompany.JComp_Main_City AS City, jcompany.JComp_Main_State AS State, 
                      jcompany.JComp_Main_PostalCode AS PostalCode, jcompany.JComp_Main_Country AS Country, jcompany.JComp_Main_Longitude_d AS Longitude, 
                      jcompany.JComp_Main_Latitude_d AS Latitude, jcompany.JComp_Ship_Addr1 AS ShipAddress1, jcompany.JComp_Ship_Addr2 AS ShipAddress2, 
                      jcompany.JComp_Ship_Addr3 AS ShipAddress3, jcompany.JComp_Ship_City AS ShipCity, jcompany.JComp_Ship_State AS ShipState, 
                      jcompany.JComp_Ship_PostalCode AS ShipPostalCode, jcompany.JComp_Ship_Country AS ShipCountry, 
                      jcompany.JComp_Ship_Longitude_d AS ShipLongitude, jcompany.JComp_Ship_Latitude_d AS ShipLatitude, 
                      jcompany.JComp_Customer_b AS Customer, '' AS HomeEmail, '' AS HomePhone
FROM         jcompany LEFT JOIN
                      jperson ON jcompany.JComp_Primary_Person_ID = jperson.JPers_JPerson_UID LEFT JOIN
                      jcompany AS jcompany2 ON jcompany2.JComp_Parent_ID = jcompany2.JComp_JCompany_UID LEFT JOIN
                      juser ON jcompany.JComp_Owner_JUser_ID = juser.JUser_JUser_UID LEFT JOIN
                      juser AS juser2 ON jcompany.JComp_CreatedBy_JUser_ID = juser2.JUser_JUser_UID LEFT JOIN
                      juser AS juser3 ON jcompany.JComp_ModifiedBy_JUser_ID = juser3.JUser_JUser_UID
WHERE     ((jcompany.JComp_Deleted_b <> 1) OR
                      (jcompany.JComp_Deleted_b IS NULL)) AND (jcompany.JComp_Vendor_b = 1)
UNION
SELECT     JPers_JPerson_UID AS UID, jcompany.JComp_Name AS Company, '' AS ParentCompany, 
                      jperson.JPers_NameFirst + ' ' + jperson.JPers_NameMiddle + ' ' + jperson.JPers_NameLast AS Person, JPers_Work_Phone AS WorkPhone, '' AS Fax, 
                      JPers_Work_Email AS WorkEmail, '' AS Website, JPers_Mobile_Phone AS MobilePhone, '' AS AssignedTo, juser.JUser_Name AS CreatedBy, 
                      JPers_Created_DT AS Created, juser2.JUser_Name AS ModifiedBy, JPers_Modified_DT AS Modified, JPers_Addr1 AS Address1, 
                      JPers_Addr2 AS Address2, JPers_Addr3 AS Address3, JPers_City AS City, JPers_State AS State, JPers_PostalCode AS PostalCode, 
                      JPers_Longitude_d AS Longitude, JPers_Latitude_d AS Latitude, JPers_Country AS Country, '' AS ShipAddress1, '' AS ShipAddress2, 
                      '' AS ShipAddress3, '' AS ShipCity, '' AS ShipState, '' AS ShipPostalCode, '' AS ShipCountry, '' AS ShipLongitude, '' AS ShipLatitude, 
                      JPers_Customer_b AS Customer, JPers_Home_Email AS HomeEmail, JPers_Home_Phone AS HomePhone
FROM         jperson LEFT JOIN
                      jcompany ON JPers_Primary_Company_ID = JComp_JCompany_UID LEFT JOIN
                      juser ON JPers_CreatedBy_JUser_ID = juser.JUser_JUser_UID LEFT JOIN
                      juser AS juser2 ON JPers_ModifiedBy_JUser_ID = juser.JUser_JUser_UID
WHERE     ((JPers_Deleted_b <> 1) OR
                      (JPers_Deleted_b IS NULL)) AND (JPers_Vendor_b = 1)