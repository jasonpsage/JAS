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
Const 
//=============================================================================
  {}
  Readonly=Readonly;//<Brings the DOS Unit value of the same name to this unit's implementation
  hidden=hidden;//<Brings the DOS Unit value of the same name to this unit's implementation
  sysfile=sysfile;//<Brings the DOS Unit value of the same name to this unit's implementation
  volumeid=volumeid;//<Brings the DOS Unit value of the same name to this unit's implementation
  directory=directory;//<Brings the DOS Unit value of the same name to this unit's implementation
  archive=archive;//<Brings the DOS Unit value of the same name to this unit's implementation
  anyfile=anyfile;//<Brings the DOS Unit value of the same name to this unit's implementation
//=============================================================================




//=============================================================================
{}
// Represents one Directory Entry's Properties
Type JFC_DIRENTRY = Class
//=============================================================================
  u1Attr : Byte; {attribute of found file}
  i4Time : LongInt; {last modify date of found file}
  i4Size : LongInt; {file size of found file}
  u2Reserved : Word; {future use}
  saName : AnsiString; {name of found file}
  saSearchSpec: AnsiString; {search pattern}
  u2NamePos: Word; {end of path, start of name position}

  {$IFDEF LINUX}
  i4SearchNum: LongInt; {to track which search this is}
  i4SearchPos: LongInt; {directory position}
  lpDirPtr: Pointer; {directory pointer for reading directory}
  u1SearchType: Byte; {0=normal, 1=open will close}
  u1SearchAttr: Byte; {attribute we are searching for}
  {$ENDIF}
End;
//=============================================================================

//=============================================================================
{}
// This is the class that is used to read directories and manipulate
// the collected data.
Type JFC_DIR = Class(JFC_DL)
//=============================================================================
  Procedure pvt_createtask; override; 
  Procedure pvt_destroytask(p_lp:pointer); override;
  Procedure AppendItem_SearchRec(p_rSearchRec: SEARCHREC);

  Function read_item_saName: AnsiString;
  Function read_item_bReadOnly: Boolean;
  Function read_item_bHidden: Boolean;  
  Function read_item_bSysFile: Boolean; 
  Function read_item_bVolumeID: Boolean;
  Function read_item_bDir: Boolean;
  Function read_item_bArchive: Boolean; 

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
  saLastName: ansistring;
  Constructor create;
  Destructor destroy; override;
  Procedure LoadDir;
  Procedure PreviousDir;

  Property Item_saName: AnsiString read read_item_saName;
  Property Item_bReadOnly: Boolean read read_item_bReadOnly;
  Property Item_bHidden: Boolean   read read_item_bHidden;
  Property Item_bSysFile: Boolean  read read_item_bSysFile;
  Property Item_bVolumeID: Boolean read read_item_bVolumeID;
  Property Item_bDir: Boolean      read read_item_bDir;
  Property Item_bArchive: Boolean  read read_item_bArchive;
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
  Inherited;
  Tk:=JFC_TOKENIZER.create;
  TK.saQuotes:='';
  TK.saSeparators:=csDOSSLASH;
  TK.saWhiteSpace:='';
  
  saPath:=FExpand('.');
  safileSpec:='*';
  bDirOnly:=False;
  //saFilename:='';
  bSort:=True;
  bSortAscending:=True;
  bSortCaseSensitive:=False;
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
Procedure JFC_DIR.AppendItem_SearchRec(p_rSearchRec: SEARCHREC);
//=============================================================================
Begin
  

  With p_rSearchRec Do Begin
    if Name<>saLAstName then
    begin
      AppendItem;

      JFC_DIRENTRY(Item_lpPTr).u1Attr      :=Attr;// Byte; {attribute of found file}
      JFC_DIRENTRY(Item_lpPTr).i4Time      :=Time;// LongInt; {last modify date of found file}
      JFC_DIRENTRY(Item_lpPTr).i4Size      :=Size;// LongInt; {file size of found file}
      //u2Reserved : Word; {future use}
      JFC_DIRENTRY(Item_lpPTr).saName      :=Name;// AnsiString; {name of found file}
      //Supposed to exist! //JFC_DIRENTRY(Item_lpPTr).saSearchSpec:=SearchSpec;// AnsiString; {search pattern}
      //Supposed to Exist! //JFC_DIRENTRY(Item_lpPTr).u2NamePos   :=NamePos;// Word; {end of path, start of name position}

      {$IFDEF LINUX}
      JFC_DIRENTRY(Item_lpPtr).i4SearchNum :=SearchNum;// LongInt; {to track which search this is}
      JFC_DIRENTRY(Item_lpPtr).i4SearchPos :=SearchPos;// LongInt; {directory position}
      JFC_DIRENTRY(Item_lpPtr).lpDirPtr    :=DirPtr;// Pointer; {directory pointer for reading directory}
      JFC_DIRENTRY(Item_lpPtr).u1SearchType:=SearchType;// Byte; {0=normal, 1=open will close}
      JFC_DIRENTRY(Item_lpPtr).u1SearchAttr:=SearchAttr;// Byte; {attribute we are searching for}
      {$ENDIF}
      saLastName:=Name;
    end;
  End;
