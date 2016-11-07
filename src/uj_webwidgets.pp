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
{}
// Consolidation of Severside Internet controls
Unit uj_webwidgets;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_webwidgets.pp'}
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
Uses
//=============================================================================
classes
,syncobjs
,sysutils
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_xdl
,ug_jcrypt
,uj_context
,uj_definitions
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
{}
// Creates a widget that gets inserted into outgoing web pages via the JAS
// SNR mechanisms. So, if you make a widget named MyTest in code, then
// whan that page is served there will be the necessary code for that widget
// in the SNR list. When your outout is about to leave the server, any
// instance of [#MyTest#] will be replaced by the code created by this function.
// Additionally, if this widget is placed correctly, then when the user submits
// their page back the the server, you will have your MyTest's submitted value
// in the incoming post or get variables from the user.
Procedure WidgetInputBox(
  p_Context: TCONTEXT;
  p_saWidgetName: Ansistring;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u8MaxLen: UInt64;
  p_u2Size: word;
  p_bPassword: boolean;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring;
  p_saOnSelect: ansistring
);
//=============================================================================
{}
{}
// Creates a widget that gets inserted into outgoing web pages via the JAS
// SNR mechanisms. So, if you make a widget named MyTest in code, then
// whan that page is served there will be the necessary code for that widget
// in the SNR list. When your outout is about to leave the server, any
// instance of [#MyTest#] will be replaced by the code created by this function.
// Additionally, if this widget is placed correctly, then when the user submits
// their page back the the server, you will have your MyTest's submitted value
// in the incoming post or get variables from the user.
// This Version places the Caption OVER the datafield.
Procedure WidgetTextArea(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u2Cols: word;
  p_u2Rows: word;
  p_bEditMode: Boolean;
  p_bRequired: boolean;
  p_bShowToolButtons: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring
);
//=============================================================================
{}
// Creates a widget that gets inserted into outgoing web pages via the JAS
// SNR mechanisms. So, if you make a widget named MyTest in code, then
// whan that page is served there will be the necessary code for that widget
// in the SNR list. When your outout is about to leave the server, any
// instance of [#MyTest#] will be replaced by the code created by this function.
// Additionally, if this widget is placed correctly, then when the user submits
// their page back the the server, you will have your MyTest's submitted value
// in the incoming post or get variables from the user.
Procedure WidgetBoolean(
  p_Context: TCONTEXT;
  p_saWidgetName: ansiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString; // TRUE, FALSE, NULL
  p_u2Size: word; // Widget Height Property - effect SELECT Tag's Size
  p_bEditMode: Boolean;
  p_bFilter: Boolean; // If Used as a filter, 3 options Yes, No, Blank
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_bMultiple: boolean;
  p_bBlankSelected: boolean;// THESE ARE FOR MULTIPLE SELECTION ONLY
  p_bNULLSelected: boolean; // THESE ARE FOR MULTIPLE SELECTION ONLY
  p_bTrueSelected: boolean; // THESE ARE FOR MULTIPLE SELECTION ONLY
  p_bFalseSelected: boolean; // THESE ARE FOR MULTIPLE SELECTION ONLY
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring
);
//=============================================================================
{}
// Creates a widget that gets inserted into outgoing web pages via the JAS
// SNR mechanisms. So, if you make a widget named MyTest in code, then
// whan that page is served there will be the necessary code for that widget
// in the SNR list. When your outout is about to leave the server, any
// instance of [#MyTest#] will be replaced by the code created by this function.
// Additionally, if this widget is placed correctly, then when the user submits
// their page back the the server, you will have your MyTest's submitted value
// in the incoming post or get variables from the user.
Procedure WidgetDateTime(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_bWidgetDate: boolean;
  p_bWidgetTime: boolean;
  p_saWidgetMask: AnsiString; //< JDate Formats '1' thru '17' Input and Display
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring
);
//=============================================================================
{}
// Creates a widget that gets inserted into outgoing web pages via the JAS
// SNR mechanisms. So, if you make a widget named MyTest in code, then
// whan that page is served there will be the necessary code for that widget
// in the SNR list. When your outout is about to leave the server, any
// instance of [#MyTest#] will be replaced by the code created by this function.
// Additionally, if this widget is placed correctly, then when the user submits
// their page back the the server, you will have your MyTest's submitted value
// in the incoming post or get variables from the user.
// XDL Reference reference: name=caption, value=returned,
// i8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
Procedure WidgetList(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u2Size: word;
  p_bMultiple: boolean;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_XDL: JFC_XDL;// reference: name=caption, value=returned, desc = "" or "selected", iUser=1 then option selectable (0=grayed out)
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring
);
//=============================================================================
{}
// Creates a widget that gets inserted into outgoing web pages via the JAS
// SNR mechanisms. So, if you make a widget named MyTest in code, then
// whan that page is served there will be the necessary code for that widget
// in the SNR list. When your outout is about to leave the server, any
// instance of [#MyTest#] will be replaced by the code created by this function.
// Additionally, if this widget is placed correctly, then when the user submits
// their page back the the server, you will have your MyTest's submitted value
// in the incoming post or get variables from the user.
// XDL Reference reference: name=caption, value=returned,
// u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
Procedure WidgetDropDown(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u2Size: word;
  p_bMultiple: boolean;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_XDL: JFC_XDL;
  p_bIfInReadOnly_UseDefaultValueOnly: boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring
);
//=============================================================================
{}
// Creates a widget that gets inserted into outgoing web pages via the JAS
// SNR mechanisms. So, if you make a widget named MyTest in code, then
// whan that page is served there will be the necessary code for that widget
// in the SNR list. When your outout is about to leave the server, any
// instance of [#MyTest#] will be replaced by the code created by this function.
// Additionally, if this widget is placed correctly, then when the user submits
// their page back the the server, you will have your MyTest's submitted value
// in the incoming post or get variables from the user.
// XDL Reference reference: name=caption, value=returned,
// u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
Procedure WidgetComboBox(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u8MaxLen: uint64;
  p_u2Size: word;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_XDL: JFC_XDL;// reference: name=caption, value=returned, desc = "" (not selected) or "selected" | "true" (selected)  , iUser=1 then option selectable (0=grayed out)
  p_bIfInReadOnly_UseDefaultValueOnly: boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring;
  p_saOnSelect: ansistring
);
//=============================================================================
{}
// Creates a widget that gets inserted into outgoing web pages via the JAS
// SNR mechanisms. So, if you make a widget named MyTest in code, then
// whan that page is served there will be the necessary code for that widget
// in the SNR list. When your outout is about to leave the server, any
// instance of [#MyTest#] will be replaced by the code created by this function.
// Additionally, if this widget is placed correctly, then when the user submits
// their page back the the server, you will have your MyTest's submitted value
// in the incoming post or get variables from the user.
Procedure WidgetURL(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_u2WidgetWidth: word;
  p_saDefaultValue: AnsiString;
  p_u8MaxLen: UInt64;
  p_u2Size: word;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring;
  p_saOnSelect: ansistring
);
//=============================================================================
{}
// Creates a widget that gets inserted into outgoing web pages via the JAS
// SNR mechanisms. So, if you make a widget named MyTest in code, then
// whan that page is served there will be the necessary code for that widget
// in the SNR list. When your outout is about to leave the server, any
// instance of [#MyTest#] will be replaced by the code created by this function.
// Additionally, if this widget is placed correctly, then when the user submits
// their page back the the server, you will have your MyTest's submitted value
// in the incoming post or get variables from the user.
Procedure WidgetEMail(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u8MaxLen: uint64;
  p_u2Size: word;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring;
  p_saOnSelect: ansistring
);
//=============================================================================
{}
// Creates a widget that gets inserted into outgoing web pages via the JAS
// SNR mechanisms. So, if you make a widget named MyTest in code, then
// whan that page is served there will be the necessary code for that widget
// in the SNR list. When your outout is about to leave the server, any
// instance of [#MyTest#] will be replaced by the code created by this function.
// Additionally, if this widget is placed correctly, then when the user submits
// their page back the the server, you will have your MyTest's submitted value
// in the incoming post or get variables from the user.
// Use to make hidden input elements.
Procedure WidgetHidden(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saDefaultValue: AnsiString
);
//=============================================================================

//=============================================================================
{}
// Creates a widget that gets inserted into outgoing web pages via the JAS
// SNR mechanisms. So, if you make a widget named MyTest in code, then
// whan that page is served there will be the necessary code for that widget
// in the SNR list. When your outout is about to leave the server, any
// instance of [#MyTest#] will be replaced by the code created by this function.
// Additionally, if this widget is placed correctly, then when the user submits
// their page back the the server, you will have your MyTest's submitted value
// in the incoming post or get variables from the user.
Procedure WidgetPhone(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saSIPURL: AnsiString;
  p_saValue: ansistring;
  p_u8MaxLen: uint64;
  p_u2Size: word;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring;
  p_saOnSelect: ansistring
);
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
function saFilterTool_AndNot_Toggle(p_saWidgetName: ansistring; p_bFilterNot: boolean): ansistring;
//=============================================================================
var
  sa: ansistring;
  sNot: string; // (B^)> sNot <--- hahha
  sDAnd: string;
  sDNot: string;
begin
  sDNot:='display: none;';
  if p_bFilterNOT then
  begin
    sNot:='NOT';
    sDAnd:=sDNot;
    sDNot:='';
  end
  else
  begin
    sNot:='';
    sDAnd:='';
  end;

  sa:=
    '<script>'+
    '  function f'+p_saWidgetName+'FTA(){'+
    '    el=document.getElementById("'+p_saWidgetName+'FTA");el.style.display="none";'+
    '    el=document.getElementById("'+p_saWidgetName+'FTB");el.style.display="";'+
    '    document.getElementById("'+p_saWidgetName+'FT").value="NOT";'+
    '  };'+
    '  function f'+p_saWidgetName+'FTB(){'+
    '    el=document.getElementById("'+p_saWidgetName+'FTA");el.style.display="";'+
    '    el=document.getElementById("'+p_saWidgetName+'FTB");el.style.display="none";'+
    '    document.getElementById("'+p_saWidgetName+'FT").value="";'+
    '  };'+
    '</script>'+
    '<input type="hidden" id="'+p_saWidgetName+'FT" name="'+p_saWidgetName+'FT" value="'+sNot+'" />'+
    '<div id="'+p_saWidgetName+'FTA" style="'+sDAnd+'" />'+
    '  <img class="image" onclick="f'+p_saWidgetName+'FTA();" title="Click to EXCLUDE" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-add.png" />'+
    '</div>'+
    '<div id="'+p_saWidgetName+'FTB" style="'+sDNot+'" />'+
    '  <img class="image" onclick="f'+p_saWidgetName+'FTB()" title="Click to INCLUDE" src="<? echo $JASDIRICONTHEME; ?>16/actions/edit-delete.png" />'+
    '</div>';
  result:=sa;
end;
//=============================================================================








