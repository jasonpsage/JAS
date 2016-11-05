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
// Class for Reading and Working with Directories
//
// TODO: this thing only good for one filter at a time. Need to Fix'r Up :)
//       to allows multiples with descriptions and stuff.
//
Unit ug_jfc_dir;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfc_dir.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}
//=============================================================================


//=============================================================================
// DEBUG
//=============================================================================
{DEFINE DEBUG_JFC_DIR}
{$IFDEF DEBUG_JFC_DIR}
  {$INFO DEBUG_JFC_DIR - Diagnostic Output ENABLED!!}
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
  dos,
  sysutils,
  ug_common,
  ug_jfc_dl,
  ug_jfc_tokenizer;
//=============================================================================


//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
//Const 
//=============================================================================
  {}
  //Readonly=Readonly;//<Brings the DOS Unit value of the same name to this unit's implementation
  //hidden=hidden;//<Brings the DOS Unit value of the same name to this unit's implementation
  //sysfile=sysfile;//<Brings the DOS Unit value of the same name to this unit's implementation
  //volumeid=volumeid;//<Brings the DOS Unit value of the same name to this unit's implementation
  //directory=directory;//<Brings the DOS Unit value of the same name to this unit's implementation
  //archive=archive;//<Brings the DOS Unit value of the same name to this unit's implementation
  //anyfile=anyfile;//<Brings the DOS Unit value of the same name to this unit's implementation
//=============================================================================




//=============================================================================
{}
// Represents one Directory Entry's (TSEARCHREC) Properties
// NOTE TSEARCH Record HAS a TIMESTAMP so remember susutils TimeStampToDateTime
Type JFC_DIRENTRY = Class
//=============================================================================
  u1Attr : Byte; {attribute of found file}
  dtModified : TDateTime;{last modify date of found file}
  u8Size : UInt64; {file size of found file}
  u2Reserved : Word; {future use}
  saName : AnsiString; {name of found file}
  u8CRC: UInt64;{Optionally calculated while loading a directory if bCalcCRC
                 is set.}
End;
//=============================================================================

