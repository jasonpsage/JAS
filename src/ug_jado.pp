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
// Common Wrapper for all data sources as well as an API for interacting with them.
//
// NOTE: On Linux, I had to FIND the MYSQL (ver 4) units and copy them
// to my FPC directory, then rename mysql.pp to mysql4.pp, open it
// and change the unit name to follow suit: Unit mysql4;
// -----
// TODO: Add NULL FLAG support (for JADO_FIELD(FIELDS.lpItem).bNull ) for MEMO
//       columns. Might be as simple as looking for a -1 when the FIRST call
//       to grab LOB info. Where 0=Zero Length perhaps and -1=null.
//       Actually - I removed it - was a pain. Need it though time permitting.
//
// Note: For MYSQL I made the Field value literally equal NULL if a nil was
// encountered for the pchar pointer to the returned data. Additionally I
// made the rs.fields.item_saDesc equal NULL also.
Unit ug_jado;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_jado.pp'}
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}


{DEFINE SQLTRACE}
{DEFINE DIAGMSG}
{DEFINE DEBUGLOGBEGINEND}


{$IFDEF DEBUGLOGBEGINEND}
{$INFO | DEBUGLOGBEGINEND: TRUE}
{$ENDIF}

{$IFDEF DIAGMSG}
{$INFO | DIAGMSG: TRUE}
{$ENDIF}

{$IFDEF SQLTRACE}
{$INFO | SQLTRACE: TRUE}
{$ENDIF}

{$IFDEF MYSQL5}
{$INFO | COMPILED FOR MYSQL5}
{$ELSE}
{$INFO | COMPILED FOR MYSQL4}
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
  sysutils,
  {$IFNDEF MYSQL5}
  mysql4,
  {$ELSE}
  mysql50,
  {$ENDIF}
  {$IFDEF ODBC}
  odbcsqldyn,
  {$ENDIF}
  ug_misc,
  ug_common,

  ug_jegas,
  ug_jfc_dl,
  ug_jfc_xdl,
  ug_jfc_matrix,
  ug_JFC_Tokenizer,
  ug_tsfileio;
//=============================================================================


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !@!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************
{}
Const cnLOBBufSize=65535;
Const cnODBC_ColumnNameBufLen=64;

//-----------------------------------------------
// jado.rtConnection.i4DMBSID: DBMS Dialect
//-----------------------------------------------
{}
Const cnDBMS_Generic = 1; //<jado.rtConnection.i4DMBSID: DBMS Dialect
Const cnDBMS_MSSQL = 2;//<jado.rtConnection.i4DMBSID: DBMS Dialect
Const cnDBMS_MSAccess = 3;//<jado.rtConnection.i4DMBSID: DBMS Dialect
Const cnDBMS_MySQL = 4;//<jado.rtConnection.i4DMBSID: DBMS Dialect
Const cnDBMS_Excel = 5;//<jado.rtConnection.i4DMBSID: DBMS Dialect
Const cnDBMS_dBase = 6;//<jado.rtConnection.i4DMBSID: DBMS Dialect
Const cnDBMS_FoxPro = 7;//<jado.rtConnection.i4DMBSID: DBMS Dialect
Const cnDBMS_Oracle = 8;//<jado.rtConnection.i4DMBSID: DBMS Dialect
Const cnDBMS_Paradox = 9;//<jado.rtConnection.i4DMBSID: DBMS Dialect
Const cnDBMS_Text = 10;//<jado.rtConnection.i4DMBSID: DBMS Dialect
Const cnDBMS_PostGresSQL = 11;//<jado.rtConnection.i4DMBSID: DBMS Dialect
Const cnDBMS_SQLite = 12;//<jado.rtConnection.i4DMBSID: DBMS Dialect
{}
//-----------------------------------------------




//=============================================================================
// jado.rtConnection.u2DrivID: Library to use
//=============================================================================
{}
// Use the ODBC API.
// The Jegas API uses both ODBC and Native Drivers when
// possible for various DBMS it supports. That Said we need to have constants
// to indicate what method is to be used.
Const cnDriv_ODBC = 1;
{}
// Use the MySQL API. (Works for Version 4 and 5) to date 2012-03-09
// The Jegas API uses both ODBC and Native Drivers when
// possible for various DBMS it supports. That Said we need to have constants
// to indicate what method is to be used.
Const cnDriv_MySQL =2;
//=============================================================================




{}
Const adSchemaActions                  =  41;
Const adSchemaAsserts                  =  0; 
Const adSchemaCatalogs                 =  1; 
Const adSchemaCharacterSets            =  2; 
Const adSchemaCheckConstraints         =  5; 
Const adSchemaCollations               =  3; 
Const adSchemaColumnPrivileges         =  13; 
Const adSchemaColumns                  =  4; 
Const adSchemaColumnsDomainUsage       =  11; 
Const adSchemaCommands                 =  42; 
Const adSchemaConstraintColumnUsage    =  6; 
Const adSchemaConstraintTableUsage     =  7; 
Const adSchemaCubes                    =  32; 
Const adSchemaDBInfoKeywords           =  30; 
Const adSchemaDBInfoLiterals           =  31; 
Const adSchemaDimensions               =  33; 
Const adSchemaForeignKeys              =  27; 
Const adSchemaFunctions                =  40; 
Const adSchemaHierarchies              =  34; 
Const adSchemaIndexes                  =  12; 
Const adSchemaKeyColumnUsage           =  8; 
Const adSchemaLevels                   =  35; 
Const adSchemaMeasures                 =  36; 
Const adSchemaMembers                  =  38; 
Const adSchemaPrimaryKeys              =  28; 
Const adSchemaProcedureColumns         =  29; 
Const adSchemaProcedureParameters      =  26; 
Const adSchemaProcedures               =  16; 
Const adSchemaProperties               =  37; 
Const adSchemaProviderSpecific         =  -1; 
Const adSchemaProviderTypes            =  22; 
Const adSchemaReferentialConstraints   =  9; 
Const adSchemaSchemata                 =  17; 
Const adSchemaSets                     =  43; 
Const adSchemaSQLLanguages             =  18; 
Const adSchemaStatistics               =  19; 
Const adSchemaTableConstraints         =  10; 
Const adSchemaTablePrivileges          =  14; 
Const adSchemaTables                   =  20; 
Const adSchemaTranslations             =  21; 
Const adSchemaTrustees                 =  39; 
Const adSchemaUsagePrivileges          =  15; 
Const adSchemaViewColumnUsage          =  24; 
Const adSchemaViews                    =  23; 
Const adSchemaViewTableUsage           =  25; 

Const csSchema_Actions = 'Actions';
Const csSchema_Asserts = 'Asserts';
Const csSchema_Catalogs = 'Catalogs';
Const csSchema_CharacterSets = 'CharacterSets';
Const csSchema_CheckConstraints = 'CheckConstraints';
Const csSchema_Collations = 'Collations';
Const csSchema_ColumnPrivileges = 'ColumnPrivileges';
Const csSchema_Columns = 'Columns';
Const csSchema_ColumnsDomainUsage = 'ColumnsDomainUsage';
Const csSchema_Commands = 'Commands';
Const csSchema_ConstraintColumnUsage = 'ConstraintColumnUsage';
Const csSchema_ConstraintTableUsage = 'ConstraintTableUsage';
Const csSchema_Cubes = 'Cubes';
Const csSchema_DBInfoKeywords = 'DBInfoKeywords';
Const csSchema_DBInfoLiterals = 'DBInfoLiterals';
Const csSchema_Dimensions = 'Dimensions';
Const csSchema_ForeignKeys = 'ForeignKeys';
Const csSchema_Functions = 'Functions';
Const csSchema_Hierarchies = 'Hierarchies';
Const csSchema_Indexes = 'Indexes';
Const csSchema_KeyColumnUsage = 'KeyColumnUsage';
Const csSchema_Levels = 'Levels';
Const csSchema_Measures = 'Measures';
Const csSchema_Members = 'Members';
Const csSchema_PrimaryKeys = 'PrimaryKeys';
Const csSchema_ProcedureColumns = 'ProcedureColumns';
Const csSchema_ProcedureParameters = 'ProcedureParameters';
Const csSchema_Procedures = 'Procedures';
Const csSchema_Properties = 'Properties';
Const csSchema_ProviderSpecific = 'ProviderSpecific';
Const csSchema_ProviderTypes = 'ProviderTypes';
Const csSchema_ReferentialConstraints = 'ReferentialConstraints';
Const csSchema_Schemata = 'Schemata';
Const csSchema_Sets = 'Sets';
Const csSchema_SQLLanguages = 'SQLLanguages';
Const csSchema_Statistics = 'Statistics';
Const csSchema_TableConstraints = 'TableConstraints';
Const csSchema_TablePrivileges = 'TablePrivileges';
Const csSchema_Tables = 'Tables';
Const csSchema_Translations = 'Translations';
Const csSchema_Trustees = 'Trustees';
Const csSchema_UsagePrivileges = 'UsagePrivileges';
Const csSchema_ViewColumnUsage = 'ViewColumnUsage';
Const csSchema_Views = 'Views';
Const csSchema_ViewTableUsage = 'ViewTableUsage';

//=============================================================================
{}
// ODBC itself uses a series of functions to do different kinds of queries to 
// the connected database. Unfortunately; each has it's own "way" it needs to be 
// used... So - in an effort to make the Jegas, LLC JADO Connector work identical 
// for both ODBC, MYSQL, etc... (Speaking about how the JADO_RECORDSET class 
// works) We've got these constants that guide requests through the proper 
// code for their respective ODBC API command to be carried out. 
// Here's how it's intended to work: You open a QUERY 

const cnODBC_SQL = 0;                 // NORMAL SQL STATEMENT SQLPrepare()
const cnODBC_SQLTables = 1;           // SHOW TABLES - SQLTables()
const cnODBC_SQLColumns = 2;          // SHOW Columns - SQLColumns()
const cnODBC_SQLColumnPrivileges = 3; // COLUMN Privileges - SQLColumnPrivileges()
const cnODBC_SQLStatistics = 4;       // TABLE Stats and Indexs - SQLStatistics()
const cnODBC_SQLTablePrivileges = 5;  // TABLE Privileges - SQLTablePrivileges()
//=============================================================================









//=============================================================================
{}
Type JADO_FIELD = Class(JFC_XDLITEM)
//=============================================================================
  u2JDType: word; //< Jegas Types Declared in uxxg_common.pp
  u8DefinedSize: UInt64;
  i4NumericScale: LongInt;
  i4Precision: LongInt;
  {}
  //----------------------

  //------------------------------------------------
  // ODBC FIELD PROPERTY
  //------------------------------------------------
    {$IFDEF ODBC}
    {}
    ODBCSQLHSTMT:SQLHSTMT;//<ODBC FIELD PROPERTY
    {}
    //ODBCStatementHandle:SQLHSTMT;
    {}
    ODBCColumnNumber:SQLUSMALLINT;//< ODBC FIELD PROPERTY
    ODBCColumnName:PSQLCHAR;//< ODBC FIELD PROPERTY
    ODBCColNameBufLen:SQLSMALLINT;//< ODBC FIELD PROPERTY
    ODBCNameLength:SQLSMALLINT;//< ODBC FIELD PROPERTY
    ODBCDataType:SQLSMALLINT; //< ODBC FIELD PROPERTY as reported from SQLDescribeCol
    ODBCTargetType: SQLSMALLINT;//< ODBC FIELD PROPERTY As sent to SQLBindCol
    ODBCColumnSize:SQLUINTEGER;//< ODBC FIELD PROPERTY
    ODBCDecimalDigits:SQLSMALLINT;//< ODBC FIELD PROPERTY
    ODBCNullable:SQLSMALLINT;//< ODBC FIELD PROPERTY
    ODBCDATAPOINTER: pointer;//< ODBC FIELD PROPERTY
    ODBCLOB: Boolean;//< ODBC FIELD PROPERTY
    ODBCStrLen_or_Ind: PSQLINTEGER;
    {$ELSE}
    ODBCColumnNumber: shortint;//< ODBC FIELD PROPERTY
    {$ENDIF}
  {}
  //------------------------------------------------
  {}
  rMySqlField: PMySQL_FIELD;//<MySQL Field Properties

  Constructor create; //< OVERRIDE BUT INHERIT
  Destructor destroy; override; //< OVERRIDE but inherit
End;
//=============================================================================





//=============================================================================
{}
// This class is just to wrap this UNIT into something along the lines of a 
// NameSpace which isn't required in freepascal - BUT helps make code self
// documenting in that you know where to look for things perhaps...
// This class WILL be automatically instanced in the unit start up code.
// If you want to cleanly remove the class during application shutdown,
// I recommend you use: if(JADO<>nil)then begin JADO.destroy;JADO:=nil; end;    
type TJADO = class
//=============================================================================
  public 
  constructor create;
  destructor destroy; override;
  public
  {$IFDEF ODBC}
  ODBCDSNXDL: JFC_XDL;
  ODBCENVHANDLE: SQLHANDLE;
  i4ODBCConCount: longint;

  // NOTE: the ODBCDSN (JFC_XDL) Is not initialized until this function is 
  // called. Ths JFC_XDL for it is global to this unit and is therefore not 
  // threads safe.
  Procedure ODBCLoadDataSources; //< ODBCSQL Specific
  {$ENDIF}
  {}
  //---------------------------------------------------------------------------
  Function saBuildConnectString( 
    p_saDSN: AnsiString;
    p_saDriver: AnsiString; 
    p_saServer: AnsiString; 
    p_saUserName: AnsiString; 
    p_saPassword: AnsiString; 
    p_saDatabase: AnsiString; 
    p_bFileBased: Boolean;
    p_u2DrivID: word
  ): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // This is sent one of the cnDBMS_?????? constants to determine
  // how to escape texual data bound for a database. 
  // !! NOTE: THIS Puts the Quotes on For you!
  Function saDBMSScrub(p_sa: AnsiString; p_u2DbmsID: word): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // This is sent one of the cnDBMS_?????? constants to determine
  // how to escape texual data bound for a database. 
  // !! NOTE: THIS Puts the Quotes on For you!
  Function saDBMSDateScrub(p_sa: AnsiString; p_u2DbmsID: word): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // This is sent one of the cnDBMS_?????? constants to determine
  // how to escape texual data bound for a database. 
  // !! NOTE: THIS Puts the Quotes on For you!
  Function saDBMSDateScrub(p_dt: tdatetime; p_u2DbmsID: word): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // This is sent one of the cnDBMS_?????? constants to determine
  // how to escape texual data bound for a database. 
  // !! NOTE: THIS Puts the Quotes on For you!
  Function saDBMSDateScrub(p_ts: ttimestamp; p_u2DbmsID: word): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // Returns Proper boolean representation for the passed DBMS  
  Function saDBMSBoolScrub(p_sa: ansistring; p_u2DbmsID: word): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // Returns Proper boolean representation for the passed DBMS  
  Function saDBMSBoolScrub(p_b: boolean; p_u2DbmsID: word): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // Returns Proper Integer representation for the passed DBMS  
  // Note: Same as it's like named counterpart except this version will return
  // 'null' if 'NULL' is passed to is as a string .. and if its not a null,
  // then the function uses the i8Val(ansistring) function to convert 
  // p_sa parameter to an integer.
  function saDBMSIntScrub(p_sa: ansistring; p_u2DbmsID: word): ansistring;
  {}
  // Returns Proper Integer representation for the passed DBMS  
  function saDBMSIntScrub(p_i8: int64; p_u2DbmsID: word): ansistring;
  {}
  // Returns Proper decimal representation for the passed DBMS  
  // Note: Same as it's like named counterpart except this version will return
  // 'null' if 'NULL' is passed to is as a string .. and if its not a null,
  // then the function uses the i8Val(ansistring) function to convert 
  // p_sa parameter to an integer.
  function saDBMSDecScrub(p_sa: ansistring; p_u2DbmsID: word): ansistring;
  //---------------------------------------------------------------------------
  {}
  // Returns Proper Unsigned Integer representation for the passed DBMS
  // Note: Same as it's like named counterpart except this version will return
  // 'null' if 'NULL' is passed to is as a string .. and if its not a null,
  // then the function uses the u8Val(ansistring) function to convert 
  // p_sa parameter to an integer.
  function saDBMSUIntScrub(p_sa: ansistring; p_u2DbmsID: word): ansistring;
  //---------------------------------------------------------------------------
  {}
  // Returns Proper Unsigned Integer representation for the passed DBMS
  // Note: Same as it's like named counterpart except this version will return
  // 'null' if 'NULL' is passed to is as a string .. and if its not a null,
  // then the function uses the u8Val(ansistring) function to convert
  // p_sa parameter to an integer.
  function saDBMSUIntScrub(p_u8: UInt64; p_u2DbmsID: word): ansistring;
  //---------------------------------------------------------------------------
  {}
  // This is sent one of the cnDBMS_?????? constants to determine
  // the wildcard character to use in LIKE clauses for the passed DBMS. 
  Function saDBMSWild(p_u2DbmsID: word): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // This is sent one of the cnDBMS_?????? constants to properly enclose DBMS 
  // object names. Examples: Mysql: `sometablename` MSAccess: [sometablename]
  Function saDBMSEncloseObjectName(p_saObjectName: ansistring; p_u2DbmsID: word): AnsiString;
  {}
  // This function takes an object name and returns it potentially modified if the 
  // object name is a keyword or a special character. This function was written to 
  // allow data field names to be ported without running into problems with keywords
  // and often disallowed punctuation in or numbers leading field names.
  function saDBMSCleanObjectName(p_saObjectName: ansistring; p_u2DbmsID: word): AnsiString;
  {}
  // Returns textual name of the indicated Schemata Descriptor passed in p_i4
  // e.g. of constants: adSchemaActions, adSchemaAsserts etc.
  // It's name is admittedly humorous but the name stuck
  function saSchemaThingy(p_i4: longint): ansistring;
  //---------------------------------------------------------------------------
  {}
  function saCursorOption(p_iCursorOption: Longint): ansistring;//< These functions just turn the various (ADODB enumerated) constants into their textual names
  //---------------------------------------------------------------------------
  {}
  function saDataType(p_iDataType: Longint): ansistring;//< These functions just turn the various (ADODB enumerated) constants into their textual names
  //---------------------------------------------------------------------------
  {}
  function saEditMode(p_iEditMode: Longint): ansistring;//< These functions just turn the various (ADODB enumerated) constants into their textual names
  //---------------------------------------------------------------------------
  {}
  function saEventStatus(p_iEventStatus: Longint): ansistring;//< These functions just turn the various (ADODB enumerated) constants into their textual names
  //---------------------------------------------------------------------------
  {}
  function saLockType(p_iLockType: Longint): ansistring;//< These functions just turn the various (ADODB enumerated) constants into their textual names
  //---------------------------------------------------------------------------
  {}
  function saObjectState(p_iObjectState: Longint): ansistring;//< These functions just turn the various (ADODB enumerated) constants into their textual names
  //---------------------------------------------------------------------------
  {}
  function saRecordStatus(p_iRecordStatus: Longint): ansistring;//< These functions just turn the various (ADODB enumerated) constants into their textual names
  //---------------------------------------------------------------------------
  {}
  function saRecordType(p_iRecordType: Longint): ansistring;//< These functions just turn the various (ADODB enumerated) constants into their textual names
  //---------------------------------------------------------------------------
  {}
  {$IFDEF ODBC}
  Function ODBCSuccess (p_i2ODBCResult: SmallInt) : Boolean;//< These functions just turn the various (ADODB enumerated) constants into their textual names 
  //---------------------------------------------------------------------------
  {}
  Function bODBC_OK: Boolean;
  //---------------------------------------------------------------------------
  {$ENDIF}
  {}
  // This function takes a populated JADO Field Structure and turns it into appropriate
  // DBMS DDL language for the DBMS at hand.
  Function saDDLField(
    p_saName: ansistring;
    p_u2DbmsID: word;
    p_u2JDType: word;
    p_u8DefinedSize: UInt64;
    p_i4NumericScale: LongInt;
    p_i4Precision: LongInt;
    p_saDefaultValue: ansistring;
    p_bAllowNulls: boolean;
    p_bAutoIncrement: boolean;
    p_bCleanFieldName: boolean
  ): ansistring;
  //---------------------------------------------------------------------------
  {}
  // This function returns true if the passed query appears to be a readonly 
  // query.
  Function bReadOnlyQueryCheck(p_saQry: ansistring):Boolean;
  //---------------------------------------------------------------------------
  {}
  // This function checks for the existance of a table (or view) in the database
  // actively connected to by the passed JADO_CONNECTION
  // NOTE: p_Con needs to be a pointer but refers to JADO_CONNECTION.
  // Due to it's location in the code internally... You need to TypeCast
  // a JADO_CONNECTION as a pointer here.
  Function bTableExists(p_saTable: ansistring; p_Con: pointer; p_u8Caller: UInt64): boolean;
  //---------------------------------------------------------------------------
  {}
  // this function drops specified table; if there is a table and a view
  // the same name; both will be deleted - this function doesn't try to 
  // differentiate between tables and views. 
  // NOTE: p_Con needs to be a pointer but refers to JADO_CONNECTION.
  // Due to it's location in the code internally... You need to TypeCast
  // a JADO_CONNECTION as a pointer here.
  Function bDropTable(p_saTable: ansistring; p_Con: pointer;p_u8Caller: UInt64): Boolean;
  //---------------------------------------------------------------------------
  {}
  // this function drops specified view; if there is a table and a view
  // the same name; both will be deleted - this function doesn't try to
  // differentiate between tables and views.
  // NOTE: p_Con needs to be a pointer but refers to JADO_CONNECTION.
  // Due to it's location in the code internally... You need to TypeCast
  // a JADO_CONNECTION as a pointer here.
  Function bDropView(p_saTable: ansistring; p_Con: pointer;p_u8Caller: UInt64): Boolean;
  //---------------------------------------------------------------------------
  {}
  // This function allows you to dynamically add a column to a MySQL Database
  // Currently. Another version needs to be written along the lines of How
  // SchemaMaster does it... It has a Jegas Data Type Paradigm.. and then 
  // output the correct DBMS syntax to the currently Connected DataBase.
  // This function Does check if column exists. if it does it modifies the existing column.  
  // NOTE: p_Con needs to be a pointer but refers to JADO_CONNECTION.
  // Due to it's location in the code internally... You need to TypeCast
  // a JADO_CONNECTION as a pointer here.
  function bAddColumn(
    p_saTable: ansistring;
    p_saColumn: Ansistring;
    p_saColumnDefinition: ansistring; 
    p_Con: pointer;
    p_u8Caller: UInt64
  ): boolean;

  //---------------------------------------------------------------------------
  {}
  // Returns TRUE if Column Exists. False if it doesn''t or there is an error.
  // p_Con is JADO_CONNECTION Pointer
  // p_u8Caller is just a number (YYYYMMDDHHMM) that is unique so you
  // can track whose calling this routine if its failing.
  function bColumnExists(
    p_saTable: ansistring;
    p_saColumn: Ansistring;
    p_Con: pointer;
    p_u8Caller: UInt64
  ): boolean;

  //---------------------------------------------------------------------------
  {}
  // Returns TRUE if Column Exists. False if it doesn''t or there is an error.
  Procedure CopyRecordToXDL(
    p_RS: pointer;
    p_XDL: JFC_XDL
  );
  //---------------------------------------------------------------------------
  
  //---------------------------------------------------------------------------
  {}
  // Locate index of specific JADO_CONNECTION in an array of JADO_CONNECTION
  // using the ID field value. This Generally UID of the JADO_CONNECTION when
  // it resides in a JAS database. This UID is presumed to be an Unsigned 8
  // byte (64bit) number.
  function bFoundConnectionByID(
    p_u8UID: UInt64;
    var p_lpaJADOC: pointer;
    var p_iIndex: longint
  ):boolean;
  //---------------------------------------------------------------------------


//=============================================================================
end;
//=============================================================================
Var JADO: TJADO;  
//=============================================================================

//=============================================================================
// HISTORY: Jegas DSN in vb6 apps, previously rtConnection in FPC 
//DO NOT CHANGE the order of these fields. Add to the bottom.
//there are many areas of the code that us humans use this list,
//in the order it is in to make sure we have covered all the
//fields in whatever task it happens to be. (Saving the file for
//example.)
Const cnRTConnectionFields = 45; 
//public Global Const cnRTConnectionFields = 2' Debugging Test Value
//=============================================================================







//=============================================================================
//=============================================================================
//=============================================================================
//=============================================================================


//=============================================================================
// ADODB.CursorOptionEnum
//=============================================================================
{}
Const adAddNew = 16778240;//< (&H1000400) ADODB.CursorOptionEnum
Const adApproxPosition = 16384;//< (&H4000) ADODB.CursorOptionEnum
Const adBookmark = 8192;//< (&H2000) ADODB.CursorOptionEnum
Const adDelete = 16779264;//< (&H1000800) ADODB.CursorOptionEnum
Const adFind = 524288;//< (&H80000) ADODB.CursorOptionEnum
Const adHoldRecords = 256;//< (&H100) ADODB.CursorOptionEnum
Const adIndex = 8388608;//< (&H800000) ADODB.CursorOptionEnum
Const adMovePrevious = 512;//< (&H200) ADODB.CursorOptionEnum
Const adNotify = 262144;//< (&H40000) ADODB.CursorOptionEnum
Const adResync = 131072;//< (&H20000) ADODB.CursorOptionEnum
Const adSeek = 4194304;//< (&H400000) ADODB.CursorOptionEnum
Const adUpdate = 16809984;//< (&H1008000) ADODB.CursorOptionEnum
Const adUpdateBatch = 65536;//< (&H10000) ADODB.CursorOptionEnum
{}
//=============================================================================



//=============================================================================
// ADODB.DataTypeEnum
//=============================================================================
{}
Const adArray = 8192;//< (&H2000) ADODB.DataTypeEnum
Const adBigInt = 20;//< (&H14) ADODB.DataTypeEnum
Const adBinary = 128;//< (&H80) ADODB.DataTypeEnum
Const adBoolean = 11;//< ADODB.DataTypeEnum
Const adBSTR = 8;//< ADODB.DataTypeEnum
Const adChapter = 136;//< (&H88) ADODB.DataTypeEnum
Const adChar = 129;//< (&H81) ADODB.DataTypeEnum
Const adCurrency = 6;//< ADODB.DataTypeEnum
Const adDate = 7;//< ADODB.DataTypeEnum
Const adDBDate = 133;//< (&H85) ADODB.DataTypeEnum
Const adDBTime = 134;//< (&H86) ADODB.DataTypeEnum
Const adDBTimeStamp = 135;//< (&H87) ADODB.DataTypeEnum
Const adDecimal = 14;//< ADODB.DataTypeEnum
Const adDouble = 5;//< ADODB.DataTypeEnum
Const adEmpty = 0;//< ADODB.DataTypeEnum
Const adError = 10;//< ADODB.DataTypeEnum
Const adFileTime = 64;//< (&H40) ADODB.DataTypeEnum
Const adGUID = 72;//< (&H48) ADODB.DataTypeEnum
Const adIDispatch = 9;//< ADODB.DataTypeEnum
Const adInteger = 3;//< ADODB.DataTypeEnum
Const adIUnknown = 13;//< ADODB.DataTypeEnum
Const adLongVarBinary = 205;//< (&HCD) ADODB.DataTypeEnum
Const adLongVarChar = 201;//< (&HC9) ADODB.DataTypeEnum
Const adLongVarWChar = 203;//< (&HCB) ADODB.DataTypeEnum
Const adNumeric = 131;//< (&H83) ADODB.DataTypeEnum
Const adPropVariant = 138;//< (&H8A) ADODB.DataTypeEnum
Const adSingle = 4;//< ADODB.DataTypeEnum
Const adSmallInt = 2;//< ADODB.DataTypeEnum
Const adTinyInt = 16;//< (&H10) ADODB.DataTypeEnum
Const adUnsignedBigInt = 21;//< (&H15) ADODB.DataTypeEnum
Const adUnsignedInt = 19;//< (&H13) ADODB.DataTypeEnum
Const adUnsignedSmallInt = 18;//< (&H12) ADODB.DataTypeEnum
Const adUnsignedTinyInt = 17;//< (&H11) ADODB.DataTypeEnum
Const adUserDefined = 132;//< (&H84) ADODB.DataTypeEnum
Const adVarBinary = 204;//< (&HCC) ADODB.DataTypeEnum
Const adVarChar = 200;//< (&HC8) ADODB.DataTypeEnum
Const adVariant = 12;//< ADODB.DataTypeEnum
Const adVarNumeric = 139;//< (&H8B) ADODB.DataTypeEnum
Const adVarWChar = 202;//< (&HCA) ADODB.DataTypeEnum
Const adWChar = 130;//< (&H82) ADODB.DataTypeEnum
{}
//=============================================================================

//=============================================================================
// ADODB.EditModeEnum
//=============================================================================
{}
Const adEditAdd = 2;//< ADODB.EditModeEnum
Const adEditDelete = 4;//< ADODB.EditModeEnum
Const adEditInProgress = 1;//< ADODB.EditModeEnum
Const adEditNone = 0;//< ADODB.EditModeEnum
{}
//=============================================================================

//=============================================================================
// ADODB.EventStatusEnum
//=============================================================================
{}
Const adStatusCancel = 4;//< ADODB.EventStatusEnum
Const adStatusCantDeny = 3;//< ADODB.EventStatusEnum
Const adStatusErrorsOccurred = 2;//<ADODB.EventStatusEnum
Const adStatusOK = 1;//<ADODB.EventStatusEnum
Const adStatusUnwantedEvent = 5;//<ADODB.EventStatusEnum
{}
//=============================================================================

//=============================================================================
// ADODB.LockTypeEnum
//=============================================================================
{}
Const adLockBatchOptimistic = 4;//<ADODB.LockTypeEnum
Const adLockOptimistic = 3;//<ADODB.LockTypeEnum
Const adLockPessimistic = 2;//<ADODB.LockTypeEnum
Const adLockReadOnly = 1;//<ADODB.LockTypeEnum
{}
//=============================================================================

//=============================================================================
// ADODB.ObjectStateEnum
//=============================================================================
{}
Const adStateClosed = 0;//< ADODB.ObjectStateEnum
Const adStateConnecting = 2;//< ADODB.ObjectStateEnum
Const adStateExecuting = 4;//< ADODB.ObjectStateEnum
Const adStateFetching = 8;//< ADODB.ObjectStateEnum
Const adStateOpen = 1;//< ADODB.ObjectStateEnum
{}
//=============================================================================

//=============================================================================
// ADODB.RecordStatusEnum
//=============================================================================
{}
Const adRecCanceled = 256;//< (&H100) ADODB.RecordStatusEnum
Const adRecCantRelease = 1024;//< (&H400) ADODB.RecordStatusEnum
Const adRecConcurrencyViolation = 2048;//< (&H800) ADODB.RecordStatusEnum
Const adRecDBDeleted = 262144;//< (&H40000) ADODB.RecordStatusEnum
Const adRecDeleted = 4;//< ADODB.RecordStatusEnum
Const adRecIntegrityViolation = 4096;//< (&H1000) ADODB.RecordStatusEnum
Const adRecInvalid = 16;//< (&H10) ADODB.RecordStatusEnum
Const adRecMaxChangesExceeded = 8192;//< (&H2000) ADODB.RecordStatusEnum
Const adRecModified = 2;//< ADODB.RecordStatusEnum
Const adRecMultipleChanges = 64;//< (&H40) ADODB.RecordStatusEnum
Const adRecNew = 1;//< ADODB.RecordStatusEnum
Const adRecObjectOpen = 16384;//< (&H4000) ADODB.RecordStatusEnum
Const adRecOK = 0;//< ADODB.RecordStatusEnum
Const adRecOutOfMemory = 32768;//< (&H8000) ADODB.RecordStatusEnum
Const adRecPendingChanges = 128;//< (&H80) ADODB.RecordStatusEnum
Const adRecPermissionDenied = 65536;//< (&H10000) ADODB.RecordStatusEnum
Const adRecSchemaViolation = 131072;//< (&H20000) ADODB.RecordStatusEnum
Const adRecUnmodified = 8;//< ADODB.RecordStatusEnum
{}
//=============================================================================


//=============================================================================
// ADODB.RecordTypeEnum
//=============================================================================
{}
Const adCollectionRecord = 1; //< ADODB.RecordTypeEnum
Const adSimpleRecord = 0;//< ADODB.RecordTypeEnum
Const adStructDoc = 2;//< ADODB.RecordTypeEnum
{}
//=============================================================================











//=============================================================================
{}
// Manages list of JADO_FIELD
Type JADO_FIELDS = Class(JFC_XDL) 
{}
//=============================================================================
  //---------------------------------------------------------------------------
  {}
  // Override these two if you make descendant of JFC_DLITEM
  // with more fields or something.
  Function pvt_CreateItem: JADO_FIELD; override;
  Procedure pvt_DestroyItem(p_lp:pointer); override;
  {}
  //---------------------------------------------------------------------------
  {}
  Public
  Constructor create; 
  Destructor Destroy; override;  

  function Get_Field(p_saName: ansistring): JADO_FIELD;
  function Get_FieldCS(p_saName: ansistring): JADO_FIELD;
End;
//=============================================================================



//=============================================================================
{}
Type JADO_ERROR = Class(JFC_DLITEM)
//=============================================================================
  // Description: string; JFC_XDLITEM.saDesc will suffice
  {}
  i8NativeError: Int64;
  i8Number: Int64;
  saSource: AnsiString;
  saSQLState: String;
  Constructor create; 
  Destructor destroy; override; 
End;
//=============================================================================



//=============================================================================
{}
// Manages list of JADO_ERROR
Type JADO_ERRORS = Class(JFC_DL) 
//=============================================================================
  // procedure Clear - JFC_DL.DELETEALL should suffice.
  // Count - JFC_DL.ListCount Should Suffice
  // Item - JADO_ERROR(lpItem).WhatEver  Should Suffice
  // Refresh... hmm... no idea
  
  //---------------------------------------------------------------------------
  // Override these two if you make descendant of JFC_DLITEM
  // with more fields or something.
  {}
  Function pvt_CreateItem: JADO_ERROR; override; // WERE Virtuals
  Procedure pvt_DestroyItem(p_lp:pointer); override; // Were Virtuals
  {}
  //---------------------------------------------------------------------------
  
  Public
  Constructor create; 
  Destructor Destroy; override;
  Procedure AppendItem_Error(
    p_i8NativeError: Int64;
    p_i8Number: Int64;
    p_saSource: AnsiString;
    p_saSQLState: String;
    p_bDropToLog: Boolean
  );
End;
//=============================================================================












