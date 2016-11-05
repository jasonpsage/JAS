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
{ }
// Test Jegas Foundation Class: JFC_BUFFER
program test_ug_jfc_buffer;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$SMARTLINK ON}
{$MODE objfpc}
{$PACKRECORDS 4}
//=============================================================================


//=============================================================================
uses
//=============================================================================
  ug_jfc_buffer;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// JFC_BUFFER Test CODE
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=
//=============================================================================
function test_JFC_buffer: boolean;
//=============================================================================

const
  cs_data = 'TEST DATA';
  cn_size = 1024*1024*2;     

var 
  sa: AnsiString;
  i: integer;
  clsBuffer: JFC_BUFFER;

Begin
  result:=true;
  //Writeln('Testing JFC_BUFFER Class...');
  clsBuffer:=JFC_BUFFER.Create(cn_size,1); 
  
  i:=0;
  while result and (i<100) do
  Begin
    i+=1;
    sa:=cs_data;  
    clsBuffer.sain(sa);
    result:=(clsBuffer.saOut=cs_data) and (sa='');
  End;
  
  //Writeln('Heavy Test...');
  //Write('1 ');
  sa:=stringofchar('?',cn_size*2);
  //Write('2 ');
  result :=length(sa)=cn_size*2;
  
  if result then
  Begin
    //Write('3 ');
    clsBuffer.sain(sa);
    result:=length(sa)=cn_size;
    if result then 
    Begin
      //Write('4 ');
      result:=clsBuffer.uItems=cn_size;
      if result then
      Begin
        //Write('5 ');
        result:=clsBuffer.uSize=cn_size;
        if result then
        Begin
          //Write('6 ');
          Result:=length(clsBuffer.saOut)=cn_size;
          if result then 
          Begin
            //Write('7 ');
            result:=clsBuffer.saOut=stringofchar('?',cn_size);
            if result then
            Begin
              //Writeln('8 ');
            End;
          End;
        End;
      End;
    End;
  End;

  //Writeln('Freeing Big Chunk-o-mem...');
  clsBuffer.Destroy;

End;
//=============================================================================


var bResult: boolean;
//=============================================================================
Begin // Main Program
//=============================================================================
  bresult:=true;
  Writeln('Please Wait - Slamming da code!');
  if bResult then
  Begin
    bResult:=test_JFC_buffer;
    Writeln('JFC_BUFFER Test Result:',bresult);
  End;
  Writeln;
  Write('Press Enter To End This Program:');
  readln;
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