//=============================================================================
{}
// This is the class that is used to read directories and manipulate
// the collected data. Is can even delete entire directories (subject to file
// permissions.
Type JFC_DIR = Class(JFC_DL)
//=============================================================================
  Procedure pvt_createtask; override;
  Procedure pvt_destroytask(p_lp:pointer); override;
  Procedure AppendItem_SearchRec(p_rSearchRec: TSEARCHREC);
  Function read_item_saName: AnsiString;
  Function read_item_bReadOnly: Boolean;
  Function read_item_bHidden: Boolean;  
  Function read_item_bSysFile: Boolean; 
  Function read_item_bVolumeID: Boolean;
  Function read_item_bDir: Boolean;
  Function read_item_bArchive: Boolean;
  function read_item_u1Attr : Byte;
  function read_item_dtModified : TDateTime;
  function read_item_u8Size : UInt64;
  function read_item_u8CRC: UInt64;

  public          
  TK: JFC_TOKENIZER;
  saPath: AnsiString;//< Current Path
  bDirOnly: Boolean; //< Load Directories Only
  saFileSpec: AnsiString;
  {}              
  //saFileName: AnsiString;
  {}              
  bSort: Boolean; 
  bSortAscending: Boolean;
  bSortCaseSensitive: Boolean;
  bCalcCRC: boolean;
  bOutput: boolean;
  saLastName: ansistring;
  uMaxNestLevel: UINT;
  Constructor create;
  Destructor destroy; override;
  Procedure LoadDir;
  Procedure PreviousDir;
  function saConvertPathToWindowsFormat(p_saPath: ansistring): ansistring;
  Function FoundItem_saName(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;//< Find first matching item. This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  Function FNextItem_saName(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;//< Find Next Matching Item. This Search is Offered for convienence; the Tricky Pointer Calling convention stuff is handled for you. In short there are calls that are generic for doing binary and text searches on any data element you like but you need to handle pointers correctly to get them working. This routine that work was done for you and provided as a clean wrapper.
  function DeleteThis(p_saPath: ansistring):boolean;//<<deletes the directory contents and all the subdirectories also. YOu will want to perform a RemoveDir on the directory you emptied if you want it gone as well.
  Property Item_saName: AnsiString     read read_item_saName;
  Property Item_bReadOnly: Boolean     read read_item_bReadOnly;
  Property Item_bHidden: Boolean       read read_item_bHidden;
  Property Item_bSysFile: Boolean      read read_item_bSysFile;
  Property Item_bVolumeID: Boolean     read read_item_bVolumeID;
  Property Item_bDir: Boolean          read read_item_bDir;
  Property Item_bArchive: Boolean      read read_item_bArchive;
  Property Item_u1Attr : Byte          read read_item_u1Attr; //< attribute of found file
  Property Item_dtModified : TDateTime read read_item_dtModified;  //< last modify date of found file
  Property Item_u8Size : UInt64        read read_item_u8Size; //< file size of found file
  Property Item_u8CRC: UInt64          read read_item_u8CRC; //< Optionally calculated while loading a directory if bCalcCRC is set.
End;
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
//


//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//
// JFC_DIR Routines
//             
//*****************************************************************************
//=============================================================================
//*****************************************************************************
//=*=

//=============================================================================
Constructor JFC_DIR.create;
//=============================================================================
Begin
  Inherited;               //create(p_uSize: UINT; p_uSizePerItem: UINT);
  Tk:=JFC_TOKENIZER.create;
  TK.sQuotes:='';
  TK.sSeparators:=DOSSLASH;
  TK.sWhiteSpace:='';
  
  saPath:=FExpand('.');
  safileSpec:='*';
  bDirOnly:=False;
  //saFilename:='';
  bSort:=True;
  bSortAscending:=True;
  bSortCaseSensitive:=False;
  bCalcCRC:=false;
  bOutPut:=false;
  uMaxNestLevel:=25;
End;
//=============================================================================

//=============================================================================
Destructor JFC_DIR.Destroy;
//=============================================================================
Begin
  TK.Destroy;
  Inherited;
End;
//=============================================================================

//=============================================================================
Procedure JFC_DIR.pvt_createtask;
//=============================================================================
Begin
  Inherited;
  Item_lpPtr:=JFC_DIRENTRY.Create;
End;
//=============================================================================

//=============================================================================
Procedure JFC_DIR.pvt_destroytask(p_lp:pointer);
//=============================================================================
Begin
  JFC_DIRENTRY(JFC_DLITEM(p_lp).lpPtr).Destroy;
  Inherited;
End;
//=============================================================================

//=============================================================================
Procedure JFC_DIR.AppendItem_SearchRec(p_rSearchRec: TSEARCHREC);
//=============================================================================
Begin
  With p_rSearchRec Do Begin
    if Name<>saLAstName then
    begin
      AppendItem;
      JFC_DIRENTRY(Item_lpPTr).u1Attr      :=Attr;// {attribute of found file}

      try
        JFC_DIRENTRY(Item_lpPTr).dtModified  :=FileDateToDateTime(Time);//TimeStampToDateTime(ts);// {last modify TIMESTAMP of found file}
      except on E:EConvertError do begin
        JFC_DIRENTRY(Item_lpPTr).dtModified:=now;
      end;//except
      end;//try
      JFC_DIRENTRY(Item_lpPTr).u8Size      :=Size;// {file size of found file}
      JFC_DIRENTRY(Item_lpPTr).saName      :=Name;// AnsiString; {name of found file}
      JFC_DIRENTRY(Item_lpPtr).u8CRC       :=0;//not enough info to calc here
                                               //see LoadDir, thats where it
                                               //is calculated if bCalcCRC set
      saLastName:=Name;
    end;
  End;
End;
//=============================================================================



//=============================================================================
Procedure JFC_DIR.LoadDir;
//=============================================================================
Var
    rDirBuf: Tsearchrec;
    t:Integer;
    s: Integer;
    bFirst: boolean;
    saFile: ansistring;
    sa: ansistring;
    saLastOne:ansistring;
    bDoneHere: boolean;
    saP: ansistring;
    u8CRC: UInt64;
    uDiagCount: UINT;
    bOk:boolean;
Begin
  bOk:=true;
  if bOutput then begin writeln;writeln('BEGIN JFC_DIR.LoadDir ',saRepeatChar('=',50));end;
  DeleteAll;
  saLastName:='';
  //Sagelog(1,'LoadDIR Begin');
  //sagelog(1,'In FileSpec:'+saFilespec+
  //  ' Path:'+saPath+' bDirOnly:'+saTrueFalse(bDirOnly));

  if bOutput then writeln('Path Request >'+saPath+'<');
  //If length(saPath)=0 Then saPath:=FExpand('.');
  //else saPath:=FExpand(saPath);
  //SageLog(1,'1');


  {IFNDEF WINDOWS}
  saP:=saAddSlash(saPath);//non windows
  {ELSE}
  //saP:=saConvertPathToWindowsFormat(saPath);//modifying itself here
  {ENDIF}
  if bOutput then writeln('Path >'+saP+'<');

  //SageLog(1,'2');
  //if bOutput then riteln('NOW In FileSpec:'+saFilespec+' Path(saP):'+saP+' bDirOnly:'+saTrueFalse(bDirOnly));

  //FindFirst(saPath+'*',anyfile, rDirBuf) ;
  if bOutput then writeln('File Spec: '+saFileSpec);
  //riteln('findfirst start');
  try
    FindFirst(saP+saFileSpec,anyfile, rDirBuf) ;
  except on E:EConvertError do begin
    bOk:=false;
  end;//except
  end;//try
  //riteln('findfirst done bOk: ', sYesNo(bOk));

  if bOk then
  begin
    //SageLog(1,'3');
    bFirst:=true;saLastOne:='';
    bDoneHere:= not true;    // <<----- LOL
    repeat
      u8CRC:=0;
      if not bFirst then
      begin
        //riteln('findnext top');
        FindNext(rDirBuf);
        //riteln('findnext done');
      end
      else
      begin
        bFirst:=false;
      end;
    
      bDoneHere:=rDirBuf.name=saLastOne;
      if not bDoneHere then
      begin
        saLastOne:=rDirBuf.name;
        //rite('rDirBuf:' +rDirBuf.name);
        if bOutput or bCalcCRC then // calccrc passes thru to get a good saFile
        begin                       // Value :)
          //riteln('before safile set');
          saFile:=saAddSlash(saP)+rDirBuf.Name;
          //riteln('end safile set');

          //riteln('calc crc - start');
          if bCalcCRC then u8CRC:=u8GetCRC64(saFile);
          //riteln('calc crc - past');



          if bOutput then
          begin
            sa:='';//'DirOnly:'+saYesNo(bDirOnly)+csCRLF;
            if (rDirBuf.attr and directory)=directory then sa+='D' else sa+='-';
            if (rDirBuf.attr and readonly )=readonly  then sa+='R' else sa+='-';
            if (rDirBuf.attr and hidden   )=hidden    then sa+='H' else sa+='-';
            if (rDirBuf.attr and sysfile  )=sysfile   then sa+='S' else sa+='-';
            if (rDirBuf.attr and volumeid )=volumeid  then sa+='V' else sa+='-';
            if (rDirBuf.attr and archive  )=archive   then sa+='A' else sa+='-';
          end;
          if bCalcCRC then if bOutput then sa+=' '+inttostr(u8CRC) else sa+=' 0';
          if bOutput then
          begin
            sa+=' "'+safile+'"';
            if ((rDirBuf.attr and directory)=directory) and
               ((rDirBuf.name<>'.') and
               (rDirBuf.name<>'..') and (saPath<>DOSSLASH))Then  writeln(sa);
          end;
        end;
    
    
        If ((rDirBuf.attr and directory) = directory)  then
        begin
          if ((ListCount=0) OR (JFC_DIRENTRY(Item_lpPtr).saName<>rDirBuf.Name)) and
             (rDirBuf.Name<>DOSSLASH) and (rDirBuf.Name<>'.') Then
          Begin
            //riteln('ug_jfc_dir A - rDirBuf.name: >',rdirbuf.name,'<');
            AppendItem_SearchRec(rDirBuf);
          End
        end
        else
        begin
          If not bDirOnly Then
          begin
            //riteln('ug_jfc_dir B - rDirBuf.name: >',rdirbuf.name,'<');
            AppendItem_SearchRec(rDirBuf);
            if bCalcCRC then
            begin
    
              //circular reference doing u8GetCRC64(saFile); call in ug_jegas.pp
              // this - ok - redundandt call? MAYBE - maybe and include which
              // is like a C++ TEMPLATE in a way: one source file, used to
              // generate code in two different places
              // OR BETTER STILL - see if Ican just move the routine's SCOPE!!!
              if u8CRC=0 then u8CRC:=u8GetCRC64(saFile);
              JFC_DIRENTRY(lpItem).u8CRC:=u8CRC;
            end;
          end;
        end;
      end;
    until (DosError<>0) or (bDoneHere);
  end;

  //riteln('findclose - before. bOk is '+sYesNo(bOk)+' btw...what..just saying!');
  try
    FindClose(rDirBuf);
  except on E:Exception do begin
    bOk:=false;
  end;//except
  end;//try
  //riteln('findclose - past it. bOk is now '+sYesNo(bOk));


  if bOk then
  begin
    //riteln('Loaded Directories - ListCount:'+inttostr(listcount));
    //riteln('Loaded Files ListCount:'+inttostr(listcount));
    //riteln('About to Sort - bSortCaseSensitive:' +  saTrueFalse(bSortCaseSensitive));
    //riteln('About to Sort - bSortAscending:' +  saTrueFalse(bSortAscending));
    If listcount>1 Then Begin
      If bSort Then Begin
        // SORT EVERYTHING
        If bSortCaseSensitive Then Begin
          If bSortAscending Then Begin
            For t:=1 To ListCount Do Begin
              MoveFirst;
              For s:=1 To ListCount-1 Do Begin
                If JFC_DIRENTRY(Item_lpPtr).saName>
                   JFC_DIRENTRY(JFC_DLITEM(Next_lpITem).lpPtr).saName Then Begin
                  SwapItem_lpPtr(lpItem, Next_lpItem);
                  //s+=2;
                End;
                MoveNext;
              End;
            End;
          End Else Begin
            // SORT EVERYTHING
            For t:=1 To ListCount Do Begin
              MoveFirst;
              For s:=1 To ListCount-1 Do Begin
                If JFC_DIRENTRY(Item_lpPtr).saName<
                   JFC_DIRENTRY(JFC_DLITEM(Next_lpITem).lpPtr).saName Then Begin
                  SwapItem_lpPtr(lpItem, Next_lpItem);
                  //s+=2;
                End;
                MoveNext;
              End;
            End;
          End;
        End Else Begin
          If bSortAscending Then Begin
            For t:=1 To ListCount Do Begin
              MoveFirst;
              For s:=1 To ListCount-1 Do Begin
                If UPCASE(JFC_DIRENTRY(Item_lpPtr).saName)>
                   UPCASE(JFC_DIRENTRY(JFC_DLITEM(Next_lpITem).lpPtr).saName) Then Begin
                  SwapItem_lpPtr(lpItem, Next_lpItem);
                  //s+=2;
                End;
                MoveNext;
              End;
            End;
          End Else Begin
            // SORT EVERYTHING
            For t:=1 To ListCount Do Begin
              MoveFirst;
              For s:=1 To ListCount-1 Do Begin
                If UPCASE(JFC_DIRENTRY(Item_lpPtr).saName)<
                   UPCASE(JFC_DIRENTRY(JFC_DLITEM(Next_lpITem).lpPtr).saName) Then Begin
                  SwapItem_lpPtr(lpItem, Next_lpItem);
                  //s+=2;
                End;
                MoveNext;
              End;
            End;
          End;
        End;
    
        // Sort Directories (Put First)
        For t:=1 To ListCount Do Begin
          MoveFirst;
          For s:=1 To ListCount-1 Do Begin
            If ((JFC_DIRENTRY(Item_lpPtr).u1Attr and Directory)<>directory) and
               ((JFC_DIRENTRY(JFC_DLITEM(Next_lpITem).lpPtr).u1Attr and Directory)=directory) Then Begin
              SwapItem_lpPtr(lpItem, Next_lpItem);
              //s+=2;
            End;
            MoveNext;
          End;
        End;
      End;
    End;
    
    uDiagCount:=0;
    if Movefirst then repeat uDiagCount+=1; until not MoveNext;
    Movefirst;
  end;

  //Sagelog(1,'LoadDIR End');
  if bOutput then writeln('END  jfc_dir.loaddir',saRepeatChar('=',50));
End;
//=============================================================================



//=============================================================================
function JFC_DIR.saConvertPathToWindowsFormat(p_saPath: ansistring): ansistring;
//=============================================================================
var saP: ansistring;
    //saP2: ansistring;
    sa: ansistring;
    iPos: INT;
    //iPos2: INT;
begin
  //    /c/files
  {$IFDEF DEBUG_JFC_DIR}
    writeln('BEGIN =-=-=-=-=-=-=-=-=-=-=- Windows Path Conversion ==-=-=-=-=-=-=-=-=');
    writeln('A: p_saPath: >',p_saPath,'<');
  {$ENDIF}

  saP:=saSNRStr(p_saPath,'/','\');
  //saP2:='';
  if (saP<>'.') and (LeftStr(saP,2)<>'..') then
  begin
    {$IFDEF DEBUG_JFC_DIR}writeln('B: saP: >',saP,'<');{$ENDIF}
    if length(saP)>0 then
    begin
      //    \c\files
      {$IFDEF DEBUG_JFC_DIR}writeln('C: saP: >',saP,'<');{$ENDIF}
      if saP[1]='\' then saP:=rightstr(saP,length(saP)-1);
      //    c\files
    
      //   c\files
      iPos:=Pos('\',saP);
      {$IFDEF DEBUG_JFC_DIR}writeln('D: saP: >',saP,'<  iPos: ',ipos);{$ENDIF}
      if iPos=0 then
      begin
        // cfiles
        saP+=':\';
        // cfiles:\
        {$IFDEF DEBUG_JFC_DIR}writeln('E: saP: >',saP,'<  iPos: ',ipos);{$ENDIF}
      end
      else
      begin
        //   c\files\
        {$IFDEF DEBUG_JFC_DIR}writeln('F: saP: >',saP,'<  iPos: ',ipos);{$ENDIF}
        if Pos(':',saP)=0 then
        begin
          {$IFDEF DEBUG_JFC_DIR}writeln('partF-1 - hit');{$ENDIF}
          iPos:=Pos('\',saP);//2
          sa:=leftstr(saP,iPos-1)+':' + RightStr(saP,length(saP)-iPos+1);
          saP:=sa;
        end;
    
    
        if Pos(':',saP)=0 then
        begin
         {$IFDEF DEBUG_JFC_DIR}writeln('partF-2 - hit');{$ENDIF}
         //saP2:=leftstr(saP,iPos-1);
        end
        else
        begin
         {$IFDEF DEBUG_JFC_DIR}writeln('partF-3 - hit');{$ENDIF}
          //saP2:=leftstr(saP,iPos);
        end;
    
    
        {$IFDEF DEBUG_JFC_DIR}writeln('G: saP: >',saP,'<  iPos: ',ipos);{$ENDIF}
    
        //saP c\src\   saP2 c:
        //iPos2:=pos(':',saP);
        //if iPos2=0 then saP:=saP2+rightstr(saP,length(saP)-iPos+1);
    
        //   c:\files
        {$IFDEF DEBUG_JFC_DIR}writeln('H: saP: >',saP,'<');{$ENDIF}
      end;
    end;
  end;
  If (saP<>'.') and (length(saP)>0) and (saP[length(saP)]<>'\') Then
  begin
    saP+='\';
  end;
  {$IFDEF DEBUG_JFC_DIR}writeln('I: saP: >',saP,'<');{$ENDIF}

  {$IFDEF DEBUG_JFC_DIR}Writeln('END   =-=-=-=-=-=-=-=-=-=-=- Windows Path Conversion ==-=-=-=-=-=-=-=-=');{$ENDIF}
  result:=saP;
end;
//=============================================================================


//=============================================================================
Function JFC_DIR.FoundItem_saName(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;
//=============================================================================
Begin
  Result:=FoundAnsiString(p_sa,
                           p_bCaseSensitive,
                           @JFC_DIRENTRY(nil).saName,
                           True,False);
End;
//=============================================================================

//=============================================================================
Function JFC_DIR.FNextItem_saName(p_sa:AnsiString;p_bCaseSensitive:Boolean):Boolean;
//=============================================================================
Begin
  Result:=FoundAnsiString(p_sa,
                           p_bCaseSensitive,
                           @JFC_DIRENTRY(nil).saName,
                           False,False);
End;
//=============================================================================






















//=============================================================================
Procedure JFC_DIR.PreviousDir;
//=============================================================================
Var u:uInt;
Begin
  TK.Tokenize(saPath);
  //TK.DumpToTextFile('debug_previousdir.txt');
  If (tk.tokens>1) and (uItems>0) and
     (JFC_DIRENTRY(Item_lpPtr).saName='..') Then Begin  
    // Goto previous Directory
    saPath:='';
    For u:=1 To tk.tokens-2 Do
    Begin
      saPath:=saPath+TK.NthItem_saToken(u);
    End;
    {$IFDEF Windows}
    If sapath[length(saPath)]<>DOSSLASH Then saPath:=saPAth+DOSSLASH;
    {$ENDIF}
    //SageLog(1,'u03g_JFC_dir PATH before Loaddir in previous:'+saPAth);
    LoadDir;
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_DIR.read_item_saName: AnsiString;
//=============================================================================
Begin
  Result:=JFC_DIRENTRY(Item_lpPtr).saName;
End;
//=============================================================================

//=============================================================================
Function JFC_DIR.read_item_bDir: Boolean;
//=============================================================================
Begin
  Result:=(JFC_DIRENTRY(Item_lpPtr).u1Attr and directory)=directory;
End;
//=============================================================================

//=============================================================================
Function JFC_DIR.read_item_bReadOnly: Boolean;
//=============================================================================
Begin
  Result:=(JFC_DIRENTRY(Item_lpPtr).u1Attr and Readonly)=Readonly;
End;
//=============================================================================

//=============================================================================
Function JFC_DIR.read_item_bHidden: Boolean;  
//=============================================================================
Begin
  Result:=(JFC_DIRENTRY(Item_lpPtr).u1Attr and hidden)=hidden;
End;
//=============================================================================

//=============================================================================
Function JFC_DIR.read_item_bSysFile: Boolean; 
//=============================================================================
Begin
  Result:=(JFC_DIRENTRY(Item_lpPtr).u1Attr and sysfile)=sysfile;
End;
//=============================================================================

//=============================================================================
Function JFC_DIR.read_item_bVolumeID: Boolean;
//=============================================================================
Begin
  Result:=(JFC_DIRENTRY(Item_lpPtr).u1Attr and volumeid)=volumeid;
End;
//=============================================================================

//=============================================================================
Function JFC_DIR.read_item_bArchive: Boolean; 
//=============================================================================
Begin
  Result:=(JFC_DIRENTRY(Item_lpPtr).u1Attr and archive)=archive;
End;
//=============================================================================

//=============================================================================
function JFC_DIR.read_item_u1Attr : Byte;
//=============================================================================
begin
  Result:=JFC_DIRENTRY(Item_lpPtr).u1Attr;
end;
//=============================================================================

//=============================================================================
function JFC_DIR.read_item_dtModified : TDateTime;
//=============================================================================
begin
  Result:=JFC_DIRENTRY(Item_lpPtr).dtModified;
end;
//=============================================================================

//=============================================================================
function JFC_DIR.read_item_u8Size : UInt64;
//=============================================================================
begin
 Result:=JFC_DIRENTRY(Item_lpPtr).u8Size;
end;
//=============================================================================

//=============================================================================
function JFC_DIR.read_item_u8CRC: UInt64;
//=============================================================================
begin
  Result:=JFC_DIRENTRY(Item_lpPtr).u8CRC;
end;
//=============================================================================










var uNestLevel: UINT;
//=============================================================================
function JFC_DIR.DeleteThis(p_saPath: ansistring):boolean;//<<deletes the directory and its contents.
//=============================================================================
   //--------------------------------------------------------------------------
   function bDive(p_saPath: ansistring):boolean;
   //--------------------------------------------------------------------------
   var DR: JFC_DIR;
   begin
     uNestLevel+=1;
     result:=true;
     DR:=JFC_DIR.Create;
     DR.saPath:=p_saPath;
     DR.LoadDir;
     if DR.MoveFirst then
     begin
       repeat
         //riteln('Path: ',p_saPath,' Dir: ',sYesNo(DR.Item_bDir),' ',DR.Item_saName);
         //eadln;
         if DR.Item_bDir then
         begin
           if (DR.Item_saName<>'.') and (DR.Item_saName<>'..') then
           begin
             if uMaxNestLevel>uNestLevel then
             begin
               result:=bDive(saAddSlash(p_saPath) + DR.Item_saName);
               if result then
               begin
                 result:=removedir(saAddSlash(p_saPath) + DR.Item_saName);
                 //riteln('Result: ', syesno(result),' Remove Dir: '+ saAddSlash(p_saPath) + DR.Item_saName);
               end;// else riteln('Dive Failed: '+saAddSlash(p_saPath) + DR.Item_saName);
             end;
           end;
         end
         else
         begin
           try
             DeleteFile(saAddSlash(p_sapath)+DR.Item_saName);
           except on e:Exception do begin
             {riteln('Delete file failed: '+saAddSlash(p_sapath)+DR.Item_saName);}
             result:=false;
           end;
           end;//try
         end;
       until not DR.MoveNext;
     end;
     DR.Destroy;DR:=nil;
     uNestLevel-=1;
   end;
   //--------------------------------------------------------------------------


//-----------------------------------------------------------------------------
begin
//-----------------------------------------------------------------------------
  result:=bDive(p_saPath);
  //if result then result:=removedir(p_saPath); Let user do this step - this way they can just enpty a directory
//-----------------------------------------------------------------------------
end;
//=============================================================================












//=============================================================================
// Initialization
//=============================================================================
Begin
//=============================================================================
  
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
