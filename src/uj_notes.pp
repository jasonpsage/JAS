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
Unit uj_notes;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_notes.pp'}
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
,ug_jegas
,ug_jado
,uj_permissions
,uj_context
,uj_definitions
,uj_tables_loadsave
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
// This function makes it realatively easy to get notes from the JAS database's 
// jnote table.
Function bJASNote(
  p_Context: TCONTEXT; //< JAS Thread Context Record
      p_u8NoteID: uint64; //< Specific Note Being Sought
  Var p_saResult: AnsiString; //< Notes come back in here.
      p_saDefault: AnsiString  {< Value to return if p_saNotesUID='0' or
                                can not be found.
                                NOTE: p_saDefault is only used when
                                note Record Cannot be found OR
                                note Record is Found and the 
                                Current Language field is empty
                                AND the default US field is empty 
                                also.}
): Boolean;
//=============================================================================



//=============================================================================
{}
// Language is taken into consideration!
//
// This function makes it realatively easy to get notes from the JAS database's
// jnote table. providing the user has the security permission for the
// specified table and or table/row combination in JNote_Table_ID and
// the optional JNote_Row_ID
//
// See Also JAS_GetNoteSecure in uxxj_application (where dispatched from)
// and uxxj_fileserv.pp
Function bJASNoteSecure(
  p_Context: TCONTEXT; //< JAS Thread Context Record
      p_u8NoteID: uint64; //< Specific Note Being Sought
  Var p_saResult: AnsiString; //< Notes come back in here.
      p_saDefault: AnsiString  {< Value to return if p_saNotesUID='0' or
                                can not be found.
                                NOTE: p_saDefault is only used when
                                note Record Cannot be found OR
                                note Record is Found and the
                                Current Language field is empty
                                AND the default US field is empty
                                also.}
): Boolean;
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
Function bJASNote(
  p_Context: TCONTEXT; // JAS Thread Context Record
      p_u8NoteID: uint64; // Specific Note Being Sought
  Var p_saResult: AnsiString;
      p_saDefault: AnsiString  // Value to return if p_saCaptionID='0' or 
                               // can not be found.
                               // NOTE: p_saDefault is only used when
                               // note Record Cannot be found OR
                               // note Record is Found and the 
                               // Current Language field is empty
                               // AND the default US field is empty 
                               // also.
): Boolean;
//=============================================================================
Var saQry: AnsiString;
    rs: JADO_RECORDSET;
    bOk: Boolean;
    saResult: AnsiString;
    DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJASNote(p_Context: TCONTEXT;p_saNotesUID: AnsiString;Var p_saResult: AnsiString;p_saDefault: AnsiString): Boolean;'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102471,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102472, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saResult:='';
  //ASPrintln('14322 bJASNote - p_Context.saLang: '+p_Context.saLang);
  if (p_Context.sLang='') or (upcase(p_Context.sLang)='NUL') then p_Context.sLang:='en';
  if (grJASConfig.sDefaultLanguage='') or (upcase(grJASConfig.sDefaultLanguage)='NULL') then grJASConfig.sDefaultLanguage:='en';

  saQry:='SELECT JNote_'+p_Context.sLang+', JNote_'+grJASConfig.sDefaultLanguage+' as DEFAULTLANG FROM jnote '+
    'WHERE JNote_JNote_UID='+DBC.sDBMSUIntScrub(p_u8NoteID)+' and '+
    'JNote_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203261858, sTHIS_ROUTINE_NAME + ' In Query');{$ENDIF}
  bOk:=rs.Open(saQry, DBC,201503161000);
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203261858, sTHIS_ROUTINE_NAME + ' Back from Query');{$ENDIF}
  If not bOk Then
  Begin
    //legacy_RenderHTMLErrorPage(p_Context, 200702120847,'Unable to Query jnote table for JNote_JNote_UID='+p_saNotesUID+' Qry:'+saQry);
    saResult:='Unable to Load Notes - Err code:200702120847';
  End;
  If bOk Then
  Begin  
    If not rs.EOL Then
    Begin
      if rs.Fields.FoundItem_saName('JCapt_'+p_Context.sLang) then
      begin
        saResult:=rs.Fields.Item_saValue;
      end
      else
      begin
        if rs.Fields.FoundItem_saName('DEFAULTLANG') then
        begin
          saResult:=rs.Fields.Item_saValue;
        end
        else
        begin
          saResult:=p_saDefault;
        end;
      end;
    End;
    rs.Close;
  End;
  p_saResult:=saResult;
  rs.Destroy;
  Result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102473,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================













