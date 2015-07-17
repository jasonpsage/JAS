CREATE VIEW dbo.view_lead
AS
SELECT     TOP 100 PERCENT dbo.jlead.JLead_JLead_UID, dbo.jlead.JLead_NameSalutation, dbo.jlead.JLead_NameFirst, dbo.jlead.JLead_NameMiddle, 
                      dbo.jlead.JLead_NameLast, dbo.jlead.JLead_NameSuffix, dbo.jlead.JLead_Desc, dbo.jlead.JLead_Gender, dbo.jlead.JLead_Home_Phone, 
                      dbo.jlead.JLead_Mobile_Phone, dbo.jlead.JLead_Work_Email, dbo.jlead.JLead_Work_Phone, dbo.jlead.JLead_Fax, dbo.jlead.JLead_Home_Email, 
                      dbo.jlead.JLead_Website, dbo.jlead.JLead_Main_Addr1, dbo.jlead.JLead_Main_Addr2, dbo.jlead.JLead_Main_Addr3, dbo.jlead.JLead_Main_City, 
                      dbo.jlead.JLead_Main_State, dbo.jlead.JLead_Main_PostalCode, dbo.jlead.JLead_Main_Country, dbo.jlead.JLead_Main_Longitude_d, 
                      dbo.jlead.JLead_Main_Latitude_d, dbo.jlead.JLead_Ship_Addr1, dbo.jlead.JLead_Ship_Addr2, dbo.jlead.JLead_Ship_Addr3, 
                      dbo.jlead.JLead_Ship_City, dbo.jlead.JLead_Ship_State, dbo.jlead.JLead_Ship_PostalCode, dbo.jlead.JLead_Ship_Country, 
                      dbo.jlead.JLead_Ship_Longitude_d, dbo.jlead.JLead_Ship_Latitude_d, dbo.jlead.JLead_CompanyName, 
                      dbo.jcompany.JComp_Name AS CompanyName, 
                      dbo.jperson.JPers_NameFirst + ' ' + dbo.jperson.JPers_NameMiddle + ' ' + dbo.jperson.JPers_NameLast AS Person, dbo.jlead.JLead_LeadSourceAddl, 
                      dbo.jleadsource.JLDSR_Name, dbo.juser.JUser_Name AS Owner, juser2.JUser_Name AS CreatedBy, dbo.jlead.JLead_Created_DT, 
                      juser3.JUser_Name AS ModifiedBy, dbo.jlead.JLead_Modified_DT, dbo.jlead.JLead_Private_b
FROM         dbo.jlead LEFT OUTER JOIN
                      dbo.jcompany ON dbo.jlead.JLead_Exist_JCompany_ID = dbo.jcompany.JComp_JCompany_UID LEFT OUTER JOIN
                      dbo.jperson ON dbo.jlead.JLead_Exist_JPerson_ID = dbo.jperson.JPers_JPerson_UID LEFT OUTER JOIN
                      dbo.jleadsource ON dbo.jlead.JLead_JLeadSource_ID = dbo.jleadsource.JLDSR_JLeadSource_UID LEFT OUTER JOIN
                      dbo.juser ON dbo.jlead.JLead_Owner_JUser_ID = dbo.juser.JUser_JUser_UID LEFT OUTER JOIN
                      dbo.juser juser2 ON dbo.jlead.JLead_CreatedBy_JUser_ID = juser2.JUser_JUser_UID LEFT OUTER JOIN
                      dbo.juser juser3 ON dbo.jlead.JLead_ModifiedBy_JUser_ID = juser3.JUser_JUser_UID
WHERE     (dbo.jlead.JLead_Deleted_b <> 1) OR
                      (dbo.jlead.JLead_Deleted_b IS NULL)
ORDER BY dbo.jlead.JLead_NameFirst

