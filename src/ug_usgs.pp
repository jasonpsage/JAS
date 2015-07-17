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
// Contains routines to convert USGS Satellite Data to Bitmap
Unit ug_usgs;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_usgs.pp'}
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
uses
//=============================================================================
  sysutils
  ,ug_common
  ,ug_jegas
  ,ug_jfc_tokenizer
  ,ug_pixelgrid
  ,ug_tlbr
  ,ug_rgba
;
//=============================================================================



//============================================================================
// begin                          JGC_USGS
//============================================================================
const USGS_ABSOLUTEZERO = -5.0;

//----------------------------------------------------------------------------
// Shrinks a USGS GridFloat Map by skipping specific number of data points
// Called Floats
function USGSMapConvert(
  p_i4FloatsToSkip: longint;
  p_saFilename_FloatFile_NoExtension: ansistring;
  p_saOutFile_NoExtension: ansistring
): boolean;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
{}
// Converts USGS GridFloat format to bitmap
// You can pass a progress bar functions in a GUI along with the class instance
// (so you get the right memory location when using it)
// Pass NIL to OPT out of using the progress bar callback
function USGSMapToBitMap(
  p_bGrayScale: boolean;
  p_saFilename_FloatFile_NoExtension: ansistring;
  p_saOutFile_NoExtension: ansistring;
  p_iDesiredSize: integer;
  p_fScale: single;
  p_lpfnProgressBar: pointer;
  p_lpfnFormInstance: pointer;
  p_bRegistered: boolean
):word;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Converts USGS GridFloat format to RAW16
// You can pass a progress bar functions in a GUI along with the class instance
// (so you get the right memory location when using it)
// Pass NIL to OPT out of using the progress bar callback
function USGSMapToRaw16(
  //p_i4DesiredSize: longint;
  p_saFilename_FloatFile_NoExtension: ansistring;
  p_saOutFile_WithExtension: ansistring;
  p_iDesiredSize: integer;
  p_fScale: single;
  p_lpfnProgressBar: pointer;
  p_lpfnFormInstance: pointer;
  p_bRegistered: boolean
): word;
//----------------------------------------------------------------------------

//============================================================================





//============================================================================
//============================================================================
//============================================================================
//============================================================================
                               Implementation
//============================================================================
//============================================================================
//============================================================================
//============================================================================










//============================================================================
//----------------------------------------------------------------------------
function USGSMapConvert(
  p_i4FloatsToSkip: longint;
  p_saFilename_FloatFile_NoExtension: ansistring;
  p_saOutFile_NoExtension: ansistring
): boolean;
//----------------------------------------------------------------------------
var
  i4FileRows: longint;
  i4FileCols: longint;
  saFileIn: ansistring;
  saFileOut: ansistring;
  saData: ansistring;
  TK: JFC_TOKENIZER;
  ft: text;
  fin: file of single;
  fout: file of single;
  fSingle: single;
  u2IOResult: word;
  x: longint;
  z: longint;
  i4Across: longint;
  i4Down: longint;
  bWriteIt: boolean;
  bOk: boolean;
begin
  writeln('USGS Map Convert - Started.');

  i4FileRows:=0;
  i4FileCols:=0;
  
  TK:=JFC_TOKENIZER.Create;
  TK.saWhitespace:=' ';
  TK.saSeparators:=' ';
  saFileIn:=p_saFilename_FloatFile_NoExtension+'.hdr';
  bOk:=FileExists(saFileIn);
  if bOk then
  begin
    assign(ft,saFileIn);
    {$I-}
    reset(ft);
    {$I+}
    u2IOResult:=IOResult;
    bOk:=u2IOResult=0;
  end;

  if bOk then
  begin
    readln(ft,saData);
    TK.Tokenize(saData);
    //TK.DumpToTextfile('test.txt');
    if(TK.MoveFirst) then
    begin
      if TK.Item_saToken='ncols' then
      begin
        if Tk.MoveNext then
        begin
          i4FileCols:=iVal(TK.Item_saToken);
        end;
      end;
      readln(ft,saData);
      TK.Tokenize(saData);
      if TK.MoveFirst then
      begin
        if TK.Item_saToken='nrows' then
        begin
          if Tk.MoveNext then
          begin
            i4FileRows:=iVal(TK.Item_saToken);
          end;
        end;
      end;
    end;
    close(ft);
    bOk:= (i4FileCols>0) and (i4FileRows>0);
  end;

  if bOk then
  begin
    saFileIn:=p_saFilename_FloatFile_NoExtension+'.flt';
    saFileOut:=p_saOutFile_NoExtension+'.flt';
    x:=0;z:=0;fSingle:=0;

    assign(fin,saFileIn);
    {$I-}
    reset(fin);
    {$I+}
    u2IOResult:=IOResult;
    bOk:=u2IOResult=0;
  end;

  if bOk then
  begin
    assign(fout,saFileOut);
    {$I-}
    rewrite(fout);
    {$I+}
    u2IOResult:=IOResult;
    bOk:=u2IOResult=0;
  end;

  if bOk then
  begin
    i4Across:=0;
    i4Down:=0;
    bWriteIt:=false;
    for z:=0 to i4FileRows-1 do begin
      for x:=0 to i4FileCols-1 do begin
        read(fin,fSingle);
        bWriteIt:=false;
        if(p_i4FloatsToSkip=0)then
        begin
          bWriteIt:=true;
        end
        else
        begin
          if( ((x mod p_i4FloatsToSkip)=0) and ((z mod p_i4FloatsToSkip)=0) )then
          begin
            bWriteIt:=true;
          end;
        end;
        if(bWriteIt)then
        begin
          if(i4Down=0)then i4Across:=i4Across+1;
          if(i4Down<i4Across)then
          begin
            write(fout,fSingle);
          end;
        end;
      end;
      if(p_i4FloatsToSkip=0)then
      begin
        i4Down:=i4Down+1;
      end
      else
      begin
        if(z mod p_i4FloatsToSkip)=0 then
        begin
          i4Down:=i4Down+1;
        end;
      end;
    end;
    close(fin);
    close(fout);
    saFileOut:=p_saOutFile_NoExtension+'.hdr';

    assign(ft,saFileOut);
    {$I-}
    rewrite(ft);
    {$I+}
    u2IOResult:=IOResult;
    bOk:=u2IOResult=0;
  end;

  if bOk then
  begin
    writeln(ft,'ncols ',i4Across);
    writeln(ft,'nrows ',i4Down);
    close(ft);
  end;//if file exist
  TK.Destroy;
  result:=bOk;
end;
//----------------------------------------------------------------------------










//----------------------------------------------------------------------------
function USGSMapToBitMap(
  p_bGrayScale: boolean;
  p_saFilename_FloatFile_NoExtension: ansistring;
  p_saOutFile_NoExtension: ansistring;
  p_iDesiredSize: integer;
  p_fScale: single;
  p_lpfnProgressBar: pointer;
  p_lpfnFormInstance: pointer;
  p_bRegistered: boolean
):word;
//----------------------------------------------------------------------------
var
  i4FileRows: longint;
  i4FileCols: longint;
  saFileIn: ansistring;
  saFileOut: ansistring;
  saData: ansistring;
  pg: TPixelGrid;
  tk: jfc_tokenizer;
  ft: text;
  bOk: boolean;
  x: longint;
  z: longint;
  fSingle: single;
  fin: file of single;
  //bWriteIt: boolean;
  fHighest: single;
  fLowest: single;
  fNormalizer: single;
  //px: longint;
  //py: longint;
  fValue: single;
  u2IOResult: word;
  u1: byte;
  u4c: rt4ByteCast;
  //i4: longint;

  i4Rows: longint;
  i4CurrentRow: longint;

  lpfnProgressBar: procedure (p_i4Fill: longint; p_i4Value: longint; p_i4Max: longint; p_lpfnFormInstance: pointer);
  lpfnFormInstance: pointer;
  RGBA: TRGBA;
  u4: cardinal;
begin
  RGBA:=TRGBA.Create(255,255,255,255);
  pointer(lpfnProgressBar):=p_lpfnProgressBar;
  lpfnFormInstance:=p_lpfnFormInstance;

  bOk:=true;
  i4Rows:=0;
  i4CurrentRow:=0;
  i4FileRows:=0;
  i4FileCols:=0;
  TK:=JFC_TOKENIZER.Create;
  TK.saSeparators:=' ';
  TK.saWhiteSpace:=' ';
  PG:=TPIXELGRID.Create;

  saFileIn:=p_saFilename_FloatFile_NoExtension+'.hdr';

  if bOk then
  begin
    assign(ft,saFileIn);
    {$I-}
    reset(ft);
    {$I+}
    u2IOResult:=IOResult;
    bOk:=u2IOResult=0;
  end;

  if bOk then
  begin
    readln(ft,saData);
    TK.Tokenize(saData);

    if(TK.MoveFirst) then
    begin
      if TK.Item_saToken='ncols' then
      begin
        if Tk.MoveNext then
        begin
          i4FileCols:=iVal(TK.Item_saToken);
        end;
      end;
      readln(ft,saData);
      TK.Tokenize(saData);
      if TK.MoveFirst then
      begin
        if TK.Item_saToken='nrows' then
        begin
          if Tk.MoveNext then
          begin
            i4FileRows:=iVal(TK.Item_saToken);
          end;
        end;
      end;
    end
    else
    begin
    end;
    close(ft);

    saFileIn:=p_saFilename_FloatFile_NoExtension+'.flt';
    saFileOut:=p_saOutFile_NoExtension+'.bmp';
    i4Rows:=i4FileRows * 2;
    i4CurrentRow:=0;


    x:=0;z:=0;
    fSingle:=0.0;

    assign(fin,saFileIn);
    {$I-}
    reset(fin);
    {$I+}
    u2IOResult:=IOResult;
    bOk:=u2IOResult=0;
  end;

  if bOk then
  begin
    //bWriteIt:=false;
    fHighest:=0.0;
    fLowest:=0.0;

    for z:=0 to i4FileRows-1 do begin
      for x:=0 to i4FileCols-1 do begin
        read(fin, fSingle);
        if (not p_bGrayScale) and (fSingle< 0) then fSingle:=0;

        if (fSingle < -9000)then
        begin
          fSingle:=USGS_ABSOLUTEZERO;
        end;
        if(fSingle<fLowest)then
        begin
          fLowest:=fSingle;
        end;
        if(fSingle>fHighest)then
        begin
          fHighest:=fSingle;
        end;
      end;
      if p_lpfnProgressBar<>nil then
      begin
        i4CurrentRow+=1;
        lpfnProgressBar(0,i4CurrentRow, i4Rows, lpfnFormInstance);
      end;
    end;
    close(fin);

    fNormalizer:=0.0;
    if(p_bGrayScale)then
    begin
      fNormalizer := 255 / (fHighest-fLowest);
    end
    else
    begin
      //fNormalizer := 4294967295 / (fHighest-fLowest);
      fNormalizer:=16777215 / (fHighest-fLowest);
      //fNormalizer:=65535 / (fHighest-fLowest);
    end;

    if (p_iDesiredSize>0) and (p_iDesiredSize<=i4FileCols) and (p_iDesiredSize<=i4FileRows)then
    begin
      PG.Size_Set(p_iDesiredSize,p_iDesiredSize);
    end
    else
    begin
      PG.Size_Set(i4FileCols, i4Filerows);
    end;

    fValue:=0.0;
    assign(fin,saFileIn);
    {$I-}
    reset(fin);
    {$I+}
    u2IOResult:=IOResult;
    bOk:=u2IOResult=0;
  end;

  if bOk then
  begin
    for z:=0 to i4FileRows-1 do begin
      for x:=0 to i4FileCols-1 do begin
        read(fin,fSingle);
        if (not p_bGrayScale) and (fSingle< 0) then fSingle:=0;
        if(fSingle<-9000)then
        begin
          fSingle:=USGS_ABSOLUTEZERO;
        end;
        fValue:=(fNormalizer * (fSingle+ABS(fLowest)))*p_fScale;
        if(p_bGrayScale)then
        begin
          u1:=trunc(fValue);
          PG.Red_Set(x,z,  u1);
          PG.Green_Set(x,z,u1);
          PG.Blue_Set(x,z, u1);
          PG.Alpha_Set(x,z,u1);
        end
        else
        begin
          //PG.RGBA_Set(x,z,trunc(fValue));
          u4:=trunc(fValue);
          u4c:=rt4ByteCast(u4);
          PG.Red_Set(x,z,  u4c.u1[0]);
          PG.Green_Set(x,z,u4c.u1[1]);
          PG.Blue_Set(x,z, u4c.u1[2]);
          PG.Alpha_Set(x,z,u4c.u1[3]);
        end;
      end;
      if p_lpfnProgressBar<>nil then
      begin
        i4CurrentRow:=i4CurrentRow+1;
        lpfnProgressBar(0,i4CurrentRow, i4Rows, lpfnFormInstance);
      end;
    end;
    close(fin);

    if not p_bRegistered then
    begin
      x:=0;
      repeat
        PG.Line(0,x,i4FileCols,x,RGBA.RGBA_Get);
        x:=x+120;
      until x>=i4Filerows;

      x:=0;
      repeat
        PG.Line(x,0,x,i4FileRows,RGBA.RGBA_Get);
        x:=x+120;
      until x>=i4FileCols;
    end;
    u2IOResult:=PG.bSaveBitmap24(saFileOut,lpfnProgressBar,lpfnFormInstance);
  end;
  TK.Destroy;
  PG.Destroy;
  RGBA.Destroy;
  result:=u2IOResult;
