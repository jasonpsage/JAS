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
{ }
// this is a test program, of of two unit tests programs for the ug_jfc_xml
// class.
program tesT_ug_jfc_xml2;
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

{$IFDEF R or T}
{$ENDIF}


uses ug_common, sysutils, ug_jfc_xml;
var
  sa: ansistring;
  XML: JFC_XML;
  XMLR: JFC_XML;

begin

  sa:='<xml><FBLOK2012040317480604679 />'+
      '<FBLOK2012040317480604679FT />'+
      '<FBLOK2012040317480592942CBO />'+
      '<FBLOK2012040317480592942 />'+
      '<FBLOK2012040317480592942FT />'+
      '<FBLOK2012040317480590800><![CDATA[test]]></FBLOK2012040317480590800>'+
      '<FBLOK2012040317480590800FT />'+
      '<FBLOK2012040317480601779CBO />'+
      '<FBLOK2012040317480601779 />'+
      '<FBLOK2012040317480601779FT />'+
      '<FBLOK2012040317480589791 />'+
      '<FBLOK2012040317480589791FT><![CDATA[NOT]]></FBLOK2012040317480589791FT>'+
      '<BFS2012040316073517124U><![CDATA[0]]></BFS2012040316073517124U>'+
      '<BFS2012040316073517124P><![CDATA[1]]></BFS2012040316073517124P>'+
      '<BFS2012040316140881243U><![CDATA[0]]></BFS2012040316140881243U>'+
      '<BFS2012040316140881243P><![CDATA[1]]></BFS2012040316140881243P>'+
      '<BFS2012040316124425057U><![CDATA[0]]></BFS2012040316124425057U>'+
      '<BFS2012040316124425057P><![CDATA[1]]></BFS2012040316124425057P>'+
      '<BFS2012040316073518663U><![CDATA[0]]></BFS2012040316073518663U>'+
      '<BFS2012040316073518663P><![CDATA[1]]></BFS2012040316073518663P>'+
      '<BFS2012040316150953244U><![CDATA[0]]></BFS2012040316150953244U>'+
      '<BFS2012040316150953244P><![CDATA[1]]></BFS2012040316150953244P></xml>';

{
  sa:='<?xml version="1.0" encoding="UTF-8" ?>'+csCRLF+
      '<xml>'+csCRLF+
      '  <aloneat test="stuff" more="stuff"/>'+csCRLF+
      '  <alone/>'+csCRLF+
      '  <single />'+csCRLF+
      '  <single with="attributes" more="attributes" />'+csCRLF+
      '  <node something="somedata" somethingelse="test">Stuff in side</node>'+csCRLF+
      '  <!-- a Comment '+csCRLF+
      '                    more -->'+csCRLF+
      '  <cd><![CDATA[Gobbly Gook Here]]></cd>'+csCRLF+
      '  <nestme>'+csCRLF+
      '    <nested>stuff</nested>'+csCRLF+
      '    <nested withattr="testing">dude</nested>'+csCRLF+
      '  </nestme>'+csCRLF+
      '</xml>'+csCRLF;
}
{
  sa:='<?xml version="1.0" encoding="UTF-8" ?>'+csCRLF+
      '<xml>'+csCRLF+
      '  <aloneat />'+csCRLF+
      '  <alone/>'+csCRLF+
      '  <single />'+csCRLF+
      '  <single />'+csCRLF+
      '  <node>Stuff in side</node>'+csCRLF+
      '  <!-- a Comment '+csCRLF+
      '                    more -->'+csCRLF+
      '  <cd><![CDATA[Gobbly Gook Here]]></cd>'+csCRLF+
      '  <nestme>'+csCRLF+
      '    <nested>stuff</nested>'+csCRLF+
      '    <nested>dude</nested>'+csCRLF+
      '  </nestme>'+csCRLF+
      '</xml>'+csCRLF;
}


  //sa:='<xml />';
  //sa:='<xml><test><new /></test></xml>';
  //sa:='<xml><test>DATA</test></xml>';



  XML:=JFC_XML.create;
  writeln('XML PARSE: ',XML.bParseXML(sa));
  writeln('XML Last Error: ', XML.saLastError);
  writeln('XML ListCount: ', XML.ListCount);
  writeln('----------XML.saXML-------------');
  writeln(XML.saXML(false,false));
  writeln('----------XML.saXML-------------');

  //if XML.Movefirst then
  //begin
  //  XMLR:=JFC_XML(XML.Item_lpPTR);
  //  writeln('XMLR Last Error: ', XMLR.saLastError);
  //  writeln('XMLR ListCount: ', XMLR.ListCount);
  //end;

  if XML.saLastError='' then
  begin
    writeln('Test PASSED!');
  end;

  XML.Destroy;
end.