//=============================================================================
{}
Type JADO_CONNECTION = Class
//=============================================================================
  ID: ansistring; // UID In jdconnection stored as string
  JDCon_JSecPerm_ID: ansistring;// UID of Required Permission
  
  u2DbmsID: word; {< Used to determine what DBMS for apps that want to
   handle different DBMS app differently. This Value is ONLY a reference 
   so each instantiated connection has its own value to see what was used to 
   create it. By allowing each instantiated connection to hold this value, 
   applications (designed to be thread safe) can decipher what the underlying
   dbms is without having to refer to the rtConnection structure that was used
   to create it - whose values may change. This is a "memory" of what the DBMS 
   for this instant was/is.}
  {}
  Function CloseCon:Boolean;
  public
  {}
  saConnectionString: AnsiString;
  {}
  saDefaultDatabase: AnsiString;
  {}
  Errors: JADO_Errors;
  {}
  Function OpenCon(p_saConnectionString: AnsiString):Boolean;
  Function OpenCon: boolean; //< uses internal values
  {}
  
  public
  {}
  saProvider: AnsiString;
  {}
  i4State: LongInt; //< STATE: ADODB.ObjectStateEnum - Default: adStateClosed
  saVersion: AnsiString; //< ADODB.Connection.VERSION

  
  
  u2DrivID: word;{< (0=ODBC) For when ODBC isn't the connection method,
   which DBMS driver. This is a Direct Take off from the JADO.rtConnection
   Connection Record Type. The values are the Same.}

  {}
  saMyUsername: AnsiString;//< GENERIC - Used by Open Connection
  saMyPassword: AnsiString;//< GENERIC - Used by Open Connection
  saMyConnectString: AnsiString;//< GENERIC - Used by Open Connection
  saMyDatabase: AnsiString;//< GENERIC - Used by Open Connection
  saMyServer: AnsiString;//< GENERIC - Used by Open Connection
  u4MyPort: cardinal;
  {}
  {$IFDEF ODBC}
  ODBCDBHandle   : SQLHandle; //< For ODBC Connection
  ODBCStmtHandle : SQLHSTMT;  //< Used for executing Commands, the RecordSet Object will uses this as well.
  {$ENDIF}
  {}
  
  Public
  {}
  Constructor create; // OVERRIDE BUT INHERIT
  {}
  Constructor createcopy(p_JADOC: JADO_CONNECTION); // OVERRIDE BUT INHERIT
  {}
  procedure pvt_Init;
  {}
  Destructor Destroy; override;  // OVERRIDE BUT INHERIT
  {}
  {$IFDEF ODBC}
  Procedure ODBCSQLGetDiag(
    p_SQLHandleType: LongInt; 
    p_SQLHandle: pointer;
    p_i8Number: Int64;
    p_saMsg: AnsiString;
    p_saSource: AnsiString;
    p_bAll: Boolean;
    p_bDropToLog: Boolean
  );
  {$ENDIF}
  {}
  // This function handles "Scrubbing" textual (and numerical for MySQL) data values. 
  // This version of this function utilizes the cnDBMS_?????? information about the
  // connection to determine how it should escape the values you send.
  // !! NOTE: THIS Function Puts the appropriate Quotes on For YOU!
  Function saDBMSScrub(p_sa: AnsiString): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // This basically is sent one of the cnDBMS_?????? constants to determine
  // how to escape texual data bound for a database. 
  // !! NOTE: THIS Puts the Quotes on For you!
  Function saDBMSDateScrub(p_sa: AnsiString): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // This basically is sent one of the cnDBMS_?????? constants to determine
  // how to escape texual data bound for a database. 
  // !! NOTE: THIS Puts the Quotes on For you!
  Function saDBMSDateScrub(p_dt: tdatetime): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // This basically is sent one of the cnDBMS_?????? constants to determine
  // how to escape texual data bound for a database. 
  // !! NOTE: THIS Puts the Quotes on For you!
  Function saDBMSDateScrub(p_ts: ttimestamp): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // Returns Proper boolean representation for the connected DBMS  
  Function saDBMSBoolScrub(p_sa: ansistring): AnsiString;
  //---------------------------------------------------------------------------
  {}
  // Returns Proper boolean representation for the connected DBMS  
  Function saDBMSBoolScrub(p_b: boolean): AnsiString;
  {}
  // Returns Proper Integer representation for the passed DBMS  
  // Note: Same as it's like named counterpart except this version will return
  // 'null' if 'NULL' is passed to is as a string .. and if its not a null,
  // then the function uses the i8Val(ansistring) function to convert 
  // p_sa parameter to an integer.
  function saDBMSIntScrub(p_sa: ansistring): ansistring;  
  {}
  // Returns Proper Integer representation for the passed DBMS  
  function saDBMSIntScrub(p_i8: int64): ansistring;  
  //---------------------------------------------------------------------------
  {}
  // Returns Proper Decimal representation for the passed DBMS  
  // Note: Same as it's like named counterpart except this version will return
  // 'null' if 'NULL' is passed to is as a string .. and if its not a null,
  // then the function uses the i8Val(ansistring) function to convert 
  // p_sa parameter to an integer.
  function saDBMSDecScrub(p_sa: ansistring): ansistring;  
  //---------------------------------------------------------------------------
  {}
  // Returns Proper Unsigned Integer representation for the passed DBMS
  // Note: Same as it's like named counterpart except this version will return
  // 'null' if 'NULL' is passed to is as a string .. and if its not a null,
  // then the function uses the u8Val(ansistring) function to convert 
  // p_sa parameter to an integer.
  function saDBMSUIntScrub(p_sa: ansistring): ansistring;  
  //---------------------------------------------------------------------------
  {}
  // Returns Proper Unsigned Integer representation for the passed DBMS
  // Note: Same as it's like named counterpart except this version will return
  // 'null' if 'NULL' is passed to is as a string .. and if its not a null,
  // then the function uses the u8Val(ansistring) function to convert
  // p_sa parameter to an integer.
  function saDBMSUIntScrub(p_u8: UInt64): ansistring;
  //---------------------------------------------------------------------------
  {}
  // Returns proper wildcard char for like clauses for the passed DBMS
  Function saDBMSWild: AnsiString;
  //---------------------------------------------------------------------------
  {}
  // Properly Encloses DBMS Object names
  function saDBMSEncloseObjectName(p_saObjectName: ansistring): ansistring;
  //---------------------------------------------------------------------------
  {}
  // Cleans Object names to prevent using object names that are keywords or contain illformed names
  // puncuation, first character is a number etc.
  function saDBMSCleanObjectName(p_saObjectName: ansistring): AnsiString;

  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  // BEGIN JADO_DATASOURCE MERGE
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  public
  saName: AnsiString;
  saDesc: AnsiString;
  saDSN: AnsiString;
  saUserName: AnsiString;
  saPassword: AnsiString;
  saDriver: AnsiString; //< ODBC Driver Name (Win32 Specific Maybe)
  saServer: AnsiString;
  saDatabase: AnsiString;
  bConnected: Boolean;
  bConnecting: Boolean;
  bInUse: Boolean;{< Set to True and false by user and timer
                     Timer IGNORES if set to TRUE - This timer
                     is only SchemaMaster Specific.}
  bFileBasedDSN: Boolean; //< file based DSN, nothing to do with saving connection as file
  saDSNFileName: AnsiString;
  saConnectString: ansistring;{< This is NOT part of the legacy rtConnection
   structure. It is the actual connect string "compiled" from the various
   datapoints stored above, like username, password, etc.}
  //---------------------------------------------------------------------------
  // Above are the fields in the order of the legacy rtConnection record structure   
  //---------------------------------------------------------------------------
  {}
  // Load Jegas API DBMS Connection from File - doesn't automatically overwrite
  // existing file.
  function bSave(p_saFileName: AnsiString): Boolean;//< was bSaveConnectionToFile
  {}
  //---------------------------------------------------------------------------
  {}
  // Save Jegas API DBMS Connection from File. Optionally overwritines existing
  // file.
  Function bSave(p_saFileName: AnsiString; p_bOverWriteAlways: Boolean): boolean;//<was bSaveConnectionToFile
  {}
  //---------------------------------------------------------------------------
  {}
  // Load Jegas API DBMS Connection from File
  Function bLoad( p_saFileName: AnsiString): Boolean;
  {}
  //---------------------------------------------------------------------------
  {}
  Function bConnectTo:Boolean;//<was bConnectToCon
  {}
  //---------------------------------------------------------------------------
  {}
  Function bClose:Boolean;//<was bCloseConnection
  {}
  //---------------------------------------------------------------------------
  {}
  Function saBuildConnectString: ansistring; 
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  // END JADO_DATASOURCE MERGE
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  {}
  // If bJAS is set to true before opening this connection, and 
  // JASTABLEMATRIX is nil, then it is instantiated and a query is 
  // made to the connection after it opens to gather the table list from 
  // a table named "jtable" that is JAS specific. This entire table is 
  // recorded into the matrix for look ups germane to JAS internal operations
  // where the table name and it's ID in the system needs to be referred often.
  // Closing a connection will not change this classes contents however subsequent
  // connection opens will. If the class is already instatiated it will be emptied.
  // if the class has not yet been instatiated, it will be.
  // destruction of the class doesn't happen until the instance of JADO_CONNECTION
  // is destroyed.
  public
  JASTABLEMATRIX: JFC_MATRIX;
  // used to indicate (when connection opened via OpenCon (which uses internal values
  // versus passed in ODBC connection info) should perform JAS specific tasks
  bJAS: boolean;
  // Set to true if this class was created as a copy. Note that this isn't
  // important for most things in this class because a TRUE copy is made EXCEPT for the 
  // the JAS specfic bits. If a connection is a JAS connection, then data is gathered
  // aboyut the JAS system that is needed; but should not be replicated accross
  // copies as it would be a gross waste of system resources to do so. So this flag
  // is used to control how the JAS related constructs are handled in this regard; e.g.
  // how and whether or not classes are created and or destroyed etc.
  function bIsCopy: boolean;
  // This is a reference to the Original Connection the copy was made from.
  public
  OrigJADOC: JADO_CONNECTION;
  // This returns the JAS table ID. The Class needs to have the bJAS set to true
  // before calling JADO_CONNECTION.OpenCon for this to work properly.
  // Note: you can optionally pass table id in the p_saTable parameter
  // instead of the table name if its easier for a particular
  // purpose. We recommend using names so code self documents but it is easy to 
  // envision scenarios where the ID is already readily available in code.
  // p_u8Caller is an unique number (YYYYMMDDHHMM) used to track problems down...
  // like who called this routine.
  function saGetTableID(p_saJDConnectionID, p_saTable: ansistring; p_u8Caller: UInt64):ansistring;

  // This function returns the Table Name associated with the connection. Pass it the
  // Table ID you are looking for. 
  // Note: you can optionally pass the table name in the p_saTableID parameter 
  // instead of the table ID if its easier for a particular
  // purpose.
  function saGetTable(p_saTableID: ansistring):ansistring;
  
  // This function works like saGetTableID except it returns the Table's Column Prefix.
  function saGetColumnPrefix(p_saJDConnectionID, p_saTable: ansistring):ansistring;
  
  // This function returns the jcolumn UID for the given connection, table, and column
  // Note: you can optionally pass table id and column id's in their respective 
  // parameters instead of the table name or column name if its easier for a 
  // particular purpose. We recommend using names so code self documents but it 
  // is easy to envision scenarios where the ID is already readily available in code.
  function saGetColumnID(
    p_JDConnection_ID: ansistring;
    p_JTable_Name: ansistring;
    p_JColumn_Name: Ansistring
  ): ansistring;
  
  // This function just renders the Errors XDL into reasonable HTML output
  // returned as a string. It doesn't render a complete page - just some
  // tags - dumping all errors in the DL.
  function saRenderHTMLErrors: ansistring;

  // returns a record count for the specified table/view and where clause combination.
  function u8GetRowCount(p_saTable: ansistring; p_saWhereClauseOrBlank: ansistring; p_u8Caller: UInt64): UInt64;

  // returns true if specified table exists
  function bTableExists(p_saTable: ansistring; p_u8Caller: UInt64): boolean;

  function bDropTable(p_saTable: ansistring; p_u8Caller: UInt64): boolean;
  function bDropView(p_saTable: ansistring; p_u8Caller: UInt64): boolean;

  
  // MYSQL Specific Way to dynamically add a column... 
  // This function Does check if column exists. if it does it modifies the existing column.
  function bAddColumn(
    p_saTable: ansistring;
    p_saColumn: Ansistring;
    p_saColumnDefinition: ansistring;
    p_u8Caller: UInt64
  ): boolean;

  function bColumnExists(
    p_saTable: ansistring;
    p_saColumn: Ansistring;
    p_u8Caller: UInt64
  ): boolean;

  function bCreateTable(p_saTable: ansistring; p_saDDL: ansistring): boolean;

  function saGetPKeyColumn(p_lpJADOC: pointer; p_saTable: ansistring; p_u8Caller: UInt64):ansistring;
  function saGetPKeyColumnWTableID(p_lpJADOC: pointer; p_sTableID: string;p_u8Caller: UInt64):ansistring;
  function saGetColumn(p_lpJADOC: pointer; p_sUID: string;p_u8Caller: UInt64): ansistring;

  // returns a single value, NULL, or blank. Blank MAY indicate No Record Found.
  // this is for quick single field lookups.
  function saGetValue(p_saTable: ansistring; p_saField: ansistring; p_saWhereClauseOrBlank: ansistring):ansistring;



End;
//=============================================================================



//=============================================================================
{}
Type JADO_RECORD=Class(JFC_XDLITEM)
//=============================================================================
  //vActiveConnection: Variant;
  {}
  ActiveConnection: JADO_CONNECTION;
  {}
  Fields: JADO_FIELDS;
  {}
  saParentURL: AnsiString; //< No Clue
  {}
  i4RecordType: LongInt; //< vb ADODB.RecordTypeEnum
  {}
  // Property Source As Variant  
  // Reference: http://docs.sun.com/source/817-2514-10/Ch11_ADO123.html
  // The source for the data in a Recordset object (Command object, SQL statement, table name, or stored procedure).
  //
  // Source Property Return Values (ADO Recordset Object):
  // Sets a String value OR Command Object reference; returns only a String value.
  //
  // Source Property Remarks (ADO Recordset Object)
  // Use the Source Property To specify a data source For a Recordset 
  // Object using one Of the following: an ADO Command Object variable, 
  // an SQL statement, a stored Procedure, OR a table name. The Source 
  // Property is read/Write For closed Recordset objects AND read-only 
  // For open Recordset objects.
  //
  // If you Set the Source Property To a Command Object, the ActiveConnection 
  // Property Of the Recordset Object will inherit the value Of the 
  // ActiveConnection Property For the specified Command Object. However, 
  // reading the Source Property does NOT return a Command Object; instead, 
  // it returns the CommandText Property Of the Command Object To which 
  // you Set the Source Property.
  //
  // If the Source Property is an SQL statement, a stored Procedure, OR a 
  // table name, you can optimize performance by passing the appropriate 
  // Options argument With the ADO Recordset Object Open Method call.
  //


  {}
  i4State: LongInt; //< VB ADODB.ObjectStateENum (Usually 1=open, 0 Closed)
  Constructor create; //< OVERRIDE BUT INHERIT
  Destructor Destroy; override; //< OVERRIDE BUT INHERIT
End;
//=============================================================================





//=============================================================================
{}
Type JADO_RECORDSET = Class(JFC_XDL)
//=============================================================================
  {}
  u2DBMSID: Word;
  Fields: JADO_FIELDS;
  {}
  ActiveConnection: JADO_CONNECTION;
  {}
  Function Close: Boolean;
  {}
  public
  i4EditMode: LongInt;//< ADODB.EditModeEnum
  {}
  Function pvt_read_eol: Boolean;
  Property EOL: Boolean read pvt_read_eol;
  public
  pvt_bEOL: Boolean;
  {}
  i4LockType: LongInt;//< LOCKTYPE: VB ADODB.LockTypeEnum;
  {}
  u8MaxRecords: Uint64; {< ADO_LONGPTR (in vb) This field
   The maximum number Of records To return To a recordset from a query. 
   MaxRecords Property Return Values: Sets OR returns a Long value. Default is zero (no limit).
   MaxRecords Property Remarks:
   Use the MaxRecords Property To limit the number Of records the provider 
   returns from the data source. The Default setting Of this Property is 
   zero, which means the provider returns all requested records. The 
   MaxRecords Property is read/Write when the recordset is closed AND 
   read-only when it is open.}
  {}
  Function MoveNext: Boolean;
  {}
  // Generic Open RecordSet
  Function Open(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION; p_u8Caller: UInt64):Boolean;
  {}
  // Generic Open Record Set with third parameter to allow LOGGING ERRORS
  // (true) or not logging errors (false). Example: Record Locking doesn't
  // need error log report - its expected to fail if a lock already in place.
  // Note that errors with the connection not being open or the recordset
  // being already in use - errors like that will still be reported.
  // just SQL errors will be stiffled in p_bLogError is set to true.
  Function Open(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION; p_bLogError: boolean; p_u8Caller: UInt64):Boolean;
  {}
  // PRIVATE - Use OPEN.
  {$IFDEF ODBC}
  Function OpenODBC(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION; p_bLogError: boolean; p_u8Caller: UInt64):Boolean;
  {$ENDIF}
  
  // PRIVATE - Use OPEN.
  Function OpenMySQL(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION; p_bLogError: boolean; p_u8Caller: UInt64):Boolean;
  Function bMySQLFetchRecord(Var p_oADOC: JADO_CONNECTION): Boolean;
  Procedure MySQLShowRecord;//< private, does dump to std out
  {}
  {$IFDEF ODBC}
  Function  bODBCFetchRecord(p_oADOC: jado_connection; Var p_i2ODBCResult:SmallInt): Boolean;//<private
  Procedure ODBCShowRecord;//< private - does dump to stdout
  {$ENDIF}
  {}  
  public
  {}
  i4State: LongInt; //< VB ADODB.State (Probably ADODB.ObjectStateENum Values)
  i4Status: LongInt; //< VB ADODB.Status ADODB.RecordStatusEnum
  //---------------------------------------------------------------------------
  {}
  // Override these two if you make descendant of JFC_DLITEM
  // with more fields or something.
  {}
  Function pvt_CreateItem: JADO_RECORD; override; 
  Procedure pvt_DestroyItem(p_lp:pointer); override; 
  {}
  //---------------------------------------------------------------------------
  
  public
  u2DrivID: word; {< when a recordset is OPEN, this is copied from
   the Connection object - as a reference on how to behave while open.
   When the recordset is CLOSED, it is cleared to ZERO. }
  {}
  // ODBCSTUFF
  {}
  {$IFDEF ODBC}
  ODBCSQLHSTMT: SQLHSTMT; //< ODBC Statement Handle
  {$ENDIF}
  ODBCCommandType: longint;// ZERO Means Regular SQL Statement ( SQLPrepare )
                           // cnODBC_SQL = 0 = NORMAL SQL STATEMENT SQLPrepare()
                           // cnODBC_SQLTables = 1 = SHOW TABLES - SQLTables()
                           // cnODBC_SQLColumns = 2 = SHOW Columns - SQLColumns()
                           // cnODBC_SQLColumnPrivileges = 3 = COLUMN Privileges - SQLColumnPrivileges()
                           // cnODBC_SQLStatistics = 4 = TABLE Stats and Indexs - SQLStatistics()
                           // cnODBC_SQLTablePrivileges = 5 = Table Privileges - SQLTablePrivileges()
  {}
  rMySQL: st_mysql;//TMYSQL;
   {< NOTE: This WAS a connection THING, but has been moved HERE
   for Thread Safety in MySQL4 Driver mode. Note, other things about sharing 
   connections between threads may be problematic.}
  
  lpMySQLResults : PMYSQL_RES;  
  lpMySQLPtr: pointer;  
  lpMySQLHost:pointer;
  lpMySQLUser:pointer;
  lpMySQLPasswd:pointer;
  
  aRowBuf: MYSQL_ROW;//TMySQL_ROW;
  u4Columns: dword;
  u4Rows: dword;  
  u4RowsLeft: dword;
  u4RowsRead: dword;
  
  Public
  Constructor create; //< OVERRIDE BUT INHERIT
  Destructor Destroy; override;  //< OVERRIDE BUT INHERIT
  
  {}
  // This function just saves an open recordset (current record position to end) 
  // to a CSV file.
  function bSaveResultsAsCSVFile(p_saFilename: ansistring; p_saTextDelimiter: ansistring; var p_u2IOresult: word): boolean;

  {}
  {$IFDEF ODBC}
  // This function is a preparser for SQL commands for effecting how the command is 
  // processed. If the command is a Jegas Specific Command - that happens... other
  // wise the SQL is passed through to the connected DBMS through the appropriate API.
  Function Jegas_SQL_Wedge(
    p_saCmd: ansistring;
    var p_oADOC: JADO_CONNECTION;
    var saUpCase: ansistring;
    var SQL_Catalog: ANSISTRING;
    var SQL_Schema: ansistring;
    var SQL_Table: ansistring;
    var SQL_TableTypeOrCol: ansistring;
    var lpSQL_Catalog: pointer;
    var lpSQL_Schema: pointer;
    var lpSQL_Table: pointer;
    var lpSQL_TableTypeOrCol: pointer;
    var lenSQL_Catalog: longint;
    var lenSQL_Schema: longint;
    var lenSQL_Table: longint;
    var lenSQL_TableTypeOrCol: longint;
    var SQL_Unique: word;
    var SQL_Reserved: word;
    var saODBCCommandType: ansistring
  ): Boolean;
  {$ENDIF}
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


//*****************************************************************************
//=============================================================================
//*****************************************************************************
// !#!Declarations 
//*****************************************************************************
//=============================================================================
//*****************************************************************************

//=============================================================================
//=============================================================================
//=============================================================================
// BEGIN                          TJADO
//=============================================================================
//=============================================================================
//=============================================================================