//=============================================================================
procedure clearnullevents(
  var p_saOnBlur: ansistring;
  var p_saOnChange: ansistring;
  var p_saOnClick: ansistring;
  var p_saOnDblClick: ansistring;
  var p_saOnFocus: ansistring;
  var p_saOnKeyDown: ansistring;
  var p_saOnKeypress: ansistring;
  var p_saOnKeyUp: ansistring
);
//=============================================================================
begin
  p_saOnBlur:=trim(p_saOnBlur);if p_saOnBlur='NULL' then p_saOnBlur:='';
  p_saOnChange:=trim(p_saOnChange);if p_saOnChange='NULL' then p_saOnChange:='';
  p_saOnClick:=trim(p_saOnClick);if p_saOnClick='NULL' then p_saOnClick:='';
  p_saOnDblClick:=trim(p_saOnDblClick);if p_saOnDblClick='NULL' then p_saOnDblClick:='';
  p_saOnFocus:=trim(p_saOnFocus);if p_saOnFocus='NULL' then p_saOnFocus:='';
  p_saOnKeyDown:=trim(p_saOnKeyDown);if p_saOnKeyDown='NULL' then p_saOnKeyDown:='';
  p_saOnKeypress:=trim(p_saOnKeypress);if p_saOnKeypress='NULL' then p_saOnKeypress:='';
  p_saOnKeyUp:=trim(p_saOnKeyUp);if p_saOnKeyUp='NULL' then p_saOnKeyUp:='';
end;
//=============================================================================
















