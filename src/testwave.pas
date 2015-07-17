program testwave;
uses
  ug_jegas,
  ug_jfc_xdl,
  ug_wave;

var 
  Wave: TWAVE;
  u8Result: UInt64;
  saResult: ansistring;
  bOk: boolean;
  saFilename: ansistring;
  WaveMerge: TWAVEMERGE;

//------------------ Colors of Waveform in Graphics file created during processevent
const cnColorPenR = 32;
const cnColorPenG = 32;
const cnColorPenB = 255;
const cnColorBgR = 0;
const cnColorBgB = 0;
const cnColorBgG = 0;
//------------------ Colors of Waveform in Graphics file created during processevent



  
begin
  //writeln('Create WaveMerge');
  WaveMerge:=TWaveMerge.Create;

  //writeln('Add Files');
  WaveMerge.AppendItem_saName('/xfiles/inet/jas/vrooster/webroot/download/2012/0911/1332/4713/166E/work/2012091113333248857_Video_Processed.wav');
  WaveMerge.AppendItem_saName('/xfiles/inet/jas/vrooster/webroot/download/2012/0911/1332/4713/166E/work/2012091113332681067_Video_Processed.wav');

  //Writeln('Load Waves');
  bOk:=WaveMerge.bLoadWaves(u8result,saResult);
  if not bOk then
  begin
    writeln('bLoadWaves Failed: ',u8Result,' ',saResult);
  end;

  //if bOk then
  //begin
  //  Writeln('Diagnose Waves');
  //  if WaveMErge.MoveFirst then
  //  begin
  //    repeat
  //      writeln;
  //      writeln(saRepeatchar('=',78));
  //      writeln(TWAVE(JFC_XDLITEM(WaveMerge.lpItem).lpPtr).saDiagnosticInfo);
  //      writeln(saRepeatChar('=',78));
  //      writeln;
  //    until not WaveMerge.MoveNExt;
  //  end;
  //end;

  
  
  if bOk then
  begin
    //writeln('Merge');
    bOk:=WaveMerge.bMerge;
    if not bOk then
    begin
      writeln('bMerge Failed');
    end;
  end;
  
  if bOk then
  begin
    //writeln('Save Merged Wave');
    bOk:=WaveMerge.bSaveMergedWave('test.wav',u8result,saResult);
    if not bOk then
    begin
      writeln('bSaveMergedWave Failed: ',u8Result,' ',saResult);
    end;
  end;

  if 1=2 then
  begin
    writeln('Making Bitmap...');
    bOk:=WaveMerge.MergedWave.bMakeBitMap(
      1600,
      800,
      cnColorPenR,
      cnColorPenG,
      cnColorPenB,
      cnColorBgR,
      cnColorBgG,
      cnColorBgB,
      'test.bmp',
      u8Result,
      saResult
    );
    if not bOk then
    begin
      writeln('bMakeBitmap Failed: ',u8Result,' ',saResult);
    end;
  end;
  
  WaveMerge.Destroy;WaveMerge:=Nil;
  
  {
  saFilename:='/xfiles/inet/jas/vrooster/webroot/download/'+
              '2012/0911/1332/4713/166E/work/'+
              '2012091113332681067_Video_Processed.wav';

  Wave:=TWave.create;
  bOk:=Wave.Load(saFilename, u8Result, saResult);
  if not bOk then
  begin
    writeln('Error :',u8result,' ',saResult);
  end;

  if bOk then
  begin
    writeln(Wave.saDiagnosticInfo);
  end;

  wave.wavereset;

  wave.Createnewwave(2000000);
  bOk:=wave.save('test.wav',u8Result, saResult);
  
  if not bOk then
  begin
    writeln('Error :',u8result,' ',saResult);
  end
  else
  begin
    writeln(Wave.saDiagnosticInfo);
  end;
  Wave.destroy;
  }

  writeln('DONE :) ');
end.
