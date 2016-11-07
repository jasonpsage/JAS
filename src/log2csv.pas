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
{}
//
// SEARCH: !@! - Defines      !#! - Functions/Procedures
//
// this program: Converts apache logs (default format) into CSV files which
// can help importing data into some systems.
//
// Usage: log2csv src-file dest-file     (single file, no wild carding)
//
// Sample Input
//   127.0.0.1 - - [17/Feb/2016:09:47:23 -0500] "GET /index.php/admin HTTP/1.1" 0 0 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0"
//
// Sample Output
// "filename","127.0.0.1","2016-02-17 09:47:23","-0500","GET /index.php/admin HTTP/1.1","Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0"
//
//
// Global Directives
//
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='log2csv.pas'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
{$DEFINE RELEASE}
program log2csv; // !@!
//=============================================================================

//=============================================================================
Uses //!@!
//=============================================================================
sysutils
,dos
,ug_common
,ug_jegas
,ug_misc
,ug_jfc_tokenizer
;
//=============================================================================







//=============================================================================
const // !@!
//=============================================================================
  //---------------------------------------------------------------------------
  // Application info
  //---------------------------------------------------------------------------
  csJBU_AppTitle       = 'Jegas log2csv';
  csJBU_AppProductName = 'Jegas log2csv';
  csJBU_AppMajor       = '0';//Feel like i own the univrse... ;)
  csJBU_AppMinor       = '0';//super awesomeness
  csJBU_AppRevision    = '1';// I revise per day or major awesomeness factor
  //---------------------------------------------------------------------------
//=============================================================================




//=============================================================================
//var             // !@!
//=============================================================================
//  gu8Count_Errors: uint64;
//=============================================================================







{$IFDEF DEBUG_ROUTINE_NESTING}
//=============================================================================
procedure DebugRoutineIn(p_saRoutineName: ansistring);
//=============================================================================
begin
  write('-->  |');
  gi8RoutineNestLvl+=1;
  if gi8RoutineNestLvl>1 then write(saRepeatChar('-',gi8RoutineNestLvl));
  writeln(p_saRoutineName);
end;
//=============================================================================

//=============================================================================
procedure DebugRoutineOut(p_saRoutineName: ansistring);
//=============================================================================
begin
  write('<--  |');
  if gi8RoutineNestLvl>1 then write(saRepeatChar('-',gi8RoutineNestLvl));
  gi8RoutineNestLvl-=1;
  writeln(p_saRoutineName);
end;
//=============================================================================
{$ENDIF}

//=============================================================================
procedure WriteSeparator(p_bStart: boolean; p_saName: ansistring);// !#!
//=============================================================================
{$IFDEF DEBUG_ROUTINE_NESTING}const csRoutineName='WriteSeparator';{$ENDIF}
var i: integer;
begin
{$IFDEF DEBUG_ROUTINE_NESTING}DebugRoutineIn(csRoutineName);{$ENDIF}
  for i:=0 to 1 do write(saRepeatChar('=',79)+csCRLF);
  if p_bStart then write('BEGIN ') else write('END ');
  for i:=0 to 1 do write(saRepeatChar('=',79)+csCRLF);
{$IFDEF DEBUG_ROUTINE_NESTING}DebugRoutineOut(csRoutineName);{$ENDIF}
end;
//=============================================================================



//=============================================================================
//procedure LogError(p_id: uint64; p_saErr:ansistring);// !#!
//=============================================================================
{$IFDEF DEBUG_ROUTINE_NESTING}
//const csRoutineName='LogError';
{$ENDIF}
//var sa: ansistring;
//begin
{$IFDEF DEBUG_ROUTINE_NESTING}
//DebugRoutineIn(csRoutineName);
{$ENDIF}
//  gu8Count_Errors+=1;
//  sa:=inttostr(p_id)+' - '+p_saErr;
//  //riteln(sa);
{$IFDEF DEBUG_ROUTINE_NESTING}
//DebugRoutineOut(csRoutineName);
{$ENDIF}
//end;
//=============================================================================






{IFNDEF WINDOWS}
//=============================================================================
function bLog2CSV:boolean;// !#!
//=============================================================================
{$IFDEF DEBUG_ROUTINE_NESTING}const csRoutineName='bPermRestore';{$ENDIF}
var
  bOk: boolean;
  TK: JFC_TOKENIZER;
  saSrc: ansistring;
  saDest: ansistring;
  u2ioresult: word;
  fin,fout: text;
  bOpenIn,bOpenOut: boolean;
  sa:ansistring;
  saToken: ansistring;
  bFirstLine: boolean;
  bErrLog: boolean;
  saCols: ansistring;
  i: longint;
  bAppending: boolean;
  dir,name,ext:string;
  sSrcFilename: string;