//=============================================================================
constructor TJADO.create;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.create;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  {$IFDEF ODBC}
  ODBCDSNXDL:=nil;
  ODBCEnvHandle:=nil;
  i4ODBCConCount:=0;
  {$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
destructor TJADO.destroy;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.destroy;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  {$IFDEF ODBC}
  if(ODBCDSNXDL<>nil)then
  begin
    ODBCDSNXDL.destroy;ODBCDSNXDL:=nil;
  end;
  if(ODBCEnvHandle<>nil)then 
  begin 
    SQLFreeHandle(SQL_HANDLE_ENV,ODBCEnvHandle);
    ODBCEnvHandle:=nil;
  end;  
  {$ENDIF}
  Inherited;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
Function TJADO.saBuildConnectString( 
  p_saDSN: AnsiString;
  p_saDriver: AnsiString; 
  p_saServer: AnsiString; 
  p_saUserName: AnsiString; 
  p_saPassword: AnsiString; 
  p_saDatabase: AnsiString; 
  p_bFileBased: Boolean;
  p_u2DrivID: word
): AnsiString;
//=============================================================================
Var 
  saConnect: AnsiString;
  saADOConnect: AnsiString;
  //saDAOConnect: AnsiString;
  saDSN: AnsiString;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saBuildConnectString';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  saDSN:='';
  saConnect:='';
  saADOConnect:='';
  //saDAOConnect:='';
  
  If (Length(p_saDSN) > 0) and (p_u2DrivID=cnDriv_ODBC) Then  // u2DrivID=0 = ODBC
  Begin
    saDSN:= 'DSN=' + p_saDSN + ';';
  End
  Else
  Begin
    saConnect:=saConnect + 'Driver=' + p_saDriver + ';';
    If not p_bFileBased Then
    Begin
      saConnect:= saConnect + 'Server=' + p_saServer + ';';
    End;
  End;
  
  saConnect:=saConnect + 'UID=' + p_saUserName + ';';
  saConnect:=saConnect + 'PWD=' + p_saPassword + ';';
  
  If Length(p_saDatabase) > 0 Then
  Begin
    If p_bFileBased Then
    Begin
      saConnect:= saConnect + 'DBQ=' + p_saDatabase + ';';
    End
    Else
    Begin
      saConnect:= saConnect + 'Database=' + p_saDatabase + ';';
    End;
  End;
  {$IFDEF WIN32}
  saADOConnect:= 'PROVIDER=MSDASQL;' + saDSN + saConnect;
  {$ELSE}
  saADOConnect:= saDSN + saConnect;
  {$ENDIF}
  //saDAOConnect:= 'ODBC;' + saDSN + saConnect;
  
  Result:=saADOConnect;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

{$IFDEF ODBC}
//=============================================================================
Function TJADO.ODBCSuccess (p_i2ODBCResult: SmallInt) : Boolean;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.ODBCSuccess(p_i2ODBCResult: SmallInt):Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=(p_i2ODBCResult=SQL_SUCCESS);// OR (p_i2ODBCResult=SQL_SUCCESS_WITH_INFO);
  //result:=(p_i2ODBCResult=SQL_SUCCESS) OR (p_i2ODBCResult=SQL_SUCCESS_WITH_INFO);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================
{$ENDIF}

//=============================================================================
// Returns Proper boolean representation for the passed DBMS  
Function TJADO.saDBMSBoolScrub(p_b: boolean; p_u2DbmsID: word): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSBoolScrub(p_b: boolean; p_iDbmsID: Longint): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  case p_u2DbmsID of
  cnDBMS_MYSQL: Begin
    if(p_b)then result:='1' else result:='0';
  end;
  cnDBMS_MSSQL,cnDBMS_MSAccess: Begin
    if(p_b)then result:='true' else result:='false';
  end;
  else begin
    JLog(cnLog_ERROR,200912261013,
      'TJADO.saDBMSBoolScrub - Unsupported DBMS ' + 
      'p_iDbmsID: '+inttostr(p_u2DbmsID), SOURCEFILE);
  end;
  end;//switch
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
// Returns Proper boolean representation for the passed DBMS  
Function TJADO.saDBMSBoolScrub(p_sa: ansistring; p_u2DbmsID: word): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSBoolScrub(p_sa: ansistring; p_iDbmsID: Longint): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  if(p_sa<>'NULL')then
  begin
    result:=saDBMSBoolScrub(bVal(p_sa),p_u2DbmsID);
  end
  else
  begin
    result:='null';
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
Function TJADO.saDBMSWild(p_u2DbmsID: word): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSWild(p_iDbmsID: Longint): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  case p_u2DbmsID of
  cnDBMS_MYSQL: result:='%';
  cnDBMS_MSSQL,cnDBMS_MSAccess: result:='*';
  else begin
    JLog(cnLog_ERROR,201002072224,
      'TJADO.saDBMSWild - Unsupported DBMS ' + 
      'p_iDbmsID: '+inttostr(p_u2DbmsID), SOURCEFILE);
  end;
  end;//switch
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
Function TJADO.saDBMSEncloseObjectName(p_saObjectName: ansistring; p_u2DbmsID: word): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSEncloseObjectName(p_saObjectName: ansistring; p_iDbmsID: Longint): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=trim(p_saObjectName);
  case p_u2DbmsID of
  cnDBMS_MSAccess, cnDBMS_Excel,cnDBMS_FoxPro: begin
    If pos(result, '[') = 0 Then
    begin
      result:= '[' + result + ']';
    End;
  end;
  cnDBMS_MySQL:  begin
    If pos(result, '`') = 0 Then
    begin
      result:= '`' + result + '`';
    End;
  end else begin
    JLog(cnLog_ERROR,201005022302,
      'TJADO.saDBMSEncloseObjectName - Unsupported DBMS ' + 
      'p_u2DbmsID: '+inttostr(p_u2DbmsID), SOURCEFILE);
  end;
  end;//switch
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
Function TJADO.saDBMSCleanObjectName(p_saObjectName: ansistring; p_u2DbmsID: word): AnsiString;
//=============================================================================
var
  sa: ansistring;
  saUpper: ansistring;
  bKeyword: boolean;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSCleanObjectName(p_saObjectName: ansistring; p_u2DbmsID: word): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // NOTE: p_iDBMSID isn't implemented yet but is here as a place holder to allow
  // adding code to make more DBMS specific decisions when cleaning object names.
  sa:=trim(p_saObjectName);
  saUpper:=uppercase(sa);
  bKEyWord:=false;  
  if not bKeyword then bKeyWord:=('ABSOLUTE'             =saUpper);
  if not bKeyword then bKeyWord:=('ACTION'               =saUpper);
  if not bKeyword then bKeyWord:=('ADD'                  =saUpper);
  if not bKeyword then bKeyWord:=('ALL'                  =saUpper);
  if not bKeyword then bKeyWord:=('ALLOCATE'             =saUpper);
  if not bKeyword then bKeyWord:=('ALTER'                =saUpper);
  if not bKeyword then bKeyWord:=('AND'                  =saUpper);
  if not bKeyword then bKeyWord:=('ANY'                  =saUpper);
  if not bKeyword then bKeyWord:=('ARE'                  =saUpper);
  if not bKeyword then bKeyWord:=('AS'                   =saUpper);
  if not bKeyword then bKeyWord:=('ASC'                  =saUpper);
  if not bKeyword then bKeyWord:=('ASSERTION'            =saUpper);
  if not bKeyword then bKeyWord:=('AT'                   =saUpper);
  if not bKeyword then bKeyWord:=('AUTHORIZATION'        =saUpper);
  if not bKeyword then bKeyWord:=('AVG'                  =saUpper);
  if not bKeyword then bKeyWord:=('BACKUP'               =saUpper);
  if not bKeyword then bKeyWord:=('BEGIN'                =saUpper);
  if not bKeyword then bKeyWord:=('BETWEEN'              =saUpper);
  if not bKeyword then bKeyWord:=('BIT'                  =saUpper);
  if not bKeyword then bKeyWord:=('BIT_LENGTH'           =saUpper);
  if not bKeyword then bKeyWord:=('BOTH'                 =saUpper);
  if not bKeyword then bKeyWord:=('BREAK'                =saUpper);
  if not bKeyword then bKeyWord:=('BROWSE'               =saUpper);
  if not bKeyword then bKeyWord:=('BULK'                 =saUpper);
  if not bKeyword then bKeyWord:=('BY'                   =saUpper);
  if not bKeyword then bKeyWord:=('CASCADE'              =saUpper);
  if not bKeyword then bKeyWord:=('CASCADED'             =saUpper);
  if not bKeyword then bKeyWord:=('CASE'                 =saUpper);
  if not bKeyword then bKeyWord:=('CAST'                 =saUpper);
  if not bKeyword then bKeyWord:=('CATALOG'              =saUpper);
  if not bKeyword then bKeyWord:=('CHAR'                 =saUpper);
  if not bKeyword then bKeyWord:=('CHAR_LENGTH'          =saUpper);
  if not bKeyword then bKeyWord:=('CHARACTER'            =saUpper);
  if not bKeyword then bKeyWord:=('CHARACTER_'           =saUpper);
  if not bKeyword then bKeyWord:=('CHECK'                =saUpper);
  if not bKeyword then bKeyWord:=('CHECKPOINT'           =saUpper);
  if not bKeyword then bKeyWord:=('CLOSE'                =saUpper);
  if not bKeyword then bKeyWord:=('CLUSTERED'            =saUpper);
  if not bKeyword then bKeyWord:=('COALESCE'             =saUpper);
  if not bKeyword then bKeyWord:=('COLLATE'              =saUpper);
  if not bKeyword then bKeyWord:=('COLLATION'            =saUpper);
  if not bKeyword then bKeyWord:=('COLUMN'               =saUpper);
  if not bKeyword then bKeyWord:=('COMMIT'               =saUpper);
  if not bKeyword then bKeyWord:=('COMPUTE'              =saUpper);
  if not bKeyword then bKeyWord:=('CONNECT'              =saUpper);
  if not bKeyword then bKeyWord:=('CONNECTION'           =saUpper);
  if not bKeyword then bKeyWord:=('CONSTRAINT'           =saUpper);
  if not bKeyword then bKeyWord:=('CONSTRAINTS'          =saUpper);
  if not bKeyword then bKeyWord:=('CONTAINS'             =saUpper);
  if not bKeyword then bKeyWord:=('CONTAINSTABLE'        =saUpper);
  if not bKeyword then bKeyWord:=('CONTINUE'             =saUpper);
  if not bKeyword then bKeyWord:=('CONVERT'              =saUpper);
  if not bKeyword then bKeyWord:=('CORRESPON'            =saUpper);
  if not bKeyword then bKeyWord:=('COUNT'                =saUpper);
  if not bKeyword then bKeyWord:=('CREATE'               =saUpper);
  if not bKeyword then bKeyWord:=('CROSS'                =saUpper);
  if not bKeyword then bKeyWord:=('CURRENT'              =saUpper);
  if not bKeyword then bKeyWord:=('CURRENT_DATE'         =saUpper);
  if not bKeyword then bKeyWord:=('CURRENT_TIME'         =saUpper);
  if not bKeyword then bKeyWord:=('CURRENT_TIMESTAMP'    =saUpper);
  if not bKeyword then bKeyWord:=('CURRENT_USER'         =saUpper);
  if not bKeyword then bKeyWord:=('CURSOR'               =saUpper);
  if not bKeyword then bKeyWord:=('DATABASE'             =saUpper);
  if not bKeyword then bKeyWord:=('DATE'                 =saUpper);
  if not bKeyword then bKeyWord:=('DAY'                  =saUpper);
  if not bKeyword then bKeyWord:=('DBCC'                 =saUpper);
  if not bKeyword then bKeyWord:=('DEALLOCATE'           =saUpper);
  if not bKeyword then bKeyWord:=('DEC'                  =saUpper);
  if not bKeyword then bKeyWord:=('DECIMAL'              =saUpper);
  if not bKeyword then bKeyWord:=('DECLARE'              =saUpper);
  if not bKeyword then bKeyWord:=('DEFAULT'              =saUpper);
  if not bKeyword then bKeyWord:=('DEFERRABLE'           =saUpper);
  if not bKeyword then bKeyWord:=('DEFERRED'             =saUpper);
  if not bKeyword then bKeyWord:=('DELETE'               =saUpper);
  if not bKeyword then bKeyWord:=('DENY'                 =saUpper);
  if not bKeyword then bKeyWord:=('DESC'                 =saUpper);
  if not bKeyword then bKeyWord:=('DESCRIBE'             =saUpper);
  if not bKeyword then bKeyWord:=('DESCRIPTOR'           =saUpper);
  if not bKeyword then bKeyWord:=('DIAGNOSTICS'          =saUpper);
  if not bKeyword then bKeyWord:=('DING'                 =saUpper);
  if not bKeyword then bKeyWord:=('DISCONNECT'           =saUpper);
  if not bKeyword then bKeyWord:=('DISK'                 =saUpper);
  if not bKeyword then bKeyWord:=('DISTINCT'             =saUpper);
  if not bKeyword then bKeyWord:=('DISTRIBUTED'          =saUpper);
  if not bKeyword then bKeyWord:=('DOMAIN'               =saUpper);
  if not bKeyword then bKeyWord:=('DOUBLE'               =saUpper);
  if not bKeyword then bKeyWord:=('DROP'                 =saUpper);
  if not bKeyword then bKeyWord:=('DUMMY'                =saUpper);
  if not bKeyword then bKeyWord:=('DUMP'                 =saUpper);
  if not bKeyword then bKeyWord:=('ELSE'                 =saUpper);
  if not bKeyword then bKeyWord:=('END'                  =saUpper);
  if not bKeyword then bKeyWord:=('END-EXEC'             =saUpper);
  if not bKeyword then bKeyWord:=('ERRLVL'               =saUpper);
  if not bKeyword then bKeyWord:=('ESCAPE'               =saUpper);
  if not bKeyword then bKeyWord:=('EXCEPT'               =saUpper);
  if not bKeyword then bKeyWord:=('EXCEPTION'            =saUpper);
  if not bKeyword then bKeyWord:=('EXEC'                 =saUpper);
  if not bKeyword then bKeyWord:=('EXECUTE'              =saUpper);
  if not bKeyword then bKeyWord:=('EXISTS'               =saUpper);
  if not bKeyword then bKeyWord:=('EXIT'                 =saUpper);
  if not bKeyword then bKeyWord:=('EXTERNAL'             =saUpper);
  if not bKeyword then bKeyWord:=('EXTRACT'              =saUpper);
  if not bKeyword then bKeyWord:=('FALSE'                =saUpper);
  if not bKeyword then bKeyWord:=('FETCH'                =saUpper);
  if not bKeyword then bKeyWord:=('FILE'                 =saUpper);
  if not bKeyword then bKeyWord:=('FILLFACTOR'           =saUpper);
  if not bKeyword then bKeyWord:=('FIRST'                =saUpper);
  if not bKeyword then bKeyWord:=('FLOAT'                =saUpper);
  if not bKeyword then bKeyWord:=('FOR'                  =saUpper);
  if not bKeyword then bKeyWord:=('FORCE'                =saUpper);
  if not bKeyword then bKeyWord:=('FOREIGN'              =saUpper);
  if not bKeyword then bKeyWord:=('FOUND'                =saUpper);
  if not bKeyword then bKeyWord:=('FREETEXT'             =saUpper);
  if not bKeyword then bKeyWord:=('FREETEXTTABLE'        =saUpper);
  if not bKeyword then bKeyWord:=('FROM'                 =saUpper);
  if not bKeyword then bKeyWord:=('FULL'                 =saUpper);
  if not bKeyword then bKeyWord:=('FUNCTION'             =saUpper);
  if not bKeyword then bKeyWord:=('GET'                  =saUpper);
  if not bKeyword then bKeyWord:=('GLOBAL'               =saUpper);
  if not bKeyword then bKeyWord:=('GO'                   =saUpper);
  if not bKeyword then bKeyWord:=('GOTO'                 =saUpper);
  if not bKeyword then bKeyWord:=('GRANT'                =saUpper);
  if not bKeyword then bKeyWord:=('GROUP'                =saUpper);
  if not bKeyword then bKeyWord:=('HAVING'               =saUpper);
  if not bKeyword then bKeyWord:=('HOLDLOCK'             =saUpper);
  if not bKeyword then bKeyWord:=('HOUR'                 =saUpper);
  if not bKeyword then bKeyWord:=('IDENTITY'             =saUpper);
  if not bKeyword then bKeyWord:=('IDENTITY_INSERT'      =saUpper);
  if not bKeyword then bKeyWord:=('IDENTITYCOL'          =saUpper);
  if not bKeyword then bKeyWord:=('IF'                   =saUpper);
  if not bKeyword then bKeyWord:=('IMMEDIATE'            =saUpper);
  if not bKeyword then bKeyWord:=('IN'                   =saUpper);
  if not bKeyword then bKeyWord:=('INOUT'                =saUpper);
  if not bKeyword then bKeyWord:=('INDEX'                =saUpper);
  if not bKeyword then bKeyWord:=('INDICATOR'            =saUpper);
  if not bKeyword then bKeyWord:=('INITIALLY'            =saUpper);
  if not bKeyword then bKeyWord:=('INNER'                =saUpper);
  if not bKeyword then bKeyWord:=('INPUT'                =saUpper);
  if not bKeyword then bKeyWord:=('INSENSITIVE'          =saUpper);
  if not bKeyword then bKeyWord:=('INSERT'               =saUpper);
  if not bKeyword then bKeyWord:=('INT'                  =saUpper);
  if not bKeyword then bKeyWord:=('INTEGER'              =saUpper);
  if not bKeyword then bKeyWord:=('INTERSECT'            =saUpper);
  if not bKeyword then bKeyWord:=('INTERVAL'             =saUpper);
  if not bKeyword then bKeyWord:=('INTO'                 =saUpper);
  if not bKeyword then bKeyWord:=('IS'                   =saUpper);
  if not bKeyword then bKeyWord:=('ISOLATION'            =saUpper);
  if not bKeyword then bKeyWord:=('JOIN'                 =saUpper);
  if not bKeyword then bKeyWord:=('KEY'                  =saUpper);
  if not bKeyword then bKeyWord:=('KEYS'                 =saUpper);
  if not bKeyword then bKeyWord:=('KILL'                 =saUpper);
  if not bKeyword then bKeyWord:=('LANGUAGE'             =saUpper);
  if not bKeyword then bKeyWord:=('LAST'                 =saUpper);
  if not bKeyword then bKeyWord:=('LEADING'              =saUpper);
  if not bKeyword then bKeyWord:=('LEFT'                 =saUpper);
  if not bKeyword then bKeyWord:=('LENGTH'               =saUpper);
  if not bKeyword then bKeyWord:=('LEVEL'                =saUpper);
  if not bKeyword then bKeyWord:=('LIKE'                 =saUpper);
  if not bKeyword then bKeyWord:=('LINENO'               =saUpper);
  if not bKeyword then bKeyWord:=('LOAD'                 =saUpper);
  if not bKeyword then bKeyWord:=('LOCAL'                =saUpper);
  if not bKeyword then bKeyWord:=('LOWER'                =saUpper);
  if not bKeyword then bKeyWord:=('MATCH'                =saUpper);
  if not bKeyword then bKeyWord:=('MAX'                  =saUpper);
  if not bKeyword then bKeyWord:=('MIN'                  =saUpper);
  if not bKeyword then bKeyWord:=('MINUTE'               =saUpper);
  if not bKeyword then bKeyWord:=('MODULE'               =saUpper);
  if not bKeyword then bKeyWord:=('MONTH'                =saUpper);
  if not bKeyword then bKeyWord:=('NAMES'                =saUpper);
  if not bKeyword then bKeyWord:=('NATIONAL'             =saUpper);
  if not bKeyword then bKeyWord:=('NATURAL'              =saUpper);
  if not bKeyword then bKeyWord:=('NCHAR'                =saUpper);
  if not bKeyword then bKeyWord:=('NEXT'                 =saUpper);
  if not bKeyword then bKeyWord:=('NO'                   =saUpper);
  if not bKeyword then bKeyWord:=('NOCHECK'              =saUpper);
  if not bKeyword then bKeyWord:=('NONCLUSTERED'         =saUpper);
  if not bKeyword then bKeyWord:=('NOT'                  =saUpper);
  if not bKeyword then bKeyWord:=('NULL'                 =saUpper);
  if not bKeyword then bKeyWord:=('NULLIF'               =saUpper);
  if not bKeyword then bKeyWord:=('NUMERIC'              =saUpper);
  if not bKeyword then bKeyWord:=('OCTET_LENGTH'         =saUpper);
  if not bKeyword then bKeyWord:=('OF'                   =saUpper);
  if not bKeyword then bKeyWord:=('OFF'                  =saUpper);
  if not bKeyword then bKeyWord:=('OFFSETS'              =saUpper);
  if not bKeyword then bKeyWord:=('ON'                   =saUpper);
  if not bKeyword then bKeyWord:=('ONLY'                 =saUpper);
  if not bKeyword then bKeyWord:=('OPEN'                 =saUpper);
  if not bKeyword then bKeyWord:=('OPENDATASOURCE'       =saUpper);
  if not bKeyword then bKeyWord:=('OPENQUERY'            =saUpper);
  if not bKeyword then bKeyWord:=('OPENROWSET'           =saUpper);
  if not bKeyword then bKeyWord:=('OPENXML'              =saUpper);
  if not bKeyword then bKeyWord:=('OPTION'               =saUpper);
  if not bKeyword then bKeyWord:=('OR'                   =saUpper);
  if not bKeyword then bKeyWord:=('ORDER'                =saUpper);
  if not bKeyword then bKeyWord:=('OUTER'                =saUpper);
  if not bKeyword then bKeyWord:=('OUTPUT'               =saUpper);
  if not bKeyword then bKeyWord:=('OVER'                 =saUpper);
  if not bKeyword then bKeyWord:=('OVERLAPS'             =saUpper);
  if not bKeyword then bKeyWord:=('PAD'                  =saUpper);
  if not bKeyword then bKeyWord:=('PARTIAL'              =saUpper);
  if not bKeyword then bKeyWord:=('PERCENT'              =saUpper);
  if not bKeyword then bKeyWord:=('PLAN'                 =saUpper);
  if not bKeyword then bKeyWord:=('POSITION'             =saUpper);
  if not bKeyword then bKeyWord:=('PRECISION'            =saUpper);
  if not bKeyword then bKeyWord:=('PREPARE'              =saUpper);
  if not bKeyword then bKeyWord:=('PRESERVE'             =saUpper);
  if not bKeyword then bKeyWord:=('PRIMARY'              =saUpper);
  if not bKeyword then bKeyWord:=('PRINT'                =saUpper);
  if not bKeyword then bKeyWord:=('PRIOR'                =saUpper);
  if not bKeyword then bKeyWord:=('PRIVILEGES'           =saUpper);
  if not bKeyword then bKeyWord:=('PROC'                 =saUpper);
  if not bKeyword then bKeyWord:=('PROCEDURE'            =saUpper);
  if not bKeyword then bKeyWord:=('PUBLIC'               =saUpper);
  if not bKeyword then bKeyWord:=('RAISERROR'            =saUpper);
  if not bKeyword then bKeyWord:=('READ'                 =saUpper);
  if not bKeyword then bKeyWord:=('READTEXT'             =saUpper);
  if not bKeyword then bKeyWord:=('REAL'                 =saUpper);
  if not bKeyword then bKeyWord:=('RECONFIGURE'          =saUpper);
  if not bKeyword then bKeyWord:=('REFERENCES'           =saUpper);
  if not bKeyword then bKeyWord:=('RELATIVE'             =saUpper);
  if not bKeyword then bKeyWord:=('REPLICATION'          =saUpper);
  if not bKeyword then bKeyWord:=('RESTORE'              =saUpper);
  if not bKeyword then bKeyWord:=('RESTRICT'             =saUpper);
  if not bKeyword then bKeyWord:=('RETURN'               =saUpper);
  if not bKeyword then bKeyWord:=('REVOKE'               =saUpper);
  if not bKeyword then bKeyWord:=('RIGHT'                =saUpper);
  if not bKeyword then bKeyWord:=('ROLLBACK'             =saUpper);
  if not bKeyword then bKeyWord:=('ROWCOUNT'             =saUpper);
  if not bKeyword then bKeyWord:=('ROWGUIDCOL'           =saUpper);
  if not bKeyword then bKeyWord:=('ROWS'                 =saUpper);
  if not bKeyword then bKeyWord:=('RULE'                 =saUpper);
  if not bKeyword then bKeyWord:=('SAVE'                 =saUpper);
  if not bKeyword then bKeyWord:=('SCHEMA'               =saUpper);
  if not bKeyword then bKeyWord:=('SCROLL'               =saUpper);
  if not bKeyword then bKeyWord:=('SECOND'               =saUpper);
  if not bKeyword then bKeyWord:=('SECTION'              =saUpper);
  if not bKeyword then bKeyWord:=('SELECT'               =saUpper);
  if not bKeyword then bKeyWord:=('SESSION'              =saUpper);
  if not bKeyword then bKeyWord:=('SESSION_USER'         =saUpper);
  if not bKeyword then bKeyWord:=('SET'                  =saUpper);
  if not bKeyword then bKeyWord:=('SETUSER'              =saUpper);
  if not bKeyword then bKeyWord:=('SHUTDOWN'             =saUpper);
  if not bKeyword then bKeyWord:=('SIZE'                 =saUpper);
  if not bKeyword then bKeyWord:=('SMALLINT'             =saUpper);
  if not bKeyword then bKeyWord:=('SOME'                 =saUpper);
  if not bKeyword then bKeyWord:=('SPACE'                =saUpper);
  if not bKeyword then bKeyWord:=('SQL'                  =saUpper);
  if not bKeyword then bKeyWord:=('SQLCODE'              =saUpper);
  if not bKeyword then bKeyWord:=('SQLERROR'             =saUpper);
  if not bKeyword then bKeyWord:=('SQLSTATE'             =saUpper);
  if not bKeyword then bKeyWord:=('STAMP'                =saUpper);
  if not bKeyword then bKeyWord:=('STATISTICS'           =saUpper);
  if not bKeyword then bKeyWord:=('SUBSTRING'            =saUpper);
  if not bKeyword then bKeyWord:=('SUM'                  =saUpper);
  if not bKeyword then bKeyWord:=('SYSTEM_USER'          =saUpper);
  if not bKeyword then bKeyWord:=('TABLE'                =saUpper);
  if not bKeyword then bKeyWord:=('TEMPORARY'            =saUpper);
  if not bKeyword then bKeyWord:=('TEXTSIZE'             =saUpper);
  if not bKeyword then bKeyWord:=('THEN'                 =saUpper);
  if not bKeyword then bKeyWord:=('TIME'                 =saUpper);
  if not bKeyword then bKeyWord:=('TIMESTAMP'            =saUpper);
  if not bKeyword then bKeyWord:=('TIMEZONE_HOUR'        =saUpper);
  if not bKeyword then bKeyWord:=('TIMEZONE_MINUTE'      =saUpper);
  if not bKeyword then bKeyWord:=('TO'                   =saUpper);
  if not bKeyword then bKeyWord:=('TOP'                  =saUpper);
  if not bKeyword then bKeyWord:=('TRAILING'             =saUpper);
  if not bKeyword then bKeyWord:=('TRAN'                 =saUpper);
  if not bKeyword then bKeyWord:=('TRANSACTION'          =saUpper);
  if not bKeyword then bKeyWord:=('TRANSLATE'            =saUpper);
  if not bKeyword then bKeyWord:=('TRANSLATION'          =saUpper);
  if not bKeyword then bKeyWord:=('TRIGGER'              =saUpper);
  if not bKeyword then bKeyWord:=('TRIM'                 =saUpper);
  if not bKeyword then bKeyWord:=('TRUE'                 =saUpper);
  if not bKeyword then bKeyWord:=('TRUNCATE'             =saUpper);
  if not bKeyword then bKeyWord:=('TSEQUAL'              =saUpper);
  if not bKeyword then bKeyWord:=('UNION'                =saUpper);
  if not bKeyword then bKeyWord:=('UNIQUE'               =saUpper);
  if not bKeyword then bKeyWord:=('UNKNOWN'              =saUpper);
  if not bKeyword then bKeyWord:=('UPDATE'               =saUpper);
  if not bKeyword then bKeyWord:=('UPDATETEXT'           =saUpper);
  if not bKeyword then bKeyWord:=('UPPER'                =saUpper);
  if not bKeyword then bKeyWord:=('USAGE'                =saUpper);
  if not bKeyword then bKeyWord:=('USE'                  =saUpper);
  if not bKeyword then bKeyWord:=('USER'                 =saUpper);
  if not bKeyword then bKeyWord:=('USING'                =saUpper);
  if not bKeyword then bKeyWord:=('VALUE'                =saUpper);
  if not bKeyword then bKeyWord:=('VALUES'               =saUpper);
  if not bKeyword then bKeyWord:=('VARCHAR'              =saUpper);
  if not bKeyword then bKeyWord:=('VARYING'              =saUpper);
  if not bKeyword then bKeyWord:=('VIEW'                 =saUpper);
  if not bKeyword then bKeyWord:=('WAITFOR'              =saUpper);
  if not bKeyword then bKeyWord:=('WHEN'                 =saUpper);
  if not bKeyword then bKeyWord:=('WHENEVER'             =saUpper);
  if not bKeyword then bKeyWord:=('WHERE'                =saUpper);
  if not bKeyword then bKeyWord:=('WHILE'                =saUpper);
  if not bKeyword then bKeyWord:=('WITH'                 =saUpper);
  if not bKeyword then bKeyWord:=('WORK'                 =saUpper);
  if not bKeyword then bKeyWord:=('WRITE'                =saUpper);
  if not bKeyword then bKeyWord:=('WRITETEXT'            =saUpper);
  if not bKeyword then bKeyWord:=('YEAR'                 =saUpper);
  if not bKeyword then bKeyWord:=('ZONE'                 =saUpper);
  if bKeyWord then sa:=sa+'_KW';
  sa:=saSNRStr(sa,' ','_');
  sa:=saSNRStr(sa,'"','DQ');
  sa:=saSNRStr(sa,'''','SQ');
  sa:=saSNRStr(sa,'&','_N_');
  sa:=saSNRStr(sa,'%','PCT');
  sa:=saSNRStr(sa,'#','NO');
  sa:=saSNRStr(sa,'-','_');
  sa:=saSNRStr(sa,'*','_AST_');
  sa:=saSNRStr(sa,'\','_BSL_');
  sa:=saSNRStr(sa,'/','_FSL_');
  sa:=saSNRStr(sa,'=','_EQ_');
  sa:=saSNRStr(sa,'>','_GT_');
  sa:=saSNRStr(sa,'<','_LT_');
  sa:=saSNRStr(sa,'|','_P_');
  sa:=saSNRStr(sa,':','_col_');

  If Length(sa) > 0 Then
  begin
    If (LeftStr(sa, 1) >= '0') And (LeftStr(sa, 1) <= '9') Then
    begin
      sa := '_' + sa;
    End;
  End;
  result:=sa;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Function TJADO.saSchemaThingy(p_i4: longint): ansistring;
//=============================================================================
var sa: ansistring;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saSchemaThingy(p_i4: longint): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // NOTE: 45 ENUM Schema thingies
  case p_i4 of 
  adSchemaActions:                            sa:= csSchema_Actions                  ;
  adSchemaAsserts:                            sa:= csSchema_Asserts                  ;
  adSchemaCatalogs:                           sa:= csSchema_Catalogs                 ;
  adSchemaCharacterSets:                      sa:= csSchema_CharacterSets            ;
  adSchemaCheckConstraints:                   sa:= csSchema_CheckConstraints         ;
  adSchemaCollations:                         sa:= csSchema_Collations               ;
  adSchemaColumnPrivileges:                   sa:= csSchema_ColumnPrivileges         ;
  adSchemaColumns:                            sa:= csSchema_Columns                  ;
  adSchemaColumnsDomainUsage:                 sa:= csSchema_ColumnsDomainUsage       ;
  adSchemaCommands:                           sa:= csSchema_Commands                 ;
  adSchemaConstraintColumnUsage:              sa:= csSchema_ConstraintColumnUsage    ;
  adSchemaConstraintTableUsage:               sa:= csSchema_ConstraintTableUsage     ;
  adSchemaCubes:                              sa:= csSchema_Cubes                    ;
  adSchemaDBInfoKeywords:                     sa:= csSchema_DBInfoKeywords           ;
  adSchemaDBInfoLiterals:                     sa:= csSchema_DBInfoLiterals           ;
  adSchemaDimensions:                         sa:= csSchema_Dimensions               ;
  adSchemaForeignKeys:                        sa:= csSchema_ForeignKeys              ;
  adSchemaFunctions:                          sa:= csSchema_Functions                ;
  adSchemaHierarchies:                        sa:= csSchema_Hierarchies              ;
  adSchemaIndexes:                            sa:= csSchema_Indexes                  ;
  adSchemaKeyColumnUsage:                     sa:= csSchema_KeyColumnUsage           ;
  adSchemaLevels:                             sa:= csSchema_Levels                   ;
  adSchemaMeasures:                           sa:= csSchema_Measures                 ;
  adSchemaMembers:                            sa:= csSchema_Members                  ;
  adSchemaPrimaryKeys:                        sa:= csSchema_PrimaryKeys              ;
  adSchemaProcedureColumns:                   sa:= csSchema_ProcedureColumns         ;
  adSchemaProcedureParameters:                sa:= csSchema_ProcedureParameters      ;
  adSchemaProcedures:                         sa:= csSchema_Procedures               ;
  adSchemaProperties:                         sa:= csSchema_Properties               ;
  adSchemaProviderSpecific:                   sa:= csSchema_ProviderSpecific         ;
  adSchemaProviderTypes:                      sa:= csSchema_ProviderTypes            ;
  adSchemaReferentialConstraints:             sa:= csSchema_ReferentialConstraints   ;
  adSchemaSchemata:                           sa:= csSchema_Schemata                 ;
  adSchemaSets:                               sa:= csSchema_Sets                     ;
  adSchemaSQLLanguages:                       sa:= csSchema_SQLLanguages             ;
  adSchemaStatistics:                         sa:= csSchema_Statistics               ;
  adSchemaTableConstraints:                   sa:= csSchema_TableConstraints         ;
  adSchemaTablePrivileges:                    sa:= csSchema_TablePrivileges          ;
  adSchemaTables:                             sa:= csSchema_Tables                   ;
  adSchemaTranslations:                       sa:= csSchema_Translations             ;
  adSchemaTrustees:                           sa:= csSchema_Trustees                 ;
  adSchemaUsagePrivileges:                    sa:= csSchema_UsagePrivileges          ;
  adSchemaViewColumnUsage:                    sa:= csSchema_ViewColumnUsage          ;
  adSchemaViews:                              sa:= csSchema_Views                    ;
  adSchemaViewTableUsage:                     sa:= csSchema_ViewTableUsage           ;
  Else sa := inttostr(p_i4);
  End;//switch
  result:=sa;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Function TJADO.saDDLField(
  p_saName: ansistring;
  p_u2DbmsID: word;
  p_u2JDType: word;
  p_u8DefinedSize: UInt64;
  p_i4NumericScale: LongInt;
  p_i4Precision: LongInt;
  p_saDefaultValue: ansistring;
  p_bAllowNulls: boolean;
  p_bAutoIncrement: boolean;
  p_bCleanFieldName: boolean
): ansistring;
//=============================================================================
var
  saFieldName: ansistring;
  sa: ansistring;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDDLField(p_rJegasField: rtJegasField; p_i4DBMSID: longint; p_bCleanFieldName: boolean): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  If p_bCleanFieldName Then
  begin
    saFieldName := saDBMSCleanObjectName(p_saName, p_u2DBMSID);
  end
  Else
  begin
    saFieldName := p_saName;
  End;
  sa:= '';

  
  case p_u2DBMSID of
  cnDBMS_Generic:;
  //===================================== MSSQL
  //===================================== MSSQL
  //===================================== MSSQL
  //===================================== MSSQL
  cnDBMS_MSSQL: begin
    case p_u2JDType of
    cnJDType_Unknown  :begin
      If p_u8DefinedSize <= 250 Then
      begin
        sa := '"' + saFieldName + '" CHAR(' + inttostR(p_u8DefinedSize) + ') ';
      end
      else
      begin
        If p_u8DefinedSize <= 1024 Then
        begin
          sa := '"' + saFieldName + '" TEXT ';
        end;
      End;
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_b        :begin
      sa := '"' + saFieldName + '" BIT ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSBoolScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i1       :begin
      sa := '"' + saFieldName + '" TINYINT ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i2       :begin
      sa := '"' + saFieldName + '" SMALLINT ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i4       :begin
      sa := '"' + saFieldName + '" INT ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i8       :begin
      sa := '"' + saFieldName + '" BIGINT ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i16      :begin
      sa := '"' + saFieldName + '" CHAR(' + inttostr(cnMaxDigitsFor16ByteUInt) + ') ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i32      :begin
      sa := '"' + saFieldName + '" CHAR(' + inttostr(cnMaxDigitsFor32ByteUInt) + ') ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u1       :begin
      sa := '"' + saFieldName + '" SMALLINT ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u2       :begin
      sa := '"' + saFieldName + '" INT ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u4       :begin
      sa := '"' + saFieldName + '" BIGINT ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u8       :begin
      sa := '"' + saFieldName + '" CHAR(' + inttostr(cnMaxDigitsFor08ByteUInt) + ') ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u16      :begin
      sa := '"' + saFieldName + '" CHAR(' + inttostr(cnMaxDigitsFor16ByteUInt) + ') ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u32      :begin
      sa := '"' + saFieldName + '" CHAR(' + inttostr(cnMaxDigitsFor32ByteUInt) + ') ';
      if p_bAutoIncrement then sa+=' IDENTITY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_fp       :begin
      sa := '"' + saFieldName + '" FLOAT ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSDecScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_fd       :begin
      sa := '"'+saFieldName+'" DOUBLE('+inttostR(p_i4NumericScale)+','+inttostr(p_i4Precision)+')';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSDecScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_cur      :begin
      sa := '"' + saFieldName + '" MONEY ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa+=saDBMSDecScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_ch       :begin
      sa := '"' + saFieldName + '" CHAR(1) ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_chu      :begin
      sa := '"' + saFieldName + '" NCHAR(1) ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_dt       :begin
      sa := '"' + saFieldName + '" DATETIME ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSDateScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_s        :begin
      If p_u8DefinedSize <= 250 Then
        sa := '"' + saFieldName + '" CHAR(' + inttostR(p_u8DefinedSize) + ') '
      Else If p_u8DefinedSize <= 1024 Then
        sa := '"' + saFieldName + '" TEXT ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL';
        end
        else
        begin
          sa:=' '+saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_su       :begin
      If p_u8DefinedSize <= 250 Then
        sa := '"' + saFieldName + '" NCHAR(' + inttostr(p_u8DefinedSize) + ') '
      Else If p_u8DefinedSize <= 1024 Then
        sa := '"' + saFieldName + '" NVARCHAR(' + inttostr(p_u8DefinedSize) + ') '
      Else
        sa := '"' + saFieldName + '" NTEXT ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_sn       :begin
      sa := '"' + saFieldName + '" TEXT ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_sun      :begin
      sa := '"' + saFieldName + '" NTEXT ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_bin      :begin
      If (p_u8DefinedSize < 8000) And (p_u8DefinedSize <> 0) Then
        sa := '"' + saFieldName + '" VARBINARY(' + inttostr(p_u8DefinedSize) + ') '
      Else
        sa := '"' + saFieldName + '" IMAGE ';
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case      
    end;//switch
  end;//end case cnDBMS_MSSQL
  //===================================== MSSQL
  //===================================== MSSQL
  //===================================== MSSQL
  //===================================== MSSQL



















  
  //===================================== MS Access
  //===================================== MS Access
  //===================================== MS Access
  //===================================== MS Access
  cnDBMS_MSAccess: begin
    case p_u2JDType of
    cnJDType_Unknown  :begin
      // Treat as sx (Fixed String based on Defined Size, size bigger
      // than 255 becomes memo.
      // Note: I know 255 is the limit, but if you get to many, you
      // get a record is to large error.
      // Memo slower, but forces table to be created.
      If p_u8DefinedSize > cnMSAccessMaxString Then
      begin
        // TREAT AS cnJegasType_sn (memo)
        sa := '[' + saFieldName + '] MEMO ';
      end
      Else
      begin
        sa := '[' + saFieldName + '] CHAR(' + inttostR(p_u8DefinedSize) + ')';
      End;
      if p_bAllowNulls then sa+=' NULL ' else sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_b        :begin
      sa := '[' + saFieldName + '] yesno ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSBoolScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i1       :begin
      // Treat like i2
      sa := '[' + saFieldName + '] INTEGER ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i2       :begin
      sa := '[' + saFieldName + '] INTEGER ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i4       :begin
      sa := '[' + saFieldName + '] long ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i8       :begin
      // Treat Like Text
      // 10 digits + 1 for sign: e.g:-2114967295
      //sa = "[" & rJegasField.saFieldName & "] CHAR(" & 11 & ")"
      sa := '[' + saFieldName + '] DOUBLE ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i16      :begin
      //  Treat Like Text
      sa := '[' + saFieldName + '] MEMO ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i32      :begin
      // Treat Like Text
      //  255 cuz I have no idea
      sa := '[' + saFieldName + '] MEMO ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u1       :begin
      sa := '[' + saFieldName + '] BYTE ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u2       :begin
      sa := '[' + saFieldName + '] CHAR(5) ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u4       :begin
      sa := '[' + saFieldName + '] CHAR(10) ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u8       :begin
      sa := '[' + saFieldName + '] CHAR(20) ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u16      :begin
      sa := '[' + saFieldName + '] CHAR(255) ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u32      :begin
      sa := '[' + saFieldName + '] CHAR(255) ';
      if p_bAutoIncrement then sa+=' COUNTER ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_fp       :begin
      sa := '[' + saFieldName + '] DOUBLE ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSDecScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_fd       :begin
      sa := '[' + saFieldName + '] DOUBLE ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSDecScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_cur      :begin
      sa := '[' + saFieldName + '] CURRENCY ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSDecScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_ch       :begin
      sa := '[' + saFieldName + '] CHAR(1) ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_chu      :begin
      // TODO: Not sure if unicode handled for ya
      sa := '[' + saFieldName + '] CHAR(1) ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_dt       :begin
      sa := '[' + saFieldName + '] datetime ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSDateScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_s        :begin
      If p_u8DefinedSize > cnMSAccessMaxString Then
      begin
        // TREAT AS cnJDType_sn (memo)
        sa := '[' + saFieldName + '] MEMO ';
      end
      Else
      begin
        sa := '[' + saFieldName + '] CHAR(' + inttostr(p_u8DefinedSize) + ') ';
      End;
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_su       :begin
      If p_u8DefinedSize > cnMSAccessMaxString Then
      begin
        // TREAT AS cnJDType_sn (memo)
        sa := '[' + saFieldName + '] MEMO ';
      end
      Else
      begin
        sa := '[' + saFieldName + '] CHAR(' + inttostr(p_u8DefinedSize) + ') ';
      end;
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_sn       :begin
      sa := '[' + saFieldName + '] memo ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_sun      :begin
      sa := '[' + saFieldName + '] memo ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_bin      :begin
      //  OLE Might be better here but not sure
      sa := '[' + saFieldName + '] memo ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    end;//switch
  end;//end case cnDBMS_MSAccess
  //===================================== MS Access
  //===================================== MS Access
  //===================================== MS Access
  //===================================== MS Access


























  //===================================== MySQL
  //===================================== MySQL
  //===================================== MySQL
  //===================================== MySQL
  cnDBMS_MySQL: begin
    case p_u2JDType of
    cnJDType_Unknown  :begin
      if not p_bAllowNulls then sa+=' NOT NULL ';
      // Note: MySQL BEFORE 5.0.3 goes 0-255 varchar.
      //       MySql SINCE 5.0.3 on, goes 65535-3 (65532 Effective according to docs)
      //       So, for compatibility, going to go next datatype higher
      //       for VARCHAR(>255)
      If p_u8DefinedSize <= 255 Then
      begin
        sa := '`' + saFieldName + '` CHAR(' + inttostr(p_u8DefinedSize) + ') ASCII ';
      end
      else
      begin
        If p_u8DefinedSize <= 65535 Then
        begin
          //sa = "`" & saFieldName & "` TINYTEXT(" & p_JField.u8DefinedSize & ") ASCII "
          sa := '`' + saFieldName + '` TINYTEXT ';
        end
        else
        begin
          If p_u8DefinedSize <= 16777215 Then
          begin
            //sa = "`" & saFieldName & "` MEDIUMTEXT(" & p_JField.u8DefinedSize & ") ASCII "
            sa := '`' + saFieldName + '` MEDIUMTEXT ';
          end
          else
          begin
            // NOTE: This max's out at 4294967295 (4gb) 2'32
            //sa = "`" & saFieldName & "` LONGTEXT(" & p_JField.u8DefinedSize & ") ASCII "
            // BUG with ADO and MySQL: Bug: #13776: Invalid string or buffer length error
            //sa = "`" & saFieldName & "` MEDIUMTEXT(" & p_JField.u8DefinedSize & ") ASCII "

            // This was issues either ASCII UNICODE or Length - dropped it to Pure
            sa := '`' + saFieldName + '` MEDIUMTEXT ';
          end;
        end;
      end;
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_b        :begin
      //sa = "`" & saFieldName & "` BIT(1) "
      sa := '`' + saFieldName + '` TINYINT(1) ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSBoolScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i1       :begin
      sa := '`' + saFieldName + '` TINYINT ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i2       :begin
      sa := '`' + saFieldName + '` SMALLINT ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i4       :begin
      sa := '`' + saFieldName + '` INT ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i8       :begin
      sa := '`' + saFieldName + '` BIGINT ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i16      :begin
      sa := '`' + saFieldName + '` CHAR(' + inttostr(cnMaxDigitsFor16ByteUInt) + ') ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_i32      :begin
      sa := '`' + saFieldName + '` CHAR(' + inttostr(cnMaxDigitsFor32ByteUInt) + ') ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u1       :begin
      sa := '`' + saFieldName + '` TINYINT UNSIGNED ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u2       :begin
      sa := '`' + saFieldName + '` SMALLINT UNSIGNED ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u4       :begin
      sa := '`' + saFieldName + '` INT UNSIGNED ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u8       :begin
      sa := '`' + saFieldName + '` BIGINT UNSIGNED ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u16      :begin
      sa := '`' + saFieldName + '` CHAR(' + inttostr(cnMaxDigitsFor16ByteUInt) + ') ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_u32      :begin
      sa := '`' + saFieldName + '` CHAR(' + inttostr(cnMaxDigitsFor32ByteUInt) + ') ';
      if p_bAutoIncrement then sa+=' AUTO_INCREMENT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSUIntScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_fp       :begin
      sa := '`'+saFieldName+'` FLOAT('+inttostR(p_i4NumericScale)+','+inttostr(p_i4Precision)+')';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSDecScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_fd       :begin
      sa := '`'+saFieldName+'` DOUBLE('+inttostR(p_i4NumericScale)+','+inttostr(p_i4Precision)+')';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSDecScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_cur      :begin
      sa := '`'+saFieldName+'` DOUBLE('+inttostR(p_i4NumericScale)+','+inttostr(p_i4Precision)+')';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSDecScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_ch       :begin
      sa := '`' + saFieldName + '` CHAR(1) ASCII ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_chu      :begin
      sa := '`' + saFieldName + '` CHAR(1) UNICODE ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_dt       :begin
      sa := '`' + saFieldName + '` DATETIME ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if (p_saDefaultValue='NULL') or (Trim(p_saDefaultValue)='0')then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSDateScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_s        :begin
      If p_u8DefinedSize < 256 Then
        sa := '`' + saFieldName + '` CHAR(' + inttostr(p_u8DefinedSize) + ') ASCII '
      Else If p_u8DefinedSize < 65532 Then // Not Type 5.0.3 max effective len: 65532
        sa := '`' + saFieldName + '` VARCHAR(' + inttostr(p_u8DefinedSize) + ') ASCII '
      Else If p_u8DefinedSize < 16777215 Then
        sa := '`' + saFieldName + '` MEDIUMTEXT(' + inttostr(p_u8DefinedSize) + ') ASCII '
        //sa = "`" & saFieldName & "` MEDIUMTEXT ASCII "
      Else
        //sa = "`" & saFieldName & "` LONGTEXT(" & p_JField.u8DefinedSize & ") ASCII "
        ////'' BUG WORK AROUND: with ADO and MySQL: Bug: #13776: Invalid string or buffer length error
        // sa = "`" & saFieldName & "` MEDIUMTEXT(" & p_JField.u8DefinedSize & ") ASCII "
        sa := '`' + saFieldName + '` MEDIUMTEXT ASCII ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_su       :begin
      If p_u8DefinedSize < 256 Then
        sa := '`' + saFieldName + '` CHAR(' + inttostr(p_u8DefinedSize) + ') UNICODE '
      Else If p_u8DefinedSize < 65532 Then // Not Type 5.0.3 max effective len: 65532
        sa := '`' + saFieldName + '` VARCHAR(' + inttostr(p_u8DefinedSize) + ') UNICODE '
      Else If p_u8DefinedSize < 16777215 Then
        sa := '`' + saFieldName + '` MEDIUMTEXT(' + inttostr(p_u8DefinedSize) + ') UNICODE '
      Else
        //sa = "`" & saFieldName & "` LONGTEXT(" & p_JField.u8DefinedSize & ") UNICODE "
        // BUG WORK AROUND: with ADO and MySQL: Bug: #13776: Invalid string or buffer length error
        sa := '`' + saFieldName + '` MEDIUMTEXT(' + inttostr(p_u8DefinedSize) + ') UNICODE ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_sn       :begin
      If p_u8DefinedSize < 256 Then
        //sa = "`" & saFieldName & "` TINYTEXT(" & p_JField.u8DefinedSize & ") ASCII "
        sa := '`' + saFieldName + '` TINYTEXT '
      Else If p_u8DefinedSize < 65532 Then // Not Type 5.0.3 max effective len: 65532
        //sa = "`" & saFieldName & "` TEXT(" & p_JField.u8DefinedSize & ") ASCII "
        sa := '`' + saFieldName + '` TEXT '
      Else If p_u8DefinedSize < 16777215 Then
        //sa = "`" & saFieldName & "` MEDIUMTEXT(" & p_JField.u8DefinedSize & ") ASCII "
        sa := '`' + saFieldName + '` MEDIUMTEXT '
      Else
        //sa = "`" & saFieldName & "` LONGTEXT(" & p_JField.u8DefinedSize & ") ASCII "
        // BUG WORK AROUND: with ADO and MySQL: Bug: #13776: Invalid string or buffer length error
        //sa = "`" & saFieldName & "` MEDIUMTEXT(" & p_JField.u8DefinedSize & ") ASCII "
        // This change syntatical
        sa := '`' + saFieldName + '` MEDIUMTEXT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_sun      :begin
      If p_u8DefinedSize < 256 Then
        //sa = "`" & saFieldName & "` TINYTEXT(" & p_JField.u8DefinedSize & ") UNICODE "
        sa := '`' + saFieldName + '` TINYTEXT '
      Else If p_u8DefinedSize < 65532 Then // Not Type 5.0.3 max effective len: 65532
        //sa = "`" & saFieldName & "` TEXT(" & p_JField.u8DefinedSize & ") UNICODE "
        sa := '`' + saFieldName + '` TEXT '
      Else If p_u8DefinedSize < 16777215 Then
        //sa = "`" & saFieldName & "` MEDIUMTEXT(" & p_JField.u8DefinedSize & ") UNICODE "
        sa := '`' + saFieldName + '` MEDIUMTEXT '
      Else
        //sa = "`" & saFieldName & "` LONGTEXT(" & p_JField.u8DefinedSize & ") UNICODE "
        // BUG WORK AROUND: with ADO and MySQL: Bug: #13776: Invalid string or buffer length error
        //sa = "`" & saFieldName & "` MEDIUMTEXT(" & p_JField.u8DefinedSize & ") UNICODE "

        // This change syntatical
        sa := '`' + saFieldName + '` MEDIUMTEXT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    cnJDType_bin      :begin
      // ---NOTE: MySQL - No Support for BLOBS via ODBC
      //If p_JField.u8DefinedSize < 256 Then
      //  sa = "`" & saFieldName & "` TINYBLOB(" & p_JField.u8DefinedSize & ") "
      //ElseIf p_JField.u8DefinedSize < 65532 Then ' Not Type 5.0.3 max effective len: 65532
      //  sa = "`" & saFieldName & "` BLOB(" & p_JField.u8DefinedSize & ") "
      //ElseIf p_JField.u8DefinedSize < 16777215 Then
      //  sa = "`" & saFieldName & "` MEDIUMBLOB(" & p_JField.u8DefinedSize & ") "
      //Else
      //  sa = "`" & saFieldName & "` LONGBLOB(" & p_JField.u8DefinedSize & ") "
      //End If
      If p_u8DefinedSize < 256 Then
        //sa = "`" & saFieldName & "` TINYTEXT(" & p_JField.u8DefinedSize & ") UNICODE "
        sa := '`' + saFieldName + '` TINYTEXT '
      Else If p_u8DefinedSize < 65532 Then // Not Type 5.0.3 max effective len: 65532
        //sa = "`" & saFieldName & "` TEXT(" & p_JField.u8DefinedSize & ") UNICODE "
        sa := '`' + saFieldName + '` TEXT '
      Else If p_u8DefinedSize < 16777215 Then
        //sa = "`" & saFieldName & "` MEDIUMTEXT(" & p_JField.u8DefinedSize & ") UNICODE "
        sa := '`' + saFieldName + '` MEDIUMTEXT '
      Else
        //sa = "`" & saFieldName & "` LONGTEXT(" & p_JField.u8DefinedSize & ") UNICODE "
        // BUG WORK AROUND: with ADO and MySQL: Bug: #13776: Invalid string or buffer length error
        //sa = "`" & saFieldName & "` MEDIUMTEXT(" & p_JField.u8DefinedSize & ") UNICODE "

        // this change syntatical
        sa := '`' + saFieldName + '` LONGTEXT ';
      if not p_bAllowNulls then sa+=' NOT NULL ';
      if length(p_saDefaultValue)>0 then
      begin
        sa+='DEFAULT ';
        if p_saDefaultValue='NULL' then
        begin
          sa+='NULL ';
        end
        else
        begin
          sa+=saDBMSScrub(p_saDefaultValue,p_u2DBMSID)+' ';
        end;
      end;
    end;//case
    end;//switch
  end;//end case cnDBMS_MySQL
  //===================================== MySQL
  //===================================== MySQL
  //===================================== MySQL
  //===================================== MySQL

  
  cnDBMS_Excel:;
  cnDBMS_dBase:;
  cnDBMS_FoxPro:;
  cnDBMS_Oracle:;
  cnDBMS_Paradox:;
  cnDBMS_Text:;
  cnDBMS_PostGresSQL:;
  cnDBMS_SQLite:;
  end;//case

  result:=sa;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================





//=============================================================================
{}
// This function returns true if the passed query appears to be a readonly 
// query.
Function TJADO.bReadOnlyQueryCheck(p_saQry: ansistring):Boolean;
//=============================================================================
var 
  bRW: Boolean; // Read Write
  TK: JFC_TOKENIZER;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.bReadOnlyQueryCheck(p_saQry: ansistring):Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  TK:=JFC_TOKENIZER.Create;
  TK.saSeparators:=', ()'+csCR+csLF;
  TK.saQuotes:='''"';
  TK.saWhiteSpace:=csCR+csLF+' '+csTAB;
  bRW := False;
  
  TK.Tokenize(p_saQry);
  if TK.MoveFirst then
  begin
    repeat
      if (UpperCase(TK.Item_saToken)='ALTER') or
         (UpperCase(TK.Item_saToken)='UPDATE') or
         (UpperCase(TK.Item_saToken)='DROP') or    
         (UpperCase(TK.Item_saToken)='DELETE') or  
         (UpperCase(TK.Item_saToken)='INSERT') then
      begin
        bRW:=true;
      end;
    until (bRW=true) or (not TK.movenext);
  end;
  TK.Destroy;  
  result:=not bRW;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================



//=============================================================================
{}
// This function checks for the existance of a table (or view) in the database
// actively connected to by the passed JADO_CONNECTION
Function TJADO.bTableExists(p_saTable: ansistring; p_CON: pointer; p_u8Caller: UInt64): boolean;
//=============================================================================
var 
  RS: JADO_RECORDSET;
  //saQry: ansistring;
  bOk: boolean;
  saQry: ansistring;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.bTableExists(p_saTable: ansistring; p_CON: pointer): boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=false;
  rs:=JADO_RECORDSET.Create;
  saQry:='show tables like ' + JADO_CONNECTION(p_CON).saDBMSScrub(Trim(p_saTable));
  bOk:=rs.Open(saQry, JADO_CONNECTION(p_CON),201503160000);
  if bOk then
  begin
    result:=(rs.eol=false) ;
  end
  else
  begin
    JLog(cnLog_INFO,201006221154,'TJADO.bTableExists FAILED - Caller: '+inttostr(p_u8Caller) +' p_saTable: '+p_saTable+' Trouble Executing Query: '+saQry, SOURCEFILE);
  end;
  rs.close;   
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
{}
// this function drops specified table; if there is a table and a view
// the same name; both will be deleted - this function doesn't try to 
// differentiate between tables and views. 
Function TJADO.bDropTable(p_saTable: ansistring; p_Con: pointer; p_u8Caller: UInt64): Boolean;
//=============================================================================
var
  saQry: ansistring;
  rs: JADO_RECORDSET;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.bDropTable(p_saTable: ansistring; p_Con: pointer): Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  if not bTableExists(p_saTable, p_Con,p_u8Caller) then
  begin
    result:=true;
  end
  else
  begin
    rs:=JADO_RECORDSET.Create;
    saQry:='DROP TABLE ' + JADO.saDBMSEncloseObjectName(p_saTable, JADO_CONNECTION(p_CON).u2DbmsID);
    rs.open(saQry,JADO_CONNECTION(p_CON),201503160001);rs.close;
    result:= Not bTableExists(p_saTable, p_CON, p_u8Caller);
    if not result then
    begin
      JLog(cnLog_ERROR,2010020135,'TJADO.bDropTable FAILED - Caller: '+inttostr(p_u8Caller) +
        ' p_saTable: '+p_saTable+' Trouble Executing Query: '+saQry +
        ' JADOC.saName:'+JADO_CONNECTION(p_CON).saName, SOURCEFILE);
    end;
    rs.destroy;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
{}
// this function drops specified view; if there is a table and a view
// the same name; both will be deleted - this function doesn't try to
// differentiate between tables and views.
Function TJADO.bDropView(p_saTable: ansistring; p_Con: pointer; p_u8Caller: Uint64): Boolean;
//=============================================================================
var
  saQry: ansistring;
  rs: JADO_RECORDSET;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.bDropView(p_saTable: ansistring; p_Con: pointer): Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  if not bTableExists(p_saTable, p_Con, p_u8Caller) then
  begin
    result:=true;
  end
  else
  begin
    rs:=JADO_RECORDSET.Create;
    saQry:='DROP VIEW ' + JADO.saDBMSEncloseObjectName(p_saTable, JADO_CONNECTION(p_CON).u2DbmsID);
    rs.open(saQry,JADO_CONNECTION(p_CON),201503160002);rs.close;
    result:= Not bTableExists(p_saTable, p_CON, p_u8Caller);
    if not result then
    begin
      JLog(cnLog_ERROR,2010020136,'TJADO.bDropView FAILED - Caller: '+inttostr(p_u8Caller) +
        ' View: '+p_saTable+' Trouble Executing Query: '+saQry +
        ' JADOC.saName:'+JADO_CONNECTION(p_CON).saName, SOURCEFILE);
    end;    
    rs.destroy;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================



//=============================================================================
function TJADO.bAddColumn(
  p_saTable: ansistring;
  p_saColumn: Ansistring;
  p_saColumnDefinition: ansistring; 
  p_Con: pointer;
  p_u8Caller: Uint64
): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  bNeedToAdd: boolean;
  bFoundColumn: boolean;
  
  Con: JADO_CONNECTION;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='function TJADO.bAddColumn(p_saTable: ansistring;p_saColumn: Ansistring;p_saColumnDefinition: ansistring;p_Con: pointer): boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  Con:=JADO_CONNECTION(p_Con);
  rs:=JADO_RECORDSET.create;
  saQry:='describe `'+p_saTable+'`';
  bOk:=rs.Open(saQry,Con,201503160004);
  if not bOk then
  begin
    JLog(cnLog_Error,201006241820,'TJADO.bAddColumn Caller:'+inttostr(p_u8Caller)+' - Table:'+p_saTable+' Problem opening query:'+saQry,SourceFile);
  end;
  
  bNeedToAdd:=true;
  bFoundColumn:=false;
  if bOk then
  begin
    if rs.eol=false then
    begin
      repeat
        if not bFoundColumn then
        begin 
          bFoundColumn:=rs.fields.FoundItem_saValue(p_saColumn,true);
        end;
        //JcnLog_ity_DEBUG,201006251031,'TEST for column exist in TJADO.bAddColumn rs.fields.FoundItem_saValue('+p_saColumn+',true):'+
        //  saTrueFalse(rs.fields.FoundItem_saValue(p_saColumn,true)), SOURCEFILE);
      until (bFOundcolumn ) or (not rs.MoveNext);
    end;
  end;
  rs.close;    
  bNeedToAdd:=NOT bFoundcolumn;
  
  if bOk then
  begin
    if bNeedToAdd then
    begin
      saQry:='alter table `'+p_saTable+'` add column '+p_saColumn+' '+p_saColumnDefinition;
    end
    else
    begin
      saQry:='alter table `'+p_saTable+'` modify column '+p_saColumn+' '+p_saColumnDefinition;
    end;  
    
    bOk:=rs.Open(saQry,Con,201503160007);
    if not bOk then
    begin
      JLog(cnLog_Error,201006241821,'TJADO.bAddColumn - Table:'+p_saTable+' Problem opening query:'+saQry,SourceFile);
      //bOk:=true; 
    end;
    rs.close;
  end;
  rs.destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
function TJADO.bColumnExists(
  p_saTable: ansistring;
  p_saColumn: Ansistring;
  p_Con: pointer;
  p_u8Caller: UInt64
): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  //bNeedToAdd: boolean;
  bFoundColumn: boolean;
  
  Con: JADO_CONNECTION;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.bColumnExists(p_saTable: ansistring;p_saColumn: Ansistring;p_Con: pointer): boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  Con:=JADO_CONNECTION(p_Con);
  rs:=JADO_RECORDSET.create;
  bOk:=true;
  case Con.u2DBMSID of
  cnDBMS_MySQL:    saQry:='describe `'+p_saTable+'`';
  cnDBMS_MSAccess: saQry:='SQLCOLUMNS NULL NULL (jcompany) NULL';
  else begin bOk:=false;JLog(cnLog_Error,201203112253,'Unsupported DBMS ID: '+inttostr(Con.u2DBMSID),SourceFile);end;
  end;//switch

  if bOk then
  begin
    bOk:=rs.Open(saQry,Con,201503160008);
    if not bOk then
    begin
      JLog(cnLog_Error,201006291458,'TJADO.bColumnExists - Caller: '+inttostr(p_u8Caller)+' Table:'+p_saTable+' Problem opening query:'+saQry,SourceFile);
    end;

    if bOk and (rs.eol=false) then
    begin
      repeat
        case Con.u2DBMSID of
        cnDBMS_MySQL: bFoundColumn:=trim(rs.fields.Get_saValue('Field'))=p_saColumn;
        cnDBMS_MSAccess: bFoundColumn:=trim(rs.fields.Get_saValue('COLUMN_NAME'))=p_saColumn;
        end;//switch
        
     until (bFoundColumn) or (not rs.movenext);
   end;
   rs.close;
  end;
  if bOk then
  begin
    bOk:=bFoundcolumn;
    if not bOk then
    begin
      //JLog(cnLog_INFO,2010020137,'TJADO.bColumnExists FAILED - Caller: '+inttostr(p_u8Caller) +
      //  ' Table: '+p_saTable+' Trouble Executing Query: '+saQry +
      //  ' JADOC.saName:'+JADO_CONNECTION(p_CON).saName, SOURCEFILE);
    end;
  end;
  rs.destroy;
  result:=bOk; 
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
Procedure TJADO.CopyRecordToXDL(
  p_RS: pointer;
  p_XDL: JFC_XDL
);
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.CopyRecordToXDL(p_RS: pointer;p_XDL: JFC_XDL);';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  p_XDL.DeleteAll;
  if JADO_RECORDSET(p_RS).fields.movefirst then
  begin
    repeat
      p_XDL.AppendItem_saName_N_saValue(JADO_RECORDSET(p_RS).fields.Item_saName,JADO_RECORDSET(p_RS).fields.Item_saValue);
    until not JADO_RECORDSET(p_RS).fields.MoveNext;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================















//=============================================================================
//=============================================================================
//=============================================================================
//=============================================================================
//=============================================================================
// ODBCSQL Specific Stuff
//=============================================================================
//=============================================================================
//=============================================================================
//=============================================================================
//=============================================================================
// Codes used for FetchOrientation in SQLFetchScroll()
//  and in SQLDataSources()
//  SQL_FETCH_NEXT     = 1;
//  SQL_FETCH_FIRST    = 2;
//{ifdef odbcver3}
//  SQL_FETCH_FIRST_USER = 31;
//  SQL_FETCH_FIRST_SYSTEM = 32;
//{endif}


//type   TSQLDataSources=function (EnvironmentHandle:SQLHENV;
//           Direction:SQLUSMALLINT;ServerName:PSQLCHAR;
//           BufferLength1:SQLSMALLINT;NameLength1:PSQLSMALLINT;
//           Description:PSQLCHAR;BufferLength2:SQLSMALLINT;
//           NameLength2:PSQLSMALLINT):SQLRETURN;extdecl;

//type   TSQLDrivers=function (EnvironmentHandle:SQLHENV;
//           Direction:SQLUSMALLINT;DriverDescription:PSQLCHAR;
//           BufferLength1:SQLSMALLINT;DescriptionLength1:PSQLSMALLINT;
//           DriverAttributes:PSQLCHAR;BufferLength2:SQLSMALLINT;
//           AttributesLength2:PSQLSMALLINT):SQLRETURN;extdecl;






////=============================================================================
//Procedure ODBC_FreeEnvironment;
////=============================================================================
//Begin
//  // This function has been modified to only free the ODBC Environment when
//  // it has been or can be established. This makes it pretty safe to call
//  // whenever. However, calling this routine while other handles to queries
//  // or whatever are open, well, that will most definately be a problem.
//  //
//  //  If StmtHAndle<>0 Then
//  //    SQLFreeHandle(SQL_HANDLE_STMT,StmtHandle);
//  //  If DBHandle<>0 Then
//  //    SQLFreeHandle(SQL_HANDLE_DBC,DBHandle);
//  If bODBC_OK Then SQLFreeHandle(SQL_HANDLE_ENV,JADO.ODBCEnvHandle);
//End;
//=============================================================================



{$IFDEF ODBC}
//=============================================================================
Function TJADO.bODBC_OK: Boolean;
//=============================================================================
Var i2ODBCResult: SmallInt;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.bODBC_OK: Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  // This function relies on UNIT start up setting the ODBC Environment handle 
  // to nil. This function can be called prior to almost all ODBC functions
  // to assure the environment is established.
  Result:=True;
  If JADO.ODBCEnvHandle=nil Then
  Begin
    i2ODBCResult:=SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, JADO.ODBCEnvHandle);
    If i2ODBCResult <> SQL_SUCCESS Then
    Begin
      JLog(
        cnLog_ERROR,
        200609091013, 
        'ODBC: Could not Allocate ODBC Handle. ' +  
        'TJADO.bODBC_OK:Boolean', SOURCEFILE);
      JADO.ODBCEnvHandle:=nil;
      Result:=False;
    End
    Else
    Begin
      i2ODBCResult:=SQLSetEnvAttr(JADO.ODBCEnvHandle,SQL_ATTR_ODBC_VERSION, SQLPOINTER(SQL_OV_ODBC3), 0);
      If not ODBCSuccess(i2ODBCResult) Then
      Begin
        JLog(
          cnLog_ERROR,
          200609091014, 
          'ODBC: Could not set environment. ' +  
          'TJADO.bODBC_OK:Boolean', SOURCEFILE);
        // Now totally release and reset ODBC back to original state
        // as far as this unit is conecerned.
        SQLFreeHandle(SQL_HANDLE_ENV,JADO.ODBCEnvHandle);
        JADO.ODBCEnvHandle:=nil; 
        Result:=False;
      End;
    End;
  End;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================
{$ENDIF}



////=============================================================================
////Procedure StartSession;
////=============================================================================
//Var
//  i2ODBCResult : SmallInt;
//Begin
//  //ODBCDBHandle:=0;
//  //StmtHandle:=0;
//  // The EnvHandle is now named JADO.ODBCEnvHandle, and is initialized at 
//  // Unit startup.
//  //Res:=SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, JADO.ODBCEnvHandle);
//  //If Res <> SQL_SUCCESS Then
//  //  ODBCErrorHandler('Could allocate ODBC handle',Res);
//  i2ODBCResult:=SQLSetEnvAttr(JADO.ODBCEnvHandle,SQL_ATTR_ODBC_VERSION, SQLPOINTER(SQL_OV_ODBC3), 0);
//  If not ODBCSuccess(i2ODBCResult) Then
//    ODBCErrorHandler('Could not set environment',i2ODBCResult);
//  //Res:=SQLAllocHandle(SQL_HANDLE_DBC, JADO.ODBCEnvHandle, DBHandle);
//  //if res<>SQL_SUCCESS then
//  //  ODBCErrorHandler('Could not create database handle',res);
////  Res:=SQLConnect(DBHandle,PSQLCHAR(DBDSN),SQL_NTS,
////                        PSQLChar(UserName),SQL_NTS,
////                        PSQLCHAR(Password),SQL_NTS);
////  if not OdbcSuccess(res) then
////    ODBCErrorHandler('Could not connect to datasource.',Res);
//End;
////=============================================================================

{$IFDEF ODBC}
//=============================================================================
Procedure TJADO.ODBCLoadDataSources;
//=============================================================================
Var
  i: Longint;
  lpsDSNItem: PChar; // 1024
  lpsDRVItem: PChar; //1024
  iDSNLen: PSQLSMALLINT;
  iDRVLen: PSQLSMALLINT;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.ODBCLoadDataSources;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  If bODBC_OK Then
  Begin
    If ODBCDSNXDL=nil Then
    Begin
      ODBCDSNXDL:=JFC_XDL.Create;
      iDSNLen:=PSQLSMALLINT(0);
      iDRVLen:=PSQLSMALLINT(0);
      lpsDSNItem:=getmem(1024);
      lpsDRVItem:=getmem(1024);
      //StartSession;
      repeat
        i := SQLDataSources(
               JADO.ODBCEnvHandle,
               SQL_FETCH_NEXT,
               lpsDSNItem,
               1024,
               iDSNLen,
               lpsDRVItem,
               1024,
               iDRVLen);
        If i=SQL_SUCCESS Then
        Begin
          //Application.MessageBox(lpsDSNItem,lpsDRVItem,MB_OK);
          //self.cboDSN.Items.Add(lpsDSNItem);
          ODBCDSNXDL.AppendItem_saName_N_saValue(AnsiString(lpsDSNItem),AnsiString(lpsDRVItem));
        End;
      Until (i<> SQL_SUCCESS) and (i<>SQL_SUCCESS_WITH_INFO);
      freemem(lpsDSNItem);
      freemem(lpsDRVItem);
    End;
  End;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================
{$ENDIF}






//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function TJADO.saDBMSScrub(p_sa: AnsiString; p_u2DbmsID: word): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSScrub(p_sa: AnsiString; p_iDbmsID: Longint): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  if (p_sa<>'NULL') then
  begin   
    Case p_u2DbmsID Of
    cnDBMS_MySQL: Result:=''''+saMySQLScrub(p_sa)+'''';
    cnDBMS_MSAccess: Result:=''''+saSQLScrub(p_sa)+'''';
    else Result:=''''+saSQLScrub(p_sa)+'''';
    End;//switch
  end
  else
  begin
    result:='null';
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function TJADO.saDBMSDateScrub(p_sa: AnsiString; p_u2DbmsID: word): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSDateScrub(p_sa: AnsiString; p_iDbmsID: Longint): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  //if (p_sa<>'NULL') and (p_sa<>'1899-12-30 12:00:00 PM') and (p_sa<>'1899-12-30 12:00:00 AM') then
  p_sa:=trim(p_sa);
  if (p_sa='') then p_sa:='NULL';
  if (p_sa<>'NULL')then
  begin
    Case p_u2DbmsID Of
    cnDBMS_MySQL: Result:=''''+saMySQLScrub(p_sa)+'''';
    cnDBMS_MSAccess: Result:='#'+p_sa+'#';
    else result:=p_sa;
    End;//switch
  end
  else
  begin
    result:='null';
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function TJADO.saDBMSDateScrub(p_dt: TDateTime; p_u2DbmsID: word): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSDateScrub(p_dt: TDateTime; p_iDbmsID: Longint): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=saDBMSDateScrub(JDate('',cnDateFormat_11, cnDateFormat_00, p_dt), p_u2DbmsID);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function TJADO.saDBMSDateScrub(p_ts: TTimeStamp; p_u2DbmsID: word): AnsiString;
//=============================================================================
var dt: TDateTime;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSDateScrub(p_ts: TTimeStamp; p_iDbmsID: Longint): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  dt:=TimeStampToDateTime(p_ts);
  result:=saDBMSDateScrub(dt, p_u2DbmsID);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================






//=============================================================================
{}
// Returns Proper Integer representation for the passed DBMS  
// Note: Same as it's like named counterpart except this version will return
// 'null' if 'NULL' is passed to is as a string .. and if its not a null,
// then the function uses the i8Val(ansistring) function to convert 
// p_sa parameter to an integer.
function TJADO.saDBMSIntScrub(p_sa: ansistring; p_u2DbmsID: word): ansistring;
//=============================================================================
var i8: Int64;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSIntScrub(p_sa: ansistring; p_iDbms: Longinter): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  //if (p_sa<>'NULL') and (p_sa<>'1899-12-30 12:00:00 PM') and (p_sa<>'1899-12-30 12:00:00 AM') then
  p_sa:=trim(p_sa);
  if (p_sa='') then p_sa:='NULL';
  if (p_sa<>'NULL')then
  begin
    i8:=i8Val(p_sa);    
    Case p_u2DBMSID Of
    cnDBMS_MySQL: Result:=''''+saMySQLScrub(inttostr(i8))+'''';
    cnDBMS_MSAccess: Result:=inttostr(i8);
    else Result:=inttostr(i8);
    End;//switch
  end
  else
  begin
    result:='null';
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
{}
// Returns Proper Integer representation for the passed DBMS  
function TJADO.saDBMSIntScrub(p_i8: int64; p_u2DbmsID: word): ansistring;
//=============================================================================
//var i8: Int64;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSIntScrub(p_i8: int64; p_iDbms: Longinter): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  //if (p_sa<>'NULL') and (p_sa<>'1899-12-30 12:00:00 PM') and (p_sa<>'1899-12-30 12:00:00 AM') then
  result:=saDBMSIntScrub(inttostr(p_i8),p_u2DbmsID);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
{}
// Returns Proper Decimal representation for the passed DBMS  
// Note: Same as it's like named counterpart except this version will return
// 'null' if 'NULL' is passed to is as a string .. and if its not a null,
// then the function uses the i8Val(ansistring) function to convert 
// p_sa parameter to an integer.
function TJADO.saDBMSDecScrub(p_sa: ansistring; p_u2DbmsID: word): ansistring;
//=============================================================================
var dfp: double;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSDecScrub(p_sa: ansistring; p_iDbms: Longinter): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  //if (p_sa<>'NULL') and (p_sa<>'1899-12-30 12:00:00 PM') and (p_sa<>'1899-12-30 12:00:00 AM') then
  p_sa:=trim(p_sa);
  if (p_sa='') then p_sa:='NULL';
  if (p_sa<>'NULL')then
  begin
    dfp:=fpVal(p_sa);    
    Case p_u2DBMSID Of
    cnDBMS_MySQL: Result:=''''+saMySQLScrub(floattostr(dfp))+'''';
    cnDBMS_MSAccess: Result:='#'+floattostr(dfp)+'#';
    else Result:=floattostr(dfp);
    End;//switch
  end
  else
  begin
    result:='null';
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
{}
// Returns Proper Unsigned Integer representation for the passed DBMS
// Note: Same as it's like named counterpart except this version will return
// 'null' if 'NULL' is passed to is as a string .. and if its not a null,
// then the function uses the i8Val(ansistring) function to convert 
// p_sa parameter to an integer.
function TJADO.saDBMSUIntScrub(p_sa: ansistring; p_u2DbmsID: word): ansistring;
//=============================================================================
var u8: UInt64;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSUIntScrub';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  p_sa:=trim(p_sa);
  if (p_sa<>'NULL')then
  begin
    u8:=u8Val(p_sa);
    Case p_u2DBMSID Of
    cnDBMS_MySQL: Result:=saMySQLScrub(inttostr(u8));
    cnDBMS_MSAccess: Result:=inttostr(u8);
    else Result:=inttostr(u8);
    End;//switch
  end
  else
  begin
    result:='null';
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
{}
// Returns Proper Unsigned Integer representation for the passed DBMS
// Note: Same as it's like named counterpart except this version will return
// 'null' if 'NULL' is passed to is as a string .. and if its not a null,
// then the function uses the i8Val(ansistring) function to convert
// p_sa parameter to an integer.
function TJADO.saDBMSUIntScrub(p_u8: UInt64; p_u2DbmsID: word): ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDBMSUIntScrub(p_u8: UInt64; p_iDbmsID: Longint): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=saDBMSUIntScrub(inttostr(p_u8),p_u2DbmsID);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================














//=============================================================================
function TJADO.saCursorOption(p_iCursorOption: Longint): ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saCursorOption(p_iCursorOption: Longint): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // ADODB.CursorOptionEnum
  case p_iCursorOption of 
  adAddNew: result:='adAddNew';
  adApproxPosition: result:='adApproxPosition';
  adBookmark: result:='adBookmark';
  adDelete: result:='adDelete';
  adFind: result:='adFind';
  adHoldRecords: result:='adHoldRecords';
  adIndex: result:='adIndex';
  adMovePrevious: result:='adMovePrevious';
  adNotify: result:='adNotify';
  adResync: result:='adResync';
  adSeek: result:='adSeek';
  adUpdate: result:='adUpdate';
  adUpdateBatch: result:='adUpdateBatch';
  end;//switch
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function TJADO.saDataType(p_iDataType: Longint): ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saDataType(p_iDataType: Longint): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // ADODB.DataTypeEnum
  case p_iDataType of
  adArray: result:='adArray';
  adBigInt: result:='adBigInt';
  adBinary: result:='adBinary';
  adBoolean: result:='adBoolean';
  adBSTR: result:='adBSTR';
  adChapter: result:='adChapter';
  adChar: result:='adChar';
  adCurrency: result:='adCurrency';
  adDate: result:='adDate';
  adDBDate: result:='adDBDate';
  adDBTime: result:='adDBTime';
  adDBTimeStamp: result:='adDBTimeStamp';
  adDecimal: result:='adDecimal';
  adDouble: result:='adDouble';
  adEmpty: result:='adEmpty';
  adError: result:='adError';
  adFileTime: result:='adFileTime';
  adGUID: result:='adGUID';
  adIDispatch: result:='adIDispatch';
  adInteger: result:='adInteger';
  adIUnknown: result:='adIUnknown';
  adLongVarBinary: result:='adLongVarBinary';
  adLongVarChar: result:='adLongVarChar';
  adLongVarWChar: result:='adLongVarWChar';
  adNumeric: result:='adNumeric';
  adPropVariant: result:='adPropVariant';
  adSingle: result:='adSingle';
  adSmallInt: result:='adSmallInt';
  adTinyInt: result:='adTinyInt';
  adUnsignedBigInt: result:='adUnsignedBigInt';
  adUnsignedInt: result:='adUnsignedInt';
  adUnsignedSmallInt: result:='adUnsignedSmallInt';
  adUnsignedTinyInt: result:='adUnsignedTinyInt';
  adUserDefined: result:='adUserDefined';
  adVarBinary: result:='adVarBinary';
  adVarChar: result:='adVarChar';
  adVariant: result:='adVariant';
  adVarNumeric: result:='adVarNumeric';
  adVarWChar: result:='adVarWChar';
  adWChar: result:='adWChar';
  end;//switch
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function TJADO.saEditMode(p_iEditMode: Longint): ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saEditMode(p_iEditMode: Longint): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // ADODB.EditModeEnum
  case p_iEditMode of
  adEditAdd: result:='adEditAdd';
  adEditDelete: result:='adEditDelete';
  adEditInProgress: result:='adEditInProgress';
  adEditNone: result:='adEditNone';
  end;//switch
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function TJADO.saEventStatus(p_iEventStatus: Longint): ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saEventStatus(p_iEventStatus: Longint): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // ADODB.EventStatusEnum
  case p_iEventStatus of
  adStatusCancel: result:='adStatusCancel';
  adStatusCantDeny: result:='adStatusCantDeny';
  adStatusErrorsOccurred: result:='adStatusErrorsOccurred';
  adStatusOK: result:='adStatusOK';
  adStatusUnwantedEvent: result:='adStatusUnwantedEvent';
  end;//switch
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function TJADO.saLockType(p_iLockType: Longint): ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saLockType(p_iLockType: Longint): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // ADODB.LockTypeEnum
  case p_iLockType of 
  adLockBatchOptimistic: result:='adLockBatchOptimistic';
  adLockOptimistic: result:='adLockOptimistic';
  adLockPessimistic: result:='adLockPessimistic';
  adLockReadOnly: result:='adLockReadOnly';
  end;//switch
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function TJADO.saObjectState(p_iObjectState: Longint): ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saObjectState(p_iObjectState: Longint): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // ADODB.ObjectStateEnum
  case p_iObjectState of
  adStateClosed: result:='adStateClosed';
  adStateConnecting: result:='adStateConnecting';
  adStateExecuting: result:='adStateExecuting';
  adStateFetching: result:='adStateFetching';
  adStateOpen: result:='adStateOpen';
  end;//switch
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function TJADO.saRecordStatus(p_iRecordStatus: Longint): ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saRecordStatus(p_iRecordStatus: Longint): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // ADODB.RecordStatusEnum
  case p_iRecordStatus of
  adRecCanceled: result:='adRecCanceled';
  adRecCantRelease: result:='adRecCantRelease';
  adRecConcurrencyViolation: result:='adRecConcurrencyViolation';
  adRecDBDeleted: result:='adRecDBDeleted';
  adRecDeleted: result:='adRecDeleted';
  adRecIntegrityViolation: result:='adRecIntegrityViolation';
  adRecInvalid: result:='adRecInvalid';
  adRecMaxChangesExceeded: result:='adRecMaxChangesExceeded';
  adRecModified: result:='adRecModified';
  adRecMultipleChanges: result:='adRecMultipleChanges';
  adRecNew: result:='adRecNew';
  adRecObjectOpen: result:='adRecObjectOpen';
  adRecOK: result:='adRecOK';
  adRecOutOfMemory: result:='adRecOutOfMemory';
  adRecPendingChanges: result:='adRecPendingChanges';
  adRecPermissionDenied: result:='adRecPermissionDenied';
  adRecSchemaViolation: result:='adRecSchemaViolation';
  adRecUnmodified: result:='adRecUnmodified';
  end;//switch
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function TJADO.saRecordType(p_iRecordType: Longint): ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.saRecordType(p_iRecordType: Longint): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // ADODB.RecordTypeEnum
  case p_iRecordType of
  adCollectionRecord: result:='adCollectionRecord';
  adSimpleRecord: result:='adSimpleRecord';
  adStructDoc: result:='adStructDoc';
  end;//switch
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================





//=============================================================================
function TJADO.bFoundConnectionByID(p_u8UID: UInt64; var p_lpaJADOC: pointer; var p_iIndex: longint):boolean;
//=============================================================================
var i: longint;
var aJADOC: array of JADO_CONNECTION;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='TJADO.bFoundConnectionByID:boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=false;
  aJADOC:=p_lpaJADOC;
  //riteln('Len aJADOC: '+inttostr(length(aJADOC)));
  for i:=0 to length(aJADOC)-1 do
  begin
    if u8val(aJADOC[i].ID)=p_u8UID then
    begin
      result:=true;
      p_iIndex:=i;
      break;
    end;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================













//=============================================================================
//=============================================================================
//=============================================================================
// END                          TJADO
//=============================================================================
//=============================================================================
//=============================================================================





//=============================================================================
Constructor JADO_FIELD.create;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_FIELD.create';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  Inherited;
  saClassName:='JADO_FIELD';
  u8DefinedSize:=0;
  i4NumericScale:=0;// LongInt;
  i4Precision:=0;// LongInt;
  u2JDType:=0;// LongInt; // Jegas Types Declared in uxxg_common.pp

  {$IFDEF ODBC}
  ODBCSQLHSTMT:=nil;                //ODBCStatementHandle:SQLHSTMT;
  ODBCColumnNumber:=0;            //ODBCColumnNumber:SQLUSMALLINT; 
  ODBCColumnName:=getmem(cnODBC_ColumnNameBufLen);             //ODBCColumnName:PSQLCHAR;       
  ODBCColNameBufLen:=cnODBC_ColumnNameBufLen;            //ODBCColNameBufLen:SQLSMALLINT;  
  ODBCNameLength:=0;              //ODBCNameLength:SQLSMALLINT;    
  ODBCDataType:=0;                //ODBCDataType:SQLSMALLINT;      
  ODBCTargetType:=0;
  ODBCColumnSize:=0;              //ODBCColumnSize:SQLUINTEGER;    
  ODBCDecimalDigits:=0;           //ODBCDecimalDigits:SQLSMALLINT; 
  ODBCNullable:=0;                //ODBCNullable:SQLSMALLINT       
  ODBCDATAPOINTER:=nil;
  ODBCLOB:=False;
  ODBCStrLen_or_Ind:=getmem(sizeof(longint));
  {$ENDIF}

  rMySqlField:=nil;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Destructor JADO_FIELD.destroy;
//=============================================================================
//Var saSourceRoutine: AnsiString;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_FIELD.destroy;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  //saSourceRoutine:='Destructor JADO_FIELD.destroy;';
  {$IFDEF ODBC}
  freemem(ODBCStrLen_or_Ind);
  freemem(ODBCColumnName);// Admittedly, this gets Allocated regardless of 
  // Whether or not its ODBC drivid=cnDriv_ODBC. This might be usable for MySQL
  // Also, or other drivers that need dynamic buffer to drop column names into.
  // At Which Case I'll rename it: 
  // TODO: Rename as appropriate.
  If ODBCDATAPOINTER<>nil Then
  Begin
    If ODBCLOB Then
    Begin
      If JFC_XDL(ODBCDATAPOINTER).MoveFirst Then
      Begin
        repeat
          freemem(JFC_XDLITEM(JFC_XDL(ODBCDATAPOINTER).lpItem).lpPtr);
        Until not JFC_XDL(ODBCDATAPOINTER).movenext;
        JFC_XDL(ODBCDATAPOINTER).destroy;
      End;
    End
    Else
    Begin
      freemem(ODBCDATAPOINTER);
    End;
  End;
  {$ENDIF}
  Inherited;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================




//=============================================================================
Constructor JADO_FIELDS.Create;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_FIELDS.Create;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  Inherited;
  saClassName:='JADO_FIELDS';

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Destructor JADO_FIELDS.Destroy;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_FIELDS.Destroy;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  Inherited;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Function JADO_FIELDS.pvt_CreateItem: JADO_FIELD;  
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_FIELDS.pvt_CreateItem: JADO_FIELD;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  Result:=JADO_FIELD.create;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure JADO_FIELDS.pvt_DestroyItem(p_lp:pointer); 
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_FIELDS.pvt_DestroyItem(p_lp:pointer); ';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  //riteln('About to Destroy a Field!', Cardinal(p_lp));
  JADO_FIELD(p_lp).Destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
function JADO_FIELDS.Get_Field(p_saName: ansistring): JADO_FIELD;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_FIELDS.Get_Field(p_saName: ansistring): JADO_FIELD;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  Result:=nil;
  If self.listcount>0 Then
  Begin
    If FoundItem_saName(p_saName,false) Then
    Begin
      Result:=JADO_FIELD(lpItem);
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function JADO_FIELDS.Get_FieldCS(p_saName: ansistring): JADO_FIELD;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_FIELDS.Get_FieldCS(p_saName: ansistring): JADO_FIELD;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  Result:=nil;
  If self.listcount>0 Then
  Begin
    If FoundItem_saName(p_saName,True) Then
    Begin
      Result:=JADO_FIELD(lpItem);
    End;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================




//=============================================================================
Constructor JADO_RECORD.create;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='Constructor JADO_RECORD.create;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  Inherited;
  saClassName:='JADO_RECORD';
  ActiveConnection:=nil;
  Fields:= JADO_FIELDS.create;
  saParentURL:='';
  i4RecordType:= adSimpleRecord; // vb ADODB.RecordTypeEnum
  i4State:=adStateClosed; // VB ADODB.ObjectStateENum (Usually 1=open, 0 Closed)

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Destructor JADO_RECORD.Destroy;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORD.Destroy;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  Fields.Destroy;Fields:=nil;
  Inherited;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================







//=============================================================================
Constructor JADO_RECORDSET.Create;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.Create;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  //AbsolutePage: LongInt; // vb ADODB.PositionEnum_Param
  //AbsolutePosition: LongInt;// vb ADODB.PositionEnum_Param
  //ActiveCommand: pointer; // in vb ADODB.Object
  
  //vActiveConnection:=0;// Variant; 
  ActiveConnection:=nil;
  
  //Procedure AddNew([FieldList], [Values]);
  //Function BOL: Boolean; // returns true or false = BOF (begin if file, begin of recordset)
  // JFC_DL BOL (Beginning of list) will work fine.
    
  //BookMark: Variant;
  //CacheSize: LongInt;
  //Procedure Cancel;
  //Procedure CancelBatch([AffectRecords As AffectEnum = adAffectAll]);
  //Procedure CancelUpdate;
  //Function Clone([LockType As LockTypeEnum = adLockUnspecified]) As JADO_Recordset;
  //Procedure Close;
  //Function CompareBookMarks(Bookmark1, Bookmark2): CompareEnum; // 
  //Property CursorLocation As CursorLocationEnum
  //Property CursorType As CursorTypeEnum
  //Property DataMember As String
  //Property DataSource As Unknown
  //Sub Delete([AffectRecords As AffectEnum = adAffectCurrent])
  //  JFC_DL.DeleteItem MIGHT need Override here.
  i4EditMode:=adEditNone;// LongInt;// ADODB.EditModeEnum
  //Event EndOfRecordset(fMoreData As Boolean, adStatus As EventStatusEnum, pRecordset As Recordset)
  //Property Eof As Boolean
  
  //  JFC_DL.EOL Overridden.
  pvt_bEOL:=False;
  
  
  //Event FetchComplete(pError As Error, adStatus As EventStatusEnum, pRecordset As Recordset)
  //Event FetchProgress(Progress As Long, MaxProgress As Long, adStatus As EventStatusEnum, pRecordset As Recordset)
  //Event FieldChangeComplete(cFields As Long, Fields, pError As Error, adStatus As EventStatusEnum, pRecordset As Recordset)
  Fields:=JADO_FIELDS.create;
  //Filter: Variant;
  //Find(Criteria As String, [SkipRecords As ADO_LONGPTR], [SearchDirection As SearchDirectionEnum = adSearchForward], [Start])
  //Function GetRows([Rows As Long = -1], [Start], [Fields])
  //Function GetString([StringFormat As StringFormatEnum = adClipString], [NumRows As Long = -1], [ColumnDelimeter As String], [RowDelimeter As String], [NullExpr As String]) As String
  //sIndex: String; // used to SET the name of the index you wish to search on
  i4LockType:=adLockReadOnly;// LongInt;// LOCKTYPE: VB ADODB.LockTypeEnum;
  //Property MarshalOptions As MarshalOptionsEnum
  
  
  u8MaxRecords:=0;// 0=no limit // Uint64; //ADO_LONGPTR (in vb) This field
  // The maximum number Of records To return To a recordset from a query. 
  // MaxRecords Property Return Values: Sets OR returns a Long value. Default is zero (no limit).
  // MaxRecords Property Remarks:
  // Use the MaxRecords Property To limit the number Of records the provider 
  // returns from the data source. The Default setting Of this Property is 
  // zero, which means the provider returns all requested records. The 
  // MaxRecords Property is read/Write when the recordset is closed AND 
  // read-only when it is open.

  //Sub Move(NumRecords As ADO_LONGPTR, [Start])
  //Event MoveComplete(adReason As EventReasonEnum, pError As Error, adStatus As EventStatusEnum, pRecordset As Recordset)
  
  //MoveFirst    - JFC_DL.MoveFirst Should Suffice - might need to be overwritten
  //MoveLast     - JFC_DL.MoveLast Should Suffice - might need to be overwritten
  //MoveNext     - JFC_DL.MoveNext Should Suffice - might need to be overwritten
  //MovePrevious - JFC_DL.MovePrevious Should Suffice - might need to be overwritten
  //Function NextRecordset([RecordsAffected]) As Recordset
  
  //Sub Open(
  //      [Source], 
  //      [ActiveConnection], 
  //      [CursorType As CursorTypeEnum = adOpenUnspecified], 
  //      [LockType As LockTypeEnum = adLockUnspecified], 
  //      [Options As Long = -1]
  //)
  
  //Property PageCount As ADO_LONGPTR
  //Property PageSize As Long
  //Event RecordChangeComplete(adReason As EventReasonEnum, cRecords As Long, pError As Error, adStatus As EventStatusEnum, pRecordset As Recordset)
  
  //Property RecordCount As ADO_LONGPTR
  //  JFC_DL.ListCount Should Suffice - But will likely need to be 
  // Overridden because this is NOT necessarily the rows loaded
  // value, but could be total rows available, yet not loaded yet.
  
  //Event RecordsetChangeComplete(adReason As EventReasonEnum, pError As Error, adStatus As EventStatusEnum, pRecordset As Recordset)
  //Sub Requery([Options As Long = -1])
  //Sub Resync([AffectRecords As AffectEnum = adAffectAll], [ResyncValues As ResyncEnum = adResyncAllValues])
  //Sub Save([Destination], [PersistFormat As PersistFormatEnum = adPersistADTG])
  //Sub Seek(KeyValues, [SeekOption As SeekEnum = adSeekFirstEQ])
  //Property Sort As String
  
  // Property Source As Variant  
  // Reference: http://docs.sun.com/source/817-2514-10/Ch11_ADO123.html
  // The source for the data in a Recordset object (Command object, SQL statement, table name, or stored procedure).
  //
  // Source Property Return Values (ADO Recordset Object):
  // Sets a String value OR Command Object reference; returns only a String value.
  //
  // Source Property Remarks (ADO Recordset Object)
  // Use the Source Property To specify a data source For a Recordset 
  // Object using one Of the following: an ADO Command Object variable, 
  // an SQL statement, a stored Procedure, OR a table name. The Source 
  // Property is read/Write For closed Recordset objects AND read-only 
  // For open Recordset objects.
  //
  // If you Set the Source Property To a Command Object, the ActiveConnection 
  // Property Of the Recordset Object will inherit the value Of the 
  // ActiveConnection Property For the specified Command Object. However, 
  // reading the Source Property does NOT return a Command Object; instead, 
  // it returns the CommandText Property Of the Command Object To which 
  // you Set the Source Property.
  //
  // If the Source Property is an SQL statement, a stored Procedure, OR a 
  // table name, you can optimize performance by passing the appropriate 
  // Options argument With the ADO Recordset Object Open Method call.
  //


  i4State:=adStateClosed;// LongInt; // VB ADODB.State (Probably ADODB.ObjectStateENum Values)
  i4Status:=adRecOK;// LongInt; // VB ADODB.Status ADODB.RecordStatusEnum
  //Property StayInSync As Boolean
  //Function Supports(CursorOptions As CursorOptionEnum) As Boolean
  //Sub Update([Fields], [Values])
  //Sub UpdateBatch([AffectRecords As AffectEnum = adAffectAll])
  //Event WillChangeField(cFields As Long, Fields, adStatus As EventStatusEnum, pRecordset As Recordset)
  //Event WillChangeRecord(adReason As EventReasonEnum, cRecords As Long, adStatus As EventStatusEnum, pRecordset As Recordset)
  //Event WillChangeRecordset(adReason As EventReasonEnum, adStatus As EventStatusEnum, pRecordset As Recordset)
  //Event WillMove(adReason As EventReasonEnum, adStatus As EventStatusEnum, pRecordset As Recordset)
  
  u2DBMSID:=0;
  u2DrivID:=0;
  {$IFDEF ODBC}
  ODBCSQLHSTMT:=nil;// ODBC Statement Handle
  ODBCCOMMANDTYPE:=cnODBC_SQL;// DEFAULT - is NORMAL SQL Statement ( SQLPrepare() )
  {$ENDIF}
  
  
  // MYSQL Specific
  lpMySQLResults:=nil;
  
  u4Columns:=0;
  u4Rows:=0;
  u4RowsLeft:=0;
  u4RowsRead:=0;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Function JADO_RECORDSET.pvt_CreateItem: JADO_RECORD; 
//=============================================================================
Var MYRecord: JADO_RECORD;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.pvt_CreateItem: JADO_RECORD; ';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  MyRecord:=JADO_RECORD.Create;
  MyRecord.ActiveConnection:=self.activeconnection;
  Result:=myrecord;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure JADO_RECORDSET.pvt_DestroyItem(p_lp:pointer); 
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.pvt_DestroyItem(p_lp:pointer);';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  JADO_RECORD(p_lp).Destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Destructor JADO_RECORDSET.Destroy;  // OVERRIDE BUT INHERIT
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.Destroy;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  If self.i4State=adStateOpen Then self.close;
  Fields.Destroy;
  Inherited;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================



//=============================================================================
Function JADO_RECORDSET.Open(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION; p_u8Caller:UInt64):Boolean;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.Open(p_saCMD: AnsiString; Var p_oADOC: '+
    'JADO_CONNECTION):Boolean; p_saCMD: [ '+p_saCMD+' ] ';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
    result:= self.open( p_saCMD , p_oADOC, true,p_u8Caller);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================





//=============================================================================
Function JADO_RECORDSET.Open(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION; p_bLogError: boolean; p_u8Caller: uint64):Boolean;
//=============================================================================
Var 
  bOk: Boolean;
  saSourceRoutine: AnsiString;
  sa: ansistring;
  //i4Retries: longint;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.Open(p_saCMD: AnsiString; '+
    'Var p_oADOC: JADO_CONNECTION; p_bLogError: boolean):Boolean; p_saCMD: [ '+p_saCMD+' ] ';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  bOk:=True;
  saSourceRoutine:= SOURCEFILE + ' JADO_RECORDSET.Open(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION); Qry:'+p_saCMD;
  pvt_bEOL:=True;
  u4Columns:=0;
  u4Rows:=0;
  u4RowsLeft:=0;
  u4RowsRead:=0;
  
  bOk:=(p_oADOC<>nil);
  If not bOk Then
  Begin
    sa:='Caller: ' +inttostr(p_u8Caller)+ ' JADO: Connection object is nil. Is this a Disconnected Recordset? ' + saSourceRoutine;
    p_oADOC.Errors.AppendItem_Error(200609091415,
      200609091415, sa,'',True);
    JLog(cnLog_ERROR, 200609091415, sa, SOURCEFILE);
  End;
  
  If bOk Then
  Begin
    bOk:=(p_oADOC.i4State=adStateOpen);
    If not bOk Then
    Begin
      sa:='Caller: ' +inttostr(p_u8Caller)+ ' JADO: Connection Closed. Unable to open recordset. ' + 
        saSourceRoutine;
      p_oADOC.Errors.AppendItem_Error(200609091416,
        200609091416, sa,'',True);
      JLog(cnLog_ERROR, 200609091416, sa, SOURCEFILE);
    End;
  End;
      
  If bOk Then 
  Begin
    bOk:=i4State=adStateClosed;
    If not bOk Then 
    Begin
      sa:='Caller: ' +inttostr(p_u8Caller)+ ' JADO: Unable to open recordset. Already open. ' + 
        saSourceRoutine;
      p_oADOC.Errors.AppendItem_Error(200609091417,
        200609091417, sa, '', True);
      JLog(cnLog_ERROR, 200609091417, sa, SOURCEFILE);
    End;
  End;
  
  If bOk Then
  Begin
    p_oADOC.Errors.DeleteAll;
    self.u2DrivID:=p_oADOC.u2DrivID;
    self.u2DBMSID:=p_oADOC.u2DBMSID;
    Case u2DrivID Of
    {$IFDEF ODBC}
    cnDRIV_ODBC: Begin self.OpenODBC(p_saCMD, p_oADOC,p_bLogError, p_u8Caller); End; // ODBC CASE Section
    {$ENDIF}
    cnDriv_MySQL: Begin // MySQL CASE Section
        bOk:=self.OpenMySQL(p_saCMD, p_oADOC, p_bLogError,p_u8Caller);
        //riteln('self.OpenMySQL returned:',bOk);
    End;
    Else begin
      p_oADOC.Errors.AppendItem_Error(200609131225,
        200609131225, 'Caller: ' +inttostr(p_u8Caller)+ ' JADO: Bad self.u2DrivID:' + saStr(self.u2DrivID)+' '+
        saSourceRoutine, '', True);
    end;//case
    End;//switch
  End;

  if bOk then
  begin
    bOk:= p_oADOC.Errors.listcount=0;
  end;
  If bOk Then ActiveConnection:=p_oADOC;
  pvt_bEOL:=(u4RowsRead=0);
  Result:=bOk;
  if not bOk then JLog(cnLog_DEBUG, 201203112302, 'Caller: ' +inttostr(p_u8Caller)+ ' DEBUG - QUERY - OK:'+saYesNo(bOk)+' QUERY: '+p_saCMD, SOURCEFILE);


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================







//=============================================================================
Function JADO_RECORDSET.MoveNext: Boolean;
//=============================================================================
Var 
  bOk: Boolean;
  saSourceRoutine: AnsiString;
  sa: AnsiString;
  {$IFDEF ODBC}i2Fetch_ODBCResult: SmallInt;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.MoveNext: Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  bOk:=True;
  saSourceRoutine:= SOURCEFILE + ' Function JADO_RECORDSET.MoveNext: Boolean;';
  bOk:=(ACTIVECONNECTION<>nil);
  If not bOk Then
  Begin
    sa:='JADO: ActiveConnection object is nil. Is this a Disconnected Recordset? ';
    JLog(cnLog_ERROR, 200609111131, sa, SOURCEFILE);
  End;
  If bOk Then
  Begin
    bOk:=(ACTIVECONNECTION.i4State=adStateOpen);
    If not bOk Then
    Begin
      ActiveConnection.Errors.AppendItem_Error(200609111132,
        200609111132, 'JADO: Connection not Open. Unable to open recordset. ' + 
        saSourceRoutine,'',True);
    End;
  End;
  If bOk Then 
  Begin
    bOk:=i4State=adStateOpen;
    If not bOk Then 
    Begin
      ActiveConnection.Errors.AppendItem_Error(200609111133,
        200609111133, 'JADO: Unable to MoveNext - Record Set is Closed ' + 
        saSourceRoutine, '', True);
    End;
  End;

  If bOk Then
  Begin
    Case u2DrivID Of
    {$IFDEF ODBC}
    cnDRIV_ODBC:Begin 
        bOk:=bODBCFetchRecord(ACTIVECONNECTION,i2Fetch_ODBCResult);
      End;
    {$ENDIF}
    cnDriv_MySQL: Begin bOk:=bMySQLFetchRecord(ACTIVECONNECTION);End;
    Else
      Begin
        ActiveConnection.Errors.AppendItem_Error(200609131243,
          200609131243, 'JADO: Bad self.u2DrivID:'+saStr(self.u2DrivID)+' '+
          saSourceRoutine, '', True);
      End;
    End;//switch
  End;        
  
  If not bOk Then pvt_bEOL:=True;
  Result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JADO_RECORDSET.Close: Boolean;
//=============================================================================
Var 
  bOk: Boolean;
  saSourceRoutine: AnsiString;
  
  {$IFDEF ODBC}
  sa: AnsiString;
  i2ODBCResult: SmallInt;  
  {$ENDIF}
  
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.Close: Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  saSourceRoutine:='Procedure JADO_RECORDSET.Close;';
  bOk:=True;
  if i4State=adStateOpen then
  begin
    // NOTE: Original was quite strict here. Some Drivers report a record set as open when no results.
    // Having "safety" close recordset measures should be allowed, and should give error. Instead, do best
    // to clean house and close the recordset and hide the crap from the programmer using this lib if possible.
    If bOk Then
    Begin
      u4Columns:=0;
      u4Rows:=0;
      u4RowsLeft:=0;
      u4RowsRead:=0;
  
      Case u2DrivID Of
      {$IFDEF ODBC}
      cnDRIV_ODBC:
        Begin
          If ODBCSQLHSTMT <> nil Then
          Begin
            i2ODBCResult:=SQLFreeHandle(SQL_HANDLE_STMT,ODBCSQLHSTMT);
            bOk:=JADO.ODBCSuccess(i2ODBCResult);
            If not bOk Then 
            Begin
              sa:='JADO-ODBC: Tried to Free Handle and Got this as a Result in i2ODBCResult:' + saSTR(i2ODBCResult);
              JLog(cnLog_ERROR, 200609111524, sa, SOURCEFILE);
            End;     
            If bOk Then
            Begin
              ODBCSQLHSTMT:=nil;
            End;
          End;
        End;
      {$ENDIF}
      cnDriv_MySQL:
        Begin
          If lpMySQLResults<>nil Then 
          Begin
            mysql_free_result(lpMySQLResults);
            lpMySQLResults:=nil;
          End;
          If lpMySQLPtr<>nil Then 
          Begin
            mysql_close(lpMySQLPtr);
            lpMySQLPtr:=nil;
          End;
        End;      
      Else
        Begin
          JLog(cnLog_WARN, 200609131244, 'JADO: (Record Set may not have been in an open state.) Bad self.u8DrivID:'+saStr(self.u2DrivID)+' '+saSourceRoutine , SOURCEFILE);
        End;//case
      End;//switch
    End;
    If bOk Then
    Begin
      // Last Thing to do it remove from "previous" ttached connection
      If ActiveConnection<>nil Then
      Begin
        ActiveConnection:=nil;
      End;      
      // FINAL CONFIRMATION
    End;
    u2DrivID:=0;
    u2DBMSID:=0;
    Fields.DeleteAll;
    self.i4State:=adStateClosed;
  end;

  //riteln('----------------------END JADO_RECORDSET.Close');
  Result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JADO_RECORDSET.pvt_read_eol:Boolean;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.pvt_read_eol:Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  Result:=pvt_bEOL;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
function JADO_RECORDSET.bSaveResultsAsCSVFile(p_saFilename: ansistring; p_saTextDelimiter: ansistring; var p_u2IOresult: word): boolean;
//=============================================================================
var 
  f: text;
  bOk: boolean;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.bSaveResultsAsCSVFile(p_saFilename: ansistring; p_saTextDelimiter: ansistring; var p_u2IOresult: word): boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  bOk:=  bTSOpenTextFile( p_saFilename, p_u2IOResult, f, false, false);
  if bOk then
  begin
    if fields.movefirst then
    begin
      repeat
        write(f,fields.Item_saName);
        if fields.N<fields.listcount then 
        begin
          writeln;
        end
        else
        begin
          write(',');
        end;
      until not fields.movenext;
    end;
    if eol=false then
    begin
      repeat
        if fields.movefirst then
        begin
          repeat
            write(f,p_saTextDelimiter+fields.Item_saValue+p_saTextDelimiter);
            if fields.N<fields.listcount then 
            begin
              writeln;
            end
            else
            begin
              write(',');
            end;
          until not fields.movenext;
        end;
      until not movenext;
    end;
  end;

  if bOk then
  begin
    bOk:=bTSCloseTextFile(p_safilename, p_u2IOResult, f);
  end;

  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================




{$IFDEF ODBC}
//=============================================================================
Function JADO_RECORDSET.Jegas_SQL_Wedge(
  p_saCmd: ansistring;
  var p_oADOC: JADO_CONNECTION;
  var saUpCase: ansistring;
  var SQL_Catalog: ANSISTRING;
  var SQL_Schema: ansistring;
  var SQL_Table: ansistring;
  var SQL_TableTypeOrCol: ansistring;
  var lpSQL_Catalog: pointer;
  var lpSQL_Schema: pointer;
  var lpSQL_Table: pointer;
  var lpSQL_TableTypeOrCol: pointer;
  var lenSQL_Catalog: longint;
  var lenSQL_Schema: longint;
  var lenSQL_Table: longint;
  var lenSQL_TableTypeOrCol: longint;
  var SQL_Unique: word;
  var SQL_Reserved: word;
  var saODBCCommandType: ansistring
): Boolean;
//=============================================================================
Var 
  bOk: Boolean;
  saSourceRoutine: AnsiString;
  //sa: AnsiString;
  TK: JFC_TOKENIZER;
{$IFDEF DEBUGLOGBEGINEND}var saTHIS_ROUTINE_NAME:AnsiString;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  saTHIS_ROUTINE_NAME:='Jegas_SQL_Wedge';
  DebugIn(saTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  saSourceRoutine:='Function JADO_RECORDSET.Jegas_SQL_Wedge';

  bOk:=true;
  SQL_Catalog:='';
  SQL_Schema:='';
  SQL_Table:='';
  SQL_TableTypeOrCol:='';
  lpSQL_Catalog:=nil;
  lpSQL_Schema:=nil;
  lpSQL_Table:=nil;
  lpSQL_TableTypeOrCol:=nil;
  lenSQL_Catalog:=0;;
  lenSQL_Schema:=0;
  lenSQL_Table:=0;
  lenSQL_TableTypeOrCol:=0;
  SQL_Unique:=0;
  SQL_Reserved:=0;    
  
  TK:=JFC_TOKENIZER.Create;
  //TK.bKeepDeBugInfo:=true;
  TK.saWhiteSpace:=' '+#9+#10+#13;
  TK.saSeparators:=' '+#9+#10+#13;
  TK.QuotesXDL.AppendItem_QuotePair('(',')');
  TK.Tokenize(trim(p_saCMD));
  //TK.DumpToTextFile('tk.txt');    
  if TK.MoveFirst then
  begin
    saUpCase:=upcase(TK.Item_saToken);
    if (saUPCase='SQLTABLES') or (saUPCase='SQLCOLUMNS') or (saUPCase='SQLCOLUMNPRIVILEGES') or  (saUPCase='SQLSTATISTICS') or  (saUPCase='SQLTABLEPRIVILEGES') then
    begin
      if upcase(TK.Item_saToken)='SQLTABLES' then 
      begin
        ODBCCOMMANDTYPE:=cnODBC_SQLTables;
      end
      else
      begin
        if upcase(TK.Item_saToken)='SQLCOLUMNS' then 
        begin
          ODBCCOMMANDTYPE:=cnODBC_SQLColumns;
        end
        else
        begin
          bOk:=false;
          p_oADOC.Errors.AppendItem_Error(
            Int64(0),
            201007070521, 
            'ODBC: Jegas Command Error - Unsupported or Unresolved Command (First Token):' + p_saCMD + ' Occurred:' + saSourceRoutine,
            '',True);
        end;
      end;

      if bOk then
      begin
        if TK.MoveNext then
        begin
          if TK.Item_iQuoteID=1 then
          begin
            SQL_Catalog:=TK.Item_saToken;
          end
          else
          begin
            if upcase(TK.Item_saToken)<>'NULL' then
            begin
              bOk:=false;
              p_oADOC.Errors.AppendItem_Error(
                Int64(0),
                201007070153, 
                'ODBC: Jegas Command Syntax Error - Only NULL is valid for the first parameter if not enclosed in parenthesis. Token: '+TK.Item_saToken+' Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
                '',True);
            end
            else
            begin
              SQL_Catalog:='NULL';
            end;
          end;            
        end
        else
        begin
          bOk:=false;
          p_oADOC.Errors.AppendItem_Error(
            Int64(0),
            201007070154, 
            'ODBC: Jegas Command Syntax Error - Expected another token. Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
            '',True);
        end;
      end;
      
      if bOk then
      begin
        if TK.MoveNext then
        begin
          if TK.Item_iQuoteID=1 then
          begin
            SQL_Schema:=TK.Item_saToken;
          end
          else
          begin
            if upcase(TK.Item_saToken)<>'NULL' then
            begin
              bOk:=false;
              p_oADOC.Errors.AppendItem_Error(
                Int64(0),
                201007070155, 
                'ODBC: Jegas Command Syntax Error - Only NULL is valid for the first parameter if not enclosed in parenthesis. Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
                '',True);
            end
            else
            begin
              SQL_Schema:='NULL';
            end;
          end;            
        end
        else
        begin
          bOk:=false;
          p_oADOC.Errors.AppendItem_Error(
            Int64(0),
            201007070156, 
            'ODBC: Jegas Command Syntax Error - expected another token. Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
            '',True);
        end;
      end;

      if bOk then
      begin
        if TK.MoveNext then
        begin
          if TK.Item_iQuoteID=1 then
          begin
            SQL_Table:=TK.Item_saToken;
          end
          else
          begin
            if upcase(TK.Item_saToken)<>'NULL' then
            begin
              bOk:=false;
              p_oADOC.Errors.AppendItem_Error(
                Int64(0),
                201007070157, 
                'ODBC: Jegas Command Syntax Error - Only NULL is valid for the first parameter if not enclosed in parenthesis. Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
                '',True);
            end
            else
            begin
              SQL_Table:='NULL';
            end;
          end;            
        end
        else
        begin
          bOk:=false;
          p_oADOC.Errors.AppendItem_Error(
            Int64(0),
            201007070158, 
            'ODBC: Jegas Command Syntax Error - expected another token. Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
            '',True);
        end;
      end;

      if bOk and (ODBCCOMMANDTYPE<>cnODBC_SQLStatistics) and (ODBCCOMMANDTYPE<>cnODBC_SQLTablePrivileges) then
      begin
        if TK.MoveNext then
        begin
          if TK.Item_iQuoteID=1 then
          begin
            SQL_TableTypeOrCol:=TK.Item_saToken;
          end
          else
          begin
            if upcase(TK.Item_saToken)<>'NULL' then
            begin
              bOk:=false;
              p_oADOC.Errors.AppendItem_Error(
                Int64(0),
                201007070251, 
                'ODBC: Jegas Command Syntax Error - Only NULL is valid for the first parameter if not enclosed in parenthesis. Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
                '',True);
            end
            else
            begin
              SQL_TableTypeOrCol:='NULL';
            end;
          end;            
        end
        else
        begin
          bOk:=false;
          p_oADOC.Errors.AppendItem_Error(
            Int64(0),
            201007070252, 
            'ODBC: Jegas Command Syntax Error - expected another token. Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
            '',True);
        end;
      end;

      if ODBCCOMMANDTYPE=cnODBC_SQLStatistics then
      begin
        if bOk then
        begin
          if TK.MoveNext then
          begin
            if TK.Item_iQuoteID=1 then
            begin
              if upcase(TK.Item_saToken)='SQL_INDEX_UNIQUE' then 
              begin
                SQL_Unique:=SQL_INDEX_UNIQUE;
              end
              else
              begin
                if upcase(TK.Item_saToken)='SQL_INDEX_ALL' then 
                begin
                  SQL_Unique:=SQL_INDEX_ALL;
                end
                else
                begin
                  bOk:=false;
                  p_oADOC.Errors.AppendItem_Error(
                    Int64(0),
                    201007070201, 
                    'ODBC: Jegas Command Syntax Error - Invalid Token: '+TK.Item_saToken+' Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
                    '',True);
                end;
              end;
            end
            else
            begin
              SQL_Unique:=u2Val(TK.Item_saToken);
            end;            
          end;
        end
        else
        begin
          bOk:=false;
          p_oADOC.Errors.AppendItem_Error(
            Int64(0),
            201007070202, 
            'ODBC: Jegas Command Syntax Error - expected another token. Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
            '',True);
        end;

        if bOk then
        begin
          if TK.MoveNext then
          begin
            if TK.Item_iQuoteID=1 then
            begin
              if upcase(TK.Item_saToken)='SQL_ENSURE' then 
              begin
                SQL_Reserved:=SQL_INDEX_UNIQUE;
              end
              else
              begin
                if upcase(TK.Item_saToken)='SQL_QUICK' then 
                begin
                  SQL_Reserved:=SQL_INDEX_ALL;
                end
                else
                begin
                  bOk:=false;
                  p_oADOC.Errors.AppendItem_Error(
                    Int64(0),
                    201007070203, 
                    'ODBC: Jegas Command Syntax Error - Invalid Token: '+TK.Item_saToken+' Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
                    '',True);
                end;
              end;
            end
            else
            begin
              SQL_Reserved:=u2Val(TK.Item_saToken);
            end;            
          end
          else
          begin
            bOk:=false;
            p_oADOC.Errors.AppendItem_Error(
              Int64(0),
              201007070204, 
              'ODBC: Jegas Command Syntax Error - expected another token. Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
              '',True);
          end;
        end;
      end
      else
      begin
        if TK.MoveNext then
        begin
          p_oADOC.Errors.AppendItem_Error(
            Int64(0),
            201007070205, 
            'ODBC: Jegas Command Syntax Error - Too many tokens. Choked on this command: ' + p_saCMD + ' Occurred:' + saSourceRoutine,
            '',True);
        end;
      end;
    end;
  
    if bOk and (ODBCCOMMANDTYPE<>cnODBC_SQL) then
    begin
      
      case ODBCCommandType of 
      cnODBC_SQL:saODBCCommandType:='cnODBC_SQL';
      cnODBC_SQLTables:saODBCCommandType:='cnODBC_SQLTables';
      cnODBC_SQLColumns:saODBCCommandType:='cnODBC_SQLColumns';
      cnODBC_SQLColumnPrivileges:saODBCCommandType:='cnODBC_SQLColumnPrivileges';
      cnODBC_SQLStatistics:saODBCCommandType:='cnODBC_SQLStatistics';
      cnODBC_SQLTablePrivileges:saODBCCommandType:='cnODBC_SQLTablePrivileges';
      end;//switch
      
      //riteln;
      //riteln('Jegas ODBC Wedge Command: '+saODBCCommandType);
      //riteln('CAT:',SQL_Catalog,' SCH:',SQL_Schema,' TBL:'+SQL_Table,' TOC:',SQL_TableTypeOrCol, ' UN:',SQL_Unique,' RE:',SQL_Reserved);
      
      if SQL_Catalog='NULL' then
      begin
        lpSQL_Catalog:=nil;
        lenSQL_Catalog:=0;
      end
      else
      begin
        lpSQL_Catalog:=PCHAR(SQL_Catalog);
        lenSQL_Catalog:=length(SQL_Catalog);
      end;

      if SQL_Schema='NULL' then
      begin
        lpSQL_Schema:=nil;
        lenSQL_Schema:=0;
      end
      else
      begin
        lpSQL_Schema:=PCHAR(SQL_Schema);
        lenSQL_Schema:=length(SQL_Schema);
      end;

      if SQL_Table='NULL' then
      begin
        lpSQL_Table:=nil;
        lenSQL_Table:=0;
      end
      else
      begin
        lpSQL_Table:=PCHAR(SQL_Table);
        lenSQL_Table:=length(SQL_Table);
      end;

      if SQL_TableTypeOrCol='NULL' then 
      begin
        lpSQL_TableTypeOrCol:=nil;
        lenSQL_TableTypeOrCol:=0;
      end
      else
      begin
        lpSQL_TableTypeOrCol:=PCHAR(SQL_TableTypeOrCol);
        lenSQL_TableTypeOrCol:=length(SQL_TableTypeOrCol);
      end;

    end;
  
  end;
  TK.Destroy;TK:=nil;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(saTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================
{$ENDIF}


////////////////////////////////////////////////////////////////////////////////
///////////////////////         JADO_RECORDSET    BASIC          Above//////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///////////////////////         JADO_RECORDSET Driver Specific Below ///////////
////////////////////////////////////////////////////////////////////////////////







{$IFDEF ODBC}
//=============================================================================
Function JADO_RECORDSET.OpenODBC(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION; p_bLogError: boolean; p_u8Caller: uint64):Boolean;
//=============================================================================
Var
  bOk: Boolean;
  saSourceRoutine: AnsiString;
  i_ODBC_saCMDLength: SQLINTEGER;//ODBC SPECIFIC
  i_ODBC_Columns: SQLSMALLINT;
  i2ODBCResult: SmallInt;  
  u_ODBC_Columns_Loop:SQLUSMALLINT;
  //i4ODBCERRORCODE : LongInt;
  i2Fetch_i2ODBCResult: SmallInt;
  
  
  // Diagnistic: 
  saColumnDataForLog: AnsiString;
  
  //ch: Char;
  //TK: JFC_TOKENIZER;
  saUpCase: ansistring;
  SQL_Catalog: ANSISTRING;
  SQL_Schema: ansistring;
  SQL_Table: ansistring;
  SQL_TableTypeOrCol: ansistring;
  lpSQL_Catalog: pointer;
  lpSQL_Schema: pointer;
  lpSQL_Table: pointer;
  lpSQL_TableTypeOrCol: pointer;
  lenSQL_Catalog: longint;
  lenSQL_Schema: longint;
  lenSQL_Table: longint;
  lenSQL_TableTypeOrCol: longint;
  SQL_Unique: word;
  SQL_Reserved: word;
  saODBCCommandType: ansistring;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.OpenODBC(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION):Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  bOk:=True;
  ODBCCommandType:=cnODBC_SQL;// DEFAULT SQLPrepare() = Normal SQL Statement
  
  saSourceRoutine:=SOURCEFILE + ' JADO_RECORDSET.OpenODBC(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION)';
  bOk:=ODBCSQLHSTMT=nil; // Should be ZERO on Entry. Otherwise, poor clean up somewhere
  
  
  // Get the ODBC Statement Handle ----------------------------------------------------
  If bOk Then
  Begin
    i2ODBCResult:=SQLAllocHandle(SQL_HANDLE_STMT, p_oADOC.ODBCDBHandle,ODBCSQLHSTMT);
    bOk:=JADO.ODBCSuccess(i2ODBCResult);
    If not bOk Then
    Begin
      p_oADOC.Errors.AppendItem_Error(
        Int64(i2ODBCResult),
        200609091414, 
        'Caller: '+inttostr(p_u8Caller)+' ODBC: SQLAllocHandle could not allocate statement handle. Trying to open this command: ' + p_saCMD + ' Occurred:' + 
        saSourceRoutine,
        '', True);
    End;    
  End;          
  

  // Prepare For Statement Execution --------------------------------------------------
  If bOk Then
  Begin
    bOk:=Jegas_SQL_Wedge(
      p_saCmd,
      p_oADOC,
      saUpCase,
      SQL_Catalog,
      SQL_Schema,
      SQL_Table,
      SQL_TableTypeOrCol,
      lpSQL_Catalog,
      lpSQL_Schema,
      lpSQL_Table,
      lpSQL_TableTypeOrCol,
      lenSQL_Catalog,
      lenSQL_Schema,
      lenSQL_Table,
      lenSQL_TableTypeOrCol,
      SQL_Unique,
      SQL_Reserved,
      saODBCCommandType
    );
        
    if bOk and (ODBCCOMMANDTYPE=cnODBC_SQL) then
    begin
      //riteln('Prepare for Statement Execution');
      i_ODBC_saCMDLength:=length(p_saCMD);
      i2ODBCResult:=SQLPrepare(ODBCSQLHSTMT,PSQLCHAR(p_saCMD), i_ODBC_saCMDLength);
      bOk:=JADO.ODBCSuccess(i2ODBCResult);
      If (not bOk) and p_bLogError Then
      Begin
        p_oADOC.Errors.AppendItem_Error(
          Int64(i2ODBCResult),
          200609091410, 
          'Caller: '+inttostr(p_u8Caller)+' ODBC: SQL Prepare Choked on this command: ' + p_saCMD + ' Occurred:' + 
          saSourceRoutine,
          '',True);
      End;
    end;
    
    if bOk and (ODBCCOMMANDTYPE<>cnODBC_SQL) then
    begin
      // --- DEFAULTS for JADO_FIELD.create
      // ODBCColumnNumber:=0;            //ODBCColumnNumber:SQLUSMALLINT; 
      // ODBCColumnName:=getmem(cnODBC_ColumnNameBufLen);             //ODBCColumnName:PSQLCHAR;       
      // ODBCColNameBufLen:=cnODBC_ColumnNameBufLen;            //ODBCColNameBufLen:SQLSMALLINT;  
      // ODBCNameLength:=0;              //ODBCNameLength:SQLSMALLINT;    
      // ODBCDataType:=0;                //ODBCDataType:SQLSMALLINT;      
      // ODBCTargetType:=0;
      // ODBCColumnSize:=0;              //ODBCColumnSize:SQLUINTEGER;    
      // ODBCDecimalDigits:=0;           //ODBCDecimalDigits:SQLSMALLINT; 
      // ODBCNullable:=0;                //ODBCNullable:SQLSMALLINT       
      // ODBCDATAPOINTER:=nil;
      // ODBCLOB:=False;
      // ODBCStrLen_or_Ind:=0;

      if ODBCCOMMANDTYPE=cnODBC_SQLTABLES then
      begin
        i_ODBC_Columns:=5;
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='TABLE_CAT';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=1;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
  
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='TABLE_SCHEM';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=2;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
        
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='TABLE_NAME';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=3;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
  
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='TABLE_TYPE';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=4;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
  
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='REMARKS';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=5;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
      end;
      
      if ODBCCOMMANDTYPE=cnODBC_SQLColumns then
      begin
        i_ODBC_Columns:=18;
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='TABLE_CAT';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=1;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
  
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='TABLE_SCHEM';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=2;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
        
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='TABLE_NAME';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=3;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=0;
  
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='COLUMN_NAME';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=4;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=0;
  
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='DATA_TYPE';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=5;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_SMALLINT;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=0;

        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='TYPE_NAME';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=6;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=0;

        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='COLUMN_SIZE';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=7;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_INTEGER; 
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;

        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='BUFFER_LENGTH';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=8;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_INTEGER;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;

        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='DECIMAL_DIGITS';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=9;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_SMALLINT;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
        
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='NUM_PREC_RADIX';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=10;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_SMALLINT;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
        
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='NULLABLE';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=11;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_SMALLINT;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=0;
        
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='REMARKS';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=12;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
        
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='COLUMN_DEF';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=13;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
        
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='SQL_DATA_TYPE';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=14;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_SMALLINT;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=0;
        
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='SQL_DATETIME_SUB';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=15;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_SMALLINT;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
        
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='CHAR_OCTET_LENGTH';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=16;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_INTEGER;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
        
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='ORDINAL_POSITION';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=17;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_INTEGER;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=0;
        
        Fields.AppendItem;
        JADO_FIELD(Fields.lpItem).saName:='IS_NULLABLE';
        JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
        JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=18;
        JADO_FIELD(Fields.lpItem).ODBCDataType:=SQL_VARCHAR;
        JADO_FIELD(Fields.lpItem).ODBCColumnSize:=1024;
        JADO_FIELD(Fields.lpItem).ODBCDecimalDigits:=0;
        JADO_FIELD(Fields.lpItem).ODBCNullable:=1;
      end;
      
    end;
    
    
  End;   

  // Learn How Many Columns--------------------------------------------------------------
  If bOk and (ODBCCOMMANDTYPE=cnODBC_SQL) Then
  Begin
    //rite('(JADO) Learn How Many Columns...');
    i_ODBC_Columns:=0;
    i2ODBCResult:=SQLNumResultCols(ODBCSQLHSTMT,i_ODBC_Columns);
    //riteln(i_ODBC_Columns,' i2ODBCResult:',i2ODBCResult);
    bOk:=JADO.ODBCSuccess(i2ODBCResult);
    If not bOk Then
    Begin
      p_oADOC.ODBCSQLGetDiag(SQL_HANDLE_STMT, ODBCSQLHSTMT, 200609091413, 
        'Caller: '+inttostr(p_u8Caller)+' ODBC: SQLNumResultCols Choked on this command: ' + p_saCMD,
        saSourceroutine, 
        True, // Log ALL ODBC Errors.
        True  // Drop To Log File
      );
    End;
  End;

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^COLUMNS ????
  // Column Stuff start                         Start da columns
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^COLUMNS ????
  
  // Verify we have at least one column -------------------------------------------------
  If bOk Then
  Begin
    If (i_ODBC_Columns>0) then //and ((ODBCCommandType=cnODBC_SQL) or (ODBCCommandType=cnODBC_SQLTABLES) or () ) Then 
    Begin
      // Describe the columns -----------------------------------------------------------
      
      if (ODBCCommandType=cnODBC_SQL) then
      begin
        //riteln('Describe the columns');
        u_ODBC_Columns_Loop:=1; // Book Mark Column is ZERO, not messing with that.
        repeat 
          If not Fields.AppendItem Then 
          Begin
            //riteln('Describe column thing - add fields FAILED!');
            Halt(4);
          End;

          JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT:=ODBCSQLHSTMT;
          JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=u_ODBC_Columns_Loop;
          
          // This Describes the Columns, and the JADO_RECORDSET.Fields(xdl)'s XDL 
          // ITEMS (JADO_FIELDS), becomes the landing ZONE of the result sets, because 
          // the pointers are given to ODBC below.
    
          //-----------------------------------------------------------------
          //Type   TSQLDescribeCol=Function (StatementHandle:SQLHSTMT;
          //           ColumnNumber:SQLUSMALLINT;ColumnName:PSQLCHAR;
          //           BufferLength:SQLSMALLINT;Var NameLength:SQLSMALLINT;
          //           Var DataType:SQLSMALLINT;Var ColumnSize:SQLUINTEGER;
          //           Var DecimalDigits:SQLSMALLINT;Var Nullable:SQLSMALLINT):SQLRETURN;extdecl;
          //-----------------------------------------------------------------
          //riteln('before Describe');
          i2ODBCResult:=SQLDescribeCol(
                            ODBCSQLHSTMT,
                            u_ODBC_Columns_Loop,
                            JADO_FIELD(Fields.lpItem).ODBCColumnName,
                            JADO_FIELD(Fields.lpItem).ODBCColNameBufLen,
                            JADO_FIELD(Fields.lpItem).ODBCNameLength,
                            JADO_FIELD(Fields.lpItem).ODBCDataType,
                            JADO_FIELD(Fields.lpItem).ODBCColumnSize,
                            JADO_FIELD(Fields.lpItem).ODBCDecimalDigits,
                            JADO_FIELD(Fields.lpItem).ODBCNullable);
           
          //riteln('after describe');  
          bOk:=JADO.ODBCSuccess(i2ODBCResult);
          If bOk Then
          Begin
            JADO_FIELD(Fields.lpItem).saName:=satrim(copy(JADO_FIELD(Fields.lpItem).ODBCColumnName,1,JADO_FIELD(Fields.lpItem).ODBCNameLength));
            //JADO_FIELD(Fields.lpItem).saName:=sareverse(copy(JADO_FIELD(Fields.lpItem).ODBCColumnName,1,JADO_FIELD(Fields.lpItem).ODBCNameLength));
            //ch:=JADO_FIELD(Fields.lpItem).saName[1];
            //repeat
            //  If ch=#32 Then
            //  Begin
            //    delete(JADO_FIELD(Fields.lpItem).saName,1,1);            
            //  End; 
            //  ch:=JADO_FIELD(Fields.lpItem).saName[1];
            //Until ch<>#32;
            //JADO_FIELD(Fields.lpItem).saName:=saReverse(JADO_FIELD(Fields.lpItem).saName);
            
            // Some Field Diagnostics
            //riteln('----------------------------------');
            //riteln('ODBCSQLHSTMT      :',JADO_FIELD(Fields.lpItem).ODBCSQLHSTMT);
            //riteln('ODBCColumnNumber  :',JADO_FIELD(Fields.lpItem).ODBCColumnNumber);
            //riteln('ODBCColumnName    :',JADO_FIELD(Fields.lpItem).ODBCColumnName);
            //riteln('ODBCColNameBufLen :',JADO_FIELD(Fields.lpItem).ODBCColNameBufLen);
            //riteln('ODBCNameLength    :',JADO_FIELD(Fields.lpItem).ODBCNameLength);
            //riteln('ODBCDataType      :',JADO_FIELD(Fields.lpItem).ODBCDataType);
            //riteln('ODBCTargetType    :',JADO_FIELD(Fields.lpItem).ODBCTargetType,' (not set yet)');
            //riteln('ODBCColumnSize    :',JADO_FIELD(Fields.lpItem).ODBCColumnSize);
            //riteln('ODBCDecimalDigits :',JADO_FIELD(Fields.lpItem).ODBCDecimalDigits);
            //riteln('ODBCNullable      :',JADO_FIELD(Fields.lpItem).ODBCNullable);
            //riteln('----------------------------------');
          End
          Else
          Begin
            //riteln('error coming in....');
            p_oADOC.ODBCSQLGetDiag(SQL_HANDLE_STMT, ODBCSQLHSTMT, 200609091528, 
              'Caller: '+inttostr(p_u8Caller)+' ODBC: SQLDescribeCol Failed on Column# ' + saSTR(u_ODBC_Columns_Loop) + 
              ' of ' + saStr(i_ODBC_Columns) + '.' +
              ' Command: ' +p_saCMD,
              saSourceroutine, 
              True, // Log ALL ODBC Errors.
              True  // Drop To Log File
            );
          End;  
          Inc(u_ODBC_Columns_Loop);
        Until (not bOk) OR (u_ODBC_Columns_Loop>i_ODBC_Columns);
        //riteln('Done With Loop, fields:',fields.listcount,' Col Count:',i_ODBC_Columns, ' Success:',saTrueFalse(bOk));
        
        
        // Fail Clean Up - Clean Up Fields
        If not bOk Then
        Begin
          Fields.DeleteAll;    
        End;
      end;      
    
      
      
      ////--------------------------------------------------------------------------------------
      //// NOTE: This Block is what SHOULD be done, for various Target Data Type Conversions, 
      //// BUT FOR expediancy in getting this Jegas Show online, I'll take the SQL CHAR as
      //// Good Enough for now - I convert all data to a ASCII representation.
      //// TODO: OPTIMIZE ODBC PErformance by not converting everything to ASCII.
      ////--------------------------------------------------------------------------------------
      //// TRY to MAP the DATA coming in for each Field
      //
      If bOk  then //and ((ODBCCommandType=cnODBC_SQL) or (ODBCCommandType=cnODBC_SQLTABLES)) Then 
      Begin
        //riteln('Trying to map the ODBC data Type sources to something we can use.');
        Fields.Movefirst;  
        repeat 
          //--
          // NOTE: Target Type has a bearing on ODBCDataPointer. 
          // For example: SQL_LONGVARCHAR is "BLOBish" so SQLFetch isn't used for this,
          // SQLGetData is. Therefore, ODBCPOINTER is NIL (or should be) coming into
          // the portion of code that is calling SQLFETCH. It Skips these BLOBBISH
          // Ones, in that those columns are BOUND, therefore not "FETCHED", but
          // SQLGetData is used to get data for these "Blob'ish" Fields.
          JADO_FIELD(Fields.lpItem).ODBCTargetType:=0;
          JADO_FIELD(Fields.lpItem).ODBCDataPointer:=nil;
          JADO_FIELD(Fields.lpItem).ODBCLOB:=False;
          
          Case JADO_FIELD(Fields.lpItem).ODBCDataType Of
          SQL_UNKNOWN_TYPE:     { = 0;     }    Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_UNKNOWN_TYPE   Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          SQL_LONGVARCHAR:      { =(-1);   }    //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_LONGVARCHAR    Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR;
              JADO_FIELD(Fields.lpItem).ODBCLOB:=True;
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_LONGVARCHAR DEST:SQL_C_CHAR (ODBC Large Object)';
            End; 
          //SQL_BINARY:           { =(-2);   }    Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_BINARY         Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          //SQL_VARBINARY:        { =(-3);   }    Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_VARBINARY      Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          //SQL_LONGVARBINARY:    { =(-4);   }    Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_LONGVARBINARY  Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          SQL_BIGINT:           { =(-5);   }    //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_BIGINT         Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_BIGINT DEST:SQL_C_CHAR';
            End;
          SQL_TINYINT:          { =(-6);   }    //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_TINYINT        Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TINYINT DEST:SQL_C_CHAR';
            End;
          SQL_BIT:              { =(-7);   }    //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_BIT            Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              //JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              //JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_BIT DEST:SQL_C_CHAR';
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_BIT; // TODO: Optimize
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_BIT DEST:SQL_BIT';
            End;
          //SQL_WCHAR:            { =(-8);   }    Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_WCHAR          Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          
          SQL_WVARCHAR:         { =(-9);   }    //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_WVARCHAR       Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          //SQL_WVARCHAR:
          Begin
            JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR;
            //JADO_FIELD(Fields.lpItem).ODBCLOB:=True;
            JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_WVARCHAR DEST:SQL_C_CHAR';
          End;

          
          //SQL_WLONGVARCHAR:     { =(-10);  }    Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_WLONGVARCHAR   Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          //SQL_WLONGVARCHAR:      { =(-1);   }    //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_LONGVARCHAR    Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          //  Begin
          //    JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR;
          //    JADO_FIELD(Fields.lpItem).ODBCLOB:=True;
          //    JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_WLONGVARCHAR DEST:SQL_C_CHAR (ODBC Large Object)';
          //  End; 
          
          SQL_CHAR:             { = 1;  }       //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_CHAR           Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; 
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_CHAR DEST:SQL_C_CHAR';
            End;
          SQL_NUMERIC:          { = 2;  }       //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_NUMERIC        Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_NUMERIC DEST:SQL_C_CHAR';
            End;
          SQL_DECIMAL:          { = 3;  }       //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_DECIMAL        Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_DECIMAL DEST:SQL_C_CHAR';
            End;
          SQL_INTEGER:          { = 4;  }       //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_INTEGER        Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_INTEGER DEST:SQL_C_CHAR';
            End;
          SQL_SMALLINT:         { = 5;  }       //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_SMALLINT       Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_SMALLINT DEST:SQL_C_CHAR';
            End;
          SQL_FLOAT:            { = 6;  }       //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_FLOAT          Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_FLOAT DEST:SQL_C_CHAR';
            End;
          SQL_REAL:             { = 7;  }       //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_REAL           Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_REAL DEST:SQL_C_CHAR';
            End;
          SQL_DOUBLE:           { = 8;  }       //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_DOUBLE         Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_DOUBLE DEST:SQL_C_CHAR';
            End;
      //   {$ifdef ODBCVER3}      {       }                                                                                                                                                 
          SQL_DATETIME:         { = 9;  }       //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_DATETIME       Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_TIMESTAMP;
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_DATETIME DEST:SQL_TIMESTAMP';

              //JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              //JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_DATETIME DEST:SQL_C_CHAR';

            End;
      //   {$endif}               {       }                                                                                                                                                 
          SQL_VARCHAR:          { = 12; }       //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_VARCHAR        Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR; // TODO: Optimize
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_VARCHAR DEST:SQL_C_CHAR';
            End;
      //                          {}                                                                                                                                                 
      //   {$ifdef ODBCVER3}      {}                                                                                                                                                 
          SQL_TYPE_DATE:        {= 91;}         //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_TYPE_DATE      Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              //JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_TYPE_DATE;
              //JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TYPE_DATE DEST:SQL_TYPE_DATE';
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_TIMESTAMP;
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TYPE_DATE DEST:SQL_TIMESTAMP';
              
              //JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR;
              //JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TYPE_DATE DEST:SQL_C_CHAR';
            End;
          SQL_TYPE_TIME:        {= 92;}         //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_TYPE_TIME      Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_TIMESTAMP;
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TYPE_TIME DEST:SQL_TIMESTAMP';
              //JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR;
              //JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TYPE_TIME DEST:SQL_C_CHAR';
            End;
          SQL_TYPE_TIMESTAMP:   {= 93;}         //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_TYPE_TIMESTAMP Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              {
              SQL_TIMESTAMP_STRUCT = Packed Record
                Year :     SQLUSMALLINT;
                Month :    SQLUSMALLINT;
                Day :      SQLUSMALLINT;
                Hour :     SQLUSMALLINT;
                Minute :   SQLUSMALLINT;
                Second :   SQLUSMALLINT;
                Fraction : SQLUINTEGER;
              End;
              PSQL_TIMESTAMP_STRUCT = ^SQL_TIMESTAMP_STRUCT;
              }
              //JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_TYPE_TIMESTAMP;
              //JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TYPE_TIMESTAMP DEST:SQL_TYPE_TIMESTAMP';
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_TIMESTAMP;
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TYPE_TIMESTAMP DEST:SQL_TIMESTAMP';
              //JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR;
              //JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TYPE_TIMESTAMP DEST:SQL_C_CHAR';
            End;
      //   {$endif}               {}                                                                                                                                                 
      //                          {}                                                                                                                                                 
      
          // Duplicated above as SQL_DATETIME
          {$ifndef ODBCVER3}
          //SQL_DATE:             {= 9; }         //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_DATE           Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          //  begin
          //    JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR;
          //   JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_DATE (Not ODBC3) DEST:SQL_C_CHAR';
          //  end;
          {$endif}
      
      
      
          SQL_TIME:             {= 10;}         //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_TIME           Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_TIMESTAMP;
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TIME DEST:SQL_TIMESTAMP';
              //JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR;
              //JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TIME DEST:SQL_C_CHAR';
            End;
            
          SQL_TIMESTAMP:        {= 11;}         //Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_TIMESTAMP      Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            Begin
              JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_TIMESTAMP;
              JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TIMESTAMP DEST:SQL_TIMESTAMP';
              //JADO_FIELD(Fields.lpItem).ODBCTargetType:=SQL_C_CHAR;
              //JADO_FIELD(Fields.lpItem).saDesc:='ODBC SOURCE:SQL_TIMESTAMP DEST:SQL_C_CHAR';
            End;
      //    
      //    // NOTE: If ODBC > $0300, then SQL_TIME means Interval!!! UGH.
      //    {if ODBCVER >= $0300} {}                                                                                                                                             
      //    //SQL_INTERVAL:         {= 10;}         Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_INTERVAL       Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
      //    {endif}               {}                                                                                                                                                
      //    
      //    
      //    {if ODBCVER >= $0350}{}                                                                                                                                                 
      //    SQL_GUID:             {= -11;}        Begin JLog(cnLog_INFO, 0, 'ODBC DATATYPE: SQL_GUID           Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
      //    {endif}
          Else
            Begin 
              Begin JLog(cnLog_WARN, 200609111239, 'ODBC DATATYPE: Not Sure - No Code Yet For it. Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
            End; 
          End;//switch
          if JADO_FIELD(Fields.lpItem).ODBCTargetType=SQL_UNKNOWN_TYPE then
          begin
            Begin JLog(cnLog_WARN, 201007070404, 'Field:'+inttostr(Fields.N)+' Name:'+JADO_FIELD(Fields.lpItem).saName+' ODBC DATATYPE not Resolved. Value:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          end;
          //----
          
      //    riteln('CHECKING COLUMN:',Fields.N);
        Until (not Fields.MoveNext);
        //riteln('OK... Made it past the Mapping. In theory, JADO_FIELDS should be loaded swell.');
        If Fields.MoveFirst Then
        Begin
          repeat
            //riteln(JADO_FIELD(Fields.lpItem).saName,JADO_FIELD(Fields.lpItem).saDesc);
          Until not fields.movenext;
        End;
        //riteln('Ok.. Got Past that deal.');
      End;
      ////--------------------------------------------------------------------------------------
      
      
      //riteln('Next we bind!');
      
      
      
      
      
      
      
      
      
      
      
      
      
      // Bind The Columns !!! ------------------------------------------------------
      If bOk Then 
      Begin
        //riteln('ODBC - Binding the columns');
        // Prepare for Column By Column Binding Loop.
        Fields.MoveFirst; // We SHOULD always have Fields defined in 
        // JADO_RECORDSET.JADO_FIELDS at this point.
        
        //riteln('Just did the Fields.movefirst thing...');  
        
        u_ODBC_Columns_Loop:=1; // Book Mark Column is ZERO, not messing with that.
        repeat 
          //riteln('About to Bind Fields.Nth:',Fields.N);
          
          // NOTE: We are allocating memory here, based on ColumnSize alone, BUT, 
          // As Mentioned above, this gets dicey depending on data type coming in.
          // if the Data Type is a predefined size, then Column SIZE is not the 
          // right Amount Of bytes to allocate on the memory heap.
          //riteln('Trying to Allocate Memory for ODBCDATAPOINTER...');
          
          // NOTE: I know the code is a bit "busy" here and not the tightest COMPILE size wise - 
          // but it should run quickly - and is easy to maintain...because its explicit.
    
          //riteln('OdbcTargetType:',JADO_FIELD(Fields.lpItem).ODBCTargetType);
          //riteln('LOB? ',JADO_FIELD(Fields.lpItem).ODBCLOB);
          Case JADO_FIELD(Fields.lpItem).ODBCTargetType Of 
          SQL_UNKNOWN_TYPE: Begin JLog(cnLog_WARN, 200609111239, 'ODBC Binding: SQL_UNKNOWN_TYPE as ODBCTargetType. ODBCDataType:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          SQL_LONGVARCHAR:  
            Begin
              If JADO_FIELD(Fields.lpItem).ODBCLOB Then
              Begin
                JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=JFC_XDL.Create;
              End
              Else
              Begin
                JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); 
              End;
            End;
              //JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=JFC_XDL.Create;
          SQL_BINARY:       Begin JLog(cnLog_WARN, 200609111240, 'ODBC Binding: SQL_BINARY as ODBCTargetType. ODBCDataType:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          SQL_VARBINARY:    Begin JLog(cnLog_WARN, 200609111241, 'ODBC Binding: SQL_VARBINARY as ODBCTargetType. ODBCDataType:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          SQL_LONGVARBINARY:Begin JLog(cnLog_WARN, 200609111242, 'ODBC Binding: SQL_LONGVARBINARY as ODBCTargetType. ODBCDataType:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          SQL_BIGINT:       
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); // supposed to be 1
          SQL_TINYINT:
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); 
          SQL_BIT:             
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); 
          SQL_WCHAR:        Begin JLog(cnLog_WARN, 200609111243, 'ODBC Binding: SQL_WCHAR as ODBCTargetType. ODBCDataType:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          SQL_WVARCHAR:     Begin JLog(cnLog_WARN, 200609111244, 'ODBC Binding: SQL_WVARCHAR as ODBCTargetType. ODBCDataType:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          SQL_WLONGVARCHAR: Begin JLog(cnLog_WARN, 200609111245, 'ODBC Binding: SQL_WLONGVARCHAR as ODBCTargetType. ODBCDataType:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE);End;
          SQL_CHAR:            
            Begin
              If JADO_FIELD(Fields.lpItem).ODBCLOB Then
              Begin
                JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=JFC_XDL.Create;
              End
              Else
              Begin
                JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1);
              End;
            End;
          SQL_NUMERIC:         
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); 
          SQL_DECIMAL:         
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); 
          SQL_INTEGER:         
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); 
          SQL_SMALLINT:        
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); 
          SQL_FLOAT:           
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); 
          SQL_REAL:            
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); 
          SQL_DOUBLE:          
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); 
          {$ifdef ODBCVER3}   
          SQL_DATETIME:        
            //JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(sizeof(SQL_TIMESTAMP_STRUCT));
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(40);
          {$endif}            
          SQL_VARCHAR:         
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(JADO_FIELD(Fields.lpItem).ODBCColumnSize+1); 
          {$ifdef ODBCVER3}   
          SQL_TYPE_DATE:       
            //JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(sizeof(SQL_TIMESTAMP_STRUCT));
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(40);
          SQL_TYPE_TIME:       
            //JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(sizeof(SQL_TIMESTAMP_STRUCT));
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(40);
          SQL_TYPE_TIMESTAMP:  
            // Last check - Code Above that sets ODBCTARGET Type - Never Sets to SQL_TYPE_TIMESTAMP,
            // and instead sets SQL_TIMESTAMP. This means this code probably won't ever execute.
            // keep as reference.
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(sizeof(SQL_TIMESTAMP_STRUCT));
            //JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(40);
          {$endif}            
          {SQL_DATE is a duplicate Constant - so not included here}
          SQL_TIME:            
            //JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(sizeof(SQL_TIMESTAMP_STRUCT));
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(40);// big , yeah - for consistancy now.. 
          SQL_TIMESTAMP:       
            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(sizeof(SQL_TIMESTAMP_STRUCT));
            //JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER:=getmem(40);
          //SQL_INTERVAL:    
          Else
            Begin 
              JLog(cnLog_WARN, 200609111246, 'ODBC Binding: ' +
                'Caller: '+inttostr(p_u8Caller)+' (Fell Through Case Statement). ODBCTargetType:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCTargetType) + 
                '. ODBCDataType:' + saSTR(JADO_FIELD(Fields.lpItem).ODBCDataType), SOURCEFILE
              );
            End;
          End;// case
          //riteln('Ok, that SEEMS to have worked...Now To Bind Column:',u_ODBC_Columns_Loop);
          //riteln('Got Mem? hahaha');
    
    
          //
          //Type   TSQLBindCol=Function (
          //          StatementHandle:SQLHSTMT;
          //          ColumnNumber:SQLUSMALLINT;
          //          TargetType:SQLSMALLINT;
          //          TargetValue:SQLPOINTER;
          //          BufferLength:SQLINTEGER;
          //          StrLen_or_Ind:PSQLINTEGER
          //       ):SQLRETURN;extdecl;
          //
          // SAMPLE:   SQLBindCol(stmtHandle,1,SQL_INTEGER,SQLPointer(@ResID),4,@ErrCode);
          If JADO_FIELD(Fields.lpItem).ODBCLOB Then 
          Begin
            // FORCE NO BIND for Column - For large Data Types
            i2ODBCResult:=SQL_SUCCESS;
            //riteln('GOTZ a BLOB of Somesort!!!!!!!!!!');
          End
          Else
          Begin


            i2ODBCResult:=SQLBindCol(
                            ODBCSQLHSTMT, 
                            u_ODBC_Columns_Loop, 
                            JADO_FIELD(Fields.lpItem).ODBCTargetType,
                            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER,
                            JADO_FIELD(Fields.lpItem).ODBCColumnSize,
                            JADO_FIELD(Fields.lpItem).ODBCStrLen_or_Ind);

            // BEGIN ---- ORIGINAL ------
            //i2ODBCResult:=SQLBindCol(
            //                ODBCSQLHSTMT, 
            //                u_ODBC_Columns_Loop, 
            //                JADO_FIELD(Fields.lpItem).ODBCTargetType,
            //                JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER,
            //                JADO_FIELD(Fields.lpItem).ODBCColumnSize,
            //                @i4ODBCErrorCode);
            // END ---- ORIGINAL ------
            
            {
            i2ODBCResult:=SQLBindCol(
                            ODBCSQLHSTMT, 
                            u_ODBC_Columns_Loop, 
                            SQL_CHAR,
                            JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER,
                            JADO_FIELD(Fields.lpItem).ODBCColumnSize,
                            @i4ODBCErrorCode);
            }
          End;                                  
          //riteln('Checking ODBCSuccess....');
          bOk:=JADO.ODBCSuccess(i2ODBCResult);
          //riteln('OdbcSuccess Says:',satrueFalse(bOk));
          If not bOk Then 
          Begin
            // because THIS is ultimately a JFC_XDL, with each item being JADO_RECORD class.
            //riteln('Active Connection Pointer''s value:',Cardinal(ActiveConnection));
            //riteln('p_oADOC Pointer''s value:',Cardinal(p_oADOC));
            {
            Procedure JADO_CONNECTION.ODBCSQLGetDiag(
              p_SQLHandleType: LongInt; 
              p_SQLHandle: pointer;
              p_i8Number: Int64;
              p_saMsg: AnsiString;
              p_saSource: AnsiString;
              p_bAll: Boolean;
              p_bDropToLog: Boolean
            );
            }
            p_oADOC.ODBCSQLGetDiag(SQL_HANDLE_STMT, ODBCSQLHSTMT, 200609091953, 
              'Caller: '+inttostr(p_u8Caller)+' ODBC: SQLBindCol Failed on Column# ' + saSTR(u_ODBC_Columns_Loop) + 
              ' of ' + saStr(i_ODBC_Columns) + '.' + 
              ' Returned SQLBindCol StrLen_or_Ind Value:' + saStr(JADO_FIELD(Fields.lpItem).ODBCStrLen_or_Ind^) +
              ' Command: ' +p_saCMD,
              saSourceroutine, 
              True, // log all ODBC errors
              True
            );// drop to log file.
          End;
        
          If bOk Then
          Begin 
            Inc(u_ODBC_Columns_Loop);
            Fields.MoveNExt;
          End;
        Until (not bOk) OR (u_ODBC_Columns_Loop>i_ODBC_Columns);
    
        //riteln('Ok - Columns have been bound');
        
        // Fail Clean Up - Clean Up Fields
        If not bOk Then
        Begin
          // Clean Up Tasks Here
          Fields.DeleteAll; // Note Allocated Memory on ODBCDATAPOINTER
          // is handled in the JADO_FIELD object destructor.
          // if non-zero - calls freemem.
        End;
      End;
    End;
  End;// if bOk before column count check
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^COLUMNS ????
  // Column Stuff END                         Done da columns
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^COLUMNS ????

  
  
  // RELAX for a second ------------------------------------------------
  // hmm... Where did life come from? Coffee? Milk and Sugar please,
  // kinda sweet... 3 spoons is fine... thank You... ahhh.....
  //
  // Ok - enough relaxing!
  // -------------------------------------------------------------------  
  
  
  
  
  // Execute the command -----------------------------------------------
  If bOk and (ODBCCOMMANDTYPE=cnODBC_SQL) Then 
  Begin
    //riteln('EXECUTE the COMMAND:',p_saCmd);
    i2ODBCResult:=SQLExecDirect(ODBCSQLHSTMT,PSQLCHAR(p_saCMD),SQL_NTS);
    bOk:=JADO.ODBCSuccess(i2ODBCResult);
    If not bOk Then 
    Begin
      p_oADOC.ODBCSQLGetDiag(SQL_HANDLE_STMT, ODBCSQLHSTMT, 200609092002, 
        'Caller: '+inttostr(p_u8Caller)+' ODBC: SQLExecDirect Choked on this command: ' + p_saCMD,
        saSourceRoutine, 
        True, // log all ODBC errors
        True  // drop to jegas log file.
      );
    End;
  End;  
  
  if bOk and (ODBCCOMMANDTYPE=cnODBC_SQLTABLES) Then 
  begin
    //i2ODBCResult:=SQLTables(ODBCSQLHSTMT,PSQLCHAR(SQL_ALL_CATALOGS),SQL_NTS,PSQLCHAR(''),SQL_NTS,PSQLCHAR(''),SQL_NTS,PSQLCHAR(''),SQL_NTS);
    //i2ODBCResult:=SQLTables(ODBCSQLHSTMT,nil,SQL_NTS,nil,SQL_NTS,nil,SQL_NTS,nil,SQL_NTS);
    i2ODBCResult:=SQLTables(ODBCSQLHSTMT,
      lpSQL_Catalog,lenSQL_Catalog,
      lpSQL_Schema,lenSQL_Schema,
      lpSQL_Table,lenSQL_Table,
      lpSQL_TableTypeOrCol,lenSQL_TableTypeOrCol
    );
    bOk:=JADO.ODBCSuccess(i2ODBCResult);
    If not bOk Then 
    Begin
      p_oADOC.ODBCSQLGetDiag(SQL_HANDLE_STMT, ODBCSQLHSTMT, 201007070334, 
        'Caller: '+inttostr(p_u8Caller)+' ODBC: SQLTables Choked.',
        saSourceRoutine, 
        True, // log all ODBC errors
        True  // drop to jegas log file.
      );
    End;
  end;
  
  if bOk and (ODBCCOMMANDTYPE=cnODBC_SQLCOLUMNS) Then 
  begin
    i2ODBCResult:=SQLColumns(ODBCSQLHSTMT,
      lpSQL_Catalog,lenSQL_Catalog,
      lpSQL_Schema,lenSQL_Schema,
      lpSQL_Table,lenSQL_Table,
      lpSQL_TableTypeOrCol,lenSQL_TableTypeOrCol
    );
    bOk:=JADO.ODBCSuccess(i2ODBCResult);
    If not bOk Then 
    Begin
      p_oADOC.ODBCSQLGetDiag(SQL_HANDLE_STMT, ODBCSQLHSTMT, 201007070335, 
        'Caller: '+inttostr(p_u8Caller)+' ODBC: SQLColumns Choked.',
        saSourceRoutine, 
        True, // log all ODBC errors
        True  // drop to jegas log file.
      );
    End;
  end;
  
  

  // -------------------------------------------------------------------------
  // -- OK At this Point everything is more or less set
  // You can technically say the recordset is open. Now how 
  // you want to go about handling the record by record, 
  // well, that's another matter. Do you push them all to memory
  // or just "work" a record at a time, letting the application figure it out?
  // personally, the right way is to probably treat as cursor, "loading"
  // the current row with a fetch, for the current record, and waiting for 
  // a move next or something, to decide how to proceed.
  // -------------------------------------------------------------------------

    
  If bOk Then 
  Begin
    If i_ODBC_Columns>0 Then 
    Begin
      //riteln('ODBC FetchRecord (columns (i_ODBC_Columns) :',i_ODBC_Columns,')');
      bOk:=(self.bODBCFetchRecord(p_oADOC, i2Fetch_i2ODBCResult));
      If not bOk Then
      Begin
        bOk:=(i2Fetch_i2ODBCResult=SQL_NO_DATA);
      End
      Else
      Begin
        //
      End;
      //riteln('Back from ODBCFetch Record');
      If not bOk Then 
      Begin
        saColumnDataForLog:='';
        If fields.listcount>0 Then
        Begin
          fields.movefirst;
          repeat
            saColumnDataForLog+='    Column:'+saStr(fields.n)+' Name: '+JADO_FIELD(Fields.lpItem).saName + ' Desc: ' +JADO_FIELD(Fields.lpItem).saDesc;
          Until not fields.movenext;
        End;
        
        
        p_oADOC.ODBCSQLGetDiag(SQL_HANDLE_STMT, ODBCSQLHSTMT, 200609111716, 
          'Caller: '+inttostr(p_u8Caller)+' ODBC: Opening Record, all good until tried to fetch first row. ' + p_saCMD+
          ' Columns:' + saColumnDataForLog,
          saSourceRoutine, 
          True, // log all ODBC errors
          True  // drop to jegas log file.
        );
      End;
    End;
  End;


  If bOk Then 
  Begin
    i4State:=adStateOpen; // I'm OPEN!
  End
  Else
  Begin
    i4State:=adStateClosed;
  End;
  //riteln('All done, leaving:',saSourceRoutine);
  Result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================
{$ENDIF}


