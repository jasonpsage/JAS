use jas;
update juser set JUser_Password='';
update juserpreflink set UsrPL_Value='' where UsrPL_UserPrefLink_UID=2012100615163514292;
update juserpreflink set UsrPL_Value='' where UsrPL_UserPrefLink_UID=2012100615164495133;
update juserpreflink set UsrPL_Value='' where UsrPL_UserPrefLink_UID=2012100615162043726;

delete from jaccesslog where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jadodbms where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jadodriver where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jalias where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jasident where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jblog where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jblok where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jblokbutton where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jblokfield where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jbloktype where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jbuttontype where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jcaption where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jcase where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jcasecategory where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jcasesource where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jcasesubject where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jcasetype where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jclickaction where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jcolumn where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jdashboard where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jdconnection where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jdebug;
delete from jdownloadfilelist where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jdtype where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jegaslog;
delete from jerrorlog;
delete from jetname where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jfile;
delete from jfiltersave where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jfiltersavedef where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jhelp where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jiconcontext where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jiconmaster where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jindexfile where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jindustry where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jinstalled where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jinterface where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jinvoice;
delete from jinvoicelines;
delete from jiplist;
delete from jiplistlu where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jipstat where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jjobq;
delete from jjobtype where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jlanguage where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jlead;
delete from jleadsource where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jlock where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jlog;
delete from jlogtype where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jlookup where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jmail;
delete from jmenu where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jmime where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jmodc where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jmodule where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jmoduleconfig where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jmodulesetting where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jnote where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jorg where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jorgpers where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jpassword;
delete from jperson where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jpersonskill where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jprinter where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jpriority where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jproduct where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jproductgrp where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jproductqty where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jproject where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jprojectcategory where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jprojectpriority where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jprojectstatus where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jpunkbait where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jquicklink where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jquicknote where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jredirect where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jredirectlu where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jrequestlog where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jscreen where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jscreentype where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jsecgrp where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jsecgrplink where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jsecgrpuserlink where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jseckey where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jsecperm where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jsecpermuserlink where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jsession where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jsessiondata where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jsessiontype where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jskill where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jstatus where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jsync where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jsysmodule where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jsysmodulelink where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jtable where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jtabletype where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jtask where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jtaskcategory where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jteam where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jteammember where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jtheme where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jthemeicon where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jtimecard where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jtrak where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from juser where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from juserpref where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from juserpreflink where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jvhost where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
delete from jwidget where ((JAS_Row_b = FALSE) or (JAS_ROW_b IS NULL));
/* public_view_jproject */
/* public_view_jtask */
/* view_case */
/* view_inventory */
/* view_invoice */
/* view_lead */
/* view_menu */
/* view_org */
/* view_person */
/* view_project */
/* view_task */
/* view_team */
/* view_time */
/* view_vendor */












