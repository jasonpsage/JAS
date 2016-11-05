{=============================================================================
|    _________ _______  _______  ______  _______  Get out of the Mainstream, |
|   /___  ___// _____/ / _____/ / __  / / _____/    Mainstream Jetstream!    |
|      / /   / /__    / / ___  / /_/ / / /____         and into the          |
|     / /   / ____/  / / /  / / __  / /____  /            Jetstream! (tm)    |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                        Jason@Jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}


//=============================================================================
{}
// JAS Specific Functions
Unit uj_modules;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_modules.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND: TRUE}
{$ENDIF}
//=============================================================================



//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                               Interface
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//=============================================================================
Uses
//=============================================================================
classes
,syncobjs
,sysutils
,ug_common
,ug_jado
,ug_jfc_xdl
,uj_definitions
,uj_context
,uj_permissions
,uj_notes
;
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//=============================================================================
{}
// Returns the JModule.JModu_JModule_UID of the requested JModule.JModu_Name. 
// The search is exact. If data permits multiple rows that match the criteria,
// only the first row is returned. Duplicates should not be present.
// Returns true if successful, false if not. 
function bGet_Module_ID_With_Name(
  p_Context: TCONTEXT; 
  p_JModu_Name: ansistring; 
  var p_JModu_JModule_UID: ansistring
): boolean;
//=============================================================================

//=============================================================================
{}
// Returns the JModule.JModu_Name of the requested JModule.JModu_JModule_UID. 
// Exact Match. Returns true if successful, false if not. 
function bGet_Module_Name_With_ID(
  p_Context: TCONTEXT; 
  p_JModu_JModule_UID: ansistring; 
  var p_JModu_Name: ansistring
): boolean;
//=============================================================================

//=============================================================================
{}
// This function returns an instantiated JFC_XDL. Upon entry, if the p_XDL
// parameter is not nil a p_XDL.Destroy will be executed upon it assuming it
// is an instantiated JFC_XDL object. So be sure to set your JFC_XDL variable to 
// nil before calling this function or expect an exception when this function tries to 
// blast your unintialized pointer thinking it's an Instantiated JFC_XDL Object. 
// The p_ReturnEnabledInstalledInstancesOnly parameter is how you indicate if you 
// want the function to only return results for a given Installed Module 
// instance if it's in fact enabled. 
// If an error occurs, the p_XDL object will be destroyed and returned as nil.
// If this function returns True (No Error) - It WILL return an instantiated 
// JFC_XDL object.. with ZERO items in it.
// JFC_XDL object.. with ZERO items in it.
// JFC_XDL.Item_saName = 'Name of Module' (which you already probably know)
// JFC_XDL.Item_saValue = jinstalled.JInst_JModule_UID 
// Returns true if successful, false if not. 
function bGet_Installed_Instances_For_Given_Module_ID(
  p_Context: TCONTEXT; 
  p_JModu_JModule_UID: ansistring; 
  p_bReturnEnabledInstalledInstancesOnly: boolean;
  var p_XDL: JFC_XDL
): boolean;
//=============================================================================

//=============================================================================
{}
// Returns the JModule.JModu_Name of the 
// requested JModule.JModu_JModule_UID. Exact Match.
// This function returns an instantiated JFC_XDL. Upon entry, if the p_XDL
// parameter is not nil a p_XDL.Destroy will be executed upon it assuming it
// is an instantiated JFC_XDL object. So be sure to set your JFC_XDL variable to 
// nil before calling this function or expect an exception when this function tries to 
// blast your unintialized pointer thinking it's an Instantiated JFC_XDL Object. 
// The p_ReturnEnabledInstalledInstancesOnly parameter is how you indicate if you 
// want the function to only return results for a given Installed Module 
// instance if it's in fact enabled. 
// Returns true if successful, false if not.
function bGet_Installed_Instances_For_Given_Module_Name(
  p_Context: TCONTEXT; 
  p_JModu_Name: ansistring; 
  p_bReturnEnabledInstalledInstancesOnly: boolean;
  var p_XDL: JFC_XDL
): boolean;
//=============================================================================