{$IFDEF ODBC}
//=============================================================================
Function JADO_RECORDSET.bODBCFetchRecord(p_oADOC: jado_connection; Var p_i2ODBCResult:SmallInt): Boolean;
//=============================================================================
Var 
  bOk: Boolean;
  i2ODBCResult: SmallInt;
  i_ODBC_SqlGetData_Returned_Len: SQLINTEGER;
  bDone: Boolean;
  var sTHIS_ROUTINE_NAME:String;
Begin
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.bODBCFetchRecord(p_oADOC: jado_connection; Var p_i2ODBCResult:SmallInt): Boolean;';
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  //riteln('Fetching..........................................');
  i2ODBCResult:=SQLFetch(ODBCSQLHSTMT);
  If i2ODBCResult=SQL_NO_DATA Then 
  Begin
    Result:=False;
    p_i2ODBCResult:=i2ODBCResult;
    Exit;
  End;
  bOk:=(i2ODBCResult=SQL_SUCCESS) OR (i2ODBCResult=SQL_SUCCESS_WITH_INFO);
  //riteln('1 bOk odbc fetch:',bOk);

  If bOk Then 
  Begin
    u4RowsRead+=1;

    If Fields.MoveFirst Then
    Begin
      repeat
        //riteln('Status Success: ',bOk,' fields.N:',fields.N);
        // GET THE INFO Into the FIELD------------------------------------
        // NOTE: Above Line will report FALSE for LOB because the pointer is to a class
        // I set up to gather "chunks". Need To Figure This Out. note:
        // if JFC_XDLITEM(JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).lpitem).iUser = -1 on the 
        // first iteration when gethering LOB data - This MAY indicate a null.
        
        If bOk Then 
        Begin
          If JADO_FIELD(Fields.lpItem).ODBCLOB Then
          Begin
            bDone:=False;
            JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).DeleteAll;
            repeat 
              //riteln('Looping Chunks');
              JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).AppendItem;
              JFC_XDLITEM(JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).lpItem).lpPTR:=getmem(cnLOBBufSize+1);
              i2ODBCResult:=SQLGetData(
                              ODBCSQLHSTMT, 
                              Fields.iNN,
                              JADO_FIELD(Fields.lpItem).ODBCTargetType, 
                              JFC_XDLITEM(JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).lpItem).lpPTR,
                              cnLOBBufSize,
                              psqlinteger(@i_ODBC_SqlGetData_Returned_Len)
                            );
              JFC_XDLITEM(JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).lpitem).i8User:=i_ODBC_SqlGetData_Returned_Len;
              //riteln('SQLGetData Returned:',i2ODBCResult);
              If (i2ODBCResult=SQL_SUCCESS) OR (i2ODBCResult=SQL_SUCCESS_WITH_INFO) Then
              Begin
                // KEEP THE MEMORY
                bDone:=i2ODBCResult=SQL_SUCCESS;
              End
              Else
              Begin
                freemem(JFC_XDLITEM(JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).lpItem).lpPTR);
                JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).DeleteItem;
                bOk:=False;
                p_oADOC.ODBCSQLGetDiag(SQL_HANDLE_STMT, ODBCSQLHSTMT, 200609111607, 
                  'ODBC: SQLGetData Choked on column: ' + saStr(Fields.N) + ' Row: ' + saSTR(u4RowsRead),
                  sTHIS_ROUTINE_NAME,
                  True, // log all ODBC errors
                  True  // drop to jegas log file.
                );
              End;
            Until bDone OR (not bOk);
            //riteln('Chunks:',JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).listcount);
          End
          Else
          Begin
            //riteln('OK, so its not AN LOB');
          End;
        End;
        
        // Get the Data into XDL Common Fields ---------------------------------------
        // saName, saDesc, saValue
        If bOk Then
        Begin
          Case JADO_FIELD(fields.lpItem).ODBCTargetType Of
          SQL_CHAR: 
            Begin  
              If JADO_FIELD(fields.lpItem).ODBCLOB Then
              Begin
                If JFC_XDL(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER).movefirst Then
                Begin
                  // Note: Commented out because it wasn't being used.
                  //uBytesTotal:=Cardinal(JFC_XDLITEM(JFC_XDL(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER).lpitem).iUser);
                  
                  JADO_FIELD(fields.lpItem).savalue:='';
                  //setlength(JADO_FIELD(lpItem).savalue, uBytesTotal);
                  //riteln('1Suspect ODBC Issue here - chunking to Ansistring a LOB');
                  repeat
                    If JFC_XDLITEM(JFC_XDL(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER).lpitem).i8User>0 Then
                    Begin
                      JADO_FIELD(fields.lpitem).savalue+=PChar(JFC_XDLITEM(JFC_XDL(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER).lpItem).lpPTR);
                    End;
                    freemem(JFC_XDLITEM(JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).lpItem).lpPTR);
                    JFC_XDL(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER).DeleteItem;
                  Until JFC_XDL(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER).listcount=0;
                End
                else
                begin
                  if(JADO_FIELD(fields.lpItem).ODBCStrLen_or_Ind^=SQL_NULL_DATA) then 
                  begin
                    JADO_FIELD(fields.lpitem).savalue:='NULL';
                  end;
                end;
              End
              Else
              Begin
                if(JADO_FIELD(fields.lpItem).ODBCStrLen_or_Ind^=SQL_NULL_DATA) then 
                begin
                  JADO_FIELD(fields.lpItem).savalue:='NULL';
                end
                else
                begin
                  JADO_FIELD(fields.lpItem).savalue:=PSQLCHAR(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER);
                end;
                
              End;
            End;
          SQL_BIT: 
            Begin
              if(JADO_FIELD(fields.lpItem).ODBCStrLen_or_Ind^=SQL_NULL_DATA) then 
              Begin
                JADO_FIELD(fields.lpItem).savalue:='NULL';
              end
              else
              begin
                If Boolean(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^)=False Then
                Begin
                  JADO_FIELD(fields.lpItem).savalue:='false';
                End
                Else
                Begin
                  JADO_FIELD(fields.lpItem).savalue:='true';
                End;  
              end;
            End;
          SQL_TIMESTAMP: 
            Begin
              if(JADO_FIELD(fields.lpItem).ODBCStrLen_or_Ind^=SQL_NULL_DATA) then 
              Begin
                //JADO_FIELD(fields.lpItem).savalue:='0000-00-00 00:00:00 n0000';
                JADO_FIELD(fields.lpItem).savalue:='NULL';
              end
              else
              begin
                //SQL_TIMESTAMP_STRUCT = packed record
                //  Year :     SQLUSMALLINT;
                //  Month :    SQLUSMALLINT;
                //  Day :      SQLUSMALLINT;
                //  Hour :     SQLUSMALLINT;
                //  Minute :   SQLUSMALLINT;
                //  Second :   SQLUSMALLINT;
                //  Fraction : SQLUINTEGER;
                //end;
                //PSQL_TIMESTAMP_STRUCT = ^SQL_TIMESTAMP_STRUCT;
                
                
                //JADO_FIELD(fields.lpItem).savalue:='SQL_TIMESTAMP_STRUCT';
                
                //u2SQLVALUE:=PSQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER)^.Month;
                //JADO_FIELD(fields.lpItem).saValue:=saStr(u2SQLValue);
                
                // Based on uxxg_jegas.pp JDATE Format csDateFormat_11 'YYYY-MM-DD HH:NN:SS' with
                // Additional ' n0000' which is the fractions of a second
                JADO_FIELD(fields.lpItem).savalue:=
                  saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Year    ,4)+'-'+
                  saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Month   ,2)+'-'+
                  saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Day     ,2)+' '+
                  saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Hour    ,2)+':'+
                  saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Minute  ,2)+':'+
                  saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Second  ,2)+' n'+
                  saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Fraction,4);
              End;
            End;
          else begin
            bOk:=False;
            p_i2ODBCResult:=i2ODBCResult;
              p_oADOC.Errors.AppendItem_Error(201007071212,
              201007071212,'JADO-ODBC: Field: '+ JADO_FIELD(Fields.lpItem).saName + 
              ' Unsupported Target Column Data Type for Field: '+
              ' JADO_FIELD(fields.lpItem).ODBCTargetType: ' +
              inttostr(JADO_FIELD(fields.lpItem).ODBCTargetType)+' '+
              sTHIS_ROUTINE_NAME,'',True);
              JLog(cnLog_WARN, 201007071213,'success lost here ' + sTHIS_ROUTINE_NAME,sourcefile);
              
          end;//case
          End;//switch odbc target types
          
        End;//
      Until (not bOk) or (not Fields.MoveNext);
    //riteln();
    End
    Else
    Begin
      //riteln('200609131940 JADO_RECORDSET.bODBCFetchRecord - No Fields');
    End;
  End;
  // Closing is a slightly different MAtter.
  // its my understanding one should "unbind" each column
  // as a safety clean up measure.
  //riteln('Done Fetching..........................................');
  //riteln('Leaving Fetch bOk:',bOk);
  Result:=bOk;
  //ODBCShowRecord;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================
{$ENDIF}


