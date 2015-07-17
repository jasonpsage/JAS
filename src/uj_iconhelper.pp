{==============================================================================
|    _________ _______  _______  ______  _______  Jegas, LLC                  |
|   /___  ___// _____/ / _____/ / __  / / _____/  JasonPSage@jegas.com        |
|      / /   / /__    / / ___  / /_/ / / /____                                |
|     / /   / ____/  / / /  / / __  / /____  /                                |
|____/ /   / /___   / /__/ / / / / / _____/ /                                 |
/_____/   /______/ /______/ /_/ /_/ /______/                                  |
|                 Under the Hood                                              |
===============================================================================
                       Copyright(c)2012 Jegas, LLC
==============================================================================}

//=============================================================================
{}
// JAS Specific Functions
Unit uj_iconhelper;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_iconhelper.pp'}
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
,syncobjs
,sysutils
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_tokenizer
,ug_jado
,uj_context
,uj_definitions
,uj_permissions
,uj_ui_stock
,uj_fileserv
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
//()
//cnAction_JIconHelper = 44
// Sample usages:
// http://10.1.10.3:81/?Action=44&subaction=ICONTHEMECREATOR&name=test&placeholdericons=false
// http://10.1.10.3:81/?Action=44&subaction=ICONTHEMECREATOR&name=test2&placeholdericons=true
// http://10.1.10.3:81/?Action=44&subaction=ICONTHEMEANALYZER&name=test
// http://10.1.10.3:81/?Action=44&subaction=ICONTHEMEANALYZER&name=Nuvola
Procedure JIconHelper(p_Context: TCONTEXT);
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
Procedure ICONTHEMECREATOR(p_Context: TCONTEXT);
//=============================================================================
var 
  bOk: boolean;
  u2IOREsult: word;
  saTemplateName: ansistring;
  saPathDefaultOveride: ansistring;
  saPath: ansistring;
  saSP: ansistring; //size path
  //saCP: ansistring;//context path
  saSrcMissingIconFile: ansistring;
  saSrcIconHelper: ansistring;
  saDestFile: ansistring;
  saQry: ansistring;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  rs2: JADO_RECORDSET;
  iSize: integer;
  bCopyMissingPNGFile: boolean;
  saOutPut: ansistring;
  TK: JFC_TOKENIZER;
  saTKPath: ansistring;
  saWorkPath: ansistring;
  bFailIfUnableToCreateDir: boolean;
  {$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME: String;{$ENDIF}



                            // Begin ------- Tokenize Path
                            function saTokenizePathAndCreate(p_saStartHere: ansistring; p_saTokenizeThis: ansistring): ansistring;
                            // Begin ------- Tokenize Path
                            begin
                              {$IFDEF DEBUGLOGBEGINEND}
                                DebugIn(sTHIS_ROUTINE_NAME+'.saTokenizePathAndCreate',SourceFile);
                              {$ENDIF}
                              {$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102342,sTHIS_ROUTINE_NAME+'.saTokenizePathAndCreate',SOURCEFILE);{$ENDIF}
                              {$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102343, sTHIS_ROUTINE_NAME+'.saTokenizePathAndCreate');{$ENDIF}
                              TK.SetDefaults;
                              //TK.bKeepDebugInfo:=true;
                              TK.saSeparators:=csDOSSLASH;
                              TK.saWhiteSpace:='';
                              TK.Tokenize(p_saTokenizeThis);
                              //TK.DumpToTextFile('tk.IHCO_JIconContext_UID.'+rs.fields.Get_saValue('IHCO_IHCO_JIconContext_UID')+'.txt');
                              //ASPrintLn('test 150');
                              if TK.MoveFirst then 
                              begin
                                //ASPrintLn('test 160');
                                result:=p_saStartHere;
                                repeat
                                  //ASPrintLn('test 170');
                                  result+=TK.Item_saToken+csDOSSLASH;
                                  if not fileexists(p_saStartHere+result) then
                                  begin
                                    bOk:=CreateDir(result) or (bFailIfUnableToCreateDir=false);
                                    if not bOk then
                                    begin
                                      JAS_Log(p_Context,cnLog_Error, 201008032056, 'Icon Helper - Unable to create directory: '+result,'',SOURCEFILE,nil,nil);
                                      RenderHtmlErrorPage(p_Context);
                                    end;      
                                  end;
                                until (not bOk) or (not TK.MoveNext);
                              end;
                            // End ------- Tokenize Path
                            {$IFDEF DEBUGLOGBEGINEND}
                              DebugOut(sTHIS_ROUTINE_NAME+'.saTokenizePathAndCreate',SourceFile);
                            {$ENDIF}
                            {$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102344,sTHIS_ROUTINE_NAME+'.saTokenizePathAndCreate',SOURCEFILE);{$ENDIF}
                            end;
                            // End ------- Tokenize Path
                            
                            
                            
                            
                            
                            // Begin ------- ProcessIcon
                            Procedure ProcessIcon(p_iSize: integer);
                            // Begin ------- ProcessIcon
                            begin
                              {$IFDEF DEBUGLOGBEGINEND}
                                DebugIn(sTHIS_ROUTINE_NAME+'.ProcessIcon(p_iSize: integer);',SourceFile);
                              {$ENDIF}
                              {$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102347,sTHIS_ROUTINE_NAME+'.ProcessIcon(p_iSize: integer);',SOURCEFILE);{$ENDIF}
                              {$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102348, sTHIS_ROUTINE_NAME+'.ProcessIcon(p_iSize: integer);');{$ENDIF}

                              if not (p_iSize<=0) then // this allows fixed directories to have their saSP path set before calling this
                              begin
                                saSP:=saPath+inttostR(p_iSize)+csDOSSlash;
                              end;
                              saWorkPath:=trim(rs.fields.Get_saValue('IHCO_Directory'));
                              if (saWorkPath<>'NULL') and (length(saWorkPath)>0) then
                              begin
                                saWorkPath:=saTokenizePathAndCreate(saSP, saWorkPath);
                              end
                              else
                              begin
                                saWorkPath:=saSP;
                              end;
                              //ASPrintln('GOT DIR TO PROCESS: '+ saWorkPath);
                
                              saSrcIconHelper:=saSNRSTR(saSrcMissingIconFile,'[@SIZE@]',inttostR(p_iSize));
                              //ASPrintln('saSrcIconHelper: '+saSrcIconHelper);
                                          
                              saDestFile:=saWorkPath+rs2.fields.Get_saValue('IHMA_Name')+'.png';
                              if(bCopyMissingPNGFile) and (not fileexists(saDestfile)) then
                              begin
                                bOk:=bCopyfile(saSrcIconHelper, saDestfile, u2IOResult);
                                if not bOk then
                                begin
                                  JAS_Log(p_Context,cnLog_Error, 201008020452, 'Icon Helper - Trouble copying Icon place holder file. IO Result:'+
                                   saIOResult(u2IOResulT) ,'Source: '+saSrcIconHelper+' Destination: '+saDestfile,SOURCEFILE,nil,nil);
                                  RenderHtmlErrorPage(p_Context);
                                end
                                else
                                begin
                                  saOutPut+='Added: '+saDestfile+#9+rs2.fields.Get_saValue('ICMA_Desc')+csCRLF;
                                end;
                              end;
                            // End ------- ProcessIcon
                              {$IFDEF DEBUGLOGBEGINEND}
                                DebugOut(sTHIS_ROUTINE_NAME+'.ProcessIcon(p_iSize: integer);',SourceFile);
                              {$ENDIF}
                              {$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102349,sTHIS_ROUTINE_NAME+'.ProcessIcon(p_iSize: integer);',SOURCEFILE);{$ENDIF}
                            end;
                            // End ------- ProcessIcon
                            


Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='ICONTHEMECREATOR(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102340,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102341, sTHIS_ROUTINE_NAME);{$ENDIF}

  //ASPrintLn('test 10');
  DBC:=p_Context.VHDBC;
  rs:=JADO_RECORDSET.Create;
  //ASPrintLn('test 20');
  rs2:=JADO_RECORDSET.Create;
  //ASPrintLn('test 30');
  TK:=JFC_TOKENIZER.Create;
  //ASPrintLn('test 40');
  
  bCopyMissingPNGFile:=bVal(p_Context.CGIENV.DataIn.Get_saValue('placeholdericons'));
  bFailIfUnableToCreateDir:=bVal(p_Context.CGIENV.DataIn.Get_saValue('failifunabletocreatedir'));
  saOutput:='';
  
  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,201204140324,'Session is not valid. You need to be logged in and have permission to access this resource.','',SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  End;

  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context, cnJSecPerm_IconHelper);
    If not bOk Then
    Begin
      JAS_Log(p_Context,cnLog_Error,201204301253,'You need to have "Icon Helper" permission to access this resource.','',SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    End;
  end;


  if bOk then
  begin
    saTemplateName:=trim(p_Context.CGIENV.DataIn.Get_saValue('Name'));
    bOk:=length(satemplateName)>0;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201008011138, 'Icon Helper - Invalid New Template Directory Name: '+saTemplateName,'',SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;
  //ASPrintLn('test 50');

  if bOk then
  begin
    saPathDefaultOveride:=trim(p_Context.CGIENV.DataIn.Get_saValue('path'));
    if length(saPathDefaultOveride)>0 then
    begin
      if saRightStr(saPathDefaultOveride,1)<>csDOSSLASH then saPathDefaultOveride+=csDOSSLASH;
      saPath:=saPathDefaultOveride;
    end
    else
    begin
      saPath:=grJASConfig.saSysDir+'webshare'+csDOSSLASH+'img'+csDOSSLASH+'icon'+csDOSSLASH+'themes'+csDOSSLASH+saTemplateName+csDOSSLASH;
    end;
    //bOk := (FALSE = bDirExists(saPath));
    //bOk := (FALSE = fileexists(saPath));
    //if not bOk then
    //begin
    //  JAS_Log(p_Context,cnLog_Error, 201008011139, 'Icon Helper - New Template Directory Exists: '+saPath,'',SOURCEFILE);
    //  RenderHtmlErrorPage(p_Context);
    //end;
  end;
  
  //ASPrintLn('test 60');
  if bOk then
  begin
    bOk := CreateDir(saPath) or (bFailIfUnableToCreateDir=false);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201008011140, 'Icon Helper - Unable to Create New Template Directory: '+saPath,'',SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;
    
  if bOk then 
  begin
    saSrcMissingIconFile:=grJASConfig.saSysDir+'webshare'+csDOSSLASH+'img'+csDOSSLASH+'icon'+csDOSSLASH+'JAS'+csDOSSLASH+'iconhelper'+csDOSSLASH+'missing-[@SIZE@].png';
  end;    
  
  //ASPrintLn('test 70');
  if bOk then
  begin
    saSP:=saPath+'fixed'+csDOSSlash;
    bOk:=CreateDir(saSP) or (bFailIfUnableToCreateDir=false);;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201008021932, 'Icon Helper - Unable to create directory: '+saSP,'',SOURCEFILE,nil,nil);
      RenderHtmlErrorPage(p_Context);
    end;      
  end;


  //ASPrintLn('test 80');
  if bOk then
  begin
    saQry:='select * from jiconcontext where IHCO_Deleted_b<>'+DBC.saDBMSBoolScrub(true);
    bOk:=rs.Open(saQry, DBC,201503161600);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201008011142, 'Icon Helper - Unable to open query.','Query: '+saQry,SOURCEFILE,DBC,rs);
      RenderHtmlErrorPage(p_Context);
    end;
  end;
  
  //ASPrintLn('test 90');
  if bOk then
  begin
    bOk:=rs.eol=false;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201008032028, 'Icon Helper - jiconcontext table has zero records.','Query: '+saQry,SOURCEFILE,DBC,rs);
      RenderHtmlErrorPage(p_Context);
    end;
  end;
  
  //ASPrintLn('test 100');
  if bOk then
  begin
    repeat
      //ASPrintLn('test 110');
      if bVal(rs.fields.Get_saValue('IHCO_Fixed')) then
      begin
        saSP:=saPath;
        bOk:=CreateDir(saSP) or (bFailIfUnableToCreateDir=false);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_Error, 201008032037, 'Icon Helper - Unable to create directory: '+saSP,'',SOURCEFILE,nil,nil);
          RenderHtmlErrorPage(p_Context);
        end;      
        saTKPath:=saSP;
      end
      else
      begin
        //ASPrintLn('test 120');
        for iSize:=1 to 11 do 
        begin
          //ASPrintLn('test 130');
          if bOk then
          begin
            case iSize of 
             1: begin saSP:=saPath+'16'+csDOSSlash;   end;
             2: begin saSP:=saPath+'22'+csDOSSlash;   end;
             3: begin saSP:=saPath+'24'+csDOSSlash;   end;
             4: begin saSP:=saPath+'32'+csDOSSlash;   end;
             5: begin saSP:=saPath+'48'+csDOSSlash;   end;
             6: begin saSP:=saPath+'64'+csDOSSlash;   end;
             7: begin saSP:=saPath+'72'+csDOSSlash;   end;
             8: begin saSP:=saPath+'96'+csDOSSlash;   end;
             9: begin saSP:=saPath+'128'+csDOSSlash;  end;
            10: begin saSP:=saPath+'256'+csDOSSlash;  end;
            11: begin saSP:=saPath+'512'+csDOSSlash;  end;
            end;//switch
            if not fileexists(saSP) then
            begin
              bOk:=CreateDir(saSP) or (bFailIfUnableToCreateDir=false);
              if not bOk then
              begin
                JAS_Log(p_Context,cnLog_Error, 201008011141, 'Icon Helper - Unable to create directory: '+saSP,'',SOURCEFILE,nil,nil);
                RenderHtmlErrorPage(p_Context);
              end;      
            end;
            
            //ASPrintLn('test 140');
            if bOk then
            begin
              saWorkPath:=trim(rs.fields.Get_saValue('IHCO_Directory'));
              if (saWorkPath<>'NULL') and (length(saWorkPath)>0) then
              begin
                saTKPath:=saTokenizePathAndCreate(saSP, saWorkPath);
              end;
            end;
          end;
        end;
      end;
      
      if bOk then
      begin
        // Got Directory - COOL! 
        // Next - Look up All Files that go in the Various Places
        // with the matching dir jcontextMASTER.IHCO_JIconMaster_ID
        saQry:='select * from jiconmaster '+
          'where IHMA_JIconContext_ID='+rs.fields.Get_saValue('IHCO_JIConContext_UID')+' and '+
          'IHMA_Deleted_b<>'+DBC.saDBMSBoolScrub(true);

        bOk:=rs2.open(saQry, DBC,201503161601);
        if not bOk then
        begin
          JAS_Log(p_Context,cnLog_Error, 201008041610, 'Icon Helper - Trouble opening Query processing directory: '+saTKPath,'Query: '+saQry,SOURCEFILE,DBC,rs2);
          RenderHtmlErrorPage(p_Context);
        end;
        
        if bOk and (rs2.eol=false) then
        begin
          repeat
            //IHMA_JIconMaster_UID
            //IHMA_Name
            //IHMA_Desc
            //IHMA_JIconContext_ID
            //IHMA_Standard_b
            
            
            // for each check if they go in a particular size folder
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Size_16_b' )) then ProcessIcon(16);
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Size_22_b' )) then ProcessIcon(22);
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Size_24_b' )) then ProcessIcon(24);
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Size_32_b' )) then ProcessIcon(32);
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Size_48_b' )) then ProcessIcon(48);
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Size_64_b' )) then ProcessIcon(64);
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Size_72_b' )) then ProcessIcon(72);
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Size_96_b' )) then ProcessIcon(96);
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Size_128_b')) then ProcessIcon(128);
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Size_256_b')) then ProcessIcon(256);
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Size_512_b')) then ProcessIcon(512);
            
            //rs2.fields.Get_saValue('IHMA_Directory');
            if bOk and bVal(rs2.fields.Get_saValue('IHMA_Fixed_b')) then
            begin
              saSP:=saPath+csDOSSlash;
              ProcessIcon(0);
            end;


          until (not bOk) or (not rs2.movenext);
        end;
        rs2.close;
        
      end;
    until (not bOk) or (not rs.movenext);    
  end;
  rs.close;  
  
  if bOk and (not p_Context.bErrorCondition) then
  begin
    p_Context.saPage:=saJegasLogoRawText(csCRLF, true)+csCRLF;
    p_Context.saPage+=saREpeatChar('-',80)+csCRLF;
    p_Context.saPage+='JAS Icon Helper - New Template created ';
    if bCopyMissingPNGFile then
    begin
      p_Context.saPage+='WITH place holder icons.';
    end
    else
    begin
      p_Context.saPage+='WITHOUT place holder icons.';
    end;
    
    p_Context.saPage+=csCRLF+saRepeatChar('-',80)+csCRLF;
    p_Context.saPage+='Location: '+saPath+csCRLF;
    //p_Context.saPage+=saRepeatChar('-',80)+csCRLF;
    p_Context.saPage+=saOutput;
    p_Context.saPage+=saREpeatChar('-',80)+csCRLF;
    p_Context.saPage+=' EOF - End of File'+csCRLF;
    p_Context.saPage+=saREpeatChar('-',80)+csCRLF;
    p_Context.CGIENV.Header_PlainText(garJVHostLight[p_Context.i4VHost].saServerIdent);
    p_Context.CGIENV.iHttpResponse:=cnHTTP_RESPONSE_200;
    p_Context.bOutputRaw:=true;
  end;

  rs.destroy;
  rs2.destroy;
  TK.Destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102342,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