//=============================================================================
Function bJASNoteSecure(
  p_Context: TCONTEXT; // JAS Thread Context Record
      p_u8NoteID: uint64; // Specific Note Being Sought
  Var p_saResult: AnsiString;
      p_saDefault: AnsiString  // Value to return if p_saCaptionID='0' or
                               // can not be found.
                               // NOTE: p_saDefault is only used when
                               // note Record Cannot be found OR
                               // note Record is Found and the
                               // Current Language field is empty
                               // AND the default US field is empty
                               // also.
): Boolean;
//=============================================================================
Var
  saQry: AnsiString;
  rs: JADO_RECORDSET;
  bOk: Boolean;
  saResult: AnsiString;
  DBC: JADO_CONNECTION;
  rJNote: rtJNote;
  sLangColumn: ansistring;
  saCurrentLang: ansistring;
  rJTable: rtJTable;
  bAdd,bView,bUpdate,bDelete: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJASNoteSecure'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}DebugIn(sTHIS_ROUTINE_NAME,SourceFile);{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102471,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102472, sTHIS_ROUTINE_NAME);{$ENDIF}
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  sLangColumn:='JNote_'+p_Context.sLang;
  saResult:='';
  saQry:='SELECT '+sLangColumn+', '+
    'JNote_en as DEFAULTLANG, JNote_JTable_ID, JNote_JColumn_ID, JNote_Row_ID '+
    'FROM jnote '+
    'WHERE JNote_JNote_UID='+DBC.sDBMSUIntScrub(p_u8NoteID)+' and '+
    ' JNote_Deleted_b<>'+DBC.sDBMSBoolScrub(true);
  bOk:=rs.Open(saQry, DBC,201503161001);
  If not bOk Then
  Begin
    //legacy_RenderHTMLErrorPage(p_Context, 200702120847,'Unable to Query jnote table for JNote_JNote_UID='+p_saNotesUID+' Qry:'+saQry);
    saResult:='201101131501: Unable to Load Secure Note';
  End;
  If bOk Then
  Begin
    If not rs.EOL Then
    Begin
      saCurrentLang:=rs.fields.Get_saValue(sLangColumn);
      clear_JNote(rJNote);
      with rJNote do begin
        //JNote_JNote_UID          : ansistring;
        JNote_JTable_ID           :=u8Val(rs.fields.Get_saValue('JNote_JTable_ID'));
        JNote_JColumn_ID          :=u8Val(rs.fields.Get_saValue('JNote_JColumn_ID'));
        JNote_Row_ID              :=u8Val(rs.fields.Get_saValue('JNote_Row_ID'));
        //JNote_Orphan_b            : ansistring;
        JNote_en                  :=rs.fields.Get_saValue('DEFAULTLANG');
        //JNote_Created_DT          : ansistring;
        //JNote_CreatedBy_JUser_ID  : ansistring;
        //JNote_Modified_DT         : ansistring;
        //JNote_ModifiedBy_JUser_ID : ansistring;
        //JNote_DeletedBy_JUser_ID  : ansistring;
        //JNote_Deleted_DT          : ansistring;
        //JNote_Deleted_b           : ansistring;
        //JAS_Row_b                 : ansistring;
      end;

      if (rJNote.JNote_JTable_ID>0) then
      begin
        clear_JTable(rJTable);
        rJTable.JTabl_JTable_UID:=rJNote.JNote_JTable_ID;
        bOk:=bJAS_Load_JTable(p_Context, DBC, rJTable, false,201608310003);
        if not bOk then
        begin
          //JLog(p_Context, cnLog_Error, 201211051535,'Unable to Load Table Record - Table ID: '+rJNote.JNote_JTable_ID,'',SOURCEFILE);
          saResult:='201211051535: Unable to Load Table Record - Table ID: '+inttostr(rJNote.JNote_JTable_ID);
        end;
      end;

      if bOk then
      begin
        bOk:=bJAS_TablePermission(
          p_Context,
          rJTable,
          rJNote.JNote_Row_ID,
          0,
          bAdd,bView,bUpdate,bDelete,
          false,true,false,false
        );
        if not bOk then
        begin
          //JAS_LOG(p_Context, cnLog_Error, 201211051651,'Unable to test table security permissions. Table: '+rJTable.JTabl_Name+' Row: '+rJNote.JNote_Row_ID,'',SOURCEFILE);
          saResult:='201211051651: Unable to test table security permissions. Table: '+rJTable.JTabl_Name+' Row: '+inttostr(rJNote.JNote_Row_ID);
        end;
      end;

      if bOk and bView then
      begin
        if length(trim(saCurrentLang))=0 then
        begin
          saResult:=rJNote.JNote_en;
        end
        else
        begin
          saResult:=saCurrentLang;
        end;
      end;
    End;
    rs.Close;
  End;
  p_saResult:=saResult;
  rs.Destroy;
  Result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}DebugOut(sTHIS_ROUTINE_NAME,SourceFile);{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203092471,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
