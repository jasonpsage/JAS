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
// Purpose : A Speedy way to work with Arrays of AnsiString    
// Note: Comments about thread safe and thread lucky pertain   
// to the ability to have multiple threads access one MATRIX   
// without locking semantics of any kind. If Matrix are loaded 
// in a single thread, and then used in a read only way by     
// multiple threads, the result is SUPER fast data retrieval   
// Note Columns and Rows are ONE BASED in the functions that 
// allow you to set and access data! COLUMN 1 and ROW 1 are the firsts of 
// each respective axis.
Unit ug_jfc_matrix;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jfc_matrix.pp'}
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
sysutils,
ug_common,
ug_jfc_dl;
//=============================================================================





//*****************************************************************************
//INTERFACE====================================================================
//*****************************************************************************
// !@!JFC_MATRIX
//*****************************************************************************
{}
// NOTE: thread Safety Comments are based on using a master MATRIX as a memory
// based table or array, and having the threads do operations on the class.
// The best way to use this thing - is for data tables you want in memory,
// you build them - then threads just look up values. In that way - this thing
// is thread safe if used like that. Note: Make Sure that the Matrix is 
// Established, contains all data it's going to FIRST... Then allow threads
// to query it. :)
Type JFC_MATRIX = Class(JFC_DLITEM)
  // This is reference to the original MATRIX in case this is a copy class.
  // The copied class has a limited subset of functions to preserve the 
  // integrity of the parent. Unlike the JFC_DL, JFC_XDL, and JFC_XXDL base 
  // classes, we don't just set up a "cursor" to examine the data because the
  // MATRIX class has an array of strings versus a list of pointers that
  // can unobtrusively be "looked at". So what we do in copied versions of the 
  // class is use the parent class (the original) but in a readonly manner
  // as to not put a wrench in the works.
  // Note: Touches on my topic of "Thread Lucky" versus Thread safe.
  // (Living on the edge of "unmanaged" code)
  OrigMTX: JFC_MATRIX;
  
  // Current number of columns
  iCols: Integer;
  // Current number of rows
  iRows: Integer;
  // Current Record position or row
  iNth: Integer;
  // The Raw dynamic Array where the column names are kept
  asaColumns: array Of AnsiString;
  // The Raw dynamic Array where all the matrix data is stored
  asaMatrix: array Of AnsiString;
  // creates instance of the JFC_MATRIX class
  Constructor create; 
  
  // This creates an instance of the JFC_MATRIX class but it creates a 
  // "Copy" of another JFC_MATRIX class which doesn't house it's own data 
  // to save resources. 
  // Instead it keeps it's own current row value but all seeks and finds are 
  // performed on the data in the original. For this reason, you should have 
  // the original JFC_MATRIX instantiated FIRST, then make a copy. 
  // You must do the reverse to remove these: Destroy the COPY FIRST, 
  // then DESTROY the original. This is also how the JFC_DL, JFC_XDL and 
  // JFC_XXDL classes all work. The idea is to have multiple LIKE classes 
  // access ONE dataset; but this incurs dependance on the existance of the 
  // other classes remaining intact for the life of the "copies".
  Constructor createCopy(p_MTX: JFC_MATRIX); 

  // Destroys the JFC_MATRIX class, and the data if it's not a "copy" instance.
  Destructor destroy; override;
  
  // Appends a row to the matrix 
  // - Not thread safe meaning you can't have separate
  // threads appending items to the same instance of this class and not expect 
  // problems.
  Procedure AppendItem;inline;
  // Appends a name value pair to a matrix with 2 or more columns 
  // p_saName - name value (column 1)
  // p_saValue - value value (column 2)
  // - Not thread safe 
  // meaning you can't have separate threads appending items to the same instance 
  // of this class and not expect problems.
  procedure AppendItem_saName_N_saValue(p_saName: ansistring; p_saValue: ansistring);
  // Appends a name,value, and desc fields to a matrix with 3 or more columns 
  // p_saName - name value (column 1)
  // p_saValue - value value (column 2)
  // p_saDesc - desc value (column 3)
  //
  // - Not thread safe 
  // meaning you can't have separate threads appending items to the same instance 
  // of this class and not expect problems.
  procedure AppendItem_MATRIX(p_saName: ansistring; p_saValue: ansistring; p_saDesc: ansistring);
  // Searches for value in first column (aka name column). 
  // p_sa = name sought
  // p_bCaseSensitive = pass true for case sensitive search
  //
  // - Not thread safe meaning you can't have separate
  // threads appending items to the same instance of this class and not expect 
  // problems.
  function FoundItem_saName(p_sa: ansistring; p_bCaseSensitive: boolean):boolean;
  // Searches for value in second column (aka value column). 
  // p_sa = value sought
  // p_bCaseSensitive = pass true for case sensitive search
  //
  // - Not thread safe meaning you can't have separate
  // threads appending items to the same instance of this class and not expect 
  // problems.
  function FoundItem_saValue(p_sa: ansistring; p_bCaseSensitive: boolean):boolean;
  // Searches for value in third column (aka Desc column). 
  // p_sa = desc sought
  // p_bCaseSensitive = pass true for case sensitive search
  //
  // - Not thread safe meaning you can't have separate
  // threads appending items to the same instance of this class and not expect 
  // problems.
  function FoundItem_saDesc(p_sa: ansistring; p_bCaseSensitive: boolean):boolean;

  // Private Property Access Fields - you can't rely on these being available...
  // one day I might just make them private and BANG your code won't compile! 
  // <evil laughing from over tired programmer... hahahhaha >
  function read_item_saName: ansistring;
  // Private Property Access Fields - you can't rely on these being available...
  // one day I might just make them private and BANG your code won't compile! 
  // <evil laughing from over tired programmer... hahahhaha >
  procedure write_item_saName(p_sa: Ansistring);
  // Private Property Access Fields - you can't rely on these being available...
  // one day I might just make them private and BANG your code won't compile! 
  // <evil laughing from over tired programmer... hahahhaha >
  function read_item_saValue: ansistring;
  // Private Property Access Fields - you can't rely on these being available...
  // one day I might just make them private and BANG your code won't compile! 
  // <evil laughing from over tired programmer... hahahhaha >
  procedure write_item_saValue(p_sa: Ansistring);
  // Private Property Access Fields - you can't rely on these being available...
  // one day I might just make them private and BANG your code won't compile! 
  // <evil laughing from over tired programmer... hahahhaha >
  function read_item_saDesc: ansistring;
  // Private Property Access Fields - you can't rely on these being available...
  // one day I might just make them private and BANG your code won't compile! 
  // <evil laughing from over tired programmer... hahahhaha >
  procedure write_item_saDesc(p_sa: Ansistring);
  
  // Returns or sets value in column1 aka the Name column in the current row
  property Item_saName: ansistring read read_item_saName write write_item_saName;
  // Returns or sets value in column2 aka the Value column in the current row
  property Item_saValue: ansistring read read_item_saValue write write_item_saValue;
  // Returns or sets value in column3 aka the Desc column in the current row
  property Item_saDesc: ansistring read read_item_saDesc write write_item_saDesc;

  // Returns number of rows
  property ListCount: integer read iRows;

  // returns VALUE (col2) for the row matching the Name passed in p_sa (column1)
  // not case sensistive
  function Get_saValue(p_sa: ansistring): ansistring;
  
  // Moves to First row - returns false if not successful
  //
  // - Not thread safe meaning you can't have separate
  // threads appending items to the same instance of this class and not expect 
  // problems.
  Function MoveFirst:Boolean;inline;
  // Moves to last row - returns false if not successful
  //
  // - Not thread safe meaning you can't have separate
  // threads appending items to the same instance of this class and not expect 
  // problems.
  Function MoveLast:Boolean;inline;
  // moves to Previous row - returns false if not successful
  //
  // - Not thread safe meaning you can't have separate
  // threads appending items to the same instance of this class and not expect 
  // problems.
  Function MovePrevious: Boolean;//inline
  // moves to next row. returns false if not successful
  //
  // - Not thread safe meaning you can't have separate
  // threads appending items to the same instance of this class and not expect 
  // problems.
  Function MoveNext: Boolean;//inline
  
  // Sets the number of columns for the matrix. This is destructive to 
  // all data, but preserves columns names when expanding the number of 
  // columns. 
  //
  // - Not thread safe meaning you can't have separate
  // threads appending items to the same instance of this class and not expect 
  // problems.
  Procedure SetNoOfColumns(p_iCols: Integer);
  
  // Returns column name identified by number passed in p_iCol
  //
  // thread lucky - which means if multiple threads hit this routine, we've 
  // yet to see an issue even though there is no specific thread handling
  // code. The reason this works is because we are access the data in a readonly
  // manner so it's use is unintrusive yet technically some purists would argue
  // that it's possible to get data in an unpure state... such as getting half
  // a string right because we snagged it while it was being written to. Well...
  // I don't disagree but the whole purpose of this class is for fast lookups
  // to data, not for adding and removing data alot... so... in our multi-threaded 
  // applications - we load this class up - and then just read from it without
  // issue - so... we insist - this is thread lucky! :)
  Function Get_saColName(p_iCol: Integer): AnsiString;
  
  // Returns data in specific row and column
  //
  // thread lucky - which means if multiple threads hit this routine, we've 
  // yet to see an issue even though there is no specific thread handling
  // code. The reason this works is because we are access the data in a readonly
  // manner so it's use is unintrusive yet technically some purists would argue
  // that it's possible to get data in an unpure state... such as getting half
  // a string right because we snagged it while it was being written to. Well...
  // I don't disagree but the whole purpose of this class is for fast lookups
  // to data, not for adding and removing data alot... so... in our multi-threaded 
  // applications - we load this class up - and then just read from it without
  // issue - so... we insist - this is thread lucky! :)
  Function Get_saMatrix(p_iCol: Integer; p_iRow: Integer): AnsiString;
  
  // Returns Data in specified row for current (iNth) row.
  // Thread - lucky :)
  function Get_saMatrix(p_iCol: Integer): AnsiString;
  
  // Returns Data from SPECIFIC INDEX into the MATRIX Array.
  // this function handles the logic for getting data from MAIN or COPY versions
  // of JFC_MATRIX
  Function Get_saElement(p_ix: Integer): AnsiString;inline;

  
  // Sets data in specified row and column with data passed in p_saValue 
  // Not threadsafe. High collision probability
  Procedure Set_Matrix(p_iCol: Integer; p_iRow: Integer; p_saValue: AnsiString);inline;
  
  // Sets data in specified column in current row with data passed in p_saValue
  // Not threadsafe. High collision probability
  Procedure Set_Matrix(p_iCol: Integer; p_saValue: AnsiString);inline;

  // Returns INDEX in to the Array where the value was found (with regards to the case sensitivity flag)
  // in the specified column matching value passed (what is being sought) in p_saCriteria
  // -1 result means NOT FOUND
  //
  // thread lucky - which means if multiple threads hit this routine, we've 
  // yet to see an issue even though there is no specific thread handling
  // code. The reason this works is because we are access the data in a readonly
  // manner so it's use is unintrusive yet technically some purists would argue
  // that it's possible to get data in an unpure state... such as getting half
  // a string right because we snagged it while it was being written to. Well...
  // I don't disagree but the whole purpose of this class is for fast lookups
  // to data, not for adding and removing data alot... so... in our multi-threaded 
  // applications - we load this class up - and then just read from it without
  // issue - so... we insist - this is thread lucky! :)
  Function iFoundItem(p_iCol: Integer; p_saCriteria: AnsiString; p_bCaseSensitive: Boolean): Integer;inline;

  
  // Returns INDEX into the Array for the next row that the value was found 
  // (with regards to the case sensitiveity flag) in the specified column matching 
  // value passed (what is being sought) in p_saCriteria
  // -1 result means NOT FOUND or bad column requested
  //
  // thread lucky - which means if multiple threads hit this routine, we've 
  // yet to see an issue even though there is no specific thread handling
  // code. The reason this works is because we are access the data in a readonly
  // manner so it's use is unintrusive yet technically some purists would argue
  // that it's possible to get data in an unpure state... such as getting half
  // a string right because we snagged it while it was being written to. Well...
  // I don't disagree but the whole purpose of this class is for fast lookups
  // to data, not for adding and removing data alot... so... in our multi-threaded 
  // applications - we load this class up - and then just read from it without
  // issue - so... we insist - this is thread lucky! :)
  Function iFoundNext(p_iCol: Integer; p_saCriteria: AnsiString; p_bCaseSensitive: Boolean; p_iCurrentRow: Integer): Integer;

  // Returns index for data element in the array.
  // -1 result means invalid request (bad column and/or row requested)
  //
  // thread lucky - which means if multiple threads hit this routine, we've 
  // yet to see an issue even though there is no specific thread handling
  // code. The reason this works is because we are access the data in a readonly
  // manner so it's use is unintrusive yet technically some purists would argue
  // that it's possible to get data in an unpure state... such as getting half
  // a string right because we snagged it while it was being written to. Well...
  // I don't disagree but the whole purpose of this class is for fast lookups
  // to data, not for adding and removing data alot... so... in our multi-threaded 
  // applications - we load this class up - and then just read from it without
  // issue - so... we insist - this is thread lucky! :)
  Function iGetIndex(p_iCol: Integer; p_iRow: Integer): Integer;inline;

  // Deletes everything in the matrix. We opted to not make a delete row
  // function because the nature of this classes design would make such an operation
  // processor intensive.
  //
  // - Not thread safe meaning you can't have separate
  // threads appending items to the same instance of this class and not expect 
  // problems.
  Function DeleteAll: Boolean; 

  // returns a an XML based output containing the contents of the entire matrix
  // using defaults for table column names etc.  Unlike the saHTMLTable counterparts
  // of this function, this function is not limited to specific number of columns.
  Function saXML: AnsiString;

  // returns a HTML based table containing the contents of the entire matrix (NOTE: limited to SIX columns) 
  // using defaults for table column names etc. See other version of this 
  // function that allows limiting what columns are returned and their 
  // captions in the returned table as well as controlling the table caption itself.
  Function saHTMLTable: AnsiString;

  {}
  // returns a HTML based table containing the contents of the entire matrix (NOTE: limited to SIX columns) 
  // using defaults for table column names etc. This version allows limiting 
  // what columns are returned and their captions in the returned table as 
  // well as controlling the table caption itself. See other version of this
  // function for a simpler mechanism to just get a html table out without 
  // having to figure out all these parameters (the shorthand version).
  // 
  // Ok - how this function works is similiar to how similiar named functions
  // in the JFC_DL, JFC_XDL and JFC_XXDL classes who have the same functions
  // tailored for their data. 
  //
  //  p_saTableTagInsert: AnsiString; - You can pass to this parameter 
  //  information to appear in place of "here": <table here>
  //    
  //  p_bTableCaption: Boolean; - You send true if you want the table to be rendered  
  //  a table caption. e.g. <table><caption></caption>
  //
  //  p_saTableCaption: AnsiString; - Here, providing you passed true to the 
  //  p_bTableCaption parameter, you place the text or tags or whatever you want 
  //  to appear in the actual <caption> </caption>
  //
  //  p_bTableCaptionShowRowCount: Boolean; - If passed as true, the total number of rows in the 
  //  table are appended to the text before the closing </caption> tag
  //  
  //  p_bTableHEAD: Boolean; - if true is passed, a table header is rendered - good for
  //  rendering column names etc. If you pass true, you may want to address the parameters
  //  that follow with values other than blank head text and zeros for the position to 
  //  place the columns. NOTE: Freepascal doesn't make passing dynamic parameters simple
  //  task, and forcing someone to build an array of paramers and passing in the array is a 
  //  little clunky and a bit to impose... SO this function is currently hardcoded to handle a 
  //  maximum of 6 columns in the MATRIX. Your matrix can have more but currently you can't
  //  get that data to render. This should be made more dynamic but has served well to date.
  //  TODO: Make another version of this function that accepts dynamic columns information
  //  for as many as the user wishes to send.
  //  
  //  p_saRowHEADText: AnsiString; - This is the text that appears accross the entire header 
  //  in the rendered table, and is not column specific.
  // 
  //  p_iRowCol: Integer;  - this is where you can specify what column in the table should contain
  //  the current row numbere. Pass a zero to not have this dynamic column rendered.
  //  
  //  p_sa01HEADText: AnsiString; - This is the header text for the first column in the matrix
  //  if you have the p_bTableHEAD parameter set to true it will in fact be rendered if the 
  //  p_i??Col (where ?? is same as digits in this parameter's name. 
  //
  //  p_i01Col: Integer; - passing a zero means don't display this column. If you want to display
  //  this column, the COLUMN in the matrix is FIXED but the value you pass here is where 
  //  in the table (which column) you want this particular Matrix column rendered.
  // 
  //  p_sa02HEADText: AnsiString; - This is the header text for the first column in the matrix
  //  if you have the p_bTableHEAD parameter set to true it will in fact be rendered if the 
  //  p_i??Col (where ?? is same as digits in this parameter's name. 
  //
  //  p_i02Col: Integer; - passing a zero means don't display this column. If you want to display
  //  this column, the COLUMN in the matrix is FIXED but the value you pass here is where 
  //  in the table (which column) you want this particular Matrix column rendered.
  //
  //  p_sa03HEADText: AnsiString; - This is the header text for the first column in the matrix
  //  if you have the p_bTableHEAD parameter set to true it will in fact be rendered if the 
  //  p_i??Col (where ?? is same as digits in this parameter's name. 
  //
  //  p_i03Col: Integer; - passing a zero means don't display this column. If you want to display
  //  this column, the COLUMN in the matrix is FIXED but the value you pass here is where 
  //  in the table (which column) you want this particular Matrix column rendered.
  //
  //  p_sa04HEADText: AnsiString; - This is the header text for the first column in the matrix
  //  if you have the p_bTableHEAD parameter set to true it will in fact be rendered if the 
  //  p_i??Col (where ?? is same as digits in this parameter's name. 
  //
  //  p_i04Col: Integer; - passing a zero means don't display this column. If you want to display
  //  this column, the COLUMN in the matrix is FIXED but the value you pass here is where 
  //  in the table (which column) you want this particular Matrix column rendered.
  //
  //  p_sa05HEADText: AnsiString; - This is the header text for the first column in the matrix
  //  if you have the p_bTableHEAD parameter set to true it will in fact be rendered if the 
  //  p_i??Col (where ?? is same as digits in this parameter's name. 
  //
  //  p_i05Col: Integer; - passing a zero means don't display this column. If you want to display
  //  this column, the COLUMN in the matrix is FIXED but the value you pass here is where 
  //  in the table (which column) you want this particular Matrix column rendered.
  //
  //  p_sa06HEADText: AnsiString; - This is the header text for the first column in the matrix
  //  if you have the p_bTableHEAD parameter set to true it will in fact be rendered if the 
  //  p_i??Col (where ?? is same as digits in this parameter's name. 
  //
  //  p_i06Col: Integer - passing a zero means don't display this column. If you want to display
  //  this column, the COLUMN in the matrix is FIXED but the value you pass here is where 
  //  in the table (which column) you want this particular Matrix column rendered.
  //
  Function saHTMLTable(
    p_saTableTagInsert: AnsiString;
  
    p_bTableCaption: Boolean;
    p_saTableCaption: AnsiString;
    p_bTableCaptionShowRowCount: Boolean;
    
    p_bTableHEAD: Boolean;
    
    p_saRowHEADText: AnsiString;
    p_iRowCol: Integer;
  
    p_sa01HEADText: AnsiString;
    p_i01Col: Integer;//< zero = Don't Display
  
    p_sa02HEADText: AnsiString;
    p_i02Col: Integer;
  
    p_sa03HEADText: AnsiString;
    p_i03Col: Integer;
  
    p_sa04HEADText: AnsiString;
    p_i04Col: Integer;
  
    p_sa05HEADText: AnsiString;
    p_i05Col: Integer;
  
    p_sa06HEADText: AnsiString;
    p_i06Col: Integer
  ):AnsiString;
  
  // returns true if instance of JFC_MATRIX is a copy of another JFC_MATRIX instance
  function bIsCopy: boolean;
  // This function goes out and gets the Current iCols and iRows values 
  // from the original JFC_MATRIX class if this instance is a copy.
  // NOTE: The Original Must exist for the life of this class for this to 
  // work without issue. See CreateCopy constructor info for more information.
  Procedure UpdateCopy;
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
//=*=




