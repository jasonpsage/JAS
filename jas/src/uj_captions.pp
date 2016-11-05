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
Unit uj_captions;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_caption.pp'}
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
,ug_jfc_xxdl
,ug_jado
,uj_context
,uj_definitions
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
// This function loads the (You must Instantiate) passed JFC_XXDL class with
// caption information for each record found to match the criteria:
//
// XXDL.ID1=JCapt_JCaption_UID      (Note: If you change this change the
// XXDL.ID2=                               comments below and over the function
// XXDL.ID3=JCapt_JCaptGrp_ID              itself )
// XXDL.saValue= JCapt_Value
// XXDL.saDesc= any logical returned data based on
//        "Desired Language" if Not Empty or not found
//                           when searching by UID
//        "Default Language (usually "en")" if not empty
Function bJASLoadCaptionXXDL(
      p_Context: TCONTEXT; //< JAS Thread Context Record
      p_u8CaptionUID: UInt64; {< Specific Caption Being Sought (blank makes ignored)
                                   Sending a Value that equates to <1 makes
                                   this field get ignored. If the value equates
                                   >=1 then the p_saCaptionType and 
                                   p_saCaptionGrp parameters are ignored.
                                   Refers to JCapt_JCaption_UID}
                                  

      p_u8CaptGrp: Uint64;  {< JCapt_JCaptGrp_ID Sought (blank ignores)
                                    Note: If a value is passed in p_saCaptionType
                                    AND p_saCaptionGrp then this 
                                    makes the QUERY itself use AND logic.
                                    by passed, we mean not empty i.e. Value=''}

  Var p_XXDL: JFC_XXDL  {< This returns the result set NOTE default Order
                         is Alphabetical on User's language from database
                         This could be optimized more on the database side
                         Sort alphabetically based on returned data from 
                         both the default JAS language ("en") and the sought
                         language - but for simplicity and not getting
                         deep into SQL logic for portability reasons right
                         now - this is rather simplified.
                        
                         p_XXDL RETURNED FORMAT (Note Caller Must instantiate)
                         ----------------------------------------------------
                         NOTE: XXDL.UID not same as data UID. XXDL.UID is a 
                         unique identifier for that instant of itself for each
                         record in the class itself. Not related to external
                         database in any way.
                         
                        XXDL.ID1=JCapt_JCaption_UID
                        XXDL.ID2=
                        XXDL.ID3=JCapt_JCaptGrp_ID
                        XXDL.saValue= JCapt_Value
                        XXDL.saDesc= any logical returned data based on
                               "Desired Language" if Not Empty or not found
                                                   when searching by UID
                                "Default Language (usually "en")" if not empty}
): Boolean;
//=============================================================================

