CREATE OR REPLACE VIEW view_menu AS 
SELECT
  jmenu.JMenu_JMenu_UID as UID,
  jmenu.JMenu_Name_en as Name,
  jmenu.JMenu_Title_en as Title,

  jmenu2.JMenu_JMenu_UID as ParentUID,
  jmenu2.JMenu_Name_en as ParentName,
  jmenu2.JMenu_Title_en as ParentTitle,

  jmenu.JMenu_URL as URL,

  JSPrm_Name as RequiredPermission,

  jmenu.JMenu_NewWindow_b as NewWindow,
  jmenu.JMenu_SEQ_u as Position,
  jmenu.JMenu_IconSmall as SmallIcon,
  jmenu.JMenu_IconSmall_Theme_b as SmallIconUsesIconTheme,
  jmenu.JMenu_IconLarge as LargeIcon,
  jmenu.JMenu_IconLarge_Theme_b as LargeIconUsesIconTheme,
  jmenu.JMenu_ValidSessionOnly_b as ValidSessionOnly,
  jmenu.JMenu_DisplayIfNoAccess_b as DisplayIfNoAccess,
  jmenu.JMenu_DisplayIfValidSession_b as DisplayIfValidSession,
  jmenu.JMenu_ReadMore_b as AllowReadMoreButton,
  jmenu.JMenu_Data_en as Data,
  jmenu.JMenu_CreatedBy_JUser_ID as CreatedBy,
  jmenu.JMenu_Created_DT as Created,
  jmenu.JMenu_ModifiedBy_JUser_ID as ModifiedBy,
  jmenu.JMenu_Modified_DT as Modified

FROM jmenu

LEFT JOIN jmenu as jmenu2 on jmenu.JMenu_JMenuParent_ID=jmenu2.JMenu_JMenu_UID
LEFT JOIN juser on juser.JUser_JUser_UID=jmenu.JMenu_CreatedBy_JUser_ID
LEFT JOIN juser as juser2 on juser2.JUser_JUser_UID=jmenu.JMenu_ModifiedBy_JUser_ID
LEFT JOIN jsecperm on JSPrm_JSecPerm_UID=jmenu.JMenu_JSecPerm_ID

WHERE ((jmenu.JMenu_Deleted_b<>true)OR(jmenu.JMenu_Deleted_b IS NULL))
ORDER BY jmenu.JMenu_Name_en; 