//*****************************************************************************
//IMPLEMENTATION===============================================================
//*****************************************************************************
// !#!JFC_MATRIX
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//*****************************************************************************
//
// JFC_MATRIX Routines          BASE "ITEMCLASS" 
//             
//*****************************************************************************

//=============================================================================
Constructor JFC_MATRIX.create; // OVERRIDE - BUT INHERIT
//=============================================================================
Begin
  iCols:=0;
  iRows:=0;
  iNth:=0;
  OrigMTX:=nil;
  Inherited;
  saClassName:='JFC_MATRIX';
End;
//=============================================================================

//=============================================================================
Constructor JFC_MATRIX.createCopy(p_MTX: JFC_MATRIX); // OVERRIDE - BUT INHERIT
//=============================================================================
Begin
  Inherited;
  saClassName:=p_MTX.saClassName;
  OrigMTX:=p_MTX;
  iNth:=0;
  UpdateCopy;
End;
//=============================================================================



//=============================================================================
Destructor JFC_MATRIX.Destroy; // OVERRIDE - BUT INHERIT
//=============================================================================
Begin
  if OrigMTX=nil then // means its NOT a copy
  begin
    saClassName:='';
    SetLength(asaColumns,0);
    SetLength(asaMatrix,0);
  end;
  Inherited;
