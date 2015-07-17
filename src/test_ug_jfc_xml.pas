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
// Testing the uxxg_jfc_xml.pp Unit
program test_ug_jfc_xml;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_splash.pp}
{$SMARTLINK ON}
{$MODE objfpc}
{$PACKRECORDS 4}
//=============================================================================



//=============================================================================
uses
//=============================================================================
ug_jfc_xml,
ug_misc,
ug_common;
//=============================================================================

//=============================================================================
function bTest_JFC_XML_From_File(p_safile:ansistring): boolean;
//=============================================================================
var
  XML: JFC_XML;
  bOk: boolean;
  saXML: ansistring;
begin
  XML:=JFC_XML.Create;
  bOk:=bLoadTextFile(p_safile, saXML);
  if bOk then
  begin
    writeln('Loaded XML, Now On to Tokenizing it.');
    bOk:=XML.bParseXML(saXML);
    if bOk then
    begin
      writeln('BEGIN ---- XML RENDER');
      writeln(XML.saXML);    
      writeln('END   ---- XML RENDER');
    end;
    writeln('XML.ListCount:',XML.ListCount);
    if xml.movefirst then
    begin
      repeat
        writeln('Name:'+xml.Item_saName+' Value:'+XML.Item_saValue+' lpPtr:',cardinal(XML.Item_lpPtr));
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
  
  writeln(XML.saXML);
  
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
    writeln(XML.saXML);    
    writeln('END   ---- XML RENDER');
  end;
  writeln('XML.ListCount:',XML.ListCount);
  if xml.movefirst then
  begin
    repeat
      writeln('Name:'+xml.Item_saName+' Value:'+XML.Item_saValue+' lpPtr:',cardinal(XML.Item_lpPtr));
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
Begin
  {
  write('Testing...bTest_JFC_XML_From_Scratch');
  if bTest_JFC_XML_From_Scratch then
  begin
    write('PASSED');
  end
  else
  begin
    write('FAILED');
  end;
  writeln('...Done!');
  }

  {
  write('Testing...bTest_JFC_XML_From_File(''test.xml''');
  if bTest_JFC_XML_From_File('test.xml') then
  begin
    write('PASSED');
  end
  else
  begin
    write('FAILED');
  end;
  writeln('...Done!');
  }

  {
  write('Testing...bTest_JFC_XML_SpecificData');
  if bTest_JFC_XML_SpecificData then
  begin
    write('PASSED');
  end
  else
  begin
    write('FAILED');
  end;
  writeln('...Done!');
  }

  {
  write('Testing...bTest_JFC_XML_From_File(''test2.xml''');
  if bTest_JFC_XML_From_File('test2.xml') then
  begin
    write('PASSED');
  end
  else
  begin
    write('FAILED');
  end;
  writeln('...Done!');
  }


  write('Testing...bTest_JFC_XML_From_File(''testbig.xml''');
  if bTest_JFC_XML_From_File('testbig.xml') then
  begin
    write('PASSED');
  end
  else
  begin
    write('FAILED');
  end;
  writeln('...Done!');


End.
//=============================================================================


//*****************************************************************************
// eof 
//*****************************************************************************