End;
//=============================================================================

//=============================================================================
Procedure JFC_DIR.LoadDir;
//=============================================================================
Var rDirBuf: searchrec;
    t:Integer;
    s: Integer;
    bFirst: boolean;
Begin
  DeleteAll;
  saLastName:='';
  //Sagelog(1,'LoadDIR Begin');
  //sagelog(1,'In FileSpec:'+saFilespec+
  //  ' Path:'+saPath+' bDirOnly:'+saTrueFalse(bDirOnly));
  
  If length(saPath)=0 Then saPath:=FExpand('.');
  //else saPath:=FExpand(saPath);
  //SageLog(1,'1');
  If (length(saPath)>0) and (saPath[length(saPath)]<>csDOSSLASH) Then
    saPath:=saPath+csDOSSLASH;
  //SageLog(1,'2');

  //sagelog(1,'NOW In FileSpec:'+saFilespec+
  //  ' Path:'+saPath+' bDirOnly:'+saTrueFalse(bDirOnly));
  

  //FindFirst(saPath+'*',anyfile, rDirBuf) ;
  FindFirst(saPath+saFileSpec,anyfile, rDirBuf) ;

  //SageLog(1,'3');
  bFirst:=true;
  repeat 
    //sagelog(1,'finding ...');
    if not bFirst then
    begin
      FindNext(rDirBuf);
    end
    else
    begin
      bFirst:=false;
    end;
    If ((rDirBuf.attr and directory) = directory)  then
    begin
      if ((ListCount=0) OR (JFC_DIRENTRY(Item_lpPtr).saName<>rDirBuf.Name)) and
         (rDirBuf.name<>'.') and
         ((rDirBuf.name<>'..') OR (saPath<>csDOSSLASH))
      Then
      Begin
        AppendItem_SearchRec(rDirBuf);
      End
    end
    else
    begin
      If not bDirOnly Then
      begin
        AppendItem_SearchRec(rDirBuf);
      end;
    end;
  until (DosError<>0);
  FindClose(rDirBuf);

  //Sagelog(1,'Loaded Directories - ListCount:'+inttostr(listcount));
  //SageLog(1,'Loaded Files ListCount:'+inttostr(listcount));
  //SageLog(1,'About to Sort - bSortCaseSensitive:' +  saTrueFalse(bSortCaseSensitive));
  //SageLog(1,'About to Sort - bSortAscending:' +  saTrueFalse(bSortAscending));
  
  
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
  //Sagelog(1,'LoadDIR End');
End;
//=============================================================================

//=============================================================================
Procedure JFC_DIR.PreviousDir;
//=============================================================================
Var t:LongInt;
Begin
  TK.Tokenize(saPath);
  //TK.DumpToTextFile('debug_previousdir.txt');
  If (tk.tokens>1) and (iItems>0) and 
     (JFC_DIRENTRY(Item_lpPtr).saName='..') Then Begin  
    // Goto previous Directory
    saPath:='';
    For t:=1 To tk.tokens-2 Do
    Begin
      saPath:=saPath+TK.NthItem_saToken(t);   
    End;
    {$IFDEF Win32}
    If sapath[length(saPath)]<>csDOSSLASH Then saPath:=saPAth+csDOSSLASH;
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