End;
//=============================================================================


//=============================================================================
Procedure JFC_MATRIX.AppendItem;//inline;
//=============================================================================
Var i: Integer;
Begin
  if OrigMTX=nil then // means its NOT a copy
  begin
    //riteln('New Matrix Length:',(self.iRows * self.iCols)+ self.iCols);
    setlength(asaMAtrix,(self.iRows * self.iCols)+ self.iCols);
    iRows+=1;
    iNth:=iRows;
    For i:=1 To self.iCols Do 
    Begin
      //riteln('Index To Clear:',iGetIndex(i,irows));
      asaMatrix[iGetIndex(i,irows)]:='';
    End;
  end;
End;
//=============================================================================

//=============================================================================
procedure JFC_MATRIX.AppendItem_saName_N_saValue(
  p_saName: ansistring; 
  p_saValue: ansistring
);
//=============================================================================
begin
  if OrigMTX=nil then // means its NOT a copy
  begin
    AppendItem;
    if(iCols>=1)then asaMatrix[iGetIndex(1,irows)]:=p_saName;
    if(iCols>=2)then asaMatrix[iGetIndex(2,irows)]:=p_saValue;
  end;
end;
//=============================================================================

//=============================================================================
procedure JFC_MATRIX.AppendItem_MATRIX(p_saName: ansistring; p_saValue: ansistring; p_saDesc: ansistring);
//=============================================================================
begin
  if OrigMTX=nil then // means its NOT a copy
  begin
    AppendItem;
    if(iCols>=1)then asaMatrix[iGetIndex(1,irows)]:=p_saName;
    if(iCols>=2)then asaMatrix[iGetIndex(2,irows)]:=p_saValue;
    if(iCols>=3)then asaMatrix[iGetIndex(3,irows)]:=p_saDesc;
  end;
