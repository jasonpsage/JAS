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
// JAS Database Tools
Unit uj_dbtools;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_dbtools.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF DEBUGLOGBEGINEND}
  {$INFO | DEBUGLOGBEGINEND: TRUE}
{$ENDIF}

{DEFINE DEBUGTHREADBEGINEND} // used for thread debugging, like begin and end sorta
                  // showthreads shows the threads progress with this.
                  // whereas debuglogbeginend is ONE log file for all.
                  // a bit messy for threads. See uxxg_jfc_threadmgr for
                  // mating define - to use this here, needs to be declared
                  // in uxxg_jfc_threadmgr also.
{$IFDEF DEBUGTHREADBEGINEND}
  {$INFO | DEBUGTHREADBEGINEND: TRUE}
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
,dos
,syncobjs
,sysutils
,ug_misc
,ug_common
,ug_jegas
,ug_tsfileio
,ug_jfc_dir
,ug_jfc_xdl
,ug_jfc_xxdl
,ug_jfc_tokenizer
,ug_jfc_matrix
,ug_jado
,uj_definitions
,uj_context
,uj_tables_loadsave
,uj_permissions
,uj_fileserv
,uj_webwidgets
,uj_locking
,uj_sessions
,uj_notes
,uj_captions
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
// Delete all records in tables with _Deleted_b flag set to true.
procedure DBM_EmptyTrash(p_Context: TCONTEXT);
//=============================================================================
{}
// Delete all orphaned records in the database.
// The jnote and jcaption tables need to have the "Flag Orphans" utility
// executed to effectively be included. The reason is you can edit records
// flagged as orphans and optionally flag them to be kept regardless if
// currently orphaned or not. e.g. A note record named "Welcome" isn't used
// in a screen yet so it will be flagged an orphan by the "Flag Orphans"
// utility.
//
// Now other tables are treated with less user interaction because these
// other types of orphans are bad data unless you disconnected something that
// shouldn't have. Hopefully you fix any issues like this before running the
// "Kill Orphans" utility.
//
// Tables that are scrutized for orphans and freed of them are in this
// list as follows. Note Only the jnote and jcaption table have a KEEP
// or preservation flag to keep some orphans; the rest of these tables do not
// have that functionality:
//
//    jblok
//    jblokbutton
//    jblokfield
//    jmenu
//    jsecgrplink
//    jsecgrpuserlnk
//    jsecpermuserlink
//    jsysmodulelink
//    jinvoicelines
//    jinstalled
//    jmodc
//    jmodulesettings
//    jmoduleconfig
//    juserpreflink
//    jcaption
//    jnote
//
//
procedure DBM_KillOrphans(p_Context: TCONTEXT);
//=============================================================================
{}
// This function goes thru DBMS schema and corrects jcolumn Records if it can
// EACH DBMS will need to be addressed as the techniques and data will vary.
// Starting with MySQL and using the information schema.
procedure DBM_SyncDBMSColumns(p_Context: TCONTEXT);
//=============================================================================
{}
// This function examines jblokfield records system wide. If they have a
// column associated with then (i.e. not a custom jblokfield) and the
// properties aren't set for max width, length and height - this function
// adjusts them based on the associated database columns.
procedure DBM_SyncScreenFields(p_Context: TCONTEXT);
//=============================================================================
{}
procedure DBM_JCaptionFlagOrphans(p_Context: TCONTEXT);
//=============================================================================
{}
procedure DBM_JNoteFlagOrphans(p_Context: TCONTEXT);
//=============================================================================
{}
// This procedure compares JAS Database info against actual database
procedure DBM_DiffTool(p_Context: TCONTEXT);
//=============================================================================
{}
// Delete all records in tables with _Deleted_b flag set to true.
procedure DBM_WipeAllRecordLocks(p_Context: TCONTEXT);
//=============================================================================
{}
// Updates jorgmember by interrogating the jperson table and the jorganiztion
// table to find members that may not of been added.
procedure DBM_UpdateOrgMembers(p_Context: TCONTEXT);
//=============================================================================
{}
// Diagnostic looking for Duplicate UID's. Shouldn't be any, but if there
// are, the table should be altered to have the UID column set as the primary
// key after the data is scrubbed accordingly.
procedure DBM_FindDupeUID(p_Context: TCONTEXT);
//=============================================================================
{}
// This tool allows you to point to a connected database connection and select
// one or more tables and submit your selection. Once submitted this function
// will add table records and column records into JAS' meta data allowing you
// to later view them, and make screens for them from the JTable Search
// screen or from the record/detail view of any one of those tables.
procedure DBM_LearnTables(p_Context: TCONTEXT);
//=============================================================================
{}
// Routine that does the actual importing of CSV files
procedure CSVUpload(p_Context: TCONTEXT);
//=============================================================================
{}
// Routine To Handle the process of mapping fields from the CSV to the
// target table
procedure CSVMapfields(p_Context: TCONTEXT);
//=============================================================================
{}
// First step int the CSV import process -starts here
procedure CSVImport(p_Context: TCONTEXT);
//=============================================================================
{}
// This function literally synchronizes Itself with another JAS Installation
// connected as a Datasource. It doesn't work over the web via some sort of
// webbrowser connection. A web browser is the default way to invoke the
// synchronization however.
procedure JASSync(p_Context: TCONTEXT);
//=============================================================================
{}
// handles uploaded files to system
procedure FileUpload(p_Context: TCONTEXT);
//=============================================================================
{}
// This function is for downloading files from the file repository and it
// takes permissions and ownership into consideration. Ownership first,
// if the user is not the Owner (Created By) then the user must have the
// permission assigned to the file. If they do not have the permission,
// or the permission is NULL or ZERO - then access is denied.
procedure FileDownload(p_Context: TCONTEXT);
//=============================================================================
{}
// Delete JBlok children
function bPreDel_JBlok(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
{}
// Delete JCase children
function bPreDel_JCase(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JTask children
function bPreDel_JTask(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Rename JFile Records File to Linux "hidden"; prepend period to name.
function bPreDel_JFile(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JOrg Children
function bPreDel_JOrg(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JFilterSave Children (defaults)
function bPreDel_JFilterSave(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JIconContext Children (jiconmaster)
function bPreDel_JIconContext(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JInvoice Children (jinvoicelines)
function bPreDel_JInvoice(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JLead Children
function bPreDel_JLead(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JInstalled Children
function bPreDel_JInstalled(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JModuleSetting Children
function bPreDel_JModuleSetting(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JModule Children
function bPreDel_JModule(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JPerson Children
function bPreDel_JPerson(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JProject Children
function bPreDel_JProject(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JProduct Children
function bPreDel_JProduct(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JScreen children   - here for a circular reference /.... hmm i wonder if I knocked that out the park...
function bPreDel_JScreen(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JSecGrp Children
function bPreDel_JSecGrp(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JSecPerm Children
function bPreDel_JSecPerm(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JSession Children
function bPreDel_JSession(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JSysModule Children
function bPreDel_JSysModule(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JSysModuleLink Children
function bPreDel_JSysModuleLink(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JTable Children (columns)
function bPreDel_JTable(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JTeam Children
function bPreDel_JTeam(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// Delete JUser Children
function bPreDel_JUser(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64):boolean;
//=============================================================================
{}
// This function is only for the main JAS database and is for preparing for
// distribution of new upgrades, making new JAS databases and new Jet
// databases.
procedure DBM_FlagJasRow(p_Context: TCONTEXT);
//=============================================================================
{}
// This function does the actual work that DBM_FlagJasRow commands.
procedure DBM_FlagJasRowExecute(p_Context: TCONTEXT);
//=============================================================================
{}
// Makes new user, password and database and makes a JAS connection
// for it using same info. This routin passes back the JDConnection UID
// when successful or a ZERO if it fails. Note the connection IS NOT ENABLED
// so the next step to make the database etc would be to load the info
// into an instance of JDCON, Doo all you have to do then SAVE the connection
// as ENABLED and send the Cycle command into the JobQueue of the Squadron
// Leader databse.
function u8NewConAndDB(
  p_Context: TCONTEXT;
  p_saName: ansistring// becomes user name, password, and database name.
): UInt64;
//=============================================================================
{}
// DBC - Main DB Connection (SOURCE)
// JDCon_JDConnection_UID: Database connection in source DB to use
// Name to use making a connection if JDCon_JDConnection_UID is ZERO on entry
// bLeadJet: If True treat as Master Database, otherwise like a JET database.
//
// Makes New Master databses or Jet databases and also upgrades existing
// databases.
//
// Make Tables (jtable info) or Alter
//   NOTE: if not exist (Use JAS_Row_b Column Records for info)
// Add Rows or Update from master flagged JAS_Row_b
//   Note: Tables without JAS_Row_b - Add rows (e.g. jasident, juserpref)
// TODO: Add VIEW SQL to jtable - for each DBMS - Use to make Views)
function bDBMasterUtility(
  p_Context: TCONTEXT;
  p_DBC: JADO_CONNECTION;
  var p_JDCon_JDConnection_UID: UInt64;// UID of Target connection
  p_saName: ansistring; //< if p_JDCon_JDConnection_UID = 0 then NAME is
                        //< used to create connection record using info
                        //< from JAS connection. new user name made etc.
  p_bLeadJet: boolean   //< Whether to upgrade/create a Jet Leader DB or
                        //< a Jet DB. Jet Leader = Main JAS Database.
): boolean;
//=============================================================================
{}
// Make Default Security Settings
function bSetDefaultSecuritySettings(p_Context: TCONTEXT): Boolean;
//=============================================================================
{}
procedure DBM_RemoveJet(p_Context: TCONTEXT);
//=============================================================================
{}
function  bDBM_DatabaseScrub(p_Context: TCONTEXT): boolean;
//=============================================================================
{}
// this is the same as DBM_RenderHtmlErrorPage(p_Context: TCONTEXT) in
// uj_ui_stock.pp and its here only to prevent a circular reference.
// DbTools needs its own Error Page Renderer, thats all. :)
Procedure DBM_RenderHtmlErrorPage(p_Context: TCONTEXT);
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
// Delete all records in tables with _Deleted_b flag set to true.
procedure DBM_EmptyTrash(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  TGT: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  rs3: JADO_RECORDSET;
  saQry: ansistring;
  rJTable: rtJTable;
  sa: ansistring;
  //saJASROw: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_EmptyTrash';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102283,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102284, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  rs3:=JADO_RECORDSET.Create;

  if bOk then
  begin
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201206211550, 'Unable to comply - session is not valid.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_EmptyTrash);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201206211551,
        '"Database Maintenance" - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;


  //if bOk then
  //begin
  //  //if garJVHostLight[p_Context.i4VHost].saServerDomain='default' then

  //saJASROW:=' AND (not JAS_Row_b)';// else saJASRow:='';

  //
  //  saQry:='delete from jtable where JTabl_Deleted_b='+DBC.sDBMSBoolScrub(true)+saJASRow;
  //  bOk:=rs.open(saQry, DBC,201503161220);
  //  if not bOk then
  //  begin
  //    JAS_Log(p_Context, cnLog_Error,201203031737, 'Trouble removing deleted rows from jtable','Query:'+saQry,SOURCEFILE,DBC,rs);
  //    DBM_RenderHtmlErrorPage(p_Context);
  //  end;
  //  rs.close;
  //end;

  //if bOk then
  //begin
  //  saQry:='delete from jcolumn where JColu_Deleted_b='+DBC.sDBMSBoolScrub(true)+saJASRow;
  //  bOk:=rs.open(saQry, DBC,201503161221);
  //  if not bOk then
  //  begin
  //    JAS_Log(p_Context, cnLog_Error,201203031737, 'Trouble removinged deleted rows from jtable','Query:'+saQry,SOURCEFILE,DBC,rs);
  //    DBM_RenderHtmlErrorPage(p_Context);
  //  end;
  //  rs.close;
  //end;



  if bOk then
  begin
    saQry:=
      'select '+
      '  JTabl_JTable_UID, JTabl_Name '+
      'from jtable ';
    saQry+=
      'where '+
      '  (JTabl_JTableType_ID='+DBC.sDBMSUIntScrub(cnTableType_Table)+') and ((JTabl_Deleted_b=false) or (JTabl_Deleted_b is null))' +
      'order by JTabl_Name';
    bOk:=rs.open(saQry,DBC,201503161222);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201203031733, 'Trouble Querying jtable ','Query:'+saQry,SOURCEFILE,DBC,rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    repeat
      clear_JTable(rJTable);
      rJTable.JTabl_JTable_UID:=u8Val(rs.fields.Get_saValue('JTabl_JTable_UID'));
      if bJAS_Load_JTable(p_Context, DBC,rJTable, false, 201608300025) then
      begin
        JASPrintln('  Table: '+rJTable.JTabl_Name);
        saQry:=
          'select '+
          '  JColu_JColumn_UID '+
          'from jcolumn '+
          'where '+
          '  JColu_JTable_ID='+DBC.sDBMSIntScrub(rJTable.JTabl_JTable_UID)+' and '+
          '  JColu_Name='+DBC.saDBMSSCrub(rJTable.JTabl_ColumnPrefix+'_Deleted_b');
        bOk:=rs2.open(saQry, DBC,201503161223);
        if not bOk then
        begin
          JAS_Log(p_Context, cnLog_Error,201203031735, 'Trouble executing query on jcolumn.','Query: '+saQry,SOURCEFILE,DBC,rs2);
          DBM_RenderHtmlErrorPage(p_Context);
        end;



        if bOk and (rs2.eol=false) then
        begin
          if rJTable.JTabl_JDConnection_ID=0 then rJTable.JTabl_JDConnection_ID:=1;//main connect zero or 1 = 1 here.
          TGT:=p_Context.DBCON(rJTable.JTabl_JDConnection_ID,201610312254);
          if TGT.bColumnExists(rJTable.JTabl_Name,rJTable.JTabl_ColumnPrefix+'_Deleted_b',201210050407) then
          begin
            saQry:='delete from '+rJTable.JTabl_Name+' where '+rJTable.JTabl_ColumnPrefix+'_Deleted_b='+TGT.sDBMSBoolScrub(true);
            bOk:=rs3.open(saQry, TGT,201503161224);
            if not bOk then
            begin
              JAS_Log(p_Context, cnLog_Error,201203031741, 'Trouble removing records flagged as deleted.','Query: '+saQry,SOURCEFILE,DBC,rs3);
              DBM_RenderHtmlErrorPage(p_Context);
            end;
            rs3.close;
          end;
        end;
        rs2.close;
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs3.destroy;
  rs2.destroy;
  rs.destroy;

  if bOk then
  begin
    bOk:=bJASNote(p_Context,6439,sa,'Trash emptied.');
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_message','',false, 201203122216);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/places/user-trash.png');
    p_Context.saPageTitle:='Emptied Trash';
    p_Context.bNoWebCache:=true;
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102285,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




















//=============================================================================
{}
function bKO_jblokbutton(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jblokbutton(p_Context: TCONTEXT): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102286,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102287, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;

  saQry:='select JBlkB_JBlokButton_UID, JBlkB_JBlok_ID from jblokbutton where JBlkB_Deleted_b='+DBC.sDBMSBoolScrub(false);
  bOk:=rs.open(saQry, DBC,201503161225);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201203032035, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      if DBC.u8GetRecordCount('jblok','JBlok_JBlok_UID='+rs.fields.Get_saValue('JBlkB_JBlok_ID')+' and JBlok_Deleted_b='+DBC.sDBMSBoolScrub(false),201506171719)=0 then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jblokbutton',u8Val(rs.fields.Get_saValue('JBlkB_JBlokButton_UID')));
        if not bOk then
        begin
          JAS_Log(p_Context, cnLog_Error,201203032036, 'Trouble deleting record.','',SOURCEFILE);
          DBM_RenderHtmlErrorPage(p_Context);
        end;
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;

  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102288,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
















//=============================================================================
{}
function bKO_jblokfield(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jblokfield(p_Context: TCONTEXT): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102289,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102290, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;

  saQry:='select JBlkF_JBlokField_UID, JBlkF_JBlok_ID from jblokfield where JBlkF_Deleted_b='+DBC.sDBMSBoolScrub(false);
  bOk:=rs.open(saQry, DBC,201503161226);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201203032037, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      if DBC.u8GetRecordCount('jblok','JBlok_JBlok_UID='+rs.fields.Get_saValue('JBlkF_JBlok_ID')+' and JBlok_Deleted_b='+DBC.sDBMSBoolScrub(false),201506171720)=0 then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jblokfield',u8Val(rs.fields.Get_saValue('JBlkF_JBlokField_UID')));
        if not bOk then
        begin
          JAS_Log(p_Context, cnLog_Error,201203032038, 'Trouble deleting record.','',SOURCEFILE);
          DBM_RenderHtmlErrorPage(p_Context);
        end;
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102291,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

















//=============================================================================
{}
function bKO_jblok(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jblok(p_Context: TCONTEXT): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102292,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102293, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select JBlok_JBlok_UID, JBlok_JScreen_ID from jblok where JBlok_Deleted_b='+DBC.sDBMSBoolScrub(false);
  bOk:=rs.open(saQry, DBC,201503161227);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201203032039, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      if DBC.u8GetRecordCount('jscreen','JScrn_JScreen_UID='+rs.fields.Get_saValue('JBlok_JScreen_ID')+' and JScrn_Deleted_b='+DBC.sDBMSBoolScrub(false),201506171721)=0 then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jblok',u8Val(rs.fields.Get_saValue('JBlok_JBlok_UID')));
        if not bOk then
        begin
          JAS_Log(p_Context, cnLog_Error,201203032040, 'Trouble deleting record.','',SOURCEFILE);
          DBM_RenderHtmlErrorPage(p_Context);
        end;
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102294,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
























//=============================================================================
{}
function bKO_jmenu(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
  i4Removed: longint;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jmenu(p_Context: TCONTEXT): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102294,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102295, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;

  repeat
    i4Removed:=0;
    saQry:='select JMenu_JMenu_UID, JMenu_JMenuParent_ID from jmenu where JMenu_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
    bOk:=rs.open(saQry, DBC,201503161228);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201203032041, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;

    if bOk and (rs.eol=false) then
    begin
      repeat
        if u8Val(rs.fields.Get_saValue('JMenu_JMenuParent_ID'))>0 then
        begin
          if DBC.u8GetRecordCount('jmenu','JMenu_JMenu_UID='+rs.fields.Get_saValue('JMenu_JMenuParent_ID')+' and JMenu_Deleted_b='+DBC.sDBMSBoolScrub(false),201506171722)=0 then
          begin
            bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jmenu',u8Val(rs.fields.Get_saValue('JMenu_JMenu_UID')));
            if not bOk then
            begin
              JAS_Log(p_Context, cnLog_Error,201203032042, 'Trouble deleting record.','',SOURCEFILE);
              DBM_RenderHtmlErrorPage(p_Context);
            end;
            i4Removed+=1;
          end;
        end;
      until (not bOk) or (not rs.movenext);
    end;
    rs.close;
  until (not bOk) or (i4Removed=0);

  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102296,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
















//=============================================================================
{}
function bKO_jsecgrplink(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jsecgrplink(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205020940,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205020941, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT JSGLk_JSecGrpLink_UID FROM jsecgrplink left join jsecgrp on JSGrp_JSecGrp_UID=JSGLk_JSecGrp_ID '+
    'where JSGLk_JSecGrp_ID is NULL or JSGLk_JSecGrp_ID=0 and JSGLk_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
  bOk:=rs.open(saQry, DBC,201503161229);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201205020942, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC,'jsecgrplink',u8Val(rs.fields.Get_saValue('JSGLk_JSecGrpLink_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jsecgrplink',u8Val(rs.fields.Get_saValue('JSGLk_JSecGrpLink_UID')));
      p_Context.JTrakEnd(u8Val(rs.fields.Get_saValue('JSGLk_JSecGrpLink_UID')),
        'DELETE FROM jsecgrplink WHERE JSGLk_JSecGrpLink_UID='+DBC.sDBMSUintScrub(rs.fields.Get_saValue('JSGLk_JSecGrpLink_UID'))
      );
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201205020943, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205020944,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
{}
function bKO_jsecgrpuserlnk(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jsecgrpuserlnk(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205020945,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205020946, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select JSGUL_JSecGrpUserLink_UID from jsecgrpuserlink WHERE JSGUL_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
    'JSGUL_JSecGrp_ID is null or JSGUL_JSecGrp_ID=0 or JSGUL_JUser_ID is null or JSGUL_JUser_ID=0';
  bOk:=rs.open(saQry, DBC,201503161230);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201205020947, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC,'jsecgrpuserlink',u8Val(rs.fields.Get_saValue('JSGUL_JSecGrpUserLink_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jsecgrpuserlink',u8Val(rs.fields.Get_saValue('JSGUL_JSecGrpUserLink_UID')));
      p_Context.JTrakEnd(u8Val(rs.fields.Get_saValue('JSGUL_JSecGrpUserLink_UID')),
        'DELETE FROM jsecgrpuserlink WHERE JSGUL_JSecGrpUserLink_UID='+rs.fields.Get_saValue('JSGUL_JSecGrpUserLink_UID')
      );





      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201205020948, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205020949,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





//=============================================================================
{}
function bKO_jsecpermuserlink(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jsecpermuserlink(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205020950,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205020951, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT JSPUL_JSecPermUserLink_UID FROM jsecpermuserlink where JSPUL_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
    '(JSPUL_JSecPerm_ID=0 or JSPUL_JSecPerm_ID is null or JSPUL_JUser_ID=0 or JSPUL_JUser_ID is NULL)';
  bOk:=rs.open(saQry, DBC,201503161231);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201205020952, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC,'jsecpermuserlink',u8Val(rs.fields.Get_saValue('JSPUL_JSecPermUserLink_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jsecpermuserlink',u8Val(rs.fields.Get_saValue('JSPUL_JSecPermUserLink_UID')));
      p_Context.JTrakEnd(u8Val(rs.fields.Get_saValue('JSPUL_JSecPermUserLink_UID')),
        'DELETE FROM jsecpermuserlink WHERE JSPUL_JSecPermUserLink_UID='+rs.fields.Get_saValue('JSPUL_JSecPermUserLink_UID')
      );

      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201205020948, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205020954,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
{}
function bKO_jsysmodulelink(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jsysmodulelink(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205020955,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205020956, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT JSyLk_JSysModuleLink_UID FROM jsysmodulelink left join jsysmodule on JSysM_JSysModule_UID=JSyLk_JSysModule_ID '+
    'WHERE JSyLk_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
    '(JSyLk_JSysModule_ID is NULL or JSyLk_JSysModule_ID=0)';
  bOk:=rs.open(saQry, DBC,201503161232);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201205020957, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC, 'jsysmodulelink',u8Val(rs.fields.Get_saValue('JSyLk_JSysModuleLink_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jsysmodulelink',u8Val(rs.fields.Get_saValue('JSyLk_JSysModuleLink_UID')));
      p_Context.JTrakEnd(u8Val(rs.fields.Get_saValue('JSyLk_JSysModuleLink_UID')),
        'DELETE FROM jsysmodulelink where JSyLk_JSysModuleLink_UID='+rs.fields.Get_saValue('JSyLk_JSysModuleLink_UID')
      );
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201205020948, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205020959,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
{}
function bKO_jinvoicelines(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jinvoicelines(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205021000,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205021001, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT JILin_JInvoiceLines_UID FROM jinvoicelines left join jinvoice on JIHdr_JInvoice_UID=JILin_JInvoice_ID '+
    'WHERE (JILin_JInvoice_ID is null or JILin_JInvoice_ID=0) AND JILin_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
  bOk:=rs.open(saQry, DBC,201503161233);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201205021002, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC, 'jinvoicelines',u8Val(rs.fields.Get_saValue('JILin_JInvoiceLines_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jinvoicelines',u8Val(rs.fields.Get_saValue('JILin_JInvoiceLines_UID')));
      p_Context.JTrakEnd(u8Val(rs.fields.Get_saValue('JILin_JInvoiceLines_UID')),
        'DELETE FROM jinvoicelines WHERE JILin_JInvoiceLines_UID='+rs.fields.Get_saValue('JILin_JInvoiceLines_UID')
      );
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201205020948, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205021004,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
{}
function bKO_jinstalled(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jinstalled(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205021112,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205021113, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT JInst_JInstalled_UID FROM jinstalled left join jmodule on JModu_JModule_UID=JInst_JModule_ID '+
    'WHERE (JInst_JModule_ID is null or JInst_JModule_ID=0) and JInst_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
  bOk:=rs.open(saQry, DBC,201503161234);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201205021114, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC, 'jinstalled',u8Val(rs.fields.Get_saValue('JInst_JInstalled_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jinstalled',u8Val(rs.fields.Get_saValue('JInst_JInstalled_UID')));
      p_Context.JTrakEnd(
        u8Val(rs.fields.Get_saValue('JInst_JInstalled_UID')),
        'DELETE FROM jinstalled WHERE JInst_JInstalled_UID='+rs.fields.Get_saValue('JInst_JInstalled_UID')
      );
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201205020948, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205021116,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
{}
function bKO_jmodc(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jmodc(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205021005,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205021006, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT JModC_JModC_UID FROM jmodc left join jinstalled on JInst_JInstalled_UID=JModC_JInstalled_ID '+
    'where (JModC_JInstalled_ID=0 or JModC_JInstalled_ID is null) and JModC_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
  bOk:=rs.open(saQry, DBC,201503161235);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201205021007, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC, 'jmodc',u8Val(rs.fields.Get_saValue('JModC_JModC_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jmodc',u8Val(rs.fields.Get_saValue('JModC_JModC_UID')));
      p_Context.JTrakEnd(
        u8Val(rs.fields.Get_saValue('JModC_JModC_UID')),
        'DELETE FROM jmodc WHERE JModC_JModC_UID='+rs.fields.Get_saValue('JModC_JModC_UID')
      );
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201205020948, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205021009,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
{}
function bKO_jmodulesettings(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jmodulesettings(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205021015,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205021016, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT JMSet_JModuleSetting_UID FROM jmodulesetting left join jmodule on JModu_JModule_UID=JMSet_JModule_ID '+
    'where (JMSet_JModule_ID=0 or JMSet_JModule_ID is NULL) AND JMSet_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
  bOk:=rs.open(saQry, DBC,201503161236);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201205021017, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC, 'jmodulesetting',u8Val(rs.fields.Get_saValue('JModC_JModC_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jmodulesetting',u8Val(rs.fields.Get_saValue('JModC_JModC_UID')));
      p_Context.JTrakEnd(
        u8Val(rs.fields.Get_saValue('JModC_JModC_UID')),
        'DELETE FROM jmodulesetting WHERE JModC_JModC_UID='+rs.fields.Get_saValue('JModC_JModC_UID')
      );
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201205020948, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205021019,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
{}
function bKO_jmoduleconfig(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jmoduleconfig(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205021010,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205021011, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT JMCfg_JModuleConfig_UID FROM jmoduleconfig LEFT JOIN jmodulesetting ON JMSet_JModuleSetting_UID=JMCfg_JModuleSetting_ID '+
    'WHERE (JMCfg_JModuleSetting_ID=0 or JMCfg_JModuleSetting_ID is NULL) AND JMCfg_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
  bOk:=rs.open(saQry, DBC,201503161237);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201205021012, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC, 'jmoduleconfig',u8Val(rs.fields.Get_saValue('JMCfg_JModuleConfig_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jmoduleconfig',u8Val(rs.fields.Get_saValue('JMCfg_JModuleConfig_UID')));
      p_Context.JTrakEnd(
        u8Val(rs.fields.Get_saValue('JMCfg_JModuleConfig_UID')),
        'DELETE FROM jmoduleconfig WHERE JMCfg_JModuleConfig_UID='+rs.fields.Get_saValue('JMCfg_JModuleConfig_UID')
      );
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201205020948, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205021014,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









//=============================================================================
{}
function bKO_juserpreflink(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_juserpreflink(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205021020,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205021021, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT UsrPL_UserPrefLink_UID FROM juserpreflink left join juser on JUser_JUser_UID=UsrPL_User_ID '+
    'WHERE (UsrPL_User_ID=0 or UsrPL_User_ID is null)';
  bOk:=rs.open(saQry, DBC,201503161238);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201205021022, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC, 'juserpreflink',u8Val(rs.fields.Get_saValue('UsrPL_UserPrefLink_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'juserpreflink',u8Val(rs.fields.Get_saValue('UsrPL_UserPrefLink_UID')));
      p_Context.JTrakEnd(
        u8Val(rs.fields.Get_saValue('UsrPL_UserPrefLink_UID')),
        'DELETE FROM juserpreflink WHERE UsrPL_UserPrefLink_UID='+rs.fields.Get_saValue('UsrPL_UserPrefLink_UID')
      );
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201205020948, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205021024,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



















//=============================================================================
{}
function bKO_jnote(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jnote(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201610211702,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201610211703, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT JNote_JNote_UID FROM jnote '+
    'WHERE ((JNote_Deleted_b=false) or (JNote_Deleted_b is null)) and (JNote_Orphan_b=true) and ((JNote_Keep_b=false)or(JNote_Keep_b=null))';
  bOk:=rs.open(saQry, DBC,201610211704);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201610211705, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC, 'jnote',u8Val(rs.fields.Get_saValue('JNote_JNote_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jnote',u8Val(rs.fields.Get_saValue('JNote_JNote_UID')));
      p_Context.JTrakEnd(
        u8Val(rs.fields.Get_saValue('UsrPL_UserPrefLink_UID')),
        'DELETE FROM jnote WHERE JNote_JNote_UID='+rs.fields.Get_saValue('JNote_JNote_UID')
      );
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201610211706, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205021024,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


















//=============================================================================
{}
function bKO_jcaption(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs:JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bKO_jcaption(p_Context): boolean;';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201610211702,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201610211703, sTHIS_ROUTINE_NAME);{$ENDIF}


  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='SELECT JCapt_JCaption_UID FROM jcaption '+
    'WHERE ((JCapt_Deleted_b=false) or (JCapt_Deleted_b is null)) and (JCapt_Orphan_b=true) and ((JCapt_Keep_b=false)or(JCapt_Keep_b=null))';
  bOk:=rs.open(saQry, DBC,201610211704);
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201610211705, 'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC,rs);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      p_Context.JTrakBegin(DBC, 'jnote',u8Val(rs.fields.Get_saValue('JCapt_JCaption_UID')));
      bOk:=bJAS_DeleteRecord(p_Context,DBC, 'jnote',u8Val(rs.fields.Get_saValue('JCapt_JCaption_UID')));
      p_Context.JTrakEnd(
        u8Val(rs.fields.Get_saValue('JCapt_JCaption_UID')),
        'DELETE FROM jcaption WHERE JCapt_JCaption_UID='+rs.fields.Get_saValue('JCapt_JCaption_UID')
      );
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201610211706, 'Trouble deleting record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201205021024,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







































//=============================================================================
{}
procedure DBM_KillOrphans(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  sa: ansistring;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_KillOrphans(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102297,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102298, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  if bOk then
  begin
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201016211550, 'Unable to comply - session is not valid.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_KillOrphans);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201016211551,
        '"Database Maintenance" - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;


  if bOk then
  begin
    bOk:=bKO_JBlok(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jblokbutton(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jblokfield(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_JMenu(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jsecgrplink(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jsecgrpuserlnk(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jsecpermuserlink(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jsysmodulelink(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jinvoicelines(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jinstalled(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jmodc(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jmodulesettings(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jmoduleconfig(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_juserpreflink(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jcaption(p_Context);
  end;

  if bOk then
  begin
    bOk:=bKO_jnote(p_Context);
  end;


  if bOk then
  begin
    bOk:=bJASNote(p_Context,6440,sa,'Orphan records deleted.');
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_message','',false, 201203122225);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/places/user-trash.png');
    p_Context.saPageTitle:='Success';
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102299,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================













//=============================================================================
{}
procedure DBM_SyncDBMSColumns(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  saQry: ansistring;
  rJColumn: rtJColumn;
  bUnsigned: boolean;
  u8JDType: uInt64;
  sa: ansistring;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_SyncDBMSColumns(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102300,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102301, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;


  if bOk then
  begin
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201006211550, 'Unable to comply - session is not valid.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_SyncDBMSColumns);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201006211551,
        '"Database Maintenance" - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;



  if bOk then
  begin
    saQry:=
      'SELECT * '+
      'FROM INFORMATION_SCHEMA.COLUMNS '+
      'WHERE TABLE_SCHEMA='''+DBC.saMyDatabase+''' '+
      'ORDER BY TABLE_NAME, ORDINAL_POSITION';
    bOk:=rs.open(saQry, DBC,201503161239);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201203050129, 'Trouble Querying Information Schema','Query:'+saQry,SOURCEFILE, DBC, rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    repeat
      if not rs.eol then
      begin
        saQry:='select JTabl_Name, JTabl_JTable_UID, JColu_Name, JColu_JColumn_UID from jcolumn inner join jtable on JTabl_JTable_UID=JColu_JTable_ID '+
               'where JTabl_Name='+DBC.saDBMSScrub(rs.fields.Get_saValue('TABLE_NAME'))+' and '+
               'JColu_Name='+DBC.saDBMSScrub(rs.fields.Get_saValue('COLUMN_NAME'));
        bOk:=rs2.open(saQry, DBC,201503161240);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201203050130, 'Trouble Querying JAS Tables and Columns','Query:'+saQry,SOURCEFILE, DBC, rs2);
          DBM_RenderHtmlErrorPage(p_Context);
        end;
      end;

      if bOk and (not rs2.eol) then
      begin
        clear_jcolumn(rJColumn);
        rJColumn.JColu_JColumn_UID:=u8Val(rs2.fields.Get_saValue('JColu_JColumn_UID'));
        bOk:=bJAS_Load_JColumn(p_Context, DBC, rJColumn, true, 201608300026);
        if not bok then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201203050131, 'Trouble Loading JColumn record. '+
            'Table: '+rs2.fields.Get_saValue('JTabl_Name')+' '+
            'Column: '+rs2.fields.Get_saValue('JColu_Name'),'Query:'+saQry,SOURCEFILE);
          DBM_RenderHtmlErrorPage(p_Context);
        end;

        if bOk then
        begin
          JASPrintln('Table: '+rs2.fields.Get_saValue('JTabl_Name')+' Column: '+rJColumn.JColu_Name);
          //-------------------------------------------------------------------------Begin Figuring out Jegas Data Type
          u8JDType:=cnJDType_Unknown;

          rJColumn.JColu_DefinedSize_u         :=uVal(rs.fields.Get_saValue('CHARACTER_MAXIMUM_LENGTH'));

          // THESE Need to be swapped based on findings so far - they appear backwards
          // If this doesn't work out - set back to the way it seems it should be.
          rJColumn.JColu_NumericScale_u        :=uVal(rs.fields.Get_saValue('NUMERIC_PRECISION'));
          rJColumn.JColu_Precision_u           :=uVal(rs.fields.Get_saValue('NUMERIC_SCALE'));

          
          if (rs.fields.Get_saValue('DATA_TYPE')='tinytext') or
             (rs.fields.Get_saValue('DATA_TYPE')='text') or
             (rs.fields.Get_saValue('DATA_TYPE')='mediumtext') or
             (rs.fields.Get_saValue('DATA_TYPE')='longtext') then
          begin
            //if rs.fields.Get_saValue('CHARACTER_SET_NAME')='utf8' then
            u8JDType:=cnJDType_sn;
          end else

          bUnsigned:=(saRightStr(rs.fields.Get_saValue('COLUMN_TYPE'),7)='unsigned');
          if rs.fields.Get_saValue('DATA_TYPE')='tinyint' then
          begin
            if bUnsigned then u8JDType:=cnJDType_i1 else u8JDType:=cnJDType_u1;
            rJColumn.JColu_DefinedSize_u:=1;
            if rJColumn.JColu_Boolean_b then u8JDType:=cnJDType_b;
          end else

          if rs.fields.Get_saValue('DATA_TYPE')='smallint' then
          begin
            if bUnsigned then u8JDType:=cnJDType_i2 else u8JDType:=cnJDType_u2;
            rJColumn.JColu_DefinedSize_u:=2;
          end else

          if rs.fields.Get_saValue('DATA_TYPE')='int' then
          begin
            if bUnsigned then u8JDType:=cnJDType_i4 else u8JDType:=cnJDType_u4;
            rJColumn.JColu_DefinedSize_u:=4;
          end else

          if rs.fields.Get_saValue('DATA_TYPE')='bigint' then
          begin
            if bUnsigned then u8JDType:=cnJDType_i8 else u8JDType:=cnJDType_u8;
            rJColumn.JColu_DefinedSize_u:=8;
          end else

          if (rs.fields.Get_saValue('DATA_TYPE')='double') or
             (rs.fields.Get_saValue('DATA_TYPE')='single') or
             (rs.fields.Get_saValue('DATA_TYPE')='real') or
             (rs.fields.Get_saValue('DATA_TYPE')='float') then
          begin
            u8JDType:=cnJDType_fp;
          end else


          if (rs.fields.Get_saValue('DATA_TYPE')='decimal') or
             (rs.fields.Get_saValue('DATA_TYPE')='numeric') then
          begin
            u8JDType:=cnJDType_fd;
          end else

          if (rs.fields.Get_saValue('DATA_TYPE')='char') or
             (rs.fields.Get_saValue('DATA_TYPE')='varchar') then
          begin
            if iVal(rs.fields.Get_saValue('CHARACTER_MAXIMUM_LENGTH'))=1 then
            begin
              u8JDType:=cnJDType_ch;
            end
            else
            begin
              u8JDType:=cnJDType_s;
            end;
          end else

          //if (rs.fields.Get_saValue('DATA_TYPE')='tinyint') then
          //begin
          //  Const cnJDType_b        = 20; //< Jegas Data Type - Boolean - Byte	b
          //  Const cnJDType_bi1      = 21; //< Jegas Data Type - Boolean - Boolean Integer - 1 Byte - >Zero=true	bi1
          //end;

          if (rs.fields.Get_saValue('DATA_TYPE')='datetime') then
          begin
            u8JDType:=cnJDType_dt;
          end else

          if (rs.fields.Get_saValue('DATA_TYPE')='tinyblob') or
             (rs.fields.Get_saValue('DATA_TYPE')='blob') or
             (rs.fields.Get_saValue('DATA_TYPE')='mediumblob') or
             (rs.fields.Get_saValue('DATA_TYPE')='longblob') then
          begin
            u8JDType:=cnJDType_bin;
          end;
          //-------------------------------------------------------------------------END Figuring out Jegas Data Type
          rJColumn.JColu_JDType_ID            := u8JDType;
          rJColumn.JColu_AllowNulls_b         := bVal(rs.Fields.Get_saValue('IS_NULLABLE'));
          rJColumn.JColu_DefaultValue         := rs.fields.Get_saValue('COLUMN_DEFAULT');
          rJColumn.JColu_PrimaryKey_b         := (rs.fields.Get_saValue('COLUMN_KEY')='PRI');
          rJColumn.JColu_AutoIncrement_b      := (saLeftStr(rs.fields.Get_saValue('extra'),14)='auto_increment');
          if ((rJColumn.JColu_Desc='NULL') or (rJColumn.JColu_Desc='')) and
             (rs.fields.Get_saValue('COLUMN_COMMENT')<>'NULL') and
             (rs.fields.Get_saValue('COLUMN_COMMENT')<>'') then
          begin
            rJColumn.JColu_Desc:=rs.fields.Get_saValue('COLUMN_COMMENT');
          end;
            //JAS_LOG(p_Context, cnLog_Ebug, 201202203203, 'rs.Fields.Get_saValue(''IS_NULLABLE''):'+rs.Fields.Get_saValue('IS_NULLABLE'),'',SOURCEFILE);

          bOk:=bJAS_Save_JColumn(p_Context, DBC, rJColumn, true, false, 201608300027);
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201203050303, 'Trouble Saving JColumn','',SOURCEFILE);
            DBM_RenderHtmlErrorPage(p_Context);
          end;
        end;
      end;
      rs2.close;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  rs2.destroy;
  rs.destroy;

  if bOk then
  begin
    bOk:=bJASNote(p_Context,6441,sa,'DBMS and JAS Meta-Data Synchronized.');
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_message','',false, 201203122225);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/apps/system-file-manager.png');
    p_Context.saPageTitle:='Success';
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102302,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









//=============================================================================
{}
procedure DBM_SyncScreenFields(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  saQry: ansistring;
  rJColumn: rtJColumn;
  u8JDType: word;
  rJBlokField: rtJBlokfield;
  rJBlok: rtJBlok;
  bDoneHere: Boolean;
  sa: ansistring;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_SyncScreenFields(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102303,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102304, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;

  if bOk then
  begin
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201006231550, 'Unable to comply - session is not valid.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context, cnPerm_API_SyncScreenFields);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201006311551,
        '"Database Maintenance" - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    saQry:='select JBlkF_JBlokField_UID, JBlkF_JBlok_ID from jblokfield where (JBlkF_JWidget_ID is null) or (JBlkF_JWidget_ID=0) and JBlkF_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' and '+
      'JBlkF_JColumn_ID>0 and JBlkF_JColumn_ID is not null';
    bOk:=rs.open(saQry, DBC,201503161241);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201203050405, 'Trouble with query.','Query: '+saQry, SOURCEFILE, DBC, rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and (not rs.eol) then
  begin
    repeat
      bDoneHere:=false;
      clear_JBlokField(rJBlokField); clear_JColumn(rJColumn);
      rJBlokField.JBlkF_JBlokField_UID:=u8Val(rs.fields.Get_saValue('JBlkF_JBlokField_UID'));
      bOk:=bJas_Load_JBlokField(p_Context, DBC,rJBlokField, true, 201608300028);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201203050406, 'Unable to load JBlokField.','JBlokField UID: '+inttostr(rJBlokField.JBlkF_JBlokField_UID), SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;

      if bOk then
      begin
        clear_JColumn(rJColumn);
        rJColumn.JColu_JColumn_UID:=rJBlokField.JBlkF_JColumn_ID;
        bOk:=bJAS_Load_JColumn(p_Context, DBC, rJColumn, false, 201608300029);
        if not bOk then
        begin
          if p_Context.bErrorCondition then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201203050408, 'Unable to load JColumn.','JBlokField UID: '+inttostr(rJBlokField.JBlkF_JBlokField_UID), SOURCEFILE);
          end
          else
          begin
            bOk:=true;
            bJas_Unlockrecord(p_Context, DBC.ID, 'jblokfield', rJBlokField.JBlkF_JBlokField_UID,0,201501020000);
            rJBlok.JBlok_JBlok_UID:=  u8Val(rs.fields.Get_saValue('JBlkF_JBlok_ID'));
            if bJAS_Load_JBlok(p_Context, DBC, rJBlok, false, 201608300030) then
            begin
              JAS_LOG(p_Context, cnLog_WARN, 201203010408,
                'Missing Column UID: '+inttostr(rJColumn.JColu_JColumn_UID)+' '+
                'JBlok UID: '+inttostr(rJBlok.JBlok_JBlok_UID)+' '+
                'JBlok (Missing Column in jblokfield): '+rJBlok.JBlok_Name +' '+
                'JBlokField UID: '+inttostr(rJBlokField.JBlkF_JBlokField_UID),'',SOURCEFILE);
            end
            else
            begin
              JAS_LOG(p_Context, cnLog_WARN, 201203150409,
                'Missing Column UID: '+inttostr(rJColumn.JColu_JColumn_UID)+' '+
                'JBlokField UID: '+inttostr(rJBlokField.JBlkF_JBlokField_UID),'',SOURCEFILE);
            end;
          end;
        end;
      end;

      JASPrintln('JBlokField UID: '+inttostr(rJBlokfield.JBlkF_JBlokField_UID)+' Column: '+rJColumn.JColu_Name);
      //+' DH:'+sYesNo(bDoneHere)+' OK:'+sYesNo(bOk));


      if bOk and (not bDoneHere) then
      begin
        rJBlokField.JBlkF_Widget_MaxLength_u   := rJColumn.JColu_DefinedSize_u;
        rJBlokField.JBlkF_Widget_Password_b    := false;
        if rJColumn.JColu_PrimaryKey_b then rJBlokField.JBlkF_Required_b:=true;
        u8JDType:=rJColumn.JColu_JDType_ID;
        if not bDoneHere then
        begin
          if (rJColumn.JColu_LU_JColumn_ID>0) then
          begin
            rJBlokField.JBlkF_JWidget_ID:=cnJWidget_Lookup;
            rJBlokField.JBlkF_Widget_MaxLength_u:=rJColumn.JColu_DefinedSize_u;
            rJBlokField.JBlkF_Widget_Height:=1;
            bDoneHere:=true;
          end;
        end;

        if not bDoneHere then
        begin
          if (u8JDType=cnJDType_i1) or (u8JDType=cnJDType_i2) or (u8JDType=cnJDType_i4) or (u8JDType=cnJDType_i8) or
             (u8JDType=cnJDType_u1) or (u8JDType=cnJDType_u2) or (u8JDType=cnJDType_u4) or (u8JDType=cnJDType_u8) or
             (u8JDType=cnJDType_fp) or (u8JDType=cnJDType_fd) or (u8JDType=cnJDType_cur) then
          begin
            if ((u8JDType=cnJDType_i1) or (u8JDType=cnJDType_u1))and (rJColumn.JColu_Boolean_b) then
            begin
              rJBlokField.JBlkF_JWidget_ID:=cnJDType_b;
            end
            else
            begin
              rJBlokField.JBlkF_JWidget_ID:=rJColumn.JColu_JDType_ID;
            end;
            rJBlokField.JBlkF_Widget_MaxLength_u:=20;
            rJBlokField.JBlkF_Widget_Height:=1;
            bDoneHere:=true;
          end;
        end;

        if not bDoneHere Then
        begin
          if (u8JDType=cnJDType_b)then
          begin
            rJBlokField.JBlkF_JWidget_ID:=rJColumn.JColu_JDType_ID;
            rJBlokField.JBlkF_Widget_MaxLength_u:=5;
            rJBlokField.JBlkF_Widget_Height:=1;
            bDoneHere:=true;
          end;
        end;

        if not bDoneHere Then
        begin
          if (u8JDType=cnJDType_dt) then
          begin
            rJBlokField.JBlkF_JWidget_ID:=rJColumn.JColu_JDType_ID;
            rJBlokField.JBlkF_Widget_MaxLength_u:=0;
            rJBlokField.JBlkF_Widget_Height:=1;
            rJBlokField.JBlkF_Widget_Date_b:=true;
            rJBlokField.JBlkF_Widget_Time_b:=true;
            bDoneHere:=true;
          end;
        end;

        if not bDoneHere then
        begin
          if (u8JDType=cnJDType_sn) or (u8JDType=cnJDType_sun) or (u8JDType=cnJDType_bin) then
          begin
            rJBlokField.JBlkF_Widget_MaxLength_u:=  rJColumn.JColu_DefinedSize_u;
            rJBlokField.JBlkF_Widget_Height:=0;//will use default text area size
            rJBlokField.JBlkF_Widget_Width:=0;
            bDOneHere:=true;
          end;
        end;

        if not bDoneHere then
        begin
          rJBlokField.JBlkF_JWidget_ID:=rJColumn.JColu_JDType_ID;
          rJBlokField.JBlkF_Widget_MaxLength_u:=rJColumn.JColu_DefinedSize_u;
          if rJColumn.JColu_DefinedSize_u>50 then
          begin
            rJBlokField.JBlkF_Widget_Width:=50;
          end
          else
          begin
            rJBlokField.JBlkF_Widget_Height:=1;
          end;
          rJBlokField.JBlkF_Widget_Height:=1;
        end;

        bOk:=bJAS_Save_JBlokfield(p_Context, DBC, rJBlokField, true,false, 201608300031);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201203050407, 'Unable to save JBlokField.','UID: '+inttostr(rJBlokField.JBlkF_JBlokField_UID), SOURCEFILE);
        end;
      end;

    until (not bOk) or (not rs.Movenext);
  end;
  rs.Close;

  rs2.destroy;
  rs.destroy;

  if bOk then
  begin
    bOk:=bJASNote(p_Context,6443,sa,'Screen fields syncronized with database.');
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_message','',false,201203122227);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/apps/system-file-manager.png');
    p_Context.saPageTitle:='Success';
  end
  else
  begin
    DBM_RenderHtmlErrorPage(p_Context);
  end;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102305,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








































//JASAPI_JNoteFlagOrphans
//=============================================================================
procedure DBM_JCaptionFlagOrphans(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  bOrphan: boolean;
  sa: ansistring;
  sJCaptionUID: string[19];//used for text output - keep as string
  bKeep: boolean;
  saSrcPath: ansistring;
  Dir: JFC_DIR;
  bDone: boolean;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_JCaptionFlagOrphans(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102744,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102745, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  Dir:=JFC_DIR.Create;


  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,201204140325,'Session is not valid. You need to be logged in and have permission to access this resource.','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  End;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context, cnPerm_API_JCaptionFlagOrphans);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204140326,
        '"Database Maintenance" - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    saSrcPath:='..'+DOSSLASH+'src'+DOSSLASH;
    if fileexists(saSrcPath+'jas.pas') then // have jas.pas? Probably ok to scan the source code.
    begin
      Dir.saFilespec:='*.pp';
      Dir.bDirOnly:=false;
      Dir.bSort:=true;
      Dir.bSortAscending:=true;
      Dir.bSortCaseSensitive:=true;
    end;
    Dir.LoadDir;
    saQry:='select JCapt_JCaption_UID,JCapt_Keep_b from jcaption '+
      'where ((JCapt_Deleted_b<>'+DBC.sDBMSBoolScrub(true) + ') or '+
      '(JCapt_Deleted_b is null))';
    bOk:=rs.open(saQry,DBC,201503161242);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201203081301, 'Trouble with Query','Query: ' + saQry, SOURCEFILE,DBC, rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    if rs.eol=false then
    begin
      repeat
        sJCaptionUID:=DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JCapt_JCaption_UID'));//NOTE ALREADY ESCAPED
        bKeep:=bVal(rs.fields.Get_saValue('JCapt_Keep_b'));
        //bOrphan:=true;
        bOrphan:=
          (NOT  bKeep) and
          (DBC.u8GetRecordCount('jblokbutton','JBlkB_JCaption_ID='+     sJCaptionUID,201506171723)=0) and
          (DBC.u8GetRecordCount('jblokfield','JBlkF_JCaption_ID='+      sJCaptionUID,201506171724)=0) and
          (DBC.u8GetRecordCount('jblok','JBlok_JCaption_ID='+           sJCaptionUID,201506171725)=0) and
          (DBC.u8GetRecordCount('jcolumn','JColu_JCaption_ID='+         sJCaptionUID,201506171726)=0) and
          (DBC.u8GetRecordCount('jjobtype','JJobT_JCaption_ID='+        sJCaptionUID,201506171727)=0) and
          (DBC.u8GetRecordCount('jprojectcategory','JPjCt_JCaption_ID='+sJCaptionUID,201506171729)=0) and
          (DBC.u8GetRecordCount('jprojectpriority','JPrjP_JCaption_ID='+sJCaptionUID,201506171730)=0) and
          (DBC.u8GetRecordCount('jprojectstatus','JPrjS_JCaption_ID='+  sJCaptionUID,201506171731)=0) and
          (DBC.u8GetRecordCount('jscreen','JScrn_JCaption_ID='+         sJCaptionUID,201506171732)=0) and
          (DBC.u8GetRecordCount('jtaskcategory','JTCat_JCaption_ID='+   sJCaptionUID,201506171733)=0) and
          (DBC.u8GetRecordCount('jpriority','JPrio_JCaption_ID='+   sJCaptionUID,201506171734)=0) and
          (DBC.u8GetRecordCount('jstatus','JStat_JCaption_ID='+     sJCaptionUID,201506171735)=0);
        if bOrphan and (Dir.Listcount>1) then
        begin
          if DIR.Movefirst then
          begin
            bDone:=false;
            repeat
              if bLoadTextFile(DIR.Item_saName,sa) and (pos(sJCaptionUID,sa)<>0) then
              begin
                writeln('201507190955 - FOUND CAPTION USED IN CODE!!! ================================');
                bOrphan:=false;
                bDone:=true;
              end;
            until (bDone) or (not DIR.movenext);
          end;
        end;
        saQry:='update jcaption set ';
        if not bKeep then
        begin
          saQry+='  JCapt_Orphan_b='+DBC.sDBMSBoolScrub(bOrphan)+' ';
        end
        else
        begin
          saQry+='  JCapt_Orphan_b=false ';
        end;
        saQry+='where '+
          'JCapt_JCaption_UID='+DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JCapt_JCaption_UID'))+' and '+
          '  (JCapt_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' or JCapt_Deleted_b is null)';

        //riteln('=====================BEGIN===========');
        //riteln ('DO THESE HAVE ZERO CAPTIONS');
        //riteln (' jblokbutton:'+   sYesNo(DBC.u8GetRecordCount('jblokbutton','JBlkB_JCaption_ID='+     saJCaptionUID),201506171723)=0));
        //riteln (' jblokfield:'+    sYesNo(DBC.u8GetRecordCount('jblokfield','JBlkF_JCaption_ID='+      saJCaptionUID),201506171724)=0));
        //riteln (' jblok:'+         sYesNo(DBC.u8GetRecordCount('jblok','JBlok_JCaption_ID='+           saJCaptionUID),201506171725)=0));
        //riteln (' jcolumn:'+       sYesNo(DBC.u8GetRecordCount('jcolumn','JColu_JCaption_ID='+         saJCaptionUID),201506171726)=0));
        //riteln (' jjobtype:'+      sYesNo(DBC.u8GetRecordCount('jjobtype','JJobT_JCaption_ID='+        saJCaptionUID),201506171727)=0));
        //riteln (' jprojectcateg:'+ sYesNo(DBC.u8GetRecordCount('jprojectcategory','JPjCt_JCaption_ID='+saJCaptionUID),201506171729)=0));
        //riteln (' jprojectprior:'+ sYesNo(DBC.u8GetRecordCount('jprojectpriority','JPrjP_JCaption_ID='+saJCaptionUID),201506171730)=0));
        //riteln (' jprojectstatu:'+ sYesNo(DBC.u8GetRecordCount('jprojectstatus','JPrjS_JCaption_ID='+  saJCaptionUID),201506171731)=0));
        //riteln (' jscreen:' +      sYesNo(DBC.u8GetRecordCount('jscreen','JScrn_JCaption_ID='+         saJCaptionUID),201506171732)=0));
        //riteln (' jtaskcategory:'+ sYesNo(DBC.u8GetRecordCount('jtaskcategory','JTCat_JCaption_ID='+   saJCaptionUID),201506171733)=0));
        //riteln (' jpriority:'    + sYesNo(DBC.u8GetRecordCount('jpriority',    'JPrio_JCaption_ID='+   saJCaptionUID),201506171734)=0));
        //riteln (' jstatus:'+   sYesNo(DBC.u8GetRecordCount('jstatus','JStat_JCaption_ID='+     saJCaptionUID),201506171735)=0));
        //riteln('=====================END=============');


        //if bOrphan then
        //begin
        //  ASPrintln('');
        //  ASPrintln('==================BEGIN=============');
        //  ASPrintln(saQry);
        //  ASPrintln('==================END=============');
        //  ASPrintln('');
        //  halt(0);
        //end;
        bOk:=rs2.open(saQry, DBC,201503161243);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201203081302, 'Trouble with Query','Query: ' + saQry, SOURCEFILE, DBC, rs2);
          DBM_RenderHtmlErrorPage(p_Context);
        end;
        rs2.close;
      until (not bOK) or (not rs.movenext);
    end;
  end;

  if bOk then
  begin
    bOk:=bJASNote(p_Context,0,sa,'Orphaned Captions have been flagged.');
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_message','',false, 201203122225);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICON; ?>/JAS/jegas/64/table_search.png');
    p_Context.saPageTitle:='Success';
  end;

  rs.destroy;
  rs2.destroy;
  Dir.Destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102746,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================













//JASAPI_JNoteFlagOrphans
//=============================================================================
procedure DBM_JNoteFlagOrphans(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  bOrphan: boolean;
  sa: ansistring;
  sJNoteUID: string[19];//keep as string
  bKeep: boolean;
  saSrcPath: ansistring;
  Dir: JFC_DIR;
  bDone: boolean;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_JNoteFlagOrphans(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201507191430,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201507191431, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  Dir:=JFC_DIR.Create;


  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,201507191432,'Session is not valid. You '+
      'need to be logged in and have permission to access this resource.','',
      SOURCEFILE
    );
    DBM_RenderHtmlErrorPage(p_Context);
  End;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context, cnPerm_API_JNoteFlagOrphans);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201507191433,
        '"Database Maintenance" - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    saSrcPath:='..'+DOSSLASH+'src'+DOSSLASH;
    // have jas.pas? Probably ok to scan the source code.
    if fileexists(saSrcPath+'jas.pas') then
    begin
      Dir.saFilespec:='*.pp';
      Dir.bDirOnly:=false;
      Dir.bSort:=true;
      Dir.bSortAscending:=true;
      Dir.bSortCaseSensitive:=true;
    end;
    Dir.LoadDir;
    saQry:='select JNote_JNote_UID,JNote_Keep_b from jnote '+
      'where ((JNote_Deleted_b<>'+DBC.sDBMSBoolScrub(true) + ') or '+
      '(JNote_Deleted_b is null))';
    bOk:=rs.open(saQry,DBC,201507191434);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201507191435, 'Trouble with Query','Query: ' + saQry, SOURCEFILE,DBC, rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    if rs.eol=false then
    begin
      repeat
        sJNoteUID:=DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JNote_JNote_UID'));//NOTE ALREADY ESCAPED
        bKeep:=bVal(rs.fields.Get_saValue('JNote_Keep_b'));
        //bOrphan:=true;
        bOrphan:=
          (NOT  bKeep) and
          (DBC.u8GetRecordCount('jtimecard','TMCD_JNote_Public_ID='+  sJNoteUID, 201507191436 )=0) and
          (DBC.u8GetRecordCount('jtimecard','TMCD_JNote_Internal_ID='+sJNoteUID, 201507191437 )=0) and
          (DBC.u8GetRecordCount('jmoduleconfig','JMCfg_JNote_ID='+    sJNoteUID, 201507191438 )=0) and
          (DBC.u8GetRecordCount('jmodulesetting','JMSet_JNote_ID='+   sJNoteUID, 201507191439 )=0) and
          (DBC.u8GetRecordCount('jinstalled','JInst_JNote_ID='+       sJNoteUID, 201507191440 )=0);
        if bOrphan and (Dir.Listcount>1) then
        begin
          if DIR.Movefirst then
          begin
            bDone:=false;
            repeat
              if bLoadTextFile(DIR.Item_saName,sa) and (pos(sJNoteUID,sa)<>0) then
              begin
                writeln('201507191448 - FOUND NOTE USED IN CODE!!! ================================');
                bOrphan:=false;
                bDone:=true;
              end;
            until (bDone) or (not DIR.movenext);
          end;
        end;
        saQry:='update jnote set ';
        if not bKeep then
        begin
          saQry+='  JNote_Orphan_b='+DBC.sDBMSBoolScrub(bOrphan)+' ';
        end
        else
        begin
          saQry+='  JNote_Orphan_b=false ';
        end;
        saQry+='where '+
          'JNote_JNote_UID='+DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JNote_JNote_UID'))+' and '+
          '  (JNote_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' or JNote_Deleted_b is null)';

        //riteln('=====================BEGIN===========');
        //riteln ('DO THESE HAVE ZERO CAPTIONS');
        //riteln (' jblokbutton:'+   sYesNo(DBC.u8GetRecordCount('jblokbutton','JBlkB_JCaption_ID='+     saJCaptionUID),201507191449)=0));
        //riteln (' jblokfield:'+    sYesNo(DBC.u8GetRecordCount('jblokfield','JBlkF_JCaption_ID='+      saJCaptionUID),201507191450)=0));
        //riteln (' jblok:'+         sYesNo(DBC.u8GetRecordCount('jblok','JBlok_JCaption_ID='+           saJCaptionUID),201507191451)=0));
        //riteln (' jcolumn:'+       sYesNo(DBC.u8GetRecordCount('jcolumn','JColu_JCaption_ID='+         saJCaptionUID),201507191452)=0));
        //riteln (' jjobtype:'+      sYesNo(DBC.u8GetRecordCount('jjobtype','JJobT_JCaption_ID='+        saJCaptionUID),201507191453)=0));
        //riteln (' jprojectcateg:'+ sYesNo(DBC.u8GetRecordCount('jprojectcategory','JPjCt_JCaption_ID='+saJCaptionUID),201507191454)=0));
        //riteln (' jprojectprior:'+ sYesNo(DBC.u8GetRecordCount('jprojectpriority','JPrjP_JCaption_ID='+saJCaptionUID),201507191455)=0));
        //riteln (' jprojectstatu:'+ sYesNo(DBC.u8GetRecordCount('jprojectstatus','JPrjS_JCaption_ID='+  saJCaptionUID),201507191456)=0));
        //riteln (' jscreen:' +      sYesNo(DBC.u8GetRecordCount('jscreen','JScrn_JCaption_ID='+         saJCaptionUID),201507191457)=0));
        //riteln (' jtaskcategory:'+ sYesNo(DBC.u8GetRecordCount('jtaskcategory','JTCat_JCaption_ID='+   saJCaptionUID),201507191458)=0));
        //riteln (' jpriority:'+ sYesNo(DBC.u8GetRecordCount('jpriority','JPrio_JCaption_ID='+   saJCaptionUID),201507191459)=0));
        //riteln (' jstatus:'+   sYesNo(DBC.u8GetRecordCount('jstatus','JStat_JCaption_ID='+     saJCaptionUID),201507191460)=0));
        //riteln('=====================END=============');


        //if bOrphan then
        //begin
        //  ASPrintln('');
        //  ASPrintln('==================BEGIN=============');
        //  ASPrintln(saQry);
        //  ASPrintln('==================END=============');
        //  ASPrintln('');
        //  halt(0);
        //end;
        bOk:=rs2.open(saQry, DBC,201507191461);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201507191462, 'Trouble with Query','Query: ' + saQry, SOURCEFILE, DBC, rs2);
          DBM_RenderHtmlErrorPage(p_Context);
        end;
        rs2.close;
      until (not bOK) or (not rs.movenext);
    end;
  end;

  if bOk then
  begin
    bOk:=bJASNote(p_Context,6569,sa,'Orphaned Notes have been flagged.');
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_message','',false, 201507191463);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICON; ?>/JAS/jegas/64/table_search.png');
    p_Context.saPageTitle:='Success';
  end;

  rs.destroy;
  rs2.destroy;
  Dir.Destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201507191464,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
procedure DBM_DiffTool(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  bOk2: boolean;
  DBC: JADO_CONNECTION;
  TGT: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  saQry: ansistring;
  DBCTblXDL: JFC_XDL;
  TGTTblXDL: JFC_XDL;
  DBCFldXDL: JFC_XDL;
  TGTFldXDL: JFC_XDL;
  saResult: ansistring;
  sName: string;
  u8Key: UInt64;
  bTblShown: boolean;

  //t: longint;tMax: longint;
  //f: longint;fMax: longint;
  saTGT: ansistring;
  bDone: boolean;
  XDL: JFC_XDL;
const cnColWidth=40;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
          
  function bLoadJASFields(p_u8TableID: UInt64): boolean;
  begin   
    DBCFldXDL.DeleteAll;
    saQry:='select JColu_Name, JColu_JDType_ID, JColu_PrimaryKey_b from jcolumn where JColu_JTable_ID=' +DBC.sDBMSUIntScrub(p_u8TableID)+
      ' AND ((JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JColu_Deleted_b IS NULL))';
    bOk2:=rs2.Open(saQry,DBC,201503161246);
    if not bOk2 then
    begin
      saResult:='1';
    end;

    if bOk2 and (not rs2.eol) then
    begin
      repeat
        DBCFldXDL.AppendItem_saName_saValue_saDesc(
          rs2.fields.Get_saValue('JColu_Name'),
          rs2.fields.Get_saValue('JColu_JDType_ID'),
          rs2.fields.Get_saValue('JColu_PrimaryKey_b')
        );
      until not rs2.movenext;
    end;
    rs2.close;
    result:=bOk2;
  end;

  function bLoadDBFields(p_saTableName: ansistring): boolean;
  begin
    TGTFldXDL.DeleteAll;
    saQry:='describe '+TGT.sDBMSEncloseObjectName(p_saTableName);
    bOk2:=rs2.open(saQry,TGT,201503161247);
    if not bOk2 then
    begin
      saResult:='2';
    end;

    if bOk2 and (not rs2.eol) then
    begin
      repeat
        TGTFldXDL.AppendItem_saName_saValue_saDesc(
          rs2.fields.Get_saValue('Field'),
          rs2.fields.Get_saValue('Type'),
          rs2.fields.Get_saValue('Key')
        );
      until not rs2.movenext;
    end;
    rs2.close;
    result:=bOk2;
  end;

Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_DiffTool(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201209290252,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201209290253, sTHIS_ROUTINE_NAME);{$ENDIF}
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  DBCTblXDL:= JFC_XDL.Create;
  TGTTblXDL:= JFC_XDL.create;
  DBCFldXDL:= JFC_XDL.create;
  TGTFldXDL:= JFC_XDL.create;
        XDL:= JFC_XDL.Create;
  saresult:='';bDone:=false;
  DBC:=p_Context.VHDBC;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201209290254, 'Unable to comply - session is not valid.','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_DiffTool);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201209290255,
        '"Database Maintenance" - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    saTGT:=p_Context.CGIENV.DataIn.Get_saValue('TargetDBConnection');
    if (saTGT='') or (NOT bVal(p_Context.CGIENV.DataIn.Get_saValue('process'))) then
    begin
      JASprintln('STARTED DIFF PAGE');
      // Send Page Asking for Selection of Database Connection
      saQry:='select JDCon_Name from jdconnection where ((JDCon_Deleted_b<>'+
        DBC.sDBMSBoolScrub(true)+')OR(JDCon_Deleted_b IS NULL)) AND (JDCon_Enabled_b='+
        DBC.sDBMSBoolScrub(true)+')';
      //ASPrintln('Got QRY ready');
      bOk:=rs.open(saQry,DBC,201503161248);
      //ASprintln('PAST rs.open');
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201210010243,'Trouble With Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
      //ASprintln('PAST QUERY bOk:'+sTrueFalse(bOk));

      if bOk and (not rs.eol) then
      begin
        repeat
          XDL.AppendItem_saName_N_saValue(rs.fields.Get_saValue('JDCon_Name'),rs.fields.Get_saValue('JDCon_Name'));
          XDL.Item_i8User:=1;
        until not rs.movenext;
        //ASprintln('PAST Record Loop bOk:'+sTrueFalse(bOk));

        WidgetList(
          p_Context,
          'TargetDBConnection',//p_saWidgetName AnsiString;
          'Database Connections', //p_saWidgetCaption: AnsiString;
          '', // p_saDefaultValue: AnsiString;
          1,  // p_saSize: Ansistring;
          false, // p_bMultiple: boolean;
          false, // p_bEditMode: Boolean;
          false, // p_bDataOnRight: Boolean;
          XDL, // p_XDL: JFC_XDL;// reference: name=caption, value=returned, desc = "" or "selected", iUser=1 then option selectable (0=grayed out)
          true, // p_bRequired: boolean;
          false, //p_bFilterTools: boolean;
          false, //p_bFilterNot: boolean;
          '',// p_saOnBlur: ansistring;
          '',// p_saOnChange: ansistring;
          '',// p_saOnClick: ansistring;
          '',// p_saOnDblClick: ansistring;
          '',// p_saOnFocus: ansistring;
          '',// p_saOnKeyDown: ansistring;
          '',// p_saOnKeypress: ansistring;
          ''// p_saOnKeyUp: ansistring
        );
        p_Context.PAGESNRXDL.AppendItem_SNRPair('[@SCREENCAPTION@]','JAS and Database Connection Difference Utility');
        p_Context.PAGESNRXDL.AppendItem_SNRPair('[@JSCRN_ICONLARGE@]','[@JASDIRICONTHEME@]64/apps/accessories-magnifier.png');
        //ASprintln('PAST WidgetList bOk:'+sTrueFalse(bOk));
        p_Context.saPage:=saGetPage(p_Context, 'sys_area_bare','sys_page_difftool','',false,201210010304);
        p_Context.saPageTitle:='Database Connections';
        //ASprintln('PAST GetPage bOk:'+sTrueFalse(bOk));
        bDone:=true;
      end;
      rs.close;
    end;
  end;

  if bOk and (not bDone) then
  begin
    p_Context.saPageTitle:='Success';
    p_Context.sMimeType:=csMIME_TextPlain;
    p_Context.CGIEnv.uHTTPResponse:=cnHTTP_RESPONSE_200;
    TGT:=p_Context.DBCON(saTGT,201610312255);
    bOK:=(DBC <> nil) and (TGT<>nil);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201209290257,'Dataconnection '+
        p_Context.CGIENV.DataIn.Get_saValue('TargetDBConnection')+' Invalid. Unable to proceed.','',SOURCEFILE);
    end;
  end;

  // BEGIN --------- LOAD TGT TABLES and FIELDS ---------------
  if bOk and (not bDone) then
  begin
    saQry:='show tables';
    bOk:=rs.open(saQry,TGT,201503161249);
    if not bOk then
    begin
      saResult:='3';
    end;
  end;

  if bOk and (not bDone) and (not rs.eol) then
  begin
    repeat
      TGTTblXDL.AppendItem_saName(rs.fields.Item_saValue);
      bOk:=bLoadDBFields(rs.fields.Item_saValue);
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  // END --------- LOAD TGT TABLES and FIELDS ---------------

  // BEGIN --------- LOAD JAS TABLES and FIELDS ---------------
  if bOk and (not bDone) then
  begin
    saQry:='select JTabl_JTable_UID, JTabl_Name from jtable '+
      'where ((JTabl_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JTabl_Deleted_b IS NULL))';
    bOk:=rs.open(saQry,DBC,201503161250);
    if not bOk then
    begin
      saResult:='4';
    end;
  end;

  if bok and (not bDone) and (NOT rs.EOL) then
  begin
    repeat
      DBCTblXDL.AppendItem_saName_N_saValue(rs.fields.Get_saValue('JTabl_Name'), rs.fields.Get_saValue('JTabl_JTable_UID'));
      bOk:=bLoadJASFields(u8Val(rs.fields.Get_saValue('JTabl_JTable_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  // END --------- LOAD JAS TABLES and FIELDS ---------------



  // BEGIN --------- Check for Items in JAS not found in TGT  ---------------
  if bOk and (not bDone) then
  begin
    saResult+=saRepeatChar('=',cnColWidth*2)+csCRLF;
    saResult+=saJegasLogoRawText(csCRLF,true);
    saResult+=saRepeatChar('=',cnColWidth*2)+csCRLF+csCRLF;

    saResult+=saRepeatChar('=',cnColWidth*2)+csCRLF;
    saResult+='Items in JAS not found in the '+TGT.sName+' database'+csCRLF;
    saResult+=saRepeatChar('=',cnColWidth*2)+csCRLF;

    if DBCTblXDL.Movefirst then
    begin
      repeat
        sName:=DBCTblXDL.Item_saName;
        if NOT TGTTblXDL.FoundItem_saName(sName) then
        begin
          saResult+=sName+csCRLF
        end
        else
        begin
          u8Key:=u8Val(DBCTblXDL.Item_saValue);
          bOk:=bLoadJASFields(u8Key);
          if not bOk then
          begin
            saResult:='5';
          end;

          if bOk then
          begin
            bOk:=bLoadDBFields(sName);
            if not bOk then
            begin
              saResult:='6';
            end;
          end;

          if bOk then
          begin
            bTblShown:=false;
            if DBCFldXDL.MoveFirst then
            begin
              repeat
                if NOT TGTFldXDL.FoundItem_saName(DBCFldXDL.Item_saName) then
                begin
                  if not bTblShown then
                  begin
                    bTblShown:=true;
                    saResult+=sName+csCRLF;
                  end;
                  saResult+=saRepeatChar(' ',8)+DBCFldXDL.Item_saName+csCRLF
                end
              until not DBCFldXDL.MoveNext;
              if bTblShown then saResult+=csCRLF;
            end;
          end;
        end;
      until not DBCTblXDL.MoveNext;
    end;
  end;
  // END --------- Check for Items in JAS not found in TGT  ---------------

  // BEGIN --------- Check for Items in TGT not found in JAS  ---------------
  if bOk and (not bDone) then
  begin
    saResult+=csCRLF+saRepeatChar('=',cnColWidth*2)+csCRLF;
    saResult+='Items in the '+TGT.sName+' database not found in JAS'+csCRLF;
    saResult+=saRepeatChar('=',cnColWidth*2)+csCRLF;
    if TGTTblXDL.Movefirst then
    begin
      repeat
        sName:=TGTTblXDL.Item_saName;
        if NOT DBCTblXDL.FoundItem_saName(sName) then
        begin
          saResult+=sName+csCRLF
        end
        else
        begin
          u8Key:=u8Val(DBCTblXDL.Item_saValue);
          bOk:=bLoadJASFields(u8Key);
          if not bOk then
          begin
            saResult:='7';
          end;

          if bOk then
          begin
            bOk:=bLoadDBFields(sName);
            if not bOk then
            begin
              saResult:='8'
            end;
          end;

          if bOk then
          begin
            bTblShown:=false;
            if TGTFldXDL.MoveFirst then
            begin
              repeat
                if NOT DBCFldXDL.FoundItem_saName(TGTFldXDL.Item_saName) then
                begin
                  if not bTblShown then
                  begin
                    bTblShown:=true;
                    saResult+=sName+csCRLF;
                  end;
                  saResult+=saRepeatChar(' ',8)+TGTFldXDL.Item_saName+csCRLF
                end
              until not TGTFldXDL.MoveNext;
              if bTblShown then saResult+=csCRLF;
            end;
          end;
        end;
      until not TGTTblXDL.MoveNext;
    end;

    saResult+=saRepeatChar('=',cnColWidth*2)+csCRLF;
  end;
  // END --------- Check for Items in TGT not found in JAS  ---------------


  if bOk and (not bDone) then
  begin
    p_Context.saPage:=saResult;
  end
  else
  begin
    if not bDone then
    begin
      p_Context.saPage:='Error: '+saResult;
    end;
  end;
  XDL.Destroy;
  DBCTblXDL.destroy;
  TGTTblXDL.destroy;
  DBCFldXDL.Destroy;
  TGTFldXDL.Destroy;
  rs2.destroy;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201209290256,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================














//=============================================================================
{}
// Delete all records in tables with _Deleted_b flag set to true.
procedure DBM_WipeAllRecordLocks(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
  sa: ansistring;
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_WipeAllRecordLocks';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204281340,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204281341, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;

  if bOk then
  begin
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204281342, 'Unable to comply - session is not valid.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_WipeAllRecordLocks);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204281343,
        '"Database Maintenance" - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;


  if bOk then
  begin
    saQry:='delete from jlock';
    bOk:=rs.open(saQry, DBC,201503161251);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204281344, 'Trouble removing record locks from the jlock table.','Query:'+saQry,SOURCEFILE,DBC,rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
    rs.close;
  end;

  if bOk then
  begin
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_message','',false, 201204281350);
    p_Context.saPageTitle:='Success';
    sa:='All record locks successfully removed from the system.';
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/places/user-trash.png');
  end;

  rs.destroy;
  p_Context.bNoWebCache:=true;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204281351,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
















//=============================================================================
{}
// Updates jorgmember by interrogating the jperson table and the jorg
// table to find members that may not of been added.
procedure DBM_UpdateOrgMembers(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  //rs2: JADO_RECORDSET;
  saQry: ansistring;
  sa: ansistring;
  rJOrgPers: rtJOrgPers;


{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_UpdateOrgMembers';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204281433,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204281434, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  //rs2:=JADO_RECORDSET.Create;

  if bOk then
  begin
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204281435, 'Unable to comply - session is not valid.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_UpdateOrgMembers);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204281436,
        '"Database Maintenance" - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    saQry:='delete from jorgpers';//yup - blast this thing - gonna rebuild
    bOk:=rs.open(saQry,DBC,201611062110);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201611062111, 'Trouble with query.','Query:'+saQry,SOURCEFILE,DBC,rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    saQry:=
      'select '+
        'JPers_JPerson_UID, '+
        'JPers_Primary_Org_ID '+
      'FROM '+
        'jperson '+
      'WHERE ' +
        '((JPers_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JPers_Deleted_b IS NULL)) AND '+
        '(JPers_Primary_Org_ID IS NOT NULL)';
    bOk:=rs.open(saQry, DBC,201503161252);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204281437, 'Trouble with query.','Query:'+saQry,SOURCEFILE,DBC,rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and (not rs.eol) then
  begin
    repeat
      if DBC.u8GetRecordCount('jorg',saQry,201506171737)>0 then
      begin
        saQry:='((JCpyP_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JCpyP_Deleted_b IS NULL)) AND '+
          '(JCpyP_JPerson_ID='+DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JPers_JPerson_UID')) + ') AND '+
          '(JCpyP_JOrg_ID='+DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JPers_Primary_Org_ID'))+')';
        if DBC.u8GetRecordCount('jorgpers',saQry,201506171738)=0 then
        begin
          clear_JOrgPers(rJOrgPers);
          with rJOrgPers do begin
            //JCpyP_JOrgPers_UID    : ansistring;
            JCpyP_JOrg_ID         :=u8Val(rs.fields.Get_saValue('JPers_JPerson_UID'));
            JCpyP_JPerson_ID          :=u8Val(rs.fields.Get_saValue('JPers_Primary_Org_ID'));
            //JCpyP_JOrgDept_ID     : ansistring;
            //JCpyP_Title               : ansistring;
            //JCpyP_ReportsTo_Person_ID : ansistring;
            //JCpyP_CreatedBy_JUser_ID  : ansistring;
            //JCpyP_Created_DT          : ansistring;
            //JCpyP_ModifiedBy_JUser_ID : ansistring;
            //JCpyP_Modified_DT         : ansistring;
            //JCpyP_DeletedBy_JUser_ID  : ansistring;
            //JCpyP_Deleted_DT          : ansistring;
            //JCpyP_Deleted_b           : ansistring;
            //JAS_Row_b                 : ansistring;
          end;//with
          if not bJAS_Save_JOrgPers(p_Context,DBC,rJOrgPers,false,false, 201608300032) then
          begin
            JAS_LOG(p_COntext, cnLog_info, 201204281446, 'Unable to save to Organization Members Table.',
               'bJAS_Save_JOrgPers Failed. rJOrgPers.JCpyP_JOrgPers_UID: '+inttostr(rJOrgPers.JCpyP_JOrgPers_UID),SOURCEFILE);
            DBM_RenderHtmlErrorPage(p_Context);
          end;
        end;
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;



  if bOk then
  begin
    saQry:=
      'select '+
        'JOrg_JOrg_UID, '+
        'JOrg_Primary_Person_ID '+
      'FROM '+
        'jorg '+
      'WHERE ' +
        '((JOrg_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JOrg_Deleted_b IS NULL)) AND '+
        '(JOrg_Primary_Person_ID IS NOT NULL)';
    bOk:=rs.open(saQry, DBC,201503161253);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204281452, 'Trouble with query.','Query:'+saQry,SOURCEFILE,DBC,rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and (not rs.eol) then
  begin
    repeat
      saQry:='((JPers_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JPers_Deleted_b IS NULL)) AND '+
             '(JPers_JPerson_UID='+DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JOrg_Primary_Person_ID'))+')';
      if DBC.u8GetRecordCount('jperson',saQry,201506171739)>0 then
      begin
        saQry:='((JCpyP_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JCpyP_Deleted_b IS NULL)) AND '+
               '(JCpyP_JPerson_ID='+DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JOrg_Primary_Person_ID')) + ') AND '+
               '(JCpyP_JOrg_ID='+DBC.sDBMSUIntScrub(rs.fields.Get_saValue('JOrg_JOrg_UID'))+')';
        if DBC.u8GetRecordCount('jorgpers',saQry,201506171740)=0 then
        begin
          clear_JOrgPers(rJOrgPers);
          with rJOrgPers do begin
            //JCpyP_JOrgPers_UID    : ansistring;
            JCpyP_JOrg_ID             :=u8Val(rs.fields.Get_saValue('JOrg_JOrg_UID'));
            JCpyP_JPerson_ID          :=u8Val(rs.fields.Get_saValue('JOrg_Primary_Org_ID'));
            //JCpyP_JOrgDept_ID     : ansistring;
            //JCpyP_Title               : ansistring;
            //JCpyP_ReportsTo_Person_ID : ansistring;
            //JCpyP_CreatedBy_JUser_ID  : ansistring;
            //JCpyP_Created_DT          : ansistring;
            //JCpyP_ModifiedBy_JUser_ID : ansistring;
            //JCpyP_Modified_DT         : ansistring;
            //JCpyP_DeletedBy_JUser_ID  : ansistring;
            //JCpyP_Deleted_DT          : ansistring;
            //JCpyP_Deleted_b           : ansistring;
            //JAS_Row_b                 : ansistring;
          end;//with
          bJAS_Save_JOrgPers(p_Context,DBC, rJOrgPers,false,false, 201608300033);//probably a dupe - not a problem - its there already!
          //if not boK then
          //begin
          //  JAS_LOG(p_COntext, cnLog_Error, 201204281453, 'Unable to save to Organization Members Table.','bJAS_Save_JOrgPers Failed.',SOURCEFILE);
          //  DBM_RenderHtmlErrorPage(p_Context);
          //end;
        end;
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  if bOk then
  begin
    saQry:='SELECT JCpyP_JOrgPers_UID, JOrg_JOrg_UID from jorgpers left join jorg on JCpyP_JOrg_ID=JOrg_JOrg_UID '+
      ' WHERE ((JCpyP_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JCpyP_Deleted_b IS NULL))';
    bOk:=rs.open(saQry, DBC,201503161254);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204281539, 'Trouble with query.','Query:'+saQry,SOURCEFILE,DBC,rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and (not rs.eol) then
  begin
    repeat
      if rs.fields.get_saValue('JOrg_JOrg_UID')='NULL' then
      begin
        p_Context.JTrakBegin(DBC, 'jorgpers', u8Val(rs.fields.Get_saValue('JCpyP_JOrgPers_UID')));
        bOk:=bJAS_DeleteRecord(p_Context,DBC,'jorgpers',u8Val(rs.fields.Get_saValue('JCpyP_JOrgPers_UID')));
        p_Context.JTrakEnd(
          u8Val(rs.fields.Get_saValue('JCpyP_JOrgPers_UID')),
          'DELETE FROM jorgpers WHERE JCpyP_JOrgPers_UID='+rs.fields.Get_saValue('JCpyP_JOrgPers_UID')
        );
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Warn,201204281543,'Trouble deleting jorgpers record UID: '+rs.fields.Get_saValue('JCpyP_JOrgPers_UID'),'',SOURCEFILE);
          //DBM_RenderHtmlErrorPage(p_Context);
          bOk:=true;
        end;
      end;
    until (not bOk) or (not rs.moveNext);
  end;
  rs.close;


  if bOk then
  begin
    saQry:='SELECT JCpyP_JOrgPers_UID, JPers_JPerson_UID from jorgpers left join jperson on JCpyP_JPerson_ID=JPers_JPerson_UID '+
      ' WHERE ((JCpyP_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JCpyP_Deleted_b IS NULL))';
    bOk:=rs.open(saQry, DBC,201503161255);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204281554, 'Trouble with query.','Query:'+saQry,SOURCEFILE,DBC,rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and (not rs.eol) then
  begin
    repeat
      if rs.fields.get_saValue('JPers_JPerson_UID')='NULL' then
      begin
        p_Context.JTrakBegin(DBC, 'jorgpers', u8Val(rs.fields.Get_saValue('JCpyP_JOrgPers_UID')));
        bOk:=bJAS_DeleteRecord(p_Context,DBC,'jorgpers',u8Val(rs.fields.Get_saValue('JCpyP_JOrgPers_UID')));
        p_Context.JTrakEnd(
          u8Val(rs.fields.Get_saValue('JCpyP_JOrgPers_UID')),
          'DELETE FROM jorgpers WHERE JCpyP_JOrgPers_UID='+rs.fields.Get_saValue('JCpyP_JOrgPers_UID')
        );
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Info,201204281555,'Trouble deleting jorgpers record during update org members UID: '+rs.fields.Get_saValue('JCpyP_JOrgPers_UID'),'',SOURCEFILE);
          //DBM_RenderHtmlErrorPage(p_Context);
          bOk:=true;//its ok :)
        end;
      end;
    until (not bOk) or (not rs.moveNext);
  end;
  rs.close;
  rs.destroy;
  //rs2.destroy;

  if bOk then
  begin
    p_Context.u8ErrNo:=0;p_Context.saErrMsg:='Success';p_Context.bErrorCondition:=false;
    bOk:=bJASNote(p_Context,2012042814350754106,sa,'The organization members table has been updated.');
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_message','',false, 201204281438);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/places/document-folder.png');
    p_Context.saPageTitle:='Success';
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204281439,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

















//=============================================================================
{}
// Diagnostic looking for Duplicate UID's. Shouldn't be any, but if there
// are, the table should be altered to have the UID column set as the primary
// key after the data is scrubbed accordingly.
procedure DBM_FindDupeUID(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  saQry: ansistring;
  //sa: ansistring;
  XDL: JFC_XDL;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_FindDupeUID';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201209261140,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201209261141, sTHIS_ROUTINE_NAME);{$ENDIF}
  bOk:=true;
  DBC:=p_COntext.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  XDL:=JFC_XDL.Create;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201209261201,'Invalid Session. You''re not logged in.','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_FindDupeUID);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201209261202,'You need to have Database Maintenance permission to use this feature.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    saQry:=
      'SELECT JTabl_Name, JColu_Name FROM jtable join jcolumn on JTabl_JTable_UID=JColu_JTable_ID '+
      'WHERE ( 	JTabl_JTableType_ID=1 ) AND '+
      '((JTabl_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+') OR (JTabl_Deleted_b IS NULL)) and ';

      saQry+='((JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+') OR (JColu_Deleted_b IS NULL)) and (JColu_Name LIKE ''%_UID'')';
    bOk:=rs.open(saQry, DBC,201503161257);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201209261203,'Trouble with Query.','Query: '+saQry,SOURCEFILE,DBC,rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and  ( not rs.EOL) then
  begin
    repeat
      saQry:='SELECT COUNT('+DBC.sDBMSEncloseObjectName(rs.fields.Get_saValue('JColu_Name'))+') as MyCount,  '+
        DBC.sDBMSEncloseObjectName(rs.fields.Get_saValue('JColu_Name'))+' FROM '+
        DBC.sDBMSEncloseObjectName(rs.fields.Get_saValue('JTabl_Name'))+
        ' group by '+DBC.sDBMSEncloseObjectName(rs.fields.Get_saValue('JColu_Name'))+
        ' HAVING (COUNT('+DBC.sDBMSEncloseObjectName(rs.fields.Get_saValue('JColu_Name'))+')>1)';

      bOk:=rs2.open(saQry,DBC,201503161258);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201209261204,'Trouble with Inner Query.','Query: '+saQry,SOURCEFILE,DBC,rs2);
        DBM_RenderHtmlErrorPage(p_Context);
      end;

      if bOk and (NOT rs2.eol) then
      begin
        repeat
          XDL.AppendItem_saName_N_saValue(rs.fields.Get_saValue('JTabl_Name'),rs2.fields.Get_saValue('MyCount'));
          XDL.Item_saDesc:=rs.fields.Get_saValue('JColu_Name')+': '+rs2.fields.Get_saValue(rs.fields.Get_saValue('JColu_Name'));
        until not rs2.movenext;
      end;
      rs2.close;
    until NOT rs.movenext;
  end;
  rs.close;

  if bOk then
  begin
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_message','',false, 201209261212);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',XDL.saHTMLTable);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/places/document-folder.png');
    p_Context.saPageTitle:='Duplicate UID Report';
  end;

  rs.destroy;
  rs2.destroy;
  XDL.Destroy;
  //p_Context.CGIENV.iHTTPResponse:=cnHTTP_RESPONSE_200;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201209261142,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





















//=============================================================================
procedure CSVImport(p_Context: TCONTEXT);
//=============================================================================
var
  bOk:boolean;
  saQry: Ansistring;
  DBC: JADO_CONNECTION;
  RS: JADO_RECORDSET;
  LXDL: JFC_XDL;

  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='CSVImport(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102306,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102307, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  RS:=JADO_RECORDSET.Create;
  LXDL:=JFC_XDL.Create;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201202252057,
      'Session not valid, upload not permitted.','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_csvimport);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204021309,
        'JAS Syncronization - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    saQry:=
      'select '+csCRLF+
      '  JTabl_JTable_UID, '+csCRLF+
      '  JTabl_Name '+csCRLF+
      //'  JDCon_Name, '+csCRLF+
      'from jtable '+csCRLF+
      //'  inner join jdconnection on JDCon_JDConnection_UID=JTabl_JDConnection_ID '+csCRLF+
      'where '+csCRLF+
      '  JTabl_JTableType_ID=1 and '+csCRLF+
      '  JTabl_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' '+
      'Order By JTabl_Name';
    bOk:=rs.open(saQry, DBC,201503161259);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 2012260631, 'Unable to query table list for CSV Import','Query: '+saQry,SOURCEFILE,DBC,rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;

    if bOk then
    begin
      repeat
        LXDL.AppendItem_saName_N_saValue(
          rs.fields.Get_saValue('JTabl_Name')//+' | '+
          //rs.fields.Get_saValue('JDCon_Name')+' | '+
          ,rs.fields.Get_saValue('JTabl_JTable_UID')
        );
        LXDL.Item_i8User:=1;//Selectable
      until not rs.movenext;
      WidgetList(
        p_Context,
        'JTabl_JTable_UID',
        'Please Select Table you wish to import to',
        '0',
        20,
        false,
        true,
        garJVHost[p_Context.u2VHost].VHost_DataOnRight_b,
        LXDL,
        true,
        false,
        false,
        '',//p_saOnBlur: ansistring;
        '',//p_saOnChange: ansistring;
        '',//p_saOnClick: ansistring;
        '',//p_saOnDblClick: ansistring;
        '',//p_saOnFocus: ansistring;
        '',//p_saOnKeyDown: ansistring;
        '',//p_saOnKeypress: ansistring;
        '' //p_saOnKeyUp: ansistring
      );
    end;
    rs.close;

    if bOk then
    begin
      p_Context.saPage:=saGetPage(p_Context, 'sys_area', 'sys_page_csvimport','CSVIMPORT',false,'',201202260647);
      p_Context.saPageTitle:='Step #1 - Select Table and File';
      //p_Context.CGIENV.iHTTPResponse:=cnHttp_Response_200;
      p_Context.bNoWebCache:=true;
    end;
  end;
  //p_Context.bOutputRaw:=true;
  //p_Context.CGIENV.Header_Html;

  RS.Destroy;RS:=nil;
  LXDL.Destroy;LXDL:=nil;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102308,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






































//=============================================================================
procedure CSVMapFields(p_Context: TCONTEXT);
//=============================================================================
var
  bOk:boolean;
  f: text;
  u2IOResult: word;
  saFilename: ansistring;
  saOrigFilename: ansistring;
  saHeaders: ansistring;
  TK: JFC_TOKENIZER;
  saQry: Ansistring;
  DBC: JADO_CONNECTION;
  RS: JADO_RECORDSET;
  LXDL: JFC_XDL;
  FXDL: JFC_XDL;
  u8TableCol: UInt64;
  saHTMLTable: ansistring;
  i: longint;
  saScript: ansistring;
  JTabl_JTable_UID: UInt64;
  JTabl_ColumnPrefix: ansistring;

  path: string;
  dir: string;
  name: string;
  ext: string;
  uFileSize: uint;

  rJTask: rtJTask;

  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='CSVMapFields(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102312,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102313, sTHIS_ROUTINE_NAME);{$ENDIF}

  //JAS_Log(p_Context,cnLog_ebug,201203312246,'CSVMapFields - BEGIN ','',SOURCEFILE);

  //---------------------------------------------------------------Init
  p_Context.bSaveSessionData:=true;
  DBC:=p_Context.VHDBC;
  RS:=JADO_RECORDSET.Create;
  LXDL:=JFC_XDL.Create;// For The List Web Widgets
  FXDL:=JFC_XDL.Create;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201202252057,
      'Session not valid, upload not permitted.','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_CSVMapFields);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204021308,
        'JAS Syncronization - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;
  //---------------------------------------------------------------Init




  //---------------------------------------------Verify a Target Table was Selected
  if bOk then
  begin
    bOk:=p_Context.CGIEnv.DataIn.FoundItem_saName('JTabl_JTable_UID');
    if bOk then
    begin
      JTabl_JTable_UID:=u8Val(p_Context.CGIEnv.DataIn.Item_saValue);
    end
    else
    begin
      JAS_Log(p_Context, cnLog_Error,201202261438, 'JTable not specified','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;
  //---------------------------------------------Verify a Target Table was Selected


  //------------------------------------------ Verify File Uploaded
  if bOk then
  begin
    bOk:=p_Context.CGIENV.FilesIn.ListCount=1;
    if not bOk then
    begin
      if p_Context.CGIENV.FilesIn.ListCount=0 then
      begin
        JAS_LOG(p_Context, cnLog_Error,201203312217, 'No file received for import.','',SOURCEFILE);
      end
      else
      begin
        JAS_LOG(p_Context, cnLog_Error,201202252107, 'Received '+inttostr(p_Context.CGIENV.FilesIn.ListCount)+' files. Only one file at a time can be imported.','',SOURCEFILE);
      end;
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=p_Context.CGIENV.DataIn.FoundItem_saName(p_Context.CGIENV.FilesIn.Item_saName);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202252118, 'Unable to locate file in DataIN XDL.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;


  if bOk then
  begin
    bOk:=p_Context.CGIENV.DataIn.FoundItem_saName('importcsv');
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202252116, 'Unable to locate filename in DataInXDL','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;
  //------------------------------------------ Verify File Uploaded



  //------------------------------------------------ Save Imported File
  if bOk then
  begin
    path:=p_Context.CGIENV.DataIn.Item_saValue;
    FSplit(path,dir,name,ext);
    saOrigFilename:=name+ext;
    saFilename:=saAddSlash(garJVHost[p_Context.u2VHost].VHost_FileDir)+name+'.'+inttostr(u8JAS_GetSessionKey)+ext;
    try
      bOk:=false;
      if FileExists(saFilename) then DeleteFile(safilename);
      u2IOResult:=IORESULT;
      bOk:=true;
    finally
    end;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201203141511, 'Unable to delete file. Result: '+sIOResult(u2IOResult),
        'File: '+saFilename+' '+sIOResult(u2IOResult),SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=bTSOpenTextFile(saFilename,u2IOResult,f,false,false);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202252116, 'Unable to open file for writing: '+saFilename+' '+sIOResult(u2IOResult),'',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    write(f,p_Context.CGIENV.FilesIn.Item_saValue);
    uFileSize:=length(p_Context.CGIENV.FilesIn.Item_saValue);
    bOk:=bTSCloseTextFile(saFilename,u2IOResult,F);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202252117, 'Trouble closing open file: '+saFilename+' '+sIOResult(u2IOResult),'',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;
  //------------------------------------------------ Save Imported File


  //------------------------------------------------ Set Up Date/time Pull down
  LXDL.AppendItem_saName_N_saValue('<None>','None');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('HH:NN','17');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('HH:NN AM','16');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('HH:NN:SS','8');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('HH:NN:SS EDT','9');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('M/D/YYYY HH:NN','19');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('MM/DD/YY','12');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('MM/DD/YYYY','2');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('MM/DD/YYYY HH:NN','20');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('MM/DD/YYYY HH:NN AM','1');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('MMM DDD DD YYYY','10');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('YYYY-MM-DD','3');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('YYYY-MM-DD HH:NN:SS','11');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('DD/MM/YYYY HH:NN AM','24');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('DD/MMM/YYYY','13');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('DD/MMM/YYYY HH:MM','15');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('DD/MMM/YYYY HH:MM AM','14');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('DD/MMM/YYYY:HH:NN:SS','18');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('DDD, DD MMM YYYY HH:NN:SS','5');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('DDD, DD MMM YYYY HH:NN:SS UTC','6');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('DDDD, DD MMM, YYYY HH:NN:SS AM','7');LXDL.Item_i8User:=1;
  LXDL.AppendItem_saName_N_saValue('DDD MMM DD HH:NN:SS EDT YYYY','4');LXDL.Item_i8User:=1;
  WidgetList(
    p_Context,
    'CSV_DateFormat',
    'Select format for date/time fields.',
    '0',
    1,
    false,
    true,
    garJVHost[p_Context.u2VHost].VHost_DataOnRight_b,
    LXDL,
    false,
    false,
    false,
    '',//p_saOnBlur: ansistring;
    '',//p_saOnChange: ansistring;
    '',//p_saOnClick: ansistring;
    '',//p_saOnDblClick: ansistring;
    '',//p_saOnFocus: ansistring;
    '',//p_saOnKeyDown: ansistring;
    '',//p_saOnKeypress: ansistring;
    '' //p_saOnKeyUp: ansistring
  );
  //------------------------------------------------ Set Up Date/time Pull down






  //----------------------------------------------Get Headers from File
  // READ THE FIRST LINE OF THE FILE FOR HEADERS
  if bOk then
  begin
    bOk:=bTSOpenTextFile(saFilename,u2IOResult,f,true,false);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202252119, 'Unable to open file for reading: '+saFilename+' '+sIOResult(u2IOResult),'',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    LXDL.DeleteAll;
    readln(f,saheaders);
    TK:=JFC_TOKENIZER.create;
    TK.sWhitespace:='", ';
    TK.sSeparators:=',';
    TK.sQuotes:='"';
    TK.Tokenize(saHeaders);
    //TK.DumpToTextFile(garJVHostLight[p_Context.i4VHost].saFileDir+'importheader.txt');
    LXDL.AppendItem_saName_N_saValue('<None>','0');LXDL.Item_i8User:=1;//Selectable
    if TK.MoveFirst then
    begin
      repeat
        LXDL.AppendItem_saName_N_saValue(TK.Item_saToken,inttostr(LXDL.N));
        LXDL.Item_i8User:=1;//Selectable
      until not TK.MoveNext;
      LXDL.SortItem_saName(true,true);
    end;
    TK.Destroy;TK:=nil;
    p_Context.saPage+='Done tokenizing<br />';
  end;

  if bOk then
  begin
    bOk:=bTSCloseTextFile(saFilename,u2IOResult,F);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202252120,
        'Trouble closing open file: '+saFilename+' '+sIOResult(u2IOResult),'',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;


  if bOk then
  begin
    bOK:=LXDL.ListCount>1;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202252121,
        'There doesn''t seem to be any columns in this CSV file.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;
  //----------------------------------------------Get Headers from File




  //-----------------------------------------------Produce Interface for Mapping Fields
  if bOk then
  begin
    saQry:='select JTabl_ColumnPrefix from jtable where JTabl_JTable_UID='+inttostr(JTabl_JTable_UID);
    bOk:=rs.open(saQry, DBC,201503161260);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202261228,
        'Trouble querying jtable table.','Query: '+saQry,SOURCEFILE, DBC,RS);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.eol=false;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202261229,
        'Trouble querying jcolumn table.','Query: '+saQry,SOURCEFILE, DBC,RS);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    JTabl_ColumnPrefix:=rs.fields.Get_saValue('JTabl_ColumnPrefix');
  end;
  rs.close;



  if bOk then
  begin
    saQry:=
      'select '+
      '  JColu_JColumn_UID, '+
      '  JColu_Name, '+
      '  JColu_JCaption_ID '+
      'from '+
      '  jcolumn '+
      'where '+
      '  (JColu_JTable_ID='+DBC.sDBMSUIntScrub(p_Context.CGIENV.DataIn.Get_saValue('JTabl_JTable_UID'))+') and ('+
      '  (JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+ ') or ( JColu_Deleted_b IS NULL )) and ('+
      '  (JColu_PrimaryKey_b<>'+DBC.sDBMSBoolScrub(true)+') and '+
      //'  JColu_Name<>'+DBC.saDBMSSCrub(JTabl_ColumnPrefix+'_CreatedBy_JUser_ID')+' and '+
      //'  JColu_Name<>'+DBC.saDBMSSCrub(JTabl_ColumnPrefix+'_Created_DT')+' and '+
      //'  JColu_Name<>'+DBC.saDBMSSCrub(JTabl_ColumnPrefix+'_ModifiedBy_JUser_ID')+' and '+
      //'  JColu_Name<>'+DBC.saDBMSSCrub(JTabl_ColumnPrefix+'_Modified_DT')+' and '+
      '  (JColu_Name<>'+DBC.saDBMSSCrub(JTabl_ColumnPrefix+'_DeletedBy_JUser_ID')+') and '+
      '  (JColu_Name<>'+DBC.saDBMSSCrub(JTabl_ColumnPrefix+'_Deleted_DT')+') and '+
      '  (JColu_Name<>'+DBC.saDBMSSCrub(JTabl_ColumnPrefix+'_Deleted_b')+') and '+
      '  (JColu_Name<>'+DBC.saDBMSSCrub('JAS_Row_b')+')) '+
      'ORDER BY '+
      '  JColu_Name';
    bOk:=rs.open(saQry, DBC,201503161261);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202260839,
        'Trouble querying jcolumn table.','Query: '+saQry,SOURCEFILE, DBC,RS);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.eol = false;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202260840,
        'Zero Columns Returned for table UID: ' + p_Context.CGIENV.DataIn.Get_saValue('JTabl_JTable_UID'),
        'Query: '+saQry,SOURCEFILE, DBC, RS);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    repeat
      FXDL.AppendItem;
      FXDL.Item_saName:=rs.fields.Get_saValue('JColu_Name');
      JFC_XDLITEM(FXDL.lpItem).UID:=u8Val(rs.fields.Get_saValue('JColu_JColumn_UID'));
      bOk:=bJASCaption(p_Context, u8Val(rs.fields.Get_saValue('JColu_JCaption_ID')), JFC_XDLITEM(FXDL.lpItem).saValue,JFC_XDLITEM(FXDL.lpItem).saName);
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201203252011,'Trouble gathering caption for column of import destination table.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;



  if bOk and FXDL.MoveFirst then
  begin
    saHTMLTable:='<table>';
    u8TableCol:=1;
    saScript:='';
    repeat
      if u8TableCol=1 then saHTMLTable+='<tr>';
      saHTMLTable+='<td>[#'+'COLUMN'+inttostr(JFC_XDLITEM(FXDL.lpItem).UID)+'#]</td>';
      u8TableCol += 1;
      if u8TableCol=5 then
      begin
        u8TableCol:=1;
        saHTMLTable+='</tr>'+csCRLF;
      end;
      saScript+='el=document.getElementById("COLUMN'+inttostr(JFC_XDLITEM(FXDL.lpItem).UID)+'");if(parseInt(el.value)>0){iMF++};'+csCRLF;

      if LXDL.MoveFirst then
      begin
        repeat
          if (LXDL.Item_saName=FXDL.Item_saName) or (LXDL.Item_saName=FXDL.Item_saValue) then
          begin
            if (LXDL.Item_saName=FXDL.Item_saName) then FXDL.Item_saValue:=FXDL.Item_saName;
            LXDL.Item_i8User:=B00+B01+B02;//Selectable
          end
          else
          begin
            LXDL.Item_i8User:=B00;//Selectable
          end;
        until not LXDL.MoveNext;
      end;

      WidgetList(
        p_Context,
        'COLUMN'+inttostr(JFC_XDLITEM(FXDL.lpItem).UID),
        FXDL.Item_saValue,
        '0',
        1,
        false,
        true,
        garJVHost[p_Context.u2VHost].VHost_DataOnRight_b,
        LXDL,
        false,
        false,
        false,
        '',//p_saOnBlur: ansistring;
        '',//p_saOnChange: ansistring;
        '',//p_saOnClick: ansistring;
        '',//p_saOnDblClick: ansistring;
        '',//p_saOnFocus: ansistring;
        '',//p_saOnKeyDown: ansistring;
        '',//p_saOnKeypress: ansistring;
        '' //p_saOnKeyUp: ansistring
      );
    until not FXDL.MoveNext;

    saScript:='function bFieldsMapped(){ var iMF=0; '+saScript+' return (iMF > 0); alert(iMF.toString());}';

    if u8TableCol>1 then
    begin
      for i:=u8TableCol to 4 do
      begin
        saHTMLTable+='<td>&nbsp;</td>';
      end;
      saHTMLTable+='</tr>'+csCRLF;
    end;
    saHTMLTable+=
      '<tr><td align="right">Perform Deduplication</td><td><input type="checkbox" name="DEDUPE" /></td>'+
          '<td align="right">Perform Merging</td><td><input type="checkbox" name="MERGE" /></td></tr>'+csCRLF+
      '</table>';

  end;
  //-----------------------------------------------Produce Interface for Mapping Fields


  //---------------------------------------------------------------------------- TRACK as TASK in case there is a time out
  if bOk then
  begin
    clear_JTask(rJTask);
    with rJTask do begin
      JTask_JTask_UID                  :=0;//So we get a new record
      JTask_Name                       :='Import into '+DBC.sGetTable(u8Val(p_Context.CGIENV.DataIn.Get_saValue('JTabl_JTable_UID')),201608191907);
      JTask_Desc                       :='JAS will update this task''s progress during the import. Refresh this page to monitor progress. '+csCRLF+
                                         'File: ' + saOrigFilename;
      JTask_JTaskCategory_ID           :=1;//task
      JTask_JProject_ID                :=0;
      JTask_JStatus_ID                 :=2;//In progress
      JTask_Due_DT                     :='';
      JTask_Duration_Minutes_Est       :=0;
      JTask_JPriority_ID               :=4;//normal
      JTask_Start_DT                   :=FormatDateTime(csDATETIMEFORMAT,now);
      JTask_Owner_JUser_ID             :=p_Context.rJUser.JUser_JUser_UID;
      JTask_SendReminder_b             :=false;
      JTask_ReminderSent_b             :=false;
      JTask_ReminderSent_DT            :='';
      JTask_Remind_DaysAhead_u         :=0;
      JTask_Remind_HoursAhead_u        :=0;
      JTask_Remind_MinutesAhead_u      :=0;
      JTask_Remind_Persistantly_b      :=false;
      JTask_Progress_PCT_d             :=0;
      JTask_JCase_ID                   :=0;
      JTask_Directions_URL             :='';
      JTask_URL                        :='';
      JTask_Milestone_b                :=false;
      JTask_Budget_d                   :=0;
    end;//with
    bOk:=bJAS_Save_JTask(p_Context, DBC, rJTask,false,true, 201608300034);
    if not bok then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201202271535, 'Trouble saving JTask','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;
  //---------------------------------------------------------------------------- TRACK as TASK in case there is a time out






  //------------------------------------------------Output Interface to User
  if bOk then
  begin
    p_Context.saPage:=saGetPage(p_Context, 'sys_area', 'sys_page_csvimport','CSVMAPFIELDS',false,'',201202260647);
    p_Context.saPage:=saSNRStr(p_Context.saPage,'[#FIELDSMAPPEDFUNCTION#]',saScript);
    p_Context.saPage:=saSNRStr(p_Context.saPage,'[#MAPFIELDSTABLE#]',saHTMLTable);
    p_Context.saPageTitle:='Step #2 - Map fields';
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@JTABL_JTABLE_UID@]',inttostr(JTabl_JTable_UID));
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@CSV_FILENAME@]',saFilename);
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@CSV_ORIGFILENAME@]',saOrigFilename);
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@CSV_FILESIZE@]',inttostr(uFileSize));
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@JTASK_JTASK_UID@]',inttostr(rJTask.JTask_JTask_UID));
    p_Context.bNoWebCache:=true;
  end;
  //------------------------------------------------Output Interface to User



  //JAS_Log(p_Context,cnLog_ebug,201203312246,'CSVMapFields - END bOk: '+sYesNo(bOk),'',SOURCEFILE);
  //---------------------------------------------------- Shut down
  RS.Destroy;
  LXDL.Destroy;
  FXDL.Destroy;
  //---------------------------------------------------- Shut down
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102314,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






















//=============================================================================
procedure CSVUpload(p_Context: TCONTEXT);
//=============================================================================
type rtLookUp=record
  sTable: string;
  sColumnPrefix: string;
  sPKey: string;
  saSQL: ansistring;
end;


var
  bOk:boolean;
  f: text;
  u2IOResult: word;
  saFilename: ansistring;
  saOrigFileName: ansistring;
  TK: JFC_TOKENIZER;
  saQry: Ansistring;
  DBC: JADO_CONNECTION;
  RS: JADO_RECORDSET;
  rJTable: rtJTable;
  rJColumn: rtJColumn;
  sa: ansistring;
  ch: char;
  chLast: char;
  DataXDL: JFC_XDL;
  iCol: longint;
  bInQuotes: boolean;
  bEndRow: boolean; bEndCol: boolean;
  u8JDType: word;
  uRow: UINT;
  uRowsAdded: UINT;
  uRowsMerged: UINT;
  uRowsSkipped: UINT;
  uRowsUnable: UINT;
  rJTask: rtJTask;
  uFileSize: UINT;
  uCharsProcessed: UINT;
  iTaskUpDateInterval: longint;
  iIntervalCount: longint;
  saTaskQry: ansistring;
  fCharsProcessed: double;
  fFileSize: double;
  uX: UINT;
  arJColumn: Array of rtJColumn;
  arLU: Array of rtLookUp;
  arData: Array of ansistring;
  bGotData: boolean;
  bFoundLookUpValue: boolean;
  saLUQry: ansistring;
  iDateFormat: longint;
  rAudit: rtAudit;
  bOkToAddRecord: boolean;
  bOkToUpdateRecord: boolean;
  bDupe: boolean;
  uDupeScore: Cardinal;
  uDupesCounted: cardinal;
  SrcXDL: JFC_XDL;
  DestXDL: JFC_XDL;
  ColXDL: JFC_XDL;
  u8UIDofDupe: uint64;
  sPKeyName: string;
  bPKeyJAS: boolean;

  saResultName: ansistring;// just filename portion
  saResultfilename: ansistring;// full path to storage location
  saPassedName: ansistring;
  saPassedFilename: ansistring;
  f2: text;
  f3: text;
  bGreenRow: boolean;

  bDeDupe: boolean;
  bMerge: boolean;
  ListXDL: JFC_XDL;
  //saJADO_Errors: ansistring;

  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='CSVUpload(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102315,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102316, sTHIS_ROUTINE_NAME);{$ENDIF}


  //--------------------------------INIT
  DBC:=p_Context.VHDBC;
  RS:=JADO_RECORDSET.Create;
  DataXDL:=JFC_XDL.Create;
  SrcXDL:=JFC_XDL.Create;
  DestXDL:=JFC_XDL.Create;
  ColXDL:=JFC_XDL.Create;
  ListXDL:=JFC_XDL.Create;
  TK:=JFC_TOKENIZER.create;
  arJColumn:=nil;
  arLU:=nil;
  arData:=nil;
  bGreenRow:=true;
  bDeDupe:=p_Context.CGIENV.DataIn.Get_saValue('DEDUPE')='on';
  bMerge:=p_Context.CGIENV.DataIn.Get_saValue('MERGE')='on';
  if bMerge and (not bDeDupe) then bDeDupe:=true;


  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201202261010,
      'Session not valid, upload not permitted.','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_CSVUpload);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204021307,
        'JAS Syncronization - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;
  //--------------------------------INIT



  //--------------------------------------- Get the IMPORTED FILE's NAME
  if bOk then
  begin
    //ASPrintln('csvupload - csv safilename:'+p_Context.CGIENV.DATAIN.Get_saValue('CSV_Filename'));

    //saFilename:=garJVHostLight[p_Context.i4VHost].saFileDir+p_Context.CGIENV.DATAIN.Get_saValue('CSV_Filename');
    saFilename:=p_Context.CGIENV.DATAIN.Get_saValue('CSV_Filename');


    saOrigfilename:=p_Context.CGIENV.DATAIN.Get_saValue('CSV_OrigFilename');
    bOk:=fileexists(saFilename);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201202261011,
        'File Not Found: '+safilename+' for CSV IMPORT: '+saOrigFilename,'',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  //--------------------------------------- Get the IMPORTED FILE's NAME
  uFileSize:=uVal(p_Context.CGIENV.DataIn.Get_saValue('CSV_Filesize'));
  iDateFormat:=iVal(p_Context.CGIENV.DataIn.Get_saValue('CSV_DateFormat'));


  //--------------------------------------- Load information about the Table we are going to import into
  if bOk then
  begin
    clear_jtable(rJTable);
    rJTable.JTabl_JTable_UID:=u8Val(p_Context.CGIENV.DataIn.Get_saValue('JTabl_JTable_UID'));
    bOk:=bJAS_Load_JTable(p_Context, DBC, rJTable, false, 201608300035);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201202261535,'Unable to load jtable record.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;
  //--------------------------------------- Load information about the Table we are going to import into



  //----------------------------------------------RESULT FILE CREATION
  if bOk and bDeDupe then
  begin
    saResultName:=p_Context.rJUser.JUser_Name+'-import-'+rJTable.JTabl_Name+'-details-'+inttostr(u8JAS_GetSessionKey)+'.html';
    saResultfileName:=garJVHost[p_Context.u2VHost].VHost_FileDir+saResultName;
    bOk:=bTSOpenTextFile(saResultfileName, u2IOResult, f2, false, true);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204121754,'Unable to create output file for import details.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and bDeDupe then
  begin
    writeln(f2,'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
    writeln(f2,'<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" >');
    writeln(f2,'<head><title>'+rJTable.JTabl_Name+' Import Details</title></head>');
    writeln(f2,'<body>');
    writeln(f2,'  <h1>'+rJTable.JTabl_Name+' Import Details</h1>');
    writeln(f2,'  <p>Below is information about every record that could not be imported.</p><hr />');
    writeln(f2,'<p>Deduplication: '+sYesNo(bDeDupe)+'&nbsp; Merge: '+sYesNo(bMerge));
  end;
  //---------------------------------------------RESULT FILE CREATION


  //--------------------------------------------- PASSED (over) FILE CREATION
  if bOk and bDeDupe then
  begin
    saPassedName:=p_Context.rJUser.JUser_Name+'-import-'+rJTable.JTabl_Name+'-rows-not-imported-'+inttostr(u8JAS_GetSessionKey)+'.html';
    saPassedFileName:=garJVHost[p_Context.u2VHost].VHost_FileDir+saPAssedName;
    bOk:=bTSOpenTextFile(saPassedFileName, u2IOResult, f3, false, true);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204121755,'Unable to create output file for rows not imported.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and bDeDupe then
  begin
    writeln(f3,'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
    writeln(f3,'<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" >');
    writeln(f3,'<head><title>'+rJTable.JTabl_Name+' Import Results</title></head>');
    writeln(f3,'<!-- www.jegas.com - Jegas, LLC-Virtually Everything IT(TM)-Copyright(C)2016 -->');
    writeln(f3,'<!--      _________ _______  _______  ______  _______                        -->');
    writeln(f3,'<!--     /___  ___// _____/ / _____/ / __  / / _____/                        -->');
    writeln(f3,'<!--        / /   / /__    / / ___  / /_/ / / /____                          -->');
    writeln(f3,'<!--       / /   / ____/  / / /  / / __  / /____  /                          -->');
    writeln(f3,'<!--  ____/ /   / /___   / /__/ / / / / / _____/ /                           -->');
    writeln(f3,'<!-- /_____/   /______/ /______/ /_/ /_/ /______/                            -->');
    writeln(f3,'<!--                                                                         -->');
    writeln(f3,'<!-- www.jegas.com - Jegas, LLC-Virtually Everything IT(TM)-Copyright(C)2016 -->');
    writeln(f3,'<body><table style="background:#aaaaaa;margin:4px;" align="left">');
  end;
  //--------------------------------------------- PASSED (over) FILE CREATION


















  //--------------------------------------- Load Every Column for the table - we're going to use them all
  if bOk then
  begin
    clear_Audit(rAudit,rJTable.JTabl_ColumnPrefix);
    saQry:='SELECT JColu_JColumn_UID FROM jcolumn WHERE JColu_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+' AND '+
      'JColu_JTable_ID='+DBC.sDBMSUIntScrub(rJTable.JTabl_JTable_UID);
    bOk:=rs.Open(saQry, DBC,201503161262);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201104120002, 'Trouble with Query.','Query: '+saQry, SOURCEFILE, DBC, rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:= not rs.eol;
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201104120003, 'Column records for table '+rJTable.JTabl_Name+' are missing.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    repeat
      clear_JColumn(rJColumn);
      rJColumn.JColu_JColumn_UID:=u8Val(rs.fields.Get_saValue('JColu_JColumn_UID'));
      bOk:=bJAS_Load_JColumn(p_Context, DBC, rJColumn, false, 201608300036);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201104120004, 'Trouble loading column record.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;

      if bOk then
      begin
        //-- Primary Key Info
        if rJColumn.JColu_PrimaryKey_b then
        begin
          sPKeyName:=rJColumn.JColu_Name;
          bPKeyJAS:=rJColumn.JColu_JAS_Key_b;
        end
        else
        begin
          setlength(arJColumn,length(arJColumn)+1);
          setlength(arLU,length(arJColumn));
          arLU[length(arLU)-1].sTable:='';
          arLU[length(arLU)-1].sColumnPrefix:='';
          arLU[length(arLU)-1].sPKey:='';
          arLU[length(arLU)-1].saSQL:='';
          setlength(arData,length(arJColumn));
          arData[length(arData)-1]:='';

          arJColumn[length(arJColumn)-1].JColu_JColumn_UID            := rJColumn.JColu_JColumn_UID          ;
          arJColumn[length(arJColumn)-1].JColu_Name                   := rJColumn.JColu_Name                 ;
          arJColumn[length(arJColumn)-1].JColu_JTable_ID              := rJColumn.JColu_JTable_ID            ;
          arJColumn[length(arJColumn)-1].JColu_JDType_ID              := rJColumn.JColu_JDType_ID            ;
          arJColumn[length(arJColumn)-1].JColu_AllowNulls_b           := rJColumn.JColu_AllowNulls_b         ;
          arJColumn[length(arJColumn)-1].JColu_DefaultValue           := rJColumn.JColu_DefaultValue         ;
          arJColumn[length(arJColumn)-1].JColu_PrimaryKey_b           := rJColumn.JColu_PrimaryKey_b         ;
          arJColumn[length(arJColumn)-1].JColu_JAS_b                  := rJColumn.JColu_JAS_b                ;
          arJColumn[length(arJColumn)-1].JColu_JCaption_ID            := rJColumn.JColu_JCaption_ID          ;
          arJColumn[length(arJColumn)-1].JColu_DefinedSize_u          := rJColumn.JColu_DefinedSize_u        ;
          arJColumn[length(arJColumn)-1].JColu_NumericScale_u         := rJColumn.JColu_NumericScale_u       ;
          arJColumn[length(arJColumn)-1].JColu_Precision_u            := rJColumn.JColu_Precision_u          ;
          arJColumn[length(arJColumn)-1].JColu_Boolean_b              := rJColumn.JColu_Boolean_b            ;
          arJColumn[length(arJColumn)-1].JColu_JAS_Key_b              := rJColumn.JColu_JAS_Key_b            ;
          arJColumn[length(arJColumn)-1].JColu_AutoIncrement_b        := rJColumn.JColu_AutoIncrement_b      ;
          arJColumn[length(arJColumn)-1].JColu_LUF_Value              := rJColumn.JColu_LUF_Value            ;
          arJColumn[length(arJColumn)-1].JColu_LD_CaptionRules_b      := rJColumn.JColu_LD_CaptionRules_b    ;
          arJColumn[length(arJColumn)-1].JColu_JDConnection_ID        := rJColumn.JColu_JDConnection_ID      ;
          arJColumn[length(arJColumn)-1].JColu_Desc                   := rJColumn.JColu_Desc                 ;
          arJColumn[length(arJColumn)-1].JColu_Weight_u               := rJColumn.JColu_Weight_u             ;
          arJColumn[length(arJColumn)-1].JColu_LD_SQL                 := rJColumn.JColu_LD_SQL               ;
          arJColumn[length(arJColumn)-1].JColu_LU_JColumn_ID          := rJColumn.JColu_LU_JColumn_ID        ;
          arJColumn[length(arJColumn)-1].JColu_CreatedBy_JUser_ID     := rJColumn.JColu_CreatedBy_JUser_ID   ;
          arJColumn[length(arJColumn)-1].JColu_Created_DT             := rJColumn.JColu_Created_DT           ;
          arJColumn[length(arJColumn)-1].JColu_ModifiedBy_JUser_ID    := rJColumn.JColu_ModifiedBy_JUser_ID  ;
          arJColumn[length(arJColumn)-1].JColu_Modified_DT            := rJColumn.JColu_Modified_DT          ;
          //---------------------------------------
          // Using this field to HOLD MAPPED Column
          if p_Context.CGIENV.DataIn.FoundItem_saName('COLUMN'+inttostr(rJColumn.JColu_JColumn_UID)) then
          begin
            arJColumn[length(arJColumn)-1].JColu_DeletedBy_JUser_ID     := u8Val(p_Context.CGIENV.DataIn.Item_saValue);
          end
          else
          begin
            arJColumn[length(arJColumn)-1].JColu_DeletedBy_JUser_ID:=0;
          end;
          //---------------------------------------
          arJColumn[length(arJColumn)-1].JColu_Deleted_DT             := rJColumn.JColu_Deleted_DT           ;
          arJColumn[length(arJColumn)-1].JColu_Deleted_b              := rJColumn.JColu_Deleted_b            ;
          arJColumn[length(arJColumn)-1].JAS_Row_b                    := rJColumn.JAS_Row_b                  ;
          //-- Audit Info
          if not rAudit.bUse_CreatedBy_JUser_ID  then rAudit.bUse_CreatedBy_JUser_ID:=rJColumn.JColu_Name=rAudit.saFieldName_CreatedBy_JUser_ID;
          if not rAudit.bUse_Created_DT          then rAudit.bUse_Created_DT:=rJColumn.JColu_Name=rAudit.saFieldName_Created_DT;
          if not rAudit.bUse_ModifiedBy_JUser_ID then rAudit.bUse_ModifiedBy_JUser_ID:=rJColumn.JColu_Name=rAudit.saFieldName_ModifiedBy_JUser_ID;
          if not rAudit.bUse_Modified_DT         then rAudit.bUse_Modified_DT:=rJColumn.JColu_Name=rAudit.saFieldName_Modified_DT;
          if not rAudit.bUse_DeletedBy_JUser_ID  then rAudit.bUse_DeletedBy_JUser_ID:=rJColumn.JColu_Name=rAudit.saFieldName_DeletedBy_JUser_ID;
          if not rAudit.bUse_Deleted_DT          then rAudit.bUse_Deleted_DT:=rJColumn.JColu_Name=rAudit.saFieldName_Deleted_DT;
          if not rAudit.bUse_Deleted_b           then rAudit.bUse_Deleted_b:=rJColumn.JColu_Name=rAudit.saFieldName_Deleted_b;
        end;
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;
  //--------------------------------------- Load Every Column for the table - we're going to use them all

  uX:=0;
  if bDeDupe then
  begin
    writeln(f3,'<thead style="color:#000000;background:#eeeeee;font-weight:bold;"><tr>');
    repeat
      write(F3,'<td style="padding-top:1px;padding-left:5px;padding-right:5px;padding-bottom:1px;" align="');
      u8JDType:=arJColumn[uX].JColu_JDType_ID;
      case u8JDType of
      cnJDType_i1,
      cnJDType_i2,
      cnJDType_i4,
      cnJDType_i8,
      cnJDType_i16,
      cnJDType_i32:begin
        write(F3,'right');
      end;
      cnJDType_u1,
      cnJDType_u2,
      cnJDType_u4,
      cnJDType_u8,
      cnJDType_u16,
      cnJDType_u32:begin
        write(F3,'right');
      end;
      cnJDType_fp,
      cnJDType_fd,
      cnJDType_cur:begin
        write(F3,'right');
      end;
      cnJDType_Unknown,
      cnJDType_s,
      cnJDType_su,
      cnJDType_ch,
      cnJDType_chu,
      cnJDType_sn,
      cnJDType_sun,
      cnJDType_bin:begin // 37 Jegas Data Type - Binary - Unspecified Length Binary Large Object
        write(F3,'left');
      end;
      cnJDType_b        :begin // 20 Jegas Data Type - Boolean - Byte	b
        write(F3,'right');
      end;
      cnJDType_dt       :begin // 23 Jegas Data Type - Timestamp	dt
        write(F3,'left');
      end;
      end;//case
      writeln(F3,'" valign="middle" >'+saHTMLScrub(arJColumn[uX].JColu_Name)+'</td>');

      uX+=1;
    until uX>=length(arJColumn);
    writeln(f3,'</tr></thead><tbody>');
  end;

  //---------------------------------------------------------------------------- TRACK as TASK in case there is a time out
  if bOk then
  begin
    clear_JTask(rJTask);
    rJTask.JTask_JTask_UID:=u8Val(p_Context.CGIENV.DataIn.Get_saValue('JTASK_JTASK_UID'));
    bOk:=bJAS_Load_JTask(p_Context, DBC, rJTask,false, 201608300037);
    if not bok then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201204121622, 'Trouble loading Task. UID: '+inttostr(rJTask.JTask_JTask_UID),'',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;
  //---------------------------------------------------------------------------- TRACK as TASK in case there is a time out





  //---------------------------------------------------- IMPORT DATA
  if bOk then
  begin
    bOk:=bTSOpenTextFile(saFilename,u2IOResult,f,true,false);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202261624, 'Unable to open file for reading: '+saFilename+' '+sIOResult(u2IOResult),'',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  // READ the HEADERS in one FELL SWOOP
  if bOk then
  begin
    readln(f, sa);
    TK.sWhitespace:=', ';
    TK.sSeparators:=',';
    TK.sQuotes:='"';
    //TK.bKeepDebugInfo:=true;
    TK.Tokenize(sa);
    //TK.DumpToTextFile('IMPORT_FILE_HEADER_TOKENS.TXT');
    //iImportColumns:=TK.ListCount;

    // Now Attempt to read Columns - need the column count...hmm...
    sa:='';
    bInQuotes:=false;
    iCol:=1;
    uRow:=0;
    uRowsAdded:=0;
    uRowsMerged:=0;
    uRowsSkipped:=0;
    bEndRow:=false;
    bEndCol:=false;
    ch:=#00;
    uCharsProcessed:=0;
    iTaskUpDateInterval:=uFilesize div 100;
    iIntervalCount:=0;
    fFileSize:=uFileSize;
    repeat
      chLast:=ch;
      read(f,ch);
      uCharsProcessed+=1;
      iIntervalCount+=1;
      if iTaskUpdateInterval>0 then
      begin
        if iIntervalCount=iTaskUpdateInterval then
        begin
          iIntervalCount:=0;
          fCharsProcessed:=uCharsProcessed;
          saTaskQry:=
            'update jtask set '+
            'JTask_ModifiedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+','+
            'JTask_Modified_DT='+DBC.sDBMSDateScrub(now)+','+
            'JTask_Progress_PCT_d='+DBC.sDBMSDecScrub( saDouble(100*(fCharsProcessed / fFilesize),3,2) )+' '+
            'where JTask_JTask_UID='+DBC.sDBMSUintScrub(rJTask.JTask_JTask_UID);
          bOk:=rs.open(saTaskQry, DBC,201503161263);
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201202271627, 'Trouble Updating JTask during Import','Query: '+saTaskQry,SOURCEFILE, DBC, rs);
            DBM_RenderHtmlErrorPage(p_Context);
          end;
          rs.close;
        end;
      end;

      if bOk then
      begin
        case ch of
        '"': begin
          if bInQuotes then
          begin
            bInQuotes:=false;
          end
          else
          begin
            bInQuotes:=true;
            if chLast='"' then
            begin
              sa+='"';
            end;
          end;
        end;
        #10: begin
          if not bInQuotes then
          begin
            if saRightStr(sa,1)=#13 then sa:=saLeftStr(sa,length(sa)-1);
            bEndRow:=true;
          end
          else
          begin
            sa+=ch;
          end;
        end;
        ',': begin
          if bInQuotes then sa+=ch else
          begin
            bEndCol:=true;
          end;
        end
        else
        begin
          sa+=ch;
        end;
        end;//case

        if bEndCol or bEndRow then
        begin
          TK.FoundNth(iCol);
          DataXDL.AppendItem_saName_N_saValue(TK.Item_saToken,sa);
          sa:='';
          if bEndCol then
          begin
            bEndCol:=false;
            iCol+=1;
          end;
          if bEndRow then
          begin
            iCol:=1;
            bEndRow:=false;
            bGotData:=false;
            if DataXDL.MoveFirst then
            begin
              Repeat
                if not bGotData then bGotData:=(trim(DataXDL.Item_saValue)>'');
              until not DataXDL.MoveNext;
            end;

            if bGotData then
            begin
              //JAS_LOG(p_Context, nLog_Debug, 201204120128,'Got Data','',SOURCEFILE);
              uX:=0;
              repeat
                if (DataXDL.FoundNth(arJColumn[uX].JColu_DeletedBy_JUser_ID)) then
                begin
                  u8JDType:=arJColumn[uX].JColu_JDType_ID;
                  if ((u8JDType=cnJDType_i1) or
                     (u8JDType=cnJDType_i2) or
                     (u8JDType=cnJDType_i4) or
                     (u8JDType=cnJDType_i8) or
                     (u8JDType=cnJDType_i16) or
                     (u8JDType=cnJDType_i32) or
                     (u8JDType=cnJDType_u1) or
                     (u8JDType=cnJDType_u2) or
                     (u8JDType=cnJDType_u4) or
                     (u8JDType=cnJDType_u8) or
                     (u8JDType=cnJDType_u16) or
                     (u8JDType=cnJDType_u32)) and
                     (arJColumn[uX].JColu_LU_JColumn_ID>0) and
                     (upcase(trim(DataXDL.Item_saValue))<>'NULL') then
                  begin
                    bFoundLookUpValue:=false;
                    if p_Context.bPopulateLookUpList(
                        rJTable.JTabl_Name,
                        arJColumn[uX].JColu_Name,
                        ListXDL,
                        DataXDL.Item_saValue,
                        true
                    ) then
                    begin
                      if ListXDL.MoveFirst then
                      begin
                        repeat
                          if UPCASE(ListXDL.Item_saName)=UPCASE(DataXDL.Item_saValue) then
                          begin
                            arData[uX]:=ListXDL.Item_saValue;
                            bFoundLookUpValue:=true;
                          end;
                        until bFoundLookUpValue or (not ListXDL.MoveNext);
                      end;
                    end;
                    if not bFoundLookUpValue then arData[uX]:='NULL';
                  end
                  else
                  begin
                    arData[uX]:=DataXDL.Item_saValue;
                  end;
                end
                else
                begin
                  arData[uX]:=arJColumn[uX].JColu_DefaultValue;
                end;
                uX+=1;
              until (not bOk) or (uX>=length(arJColumn));


              //uX:=0;sa:='';
              //repeat
              //  sa+='<br />arData['+inttostr(uX)+'] = '+arData[uX];
              //  uX+=1;
              //until uX> length(arData);
              //JAS_LOG(p_Context, nLog_Debug,201204120235,'arData after initial dataload: '+sa,'',SOURCEFILE);

              if bDeDupe then
              begin
                if bOk then
                begin
                  // HAVE DATA SO USE to Get a Result Set from the Target
                  saQry:='';
                  uX:=0;
                  bOkToAddRecord:=false;
                  bOkToUpdateRecord:=false;
                  uDupesCounted:=0;
                  saQry:='SELECT * FROM '+ DBC.sDBMSEncloseObjectName(rJTable.JTabl_Name);
                  //saQry:='SELECT * FROM '+ rJTable.JTabl_Name +' WHERE '+saQry;
                  //JAS_LOG(p_Context, nLog_Debug, 201204120126,'Query to sample: '+saQry,'',SOURCEFILE);
                  bOk:=rs.Open(saQry,DBC,201503161264);
                  if not bOk then
                  begin
                    JAS_LOG(p_Context, cnLog_Error,201204112019,'Trouble with query.','Query: '+saQry, SOURCEFILE,DBC,rs);
                    DBM_RenderHtmlErrorPage(p_Context);
                  end;
                end;

                if bOk then
                begin
                  if rs.eol then
                  begin
                    bOkToAddRecord:=true;
                  end
                  else
                  begin
                    repeat
                      // check For DUPES - Just Count Them
                      SrcXDL.DeleteAll;
                      DestXDL.DeleteAll;
                      ColXDL.DeleteAll;
                      for uX:=0 to length(arJColumn)-1 do begin
                        SrcXDL.AppendItem;
                        SrcXDL.Item_saName:=arJColumn[uX].JColu_Name;
                        SrcXDL.Item_saValue:=arData[uX];
                        SrcXDL.Item_i8User:=arJColumn[uX].JColu_Weight_u;
                      end;
                      //JAS_LOG(p_Context, nLog_Debug, 201204120126,'DupeTest SrcXDL: '+SrcXDL.saHTMLTable,'',SOURCEFILE);

                      if rs.fields.MoveFirst then
                      begin
                        repeat
                          DestXDL.AppendItem_saName_N_saValue(rs.fields.Item_saName, rs.fields.Item_saValue);
                        until not rs.fields.movenext;
                      end;
                      //JAS_LOG(p_Context, nLog_Debug, 201204120126,'DupeTest DestXDL: '+DestXDL.saHTMLTable,'',SOURCEFILE);

                      bDupe:=false;uDupeScore:=rJTable.JTabl_DupeScore_u;
                      Merge(false, uDupeScore, false, bDupe, SrcXDL, DestXDL, ColXDL);
                      //JAS_LOG(p_Context, nLog_Debug, 201204120126,'DupeTest Merge Result: uDupeScore: '+inttostr(uDupeScore)+' bDupe: '+sYesNo(bDupe),'',SOURCEFILE);
                      if bDupe then
                      begin
                        uDupesCounted+=1;
                        u8UIDOfDupe:=u8val(DestXDL.Get_saValue(sPKeyName));
                      end;
                    until (not bOk) or (uDupesCounted>1) or (not rs.movenext);
                    if uDupesCounted=0 then bOkToAddRecord:=true;
                  end;
                end;
                rs.close;
              end;

              if bOk then
              begin
                if bMerge then
                begin
                  if not bOkToAddRecord then
                  begin
                    if uDupesCounted>1 then
                    begin
                      // MUST SKIP THIS RECORD - MULTIPLE DUPES EXIST
                      writeln(f2,'<h2>MultipleDuplicates Exist for this Row</h2>'+SrcXDL.saHTMLTable+'<hr />');
                      //JAS_LOG(p_Context, nLog_Debug, 201204120126,'skipping record cuz multiple dupes exist: uDupesCounted: '+inttostr(uDupesCounted),'',SOURCEFILE);
                    end else
                    begin
                      // ATTEMPT a MERGE TO SEE IF WE CAN UPDATE EXISTING RECORD
                      //JAS_LOG(p_Context, nLog_Debug, 201204120126,'Loading XDL for Merge.','',SOURCEFILE);
                      bOk:=p_Context.bLoadXDLForMerge(
                        rJTable.JTabl_Name,
                        u8UIDOfDupe,
                        DestXDL,
                        uDupeScore
                      );
                      //JAS_LOG(p_Context, nLog_Debug, 201204120126,'Result of Loading XDL for Merge: '+sYesNo(bOk),'',SOURCEFILE);

                      if not bOk then
                      begin
                        JAS_LOG(p_Context, cnLog_Error, 201204112102, 'Trouble in call to bLoadXDLForMerge','',SOURCEFILE);
                        DBM_RenderHtmlErrorPage(p_Context);
                      end;

                      if bOk then
                      begin
                        bDupe:=false;
                        //JAS_LOG(p_Context, nLog_Debug, 201204120126,'Attempting Actual Merge','',SOURCEFILE);
                        uDupeScore:=rJTable.JTabl_DupeScore_u;
                        Merge(true, uDupeScore, false, bDupe, SrcXDL, DestXDL, ColXDL);

                        //JAS_LOG(p_Context, nLog_Debug, 201204120126,'Merge Result: uDupeScore: '+inttostr(uDupeScore)+
                        //  ' bDupe: '+sYesNo(bDupe)+' ColXDL: '+ColXDL.saHTMLTable,'',SOURCEFILE);

                        bOkToUpdateRecord:=ColXDL.ListCount=0;
                        if bOkToUpdateRecord then
                        begin
                          saQry:='';
                          uX:=0;
                          repeat
                            if (arJColumn[uX].JColu_Name=rAudit.saFieldName_CreatedBy_JUser_ID) then
                            begin
                              if saQry<>'' then saQry+=', ';
                              saQry+=rAudit.saFieldName_CreatedBy_JUser_ID+'='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID);
                            end else

                            if (arJColumn[uX].JColu_Name=rAudit.saFieldName_Created_DT) then
                            begin
                              if saQry<>'' then saQry+=', ';
                              saQry+=rAudit.saFieldName_CreatedBy_JUser_ID+'='+DBC.sDBMSDateScrub(formatdatetime(csDATETIMEformat,now));
                            end else

                            if
                               (arJColumn[uX].JColu_Name<>rAudit.saFieldName_DeletedBy_JUser_ID) and
                               (arJColumn[uX].JColu_Name<>rAudit.saFieldName_Deleted_DT) and
                               (arJColumn[uX].JColu_Name<>rAudit.saFieldName_Deleted_b) then
                            begin
                              if (arJColumn[uX].JColu_Name=rAudit.saFieldName_ModifiedBy_JUser_ID) then
                              begin
                                arData[uX]:=inttostr(p_Context.rJUser.JUser_JUser_UID);
                              end else
                              if (arJColumn[uX].JColu_Name=rAudit.saFieldName_Modified_DT) then
                              begin
                                arData[uX]:=FormatDateTime(csDATETIMEFORMAT, now);
                              end;

                              if saQry<>'' then saQry+=', ';
                              saQry+=arJColumn[uX].JColu_Name;
                              saQry+=' = ';
                              u8JDType:=arJColumn[uX].JColu_JDType_ID;
                              case u8JDType of
                              cnJDType_i1,
                              cnJDType_i2,
                              cnJDType_i4,
                              cnJDType_i8,
                              cnJDType_i16,
                              cnJDType_i32:begin
                                saQry+=DBC.sDBMSIntScrub(arData[uX]);
                              end;
                              cnJDType_u1,
                              cnJDType_u2,
                              cnJDType_u4,
                              cnJDType_u8,
                              cnJDType_u16,
                              cnJDType_u32:begin
                                saQry+=DBC.sDBMSUIntScrub(arData[uX]);
                              end;
                              cnJDType_fp,
                              cnJDType_fd,
                              cnJDType_cur:begin
                                saQry+=DBC.sDBMSDecScrub(arData[uX]);
                              end;
                              cnJDType_Unknown,
                              cnJDType_s,
                              cnJDType_su,
                              cnJDType_ch,
                              cnJDType_chu,
                              cnJDType_sn,
                              cnJDType_sun,
                              cnJDType_bin:begin // 37 Jegas Data Type - Binary - Unspecified Length Binary Large Object
                                saQry+=DBC.saDBMSScrub(arData[uX]);
                              end;
                              cnJDType_b        :begin // 20 Jegas Data Type - Boolean - Byte	b
                                saQry+=DBC.sDBMSBoolScrub(arData[uX]);
                              end;
                              cnJDType_dt       :begin // 23 Jegas Data Type - Timestamp	dt
                                saQry+=DBC.sDBMSDateScrub(JDate(arData[uX],11,iDateFormat));
                              end;
                              end;//case
                            end;
                            uX+=1;
                          until uX>=length(arJColumn);
                          saQry:='UPDATE '+rJTable.JTabl_Name+' SET '+saQRY+' WHERE '+sPKeyName+'='+DBC.sDBMSUIntScrub(u8UIDofDupe);
                          bOk:=rs.open(saQry, DBC,201503161265);
                          if not bOk then
                          begin
                            JAS_LOG(p_Context, cnLog_Error, 201104112122, 'Trouble with query.','Query: '+saQry,SOURCEFILE, DBC, rs);
                            DBM_RenderHtmlErrorPage(p_Context);
                          end;
                          rs.close;
                          uRowsMerged+=1;
                          //JAS_LOG(p_Context, nLog_Debug, 201204112326,'UPDATE: '+saQry,'',SOURCEFILE);
                        end
                        else
                        begin
                          writeln(f2, '<h2>Unable to Merge due to Data Collisions.</h2>'+
                            SrcXDL.saHTMLTable+'<br /><h2>Colisions</h2>'+ColXDL.saHTMLTable+'<hr />');
                        end;
                      end;
                    end;
                  end;
                end
                else
                begin
                  if bDeDupe and (not bOkToAddRecord) then
                  begin
                    writeln(f2,'<h2>This row scored as a duplicate.</h2>'+SrcXDL.saHTMLTable+'<hr />');
                  end;
                end;

                if not bDeDupe then bOkToAddRecord:=true;

                if bOkToAddRecord then
                begin
                  // OK To Add RECORD
                  saQry:='';
                  saLUQry:='';
                  uX:=0;
                  repeat
                    //JAS_LOG(p_Context, nLog_Debug, 201204120129,'LOOP E','',SOURCEFILE);
                    if (arJColumn[uX].JColu_Name<>rAudit.saFieldName_ModifiedBy_JUser_ID) and
                       (arJColumn[uX].JColu_Name<>rAudit.saFieldName_Modified_DT) and
                       (arJColumn[uX].JColu_Name<>rAudit.saFieldName_DeletedBy_JUser_ID) and
                       (arJColumn[uX].JColu_Name<>rAudit.saFieldName_Deleted_DT) and
                       (arJColumn[uX].JColu_Name<>rAudit.saFieldName_Deleted_b) then
                    begin
                      if saQry<>'' then saQry+=', ';
                      if saLUQry<>'' then saLUQry+=', ';

                      if (arJColumn[uX].JColu_Name=rAudit.saFieldName_CreatedBy_JUser_ID) then
                      begin
                        arData[uX]:=inttostR(p_Context.rJUser.JUser_JUser_UID);
                      end;

                      saQry+=arJColumn[uX].JColu_Name;
                      u8JDType:=arJColumn[uX].JColu_JDType_ID;
                      case u8JDType of
                      cnJDType_i1,
                      cnJDType_i2,
                      cnJDType_i4,
                      cnJDType_i8,
                      cnJDType_i16,
                      cnJDType_i32:begin
                        saLUQry+=DBC.sDBMSIntScrub(arData[uX]);
                      end;
                      cnJDType_u1,
                      cnJDType_u2,
                      cnJDType_u4,
                      cnJDType_u8,
                      cnJDType_u16,
                      cnJDType_u32:begin
                        saLUQry+=DBC.sDBMSUIntScrub(arData[uX]);
                      end;
                      cnJDType_fp,
                      cnJDType_fd,
                      cnJDType_cur:begin
                        saLUQry+=DBC.sDBMSDecScrub(arData[uX]);
                      end;
                      cnJDType_Unknown,
                      cnJDType_s,
                      cnJDType_su,
                      cnJDType_ch,
                      cnJDType_chu,
                      cnJDType_sn,
                      cnJDType_sun,
                      cnJDType_bin:begin // 37 Jegas Data Type - Binary - Unspecified Length Binary Large Object
                        saLUQry+=DBC.saDBMSScrub(arData[uX]);
                      end;
                      cnJDType_b        :begin // 20 Jegas Data Type - Boolean - Byte	b
                        saLUQry+=DBC.sDBMSBoolScrub(arData[uX]);
                      end;
                      cnJDType_dt       :begin // 23 Jegas Data Type - Timestamp	dt
                        if (arJColumn[uX].JColu_Name<>rAudit.saFieldName_Created_DT) then
                        begin
                          saLUQry+=DBC.sDBMSDateScrub(JDate(arData[uX],11,iDateFormat));
                        end
                        else
                        begin
                          saLUQry+=DBC.sDBMSDateScrub(FormatDateTime(csDATETIMEFORMAT, now));
                        end;
                      end;
                      else
                      begin
                        JASPRintln('UNKNOWN DATA TYPE IN IMPORT:'+inttostr(u8JDType));
                      end;//else
                      end;//case
                    end;
                    uX+=1;
                  until uX>=length(arJColumn);
                  if bPkeyJas then
                  begin
                    saQry+=', '+sPKeyName;
                    saLUQry+=', '+sGetUID;
                  end;



                  saQry:='INSERT INTO '+rJTable.JTabl_Name+' ( '+saQry+' ) VALUES ( '+saLUQry+')';
                  bOk:=rs.open(saQry, DBC,201503161266);
                  if not bOk then
                  begin
                    //saJADO_ERRORS:='<font style="color: #F00000;">JADO_CONNECTION.JADO_ERRORS.ListCount:</font> <b><font style="color: #F00000;">' +inttostr(DBC.Errors.ListCount)+'</font></b><br />'+csCRLF;


                    //if DBC.Errors.MoveFirst then
                    //begin
                    //  repeat
                    //    saJADO_ERRORS+='<b>Error:' + inttostr(DBC.Errors.N)+'</b><br />'+csCRLF;
                    //    saJADO_ERRORS+='i8NativeError: <b>' + saSTR(JADO_ERROR(DBC.Errors.lpItem).i8NativeError)+'</b><br />'+csCRLF;
                    //    saJADO_ERRORS+='i8Number: <b>' + saSTR(JADO_ERROR(DBC.Errors.lpItem).i8Number)+'</b><br />'+csCRLF;
                    //    saJADO_ERRORS+='saSource: <b>' + JADO_ERROR(DBC.Errors.lpItem).saSource+'</b><br />'+csCRLF;
                    //    saJADO_ERRORS+='saSQLState: <b>' + JADO_ERROR(DBC.Errors.lpItem).saSQLState+'</b><br />'+csCRLF;
                    //    saJADO_ERRORS+='<br />'+csCRLF;
                    //  Until not DBC.Errors.Movenext;
                    //end;

                    //----
                    // using WARNING versus error prevents the context of this web request entering an error state where its clean up time mode.
                    // seeing how we are going to SKIP errors in the name of progress... we use cnLog_Warn, not cnLOG_Error. Think of thelog as
                    // big brother - watching - recording and if it looks messed up - knock knock - Mr. Jegas please step outside - um what did
                    // I do officer?
                    JAS_LOG(p_Context, cnLog_Warn, 201104112123,
                      'IMPORTING CSV FILE: '+saOrigFilename+' Uploaded as: '+saFilename+
                      ' Trouble with query. Row: '+inttostR(uRowsAdded)+' DataXDL:'+DataXDL.saHTMLTable,
                      'Query: '+saQry,SOURCEFILE, DBC, rs);
                    //----

                    //---
                    // One Way that is correct but stops the import dead in its tracks
                    //---
                    // A: Keep bOK as it is FALSE
                    // B: Render an Error Page to help out.
                    // DBM_RenderHtmlErrorPage(p_Context);
                    //---
                    // The Other Way? Heck with it!
                    bOk:=TRUE; // I LIED YAY!
                    uRowsSkipped+=1;
                  end
                  else
                  begin
                    uRowsAdded+=1;
                  end;
                  rs.close;
                  //JAS_LOG(p_Context, nLog_debug, 201204112325,'INSERT: '+saQry,'',SOURCEFILE);
                end;
              end;

              if bDeDupe and (not bOkToAddRecord) and (not bOkToUpdateRecord) then
              begin
                if not bGreenRow then
                begin
                  writeln(F3,'<tr style="color:#000000;background: #ffffff;">');
                end
                else
                begin
                  writeln(F3,'<tr style="color:#000000;background: #c0f0c0;">');
                end;
                uX:=0;
                repeat
                  write(F3,'<td style="padding-top:1px;padding-left:5px;padding-right:5px;padding-bottom:3px;text-align:left;" align="');
                  u8JDType:=arJColumn[uX].JColu_JDType_ID;
                  case u8JDType of
                  cnJDType_i1,
                  cnJDType_i2,
                  cnJDType_i4,
                  cnJDType_i8,
                  cnJDType_i16,
                  cnJDType_i32:begin
                    write(F3,'right');
                  end;
                  cnJDType_u1,
                  cnJDType_u2,
                  cnJDType_u4,
                  cnJDType_u8,
                  cnJDType_u16,
                  cnJDType_u32:begin
                    write(F3,'right');
                  end;
                  cnJDType_fp,
                  cnJDType_fd,
                  cnJDType_cur:begin
                    write(F3,'right');
                  end;
                  cnJDType_Unknown,
                  cnJDType_s,
                  cnJDType_su,
                  cnJDType_ch,
                  cnJDType_chu,
                  cnJDType_sn,
                  cnJDType_sun,
                  cnJDType_bin:begin // 37 Jegas Data Type - Binary - Unspecified Length Binary Large Object
                    write(F3,'left');
                  end;
                  cnJDType_b        :begin // 20 Jegas Data Type - Boolean - Byte	b
                    write(F3,'right');
                  end;
                  cnJDType_dt       :begin // 23 Jegas Data Type - Timestamp	dt
                    write(F3,'left');
                  end;
                  end;//case
                  writeln(F3,'" valign="top" nowrap="nowrap">'+saHTMLScrub(arData[uX])+'</td>');

                  uX+=1;
                until uX>=length(arJColumn);
                writeln(f3,'</tr>');
                bGreenRow:=not bGreenRow;
              end;

              if bOk then
              begin
                uRow+=1;
              end;
            end;
            DataXDL.DeleteAll;
          end;
        end;
      end;
    until (not bOk) or (eof(f));// or (bEndRow); // DONT FORGET REMOVE ENDROW THING HERE
  end;

  if bOk then
  begin
    bOk:=bTSCloseTextFile(saFilename,u2IOResult,F);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202290933,
        'Trouble closing open file: '+saFilename+' '+sIOResult(u2IOResult),'',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
    try
      deletefile(saFileName)
    except on E:Exception do
    begin
      JAS_Log(p_Context, cnLog_Error,201605012347,
        'unable to delete temporary csv import upload: '+saFilename+' '+sIOResult(u2IOResult),'',SOURCEFILE);
    end;//except
    end;//try
  end;
  //---------------------------------------------------- IMPORT DATA


  //---------------------------------------------------- RENDER OUTPUT
  if bOk then
  begin
    if uRowsSkipped=0 then
      p_Context.saPageTitle:='Success!'
    else
      p_Context.saPageTitle:='Done. '+inttostr(uRowsSkipped)+' rows were skipped due to errors.';


    p_Context.saPage:=saGetPage(p_Context, 'sys_area', 'sys_page_csvimport','CSVUPLOAD',false,'',201202261514);
    sa:=inttostr(uRow)+' Processed.';
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@ROWS@]',sa);

    if uRowsAdded=0 then sa:='' else sa:=inttostr(uRowsAdded)+' Records Added.';
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@ADDED@]',sa);

    if uRowsMerged=0 then sa:='' else sa:=inttostr(uRowsMerged)+' Records merged.';
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MERGED@]',sa);

    if uRowsSkipped=0 then sa:='' else sa:=inttostr(uRowsSkipped)+' Records Skipped (Errors).';
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@SKIPPED@]',sa);
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@CSV_ORIGFILENAME@]',saOrigFilename);


    uRowsUnable:=uRow-uRowsMerged-uRowsAdded;
    if uRowsUnable<=0 then sa:='' else sa:=inttostr(uRowsUnable)+' Records were not imported because they would cause duplicates, and could not be successfully merged.';
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@UNABLE@]',sa);
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@JTASK_JTASK_UID@]',inttostr(rJTask.JTask_JTask_UID));
    p_Context.bNoWebCache:=true;
  end;
  //---------------------------------------------------- RENDER OUTPUT


  if bOk and bDeDupe then
  begin
    writeln(f2,'</body></html>');
    bOk:=bTSCloseTextFile(saResultFilename,u2IOResult,F2);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202290933,
        'Trouble closing open file: '+saResultFilename+' '+sIOResult(u2IOResult),'',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and bDeDupe then
  begin
    writeln(f3,'</tbody></table></body></html>');
    bOk:=bTSCloseTextFile(saPassedFilename,u2IOResult,F3);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201202290934,
        'Trouble closing open file: '+saPassedFilename+' '+sIOResult(u2IOResult),'',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    sa:='Import Successful'+csCRLF+
      saFilename+csCRLF+
      inttostr(uRow)+' Processed.'+csCRLF+
      inttostr(uRowsAdded)+' Records Added.'+csCRLF+
      inttostr(uRowsMerged)+' Records Merged.'+csCRLF+
      inttostr(uRowsSkipped)+' Records Skipped(errors).'+csCRLF+
      'Deduplication: '+sYesNo(bDeDupe)+csCRLF+
      'Merge: '+sYesNo(bMerge);
      uRowsUnable:=uRow-uRowsMerged-uRowsAdded;
    if uRowsUnable<=0 then sa+='' else
    begin
      sa+=inttostr(uRowsUnable)+' Records were not imported because they would cause duplicates, and could not be successfully merged.'+csCRLF+
       'You can view the details by clicking the link in the "URL" field. For a look at just the rows that didn''t get imported, click on '+
       'the URL in the "URL Directions" field.';
    end;
    saTaskQry:=
      'update jtask set '+
      'JTask_JStatus_ID='+DBC.sDBMSIntScrub('3')+',';
    if (bDeDupe) then
    begin
      saTaskQry+=
        'JTask_URL='+DBC.saDBMSScrub(garJVHost[p_Context.u2VHost].VHost_ServerURL+garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'download/'+saResultName)+','+
        'JTask_Directions_URL='+DBC.saDBMSScrub(garJVHost[p_Context.u2VHost].VHost_ServerURL+garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'download/'+saPassedName)+',';
    end;
    saTaskQry+=
      'JTask_Desc='+DBC.saDBMSScrub(sa)+','+
      'JTask_ModifiedBy_JUser_ID='+DBC.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID)+','+
      'JTask_Completed_DT='+DBC.sDBMSDateScrub(now)+','+
      'JTask_Modified_DT='+DBC.sDBMSDateScrub(now)+','+
      'JTask_Progress_PCT_d='+DBC.sDBMSDecScrub('100')+' '+
      'where JTask_JTask_UID='+inttostr(rJTask.JTask_JTask_UID);
    bOk:=rs.open(saTaskQry, DBC,201503161267);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201202271525, 'Trouble Updating JTask during Import','Query: '+saTaskQry,SOURCEFILE, DBC, rs);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=bJAS_UnlockRecord(p_Context,DBC.ID,'jtask',rJTask.JTask_JTask_UID,0,201501020001);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201202271628, 'Unable to unlock lock on jtask table. UID: '+
        inttostr(rJTask.JTask_JTask_UID),'',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;



  //------------------------ SHUTDOWN
  RS.Destroy;
  setlength(arJColumn,0);
  setlength(arLU,0);
  setLength(arData,0);
  DataXDL.Destroy;
  SrcXDL.Destroy;
  DestXDL.Destroy;
  ColXDL.Destroy;
  ListXDL.Destroy;
  TK.Destroy;
  //------------------------ SHUTDOWN
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102316,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






































//=============================================================================
procedure JASSync(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  //JAS: JADO_CONNECTION;
  //DBC: JADO_CONNECTION;// Destination
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='JASSync(p_Context: TCONTEXT)';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204021301,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204021302, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201204021310, 'Unable to comply - session is not valid.','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_JASSync);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204021311,
        'JAS Syncronization - ACCESS DENIED - You do not have permission '+
        '"JAS Admin" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=p_Context.CGIENV.DataIn.FoundItem_saName('DESTDSN');
    if not bOk then
    begin
      JAS_LOG(p_COntext, cnLog_Error, 201204021312, 'Destination DSN Name (Other JAS Installation) not passed in request.','',SOURCEFILE);
    end;
  end;
  // NOT FINISHED - STOPPED to Improve UID system for syncronization

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201204021303,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
{}
// handles uploaded files to system
procedure FileUpload(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  path: string;
  dir: string;
  name: string;
  ext: string;
  saRelPath: ansistring;
  saOrigFilename: ansistring;
//  saStoredFile: ansistring;
  saFilename: ansistring;
  u8FileSize: UInt64;
  sa: ansistring;

  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='FileUpload(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204291124,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204291125, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=p_Context.bSessionValid;
  saRelPath:='';
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201204021310, 'Unable to comply - session is not valid.','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_FileUpload);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201608241453,
        'You are not authorized to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;



  if bOk and (not p_Context.CGIENV.DataIn.FoundItem_saName('fileupload')) then
  begin
    p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@MAXFILESIZE@]',inttostr(grJASConfig.uMaximumRequestHeaderLength));
    p_Context.saPage:=saGetPage(p_Context, '','sys_page_fileupload','FILEUPLOAD',false,201204291127);
  end
  else
  begin
    //------------------------------------------ Verify File Uploaded
    if bOk then
    begin
      bOk:=p_Context.CGIENV.FilesIn.ListCount=1;
      if not bOk then
      begin
        if p_Context.CGIENV.FilesIn.ListCount=0 then
        begin
          JAS_LOG(p_Context, cnLog_Error,201204291225, 'No file received.','',SOURCEFILE);
        end
        else
        begin
          JAS_LOG(p_Context, cnLog_Error,201204291226, 'Received '+inttostr(p_Context.CGIENV.FilesIn.ListCount)+' files. Only one file at a time can be uploaded.','',SOURCEFILE);
        end;
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    end;

    if bOk then
    begin
      bOk:=p_Context.CGIENV.DataIn.FoundItem_saName(p_Context.CGIENV.FilesIn.Item_saName);
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201204291227, 'Unable to locate file in DataIn XDL.','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    end;


    if bOk then
    begin
      bOk:=p_Context.CGIENV.DataIn.FoundItem_saName('fileupload');
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201204291228, 'Unable to locate filename in DataIn XDL','',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    end;
    //------------------------------------------ Verify File Uploaded




    //------------------------------------------------ Save Imported File
    if bOk then
    begin
      saOrigFilename:=p_Context.CGIENV.DataIn.Item_saValue;
      path:=saOrigFilename;
      FSplit(path,dir,name,ext);
      u8FileSize:=length(p_Context.CGIENV.FilesIn.Item_saValue);
      bOk:=bStoreFileInTree(saOrigfilename,'',saOrigfilename,garJVHost[p_Context.u2VHost].VHost_FileDir,p_Context.CGIENV.FilesIn.Item_saValue, saRelPath, 2,3);
      if not bOk then
      begin
        JAS_Log(p_Context, cnLog_Error,201204291231, 'Trouble storing file in dir tree. file: '+saOrigFilename,'',SOURCEFILE);
        DBM_RenderHtmlErrorPage(p_Context);
      end;
    end;

    if bOk then
    begin
      //saStoredFile:=garJVHost[p_Context.u2VHost].VHost_FileDir+saRelPath+DOSSLASH+saOrigFilename;
      if saLeftStr(ext,1)='.' then ext:=saRightStr(ext,length(ext)-1);
      ////saFilename:=saSequencedFilename(garJVHost[p_Context.u2VHost].VHost_FileDir+saRelPath+DOSSLASH+name,ext);
      saFilename:=garJVHost[p_Context.u2VHost].VHost_FileDir+saRelPath+DOSSLASH+name+'.'+ext;
      ////bOk:=bMoveFile(saStoredFile, saFilename);
      ////if not bOk then
      ////begin
      ////  JAS_Log(p_Context, cnLog_Error,201204291245, 'Trouble moving file. Src: '+saStoredFile+' Dest: '+saFilename,'',SOURCEFILE);
      ////  DBM_RenderHtmlErrorPage(p_Context);
      ////end;
    end;
    //------------------------------------------------ Save Imported File
    if bOk then
    begin
      p_Context.saPage:=saGetPage(p_Context, '','sys_page_fileupload','FILEUPLOADCOMPLETE',false,201204291128);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@FILE@]',saOrigfilename);
      //p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PATH@]',saRightStr(saFilename,length(safilename)-length(garJVHost[p_Context.u2VHost].VHost_FileDir)));

      sa:=saFilename;
      {$IFDEF WINDOWS}
      sa:=saSNRStr(sa,'\','[SLASH]');
      sa:=saSNRStr(sa,'[SLASH]','\\');
      {$ENDIF}

      //if rightstr(sa,1)=DOSSLASH then sa:=leftstr(sa,length(sa)-1);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@PATH@]',sa);
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@SIZE@]',inttostr(u8FileSize));
    end;
  end;
  p_Context.bNoWebCache:=true;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201204291126,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



























//=============================================================================
{}
// This function is for downloading files from the file repository and it
// takes permissions and ownership into consideration. Ownership first,
// if the user is not the Owner (Created By) then the user must have the
// permission assigned to the file. If they do not have the permission,
// or the permission is NULL or ZERO - then access is denied.
procedure FileDownload(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  saFilename: ansistring;
 // sa: ansistring;

  u2IOResult: word;
  saFileData: ansistring;

  rJFile: rtJFile;
  sMimeType: string;

  DBC: JADO_CONNECTION;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='FileDownload(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204291434,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204291435, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=p_Context.bSessionValid;
  DBC:=p_Context.VHDBC;
  if not bOk then
  begin
    JAS_Log(p_Context, cnLog_Error,201204021310, 'Unable to comply - session is not valid.','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnPerm_API_FileDownload);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201608241459,
        'You are not authorized to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=p_Context.CGIENV.DataIn.FoundItem_saName('UID');
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error,201204291437, 'File UID not Supplied.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    clear_JFile(rJfile);
    rJFile.JFile_JFile_UID:=u8Val(p_Context.CGIENV.DataIn.Item_saValue);
    bOk:=bJAS_Load_JFile(p_Context, DBC, rJFile, false, 201608300038);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error,201204291438, 'Record not found.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=(rJFile.JFile_CreatedBy_JUser_ID=p_Context.rJUser.JUser_JUser_UID) OR
       (bJAS_HasPermission(p_Context,rJFile.JFile_JSecPerm_ID));
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error,201611070101, 'Access Denied','Missing Permission: '+inttostr(rJFile.JFile_JSecPerm_ID),SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin // path means file here
    //bOk:=FileExistsInTree(
    //  rJFile.JFile_Path, //p_saMakeTreeWithThis: ansistring;  // Can be filename or your own string to create nested dir
    //  rJFile.JFile_Path, //p_saFilename: ansiString;
    //  saFixSlash(garJVHost[p_Context.u2VHost].VHost_FileDir),// p_saTreeTop: ansiString;
    //  sa, // Var p_saRelPath: ansiString;
    //  2, //p_u1Size: byte;
    //  3 //p_u1Levels: byte
    //  );
    //if not bOk then
    //begin
    //  JAS_Log(p_Context, cnLog_Error,201607212040, 'File not found in tree. Path:'+garJVHost[p_Context.u2VHost].VHost_FileDir+' File:'+rJFile.JFile_Path,'',SOURCEFILE);
    //  DBM_RenderHtmlErrorPage(p_Context);
    //end;
  end;

  if bOk then
  begin
    ////saFilename:=saFixSlash(garJVHost[p_Context.u2VHost].VHost_FileDir+rJFile.JFile_Path);
    //saFilename:=sa+rJFile.JFile_Path;
    saFilename:=garJVHost[p_Context.u2VHost].VHost_FileDir+saFileToTreeDOS(rJFile.JFile_Path,2,3)+rJFile.JFile_Name;//in api ug_common.pp
    saFilename:=saFixSlash(saFilename);
    //bOk:=FileExists(saFilename);
    bOK:=FileExists(rJFile.JFile_Path);
    saFilename:=rJFile.JFile_Path;
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204291439, 'File not Found.',
        'saFilename: '+saFilename+' Path:'+garJVHost[p_Context.u2VHost].VHost_FileDir+' File:'+rJFile.JFile_Path,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    bOk:=bTSLoadEntireFile(saFilename,u2IOResult, saFileData);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201204291440, 'Trouble loading file.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    sMimeType:='application/force-download';
    //=========================================== HEADER
    p_Context.CGIENV.uHttpResponse:=cnHTTP_RESPONSE_200;
    p_Context.CGIENV.HEADER.MoveFirst;
    p_Context.CGIENV.HEADER.InsertItem_saName_N_saValue(csCGI_HTTP_HDR_VERSION,p_Context.CGIENV.saHttpResponse);
    p_Context.CGIENV.HEADER.AppendItem_saName_N_saValue(csINET_HDR_SERVER,p_Context.CGIENV.saServerSoftware);
    p_Context.CGIENV.Header_Date;
    p_Context.CGIENV.HEADER.AppendItem_saName_N_saValue(csINET_HDR_CONTENT_TYPE,sMimeType);
    //header('Content-Type: text/csv; charset=utf-8');
    //header('Content-Disposition: data.csv');
    p_Context.CGIENV.HEADER.AppendItem_saName_N_saValue('Content-Disposition: ','attachment; filename="'+rJFile.JFile_Name+'"');
    //p_Context.CGIENV.Header_Cook ies(garJVHost[p_Context.u2VHost].VHost_ServerIdent);
    //=========================================== HEADER
    p_Context.sMimeType:=sMimeType;
    p_Context.saPage:=saFileData;
  end;
  p_Context.bOutputRaw:=true;
  p_Context.bNoWebCache:=true;

  // The user is getting their desired file - and this error isn't their problem that mmight happen
  //next: Going to update the downloads file count and update the jfile record.
  if bOk then
  begin
    rJFile.JFile_Downloads+=1;
    bJAS_Save_jfile(p_Context,DBC,rJFile,false,false, 201611070137);
  end;


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201204291126,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================































//=============================================================================
{}
function bPreDel_JBlok(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JBlok';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205302130,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205302131, sTHIS_ROUTINE_NAME);{$ENDIF}
  rs:=JADO_RECORDSET.Create;
  saQry:='select JBlkF_JBlokField_UID from jblokfield where JBlkF_JBlok_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+' AND JBlkF_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.open(saQry, p_TGT,201503161268);
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201203261233,'Trouble with Query.','Query: '+saQry, SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (not rs.eol) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jblokfield',u8Val(rs.fields.Get_saValue('JBlkF_JBlokField_UID')));
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error,201203261232,'Trouble deleting JBlokField.','', SOURCEFILE);
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  if bOk then
  begin
    saQry:='select JBlkB_JBlokButton_UID from jblokbutton where JBlkB_JBlok_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+' AND JBlkB_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
    bOk:=rs.open(saQry, p_TGT,201503161269);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201203261249,'Trouble with Query.','Query: '+saQry, SOURCEFILE,p_TGT,rs);
    end;
    if bOk and (not rs.eol) then
    begin
      repeat
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jblokbutton',u8Val(rs.fields.Get_saValue('JBlkB_JBlokButton_UID')));
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error,201203261234,'Trouble deleting JBlokButton.','', SOURCEFILE);
        end;
      until (not bOk) or (not rs.movenext);
    end;
    rs.close;
  end;

  if bOk then
  begin
    saQry:='select JFtSa_JFilterSave_UID from jfiltersave where JFtSa_JBlok_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+' AND JFtSa_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
    bOk:=rs.open(saQry, p_TGT,201503161270);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201205310123,'Trouble with Query.','Query: '+saQry, SOURCEFILE,p_TGT,rs);
    end;
    if bOk and (not rs.eol) then
    begin
      repeat
        bOk:=bPreDel_JFilterSave(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JFtSa_JFilterSave_UID')));
        if bOk then
        begin
          bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jfiltersave',u8Val(rs.fields.Get_saValue('JFtSa_JFilterSave_UID')));
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error,201205310124,'Trouble deleting jfiltersave record.','', SOURCEFILE);
          end;
        end;
      until (not bOk) or (not rs.movenext);
    end;
    rs.close;
  end;
  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205302132,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
















//=============================================================================
{}
function bPreDel_JCase(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JCase';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205302252,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205302253, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  saQry:='select JTask_JTask_UID from jtask where JTask_Related_JTable_ID=10 AND JTask_Related_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JTask_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161272);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205302254,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JTask(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JTask_JTask_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jtask',u8Val(rs.Fields.Get_saValue('JTask_JTask_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;


  saQry:='select JNote_JNote_UID from jnote where JNote_JTable_ID=10 AND JNote_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JNote_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161273);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205302256,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jnote',u8Val(rs.Fields.Get_saValue('JNote_JNote_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;



  saQry:='select JFile_JFile_UID from jfile where JFile_JTable_ID=10 AND JFile_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JFile_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161274);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205302257,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JFile(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jfile',u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205302255,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================











//=============================================================================
{}
function bPreDel_JTask(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JTask';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205302304,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205302305, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  saQry:='select TMCD_TimeCard_UID from jtimecard where TMCD_JTask_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND TMCD_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161275);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205302306,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jtimecard',u8Val(rs.Fields.Get_saValue('TMCD_TimeCard_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;


  saQry:='select JNote_JNote_UID from jnote where JNote_JTable_ID=121 AND JNote_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JNote_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161276);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205302307,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jnote',u8Val(rs.Fields.Get_saValue('JNote_JNote_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;



  saQry:='select JFile_JFile_UID from jfile where JFile_JTable_ID=121 AND JFile_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JFile_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161277);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205302308,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JFile(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jfile',u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205302309,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
{}
function bPreDel_JFile(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  rJFile: rtJFile;
  saFileName: ansistring;
  saNewName: ansistring;
  sarev: ansistring;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JTask';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205302304,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205302305, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  clear_jfile(rJFile);
  rJFile.JFile_JFile_UID:=p_u8UID;

  writeln('uj_dbtools - TGT.ID: ' , p_TGT.ID);

  bOk:=bJAS_Load_JFile(p_Context, p_TGT, rJFile, false, 201608300039);
  if bOk then
  begin
    saFilename:=garJVHost[p_Context.u2VHost].VHost_FileDir+rJFile.JFile_Path;
    saNewName:='.'+ExtractFileName(safilename);
    sarev:=saReverse(safilename);
    saNewName:=sareverse(saRightStr(saRev, length(sarev)-pos(DOSSLASH,saRev)))+DOSSLASH+saNewName;
    //JAS_Log(p_Context, nLog_Debug,201205302343,'safilename: ' + saFilename+' New Name: '+saNewName,'',SOURCEFILE);

    //riteln('uj_dbtools - safilename: ' + saFilename+' New Name: '+saNewName);
    bMovefile(saFilename, saNewName);
    //riteln('uj_dbtools - past actual bMoveFile call');
  end;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205302309,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================













//=============================================================================
{}
function bPreDel_JOrg(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JOrg';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310004,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310005, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  // NOTES
  saQry:='select JNote_JNote_UID from jnote where JNote_JTable_ID=23 AND JNote_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JNote_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161278);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310006,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jnote',u8Val(rs.Fields.Get_saValue('JNote_JNote_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // FILES
  saQry:='select JFile_JFile_UID from jfile where JFile_JTable_ID=23 AND JFile_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JFile_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161279);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310007,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JFile(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jfile',u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // TASKS
  saQry:='select JTask_JTask_UID from jtask where JTask_Related_JTable_ID=23 AND JTask_Related_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JTask_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161280);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310008,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JTask(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JTask_JTask_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jtask',u8Val(rs.Fields.Get_saValue('JTask_JTask_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // MEMBERS
  saQry:='select JCpyP_JOrgPers_UID from jorgpers where JCpyP_JOrg_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JCpyP_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161281);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310009,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jorgpers',u8Val(rs.Fields.Get_saValue('JCpyP_JOrgPers_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;


  // PROJECTS
  saQry:='select JProj_JProject_UID from jproject where JProj_JOrg_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JProj_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161282);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310010,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JProject(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JProj_JProject_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jproject',u8Val(rs.Fields.Get_saValue('JProj_JProject_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310008,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
























//=============================================================================
{}
function bPreDel_JFilterSave(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JFilterSave';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310056,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310057, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  // NOTES
  saQry:='select JFtSD_JFilterSaveDef_UID from jfiltersavedef where JFtSD_JFilterSave_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JFtSD_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161283);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310058,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jfiltersavedef',u8Val(rs.Fields.Get_saValue('JFtSD_JFilterSaveDef_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310103,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================











//=============================================================================
{}
function bPreDel_JIconContext(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JIconContext';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310129,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310130, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  saQry:='select IHMA_JIconMaster_UID from jiconmaster where IHMA_JIconContext_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND IHMA_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161284);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310131,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jiconmaster',u8Val(rs.Fields.Get_saValue('IHMA_JIconMaster_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310132,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================










//=============================================================================
{}
function bPreDel_JInvoice(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JInvoice';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310133,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310134, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  saQry:='select JILin_JInvoiceLines_UID from jinvoicelines where JILin_JInvoice_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JILin_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161285);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310134,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jinvoicelines',u8Val(rs.Fields.Get_saValue('JILin_JInvoiceLines_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310135,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
{}
function bPreDel_JLead(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JOrg';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310136,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310137, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  // NOTES
  saQry:='select JNote_JNote_UID from jnote where JNote_JTable_ID=36 AND JNote_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JNote_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161286);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310138,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jnote',u8Val(rs.Fields.Get_saValue('JNote_JNote_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // FILES
  saQry:='select JFile_JFile_UID from jfile where JFile_JTable_ID=36 AND JFile_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JFile_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161287);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310139,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JFile(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jfile',u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // TASKS
  saQry:='select JTask_JTask_UID from jtask where JTask_Related_JTable_ID=36 AND JTask_Related_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JTask_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161288);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310140,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JTask(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JTask_JTask_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jtask',u8Val(rs.Fields.Get_saValue('JTask_JTask_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310143,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
















//=============================================================================
{}
function bPreDel_JInstalled(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JInstalled';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310144,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310145, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  saQry:='select JMCfg_JModuleConfig_UID from jmoduleconfig where JMCfg_JInstalled_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND 	JMCfg_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161289);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310146,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jmoduleconfig',u8Val(rs.Fields.Get_saValue('JMCfg_JModuleConfig_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310147,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
{}
function bPreDel_JModuleSetting(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JModuleSetting';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310148,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310149, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=bPreDel_JInstalled(p_Context,p_TGT,p_u8UID);
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310151,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
{}
function bPreDel_JModule(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JModule';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310152,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310153, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  // JInstalled
  saQry:='select JInst_JInstalled_UID from jinstalled WHERE JInst_JModule_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JInst_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161290);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310155,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JInstalled(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JInst_JInstalled_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jinstalled',u8Val(rs.Fields.Get_saValue('JInst_JInstalled_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // JModuleSetting
  saQry:='select JMSet_JModuleSetting_UID from jmodulesetting where JMSet_JModule_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JMSet_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161291);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310156,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JTask(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JMSet_JModuleSetting_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jmodulesetting',u8Val(rs.Fields.Get_saValue('JMSet_JModuleSetting_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310157,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
















//=============================================================================
{}
function bPreDel_JPerson(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JPerson';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310158,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310159, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  // NOTES
  saQry:='select JNote_JNote_UID from jnote where JNote_JTable_ID=44 AND JNote_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JNote_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161292);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310200,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jnote',u8Val(rs.Fields.Get_saValue('JNote_JNote_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // FILES
  saQry:='select JFile_JFile_UID from jfile where JFile_JTable_ID=44 AND JFile_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JFile_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161293);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310201,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JFile(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jfile',u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // TASKS
  saQry:='select JTask_JTask_UID from jtask where JTask_Related_JTable_ID=44 AND JTask_Related_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JTask_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161294);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310202,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JTask(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JTask_JTask_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jtask',u8Val(rs.Fields.Get_saValue('JTask_JTask_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // MEMBERS
  saQry:='select JCpyP_JOrgPers_UID from jorgpers where JCpyP_JPerson_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JCpyP_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161295);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310203,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jorgpers',u8Val(rs.Fields.Get_saValue('JCpyP_JOrgPers_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;


  // projects
  saQry:='select JProj_JProject_UID from jproject where JProj_JPerson_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JProj_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161296);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310204,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JProject(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JProj_JProject_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jproject',u8Val(rs.Fields.Get_saValue('JProj_JProject_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;



  // skillset
  saQry:='select JPSki_JPersonSkill_UID from jpersonskill where JPSki_JPerson_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JPSki_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161297);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310206,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jpersonskill',u8Val(rs.Fields.Get_saValue('JPSki_JPersonSkill_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310205,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================













//=============================================================================
{}
function bPreDel_JProject(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JProject';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310942,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310943, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  // NOTES
  saQry:='select JNote_JNote_UID from jnote where JNote_JTable_ID=107 AND JNote_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JNote_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161298);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310944,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jnote',u8Val(rs.Fields.Get_saValue('JNote_JNote_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // FILES
  saQry:='select JFile_JFile_UID from jfile where JFile_JTable_ID=107 AND JFile_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JFile_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161299);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310945,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JFile(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jfile',u8Val(rs.Fields.Get_saValue('JFile_JFile_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // TASKS
  saQry:='select JTask_JTask_UID from jtask where JTask_Related_JTable_ID=107 AND JTask_Related_Row_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JTask_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161300);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310946,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JTask(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JTask_JTask_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jtask',u8Val(rs.Fields.Get_saValue('JTask_JTask_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // TIMECARD
  saQry:='select TMCD_TimeCard_UID from jtimecard where TMCD_JProject_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND TMCD_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161301);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310946,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jtimecard',u8Val(rs.Fields.Get_saValue('TMCD_TimeCard_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;


  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310947,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================














//=============================================================================
{}
function bPreDel_JProduct(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JProduct';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310948,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310949, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  // Product Qty
  saQry:='select JPrdQ_JProductQty_UID from jproductqty where JPrdQ_JProduct_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JPrdQ_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161302);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310950,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jproductqty',u8Val(rs.Fields.Get_saValue('JPrdQ_JProductQty_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310951,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================










//=============================================================================
{}
function bPreDel_JScreen(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs,rs2: JADO_RECORDSET;
  rJBlok: rtJBLok;
  rJBlokField: rtJBlokField;
  rJBlokButton: rtJBlokButton;
  DBC: JADO_CONNECTION;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JScreen';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205302133,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205302134, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;

  saQry:='select JBlok_JBlok_UID from jblok where ((JBlok_Deleted_b = '+
    DBC.sDBMSBoolScrub(false)+') or (JBlok_Deleted_b is NULL)) AND '+
    '(JBlok_JScreen_ID = '+DBC.sDBMSUIntScrub(p_u8UID)+' )';

  //writeln('bPreDel_JScreen - ');
  //writeln('bPreDel_JScreen - saQry: '+saQry);

  bOk:=rs.open(saQry, DBC,201503161196);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201209031340,'JAS_DeleteScreen - Trouble '+
      'with query on jblok table. JScrn_JScreen_UID: '+inttostr(p_u8UID),'',SOURCEFILE);
  end;


  //riteln('bPreDel_JScreen - A bOk: '+sYesNo(bOk));

  if bOk then
  begin
    if not rs.eol then
    begin
      //riteln('bPreDel_JScreen - B');
      repeat
        //riteln('bPreDel_JScreen - C');

        clear_jblok(rJBlok);
        rJBlok.JBlok_JBlok_UID:=u8Val(rs.fields.get_saValue('JBlok_JBlok_UID'));
        bOk:=bJAS_Load_JBlok(p_Context, DBC, rJBlok, true, 201608300040);
        //if not bOk then
        //begin
        //  JAS_Log(p_Context,cnLog_Error,201608141104,'bPreDel_JScreen - Failed to delete child records '+
        //    'for this screen.','JScrn_JScreen_UID: '+inttostr(p_u8UID)+' Context err code: '+
        //    inttostr(p_Context.u8ErrNo)+' Context Err Message: '+p_Context.saErrMsg,SOURCEFILE);
        //end;
          //riteln('bPreDel_JScreen - D');

        //------------------------ JBLOKFIELD -------------------------------------------
        if bOk then
        begin
          saQry:='select JBlkF_JBlokField_UID from jblokfield where ((JBlkF_Deleted_b='+
            DBC.sDBMSBoolScrub(false)+
            ') or (JBlkF_Deleted_b is NULL)) and (JBlkF_JBlok_ID='+
            DBC.sDBMSUIntScrub(rJBlok.JBlok_JBlok_UID)+')';
          bOk:=rs2.open(saQry, DBC,201503161197);
          if not bOk then
          begin
            JAS_Log(p_Context,cnLog_Error,201209031346,'JAS_DeleteScreen - '+
              'Trouble with query on jblokfield table. JScrn_JScreen_UID: '+
              inttostr(p_u8UID),'',SOURCEFILE);
          end;

          if not rs2.eol then
          begin
            repeat
              clear_jblokfield(rJBlokField);
              rJBlokField.JBlkF_JBlokField_UID:=u8Val(rs2.fields.Get_saValue('JBlkF_JBlokField_UID'));
              bOk:=bJAS_LockRecord(p_Context, DBC.ID, 'jblokfield',rJBlokField.JBlkF_JBlokField_UID,0,201501011024);
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error,201209031353,'JAS_DeleteScreen - Unable to lock JBlokField record. JBlkF_JBlokField_UID: '+inttostr(rJBlokField.JBlkF_JBlokField_UID),'',SOURCEFILE);
              end;

              if bOk then
              begin
                bOk:=bJAS_DeleteRecord(p_Context, DBC, 'jblokfield', rJBlokField.JBlkF_JBlokField_UID);
                if not bOk then
                begin
                  JAS_Log(p_Context,cnLog_Error,201209031356,'JAS_DeleteScreen - Unable to delete JBlokField record. JBlkF_JBlokField_UID: '+inttostr(rJBlokField.JBlkF_JBlokField_UID),'',SOURCEFILE);
                end;
                bJAS_UnLockRecord(p_Context, DBC.ID, 'jblokfield',rJBlokField.JBlkF_JBlokField_UID,0,201501011025);
              end;
            until (not bOk) or (not rs2.movenext);
          end;
          rs2.close;
        end;
        //------------------------ JBLOKFIELD -------------------------------------------


        //riteln('bPreDel_JScreen - E');


        //------------------------ JBLOKBUTTON -------------------------------------------
        if bOk then
        begin
          saQry:='select JBlkB_JBlokButton_UID from jblokbutton where ((JBlkB_Deleted_b='+
            DBC.sDBMSBoolScrub(false)+') or (JBlkB_Deleted_b is NULL)) and (JBlkB_JBlok_ID='+
            DBC.sDBMSUIntScrub(rJBlok.JBlok_JBlok_UID)+')';
          bOk:=rs2.open(saQry, DBC,201503161198);
          if not bOk then
          begin
            JAS_Log(p_Context,cnLog_Error,201209031412,'JAS_DeleteScreen - Trouble with query on jblokbutton table. JScrn_JScreen_UID: '+inttostr(p_u8UID),'',SOURCEFILE);
          end;

          if not rs2.eol then
          begin
            repeat
              clear_jblokbutton(rJBlokButton);
              rJBlokButton.JBlkB_JBlokButton_UID:=u8Val(rs2.fields.Get_saValue('JBlkB_JBlokButton_UID'));
              bOk:=bJAS_LockRecord(p_Context, DBC.ID, 'jblokbutton',rJBlokButton.JBlkB_JBlokButton_UID,0,201501011026);
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error,201209031413,'JAS_DeleteScreen - Unable to lock JBlokButton record. JBlkB_JBlokButton_UID: '+inttostr(rJBlokButton.JBlkB_JBlokButton_UID),'',SOURCEFILE);
              end;

              if bOk then
              begin
                bOk:=bJAS_DeleteRecord(p_Context, DBC, 'jblokbutton', rJBlokButton.JBlkB_JBlokButton_UID);
                if not bOk then
                begin
                  JAS_Log(p_Context,cnLog_Error,201209031414,'JAS_DeleteScreen - Unable to delete JBlokButton record. JBlkB_JBlokButton_UID: '+inttostr(rJBlokButton.JBlkB_JBlokButton_UID),'',SOURCEFILE);
                end;
                bJAS_UnLockRecord(p_Context, DBC.ID, 'jblokbutton',rJBlokButton.JBlkB_JBlokButton_UID,0,201501011027);
              end;
            until (not bOk) or (not rs2.movenext);
          end;
          rs2.close;
        end;
        //------------------------ JBLOKBUTTON -------------------------------------------


          //riteln('bPreDel_JScreen - F');




        if bOk then
        begin
          //riteln('bPreDel_JScreen - G');

          bOk:=bJAS_DeleteRecord(p_Context, DBC, 'jblok', rJBlok.JBlok_JBlok_UID);

  //riteln('bPreDel_JScreen - H');

          if not bOk then
          begin
            JAS_Log(p_Context,cnLog_Error,201209031359,'JAS_DeleteScreen - Unable to delete JBlok record. JBlok_JBlok_UID: '+inttostr(rJBlok.JBlok_JBlok_UID),'',SOURCEFILE);
          end;
  //riteln('bPreDel_JScreen - I');
          bJAS_UnLockRecord(p_Context, DBC.ID, 'jblok',rJBlok.JBlok_JBlok_UID,0,201501011028);
        end;
  //riteln('bPreDel_JScreen - J');
      until (not rs.movenext);//writen to glaze over missing children
    end;
  end;
  //riteln('bPreDel_JScreen - DONE');


  rs.destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205302135,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
















//=============================================================================
{}
function bPreDel_JSecGrp(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JSecGrp';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310952,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205310953, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  // JSECGRPLINK
  saQry:='select JSGLk_JSecGrpLink_UID from jsecgrplink where JSGLk_JSecGrp_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JSGLk_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161303);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310954,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jsecgrplink',u8Val(rs.Fields.Get_saValue('JSGLk_JSecGrpLink_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // JSECGRPUSERLINK
  saQry:='select JSGUL_JSecGrpUserLink_UID from jfile where JSGUL_JSecGrp_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JSGUL_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161304);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205310955,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jsecgrpuserlnk',u8Val(rs.Fields.Get_saValue('JSGUL_JSecGrpUserLink_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205310958,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
{}
function bPreDel_JSecPerm(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JSecPerm';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205310959,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205311000, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  // JSecGrpLink
  saQry:='select JSGLk_JSecGrpLink_UID from jsecgrplink where JSGLk_JSecPerm_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND ((JSGLk_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true)+')OR(JSGLk_Deleted_b IS NULL))';
  bOk:=rs.Open(saQry,p_TGT,201503161305);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205311001,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jsecgrplink',u8Val(rs.Fields.Get_saValue('JSGLk_JSecGrpLink_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // JSecPermUserLink
  saQry:='select JSPUL_JSecPermUserLink_UID from jsecpermuserlink where JSPUL_JSecPerm_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND ((JSPUL_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true)+')OR(JSPUL_Deleted_b IS NULL))';
  bOk:=rs.Open(saQry,p_TGT,201503161306);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205311002,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jsecpermuserlnk',u8Val(rs.Fields.Get_saValue('JSPUL_JSecPermUserLink_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205311003,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









//=============================================================================
{}
function bPreDel_JSession(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JSession';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205311004,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205311005, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;

  // JSessionData
  saQry:='select JSDat_JSessionData_UID from jsessiondata where JSDat_JSession_ID='+p_TGT.sDBMSUIntScrub(p_u8UID);
  bOk:=rs.Open(saQry,p_TGT,201503161307);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205311008,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      saQry:='delete from jsessiondata where JSDat_JSessionData_UID='+
        p_TGT.sDBMSUIntScrub(rs.Fields.Get_saValue('JSDat_JSessionData_UID'));
      bOk:=rs2.open(saQry,p_TGT,201503161308);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201205311009,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs2);
      end;
      rs2.close;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  rs2.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205311007,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================














//=============================================================================
{}
function bPreDel_JSysModule(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;

  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JSysModule';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205311010,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205311011, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  // JSysModuleLink
  saQry:=
    'select JSyLk_JSysModuleLink_UID '+
    'FROM jsysmodulelink '+
    'WHERE '+
    '  JSyLk_JSysModule_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+' AND '+
    '  JSyLk_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161309);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205311012,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bPreDel_JSysModuleLink(p_Context,p_TGT, u8Val(rs.Fields.Get_saValue('JSyLk_JSysModuleLink_UID')));
      if bOk then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jsysmodulelink',u8Val(rs.Fields.Get_saValue('JSyLk_JSysModuleLink_UID')));
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205311016,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

























//=============================================================================
{}
function bPreDel_JSysModuleLink(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  u8JTableID: UInt64;
  u8JColumnID: UInt64;
  u8RowID: UInt64;
  u8JScreenID: UInt64;

  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JSysModuleLink';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205311017,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205311018, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;

  // JSysModuleLink
  saQry:=
    'select '+
    '  JSyLk_JDConnection_ID, '+
    '  JSyLk_JTable_ID, '+
    '  JSyLk_JColumn_ID, '+
    '  JSyLk_Row_ID, '+
    '  JSyLk_JScreen_ID '+
    'FROM jsysmodulelink '+
    'WHERE '+
    '  JSyLk_JSysModuleLink_UID='+p_TGT.sDBMSUIntScrub(p_u8UID)+' AND '+
    '  JSyLk_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161310);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205311019,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jsysmodulelink',u8Val(rs.Fields.Get_saValue('JSyLk_JSysModuleLink_UID')));

      if bOk then
      begin
        // REMOVE MODULE MODIFICATIONS TO JAS
        u8JTableID:=u8Val(rs.Fields.Get_saValue('JSyLk_JTable_ID'));
        u8JColumnID:=u8Val(rs.Fields.Get_saValue('JSyLk_JColumn_ID'));
        u8RowID:=u8Val(rs.Fields.Get_saValue('JSyLk_Row_ID'));
        u8JScreenID:=u8Val(rs.Fields.Get_saValue('JSyLk_JScreen_ID'));

        if (u8JTableID>0) then
        begin
          // REMOVE ROW IN SPECIFIED TABLE - NOTE: NO CASCADE DELETE
          if (u8JColumnID=0) and (u8RowID>0) then
          begin
            bOk:=bJAS_DeleteRecord(
              p_Context,
              p_TGT,
              p_TGT.sGetTable(u8Val(rs.Fields.Get_saValue('JSyLk_JTable_ID')),201608191909),
              u8Val(rs.Fields.Get_saValue('JSyLk_Row_ID'))
            );
          end else

          // REMOVE COLUMN FROM JAS JColumn Table
          // AND Clean Up Any SCREEN JBlokFields that USE the Column
          if (u8JColumnID>0) and (u8RowID=0) then
          begin
            bOk:=bJAS_DeleteRecord(p_Context,p_TGT,'jcolumn',u8Val(rs.Fields.Get_saValue('JSyLk_JColumn_ID')));
            if bOk then
            begin
              saQry:='select JBlkF_JBlokField_UID from jblokfield '+
               'WHERE JBlkF_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true)+' AND '+
               'JBlkF_JColumn_ID='+p_TGT.sDBMSUIntScrub(rs.Fields.Get_saValue('JSyLk_JColumn_ID'));
              bOk:=rs2.Open(saQry,p_TGT,201503161311);
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error,201205311620,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs2);
              end;

              if bOk and (rs2.eol=false) then
              begin
                repeat
                  bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jblokfield',u8Val(rs2.Fields.Get_saValue('JBlkF_JBlokField_UID')));
                until (not bOk) or (not rs2.movenext);
              end;
              rs2.close;
            end;
          end else

          // Specific Field Value - do What? Make null I suppose
          if (u8JColumnID>0) and (u8RowID>0) then
          begin
            saQry:='UPDATE '+p_TGT.sGetTable(u8Val(rs.Fields.Get_saValue('JSyLk_JTable_ID')),201608191909)+
              ' SET '+p_TGT.sGetColumnName(u8Val(rs.Fields.Get_saValue('JSyLk_JColumn_ID')),201210020206)+'=NULL '+
              ' WHERE '+p_TGT.sGetPKeyColumnName(p_TGT.sGetTable(u8Val(rs.Fields.Get_saValue('JSyLk_JTable_ID')),201608191910),201210020207)+'='+
                rs.Fields.Get_saValue('JSyLk_Row_ID');
            bOk:=rs2.Open(saQry, p_TGT,201503161312);
            if not bOk then
            begin
              JAS_Log(p_Context,cnLog_Error,201205311621,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs2);
            end;
            rs2.close;
          end else

          // REMOVE TABLE, COLUMNS, SCREENS that use the specified Table.
          // NOTE: NO CASCADE DELETE
          if (u8JColumnID=0) and (u8RowID=0) then
          begin
            bOk:=bPreDel_JTable(p_Context,p_TGT,u8Val(rs.Fields.Get_saValue('JSyLk_JTable_ID')));
            if bOk then
            begin
              bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jtable',u8Val(rs.Fields.Get_saValue('JSyLk_JTable_ID')));
            end;

            if bOk then
            begin
              saQry:='select JBlok_JScreen_ID FROM jblok WHERE JBlok_JTable_ID='+
                p_TGT.sDBMSUIntScrub(rs.Fields.Get_saValue('JSyLk_JTable_ID'))+' AND '+
                'JBlok_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
              bOk:=rs2.Open(saQry, p_TGT,201503161313);
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error,201205311622,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs2);
              end;

              if bOk and (rs2.eol=false) then
              begin
                bOk:=bPreDel_JScreen(p_Context,p_TGT,u8Val(rs2.Fields.Get_saValue('JBlok_JScreen_ID')));
                if bOk then
                begin
                  bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jscreen',u8Val(rs2.Fields.Get_saValue('JBlok_JScreen_ID')));
                end;
              end;
              rs2.close;
            end;
          end;
        end else

        if (u8JScreenID>0) then
        begin
          bOk:=bPreDel_JScreen(p_Context,p_TGT,u8Val(rs.Fields.Get_saValue('JSyLk_JScreen_ID')));
          if bOk then
          begin
            bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jscreen',u8Val(rs.Fields.Get_saValue('JSyLk_JScreen_ID')));
          end;
        end;
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  rs2.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205311023,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================










//=============================================================================
{}
function bPreDel_JTable(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JTable';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205311024,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205311025, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  saQry:='select JColu_JColumn_UID from jcolumn where JColu_JTable_ID='+p_TGT.sDBMSUIntScrub(p_u8UID);
  bOk:=rs.Open(saQry,p_TGT,201503161314);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205311026,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jcolumn',u8Val(rs.Fields.Get_saValue('JColu_JColumn_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205311028,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================











//=============================================================================
{}
function bPreDel_JTeam(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JTeam';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205311029,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205311030, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  //
  saQry:='select JTMem_JTeamMember_UID from jteammember where JTMem_JTeam_ID='+p_TGT.sDBMSUIntScrub(p_u8UID);
  bOk:=rs.Open(saQry,p_TGT,201503161315);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205311031,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jteammember',u8Val(rs.Fields.Get_saValue('JTMem_JTeamMember_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205311032,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
{}
function bPreDel_JUser(p_Context: TCONTEXT; p_TGT: JADO_CONNECTION; p_u8UID: uint64): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bPreDel_JOrg';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201205311033,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201205311034, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  rs:=JADO_RECORDSET.Create;

  // juserpreflink
  saQry:='select UsrPL_UserPrefLink_UID from juserpreflink where UsrPL_User_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND UsrPL_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161316);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205311035,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'juserpreflink',u8Val(rs.Fields.Get_saValue('UsrPL_UserPrefLink_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // 	jsecgrpuserlink
  saQry:='select JSGUL_JSecGrpUserLink_UID from jsecgrpuserlink where JSGUL_JUser_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JSGUL_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161317);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205311036,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jsecgrpuserlink',u8Val(rs.Fields.Get_saValue('JSGUL_JSecGrpUserLink_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  // jsecpermuserlink
  saQry:='select JSPUL_JSecPermUserLink_UID from jsecpermuserlink where JSPUL_JUser_ID='+p_TGT.sDBMSUIntScrub(p_u8UID)+
    ' AND JSPUL_Deleted_b<>'+p_TGT.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry,p_TGT,201503161318);
  if not bOk then
  begin
    JAS_Log(p_Context,cnLog_Error,201205311037,'Trouble with Query','Query: ' + saQry,SOURCEFILE,p_TGT,rs);
  end;

  if bOk and (rs.eol=false) then
  begin
    repeat
      bOk:=bJAS_DeleteRecord(p_Context,p_TGT, 'jsecpermuserlink',u8Val(rs.Fields.Get_saValue('JSPUL_JSecPermUserLink_UID')));
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  rs.Destroy;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201205311040,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
{}
// This tool allows you to point to a connected database connection and select
// one or more tables and submit your selection. Once submitted this function
// will add table records and column records into JAS' meta data allowing you
// to later view them, and make screens for them from the JTable Search
// screen or from the record/detail view of any one of those tables.
procedure DBM_LearnTables(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  TGT: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  //rs2: JADO_RECORDSET;
  //bOrphan: boolean;
  sa: ansistring;
  rJTable: rtJTable;
  rJColumn: rtJColumn;
  //saPKey: ansistring;
  //bNoRecords: boolean;
  //iRecords: longint;
  sTable: string;
  u8TablesAdded: uint64;
  u8ColumnsAdded: uint64;
  saDSN: ansistring;
  i: longint;
  XDL: JFC_XDL;
  bUnsigned: boolean;
  u8JDType: word;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_LearnTables';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102747,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102748, sTHIS_ROUTINE_NAME);{$ENDIF}
  XDL:=JFC_XDL.Create;
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  u8TablesAdded:=0;
  u8ColumnsAdded:=0;

  p_Context.bNoWebCache:=true;

  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,201210020304,'Session is not valid. You need to be logged in and have permission to access this resource.','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  End;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context, cnPerm_API_LearnTables);
    if not bOk then
    begin
      JAS_Log(p_Context, cnLog_Error,201210020305,
        '"Database Maintenance" - ACCESS DENIED - You do not have permission '+
        '"Database Maintenance" required to perform this action.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk then
  begin
    if p_Context.CGIENV.DataIn.FoundItem_saName('TABLES') then
    begin
      if bOk then
      begin
        bOk:=p_Context.CGIENV.DataIn.MoveFirst;
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201010020311, 'No Database connection or table(s) selected.','',SOURCEFILE);
          DBM_RenderHtmlErrorPage(p_Context);
        end;
      end;

      if bOk then
      begin
        repeat
          // FORMAT FOR INCOMING TABLES: DSNID - tablename
          // PARSE OUT DSN AND TABLE
          if p_Context.CGIENV.DataIn.Item_saName='TABLES' then
          begin
            sa:=p_Context.CGIENV.DataIn.Item_saValue;
            saDSN:=trim(saLeftStr(sa,pos('-',sa)-2));
            TGT:=p_Context.DBCON(saDSN,201610312256);
            bOk:=TGT<>nil;
            if not bOk then
            begin
              JAS_LOG(p_Context, cnLog_Error, 201010020310, 'sa: '+sa+' DSN: ' + saDSN + ' Invalid Database Connection Received. Unable to proceed.','',SOURCEFILE);
              DBM_RenderHtmlErrorPage(p_Context);
            end;

            if not bJAS_HasPermission(p_Context, TGT.JDCon_JSecPerm_ID) then
            begin
              JAS_LOG(p_Context, cnLog_Error, 201210152320, 'sa: '+sa+' DSN: ' + saDSN + ' Access Denied. Unable to proceed.','',SOURCEFILE);
              DBM_RenderHtmlErrorPage(p_Context);
            end;

            if bOk then
            begin
              sTable:=trim(saRightStr(sa, length(sa)-(pos('-',sa)+1)));
              // GATHER TABLE INFO HERE AND Create row
              clear_JTable(rJTable);
              with rJTable do begin
                JTabl_JTable_UID          :=0;
                JTabl_Name                :=sTable;
                JTabl_Desc                :='Added to system by "Learn Tables" utility.';
                JTabl_JTableType_ID       :=1;//TABLE - because unknown if table or view here
                JTabl_JDConnection_ID     := TGT.ID;
                JTabl_ColumnPrefix        := '';// unknown - need to be entered manually or code to try and figure it out
                JTabl_DupeScore_u         := 0;
                JTabl_Perm_JColumn_ID     := 0;
                JTabl_Owner_Only_b        := false;
                JAS_Row_b                 := false;
              end;
              //ASPrint('SAVING TABLE ----------------------------');
              bOk:=bJAS_Save_JTable(p_Context,TGT, rJTable,false,false, 201608300041);
              //ASPrintln('DONE. Ok: '+sTrueFalse(bOk));
              if not bOk then
              begin
                JAS_LOG(p_Context, cnLog_Error, 201010020504, 'Unable to save table: '+sTable+' Table might already exist.','',SOURCEFILE);
                DBM_RenderHtmlErrorPage(p_Context);
              end;

              if bOk then
              begin
                u8TablesAdded+=1;
              end;

              if bOk then
              begin
                // Gather Columns Info and Makes columns in JAS HERE================================================================================================================BEGIN
                saQry:=
                  'SELECT * '+
                  'FROM INFORMATION_SCHEMA.COLUMNS '+
                  'WHERE TABLE_SCHEMA='''+DBC.saMyDatabase+''' AND TABLE_NAME= '+DBC.saDBMSScrub(sTable)+' '+
                  'ORDER BY TABLE_NAME, ORDINAL_POSITION';
                bOk:=rs.open(saQry, DBC,201503161310);
                if not bOk then
                begin
                  JAS_LOG(p_Context, cnLog_Error, 201010020511, 'Trouble Querying Information Schema','Query:'+saQry,SOURCEFILE, DBC, rs);
                  DBM_RenderHtmlErrorPage(p_Context);
                end;

                if bOk then
                begin
                  repeat
                    //ASPrintln('Column Loop: '+inttostr(u8ColumnsAdded+1));
                    if not rs.eol then
                    begin
                      clear_jcolumn(rJColumn);

                      //-------------------------------------------------------------------------Begin Figuring out Jegas Data Type
                      u8JDType:=cnJDType_Unknown;

                      rJColumn.JColu_DefinedSize_u         :=u8Val(rs.fields.Get_saValue('CHARACTER_MAXIMUM_LENGTH'));
                      rJColumn.JColu_NumericScale_u        :=u8Val(rs.fields.Get_saValue('NUMERIC_SCALE'));
                      rJColumn.JColu_Precision_u           :=u8Val(rs.fields.Get_saValue('NUMERIC_PRECISION'));
                      if (rs.fields.Get_saValue('DATA_TYPE')='tinytext') or
                        (rs.fields.Get_saValue('DATA_TYPE')='text') or
                        (rs.fields.Get_saValue('DATA_TYPE')='mediumtext') or
                        (rs.fields.Get_saValue('DATA_TYPE')='longtext') then
                      begin
                        //if rs.fields.Get_saValue('CHARACTER_SET_NAME')='utf8' then
                        u8JDType:=cnJDType_sn;
                      end else

                      bUnsigned:=(saRightStr(rs.fields.Get_saValue('COLUMN_TYPE'),7)='unsigned');
                      if rs.fields.Get_saValue('DATA_TYPE')='tinyint' then
                      begin
                        if bUnsigned then u8JDType:=cnJDType_i1 else u8JDType:=cnJDType_u1;
                        rJColumn.JColu_DefinedSize_u:=1;
                        if rJColumn.JColu_Boolean_b then u8JDType:=cnJDType_b;
                      end else

                      if rs.fields.Get_saValue('DATA_TYPE')='smallint' then
                      begin
                        if bUnsigned then u8JDType:=cnJDType_i2 else u8JDType:=cnJDType_u2;
                        rJColumn.JColu_DefinedSize_u:=2;
                      end else

                      if rs.fields.Get_saValue('DATA_TYPE')='int' then
                      begin
                        if bUnsigned then u8JDType:=cnJDType_i4 else u8JDType:=cnJDType_u4;
                        rJColumn.JColu_DefinedSize_u:=4;
                      end else

                      if rs.fields.Get_saValue('DATA_TYPE')='bigint' then
                      begin
                        if bUnsigned then u8JDType:=cnJDType_i8 else u8JDType:=cnJDType_u8;
                        rJColumn.JColu_DefinedSize_u:=8;
                      end else

                      if (rs.fields.Get_saValue('DATA_TYPE')='double') or
                        (rs.fields.Get_saValue('DATA_TYPE')='single') or
                        (rs.fields.Get_saValue('DATA_TYPE')='real') or
                        (rs.fields.Get_saValue('DATA_TYPE')='float') then
                      begin
                        u8JDType:=cnJDType_fp;
                      end else


                      if (rs.fields.Get_saValue('DATA_TYPE')='decimal') or
                        (rs.fields.Get_saValue('DATA_TYPE')='numeric') then
                      begin
                        u8JDType:=cnJDType_fd;
                      end else

                      if (rs.fields.Get_saValue('DATA_TYPE')='char') or
                        (rs.fields.Get_saValue('DATA_TYPE')='varchar') then
                      begin
                        if iVal(rs.fields.Get_saValue('CHARACTER_MAXIMUM_LENGTH'))=1 then
                        begin
                          u8JDType:=cnJDType_ch;
                        end
                        else
                        begin
                          u8JDType:=cnJDType_s;
                        end;
                      end else

                      //if (rs.fields.Get_saValue('DATA_TYPE')='tinyint') then
                      //begin
                      //  Const cnJDType_b        = 20; //< Jegas Data Type - Boolean - Byte  b
                      //  Const cnJDType_bi1      = 21; //< Jegas Data Type - Boolean - Boolean Integer - 1 Byte - >Zero=true bi1
                      //end;

                      if (rs.fields.Get_saValue('DATA_TYPE')='datetime') then
                      begin
                        u8JDType:=cnJDType_dt;
                      end else

                      if (rs.fields.Get_saValue('DATA_TYPE')='tinyblob') or
                        (rs.fields.Get_saValue('DATA_TYPE')='blob') or
                        (rs.fields.Get_saValue('DATA_TYPE')='mediumblob') or
                        (rs.fields.Get_saValue('DATA_TYPE')='longblob') then
                      begin
                        u8JDType:=cnJDType_bin;
                      end;
                      //-------------------------------------------------------------------------END Figuring out Jegas Data Type
                      rJColumn.JColu_JDType_ID            := u8JDType;
                      rJColumn.JColu_AllowNulls_b         := bVal(rs.Fields.Get_saValue('IS_NULLABLE'));
                      rJColumn.JColu_DefaultValue         := rs.fields.Get_saValue('COLUMN_DEFAULT');
                      rJColumn.JColu_PrimaryKey_b         := rs.fields.Get_saValue('COLUMN_KEY')='PRI';
                      rJColumn.JColu_AutoIncrement_b      := saLeftStr(rs.fields.Get_saValue('extra'),14)='auto_increment';
                      if ((rJColumn.JColu_Desc='NULL') or (rJColumn.JColu_Desc='')) and
                        (rs.fields.Get_saValue('COLUMN_COMMENT')<>'NULL') and
                        (rs.fields.Get_saValue('COLUMN_COMMENT')<>'') then
                      begin
                        rJColumn.JColu_Desc:=rs.fields.Get_saValue('COLUMN_COMMENT');
                      end;
                        //JAS_LOG(p_Context, cnLog_Ebug, 201202203203, 'rs.Fields.Get_saValue(''IS_NULLABLE''):'+rs.Fields.Get_saValue('IS_NULLABLE'),'',SOURCEFILE);

                      with rJColumn do Begin
                        JColu_JColumn_UID             :=0;
                        JColu_Name                    :=rs.fields.Get_saValue('COLUMN_NAME');
                        JColu_JTable_ID               :=rJTable.JTabl_JTable_UID;
                        // JColu_JDType_ID               : ansistring;
                        // JColu_AllowNulls_b            : ansistring;
                        // JColu_DefaultValue            : ansistring;
                        // JColu_PrimaryKey_b            : ansistring;
                        JColu_JAS_b                   :=false;
                        // JColu_JCaption_ID             : ansistring;
                        // JColu_DefinedSize_u           : ansistring;
                        // JColu_NumericScale_u          : ansistring;
                        // JColu_Precision_u             : ansistring;
                        // JColu_Boolean_b               : ansistring;
                        // JColu_JAS_Key_b               : ansistring;
                        // JColu_AutoIncrement_b         : ansistring;
                        // JColu_LUF_Value               : ansistring;
                        // JColu_LD_CaptionRules_b       : ansistring;
                        JColu_JDConnection_ID         := TGT.ID;
                        // JColu_Desc                    : ansistring;
                        // JColu_Weight_u                : ansistring; // int 04
                        // JColu_LD_SQL                  : ansistring;
                        // JColu_LU_JColumn_ID           : ansistring;
                        // JColu_CreatedBy_JUser_ID      : ansistring;
                        // JColu_Created_DT              : ansistring;
                        // JColu_ModifiedBy_JUser_ID     : ansistring;
                        // JColu_Modified_DT             : ansistring;
                        // JColu_DeletedBy_JUser_ID      : ansistring;
                        // JColu_Deleted_DT              : ansistring;
                        // JColu_Deleted_b               : ansistring;
                        // JAS_Row_b                     : ansistring;
                      end;//with
                      //ASPrint('Saving Column-------------');
                      bOk:=bJAS_Save_JColumn(p_Context, TGT, rJColumn, true, false, 201608300042);
                      //ASPrintln('Done. bOk:'+sTrueFalse(bOk));
                      if not bOk then
                      begin
                        JAS_LOG(p_Context, cnLog_Error, 201203050303, 'Trouble Saving JColumn','',SOURCEFILE);
                        DBM_RenderHtmlErrorPage(p_Context);
                      end;
                    end;
                    if bOk then
                    begin
                     u8ColumnsAdded+=1;
                    end;
                  until (not bOk) or (not rs.movenext);
                  rs.close;
                end;
                //==================================================================================================================================================================END
              end;
            end;
          end;
        until (not bOk) or (not p_Context.CGIENV.DataIn.MoveNext);
      end;

      if bOk then
      begin
        sa:='You successfully added '+inttostr(u8TablesAdded)+' tables and a total of '+inttostr(u8ColumnsAdded)+
             ' columns to JAS''. Now you can find those tables in the tables search screen in JAS and create '+
             'screens for them if you like so you can view and/or edit their information.';
        p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_message','',false, 201210020318);
        p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
        p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICON; ?>/JAS/jegas/64/table_search.png');
        p_Context.saPageTitle:='Success';
      end;
    end
    else
    begin
      for i:=0 to length(p_Context.JADOC)-1 do
      begin
        //ASPrintln('JADO '+inttostr(i)+' Name:'+p_Context.JADOC[i].sName+' DBMSID: '+inttostr(p_Context.JADOC[i].u8DbmsID));
        saQry:='show tables';
        bOk:=rs.open(saQry,p_Context.JADOC[i],201503161320);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201010020400, 'Trouble with Query.','Query: '+saQry,SOURCEFILE);
          DBM_RenderHtmlErrorPage(p_Context);
        end;
        //ASPrintln('Ran Query - bOk:'+sTrueFalse(bOk)+' rs.eol:'+sTrueFalse(rs.eol));
        if bOk and (not rs.eol) then
        begin
          repeat
            //ASPrintln('Looping: '+p_Context.JADOC[i].sName+' - '+sa);
            rs.fields.movefirst;
            sa:=rs.fields.Item_saValue;
            if (DBC.u8GetRecordCount('jtable','((JTabl_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JTabl_Deleted_b IS NULL)) AND '+
                '(JTabl_Name='+DBC.saDBMSScrub(sa)+') AND (JTabl_JDConnection_ID='+inttostr(p_Context.JADOC[i].ID)+')',201506171741)=0) AND
               bJAS_HasPermission(p_Context, p_Context.JADOC[i].JDCon_JSecPerm_ID) then
            begin
              XDL.AppendItem_saName_N_saValue(p_Context.JADOC[i].sName+' - '+sa,p_Context.JADOC[i].sName+' - '+sa);
              XDL.Item_i8User:=1;
            end;
          until (not rs.movenext)
        end;
        rs.close;
      end;
      if bOk then
      begin
        //ASPrintln('Building Widget');
        WidgetList(
          p_Context,// p_Context: TCONTEXT;
          'TABLES',// p_saWidgetName: AnsiString;
          'Select Database Connection',// p_saWidgetCaption: AnsiString;
          '0', // p_saDefaultValue: AnsiString;
          20,// p_saSize: Ansistring;
          true,// p_bMultiple: boolean;
          true,// p_bEditMode: Boolean;
          false,// p_bDataOnRight: Boolean;
          XDL,// p_XDL: JFC_XDL;// reference: name=caption, value=returned, desc = "" or "selected", iUser=1 then option selectable (0=grayed out)
          true,// p_bRequired: boolean;
          false,// p_bFilterTools: boolean;
          false,// p_bFilterNot: boolean;
          '',// p_saOnBlur: ansistring;
          '',// p_saOnChange: ansistring;
          '',// p_saOnClick: ansistring;
          '',// p_saOnDblClick: ansistring;
          '',// p_saOnFocus: ansistring;
          '',// p_saOnKeyDown: ansistring;
          '',// p_saOnKeypress: ansistring;
          ''// p_saOnKeyUp: ansistring
        );
        p_Context.saPage:=saGetPage(p_Context, 'sys_area_bare','sys_page_learntables','MAIN',false, 201203122225);
        p_Context.saPageTitle:='Learn Tables';
      end;
    end;
  end;
  rs.destroy;
  XDL.Destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210020306,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================















//=============================================================================
{}
procedure DBM_FlagJasRow(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  bValue: boolean;
  rJJobQ: rtJJobQ;
  rJTask: rtJTask;
  dt: TDATETIME;
  sa: ansistring;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_FlagJasRow';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210270752,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210270753, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201210270754, 'Invalid Session','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_COntext,cnPerm_API_FlagJasRow);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201210270755,'You are not authorized to run this utility.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bValue:=bVal(p_Context.CGIENV.DataIn.Get_saValue('VALUE'));
    dt:=now;
    // MAKE TASK FOR THIS EXPORT for LATER retrieval
    clear_JTask(rJTask);
    with rJTask do begin
      JTask_JTask_UID                  :=0;
      JTask_Name                       :='Flag JAS Rows: '+sTrueFalse(bValue);
      JTask_Desc                       :='Task created to allow flagging JAS Rows in the background.';
      JTask_JTaskCategory_ID           :=cnJTaskCategory_Task;
      JTask_JProject_ID                :=0;
      JTask_JStatus_ID                 :=cnJStatus_NotStarted;
      JTask_Due_DT                     :=FormatDateTime(csDateTimeFormat,dt);
      JTask_Duration_Minutes_Est       :=0;
      JTask_JPriority_ID               :=cnJPriority_Normal;
      JTask_Start_DT                   :=FormatDateTime(csDateTimeFormat,dt);
      JTask_Owner_JUser_ID             :=p_Context.rJSession.JSess_JUser_ID;
      JTask_SendReminder_b             :=false;
      JTask_ReminderSent_b             :=false;
      JTask_ReminderSent_DT            :='';
      JTask_Remind_DaysAhead_u         :=0;
      JTask_Remind_HoursAhead_u        :=0;
      JTask_Remind_MinutesAhead_u      :=0;
      JTask_Remind_Persistantly_b      :=false;
      JTask_Progress_PCT_d             :=0;
      JTask_JCase_ID                   :=0;
      JTask_Directions_URL             :='NULL';
      JTask_URL                        :='NULL';
      JTask_Milestone_b                :=false;
      JTask_Budget_d                   :=0;
      JTask_ResolutionNotes            :='';
      JTask_Completed_DT               :='';
      JTask_Related_JTable_ID          :=0;
      JTask_Related_Row_ID             :=0;
    end;//with
    bOk:=bJAS_Save_JTask(p_Context, p_Context.VHDBC, rJTask, false,false, 201608300043);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201210270756,'Unable to save task record for background flagging of JAS rows: '+sTrueFalse(bValue),'',SOURCEFILE);
    end;
  end;

  // MAKE JobQ Item linked to task, copy all CGIENV in
  // so it's used for the export - strip out right side of the
  // export mode.
  if bOk then
  begin
    clear_JJobQ(rJJobQ);
    with rJJobQ do begin
      JJobQ_JJobQ_UID           :=0;
      JJobQ_JUser_ID            :=p_Context.rJSession.JSess_JUser_ID;
      JJobQ_JJobType_ID         :=cnJJobType_General;
      JJobQ_Start_DT            :=FormatDateTime(csDateTimeFormat,dt);
      JJobQ_ErrorNo_u           :=0;
      JJobQ_Started_DT          :='NULL';
      JJobQ_Running_b           :=false;
      JJobQ_Finished_DT         :='NULL';
      JJobQ_Name                :='Flag JAS Rows: '+sTrueFalse(bValue);
      JJobQ_Repeat_b            :=false;
      JJobQ_RepeatMinute        :='';
      JJobQ_RepeatHour          :='';
      JJobQ_RepeatDayOfMonth    :='';
      JJobQ_RepeatMonth         :='';
      JJobQ_Completed_b         :=false;
      JJobQ_Result_URL          :='NULL';
      JJobQ_ErrorMsg            :='NULL';
      JJobQ_ErrorMoreInfo       :='NULL';
      JJobQ_Enabled_b           :=true;

      // POPULATE THIS WITH ALL CHIENV.DataIn parameters
      // But ADD the TASK ID so we can...
      // 1: Update task record as we progress
      // 2: Route Output to a file versus a webpage for download
      // 3: Update Task with URL for the download.
      JJobQ_Job:=
      '<CONTEXT>'+csCRLF+
      '  <saRequestMethod>POST</saRequestMethod>'+csCRLF+
      '  <saRequestType>HTTP/1.0</saRequestType>'+csCRLF+
      '  <saRequestedFile>'+p_Context.sAlias+'</saRequestedFile>'+csCRLF+
      '  <saQueryString>action=flagjasrowexecute&value='+sTrueFalse(bvalue)+'&task='+inttostr(rJTask.JTask_JTask_UID)+'</saQueryString>'+csCRLF+
      '  <REQVAR_XDL>'+csCRLF+
      '    <ITEM>'+csCRLF+
      '      <saName>HTTP_HOST</saName>'+csCRLF+
      '      <saValue>'+garJVHost[p_Context.u2VHost].VHost_ServerDomain+'</saValue>'+csCRLF+
      '    </ITEM>'+csCRLF+
      '  </REQVAR_XDL>'+csCRLF+
      '  <CGIENV>'+csCRLF+
      '   <DATAIN>'+csCRLF+
      '     <ITEM>'+csCRLF+
      '       <saName>action</saName>'+csCRLF+
      '       <saValue>flagjasrowexecute</saValue>'+csCRLF+
      '     </ITEM>'+csCRLF+
      '     <ITEM>'+csCRLF+
      '       <saName>value</saName>'+csCRLF+
      '       <saValue>'+sTrueFalse(bValue)+'</saValue>'+csCRLF+
      '     </ITEM>'+csCRLF+
      '     <ITEM>'+csCRLF+
      '       <saName>task</saName>'+csCRLF+
      '       <saValue>'+inttostr(rJTask.JTask_JTask_UID)+'</saValue>'+csCRLF+
      '     </ITEM>'+csCRLF+
      '   </DATAIN>'+csCRLF+
      '  </CGIENV>'+csCRLF+
      '</CONTEXT>';
      JJobQ_Result              :='NULL';
      JJobQ_JTask_ID            :=rJTask.JTask_JTask_UID;
    end; // with

    bOk:=bJAS_Save_JJobQ(p_Context, p_Context.VHDBC, rJJobQ, false,false, 201608300044);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201210270757,'Unable to save JobQ record for FLAG JAS ROW process.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    p_Context.PAGESNRXDL.AppendItem_SNRPair('[@PAGEICON@]','[@JASDIRICONTHEME@]64/mimetypes/x-office-spreadsheet.png');
    p_Context.saPage:=saGetPage(p_Context,'sys_area','sys_page_message','MESSAGE',false,'',201210270758);
    sa:='The FLAG JAS ROW process has been placed into a queue to be processed. '+
      '<a target="_blank" href="[@ALIAS@].?screen=jtask+Data&UID='+inttostr(rJTask.JTask_JTask_UID)+'">'+
      'You can monitor it''s progress by clicking here.</a><br />'+csCRLF+
      '<strong>Do NOT refresh this page unless you want to execute this process again!</strong><br />'+csCRLF+
      '<strong>Use the back button to return to the FLAG JAS ROW screen.</strong><br /><br />'+csCRLF+csCRLF+
      '<a title="Go Back to FLAG JAS ROW Screen" href="javascript: window.history.go(-1);">'+csCRLF+
      '  <table>'+csCRLF+
      '  <tbody>'+csCRLF+
      '    <tr>'+csCRLF+
      '      <td><img class="image" src="[@JASDIRICONTHEME@]32/actions/go-previous.png" /></td>'+csCRLF+
      '      <td>&nbsp;&nbsp;</td>'+csCRLF+
      '      <td><font size="4">Go Back</font></td>'+csCRLF+
      '    </tr>'+csCRLF+
      '  </tbody>'+csCRLF+
      '</table>'+csCRLF+
      '</a>';
    p_Context.PageSNRXDL.AppendItem_SNRPAir('[@MESSAGE@]',sa);
    p_COntext.saPageTitle:='Executed Flag Jas Rows';
  end;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210270759,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
{}
procedure DBM_FlagJasRowExecute(p_Context: TCONTEXT);
//=============================================================================

var
  bOk: boolean;
  JAS: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  rs3: JADO_RECORDSET;
  bValue: boolean;
  rJTask: rtJTask;
  saBackTask: ansistring;
  sDeletedFlagColumn: string;
  u8PKeyID: uint64;
  sPKeyColumnName: string;
  sTableName: string;
  //bInXDL: boolean;

  //SkipTableXDL: JFC_XDL; // list of tables BUT, XDL instance on lpPTR for individual keys!
  // Individual Keys - THESE ARE KEPT
  // XDL.Item_saValue= PkeyValue/UID
  //
  // XDL: JFC_XDL;//REFERENCE - DO NOT DESTROY:

  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_FlagJasRowExecute';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210262328,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210262329, sTHIS_ROUTINE_NAME);{$ENDIF}

  bValue:=bVal(p_Context.CGIENV.DataIn.Get_saValue('VALUE'));
  JASPrintln('BEGIN --------------- FLAG JAS ROWS: '+sTrueFalse(bValue));

  JAS:=p_Context.DBCON('JAS',201610312257);
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  rs3:=JADO_RECORDSET.Create;
  //SkipTableXDL:=JFC_XDL.Create;

  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201210270657, 'Invalid Session','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_COntext, cnPerm_API_FlagJasRowExecute);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201210270658,'You are not authorized to run this utility.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    saBackTask:=p_Context.CGIENV.DataIn.Get_saValue('TASK');
    if bValue then
    begin
      //with SkipTableXDL do begin
      //  //AppendItem_saName('jadodbms');
      //  //AppendItem_saName('jadodriver');
      //  AppendItem_saName('jalias');
      //  //AppendItem_saName('jasident');
      //  //AppendItem_saName('jblok');
      //  //AppendItem_saName('jblokbutton');
      //  //AppendItem_saName('jblokfield');
      //  //AppendItem_saName('jbloktype');
      //  //AppendItem_saName('jbuttontype');
      //  //AppendItem_saName('jcaption');
      //  AppendItem_saName('jcase');
      //  //AppendItem_saName('jcasecategory');
      //  //AppendItem_saName('jcasesource');
      //  //AppendItem_saName('jcasestatus');
      //  //AppendItem_saName('jcasesubject');
      //  //AppendItem_saName('jcasetype');
      //  //AppendItem_saName('jclickaction');
      //  //AppendItem_saName('jcolumn');
      //  //AppendItem_saName('jdconnection');
      //  AppendItem_saName('jdebug');
      //  //AppendItem_saName('jdtype');
      //  AppendItem_saName('jfile');
      //  //AppendItem_saName('jfiltersave');
      //  //AppendItem_saName('jfiltersavedef');
      //  AppendItem_saName('jiconcontext');
      //  AppendItem_saName('jiconmaster');
      //  //AppendItem_saName('jindexfile');
      //  //AppendItem_saName('jindustry');
      //  AppendItem_saName('jinstalled');
      //  //AppendItem_saName('jinterface');
      //  AppendItem_saName('jinvoice');
      //  AppendItem_saName('jinvoicelines');
      //  AppendItem_saName('jiplist');
      //  AppendItem_saName('jjobq');
      //  //AppendItem_saName('jjobtype');
      //  //AppendItem_saName('jlanguage');
      //  AppendItem_saName('jlead');
      //  //AppendItem_saName('jleadsource');
      //  AppendItem_saName('jlock');
      //  AppendItem_saName('jlog');
      //  //AppendItem_saName('jlogtype');
      //  //AppendItem_saName('jlookup');
      //  AppendItem_saName('jmail');
      //  //AppendItem_saName('jmenu');
      //  //AppendItem_saName('jmime');
      //  AppendItem_saName('jmodc');
      //  AppendItem_saName('jmodule');
      //  AppendItem_saName('jmoduleconfig');
      //  AppendItem_saName('jmodulesetting');
      //  //AppendItem_saName('jnote');
      //  AppendItem_saName('jorg');
      //  AppendItem_saName('jorgpers');
      //  AppendItem_saName('jpassword');
      //  AppendItem_saName('jperson');
      //  AppendItem_saName('jpersonskill');
      //  //AppendItem_saName('jprinter');
      //  //AppendItem_saName('jpriority');
      //  AppendItem_saName('jproduct');
      //  AppendItem_saName('jproductgrp');
      //  AppendItem_saName('jproductqty');
      //  AppendItem_saName('jproject');
      //  //AppendItem_saName('jprojectcategory');
      //  //AppendItem_saName('jprojectpriority');
      //  //AppendItem_saName('jprojectstatus');
      //  //AppendItem_saName('jquicklink');
      //  AppendItem_saName('jquicknote');
      //  //AppendItem_saName('jscreen');
      //  //AppendItem_saName('jscreentype');
      //  //AppendItem_saName('jsecgrp');
      //  //AppendItem_saName('jsecgrplink');
      //  //AppendItem_saName('jsecgrpuserlink');
      //  //AppendItem_saName('jseckey');
      //  //AppendItem_saName('jsecperm');
      //  //AppendItem_saName('jsecpermuserlink');
      //  AppendItem_saName('jsession');
      //  AppendItem_saName('jsessiondata');
      //  //AppendItem_saName('jsessiontype');
      //  AppendItem_saName('jskill');
      //  AppendItem_saName('jsync');
      //  AppendItem_saName('jsysmodule');
      //  AppendItem_saName('jsysmodulelink');
      //  //AppendItem_saName('jtable');
      //  //AppendItem_saName('jtabletype');
      //  AppendItem_saName('jtask');
      //  //AppendItem_saName('jtaskcategory');
      //  //AppendItem_saName('jstatus');
      //  AppendItem_saName('jteam');
      //  AppendItem_saName('jteammember');
      //  AppendItem_saName('jtestone');
      //  //AppendItem_saName('jthemecolor');
      //  //AppendItem_saName('jthemeicon');
      //  AppendItem_saName('jtimecard');
      //  AppendItem_saName('jtrak');
      //  AppendItem_saName('juser');
      //    Item_lpPtr:=JFC_XDL.Create;
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('1');// Keep Admin User
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2');// Keep Default User
      //
      //  AppendItem_saName('juserpref');
      //    Item_lpPtr:=JFC_XDL.Create;
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100523493783574');// 	JAS Enable IP Blacklist 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100523502800347');//  JAS Enable IP Whitelist 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100523585810330');// 	JAS ffmpeg 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600004038540');// 	JAS convert 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600054888559');// 	JAS Number of Threads 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600110991011');// 	JAS Max Thread Run Time MSec 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600130822122');// 	JAS Maximum File Handles 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600143939729');// 	JAS Delete Log 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600181287858');// 	JAS Safe Delete 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600194635959');// 	JAS Protect JAS Records 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600204082504');// 	JAS IP Packet Buffer Recv Size 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600223189194');// 	JAS Max Request Header Length 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600245545344');// 	JAS Retry Limit 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600253922931');// 	JAS Retry Delay In Milli Seconds 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600291265307');// 	JAS Create Socket Retry 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600302199729');// 	JAS Create Socket Retry Delay In MSec 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600381443817');// 	JAS SessionTime Out In Minutes 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600394544613');// 	JAS Record Lock Time Out In Minutes 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600431309486');// 	JAS Record Lock Retries Before Failure 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100600441382324');// 	JAS Record Lock Retry Delay In Milli Seconds 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601142107215');// 	JAS Validate Session Retry Limit 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601205217636');// 	JAS Timezone Offset 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601224675679');// 	JAS Socket Timeout In Milli Seconds 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601335136488');// 	JAS Cache Max Age In Seconds 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601353658831');// 	JAS Job Queue Enabled 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601373446775');// 	JAS Job Queue Interval In Milli Seconds 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601404369183');// 	JAS HOOK_ACTION_CREATESESSION_SUCCESS 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601411616307');// 	JAS HOOK_ACTION_CREATESESSION_FAILURE 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601421923215');// 	JAS HOOK_ACTION_REMOVESESSION_SUCCESS 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601425482315');// 	JAS HOOK_ACTION_REMOVESESSION_FAILURE 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601432299990');// 	JAS HOOK_ACTION_VALIDATESESSION_SUCCESS 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601440362819');// 	JAS HOOK_ACTION_VALIDATESESSION_FAILURE 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601470889461');// 	JAS HOOK_ACTION_SESSIONTIMEOUT 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601483142415');// 	JAS Server Console Messages Enabled 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601503826678');// 	JAS Log Messages Show On Server Console 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601521999636');// 	JAS Debug Server Console Messages Enabled 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100601554760113');// 	JAS Log Level 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100602015446290');// 	JAS Error Reporting Mode 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100602145501728');// 	JAS Error Reporting Secure Mode Message 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100602210695553');// 	JAS Debug Mode 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100602482282545');// 	JAS RC VICI Server To Server Address 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100602492729711');// 	JAS RC VICI Client To Server Address 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100602520874242');// 	JAS SMTP Host 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100602525101866');// 	JAS SMTP Username 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100602553219460');// 	JAS SMTP Password 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100604451547410');// 	JAS PHP 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100604461492825');// 	JAS Perl 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100706402078540');// 	JAS Webshare Alias 	Admin 	No
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100707063033564');// 	JAS IP Packet Buffer Send Size 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100723463178272');// 	JAS Password Key 	Admin 	No
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100806263083446');// 	JAS IP Address Whitelist Enabled 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100806285731497');// 	JAS IP Address Blacklist Enabled 	Admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100906494118344');// 	JAS Footer 	Admin 	Yes
      //
      //
      //  AppendItem_saName('juserpreflink');
      //    Item_lpPtr:=JFC_XDL.Create;
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('4');                   //    Rows per page 	admin 	8
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614040179599'); // 	JAS Cache Max Age In Seconds 	admin 	3600
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614043322770'); // 	JAS convert 	admin 	/usr/bin/convert
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614045994520'); // 	JAS Create Socket Retry 	admin 	60
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614052025145'); // 	JAS Create Socket Retry Delay In MSec 	admin 	1000
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614053914241'); // 	JAS Debug Mode 	admin 	secure
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614061800671'); // 	JAS Debug Server Console Messages Enabled 	admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614072805008'); // 	JAS Delete Log 	admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614074544424'); // 	JAS Enable IP Blacklist 	admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614080255621'); // 	JAS Enable IP Whitelist 	admin 	No
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614090714788'); // 	JAS Error Reporting Mode 	admin 	secure
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614101453914'); // 	JAS Error Reporting Secure Mode Message 	admin 	Please note the error number shown in this message and record it. Your system administrator can use that number to help remedy system problems.
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614122888581'); // 	JAS ffmpeg 	admin 	/usr/local/bin/ffmpeg
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614124173033'); // 	JAS HOOK_ACTION_CREATESESSION_FAILURE 	admin 	0
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614125179884'); // 	JAS HOOK_ACTION_CREATESESSION_SUCCESS 	admin 	0
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614130177790'); // 	JAS HOOK_ACTION_REMOVESESSION_FAILURE 	admin 	0
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614131550006'); // 	JAS HOOK_ACTION_REMOVESESSION_SUCCESS 	admin 	0
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614132661440'); // 	JAS HOOK_ACTION_SESSIONTIMEOUT 	admin 	0
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614134121397'); // 	JAS HOOK_ACTION_VALIDATESESSION_FAILURE 	admin 	0
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614135620684'); // 	JAS HOOK_ACTION_VALIDATESESSION_SUCCESS 	admin 	0
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614150622123'); // 	JAS Job Queue Enabled 	admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614165072216'); // 	JAS Job Queue Interval In Milli Seconds 	admin 	10000
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614171518219'); // 	JAS Log Level 	admin 	0
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614204192426'); // 	JAS Log Messages Show On Server Console 	admin 	No
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614291882510'); // 	JAS Max Request Header Length 	admin 	1500000000
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614484499907'); // 	JAS Max Thread Run Time MSec 	admin 	60000
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614490660469'); // 	JAS Maximum File Handles 	admin 	200
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614492220150'); // 	JAS Number of Threads 	admin 	40
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614500246737'); // 	JAS Perl 	admin 	/usr/bin/perl
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614502815902'); // 	JAS PHP 	admin 	/usr/bin/php-cgi
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614504757616'); // 	JAS Protect JAS Records 	admin 	True
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614510501178'); // 	JAS RC VICI Client To Server Address 	admin
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100614511733687'); // 	JAS RC VICI Server To Server Address 	admin
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615120666942'); // 	JAS Record Lock Retry Delay In Milli Seconds 	admin 	20
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615123707971'); // 	JAS Record Lock Time Out In Minutes 	admin 	30
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615140260928'); // 	JAS Retry Delay In Milli Seconds 	admin 	100
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615142419915'); // 	JAS Retry Limit 	admin 	20
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615145637878'); // 	JAS Safe Delete 	admin 	True
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615152356082'); // 	JAS Server Console Messages Enabled 	admin 	Yes
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615160460912'); // 	JAS SessionTime Out In Minutes 	admin 	240
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615162043726'); // 	JAS SMTP Host 	admin 	smtp.comcast.net
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615163514292'); // 	JAS SMTP Password 	admin 	pm94f47d
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615164495133'); // 	JAS SMTP Username 	admin 	jasonpsage@comcast.net
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615172828038'); // 	JAS Socket Timeout In Milli Seconds 	admin 	12000
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615180834150'); // 	JAS Timezone Offset 	admin 	-5
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100615183451070'); // 	JAS Validate Session Retry Limit 	admin 	50
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100706052712248'); // 	JAS Record Lock Retries Before Failure 	admin 	50
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100706402078540'); // 	JAS Webshare Alias 	admin 	/jws/
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100723482235916'); // 	JAS Password Key 	admin 	147
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100906502356513'); // 	JAS Footer 	admin 	jassig.jas
      //
      //  AppendItem_saName('jvhost');
      //    Item_lpPtr:=JFC_XDL.Create;
      //    JFC_XDL(Item_lpPtr).AppendItem_saValue('2012100904220966328'); // default JAS Vhost Record
      //  //AppendItem_saName('jwidget');
      //  AppendItem_saName('testnonjas');
      //  AppendItem_saName('view_case');
      //  AppendItem_saName('view_org');
      //  AppendItem_saName('view_inventory');
      //  AppendItem_saName('view_invoice');
      //  AppendItem_saName('view_lead');
      //  AppendItem_saName('view_menu');
      //  AppendItem_saName('view_person');
      //  AppendItem_saName('view_project');
      //  AppendItem_saName('view_task');
      //  AppendItem_saName('view_team');
      //  AppendItem_saName('view_time');
      //  AppendItem_saName('view_vendor');
      //  AppendItem_saName('vrevent');
      //  AppendItem_saName('vrvideo');
      //end;
    end;
  end;

  if bOk then
  begin
    saQry:='select * from jtable where ((JTabl_Deleted_b<>'+
      JAS.sDBMSBoolScrub(true)+')OR(JTabl_Deleted_b IS NULL)) AND '+
      '(JTabl_JDConnection_ID=1) AND (JTabl_JTableType_ID=1) ORDER by JTabl_Name';
    bOk:=rs.open(saQry,JAS,201503161321);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error,201210262334,'Trouble with Query.','Query: '+saQry,SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;

  if bOk and (not rs.eol) then
  begin
    repeat
      if JAS.bColumnExists(rs.fields.Get_saValue('JTabl_Name'),'JAS_Row_b',201210242350) then
      begin
        //sPKeyColumnName:= JAS.sGetPKeyColumnWTableID(pointer(JAS),u8Val(rs.fields.Get_saValue('JTabl_JTable_UID')), 201210242342);
        sPKeyColumnName:=JAS.saGetValue('jcolumn','JColu_JColumn_UID',
          '((JColu_Deleted_b<>true)or(JColu_Deleted_b IS NULL)) and '+
          '(JColu_JTable_ID='+JAS.sDBMSUIntScrub(rs.fields.Get_saValue('JTabl_JTable_UID'))+') AND '+
          '(JColu_PrimaryKey_b=true)'
        ,201608231623);
        sTableName:=rs.fields.Get_saValue('JTabl_Name');
        saQry:='select '+sPKeyColumnName+' FROM '+rs.fields.Get_saValue('JTabl_Name');
        sDeletedFlagColumn:=rs.fields.Get_saValue('JTabl_ColumnPrefix')+'_Deleted_b';
        if JAS.bColumnExists(rs.fields.Get_saValue('JTabl_Name'),sDeletedFlagColumn,201210242350) then
        begin
          saQry+=' WHERE (('+sDeletedFlagColumn+'<>'+JAS.sDBMSBoolScrub(true)+')OR('+sDeletedFlagColumn+' IS NULL))';
        end;
        bOk:=rs2.open(saQry,JAS,201503161330);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error,201210262353,'Trouble with Query.','Query: '+saQry,SOURCEFILE);
          DBM_RenderHtmlErrorPage(p_Context);
        end;
        if bOk and (not rs2.eol) then
        begin
          // If just table, exclude, if table with keys, go ahead but skip keys
          //if bValue then bInXDL:=SkipTableXDL.FoundItem_saName(rs.fields.Get_saValue('JTabl_Name'));
          //if (not bValue) or (not bInXDL) or (bInXDL and (SkipTableXDL.Item_lpPtr<>nil)) then
          //begin
            repeat
              u8PKeyID:=u8Val(rs2.fields.Get_saValue(sPKeyColumnName));
              //if (not bValue) or (not bInXDL) or
              //   (bInXDL and (JFC_XDL(SkipTableXDL.Item_lpPtr).FoundItem_saValue(inttostr(u8PKeyID)))) then
              //begin
                JASPrintln('JAS ROW - '+sTableName+' '+inttostr(u8PKeyID));
                saQry:='UPDATE '+sTableName+' SET JAS_Row_b='+
                  JAS.sDBMSBoolScrub(bValue)+' WHERE '+sPKeyColumnName+'='+inttostr(u8PKeyID);
                bOk:=rs3.open(saQry,JAS,201503161331);
                if not bOk then
                begin
                  JAS_LOG(p_Context, cnLog_Error,201210270012,'Trouble with Query.','Query: '+saQry,SOURCEFILE);
                  DBM_RenderHtmlErrorPage(p_Context);
                end;
                rs3.close;
              //end;
            until (not bOk) or (not rs2.movenext);
          //end;
        end;
        rs2.close;
        //ASPrintln('----------------------');
      end;
    until (not bOk) or (not rs.MoveNext);
  end;
  rs.close;

  if bOk then
  begin
    p_Context.saPage:='Flag Jas Row - completed';
    clear_JTask(rJTask);
    rJTask.JTask_JTask_UID:=u8Val(saBackTask);
    bOk:=bJAS_Load_JTask(p_Context, JAS, rJTask, true, 201608300045);
    if not bOk then
    begin
      p_Context.saPage+=' but I was unable to record this progress in any task record. Did you run this directly? Yeah you did! lol ';
      JAS_LOG(p_Context, cnLog_warn, 201210270808,'Unable to load JTask Record: '+saBackTask,'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    // 1: Update Task fields
    with rJTask do begin
      //JTask_JTask_UID                  : ansistring;
      //JTask_Name                       : ansistring;
      //JTask_Desc                       : ansistring;
      //JTask_JTaskCategory_ID           : ansistring;
      //JTask_JProject_ID                : ansistring;
      JTask_JStatus_ID                   :=cnJStatus_Completed;
      //JTask_Due_DT                     : ansistring;
      //JTask_Duration_Minutes_Est       : ansistring;
      //JTask_JPriority_ID               : ansistring;
      //JTask_Start_DT                   : ansistring;
      //JTask_Owner_JUser_ID             : ansistring;
      JTask_SendReminder_b             :=true;
      JTask_ReminderSent_b             :=true;
      JTask_ReminderSent_DT            :=FormatDateTime(csDATETIMEFORMAT,now);
      JTask_Remind_DaysAhead_u         :=0;
      JTask_Remind_HoursAhead_u        :=0;
      JTask_Remind_MinutesAhead_u      :=0;
      JTask_Remind_Persistantly_b      :=false;
      JTask_Progress_PCT_d             :=100;
      //JTask_JCase_ID                   : ansistring;
      //JTask_Directions_URL             : ansistring;
      //JTask_URL                        : ansistring;
      //JTask_Milestone_b                : ansistring;
      //JTask_Budget_d                   : ansistring;
      JTask_ResolutionNotes            :='FLAG JAS ROW Completed Successfully';
      JTask_Completed_DT               :=FormatDateTime(csDATETIMEFORMAT,now);
      //JTask_CreatedBy_JUser_ID         : ansistring;
      //JTask_Related_JTable_ID          : ansistring;
      //JTask_Related_Row_ID             : ansistring;
      //JTask_Created_DT                 : ansistring;
      //JTask_ModifiedBy_JUser_ID        : ansistring;
      //JTask_Modified_DT                : ansistring;
      //JTask_DeletedBy_JUser_ID         : ansistring;
      //JTask_Deleted_DT                 : ansistring;
      //JTask_Deleted_b                  : ansistring;
      //JAS_Row_b                        : ansistring;
    end;//with
    bOk:=bJAS_Save_JTask(p_Context, JAS, rJTask,true,false, 201608300046);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201210270809,'Unable to Save JTask Record: '+saBackTask,'',SOURCEFILE);
    end;
  end;


  //if SkipTableXDL.MoveFirst then
  //begin
  //  repeat
  //    if SkipTableXDL.Item_lpPtr<>nil then JFC_XDL(SkipTableXDL.Item_lpPtr).Destroy;
  //  until not SkipTableXDL.MoveNext;
  //end;
  //SkipTableXDL.Destroy;
  rs3.destroy;
  rs2.destroy;
  rs.destroy;
  JASPrintln('END --------------- FLAG JAS ROWS: '+sTrueFalse(bValue));
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210262330,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





























//=============================================================================
{}
// Makes new user, password and database and makes a JAS connection
// for it using same info. This routin passes back the JDConnection UID
// when successful or a ZERO if it failed. Note the connection IS NOT ENABLED
// so the next step to make the database etc would be to load the info
// into an instance of JDCON, Doo all you have to do then SAVE the connection
// as ENABLED and send the Cycle command into the JobQueue of the Squadron
// Leader databse.
function u8NewConAndDB(
  p_Context: TCONTEXT;
  p_saName: ansistring// becomes user name, password, and database name.
): UInt64;
//=============================================================================
var
  bOk: boolean;
  JAS: JADO_CONNECTION;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  rJDCon: rtJDConnection;
  saDBName: ansistring;

  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='u8NewConAndDB';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210271929,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210271930, sTHIS_ROUTINE_NAME);{$ENDIF}
  writeln('DBTools - newconanddb - on entry p_saName:'+p_saName);

  JAS:=p_Context.DBCON('JAS',201610312258);
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  clear_JDConnection(rJDCon);
  saDBName:='jas_'+p_saName;
  
  if bOk then
  begin
    saQry:='DROP DATABASE IF EXISTS '+JAS.sDBMSEncloseObjectName(saDBName);
    bOk:=rs.Open(saQry,JAS,201511240043);
    if not bok then
    begin
     JAS_LOG(p_Context,cnLog_Error,201511240044,'Trouble with query.','Query: '+saQry,SOURCEFILE);
    end;
    rs.close;
  end;     

  if bOk then
  begin
    saQry:='CREATE DATABASE '+JAS.sDBMSEncloseObjectName(saDBName);
    bOk:=rs.Open(saQry,JAS,201511240045);
    if not bok then
    begin
      JAS_LOG(p_Context,cnLog_Error,201511240046,'Trouble with query.','Query: '+saQry,SOURCEFILE);
    end;
    rs.close;
  end;     
 
  if bOk then
  begin
    saQry:='SELECT JDCon_JDConnection_UID from jdconnection WHERE '+
      '((JDCon_Deleted_b<>'+JAS.sDBMSBoolScrub(true)+')OR(JDCon_Deleted_b IS NULL)) AND '+
      '(JDCon_Name='+JAS.saDBMSScrub(saDBName)+')';
    bOk:=rs.Open(saQry, JAS,201503161332);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201210271957,'Trouble with query.','Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.EOL;
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201210272001,'Connection already exists in JDConnection.','',SOURCEFILE);
    end;
  end;
  rs.close;


  if bOk then
  begin
    saQry:='SELECT JDCon_JDConnection_UID from jdconnection WHERE '+
      '((JDCon_Deleted_b<>'+JAS.sDBMSBoolScrub(true)+')OR(JDCon_Deleted_b IS NULL)) AND '+
      '(JDCon_JDConnection_UID='+JAS.sDBMSUIntScrub(1)+')';
    bOk:=rs.Open(saQry, JAS,201503161333);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201210271959,'Trouble with query.','Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk and (not rs.EOL) then
  begin
    rJDCon.JDCon_JDConnection_UID:=u8Val(rs.fields.Get_saValue('JDCon_JDConnection_UID'));
    bOk:=bJAS_Load_JDConnection(p_Context, JAS, rJDCon, false, 201608300047);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201210272000,'Trouble loading Src JDConnection.','',SOURCEFILE);
    end;
  end;
  rs.close;

  //if bOk then
  //begin
  //  saQry:='SELECT SCHEMA_NAME FROM information_schema.SCHEMATA WHERE SCHEMA_NAME='+JAS.saDBMSSCrub(saDBName);
  //  bOk:=rs.open(saQry,JAS,201503161334);
  //  if not bOk then
  //  begin
  //    JAS_LOG(p_Context,cnLog_Error,201210271954,'Trouble with query.','Query: '+saQry,SOURCEFILE);
  //  end;
  //end;


  if bOk and rs.eol then
  begin
    saQry:='CREATE DATABASE IF NOT EXISTS '+JAS.sDBMSEncloseObjectName(saDBName);
    bOk:=rs.open(saQry,JAS,201503161335);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201210271955,'Trouble with query.','Query: '+saQry,SOURCEFILE);
    end;
    rs.close;
  end;


  if bOk then
  begin
    saQry:=
      'GRANT '+
        'SELECT, '+
        'INSERT, '+
        'UPDATE, '+
        'DELETE, '+
        'CREATE, '+
        'DROP, '+
        'REFERENCES, '+
        'INDEX, '+
        'ALTER, '+
        'CREATE VIEW, '+
        'SHOW VIEW '+
      'ON '+JAS.sDBMSEncloseObjectName(saDBName)+'.* to '+p_saName+'@localhost '+
      'IDENTIFIED BY "'+saDBName+'"';
    bOk:=rs.open(saQry,JAS,201503161336);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201210271956,'Trouble with query.','Query: '+saQry,SOURCEFILE);
    end;
  end;
  rs.close;







  if bOk then
  begin
    with rJDCon do begin
      JDCon_JDConnection_UID                  :=0;
      JDCon_Name                              :=p_saName;
      JDCon_Desc                              :='JAS connection created with automation.';
      JDCon_DBC_Filename                      :='';
      //JDCon_DSN                               : ansistring;
      //JDCon_DSN_Filename                      : ansistring;
      //JDCon_Enabled_b                         :='false';
      //JDCon_DBMS_ID                           : ansistring;
      //JDCon_Driver_ID                         : ansistring;
      JDCon_Username                          :=p_saName;
      JDCon_Password                          :=saDBName;
      //JDCon_ODBC_Driver                       : ansistring;
      //JDCon_Server                            : ansistring;
      JDCon_Database                          :=saDBName;
      JDCon_DSN_FileBased_b                   :=false;
      JDCon_DSN_Filename                      :='';
      JDCon_JSecPerm_ID                       :=0;
      JDCon_JAS_b                             :=true;
      //JDCon_CreatedBy_JUser_ID                : ansistring;
      //JDCon_Created_DT                        : ansistring;
      //JDCon_ModifiedBy_JUser_ID               : ansistring;
      //JDCon_Modified_DT                       : ansistring;
      //JDCon_DeletedBy_JUser_ID                : ansistring;
      //JDCon_Deleted_DT                        : ansistring;
      //JDCon_Deleted_b                         : ansistring;
      JAS_Row_b                               :=false;
    end;
    //if u8Val(rJDCon.JDCon_JDConnection_UID)=0 then
    //begin
    //  JAS_LOG(p_Context,nLog_Debug,201210272001,'WRONG JDCON UID FOR SAVE!','',SOURCEFILE);
    //end;
    bOk:=bJAS_Save_JDConnection(p_Context, JAS, rJDCon,false,false, 201608300048);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201210272001,'Trouble saving Dest JDConnection.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    result:=rJDCon.JDCon_JDConnection_UID;
  end
  else
  begin
    result:=0;
  end;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210271931,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

















//=============================================================================
{}
// DBC - Main DB Connection (SOURCE)
// JDCon_JDConnection_UID: Database connection in source DB to use
// Name to use making a connection if JDCon_JDConnection_UID is ZERO on entry
// bLeadJet: If True treat as Master Database, otherwise like a JET database.
//
// Makes New Master databases or Jet databases and also upgrades existing
// databases.
//
// Make Tables (jtable info) or Alter
//   NOTE: if not exist (Use JAS_Row_b Column Records for info)
// Add Rows or Update from master flagged JAS_Row_b
//   Note: Tables without JAS_Row_b - Add rows (e.g. jasident, juserpref)
// TODO: Add VIEW SQL to jtable - for each DBMS - Use to make Views)
function bDBMasterUtility(
  p_Context: TCONTEXT;
  p_DBC: JADO_CONNECTION;
  var p_JDCon_JDConnection_UID: UInt64;// UID of Target connection
  p_saName: ansistring; //< if p_JDCon_JDConnection_UID < 2 then NAME is
                        //< used to create connection record using info
                        //< from JAS connection. new user name made etc.
  p_bLeadJet: boolean   //< Whether to upgrade/create a Jet Leader DB or
                        //< a Jet DB. Jet Leader = Main JAS Database.
): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: ansistring;
  TGT: JADO_Connection;
  rJDCon: rtJDConnection;
  saDBCFilename: ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  rs3: JADO_RECORDSET;
  rJTable: rtJTable;
  sDelCol: string[64];
  arJColumn: array of rtJColumn;
  i: longint;
  bColumnExists: boolean;
  i4Rows: longint;
  i4TotalRows: longint;
  saPKeyValue: ansistring;
  bDelColumnExists: boolean;
  saDefault: ansistring;
  bJASRowExists: boolean;
  bDropColumn: boolean;
  saColumnValue: ansistring;
  bSkipColumn: boolean;
  bAbortRow: boolean;
  sPKeyName: string;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bDBMasterUtility';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210271932,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210271933, sTHIS_ROUTINE_NAME);{$ENDIF}
  jASPrintln(saREpeatChar('=',79));
  jASPrintln(saREpeatChar('=',79));
  jASPrintln('DB MASTER utility - BEGIN - NAME: '+p_saName);
  jASPrintln(saREpeatChar('=',79));
  jASPrintln(saREpeatChar('=',79));

  TGT:=JADO_Connection.Create;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  rs3:=JADO_RECORDSET.Create;
  arJColumn:=nil;

  bOk:=true;
  if p_JDCon_JDConnection_UID<2 then//exclude zero (default fall back) or uid 1 - reference to main db
  begin
    writeln('dbtools-dbm - p_saName b4 newconanddb: '+p_saName);
    p_JDCon_JDConnection_UID:=u8NewConAndDB(p_Context,p_saName);
    writeln('dbtools-dbm - p_saName AFTER newconanddb: '+p_saName);
    bOk:=p_JDCon_JDConnection_UID>1;
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201210291340, 'Call to u8NewConAndDB from bDBMasterUtility failed.','',SOURCEFILE);
    end;
  end;
  //ASPrintln('u8NewConAndDb bOk '+sYesNo(bOk));



  if bOk then
  begin
    clear_JDConnection(rJDCon);
    rJDCon.JDCon_JDConnection_UID:=p_JDCon_JDConnection_UID;
    //ASPRintln('----bDBMasterUtility CALLING bJAS_Load_JDConnection with rJDCon.JDCon_JDConnection_UID: '+inttostr(rJDCon.JDCon_JDConnection_UID));
    bOk:=bJAS_Load_JDConnection(p_Context, p_DBC, rJDCon, true, 201608300049);
    //ASPRintln('----bDBMasterUtility Back from CALLING bJAS_Load_JDConnection bOK:'+sYesNo(bOk));
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201210281032, 'Trouble loading JDConnection record: '+inttostr(p_JDCon_JDConnection_UID),'',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with TGT do begin
      ID:=                  rJDCon.JDCon_JDConnection_UID;
      JDCon_JSecPerm_ID:=   rJDCon.JDCon_JSecPerm_ID;
      sName:=               upcase(rJDCon.JDCon_Name);
      saDesc:=              rJDCon.JDCon_Desc;
      sDSN:=                rJDCon.JDCon_DSN;
      bFileBasedDSN:=       rJDCon.JDCon_DSN_FileBased_b;
      saDSNFileName:=       rJDCon.JDCon_DSN_Filename;
      sUserName:=           rJDCon.JDCon_Username;
      sPassword:=           rJDCon.JDCon_Password;
      sDriver:=             rJDCon.JDCon_ODBC_Driver;
      sServer:=             rJDCon.JDCon_Server;
      sDatabase:=           rJDCon.JDCon_Database;
      u8DriverID:=          rJDCon.JDCon_Driver_ID;
      u8DbmsID:=            rJDCon.JDCon_DBMS_ID;
      //bJas:=                rJDCon.JDCon_JAS_b;
      bJas:=true;
      saDBCFilename:=       rJDCon.JDCon_DBC_Filename;


        //ASPrintln('fileexists(saDBCFilename): '+sYesNo(fileexists(saDBCFilename))+' '+saDBCFilename);


      if fileexists(saDBCFilename) then
      begin
        bOk:=TGT.bLoad(saDBCFilename);
        //ASPrintln('TGT.bLoad bOk '+sYesNo(bOk));
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201210281033, '****Unable to load DBC configuration file: ' + saDBCFilename,'', SOURCEFILE);
        end;
      end ;
    end;//with
  end;

  if bOk then
  begin
    //ASPrintln('dbmu - about to TGT.OpenCon');
    TGT.bJAS:=false;
    bOk:=TGT.OpenCon;
    TGT.bJAS:=true;
    //ASPrintln('TGT.OpenCon bOk '+sYesNo(bOk));
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201210281334,'Unable to open TARGET database connection',
        'Name: '+TGT.sName+' u8DbmsID:'+inttostr(TGT.u8DbmsID)+' u2DrivID: '+inttostr(TGT.u8DriverID),SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    saQry:='SELECT JTabl_JTable_UID, JTabl_Name, JTabl_JTableType_ID FROM jtable '+
      'WHERE ((JTabl_Deleted_b='+p_DBC.sDBMSBoolScrub(false)+')OR(JTabl_Deleted_b is null)) AND '+
      '(JAS_Row_b='+p_DBC.sDBMSBoolScrub(true)+') ORDER BY JTabl_Name';
    bOk:=rs.Open(saQry, p_DBC,201503161337);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201210311520,'Trouble with Query.','Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk and (not rs.eol) then
  begin
    repeat
      if u8Val(rs.fields.Get_saValue('JTabl_JTableType_ID'))=cnJTableType_View then
      begin
        bOk:= TGT.bDropView(rs.fields.Get_saValue('JTabl_Name'),201210311526);
        if not bOk then
        begin
          JAS_LOG(p_Context,cnLog_Warn,201210311527,'Unable to Drop View (Missing?): '+rs.fields.Get_saValue('rJTable.JTabl_Name'),'',SOURCEFILE);
        end;
        bOk:=true;//it'll die after if the table indeed exists and can not be dropped
      end
      else
      begin // Treat Tables and UNKNOWNS as Tables :) //if u8Val(rs.fields.Get_saValue('JTabl_JTableType_ID'))=cnJTableType_Table then
        bOk:= TGT.bDropTable(rs.fields.Get_saValue('JTabl_Name'),201210311524);
        if not bOk then
        begin
          JAS_LOG(p_Context,cnLog_Warn,201210311525,'Unable to Drop Table (Missing?): '+rs.fields.Get_saValue('JTabl_Name'),'',SOURCEFILE);
        end;
        bOk:=true;//it'll die after if the table indeed exists and can not be dropped
      end;
      //else  <-- las in else if chain before
      //begin
      //  JAS_LOG(p_Context, cnLog_Error, 201210311521, 'Table not flagged as view or table.: '+rs.fields.Get_saValue('JTabl_Name'),'',SOURCEFILE);
      //end;
    until (not bOk) or (not rs.MoveNext);
    //ASPrintln('Killed Stuff bOk '+sYesNo(bOk));
  end;
  rs.close;




  if bOk then
  begin
    //saQry:='SELECT JTabl_JTable_UID FROM jtable WHERE ((JTabl_Deleted_b<>'+p_DBC.sDBMSBoolScrub(true)+')OR(JTabl_Deleted_b IS NULL)) AND '+
    //  '(JAS_Row_b='+p_DBC.sDBMSBoolScrub(true)+') AND (JTabl_JTableType_ID='+p_DBC.sDBMSUIntScrub(cnJTableType_Table)+') ORDER BY JTabl_Name';
    saQry:='(JAS_Row_b='+p_DBC.sDBMSBoolScrub(true)+') AND '+
      '(JTabl_JTableType_ID='+p_DBC.sDBMSUIntScrub(cnJTableType_Table)+') ';
    //ASPrintln('Table Count: '+inttostr(p_DBC.u8GetRecordCount('jtable',saQry,201506171742)));
    saQry:='SELECT JTabl_JTable_UID FROM jtable WHERE '+saQry+' ORDER BY JTabl_Name';
    bOk:=rs.Open(saQry, p_DBC,201503161338);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201210281339,'Trouble with Query.','Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk and (not rs.eol) then
  begin
    i4TotalRows:=0;
    repeat
      //asPrintln('');
      i4Rows:=1;
      clear_JTable(rJTable);
      rJTable.JTabl_JTable_UID:=u8Val(rs.fields.Get_saValue('JTabl_JTable_UID'));
      bOk:=bJAS_Load_JTable(p_Context, p_DBC, rJTable, false, 201608300050);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201210282218, 'Trouble loading jtable record: '+inttostr(rJTable.JTabl_JTable_UID),'',SOURCEFILE);
      end;

      if bOk then
      begin

        if rJTable.JAS_Row_b and rJTable.JTabl_Deleted_b and TGT.bTableExists(rJTable.JTabl_Name,201211260741) then
        begin
          //ASPrintln(p_saName+' Dropping Table: '+rJTable.JTabl_Name);
          saQry:='DROP TABLE '+TGT.sDBMSEncloseObjectName(rJTable.JTabl_Name);
          bOk:=rs2.open(saQry,TGT,201503161339);
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201211260743,'Unable to drop target DB table: '+rJTable.JTabl_Name,'',SOURCEFILE,TGT,rs2);
          end;
          rs2.close;
        end
        else
        begin


          sPKeyName:=p_DBC.saGetValue('jcolumn','JColu_Name',
            '((JColu_Deleted_b<>true)or(JColu_Deleted_b IS NULL)) and '+
            '(JColu_JTable_ID='+p_DBC.sDBMSUIntScrub(rJTable.JTabl_JTable_UID)+') AND '+
            '(JColu_PrimaryKey_b=true)'
          ,201608231624);
          //ASPRintln(' sPKeyName: ' + sPKeyName);


          JASPrint('['+TGT.sName+'] '+rJTable.JTabl_Name);
          if not TGT.bTableExists(rJTable.JTabl_Name,201210282222) then
          begin
            JASPrintln(' Creating');
            //ASPrintln(p_saName+' Creating Table: '+rJTable.JTabl_Name);
            saQry:='select JColu_Name from jcolumn where ((JColu_Deleted_b<>'+p_DBC.sDBMSBoolScrub(true)+')OR(JColu_Deleted_b IS NULL)) AND '+
              '(JAS_Row_b='+p_DBC.sDBMSBoolScrub(true)+') AND (JColu_JTable_ID='+p_DBC.sDBMSUIntScrub(rJTable.JTabl_JTable_UID)+') AND '+
              '(JColu_PrimaryKey_b='+TGT.sDBMSBoolScrub(true)+')';
            bOk:=rs2.Open(saQry,p_DBC,201503161340);
            if not bOk then
            begin
              JAS_LOG(p_Context, cnLog_error, 201210290432,'Trouble with Query.','Query: '+saQry,SOURCEFILE,p_DBC, rs2);
            end;

            if bOk then
            begin
              bOk:= NOT rs2.EOL;
              if not bOK then
              begin
                JAS_LOG(p_Context, cnLog_error, 201210290432,'Table missing Primary Key column: '+rJTable.JTabl_Name,'Query: '+saQry,SOURCEFILE,p_DBC, rs2);
              end;
            end;


            if bOk then
            begin
              if rJTAble.JTabl_Name<>'jlock' then
              begin
                saQry:='CREATE TABLE '+TGT.sDBMSEncloseObjectName(rJTable.JTabl_Name)+'('+
                  TGT.sDBMSEncloseObjectName(rs2.fields.Get_saValue('JColu_Name'))+' bigint(20) unsigned NOT NULL DEFAULT '+TGT.sDBMSUIntScrub(0)+','+
                  'PRIMARY KEY ('+TGT.sDBMSEncloseObjectName(rs2.fields.Get_saValue('JColu_Name'))+') '+
                  ') ENGINE=MyISAM CHARACTER SET utf8 COLLATE utf8_general_ci';
                  //') ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC';
              end
              else
              begin
                saQry:=
                  'CREATE TABLE `jlock` ('+
                  '  `JLock_JLock_UID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,'+
                  '  `JLock_JDConnection_ID` bigint(20) unsigned NOT NULL DEFAULT ''0'','+
                  '  `JLock_Locked_DT` datetime DEFAULT NULL,'+
                  '  `JLock_Table_ID` bigint(20) unsigned NOT NULL DEFAULT ''0'','+
                  '  `JLock_Row_ID` bigint(20) unsigned NOT NULL DEFAULT ''0'','+
                  '  `JLock_Col_ID` bigint(20) unsigned NOT NULL DEFAULT ''0'','+
                  '  `JLock_Username` char(32) DEFAULT NULL,'+
                  '  `JLock_CreatedBy_JUser_ID` bigint(20) unsigned DEFAULT NULL,'+
                  '  `JLock_JSession_ID` bigint(20) unsigned NOT NULL,'+
                  '  PRIMARY KEY (`JLock_JDConnection_ID`,`JLock_Table_ID`,`JLock_Row_ID`,`JLock_Col_ID`),'+
                  '  KEY `AUTO_UID` (`JLock_JLock_UID`)'+
                  ') ENGINE=MyISAM CHARACTER SET utf8 COLLATE utf8_general_ci';
              end;
              rs2.close;
              bOk:=rs2.Open(saQry, TGT,201503161341);
              if not bOk then
              begin
                JAS_LOG(p_COntext, cnLog_Error, 201210291640,'Unable to create new Table: '+rJTable.JTabl_Name,'',SOURCEFILE);
              end;
            end;
            rs2.close;
          end
          else
          begin
            JASPrintln(' Table Exists');
          end;
        end;

        if bOk then
        begin
          saQry:='SELECT JColu_JColumn_UID from jcolumn WHERE '+
            '(JAS_Row_b='+p_DBC.sDBMSBoolScrub(true)+') AND (JColu_JTable_ID='+p_DBC.sDBMSUIntScrub(rJTable.JTabl_JTable_UID)+') ORDER BY JColu_Name';
          bOk:=rs2.Open(saQry, p_DBC,201503161342);
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201210282237, 'Trouble with query.','Query: '+saQry,SOURCEFILE, p_DBC, rs2);
          end;
        end;

        if bOk and (not rs2.EOL) then
        begin
          //asprintln('dbmu - starting loop A');
          repeat
            setlength(arJColumn, length(arJColumn)+1);
            clear_JColumn(arJColumn[length(arJColumn)-1]);
            arJColumn[length(arJColumn)-1].JColu_JColumn_UID:=u8Val(rs2.fields.Get_saValue('JColu_JColumn_UID'));
            bOk:=bJAS_Load_JColumn(p_Context,p_DBC,arJColumn[length(arJColumn)-1],false, 201608300051);
            if not bOk then
            begin
              JAS_LOG(p_Context, cnLog_Error, 201210290001, 'Trouble loading jcolumn: '+inttostr(arJColumn[length(arJColumn)-1].JColu_JColumn_UID),'',SOURCEFILE);
            end;
          until (not bOk) or (not rs2.MoveNext);
          //ASPrintln('dbmu - finished loop A');
        end;
        rs2.close;


        // FOR EACH COLUMN IN JAS -
        // Poll columns
        //   If Not Exists - ADD
        //   IF EXIST - DO ALTER COLUMN ANYWAY in case was changed
        if bOk then
        begin
          //ASPrintln('dbmu - starting loop B');
          for i:=0 to length(arJColumn)-1 do begin
            bColumnExists:=TGT.bColumnExists(rJTable.JTabl_Name, arJColumn[i].JColu_Name,201210290102);
            saQry:='ALTER TABLE '+TGT.sDBMSEncloseObjectName(rJTable.JTabl_Name)+' ';
            bDropColumn:=arJColumn[i].JAS_Row_b and arJColumn[i].JColu_Deleted_b;
            if bColumnExists then
            begin
              if bDropColumn then
              begin
                saQry+='DROP COLUMN '+TGT.sDBMSEncloseObjectName(arJColumn[i].JColu_Name);
                //ASPrintln(p_saName+' Deleting Column: '+rJTable.JTabl_Name+'.'+arJColumn[i].JColu_Name);
                bOk:=rs3.Open(saQry, TGT,201503161343);
                if not bOk then
                begin
                  JAS_LOG(p_Context, cnLog_Error, 201211260801,'Trouble with query.','Query: '+saQry, SOURCEFILE,TGT,rs3);
                end;
                rs3.close;
              end
              else
              begin
                saQRY+='MODIFY ';
                //ASPrintln(p_saName+' Updating Column: '+rJTable.JTabl_Name+'.'+arJColumn[i].JColu_Name);
              end;
            end
            else
            begin
              saQRY+='ADD ';
              //ASPrintln(p_saNAme+' Adding   Column: '+rJTable.JTabl_Name+'.'+arJColumn[i].JColu_Name);
            end;

            if bOk and (not bDropColumn) then
            begin
              saDefault:=arJColumn[i].JColu_DefaultValue;
              if saDefault='EMPTY' then saDefault:='';
              saQry+=JADO.saDDLField(
                arJColumn[i].JColu_Name,
                TGT.u8DbmsID,
                arJColumn[i].JColu_JDType_ID,
                arJColumn[i].JColu_DefinedSize_u,
                arJColumn[i].JColu_NumericScale_u,
                arJColumn[i].JColu_Precision_u,
                saDefault,
                arJColumn[i].JColu_AllowNulls_b,
                arJColumn[i].JColu_AutoIncrement_b,
                false // Clean Field Names - this is to prevent keyword field names.
              );

              if bOk then
              begin
                bOk:=rs3.open(saQry, TGT,201503161344);
                if not bOk then
                begin
                  JAS_Log(p_Context,cnLog_Error, 201210290111, 'bDBMasterUtility - trouble with query to create or alter a column.', 'Query:'+saQry, SOURCEFILE,TGT,rs3);
                  JAS_Log(p_Context,cnLog_Error, 201210301908, 'bDBMasterUtility - Table: '+rJTable.JTabl_Name+' JADO.saDDLField('+
                    arJColumn[i].JColu_Name+','+
                    inttostR(TGT.u8DbmsID)+','+
                    inttostr(arJColumn[i].JColu_JDType_ID)+','+
                    inttostr(arJColumn[i].JColu_DefinedSize_u)+','+
                    inttostr(arJColumn[i].JColu_NumericScale_u)+','+
                    inttostr(arJColumn[i].JColu_Precision_u)+','+
                    arJColumn[i].JColu_DefaultValue+','+
                    sTrueFalse(arJColumn[i].JColu_AllowNulls_b)+','+
                    sTrueFalse(arJColumn[i].JColu_AutoIncrement_b)+','+
                    'false)'
                    ,'', SOURCEFILE
                  );
                end;
              end;
              rs3.close;
            end;
          end;
          //ASPrintln('dbmu - finished loop B');
        end;


        // Copy All rows from Source Table to Destination
        if bOk then
        begin
          if(rJTable.JTabl_Name<>'jlock') and
            (rJTable.JTabl_Name<>'jlog') and
            (rJTable.JTabl_Name<>'jquicknote') and
            (rJTable.JTabl_Name<>'jsession') and
            (rJTable.JTabl_Name<>'jsessiondata') and
            (rJTable.JTabl_Name<>'jdconnection') then
          begin
            //ASPrintln('dbmu - Start Copying Rows');
            saQry:='SELECT * FROM '+p_DBC.sDBMSEncloseObjectName(rJTable.JTabl_Name)+' WHERE 1=1 ';
            bJASRowExists:= p_DBC.bColumnExists(rJTable.JTabl_Name,'JAS_Row_b',201210300008);
            if bJASRowExists then
            begin
              saQry+=' AND (JAS_Row_b='+p_DBC.sDBMSBoolScrub(true)+')';
            end;
            sDelCol:=p_DBC.sGetColumnPrefix(rJTable.JTabl_Name)+'_Deleted_b';
            //saWhere:='';
            bDelColumnExists:=p_DBC.bColumnExists(rJTable.JTabl_Name, sDelCol,201210282245);
            //if bDelColumnExists then
            //begin
            //  saWhere:='(('+p_DBC.sDBMSEncloseObjectName(sDelCol)+'<>'+p_DBC.sDBMSBoolScrub(true)+')OR('+
            //    p_DBC.sDBMSEncloseObjectName(sDelCol)+' IS NULL))';
            //  saQry+=' AND '+saWhere;
            //end;
            bOk:=rs2.Open(saQry, p_DBC,201503161345);
            if not bOk then
            begin
              JAS_LOG(p_Context, cnLog_Error, 201210282258, 'Trouble with query.','Query: '+saQry, SOURCEFILE, p_DBC,rs2);
            end;
          

            if bOk and (not rs2.eol) then
            begin
              //ASPrintln(p_saName+'dbmaster-  Adding/Updating Rows');
              repeat
                saPKeyValue:=rs2.fields.Get_saValue(sPKeyName);

                //ASPRintln('dbmaster-saPKeyValue(sPKeyName:'+sPKeyName+'): ' + saPKeyValue);
                jasprint('.');
                bAbortRow:=false;
                //ASPrint(rJTable.JTabl_Name+' Row: '+inttostr(i4Rows)+' ');
                if (not bDelColumnExists) or
                  (bDelColumnExists and ((rs2.fields.Get_saValue(sDelCol)='NULL') or (NOT bVal(rs2.fields.Get_saValue(sDelCol))))) then
                begin
                  
                  //ASPrintln(rJTable.JTabl_Name+' '+sPKeyName+'='+saPKeyValue+' Row: '+inttostr(i4Rows));
                  if TGT.u8GetRecordCount(rJTable.JTabl_Name,'('+TGT.sDBMSEncloseObjectName(sPKeyName)+'='+saPKeyValue+')',201506171743)=0 then
                  begin
                    // TODO: Might need to check if JAS PKey or Not and the datatype to escape it correctly.
                    // Autonumber columns won't work. jlock table might need to be ignored for this part.
                    // jlock won't have data anyway. Note same kind of issue above making tables with hardcoded pkey data type
                    //ASPrint('Insert ');
                    saQry:='INSERT INTO '+TGT.sDBMSEncloseObjectName(rJTable.JTabl_Name)+' ('+TGT.sDBMSEncloseObjectName(sPKeyName)+') VALUES ('+
                      TGT.sDBMSUIntScrub(saPKeyValue)+')';
                    bOk:=rs3.open(saQry, TGT,201503161346);
                    if not bOk then
                    begin
                      JAS_LOG(p_COntext, cnLog_Error, 201210282335,'Trouble with Query. ','Database: '+TGT.sDatabase+' Query: '+saQry,SOURCEFILE, TGT,rs3);
                    end;
                    rs3.close;
                  end;

                  // BUILD QUERY TO INJECT INTO TARGET TABLE
                  if bOk then
                  begin
                    //ASPrintln('dbmaster - Update - inject tgt table');
                    saQry:='';
                    for i:=0 to length(arJColumn)-1 do
                    begin
                      saColumnValue:=rs2.fields.Get_saValue(arJColumn[i].JColu_Name);
                      //ASPrintln('A Col: '+arJColumn[i].JColu_Name+' Value: '+saColumnValue);
                      if (arJColumn[i].JColu_Name='JASID_ServerIdent') then
                      begin
                        if (p_saName<>'') then saColumnValue:=upcase(p_saName) else saColumnValue:=upcase(TGT.sName);
                      end;
                      if (arJColumn[i].JColu_Name='JTabl_JDConnection_ID') then
                      begin
                        if p_bLeadJet then saColumnValue:='0' else saColumnValue:=inttostr(TGT.ID);
                      end;  
                      //ASPrintln('B Col: '+arJColumn[i].JColu_Name+' Value: '+saColumnValue);
                      bSkipColumn:=false; 

                      //if not bSkipColumn then
                      //begin
                      //  bSkipColumn:=bVal(arJColumn[i].JColu_PrimaryKey_b);
                      //end;

                      if not bSkipColumn then
                      begin
                        bSkipColumn:=arJColumn[i].JColu_Deleted_b;
                      end;

                      
                      if not bAbortRow then
                      begin
                        bAbortRow:=(rJTable.JTabl_Name='jblokfield') and
                                     (arJColumn[i].JColu_Name='JBlkF_JColumn_ID') and
                                     (p_DBC.u8GetRecordCount('jcolumn','JColu_Name='+p_DBC.saDBMSScrub('JAS_Row_b')+' AND '+
                                     'JColu_JColumn_UID='+p_DBC.sDBMSUIntScrub(saColumnValue),201506171744)>0);
                      end;

                      if not bSkipColumn then
                      begin
                        if saQry<>'' then saQry+=','+csCRLF;
                        saQry+=TGT.sDBMSEncloseObjectName(arJColumn[i].JColu_Name)+'=';
                        case arJColumn[i].JColu_JDType_ID of
                        cnJDType_b      : saQry+= TGT.sDBMSBoolScrub(saColumnValue); //< Boolean - b
                        cnJDType_i1     : saQry+= TGT.sDBMSIntScrub(saColumnValue); //< Integer - 01 Byte   i1
                        cnJDType_i2     : saQry+= TGT.sDBMSIntScrub(saColumnValue); //< Integer - 02 Bytes  i2
                        cnJDType_i4     : saQry+= TGT.sDBMSIntScrub(saColumnValue); //< Integer - 04 Bytes  i4
                        cnJDType_i8     : saQry+= TGT.sDBMSIntScrub(saColumnValue); //< Integer - 08 Bytes  i8
                        cnJDType_i16    : saQry+= TGT.sDBMSIntScrub(saColumnValue); //< Integer - 16 Bytes  i16
                        cnJDType_i32    : saQry+= TGT.sDBMSIntScrub(saColumnValue); //< Integer - 32 Bytes  i32
                        cnJDType_u1     : saQry+= TGT.sDBMSUIntScrub(saColumnValue); //< Integer - Unsigned - 01 Byte   u1
                        cnJDType_u2     : saQry+= TGT.sDBMSUIntScrub(saColumnValue); //< Integer - Unsigned - 02 Bytes  u2
                        cnJDType_u4     : saQry+= TGT.sDBMSUIntScrub(saColumnValue); //< Integer - Unsigned - 04 Bytes  u4
                        cnJDType_u8     : saQry+= TGT.sDBMSUIntScrub(saColumnValue); //< Integer - Unsigned - 08 Bytes  u8
                        cnJDType_u16    : saQry+= TGT.sDBMSUIntScrub(saColumnValue); //< Integer - Unsigned - 16 Bytes  u16
                        cnJDType_u32    : saQry+= TGT.sDBMSUIntScrub(saColumnValue); //< Integer - Unsigned - 32 Bytes  u32
                        cnJDType_fp     : saQry+= TGT.sDBMSDecScrub(saColumnValue); //< Floating Point
                        cnJDType_fd     : saQry+= TGT.sDBMSDecScrub(saColumnValue); //< Fixed Decimal Places
                        cnJDType_cur    : saQry+= TGT.sDBMSDecScrub(saColumnValue); //< Currency
                        cnJDType_ch     : saQry+= TGT.saDBMSScrub(saColumnValue); //< Char - ASCII  ch
                        cnJDType_chu    : saQry+= TGT.saDBMSScrub(saColumnValue); //< Char - Unicode  chu
                        cnJDType_dt     : saQry+= TGT.sDBMSDateScrub(saColumnValue); //< DateTime  dt
                        cnJDType_s      : saQry+= TGT.saDBMSScrub(saColumnValue); //< Text - ASCII
                        cnJDType_su     : saQry+= TGT.saDBMSScrub(saColumnValue); //< Text - Unicode
                        cnJDType_sn     : saQry+= TGT.saDBMSScrub(saColumnValue); //< Memo - ASCII
                        cnJDType_sun    : saQry+= TGT.saDBMSScrub(saColumnValue); //< Memo - Unicode
                        cnJDType_bin    : saQry+= TGT.saDBMSScrub(saColumnValue); //< Binary - Binary Large Object
                        else begin
                          //cnJDType_Unknown:  = 00; //< Unknown
                          saQry+= TGT.saDBMSScrub(saColumnValue);
                        end;
                        end;//case
                      end;
                    end;
                    if not bAbortRow then
                    begin
                      saQry:='UPDATE '+TGT.sDBMSEncloseObjectName(rJTable.JTabl_Name)+' SET '+csCRLF+saQry+
                        ' WHERE '+TGT.sDBMSEncloseObjectName(sPKeyName)+'='+TGT.sDBMSUIntScrub(saPKeyValue);
                      bOk:=rs3.Open(saQry,TGT,201503161347);
                      if not bOk then
                      begin
                        JAS_LOG(p_Context, cnLog_Error, 201210290052,'Trouble with query.','Query: '+saQry,SOURCEFILE,TGT,rs3);
                      end;
                      rs3.close;
                    end
                    else
                    begin
                      saQry:='DELETE FROM '+TGT.sDBMSEncloseObjectName(rJTable.JTabl_Name)+
                        ' WHERE '+TGT.sDBMSEncloseObjectName(sPKeyName)+'='+TGT.sDBMSUIntScrub(saPKeyValue);
                      bOk:=rs3.Open(saQry,TGT,201503161348);
                      if not bOk then
                      begin
                        JAS_LOG(p_Context, cnLog_Error, 201212070937,'Trouble with query.','Query: '+saQry,SOURCEFILE,TGT,rs3);
                      end;
                      rs3.close;
                    end;
                    if not bOk then break;
                  end;
                end
                else
                begin
                  //ASPrintln(p_saName+' Deleting Row');
                  saQry:='DELETE FROM '+TGT.sDBMSEncloseObjectName(rJTable.JTabl_Name)+' WHERE '+sPKeyName+'='+TGT.sDBMSUIntScrub(rs2.fields.Get_saValue(sPKeyName));
                  bOk:=rs3.Open(saQry,TGT,201503161349);
                  if not bOk then
                  begin
                    JAS_LOG(p_Context, cnLog_Error, 201210311632,'Trouble with query.','Query: '+saQry,SOURCEFILE,TGT,rs3);
                  end;
                  rs3.close;
                end;
                i4Rows+=1;
              until (not bOk) or (not rs2.movenext);
            end;
            //ASPrintln('dbmu - done copying rows');
          end;
        end;
        rs2.close;
      end;
      i4TotalRows+=(i4Rows-1);

      //ASPRINTLN('Done Injecting Table with Columns');

      // RESET JColumn Array
      for i:=0 to length(arJColumn)-1 do clear_JColumn(arJColumn[i]);
      setlength(arJColumn,0);
      //ASPRINTLN('Done Resetting JColumn Array');


      // ------- JASTABLEMATRIX ------
      // Col1 = tablename
      // col2 = table uid
      // col3 = jdconnection id
      // ------- JASTABLEMATRIX ------
      p_DBC.JASTABLEMATRIX.AppendItem_MATRIX(rJTable.JTabl_Name, inttostr(rJTable.JTabl_JTable_UID),inttostr(TGT.ID));
      //ASPRintln('Past Table Add to Matrix - bottom of loop');
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  //ASPrintln('---- DBMASTERUTILITY -------- Duplicated Database -----------------------------');


  // Update/create VIEWS---------------------------
  if bOk then
  begin
    //asprintln('dmbu - a');
    saQry:='SELECT JTabl_JTable_UID FROM jtable WHERE ((JTabl_Deleted_b<>'+p_DBC.sDBMSBoolScrub(true)+')OR(JTabl_Deleted_b IS NULL)) AND '+
      '(JAS_Row_b='+p_DBC.sDBMSBoolScrub(true)+') AND (JTabl_JTableType_ID='+p_DBC.sDBMSUIntScrub(cnJTableType_View)+') ORDER BY JTabl_Name';
    bOk:=rs.Open(saQry, p_DBC,201503161350);
    if not bOk then
    begin
      JAS_LOG(p_Context,cnLog_Error,201210311258,'Trouble with Query.','Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk and (not rs.eol) then
  begin
    //asprintln('dmbu - b');
    repeat
      i4Rows:=1;
      clear_JTable(rJTable);
      rJTable.JTabl_JTable_UID:=u8Val(rs.fields.Get_saValue('JTabl_JTable_UID'));
      bOk:=bJAS_Load_JTable(p_Context, p_DBC, rJTable, false, 201608300052);
      //ASPrintln('Looping LOAD table: '+inttostr(rJTable.JTabl_JTable_UID)+' >'+rJTable.JTabl_Name+'< bOk '+sYesNo(bOk));
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201210311407, 'Trouble loading jtable record: '+inttostr(rJTable.JTabl_JTable_UID),'',SOURCEFILE);
      end;

      if bOk then
      begin
        //ASPrintln('VIEW: '+rJTable.JTabl_Name);
        case TGT.u8DbmsID of
        cnDBMS_Generic:;
        cnDBMS_MSSQL:     saQry:=rJTable.JTabl_View_MSSQL;
        cnDBMS_MSAccess:  saQry:=rJTable.JTabl_View_MSAccess;
        cnDBMS_MySQL:     saQry:=rJTable.JTabl_View_MySQL;
        cnDBMS_Excel:;
        cnDBMS_dBase:;
        cnDBMS_FoxPro:;
        cnDBMS_Oracle:;
        cnDBMS_Paradox:;
        cnDBMS_Text:;
        cnDBMS_PostGresSQL:;
        cnDBMS_SQLite:;
        end;//switch
        bOk:=rs2.Open(saQry,TGT,201503161351);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error,201210301408,'Unable to create view '+rJTable.JTabl_Name,'Query: '+saQry,SOURCEFILE,TGT,rs2);
        end;
        rs2.close;
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;


  //if bOk and (not p_bLeadJet)then
  //begin
  //  saQry:='ALTER TABLE juser DROP COLUMN JUser_Admin_b';
  //  bOk:=rs.open(saQry, TGT,201503161352);
  //  if not bOk then
  //  begin
  //    JAS_LOG(p_Context, cnLog_Error,201211011835,'Trouble dropping target JUser_Admin_b Column.','Query: '+saQry,SOURCEFILE,TGT,rs);
  //  end;
  //  rs.close;
  //end;

  if bOk and (not p_bLeadJet) then
  begin
    //asprintln('dmbu - c');
    saQry:='delete from jsecperm where Perm_Name='+TGT.saDBMSScrub('Master Admin');
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error,201211022332,'Trouble dropping target JUser_Admin_b Column.','Query: '+saQry,SOURCEFILE,TGT,rs);
    end;
    rs.close;
  end;

  if bOk then p_JDCon_JDConnection_UID:=TGT.ID;
  
  //ASPrintln('DBMaster Utility - Complete - Total Rows: '+inttostr(i4TotalRows));

  result:=bOk;
  TGT.CloseCon;
  TGT.Destroy;
  rs3.destroy;
  rs2.destroy;
  rs.destroy;

  jASPrintln(saREpeatChar('=',79));
  jASPrintln(saREpeatChar('=',79));
  jASPrintln('DB MASTER utility - END');
  jASPrintLn(saREpeatChar('=',79));
  jASPrintLn(saREpeatChar('=',79));


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210271934,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================















//=============================================================================
{}
// Make Default Security Settings
function bSetDefaultSecuritySettings(p_Context: TCONTEXT): Boolean;
//=============================================================================
var
  bOk: Boolean;
  saQry: ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  rs3: JADO_RECORDSET;
  DBC: JADO_CONNECTION;
  XDL: JFC_XDL;
  sa: ansistring;
  saTable: ansistring;
  u8TableID: uint64;
  sScreen: string;
  u8ScreenID: uint64;
  u8SecGrpID: uint64;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bSetDefaultSecuritySettings';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201211022029,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201211022030, sTHIS_ROUTINE_NAME);{$ENDIF}

  JASPrintln('bSetDefaultSecuritySettings - BEGIN');

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  rs3:=JADO_RECORDSET.Create;
  XDL:=JFC_XDL.Create;


  saQry:='DELETE FROM jsecperm';
  bOk:=rs.Open(saQry, DBC,201503161353);
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201211022120,'Trouble with query.','Query: '+saQry, SOURCEFILE);
  end;
  rs.close;

  if bOk then
  begin
    saQry:='DELETE FROM jsecgrplink';
    bOk:=rs.Open(saQry, DBC,201503161354);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211022121,'Trouble with query.','Query: '+saQry, SOURCEFILE);
    end;
    rs.close;
  end;

  if bOk then
  begin
    saQry:='DELETE FROM jsecgrpuserlink';
    bOk:=rs.Open(saQry, DBC,201503161354);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211022122,'Trouble with query.','Query: '+saQry, SOURCEFILE);
    end;
    rs.close;
  end;

  if bOk then
  begin
    saQry:='DELETE FROM jsecgrp';
    bOk:=rs.Open(saQry, DBC,201503161355);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211022123,'Trouble with query.','Query: '+saQry, SOURCEFILE);
    end;
    rs.close;
  end;

  if bOk then
  begin
    JASPrintln('bSetDefaultSecuritySettings - Adding Stock Security Groups');
    XDL.AppendItem_saName_N_saValue('Administrators',inttostr(cnJSecGrp_Administrators));
    XDL.AppendItem_saName_N_saValue('Officiers',inttostr(cnJSecGrp_Officiers));
    XDL.AppendItem_saName_N_saValue('Accounting Managers',inttostr(cnJSecGrp_AccountingManagers));
    XDL.AppendItem_saName_N_saValue('Accounting',inttostr(cnJSecGrp_Accounting));
    XDL.AppendItem_saName_N_saValue('Purchasing Managers',inttostr(cnJSecGrp_PurchasingManagers));
    XDL.AppendItem_saName_N_saValue('Purchasing',inttostr(cnJSecGrp_Purchasing));
    XDL.AppendItem_saName_N_saValue('Advertising Managers',inttostr(cnJSecGrp_AdvertisingManagers));
    XDL.AppendItem_saName_N_saValue('Advertising',inttostr(cnJSecGrp_Advertising));
    XDL.AppendItem_saName_N_saValue('Warehousing Managers',inttostr(cnJSecGrp_WarehousingManagers));
    XDL.AppendItem_saName_N_saValue('Warehousing',inttostr(cnJSecGrp_Warehousing));
    XDL.AppendItem_saName_N_saValue('Sales Managers',inttostr(cnJSecGrp_SalesManagers));
    XDL.AppendItem_saName_N_saValue('Sales',inttostr(cnJSecGrp_Sales));
    XDL.AppendItem_saName_N_saValue('Logistic Managers',inttostr(cnJSecGrp_LogisticManagers));
    XDL.AppendItem_saName_N_saValue('Logistics',inttostr(cnJSecGrp_Logistics));
    XDL.AppendItem_saName_N_saValue('Maintenance Managers',inttostr(cnJSecGrp_MaintenanceManagers));
    XDL.AppendItem_saName_N_saValue('Maintenance',inttostr(cnJSecGrp_Maintenance));
    XDL.AppendItem_saName_N_saValue('Project Managers',inttostr(cnJSecGrp_ProjectManagers));
    XDL.AppendItem_saName_N_saValue('Projects',inttostr(cnJSecGrp_Projects));
    XDL.AppendItem_saName_N_saValue('Case Managers',inttostr(cnJSecGrp_CaseManagers));
    XDL.AppendItem_saName_N_saValue('Cases',inttostr(cnJSecGrp_Cases));
    XDL.AppendItem_saName_N_saValue('Standard',inttostr(cnJSecGrp_Standard));
    
    if XDL.MoveFirst then
    begin
      repeat
        saQry:='INSERT INTO jsecgrp (JSGrp_JSecGrp_UID,JSGrp_Name) VALUES ('+DBC.sDBMSUIntScrub(XDL.Item_saValue)+','+DBC.saDBMSScrub(XDL.Item_saName)+')';
        bOk:=rs.OPen(saQry,DBC,201503161356);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201211022123,'Trouble with query.','Query: '+saQry, SOURCEFILE);
        end;
        rs.close;
      until (not bOk) or (not XDL.MoveNExt);
    end;
    XDL.DeleteAll;
  end;


  if bOk then
  begin
    JASPrintln('bSetDefaultSecuritySettings - Prepping Stock Permissions');
    XDL.AppendItem_saName_N_saValue('Master Admin',inttostr(cnPerm_Master_Admin));
    XDL.AppendItem_saName_N_saValue('Admin',inttostr(cnPerm_Admin));
    XDL.AppendItem_saName_N_saValue('Server Cycle',inttostr(cnPerm_API_CycleServer));
    XDL.AppendItem_saName_N_saValue('Server Shutdown',inttostr(cnPerm_ShutDown_Server));
    XDL.AppendItem_saName_N_saValue('DB Connection JAS',inttostr(cnPerm_DB_Connection_JAS));
    XDL.AppendItem_saName_N_saValue('SQL Tool',inttostr(cnPerm_API_JASSQLTool));
    XDL.AppendItem_saName_N_saValue('Menu Editor',inttostr(cnPerm_API_MenuEditor));
    XDL.AppendItem_saName_N_saValue('Icon Helper',inttostr(cnPerm_Icon_Helper));
    XDL.AppendItem_saName_N_saValue('Copy Security Groups',inttostr(cnPerm_API_CopySecurityGroup));
    if XDL.MoveFirst then
    begin
      repeat
        JASPrintln(XDL.Item_saValue+' '+XDL.Item_saName);
      until not XDL.MoveNext;
    end;
    
    // MAKE PERMISSIONS FOR ALL SCREENS
    saQry:='select JScrn_JScreen_UID, JScrn_Name FROM jscreen '+
      'WHERE ((JScrn_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JScrn_Deleted_b IS NULL)) AND '+
      'JAS_Row_b='+DBC.sDBMSBoolScrub(true)+' '+
      'ORDER By JScrn_Name';
    bOk:=rs.Open(saQry, DBC,201503161357);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211022035, 'Trouble with query.','Query: '+saQry,SOURCEFILE, DBC, rs);
    end;
  end;

  if bOk and (not rs.eol) then
  begin
    JASPrintln('bSetDefaultSecuritySettings - Screen Permissions');
    repeat
      // Based on 50 Char JSecPerm Name Field
      sa:=sGetUID;
      sScreen:=rs.fields.Get_saValue('JScrn_Name');
      u8ScreenID:=u8Val(rs.fields.Get_saValue('JScrn_JScreen_UID'));
      XDL.AppendItem_saName_N_saValue('Screen '+LeftStr(sScreen,43),sa);
      saQry:='UPDATE jscreen SET JScrn_JSecPerm_ID='+DBC.sDBMSUIntScrub(sa)+' WHERE JScrn_JScreen_UID='+DBC.sDBMSUIntScrub(u8ScreenID);
      bOk:=rs2.open(saQry,DBC,201503161358);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201211022139, 'Trouble with query.','Query: '+saQry,SOURCEFILE, DBC, rs);
      end;
      rs2.close;

      if bOk then
      begin
        sa:=sGetUID;
        XDL.AppendItem_saName_N_saValue('Modify Screen '+saLeftStr(sScreen,36),sa);
        saQry:='UPDATE jscreen SET JScrn_Modify_JSecPerm_ID='+DBC.sDBMSUIntScrub(sa)+' WHERE JScrn_JScreen_UID='+DBC.sDBMSUIntScrub(u8ScreenID);
        bOk:=rs2.open(saQry,DBC,201503161359);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201211022139, 'Trouble with query.','Query: '+saQry,SOURCEFILE, DBC, rs);
        end;
        rs2.close;
      end;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;




  if bOk then
  begin
    JASPrintln('bSetDefaultSecuritySettings - Table Permissions');
    saQry:='select JTabl_JTable_UID, JTabl_Name FROM jtable '+
      'WHERE ((JTabl_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+')OR(JTabl_Deleted_b IS NULL)) AND '+
      'JAS_Row_b='+DBC.sDBMSBoolScrub(true)+' '+
      ' ORDER By JTabl_Name';
    bOk:=rs.Open(saQry, DBC,201503161360);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211022036, 'Trouble with query.','Query: '+saQry,SOURCEFILE, DBC, rs);
    end;

    if bOk and (not rs.eol) then
    begin
      repeat
        // Based on 50 Char JSecPerm Name Field
        sa:=sGetUID;
        saTable:=rs.fields.Get_saValue('JTabl_Name');
        u8TableID:=u8Val(rs.fields.Get_saValue('JTabl_JTable_UID'));
        XDL.AppendItem_saName_N_saValue('Table Add '+saLeftStr(saTable,40),sa);
        
        saQry:='UPDATE jtable SET JTabl_Add_JSecPerm_ID='+DBC.saDBMSScrub(sa)+' WHERE JTabl_JTable_UID='+DBC.sDBMSUIntScrub(u8TableID);
        bOk:=rs2.Open(saQry, DBC,201503161361);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201211022143,'Trouble with query.','Query: '+saQry,SOURCEFILE, DBC, rs);
        end;
        rs2.close;
        
        sa:=sGetUID;
        XDL.AppendItem_saName_N_saValue('Table View '+saLeftStr(saTable,39),sa);
        if bOk then
        begin
          saQry:='UPDATE jtable SET JTabl_View_JSecPerm_ID='+DBC.saDBMSScrub(sa)+' WHERE JTabl_JTable_UID='+DBC.sDBMSUIntScrub(u8TableID);
          bOk:=rs2.Open(saQry, DBC,201503161362);
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201211022144,'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC, rs);
          end;
          rs2.close;
        end;

        

        if bOk then
        begin
          sa:=sGetUID;
          XDL.AppendItem_saName_N_saValue('Table Update '+saLeftStr(saTable,37),sa);
          saQry:='UPDATE jtable SET JTabl_Update_JSecPerm_ID='+DBC.saDBMSScrub(sa)+' WHERE JTabl_JTable_UID='+DBC.sDBMSUIntScrub(u8TableID);
          bOk:=rs2.Open(saQry, DBC,201503161363);
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201211022145,'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC, rs);
          end;
          rs2.close;
        end;

        
        if bOk then
        begin
          sa:=sGetUID;
          XDL.AppendItem_saName_N_saValue('Table Delete '+saLeftStr(saTable,37),sa);
          saQry:='UPDATE jtable SET JTabl_Delete_JSecPerm_ID='+DBC.saDBMSScrub(sa)+' WHERE JTabl_JTable_UID='+DBC.sDBMSUIntScrub(u8TableID);
          bOk:=rs2.Open(saQry, DBC,201503161364);
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201211022146,'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC, rs);
          end;
          rs2.close;
        end;

      until (not bOk) or (not rs.movenext);
    end;
    rs.close;
  end;

  if bOk then
  begin
    JASPrintln('bSetDefaultSecuritySettings - Adding Permissions to Database');
    if XDL.MoveFirst then
    begin
      repeat
        saQry:='INSERT INTO jsecperm (Perm_JSecPerm_UID,Perm_Name) VALUES ('+DBC.sDBMSUIntScrub(XDL.Item_saValue)+','+DBC.saDBMSScrub(XDL.Item_saName)+')';
        bOk:=rs.OPen(saQry,DBC,201503161365);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201211022212,'Trouble with query.','Query: '+saQry, SOURCEFILE);
        end;
        rs.close;
      until (not bOk) or (not XDL.MoveNext);
    end;
  end;

  if bOk then
  begin
    JASPrintln('bSetDefaultSecuritySettings - Assigning ALL Permissions to ALL GROUPS');
    saQry:='select JSGrp_JSecGrp_UID from jsecgrp ORDER by JSGrp_Name';
    bOk:=rs.Open(saQry, DBC,201503161366);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211022147,'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC, rs);
    end;
  end;

  if bOk then
  begin
    repeat
      saQry:='SELECT Perm_JSecPerm_UID from jsecperm ORDER BY Perm_Name';
      bOk:=rs2.Open(saQry, DBC,201503161367);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201211022148,'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC, rs);
      end;

      if bOk and (not rs2.EOL) then
      begin
        repeat
          u8SecGrpID:=u8Val(rs.fields.Get_saValue('JSGrp_JSecGrp_UID'));
          if u8SecGrpID<>cnJSecGrp_Standard then
          begin
            saQry:='INSERT INTO jsecgrplink (JSGLk_JSecGrpLink_UID, JSGLk_JSecGrp_ID, JSGLk_JSecPerm_ID) VALUES ( '+
              DBC.sDBMSUIntScrub(u8GetUID)+','+
              DBC.sDBMSUIntScrub(u8SecGrpID)+','+
              DBC.sDBMSUIntScrub(rs2.fields.Get_saValue('Perm_JSecPerm_UID'))+')';
            bOk:=rs3.OPen(saQry,DBC,201503161368);
            if not bOk then
            begin
              JAS_LOG(p_Context, cnLog_Error, 201211022149,'Trouble with query.','Query: '+saQry,SOURCEFILE,DBC, rs);
            end;
            rs3.close;
          end;
        until (not bOk) or (not rs2.movenext);
      end;
      rs2.close;
    until (not bOk) or (not rs.movenext);
  end;
  rs.close;

  JASPrintln('bSetDefaultSecuritySettings - END - bOk: '+sTrueFalse(bOk));
  p_Context.bNoWebCache:=true;
  result:=bOk;
  XDL.Destroy;
  rs3.destroy;
  rs2.destroy;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201211022031,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
{}
procedure DBM_RemoveJet(p_Context: TCONTEXT);
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  JAS: JADO_CONNECTION;
  //TGT: JADO_CONNECTION;
  u: UINT;
  u8UID: uint64;
  u2IOResult: word;
  sa: ansistring;
  rJDCon: rtJDConnection;
  uDBMSOffset: word;
  bSuicide: boolean;
  DIR: JFC_DIR;

  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_RemoveJet';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201211260842,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201211260843, sTHIS_ROUTINE_NAME);{$ENDIF}

  jasprintln('=== Remove Jet Begin =====================');
  bSuicide:=false;
  DIR:=JFC_DIR.Create;
  rs:=JADO_RECORDSET.Create;
  rs2:=JADO_RECORDSET.Create;
  JAS:=p_COntext.DBCON('JAS',201610312259);
  uDBMSOffset:=0;
  u2IOResult:=0;u2IOResult:=u2IOResult;//shut up compiler
  bOk:=p_Context.bSessionValid;
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201608241440, 'Invalid Session','',SOURCEFILE);
    DBM_RenderHtmlErrorPage(p_Context);
  end;

  if bOk then
  begin
    bOk:=p_Context.u2VHost=0;
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201608241040, 'Invalid operation for Jet. Shoot the Jet down from within the main system.','',SOURCEFILE);
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;


  //if bOk then
  //begin
  //  bOK:=p_Context.rJUser.JUser_JUser_UID;
  //  if not bOk then
  //  begin
  //    // complain about system killing itself
  //  end;
  //end;



  if bOk then
  begin
    jasprintln('Session: OK');
    bOk:=bJAS_HasPermission(p_COntext, cnPerm_API_RemoveJet);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201608241441,'You are not authorized to shoot down aircraft.','',SOURCEFILE);
    end;
  end;



  if bOk then
  begin
    jasprintln('User has Remove Jet Permission.');
    if p_Context.rJUser.JUser_JVHost_ID=0 then
    begin
      bOk:=bJAS_HasPermissionAssigned(p_Context, cnPerm_Suicide);
      if not bOk then
      begin
        //JAS_LOG(p_Context, cnLog_Error, 201609031234,'You are not authorized to shoot down the Squadron Leader.','',SOURCEFILE);
        JAS_LOG(p_Context, cnLog_Error, 201609031234,'You do not have a Jet to shoot down at this time.','',SOURCEFILE);
      end
      else
      begin
        bSuicide:=true;
      end;
    end;
  end;

  if bOk then
  begin
    jasprintln('Has Permission Assigned: YES');
    saQry:='select VHost_ServerDomain, VHost_ServerIdent, VHost_JDConnection_ID from '+
      'jvhost where (VHost_JVHost_UID='+JAS.sDBMSUIntScrub(p_Context.rJUser.JUser_JVHost_ID)+') and '+
      '((VHost_Deleted_b = false)OR(VHost_Deleted_b IS NULL))';
    bOk:=rs2.open(saQry,JAS,201608302300);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201608302301,'Trouble looking up virtual host record.','Query: '+saQry,SOURCEFILE);
    end;
  end;

  // gonna grab first record (only)- should only be one, but I'm gonna bomb
  // out if no records are returned.
  if bOk then
  begin
    jasprintln('Opened query to find vhost: '+inttostr(p_Context.rJUser.JUser_JVHost_ID)+' Found: '+sYesNo(rs2.eol = FALSE));
    bOk:=rs2.eol = FALSE; // END OF LIST (recordset) - not empty? Proceed!
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201608302301,'Your virtual host record ' +
        'can not be located. Did you do this already? Query: '+saQry,'',SOURCEFILE);
    end
    else
    begin
      JASPrintln('Have a valid virtual host record. Deleting database from DBMS/storage.');
    end;
  end;


  if bOk then
  begin
    for u:=0 to length(p_Context.JADOC)-1 do
    begin
      if p_Context.JADOC[u].ID=u8Val(rs2.fields.Get_saValue('VHost_JDConnection_ID')) then
      begin
        uDBMSOffset:=u;
        break;
      end;
    end;
  end;

  // Indexfiles
  if bOk then
  begin
    jasprintln('removing jindexfile records next');
    repeat
      u8UID:=u8Val(JAS.saGetValue('jindexfile','JIDX_JIndexFile_UID','(JIDX_JVHost_ID='+JAS.sDBMSUIntScrub(p_Context.rJUser.JUser_JVHost_ID)+') AND '+
        '((JIDX_Deleted_b<>'+JAS.sDBMSBoolScrub(true)+')OR(JIDX_Deleted_b IS NULL))'
      ,201608231625));
      if u8UID > 0 then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,JAS,'jindexfile',u8UID);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201211261520,'Trouble deleting record for table jindexfile. UID: '+inttostr(u8UID),'',SOURCEFILE);
        end;
      end;
    until (not bOk) or (u8UID=0);
  end;
    
  // Alias
  if bOk then
  begin
    jasprintln('Removing jalias records next');
    repeat
      u8UID:=u8Val(JAS.saGetValue('jalias','Alias_JAlias_UID',
        '(Alias_JVHost_ID='+JAS.sDBMSUIntScrub(p_Context.rJUser.JUser_JVHost_ID)+') AND '+
        '((Alias_Deleted_b<>'+JAS.sDBMSBoolScrub(true)+')OR(Alias_Deleted_b IS NULL))'
      ,201608231626));
      if u8UID>0 then
      begin
        bOk:=bJAS_DeleteRecord(p_Context,JAS,'jalias',u8UID);
        if not bOk then
        begin
          JAS_LOG(p_Context, cnLog_Error, 201211261521,'Trouble deleting record for table jalias. UID: '+inttostr(u8UID),'',SOURCEFILE);
        end;
      end;
    until (not bOk) or (u8UID=0);
  end;


  if bOk then
  begin
    jasprintln('Removing security permission for the now removed db connection');
    clear_JDConnection(rJDCon);
    rJDCon.JDCon_JDConnection_UID:=p_Context.JADOC[uDBMSOffset].ID;
    bOk:=bJAS_Load_JDConnection(p_Context, JAS,rJDCon,false, 201608300053);
    if bOk then
    begin
      // JSecPerm - for the DB Connection getting Removed
      bOk:=bJAS_DeleteRecord(p_Context,JAS,'jsecperm',rJDCon.JDCon_JSecPerm_ID);
      if not bOk then
      begin
        JAS_LOG(p_Context, cnLog_Error, 201211271444,'Trouble deleting jsecperm for jdconnection getting removed.','',SOURCEFILE);
      end;
    end
    else
    begin
      // this error can pass
      bOk:=true;
    end;
  end;


  
  // JDConnection
  if bOk then
  begin
    jasprintln('Deleting DB connection');
    bOk:=bJAS_DeleteRecord(p_Context,JAS,'jdconnection',p_Context.JADOC[uDBMSOffset].ID);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211261522,'Trouble deleting record for table jdconnection. UID: '+inttostr(u8UID),'',SOURCEFILE);
    end;
  end;
  
  // Directory - USES OS UTILITY for RECURSIVE DIRECTORY Delete
  // Linux - Gets a shell script to run
  if bOk then
  begin
    //asprintln('dir to remove: '+'../jets/'+lowercase(rs2.fields.Get_saValue('VHost_ServerIdent')));
    if not bSuicide then
      bOk:=DIR.DeleteThis('../jets/'+lowercase(rs2.fields.Get_saValue('VHost_ServerIdent')))
    else //suicide below
      bOk:=DIR.DeleteThis('../jets');

    //bOk:=(u2IOResult=0);
    //if not bOk then
    //begin
    //  //if u2IOResult>32768 then u2IOResult-=32768;
    //  JAS_LOG(p_Context, cnLog_Error, 201608312309, 'Unable to remove '+
    //    'jet directories. Server Ident: '+
    //    rs2.fields.Get_saValue('VHost_ServerIdent'),
    //    'Result: '+inttostr(u2IOResult)+' '+sIOResult(u2IOResult),SOURCEFILE);
    //end;
  end;



  if bOk then
  begin
    //asprintln('dir to remove: '+'../webroot/'+lowercase(rs2.fields.Get_saValue('VHost_ServerIdent')));
    bOk:=DIR.DeleteThis('../webroot/'+lowercase(rs2.fields.Get_saValue('VHost_ServerIdent')));
    //bOk:=(u2IOResult=0);
    //if not bOk then
    //begin
    //  JAS_LOG(p_Context, cnLog_Error, 201608312322, 'Unable to remove '+
    //    'jet directories. Server Ident: '+
    //    rs2.fields.Get_saValue('VHost_ServerIdent'),
    //    'Result: '+inttostr(u2IOResult)+' '+sIOResult(u2IOResult),SOURCEFILE);
    //end;
  end;


  if bOk and bSuicide then
  begin
    bOk:=DIR.DeleteThis('../files/');
    //bOk:=(u2IOResult=0);
    //if not bOk then
    //begin
    //  JAS_LOG(p_Context, cnLog_Error, 201608312323, 'Unable to remove '+
    //    'jet directories. Server Ident: '+
    //    rs2.fields.Get_saValue('VHost_ServerIdent'),
    //    'Result: '+inttostr(u2IOResult)+' '+sIOResult(u2IOResult),SOURCEFILE);
    //end;
  end;




  // Vhost
  if bOk and (not bSuicide) then
  begin
    jasprintln('About to remove the vhost itself now, the last step. UID:'+inttostr(p_Context.rJUser.JUser_JVHost_ID));
    bOk:=bJAS_DeleteRecord(p_Context,JAS,'jvhost',p_Context.rJUser.JUser_JVHost_ID);
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211261523,'Trouble deleting record for table vhost. UID: '+
        inttostr(p_Context.rJUser.JUser_JUser_UID),'',SOURCEFILE);
    end;
    jasprintln('VHOST record should be gone. bOk: '+sYesNo(bok)+' ErrNo: '+inttostr(p_Context.u8ErrNo));
  end;


  if bOk then
  begin
    for u:=0 to length(p_Context.JADOC)-1 do
    begin
      if u > 0 then // because guaranteed 1 element, not 2 or more. (zero based, as its an offset)
      begin
        if (p_Context.JADOC[u].ID=u8Val(rs2.fields.Get_saValue('VHost_JDConnection_ID'))) or bSuicide then
        begin
          //saQry:='DROP DATABASE '+JAS.sDBMSEncloseObjectName('jas_'+lowercase(rs2.fields.Get_saValue('VHost_ServerIdent')));
          saQry:='DROP DATABASE '+JAS.sDBMSEncloseObjectName(p_Context.JADOC[u].sDatabase);
          bOk:=rs.Open(saQry, JAS,201503161369);
          JasPrintln('Drop database >'+p_Context.JADOC[u].sDatabase+' Successfull: '+sYesNo(bOk));
          if not bOk then
          begin
            JAS_LOG(p_Context, cnLog_Error, 201211261518,'Trouble with Query.','Query: '+saQry,SOURCEFILE, JAS, rs);
          end;
          uDBMSOffset:=u;
          if not bSuicide then break;
        end;
      end;
    end;
    rs.close;
  end;

  if bOk and bSuicide then
  begin
    saQry:='DROP DATABASE '+JAS.sDBMSEncloseObjectName(p_Context.JADOC[0].sDatabase);
    bOk:=rs.Open(saQry, JAS,201503161369);
    JasPrintln('Drop database >'+p_Context.JADOC[0].sDatabase+' Successfull: '+sYesNo(bOk));
    if not bOk then
    begin
      JAS_LOG(p_Context, cnLog_Error, 201211261518,'Trouble with Suicide Query.','Query: '+saQry,SOURCEFILE, JAS, rs);
    end;
    JAS_LOG(p_Context, cnLog_Error, 666,'Squadron Destroyed!','Query: '+saQry,SOURCEFILE, JAS, rs);

    if p_Context.u8ErrNo=0 then
    begin
      sa:='Your Squadron has been ';
      if bOk then sa+='successfully ' else sa+='forcefully ';
      sa+='removed.';
      p_Context.saPageTitle:='Success';
      p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_messagewr','',false, 201203122216);
      p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
      p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/places/user-trash.png');
    end
    else
    begin
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end
  else
  begin
    if bOk then
    begin
      jasprintln('Setting user''s jvhost id field to null');
      saQry:='update juser set JUser_JVHost_ID=null where JUser_JUser_UID='+JAS.sDBMSUIntScrub(p_Context.rJUser.JUser_JUser_UID);
      bOk:=rs.open(saQry, JAS,201503161371);
      if not bOk then
      begin
        JAS_LOG(p_COntext, cnLog_Error, 201211261627,'Trouble with query.','Query: ' + saQry, SOURCEFILE, JAS, rs);
      end;
      rs.close;
    end;

    if p_Context.u8ErrNo=0 then
    begin
      sa:='Your JAS Jet has been ';
      if bOk then sa+='successfully ' else sa+='forcefully ';
      sa+='removed.';
      p_Context.saPageTitle:='Success';
      p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_messagewr','',false, 201203122216);
      p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',sa);
      p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/places/user-trash.png');
    end
    else
    begin
      DBM_RenderHtmlErrorPage(p_Context);
    end;
  end;
  p_Context.bNoWebCache:=true;
  DIR.Destroy;
  rs.Destroy;
  rs2.destroy;
  jasprintln('=== Remove Jet End ===================== bOk: '+sYesNo(bOk));

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201211260845,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================















//=============================================================================
{}
function  bDBM_DatabaseScrub(p_Context: TCONTEXT): boolean;
//=============================================================================
var
  bOk: boolean;
  saQry: Ansistring;
  rs,rs2: JADO_RECORDSET;
  i: longint;
  //sa: ansistring;
  iDBX: longint;
  saMsg: ansistring;
  saYouNeed: ansistring;
  {$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='DBM_DatabaseScrub';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201503082206,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201503082207, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  saMsg:='JAS Database Scrubbed of Non-JAS data successfully.';
  saYouNeed:='You need to create a connection, named "SCRUB", that connects to the JAS database to be scrubbed of NON-JAS data.';
  rs:=JADO_RECORDSET.Create;
  
  bOk:=length(p_Context.JADOC)>1;
  if not bOk then
  begin
    // no database connections, therefore nne can be a scrub
    saMsg:='You only have the MAIN database connection. '+saYouNeed;
    JAS_LOG(p_Context, cnLog_Error, 201503082241, 'Unable to find a dataconnection named "SCRUB" to scrub.','',SOURCEFILE);
  end;
  
  if bOk then
  begin
    iDBX:=-1;
    for i:=1 to length(p_Context.JADOC)-1 do
    begin
      if upcase(p_Context.JADOC[i].sName)='SCRUB' then
      begin
        iDBX:=i;
        break;
      end;
    end;
    bOk:=iDBX>=1;
    if not bOk then
    begin
      saMsg:='Unable to locate a database connection named "SCRUB". '+saYouNeed;
    end;
  end;
  
  //wipe smtp credentials from user preferences link table
  //we aren't checking if they exsist first so errors ignored.
  saQry:='update juserpreflink set UsrPL_Value='' where UsrPL_UserPrefLink_UID=2012100615163514292';
  rs.open(saQry,p_Context.JADOC[iDBX],201611041739);
  saQry:='update juserpreflink set UsrPL_Value='' where UsrPL_UserPrefLink_UID=2012100615164495133';
  rs.open(saQry,p_Context.JADOC[iDBX],201611041740);
  saQry:='update juserpreflink set UsrPL_Value='' where UsrPL_UserPrefLink_UID=2012100615162043726';
  rs.open(saQry,p_Context.JADOC[iDBX],201611041741);
  saQry:='delete from jpassword';
  rs.open(saQry,p_Context.JADOC[iDBX],201611041742);
  saQry:='update juser set JUser_Password=''''';
  rs.open(saQry,p_Context.JADOC[iDBX],201611041743);





  if bOk then
  begin
    saQry:='show tables';
    bOk:=rs.open(saQry,p_Context.JADOC[iDBX],201503161372);
    if not bOk then
    begin
      saMsg:='Trouble opening show tables query: '+saQry;
      JAS_LOG(p_Context, cnLog_Error, 201503082242, saMsg,'',SOURCEFILE);
    end;
  end;
  
  if bOk then
  begin
    bOk:=not rs.eol;
    if not bOk then
    begin
      // no tables returned that we can process. Empty Database?
      saMsg:='Zero tables returned. Empty or NON-JAS Database? '+saYOuNeed;
      JAS_LOG(p_Context, cnLog_Error, 201503082243, '','',SOURCEFILE);
    end;
  end;
  
  if bOk then
  begin
    repeat
      // delete from [table] where JAS_Row_b<>true
      if rs.fields.movefirst then
      begin
        saQry:='delete from '+JADO.sDBMSEncloseObjectName(rs.fields.Item_saValue,p_Context.JADOC[iDBX].u8DbmsID);
        rs2:=JADO_RECORDSET.Create;
        if rs2.open('select JAS_Row_b from '+JADO.sDBMSEncloseObjectName(rs.fields.Item_saValue,p_Context.JADOC[iDBX].u8DbmsID),p_Context.JADOC[iDBX],201611041659) then
        begin
          saQry+=' where (JAS_Row_b<>true) or (JAS_Row_b IS NULL) ';
        end;
        rs2.close;
        //ASDebugPrintln('A---'+saQry);
        bOk:=rs2.Open(saQry, p_Context.JADOC[iDBX],201503161373);
        if not bOk then
        begin
          writeln('DatabaseScrub - 201503161373 - trouble executing this query: '+saQry);
         //AS_LOG(p_Context, cnLog_Error, 201503082244, 'Trouble with query: '+saQry,'',SOURCEFILE);
         rs2.close;
         saQry:='delete from ' + JADO.sDBMSEncloseObjectName(rs.fields.Item_saValue,p_Context.JADOC[iDBX].u8DbmsID);
         //ASDebugPrintln('B+++'+saQry);
         if not rs2.open(saQry,p_Context.JADOC[iDBX],201503161374) then
           writeln('DatabaseScrub - 201503161374 - trouble executing this query: '+saQry);

         // views will choke as not updatable generally this is fine,
         // but either way should work as far as a this function goes.
        end;
        bOk:=true;//this is exactly the kind of fail you stop and complain for - its expected.
        rs2.destroy;rs2:=nil;
      end;
    until (not rs.movenext);
  end;
  rs.close;
  
  //if bOk then
  //begin
    //sa:='DATABASE SCRUBBED for distribution. Success: '+sTrueFalse(bOk);
    if bOk then p_Context.saPageTitle:='Success' else p_Context.saPageTitle:='Scrub Failed';
    p_Context.saPage:=saGetPage(p_Context, 'sys_area','sys_page_messagewr','',false, 201203122216);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@MESSAGE@]',saMsg);
    p_Context.PAGESNRXDL.AppendItem_saName_N_saValue('[@PAGEICON@]','<? echo $JASDIRICONTHEME; ?>64/places/user-trash.png');
  //end;
  
  //else
  //begin
  //  DBM_RenderHtmlErrorPage(p_Context);
  //end;
  //p_COntext.bNoWebCache:=true;  
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201503082208,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






















//=============================================================================
Procedure DBM_RenderHtmlErrorPage(p_Context: TCONTEXT);
//=============================================================================
Var saErrTemplate: AnsiString;
    bLoadedTemplateSuccessfully: boolean;
    u2IOResult: word;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='DBM_RenderHtmlErrorPage(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201608141155,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201608141156, sTHIS_ROUTINE_NAME);{$ENDIF}

  //if p_Context.CGIENV.uHTTPResponse=0 then p_Context.CGIENV.uHTTPResponse:=cnHTTP_RESPONSE_200;
  //ASPrintln('CGIError Page - ENTERING ErrorNo:'+inttostr(p_Context.u8ErrNo)+' p_Context.bErrorcondition:'+sTrueFalse(p_Context.bErrorCondition)+' and length(p_Context.saPage):'+inttostr(length(p_Context.saPage)));

  //JAS_Log(p_COntext,cnLog_ERROR,p_Context.u8ErrNo,p_Context.saErrMsg,'',SOURCEFILE);

  // then this
  saErrTemplate:=saJASLocateTemplate(
    'sys_page_error.jas',
    p_Context.sLang,
    p_Context.sTheme,
    p_Context.saRequestedDir,
    201608141157,
    garJVHost[p_Context.u2VHost].VHost_TemplateDir,
    garJVHost[p_Context.u2VHost].VHost_WebShareAlias
  );
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[@PAGETITLE@]','Error '+inttostr(p_Context.u8ErrNo));
  p_Context.sMimeType:=csMIME_TextHtml;
  p_Context.bNoWebCache:=true;
  p_Context.saPage:='';
  //bLoadedTemplateSuccessfully:=bLoadTextFile(saErrTemplate,p_Context.saPage);
  if length(saErrTemplate)>0 then
  begin
    bLoadedTemplateSuccessfully:=bTSLoadEntireFile(saErrTemplate,u2IOResult,p_Context.saPage);
  end
  else
  begin
    bLoadedTemplateSuccessfully:=false;
  end;

  //riteln('201608141158 - TEST - bLoadedTemplateSuccessfully: ' + sYesNo(bLoadedTemplateSuccessfully));

  if(bLoadedTemplateSuccessfully)then
  begin
    if NOT(
       (p_Context.u2ErrorReportingMode <> cnSYS_INFO_MODE_SECURE) and
       ((p_Context.rJSession.JSess_IP_ADDR='127.0.0.1') or (p_Context.rJSession.JSess_IP_ADDR=grJASConfig.sServerIP)) AND
       ((p_Context.u2ErrorReportingMode = cnSYS_INFO_MODE_VERBOSELOCAL) OR (p_Context.u2ErrorReportingMode = cnSYS_INFO_MODE_VERBOSE))
    ) then
    begin
      p_Context.saErrMsgMoreInfo:=grJASConfig.saErrorReportingSecureMessage;
      //ASPrintln('DBM_RenderHtmlErrorPage - NOT Accepted: '+p_Context.saErrMsgMoreInfo);
    end
    else
    begin
      //ASPrintln('DBM_RenderHtmlErrorPage - Accepted');
    end;
    //p_Context.saErrMsg+='Error Message Dispatched Properly via System Template.';
    //p_Context.CGIENV.Header_HtmlNoCook ies;
    p_Context.saPage:=saSNRStr(p_Context.saPage,'[@ERRORNUMBER@]',inttostr(p_Context.u8ErrNo),True);
    p_Context.saPage:=saSNRStr(p_Context.saPage,'[@ERRORMESSAGE@]',p_Context.saErrMsg,True);
    p_Context.saPage:=saSNRStr(p_Context.saPage,'[@ERRORMESSAGEMOREINFO@]',p_Context.saErrMsgMoreInfo,True);

    if (
       (p_Context.u2ErrorReportingMode <> cnSYS_INFO_MODE_SECURE) and
       ((p_Context.rJSession.JSess_IP_ADDR='127.0.0.1') or (p_Context.rJSession.JSess_IP_ADDR=grJASConfig.sServerIP)) AND
       ((p_Context.u2ErrorReportingMode = cnSYS_INFO_MODE_VERBOSELOCAL) OR (p_Context.u2ErrorReportingMode = cnSYS_INFO_MODE_VERBOSE))
    ) then
    begin
      //ASPrintln('MORE INFO LOGXXDL Sent');
      p_Context.saPage:=saSNRStr(p_Context.saPage,'[@LOGXXDL@]',p_Context.LogXXDL.saHTMLTable,True);
    end
    else
    begin
      //ASPrintln('MORE INFO LOGXXDL NOT Sent');
      p_Context.saPage:=saSNRStr(p_Context.saPage,'[@LOGXXDL@]','',True);
    end;
  end
  else
  begin
    p_Context.saErrMsg+='Note: Resorted to raw text response. Unable to dispatch error using configured template:'+saErrTemplate;
    JAS_Log(p_COntext,cnLog_ERROR,p_Context.u8ErrNo,p_Context.saErrMsg,'',SOURCEFILE);
    if NOT(
       (p_Context.u2ErrorReportingMode <> cnSYS_INFO_MODE_SECURE) and
       ((p_Context.rJSession.JSess_IP_ADDR='127.0.0.1') or (p_Context.rJSession.JSess_IP_ADDR=grJASConfig.sServerIP)) AND
       ((p_Context.u2ErrorReportingMode = cnSYS_INFO_MODE_VERBOSELOCAL) OR (p_Context.u2ErrorReportingMode = cnSYS_INFO_MODE_VERBOSE))
    ) then
    begin
      p_Context.saErrMsg:=grJASConfig.saErrorReportingSecureMessage;
    end;
    //p_Context.CGIENV.Header_HtmlNoCook ies;
    p_Context.saPage:=
      saJegasLogoRawHTML+csCRLF+
      '<font style="font-family: monospace">'+
      'Error<br />-----<br />'+
      'Error #:'+inttostr(p_Context.u8ErrNo)+'<br />'+
      'Error Msg:' + p_Context.saErrMsg + '<br /><br />';

    if NOT(
       (p_Context.u2ErrorReportingMode <> cnSYS_INFO_MODE_SECURE) and
       ((p_Context.rJSession.JSess_IP_ADDR='127.0.0.1') or (p_Context.rJSession.JSess_IP_ADDR=grJASConfig.sServerIP)) AND
       ((p_Context.u2ErrorReportingMode = cnSYS_INFO_MODE_VERBOSELOCAL) OR (p_Context.u2ErrorReportingMode = cnSYS_INFO_MODE_VERBOSE))
    ) then
    begin
      p_Context.saPage+='More Info:' + p_Context.saErrMsgMoreInfo + '<br /><br />';
    end;
    p_Context.saPage+='P.S. Unable to find suitable sys_error.jas file in the templating system if you are viewing this.</font>';
  End;
  //riteln('CGIError Page - LEAVING p_Context.bErrorcondition:',p_Context.bErrorCondition, ' and length(p_Context.saPage):',length(p_Context.saPage));
  //riteln('201012261751 - TEST');
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201608141159,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
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