//=============================================================================
Procedure WidgetInputBox(
  p_Context: TCONTEXT;
  p_saWidgetName: Ansistring;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u8MaxLen: UInt64;
  p_u2Size: word;
  p_bPassword: boolean;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring;
  p_saOnSelect: ansistring
);
//=============================================================================
Var
  saResult: AnsiString;
  i: integer;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='WidgetInputBox'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102651,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102652, sTHIS_ROUTINE_NAME);{$ENDIF}


  clearnullevents(
    p_saOnBlur,
    p_saOnChange,
    p_saOnClick,
    p_saOnDblClick,
    p_saOnFocus,
    p_saOnKeyDown,
    p_saOnKeypress,
    p_saOnKeyUp
  );
  p_saOnSelect:=trim(p_saOnSelect);if p_saOnSelect='NULL' then p_saOnSelect:='';
  if not p_bFilterTools then if trim(p_saDefaultValue)='NULL' then p_saDefaultValue:='';


  saResult:='<table border="0">';
  //If length(p_saWidgetCaption)>0 Then
  //Begin
    saResult+='<tr><td';
    if p_bDataOnRight then saResult+=' width="50%" ';
    saResult+='>';

    If not p_bEditMode Then saResult+='<u>';
    saResult+=p_saWidgetCaption;
    If not p_bEditMode Then saResult+='</u>';
    if (p_bRequired) then
    begin
      saResult+='<span name="'+p_saWidgetName+'rf" id="'+
        p_saWidgetName+'rf" >'+
        '<font color="red" style="font: strong">&nbsp;*&nbsp;</font>'+
        '</span>';
    end;
    If not p_bDataOnRight Then saResult+='</td></tr>';
  //End;
  If not p_bDataOnRight Then saResult+='<tr>';
  If p_bEditMode Then
  Begin
    saResult +='<td>';
  End
  Else
  Begin
    //saresult+='<td class="rodata" ';
    saresult+='<td ';
    if p_bDataOnRight then saResult+='width="50%" ';
    If length(trim(p_saDefaultValue))=0 Then
    Begin
      saResult +='height="20">';
    End
    Else
    Begin
      saResult+='>';
      if p_bPassword then
      begin
        for i:=1 to length(p_saDefaultValue) do
        begin
          saResult+='&bull;';
        end;
      end
      else
      begin
        saResult+=p_saDefaultValue;
      end;
    End;
  End;

  if p_bFilterTools and p_bEditMode then
  begin
    saresult+='<table><tr><td>';
  end;

  if p_bEditMode then
  begin
    saresult+=csCRLF+'<script language="javascript">'+csCRLF;
    if p_saOnBlur    <>'' then saResult+='function '+p_saWidgetName+'_OnBlur(){'    +csCRLF+p_saOnBlur    +csCRLF+'}'+csCRLF;
    if p_saOnChange  <>'' then saResult+='function '+p_saWidgetName+'_OnChange(){'  +csCRLF+p_saOnChange  +csCRLF+'}'+csCRLF;
    if p_saOnClick   <>'' then saResult+='function '+p_saWidgetName+'_OnClick(){'   +csCRLF+p_saOnClick   +csCRLF+'}'+csCRLF;
    if p_saOnDblClick<>'' then saResult+='function '+p_saWidgetName+'_OnDblClick(){'+csCRLF+p_saOnDblClick+csCRLF+'}'+csCRLF;
    if p_saOnFocus   <>'' then saResult+='function '+p_saWidgetName+'_OnFocus(){'   +csCRLF+p_saOnFocus   +csCRLF+'}'+csCRLF;
    if p_saOnKeyDown <>'' then saResult+='function '+p_saWidgetName+'_OnKeyDown(){' +csCRLF+p_saOnKeyDown +csCRLF+'}'+csCRLF;
    if p_saOnKeypress<>'' then saResult+='function '+p_saWidgetName+'_OnKeypress(){'+csCRLF+p_saOnKeypress+csCRLF+'}'+csCRLF;
    if p_saOnKeyUp   <>'' then saResult+='function '+p_saWidgetName+'_OnKeyUp(){'   +csCRLF+p_saOnKeyUp   +csCRLF+'}'+csCRLF;
    if p_saOnSelect  <>'' then saResult+='function '+p_saWidgetName+'_OnSelect(){'  +csCRLF+p_saOnSelect  +csCRLF+'}'+csCRLF;
    saresult+=csCRLF+'</script>'+csCRLF;
  end;

  saResult+='<input type="';
  If p_bEditMode Then
  begin
    if p_bPassword then
    begin
      saResult+='password" ';
    end
    else
    begin
      saResult+='text" ';
    end;
  end
  Else saResult+='hidden" ';
  If p_u8MaxLen<>0 Then saResult+='maxlength="'+inttostr(p_u8MaxLen)+'" ';
  If p_u2Size>0 Then saResult+='size="'+inttostr(p_u2Size)+'" ';
  saResult+='name="'+p_saWidgetName+'" id="'+p_saWidgetName
           +'" value="'+saSNRStr(p_saDefaultValue,'"','&quot;') +'"';
  if p_bEditMode then
  begin
    if p_saOnBlur    <>'' then saResult+='onblur="return '+p_saWidgetName+'_OnBlur();" ';
    if p_saOnChange  <>'' then saResult+='onchange="return '+p_saWidgetName+'_OnChange();" ';
    if p_saOnClick   <>'' then saResult+='onclick="return '+p_saWidgetName+'_OnClick();" ';
    if p_saOnDblClick<>'' then saResult+='ondblclick="return '+p_saWidgetName+'_OnDblClick();" ';
    if p_saOnFocus   <>'' then saResult+='onfocus="return '+p_saWidgetName+'_OnFocus();" ';
    if p_saOnKeyDown <>'' then saResult+='onkeydown="return '+p_saWidgetName+'_OnKeyDown();" ';
    if p_saOnKeypress<>'' then saResult+='onkeypress="return '+p_saWidgetName+'_OnKeypress();" ';
    if p_saOnKeyUp   <>'' then saResult+='onkeyup="return '+p_saWidgetName+'_OnKeyUp();" ';
    if p_saOnSelect  <>'' then saResult+='onselect="return '+p_saWidgetName+'_OnSelect();" ';
  end;
  saresult+=' />';
  //If p_bEditMode Then saresult+=p_saDefaultValue;

  if p_bFilterTools and p_bEditMode then
  begin
    saresult+='</td><td>'+saFilterTool_AndNot_Toggle(p_saWidgetName, p_bfilterNOT)+'</td></tr></table>';
  end;

  saResult+='</td></tr>';
  saResult+='</table>';
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[#'+p_saWidgetName+'#]',saResult);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102653,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================




























//=============================================================================
Procedure WidgetTextArea(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u2Cols: word;
  p_u2Rows: word;
  p_bEditMode: Boolean;
  p_bRequired: boolean;
  p_bShowToolButtons: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring
);
//=============================================================================
const cnWidth_Limit = 40;
Var
  saResult: AnsiString;
  saIconThemeToUse: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='WidgetTextArea'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102660,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102661, sTHIS_ROUTINE_NAME);{$ENDIF}

  clearnullevents(
    p_saOnBlur,
    p_saOnChange,
    p_saOnClick,
    p_saOnDblClick,
    p_saOnFocus,
    p_saOnKeyDown,
    p_saOnKeypress,
    p_saOnKeyUp
  );
  if not p_bFilterTools then if trim(p_saDefaultValue)='NULL' then p_saDefaultValue:='';

  saResult:=csCRLF+'<table border="0"><tr><td>';
  If not p_bEditMode Then saResult+='<u>';
  saResult+=p_saWidgetCaption;
  If not p_bEditMode Then saResult+='</u>';
  if (p_bRequired) then
  begin
    saResult+='<span name="'+p_saWidgetName+'rf" id="'+p_saWidgetName+'rf" >'+'<font color="red" style="font: strong">&nbsp;*&nbsp;</font>'+'</span>';
  end;
  saResult+='</td></tr><tr>';
  If p_bEditMode Then
  Begin
    saResult+='<td>';
    if p_bFilterTools then
    begin
      saresult+='<table><tr><td>';
    end;
    saresult+=csCRLF+'<script language="javascript">'+csCRLF;
    if p_saOnBlur    <>'' then saResult+='function '+p_saWidgetName+'_OnBlur(){'    +csCRLF+p_saOnBlur    +csCRLF+'}'+csCRLF;
    if p_saOnChange  <>'' then saResult+='function '+p_saWidgetName+'_OnChange(){'  +csCRLF+p_saOnChange  +csCRLF+'}'+csCRLF;
    if p_saOnClick   <>'' then saResult+='function '+p_saWidgetName+'_OnClick(){'   +csCRLF+p_saOnClick   +csCRLF+'}'+csCRLF;
    if p_saOnDblClick<>'' then saResult+='function '+p_saWidgetName+'_OnDblClick(){'+csCRLF+p_saOnDblClick+csCRLF+'}'+csCRLF;
    if p_saOnFocus   <>'' then saResult+='function '+p_saWidgetName+'_OnFocus(){'   +csCRLF+p_saOnFocus   +csCRLF+'}'+csCRLF;
    if p_saOnKeyDown <>'' then saResult+='function '+p_saWidgetName+'_OnKeyDown(){' +csCRLF+p_saOnKeyDown +csCRLF+'}'+csCRLF;
    if p_saOnKeypress<>'' then saResult+='function '+p_saWidgetName+'_OnKeypress(){'+csCRLF+p_saOnKeypress+csCRLF+'}'+csCRLF;
    if p_saOnKeyUp   <>'' then saResult+='function '+p_saWidgetName+'_OnKeyUp(){'   +csCRLF+p_saOnKeyUp   +csCRLF+'}'+csCRLF;
    saresult+=csCRLF+'</script>'+csCRLF;

    saResult+='<textarea name="'+p_saWidgetName+'" id="'+p_saWidgetName+'" ';
    If p_u2Cols<>0 Then saResult+='cols="'+inttostr(p_u2Cols)+'" ';
    If p_u2Rows<>0 Then saresult+='rows="'+inttostr(p_u2Rows)+'" ';

    if p_saOnBlur    <>'' then saResult+='onblur="return '+p_saWidgetName+'_OnBlur();" ';
    if p_saOnChange  <>'' then saResult+='onchange="return '+p_saWidgetName+'_OnChange();" ';
    if p_saOnClick   <>'' then saResult+='onclick="return '+p_saWidgetName+'_OnClick();" ';
    if p_saOnDblClick<>'' then saResult+='ondblclick="return '+p_saWidgetName+'_OnDblClick();" ';
    if p_saOnFocus   <>'' then saResult+='onfocus="return '+p_saWidgetName+'_OnFocus();" ';
    if p_saOnKeyDown <>'' then saResult+='onkeydown="return '+p_saWidgetName+'_OnKeyDown();" ';
    if p_saOnKeypress<>'' then saResult+='onkeypress="return '+p_saWidgetName+'_OnKeypress();" ';
    if p_saOnKeyUp   <>'' then saResult+='onkeyup="return '+p_saWidgetName+'_OnKeyUp();" ';
    saResult+='>'+p_saDefaultvalue;
  End
  Else
  Begin
    saresult+=
      '<td><textarea name="'+p_saWidgetName+'" id="'+p_saWidgetName+'" '+
      'style="color: black; background-color: #EFB6AF;" ';
    If p_u2Cols<>0 Then saResult+='cols="'+inttostr(p_u2Cols)+'" ';
    If p_u2Rows<>0 Then saresult+='rows="'+inttostr(p_u2Rows)+'" >'+p_saDefaultValue+'</textarea>';
  end;
  If p_bEditMode Then
  begin
    saResult+='</textarea>';
    if p_bFilterTools then
    begin
      saResult+='</td><td>'+saFilterTool_AndNot_Toggle(p_saWidgetName, p_bfilterNOT)+'</td></tr></table>';
    end;
    if FALSE = (p_Context.PageSNRXDL.FoundItem_saName('[@JCRYPTMIX@]')) then
    begin
      p_Context.PageSNRXDL.AppendItem_saName_N_saValue('[@JCRYPTMIX@]',saJCryptMix);
    end;
    saIconThemeToUse:=p_Context.sIconTheme;
    if p_bShowToolButtons then
    begin
      saResult+=
        '<script>'+
        '  function Encrypt_'+p_saWidgetName+'(){'+
        '      var el=document.getElementById("'+p_saWidgetName+'");'+
        '      el.value=sJegasEncryptSingleKey(el.value.toString());'+
        '  };'+
        '  function Decrypt_'+p_saWidgetName+'(){'+
        '      var el=document.getElementById("'+p_saWidgetName+'");'+
        '      el.value=sJegasDecryptSingleKey(el.value.toString());'+
        '  };'+
        '  function EncodeURI_'+p_saWidgetName+'(){'+
        '    var el=document.getElementById("'+p_saWidgetName+'");'+
        '    el.value=encodeURIComponent(el.value.toString());'+
        '  };'+
        '  function DecodeURI_'+p_saWidgetName+'(){'+
        '    var el=document.getElementById("'+p_saWidgetName+'");'+
        '    el.value=decodeURIComponent(el.value.toString());'+
        '  };'+
        '  function render_'+p_saWidgetName+'(){'+
        '    var el=document.getElementById("'+p_saWidgetName+'");'+
        '    try{'+
        '      el.value=decodeURIComponent(el.value.toString());'+
        '      document.getElementById("mydiv_'+p_saWidgetName+'").innerHTML=el.value;'+
        '    }catch(eX){ '+
        '      alert("Something in this text area is preventing javascript from rendering it.");'+
        '    };'+
        '  };'+
        '  function renderclear_'+p_saWidgetName+'(){'+
        '    document.getElementById("mydiv_'+p_saWidgetName+'").innerHTML="";'+
        '  };';

      saResult+=
        '</script>'+
        '<div id="mydiv_'+p_saWidgetName+'" ></div>'+
        '<br /><a title="Encrypt" onclick="Encrypt_'+p_saWidgetName+'();">'+
        '<img class="image" src="'+ garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+saIconThemeToUse+'/'+'16/actions/encrypt.png" />'+
        '</a>&nbsp;&nbsp;'+
        '<a title="Decrypt" onclick="Decrypt_'+p_saWidgetName+'();">'+
        '<img class="image" src="'+garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+saIconThemeToUse+'/'+'16/status/dialog-password.png" />'+
        '</a>&nbsp;&nbsp;'+
        '<a title="Encode URI" onclick="EncodeURI_'+p_saWidgetName+'();">'+
        '<img class="image" src="'+garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+saIconThemeToUse+'/'+'16/actions/start.png" />'+
        '</a>&nbsp;&nbsp;'+
        '<a title="Decode URI" onclick="DecodeURI_'+p_saWidgetName+'();">'+
        '<img class="image" src="'+garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+saIconThemeToUse+'/'+'16/actions/stop.png" />'+
        '</a>&nbsp;&nbsp;'+
        '<a title="HTML render" onclick="render_'+p_saWidgetName+'();">'+
        '<img class="image" src="'+garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+saIconThemeToUse+'/'+'16/places/folder-remote.png" />'+
        '</a>&nbsp;&nbsp;'+
        '<a title="HTML render clear" onclick="renderclear_'+p_saWidgetName+'();">'+
        '<img class="image" src="'+garJVHost[p_Context.u2VHost].VHost_WebShareAlias+'img/icon/themes/'+saIconThemeToUse+'/'+'16/places/folder.png" />'+
        '</a>';
    end;
  end;
  saResult+='</td></tr></table>';
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[#'+p_saWidgetName+'#]',saResult);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102662,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================

















//=============================================================================
{}
Procedure WidgetBoolean(
  p_Context: TCONTEXT;
  p_saWidgetName: ansiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString; // TRUE, FALSE, NULL
  p_u2Size: word; // Widget Height Property - effect SELECT Tag's Size
  p_bEditMode: Boolean;
  p_bFilter: Boolean; // If Used as a filter, 3 options Yes, No, Blank
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_bMultiple: boolean;
  p_bBlankSelected: boolean;// THESE ARE FOR MULTIPLE SELECTION ONLY
  p_bNULLSelected: boolean; // THESE ARE FOR MULTIPLE SELECTION ONLY
  p_bTrueSelected: boolean; // THESE ARE FOR MULTIPLE SELECTION ONLY
  p_bFalseSelected: boolean; // THESE ARE FOR MULTIPLE SELECTION ONLY
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring
);
//=============================================================================
Var
  saResult: AnsiString;
  //saRawDefault: ansistring;
  saDefaultValue: ansistring;
  i4TempLen: longint;
  saTemp: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='WidgetBoolean'; {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102663,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102664, sTHIS_ROUTINE_NAME);{$ENDIF}


  clearnullevents(
    p_saOnBlur,
    p_saOnChange,
    p_saOnClick,
    p_saOnDblClick,
    p_saOnFocus,
    p_saOnKeyDown,
    p_saOnKeypress,
    p_saOnKeyUp
  );
  saDefaultValue:=upcase(trim(p_saDefaultValue));
  if not p_bFilterTools then if trim(p_saDefaultValue)='NULL' then p_saDefaultValue:='';

  //saRawDefault:=p_saDefaultValue;
  if (p_bFilter) then
  begin
    if (saDefaultValue<>'NULL') and (saDefaultValue<>'') then
    begin
      saDefaultValue:=trim(UpCase(sTrueFalse(bVal(saDefaultValue))));
    end;
  end
  else
  begin
    if (p_bFilter) = false then
    saDefaultValue:=trim(UpCase(sTrueFalse(bVal(saDefaultValue))));
  end;

  saResult:='<table border="0" >';
  saResult+='<tr><td>';
  If not p_bEditMode Then saResult+='<u>';
  saResult+=p_saWidgetCaption;
  If not p_bEditMode Then saResult+='</u>';
  if (p_bRequired) and (not p_bFilter) then
  begin
    saResult+='<span name="'+p_saWidgetName+'rf" id="'+
      p_saWidgetName+'rf" >'+
      '<font color="red" style="font: strong">&nbsp;*&nbsp;</font>'+
      '</span>';
  end;
  If p_bDataOnRight Then saResult+='</td>' else saResult+='</td></tr><tr>';
  If p_bEditMode Then
  Begin
    saResult +='<td>';
    if p_bFilterTools then saResult+='<table><tr><td>';
  end
  else
  begin
    saResult +='<td class="rodata" >';
  end;

  If p_bEditMode Then
  Begin

    saresult+=csCRLF+'<script language="javascript">'+csCRLF;
    if p_saOnBlur    <>'' then saResult+='function '+p_saWidgetName+'_OnBlur(){'    +csCRLF+p_saOnBlur    +csCRLF+'}'+csCRLF;
    if p_saOnChange  <>'' then saResult+='function '+p_saWidgetName+'_OnChange(){'  +csCRLF+p_saOnChange  +csCRLF+'}'+csCRLF;
    if p_saOnClick   <>'' then saResult+='function '+p_saWidgetName+'_OnClick(){'   +csCRLF+p_saOnClick   +csCRLF+'}'+csCRLF;
    if p_saOnDblClick<>'' then saResult+='function '+p_saWidgetName+'_OnDblClick(){'+csCRLF+p_saOnDblClick+csCRLF+'}'+csCRLF;
    if p_saOnFocus   <>'' then saResult+='function '+p_saWidgetName+'_OnFocus(){'   +csCRLF+p_saOnFocus   +csCRLF+'}'+csCRLF;
    if p_saOnKeyDown <>'' then saResult+='function '+p_saWidgetName+'_OnKeyDown(){' +csCRLF+p_saOnKeyDown +csCRLF+'}'+csCRLF;
    if p_saOnKeypress<>'' then saResult+='function '+p_saWidgetName+'_OnKeypress(){'+csCRLF+p_saOnKeypress+csCRLF+'}'+csCRLF;
    if p_saOnKeyUp   <>'' then saResult+='function '+p_saWidgetName+'_OnKeyUp(){'   +csCRLF+p_saOnKeyUp   +csCRLF+'}'+csCRLF;
    saresult+=csCRLF+'</script>'+csCRLF;

    saResult+='<select id="'+p_saWidgetName+'" name="'+p_saWidgetName+
              '" size="'+ inttostr(p_u2Size) +'"';
    if p_bMultiple then saResult+='multiple ';

    if p_saOnBlur    <>'' then saResult+='onblur="return '+p_saWidgetName+'_OnBlur();" ';
    if p_saOnChange  <>'' then saResult+='onchange="return '+p_saWidgetName+'_OnChange();" ';
    if p_saOnClick   <>'' then saResult+='onclick="return '+p_saWidgetName+'_OnClick();" ';
    if p_saOnDblClick<>'' then saResult+='ondblclick="return '+p_saWidgetName+'_OnDblClick();" ';
    if p_saOnFocus   <>'' then saResult+='onfocus="return '+p_saWidgetName+'_OnFocus();" ';
    if p_saOnKeyDown <>'' then saResult+='onkeydown="return '+p_saWidgetName+'_OnKeyDown();" ';
    if p_saOnKeypress<>'' then saResult+='onkeypress="return '+p_saWidgetName+'_OnKeypress();" ';
    if p_saOnKeyUp   <>'' then saResult+='onkeyup="return '+p_saWidgetName+'_OnKeyUp();" ';

    saresult+=' >';

    If p_bFilter Then
    Begin
      // BLANK
      saresult+='<option value="" ';
      If (saDefaultValue='')Then saResult+='default ';
      if (p_bMultiple and p_bBlankSelected) or (saDefaultValue='') then saResult+='selected ';
      saResult+='></option>';

      // NULL
      saresult+='<option value="NULL" ';
      If (saDefaultValue='NULL')Then saResult+='default ';
      if (p_bMultiple and p_bNULLSelected) or (saDefaultValue='NULL') then saResult+='selected ';
      saResult+='>NULL</option>';
    End;

    // TRUE
    saresult+='<option value="TRUE" ';
    If saDefaultValue='TRUE' Then saResult+='default ';
    if (p_bMultiple and p_bTrueSelected) or (saDefaultValue='TRUE') then saResult+='selected ';
    saResult+='>True</option>';

    // FALSE
    saresult+='<option value="FALSE" ';
    If saDefaultValue='FALSE' Then saResult+='default ';
    if (p_bMultiple and p_bFalseSelected) or (saDefaultValue='FALSE') then saResult+='selected ';
    saResult+='>False</option>';
    saresult+='</select>';

    if p_bFilterTools then
    begin
      saresult+='</td><td>'+saFilterTool_AndNot_Toggle(p_saWidgetName, p_bfilterNOT)+'</td></tr></table>';
    end;

  End
  Else
  Begin
    saTemp:=uppercase(trim(saDefaultValue));
    i4TempLen:=length(saTemp);
    if(i4TempLen>0)then
    begin
      if satemp='NULL' then
      begin
        saResult +=saDefaultValue;
      end
      else
      begin
        if bVal(saTemp) then
        begin
          saResult+='Yes&nbsp;<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/dialog-ok.png" />&nbsp;';
        end
        else
        begin
          saResult+='No&nbsp;<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/dialog-no.png" />&nbsp;';
        end;
      end;
    end
    else
    begin
      saResult+=saDefaultValue+'&nbsp;<img class="image" src="<? echo $JASDIRICONTHEME; ?>16/actions/dialog-ok.png" />&nbsp;';
    end;
  End;
  saResult+='</td></tr>';
  saResult+='</table>';
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[#'+p_saWidgetName+'#]',saResult);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102665,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================













//=============================================================================
{}
Procedure WidgetDateTime(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_bWidgetDate: boolean;
  p_bWidgetTime: boolean;
  p_saWidgetMask: AnsiString; // JDate Formats - Input and Display
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring
);
//=============================================================================
Var saResult: AnsiString;
    bDate: Boolean;
    bTime: Boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='WidgetDateTime'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102672,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102673, sTHIS_ROUTINE_NAME);{$ENDIF}

  clearnullevents(
    p_saOnBlur,
    p_saOnChange,
    p_saOnClick,
    p_saOnDblClick,
    p_saOnFocus,
    p_saOnKeyDown,
    p_saOnKeypress,
    p_saOnKeyUp
  );


  if saMid(p_saDefaultValue,8,1)='/' then
  begin
    //asprintln('Funky date before:'+p_saDefaultValue);
    p_saDefaultValue:='';//JDATE(p_saDefaultValue,cnDateFormat_01,cnDateFormat_22);
    //asprintln('Funky date after:'+p_saDefaultValue);
  end;
  if (p_saDefaultValue='00/00/00 12:00 AM') or (p_saDefaultValue='12/30/1899 12:00 AM') then p_saDefaultValue:='';


  bDate:=p_bWidgetDate;
  bTime:=p_bWidgetTime;
  If ival(p_saWidgetMask)=0 Then p_saWidgetMask:=csDateFormat_01;
  If (not bDate) and (not bTime) Then
  Begin
    bDate:=True;
    bTime:=True;
    //p_saWidgetMask:='1';
  End;

  saResult:='<table border="0">';
  saResult+='<tr><td>';
  If not p_bEditMode Then saResult+='<u>';
  saResult+=p_saWidgetCaption;
  If not p_bEditMode Then saResult+='</u>';
  if (p_bRequired) then
  begin
    saResult+='<span name="'+p_saWidgetName+'rf" id="'+
      p_saWidgetName+'rf" >'+
      '<font color="red" style="font: strong">&nbsp;*&nbsp;</font>'+
      '</span>';
  end;
  If not p_bDataOnRight Then saResult+='</td></tr>';
  If not p_bDataOnRight Then saResult+='<tr>';
  If p_bEditMode Then
  Begin
    saResult +='<td>';
    //if p_bFilterTools then saResult+='<table><tr><td>';

    saresult+=csCRLF+'<script language="javascript">'+csCRLF;
    if p_saOnBlur    <>'' then saResult+='function '+p_saWidgetName+'_OnBlur(){'    +csCRLF+p_saOnBlur    +csCRLF+'}'+csCRLF;
    if p_saOnChange  <>'' then saResult+='function '+p_saWidgetName+'_OnChange(){'  +csCRLF+p_saOnChange  +csCRLF+'}'+csCRLF;
    if p_saOnClick   <>'' then saResult+='function '+p_saWidgetName+'_OnClick(){'   +csCRLF+p_saOnClick   +csCRLF+'}'+csCRLF;
    if p_saOnDblClick<>'' then saResult+='function '+p_saWidgetName+'_OnDblClick(){'+csCRLF+p_saOnDblClick+csCRLF+'}'+csCRLF;
    if p_saOnFocus   <>'' then saResult+='function '+p_saWidgetName+'_OnFocus(){'   +csCRLF+p_saOnFocus   +csCRLF+'}'+csCRLF;
    if p_saOnKeyDown <>'' then saResult+='function '+p_saWidgetName+'_OnKeyDown(){' +csCRLF+p_saOnKeyDown +csCRLF+'}'+csCRLF;
    if p_saOnKeypress<>'' then saResult+='function '+p_saWidgetName+'_OnKeypress(){'+csCRLF+p_saOnKeypress+csCRLF+'}'+csCRLF;
    if p_saOnKeyUp   <>'' then saResult+='function '+p_saWidgetName+'_OnKeyUp(){'   +csCRLF+p_saOnKeyUp   +csCRLF+'}'+csCRLF;
    saresult+=csCRLF+'</script>'+csCRLF;

  End
  Else
  Begin
    saresult+='<td class="rodata" ';
    If length(trim(p_saDefaultValue))=0 Then
    Begin
      saResult +='height=20>';
    End
    Else
    Begin
      saResult+='>'+p_saDefaultValue;
    End;
  End;
  saResult+='<input type="';
  If p_bEditMode Then saResult+='text" ' Else saResult+='hidden" ';
  saResult+='name="'+p_saWidgetName+'" id="'+p_saWidgetName
           +'" value="'+p_saDefaultValue+'"';

  If p_bEditMode Then
  Begin
    If p_saWidgetMask='12' Then saResult+='size=8 maxlength=8 ';

    if p_saOnBlur    <>'' then saResult+='onblur="return '+p_saWidgetName+'_OnBlur();" ';
    if p_saOnChange  <>'' then saResult+='onchange="return '+p_saWidgetName+'_OnChange();" ';
    if p_saOnClick   <>'' then saResult+='onclick="return '+p_saWidgetName+'_OnClick();" ';
    if p_saOnDblClick<>'' then saResult+='ondblclick="return '+p_saWidgetName+'_OnDblClick();" ';
    if p_saOnFocus   <>'' then saResult+='onfocus="return '+p_saWidgetName+'_OnFocus();" ';
    if p_saOnKeyDown <>'' then saResult+='onkeydown="return '+p_saWidgetName+'_OnKeyDown();" ';
    if p_saOnKeypress<>'' then saResult+='onkeypress="return '+p_saWidgetName+'_OnKeypress();" ';
    if p_saOnKeyUp   <>'' then saResult+='onkeyup="return '+p_saWidgetName+'_OnKeyUp();" ';

  End;
  saResult+='>';
  If p_bEditMode Then
  Begin
    if bDate and (not bTime) then
    begin
      saResult+='<a href="javascript:NewCssCal('''+p_saWidgetName+''',''mmddyyyy'',''dropdown'');">';
    end
    else
    begin
      saResult+='<a href="javascript: NewCssCal('''+p_saWidgetName+''',''mmddyyyy'',''dropdown'',true,12,true)">';
    end;
    saResult+='<img class="image" ' + 'name="IMG'+p_saWidgetName+'" id="IMG'+p_saWidgetName+'" title="Select ';
    If bdate Then saResult+='Date';
    If bDate and bTime Then saResult+=' and ';
    If bdate Then saResult+='Time';
    saresult+='" ';
    saResult+='src="<? echo $JASDIRICONTHEME; ?>16/apps/';
    If bDate and (not btime) Then saResult+='accessories-date.png';
    If bDate and (btime) Then saResult+='accessories-dictionary.png';
    If (not bDate) and btime Then saResult+='accessories-timer.png';
    saresult+='" align="absmiddle" style="cursor: hand" />';
    saresult+='</a>';
  End;
  saResult+='</td></tr>';
  saResult+='</table>';
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[#'+p_saWidgetName+'#]',saResult);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102674,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================














































//=============================================================================
{}
// XDL Reference
// reference: name=caption, value=returned,
//u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
Procedure WidgetList(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u2Size: word;
  p_bMultiple: boolean;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_XDL: JFC_XDL;// reference: name=caption, value=returned, desc = "" or "selected", iUser=1 then option selectable (0=grayed out)
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring
);
//=============================================================================
Var saResult: AnsiString;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='WidgetList'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102680,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102681, sTHIS_ROUTINE_NAME);{$ENDIF}


  clearnullevents(
    p_saOnBlur,
    p_saOnChange,
    p_saOnClick,
    p_saOnDblClick,
    p_saOnFocus,
    p_saOnKeyDown,
    p_saOnKeypress,
    p_saOnKeyUp
  );
  if not p_bFilterTools then if trim(p_saDefaultValue)='NULL' then p_saDefaultValue:='';

  saResult:='<table border="0">';

  If (length(p_saWidgetCaption)>0) and (not p_bRequired) Then
  Begin
    saResult+='<tr><td>';
    If not p_bEditMode Then saResult+='<u>';
    saResult+=p_saWidgetCaption;
    If not p_bEditMode Then saResult+='</u>';
    if (p_bRequired) then
    begin
      saResult+='<span name="'+p_saWidgetName+'rf" id="'+
        p_saWidgetName+'rf" >'+
        '<font color="red" style="font: strong">&nbsp;*&nbsp;</font>'+
        '</span>';
    end;
    If not p_bDataOnRight Then saResult+='</td></tr>';
  End;


  If not p_bDataOnRight Then saResult+='<tr>';
  If p_bEditMode Then
  Begin
    saResult +='<td>';

    saresult+=csCRLF+'<script language="javascript">'+csCRLF;
    if p_saOnBlur    <>'' then saResult+='function '+p_saWidgetName+'_OnBlur(){'    +csCRLF+p_saOnBlur    +csCRLF+'}'+csCRLF;
    if p_saOnChange  <>'' then saResult+='function '+p_saWidgetName+'_OnChange(){'  +csCRLF+p_saOnChange  +csCRLF+'}'+csCRLF;
    if p_saOnClick   <>'' then saResult+='function '+p_saWidgetName+'_OnClick(){'   +csCRLF+p_saOnClick   +csCRLF+'}'+csCRLF;
    if p_saOnDblClick<>'' then saResult+='function '+p_saWidgetName+'_OnDblClick(){'+csCRLF+p_saOnDblClick+csCRLF+'}'+csCRLF;
    if p_saOnFocus   <>'' then saResult+='function '+p_saWidgetName+'_OnFocus(){'   +csCRLF+p_saOnFocus   +csCRLF+'}'+csCRLF;
    if p_saOnKeyDown <>'' then saResult+='function '+p_saWidgetName+'_OnKeyDown(){' +csCRLF+p_saOnKeyDown +csCRLF+'}'+csCRLF;
    if p_saOnKeypress<>'' then saResult+='function '+p_saWidgetName+'_OnKeypress(){'+csCRLF+p_saOnKeypress+csCRLF+'}'+csCRLF;
    if p_saOnKeyUp   <>'' then saResult+='function '+p_saWidgetName+'_OnKeyUp(){'   +csCRLF+p_saOnKeyUp   +csCRLF+'}'+csCRLF;
    saresult+=csCRLF+'</script>'+csCRLF;


    if p_bFilterTools then saresult+='<table><tr><td>';
  End
  Else
  Begin
    saresult+='<td class="rodata" ';
    If length(trim(p_saDefaultValue))=0 Then
    Begin
      saResult +='height="20">';
    End
    Else
    Begin
      saResult+='>'+p_saDefaultValue;
    End;
  End;
//  saResult+='<input type="';
//  If p_bEditMode Then saResult+='text" ' Else saResult+='hidden" ';
//  If p_saMaxLen<>'' Then saResult+='maxlength="'+p_saMaxLen+'" ';
//  If p_saSize<>'' Then saResult+='size="'+p_saSize+'" ';
//  saResult+='name="'+p_saWidgetName+'" id="'+p_saWidgetName
//           +'" value="'+saSNRStr(p_saDefaultValue,'"','&quot;') +'">';

  saResult+='<select size="'+inttostr(p_u2Size)+'" name="'+p_saWidgetName+'" id="'+p_saWidgetName +'" ';
  if p_bMultiple then saResult+='multiple ';

  if p_bEditMode then
  begin
    if p_saOnBlur    <>'' then saResult+='onblur="return '+p_saWidgetName+'_OnBlur();" ';
    if p_saOnChange  <>'' then saResult+='onchange="return '+p_saWidgetName+'_OnChange();" ';
    if p_saOnClick   <>'' then saResult+='onclick="return '+p_saWidgetName+'_OnClick();" ';
    if p_saOnDblClick<>'' then saResult+='ondblclick="return '+p_saWidgetName+'_OnDblClick();" ';
    if p_saOnFocus   <>'' then saResult+='onfocus="return '+p_saWidgetName+'_OnFocus();" ';
    if p_saOnKeyDown <>'' then saResult+='onkeydown="return '+p_saWidgetName+'_OnKeyDown();" ';
    if p_saOnKeypress<>'' then saResult+='onkeypress="return '+p_saWidgetName+'_OnKeypress();" ';
    if p_saOnKeyUp   <>'' then saResult+='onkeyup="return '+p_saWidgetName+'_OnKeyUp();" ';
  end;

  saResult+='>';
  if p_XDL<>nil then
  begin
    if p_XDL.movefirst then
    begin
      repeat
        saResult+='<option value="'+p_XDL.Item_saValue+'" ';

        // reference: name=caption, value=returned, //u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
        if (p_XDL.Item_i8User and b00) <> b00 then saResult+='disabled ';
        if (p_XDL.Item_i8User and b01) = b01 then saResult+='selected ';
        if (p_XDL.Item_i8User and b02) = b02 then saResult+='default ';

        saResult+='>'+p_XDL.Item_saName+'</option>'+csCRLF;

      until (not p_XDL.MoveNext);
    end;
  end;
  saResult+='</select>';
  if p_bEditMode and p_bFilterTools then
  begin
    saResult+='</td><td>'+saFilterTool_AndNot_Toggle(p_saWidgetName, p_bfilterNOT)+'</td></tr></table>';
  end;
  saResult+='</td></tr>';
  saResult+='</table>';
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[#'+p_saWidgetName+'#]',saResult);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102682,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================
















//=============================================================================
{}
Procedure WidgetDropDown(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u2Size: word;
  p_bMultiple: boolean;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_XDL: JFC_XDL;
  p_bIfInReadOnly_UseDefaultValueOnly: boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring
);
//=============================================================================
Var saResult: AnsiString;
    saSought: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='WidgetDropDown'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102691,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102692, sTHIS_ROUTINE_NAME);{$ENDIF}

  clearnullevents(
    p_saOnBlur,
    p_saOnChange,
    p_saOnClick,
    p_saOnDblClick,
    p_saOnFocus,
    p_saOnKeyDown,
    p_saOnKeypress,
    p_saOnKeyUp
  );

  if not p_bFilterTools then if trim(p_saDefaultValue)='NULL' then p_saDefaultValue:='';

  saResult:='<!--WidgetDropDown Begin-->';
  saResult+=csCRLF+'<table border="0">';
  //If length(p_saWidgetCaption)>0 Then
  //Begin
    saResult+=csCRLF+'<tr><td>';
    If not p_bEditMode Then saResult+='<u>';
    saResult+=p_saWidgetCaption;
    If not p_bEditMode Then saResult+='</u>';
    if (p_bRequired) then
    begin
      saResult+='<span name="'+p_saWidgetName+'rf" id="'+
        p_saWidgetName+'rf" >'+
        '<font color="red" style="font: strong">&nbsp;*&nbsp;</font>'+
        '</span>';
    end;
    If not p_bDataOnRight Then saResult+='</td>'+csCRLF+'</tr>'+csCRLF;
  //End;
  If not p_bDataOnRight Then saResult+='<tr>';
  If p_bEditMode Then
  Begin
    saResult +='<td>';

    saresult+=csCRLF+'<script language="javascript">'+csCRLF;
    if p_saOnBlur    <>'' then saResult+='function '+p_saWidgetName+'_OnBlur(){'    +csCRLF+p_saOnBlur    +csCRLF+'}'+csCRLF;
    if p_saOnChange  <>'' then saResult+='function '+p_saWidgetName+'_OnChange(){'  +csCRLF+p_saOnChange  +csCRLF+'}'+csCRLF;
    if p_saOnClick   <>'' then saResult+='function '+p_saWidgetName+'_OnClick(){'   +csCRLF+p_saOnClick   +csCRLF+'}'+csCRLF;
    if p_saOnDblClick<>'' then saResult+='function '+p_saWidgetName+'_OnDblClick(){'+csCRLF+p_saOnDblClick+csCRLF+'}'+csCRLF;
    if p_saOnFocus   <>'' then saResult+='function '+p_saWidgetName+'_OnFocus(){'   +csCRLF+p_saOnFocus   +csCRLF+'}'+csCRLF;
    if p_saOnKeyDown <>'' then saResult+='function '+p_saWidgetName+'_OnKeyDown(){' +csCRLF+p_saOnKeyDown +csCRLF+'}'+csCRLF;
    if p_saOnKeypress<>'' then saResult+='function '+p_saWidgetName+'_aOnKeypress(){'+csCRLF+p_saOnKeypress+csCRLF+'}'+csCRLF;
    if p_saOnKeyUp   <>'' then saResult+='function '+p_saWidgetName+'_OnKeyUp(){'   +csCRLF+p_saOnKeyUp   +csCRLF+'}'+csCRLF;
    saresult+=csCRLF+'</script>'+csCRLF;
    if p_bFilterTools then saResult+='<table><tr><td>';
  End
  Else
  Begin
    saresult+='<td class="rodata" ';
    If length(trim(p_saDefaultValue))=0 Then
    Begin
      saResult +='height="20">';
    End
    Else
    Begin
      saResult+='>';
    End;
  End;
//  saResult+='<input type="';
//  If p_bEditMode Then saResult+='text" ' Else saResult+='hidden" ';
//  If p_saMaxLen<>'' Then saResult+='maxlength="'+p_saMaxLen+'" ';
//   If p_saSize<>'' Then saResult+='size="'+p_saSize+'" ';
//  saResult+='name="'+p_saWidgetName+'" id="'+p_saWidgetName
//           +'" value="'+saSNRStr(p_saDefaultValue,'"','&quot;') +'">';

  if p_bEditMode then
  begin
    if p_XDL<>nil then
    begin
      if p_XDL.FoundItem_saValue(p_saDefaultValue) then
      begin
        saSought:=p_XDL.Item_saName;
      end
      else
      begin
        saSought+='Missing: '+p_saDefaultValue;
      end;
    end
    else
    begin
      saSought+='Missing: '+p_saDefaultValue;
    end;

    saResult+='<select size="'+inttostr(p_u2Size)+'" name="'+p_saWidgetName+'" id="'+p_saWidgetName +'" ';

    if p_saOnBlur    <>'' then saResult+='onblur="return '+p_saWidgetName+'_OnBlur();" '         ;
    if p_saOnChange  <>'' then saResult+='onchange="return '+p_saWidgetName+'_OnChange();" '     ;
    if p_saOnClick   <>'' then saResult+='onclick="return '+p_saWidgetName+'_OnClick();" '       ;
    if p_saOnDblClick<>'' then saResult+='ondblclick="return '+p_saWidgetName+'_OnDblClick();" ' ;
    if p_saOnFocus   <>'' then saResult+='onfocus="return '+p_saWidgetName+'_OnFocus();" '       ;
    if p_saOnKeyDown <>'' then saResult+='onkeydown="return '+p_saWidgetName+'_OnKeyDown();" '   ;
    if p_saOnKeypress<>'' then saResult+='onkeypress="return '+p_saWidgetName+'_OnKeypress();" ' ;
    if p_saOnKeyUp   <>'' then saResult+='onkeyup="return '+p_saWidgetName+'_OnKeyUp();" '       ;
    
    if p_bMultiple then saResult+='multiple ';
    saResult+='>'+csCRLF;
    if p_XDL<>nil then
    begin
      if p_XDL.movefirst then
      begin
        repeat
          saResult+='  <option value="'+p_XDL.Item_saValue+'" ';

          // reference: name=caption, value=returned, //u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
          if (p_XDL.Item_i8User and b00) <> b00 then saResult+='disabled ';
          if (p_XDL.Item_i8User and b01) = b01 then saResult+='selected ';
          if (p_XDL.Item_i8User and b02) = b02 then saResult+='default ';

          saResult+='>'+p_XDL.Item_saName+'</option>'+csCRLF;

          // debug version
          //saResult+='>'+p_XDL.Item_saName+' (Flags: '+inttostr(p_XDL.Item_i8User)+')</option>'+csCRLF;

        until not p_XDL.MoveNext;
      end;
    end;
  end
  else
  begin
    if not p_bIfInReadOnly_UseDefaultValueOnly then
    begin
      if p_XDL<>nil then
      begin
        if p_XDL.FoundItem_saValue(p_saDefaultValue) then
        begin
          saResult+=p_XDL.Item_saName;
        end
        else
        begin
          saResult+='Missing: '+p_saDefaultValue;
        end;
      end
      else
      begin
        saResult+='Missing: '+p_saDefaultValue;
      end;
    end
    else
    begin
      saResult+=p_saDefaultValue;
    end;
  end;

  if p_bEditMode then
  begin
    saResult+='</select>'+csCRLF;
    if p_bFilterTools then
    begin
      saResult+='</td><td>'+saFilterTool_AndNot_Toggle(p_saWidgetName, p_bfilterNOT)+'</td></tr></table>';
    end;
  end;
  saResult+='</td></tr>'+csCRLF;
  saResult+='</table>'+csCRLF;
  saResult+='<!--WidgetDropDown End-->'+csCRLF;
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[#'+p_saWidgetName+'#]',saResult);

  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'WebWidget Dropdown '+p_saWidgetName +' Output: '+saResult,'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_saWidgetName: '+p_saWidgetName,'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_saWidgetCaption: '+p_saWidgetCaption,'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_saDefaultValue: '+p_saDefaultValue,'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_saSize: '+p_saSize,'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_bMultiple: '+saYesNo(p_bMultiple),'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_bEditMode: '+saYesNo(p_bEditMode),'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_bDataOnRight: '+saYesNo(p_bDataOnRight),'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_XDL.ListCount: '+ inttostr(p_XDL.ListCount),'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_bLookUpOnly: '+saYesNo(p_bLookUpOnly),'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_bIfInReadOnly_UseDefaultValueOnly: '+saYesNo(p_bIfInReadOnly_UseDefaultValueOnly),'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_bRequired: '+saYesno(p_bRequired),'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_bFilterTools: '+saYesno(p_bFilterTools),'',SOURCEFILE);
  //JAS_LOG(p_Context, cnLog_ebug, 201204022002, 'p_bFilterNot: '+saYesNo(p_bFilterTools),'',SOURCEFILE);



{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102693,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================
































//=============================================================================
{}
Procedure WidgetComboBox(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u8MaxLen: uint64;
  p_u2Size: word;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_XDL: JFC_XDL;// reference: name=caption, value=returned, desc = "" (not selected) or "selected" | "true" (selected)  , iUser=1 then option selectable (0=grayed out)
  p_bIfInReadOnly_UseDefaultValueOnly: boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring;
  p_saOnSelect: ansistring
);
//=============================================================================
Var saResult: AnsiString;
    saSought: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='WidgetComboBox'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204151622,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204151623, sTHIS_ROUTINE_NAME);{$ENDIF}

  clearnullevents(
    p_saOnBlur,
    p_saOnChange,
    p_saOnClick,
    p_saOnDblClick,
    p_saOnFocus,
    p_saOnKeyDown,
    p_saOnKeypress,
    p_saOnKeyUp
  );
  p_saOnSelect:=trim(p_saOnSelect);if p_saOnSelect='NULL' then p_saOnSelect:='';
  if not p_bFilterTools then if trim(p_saDefaultValue)='NULL' then p_saDefaultValue:='';

  saResult:='<!--WidgetComboBox Begin-->';
  saResult+=csCRLF+'<table>';
  saResult+=csCRLF+'<tr><td>';
  If not p_bEditMode Then saResult+='<u>';
  saResult+=p_saWidgetCaption;
  If not p_bEditMode Then saResult+='</u>';
  if (p_bRequired) then
  begin
    saResult+='<span name="'+p_saWidgetName+'rf" id="'+
      p_saWidgetName+'rf" >'+
      '<font color="red" style="font: strong">&nbsp;*&nbsp;</font>'+
      '</span>';
  end;
  If not p_bDataOnRight Then saResult+='</td>'+csCRLF+'</tr>'+csCRLF+'<tr>';
  If p_bEditMode Then
  Begin
    saResult +='<td>';
    saresult+=csCRLF+'<script language="javascript">'+csCRLF;
    if p_saOnBlur    <>'' then saResult+='function '+p_saWidgetName+'_OnBlur(){'    +csCRLF+p_saOnBlur    +csCRLF+'}'+csCRLF;
    if p_saOnChange  <>'' then saResult+='function '+p_saWidgetName+'_OnChange(){'  +csCRLF+p_saOnChange  +csCRLF+'}'+csCRLF;
    if p_saOnClick   <>'' then saResult+='function '+p_saWidgetName+'_OnClick(){'   +csCRLF+p_saOnClick   +csCRLF+'}'+csCRLF;
    if p_saOnDblClick<>'' then saResult+='function '+p_saWidgetName+'_OnDblClick(){'+csCRLF+p_saOnDblClick+csCRLF+'}'+csCRLF;
    if p_saOnFocus   <>'' then saResult+='function '+p_saWidgetName+'_OnFocus(){'   +csCRLF+p_saOnFocus   +csCRLF+'}'+csCRLF;
    if p_saOnKeyDown <>'' then saResult+='function '+p_saWidgetName+'_OnKeyDown(){' +csCRLF+p_saOnKeyDown +csCRLF+'}'+csCRLF;
    if p_saOnKeypress<>'' then saResult+='function '+p_saWidgetName+'_OnKeypress(){'+csCRLF+p_saOnKeypress+csCRLF+'}'+csCRLF;
    if p_saOnKeyUp   <>'' then saResult+='function '+p_saWidgetName+'_OnKeyUp(){'   +csCRLF+p_saOnKeyUp   +csCRLF+'}'+csCRLF;
    if p_saOnKeyUp   <>'' then saResult+='function '+p_saWidgetName+'_OnSelect(){'  +csCRLF+p_saOnSelect  +csCRLF+'}'+csCRLF;
    saresult+='function '+p_saWidgetName+'cbo_Copy(p){document.getElementById("'+p_saWidgetName+'").value=p;};'+csCRLF;
    saresult+='</script>'+csCRLF;
    if p_bFilterTools then saResult+='<table><tr><td>';
  End
  Else
  Begin
    saresult+='<td class="rodata" ';
    If length(trim(p_saDefaultValue))=0 Then
    Begin
      saResult +='height="20">';
    End
    Else
    Begin
      saResult+='>';
    End;
  End;
//  saResult+='<input type="';
//  If p_bEditMode Then saResult+='text" ' Else saResult+='hidden" ';
//  If p_saMaxLen<>'' Then saResult+='maxlength="'+p_saMaxLen+'" ';
//  If p_saSize<>'' Then saResult+='size="'+p_saSize+'" ';
//  saResult+='name="'+p_saWidgetName+'" id="'+p_saWidgetName
//           +'" value="'+saSNRStr(p_saDefaultValue,'"','&quot;') +'">';

  if p_bEditMode then
  begin
    if p_XDL<>nil then
    begin
      if p_XDL.FoundItem_saValue(p_saDefaultValue) then
      begin
        saSought:=p_XDL.Item_saName;
      end
      else
      begin
        saSought+='Missing: '+p_saDefaultValue;
      end;
    end
    else
    begin
      saSought+='Missing: '+p_saDefaultValue;
    end;

    saResult+='<select size="1" name="'+p_saWidgetName+'cbo" id="'+p_saWidgetName +'cbo" ';
    if p_saOnBlur    <>'' then saResult+='onblur="return '+p_saWidgetName+'_OnBlur();" '         ;

    saresult+='onchange="'+p_saWidgetName+'cbo_Copy(this.value);';
    if p_saOnChange  <>'' then saResult+='return '+p_saWidgetName+'_OnChange();';
    saresult+='" ';
    if p_saOnClick   <>'' then saResult+='onclick="return '+p_saWidgetName+'_OnClick();" '       ;
    if p_saOnDblClick<>'' then saResult+='ondblclick="return '+p_saWidgetName+'_OnDblClick();" ' ;
    if p_saOnFocus   <>'' then saResult+='onfocus="return '+p_saWidgetName+'_OnFocus();" '       ;
    if p_saOnKeyDown <>'' then saResult+='onkeydown="return '+p_saWidgetName+'_OnKeyDown();" '   ;
    if p_saOnKeypress<>'' then saResult+='onkeypress="return '+p_saWidgetName+'_OnKeypress();" ' ;
    if p_saOnKeyUp   <>'' then saResult+='onkeyup="return '+p_saWidgetName+'_OnKeyUp();" '       ;

    //if p_bMultiple then saResult+='multiple ';
    saResult+='>';

    if p_XDL<>nil then
    begin
      if p_XDL.movefirst then
      begin
        repeat

          saResult+=csCRLF+'  <option value="'+p_XDL.Item_saValue+'" ';

          // reference: name=caption, value=returned, //u8User bit flags: (b0)1=selectable, (b1)2=selected, (b2)4=default
          if (p_XDL.Item_i8User and b00) <> b00 then saResult+='disabled ';
          if (p_XDL.Item_i8User and b01) = b01 then saResult+='selected ';
          if (p_XDL.Item_i8User and b02) = b02 then saResult+='default ';

          saResult+='>'+p_XDL.Item_saName+'</option>'+csCRLF;

          // debug version
          //saResult+='>'+p_XDL.Item_saName+' (Flags: '+inttostr(p_XDL.Item_i8User)+')</option>'+csCRLF;

        until not p_XDL.MoveNext;
      end;
    end;
  end
  else
  begin
    if not p_bIfInReadOnly_UseDefaultValueOnly then
    begin
      if p_XDL<>nil then
      begin
        if p_XDL.FoundItem_saValue(p_saDefaultValue) then
        begin
          saResult+=p_XDL.Item_saName;
        end
        else
        begin
          saResult+='Missing: '+p_saDefaultValue;
        end;
      end
      else
      begin
        saResult+='Missing: '+p_saDefaultValue;
      end;
    end
    else
    begin
      saResult+=p_saDefaultValue;
    end;
  end;

  if p_bEditMode then
  begin
    saResult+='</select>'+csCRLF;
    //------------------------INPUT BOX
    saResult+='<br /><input type="';
    If p_bEditMode Then saResult+='text" ' else saResult+='hidden" ';
    If p_u8MaxLen>0 Then saResult+='maxlength="'+inttostr(p_u8MaxLen)+'" ';
    If p_u2Size>0 Then saResult+='size="'+inttostr(p_u2Size)+'" ';
    saResult+='name="'+p_saWidgetName+'" id="'+p_saWidgetName
             +'" value="'+saSNRStr(p_saDefaultValue,'"','&quot;') +'"';
    if p_bEditMode then
    begin
      if p_saOnBlur    <>'' then saResult+='onblur="return '+p_saWidgetName+'_OnBlur();" ';
      if p_saOnChange  <>'' then saResult+='onchange="return '+p_saWidgetName+'_OnChange();" ';
      if p_saOnClick   <>'' then saResult+='onclick="return '+p_saWidgetName+'_OnClick();" ';
      if p_saOnDblClick<>'' then saResult+='ondblclick="return '+p_saWidgetName+'_OnDblClick();" ';
      if p_saOnFocus   <>'' then saResult+='onfocus="return '+p_saWidgetName+'_OnFocus();" ';
      if p_saOnKeyDown <>'' then saResult+='onkeydown="return '+p_saWidgetName+'_OnKeyDown();" ';
      if p_saOnKeypress<>'' then saResult+='onkeypress="return '+p_saWidgetName+'_OnKeypress();" ';
      if p_saOnKeyUp   <>'' then saResult+='onkeyup="return '+p_saWidgetName+'_OnKeyUp();" ';
      if p_saOnSelect  <>'' then saResult+='onselect="return '+p_saWidgetName+'_OnSelect();" ';
    end;
    saresult+=' />';
    //------------------------INPUT BOX
    if p_bFilterTools then
    begin
      saResult+='</td><td>'+saFilterTool_AndNot_Toggle(p_saWidgetName, p_bfilterNOT)+'</td></tr></table>';
    end;
  end;
  saResult+='</td></tr>'+csCRLF;
  saResult+='</table>'+csCRLF;
  saResult+='<!--WidgetComboBox End-->'+csCRLF;
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[#'+p_saWidgetName+'#]',saResult);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204151624,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================





































//=============================================================================
Procedure WidgetURL(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_u2WidgetWidth: word;
  p_saDefaultValue: AnsiString;
  p_u8MaxLen: UInt64;
  p_u2Size: word;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring;
  p_saOnSelect: ansistring
);
//=============================================================================
Var
  saResult: AnsiString;
  saUP: ansistring;
  sa: ansistring;
  u2WidgetWidth: byte;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='WidgetURL'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102700,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102700, sTHIS_ROUTINE_NAME);{$ENDIF}

  sa:='';
  u2WidgetWidth:=p_u2WidgetWidth;
  clearnullevents(
    p_saOnBlur,
    p_saOnChange,
    p_saOnClick,
    p_saOnDblClick,
    p_saOnFocus,
    p_saOnKeyDown,
    p_saOnKeypress,
    p_saOnKeyUp
  );
  p_saOnSelect:=trim(p_saOnSelect);if p_saOnSelect='NULL' then p_saOnSelect:='';



  if not p_bFilterTools then if trim(p_saDefaultValue)='NULL' then p_saDefaultValue:='';

  saResult:='<table border="0">';
  saUP:=upcase(trim(p_saDefaultValue));
  if (not p_bfilterTools) and (saUP<>'NULL') and (saUP<>'') then
  begin
    if (saLeftStr(saUP,7)<>'HTTP://') and
       (saLeftStr(saUP,8)<>'HTTPS://') and
       (saLeftStr(saUP,6)<>'FTP://') and
       (saLeftStr(saUP,6)<>'TEL://') and
       (saLeftStr(saUP,1)<>'/') then
    begin
      p_saDefaultValue:='http://'+p_saDefaultValue;
    end;
  end;

  saResult+='<tr><td>';
  If not p_bEditMode Then saResult+='<u>';
  if (not p_bfilterTools) and (saUP<>'NULL') then
  begin
    saResult+='<a target="_blank" href="'+p_saDefaultValue+'" title="Click to go to '+
      saEncodeURI(p_saWidgetCaption)+' in a new window or tab." />'+p_saWidgetCaption+'</a>';
  end
  else
  begin
    saResult+=saEncodeURI(p_saWidgetCaption);
  end;

  If not p_bEditMode Then saResult+='</u>';
  if (p_bRequired) then
  begin
    saResult+='<span name="'+p_saWidgetName+'rf" id="'+
      p_saWidgetName+'rf" >'+
      '<font color="red" style="font: strong">&nbsp;*&nbsp;</font>'+
      '</span>';
  end;
  If not p_bDataOnRight Then saResult+='</td></tr>';
  If not p_bDataOnRight Then saResult+='<tr>';
  If p_bEditMode Then
  Begin
    saResult +='<td>';

    saresult+=csCRLF+'<script language="javascript">'+csCRLF;
    if p_saOnBlur    <>'' then saResult+='function '+p_saWidgetName+'_OnBlur(){'    +csCRLF+p_saOnBlur    +csCRLF+'}'+csCRLF;
    if p_saOnChange  <>'' then saResult+='function '+p_saWidgetName+'_OnChange(){'  +csCRLF+p_saOnChange  +csCRLF+'}'+csCRLF;
    if p_saOnClick   <>'' then saResult+='function '+p_saWidgetName+'_OnClick(){'   +csCRLF+p_saOnClick   +csCRLF+'}'+csCRLF;
    if p_saOnDblClick<>'' then saResult+='function '+p_saWidgetName+'_OnDblClick(){'+csCRLF+p_saOnDblClick+csCRLF+'}'+csCRLF;
    if p_saOnFocus   <>'' then saResult+='function '+p_saWidgetName+'_OnFocus(){'   +csCRLF+p_saOnFocus   +csCRLF+'}'+csCRLF;
    if p_saOnKeyDown <>'' then saResult+='function '+p_saWidgetName+'_OnKeyDown(){' +csCRLF+p_saOnKeyDown +csCRLF+'}'+csCRLF;
    if p_saOnKeypress<>'' then saResult+='function '+p_saWidgetName+'_OnKeypress(){'+csCRLF+p_saOnKeypress+csCRLF+'}'+csCRLF;
    if p_saOnKeyUp   <>'' then saResult+='function '+p_saWidgetName+'_OnKeyUp(){'   +csCRLF+p_saOnKeyUp   +csCRLF+'}'+csCRLF;
    if p_saOnSelect  <>'' then saResult+='function '+p_saWidgetName+'_OnSelect(){'  +csCRLF+p_saOnSelect  +csCRLF+'}'+csCRLF;
    saresult+=csCRLF+'</script>'+csCRLF;

    if p_bfiltertools then saresult+='<table><tr><td>';
  End
  Else
  Begin
    saresult+='<td class="rodata" ';
    If length(trim(p_saDefaultValue))=0 Then
    Begin
      saResult +='height="20">';
    End
    Else
    Begin
      saResult+='>';
      if length(p_saDefaultValue)>u2WidgetWidth then
      begin
        sa+=saLeftStr(p_saDefaultValue,u2WidgetWidth)+'...';
      end
      else
      begin
        sa+=p_saDefaultValue;
      end;
      saResult+='<a target="_blank" href="'+p_saDefaultValue+'" title="Click to go to '+
      saEncodeURI(p_saWidgetCaption)+' in a new window or tab." />'+sa+'</a>';
    End;
  End;
  saResult+='<input type="';
  If p_bEditMode Then saResult+='text" ' Else saResult+='hidden" ';
  If p_u8MaxLen>0 Then saResult+='maxlength="'+inttostr(p_u8MaxLen)+'" ';
  If p_u2Size>0 Then saResult+='size="'+inttostr(p_u2Size)+'" ';
  saResult+='name="'+p_saWidgetName+'" id="'+p_saWidgetName+'" value="'+saSNRStr(p_saDefaultValue,'"','&quot;')+'" ';
  if p_bEditMode then
  begin
    if p_saOnBlur    <>'' then saResult+='onblur="return '+p_saWidgetName+'_OnBlur();" ';
    if p_saOnChange  <>'' then saResult+='onchange="return '+p_saWidgetName+'_OnChange();" ';
    if p_saOnClick   <>'' then saResult+='onclick="return '+p_saWidgetName+'_OnClick();" ';
    if p_saOnDblClick<>'' then saResult+='ondblclick="return '+p_saWidgetName+'_OnDblClick();" ';
    if p_saOnFocus   <>'' then saResult+='onfocus="return '+p_saWidgetName+'_OnFocus();" ';
    if p_saOnKeyDown <>'' then saResult+='onkeydown="return '+p_saWidgetName+'_OnKeyDown();" ';
    if p_saOnKeypress<>'' then saResult+='onkeypress="return '+p_saWidgetName+'_OnKeypress();" ';
    if p_saOnKeyUp   <>'' then saResult+='onkeyup="return '+p_saWidgetName+'_OnKeyUp();" ';
    if p_saOnSelect  <>'' then saResult+='onselect="return '+p_saWidgetName+'_OnSelect();" ';
  end;
  saresult+=' />';
  if p_bEditMode and p_bFilterTools then
  begin
    saResult+='</td><td>'+saFilterTool_AndNot_Toggle(p_saWidgetName, p_bfilterNOT)+'</td></tr></table>';
  end;
  saResult+='</td></tr>';
  saResult+='</table>';
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[#'+p_saWidgetName+'#]',saResult);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102702,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================













//=============================================================================
Procedure WidgetEMail(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saDefaultValue: AnsiString;
  p_u8MaxLen: Uint64;
  p_u2Size: word;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring;
  p_saOnSelect: ansistring
);
//=============================================================================
Var
  saResult: AnsiString;
  saUP: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='WidgetEmail'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204151552,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204151553, sTHIS_ROUTINE_NAME);{$ENDIF}

  clearnullevents(
    p_saOnBlur,
    p_saOnChange,
    p_saOnClick,
    p_saOnDblClick,
    p_saOnFocus,
    p_saOnKeyDown,
    p_saOnKeypress,
    p_saOnKeyUp
  );
  p_saOnSelect:=trim(p_saOnSelect);if p_saOnSelect='NULL' then p_saOnSelect:='';

  if not p_bFilterTools then if trim(p_saDefaultValue)='NULL' then p_saDefaultValue:='';

  saResult:='<table border="0">';
  saUP:=upcase(trim(p_saDefaultValue));
  saResult+='<tr><td>';
  If not p_bEditMode Then saResult+='<u>';
  if (not p_bfilterTools) and (saUP<>'NULL') then
  begin
    saResult+='<a target="_blank" href="';
    if saLeftStr(saUp,9)<>'mailto://' then saResult+='mailto://';
    saresult+=p_saDefaultValue+'" title="Click to send an Email to '+
      p_saWidgetCaption+' with your default Email client." />'+p_saWidgetCaption+'</a>';
  end
  else
  begin
    saResult+=p_saWidgetCaption;
  end;

  If not p_bEditMode Then saResult+='</u>';
  if (p_bRequired) then
  begin
    saResult+='<span name="'+p_saWidgetName+'rf" id="'+
      p_saWidgetName+'rf" >'+
      '<font color="red" style="font: strong">&nbsp;*&nbsp;</font>'+
      '</span>';
  end;
  If not p_bDataOnRight Then saResult+='</td></tr>';
  If not p_bDataOnRight Then saResult+='<tr>';
  If p_bEditMode Then
  Begin
    saResult +='<td>';

    saresult+=csCRLF+'<script language="javascript">'+csCRLF;
    if p_saOnBlur    <>'' then saResult+='function '+p_saWidgetName+'_OnBlur(){'    +csCRLF+p_saOnBlur    +csCRLF+'}'+csCRLF;
    if p_saOnChange  <>'' then saResult+='function '+p_saWidgetName+'_OnChange(){'  +csCRLF+p_saOnChange  +csCRLF+'}'+csCRLF;
    if p_saOnClick   <>'' then saResult+='function '+p_saWidgetName+'_OnClick(){'   +csCRLF+p_saOnClick   +csCRLF+'}'+csCRLF;
    if p_saOnDblClick<>'' then saResult+='function '+p_saWidgetName+'_OnDblClick(){'+csCRLF+p_saOnDblClick+csCRLF+'}'+csCRLF;
    if p_saOnFocus   <>'' then saResult+='function '+p_saWidgetName+'_OnFocus(){'   +csCRLF+p_saOnFocus   +csCRLF+'}'+csCRLF;
    if p_saOnKeyDown <>'' then saResult+='function '+p_saWidgetName+'_OnKeyDown(){' +csCRLF+p_saOnKeyDown +csCRLF+'}'+csCRLF;
    if p_saOnKeypress<>'' then saResult+='function '+p_saWidgetName+'_OnKeypress(){'+csCRLF+p_saOnKeypress+csCRLF+'}'+csCRLF;
    if p_saOnKeyUp   <>'' then saResult+='function '+p_saWidgetName+'_OnKeyUp(){'   +csCRLF+p_saOnKeyUp   +csCRLF+'}'+csCRLF;
    if p_saOnSelect  <>'' then saResult+='function '+p_saWidgetName+'_OnSelect(){'  +csCRLF+p_saOnSelect  +csCRLF+'}'+csCRLF;
    saresult+=csCRLF+'</script>'+csCRLF;

    if p_bfiltertools then saresult+='<table><tr><td>';
  End
  Else
  Begin
    saresult+='<td class="rodata" ';
    If length(trim(p_saDefaultValue))=0 Then
    Begin
      saResult +='height="20">';
    End
    Else
    Begin
      saResult+='>';
      saResult+='<a target="_blank" href="';
      if saLeftStr(saUp,9)<>'mailto://' then saResult+='mailto://';
      saResult+=p_saDefaultValue+'" title="Click to send an Email to '+p_saDefaultValue
      +' with your default Email client." />';
      if length(p_saDefaultValue)>40 then
      begin
        saResult+=saLeftStr(p_saDefaultValue,40)+'...';
      end
      else
      begin
        saResult+=p_saDefaultValue;
      end;
      //saResult+=p_saWidgetCaption+'</a>';
      saResult+='</a>';
    End;
  End;
  saResult+='<input type="';
  If p_bEditMode Then saResult+='text" ' Else saResult+='hidden" ';
  If p_u8MaxLen>0 Then saResult+='maxlength="'+inttostr(p_u8MaxLen)+'" ';
  If p_u2Size>0 Then saResult+='size="'+inttostr(p_u2Size)+'" ';
  saResult+='name="'+p_saWidgetName+'" id="'+p_saWidgetName+'" value="'+saSNRStr(p_saDefaultValue,'"','&quot;')+'" ';
  if p_bEditMode then
  begin
    if p_saOnBlur    <>'' then saResult+='onblur="return '+p_saWidgetName+'_OnBlur();" ';
    if p_saOnChange  <>'' then saResult+='onchange="return '+p_saWidgetName+'_OnChange();" ';
    if p_saOnClick   <>'' then saResult+='onclick="return '+p_saWidgetName+'_OnClick();" ';
    if p_saOnDblClick<>'' then saResult+='ondblclick="return '+p_saWidgetName+'_OnDblClick();" ';
    if p_saOnFocus   <>'' then saResult+='onfocus="return '+p_saWidgetName+'_OnFocus();" ';
    if p_saOnKeyDown <>'' then saResult+='onkeydown="return '+p_saWidgetName+'_OnKeyDown();" ';
    if p_saOnKeypress<>'' then saResult+='onkeypress="return '+p_saWidgetName+'_OnKeypress();" ';
    if p_saOnKeyUp   <>'' then saResult+='onkeyup="return '+p_saWidgetName+'_OnKeyUp();" ';
    if p_saOnSelect  <>'' then saResult+='onselect="return '+p_saWidgetName+'_OnSelect();" ';
  end;
  saresult+=' />';
  if p_bEditMode and p_bFilterTools then
  begin
    saResult+='</td><td>'+saFilterTool_AndNot_Toggle(p_saWidgetName, p_bfilterNOT)+'</td></tr></table>';
  end;
  saResult+='</td></tr>';
  saResult+='</table>';
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[#'+p_saWidgetName+'#]',saResult);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204151554,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================















//=============================================================================
Procedure WidgetHidden(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saDefaultValue: AnsiString
);
//=============================================================================
var saResult: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='WidgetHidden'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203102709,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203102710, sTHIS_ROUTINE_NAME);{$ENDIF}

  saResult:='<input type="hidden" name="'+p_saWidgetName+'" id="'+p_saWidgetName+'" value="'+saSNRStr(p_saDefaultValue,'"','&quot;') +'" />';
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[#'+p_saWidgetName+'#]',saResult);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203102711,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
Procedure WidgetPhone(
  p_Context: TCONTEXT;
  p_saWidgetName: AnsiString;
  p_saWidgetCaption: AnsiString;
  p_saSIPURL: AnsiString;
  p_saValue: ansistring;
  p_u8MaxLen: uint64;
  p_u2Size: word;
  p_bEditMode: Boolean;
  p_bDataOnRight: Boolean;
  p_bRequired: boolean;
  p_bFilterTools: boolean;
  p_bFilterNot: boolean;
  p_saOnBlur: ansistring;
  p_saOnChange: ansistring;
  p_saOnClick: ansistring;
  p_saOnDblClick: ansistring;
  p_saOnFocus: ansistring;
  p_saOnKeyDown: ansistring;
  p_saOnKeypress: ansistring;
  p_saOnKeyUp: ansistring;
  p_saOnSelect: ansistring
);
//=============================================================================
Var
  saResult: AnsiString;
  saUP: ansistring;
  sa: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='WidgetURL'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201511132129,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201511132130, sTHIS_ROUTINE_NAME);{$ENDIF}


  //ASPrintLn('p_saWidgetName            : '+p_saWidgetName          );
  //ASPrintLn('p_saWidgetCaption         : '+p_saWidgetCaption       );
  //ASPrintLn('p_saSIPURL                : '+p_saSIPURL              );
  //ASPrintln('p_saValue                 : '+p_saValue );
  //ASPrintLn('p_saMaxLen                : '+p_saMaxLen              );
  //ASPrintLn('p_saSize                  : '+p_saSize                );
  //ASPrintLn('p_bEditMode: Boolean      : '+saTrueFalse(p_bEditMode));
  //ASPrintLn('p_bDataOnRight: Boolean   : '+saTrueFalse(p_bDataOnRight));
  //ASPrintLn('p_bRequired: boolean      : '+saTrueFalse(p_bRequired   ));
  //ASPrintLn('p_bFilterTools: boolean   : '+saTrueFalse(p_bFilterTools));
  //ASPrintLn('p_bFilterNot: boolean     : '+saTrueFalse(p_bFilterNot));
  //ASPrintLn('p_saOnBlur                : '+p_saOnBlur              );
  //ASPrintLn('p_saOnChange              : '+p_saOnChange            );
  //ASPrintLn('p_saOnClick               : '+p_saOnClick             );
  //ASPrintLn('p_saOnDblClick            : '+p_saOnDblClick          );
  //ASPrintLn('p_saOnFocus               : '+p_saOnFocus             );
  //ASPrintLn('p_saOnKeyDown             : '+p_saOnKeyDown           );
  //ASPrintLn('p_saOnKeypress            : '+p_saOnKeypress          );
  //ASPrintLn('p_saOnKeyUp               : '+p_saOnKeyUp             );
  //ASPrintLn('p_saOnSelect              : '+p_saOnSelect            );



  sa:='';
  clearnullevents(
    p_saOnBlur,
    p_saOnChange,
    p_saOnClick,
    p_saOnDblClick,
    p_saOnFocus,
    p_saOnKeyDown,
    p_saOnKeypress,
    p_saOnKeyUp
  );
  p_saOnSelect:=trim(p_saOnSelect);if p_saOnSelect='NULL' then p_saOnSelect:='';

  if not p_bFilterTools then if trim(p_saValue)='NULL' then p_saValue:='';

  saResult:='<table border="0">';
  saUP:=upcase(trim(p_saValue));
  //if (not p_bfilterTools) and (saUP<>'NULL') and (saUP<>'') then
  //begin
  //  if (saLeftStr(saUP,7)<>'HTTP://') and
  //     (saLeftStr(saUP,8)<>'HTTPS://') and
  //     (saLeftStr(saUP,6)<>'FTP://') and
  //     (saLeftStr(saUP,6)<>'TEL://') and
  //     (saLeftStr(saUP,1)<>'/') then
  //  begin
  //    p_saDefaultValue:='http://'+p_saDefaultValue;
  //  end;
  //end;

  saResult+='<tr><td>';
  If not p_bEditMode Then saResult+='<u>';
  if (not p_bfilterTools) and (saUP<>'NULL') then
  begin
    saResult+='<a href="'+p_saSIPURL+'" target="_blank" title="Dial">'+p_saWidgetCaption+'</a>';
  end
  else
  begin
    saResult+=saEncodeURI(p_saWidgetCaption);
  end;

  If not p_bEditMode Then saResult+='</u>';
  if (p_bRequired) then
  begin
    saResult+='<span name="'+p_saWidgetName+'rf" id="'+
      p_saWidgetName+'rf" >'+
      '<font color="red" style="font: strong">&nbsp;*&nbsp;</font>'+
      '</span>';
  end;
  If not p_bDataOnRight Then saResult+='</td></tr>';
  If not p_bDataOnRight Then saResult+='<tr>';
  If p_bEditMode Then
  Begin
    saResult +='<td>';

    saresult+=csCRLF+'<script language="javascript">'+csCRLF;
    if p_saOnBlur    <>'' then saResult+='function '+p_saWidgetName+'_OnBlur(){'    +csCRLF+p_saOnBlur    +csCRLF+'}'+csCRLF;
    if p_saOnChange  <>'' then saResult+='function '+p_saWidgetName+'_OnChange(){'  +csCRLF+p_saOnChange  +csCRLF+'}'+csCRLF;
    if p_saOnClick   <>'' then saResult+='function '+p_saWidgetName+'_OnClick(){'   +csCRLF+p_saOnClick   +csCRLF+'}'+csCRLF;
    if p_saOnDblClick<>'' then saResult+='function '+p_saWidgetName+'_OnDblClick(){'+csCRLF+p_saOnDblClick+csCRLF+'}'+csCRLF;
    if p_saOnFocus   <>'' then saResult+='function '+p_saWidgetName+'_OnFocus(){'   +csCRLF+p_saOnFocus   +csCRLF+'}'+csCRLF;
    if p_saOnKeyDown <>'' then saResult+='function '+p_saWidgetName+'_OnKeyDown(){' +csCRLF+p_saOnKeyDown +csCRLF+'}'+csCRLF;
    if p_saOnKeypress<>'' then saResult+='function '+p_saWidgetName+'_OnKeypress(){'+csCRLF+p_saOnKeypress+csCRLF+'}'+csCRLF;
    if p_saOnKeyUp   <>'' then saResult+='function '+p_saWidgetName+'_OnKeyUp(){'   +csCRLF+p_saOnKeyUp   +csCRLF+'}'+csCRLF;
    if p_saOnSelect  <>'' then saResult+='function '+p_saWidgetName+'_OnSelect(){'  +csCRLF+p_saOnSelect  +csCRLF+'}'+csCRLF;
    saresult+=csCRLF+'</script>'+csCRLF;

    if p_bfiltertools then saresult+='<table><tr><td>';
  End
  Else
  Begin
    saresult+='<td class="rodata" ';
    If length(trim(p_saValue))=0 Then
    Begin
      saResult +='height="20">';
    End
    Else
    Begin
      saResult+='>';
      if length(p_saValue)>40 then
      begin
        sa+=saLeftStr(p_saValue,40)+'...';
      end
      else
      begin
        sa+=p_saValue;
      end;
      saResult+='<a target="_blank" href="'+p_saSIPURL+'" title="Dial" />'+sa+'</a>';
    End;
  End;
  saResult+='<input type="';
  If p_bEditMode Then saResult+='text" ' Else saResult+='hidden" ';
  If p_u8MaxLen<>0 Then saResult+='maxlength="'+inttostr(p_u8MaxLen)+'" ';
  If p_u2Size<>0 Then saResult+='size="'+inttostr(p_u2Size)+'" ';
  saResult+='name="'+p_saWidgetName+'" id="'+p_saWidgetName+'" value="'+saSNRStr(p_saValue,'"','&quot;')+'" ';
  if p_bEditMode then
  begin
    if p_saOnBlur    <>'' then saResult+='onblur="return '+p_saWidgetName+'_OnBlur();" ';
    if p_saOnChange  <>'' then saResult+='onchange="return '+p_saWidgetName+'_OnChange();" ';
    if p_saOnClick   <>'' then saResult+='onclick="return '+p_saWidgetName+'_OnClick();" ';
    if p_saOnDblClick<>'' then saResult+='ondblclick="return '+p_saWidgetName+'_OnDblClick();" ';
    if p_saOnFocus   <>'' then saResult+='onfocus="return '+p_saWidgetName+'_OnFocus();" ';
    if p_saOnKeyDown <>'' then saResult+='onkeydown="return '+p_saWidgetName+'_OnKeyDown();" ';
    if p_saOnKeypress<>'' then saResult+='onkeypress="return '+p_saWidgetName+'_OnKeypress();" ';
    if p_saOnKeyUp   <>'' then saResult+='onkeyup="return '+p_saWidgetName+'_OnKeyUp();" ';
    if p_saOnSelect  <>'' then saResult+='onselect="return '+p_saWidgetName+'_OnSelect();" ';
  end;
  saresult+=' />';
  if p_bEditMode and p_bFilterTools then
  begin
    saResult+='</td><td>'+saFilterTool_AndNot_Toggle(p_saWidgetName, p_bfilterNOT)+'</td></tr></table>';
  end;
  saResult+='</td></tr>';
  saResult+='</table>';
  p_Context.PAGESNRXDL.AppendItem_SNRPair('[#'+p_saWidgetName+'#]',saResult);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201511132131,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
End;
//=============================================================================








//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
//=============================================================================
End.
//=============================================================================

//=============================================================================
// History (Please Insert Historic Entries at top)
//=============================================================================
// Date        Who             Notes
//=============================================================================
//=============================================================================

//*****************************************************************************
// eof
//*****************************************************************************