end;
//=============================================================================



//=============================================================================
Function JFC_MATRIX.MoveFirst:Boolean;//inline
//=============================================================================
Begin
  If iRows>0 Then 
  begin
    iNth:=1;
    Result:=true;
  end
  else
  begin
    result:=false
  end;
End;
//=============================================================================

//=============================================================================
Function JFC_MATRIX.MoveLast:Boolean;//inline
//=============================================================================
Begin
  If iRows>0 Then 
  begin
    iNth:=iRows;
    Result:=true;
  end
  else
  begin
    result:=false
  end;
End;
//=============================================================================

//=============================================================================
Function JFC_MATRIX.MovePrevious: Boolean;//inline;
//=============================================================================
Begin
  Result:=inth>1;
  If Result Then iNth-=1;
End;
//=============================================================================

//=============================================================================
Function JFC_MATRIX.MoveNext: Boolean;inline;
//=============================================================================
Begin
  Result:=inth<iRows;
  If Result Then iNth+=1;
End;
//=============================================================================


//=============================================================================
Procedure JFC_MATRIX.SetNoOfColumns(p_iCols: Integer);inline;
//=============================================================================
Var i: Integer;
Begin
  if OrigMTX=nil then // means its NOT a copy
  begin
    //riteln('JFC_MATRIX.SetNoOfColumns(p_iCols: Integer); p_icols:',p_icols);
    Deleteall;
    if p_icols>0 then
    begin
      setlength(asaColumns, p_iCols+1);
      iCols:=p_iCols;
      For i := 1 To p_iCols Do asaColumns[i]:='';
    end;
  end;