end;
//----------------------------------------------------------------------------



















//----------------------------------------------------------------------------
function USGSMapToRaw16(
  p_saFilename_FloatFile_NoExtension: ansistring;
  p_saOutFile_WithExtension: ansistring;
  p_iDesiredSize: integer;
  p_fScale: single;
  p_lpfnProgressBar: pointer;
  p_lpfnFormInstance: pointer;
  p_bRegistered: boolean
): word;
//----------------------------------------------------------------------------
var
  saData: ansistring;
  i4FileRows: longint;
  i4FileCols: longint;
//  fXSkip: single;
//  fZSkip: single;
  saFileIn: ansistring;
  saFileOut: ansistring;
  x: longint; z: longint; fSingle: Single;
  //i4Across: longint;
  //i4Down: longint;
  //bWriteIt: boolean;
  ft: text;
  fin: file of single;
  fOut: file of word;
  fHighest: single;
  fLowest: single;
  u2: word;
  TK: JFC_TOKENIZER;
  bOk: boolean;
  u2IOResult: word;
  fNormalizer: single;
  //px: longint;pz: longint;
  fValue: single;
  fABS: single;
  lpfnProgressBar: procedure (p_i4Fill: longint; p_i4Value: longint; p_i4Max: longint; p_lpfnFormInstance: pointer);
  lpfnFormInstance: pointer;

  i4Rows: longint;
  i4CurrentRow: longint;
  bWriteIt: boolean;
begin
  pointer(lpfnProgressBar):=p_lpfnProgressBar;
  lpfnFormInstance:=p_lpfnFormInstance;

  bOk:=true;
  i4FileRows:=0;
  i4FileCols:=0;
  //fXSkip:=0.0;
  //fZSkip:=0.0;
  TK:=JFC_TOKENIZER.Create;
  TK.saWhitespace:=' ';
  TK.saSeparators:=' ';

  saFileIn:=p_saFilename_FloatFile_NoExtension+'.hdr';

  if bOk then
  begin
    assign(ft,saFileIn);
    {$I-}
    reset(ft);
    {$I+}
    u2IOResult:=IOResult;
    bOk:=IOResult=0;
  end;

  if bOk then
  begin
    readln(ft,saData);
    TK.Tokenize(saData);
    if(TK.MoveFirst) then
    begin
      if TK.Item_saToken='ncols' then
      begin
        if Tk.MoveNext then
        begin
          i4FileCols:=iVal(TK.Item_saToken);
        end;
      end;
    end;

    readln(ft,saData);
    TK.Tokenize(saData);
    if(TK.MoveFirst) then
    begin
      if TK.Item_saToken='nrows' then
      begin
        if Tk.MoveNext then
        begin
          i4FileRows:=iVal(TK.Item_saToken);
        end;
      end;
    end;
    close(ft);

    //if(i4FileCols>p_iDesiredSize)then fXSkip:=single(p_iDesiredSize/single(i4FileCols));
    //if(i4FileRows>p_iDesiredSize)then fZSkip:=single(p_iDesiredSize/single(i4FileRows));

    saFileIn:=p_saFilename_FloatFile_NoExtension+'.flt';
    saFileOut:=p_saOutFile_WithExtension;
    i4Rows:=i4FileRows*2;
    i4CurrentRow:=0;


    x:=0;z:=0;
    fSingle:=0;
    //i4Across:=0;
    //i4Down:=0;
    //bWriteIt:=false;
    fHighest:=0.0;
    fLowest:=0.0;

    assign(fin,saFileIn);
    {$I-}
    reset(fin);
    {$I+}
    u2IOResult:=IOResult;
    bOk:=u2IOResult=0;
  end;


  if bOk then
  begin
    assign(fout,saFileOut);
    {$I-}
    rewrite(fout);
    {$I+}
    u2IOResult:=IOResult;
    bOk:=IOResult=0;
  end;

  if bOk then
  begin
    for z:= 0 to i4FileRows-1 do begin
      for x:=0 to  i4FileCols-1 do begin
        read(fin,fSingle);
        if(fSingle<-9000)then
        begin
          fSingle:=USGS_ABSOLUTEZERO;
        end;
        if(fSingle<fLowest)then
        begin
          fLowest:=fSingle;
        end;
        if(fSingle>fHighest)then
        begin
          fHighest:=fSingle;
        end;
      end;
      if lpfnProgressBar<>nil then
      begin
        i4CurrentRow:=i4CurrentRow+1;
        lpfnProgressBar(0,i4CurrentRow, i4Rows, lpfnFormInstance);
      end;
    end;
    close(fin);

    //dbCloseFile(2);

    fNormalizer := (fHighest-fLowest)/65535.0;

    //px:=0;pz:=0;
    fValue:=0;

    {$I-}
    reset(fin);
    {$I+}
    u2IOResult:=IOResult;
    bOk:=u2IOresult=0;
  end;

  if bOk then
  begin
    for z:=0 to i4FileRows-1 do
    begin
      for x:=0 to i4FileCols-1 do
      begin
        read(fin,fSingle);
        if(fSingle<-9000)then
        begin
          fSingle:=USGS_ABSOLUTEZERO;
        end;
        fAbs:=ABS(fLowest);
        fValue:=((fSingle + fAbs)/fNormalizer)*p_fScale;


        u2:=trunc(fValue);
        bWriteIt:=false;

        if((z<p_iDesiredSize) and (x<p_iDesiredSize)) or (p_iDesiredSize=0) then
        begin
          if (i4FileRows>i4FileCols) then
          begin
            if (z<i4FileCols) then
            begin
              bWriteIt:=true;
            end;
          end
          else
          begin
            if (i4FileRows<i4FileCols) then
            begin
              if x<i4FileRows then
              begin
                bWriteIt:=true;
              end;
            end
            else
            begin
              bWriteIt:=true;
            end;
          end;
          if bWriteIt then
          begin
            if p_bRegistered then
            begin
              write(fout,u2);
            end
            else
            begin
              if ((x mod 120)=0) or ((z mod 120)=0) then
              begin
                write(fOut,0);
              end
              else
              begin
                write(fOut,u2);
              end;
            end;
          end;
        end;
      end;
      if lpfnProgressBar<>nil then
      begin
        i4CurrentRow:=i4CurrentRow+1;
        lpfnProgressBar(0,i4CurrentRow, i4Rows, lpfnFormInstance);
      end;
    end;
    close(fin);
    close(fout);
  end;
  TK.Destroy;
  result:=u2IOREsult;
end;
//----------------------------------------------------------------------------






