//=============================================================================
{}
// Returns a Populated JFC_XDL object of all the settings possible for a 
// given module name. This doesn't return the setting values for a particular 
// Module's Installation Instance.. just the settings the given Module has
// associated with it.
// This function returns an instantiated JFC_XDL. Upon entry, if the p_XDL
// parameter is not nil a p_XDL.Destroy will be executed upon it assuming it
// is an instantiated JFC_XDL object. So be sure to set your JFC_XDL variable to 
// nil before calling this function or expect an exception when this function tries to 
// blast your unintialized pointer thinking it's an Instantiated JFC_XDL Object. 
// Returns true if successful, false if not.
function bGet_Setting_List_For_Given_Module_Name(
  p_Context: TCONTEXT; 
  p_JModu_Name: ansistring; 
  var p_XDL: JFC_XDL
): boolean;
//=============================================================================

//=============================================================================
{}
// Returns a Populated JFC_XDL object of all the settings possible for a 
// given module ID. This doesn't return the setting values for a particular 
// Module's Installation Instance.. just the settings the given Module has
// associated with it.
// This function returns an instantiated JFC_XDL. Upon entry, if the p_XDL
// parameter is not nil a p_XDL.Destroy will be executed upon it assuming it
// is an instantiated JFC_XDL object. So be sure to set your JFC_XDL variable to 
// nil before calling this function or expect an exception when this function tries to 
// blast your unintialized pointer thinking it's an Instantiated JFC_XDL Object. 
// Returns true if successful, false if not.
//      p_XDL.Item_i8User:=i8Val(rs.fields.Get_saValue('JMSet_JCaption_ID'));
//      p_XDL.Item_saName:=rs.fields.Get_saValue('JMSet_Name');
//      p_XDL.Item_saValue:=rs.fields.Get_saValue('JMSet_JModuleSetting_UID');
//      p_XDL.Item_saDesc:=i8Val(rs.fields.Get_saValue('JMSet_JNote_ID'));
function bGet_Setting_List_For_Given_Module_ID(
  p_Context: TCONTEXT; 
  p_JModu_JModule_UID: ansistring; 
  var p_XDL: JFC_XDL
): boolean;
//=============================================================================


//=============================================================================
{}
// Returns a Populated JFC_XDL object of all the settings for a given Module
// Install instance. This function returns actual configuration values for each setting.
// This function returns an instantiated JFC_XDL. Upon entry, if the p_XDL
// parameter is not nil a p_XDL.Destroy will be executed upon it assuming it
// is an instantiated JFC_XDL object. So be sure to set your JFC_XDL variable to 
// nil before calling this function or expect an exception when this function tries to 
// blast your unintialized pointer thinking it's an Instantiated JFC_XDL Object. 
// Returns true if successful, false if not.
function bGet_ModuleConfig_Values_For_Given_Install(
  p_Context: TCONTEXT; 
  p_JInst_JInstalled_UID: ansistring; 
  var p_XDL: JFC_XDL
): boolean;
//=============================================================================

//=============================================================================
{}
// Returns specific setting's configuration value for a given Module Install 
// instance and setting name combination. 
// This function returns an instantiated JFC_XDL. 
// Returns true if successful, false if not or if anything is missing.
// E.G. p_JInst_JInstalled_UID can't be found
// p_JMSet_Name can't be found or
// Actual setting value record can not be found. 
function bGet_ModuleConfig_Value_For_Given_Install(
  p_Context: TCONTEXT; 
  p_JInst_JInstalled_UID: ansistring; 
  p_JMSet_Name: ansistring;  
  var p_saValue: ansistring;
  var p_saNotes: ansistring
): boolean;
//=============================================================================





//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
                              Implementation
//            
//*****************************************************************************
//=============================================================================
//*****************************************************************************