End;
//=============================================================================

//=============================================================================
Function JFC_MATRIX.Get_saColName(p_iCol: Integer): AnsiString;inline;
//=============================================================================
Begin
  if OrigMTX=nil then // means its NOT a copy
  begin
    Result:=asaColumns[p_iCol];
  end
  else
  begin
    result:=OrigMTX.asaColumns[p_iCol];
  end;
End;
//=============================================================================

//=============================================================================
Function JFC_MATRIX.Get_saMatrix(p_iCol: Integer; p_iRow: Integer): AnsiString;inline;
//=============================================================================
Var i: Integer;
Begin
  Result:='';
  i:=iGetIndex(p_iCol,p_iRow);

  if OrigMTX=nil then // means its NOT a copy
  begin
    If i>-1 Then Result:=asaMatrix[i];
  end
  else
  begin
    If i>-1 Then Result:=OrigMTX.asaMatrix[i];
  end;
End;
//=============================================================================

//=============================================================================
Function JFC_MATRIX.Get_saMatrix(p_iCol: Integer): AnsiString;inline;
//=============================================================================
Begin
  result:=Get_saMatrix(p_iCol, iNth);
End;
//=============================================================================

//=============================================================================
Function JFC_MATRIX.Get_saElement(p_ix: Integer): AnsiString;inline;
//=============================================================================
//Var i: Integer;
Begin
  Result:='';
  if OrigMTX=nil then // means its NOT a copy
  begin
    If p_ix>-1 Then Result:=asaMatrix[p_ix];
  end
  else
  begin
    If p_ix>-1 Then Result:=OrigMTX.asaMatrix[p_ix];
  end;