////----------------------------------------------------------------------------
//void USGS::USGSMapPaint(
//  int p_iDesiredSize,
//  char *p_szFilename_FloatFile_NoExtension,
//  char *p_szOutFile_WithExtension,
//
//  float p_fRedMinPercent,
//  float p_fRedMaxPercent,
//  float p_fRedLowBandPercent,
//  float p_fRedHighBandPercent,
//  float p_fRedStrengthPercent,
//  float p_fRedMinAngle,
//  float p_fRedMaxAngle,
//
//  float p_fGreenMinPercent,
//  float p_fGreenMaxPercent,
//  float p_fGreenLowBandPercent,
//  float p_fGreenHighBandPercent,
//  float p_fGreenStrengthPercent,
//  float p_fGreenMinAngle,
//  float p_fGreenMaxAngle,
//
//  float p_fBlueMinPercent,
//  float p_fBlueMaxPercent,
//  float p_fBlueLowBandPercent,
//  float p_fBlueHighBandPercent,
//  float p_fBlueStrengthPercent,
//  float p_fBlueMinAngle,
//  float p_fBlueMaxAngle,
//
//  float p_fAlphaMinPercent,
//  float p_fAlphaMaxPercent,
//  float p_fAlphaLowBandPercent,
//  float p_fAlphaHighBandPercent,
//  float p_fAlphaStrengthPercent,
//  float p_fAlphaMinAngle,
//  float p_fAlphaMaxAngle
//
//
//
//){
////----------------------------------------------------------------------------
//  int FileRows=0;
//  int FileCols=0;
//  float fXSkip=0.0f;
//  float fZSkip=0.0f;
//
//  JGC_MEMBLOCK *mb=new JGC_MEMBLOCK();
//  JGC_PIXELGRID *pg=new JGC_PIXELGRID();
//  JFC_STRING *sjFileIn=new JFC_STRING();
//  JFC_STRING *sjFileOut=new JFC_STRING();
//  JFC_STRING *sjData=new JFC_STRING();
//  JFC_DL *DL=new JFC_DL();
//  sjFileIn->Set(p_szFilename_FloatFile_NoExtension);
//  sjFileIn->ConCat(".hdr");
//  if(!dbFileExist(sjFileIn->s)){
//    sprintf(JFC::CHAR1K,"File Not found: %s",sjFileIn->s);
//    #ifdef USE_MULTIBYTECODE_CHARSET
//      MessageBox(0,JFC::CHAR1K,"File Not Found",0);
//    #else
//      //MessageBox(0,JFC::CHAR1K,"File Not Found",0);
//    #endif
//    return;
//  };
//  int fh=JGC::File->FreeFile();
//  dbOpenToRead(fh,sjFileIn->s);
//  sjData->Set(dbReadString(fh));
//  DL->GetTokens(sjData," ");
//  DL->MoveNext();//Pass the ncols Keyword
//  FileCols=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//  sjData->Set(dbReadString(fh));
//  DL->GetTokens(sjData," ");
//  DL->MoveNext();//Pass the nrows Keyword
//  FileRows=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//  dbCloseFile(fh);
//
//  if(FileCols>p_iDesiredSize){ fXSkip=(float)p_iDesiredSize/(float)FileCols;};
//  if(FileRows>p_iDesiredSize){ fZSkip=(float)p_iDesiredSize/(float)FileRows;};
//
//  sjFileIn->Set(p_szFilename_FloatFile_NoExtension);
//  sjFileIn->ConCat(".flt");
//  sjFileOut->Set(p_szOutFile_WithExtension);
//  //sjFileOut->ConCat(".raw");
//
//  int x=0;int z=0;
//  float f=0;
//  //dbOpenToWrite(2,sjFileOut->s);
//
//  int iAcross=0;
//  int iDown=0;
//  bool bWriteIt=false;
//
//  float fHighest=0.0f;
//  float fLowest=0.0f;
//
//  dbBackdropOff();
//
//
//  // SCAN BEGIN -----------------
//  dbOpenToRead(fh,sjFileIn->s);
//  dbDeleteFile(sjFileOut->s);
//  for(z=0;z<FileRows;z++){
//    for(x=0;x<FileCols;x++){
//      f=dbReadFloat(fh);
//      if(f<-9000){
//        f=USGS_ABSOLUTEZERO;
//      };
//      if(f<fLowest){
//        fLowest=f;
//      };
//      if(f>fHighest){
//        fHighest=f;
//      };
//    };
//    if((z % 128)==0){
//      dbCLS();
//      sprintf(JFC::CHAR1K,"Scanning Row %i of %i",z,FileRows);dbPrint(JFC::CHAR1K);
//      dbSync();
//    };
//  };
//  dbCloseFile(fh);
//
//  //fLowest=USGS_ABSOLUTEZERO;
//  //fHighest=1600.0f;
//
//  // SCAN END -----------------
//
//
//
//  //float fNormalizer = (fHighest-fLowest)/255.0f;
//  pg->Size_Set(p_iDesiredSize,p_iDesiredSize);
//  mb->Make(p_iDesiredSize * p_iDesiredSize * 4);
//
//  int px=0;int pz=0;
//
//
//  //float fValue=0;
//
//
//  float fRange = fHighest-fLowest;
//  float fRedMin=fRange * (p_fRedMinPercent * 0.01f);
//  float fRedMax=fRange * (p_fRedMaxPercent * 0.01f);
//  float fRedRange=(fRedMax-fRedMin);
//  float fRedLowBandTop = fRedRange*(p_fRedLowBandPercent * 0.01f);
//  float fRedHighBandBottom=fRedRange - (fRedRange * (p_fRedHighBandPercent * 0.01f));
//  float fRedStrength = 255.0f * (p_fRedStrengthPercent * 0.01f);
//
//  float fGreenMin=fRange * (p_fGreenMinPercent * 0.01f);
//  float fGreenMax=fRange * (p_fGreenMaxPercent * 0.01f);
//  float fGreenRange=(fGreenMax-fGreenMin);
//  float fGreenLowBandTop = fGreenRange*(p_fGreenLowBandPercent * 0.01f);
//  float fGreenHighBandBottom=fGreenRange - (fGreenRange * (p_fGreenHighBandPercent * 0.01f));
//  float fGreenStrength = 255.0f * (p_fGreenStrengthPercent * 0.01f);
//
//  float fBlueMin=fRange * (p_fBlueMinPercent * 0.01f);
//  float fBlueMax=fRange * (p_fBlueMaxPercent * 0.01f);
//  float fBlueRange=(fBlueMax-fBlueMin);
//  float fBlueLowBandTop = fBlueRange*(p_fBlueLowBandPercent * 0.01f);
//  float fBlueHighBandBottom=fBlueRange - (fBlueRange * (p_fBlueHighBandPercent * 0.01f));
//  float fBlueStrength = 255.0f * (p_fBlueStrengthPercent * 0.01f);
//
//  float fAlphaMin=fRange * (p_fAlphaMinPercent * 0.01f);
//  float fAlphaMax=fRange * (p_fAlphaMaxPercent * 0.01f);
//  float fAlphaRange=(fAlphaMax-fAlphaMin);
//  float fAlphaLowBandTop = fAlphaRange*(p_fAlphaLowBandPercent * 0.01f);
//  float fAlphaHighBandBottom=fAlphaRange - (fAlphaRange * (p_fAlphaHighBandPercent * 0.01f));
//  float fAlphaStrength = 255.0f * (p_fAlphaStrengthPercent * 0.01f);
//
//
//  JFC_RGBA *rgba=new JFC_RGBA();
//  dbOpenToRead(fh,sjFileIn->s);
//  for(z=0;z<FileRows;z++){
//    for(x=0;x<FileCols;x++){
//      f=dbReadFloat(fh);
//      if(f<-9000){
//        f=USGS_ABSOLUTEZERO;
//      }else{
//        if(f>500){
//          f=f;//debug thing - breakpoint line
//        };
//      };
//      f=f+dbABS(fLowest);
//      //float fAbs=dbABS(fLowest);
//      //fValue=(f+fAbs)/fNormalizer;
//      px=(int)  (((float)x) * fXSkip);
//      pz=(int)  (((float)z) * fZSkip);
//
//      unsigned char u1Red=0;
//      unsigned char u1Green=0;
//      unsigned char u1Blue=0;
//      unsigned char u1Alpha=0;
//
//      if((f>=fRedMin) && (f<=fRedMax)){
//        if((f>=fRedLowBandTop)&&(f<=fRedHighBandBottom)){
//          u1Red = (unsigned char)fRedStrength;
//        }else{
//          if(f<fRedLowBandTop){
//            u1Red = (unsigned char)((fRedStrength / (fRedLowBandTop-fRedMin)) * (f-fRedMin));
//          }else{
//            u1Red = (unsigned char)((fRedStrength / (fRedMax-fRedHighBandBottom)) * (fRedMax-f));
//          };
//        };
//      };
//
//      if((f>=fGreenMin) && (f<=fGreenMax)){
//        if((f>=fGreenLowBandTop)&&(f<=fGreenHighBandBottom)){
//          u1Green = (unsigned char)fGreenStrength;
//        }else{
//          if(f<fGreenLowBandTop){
//            u1Green = (unsigned char)((fGreenStrength / (fGreenLowBandTop-fGreenMin)) * (f-fGreenMin));
//          }else{
//            u1Green = (unsigned char)((fGreenStrength / (fGreenMax-fGreenHighBandBottom)) * (fGreenMax-f));
//          };
//        };
//      };
//
//      if((f>=fBlueMin) && (f<=fBlueMax)){
//        if((f>=fBlueLowBandTop)&&(f<=fBlueHighBandBottom)){
//          u1Blue = (unsigned char)fBlueStrength;
//        }else{
//          if(f<fBlueLowBandTop){
//            u1Blue = (unsigned char)((fBlueStrength / (fBlueLowBandTop-fBlueMin)) * (f-fBlueMin));
//          }else{
//            u1Blue = (unsigned char)((fBlueStrength / (fBlueMax-fBlueHighBandBottom)) * (fBlueMax-f));
//          };
//        };
//      };
//
//      if((f>=fAlphaMin) && (f<=fAlphaMax)){
//        if((f>=fAlphaLowBandTop)&&(f<=fAlphaHighBandBottom)){
//          u1Alpha = (unsigned char)fAlphaStrength;
//        }else{
//          if(f<fAlphaLowBandTop){
//            u1Alpha = (unsigned char)((fAlphaStrength / (fAlphaLowBandTop-fAlphaMin)) * (f-fAlphaMin));
//          }else{
//            u1Alpha = (unsigned char)((fAlphaStrength / (fAlphaMax-fAlphaHighBandBottom)) * (fAlphaMax-f));
//          };
//        };
//      };
//
//      pg->RGBA_Set(px,pz,u1Red,u1Green,u1Blue,u1Alpha);
//      mb->Float_Set( (px * 4) + (pz * 4 * p_iDesiredSize),f);
//    };
//    if((z % 128)==0){
//      dbCLS();
//      dbPrint("Painting USGS HeightMap...");
//      sprintf(JFC::CHAR1K,"Highest Point: %f",fHighest);dbPrint(JFC::CHAR1K);
//      sprintf(JFC::CHAR1K,"Lowest  Point: %f",fLowest);dbPrint(JFC::CHAR1K);
//      sprintf(JFC::CHAR1K,"Difference: %f",(fHighest-fLowest));dbPrint(JFC::CHAR1K);
//      //sprintf(JFC::CHAR1K,"Normalizer: %f",fNormalizer);dbPrint(JFC::CHAR1K);
//
//      sprintf(JFC::CHAR1K,"%i of %i",z,FileRows);dbPrint(JFC::CHAR1K);
//      sprintf(JFC::CHAR1K,"In file: %s",sjFileIn->s);dbPrint(JFC::CHAR1K);
//      dbSync();
//    };
//  };
//  dbCloseFile(fh);
//  SAFE_DELETE(rgba);
//
//  float a=0.0f;
//  float avgcnt=0.0f;
//  float f2=0.0f;
//  for(z=0;z<p_iDesiredSize;z++){
//    for(x=0;x<p_iDesiredSize;x++){
//      a=0;
//      avgcnt=0.0f;
//      f2= mb->Float_Get( (x * 4) + (z * 4 * p_iDesiredSize));
//      //left
//      if(x>0){
//        f = mb->Float_Get( ((x-1) * 4) + (z * 4 * p_iDesiredSize));
//        a=dbABS(90-dbAtanFull(8, f-f2));
//        if( (a< p_fRedMinAngle) || (a>= p_fRedMaxAngle)){
//          float b=(float)pg->Red_Get(x,z);
//          b=b-63.75;
//          pg->Red_Set(x,z,(int)b);
//        };
//        if( (a< p_fGreenMinAngle) || (a>= p_fGreenMaxAngle)){
//          float b=(float)pg->Green_Get(x,z);
//          b=b-63.75;
//          pg->Green_Set(x,z,(int)b);
//        };
//        if( (a< p_fBlueMinAngle) || (a>= p_fBlueMaxAngle)){
//          float b=(float)pg->Blue_Get(x,z);
//          b=b-63.75;
//          pg->Blue_Set(x,z,(int)b);
//        };
//        if( (a< p_fAlphaMinAngle) || (a>= p_fAlphaMaxAngle)){
//          float b=(float)pg->Alpha_Get(x,z);
//          b=b-63.75;
//          pg->Alpha_Set(x,z,(int)b);
//        };
//      };
//
//      //right
//      if(x<(p_iDesiredSize-1)){
//        f= mb->Float_Get( ((x+1) * 4) + (z * 4 * p_iDesiredSize));
//        a=dbABS(90-dbAtanFull(8, f-f2));
//        if( (a< p_fRedMinAngle) || (a>= p_fRedMaxAngle)){
//          float b=(float)pg->Red_Get(x,z);
//          b=b-63.75;
//          pg->Red_Set(x,z,(int)b);
//        };
//        if( (a< p_fGreenMinAngle) || (a>= p_fGreenMaxAngle)){
//          float b=(float)pg->Green_Get(x,z);
//          b=b-63.75;
//          pg->Green_Set(x,z,(int)b);
//        };
//        if( (a< p_fBlueMinAngle) || (a>= p_fBlueMaxAngle)){
//          float b=(float)pg->Blue_Get(x,z);
//          b=b-63.75;
//          pg->Blue_Set(x,z,(int)b);
//        };
//        if( (a< p_fAlphaMinAngle) || (a>= p_fAlphaMaxAngle)){
//          float b=(float)pg->Alpha_Get(x,z);
//          b=b-63.75;
//          pg->Alpha_Set(x,z,(int)b);
//        };
//      };
//
//      //up
//      if(z>0){
//        f = mb->Float_Get( (x * 4) + ((z-1) * 4 * p_iDesiredSize));
//        a=dbABS(90-dbAtanFull(8, f-f2));
//        if( (a< p_fRedMinAngle) || (a>= p_fRedMaxAngle)){
//          float b=(float)pg->Red_Get(x,z);
//          b=b-63.75;
//          pg->Red_Set(x,z,(int)b);
//        };
//        if( (a< p_fGreenMinAngle) || (a>= p_fGreenMaxAngle)){
//          float b=(float)pg->Green_Get(x,z);
//          b=b-63.75;
//          pg->Green_Set(x,z,(int)b);
//        };
//        if( (a< p_fBlueMinAngle) || (a>= p_fBlueMaxAngle)){
//          float b=(float)pg->Blue_Get(x,z);
//          b=b-63.75;
//          pg->Blue_Set(x,z,(int)b);
//        };
//        if( (a< p_fAlphaMinAngle) || (a>= p_fAlphaMaxAngle)){
//          float b=(float)pg->Alpha_Get(x,z);
//          b=b-63.75;
//          pg->Alpha_Set(x,z,(int)b);
//        };
//      };
//
//      //down
//      if(z<(p_iDesiredSize-1)){
//        f = mb->Float_Get( (x * 4) + ((z+1) * 4 * p_iDesiredSize));
//        a=dbABS(90-dbAtanFull(8, f-f2));
//        if( (a< p_fRedMinAngle) || (a>= p_fRedMaxAngle)){
//          float b=(float)pg->Red_Get(x,z);
//          b=b-63.75;
//          pg->Red_Set(x,z,(int)b);
//        };
//        if( (a< p_fGreenMinAngle) || (a>= p_fGreenMaxAngle)){
//          float b=(float)pg->Green_Get(x,z);
//          b=b-63.75;
//          pg->Green_Set(x,z,(int)b);
//        };
//        if( (a< p_fBlueMinAngle) || (a>= p_fBlueMaxAngle)){
//          float b=(float)pg->Blue_Get(x,z);
//          b=b-63.75;
//          pg->Blue_Set(x,z,(int)b);
//        };
//        if( (a< p_fAlphaMinAngle) || (a>= p_fAlphaMaxAngle)){
//          float b=(float)pg->Alpha_Get(x,z);
//          b=b-63.75;
//          pg->Alpha_Set(x,z,(int)b);
//        };
//      };
//
//    };
//    if((z % 128)==0){
//      dbCLS();
//      dbPrint("Applying Angle Constraints...");
//      sprintf(JFC::CHAR1K,"%i of %i",z,p_iDesiredSize);dbPrint(JFC::CHAR1K);
//      sprintf(JFC::CHAR1K,"Source file: %s",sjFileIn->s);dbPrint(JFC::CHAR1K);
//      dbSync();
//    };
//  };
//
//
//
//
//
//  dbCLS();
//  sprintf(JFC::CHAR1K,"Saving 4 Channel Paint Job: %s",sjFileOut->s);dbPrint(JFC::CHAR1K);  dbSync();dbSync();
//  dbSync();
//  JGC_IMAGE *img = pg->MakeImageFromThis();
//  img->Save(sjFileOut->s );
//  SAFE_DELETE(img);
//  SAFE_DELETE(pg);
//  SAFE_DELETE(mb);
//  SAFE_DELETE(DL);
//  SAFE_DELETE(sjFileIn);
//  SAFE_DELETE(sjFileOut);
//  SAFE_DELETE(sjData);
//};
////----------------------------------------------------------------------------
//
//
//
//
////----------------------------------------------------------------------------
//// This function takes a source file and allows you to break it up into
//// smaller "tiles". Files supported:
////   *.DDS (Mip Maps not loaded) (Alpha channel Not adultered)
////   *.BMP
////   *.RAW (16 bit)
////   *.PNG (Alpha channel Not adultered)
////   *.JPG
////   *.FLT & *.HDR together ( USGS Grid Float file format) - If you pass a
////      source file without an extension - USGS gridfloat format is assumed.
//bool USGS::Tiler(
//  char *p_szSourceFile, // For USGS - Pass Filename without Extension.
//  char *p_szDestDirectory,
//  int p_iSourceTop, // If all ZEROS then full image used. RAW (16 bit) format
//  int p_iSourceLeft,  // REQUIRES valid values. RAW requires values to REFLECT
//                      // ENTIRE file. You can't Select a Chunk from a RAW file.
//                      // if the Raw file is 1024x1024, then the top, left,
//                      // right and bottom parameters should be: 0,0,1023,1023
//                      // respectively. This is because RAW doesn't tell you
//                      // the file dimensions - so you MUST enter them as I say.
//                      // Now Images have dimensions in them, and so do GRIDFLOAT's
//                      // USGS files in the *.hdr file.
//  int p_iSourceRight,
//  int p_iSourceBottom,
//  int p_iTileWidth, // Desired Tile Width - Fluff will be added to solve overlap.
//  int p_iTileHeight // Desired Tile Width - Fluff will be added to solve overlap.
//){
////----------------------------------------------------------------------------
//  bool bBackDropOn = JGC::Cam0->Backdrop_Get();
//  JGC::Cam0->Backdrop_Set(false);
//
//  JFC_DL *dlFileParts=new JFC_DL();
//  dlFileParts->ParseFilename( p_szSourceFile );
//
//  /*
//  dbPrint("JFC_DL->ParseFileName Function Test Result Below");
//  LoopGDK();
//  dlFileParts->MoveFirst();
//  JFC_STRING *s=new JFC_STRING();
//  do{
//    sprintf(JFC::CHAR1K,"dlFileParts->n = %i :",dlFileParts->NPosition);
//    s->Set(JFC::CHAR1K);
//    s->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//    dbPrint(s->s);
//  }while(dlFileParts->MoveNext());
//  delete s;s=NULL;
//  dbPrint("Waiting for input.");
//  dbSync();dbSync();
//  LoopGDK();
//  dbInput();
//  */
//
//  JFC_STRING *sSrcPathNFile=new JFC_STRING(p_szSourceFile);
//  JFC_STRING *sSrcFileExt=new JFC_STRING();
//  JFC_STRING *sSrcFile=new JFC_STRING();
//  JFC_STRING *sSrcDir=new JFC_STRING();
//  JFC_STRING *sDestDir=new JFC_STRING(p_szDestDirectory);
//  JFC_STRING *sSrcUSGSHdr=new JFC_STRING();
//  JFC_STRING *sSrcUSGSFlt=new JFC_STRING();
//  bool bResult = true;
//
//  if((sDestDir->s[sDestDir->Length()-1]!='\\') && (sDestDir->s[sDestDir->Length()-1]!='/')){
//    sDestDir->ConCat("/");
//  };
//
//  JFC_DL *DL=new JFC_DL();
//  sSrcPathNFile->Reverse();
//  DL->GetTokens(sSrcPathNFile,"/\\");
//  sSrcPathNFile->Reverse();
//  if(DL->MoveFirst()){
//    sSrcFile->Set(((JFC_DLITEM*)DL->Item)->Str->s);
//  }else{
//    sSrcFile->Set(sSrcPathNFile->s);
//  };
//  if(JGC::File->Exist(sSrcPathNFile->s)){
//    // we have a filename that exists
//    // Snag the file ext then and see if we support it.
//    DL->DeleteAll();
//    DL->GetTokens(sSrcFile,".");
//    if(DL->MoveFirst()){
//      sSrcFileExt->Set(((JFC_DLITEM*)DL->Item)->Str->s);
//      sSrcFileExt->Reverse();
//    };
//    bResult= sSrcFileExt->Equal("bmp") ||
//             sSrcFileExt->Equal("jpg") ||
//             sSrcFileExt->Equal("raw") ||
//             sSrcFileExt->Equal("dds") ||
//             sSrcFileExt->Equal("png");
//    if(!bResult){
//      dbCLS();
//      dbPrint("This utility supports *.bmp (24bit), *.jpg, *.raw (16bit) and *.png files.");
//      dbPrint("Here is what you gave me for a source file: ");
//      dbPrint(sSrcPathNFile->s);
//      dbPrint();
//      dbPrint("Press Enter:");
//      dbSync();
//      dbInput();
//    };
//  }else{
//    // Looks like we have possibly a missing file OR a USGS Grid Float.
//    // check for *.hdr and *.flt for source files - both must exist or
//    // we error out.
//    sSrcUSGSHdr->Set(sSrcPathNFile->s);
//    sSrcUSGSHdr->ConCat(".hdr");
//    sSrcUSGSFlt->Set(sSrcPathNFile->s);
//    sSrcUSGSFlt->ConCat(".flt");
//    bResult=JGC::File->Exist(sSrcUSGSHdr->s) && JGC::File->Exist(sSrcUSGSFlt->s);
//    if(!bResult){
//      dbCLS();
//      dbPrint("The Source file(s) can not be found, so I tried to see if you ");
//      dbPrint("wanted to process a USGS file but I couldn't find a *.flt ");
//      dbPrint("and *.hdr file pair. Here is what you gave me for a source file:");
//      dbPrint(sSrcPathNFile->s);
//      dbPrint();
//      dbPrint("Press Enter:");
//      dbSync();
//      dbInput();
//    }else{
//      sSrcFileExt->Set("hdr");
//    };
//  };
//
//  if (bResult){
//
//    int iImageWidth=p_iSourceRight-p_iSourceLeft + 1;
//    int iImageHeight=p_iSourceBottom-p_iSourceTop+1;
//
//    int iTilesX = iImageWidth / p_iTileWidth;
//    if (( iImageWidth % p_iTileWidth)>0){
//      iTilesX = iTilesX+1;
//    };
//
//    int iTilesY = iImageHeight / p_iTileHeight;
//    if (( iImageHeight % p_iTileWidth)>0){
//      iTilesY = iTilesY+1;
//    };
//
//    //----------------------------------------------------
//    // Process common gfx formats
//    //----------------------------------------------------
//    if ( sSrcFileExt->Equal("bmp") ||
//         sSrcFileExt->Equal("jpg") ||
//         sSrcFileExt->Equal("png") ||
//         sSrcFileExt->Equal("dds")
//      ){
//      JGC_PIXELGRID *pg=new JGC_PIXELGRID();
//      JGC_IMAGE *img=new JGC_IMAGE();
//      img->LoadImageGDK(sSrcPathNFile->s,false);
//      if((p_iSourceLeft==0)&&(p_iSourceRight==0)&&
//        (p_iSourceTop==0)&&(p_iSourceBottom==0)){
//        iImageWidth=img->Width_Get();
//        iImageHeight=img->Height_Get();
//        iTilesX = iImageWidth / p_iTileWidth;
//        if (( iImageWidth % p_iTileWidth)>0){
//          iTilesX = iTilesX+1;
//        };
//        iTilesY = iImageHeight / p_iTileHeight;
//        if (( iImageHeight % p_iTileHeight)>0){
//          iTilesY = iTilesY+1;
//        };
//      };
//
//
//          //DEBUG
//          //JFC_STRING *sFileOut=new JFC_STRING();
//          //sFileOut->Set(sDestDir->s);
//          //sprintf(JFC::CHAR1K,"test_loadedImage.bmp");
//          //sFileOut->ConCat(JFC::CHAR1K);
//          //img->Save(sFileOut->s);
//          //delete sFileOut;sFileOut=NULL;
//      pg->Size_Set(iImageWidth, iImageHeight);
//      pg->PasteImageOnThis(0,0,img->ID,p_iSourceLeft, p_iSourceTop, p_iSourceRight, p_iSourceBottom,NULL,true);
//          //DEBUG
//          //sFileOut=new JFC_STRING();
//          //sFileOut->Set(sDestDir->s);
//          //sprintf(JFC::CHAR1K,"test_pastedImage.bmp");
//          //sFileOut->ConCat(JFC::CHAR1K);
//          //img=pg->MakeImageFromThis();
//          //img->Save(sFileOut->s);
//          //delete sFileOut;sFileOut=NULL;
//
//
//      SAFE_DELETE(img);
//
//      JGC_PIXELGRID *pgOut=new JGC_PIXELGRID();
//      pgOut->Size_Set(p_iTileWidth,p_iTileHeight);
//      int tx=0; int ty=0;
//      int x=0; int y=0;
//      int iTileMaxX=iTilesX * p_iTileWidth;
//      int iTileMaxY=iTilesY * p_iTileHeight;
//      int sx=0;int sy=0;
//      for(y=0;y<iTilesY;y++){
//        for(x=0;x<iTilesX;x++){
//          sy=0;
//          for(ty=(y*p_iTileHeight);ty<((y+1)*p_iTileHeight);ty++){
//            sx=0;
//            for(tx=(x*p_iTileWidth);tx<((x+1)*p_iTileWidth);tx++){
//              pgOut->RGBA_Set(sx,sy, pg->RGBA_Get(tx,ty));
//              sx++;
//            };
//            sy++;
//          };
//          JFC_STRING *sFileOut=new JFC_STRING();
//          sFileOut->Set(sDestDir->s);
//          dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//          sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//          sFileOut->ConCat("_Tile_");
//          JFC_STRING *si=new JFC_STRING();
//          si->ZeroPadInt(y,2);
//          sFileOut->ConCat(si->s);
//          sFileOut->ConCat("_");
//          si->ZeroPadInt(x,2);
//          sFileOut->ConCat(si->s);
//          SAFE_DELETE(si);
//
//          sFileOut->ConCat(".");
//          sFileOut->ConCat(sSrcFileExt->s);
//          img=pgOut->MakeImageFromThis();
//          img->Save(sFileOut->s);
//          SAFE_DELETE(img);
//          SAFE_DELETE(sFileOut);
//        };
//      };
//      SAFE_DELETE(pg);
//      SAFE_DELETE(pgOut);
//      SAFE_DELETE(img);
//    };
//    //----------------------------------------------------
//
//    //----------------------------------------------------
//    // Process 16 Bit (unsigned) RAW format
//    //----------------------------------------------------
//    if(sSrcFileExt->Equal("raw")){
//      int fh=JGC::File->FreeFile();
//      JGC_MEMBLOCK *mb=new JGC_MEMBLOCK();
//      mb->Make(iImageWidth * iImageHeight * 2);
//      dbOpenToRead(fh,sSrcPathNFile->s);
//      for(int y=0;y<iImageHeight;y++){
//        for(int x=0;x<iImageWidth;x++){
//          mb->Word_Set( (x*2)+((y*2)*iImageWidth),dbReadWord(fh));
//        };
//      };
//      dbCloseFile(fh);
//
//      int tx=0; int ty=0;
//      int iTileMaxX=iTilesX * p_iTileWidth;
//      int iTileMaxY=iTilesY * p_iTileHeight;
//      int sx=0;int sy=0;
//      JGC_MEMBLOCK *mbOut=new JGC_MEMBLOCK();
//      mbOut->Make(p_iTileWidth * p_iTileHeight * 2);
//      for(int y=0;y<iTilesY;y++){
//        for(int x=0;x<iTilesX;x++){
//          sy=0;
//          for(ty=(y*p_iTileHeight);ty<((y+1)*p_iTileHeight);ty++){
//            sx=0;
//            for(tx=(x*p_iTileWidth);tx<((x+1)*p_iTileWidth);tx++){
//              if((tx>=0)&&(tx<iImageWidth)&&(ty>=0)&&(ty<iImageHeight)){
//                mbOut->Word_Set((sx*2)+((sy*2)*p_iTileWidth),mb->Word_Get((sx*2)+((sy*2)*iImageWidth)));
//              };
//              sx++;
//            };
//            sy++;
//          };
//          JFC_STRING *sFileOut=new JFC_STRING();
//          sFileOut->Set(sDestDir->s);
//          dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//          sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//          sFileOut->ConCat("_Tile_");
//          JFC_STRING *si=new JFC_STRING();
//          si->ZeroPadInt(y,2);
//          sFileOut->ConCat(si->s);
//          sFileOut->ConCat("_");
//          si->ZeroPadInt(x,2);
//          sFileOut->ConCat(si->s);
//          SAFE_DELETE(si);
//          sFileOut->ConCat(".");
//          sFileOut->ConCat(sSrcFileExt->s);
//          dbOpenToWrite(fh,sFileOut->s);
//          int x2=0;int y2=0;
//          for(y2=0;y2<p_iTileHeight;y2++){
//            for(x2=0;x2<p_iTileWidth;x2++){
//              dbWriteWord(fh,mbOut->Word_Get((x2*2)+((y2*2)*p_iTileWidth)));
//            };
//          };
//          dbCloseFile(fh);
//          SAFE_DELETE(sFileOut);
//        };
//      };
//    };
//    //----------------------------------------------------
//
//    //----------------------------------------------------
//    // Process USGS
//    //----------------------------------------------------
//    if(sSrcFileExt->Equal("hdr")){
//      // Get Cols and Rows from Header file
//      JFC_STRING *sjData=new JFC_STRING();
//      JFC_STRING *sjTempFileName=new JFC_STRING();
//      int FileRows=0;
//      int FileCols=0;
//      float xllcorner=0.0f;
//      float yllcorner=0.0f;
//      float cellsize=0.0f;
//
//      int fh=JGC::File->FreeFile();
//      sjTempFileName->Set(sSrcPathNFile->s);
//      sjTempFileName->ConCat(".");
//      sjTempFileName->ConCat(sSrcFileExt->s);
//      dbOpenToRead(fh,sjTempFileName->s);
//      sjData->Set(dbReadString(fh));
//      DL->GetTokens(sjData," ");
//      DL->MoveNext();//Pass the ncols Keyword
//      FileCols=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//      sjData->Set(dbReadString(fh));
//      DL->GetTokens(sjData," ");
//      DL->MoveNext();//Pass the nrows Keyword
//      FileRows=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//      sjData->Set(dbReadString(fh));
//      DL->GetTokens(sjData," ");
//      DL->MoveNext();//Pass the xllcorner Keyword
//      xllcorner=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//      sjData->Set(dbReadString(fh));
//      DL->GetTokens(sjData," ");
//      DL->MoveNext();//Pass the yllcorner Keyword
//      yllcorner=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//      sjData->Set(dbReadString(fh));
//      DL->GetTokens(sjData," ");
//      DL->MoveNext();//Pass the cellsize Keyword
//      cellsize=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//      dbCloseFile(fh);
//      SAFE_DELETE(sjData);
//
//      // See if user wants to use whole file based
//      // on TLBR parameters. If All Zeroes - then
//      // use whole file. Otherwise Snag the specified
//      // area as our base starting point to tile off of.
//      JFC_TLBR *tlbr=new JFC_TLBR(p_iSourceTop,p_iSourceLeft,p_iSourceBottom,p_iSourceRight);
//
//      if((p_iSourceLeft==0)&&(p_iSourceRight==0)&&
//        (p_iSourceTop==0)&&(p_iSourceBottom==0)){
//        iImageWidth=FileCols;
//        iImageHeight=FileRows;
//        tlbr->Width_Set(iImageWidth);
//        tlbr->Height_Set(iImageHeight);
//        iTilesX = iImageWidth / p_iTileWidth;
//        if (( iImageWidth % p_iTileWidth)>0){
//          iTilesX = iTilesX+1;
//        };
//        iTilesY = iImageHeight / p_iTileHeight;
//        if (( iImageHeight % p_iTileHeight)>0){
//          iTilesY = iTilesY+1;
//        };
//      };
//
//      //sprintf(JFC::CHAR1K,"USGS File %i x %i  Tiles %i x %i  File: %s",FileCols,FileRows,iTilesX, iTilesY,sSrcPathNFile->s);
//      //MessageBox(0,JFC::CHAR1K,"USGS Debug Info",0);
//
//      // Read in the Data we want to Tile
//      sjTempFileName->Set(sSrcPathNFile->s);
//      sjTempFileName->ConCat(".flt");
//      dbOpenToRead(fh,sjTempFileName->s);
//      JGC_MEMBLOCK *mb=new JGC_MEMBLOCK();
//      mb->Make(iImageWidth * iImageHeight * 4);
//      int sx=0;int sy=0;float f=0.0f;
//      int x=0;int y=0;
//      for(y=0;y<FileRows;y++){
//        for(x=0;x<FileCols;x++){
//          f=dbReadFloat(fh);
//          if(tlbr->Inside(x,y)){
//            //mb->Float_Set( (sx*4)+((sy*4)*iImageWidth), f);
//            if(f>0){
//              int o=1;//debug
//            };
//            mb->Float_Set( ((x-tlbr->Left)+((y-tlbr->Top)*iImageWidth))*4, f);
//          };
//        };
//        if((y % 128)==0){
//          dbCLS();
//          sprintf(JFC::CHAR1K,"Reading Source Row: %i  File: %s",y,sjTempFileName->s);dbPrint(JFC::CHAR1K);
//          dbSync();dbSync();
//        };
//      };
//      dbCloseFile(fh);
//
//      // save a Diagnostic of the data we want to tile
//      {
//          JFC_STRING *sFileOut=new JFC_STRING();
//          //Write the header file for the tile
//          sFileOut->Set(sDestDir->s);
//          dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//          sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//          sFileOut->ConCat("_Diagnostic");
//          //JFC_STRING *si=new JFC_STRING();
//          sFileOut->ConCat(".hdr");
//          dbOpenToWrite(fh,sFileOut->s);
//          JFC_STRING *s=new JFC_STRING(sFileOut->s);
//          sprintf(JFC::CHAR1K,"ncols         %i",iImageWidth);dbWriteString(fh,JFC::CHAR1K);
//          sprintf(JFC::CHAR1K,"nrows         %i",iImageHeight);dbWriteString(fh,JFC::CHAR1K);
//          float fNewXLLCorner=xllcorner-(cellsize*tlbr->Width_Get());
//          sprintf(JFC::CHAR1K,"xllcorner     %f",fNewXLLCorner);dbWriteString(fh,JFC::CHAR1K);
//          float fNewYLLCorner=yllcorner-(cellsize*tlbr->Height_Get());
//          sprintf(JFC::CHAR1K,"yllcorner     %f",fNewYLLCorner);dbWriteString(fh,JFC::CHAR1K);
//          sprintf(JFC::CHAR1K,"cellsize      %f",cellsize);dbWriteString(fh,JFC::CHAR1K);
//          dbWriteString(fh,"NODATA_value  -9999");
//          dbWriteString(fh,"byteorder     LSBFIRST");
//          dbCloseFile(fh);
//          //Write the Tile
//          sFileOut->Set(sDestDir->s);
//          dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//          sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//          sFileOut->ConCat("_Diagnostic.flt");
//          //--
//          dbCLS();
//          sprintf(JFC::CHAR1K,"Writing Diagnostic File: %s",sFileOut->s);dbPrint(JFC::CHAR1K);
//          dbSync();dbSync();
//          //--
//          dbOpenToWrite(fh,sFileOut->s);
//          int x2=0;int y2=0;
//          for(y2=0;y2<iImageHeight;y2++){
//            for(x2=0;x2<iImageWidth;x2++){
//              dbWriteFloat(fh,mb->Float_Get((x2+(y2*iImageWidth))*4));
//            };
//          };
//          dbCloseFile(fh);
//
//          /*
//          // Make Diagnosic TEXT file of the Values
//          sFileOut->ConCat(".txt");
//          dbOpenToWrite(fh,sFileOut->s);
//          x2=0;y2=0;
//          for(y2=0;y2<iImageHeight;y2++){
//            sprintf(JFC::CHAR1K,"Col %i  Row %i", x2,y2);
//            dbWriteString(fh,JFC::CHAR1K);
//            for(x2=0;x2<iImageWidth;x2++){
//              sprintf(JFC::CHAR1K,"%f",mb->Float_Get((x2+(y2*iImageWidth))*4));
//              dbWriteString(fh,JFC::CHAR1K);
//            };
//            dbWriteString(fh,"-----NewRow---------------------------------------------------");
//          };
//          dbCloseFile(fh);
//          */
//
//
//          // Make a diagnostic BMP file of the Tile to be sure things worked
//          JFC_DL *dlTemp = new JFC_DL();
//          dlTemp->ParseFilename(s->s);
//          dlTemp->FoundNth(PFN_POS_PATH);
//          s->Set( ((JFC_DLITEM*)dlTemp->Item)->Str->s);
//          dlTemp->FoundNth(PFN_POS_FILENOEXT);
//          s->ConCat( ((JFC_DLITEM*)dlTemp->Item)->Str->s);
//          USGSMapToBitMap(true,s->s,s->s);
//          SAFE_DELETE(s);
//          SAFE_DELETE(sFileOut);
//      };
//
//
//      // Now Tile What We Have
//      int tx=0; int ty=0;
//      int iTileMaxX=iTilesX * p_iTileWidth;
//      int iTileMaxY=iTilesY * p_iTileHeight;
//      sx=0;sy=0;
//      JGC_MEMBLOCK *mbOut=new JGC_MEMBLOCK();
//      mbOut->Make(p_iTileWidth * p_iTileHeight * 4);
//
//      for(y=0;y<iTilesY;y++){
//        for(x=0;x<iTilesX;x++){
//          int xl=x*p_iTileWidth;
//          int xr=xl+p_iTileWidth;
//          int yl=y*p_iTileHeight;
//          int yr=yl+p_iTileHeight;
//          for(ty=yl;ty<yr;ty++){
//            for(tx=xl;tx<xr;tx++){
//              sx=tx-xl;sy=ty-yl;
//              if((tx>=0)&&(tx<iImageWidth)&&(ty>=0)&&(ty<iImageHeight)){
//                mbOut->Float_Set( (sx+(sy*p_iTileWidth))*4,mb->Float_Get( (tx+(ty*iImageWidth))*4));
//              }else{
//                mbOut->Float_Set( (sx+(sy*p_iTileWidth))*4,USGS_ABSOLUTEZERO);
//              };
//            };
//          };
//
//          /*
//          sy=0;
//          for(ty=(y*p_iTileHeight);ty<((y+1)*p_iTileHeight);ty++){
//            sx=0;
//            for(tx=(x*p_iTileWidth);tx<((x+1)*p_iTileWidth);tx++){
//              if((tx>=0)&&(tx<iImageWidth)&&(ty>=0)&&(ty<iImageHeight)){
//                mbOut->Float_Set( (sx+(sy*p_iTileWidth))*4,mb->Float_Get( (tx+(ty*iImageWidth))*4));
//              }else{
//                mbOut->Float_Set( (sx+(sy*p_iTileWidth))*4,USGS_ABSOLUTEZERO);
//              };
//              sx++;
//            };
//            sy++;
//          };
//          */
//          JFC_STRING *sFileOut=new JFC_STRING();
//          //Write the header file for the tile
//          sFileOut->Set(sDestDir->s);
//          dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//          sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//          sFileOut->ConCat("_Tile_");
//          JFC_STRING *si=new JFC_STRING();
//          si->ZeroPadInt(y,2);
//          sFileOut->ConCat(si->s);
//          sFileOut->ConCat("_");
//          si->ZeroPadInt(x,2);
//          sFileOut->ConCat(si->s);
//          sFileOut->ConCat(".hdr");
//          dbOpenToWrite(fh,sFileOut->s);
//          JFC_STRING *s=new JFC_STRING(sFileOut->s);
//          sprintf(JFC::CHAR1K,"ncols         %i",p_iTileWidth);dbWriteString(fh,JFC::CHAR1K);
//          sprintf(JFC::CHAR1K,"nrows         %i",p_iTileHeight);dbWriteString(fh,JFC::CHAR1K);
//          float fNewXLLCorner=xllcorner-(cellsize*p_iTileWidth);
//          sprintf(JFC::CHAR1K,"xllcorner     %f",fNewXLLCorner);dbWriteString(fh,JFC::CHAR1K);
//          float fNewYLLCorner=yllcorner-(cellsize*p_iTileHeight);
//          sprintf(JFC::CHAR1K,"yllcorner     %f",fNewYLLCorner);dbWriteString(fh,JFC::CHAR1K);
//          sprintf(JFC::CHAR1K,"cellsize      %f",cellsize);dbWriteString(fh,JFC::CHAR1K);
//          dbWriteString(fh,"NODATA_value  -9999");
//          dbWriteString(fh,"byteorder     LSBFIRST");
//          dbCloseFile(fh);
//          //Write the Tile
//          sFileOut->Set(sDestDir->s);
//          dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//          sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//          sFileOut->ConCat("_Tile_");
//          si->ZeroPadInt(y,2);
//          sFileOut->ConCat(si->s);
//          sFileOut->ConCat("_");
//          si->ZeroPadInt(x,2);
//          sFileOut->ConCat(si->s);
//          SAFE_DELETE(si);
//          sFileOut->ConCat(".flt");
//          //--
//          dbCLS();
//          sprintf(JFC::CHAR1K,"Writing Tile %i %i (y,x) File: %s",y,x,sFileOut->s);dbPrint(JFC::CHAR1K);
//          dbSync();dbSync();
//          //--
//          dbOpenToWrite(fh,sFileOut->s);
//          int x2=0;int y2=0;
//          for(y2=0;y2<p_iTileHeight;y2++){
//            for(x2=0;x2<p_iTileWidth;x2++){
//              dbWriteFloat(fh,mbOut->Float_Get(  (x2+(y2*p_iTileWidth))*4));
//            };
//          };
//          dbCloseFile(fh);
//
//          // Make a diagnostic BMP file of the Tile to be sure things worked
//          JFC_DL *dlTemp = new JFC_DL();
//          dlTemp->ParseFilename(s->s);
//          dlTemp->FoundNth(PFN_POS_PATH);
//          s->Set( ((JFC_DLITEM*)dlTemp->Item)->Str->s);
//          dlTemp->FoundNth(PFN_POS_FILENOEXT);
//          s->ConCat( ((JFC_DLITEM*)dlTemp->Item)->Str->s);
//          USGSMapToBitMap(true,s->s,s->s);
//          SAFE_DELETE(s);
//          SAFE_DELETE(sFileOut);
//        };
//      };
//
//
//      SAFE_DELETE(tlbr);
//      SAFE_DELETE(sjTempFileName);
//      SAFE_DELETE(mb);
//      SAFE_DELETE(mbOut);
//    };
//    //----------------------------------------------------
//
//  };
//
//  SAFE_DELETE(sSrcPathNFile);
//  SAFE_DELETE(sSrcFileExt);
//  SAFE_DELETE(sSrcFile);
//  SAFE_DELETE(sSrcDir);
//  SAFE_DELETE(sDestDir);
//  SAFE_DELETE(sSrcUSGSHdr);
//  SAFE_DELETE(sSrcUSGSFlt);
//  SAFE_DELETE(DL);
//  SAFE_DELETE(dlFileParts);
//
//  JGC::Cam0->Backdrop_Set(bBackDropOn);
//  return bResult;
//};
////----------------------------------------------------------------------------



