//=============================================================================
{}
// This is a shorthand way to get a SPECIFIC Caption.
// This is not recommended when its conceivable that you can load a group
// of captions versus hitting this to many times in a row. HOWEVER when you 
// Need a SPECIFIC caption based on language - THEN,NOW, is it there or not?
// This should work fine. It basically is a wrapper for the 
// bJASLoadCaptionXXDL function with a focus on grabbing only ONE record and 
// using this short hand version saves you the symantics of instantiating the
// XXDL class to load with a series of records 
Function bJASCaption(  
  p_Context: TCONTEXT; //< JAS Thread Context Record
  p_u8CaptionUID: Uint64; //< Specific Caption Being Sought
  Var p_saResult: AnsiString; {< This is the result you are after.
                                 If a RECORD can not be found, its returned
                                 EMPTY (''). If a specific LANGUAGE ENTRY
                                 is EMPTY('') but the record exists then the
                                 result is the grJASConfig.saDefaultLanguage
                                 setting's returned value from JCaption.
                                 If this value is empty('') then 
                                 JCapt_Value is returned - unless 
                                  p_saDefault is sent NOT empty(''), in which
                                 case p_saDefault is returned as the result.}
   p_saDefault: AnsiString     {< If passed non-empty, then default is used
                                 instead of JCapt_Value when a language
                                 specific caption doesn't exist.}
                                
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
Function bJASLoadCaptionXXDL(
  p_Context: TCONTEXT; // JAS Thread Context Record
                             // Not finding a caption is not an error.
      p_u8CaptionUID: UInt64; // Specific Caption Being Sought (blank makes ignored)
                                  // Sending a Value that equates to <1 makes
                                  // this field get ignored. If the value equates
                                  // >=1 then the p_saCaptionType and 
                                  // p_saCaptionGrp parameters are ignored.
                                  // Refers to JCapt_JCaption_UID
                                  
      p_u8CaptGrp: UInt64;  // JCapt_JCaptGrp_ID Sought (blank ignores)
                                   // Note: If a value is passed in p_saCaptionType
                                   // AND p_saCaptionGrp then this 
                                   // makes the QUERY itself use AND logic.
                                   // by passed, we mean not empty i.e. Value=''

  Var p_XXDL: JFC_XXDL  // This returns the result set NOTE default Order
                        // is Alphabetical on User's language from database
                        // This could be optimized more on the database side
                        // Sort alphabetically based on returned data from 
                        // both the default JAS language (en) and the sought
                        // language - but for simplicity and not getting
                        // deep into SQL logic for portability reasons right
                        // now - this is rather simplified.
                        
                        // p_XXDL RETURNED FORMAT (Note Caller Must instantiate)
                        // ----------------------------------------------------
                        // NOTE: XXDL.UID not same as data UID. XXDL.UID is a 
                        // unique identifier for that instant of itself for each
                        // record in the class itself. Not related to external
                        // database in any way.
                        //
                        // XXDL.ID1=JCapt_JCaption_UID
                        // XXDL.ID2=
                        // XXDL.ID3=JCapt_JCaptGrp_ID
                        // XXDL.saValue= JCapt_Value
                        // XXDL.saDesc= any logical returned data based on
                        //        "Desired Language" if Not Empty or not found
                        //                           when searching by UID
                        //        "Default Language (usually en)" if not empty
): Boolean;
//=============================================================================
Var
  saQry: AnsiString;
  rs: JADO_RECORDSET;
  bSuccess: Boolean;
  saResult: AnsiString;
  u8Temp1: UInt64; // temp usage
  u8Temp2: Uint64;
  DBC: JADO_CONNECTION;
{$IFDEF ROUTINENAMES} sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bJASLoadCaptionXXDL';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102219,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102220, sTHIS_ROUTINE_NAME);{$ENDIF}




  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  saResult:='';
  saQry:='SELECT '+DBC.saDBMSScrub('JCapt_'+p_Context.sLang)+', '+DBC.saDBMSScrub('JCapt_'+grJASConfig.sDefaultLanguage)+' as JASDEFAULTLANG, ';
  saQry+='JCapt_JCaption_UID, JCapt_JCaptGrp_ID, JCapt_Value ';
  saQry+='FROM jcaption WHERE (JCapt_Deleted_b<>'+DBC.sDBMSBoolScrub(true)+') and ';

  // Logic to Build Query WHERE
  u8Temp1:=p_u8CaptionUID;
  If u8Temp1>0 Then
  Begin
    saQry+='JCapt_JCaption_UID='+inttostr(u8Temp1)+' ';
  End
  Else
  Begin
    u8Temp2:=p_u8CaptGrp;
    If (u8Temp2>0) Then
    Begin
      saQry+='(JCapt_JCaptGrp_ID='+inttostr(u8Temp2)+') ';
    End;
    // NOTE: If noting is passed for a filter - you WILL GET ALL of them!
  End;
  saQry+='ORDER BY '+DBC.saDBMSScrub('JCapt_'+p_Context.sLang);
  If p_Context.sLang<>grJASConfig.sDefaultLanguage Then
  Begin
   saQry+=','+DBC.saDBMSScrub('JCapt_'+grJASConfig.sDefaultLanguage);
  End;
    
  bSuccess:=rs.Open(saQry, DBC,201503161130);
  If not bSuccess Then
  Begin
    JAS_Log(p_Context,cnLog_Error,200702120846,'Unable to Query jcaption table.','Query: '+saQry,SOURCEFILE);
    //RenderHtmlErrorPage(p_Context);
  End;

  If bSuccess Then
  Begin  
    p_XXDL.DeleteAll;
    If not rs.EOL Then
    Begin
      repeat
        p_XXDL.AppendItem;
        p_XXDL.Item_ID1:=u8Val(rs.Fields.Get_saValue('JCapt_JCaption_UID'));
        p_XXDL.Item_ID3:=u8Val(rs.Fields.Get_saValue('JCapt_JCaptGrp_ID'));
        p_XXDL.Item_saValue:=rs.Fields.Get_saValue('JCapt_Value');
        saResult:=rs.Fields.Get_saValue('JCapt_'+p_Context.sLang);
        If (length(trim(saResult))=0) Then
        Begin
          saResult:=rs.Fields.Get_saValue('JASDEFAULTLANG');// Try Default US Langauge
        End;
        If (length(trim(saResult))=0) Then
        Begin
          p_XXDL.Item_saDesc:='';
        End
        Else
        Begin
          p_XXDL.Item_saDesc:=saResult;
        End;
      Until (not rs.MoveNext) OR (not bSuccess);
    End;
  End;
  rs.Destroy;
  Result:=bSuccess;
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102221,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
End;
//=============================================================================





//=============================================================================
// This is a shorthand way to get a SPECIFIC Caption.
// This is not recommended when its conceivable that you can load a group
// of captions versus hitting this to many times in a row. HOWEVER when you 
// Need a SPECIFIC caption based on language - THEN,NOW, is it there or not?
// This should work fine. It basically is a wrapper for the 
// bJASLoadCaptionXXDL function with a focus on grabbing only ONE record and 
// using this short hand version saves you the symantics of instantiating the
// XXDL class to load with a series of records 
Function bJASCaption(  
  p_Context: TCONTEXT; // JAS Thread Context Record
      p_u8CaptionUID: Uint64; // Specific Caption Being Sought
  Var p_saResult: AnsiString;   // This is the result you are after.
                                // If a RECORD can not be found, its returned
                                // EMPTY (''). If a specific LANGUAGE ENTRY
                                // is EMPTY('') but the record exists then the
                                // result is the grJASConfig.saDefaultLanguage
                                // setting's returned value from JCaption.
                                // If this value is empty('') then 
                                // JCapt_Value is returned - unless 
                                // p_saDefault is sent NOT empty(''), in which
                                // case p_saDefault is returned as the result.
    p_saDefault: AnsiString     // If passed non-empty, then default is used
                                // instead of JCapt_Value when a language
                                // specific caption doesn't exist.
                                
): Boolean;                               
//=============================================================================
Var
  bOk: Boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;

{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='bJASCaption';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102222,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102223, sTHIS_ROUTINE_NAME);{$ENDIF}

  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;

  saQry:=
    'SELECT '+
    '  '+DBC.sDBMSEncloseObjectName('JCapt_'+p_Context.sLang)+' , '+
    '  '+DBC.sDBMSEncloseObjectName('JCapt_'+grJASConfig.sDefaultLanguage)+' as JASDEFAULTLANG, '+
    '  JCapt_Value '+
    'FROM jcaption '+
    'WHERE '+
    '  ((JCapt_Deleted_b='+DBC.sDBMSBoolScrub(false)+') or (JCapt_Deleted_b is null)) and '+
    '  (JCapt_JCaption_UID='+DBC.sDBMSUIntScrub(p_u8CaptionUID)+')';
  {$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203261900, sTHIS_ROUTINE_NAME+' In Query');{$ENDIF}
  bOk:=rs.open(saQry,DBC,201503161131);
  //ASPrintln('');
  //asprintln('qry:'+saQry);
  //ASPrintln('');

  {$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203261901, sTHIS_ROUTINE_NAME+' Back from Query');{$ENDIF}
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201203111628, 'Trouble with Query',{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME+' '+{$ENDIF}'Query: '+saQry, SOURCEFILE, DBC, rs);
  end;

  if bOk then
  begin
    if rs.eol then
    begin
      p_saResult:=p_saDefault;
    end
    else
    begin
      //p_saResult:=trim(rs.fields.Get_saValue('JCapt_'+p_Context.sLang)+' top JCapt_'+p_Context.sLang)+' value>'+trim(rs.fields.Get_saValue('JCapt_'+p_Context.sLang)+'<');
      p_saResult:=trim(rs.fields.Get_saValue('JCapt_'+p_Context.sLang));
      if (length(p_saResult)=0) then
      begin
        p_saResult:=trim(rs.fields.Get_saValue('JASDEFAULTLANG'))+' 2nd';
        if (length(p_saResult)=0) then
        begin
          p_saResult:=trim(rs.fields.Get_saValue('JCapt_Value'));
          if (length(p_saResult)=0) then
          begin
            p_saResult:=p_saDefault+' def';
          end;
        end;
      end;
    end;
  end;

  rs.close;

  rs.Destroy;
  Result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102223,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