End;
//=============================================================================




//=============================================================================
Procedure JFC_MATRIX.Set_Matrix(p_iCol: Integer; p_iRow: Integer; p_saValue: AnsiString);inline;
//=============================================================================
Var i: Integer;
Begin
  if OrigMTX=nil then // means its NOT a copy
  begin
    i:=iGetIndex(p_iCol,p_iRow);
    If i>-1 Then asaMatrix[i]:=p_saValue;
  end;
End;
//=============================================================================

//=============================================================================
// Current row
Procedure JFC_MATRIX.Set_Matrix(p_iCol: Integer; p_saValue: AnsiString);inline;
//=============================================================================
Begin
  if OrigMTX=nil then // means its NOT a copy
  begin
    Set_Matrix(p_icol, iNth,p_saValue);
  end;
End;
//=============================================================================

//=============================================================================
// returns index in array with sought Value.
Function JFC_MATRIX.iFoundNext(p_iCol: Integer; p_saCriteria: AnsiString; p_bCaseSensitive: Boolean; p_iCurrentRow: Integer): Integer;
//=============================================================================
Var i: Integer;
    iRow: Integer;
    saUppercaseCriteria: AnsiString;
Begin
  Result:=-1;
  If (iRows>0) and (iCols>0) Then
  Begin
    If not p_bCaseSensitive Then saUppercaseCriteria:=upcase(p_saCriteria);
    iRow:=p_iCurrentRow;
    repeat
      iRow+=1;
      i:=iGetIndex(p_iCol,iRow);
      If i>-1 Then
      Begin
        If p_bCaseSensitive Then 
        Begin
          if OrigMTX=nil then // means its NOT a copy
          begin
            If asaMatrix[i]=p_saCriteria Then 
            begin
              iNth:=iRow;
              Result:=i;
            end;
          end
          else
          begin// if its a JFC_MATRIX copy 
            If OrigMTX.asaMatrix[i]=p_saCriteria Then 
            begin
              iNth:=iRow;
              Result:=i;
            end;
          end;
        End
        Else
        Begin
          if OrigMTX=nil then // means its NOT a copy
          begin
            If upcasE(asaMatrix[i])=saUppercaseCriteria Then 
            begin
              iNth:=iRow;
              Result:=i;
            end;
          end
          else
          begin// if its a JFC_MATRIX copy 
            If upcasE(OrigMTX.asaMatrix[i])=saUppercaseCriteria Then 
            begin
              iNth:=iRow;
              Result:=i;
            end;
          end;
        End;
      End;
    Until (Result>0) OR (iRow=iRows);
  End;
End;
//=============================================================================

//=============================================================================
Function JFC_MATRIX.iFoundItem(p_iCol: Integer; p_saCriteria: AnsiString; p_bCaseSensitive: Boolean): Integer;//inline;
//=============================================================================
//Var //i: Integer;
    //iRow: Integer;
    //saUppercaseCriteria: AnsiString;
Begin
  Result:=iFoundNext(p_iCol, p_saCriteria, p_bCaseSensitive, 0);
End;
//=============================================================================

//=============================================================================
Function JFC_MATRIX.iGetIndex(p_iCol: Integer; p_iRow: Integer): Integer;//inline
//=============================================================================
Begin
  Result:=-1;
  //riteln('icols:',icols);
  //riteln('irows:',irows);
  If (iCols>0) and 
     (iRows>0) and 
     (p_iCol>0) and 
     (p_iCol<=iCols) and 
     (p_iRow>0) and 
     (p_iRow<=iRows) Then
  Begin
    Result:=(p_iCol+((p_iRow-1)*iCols))-1;
  End;
  //riteln('GetIndex(p_iCol:',p_iCol,'p_iRow:',p_iRow,'):'+inttostr(result));
End;
//=============================================================================

//=============================================================================
function JFC_MATRIX.FoundItem_saName(p_sa: ansistring; p_bCaseSensitive: boolean):boolean;
//=============================================================================
var iX: integer;
begin
  ix:=iFoundItem(1,p_sa, p_bCaseSensitive);//inline;
  result:=(iX>-1);
end;
//=============================================================================

//=============================================================================
function JFC_MATRIX.FoundItem_saValue(p_sa: ansistring; p_bCaseSensitive: boolean):boolean;
//=============================================================================
var iX: integer;
begin
  ix:=iFoundItem(2,p_sa, p_bCaseSensitive);//inline;
  result:=(iX>-1);
end;
//=============================================================================

//=============================================================================
function JFC_MATRIX.FoundItem_saDesc(p_sa: ansistring; p_bCaseSensitive: boolean):boolean;
//=============================================================================
var iX: integer;
begin
  ix:=iFoundItem(3,p_sa, p_bCaseSensitive);//inline;
  result:=(iX>-1);
end;
//=============================================================================


//=============================================================================
function JFC_MATRIX.Get_saValue(p_sa: ansistring): ansistring;// Find NAME (col1), return Col2 (Value)
//=============================================================================
begin
  result:='';
  if FoundItem_saName(p_sa,false)then result:=Get_saMatrix(2,iNTh);
