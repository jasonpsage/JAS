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
// Tests the Jegas Tokenizer Class in uxxg_jfc_tokenizer.pp
program toke;
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
Uses
//=============================================================================
  ug_common,
  ug_jfc_tokenizer;
//=============================================================================

//=============================================================================
Var
//=============================================================================
  TK: jfc_TOKENIZER;
  dwResult: LongWord;
  saResult: AnsiString;
  //srcin: String;
  html: AnsiString;
  Result: Boolean;
//=============================================================================

//=============================================================================
Begin
//=============================================================================

//While not Eof() Do
///Begin
//    ReadLn(srcin);
//    html:=html+' '+srcin;
//End;

  bLoadTextfile('myfriend.htm',html);
  Writeln('Loaded It... Processing...');
  Result:=True;
  TK:=jfc_TOKENIZER.Create;
  TK.bKeepDebugInfo:=True;
  TK.saSeparators:=' ';
  TK.saWhiteSpace:=' ';
  TK.bKeepDebugInfo:=True;
  Tk.QuotesXDL.DeleteAll;
  TK.QuotesXDL.AppendItem_QuotePair('<','>');
  TK.Tokenize(html);
 //         (TK.NthItem_saToken(1)='Hello') and
 //         (TK.NthItem_saToken(2)='There') and
 //         (TK.NthItem_saToken(3)='Dude!') and
 //         (TK.MoveFirst) and
 //         (TK.Item_saToken='Hello') and
 //         (TK.MoveNext) and
 //         (TK.Item_saToken='There') and
 //         (TK.MoveNExt) and
 //         (TK.Item_saToken='Dude!') and
 //         (not TK.MoveNExt) and
 //         (TK.Tokens=TK.ListCount);
          
 // if not result then Begin
 //   Writeln('Error With Test #1');
    TK.DumpToTextFile('');
    //Writeln('See Log File:','debug_jfc_tokenizer_test01.txt');
  TK.Destroy;
//=============================================================================
End.
//=============================================================================

//*****************************************************************************
// EOF
//*****************************************************************************