//.?ACTION=44&SUBACTION=ThemeTools
procedure ThemeTools(p_Context: TCONTEXT);
//=============================================================================
var bOk: boolean;
{$IFDEF ROUTINENAMES}var  sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='ThemeTools(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102349,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102350, sTHIS_ROUTINE_NAME);{$ENDIF}


//Function saGetPage(
//  p_Context: TCONTEXT; 
//  //var p_bErrorOccurred: boolean;
//  p_saArea: AnsiString;
//  p_saPage: AnsiString; 
//  p_saSection: AnsiString;
//  p_bSectionOnly: Boolean;
//  p_saCustomSection: AnsiString;
//  p_i8Caller: int64
//): AnsiString;

  bOk:=p_Context.bSessionValid;
  If not bOk Then
  Begin
    JAS_Log(p_Context,cnLog_Error,201204140325,'Session is not valid. You need to be logged in and have permission to access this resource.','',SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  End;

  if bOk then
  begin
    p_Context.saPage:=saGetPage(p_Context,'','sys_iconhelper','main',false,'',123020100052);
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOut(201203102351,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
//cnAction_JIconHelper = 44
Procedure JIconHelper(p_Context: TCONTEXT);
//=============================================================================
var 
  bOk: boolean;
  saSubAction: ansistring;
  bHandled: boolean;
{$IFDEF ROUTINENAMES} sTHIS_ROUTINE_NAME: String;{$ENDIF}
Begin
{$IFDEF ROUTINENAMES}sTHIS_ROUTINE_NAME:='JIconHelper(p_Context: TCONTEXT);';{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102351,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102352, sTHIS_ROUTINE_NAME);{$ENDIF}

  bOk:=true;
  bHandled:=false;
  
  if bOk then
  begin
    bOk:=p_Context.bSessionValid;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201008011136, 'Icon Helper Not Available Unless you are logged in.','',SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;
  
  if bOk then
  begin
    bOk:=bJAS_HasPermission(p_Context,cnJSecPerm_IconHelper);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error, 201008011137,
        'Access Denied - You do not have "JAS Icon Helper" privilege.',
        'JUser_Name:'+p_Context.rJUser.JUser_Name,SOURCEFILE);
      RenderHtmlErrorPage(p_Context);
    end;
  end;    

  saSubAction:=UpperCase(p_Context.CGIENV.DataIn.Get_saValue('SUBACTION'));
  if bOk and (not bHandled) then
  begin
    if saSubAction='ICONTHEMECREATOR' then
    begin
      ICONTHEMECREATOR(p_Context);
      bHandled:=true;
    end;
  end;
  
  if bOk and (not bHandled) then
  begin
    if saSubAction='THEMETOOLS' then
    begin
      ThemeTools(p_Context);
      bHandled:=true;
    end;
  end;


  if bOk and (not bHandled) then
  begin
    JAS_Log(p_Context,cnLog_Error, 201008020022, 'IconHelper - Invalid SubAction passed: '+saSubAction,'p_Context.CGIENV.DataIn.Get_saValue(''SUBACTION''): '+p_Context.CGIENV.DataIn.Get_saValue('SUBACTION'),SOURCEFILE);
    RenderHtmlErrorPage(p_Context);
  end;  

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102353,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
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