end;
//=============================================================================

//=============================================================================
function JFC_MATRIX.read_item_saName: ansistring;
//=============================================================================
begin
  result:='';
  if(iNth>0)then result:=Get_saMatrix(1,iNTh);
  //riteln('Read Name:'+result);
end;
//=============================================================================

//=============================================================================
procedure JFC_MATRIX.write_item_saName(p_sa: Ansistring);
//=============================================================================
begin
  if(iNth>0)then Set_Matrix(1,iNTh,p_sa);
  //riteln('Set Name:',p_sa);
end;
//=============================================================================

//=============================================================================
function JFC_MATRIX.read_item_saValue: ansistring;
//=============================================================================
begin
  result:='';
  if(iNth>0)then result:=Get_saMatrix(2,iNTh);
  //riteln('Read Value:'+result);
end;
//=============================================================================

//=============================================================================
procedure JFC_MATRIX.write_item_saValue(p_sa: Ansistring);
//=============================================================================
begin
  if(iNth>0)then Set_Matrix(2,iNTh,p_sa);
  //riteln('Set Value:',p_sa);
end;
//=============================================================================

//=============================================================================
function JFC_MATRIX.read_item_saDesc: ansistring;
//=============================================================================
begin
  result:='';
  if(iNth>0)then result:=Get_saMatrix(3,iNTh);
  //riteln('Read Desc:'+result);
end;
//=============================================================================

//=============================================================================
procedure JFC_MATRIX.write_item_saDesc(p_sa: Ansistring);
//=============================================================================
begin
  if(iNth>0)then Set_Matrix(3,iNTh,p_sa);
  //riteln('Set Desc:',p_sa);
end;
//=============================================================================


//=============================================================================
// Make DeleteAll Return TRUE unless Error - Or bCopyied Class.
//=============================================================================
Function JFC_MATRIX.DeleteAll: Boolean; 
//=============================================================================
begin
  if OrigMTX=nil then // means its NOT a copy
  begin
    result:=true;
    iRows:=0;
    iNth:=0;
  end
  else
  begin
    result:=false;
  end;
  //riteln('deleteall iRows:',iRows,' icols:',icols);
  //Get_saMatrix(1,1);
end;
//=============================================================================



//=============================================================================
Function JFC_MATRIX.saHTMLTable: AnsiString;
//=============================================================================
Begin
  Result:=saHTMLTable(
    '',//p_saTableTagInsert: AnsiString;

    True, //p_bTableCaption: boolean;
    'ClassName: ' +saClassName+' - Rows',//p_saTableCaption: AnsiString;
    True,//p_bTableCaptionShowRowCount: boolean;
    
    True,//p_bTableHEAD: boolean;
    
    '',//p_RowText: AnsiString;
    1,//p_iRowCol: integer;// zero = Don't Display

    '',//p_sa01HEADText: AnsiString;
    2,//p_i01Col: integer;// zero = Don't Display
  
    '',//p_02HEADText: AnsiString;
    3,//p_02Col: integer;
  
    '',//p_sa03HEADText: AnsiString;
    4,//p_i03Col: integer;
  
    '',//p_sa04HEADText: AnsiString;
    5,//p_i04Col: integer;
  
    '',//p_sa05HEADText: AnsiString;
    6,//p_i05Col: integer;
  
    '',//p_sa06HEADText: AnsiString;
    7//p_i06Col: integer;
  );
End;
//=============================================================================

//=============================================================================
Function JFC_MATRIX.saHTMLTable(
  
  p_saTableTagInsert: AnsiString;

  p_bTableCaption: Boolean;
  p_saTableCaption: AnsiString;
  p_bTableCaptionShowRowCount: Boolean;
  
  p_bTableHEAD: Boolean;
  
  p_saRowHEADText: AnsiString;
  p_iRowCol: Integer;

  p_sa01HEADText: AnsiString;
  p_i01Col: Integer;// zero = Don't Display

  p_sa02HEADText: AnsiString;
  p_i02Col: Integer;

  p_sa03HEADText: AnsiString;
  p_i03Col: Integer;

  p_sa04HEADText: AnsiString;
  p_i04Col: Integer;

  p_sa05HEADText: AnsiString;
  p_i05Col: Integer;

  p_sa06HEADText: AnsiString;
  p_i06Col: Integer
):AnsiString;
//=============================================================================
Var i: Integer;
    iColSpan: Integer;
    BookMarkNth: longint;