begin
{$IFDEF DEBUG_ROUTINE_NESTING}DebugRoutineIn(csRoutineName);{$ENDIF}
  TK:=JFC_TOKENIZER.create;
  bOpenin:=false;
  bOpenOut:=false;
  bFirstLine:=true;

  bOk:=paramcount=2;
  if bOk then
  begin
    saSrc:=paramstr(1);
    saDest:=paramstr(2);
    FSplit(saSrc,dir,name,ext);
    sSrcFileName:=name+ext;
    bOk:=bOk and FileExists(saSrc);
    if not bOk then
    begin
      //LogError(201602231549,'Source File does not (appear) to exist: '+sSrc);
    end;
  end;

  if not bOk then
  begin
    writeln('Usage: log2csv sourcefile destination - try log2csv --help');
  end;

  if bOk then
  begin
    bAppending:=fileexists(saDest);
    assign(fin,saSrc);
    assign(fout,saDest);
  end;


  if bOk then
  begin
    try
      reset(fin);
    except on E:Exception do bOk:=false;
    end;//try
    u2IOResult:=ioresult;bOk:=bOk and (u2IOResult=0);bOpenIn:=bOk;
    //if not bOk then
    //begin
      //LogError(201511251955,'IOResult: '+inttostr(u2IOREsult)+' '+
      //  sIOResult(u2IOREsult)+'. Unable to open this file in read only mode: '+
      //  sSrc);
    //end;
    bOpenIn:=bOk;
  end;


  if bOk then
  begin
    try
      if bAppending then append(fout) else rewrite(fout);
    except on E:Exception do bOk:=false;
    end;//try
    u2IOResult:=ioresult;bOk:=bOk and (u2IOResult=0);bOpenIn:=bOk;
    if not bOk then
    begin
      //LogError(201602231836,'IOResult: '+inttostr(u2IOREsult)+' '+
      //  saIOResult(u2IOREsult)+'. Unable to open this file for writing: '+
      //  saDest);
    end;
    bOpenOut:=bOk;
  end;


