{=============================================================================
|    _________ _______  _______  ______  _______             Get out of the  |
|   /___  ___// _____/ / _____/ / __  / / _____/               Mainstream... |
|      / /   / /__    / / ___  / /_/ / / /____                Jump into the  |
|     / /   / ____/  / / /  / / __  / /____  /                   Jetstream   |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                         info@jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}

//=============================================================================
{ }
// Testing the uxxg_jfc_xml.pp Unit
program test_ug_jfc_xml;
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
ug_jfc_xml,
ug_misc,
sysutils,
ug_common;
//=============================================================================
var gsaFileName: ansistring;

//=============================================================================
function bTest_JFC_XML_From_File(p_safile:ansistring): boolean;
//=============================================================================
var
  XML: JFC_XML;
  bOk: boolean;
  saXML: ansistring;
begin
  XML:=JFC_XML.Create;
  bOk:=fileexists(p_safile);
  if not bOk then
  begin
    writeln('file not found: ',p_saFile);
  end;

  if bOk then
  begin
    bOk:=bLoadTextFile(p_safile, saXML);
    if not bOk then
    begin
      writeln('bLoadTextFile failed.');
    end;
  end;

  if bOk then
  begin
    writeln('Loaded XML, Now On to Tokenizing it.');
    bOk:=XML.bParseXML(saXML);
    if bOk then
    begin
      writeln('BEGIN ---- XML RENDER');
      writeln(XML.saXML(false,false));    
      writeln('END   ---- XML RENDER');
    end;
    writeln('XML.ListCount:',XML.ListCount);
    if xml.movefirst then
    begin
      repeat
        writeln('Name:'+xml.Item_saName+' Value:'+XML.Item_saValue+' lpPtr:',uint(XML.Item_lpPtr));
      until not XML.MoveNext;
    end;
  end;
  writeln('XML.saLastError:'+XML.saLastError);
  XML.Destroy;
  result:=bOk;
end;
//=============================================================================

//=============================================================================
function bTest_JFC_XML_From_Scratch: boolean;
//=============================================================================
var
  XML: JFC_XML;
  XMLNode: JFC_XML;
  bOk: boolean;
begin
  bOk:=true;
  
  XML:=JFC_XML.Create;
  XML.appenditem_saName('jmenu');
  XMLNode:=JFC_XML.Create;
  XMLNode.AppendItem_saName_N_saValue('test','data');
  //JFC_XMLITEM(XMLNode.lpItem).Attr.AppendItem_saName_N_saValue('attrib','some value');
  
  XML.Item_lpPtr:=XMLNode;
  
  writeln(XML.saXML(false,false));
  
  XML.Destroy;
  result:=bOk;
end;
//=============================================================================


{
<synchronize>
  <entitylist>
    <entity name="task">
      <upload>yes</upload>
      <download>yes</download>
      <transactional>no</transactional>
    </entity>
    <entity name="calls">
      <upload>yes</upload>
      <download>yes</download>
      <transactional>no</transactional>
    </entity>
    <entity name="meetings">
      <upload>yes</upload>
      <download>yes</download>
      <transactional>no</transactional>
    </entity>
  </entitylist>
</synchronize>
}
//=============================================================================
function bTest_JFC_XML_SpecificData: boolean;
//=============================================================================
var
  XML: JFC_XML;
  bOk: boolean;
  saXML: ansistring;
begin
  XML:=JFC_XML.Create;
  //saXML:='<synchronize><entitylist><entity name="task"><upload>yes</upload><download>yes</download><transactional>no</transactional></entity>'+
  //       '<entity name="calls"><upload>yes</upload><download>yes</download><transactional>no</transactional></entity><entity name="meetings">'+
  //       '<upload>yes</upload><download>yes</download><transactional>no</transactional></entity></entitylist></synchronize>';

  saXML:='<xml>'+csCRLF+
         '  <updates>'+csCRLF+
         '    <program name="jegasedit" version="0" revision="68" />'+csCRLF+
         '    <program name="springlitimer" version="0" revision="2" />'+csCRLF+
         '  </updates>'+csCRLF+
         '</xml>'+csCRLF;

  bOk:=XML.bParseXML(saXML);
  if bOk then
  begin
    writeln('BEGIN ---- XML RENDER');
    writeln(XML.saXML(false,false));    
    writeln('END   ---- XML RENDER');
  end;
  writeln('XML.ListCount:',XML.ListCount);
  if xml.movefirst then
  begin
    repeat
      writeln('Name:'+xml.Item_saName+' Value:'+XML.Item_saValue+' lpPtr:',uint(XML.Item_lpPtr));
    until not XML.MoveNext;
  end;
  writeln('XML.saLastError:'+XML.saLastError);
  XML.Destroy;
  result:=bOk;
end;
//=============================================================================



//=============================================================================
// Main Program Starts Here
//=============================================================================
var bGood: boolean;
Begin
  bGood:=true;


  if bGood then
  begin
    bGood:=bTest_JFC_XML_From_Scratch;
    if not bGood then
    begin
      writeln('failed: bTest_JFC_XML_From_Scratch');
    end;
  end;


  if bGood then
  begin
    bGood:=bTest_JFC_XML_SpecificData;
    if not bGood then
    begin
      writeln('failed: bTest_JFC_XML_SpecificData')
    end;
  end;

  if bGood then
  begin
    gsaFilename:='.'+DOSSLASH+'data'+DOSSLASH+'test.xml';
    Writeln('Testing bTest_JFC_XML_From_File('''+gsaFilename+''')');
    bGood:=bTest_JFC_XML_From_File(gsaFilename);
    if not bGood then
    begin
      writeln('failed: bTest_JFC_XML_From_File('''+gsaFilename+''')');
    end;
  end;

  if bGood then
  begin
    gsaFilename:='.'+DOSSLASH+'data'+DOSSLASH+'test2.xml';
    Writeln('Testing bTest_JFC_XML_From_File('''+gsaFilename+''')');
    bGood:=bTest_JFC_XML_From_File(gsaFilename);
    if not bGood then
    begin
      writeln('failed: bTest_JFC_XML_From_File('''+gsaFilename+''')');
    end;
  end;

  if bGood then
  begin
    gsaFilename:='.'+DOSSLASH+'data'+DOSSLASH+'testbig.xml';
    Writeln('Testing bTest_JFC_XML_From_File('''+gsaFilename+''')');
    bGood:=bTest_JFC_XML_From_File(gsaFilename);
    if not bGood then
    begin
      writeln('failed: bTest_JFC_XML_From_File('''+gsaFilename+''')');
    end;
  end;

  if bGood then
  begin
    Writeln('All Tests PASSED!');
  end;

End.
//=============================================================================


//*****************************************************************************
// eof 
//*****************************************************************************