Begin
  BookMarkNth:=iNth;
  Result:='<table class="gridresults" '+p_saTableTagInsert+'>';
  If p_bTableCaption Then
  Begin
    Result+='<caption>' + p_saTableCaption;
    If p_bTableCaptionShowRowCount Then Result+=' '+ inttostr(ListCount);
    Result+='</caption>';
  End;
  
  // This is based on the fact that there should always be one column minumum
  // and that the max is SIX (6) columns, and the Caller is smart enough
  // to have their passed indexes correct, no duplicates, and zero
  // indicates DO NOT show column.. but they will always have at least
  // ONE column configured.
  If p_bTableHEAD Then
  Begin
    Result+='<thead><tr>';
    For i:=1 To iCols+1 Do
    Begin

      If p_iRowCol=i Then
      Begin
        Result+='<td align="right">';
        If length(p_saRowHEADText)>0 Then 
        Begin
          Result+=p_saRowHEADText;
        End
        Else
        Begin
          Result+='Row';
        End;
        Result+='</td>'
      End;

      If p_i01Col=i Then
      Begin
        Result+='<td align="left">';
        If length(p_sa01HEADText)>0 Then 
        Begin
          Result+=p_sa01HEADText;
        End
        Else
        Begin
          Result+='Name';
        End;
        Result+='</td>'
      End;
      
      If p_i02Col=i Then
      Begin
        Result+='<td align="left">';
        If length(p_sa02HEADText)>0 Then 
        Begin
          Result+=p_sa02HEADText;
        End
        Else
        Begin
          Result+='Value';
        End;
        Result+='</td>'
      End;
    
      If p_i03Col=i Then
      Begin
        Result+='<td align="left">';
        If length(p_sa03HEADText)>0 Then 
        Begin
          Result+=p_sa03HEADText;
        End
        Else
        Begin
          Result+='Desc';
        End;
        Result+='</td>'
      End;
      
      If p_i04Col=i Then
      Begin
        Result+='<td align="left">';
        If length(p_sa04HEADText)>0 Then 
        Begin
          Result+=p_sa04HEADText;
        End
        Else
        Begin
          Result+='Col4';
        End;
        Result+='</td>'
      End;
      
      If p_i05Col=i Then
      Begin
        Result+='<td align="left">';
        If length(p_sa05HEADText)>0 Then 
        Begin
          Result+=p_sa05HEADText;
        End
        Else
        Begin
          Result+='Col5';
        End;
        Result+='</td>'
      End;
      
      If p_i06Col=i Then
      Begin
        Result+='<td align="left">';
        If length(p_sa06HEADText)>0 Then 
        Begin
          Result+=p_sa06HEADText;
        End
        Else
        Begin
          Result+='Col6';
        End;
        Result+='</td>'
      End;
    End;
    Result+='</thead>';
  End;// TABLE HEAD
  Result+='<tbody>';    
      

  If MoveFirst Then
  Begin
    repeat
      If (iNth Mod 2)=0 Then 
        Result+='<tr class="r2">' 
      Else 
        Result+='<tr class="r1">';
      
      For i:=1 To iCols+1 Do
      Begin
        If p_iRowCol    =i Then
        Begin
          Result+='<td align="right">'+inttostr(iNth)+'</td>';
        End;        

        If p_i01Col  =i Then
        Begin
          Result+='<td align="left">'+Get_saMatrix(1,iNTh)+'</td>';
        End;        

        If p_i02Col    =i Then
        Begin
          Result+='<td align="left">'+Get_saMatrix(2,iNTh)+'</td>';
        End;        

        If p_i03Col =i Then
        Begin
          Result+='<td align="left">'+Get_saMatrix(3,iNTh)+'</td>';
        End;        

        If p_i04Col=i Then
        Begin
          Result+='<td align="left">'+Get_saMatrix(4,iNTh)+'</td>';
        End;        

        If p_i05Col =i Then
        Begin
          Result+='<td align="left">'+Get_saMatrix(5,iNTh)+'</td>';
        End;        

        If p_i06Col  =i Then
        Begin
          Result+='<td align="left">'+Get_saMatrix(6,iNTh)+'</td>';
        End;        

      End;    
      Result+='</tr>';
    Until not MoveNext;    
  End
  Else
  Begin
    iColSpan:=0;
    If p_iRowCol>0 Then iColSpan+=1;
    If p_i01Col>0 Then iColSpan+=1;
    If p_i02Col>0 Then iColSpan+=1;
    If p_i03Col>0 Then iColSpan+=1;
    If p_i04Col>0 Then iColSpan+=1;
    If p_i05Col>0 Then iColSpan+=1;
    If p_i06Col>0 Then iColSpan+=1;
    if(iColSpan>(iCols+1)) then iColSpan:=iCols+1;
    Result+='<tr class="r1"><td colspan="'+inttostr(iColSpan)+'" align="center">No Data</td></tr>';
  End;
  Result+='</tbody></table>';
  iNth:=BookMarkNth;
End;
//=============================================================================


//=============================================================================
Function JFC_MATRIX.saXML: ansistring;
//=============================================================================
Var 
  i: Integer;
  iBookMarkNth: longint;
Begin
  iBookMarkNth:=iNth;
  If not MoveFirst Then
  begin
    result:='<matrix />';
  end
  else
  Begin
    result:='<matrix>';
    repeat
      result+='<row RowNo="'+inttostr(iNth)+'">'+csCRLF;
      For i:=1 To iCols+1 Do
      Begin
        result+='<column Name="'+Get_saColName(i)+'"><!CDATA!['+Get_saMatrix(i,iNTh)+']]></column>'+csCRLF;
      End;    
      Result+='</row>';
    Until not MoveNext;    
    result:='</matrix>';
  End;
  Result+='</matrix>';
  iNth:=iBookMarkNth;
End;
//=============================================================================


//=============================================================================
function JFC_MATRIX.bIsCopy: boolean;
//=============================================================================
begin
  result:=(OrigMTX=nil);
end;
//=============================================================================

//=============================================================================
procedure JFC_MATRIX.UpdateCopy;
//=============================================================================
begin
  iCols:=OrigMTX.iCols;
  iRows:=OrigMTX.iRows;
  if iNth>iRows then iNth:=iRows;
end;
//=============================================================================




//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// EOF
//*****************************************************************************