{$IFDEF ODBC}
//=============================================================================
Procedure JADO_RECORDSET.ODBCShowRecord;//private diagnostic thing
//=============================================================================
Var uBytes: Cardinal;
    uBytesTotal: Cardinal;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.ODBCShowRecord;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  If fields.MoveFirst Then
  Begin
    repeat
      Case JADO_FIELD(Fields.lpItem).ODBCTargetType Of
      SQL_CHAR: 
        Begin  
          If JADO_FIELD(Fields.lpItem).ODBCLOB Then
          Begin
            If JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).movefirst Then
            Begin
              uBytesTotal:=JFC_XDLITEM(JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).lpitem).i8User;
              repeat
                If JFC_XDLITEM(JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).lpitem).i8User>0 Then
                Begin
                  uBytes:=0;
                  //riteln('Chunk:',JFC_XDL( JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER ).n);
                  //riteln('uBytes:',ubytes,'  uBytesTotal:',ubytestotal,'  TOTAL:',Cardinal(JFC_XDLITEM(JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).lpitem).iUser));
                  repeat  
                    Write(Char(pointer(UINT(JFC_XDLITEM(JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).lpItem).lpPTR)+ubytes)^));
                    Inc(uBytes);
                    dec(uBytesTotal); 
                  Until (ubytes=(cnLOBBufSize-1)) OR 
                        (ubytestotal=0);
                End;
              Until not JFC_XDL(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER).movenext;
            End;  
          End
          Else
          Begin
            Write(PSQLCHAR(JADO_FIELD(Fields.lpItem).ODBCDATAPOINTER));            
          End;
        End;
      SQL_TIMESTAMP: 
        Begin
          // Based on uxxg_jegas.pp JDATE Format csDateFormat_11 'YYYY-MM-DD HH:NN:SS' with
          // Additional ' n0000' which is the fractions of a second
          Write(saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Year    ,4)+'-'+
                saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Month   ,2)+'-'+
                saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Day     ,2)+' '+
                saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Hour    ,2)+':'+
                saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Minute  ,2)+':'+
                saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Second  ,2)+' n'+
                saZeroPadInt(SQL_TIMESTAMP_STRUCT(JADO_FIELD(fields.lpItem).ODBCDATAPOINTER^).Fraction,4));
        End;
      Else
        Begin
          //riteln('UNSUPPORTED DATATYPE GOES HERE');
        End;
      End;// case
      Write(#9);
    Until not fields.movenext;
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================
{$ENDIF}





////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///////////////////////     odbc above               ///////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///////////////////////        mysql4 below        /////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////




//=============================================================================
Function JADO_RECORDSET.OpenMySQL(
  p_saCMD: AnsiString;
  Var p_oADOC: JADO_CONNECTION;
  p_bLogError: boolean;
  p_u8Caller: uint64
):Boolean;
//=============================================================================
Var
  bOk: Boolean;
  saSourceRoutine: AnsiString;
  //u_ODBC_Columns_Loop:SQLUSMALLINT;
  u4Columns_Loop: dword;
  //i4ODBCERRORCODE : LongInt;

  //rMySQLField: PMYSQL_FIELD;
  //lp: pointer;
  sa:AnsiString;

  saUpCase: ansistring;
  SQL_Catalog: ANSISTRING;
  SQL_Schema: ansistring;
  SQL_Table: ansistring;
  SQL_TableTypeOrCol: ansistring;
  lpSQL_Catalog: pointer;
  lpSQL_Schema: pointer;
  lpSQL_Table: pointer;
  lpSQL_TableTypeOrCol: pointer;
  lenSQL_Catalog: longint;
  lenSQL_Schema: longint;
  lenSQL_Table: longint;
  lenSQL_TableTypeOrCol: longint;
  SQL_Unique: word;
  SQL_Reserved: word;
  saODBCCommandType: ansistring;

  iRetries: longint;
  u8MySqlResult: uint64;
  u8Zero: UInt64; // compensating for fpc 2.6.x 64 uint bug - can't compare constant to variable
  {$IFDEF SQLTRACE}
  f: text; // this is for the sqltrace diagnostic below that is commented out
  u2IOResult: word;// this is for the sqltrace diagnostic below that is commented out
  {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.OpenMySQL(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION):Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  saSourceRoutine:=SOURCEFILE + ' JADO_RECORDSET.OpenMySQL(p_saCMD: AnsiString; Var p_oADOC: JADO_CONNECTION)';

  u8Zero:=0;
  bOk:=p_oADOC<>nil;
  If not bOk Then 
  Begin
    JLog(cnLog_ERROR, 20060925,'Caller: '+inttostr(p_u8Caller)+' p_oADOC Connection NIL on Entry. ' + saSourceRoutine,sourcefile);
  End;
  
  If bOk Then 
  Begin
    self.activeConnection:=p_oADOC;
    bOk:=ActiveConnection.i4State=adStateOpen;
    If not bOk Then 
    Begin
      p_oADOC.Errors.AppendItem_Error(200609250955,
      200609250955,'Caller: '+inttostr(p_u8Caller)  +' JADO-MYSQL: Connection not in Open State on entry. ' +
      saSourceRoutine,'',True);
      JLog(cnLog_ERROR, 200609250955,'success lost here ' + saSourceRoutine,sourcefile);
    End;
  End;
  

  If bOk Then
  Begin
    //JLog(cnLog_DEBUG,0,'Caller: '+p_saCaller+' About to try mysql_real_connect with Server:' + ActiveConnection.saMyServer +
    //  ' Username:'+ActiveConnection.saMyUserName+' Password:'+ActiveConnection.saMyPassword,sourcefile);
    If length(ActiveConnection.saMyServer)=0 Then lpMySQLHost:=nil else lpMySQLHost:=pointer(ActiveConnection.saMyServer);
    If length(ActiveConnection.saMyUserName)=0 Then lpMySQLUser:=nil Else lpMySQLUser:=pointer(ActiveConnection.saMyUserName);
    If length(ActiveConnection.saMyPassword)=0 Then lpMySQLPasswd:=nil Else lpMySQLPasswd:=pointer(ActiveConnection.saMyPassword);

    //lpMySQLPtr:=mysql_real_connect(
    //  PMySQL(@ActiveConnection.rMySql),
    //  lpMySQLHost,
    //  lpMySQLUser,
    //  lpMySQLPasswd,
    //  nil,
    //  0,
    //  nil,
    //  0);
    iRetries:=0;
    repeat
      mysql_init(@self.rMySql);
      lpMySQLPtr:=mysql_real_connect(
        PMySQL(@self.rMySql),
        lpMySQLHost,
        lpMySQLUser,
        lpMySQLPasswd,
        nil,
        ActiveConnection.u4MyPort,
        nil,
        0);
      bOk:=lpMySQLPtr<>nil;
      iRetries:=iRetries+1;
      if not bOk then
      begin
        sleep(100);
      end;
    until (iRetries>100) or (bOk);


    If not bOk Then
    Begin
      i4State:=adStateClosed;
      sa:='Caller: '+inttostr(p_u8Caller)+' JADO-MYSQL: Unable to connect. Check Credentials, network, and server itself. MYSQL:' + 
        mysql_error(@self.rMySQL) + ' ConPort: ' +inttostr(ActiveConnection.u4MyPort) + saSourceRoutine;
      ActiveConnection.Errors.AppendItem_Error(0,201002071146,sa,'',True);
      JLog(cnLog_ERROR, 200609120429, sa, SOURCEFILE);
    End
    Else
    Begin
      //sa:='Actually connected to the MYSQL Database!';
      //JLog(cnLog_DEBUG, 200609251300, sa, SOURCEFILE);
    End;
  End;
  

  If bOk Then
  Begin
    If length(trim(ActiveConnection.saMyDatabase))>0 Then
    Begin
      bOK:= u8Zero = mysql_select_db(lpMySQLPtr,PChar(ActiveConnection.saMyDatabase));
      if not bOk then
      Begin
        sa:='Caller: '+inttostr(p_u8Caller)+' JADO-MYSQL: Unable to change to database:' + ActiveConnection.saMyDatabase + ' MYSQL:' + mysql_error(@self.rMySQL) + ' ';
        //JLog(cnLog_ERROR, 200609120432, sa, SOURCEFILE);
        ActiveConnection.Errors.AppendItem_Error(0,200609120432,sa + saSourceRoutine,'',True);
        JLog(cnLog_ERROR, 200609120432,'success lost here ' + saSourceRoutine,sourcefile);
      End;
      // No Else cuz its ok if no need to change database.
    End
    Else
    Begin
      sa:='Caller: '+inttostr(p_u8Caller)+' length(trim(ActiveConnection.saMyDatabase))=0';
      ActiveConnection.Errors.AppendItem_Error(0,200610021149,sa + saSourceRoutine,'',True);
      JLog(cnLog_ERROR, 200610021149,'success lost here ' + saSourceRoutine,sourcefile);
    End;
  End;  
    
  //riteln('ahh.. in '+saSourceRoutine);
  //riteln('ABOUT to do this:iMySQLUID:=p_oADOC.iMySQLUID;');
  
  //riteln('Past 1');
  If bOk Then 
  Begin
    bOk:=lpMySQLResults=nil;
    If not bOk Then 
    Begin
      sa:='Caller: '+inttostr(p_u8Caller)+' JADO-MYSQL: lpMySQLResults was not NIL on entry Command:' + p_saCMD + ' ' + saSourceRoutine;
      p_oADOC.Errors.AppendItem_Error(0,200609250955,sa,'',True);
      JLog(cnLog_ERROR, 200609250955,'success lost here ' + sa,sourcefile);
    End;
  End;
  
  {$IFDEF ODBC}
  If bOk Then
  Begin
    bOk:=Jegas_SQL_Wedge(
      p_saCmd,
      p_oADOC,
      saUpCase,
      SQL_Catalog,
      SQL_Schema,
      SQL_Table,
      SQL_TableTypeOrCol,
      lpSQL_Catalog,
      lpSQL_Schema,
      lpSQL_Table,
      lpSQL_TableTypeOrCol,
      lenSQL_Catalog,
      lenSQL_Schema,
      lenSQL_Table,
      lenSQL_TableTypeOrCol,
      SQL_Unique,
      SQL_Reserved,
      saODBCCommandType
    );
  end;  
  {$ENDIF} 
 
  If bOk and (ODBCCOMMANDTYPE<>cnODBC_SQL) Then
  begin
    case ODBCCommandType of 
    cnODBC_SQL:;
    cnODBC_SQLTables:p_saCMD:='show full tables';
    cnODBC_SQLColumns:;
    cnODBC_SQLColumnPrivileges:;
    cnODBC_SQLStatistics:;
    cnODBC_SQLTablePrivileges:;
    end;//switch
  end;
  














  If bOk Then
  Begin  
    //riteln('About to execute the Query:',p_saCmd);
    //riteln('ActiveConnection:',Cardinal(ActiveConnection));
    //riteln('ActiveConnection.lpMySQLPtr:',Cardinal(ActiveConnection.lpMySQLPtr));
    u8MySqlResult:=mysql_query(lpMySQLPtr,PChar(p_saCMD));
    //if (pos('INSERT',UPCASE(p_saCMD))<>0) then
    //begin
    //  riteln('u8MySqlResult: ',u8MySqlResult,'   '+p_saCMD);
    //  riteln('u8MySqlResult=u8Zero:' , u8MySqlResult=u8Zero);
    //end;
    bOk:= u8MySqlResult=u8Zero;
    If (not bOk) and p_bLogError Then
    Begin
      //riteln('ERROR: ',u8MySqlResult);
      sa:='Caller: '+inttostr(p_u8Caller)+' mysql_error:'+
        mysql_error(@self.rMySQL)+' Command:' + p_saCMD + ' mysql_query(lpMySQLPtr, PCHAR(p_saCmd)) failed. lpMySQLPtr:';
      sa+=inttostr(UINT(lpMySQLPtr));
      sa+=' '+ saSourceRoutine;
      p_oADOC.Errors.AppendItem_Error(0,200609251001,sa,'',True);
      //Log(cnLog_ERROR, 200609251101,'success lost here ' + sa ,sourcefile);
      //log(cnLog_ERROR, 200609251102,'MYSQL ERROR: ' + mysql_error(@self.rMySQL) ,sourcefile);
    End;
    //riteln('Made it past the execute the query part');


    {$IFDEF SQLTRACE}
    bTSOpenTextFile(grJASCOnfig.saLogDir+'sqltrace.sql',u2IOREsult,f,false,true);
    write(f,'"'+saTrueFalse(bOk)+'"');
    writeln(f,',"'+saSNRStr(saSNRStr(p_saCMD,'"','[@QUOTE@]'),'[@QUOTE@]','""')+'"');
    bTSCloseTextFile(grJASCOnfig.saLogDir+'sqltrace.sql',u2IOREsult,f);
    {$ENDIF}
  End;

  If bOk Then
  Begin
    //riteln('About to Store the results...');
    lpMySQLResults:=mysql_store_result(lpMySQLPtr);
  End;
      

  //riteln('Past 2');
  If bOk Then
  Begin
    i4State:=adStateOpen;
    If lpMySQLResults<>nil Then // Got Results?
    Begin
      //riteln('Checking Results Rows and Cols');
      u4Rows:=mysql_num_rows(lpMySQLResults);
      u4RowsLeft:=u4Rows;      
      u4Columns:=mysql_num_fields(lpMySQLResults);
      
      // Normally you get two fields back.. we need to improvise
      If bOk and (ODBCCOMMANDTYPE<>cnODBC_SQL) Then
      begin
        case ODBCCommandType of 
        cnODBC_SQL:;
        cnODBC_SQLTables:u4Columns:=5;//TABLE_CAT	TABLE_SCHEM	(TABLE_NAME)	(TABLE_TYPE)	REMARKS
        cnODBC_SQLColumns: u4Columns:=18;// TABLE_CAT	TABLE_SCHEM	TABLE_NAME	COLUMN_NAME	DATA_TYPE	TYPE_NAME	COLUMN_SIZE	BUFFER_LENGTH	DECIMAL_DIGITS	NUM_PREC_RADIX	NULLABLE	REMARKS	COLUMN_DEF	SQL_DATA_TYPE	SQL_DATETIME_SUB	CHAR_OCTET_LENGTH	ORDINAL_POSITION	IS_NULLABLE
        cnODBC_SQLColumnPrivileges:;
        cnODBC_SQLStatistics:;
        cnODBC_SQLTablePrivileges:;
        end;//switch
      end;
      //riteln('Have Results Rows:',u4rows, ' Fields:', u4Columns);
    End;
  End;
  
  //riteln('Getting to MySQL4 "Describe the Columns" Code');
  // Describe the columns -----------------------------------------------------------
  If bOk Then
  Begin
    If lpMySQLResults<>nil Then  // Have Results :)
    Begin
      u4Columns_Loop:=0; // MySQL Fields are ZERO based, 0 is first column, not a bookmark column like in odbc
      repeat 
        If not Fields.AppendItem Then 
        Begin
          //riteln('Describe column thing - add fields FAILED!');
          Halt(5);
        End;

        case ODBCCommandType of 
        cnODBC_SQL: begin
          JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=u4Columns_Loop;
          // This Describes the Columns, and the JADO_RECORDSET.Fields(xdl)'s XDL 
          // ITEMS (JADO_FIELDS), becomes the landing ZONE of the result sets, because 
          // the pointers are given to ODBC below.
          {
            Function mysql_fetch_field_direct(res:PMYSQL_RES; fieldnr:dword):PMYSQL_FIELD;
            
            Type
              Pst_mysql_field = ^st_mysql_field;
              st_mysql_field = Record
                   name : PChar;
                   table : PChar;
                   org_table : PChar;
                   db : PChar;
                   def : PChar;
                   length : dword;
                   max_length : dword;
                   flags : dword;
                   decimals : dword;
                   ftype : enum_field_types;
                End;
              MYSQL_FIELD = st_mysql_field;
              TMYSQL_FIELD = MYSQL_FIELD;
              PMYSQL_FIELD = ^MYSQL_FIELD;
           } 
          JADO_FIELD(Fields.lpItem).rMySQLField:=mysql_fetch_field_direct(lpMySQLResults, u4Columns_Loop);
          JADO_FIELD(Fields.lpItem).saName:=PChar(JADO_FIELD(Fields.lpItem).rMySQLField^.name);
          bOk:=JADO_FIELD(Fields.lpItem).rMySQLField<>nil;
          If not bOk Then
          Begin
            //riteln('got error');
            sa:='Caller: '+inttostr(p_u8Caller)+' JADO-MYSQL: Failure mysql_fetch_field. Failed on Column# '+
              saStr(u4Columns_Loop)+' of '+ saStr(u4Columns)+ '. Command:' + p_saCMD + 
              ' MYSQL:' + mysql_error(lpMySQLPtr) + ' ' + saSourceRoutine;
            p_oADOC.Errors.AppendItem_Error(0,200609120534,sa,'',True);
            JLog(cnLog_ERROR, 200609120534,'success lost here ' + sa,sourcefile);
          End;
        end;
        // TABLE_CAT	TABLE_SCHEM	(TABLE_NAME)	(TABLE_TYPE)	REMARKS
        cnODBC_SQLTables:begin 
          case u4Columns_Loop of 
          0:begin
            JADO_FIELD(Fields.lpItem).rMySQLField:=nil;
            JADO_FIELD(Fields.lpItem).saName:='TABLE_CAT';
            JADO_FIELD(Fields.lpItem).saValue:='';
            JADO_FIELD(Fields.lpItem).saDesc:='';
          end;
          1:begin
            JADO_FIELD(Fields.lpItem).rMySQLField:=nil;
            JADO_FIELD(Fields.lpItem).saName:='TABLE_SCHEM';
            JADO_FIELD(Fields.lpItem).saValue:='';
            JADO_FIELD(Fields.lpItem).saDesc:='';
          end;
          2:begin // column 3 = mysql table name(col 0)
            JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=0;
            JADO_FIELD(Fields.lpItem).rMySQLField:=mysql_fetch_field_direct(lpMySQLResults, 0);
            JADO_FIELD(Fields.lpItem).saName:='TABLE_NAME';
            bOk:=JADO_FIELD(Fields.lpItem).rMySQLField<>nil;
            If not bOk Then
            Begin
              //riteln('got error');
              sa:='Caller: '+inttostr(p_u8Caller)+' JADO-MYSQL: Failure mysql_fetch_field. Failed on Column# '+
                saStr(u4Columns_Loop)+' of '+ saStr(u4Columns)+ ' during SQLTables Wedge. Command:' + p_saCMD + 
                ' MYSQL:' + mysql_error(lpMySQLPtr) + ' ' + saSourceRoutine;
              p_oADOC.Errors.AppendItem_Error(0,201007080414,sa,'',True);
              JLog(cnLog_ERROR, 201007080414,'success lost here ' + sa,sourcefile);
            End;
          end;
          3:begin //// column 4 = mysql table type(col 1)
            JADO_FIELD(Fields.lpItem).ODBCColumnNumber:=1;
            JADO_FIELD(Fields.lpItem).rMySQLField:=mysql_fetch_field_direct(lpMySQLResults, 1);
            JADO_FIELD(Fields.lpItem).saName:='TABLE_TYPE';
            bOk:=JADO_FIELD(Fields.lpItem).rMySQLField<>nil;
            If not bOk Then
            Begin
              //riteln('got error');
              sa:='Caller: '+inttostr(p_u8Caller)+' JADO-MYSQL: Failure mysql_fetch_field. Failed on Column# '+
                saStr(u4Columns_Loop)+' of '+ saStr(u4Columns)+ ' during SQLTables Wedge. Command:' + p_saCMD + 
                ' MYSQL:' + mysql_error(lpMySQLPtr) + ' ' + saSourceRoutine;
              p_oADOC.Errors.AppendItem_Error(0,201007080415,sa,'',True);
              JLog(cnLog_ERROR, 201007080415,'success lost here ' + sa,sourcefile);
            End;
          end;
          4:begin
            JADO_FIELD(Fields.lpItem).rMySQLField:=nil;
            JADO_FIELD(Fields.lpItem).saName:='REMARKS';
            JADO_FIELD(Fields.lpItem).saValue:='';
            JADO_FIELD(Fields.lpItem).saDesc:='';
          end; 
          end;//switch       
        end;
        cnODBC_SQLColumns:; 
        cnODBC_SQLColumnPrivileges:;
        cnODBC_SQLStatistics:;
        cnODBC_SQLTablePrivileges:;
        end;//switch
        
        Inc(u4Columns_Loop);
      Until (not bOk) OR (u4Columns_Loop=u4Columns);
    End;

    If bOk Then
    Begin
      If (lpMySQLResults<>nil) and (u4RowsLeft>0)Then
      Begin
        //riteln('About to mysql fetch');
        bOk:=self.bMySQLFetchRecord(p_oadoc);        
        //riteln('back from mysql fetch');
      End;
      // Fail Clean Up - Clean Up Fields
      If not bOk Then
      Begin
        Fields.DeleteAll;
        sa:='success lost here  u4RowsLeft:' +  inttostr(u4RowsLeft) +
          'u4RowsRead: ' + inttostr(u4RowsRead) + ' lpMySQLResults:';
        sa+=inttostr(UINT(lpMySQLResults));
        sa+='  Source Routine:'+saSourceRoutine; JLog(cnLog_ERROR, 200610021155,sa,sourcefile);
      End;
    End;
  End;


  If bOk Then
  Begin
    i4State:=adStateOpen; // I'm OPEN!
  End
  Else
  Begin
    i4State:=adStateClosed;
    If lpMySQLResults<>nil Then
    Begin
      mysql_free_result(lpMySQLResults);
      lpMySQLResults:=nil;
    End;
    If lpMySQLPtr<>nil Then 
    Begin
      mysql_close(lpMySQLPtr);
      lpMySQLPtr:=nil;
    End;
  End;
  Result:=bOk;
  //riteln('openmysql ok: ',bOk);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Function JADO_RECORDSET.bMySQLFetchRecord(Var p_oADOC: JADO_CONNECTION): Boolean;
//=============================================================================
Var 
  bOk: Boolean;
  //saSourceroutine: AnsiString;
  //u4ColumnsLoop: dword;
  //u4: dword;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.bMySQLFetchRecord(Var p_oADOC: JADO_CONNECTION): Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  bOk:=(u4RowsLeft>0);
  If bOk Then
  Begin
    self.aRowBuf:=nil;
    aRowBuf:=mysql_fetch_row(lpMySQLResults);
    u4RowsLeft-=1; // how mysql eof recordset managed.
    u4RowsRead+=1;
  End;

  If bOk Then
  Begin
    If fields.movefirst Then
    Begin
      // COPY reference to Each Field Item in Fields.
      repeat
        case ODBCCommandType of 
        cnODBC_SQL: begin
          //riteln('Fields.N=',fields.N);
          fields.item_savalue:=PChar(arowbuf[fields.n-1]);
          if arowbuf[fields.n-1]=nil then
          begin
            fields.item_sadesc:='NULL';
            fields.item_savalue:='NULL';
          end
          else
          begin
            fields.item_sadesc:='';
          end;
        end;
        cnODBC_SQLTables:begin //TABLE_CAT	TABLE_SCHEM	(TABLE_NAME)	(TABLE_TYPE)	REMARKS
          case (fields.n-1) of       
          0: begin
            fields.item_sadesc:='TABLE_CAT';
            fields.item_savalue:='';
          end;
          1: begin
            fields.item_sadesc:='TABLE_SCHEM';
            fields.item_savalue:='';
          end;
          2: begin
            fields.item_savalue:=PChar(arowbuf[0]);
            if arowbuf[0]=nil then
            begin
              fields.item_sadesc:='NULL';
              fields.item_savalue:='NULL';
            end
            else
            begin
              fields.item_sadesc:='';
            end;
          end;
          3: begin
            fields.item_savalue:=PChar(arowbuf[1]);
            if arowbuf[1]=nil then
            begin
              fields.item_sadesc:='NULL';
              fields.item_savalue:='NULL';
            end
            else
            begin
              fields.item_sadesc:='';
            end;
            if fields.item_savalue='BASE TABLE' then fields.item_savalue:='TABLE';
          end;
          4: begin
            fields.item_sadesc:='REMARKS';
            fields.item_savalue:='';
          end;
          end;//switch
        end;
        cnODBC_SQLColumns:begin // TABLE_CAT	TABLE_SCHEM	TABLE_NAME	COLUMN_NAME	DATA_TYPE	TYPE_NAME	COLUMN_SIZE	BUFFER_LENGTH	DECIMAL_DIGITS	NUM_PREC_RADIX	NULLABLE	REMARKS	COLUMN_DEF	SQL_DATA_TYPE	SQL_DATETIME_SUB	CHAR_OCTET_LENGTH	ORDINAL_POSITION	IS_NULLABLE
        
        end;
        cnODBC_SQLColumnPrivileges:;
        cnODBC_SQLStatistics:;
        cnODBC_SQLTablePrivileges:;
        end;//switch
        
        
        //riteln('TRYING to WRITE the FETCH ROW DATA:',PChar(arowbuf[fields.n-1]));
      Until not fields.movenext;
    End;
  End;
  Result:=bOk;
  //riteln('--------------LEAVING FETCH ROW------------');
  //MySQLShowRecord;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure JADO_RECORDSET.MySQLShowRecord;
//=============================================================================
Var u4: dword;
    
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_RECORDSET.MySQLShowRecord;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  //riteln('---MYSQLShowRecord:Begin');
  if ODBCCommandType=cnODBC_SQL then
  begin
    If u4columns>0 Then
    Begin
      For u4:=0 To u4Columns-1 Do 
      Begin
        Write(PChar(aRowBuf[u4]), #9);
      End;
      //riteln;
    End;
  end;
  //riteln('---MYSQLShowRecord:end');

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================





















//                     JADO_RECORDSET Above
////////////////////////////////////////////////////////////////////////////////////////
//                     JADO_CONNECTION below    
























//=============================================================================
Constructor JADO_CONNECTION.create;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.create;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  pvt_init;
  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Constructor JADO_CONNECTION.createcopy(p_JADOC: JADO_CONNECTION); // OVERRIDE BUT INHERIT
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.createcopy(p_JADOC: JADO_CONNECTION);';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  pvt_init;

  u2DbmsID:=p_JADOC.u2DBMSID;
  u2DrivID:=p_JADOC.u2DrivID;
  saName:=p_JADOC.saName;
  saDesc:=p_JADOC.saDesc;
  saDSN:=p_JADOC.saDSN;
  saUserName:=p_JADOC.saUserName;
  saPassword:=p_JADOC.saPassword;
  saDriver:=p_JADOC.saDriver;
  saServer:=p_JADOC.saServer;
  saDatabase:=p_JADOC.sadatabase;
  bConnected:=false;// do not copy state
  bConnecting:=False;// do not copy state
  bInUse:=False;// don't copy state
  bFileBasedDSN:=p_JADOC.bFileBasedDSN;
  saDSNFileName:=p_JADOC.saDSNFilename;
  ID:=p_JADOC.ID;
  saConnectionString:=p_JADOC.saConnectionString;
  saDefaultDatabase:=p_JADOC.saDefaultDatabase;
  Errors:= JADO_Errors.create;
  saProvider:=p_JADOC.saProvider;
  i4State:=adStateClosed;// LongInt; // STATE: ADODB.ObjectStateEnum - Default: adStateClosed
  saVersion:=p_JADOC.saVersion;
  if p_JADOC.JASTABLEMATRIX<>nil then
  begin
    JASTABLEMATRIX:=JFC_MATRIX.CreateCopy(p_JADOC.JASTABLEMATRIX);
  end;
  bJAS:=p_JADOC.bJAS;
  OrigJADOC:=p_JADOC;
  JDCon_JSecPerm_ID:=p_JADOC.JDCon_JSecPerm_ID;
  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
procedure JADO_CONNECTION.pvt_Init;
//=============================================================================
Var 
  //i2ODBCResult: SmallInt;
  saSourceRoutine: AnsiString;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.pvt_Init;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  // BEGIN JADO_DATASOURCE MERGE
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  //=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

  u2DbmsID:=cnDBMS_MySQL;// LongInt;   // DBMSID IS DBMS Dialect Selection (-1=Not Set Yet)
  u2DrivID:=cnDriv_MySQL;// LongInt;   // TODO: CHANGING THIS VALUE - As using 0 = NOTHING. Used -1 before when Signed int used.
                                       // (0=ODBC) For when ODBC isn't the connection method, which DBMS driver
  saName:='';// AnsiString;
  saDesc:='';// AnsiString;
  saDSN:='';// AnsiString;
  saUserName:='';// AnsiString;
  saPassword:='';// AnsiString;
  saDriver:='';// AnsiString; // ODBC Driver Name (Win32 Specific Maybe)
  saServer:=''; //AnsiString;
  saDatabase:=''; //AnsiString;
  bConnected:=False; //Boolean;
  bConnecting:=False;// Boolean;
  bInUse:=False;// Boolean;  // Set to True and false by user and timer
                      // Timer IGNORES if set to TRUE - This timer
                      // is only SchemaMaster Specific.
  bFileBasedDSN:=False;// Boolean; // file based DSN, nothing to do with saving connection as file
  saDSNFileName:='';// AnsiString;
  ID:='0';
  JDCon_JSecPerm_ID:='0';
  saSourceRoutine:=SOURCEFILE + ' JADO_CONNECTION.pvt_init;';
  saConnectionString:='';// AnsiString;
  saDefaultDatabase:='';// AnsiString;
  Errors:= JADO_Errors.create;
  saProvider:='';// AnsiString;
  i4State:=adStateClosed;// LongInt; // STATE: ADODB.ObjectStateEnum - Default: adStateClosed
  saVersion:=''; //AnsiString; // ADODB.Connection.VERSION
  {$IFDEF ODBC}
  ODBCDBHandle:=nil;
  {$ENDIF}
  
  Case u2DrivID Of
  cnDriv_ODBC:;
  cnDriv_MySQL:;
  else
  Begin
    Errors.AppendItem_Error(0,200609131245, 'JADO: Bad self.u8DrivID:'+saStr(self.u2DrivID)+' '+saSourceRoutine, '', True);
  end//case
  End;//switch

  // -- JAS RELATED
  bJAS:=false;
  JASTABLEMATRIX:=nil;
  OrigJADOC:=nil;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================





//=============================================================================
Function JADO_CONNECTION.OpenCon(p_saConnectionString: AnsiString):Boolean;
//=============================================================================
Var
  {$IFDEF ODBC}i2ODBCResult: SmallInt;{$ENDIF}
  saSourceRoutine: AnsiString;
  saTemp: AnsiString;
  sa: AnsiString;
  i4Pos: longint;
  TK: JFC_TOKENIZER;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.OpenCon(p_saConnectionString: AnsiString):Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=false;
  TK:=JFC_TOKENIZER.Create;
  saSourceRoutine := SOURCEFILE + '.JADO_CONNECTION.OpenCon(p_saConnectionString: AnsiString);';
  If i4State=adStateClosed Then
  Begin
    saMyConnectString:=''; saMyUserName:=''; saMyPassword:=''; saMyDatabase:='';
    saMyServer:='';
    
    saTemp:=p_saConnectionString; 
    TK.SetDefaults;
    TK.saSeparators:=';=';
    TK.saWhiteSpace:=';=';
    TK.Tokenize(saTemp);
    //TK.DumpToTextFile('ztk_jado_connection.txt');
    If TK.FoundItem_saToken('UID',False) Then
    Begin
      TK.MoveNext;
      saMyUserName:=TK.Item_saToken;
    End;
    If TK.FoundItem_saToken('PWD',False) Then
    Begin
      TK.MoveNext;
      saMyPassword:=TK.Item_saToken;
    End;

    Case u2DrivID Of
    {$IFDEF ODBC}
    cnDriv_ODBC: Begin
        If TK.FoundItem_saToken('DSN',False) Then
        Begin
          TK.MoveNExt;
          saMyConnectString:=TK.Item_saToken;
        End;
        If saMyconnectstring='' Then
        Begin
          saMyConnectString:=p_saConnectionString;
        End;
        
        
        If JADO.bODBC_OK Then
        Begin
          i4State:=adStateConnecting;
          i2ODBCResult:=SQLAllocHandle(SQL_HANDLE_DBC, JADO.ODBCEnvHandle, ODBCDBHandle);
          If i2ODBCResult<>SQL_SUCCESS Then
          Begin
            Errors.AppendItem_Error(LongInt(i2ODBCResult),
              200609091011, 'ODBC: Could Not Create ODBC Database Handle. ' + 
              saSourceRoutine, '', True);
            ODBCDBHandle:=nil;
          End;
          
          If (i2ODBCResult=SQL_SUCCESS) Then
          begin
            i2ODBCResult:=SQLConnect(ODBCDBHandle,PSQLChar(saMyConnectString),SQL_NTS,
                            PSQLChar(saMyUserName),SQL_NTS,
                            PSQLCHAR(saMyPassword),SQL_NTS);
  
            If (i2ODBCResult<>SQL_SUCCESS) and (i2ODBCResult<>SQL_SUCCESS_WITH_INFO) Then
            Begin
              ODBCSQLGetDiag(
                SQL_HANDLE_DBC, 
                ODBCDBHandle,
                200609091012,
                'Connect Issue? ',
                saSourceRoutine,
                True,
                True
              );
            End;          
          end;
          
          If (i2ODBCResult=SQL_SUCCESS) OR (i2ODBCResult=SQL_SUCCESS_WITH_INFO) Then
          Begin
            i4State:=adStateOpen;
            JADO.i4ODBCConCount+=1;
          End
          Else
          Begin
            If i2ODBCResult<>SQL_SUCCESS_WITH_INFO Then 
            Begin
              i4State:=adStateClosed;
            End;
          End;
        End;
      End;
    {$ENDIF}
    cnDriv_MySQL:
      Begin
        If TK.FoundItem_saToken('Database',False) Then
        Begin
          TK.MoveNext;
          saMyDataBase:=TK.Item_saToken;
        End;
        If TK.FoundItem_saToken('Server',False) Then
        Begin
          TK.MoveNext;
          saMyServer:=TK.Item_saToken;
          u4MyPort:=3306;
          i4Pos:=pos(':',saMyServer);
          if i4Pos>1 then
          begin
            sa:=saleftstr(saMyServer,i4Pos-1);
            u4MyPort:=iVal(sarightstr(saMyServer,length(saMyServer)-i4Pos));
            saMyServer:=sa;
          end
        End;
        //If TK.FoundItem_saToken('Port',False) Then
        //Begin
        //  TK.MoveNext;
        //  saMyPort:=TK.Item_saToken;
        //End;
        
        //riteln('Server:',saMyServer);
        //riteln('U:',saMyUsername);
        //riteln('P:',saMyPassword);
        //riteln('DB:',saMyDatabase);
        //riteln('port:',u4MyPort);
        
        i4State:=adStateOpen; // Actual Credential check happens during open
        // recordset with MySQL4 driver.
      End;
    Else
      Begin
        JLog(cnLog_WARN, 200609131246, 'JADO: Unknown Driver - u2DrivID:'+saStr(self.u2DrivID)+' '+saSourceRoutine , SOURCEFILE);
      End;
    End;//switch
  End
  Else
  Begin
    Errors.AppendItem_Error(200609091121,
        200609091121,'Action is not allowed if the connection is not closed. ' +  
        saSourceRoutine,'',True);
  End;
  TK.Destroy;
  Result:=(i4State=adStateopen);
  

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JADO_CONNECTION.OpenCon: boolean; // uses internal values
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.OpenCon: boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=bConnectTo;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
Function JADO_CONNECTION.CloseCon: Boolean;
//=============================================================================
Var 
  saSourceRoutine: AnsiString;
//  lp: pointer;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.CloseCon: Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  saSourceRoutine:='Procedure JADO_CONNECTION.CloseCon;';
  If i4State=adStateOpen Then
  Begin
    Case u2DrivID Of
    {$IFDEF ODBC}
    cnDriv_ODBC: Begin
        SQLFreeHandle(SQL_HANDLE_DBC,ODBCDBHandle);
        ODBCDBHandle:=nil;
        JADO.i4ODBCConCount-=1;
        If JADO.i4ODBCConCount<=0 Then
        Begin
          JADO.i4ODBCConCount:=0;// just in case goes below - though shouldn't
          // RELEASE ENV handle
          //if JADO.ODBCEnvHandle<>0 then
          SQLFreeHandle(SQL_HANDLE_ENV,JADO.ODBCEnvHandle);
          JADO.ODBCEnvHandle:=nil;
        End;
        i4State:=adStateClosed;
      End;
    {$ENDIF}
    cnDriv_MySQL: Begin
        i4State:=adStateClosed; 
        //mysql_close(PMySQL(@rMySql));
      End;
    Else
      Begin
        Errors.AppendItem_Error(200609131247,
          200609131247, 'JADO: Unknown Driver u2DrivID:'+saStr(self.u2DrivID)+' '+
          saSourceRoutine, '', True);
      End;
    End;//switch    
  End;
  //Else
  //Begin
  //  Errors.AppendItem_Error(200609120131,
  //      200609120131,'Action is not allowed if the connection is not open. ' +  
  //      saSourceRoutine,'',True);
  //End;
  Result:=(i4State=adStateClosed);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Destructor JADO_CONNECTION.Destroy;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.Destroy;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  // NOTE: THIS CALL to self.close MUST occur BEFORE any classes within are 
  // destroyed in case they are called during the CLOSE method.
  If self.i4State=adStateOpen Then 
  Begin
    self.CloseCon;
  End;
  Errors.Destroy;
  if JASTABLEMATRIX<>nil then JASTABLEMATRIX.Destroy;
  Inherited;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

{$IFDEF ODBC}
//=============================================================================
Procedure JADO_CONNECTION.ODBCSQLGetDiag(
  p_SQLHandleType: LongInt; 
  p_SQLHandle: pointer;
  p_i8Number: Int64;
  p_saMsg: AnsiString;
  p_saSource: AnsiString;
  p_bAll: Boolean;
  p_bDropToLog: Boolean
);
//=============================================================================
Var 
  i2ODBCResult: SmallInt;  
  achODBCSQLSTATE: array[0..4] Of Char;
  i_ODBC_NAtiveError: SQLINTEGER;
  lpODBC_MessageErrorText: PChar;
  i_ODBC_MessageLength: SQLSMALLINT;
  i_ODBC_DiagRecNo: SQLSMALLINT;  
  saErrorMessage: AnsiString;
  bDone: Boolean;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.ODBCSQLGetDiag(p_SQLHandleType: LongInt;p_SQLHandle: pointer;p_i8Number: Int64;p_saMsg: AnsiString;p_saSource: AnsiString;p_bAll: Boolean;p_bDropToLog: Boolean);';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  //                          
  //Type   TSQLGetDiagRec=Function (HandleType:SQLSMALLINT;
  //   Handle:SQLHANDLE;RecNumber:SQLSMALLINT;
  //   Sqlstate:PSQLCHAR;Var NativeError:SQLINTEGER;
  //   MessageText:PSQLCHAR;BufferLength:SQLSMALLINT;
  //   Var TextLength:SQLSMALLINT ):SQLRETURN;extdecl;
  lpODBC_MessageErrorText:=getmem(2024);
  i_ODBC_DiagRecNo:=1;
  bDone:=False;
  repeat
    i2ODBCResult:=SQLGetDiagRec(
      p_SQLHandleType, 
      p_SQLHandle,
      i_ODBC_DiagRecNo, 
      @achODBCSQLSTATE,
      i_ODBC_NativeError,
      lpODBC_MessageErrorText,
      2024, 
      i_ODBC_MessageLength);
      
    bDone:=(i2ODBCResult=SQL_NO_DATA);
    
    If not bDone Then
    Begin
      //riteln('SQLSTATE:',achODBCSQLSTATE);
      //riteln('MESSAGE: ', AnsiString(lpODBC_MessageErrorText));

      // ERRORS.AppendItem_ERROR Parameters
      //p_i4NativeError: LongInt;
      //p_i8Number: Int64;
      //p_saSource: AnsiString;
      //p_saSQLState: String
      saErrorMessage:='Message: ' + p_saMsg + ' ODBCSQLGetDiag:' + AnsiString(lpODBC_MEssageErrorText)+
          ' SQL State:' + achODBCSQLSTATE + 
          ' SOURCE: ' + p_saSource + ' '+
          ' i2ODBCResult: '+inttostr(i2ODBCResult);
      //riteln('GetDiag Message:',saErrorMessage);
      Errors.AppendItem_Error(
          i_ODBC_NativeError,
          p_i8Number,
          saErrorMessage,
          achODBCSQLSTATE,
          p_bDropToLog
      );
    End;
    i_ODBC_DiagRecNo:=i_ODBC_DiagRecNo+1;
  Until (bdone) OR (p_bAll=False);
  freemem(lpODBC_MessageErrorText);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================
{$ENDIF}


  
//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function JADO_CONNECTION.saDBMSScrub(p_sa: AnsiString): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSScrub(p_sa: AnsiString): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

   result:=JADO.saDBMSScrub(p_sa, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function JADO_CONNECTION.saDBMSDateScrub(p_sa: AnsiString): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSDateScrub(p_sa: AnsiString): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

   result:=JADO.saDBMSDateScrub(p_sa, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function JADO_CONNECTION.saDBMSDateScrub(p_dt: TDateTime): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSDateScrub(p_dt: TDateTime): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

   result:=JADO.saDBMSDateScrub(p_dt, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function JADO_CONNECTION.saDBMSDateScrub(p_ts: TTimeStamp): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSDateScrub(p_ts: TTimeStamp): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

   result:=JADO.saDBMSDateScrub(p_ts, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
// Returns Proper boolean representation for the passed DBMS  
Function JADO_CONNECTION.saDBMSBoolScrub(p_b: boolean): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSBoolScrub(p_b: boolean): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

 result:=JADO.saDBMSBoolScrub(p_b, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
// Returns Proper boolean representation for the passed DBMS  
Function JADO_CONNECTION.saDBMSBoolScrub(p_sa: ansistring): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSBoolScrub(p_sa: ansistring): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

 result:=JADO.saDBMSBoolScrub(p_sa, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function JADO_CONNECTION.saDBMSIntScrub(p_sa: AnsiString): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSIntScrub(p_sa: AnsiString): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

   result:=JADO.saDBMSIntScrub(p_sa, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function JADO_CONNECTION.saDBMSIntScrub(p_i8: int64): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSIntScrub(p_i8: int64): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

   result:=JADO.saDBMSIntScrub(p_i8, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function JADO_CONNECTION.saDBMSDecScrub(p_sa: AnsiString): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSDecScrub(p_sa: AnsiString): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

   result:=JADO.saDBMSDecScrub(p_sa, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database. 
// !! NOTE: THIS Puts the Quotes on For you!
Function JADO_CONNECTION.saDBMSUIntScrub(p_sa: AnsiString): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSUIntScrub(p_sa: AnsiString): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

   result:=JADO.saDBMSUIntScrub(p_sa, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
// This basically is sent one of the cnDBMS_?????? constants to determine
// how to escape texual data bound for a database.
// !! NOTE: THIS Puts the Quotes on For you!
Function JADO_CONNECTION.saDBMSUIntScrub(p_u8: UInt64): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSUIntScrub(p_u8: UInt64): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

   result:=JADO.saDBMSUIntScrub(inttostr(p_u8), self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
// Returns Proper boolean representation for the passed DBMS  
Function JADO_CONNECTION.saDBMSWild: AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSWild: AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  result:=JADO.saDBMSWild(self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
Function JADO_CONNECTION.saDBMSEncloseObjectName(p_saObjectName: ansistring): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSEncloseObjectName(p_saObjectName: ansistring): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  result:=JADO.saDBMSEncloseObjectName(p_saObjectName, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
Function JADO_CONNECTION.saDBMSCleanObjectName(p_saObjectName: ansistring): AnsiString;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saDBMSCleanObjectName(p_saObjectName: ansistring): AnsiString;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  result:=JADO.saDBMSCleanObjectName(p_saObjectName, self.u2DBMSID);

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================




//=============================================================================
Function JADO_CONNECTION.bLoad(p_saFileName: AnsiString): Boolean;
//=============================================================================
Var 
  sa: AnsiString;
  ftext: text;
  saBeforeEqual: AnsiString;
  u2IOResult: word;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bLoad(p_saFileName: AnsiString): Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  Result:= False;
  //InitConnectionRecord(rCon);
  If FileExists(p_saFileName) Then
  Begin
    if bTSOpenTextFile(
      p_saFilename,
      u2IOResult,
      ftext,
      true,
      false
    )then 
    begin
      While not Eof(ftext) Do
      Begin
        readln(ftext, sa);
        sa:= Trim(sa);
        If (Length(sa) <> 0) and (LeftStr(sa, 1) <> ';') Then
        Begin
          // MsgBox sGetStringBeforeEqualSign(s)
          saBeforeEqual:=UpCase(saGetStringBeforeEqualSign(sa));
          If saBeforeEqual='DBMSID' Then self.u2DbmsID := u2val(saGetStringAfterEqualSign(sa));
          If saBeforeEqual='DRIVID' Then self.u2DrivID := u2Val(saGetStringAfterEqualSign(sa));
          If saBeforeEqual='NAME' Then self.saName := saGetStringAfterEqualSign(sa);
          If saBeforeEqual='DESC' Then self.saDesc := saGetStringAfterEqualSign(sa);
          If saBeforeEqual='DSN' Then self.saDSN := saGetStringAfterEqualSign(sa);
          If saBeforeEqual='USERNAME' Then self.saUserName := saGetStringAfterEqualSign(sa);
          If saBeforeEqual='PASSWORD' Then self.saPassword := saGetStringAfterEqualSign(sa);
          If saBeforeEqual='DRIVER' Then self.saDriver := saGetStringAfterEqualSign(sa);
          If saBeforeEqual='SERVER' Then self.saServer := saGetStringAfterEqualSign(sa);
          If saBeforeEqual='DATABASE' Then self.saDatabase := saGetStringAfterEqualSign(sa);
          If saBeforeEqual='FILEBASEDDSN' Then self.bFileBasedDSN := bval(saGetStringAfterEqualSign(sa));
          If saBeforeEqual='DSNFILENAME' Then self.saDSNFileName := saGetStringAfterEqualSign(sa);
        End;// if
      End;// while loop
      Result := bTSCloseTextFile(
        p_saFilename,
        u2IOResult,
        ftext
      );
    end;
  End 
  Else
  Begin
    // do nothing - this function should return false then!
  End;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JADO_CONNECTION.bSave(p_saFileName: AnsiString): Boolean;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bSave(p_saFileName: AnsiString): Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  Result:=self.bSave(p_saFilename, False);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JADO_CONNECTION.bSave(
  p_saFileName: AnsiString;
  p_bOverWriteAlways: Boolean
):Boolean;
//=============================================================================
Var 
  bPerformSave: Boolean;
  ftext: text;  
  u2IOREsult:word;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bSave(p_saFileName: AnsiString;p_bOverWriteAlways: Boolean):Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  Result:=False;
  bPerformSave:=p_bOverWriteAlways;
  If not bPerformSave Then
  Begin
    If FileExists(p_saFileName) Then
    Begin
      //bPerformSave:=MsgBox("Overwrite " + p_sFileName + " ?", vbOKCancel + vbQuestion, "File Exists") = vbOK
      bPerformSave:=False; // Unless a UI where you can ask the user I suppose.
    End
    Else
    Begin
      bPerformSave:=True;
    End;
  End;
  If bPerformSave Then
  Begin  
    //.sFileName = p_sFileName
    //subSaveConnection (p_i4Which)
    if bTSOpenTextFile(
      p_saFilename,
      u2IOResult,
      ftext,
      false,
      false
    )then
    begin
      Writeln(ftext, ';==============================================================================');
      Writeln(ftext, ';|    _________ _______  _______  ______  ______| This is a proprietary config-');
      Writeln(ftext, ';|   /___  ___// _____/ / _____/ / __  / / _____/ uration file designed for use');
      Writeln(ftext, ';|      / /   / /__    / / ___  / /_/ / / /____ | with Jegas, LLC Software');
      Writeln(ftext, ';|     / /   / ____/  / / /  / / __  / /____  / |');
      Writeln(ftext, ';|____/ /   / /___   / /__/ / / / / / _____/ /  |');
      Writeln(ftext, ';/_____/   /______/ /______/ /_/ /_/ /______/   |    http://www.jegas.com');
      Writeln(ftext, ';|         Virtually Everything IT(tm)          |');
      Writeln(ftext, ';==============================================================================');
      Writeln(ftext, '; This file WAS not designed to be edited manually, however if you do wish to');
      Writeln(ftext, '; edit this file manually, remember that WHITESPACE is not permitted after the');
      Writeln(ftext, '; EQUAL (=) sign: e.g. Variable=Value  (THIS IS OK)');
      Writeln(ftext, ';                 e.g. Variable= Value (THIS IS NOT OK)');
      Writeln(ftext, ';==============================================================================');
      Writeln(ftext, '; Copyright  2012 Jegas, LLC  - All Rights Reserved   ');
      Writeln(ftext, ';==============================================================================');
      Writeln(ftext, '; Connection Name:         ', self.saName);
      Writeln(ftext, '; Connection Desc:         ', self.saDesc);
      Writeln(ftext, '; Original Filename:       ', p_saFileName);
      Writeln(ftext, '; Generated:               ', saFormatDateTime(csDATETIMEFORMAT,Now()));
      Writeln(ftext, '; Generating Application:  ', grJegasCommon.saAppTitle);
      Writeln(ftext, ';            EXE:          ', grJegasCommon.saAppEXEName);
      Writeln(ftext, ';            Path:         ', grJegasCommon.saAppPath);
      Writeln(ftext, ';            Product Name: ', grJegasCommon.saAppProductName);
      Writeln(ftext, ';            Version:      ', grJegasCommon.saAppMajor, '.', grJegasCommon.saAppMinor, '.', grJegasCommon.saAppRevision);
      Writeln(ftext, ';==============================================================================');
      Writeln(ftext, '; DBMSID IS DBMS Dialect Selection (0=Not Set Yet)');
      Writeln(ftext, ';  1 =   Generic');
      Writeln(ftext, ';  2 =   MS-SQL');
      Writeln(ftext, ';  3 =   Access');
      Writeln(ftext, ';  4 =   MySQL');
      Writeln(ftext, ';  5 =   Excel');
      Writeln(ftext, ';  6 =   dBase');
      Writeln(ftext, ';  7 =   FoxPro');
      Writeln(ftext, ';  8 =   Oracle');
      Writeln(ftext, ';  9 =   Paradox');
      Writeln(ftext, '; 10 =   Text');
      Writeln(ftext, '; 11 =   PostGresSQL');
      Writeln(ftext, 'DbmsID=',Trim(saStr(self.u2DbmsID)));
      Writeln(ftext, csEOL + csEOL);
      Writeln(ftext, '; DrivID is DBMS Driver ID of NON ODBC Connections.');
      Writeln(ftext, ';  1 =   ODBC');
      Writeln(ftext, ';  2 =   MySql');
      Writeln(ftext, 'DrivID=',Trim(saStr(self.u2DrivID)));
      Writeln(ftext, csEOL + csEOL);
      Writeln(ftext, 'Name=', self.saName);
      Writeln(ftext, 'Desc=' + self.saDesc);
      Writeln(ftext, 'DSN=' + self.saDSN);
      Writeln(ftext, 'UserName=' + self.saUserName);
      Writeln(ftext, 'Password=' + self.saPassword);
      Writeln(ftext, 'Driver=' + self.saDriver);
      Writeln(ftext, 'Server=' + self.saServer);
      Writeln(ftext, 'Database=' + self.saDatabase);
      Writeln(ftext, csEOL + csEOL);
      Writeln(ftext, ';FileBasedDSN has to do with the ODBC connection, not this file.');
      Writeln(ftext, 'FileBasedDSN=' + saYesNo(self.bFileBasedDSN));
      Writeln(ftext, '; Filebased Databases are handled in this way during the actual connection:');
      Writeln(ftext, '; FIRST:  if the the Database Variable above has a value at all, that is the ');
      Writeln(ftext, ';         filename that is used for the database when the FileBased Variable ');
      Writeln(ftext, ';         above is set to Yes.');
      Writeln(ftext, '; SECOND: if the Database Variable Above is EMPTY and the FileBased Variable');
      Writeln(ftext, ';         above is set to Yes, then the FileName Variable''s value (below) is ');
      Writeln(ftext, ';         used. ');
      Writeln(ftext, '; Therefore (psuedo-code to demonstrate logic): ');
      Writeln(ftext, '; IF FILEBASEDDSN = YES and DATABASENAME = SOMETHING THEN');
      Writeln(ftext, ';   DataBaseFileToOpen = SOMETHING');
      Writeln(ftext, '; ELSE');
      Writeln(ftext, ';   DataBaseFileToOpen=DSNFILENAME''s VALUE');
      Writeln(ftext, '; END IF');
      Writeln(ftext, csEOL + csEOL);
      Writeln(ftext, 'DSNFileName=' + self.saDSNFileName);
      Writeln(ftext, csEOL + csEOL);
      Writeln(ftext, ';==============================================================================');
      Writeln(ftext, '; EOF');
      Writeln(ftext, ';==============================================================================');
      result:=bTSCloseTextFile(p_saFilename,u2IOResult,ftext);
    end;
  End;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================









//=============================================================================
Function JADO_CONNECTION.bConnectTo:Boolean;
//=============================================================================
Var 
  bOk:Boolean;
  saConString: AnsiString;
  JADOR: JADO_RECORDSET;
  saErrMsg: ansistring;
  saQry: ansistring;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bConnectTo:Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JADOR:=JADO_RECORDSET.Create;
  {$IFDEF DIAGMSG}
  writeln;
  writeln('201001151506 - BEGIN JADO_CONNECTION.bConnectTo');
  {$ENDIF}
  
  bOk:=False;
  saConString:='';
  If not bInUse Then
  Begin
    {$IFDEF DIAGMSG}
    writeln('201001151506 - not in use so gonna be');
    {$ENDIF}
    self.bInUse:=True;
    // First Verify if it says its connected - is it REALLY?
    If self.bConnected Then
    Begin
      {$IFDEF DIAGMSG}
      writeln('201001151506 - state check because connected flag set');
      {$ENDIF}
      If i4State=adStateClosed Then
      Begin
        self.bConnected:=False;
      End;
    end
    else
    begin
      {$IFDEF DIAGMSG}
      writeln('201101021152 - self.bConnected: '+saTRueFalse(self.bConnected));
      {$ENDIF}
    End;
    
    If (not self.bConnected) and (not self.bConnecting) Then
    Begin
      {$IFDEF DIAGMSG}
      writeln('201001151506 - Connecting');
      {$ENDIF}
      self.bConnecting:= True;
      {$IFDEF DIAGMSG}
      writeln('connecting...');
      {$ENDIF}
      If self.bFileBasedDSN and (Trim(self.saDatabase) = '') Then self.saDatabase:= self.saDSNFileName;
      saConString:= JADO.saBuildConnectString(self.saDSN, self.saDriver, self.saServer, self.saUserName, self.saPassword, self.saDatabase, self.bFileBasedDSN, self.u2DrivID);
      
      If self.u2DbmsID = cnDBMS_MySQL Then
      Begin
        // One Suggestion for...
        // MYSQL BUG with ADO : Bug: #13776: Invalid string or buffer length error
        // Was the Below OPTION to be added to the connect string.
        // It didn't help.
          saConString:= saConString + 'OPTION=133121;';
      End;
      {$IFDEF DIAGMSG}
      writeln('First Actual JADO_CONNECTION.open(saConstring) saConstring:',saconstring);
      {$ENDIF}
      
      {$IFDEF DIAGMSG}
      writeln('201001151506 - Actual call to OpenCON(con str)');
      {$ENDIF}
      bOk:=OpenCon(saConString);
      if not bOk then
      Begin
        {$IFDEF DIAGMSG}
        writeln('201001151506 - Attempt #2 call to OpenCON(con str)');
        writeln('had errors...');
        {$ENDIF}
        Errors.DeleteAll;
        saConString:= self.saBuildConnectString;
        bOk:=OpenCon(saConString);
      End;
      
      if bOk then
      begin
        bOk:=JADOR.Open('select 1',self,201503161700);
        JADOR.Close;
      end;
      
      If (bOk) Then // No Errors? Continue
      Begin
        {$IFDEF DIAGMSG}
        writeln('201001151506 - Connection is open - perform connect tasks');
        {$ENDIF}
        self.bConnected:= True;
        self.bConnecting:= False;
      End
      Else
      Begin
        saErrMsg:='u01g_jado.JADO_CONNECTION.bConnectTo - Connection Failed to Open. ';
        Errors.AppendItem_Error(
          201003061809,
          201003061809,
          saErrMsg,
          '',
          true
        );
        self.bConnecting:=False;
        self.bConnected:=False;
      End;
    End
    Else
    Begin
      JASPrintln('JADO_CONNECTION - Connection Failure. [2011011214]'+
        '[JAS: see both jas.cfg and jas.dbc for correct database settings.'
      );
      {$IFDEF DIAGMSG}
      JASPrintln('201001151506 - this test produced false: If self.bConnect and (not self.bConnected) and (not self.bConnecting) and (self.bValid)');
      //JASPrintln('201001151506 - self.bConnect:'+saTrueFalse(bConnect));
      JASPrintln('201001151506 - self.bConnected:'+saTrueFalse(bConnected));
      JASPrintln('201001151506 - self.bConnecting:'+saTrueFalse(bConnecting));
      //JASPrintln('201001151506 - self.bValid:'+saTrueFalse(bValid));
      {$ENDIF}
      //bsave('test.txt',true);debug thing
      
      saErrMsg:='u01g_jado.JADO_CONNECTION.bConnectTo - Connection Not in agreeable State to proceed with connection. ';
      if self.bConnected then saErrMsg+='bConnected Flag reports this connection is already connected. ';
      if self.bConnecting then saErrMsg+='bConnecting Flag reports this connection is already trying to connect. ';
      Errors.AppendItem_Error(
        201003061735,
        201003061735,
        saErrMsg,
        '',
        true
      );
      {$IFDEF DIAGMSG}
      If not self.bConnected Then
      Begin
        writeln('201001151506 - Not connected - after test fail');
      End;
      {$ENDIF}
    End;
    self.bInUse := False;
  End
  Else
  Begin
    Errors.AppendItem_Error(
      0,
      201003061727,
      'u01g_jado.JADO_CONNECTION.bConnectTo',
      '',
      true
    );
     
  End;
  
  
  if bOk and bJAS then
  begin
    if JASTABLEMATRIX=nil then
    begin
      if OrigJADOC=nil then // is not a copy
      begin
        JASTABLEMATRIX:=JFC_MATRIX.Create;
      end
      else
      begin // is a copy
        JASTABLEMATRIX:=JFC_MATRIX.CreateCopy(OrigJADOC.JASTABLEMATRIX);
      end;  
    end;
    
    if OrigJADOC=nil then // is not a copy
    begin
      JASTABLEMATRIX.DeleteAll;
      JASTABLEMATRIX.SetNoOfColumns(4);
      // query grabbing fields in this order
      // so JFC_MATRIX notion of Name, Value, Description column aliases apply.

      saQry:='select JTabl_JTable_UID, JTabl_Name, JTabl_JDConnection_ID, '+
             'JTabl_ColumnPrefix from jtable where JTabl_Deleted_b<>'+saDBMSBoolScrub(true);
      if JADOR.Open(saQry,self,201503161701) then
      begin
        if JADOR.EOL = false then
        begin
          repeat
            JASTABLEMATRIX.AppendItem;
            JASTABLEMATRIX.Set_Matrix(1, trim(JADOR.Fields.Get_saValue('JTabl_Name')));
            JASTABLEMATRIX.Set_Matrix(2, JADOR.Fields.Get_saValue('JTabl_JTable_UID'));
            JASTABLEMATRIX.Set_Matrix(3, trim(JADOR.Fields.Get_saValue('JTabl_JDConnection_ID')));
            JASTABLEMATRIX.Set_Matrix(4, JADOR.Fields.Get_saValue('JTabl_ColumnPrefix'));
          until not JADOR.MoveNext;
          //LOG(cnLog_Debug, 201006250902, JASTABLEMATRIX.saHTMLTable, SOURCEFILE);
        end;
      end
      else
      begin
          saErrMsg:='u01g_jado.JADO_CONNECTION.bConnectTo - JAS connection (bJas) flag set to true but unable to load jtable information ';
          Errors.AppendItem_Error(
            201003090248,
            201003090248,
            saErrMsg,
            '',
            true
          );
      end;
      JADOR.Close;
    end;
    
  end;
  
  
  JADOR.Destroy;
  Result:=bOk;
  {$IFDEF DIAGMSG}
  writeln('201001151506 - END JADO_CONNECTION.bConnectTo');
  {$ENDIF}


{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================








//=============================================================================
Function JADO_CONNECTION.bClose:Boolean;
//=============================================================================
Var 
  bOk: Boolean;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bClose:Boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  bOk:=False;
  If i4State = adStateOpen Then
  Begin
    CloseCon;
  End;
  self.bConnected:= False;
  self.bConnecting:= False;
  bOk:=True;
  Result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
function JADO_CONNECTION.saBuildConnectString: ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saBuildConnectString: ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=JADO.saBuildConnectString(
    self.saDSN, 
    self.saDriver, 
    self.saServer, 
    self.saUserName, 
    self.saPassword, 
    grJegasCommon.saAppPath + csDOSSLASH + self.saDatabase, 
    self.bFileBasedDSN,
    self.u2DrivID
  );
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function JADO_CONNECTION.bIsCopy: boolean;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bIsCopy: boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  result:=OrigJADOC<>nil;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
function JADO_CONNECTION.saGetTableID(p_saJDConnectionID, p_saTable: ansistring; p_u8Caller: UInt64):ansistring;
//=============================================================================
var 
  i4Index: longint;
  bDone: boolean;
  saUpcaseTableName: ansistring;
  u8ValJDConnectionID: Uint64;
  saErrMsg: ansistring;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saGetTableID(p_saJDConnectionID, p_saTable: ansistring):ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:='0';
  if (i8Val(p_saTable)=0) and (p_saTable<>'') and (p_saTable<>'0') then
  begin
    saUpcaseTablename:=upcase(p_saTable);
    u8ValJDConnectionID:=u8Val(p_saJDConnectionID);
    i4Index:=-1;
    if bJAS then
    begin
      // Col1 = tablename
      // col2 = table uid
      // col3 = jdconnection id
      with JASTABLEMATRIX do begin
        //Log(0,0,'Seeking:'+saUpcaseTablename,SOURCEFILE);
        i4Index:=iFoundItem(1,saUpcaseTablename,false);
        //Log(0,0,'FirstItem Result i4Index:'+inttostr(i4Index),SOURCEFILE);
        repeat
          bDone:=i4Index<0;
          //Log(0,0,'bDone='+satruefalse(bDone)+' i4Index:'+inttostr(i4Index),SOURCEFILE);
          if not bDone then
          begin
            bDone:=(upcase(Get_saMatrix(1,iNth))=saUpcaseTablename) and 
                   (u8val(Get_saMatrix(3,iNth))=u8ValJDConnectionID);
            if not bDone then
            begin
              JLog(cnLog_Error,201003211956,'No Match - Caller: '+inttostr(p_u8Caller),SOURCEFILE);
              JLog(cnLog_Error,201003211956,'No Match - Get_saMatrix(1,iNth):'+Get_saMatrix(1,iNth)+' saUpcaseTablename:'+saUpcaseTablename,SOURCEFILE);
              JLog(cnLog_Error,201003211956,'No Match - Get_saMatrix(3,iNth):'+Get_saMatrix(3,iNth),SOURCEFILE);
              JLog(cnLog_Error,201003211956,'No Match - ival(Get_saMatrix(3,iNth)):'+inttostr(u8Val(Get_saMatrix(3,iNth))),SOURCEFILE);
              JLog(cnLog_Error,201003211956,'No Match - i4ValJDConnectionID:'+inttostr(u8ValJDConnectionID),SOURCEFILE);
            end;
            
            if not bDone then
            begin
              //Log(0,0,'iFoundNext result:'+inttostr(i4Index),SOURCEFILE);
              i4Index:=iFoundNext(1,saUpcaseTablename,false,iNth);
              //Log(0,0,'iFoundNext result:'+inttostr(i4Index),SOURCEFILE);
            end;
          end;
        until bDone;
        //Log(0,0,'DONE i4Index:'+inttostr(i4Index),SOURCEFILE);
        if i4Index>-1 then
        begin
          result:=Get_saMatrix(2,iNth);
        end;
      end;
    end;
    if i4Index=-1 then
    begin
      saErrMsg:='u01g_jado.JADO_CONNECTION.saGetTableID Failed. ';
      saErrMsg+='bJAS: '+saTrueFalse(bJas)+' Table Name Sought: '+p_saTable+' ';
      saErrMsg+='JDConnectionID: '+ p_saJDConnectionID;
      Errors.AppendItem_Error(
        201003101425,
        201003101425,
        saErrMsg,
        'Caller: '+inttostr(p_u8CalleR),
        true
      );
    end;
  end
  else
  begin
    result:=p_saTable;// got numeric id
  end;  
  //Log(cnLog_debug,201006251040,'Result: '+Result,SOURCEFILE);
  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function JADO_CONNECTION.saGetTable(p_saTableID: ansistring):ansistring;
//=============================================================================
var 
  saErrMsg: ansistring;
  iX: Longint;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saGetTable(p_saJDConnectionID, p_saTableID: ansistring):ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:='';
  if self.bJAS then
  begin
    if (i8Val(p_saTableID)=0) and (p_saTableID<>'') and (p_saTableID<>'0') then
    begin
      result:=p_saTableID;// Have Table Name Already Presumably
    end
    else
    begin
      // Col1 = tablename
      // col2 = table uid
      // col3 = jdconnection id
      iX:=JASTABLEMATRIX.iFoundItem(2, p_saTableID, false);
      //if p_saTableID='121' then JLog(cnLog_Debug,201007042058, 'JADO.saGetTableName - iX:'+inttostr(iX),SOURCEFILE);
      if iX>-1 then 
      begin
        result:=JASTABLEMATRIX.Get_saElement(iX-1);
        //if p_saTableID='121' then JLog(cnLog_Debug,201007042100, 'JADO.saGetTableName - Result:'+result,SOURCEFILE);
      end;
    end;  
    //Log(cnLog_debug,201006251041,'Result: '+Result,SOURCEFILE);
  
    if result='' then
    begin
      saErrMsg:='u01g_jado.JADO_CONNECTION.saGetTable Failed. ';
      saErrMsg+='bJAS: '+saTrueFalse(bJas)+' Table ID Sought: '+p_saTableID+' ';
      Errors.AppendItem_Error(
        201006211819,
        201006211819,
        saErrMsg,
        '',
        true
      );
    end;
  end
  else
  begin
    saErrMsg:='u01g_jado.JADO_CONNECTION.saGetTable Failed. ';
    saErrMsg+='bJAS: '+saTrueFalse(bJas)+' Table ID Sought: '+p_saTableID+' ';
    saErrMsg+='ERROR REASON: This function not valid for NON-JAS JADO connection.';
    Errors.AppendItem_Error(
      201007041052,
      201007041052,
      saErrMsg,
      '',
      true
    );
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
function JADO_CONNECTION.saGetColumnID(
  p_JDConnection_ID: ansistring;
  p_JTable_Name: ansistring;
  p_JColumn_Name: Ansistring
): ansistring;
//=============================================================================
var
  saQry: ansistring;
  JColumn_ID: ansistring;
  JADOR: JADO_RECORDSET;
  bOk: boolean;
  saErrMsg: ansistring;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saGetColumnID(p_JDConnection_ID: ansistring;p_JTable_Name: ansistring;p_JColumn_Name: Ansistring): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  JADOR:=JADO_RECORDSET.Create;
  JColumn_ID:=Trim(p_JColumn_Name);//This allows passing actual column ID if necessary versus column name
  if (i8Val(JColumn_ID)=0) and (JColumn_ID<>'') and (JColumn_ID<>'0') then
  begin
    // May have actual column name here.
    saQry:='select JColu_JColumn_UID from jcolumn where ' +
      'JColu_JDConnection_ID='+saDBMSScrub(p_JDConnection_ID)+' and '+
      'JColu_JTable_ID=' +saGetTableID(p_JDConnection_ID,p_JTable_Name,201210012300) +' and '+
      'JColu_Name='+saDBMSScrub(p_JColumn_Name)+' and '+
      'JColu_Deleted_b<>'+saDBMSBoolScrub(true);
    bOk:=JADOR.Open(saQry,self,201503161702);
    if not bOk then
    begin
      saErrMsg:='u01g_jado.JADO_CONNECTION.saGetColumnID Failed. ';
      saErrMsg+='bJAS: '+saTrueFalse(bJas)+' JDConnection: '+p_JDConnection_ID+' ';
      saErrMsg+='JTable: '+ p_JTable_Name+' ';
      saErrMsg+='JColumn: ' + p_JColumn_Name;
      saErrMsg+='Query: '+saQry;
      Errors.AppendItem_Error(
        201004042308,
        201004042308,
        saErrMsg,
        '',
        true
      );
    end;  
    if bOk then
    begin
      bOk:=JADOR.eol=false;
      if not bOk then
      begin
        saErrMsg:='u01g_jado.JADO_CONNECTION.saGetColumnID Failed (Could not get record for requested column.) ';
        saErrMsg+='bJAS: '+saTrueFalse(bJas)+' JDConnection: '+p_JDConnection_ID+' ';
        saErrMsg+='JTable: '+ p_JTable_Name+' ';
        saErrMsg+='JColumn: ' + p_JColumn_Name;
        saErrMsg+='Query: '+saQry;
        Errors.AppendItem_Error(
          201004042308,
          201004042308,
          saErrMsg,
          '',
          true
        );
      end;
    end;
    
    if bOk then
    begin
      JColumn_ID:=JADOR.Fields.Get_saValue('JColu_JColumn_UID');
    end;
    
    JADOR.Close;  
  end
  else
  begin
    JColumn_ID:='0';
  end;
  JADOR.Destroy;
  result:=JColumn_ID;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
function JADO_CONNECTION.saGetColumnPrefix(p_saJDConnectionID, p_saTable: ansistring):ansistring;
//=============================================================================
var 
  i4Index: longint;
  bDone: boolean;
  saUpcaseTableName: ansistring;
  u8ValJDConnectionID: Uint64;
  saErrMsg: ansistring;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saGetColumnPrefix(p_saJDConnectionID, p_saTable: ansistring):ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:='';
  //LOG(cnLog_Debug, 201006250903, JASTABLEMATRIX.saHTMLTable, SOURCEFILE);
  if NOT ((i8Val(p_saTable)=0) and (p_saTable<>'') and (p_saTable<>'0')) then
  begin
    // We got a Table ID... Geesh...
    p_saTable:=saGetTable(p_saTable);//have ID - connection donesnt matter
  end;
  
  if (i8Val(p_saTable)=0) and (p_saTable<>'') and (p_saTable<>'0') then
  begin
    saUpcaseTablename:=upcase(p_saTable);
    u8ValJDConnectionID:=u8Val(p_saJDConnectionID);
    i4Index:=-1;
    if bJAS then
    begin
      // Col1 = tablename (0)
      // col2 = table uid (1)
      // col3 = jdconnection id (2)
      // col4 = Column Prefix (3)
      with JASTABLEMATRIX do begin
        //Log(0,0,'Seeking:'+saUpcaseTablename,SOURCEFILE);
        i4Index:=iFoundItem(1,saUpcaseTablename,false);
        //Log(0,0,'FirstItem Result i4Index:'+inttostr(i4Index),SOURCEFILE);
        repeat
          bDone:=i4Index<0;
          //Log(0,0,'bDone='+satruefalse(bDone)+' i4Index:'+inttostr(i4Index),SOURCEFILE);
          if not bDone then 
          begin
            bDone:=(upcase(Get_saMatrix(1,iNth))=saUpcaseTablename) and 
                   (u8val(Get_saMatrix(3,iNth))=u8ValJDConnectionID);
            if not bDone then
            begin
              JLog(cnLog_Error,201006242039,'No Match - Get_saMatrix(1,iNth):'+Get_saMatrix(1,iNth)+' saUpcaseTablename:'+saUpcaseTablename,SOURCEFILE);
              JLog(cnLog_Error,201006242039,'No Match - Get_saMatrix(3,iNth):'+Get_saMatrix(3,iNth),SOURCEFILE);
              JLog(cnLog_Error,201006242039,'No Match - ival(Get_saMatrix(3,iNth)):'+inttostr(u8Val(Get_saMatrix(3,iNth))),SOURCEFILE);
              JLog(cnLog_Error,201006242039,'No Match - i4ValJDConnectionID:'+inttostr(u8ValJDConnectionID),SOURCEFILE);
            end;
            
            if not bDone then
            begin
              //Log(0,0,'iFoundNext result:'+inttostr(i4Index),SOURCEFILE);
              i4Index:=iFoundNext(1,saUpcaseTablename,false,iNth);
              //Log(0,0,'iFoundNext result:'+inttostr(i4Index),SOURCEFILE);
            end;
          end;
        until bDone;
        //Log(0,0,'DONE i4Index:'+inttostr(i4Index),SOURCEFILE);
        if i4Index>-1 then
        begin
          // column 4 has the Table's column Prefix
          result:=Get_saMatrix(4,iNth);
        end;
      end;
    end;
    if i4Index=-1 then
    begin
      saErrMsg:='u01g_jado.JADO_CONNECTION.saGetColumnPrefix Failed. ';
      saErrMsg+='bJAS: '+saTrueFalse(bJas)+' Table Name Sought: '+p_saTable+' ';
      saErrMsg+='JDConnectionID: '+ p_saJDConnectionID;
      Errors.AppendItem_Error(
        201006242040,
        201006242040,
        saErrMsg,
        '',
        true
      );
    end;
  end
  else
  begin
    saErrMsg:='u01g_jado.JADO_CONNECTION.saGetColumnPrefix Failed. ';
    saErrMsg+='bJAS: '+saTrueFalse(bJas)+' Table Name Sought: '+p_saTable+' ';
    saErrMsg+='JDConnectionID: '+ p_saJDConnectionID;
    Errors.AppendItem_Error(
      201006242041,
      201006242041,
      saErrMsg,
      '',
      true
    );
  end;  
  //Log(cnLog_debug,201006251042,'Result: '+Result,SOURCEFILE);
  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================








//=============================================================================
function JADO_CONNECTION.bCreateTable(p_saTable: ansistring; p_saDDL: ansistring): boolean;
//=============================================================================
var
  //saQry: ansistring;
  bOk: boolean;
  //rs: JADO_RECORDSET;
  //saErrMsg: ansistring;
  //saSeqTable: ansistring;
  //i4Row: longint;
  //i4Seq: longint;
  //bLocked: boolean;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bCreateTable(p_saTable: ansistring; p_saDDL: ansistring): ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  bOk:=false;
  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================












//=============================================================================
function JADO_CONNECTION.saRenderHTMLErrors: ansistring;
//=============================================================================
var saJADO_ERRORS: ansistring; 
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saRenderHTMLErrors: ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  saJADO_ERRORS:='';
  If self.Errors.ListCount=0 Then
  Begin
    saJADO_ERRORS:='<b>No Errors in JADO_CONNECTION.JADO_ERRORS</b><br />'+csCRLF;
  End
  Else
  Begin
    saJADO_ERRORS:='<font style="color: #F00000;">JADO_CONNECTION.JADO_ERRORS.ListCount:</font> <b><font style="color: #F00000;">' + saSTR(self.Errors.ListCount)+'</font></b><br />'+csCRLF;
    self.Errors.MoveFirst;
    repeat 
      saJADO_ERRORS+='<b>Error:' + saSTR(self.Errors.N)+'</b><br />'+csCRLF;
      saJADO_ERRORS+='i8NativeError: <b>' + saSTR(JADO_ERROR(self.Errors.lpItem).i8NativeError)+'</b><br />'+csCRLF;
      saJADO_ERRORS+='i8Number: <b>' + saSTR(JADO_ERROR(self.Errors.lpItem).i8Number)+'</b><br />'+csCRLF;
      saJADO_ERRORS+='saSource: <b>' + JADO_ERROR(self.Errors.lpItem).saSource+'</b><br />'+csCRLF;
      saJADO_ERRORS+='saSQLState: <b>' + JADO_ERROR(self.Errors.lpItem).saSQLState+'</b><br />'+csCRLF;
      saJADO_ERRORS+='<br />'+csCRLF;
    Until not self.Errors.Movenext;
  End;
  result:=saJADO_ERRORS;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
function JADO_CONNECTION.u8GetRowCount(p_saTable: ansistring; p_saWhereClauseOrBlank: ansistring; p_u8Caller: UInt64): UInt64;
//=============================================================================
var 
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  saErrMsg: ansistring;

{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.u8GetRowCount(p_saTable: ansistring; p_saWhereClauseOrBlank: ansistring): Int64;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  rs:=JADO_RECORDSET.create;
  saQry:='select count(*) as MyCount from ' + p_saTable;


  if trim(p_saWhereClauseOrBlank)<>'' then
  begin
    saQry+=' WHERE '+p_saWhereClauseOrBlank;
  end;

  bOk:=rs.open(saQry,self,201503161704);
  if not bOk then
  begin
    saErrMsg:='u01g_jado.JADO_CONNECTION.u8GetRowCount Failed. Caller: '+inttostr(p_u8Caller)+'  '+
              'p_saTable: '+p_saTable+' p_saWhereClauseOrBlank:'+p_saWhereClauseOrBlank+' Query:'+saQry;
    Errors.AppendItem_Error(
      201006212239,
      201006212239,
      saErrMsg,
      '',
      true
    );
  end; 
  
  if bOk then
  begin
    result:=u8Val(rs.fields.Get_saValue('MyCount'));
  end
  else
  begin
    result:=0;
    //flip unsigned to highest value - passive indicator
    // record count just failed. Log file also records NOT OK issue.
    // When debugging and you see HUGE HUGE record counts, it should
    // be a clue. Generally you have fixed your database issues before
    // this matters all too much, but I didn't want to send a ZERO
    // which is a valid response - no records means no records,
    // not necessarily an error.
    result-=1;
  end;

  rs.close;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================









//=============================================================================
// returns a single value, NULL, or blank. Blank MAY indicate No Record Found.
// this is for quick single field lookups.
function JADO_CONNECTION.saGetValue(p_saTable: ansistring; p_saField: ansistring; p_saWhereClauseOrBlank: ansistring):ansistring;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  saErrMsg: ansistring;

{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saGetValue(p_saTable: ansistring; p_saWhereClauseOrBlank: ansistring):ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  rs:=JADO_RECORDSET.create;
  result:='';

  case u2DbmsID of
  cnDBMS_MYSQL: Begin
    saQry:='SELECT '+p_saField+' FROM ' + p_saTable;
    if trim(p_saWhereClauseOrBlank)<>'' then
    begin
      saQry+=' WHERE '+p_saWhereClauseOrBlank;
    end;
    saQry+=' LIMIT 1';
  end;
  cnDBMS_MSSQL,cnDBMS_MSAccess: Begin
    saQry:='SELECT TOP 1'+p_saField+' FROM ' + p_saTable;
    if trim(p_saWhereClauseOrBlank)<>'' then
    begin
      saQry+=' WHERE '+p_saWhereClauseOrBlank;
    end;
  end;
  else begin
    JLog(cnLog_ERROR,201205030125,
      'JADO_CONNECTION.saGetValue - Unsupported DBMS ' +
      'p_iDbmsID: '+inttostr(u2DbmsID), SOURCEFILE);
  end;
  end;//switch

  //riteln('201507141200 - JADO - saGetValue Qry: ' + saQry);

  bOk:=rs.open(saQry,self,201503161705);
  if not bOk then
  begin
    saErrMsg:='JADO_CONNECTION.saGetValue Failed. ';
    saErrMsg+='p_saTable: '+p_saTable+' p_saWhereClauseOrBlank:'+p_saWhereClauseOrBlank+' Query:'+saQry;
    Errors.AppendItem_Error(
      201205030126,
      201205030127,
      saErrMsg,
      '',
      true
    );
  end;

  if bOk and (not rs.EOL) then
  begin
    result:=rs.fields.Get_saValue(p_saField);
  end;

  rs.close;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================



































//=============================================================================
function JADO_CONNECTION.bTableExists(p_saTable: ansistring; p_u8Caller: UInt64): boolean;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bTableExists(p_saTable: ansistring): boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=JADO.bTableExists(p_saTable, pointer(self), p_u8Caller);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function JADO_CONNECTION.bDropTable(p_saTable: ansistring; p_u8Caller: UInt64): boolean;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bDropTable(p_saTable: ansistring): boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=JADO.bDropTable(p_saTable, pointer(self),p_u8Caller);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function JADO_CONNECTION.bDropView(p_saTable: ansistring; p_u8Caller: UInt64): boolean;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bDropView(p_saTable: ansistring): boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=JADO.bDropTable(p_saTable, pointer(self),p_u8Caller);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function JADO_CONNECTION.bAddColumn(
  p_saTable: ansistring;
  p_saColumn: Ansistring;
  p_saColumnDefinition: ansistring;
  p_u8Caller: Uint64
): boolean;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bAddColumn(p_saTable: ansistring;p_saColumn: Ansistring;p_saColumnDefinition: ansistring): boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=JADO.bAddColumn(p_saTable, p_saColumn, p_saColumnDefinition, pointer(self), p_u8Caller);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
function JADO_CONNECTION.bColumnExists(
  p_saTable: ansistring;
  p_saColumn: Ansistring;
  p_u8Caller: UInt64
): boolean;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.bColumnExists(p_saTable: ansistring;p_saColumn: Ansistring): boolean;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=JADO.bColumnExists(p_saTable, p_saColumn, pointer(self), p_u8Caller);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================





//=============================================================================
function JADO_CONNECTION.saGetPKeyColumn(p_lpJADOC: pointer; p_saTable: ansistring; p_u8Caller: UInt64):ansistring;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saGetPKeyColumn(p_saJDConnectionID, p_saTable: ansistring):ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  result:=saGetPKeyColumnWTableID(p_lpJADOC,saGetTableID(JADO_CONNECTION(p_lpJADOC).ID, p_saTable,2010100153),p_u8Caller);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
function JADO_CONNECTION.saGetPKeyColumnWTableID(p_lpJADOC: pointer; p_sTableID: string; p_u8Caller: UInt64):ansistring;
//=============================================================================
var bOk: boolean;
  saQry: ansistring;
  rs: JADO_RECORDSET;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saGetPKeyColumn(p_saJDConnectionID, p_saTable: ansistring):ansistring;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  rs:=JADO_RECORDSET.Create;
  saQry:='select JColu_Name from jcolumn where JColu_Deleted_b<>'+saDBMSBoolScrub(true)+' and '+
    'JColu_JTable_ID='+saDBMSUIntScrub(p_sTableID)+' and '+
    'JColu_PrimaryKey_b='+saDBMSBoolScrub(true);
  bOk:=rs.open(saQry, self,201503161706);
  if not bOk then
  begin
    result:='';
  end
  else
  begin
    result:=rs.fields.Get_saValue('JColu_Name');
  end;
  rs.close;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================






//=============================================================================
function JADO_CONNECTION.saGetColumn(p_lpJADOC: pointer; p_sUID: string; p_u8Caller: UInt64): ansistring;
//=============================================================================
var bOk: boolean;
  saQry: ansistring;
  rs: JADO_RECORDSET;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_CONNECTION.saGetColumn';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  rs:=JADO_RECORDSET.Create;
  saQry:='select JColu_Name from jcolumn where JColu_Deleted_b<>'+saDBMSBoolScrub(true)+' and '+
    'JColu_JColumn_UID='+saDBMSUIntScrub(p_sUID);
  bOk:=rs.open(saQry, self,201503161707);
  if not bOk then
  begin
    result:='';
  end
  else
  begin
    result:=rs.fields.Get_saValue('JColu_Name');
  end;
  rs.close;
  rs.destroy;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
end;
//=============================================================================








//=============================================================================
Constructor JADO_ERROR.create;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_ERROR.create;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  Inherited;
  // Description: string; JFC_XDLITEM.saDesc will suffice
  i8NativeError:=0;// LongInt;
  i8Number:=0;// LongInt;
  saSource:='';// AnsiString;
  saSQLState:='';// String;
  
{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Destructor JADO_ERROR.destroy; // OVERRIDE but inherit
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_ERROR.destroy;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  Inherited;  

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Constructor JADO_ERRORS.create;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_ERRORS.create;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  Inherited;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Destructor JADO_ERRORS.destroy;
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_ERRORS.destroy;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  Inherited;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Function JADO_ERRORS.pvt_CreateItem: JADO_ERROR; 
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_ERRORS.pvt_CreateItem: JADO_ERROR;';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  Result:=JADO_ERROR.create;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================

//=============================================================================
Procedure JADO_ERRORS.pvt_DestroyItem(p_lp:pointer);
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_ERRORS.pvt_DestroyItem(p_lp:pointer);';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  JADO_ERROR(p_lp).Destroy;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================


//=============================================================================
Procedure JADO_ERRORS.AppendItem_Error(
    p_i8NativeError: Int64;
    p_i8Number: Int64;
    p_saSource: AnsiString;
    p_saSQLState: String;
    p_bDropToLog: Boolean
  );
//=============================================================================
Var sa: AnsiString;
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='JADO_ERRORS.AppendItem_Error(p_i8NativeError: Int64;p_i8Number: Int64;p_saSource: AnsiString;p_saSQLState: String;p_bDropToLog: Boolean);';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}

  self.appenditem;
  JADO_ERROR(self.lpitem).i8NativeError:=p_i8NativeError;
  JADO_ERROR(self.lpitem).i8Number:=p_i8Number;
  JADO_ERROR(self.lpitem).saSource:=p_saSource;
  JADO_ERROR(self.lpitem).saSQLState:=p_saSQLState;
  If p_bDropToLog Then
  Begin
    sa:='(NEC#' + inttostr(p_i8NativeError) + ') '+p_saSource;
    JLog(cnLog_ERROR, p_i8Number, sa, SOURCEFILE);
  End;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
End;
//=============================================================================



//=============================================================================
// Initialization
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}var sTHIS_ROUTINE_NAME:String;{$ENDIF}
Begin
//=============================================================================
{$IFDEF DEBUGLOGBEGINEND}
  sTHIS_ROUTINE_NAME:='u01g_jado Unit Initialization';
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  {$IFDEF ODBC}
  InitialiseODBC;//For ODBCSQLDYN unit (fpc 2.4.0+)
  {$ENDIF}
  JADO:=TJADO.create;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOut(sTHIS_ROUTINE_NAME,SOURCEFILE);
{$ENDIF}
//=============================================================================
End.
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
