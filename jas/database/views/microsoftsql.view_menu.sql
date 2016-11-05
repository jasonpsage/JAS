CREATE VIEW dbo.view_menu
AS
SELECT     TOP 100 PERCENT dbo.jmenu.JMenu_JMenu_UID AS UID, dbo.jmenu.JMenu_Name_en AS Name, dbo.jmenu.JMenu_Title_en AS Title,
                      jmenu2.JMenu_JMenu_UID AS ParentUID, jmenu2.JMenu_Name_en AS ParentName, jmenu2.JMenu_Title_en AS ParentTitle,
                      dbo.jmenu.JMenu_URL AS URL, dbo.jsecperm.JSPrm_Name AS RequiredPermission, dbo.jmenu.JMenu_NewWindow_b AS NewWindow,
                      dbo.jmenu.JMenu_SEQ_u AS Position, dbo.jmenu.JMenu_IconSmall AS SmallIcon,
                      dbo.jmenu.JMenu_IconSmall_Theme_b AS SmallIconUsesIconTheme, dbo.jmenu.JMenu_IconLarge AS LargeIcon,
                      dbo.jmenu.JMenu_IconLarge_Theme_b AS LargeIconUsesIconTheme, dbo.jmenu.JMenu_ValidSessionOnly_b AS ValidSessionOnly,
                      dbo.jmenu.JMenu_DisplayIfNoAccess_b AS DisplayIfNoAccess, dbo.jmenu.JMenu_DisplayIfValidSession_b AS DisplayIfValidSession,
                      dbo.jmenu.JMenu_ReadMore_b AS AllowReadMoreButton, dbo.jmenu.JMenu_Data_en AS Data, dbo.jmenu.JMenu_CreatedBy_JUser_ID AS CreatedBy,
                      dbo.jmenu.JMenu_Created_DT AS Created, dbo.jmenu.JMenu_ModifiedBy_JUser_ID AS ModifiedBy, dbo.jmenu.JMenu_Modified_DT AS Modified
FROM         dbo.jmenu LEFT OUTER JOIN
                      dbo.jmenu jmenu2 ON dbo.jmenu.JMenu_JMenuParent_ID = jmenu2.JMenu_JMenu_UID LEFT OUTER JOIN
                      dbo.juser ON dbo.juser.JUser_JUser_UID = dbo.jmenu.JMenu_CreatedBy_JUser_ID LEFT OUTER JOIN
                      dbo.juser juser2 ON juser2.JUser_JUser_UID = dbo.jmenu.JMenu_ModifiedBy_JUser_ID LEFT OUTER JOIN
                      dbo.jsecperm ON dbo.jsecperm.JSPrm_JSecPerm_UID = dbo.jmenu.JMenu_JSecPerm_ID
WHERE     (dbo.jmenu.JMenu_Deleted_b <> 1) OR
                      (dbo.jmenu.JMenu_Deleted_b IS NULL)
ORDER BY dbo.jmenu.JMenu_Name_en