//=============================================================================
{}
// Returns the JModule.JModu_JModule_UID of the requested JModule.JModu_Name. 
// The search is exact. If data permits multiple rows that match the criteria,
// only the first row is returned. Duplicates should not be present.
// If you get back a ZERO in p_JModu_JModule_UID and the function returns TRUE
// there wasn't a match. 
// Returns true if successful, false if not. 
function bGet_Module_ID_With_Name(
  p_Context: TCONTEXT; 
  p_JModu_Name: ansistring; 
  var p_JModu_JModule_UID: ansistring
): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bGet_Module_ID_With_Name(p_Context: TCONTEXT;p_JModu_Name: ansistring;'+
  'var p_JModu_JModule_UID: ansistring): boolean;';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102448,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102449, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  saQry:='select JModu_JModule_UID from jmodule '+
    'where JModu_Name='+DBC.saDBMSScrub(p_JModu_Name)+' and '+
    'JModule.JModu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
  p_JModu_JModule_UID:='0';
  bOk:=rs.Open(saQry, DBC,201602121651);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201006141228,'Trouble querying jmodule table.','Query: '+saQry,SOURCEFILE,DBC,rs);
  end;
  
  if bOk then
  begin
    if rs.eol=false then
    begin
      p_JModu_JModule_UID:=rs.fields.get_savalue('JModu_JModule_UID');
    end;
  end;
  rs.close;
  rs.Destroy;rs:=nil;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102450,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
{}
// Returns the JModule.JModu_Name of the requested JModule.JModu_JModule_UID. 
// Exact Match. Returns true if successful, false if not. 
function bGet_Module_Name_With_ID(
  p_Context: TCONTEXT; 
  p_JModu_JModule_UID: ansistring; 
  var p_JModu_Name: ansistring
): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bGet_Module_Name_With_ID(p_Context:TCONTEXT;p_JModu_JModule_UID:ansistring;var p_JModu_Name:ansistring): boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102451,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102452, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  saQry:='select JModu_Name from jmodule '+
    'where (JModu_JModule_UID='+DBC.saDBMSScrub(p_JModu_JModule_UID)+') and '+
    '(JModule.JModu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')';
  p_JModu_Name:='';
  bOk:=rs.Open(saQry, DBC,201602121652);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201006141229,'Trouble querying jmodule table.','Query: '+saQry,SOURCEFILE,DBC,rs);
  end;
  
  if bOk then
  begin
    if rs.eol=false then
    begin
      p_JModu_Name:=rs.fields.get_savalue('JModu_Name');
    end;
  end;
  rs.close;
  rs.Destroy;rs:=nil;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102453,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
{}
// This function returns an instantiated JFC_XDL. Upon entry, if the p_XDL
// parameter is not nil a p_XDL.Destroy will be executed upon it assuming it
// is an instantiated JFC_XDL object. So be sure to set your JFC_XDL variable to 
// nil before calling this function or expect an exception when this function tries to 
// blast your unintialized pointer thinking it's an Instantiated JFC_XDL Object. 
// The p_ReturnEnabledInstalledInstancesOnly parameter is how you indicate if you 
// want the function to only return results for a given Installed Module 
// instance if it's in fact enabled. 
// If an error occurs, the p_XDL object will be destroyed and returned as nil.
// If this function returns True (No Error) - It WILL return an instantiated 
// JFC_XDL object.. with ZERO items in it.
// JFC_XDL.Item_saName = 'Name of Module' (which you already probably know)
// JFC_XDL.Item_saValue = jinstalled.JInst_JModule_UID 
// Returns true if successful, false if not. 
function bGet_Installed_Instances_For_Given_Module_ID(
  p_Context: TCONTEXT; 
  p_JModu_JModule_UID: ansistring; 
  p_bReturnEnabledInstalledInstancesOnly: boolean;
  var p_XDL: JFC_XDL
): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}
  sTHIS_ROUTINE_NAME:='bGet_Installed_Instances_For_Given_Module_ID(p_Context: TCONTEXT;p_JModu_JModule_UID: ansistring;'+
    'p_bReturnEnabledInstalledInstancesOnly: boolean;var p_XDL: JFC_XDL): boolean;';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102454,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102455, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  saQry:='select '+
         'JModu_Name, '+
         'JInst_JModule_UID '+
         'from '+
         'jinstalled join jmodule on jmodule.JModu_JModule_UID=JInst_JModule_ID '+
         'where (jmodule.JModu_JModule_UID='+DBC.saDBMSScrub(p_JModu_JModule_UID)+ ')' +
         ' and (JModule.JModu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+') and '+
         '(jinstalled.JInst_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+') ';
  if p_bReturnEnabledInstalledInstancesOnly then
  begin
    saQry+='and JInst_Enabled_b=true';
  end;

  if p_XDL<>nil then 
  begin
    p_XDL.Destroy;p_XDL:=nil;
  end;
  
  p_XDL:=JFC_XDL.Create;
  bOk:=rs.Open(saQry, DBC,201602121653);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201006141229,'Trouble querying jmodule and jinstalled tables.','Query: '+saQry,SOURCEFILE,DBC,rs);
  end;
  
  if bOk and (rs.eol=false)then
  begin
    repeat
      p_XDL.AppendItem;
      p_XDL.Item_saName:=rs.fields.Get_saValue('JModu_Name');
      p_XDL.Item_saValue:=rs.fields.Get_saValue('JInst_JModule_UID');
    until not rs.movenext;    
  end;
  rs.close;
  
  if bOk = false then
  begin
    if p_XDL <> nil then
    begin
      p_XDL.Destroy;p_XDL:=nil;
    end;
  end;  
  rs.Destroy;rs:=nil;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102456,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
{}
// This function returns an instantiated JFC_XDL. Upon entry, if the p_XDL
// parameter is not nil a p_XDL.Destroy will be executed upon it assuming it
// is an instantiated JFC_XDL object. So be sure to set your JFC_XDL variable to 
// nil before calling this function or expect an exception when this function tries to 
// blast your unintialized pointer thinking it's an Instantiated JFC_XDL Object. 
// The p_ReturnEnabledInstalledInstancesOnly parameter is how you indicate if you 
// want the function to only return results for a given Installed Module 
// instance if it's in fact enabled. 
// If an error occurs, the p_XDL object will be destroyed and returned as nil.
// If this function returns True (No Error) - It WILL return an instantiated 
// JFC_XDL object.. with ZERO items in it.
// JFC_XDL.Item_saName = 'Name of Module' (which you already probably know)
// JFC_XDL.Item_saValue = jinstalled.JInst_JModule_UID 
// Returns true if successful, false if not. 
function bGet_Installed_Instances_For_Given_Module_Name(
  p_Context: TCONTEXT; 
  p_JModu_Name: ansistring; 
  p_bReturnEnabledInstalledInstancesOnly: boolean;
  var p_XDL: JFC_XDL
): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}
  sTHIS_ROUTINE_NAME:='bGet_Installed_Instances_For_Given_Module_Name(p_Context: TCONTEXT;p_JModu_Name: ansistring;'+
    'p_bReturnEnabledInstalledInstancesOnly: boolean;var p_XDL: JFC_XDL): boolean;';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102457,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102458, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  saQry:='select '+
         'JModu_Name, '+
         'JInst_JModule_UID '+
         'from '+
         'jinstalled join jmodule on jmodule.JModu_JModule_UID=JInst_JModule_ID '+
         'where jmodule.JModu_Name='+DBC.saDBMSScrub(p_JModu_Name)+
         ' and (JModule.JModu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+') and '+
         '(jinstalled.JInst_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+') ';
  if p_bReturnEnabledInstalledInstancesOnly then
  begin
    saQry+='and JInst_Enabled_b=true';
  end;
  

  if p_XDL<>nil then 
  begin
    p_XDL.Destroy;p_XDL:=nil;
  end;
  
  p_XDL:=JFC_XDL.Create;
  bOk:=rs.Open(saQry, DBC,201602121654);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201006141230,'Trouble querying jmodule and jinstalled tables.','Query: '+saQry,SOURCEFILE,DBC,rs);
  end;
  
  if bOk and (rs.eol=false)then
  begin
    repeat
      p_XDL.AppendItem;
      p_XDL.Item_saName:=rs.fields.Get_saValue('JModu_Name');
      p_XDL.Item_saValue:=rs.fields.Get_saValue('JInst_JModule_UID');
    until not rs.movenext;    
  end;
  rs.close;
  
  if bOk = false then
  begin
    if p_XDL <> nil then
    begin
      p_XDL.Destroy;p_XDL:=nil;
    end;
  end;  
  rs.Destroy;rs:=nil;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102459,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
{}
// Returns a Populated JFC_XDL object of all the settings possible for a 
// given module name. This doesn't return the setting values for a particular 
// Module's Installation Instance.. just the settings the given Module has
// associated with it.
// This function returns an instantiated JFC_XDL. Upon entry, if the p_XDL
// parameter is not nil a p_XDL.Destroy will be executed upon it assuming it
// is an instantiated JFC_XDL object. So be sure to set your JFC_XDL variable to 
// nil before calling this function or expect an exception when this function tries to 
// blast your unintialized pointer thinking it's an Instantiated JFC_XDL Object. 
// Returns true if successful, false if not.
//      p_XDL.Item_i8User:=i8Val(rs.fields.Get_saValue('JMSet_JCaption_ID'));
//      p_XDL.Item_saName:=rs.fields.Get_saValue('JMSet_Name');
//      p_XDL.Item_saValue:=rs.fields.Get_saValue('JMSet_JModuleSetting_UID');
//      p_XDL.Item_saDesc:=i8Val(rs.fields.Get_saValue('JMSet_JNote_ID'));
function bGet_Setting_List_For_Given_Module_Name(
  p_Context: TCONTEXT; 
  p_JModu_Name: ansistring; 
  var p_XDL: JFC_XDL
): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bGet_Setting_List_For_Given_Module_Name(p_Context: TCONTEXT;p_JModu_Name: ansistring;var p_XDL: JFC_XDL): boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102460,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102461, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  saQry:=
    'select  jmodule.*, jmodulesetting.*  from jmodule join jmodulesetting on JModu_JModule_UID=JMSet_JModule_ID '+
    'where jmodule.JModu_Name='+DBC.saDBMSScrub(p_JModu_Name)+' and '+
    'JMSet_Deleted_b<>'+DBC.sDBMSBoolScrub(true);

  if p_XDL<>nil then 
  begin
    p_XDL.Destroy;p_XDL:=nil;
  end;
  
  p_XDL:=JFC_XDL.Create;
  bOk:=rs.Open(saQry, DBC,201602121655);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201006141231,'Trouble querying jmodule and jmodulesetting tables.','Query: '+saQry,SOURCEFILE,DBC,rs);
  end;
  
  if bOk and (rs.eol=false)then
  begin
    repeat
      p_XDL.AppendItem;
      p_XDL.Item_i8User:=i8Val(rs.fields.Get_saValue('JMSet_JCaption_ID'));
      p_XDL.Item_saName:=rs.fields.Get_saValue('JMSet_Name');
      p_XDL.Item_saValue:=rs.fields.Get_saValue('JMSet_JModuleSetting_UID');
      p_XDL.Item_saDesc:=rs.fields.Get_saValue('JMSet_JNote_ID');
    until not rs.movenext;    
  end;
  rs.close;
  
  if bOk = false then
  begin
    if p_XDL <> nil then
    begin
      p_XDL.Destroy;p_XDL:=nil;
    end;
  end;  
  rs.Destroy;rs:=nil;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102462,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
{}
// Returns a Populated JFC_XDL object of all the settings possible for a 
// given module ID. This doesn't return the setting values for a particular 
// Module's Installation Instance.. just the settings the given Module has
// associated with it.
// This function returns an instantiated JFC_XDL. Upon entry, if the p_XDL
// parameter is not nil a p_XDL.Destroy will be executed upon it assuming it
// is an instantiated JFC_XDL object. So be sure to set your JFC_XDL variable to 
// nil before calling this function or expect an exception when this function tries to 
// blast your unintialized pointer thinking it's an Instantiated JFC_XDL Object. 
// Returns true if successful, false if not.
//      p_XDL.Item_i8User:=i8Val(rs.fields.Get_saValue('JMSet_JCaption_ID'));
//      p_XDL.Item_saName:=rs.fields.Get_saValue('JMSet_Name');
//      p_XDL.Item_saValue:=rs.fields.Get_saValue('JMSet_JModuleSetting_UID');
//      p_XDL.Item_saDesc:=i8Val(rs.fields.Get_saValue('JMSet_JNote_ID'));
function bGet_Setting_List_For_Given_Module_ID(
  p_Context: TCONTEXT; 
  p_JModu_JModule_UID: ansistring; 
  var p_XDL: JFC_XDL
): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bGet_Setting_List_For_Given_Module_ID(p_Context: TCONTEXT;p_JModu_JModule_UID: ansistring;var p_XDL: JFC_XDL: boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102463,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102464, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  saQry:=
    'select  jmodule.*, jmodulesetting.*  from jmodule join jmodulesetting on JModu_JModule_UID=JMSet_JModule_ID '+
    'where jmodule.JModu_JModule_UID='+DBC.saDBMSScrub(p_JModu_JModule_UID)+' and '+
    'JMSet_Deleted_b<>'+DBC.sDBMSBoolScrub(true);

  if p_XDL<>nil then 
  begin
    p_XDL.Destroy;p_XDL:=nil;
  end;
  
  p_XDL:=JFC_XDL.Create;
  bOk:=rs.Open(saQry, DBC,201602121656);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201006141232,'Trouble querying jmodule and jmodulesetting tables.','Query: '+saQry,SOURCEFILE,DBC,rs);
  end;
  
  if bOk and (rs.eol=false)then
  begin
    repeat
      p_XDL.AppendItem;
      p_XDL.Item_i8User:=i8Val(rs.fields.Get_saValue('JMSet_JCaption_ID'));
      p_XDL.Item_saName:=rs.fields.Get_saValue('JMSet_Name');
      p_XDL.Item_saValue:=rs.fields.Get_saValue('JMSet_JModuleSetting_UID');
      p_XDL.Item_saDesc:=rs.fields.Get_saValue('JMSet_JNote_ID');
    until not rs.movenext;    
  end;
  rs.close;
  
  if bOk = false then
  begin
    if p_XDL <> nil then
    begin
      p_XDL.Destroy;p_XDL:=nil;
    end;
  end;  
  rs.Destroy;rs:=nil;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102465,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
{}
// Returns a Populated JFC_XDL object of all the settings for a given Module
// Install instance. This function returns actual configuration values for each setting.
// This function returns an instantiated JFC_XDL. Upon entry, if the p_XDL
// parameter is not nil a p_XDL.Destroy will be executed upon it assuming it
// is an instantiated JFC_XDL object. So be sure to set your JFC_XDL variable to 
// nil before calling this function or expect an exception when this function tries to 
// blast your unintialized pointer thinking it's an Instantiated JFC_XDL Object. 
// Returns true if successful, false if not.
function bGet_ModuleConfig_Values_For_Given_Install(
  p_Context: TCONTEXT; 
  p_JInst_JInstalled_UID: ansistring; 
  var p_XDL: JFC_XDL
): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  rJModule: rtJModule;
  XDL: JFC_XDL;
  u8PermissionID: UInt64;
  saNotesResult: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}
  sTHIS_ROUTINE_NAME:='bGet_ModuleConfig_Values_For_Given_Install(p_Context: TCONTEXT;p_JInst_JInstalled_UID: ansistring;'+
    'var p_XDL: JFC_XDL): boolean;';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102466,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102467, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  saQry:='';
  XDL:=nil;
  saNotesResult:='';

  if p_XDL <> nil then
  begin
    p_XDL.Destroy;p_XDL:=nil;
  end;
  
  if bOk then
  begin
    saQry:='select JInst_JModule_ID from jinstalled '+
      ' where JInst_JInstalled_UID='+DBC.saDBMSScrub(p_JInst_JInstalled_UID)+' and '+
      'JInst_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.Open(saQry, DBC,201602121657);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201006160136,'Trouble querying jinstalled table.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;
  end;

  if bOk then
  begin
    if rs.eol=false then
    begin
      rJModule.JModu_JModule_UID:=u8Val(rs.fields.Get_saValue('JModu_JModule_UID'));
    end;
  end;
  rs.close;
  
  if bOk then
  begin
    bOk:=bGet_Setting_List_For_Given_Module_ID(p_Context, inttostr(rJModule.JModu_JModule_UID), XDL);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201006160137,'Trouble bGet_Setting_List_For_Given_Module_ID.','rJModule.JModu_JModule_UID: '+inttostr(rJModule.JModu_JModule_UID),SOURCEFILE);
    end;
  end;

  if bOk then // XDL shouldn't be nil 
  begin
    bOk:=XDL <> nil;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201006160138,'XDL is nil and it should be after call to bGet_Setting_List_For_Given_Module_ID.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    if XDL.MoveFirst then
    begin
      //      XDL.Item_i8User:=i8Val(rs.fields.Get_saValue('JMSet_JCaption_ID'));
      //      XDL.Item_saName:=rs.fields.Get_saValue('JMSet_Name');
      //      XDL.Item_saValue:=rs.fields.Get_saValue('JMSet_JModuleSetting_UID');
      //      XDL.Item_saDesc:=i8Val(rs.fields.Get_saValue('JMSet_JNote_ID'));
      repeat
        saQry:='select * from jmoduleconfig '+
          'where JMCfg_JInstalled_ID='+DBC.saDBMSScrub(p_JInst_JInstalled_UID)+' and '+
          ' JMCfg_JModuleSetting_ID='+DBC.saDBMSScrub(p_XDL.Item_saValue)+' and '+
          ' ((JMCfg_JUser_ID is null) or (JMCfg_JUser_ID='+inttostr(p_Context.rJSession.JSess_JUser_ID)+')) and '+
          ' JMCfg_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
        bOk:=rs.Open(saQry, DBC,201602121658);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_Error,201006160139,'Trouble querying jmoduleconfig table.','Query:'+saQry,SOURCEFILE,DBC,rs);
        end;
        
        if rs.eol=false then
        begin
          u8PermissionID:=u8Val(rs.fields.Get_saValue('JMCfg_Read_JSecPerm_ID'));
          if (u8PermissionID=0) or (bJAS_HasPermission(p_Context,u8PermissionID)) then
          begin
            p_XDL.AppendItem;
            p_XDL.Item_saName:=XDL.Item_saName;
            p_XDL.Item_saValue:=rs.fields.Get_saValue('JMCfg_Value');
            if(bJASNote(p_Context, u8val(rs.fields.Get_saValue('JMCfg_JNote_ID')), saNotesResult,''))then
            begin
              p_XDL.Item_saDesc:=saNotesResult;
            end;
            p_XDL.Item_i8User:=i8Val(rs.fields.Get_saValue('JMCfg_JUser_ID'));
          end;
        end;
        rs.close;
      until (not bOk) or (not XDL.MoveNext);    
    end;
  end;
  rs.Destroy;rs:=nil;
  if XDL<>nil then 
  begin
    XDL.Destroy;XDL:=nil;
  end;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102468,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
{}
// Returns specific setting's configuration value for a given Module Install 
// instance and setting name combination. 
// This function returns an instantiated JFC_XDL. 
// Returns true if successful, false if not or if anything is missing.
// E.G. p_JInst_JInstalled_UID can't be found
// p_JMSet_Name can't be found or
// Actual setting value record can not be found. 
function bGet_ModuleConfig_Value_For_Given_Install(
  p_Context: TCONTEXT; 
  p_JInst_JInstalled_UID: ansistring;
  p_JMSet_Name: ansistring;  
  var p_saValue: ansistring;
  var p_saNotes: ansistring
): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  rJModule: rtJModule;
  rJModuleSetting: rtJModuleSetting;
  //rModuleConfig: rtJModuleConfig;
  u8PermissionID: UInt64;
  saNotesResult: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}
  sTHIS_ROUTINE_NAME:='bGet_ModuleConfig_Value_For_Given_Install(p_Context: TCONTEXT;p_JInst_JInstalled_UID: ansistring;'+
    'p_JMSet_Name: ansistring;var p_saValue: ansistring;var p_saNotes: ansistring): boolean;';
{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102469,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102470, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  saQry:='';
  saNotesResult:='';

  if bOk then
  begin
    saQry:='select JInst_JModule_ID from jinstalled '+
      'where JInst_JInstalled_UID='+DBC.saDBMSScrub(p_JInst_JInstalled_UID)+' and '+
      'JInst_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.Open(saQry, DBC,201602121659);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201006160140,'Trouble querying jinstalled table.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.eol=false);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201006161850,'Zero Results trying to gather a module instance setting.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;
  end;
  
  if bOk then
  begin
    rJModule.JModu_JModule_UID:=u8Val(rs.fields.Get_saValue('JInst_JModule_ID'));
  end;
  rs.close;
  
  if bOk then
  begin
    saQry:='select JMSet_JModuleSetting_UID from jmodulesetting '+
      ' where JMSet_JModule_ID='+DBC.sDBMSUIntScrub(rJModule.JModu_JModule_UID)+' and '+
      ' JMSet_Name='+DBC.saDBMSScrub(p_JMSet_Name)+' and '+
      ' JMSet_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.open(saQry,DBC,201602121700);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201006160141,'Trouble querying jmodulesetting table.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;
  end;
  
  if bOk then
  begin
    bOk:=rs.eol=false;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201006160142,'Zero records returned querying jmodulesetting table.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;
  end;
  
  if bOk then
  begin  
    rJModuleSetting.JMSet_JModuleSetting_UID:=u8Val(rs.fields.Get_saValue('JMSet_JModuleSetting_UID'));
  end;
  rs.close;    
        
  if bOk then 
  begin
    saQry:='select * from jmoduleconfig '+
      'where JMCfg_JInstalled_ID='+DBC.saDBMSScrub(p_JInst_JInstalled_UID)+' and '+
      ' JMCfg_JModuleSetting_ID='+DBC.sDBMSUintScrub(rJModuleSetting.JMSet_JModuleSetting_UID)+' and '+
      ' ((JMCfg_JUser_ID is null) or (JMCfg_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJSession.JSess_JUser_ID)+') or (JMCfg_JUser_ID=0)) and '+
      ' JMCfg_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.Open(saQry, DBC,201602121701);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201006160143,'Trouble querying jmoduleconfig table.','Query:'+saQry,SOURCEFILE,DBC,rs);
    end;
  end;
  
  if bOk then
  begin
    bOk:=(rs.eol=false);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201006160143,'Zero records returned querying jmoduleconfig table.','Query: '+saQry,SOURCEFILE,DBC,rs);
    end;
  end;  
    
  if bOk then
  begin
    u8PermissionID:=u8Val(rs.fields.Get_saValue('JMCfg_Read_JSecPerm_ID'));
    if (u8PermissionID=0) or (bJAS_HasPermission(p_Context,u8PermissionID)) then
    begin
      p_saValue:=rs.fields.Get_saValue('JMCfg_Value');
      if(bJASNote(p_Context, u8Val(rs.fields.Get_saValue('JMCfg_JNote_ID')), saNotesResult,''))then
      begin
        p_saNotes:=saNotesResult;
      end;
    end
    else
    begin
      JAS_Log(p_Context,cnLog_Info,201006160144,'Permission not granted trying to get a module instance config value.',
        'i4Permission: '+inttostr(u8PermissionID)+' bHasPermission:'+sTrueFalse(bJAS_HasPermission(p_Context,u8PermissionID)),SOURCEFILE);
    end;
   
    rs.close;
  end;
  rs.Destroy;rs:=nil;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102471,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