//----------------------------------------------------------------------------
// This function takes a source file and allows you to resize it.
// smaller "tiles". Files supported:
//   *.DDS (Mip Maps not loaded) (Alpha channel Not adultered)
//   *.BMP
//   *.RAW (16 bit)
//   *.PNG (Alpha channel Not adultered)
//   *.JPG
//   *.FLT & *.HDR together ( USGS Grid Float file format) - If you pass a
//      source file without an extension - USGS gridfloat format is assumed.
//bool USGS::Resizer(
//  char *p_szSourceFile, // For USGS - Pass Filename without Extension.
//  char *p_szDestDirectory,
//  int p_iSourceTop, // If all ZEROS then full image used. RAW (16 bit) format
//  int p_iSourceLeft,  // REQUIRES valid values. RAW requires values to REFLECT
//                      // ENTIRE file. You can't Select a Chunk from a RAW file.
//                      // if the Raw file is 1024x1024, then the top, left,
//                      // right and bottom parameters should be: 0,0,1023,1023
//                      // respectively. This is because RAW doesn't tell you
//                      // the file dimensions - so you MUST enter them as I say.
//                      // Now Images have dimensions in them, and so do GRIDFLOAT's
//                      // USGS files in the *.hdr file.
//  int p_iSourceRight,
//  int p_iSourceBottom,
//  int p_iDesiredWidth, // Desired Tile Width - Fluff will be added to solve overlap.
//  int p_iDesiredHeight // Desired Tile Width - Fluff will be added to solve overlap.
//){
////----------------------------------------------------------------------------
//  bool bBackDropOn = JGC::Cam0->Backdrop_Get();
//  JGC::Cam0->Backdrop_Set(false);
//
//  JFC_DL *dlFileParts=new JFC_DL();
//  dlFileParts->ParseFilename( p_szSourceFile );
//
//  /*
//  dbPrint("JFC_DL->ParseFileName Function Test Result Below");
//  LoopGDK();
//  dlFileParts->MoveFirst();
//  JFC_STRING *s=new JFC_STRING();
//  do{
//    sprintf(JFC::CHAR1K,"dlFileParts->n = %i :",dlFileParts->NPosition);
//    s->Set(JFC::CHAR1K);
//    s->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//    dbPrint(s->s);
//  }while(dlFileParts->MoveNext());
//  delete s;s=NULL;
//  dbPrint("Waiting for input.");
//  dbSync();dbSync();
//  LoopGDK();
//  dbInput();
//  */
//
//  JFC_STRING *sSrcPathNFile=new JFC_STRING(p_szSourceFile);
//  JFC_STRING *sSrcFileExt=new JFC_STRING();
//  JFC_STRING *sSrcFile=new JFC_STRING();
//  JFC_STRING *sSrcDir=new JFC_STRING();
//  JFC_STRING *sDestDir=new JFC_STRING(p_szDestDirectory);
//  JFC_STRING *sSrcUSGSHdr=new JFC_STRING();
//  JFC_STRING *sSrcUSGSFlt=new JFC_STRING();
//  bool bResult = true;
//
//  if((sDestDir->s[sDestDir->Length()-1]!='\\') && (sDestDir->s[sDestDir->Length()-1]!='/')){
//    sDestDir->ConCat("/");
//  };
//
//  JFC_DL *DL=new JFC_DL();
//  sSrcPathNFile->Reverse();
//  DL->GetTokens(sSrcPathNFile,"/\\");
//  sSrcPathNFile->Reverse();
//  if(DL->MoveFirst()){
//    sSrcFile->Set(((JFC_DLITEM*)DL->Item)->Str->s);
//  }else{
//    sSrcFile->Set(sSrcPathNFile->s);
//  };
//  if(JGC::File->Exist(sSrcPathNFile->s)){
//    // we have a filename that exists
//    // Snag the file ext then and see if we support it.
//    DL->DeleteAll();
//    DL->GetTokens(sSrcFile,".");
//    if(DL->MoveFirst()){
//      sSrcFileExt->Set(((JFC_DLITEM*)DL->Item)->Str->s);
//      sSrcFileExt->Reverse();
//    };
//    bResult= sSrcFileExt->Equal("bmp") ||
//             sSrcFileExt->Equal("jpg") ||
//             sSrcFileExt->Equal("raw") ||
//             sSrcFileExt->Equal("dds") ||
//             sSrcFileExt->Equal("png");
//    if(!bResult){
//      dbCLS();
//      dbPrint("This utility supports *.bmp (24bit), *.jpg, *.raw (16bit) and *.png files.");
//      dbPrint("Here is what you gave me for a source file: ");
//      dbPrint(sSrcPathNFile->s);
//      dbPrint();
//      dbPrint("Press Enter:");
//      dbSync();
//      dbInput();
//    };
//  }else{
//    // Looks like we have possibly a missing file OR a USGS Grid Float.
//    // check for *.hdr and *.flt for source files - both must exist or
//    // we error out.
//    sSrcUSGSHdr->Set(sSrcPathNFile->s);
//    sSrcUSGSHdr->ConCat(".hdr");
//    sSrcUSGSFlt->Set(sSrcPathNFile->s);
//    sSrcUSGSFlt->ConCat(".flt");
//    bResult=JGC::File->Exist(sSrcUSGSHdr->s) && JGC::File->Exist(sSrcUSGSFlt->s);
//    if(!bResult){
//      dbCLS();
//      dbPrint("The Source file(s) can not be found, so I tried to see if you ");
//      dbPrint("wanted to process a USGS file but I couldn't find a *.flt ");
//      dbPrint("and *.hdr file pair. Here is what you gave me for a source file:");
//      dbPrint(sSrcPathNFile->s);
//      dbPrint();
//      dbPrint("Press Enter:");
//      dbSync();
//      dbInput();
//    }else{
//      sSrcFileExt->Set("hdr");
//    };
//  };
//
//  if (bResult){
//
//    int iImageWidth=p_iSourceRight-p_iSourceLeft + 1;
//    int iImageHeight=p_iSourceBottom-p_iSourceTop+1;
//
//
//    //----------------------------------------------------
//    // Process common gfx formats
//    //----------------------------------------------------
//    if ( sSrcFileExt->Equal("bmp") ||
//         sSrcFileExt->Equal("jpg") ||
//         sSrcFileExt->Equal("png") ||
//         sSrcFileExt->Equal("dds")
//      ){
//      JGC_PIXELGRID *pg=new JGC_PIXELGRID();
//      JGC_IMAGE *img=new JGC_IMAGE();
//      img->LoadImageGDK(sSrcPathNFile->s,false);
//          //DEBUG
//          //JFC_STRING *sFileOut=new JFC_STRING();
//          //sFileOut->Set(sDestDir->s);
//          //sprintf(JFC::CHAR1K,"test_loadedImage.bmp");
//          //sFileOut->ConCat(JFC::CHAR1K);
//          //img->Save(sFileOut->s);
//          //delete sFileOut;sFileOut=NULL;
//      pg->Size_Set(iImageWidth, iImageHeight);
//      pg->PasteImageOnThis(0,0,img->ID,p_iSourceLeft, p_iSourceTop, p_iSourceRight, p_iSourceBottom,NULL,true);
//          //DEBUG
//          //sFileOut=new JFC_STRING();
//          //sFileOut->Set(sDestDir->s);
//          //sprintf(JFC::CHAR1K,"test_pastedImage.bmp");
//          //sFileOut->ConCat(JFC::CHAR1K);
//          //img=pg->MakeImageFromThis();
//          //img->Save(sFileOut->s);
//          //delete sFileOut;sFileOut=NULL;
//
//
//      SAFE_DELETE(img);
//
//      JGC_PIXELGRID *pgOut=new JGC_PIXELGRID();
//      pgOut->Size_Set(p_iDesiredWidth,p_iDesiredHeight);
//      int tx=0; int ty=0;
//      int x=0; int y=0;
//      int sx=0;int sy=0;
//      for(y=0;y<iImageHeight;y++){
//        sy= (float)((float)p_iDesiredHeight/(float)iImageHeight)*((float)y);
//        for(x=0;x<iImageWidth;x++){
//          sx= (float)((float)p_iDesiredWidth/(float)iImageWidth)*((float)x);
//          pgOut->RGBA_Set(sx,sy, pg->RGBA_Get(x,y));
//        };
//      };
//
//      JFC_STRING *sFileOut=new JFC_STRING();
//      sFileOut->Set(sDestDir->s);
//      dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//      sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//      sFileOut->ConCat("_Resized_");
//      sprintf(JFC::CHAR1K,"%ix%i.",p_iDesiredWidth,p_iDesiredHeight);
//      sFileOut->ConCat(JFC::CHAR1K);
//      sFileOut->ConCat(sSrcFileExt->s);
//      img=pgOut->MakeImageFromThis();
//      img->Save(sFileOut->s);
//      SAFE_DELETE(img);
//      SAFE_DELETE(sFileOut);
//
//      SAFE_DELETE(pg);
//      SAFE_DELETE(pgOut);
//      SAFE_DELETE(img);
//    };
//    //----------------------------------------------------
//
//    //----------------------------------------------------
//    // Process 16 Bit (unsigned) RAW format
//    //----------------------------------------------------
//    if(sSrcFileExt->Equal("raw")){
//      int fh=JGC::File->FreeFile();
//      JGC_MEMBLOCK *mb=new JGC_MEMBLOCK();
//      mb->Make(iImageWidth * iImageHeight * 2);
//      dbOpenToRead(fh,sSrcPathNFile->s);
//      for(int y=0;y<iImageHeight;y++){
//        for(int x=0;x<iImageWidth;x++){
//          mb->Word_Set( (x+(y*iImageWidth))*2,dbReadWord(fh));
//        };
//      };
//      dbCloseFile(fh);
//
//      int tx=0; int ty=0;
//      int sx=0;int sy=0;
//      JGC_MEMBLOCK *mbOut=new JGC_MEMBLOCK();
//      mbOut->Make(p_iDesiredWidth * p_iDesiredHeight * 2);
//      for(int y=0;y<iImageHeight;y++){
//        sy= (float)((float)p_iDesiredHeight/(float)iImageHeight)*((float)y);
//        for(int x=0;x<iImageWidth;x++){
//          sx= (float)((float)p_iDesiredWidth/(float)iImageWidth)*((float)x);
//          mbOut->Word_Set((sx+(sy*p_iDesiredWidth))*2,mb->Word_Get( (x+(y*iImageWidth))*2 ));
//        };
//      };
//      JFC_STRING *sFileOut=new JFC_STRING();
//      sFileOut->Set(sDestDir->s);
//      dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//      sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//      sFileOut->ConCat("_Resized_");
//      sprintf(JFC::CHAR1K,"%ix%i.",p_iDesiredWidth,p_iDesiredHeight);
//      sFileOut->ConCat(JFC::CHAR1K);
//      sFileOut->ConCat(sSrcFileExt->s);
//      dbOpenToWrite(fh,sFileOut->s);
//      int x2=0;int y2=0;
//      for(y2=0;y2<p_iDesiredHeight;y2++){
//        for(x2=0;x2<p_iDesiredWidth;x2++){
//          dbWriteWord(fh,mbOut->Word_Get( (x2+(y2*p_iDesiredWidth))*2) );
//        };
//      };
//      dbCloseFile(fh);
//      SAFE_DELETE(sFileOut);
//    };
//    //----------------------------------------------------
//
//    //----------------------------------------------------
//    // Process USGS
//    //----------------------------------------------------
//    if(sSrcFileExt->Equal("hdr")){
//      // Get Cols and Rows from Header file
//      JFC_STRING *sjData=new JFC_STRING();
//      JFC_STRING *sjTempFileName=new JFC_STRING();
//      int FileRows=0;
//      int FileCols=0;
//      float xllcorner=0.0f;
//      float yllcorner=0.0f;
//      float cellsize=0.0f;
//
//      int fh=JGC::File->FreeFile();
//      sjTempFileName->Set(sSrcPathNFile->s);
//      sjTempFileName->ConCat(".");
//      sjTempFileName->ConCat(sSrcFileExt->s);
//      dbOpenToRead(fh,sjTempFileName->s);
//      sjData->Set(dbReadString(fh));
//      DL->GetTokens(sjData," ");
//      DL->MoveNext();//Pass the ncols Keyword
//      FileCols=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//      sjData->Set(dbReadString(fh));
//      DL->GetTokens(sjData," ");
//      DL->MoveNext();//Pass the nrows Keyword
//      FileRows=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//      sjData->Set(dbReadString(fh));
//      DL->GetTokens(sjData," ");
//      DL->MoveNext();//Pass the xllcorner Keyword
//      xllcorner=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//      sjData->Set(dbReadString(fh));
//      DL->GetTokens(sjData," ");
//      DL->MoveNext();//Pass the yllcorner Keyword
//      yllcorner=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//      sjData->Set(dbReadString(fh));
//      DL->GetTokens(sjData," ");
//      DL->MoveNext();//Pass the cellsize Keyword
//      cellsize=dbVal(((JFC_DLITEM*)DL->Item)->Str->s);
//      dbCloseFile(fh);
//      SAFE_DELETE(sjData);
//
//      // See if user wants to use whole file based
//      // on TLBR parameters. If All Zeroes - then
//      // use whole file. Otherwise Snag the specified
//      // area as our base starting point to tile off of.
//      JFC_TLBR *tlbr=new JFC_TLBR(p_iSourceTop,p_iSourceLeft,p_iSourceBottom,p_iSourceRight);
//
//      if((p_iSourceLeft==0)&&(p_iSourceRight==0)&&
//        (p_iSourceTop==0)&&(p_iSourceBottom==0)){
//        iImageWidth=FileCols;
//        iImageHeight=FileRows;
//        tlbr->Width_Set(iImageWidth);
//        tlbr->Height_Set(iImageHeight);
//      };
//
//      // Read in the Data we want to Tile
//      sjTempFileName->Set(sSrcPathNFile->s);
//      sjTempFileName->ConCat(".flt");
//      dbOpenToRead(fh,sjTempFileName->s);
//      JGC_MEMBLOCK *mb=new JGC_MEMBLOCK();
//      mb->Make(iImageWidth * iImageHeight * 4);
//      int sx=0;int sy=0;float f=0.0f;
//      int x=0;int y=0;
//
//      for(y=0;y<FileRows;y++){
//        for(x=0;x<FileCols;x++){
//          f=dbReadFloat(fh);
//          if(tlbr->Inside(x,y)){
//            //mb->Float_Set( (sx*4)+((sy*4)*iImageWidth), f);
//            mb->Float_Set( ((x-tlbr->Left)+((y-tlbr->Top)*iImageWidth))*4, f);
//          };
//        };
//        if((y % 128)==0){
//          dbCLS();
//          sprintf(JFC::CHAR1K,"Reading Source Row: %i  File: %s",y,sjTempFileName->s);dbPrint(JFC::CHAR1K);
//          dbSync();dbSync();
//        };
//      };
//      dbCloseFile(fh);
//
//      // save a Diagnostic of the data we want to tile
//      {
//          JFC_STRING *sFileOut=new JFC_STRING();
//          //Write the header file for the tile
//          sFileOut->Set(sDestDir->s);
//          dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//          sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//          sFileOut->ConCat("_Diagnostic");
//          //JFC_STRING *si=new JFC_STRING();
//          sFileOut->ConCat(".hdr");
//          dbOpenToWrite(fh,sFileOut->s);
//          JFC_STRING *s=new JFC_STRING(sFileOut->s);
//          sprintf(JFC::CHAR1K,"ncols         %i",iImageWidth);dbWriteString(fh,JFC::CHAR1K);
//          sprintf(JFC::CHAR1K,"nrows         %i",iImageHeight);dbWriteString(fh,JFC::CHAR1K);
//          float fNewXLLCorner=xllcorner-(cellsize*tlbr->Width_Get());
//          sprintf(JFC::CHAR1K,"xllcorner     %f",fNewXLLCorner);dbWriteString(fh,JFC::CHAR1K);
//          float fNewYLLCorner=yllcorner-(cellsize*tlbr->Height_Get());
//          sprintf(JFC::CHAR1K,"yllcorner     %f",fNewYLLCorner);dbWriteString(fh,JFC::CHAR1K);
//          sprintf(JFC::CHAR1K,"cellsize      %f",cellsize);dbWriteString(fh,JFC::CHAR1K);
//          dbWriteString(fh,"NODATA_value  -9999");
//          dbWriteString(fh,"byteorder     LSBFIRST");
//          dbCloseFile(fh);
//          //Write the Tile
//          sFileOut->Set(sDestDir->s);
//          dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//          sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//          sFileOut->ConCat("_Diagnostic.flt");
//          //--
//          dbCLS();
//          sprintf(JFC::CHAR1K,"Writing Diagnostic File: %s",sFileOut->s);dbPrint(JFC::CHAR1K);
//          dbSync();dbSync();
//          //--
//          dbOpenToWrite(fh,sFileOut->s);
//          int x2=0;int y2=0;
//          for(y2=0;y2<iImageHeight;y2++){
//            for(x2=0;x2<iImageWidth;x2++){
//              dbWriteFloat(fh,mb->Float_Get((x2+(y2*iImageWidth))*4));
//            };
//          };
//          dbCloseFile(fh);
//
//          /*
//          // Make Diagnosic TEXT file of the Values
//          sFileOut->ConCat(".txt");
//          dbOpenToWrite(fh,sFileOut->s);
//          x2=0;y2=0;
//          for(y2=0;y2<iImageHeight;y2++){
//            sprintf(JFC::CHAR1K,"Col %i  Row %i", x2,y2);
//            dbWriteString(fh,JFC::CHAR1K);
//            for(x2=0;x2<iImageWidth;x2++){
//              sprintf(JFC::CHAR1K,"%f",mb->Float_Get((x2+(y2*iImageWidth))*4));
//              dbWriteString(fh,JFC::CHAR1K);
//            };
//            dbWriteString(fh,"-----NewRow---------------------------------------------------");
//          };
//          dbCloseFile(fh);
//          */
//
//
//          // Make a diagnostic BMP file of the Tile to be sure things worked
//          JFC_DL *dlTemp = new JFC_DL();
//          dlTemp->ParseFilename(s->s);
//          dlTemp->FoundNth(PFN_POS_PATH);
//          s->Set( ((JFC_DLITEM*)dlTemp->Item)->Str->s);
//          dlTemp->FoundNth(PFN_POS_FILENOEXT);
//          s->ConCat( ((JFC_DLITEM*)dlTemp->Item)->Str->s);
//          USGSMapToBitMap(true,s->s,s->s);
//          SAFE_DELETE(s);
//          SAFE_DELETE(sFileOut);
//      };
//
//
//      // Now Save What We Have Resized
//      int tx=0; int ty=0;
//      sx=0;sy=0;
//      JGC_MEMBLOCK *mbOut=new JGC_MEMBLOCK();
//      mbOut->Make(p_iDesiredWidth * p_iDesiredHeight * 4);
//      for(int y=0;y<iImageHeight;y++){
//        sy= (float)((float)p_iDesiredHeight/(float)iImageHeight)*((float)y);
//        for(int x=0;x<iImageWidth;x++){
//          sx= (float)((float)p_iDesiredWidth/(float)iImageWidth)*((float)x);
//          mbOut->Float_Set( (sx+(sy*p_iDesiredHeight))*4,mb->Float_Get( (x+(y*iImageWidth))*4));
//        };
//      };
//
//
//      JFC_STRING *sFileOut=new JFC_STRING();
//      //Write the header file for the tile
//      sFileOut->Set(sDestDir->s);
//      dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//      sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//      sFileOut->ConCat("_Resized_");
//      sprintf(JFC::CHAR1K,"%ix%i.",p_iDesiredWidth,p_iDesiredHeight);
//      sFileOut->ConCat(JFC::CHAR1K);
//      sFileOut->ConCat("hdr");
//      dbOpenToWrite(fh,sFileOut->s);
//      JFC_STRING *s=new JFC_STRING(sFileOut->s);
//      sprintf(JFC::CHAR1K,"ncols         %i",p_iDesiredWidth);dbWriteString(fh,JFC::CHAR1K);
//      sprintf(JFC::CHAR1K,"nrows         %i",p_iDesiredHeight);dbWriteString(fh,JFC::CHAR1K);
//      float fNewXLLCorner=xllcorner-(cellsize*tlbr->Left);
//      sprintf(JFC::CHAR1K,"xllcorner     %f",fNewXLLCorner);dbWriteString(fh,JFC::CHAR1K);
//      float fNewYLLCorner=yllcorner-(cellsize*tlbr->Top);
//      sprintf(JFC::CHAR1K,"yllcorner     %f",fNewYLLCorner);dbWriteString(fh,JFC::CHAR1K);
//      sprintf(JFC::CHAR1K,"cellsize      %f",cellsize/((float)p_iDesiredWidth/(float)iImageWidth));dbWriteString(fh,JFC::CHAR1K);
//      dbWriteString(fh,"NODATA_value  -9999");
//      dbWriteString(fh,"byteorder     LSBFIRST");
//      dbCloseFile(fh);
//      //Write the Tile
//      sFileOut->Set(sDestDir->s);
//      dlFileParts->FoundNth(PFN_POS_FILENOEXT);
//      sFileOut->ConCat(((JFC_DLITEM*)dlFileParts->Item)->Str->s);
//      sFileOut->ConCat("_Resized_");
//      sprintf(JFC::CHAR1K,"%ix%i.",p_iDesiredWidth,p_iDesiredHeight);
//      sFileOut->ConCat(JFC::CHAR1K);
//      sFileOut->ConCat("flt");
//      //--
//      dbCLS();
//      sprintf(JFC::CHAR1K,"Writing Output to File: %s",sFileOut->s);dbPrint(JFC::CHAR1K);
//      dbSync();dbSync();
//      //--
//      dbOpenToWrite(fh,sFileOut->s);
//      int x2=0;int y2=0;
//      for(y2=0;y2<p_iDesiredHeight;y2++){
//        for(x2=0;x2<p_iDesiredWidth;x2++){
//          dbWriteFloat(fh,mbOut->Float_Get(  (x2+(y2*p_iDesiredWidth))*4));
//        };
//      };
//      dbCloseFile(fh);
//
//      // Make a diagnostic BMP file of the Output to be sure things worked
//      JFC_DL *dlTemp = new JFC_DL();
//      dlTemp->ParseFilename(s->s);
//      dlTemp->FoundNth(PFN_POS_PATH);
//      s->Set( ((JFC_DLITEM*)dlTemp->Item)->Str->s);
//      dlTemp->FoundNth(PFN_POS_FILENOEXT);
//      s->ConCat( ((JFC_DLITEM*)dlTemp->Item)->Str->s);
//      USGSMapToBitMap(true,s->s,s->s);
//      SAFE_DELETE(s);
//      SAFE_DELETE(sFileOut);
//
//
//      SAFE_DELETE(tlbr);
//      SAFE_DELETE(sjTempFileName);
//      SAFE_DELETE(mb);
//      SAFE_DELETE(mbOut);
//    };
//    //----------------------------------------------------
//
//  };
//
//  SAFE_DELETE(sSrcPathNFile);
//  SAFE_DELETE(sSrcFileExt);
//  SAFE_DELETE(sSrcFile);
//  SAFE_DELETE(sSrcDir);
//  SAFE_DELETE(sDestDir);
//  SAFE_DELETE(sSrcUSGSHdr);
//  SAFE_DELETE(sSrcUSGSFlt);
//  SAFE_DELETE(DL);
//  SAFE_DELETE(dlFileParts);
//
//  JGC::Cam0->Backdrop_Set(bBackDropOn);
//  return bResult;
//};
////----------------------------------------------------------------------------



//============================================================================
begin
end.
//============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

