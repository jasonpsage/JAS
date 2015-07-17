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
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$INCLUDE i_jegas_macros.pp}
{$SMARTLINK ON}
{$MODE objfpc}
{$PACKRECORDS 4}
//=============================================================================

//=============================================================================
program AnalyzePHPSerializedData;
//=============================================================================



//=============================================================================
uses
//=============================================================================
  ug_jfc_tokenizer;
//=============================================================================

var saIn: ansistring;


//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// Process php serialized data
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=
//=============================================================================
function AnalyzePHPSerializedData(p_saIn: ansistring):boolean;
//=============================================================================
var TK: jfc_TOKENIZER;
    
label jumphere;

Begin
  TK:=jfc_TOKENIZER.Create;
  
  // Test01
  TK.bKeepDebugInfo:=true;
  TK.saSeparators:='{';
  //TK.saWhiteSpace:=#13#10#20;
  //TK.QuotesXDL.AppendItem_saName_N_saDesc('"','"');
  //TK.QuotesXDL.AppendItem_saName_N_saDesc('{','}');
  TK.bKeepDebugInfo:=true;
  writeln('about to tokenize');
  TK.Tokenize(p_saIn);
  writeln('done tokenizing');
  TK.DumpToTextFile('Debug_Tokenizer.txt');
  TK.Destroy;
  
  
  
  
{  
  
          (TK.NthItem_saToken(1)='Hello') and
          (TK.NthItem_saToken(2)='There') and 
          (TK.NthItem_saToken(3)='Dude!') and 
          (TK.MoveFirst) and
          (TK.Item_saToken='Hello') and
          (TK.MoveNext) and
          (TK.Item_saToken='There') and 
          (TK.MoveNExt) and
          (TK.Item_saToken='Dude!') and
          (not TK.MoveNExt) and
          (TK.Tokens=TK.ListCount);
          
  if not result then Begin
    Writeln('Error With Test #1');
    TK.DumpToTextFile('');
    //Writeln('See Log File:','debug_jfc_tokenizer_test01.txt');
    goto jumphere;
  End;
  
  
  
  // Test02
  TK.saSeparators:=' ';
  TK.saWhiteSpace:=' ';
  TK.QuotesXDL.AppendItem_QuotePair('[@','@]');
  result:=(TK.DeleteAll) and(TK.ListCount=0) and 
          (TK.Tokenize('Hello There [@name@]!')=4) and
          TK.MoveFirst and (Tk.Item_saToken='Hello') and (TK.Item_iQuoteID=0) and 
          TK.MoveNExt and (TK.Item_saToken='There') and (TK.Item_iQuoteID=0) and
          TK.MoveNExt and (TK.Item_saToken='name') and (TK.Item_iQuoteID=1) and
          TK.MoveNExt and (tk.Item_saToken='!') and (TK.Item_iQuoteID=0);
  
  if not result then Begin
    Writeln('Error With Test #2');
    TK.DumpToTextFile('');
  End;  
  
  Tk.DeleteAll;
  TK.Destroy;

  // Do This: Allow Blank Start quote - Test
  // and Allow Blank End Quote - Test




// ---- TWEAKED Version 1 Stuff Below (single Quotes in saQUOTES only)
  
  //Writeln('Testing Single Quote System...');
  TK:=jfc_TOKENIZER.Create;
  TK.bKeepDebugInfo:=true;
  //Writeln('Past Token Init');
  Result:=true;
  if Result then result:=TK.saQuotes='';
  if Result then result:=TK.saSeparators='';
  if Result then result:=TK.saWhiteSpace='';
  if Result then result:=TK.Tokens=0;
  //if Result then result:=TK.TokenText='';    // Equivalent would bomb cuz ZERO
  if Result then result:=TK.NthItem_saToken(1)=''; // Always works - returns '' when not found
  if Result then result:=TK.Token=0;
  if not Result then Begin
    Writeln('Problem With jfc_TOKENIZER Init');
    goto jumphere;
  End;
  //Writeln('Token Batch 1');
  
  TK.saQuotes:='"';
  TK.saSeparators:=', ';
  TK.saWhiteSpace:=' ';
  
  
  
  if Result then result:=TK.Tokenize('')=0;
  if Result then result:=TK.saQuotes='"';
  if Result then result:=TK.saSeparators=', ';
  if Result then result:=TK.saWhiteSpace=' ';
  if Result then result:=TK.Tokens=0;
  //if Result then result:=TK.TokenText='';
  //if Result then result:=TK.TokenText(1)='';
  if Result then result:=TK.Token=0;
  if not Result then Begin
    Writeln('Problem With jfc_TOKENIZER.TOKENIZER('''')');
    goto jumphere;
  End;
  //Writeln('Token Batch 2');
  
  
  TK.saQuotes:='';
  TK.saSeparators:=' ';
  TK.saWhiteSpace:=' ';
  //if not Result then Writeln('jfc_TOKENIZER.TOKENIZER(''Hello There'')');
  //Writeln('before tokenize');
  dwResult:=TK.Tokenize('Hello There');
  //Writeln('after tokenize');
  if Result then Begin
    result:=dwResult=2;
    if not Result then Begin
      Writeln('Failed to return valid result' +
        '. Expected:2 Recieved:',dwResult);
    End;
  End;
  if not Result then goto jumphere;
  //Writeln('Token Batch 3');
     
  if not Result then goto jumphere;
  if Result then Begin
    result:=TK.saQuotes='';
    if not Result then Writeln('TK.saQuotes corrupt');
  End;
  if Result then Begin
    result:=TK.saSeparators=' ';
    if not Result then Writeln('TK.saSeparators corrupt');
  End;
  if Result then Begin
    result:=TK.saWhiteSpace=' ';
    if not Result then Writeln('TK.saWhiteSpace Corrupt');
  End;
  if Result then Begin
    dwResult:=TK.Tokens;
    result:=dwResult=2;
    if not Result then Writeln('TK.Tokens Returns Invalid Result. '+
       'Expected:2 Recieved:',dwResult);
  End;
  TK.MoveFirst;
  if Result then Begin
    saResult:=TK.Item_saToken;
    result:=saResult='Hello';
    if not Result then Writeln('TK.TokenText failed to return valid '+
       'result. Expected:''Hello'' Recieved:'''+saResult+'''');
  End;

  if Result then Begin
    saResult:=TK.NthItem_saToken(1);
    result:=saResult='Hello';
    if not Result then Writeln('TK.NthItem_saToken(1) failed to return valid '+
       'result. Expected:''Hello'' Recieved:'''+saResult+'''');
  End;
  if Result then Begin
    dwResult:=TK.Token; // Same as TK.N;
    result:=dwResult=1;
    if not Result then Writeln('(check 1) TK.Token failed to return valid '+
       'result. Expected:1 Recieved:', dwResult);
  End;
  if Result then Begin
    saResult:=TK.NthItem_saToken(2);
    result:=saResult='There';
    if not Result then Writeln('TK.NthItem_saToken(2) failed to return valid '+
       'result. Expected:''There'' Recieved:'''+saResult+'''');
  End;
  if Result then Begin
    dwResult:=TK.Token;
    result:=dwResult=2;
    if not Result then Writeln('(check 2) TK.Token failed to return valid '+
      'result. Expected:2 Recieved:', dwResult);
  End;
  if Result then Begin
    saResult:=TK.Item_saToken;
    result:=saResult='There';
    if not Result then Writeln('TK.Item_saToken failed to return valid '+
       'result. Expected:''There'' Recieved:'''+saResult+'''');
  End;
  
  if not Result then 
  Begin
    //Writeln('Problem With jfc_TOKENIZER.TOKENIZER(''Hello There'')');
    TK.DumpToTextFile('');
    goto jumphere;
  End;
  
  //Writeln('Token Batch 4');
  
//  Write('TOKENIZR - First Big Test - OK! Press Enter:');
//  readln;
  TK.saQuotes:='"';
  TK.saSeparators:=', ';
  TK.saWhiteSpace:=' ';
  if Result then Begin
    dwResult:=TK.Tokenize('Hello, "John""Boy"""');
    result:=dwResult=3;
    //Writeln('jfc_TOKENIZER.TOKENIZER(''Hello, "John""Boy"""'')');
    if not result then Begin
      Writeln('Failed to return valid result' +
        '. Expected:3 Recieved:',dwResult);
      TK.DumpToTextFile('');
      goto jumphere;
    End;
  End;
  //Writeln('Token Batch 5');


  if Result then Begin 
    result:=TK.saQuotes='"';
    if not Result then Writeln('TK.saQuotes corrupt');
  End;
  if Result then Begin
    result:=TK.saSeparators=', ';
    if not Result then Writeln('TK.saSeparators corrupt');
  End;
  if Result then Begin
    result:=TK.saWhiteSpace=' ';
    if not Result then Writeln('TK.saWhiteSpace Corrupt');
  End;
  if Result then Begin
    dwResult:=TK.Tokens;
    result:=dwResult=3;
    if not Result then Writeln(' -> TK.Tokens Returns Invalid Result. '+
      'Expected:3 Recieved:',dwResult);
  End;
  if Result then Begin
    TK.MoveFirst;
    saResult:=TK.NthItem_saToken(TK.Token);
    result:=saResult='Hello';
    if not Result then Writeln('TK.NthItem_saToken failed to return valid '+
      'result. Expected:''Hello'' Recieved:'''+saResult+'''');
  End;
  if Result then saResult:=TK.NthItem_saToken(1);
  if Result then Begin
    result:=saResult='Hello';
    if not Result then Writeln('TK.NthItem_saToken(1) failed to return valid '+
      'result. Expected:''Hello'' Recieved:'''+saResult+'''');
  End;
  if Result then dwResult:=TK.Token;
  if Result then Begin
    result:=dwResult=1;
    if not Result then Writeln('(check 1) TK.Token failed to return valid '+
       'result. Expected:1 Recieved:', dwResult);
  End;
  if Result then Begin
    saResult:=TK.NthItem_saToken(2);
    result:=saResult=',';
    if not Result then Writeln('TK.NthItem_saToken(2) failed to return valid '+
      'result. Expected:'','' Recieved:'''+saResult+'''');
  End;
  if Result then Begin
    dwResult:=TK.Token;
    result:=dwResult=2;
    if not Result then Writeln('(check 2) TK.Token failed to return valid '+
       'result. Expected:2 Recieved:', dwResult);
  End;
  if Result then Begin
    saResult:=TK.Item_saToken;
    result:=saResult=',';
    if not Result then Begin
      //Writeln('jfc_TOKENIZER.TOKENIZER(''Hello, "John""Boy"""'')');
      Writeln('TK.Item_saToken failed to return valid '+
       'result. Expected:'','' Recieved:'''+saResult+'''');
      TK.DumpToTextFile('');
      goto jumphere;
    End;
  End;
  
  //Writeln('Token Batch 6');
  if Result then Begin
    saResult:=TK.NthItem_saToken(3);
    Result:=saResult='John"Boy"';
    if not Result then Begin
      Writeln('TK.NthItem_saToken(2) failed. '+
        'Expected:''John"Boy"'' Recieved:'''+saResult+'''');
      goto jumphere;
    End;
  End;
  if result then Begin
    result:=TK.Item_iQuoteID=-1;
    if not result then Begin
      Writeln('TK.Item_iQuoteID (jfc_TOKENITEM(TK.lpItem).Item_iQuoteID) Faild!'+
        ' Expected -1, Got:',TK.Item_iQuoteID);
      goto jumphere;
    End;
  End;
  
  if Result then Begin
    dwResult:=TK.Token;
    result:=dwResult=3;
    if not Result then Writeln('(check 2) TK.Token failed to return valid '+
       'result. Expected:3 Recieved:', dwResult);
  End;
  
  if not result then Begin
    TK.DumpToTextFile('');
    goto jumphere;
  End;
  
  //Writeln('Token Batch 7');
  TK.saQuotes:='"';
  TK.saSeparators:='';
  TK.saWhiteSpace:=' ';
  if Result then dwResult:=TK.Tokenize('Hello  There');
  if Result then Result:=dwresult=1;
  if not result then 
  Begin
    Writeln('jfc_TOKENIZER.TOKENIZER(''Hello  There'') With Special Config');
    Writeln('Problem With jfc_TOKENIZER.Tokenize(''Hello There''); With special config');
    TK.DumpToTextFile('');
    goto jumphere;
  End;


  //Writeln('Token Batch 8');
  
  
  
  //Writeln('jfc_TOKENIZER Tests:',Result);

// code to examine tokens
//  for dwResult :=1 to dwResult do
//  begin
//    Writeln('>' + TK.TokenText(dwResult) + '< ',dwResult);
//  end;
}


End;
//=============================================================================


















var 
  cc: char;
  stdin: text;
//=============================================================================
Begin // Main Program
//=============================================================================
  saIn:='';
  assign(stdin,'');
  reset(stdin);
  while not eof(stdin) do
  begin
    read(stdin,cc);
    saIn+=cc;
  end;
  close(stdin);
  //writeln(saIn);
  
  if length(saIn)>0 then
  begin
    AnalyzePHPSerializedData(saIn);
  end
  else
  begin
    writeln('usage: [exename] < text_filename_has_serialized_php_data.txt');
  end;
  
End.
//=============================================================================
  
