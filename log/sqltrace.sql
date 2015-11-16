"True ","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'admin',1)
"True ","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,1506121556140240002,0,'admin',1)
"True ","DELETE FROM jlock where JLock_JDConnection_ID=0 and JLock_Table_ID=44 and JLock_Row_ID=0 and JLock_Col_ID=0
---------------------------------------






















"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","SELECT JScrn_JScreen_UID from jscreen WHERE JScrn_Deleted_b<>1 and JScrn_JScreen_UID=30
"True ","select * from jscreen where JScrn_JScreen_UID=30
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1963
"True ","SELECT   JBlok_JBlok_UID from jblok where   JBlok_JScreen_ID=30 AND   JBlok_Deleted_b<>1 ORDER BY JBlok_Position_u
"True ","select * from jblok where JBlok_JBlok_UID=45
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2550
"True ","select * from jtable where JTabl_JTable_UID=44
"True ","select JColu_Name from jcolumn where JColu_Deleted_b<>1 and JColu_JColumn_UID=null
"True ","select JBlkB_JBlokButton_UID from jblokbutton where JBlkB_JBlok_ID=45 AND JBlkB_Deleted_b<>1 ORDER BY JBlkB_Position_u
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=150
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=10
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=146
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=5
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=1920
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4054
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=148
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=7
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=149
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=8
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=1921
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4055
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=147
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=6
"True ","select JBlkF_JBlokField_UID from jblokfield where JBlkF_JBlok_ID=45 AND JBlkF_Deleted_b<>1 ORDER BY JBlkF_Position_u
"True ","select * from jblokfield where JBlkF_JBlokField_UID=623
"True ","select * from jcolumn where JColu_JColumn_UID=436
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1891
"True ","select * from jblokfield where JBlkF_JBlokField_UID=624
"True ","select * from jcolumn where JColu_JColumn_UID=437
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1893
"True ","select * from jblokfield where JBlkF_JBlokField_UID=625
"True ","select * from jcolumn where JColu_JColumn_UID=438
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1892
"True ","select * from jblokfield where JBlkF_JBlokField_UID=622
"True ","select * from jcolumn where JColu_JColumn_UID=435
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2012040717343336567
"True ","select * from jblokfield where JBlkF_JBlokField_UID=626
"True ","select * from jcolumn where JColu_JColumn_UID=439
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1986
"True ","select * from jblokfield where JBlkF_JBlokField_UID=627
"True ","select * from jcolumn where JColu_JColumn_UID=440
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1987
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7380
"True ","select * from jcolumn where JColu_JColumn_UID=446
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3952
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7382
"True ","select * from jcolumn where JColu_JColumn_UID=2576
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3951
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7383
"True ","select * from jcolumn where JColu_JColumn_UID=449
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3953
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7381
"True ","select * from jcolumn where JColu_JColumn_UID=447
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3949
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7384
"True ","select * from jcolumn where JColu_JColumn_UID=2575
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3950
"True ","select * from jblokfield where JBlkF_JBlokField_UID=630
"True ","select * from jcolumn where JColu_JColumn_UID=443
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1964
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012040910383165961
"True ","select * from jcolumn where JColu_JColumn_UID=2012040910312100253
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2693
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012041619385287426
"True ","select * from jcolumn where JColu_JColumn_UID=2012041619364442490
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4120
"True ","select * from jblokfield where JBlkF_JBlokField_UID=629
"True ","select * from jcolumn where JColu_JColumn_UID=442
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1989
"True ","select * from jblokfield where JBlkF_JBlokField_UID=6117
"True ","select * from jcolumn where JColu_JColumn_UID=2353
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1937
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012041609170596679
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2529
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012050218594616247
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4234
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7389
"True ","select * from jcolumn where JColu_JColumn_UID=2589
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3954
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7390
"True ","select * from jcolumn where JColu_JColumn_UID=2590
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3955
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7391
"True ","select * from jcolumn where JColu_JColumn_UID=2591
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3956
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7392
"True ","select * from jcolumn where JColu_JColumn_UID=2592
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3960
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7393
"True ","select * from jcolumn where JColu_JColumn_UID=2593
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3961
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7394
"True ","select * from jcolumn where JColu_JColumn_UID=2594
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3962
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012041420243204087
"True ","select * from jcolumn where JColu_JColumn_UID=2012041420240651587
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2012041420513148043
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7395
"True ","select * from jcolumn where JColu_JColumn_UID=2595
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3971
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7396
"True ","select * from jcolumn where JColu_JColumn_UID=2596
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3972
"True ","select * from jblokfield where JBlkF_JBlokField_UID=620
"True ","select * from jcolumn where JColu_JColumn_UID=433
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1894
"True ","select JColu_JColumn_UID from jcolumn where JColu_JTable_ID=44 and JColu_PrimaryKey_b=1
"True ","select * from jcolumn where JColu_JColumn_UID=433
"True ","describe `jperson`
"True ","describe `jperson`
"True ","describe `jperson`
"True ","describe `jperson`
"True ","describe `jperson`
"True ","describe `jperson`
"True ","describe `jperson`
"True ","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,1506121556140240002,0,'admin',1)
"True ","DELETE FROM jlock where JLock_JDConnection_ID=0 and JLock_Table_ID=44 and JLock_Row_ID=0 and JLock_Col_ID=0
"True ","select JTabl_Add_JSecPerm_ID, JTabl_Update_JSecPerm_ID, JTabl_View_JSecPerm_ID, JTabl_Delete_JSecPerm_ID  FROM jtable WHERE UCASE(JTabl_Name)=UCASE('jperson')
"True ","describe `jperson`
"True ","describe `jperson`
"True ","select `JPers_CreatedBy_JUser_ID` from `jperson` where `JPers_JPerson_UID`=1506121556140240002
"True ","SELECT `JPers_NameFirst`, `JPers_NameMiddle`, `JPers_NameLast`, `JPers_NameSalutation`, `JPers_NameSuffix`, `JPers_NameDear`, `JPers_Work_Phone`, `JPers_Home_Phone`, `JPers_Mobile_Phone`, `JPers_Work_Email`, `JPers_Home_Email`, `JPers_Primary_Company_ID`, `JPers_Customer_b`, `JPers_Vendor_b`, `JPers_Private_b`, `JPers_Desc`, `JPers_Addr1`, `JPers_Addr2`, `JPers_Addr3`, `JPers_City`, `JPers_State`, `JPers_PostalCode`, `JPers_Country`, `JPers_Longitude_d`, `JPers_Latitude_d`, `JPers_JPerson_UID` FROM jperson WHERE JPers_JPerson_UID=1506121556140240002
"True ","SELECT JColu_LU_JColumn_ID, JColu_LUF_Value FROM jcolumn WHERE JColu_Deleted_b<>1 AND JColu_JTable_ID=44 AND JColu_Name='JPers_Primary_Company_ID'
"True ","SELECT JColu_LD_SQL, JColu_LD_CaptionRules_b FROM jcolumn WHERE JColu_Deleted_b<>1 AND JColu_JColumn_UID=217
"True ","SELECT JComp_Name as DisplayMe, JComp_JCompany_UID as ColumnValue FROM jcompany WHERE ((JComp_Deleted_b<>true) or (JComp_Deleted_b is null))   ORDER BY JComp_Name
"True ","SELECT JColu_LU_JColumn_ID, JColu_LUF_Value FROM jcolumn WHERE JColu_Deleted_b<>1 AND JColu_JTable_ID=44 AND JColu_Name='JPers_Country'
"True ","SELECT JColu_LD_SQL, JColu_LD_CaptionRules_b FROM jcolumn WHERE JColu_Deleted_b<>1 AND JColu_JColumn_UID=2012041419462680842
"True ","select JLook_en as DisplayMe, JLook_Value as ColumnValue FROM jlookup WHERE (JLook_Deleted_b<>true OR JLook_Deleted_b IS null) AND JLook_Name='Country'  ORDER BY JLook_en
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","select from jlock
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select * from jlock
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","select 1
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select * from jlock;
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='root',JDCon_Password='root',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 06:31:13',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u
"True ","delete from jlog
"True ","select count(*) as MyCount from jasident
"True ","select JASID_ServerIdent from jasident
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock 111(JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock 111(JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select 1
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:24:46',44,0,0,'admin',1)












gsdfgsdffgsd
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001
"True ","select * from juser where JUser_JUser_UID=1
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u 
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:04:04',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select JSKey_KeyPub from jseckey where JSKey_JSecKey_UID=273 and JSKey_Deleted_b<>1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","select 1"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JScrn_JScreen_UID from jscreen WHERE JScrn_Deleted_b<>1 and JScrn_Name='jperson Search'"
"True ","select * from jscreen where JScrn_JScreen_UID=29"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2623"
"True ","SELECT   JBlok_JBlok_UID from jblok where   JBlok_JScreen_ID=29 AND   JBlok_Deleted_b<>1 ORDER BY JBlok_Position_u"
"True ","select * from jblok where JBlok_JBlok_UID=43"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4112"
"True ","select * from jtable where JTabl_JTable_UID=44"
"True ","select JColu_Name from jcolumn where JColu_Deleted_b<>1 and JColu_JColumn_UID=null"
"True ","select JBlkB_JBlokButton_UID from jblokbutton where JBlkB_JBlok_ID=43 AND JBlkB_Deleted_b<>1 ORDER BY JBlkB_Position_u"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=145"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=10"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=141"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=144"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=143"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3"
"True ","select JBlkF_JBlokField_UID from jblokfield where JBlkF_JBlok_ID=43 AND JBlkF_Deleted_b<>1 ORDER BY JBlkF_Position_u"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=568"
"True ","select * from jcolumn where JColu_JColumn_UID=433"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1894"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=571"
"True ","select * from jcolumn where JColu_JColumn_UID=436"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1891"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=572"
"True ","select * from jcolumn where JColu_JColumn_UID=437"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1893"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=573"
"True ","select * from jcolumn where JColu_JColumn_UID=438"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1892"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012040910355100282"
"True ","select * from jcolumn where JColu_JColumn_UID=2012040910312100253"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2693"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012041619373695994"
"True ","select * from jcolumn where JColu_JColumn_UID=2012041619364442490"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4120"
"True ","select JColu_JColumn_UID from jcolumn where JColu_JTable_ID=44 and JColu_PrimaryKey_b=1"
"True ","select * from jcolumn where JColu_JColumn_UID=433"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","select * from jblok where JBlok_JBlok_UID=44"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2531"
"True ","select * from jtable where JTabl_JTable_UID=44"
"True ","select JColu_Name from jcolumn where JColu_Deleted_b<>1 and JColu_JColumn_UID=null"
"True ","select JBlkB_JBlokButton_UID from jblokbutton where JBlkB_JBlok_ID=44 AND JBlkB_Deleted_b<>1 ORDER BY JBlkB_Position_u"
"True ","select JBlkF_JBlokField_UID from jblokfield where JBlkF_JBlok_ID=44 AND JBlkF_Deleted_b<>1 ORDER BY JBlkF_Position_u"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012050913553243071"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2012050915331229678"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=8164"
"True ","select * from jcolumn where JColu_JColumn_UID=436"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1891"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012041116044757399"
"True ","select * from jcolumn where JColu_JColumn_UID=437"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1893"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=8165"
"True ","select * from jcolumn where JColu_JColumn_UID=438"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1892"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012040910373576154"
"True ","select * from jcolumn where JColu_JColumn_UID=2012040910312100253"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2693"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7375"
"True ","select * from jcolumn where JColu_JColumn_UID=446"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3952"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7376"
"True ","select * from jcolumn where JColu_JColumn_UID=447"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3949"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7377"
"True ","select * from jcolumn where JColu_JColumn_UID=449"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3953"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7378"
"True ","select * from jcolumn where JColu_JColumn_UID=2576"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3951"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7379"
"True ","select * from jcolumn where JColu_JColumn_UID=2575"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3950"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=1503081344187730007"
"True ","select * from jcolumn where JColu_JColumn_UID=1318"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1968"
"True ","select JColu_JColumn_UID from jcolumn where JColu_JTable_ID=44 and JColu_PrimaryKey_b=1"
"True ","select * from jcolumn where JColu_JColumn_UID=433"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","select JFtSD_JFilterSave_ID from jfiltersavedef where JFtSD_Deleted_b<>1 AND JFtSD_CreatedBy_JUser_ID=1 AND JFtSD_JBlok_ID=43"
"True ","SELECT JFtSa_JFilterSave_UID,JFtSa_Name,JFtSa_XML,JFtSa_Public_b from jfiltersave  WHERE JFtSa_Deleted_b<>1 AND  JFtSa_JBlok_ID=43 AND  (JFtSa_CreatedBy_JUser_ID=1 OR  JFtSa_Public_b=true) ORDER BY JFtSa_Name"
"True ","SELECT UsrPL_Value FROM juserpreflink WHERE UsrPL_UserPref_ID=2 AND UsrPL_User_ID=1"
"True "," SELECT count(*) as mycount  FROM jperson  WHERE ((`JPers_Deleted_b`<>1) or (`JPers_Deleted_b` is null)) "
"True ","SELECT JColu_Name FROM jcolumn WHERE JColu_JColumn_UID=null LIMIT 1"
"True ","SELECT `JPers_JPerson_UID`  FROM jperson  WHERE ((`JPers_Deleted_b`<>1) or (`JPers_Deleted_b` is null))  GROUP BY JPers_JPerson_UID"
"True ","SELECT `JPers_NameFirst`, `JPers_NameMiddle`, `JPers_NameLast`, `JPers_Customer_b`, `JPers_Work_Phone`, `JPers_Work_Email`, `JPers_Mobile_Phone`, `JPers_Home_Phone`, `JPers_Home_Email`, `JPers_Created_DT`, JPers_JPerson_UID FROM jperson  WHERE JPers_JPerson_UID=1506121556140240002"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select 1"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","select 1"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","select 1"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select 1"
"True ","SELECT JScrn_JScreen_UID from jscreen WHERE JScrn_Deleted_b<>1 and JScrn_JScreen_UID=30"
"True ","select * from jscreen where JScrn_JScreen_UID=30"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1963"
"True ","SELECT   JBlok_JBlok_UID from jblok where   JBlok_JScreen_ID=30 AND   JBlok_Deleted_b<>1 ORDER BY JBlok_Position_u"
"True ","select * from jblok where JBlok_JBlok_UID=45"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2550"
"True ","select * from jtable where JTabl_JTable_UID=44"
"True ","select JColu_Name from jcolumn where JColu_Deleted_b<>1 and JColu_JColumn_UID=null"
"True ","select JBlkB_JBlokButton_UID from jblokbutton where JBlkB_JBlok_ID=45 AND JBlkB_Deleted_b<>1 ORDER BY JBlkB_Position_u"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=150"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=10"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=146"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=5"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=1920"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4054"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=148"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=7"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=149"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=8"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=1921"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4055"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=147"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=6"
"True ","select JBlkF_JBlokField_UID from jblokfield where JBlkF_JBlok_ID=45 AND JBlkF_Deleted_b<>1 ORDER BY JBlkF_Position_u"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=623"
"True ","select * from jcolumn where JColu_JColumn_UID=436"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1891"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=624"
"True ","select * from jcolumn where JColu_JColumn_UID=437"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1893"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=625"
"True ","select * from jcolumn where JColu_JColumn_UID=438"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1892"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=622"
"True ","select * from jcolumn where JColu_JColumn_UID=435"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2012040717343336567"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=626"
"True ","select * from jcolumn where JColu_JColumn_UID=439"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1986"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=627"
"True ","select * from jcolumn where JColu_JColumn_UID=440"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1987"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7380"
"True ","select * from jcolumn where JColu_JColumn_UID=446"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3952"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7382"
"True ","select * from jcolumn where JColu_JColumn_UID=2576"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3951"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7383"
"True ","select * from jcolumn where JColu_JColumn_UID=449"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3953"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7381"
"True ","select * from jcolumn where JColu_JColumn_UID=447"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3949"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7384"
"True ","select * from jcolumn where JColu_JColumn_UID=2575"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3950"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=630"
"True ","select * from jcolumn where JColu_JColumn_UID=443"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1964"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012040910383165961"
"True ","select * from jcolumn where JColu_JColumn_UID=2012040910312100253"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2693"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012041619385287426"
"True ","select * from jcolumn where JColu_JColumn_UID=2012041619364442490"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4120"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=629"
"True ","select * from jcolumn where JColu_JColumn_UID=442"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1989"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=6117"
"True ","select * from jcolumn where JColu_JColumn_UID=2353"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1937"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012041609170596679"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2529"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012050218594616247"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4234"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7389"
"True ","select * from jcolumn where JColu_JColumn_UID=2589"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3954"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7390"
"True ","select * from jcolumn where JColu_JColumn_UID=2590"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3955"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7391"
"True ","select * from jcolumn where JColu_JColumn_UID=2591"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3956"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7392"
"True ","select * from jcolumn where JColu_JColumn_UID=2592"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3960"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7393"
"True ","select * from jcolumn where JColu_JColumn_UID=2593"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3961"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7394"
"True ","select * from jcolumn where JColu_JColumn_UID=2594"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3962"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012041420243204087"
"True ","select * from jcolumn where JColu_JColumn_UID=2012041420240651587"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2012041420513148043"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7395"
"True ","select * from jcolumn where JColu_JColumn_UID=2595"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3971"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7396"
"True ","select * from jcolumn where JColu_JColumn_UID=2596"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3972"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=620"
"True ","select * from jcolumn where JColu_JColumn_UID=433"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1894"
"True ","select JColu_JColumn_UID from jcolumn where JColu_JTable_ID=44 and JColu_PrimaryKey_b=1"
"True ","select * from jcolumn where JColu_JColumn_UID=433"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","select JTabl_Add_JSecPerm_ID, JTabl_Update_JSecPerm_ID, JTabl_View_JSecPerm_ID, JTabl_Delete_JSecPerm_ID  FROM jtable WHERE UCASE(JTabl_Name)=UCASE('jperson')"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","select `JPers_CreatedBy_JUser_ID` from `jperson` where `JPers_JPerson_UID`=1506121556140240002"
"True ","SELECT `JPers_NameFirst`, `JPers_NameMiddle`, `JPers_NameLast`, `JPers_NameSalutation`, `JPers_NameSuffix`, `JPers_NameDear`, `JPers_Work_Phone`, `JPers_Home_Phone`, `JPers_Mobile_Phone`, `JPers_Work_Email`, `JPers_Home_Email`, `JPers_Primary_Company_ID`, `JPers_Customer_b`, `JPers_Vendor_b`, `JPers_Private_b`, `JPers_Desc`, `JPers_Addr1`, `JPers_Addr2`, `JPers_Addr3`, `JPers_City`, `JPers_State`, `JPers_PostalCode`, `JPers_Country`, `JPers_Longitude_d`, `JPers_Latitude_d`, `JPers_JPerson_UID` FROM jperson WHERE JPers_JPerson_UID=1506121556140240002"
"True ","SELECT JColu_LU_JColumn_ID, JColu_LUF_Value FROM jcolumn WHERE JColu_Deleted_b<>1 AND JColu_JTable_ID=44 AND JColu_Name='JPers_Primary_Company_ID'"
"True ","SELECT JColu_LD_SQL, JColu_LD_CaptionRules_b FROM jcolumn WHERE JColu_Deleted_b<>1 AND JColu_JColumn_UID=217"
"True ","SELECT JComp_Name as DisplayMe, JComp_JCompany_UID as ColumnValue FROM jcompany WHERE ((JComp_Deleted_b<>true) or (JComp_Deleted_b is null))   ORDER BY JComp_Name"
"True ","SELECT JColu_LU_JColumn_ID, JColu_LUF_Value FROM jcolumn WHERE JColu_Deleted_b<>1 AND JColu_JTable_ID=44 AND JColu_Name='JPers_Country'"
"True ","SELECT JColu_LD_SQL, JColu_LD_CaptionRules_b FROM jcolumn WHERE JColu_Deleted_b<>1 AND JColu_JColumn_UID=2012041419462680842"
"True ","select JLook_en as DisplayMe, JLook_Value as ColumnValue FROM jlookup WHERE (JLook_Deleted_b<>true OR JLook_Deleted_b IS null) AND JLook_Name='Country'  ORDER BY JLook_en"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select * from jlock"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'admin',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'admin',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'admin',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'admin',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'admin',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:09:54',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'admin',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:10:57',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'admin',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:12:29',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'admin',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:15:06',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:15:46',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:17:56',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:19:21',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:20:39',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:21:30',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:28:44',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:31:43',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:35:54',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>1"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","SELECT VHost_JVHost_UID,VHost_WebRootDir,VHost_ServerName,VHost_ServerIdent,VHost_ServerDomain,VHost_ServerIP,VHost_ServerPort,VHost_DefaultLanguage,VHost_DefaultColorTheme,VHost_MenuRenderMethod,VHost_DefaultArea,VHost_DefaultPage,VHost_DefaultSection,VHost_DefaultTop_JMenu_ID,VHost_DefaultLoggedInPage,VHost_DefaultLoggedOutPage,VHost_DataOnRight_b,VHost_CacheMaxAgeInSeconds,VHost_SystemEmailFromAddress,VHost_EnableSSL_b,VHost_SharesDefaultDomain_b,VHost_DefaultIconTheme,VHost_DirectoryListing_b,VHost_FileDir,VHost_AccessLog,VHost_ErrorLog,VHost_JDConnection_ID, VHost_CacheDir, VHost_TemplateDir FROM jvhost WHERE ((VHost_Deleted_b<>1)OR(VHost_Deleted_b IS NULL)) AND  VHOST_Enabled_b=1"
"True ","SELECT THCOL_JThemeColor_UID,THCOL_Name,THCOL_Template_Header FROM jthemecolor WHERE ((THCOL_Deleted_b<>1)OR(THCOL_Deleted_b IS NULL))"
"True ","SELECT JLang_JLanguage_UID,JLang_Name,JLang_NativeName,JLang_Code FROM jlanguage WHERE ((JLang_Deleted_b<>1)OR(JLang_Deleted_b IS NULL))"
"True ","SELECT JIDX_JIndexFile_UID,JIDX_JVHost_ID,JIDX_Filename FROM jindexfile WHERE ((JIDX_Deleted_b<>1)OR(JIDX_Deleted_b IS NULL)) ORDER BY JIDX_Order_u"
"True ","SELECT JIPL_JIPList_UID,JIPL_IPListType_u,JIPL_IPAddress FROM jiplist"
"True ","SELECT Alias_JAlias_UID,Alias_JVHost_ID,Alias_Alias,Alias_Path, Alias_VHost_b FROM jalias WHERE ((Alias_Deleted_b<>1)OR(Alias_Deleted_b IS NULL))"
"True ","SELECT MIME_JMime_UID,MIME_Name,MIME_Type,MIME_SNR_b FROM jmime WHERE ((MIME_Deleted_b<>1)OR(MIME_Deleted_b IS NULL)) AND MIME_Enabled_b=1"
"True ","select count(*) as MyCount from jdconnection WHERE JDCon_JDConnection_UID=0"
"True ","UPDATE jdconnection SET JDCon_Name='JAS',JDCon_DSN='',JDCon_DBC_Filename='c:\\opt\\jas\\config\\jas.dbc',JDCon_Enabled_b=1,JDCon_DBMS_ID=4,JDCon_Driver_ID='2',JDCon_Username='ODBC',JDCon_Password='jas',JDCon_ODBC_Driver='',JDCon_Server='localhost',JDCon_Database='jas',JDCon_DSN_FileBased_b=0,JDCon_DSN_Filename='',JDCon_JSecPerm_ID=1211050031076870004,JDCon_ModifiedBy_JUser_ID=0,JDCon_Modified_DT='2015-11-14 07:37:21',JDCon_DeletedBy_JUser_ID=null,JDCon_Deleted_DT=null,JDCon_Deleted_b=0,JAS_Row_b=1 WHERE JDCon_JDConnection_UID=0"
"True ","select * from jdconnection where JDCon_Deleted_b<>1 and JDCon_JDConnection_UID>0 and JDCon_Enabled_b=1 order by JDCon_Name"
"True ","SELECT *  FROM jmenu  WHERE ((JMenu_Deleted_b<>1)OR(JMenu_Deleted_b IS NULL))  ORDER BY JMenu_JMenuParent_ID, JMenu_SEQ_u"
"True ","delete from jlog"
"True ","select count(*) as MyCount from jasident"
"True ","select JASID_ServerIdent from jasident"
"True ","select UserP_UserPref_UID,UserP_Name,UsrPL_UserPrefLink_UID, UsrPL_Value from juserpreflink join juserpref where UsrPL_UserPref_ID=UserP_UserPref_UID and UsrPL_User_ID=1 and ((UserP_Deleted_b<>1)OR(UserP_Deleted_b IS NULL))"
"True ","select JDCon_JDConnection_UID, JDCon_Name from jdconnection where ((JDCon_Deleted_b<>1)OR(JDCon_Deleted_b IS NULL)) and (JDCon_Enabled_b=1) AND (JDCon_JDConnection_UID=0) ORDER BY JDCon_Name"
"True ","select JTabl_JTable_UID, JTabl_Name from jtable where (JTabl_JDConnection_ID=0) AND ((JTabl_Deleted_b<>1)OR(JTabl_Deleted_b IS NULL)) ORDER BY JTabl_Name"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 06:20:42',44,0,0,'DAMIT',1)"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
"True ","select 1"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","SELECT JScrn_JScreen_UID from jscreen WHERE JScrn_Deleted_b<>1 and JScrn_JScreen_UID=30"
"True ","select * from jscreen where JScrn_JScreen_UID=30"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1963"
"True ","SELECT   JBlok_JBlok_UID from jblok where   JBlok_JScreen_ID=30 AND   JBlok_Deleted_b<>1 ORDER BY JBlok_Position_u"
"True ","select * from jblok where JBlok_JBlok_UID=45"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2550"
"True ","select * from jtable where JTabl_JTable_UID=44"
"True ","select JColu_Name from jcolumn where JColu_Deleted_b<>1 and JColu_JColumn_UID=null"
"True ","select JBlkB_JBlokButton_UID from jblokbutton where JBlkB_JBlok_ID=45 AND JBlkB_Deleted_b<>1 ORDER BY JBlkB_Position_u"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=150"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=10"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=146"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=5"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=1920"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4054"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=148"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=7"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=149"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=8"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=1921"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4055"
"True ","select * from jblokbutton where JBlkB_JBlokButton_UID=147"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=6"
"True ","select JBlkF_JBlokField_UID from jblokfield where JBlkF_JBlok_ID=45 AND JBlkF_Deleted_b<>1 ORDER BY JBlkF_Position_u"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=623"
"True ","select * from jcolumn where JColu_JColumn_UID=436"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1891"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=624"
"True ","select * from jcolumn where JColu_JColumn_UID=437"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1893"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=625"
"True ","select * from jcolumn where JColu_JColumn_UID=438"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1892"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=622"
"True ","select * from jcolumn where JColu_JColumn_UID=435"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2012040717343336567"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=626"
"True ","select * from jcolumn where JColu_JColumn_UID=439"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1986"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=627"
"True ","select * from jcolumn where JColu_JColumn_UID=440"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1987"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7380"
"True ","select * from jcolumn where JColu_JColumn_UID=446"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3952"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7382"
"True ","select * from jcolumn where JColu_JColumn_UID=2576"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3951"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7383"
"True ","select * from jcolumn where JColu_JColumn_UID=449"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3953"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7381"
"True ","select * from jcolumn where JColu_JColumn_UID=447"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3949"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7384"
"True ","select * from jcolumn where JColu_JColumn_UID=2575"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3950"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=630"
"True ","select * from jcolumn where JColu_JColumn_UID=443"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1964"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012040910383165961"
"True ","select * from jcolumn where JColu_JColumn_UID=2012040910312100253"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2693"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012041619385287426"
"True ","select * from jcolumn where JColu_JColumn_UID=2012041619364442490"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4120"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=629"
"True ","select * from jcolumn where JColu_JColumn_UID=442"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1989"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=6117"
"True ","select * from jcolumn where JColu_JColumn_UID=2353"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1937"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012041609170596679"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2529"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012050218594616247"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=4234"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7389"
"True ","select * from jcolumn where JColu_JColumn_UID=2589"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3954"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7390"
"True ","select * from jcolumn where JColu_JColumn_UID=2590"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3955"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7391"
"True ","select * from jcolumn where JColu_JColumn_UID=2591"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3956"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7392"
"True ","select * from jcolumn where JColu_JColumn_UID=2592"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3960"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7393"
"True ","select * from jcolumn where JColu_JColumn_UID=2593"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3961"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7394"
"True ","select * from jcolumn where JColu_JColumn_UID=2594"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3962"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=2012041420243204087"
"True ","select * from jcolumn where JColu_JColumn_UID=2012041420240651587"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=2012041420513148043"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7395"
"True ","select * from jcolumn where JColu_JColumn_UID=2595"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3971"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=7396"
"True ","select * from jcolumn where JColu_JColumn_UID=2596"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=3972"
"True ","select * from jblokfield where JBlkF_JBlokField_UID=620"
"True ","select * from jcolumn where JColu_JColumn_UID=433"
"True ","SELECT   JCapt_en,   JCapt_en as JASDEFAULTLANG,   JCapt_Value FROM jcaption WHERE   ((JCapt_Deleted_b<>1) or (JCapt_Deleted_b is null)) and   JCapt_JCaption_UID=1894"
"True ","select JColu_JColumn_UID from jcolumn where JColu_JTable_ID=44 and JColu_PrimaryKey_b=1"
"True ","select * from jcolumn where JColu_JColumn_UID=433"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"True ","describe `jperson`"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"False","INSERT INTO jlock (JLock_JSession_ID,JLock_JDConnection_ID,JLock_Locked_DT,JLock_Table_ID,JLock_Row_ID,JLock_Col_ID,JLock_Username,JLock_CreatedBy_JUser_ID)VALUES(1511140603050670001,0,'2015-11-14 07:37:44',44,0,0,'admin',1)"
"True ","INSERT INTO jlog (JLOG_DateNTime_dt, JLOG_JLogType_ID, JLOG_Entry_ID, JLOG_EntryData_s, JLOG_SourceFile_s, JLOG_User_ID, JLOG_CmdLine_s ) VALUES ('2015-11-14 07:37:45',3,200701071725,'This RECORD is already locked by some one. Mode: Edit <a href=\""javascript: window.history.back()\"">Go Back To View Mode.</a> <br /><br />Diagnostic Info: Table:jperson UID:1506121556140240002 JSess_JSession_UID:01511140603050670001 Session Valid:Yes  ','uj_ui_screen.pp',1,'C:\\opt\\jas\\src\\jas.exe')"
"True ","SELECT JSess_JUser_ID from jsession where JSess_JSession_UID=1511140603050670001"
"True ","select * from juser where JUser_JUser_UID=1"
"True ","UPDATE jsession SET JSess_LastContact_DT=now() WHERE JSess_JSession_UID=01511140603050670001"
"True ","SELECT jsession.JSess_Username, jsessiondata.JSDat_Name, jsessiondata.JSDat_Value FROM jsessiondata INNER JOIN jsession ON jsessiondata.JSDat_JSession_ID = jsession.JSess_JSession_UID WHERE jsessiondata.JSDat_JSession_ID=01511140603050670001"
"True ","select count(*) as MyCount from jmail WHERE JMail_CreatedBy_JUser_ID=1 and JMail_From_User_ID<>1 AND ((JMail_Deleted_b=false)or(JMail_Deleted_b is null))"
"True ","SELECT   JQLnk_JQuickLink_UID,  JQLnk_Name,  JQLnk_SecPerm_ID,  JQLnk_Desc,  JQLnk_URL,  JQLnk_Icon,  JQLnk_Owner_JUser_ID,  JQLnk_Position_u,   JQLnk_ValidSessionOnly_b,  JQLnk_DisplayIfNoAccess_b,  JQLnk_DisplayIfValidSession_b,  JQLnk_RenderAsUniqueDiv_b,  JQLnk_Private_Memo,  JQLnk_Private_b FROM jquicklink WHERE JQLnk_Deleted_b<>1 and JQLnk_DisplayIfValidSession_b=true  ORDER BY JQLnk_Position_u "
"True ","select 1"
"True ","select 1"