// Sample Input
//   127.0.0.1 - - [17/Feb/2016:09:47:23 -0500] "GET /index.php/admin HTTP/1.1" 0 0 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0"
//
// Sample Output
// "filename","127.0.0.1","2016-02-17 09:47:23","-0500","GET /index.php/admin HTTP/1.1","Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0"

  if bOk then
  begin
    while (not EOF(fin)) do begin
      readln(fin,sa);
      if LeftStr(sa,1)='[' then
      begin
        bErrLog:=true;
        //TK.saLastOne:='';
        //TK.bCaseSensitive:=False;
        //TK.bKeepDebugInfo:=False;
        TK.AppendQuotePair('[',']');
        TK.sQuotes:='';
        TK.sWhiteSpace:='';//csCRLF+'';
        TK.sSeparators:='';//csCRLF+'';
      end else
      if (LeftStr(sa,1)>='0') and (LeftStr(sa,1)<='9') then
      begin
        bErrLog:=false;
        //TK.saLastOne:='';
        //TK.bCaseSensitive:=False;
        //TK.bKeepDebugInfo:=False;
        TK.sQuotes:='"';
        TK.sWhiteSpace:=csCRLF+' "';
        TK.sSeparators:=csCRLF+' ';
      end else
      begin
        //LogError(201602231631,'Doesn''t seem like the right kind of log file.');
        halt(1);// so what of it? I took another door out! So? Crybaby!... me too :( lol
      end;

      TK.Tokenize(sa);
      if TK.MoveFirst then
      begin
        saToken:=TK.Item_saToken;
        if bFirstLine then
        begin
          //riteln('LeftStr(saToken,1): ',LeftStr(saToken,1));
        end;

        if bErrLog then
        begin
          if bFirstLine then saCols:='ERRLG_LogFile';
          sa:='"'+sSrcFilename+'"';

          if bFirstLine then saCols+=', ERRLG_When_dt';

          //INBOUND - Fri Jan 22 05:38:35 2016   <---- cnDateFormat_23
          //OUTBOUND - 'YYYY-MM-DD HH:NN:SS';//ZERO PADDED Military time   <--- cnDateFormat_21
          satoken:=TK.ITem_saToken;
          //riteln('DATE TOKEN ERR LOG: ' + saToken);
          sa+=',"'+JDate(saToken, cnDateFormat_24 ,cnDateFormat_23)+'"';
          if TK.MoveNext and TK.Movenext then
          begin
            if bFirstLine then saCols+=', ERRLG_Type';
            sa+=',"'+TK.ITem_saToken+'"';

            if TK.MoveNext and TK.Movenext then
            begin
              saToken:=TK.Item_saToken;
              if bFirstLine then saCols+=', ERRLG_IPAddress';
              sa+=',"'+saRightStr(saToken,length(saToken)-7)+'"';

              if TK.Movenext then
              begin
                saToken:=TK.Item_saToken;
                if bFirstLine then saCols+=', ERRLG_Message';
                sa+=',"'+saSNRStr(RightStr(saToken,length(saToken)-1),'"','[DBLQUOTE]')+'"';
              end;
            end;
          end;
        end
        else
        begin
          if bFirstLine then saCols:='ACCLG_LogFile, ACCLG_IPAddress';
          sa:='"'+sSrcFilename+'"'+
              ',"'+TK.ITem_saToken+'"';
          if TK.MoveNExt and TK.MoveNExt and tk.movenext then
          begin
            if bFirstLine then saCols+=',ACCLG_When_dt';
            saToken:=TK.ITem_saTOken;
            sa+=',"'+saMid(saToken,9,4)+'-';//year
            for i:=1 to 12 do
            begin
              //riteln('i:',i,'>',UPcase(gasMonth[i]),'< >',upcase(saMid(saToken,5,3)));
              if UPcase(leftstr(gasMonth[i],3))=upcase(saMid(saToken,5,3)) then
              begin
                 sa+=inttostr(i)+'-';//month
              end;
            end;
            sa+=saMid(saToken,2,2)+' ';//day
            sa+=saMid(saToken,14,2)+':';//hour24
            sa+=saMid(saToken,17,2)+':';//minutes
            sa+=saMid(saToken,20,2)+'"';//second

            if TK.MoveNext then
            begin
              saToken:=TK.Item_saToken;
              if bFirstLine then saCols+=', ACCLG_TimeZone';
              sa+=',"'+saLeftStr(saToken,5)+'"';
              if tk.movenext then
              begin
                saToken:=TK.Item_saToken;
                if bFirstLine then saCols+=', ACCLG_Request';
                sa+=',"'+saSNRStr(saToken,'"','[DBLQUOTE]')+'"';

                if tk.movenext and tk.movenext and tk.movenext then
                begin
                  saToken:=TK.Item_saToken;
                  if bFirstLine then saCols+=', ACCLG_Server';
                  sa+=',"'+saSNRStr(saToken,'"','[DBLQUOTE]')+'"';
                  if tk.movenext then
                  begin
                    saToken:=TK.Item_saToken;
                    if bFirstLine then saCols+=', ACCLG_Client';
                    sa+=',"'+saSNRStr(saToken,'"','[DBLQUOTE]')+'"';
                  end;
                end;
              end;
            end;
          end;
        end;

        //writeln;
        //writeln;
        //writeln('=============');
        //writeln;
        //writeln('---');
        //writeln(saCols);
        //writeln('---');
        writeln(sa);
        //if TK.MoveFirst then
        //begin
        //  repeat
        //    writeln(TK.N,':',TK.Item_saToken);
        //  until not tk.movenext;
        //end;
        //writeln('=============');
        //write('Press [ENTER] to proceed.');
        //readln;
        if bFirstLine and (not bAppending) then
        begin
          writeln(fout,saCols);
        end;
        writeln(fout,sa);
      end;



      tk.deleteall;
      if bFirstLine then bFirstLine:=false;
    end;//while
  end;
  if bOpenIn then close(fin);
  if bOpenOut then close(fout);


  TK.Destroy;
  result:=bOk;
{$IFDEF DEBUG_ROUTINE_NESTING}DebugRoutineOut(csRoutineName);{$ENDIF}
end;
//=============================================================================
{ENDIF}








//=============================================================================
var bMAIN_Ok: boolean;
begin // !#!
{$IFDEF DEBUG_ROUTINE_NESTING}DebugRoutineIn('COMMAND LINE');{$ENDIF}
  bMAIN_Ok:=bLog2CSV;
{$IFDEF DEBUG_ROUTINE_NESTING}DebugRoutineOut('COMMAND LINE');{$ENDIF}
  if bMAIN_Ok then halt(0) else halt(1);
end.
//=============================================================================


//*****************************************************************************
// EOF
//*****************************************************************************

