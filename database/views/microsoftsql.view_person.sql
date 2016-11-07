CREATE VIEW dbo.view_person
AS
SELECT     TOP 100 PERCENT dbo.jperson.JPers_JPerson_UID, dbo.jperson.JPers_NameSalutation, dbo.jperson.JPers_NameFirst, 
                      dbo.jperson.JPers_NameMiddle, dbo.jperson.JPers_NameLast, dbo.jperson.JPers_NameSuffix, dbo.jperson.JPers_NameDear, 
                      dbo.jperson.JPers_Gender, dbo.jperson.JPers_Private_b, dbo.jcompany.JComp_Name, dbo.jperson.JPers_Work_Phone, 
                      dbo.jperson.JPers_Work_Email, dbo.jperson.JPers_Mobile_Phone, dbo.juser.JUser_Name AS CreatedBy, dbo.jperson.JPers_Created_DT, 
                      juser2.JUser_Name AS ModifiedBy, dbo.jperson.JPers_Modified_DT, dbo.jperson.JPers_Desc, dbo.jperson.JPers_Home_Email, 
                      dbo.jperson.JPers_Home_Phone, dbo.jperson.JPers_Addr1, dbo.jperson.JPers_Addr2, dbo.jperson.JPers_Addr3, dbo.jperson.JPers_City, 
                      dbo.jperson.JPers_State, dbo.jperson.JPers_PostalCode, dbo.jperson.JPers_Longitude_d, dbo.jperson.JPers_Latitude_d, 
                      dbo.jperson.JPers_Customer_b, dbo.jperson.JPers_Country, dbo.jperson.JPers_Vendor_b, dbo.jperson.JPers_DOB_DT
FROM         dbo.jperson LEFT OUTER JOIN
                      dbo.jcompany ON dbo.jperson.JPers_Primary_Company_ID = dbo.jcompany.JComp_JCompany_UID LEFT OUTER JOIN
                      dbo.juser ON dbo.jperson.JPers_CreatedBy_JUser_ID = dbo.juser.JUser_JUser_UID LEFT OUTER JOIN
                      dbo.juser juser2 ON dbo.jperson.JPers_ModifiedBy_JUser_ID = dbo.juser.JUser_JUser_UID
WHERE     (dbo.jperson.JPers_Deleted_b <> 1) OR
                      (dbo.jperson.JPers_Deleted_b IS NULL)
ORDER BY dbo.jperson.JPers_NameFirst

