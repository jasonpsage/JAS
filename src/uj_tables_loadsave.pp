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
// JAS Specific Functions
Unit uj_tables_loadsave;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='uj_tables_loadsave.pp'}
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
,ug_common
,ug_jegas
,ug_jfc_xdl
,ug_jado
,uj_context
,uj_definitions
,uj_locking
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
type TJASRECORD=class(JFC_XDL)
//=============================================================================
  public
  Constructor Create(p_Context:TCONTEXT);

    private
    procedure pvt_InitJasRecordClass; // allows multiple contructors to share init code
    public
    Context: TCONTEXT;

  public
  Destructor Destroy; override;

  // To Keep JAS in the Know about the Connection we're working with
  public
  rJDConnection: rtJDConnection;

  // To Keep JAS in the Know about the Table we're working with
  rJTable: rtJTable;

  UID_rJColumn: rtJColumn; // For holding the JAS UID Column (Currently only suppoting JAS UID Key)

  // Used to MARRY a TJASRECORD class with the appropriate table and
  // connection information it will use to load and save records properly.
  function bAssignTable(p_JTabl_JTable_UID: ansistring): boolean;

  // Used when Copying Contents from ONE TJASRECORD to Another
  // or copying from a JADO_RECORDSET INTO JASRECORD or viceversa
  public
  MapXDL: JFC_XDL;// Name: Item_saName
                  // Src Name Incoming: Item_saValue (for copying FROM somewhere)
                  // Dest Name OutGoing: Item_saDesc (for copying TO somewhere)

  procedure CopyFieldFrom(p_JADO_FIELD: JADO_FIELD);//individual copy
  procedure CopyFrom(p_RS: JADO_RECORDSET);// copy whole recordset worth of fields
  procedure CopyTo(p_RS: JADO_RECORDSET);

  procedure CopyFrom(p_JR: TJASRECORD);
  procedure CopyTo(p_JR: TJASRECORD);

  function bLoad(p_bGetLock: boolean):boolean;
  function bSave(p_bHaveLock: boolean;p_bKeepLock: boolean):boolean;

  public
  Fields: JADO_FIELDS;

  procedure Clear;//removes data - by setting field values to NULL

end;
//=============================================================================





//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jadodbms(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJADODBMS: rtJADODBMS; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jadodbms(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJADODBMS: rtJADODBMS; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jadodriver(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJADODriver: rtJADODriver; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jadodriver(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJADODriver: rtJADODriver; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
//function bJAS_Load_jalias(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJAlias: rtJAlias; p_bGetLock: boolean):boolean;
function bJAS_Load_jalias(p_DBC: JADO_COnnection; var p_rJAlias: rtJAlias): boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jalias(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJAlias: rtJAlias; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jblok(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlok: rtJBlok; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jblok(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlok: rtJBlok; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jblokbutton(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokButton: rtJBlokButton; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jblokbutton(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokButton: rtJBlokButton; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jbuttontype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJButtonType: rtJButtonType; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jbuttontype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJButtonType: rtJButtonType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jblokfield(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokField: rtJBlokField; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jblokfield(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokField: rtJBlokField; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jbloktype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokType: rtJBlokType; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jbloktype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokType: rtJBlokType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jcaption(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaption: rtJCaption; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jcaption(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaption: rtJCaption; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jcase(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCase: rtJCase; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jcase(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCase: rtJCase; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jcasecategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseCategory: rtJCaseCategory; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jcasecategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseCategory: rtJCaseCategory; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jcasepriority(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCasePriority: rtJCasePriority; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jcasepriority(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCasePriority: rtJCasePriority; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jcasesource(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseSource: rtJCaseSource; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jcasesource(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseSource: rtJCaseSource; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jcasesubject(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseSubject: rtJCaseSubject; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jcasesubject(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseSubject: rtJCaseSubject; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jcasetype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseType: rtJCaseType; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jcasetype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseType: rtJCaseType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jcolumn(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJColumn: rtJColumn; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jcolumn(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJColumn: rtJColumn; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jcompany(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCompany: rtJCompany; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jcompany(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCompany: rtJCompany; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jcompanypers(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCompanyPers: rtJCompanyPers; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jcompanypers(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCompanyPers: rtJCompanyPers; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jdconnection(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJDConnection: rtJDConnection; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jdconnection(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJDConnection: rtJDConnection; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jdtype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJDType: rtJDType; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jdtype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJDType: rtJDType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jfile(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFile: rtJFile; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jfile(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFile: rtJFile; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jfiltersave(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFilterSave: rtJFilterSave; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jfiltersave(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFilterSave: rtJFilterSave; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jfiltersavedef(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFilterSaveDef: rtJFilterSaveDef; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jfiltersavedef(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFilterSaveDef: rtJFilterSaveDef; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
//function bJAS_Load_jindexfile(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIndexFile: rtJIndexFile; p_bGetLock: boolean):boolean;
function bJAS_Load_jindexfile(p_DBC: JADO_CONNECTION; var p_rJIndexFile: rtJIndexFile):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jindexfile(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIndexfile: rtJIndexfile; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jindustry(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIndustry: rtJIndustry; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jindustry(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIndustry: rtJIndustry; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jinstalled(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInstalled: rtJInstalled; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jinstalled(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInstalled: rtJInstalled; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jinterface(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInterface: rtJInterface; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jinterface(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInterface: rtJInterface; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jinvoice(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInvoice: rtJInvoice; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jinvoice(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInvoice: rtJInvoice; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jinvoicelines(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInvoiceLines: rtJInvoiceLines; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jinvoicelines(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInvoiceLines: rtJInvoiceLines; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
//function bJAS_Load_jiplist(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIPList: rtJIPList; p_bGetLock: boolean):boolean;
function bJAS_Load_jiplist(p_DBC: JADO_CONNECTION; var p_rJIPList: rtJIPList):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jiplist(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIPList: rtJIPList; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jiplistlu(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIPListLU: rtJIPListLU; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jiplistlu(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIPListLU: rtJIPListLU; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jjobq(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJJobQ: rtJJobQ; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jjobq(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJJobQ: rtJJobQ; p_bHaveLock: boolean; p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
//function bJAS_Load_jlanguage(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLanguage: rtJLanguage; p_bGetLock: boolean):boolean;
function bJAS_Load_jlanguage(p_DBC: JADO_CONNECTION; var p_rJLanguage: rtJLanguage):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jlanguage(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLanguage: rtJLanguage; p_bHaveLock: boolean; p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jlead(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLead: rtJLead; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jlead(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLead: rtJLead; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jleadsource(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLeadSource: rtJLeadSource; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jleadsource(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLeadSource: rtJLeadSource; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jmenu(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJMenu: rtJMenu; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jmenu(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJMenu: rtJMenu; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jmail(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJMail: rtJMail; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jmail(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJMail: rtJMail; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================

{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
//function bJAS_Load_jmime(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJMime: rtJMime; p_bGetLock: boolean):boolean;
function bJAS_Load_jmime(p_DBC: JADO_CONNECTION; var p_rJMime: rtJMime):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jmime(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJMime: rtJMime; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jmodc(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModC: rtJModC; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jmodc(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModC: rtJModC; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jmodule(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModule: rtJModule; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jmodule(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModule: rtJModule; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================

{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jmoduleconfig(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModuleConfig: rtJModuleConfig; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jmoduleconfig(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModuleConfig: rtJModuleConfig; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jmodulesetting(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModuleSetting: rtJModuleSetting; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jmodulesetting(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModuleSetting: rtJModuleSetting; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jnote(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJNote: rtJNote; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jnote(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJNote: rtJNote; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jperson(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJPerson: rtJPerson; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
// p_bHaveLock determines if the function attempts to lock the record before saving.
// Note: If a NEW record is created - this parameter is ignored and treated as if FALSE was passed.
function bJAS_Save_jperson(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJPerson: rtJPerson; p_bHaveLock: boolean; p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jpriority(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjpriority: rtjpriority; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jpriority(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjpriority: rtjpriority; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jproduct(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProduct: rtJProduct; p_bGetLock: boolean):boolean;
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Save_jproduct(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProduct: rtJProduct; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Load_jproductgrp(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProductGrp: rtJProductGrp; p_bGetLock: boolean):boolean;
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Save_jproductgroup(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProductGrp: rtJProductGrp; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jproductqty(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProductQty: rtJProductQty; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jproductqty(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProductQty: rtJProductQty; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jproject(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProject: rtJProject; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jproject(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProject: rtJProject; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jprojectcategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProjectCategory: rtJProjectCategory; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jprojectcategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProjectCategory: rtJProjectCategory; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_JQuickLink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJQuickLink: rtJQuickLink; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_JQuickLink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJQuickLink: rtJQuickLink; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jscreen(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJScreen: rtJScreen; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jscreen(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJScreen: rtJScreen; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jscreentype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJScreenType: rtJScreenType; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jscreentype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJScreenType: rtJScreenType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jsecgrp(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrp: rtJSecGrp; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jsecgrp(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrp: rtJSecGrp; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jsecgrplink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrpLink: rtJSecGrpLink; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jsecgrplink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrpLink: rtJSecGrpLink; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jsecgrpuserlink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrpUserLink: rtJSecGrpUserLink; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jsecgrpuserlink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrpUserLink: rtJSecGrpUserLink; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jseckey(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecKey: rtJSecKey; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jseckey(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecKey: rtJSecKey; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jsecperm(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecPerm: rtJSecPerm; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jsecperm(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecPerm: rtJSecPerm; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jsecpermuserlink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecPermUserLink: rtJSecPermUserLink; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jsecpermuserlink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecPermUserLink: rtJSecPermUserLink; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jsession(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSession: rtJSession; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jsession(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSession: rtJSession; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jsessiontype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSessionType: rtJSessionType; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jsessiontype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSessionType: rtJSessionType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jstatus(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjstatus: rtjstatus; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jstatus(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjstatus: rtjstatus; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jsysmodule(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSysModule: rtJSysModule; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jsysmodule(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSysModule: rtJSysModule; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jtable(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTable: rtJTable; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jtable(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTable: rtJTable; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jtabletype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTableType: rtJTableType; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jtabletype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTableType: rtJTableType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jtask(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTask: rtJTask; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_JTask(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTask: rtJTask; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jtaskcategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjtaskcategory: rtjtaskcategory; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jtaskcategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjtaskcategory: rtjtaskcategory; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jteam(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTeam: rtJTeam; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jteam(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTeam: rtJTeam; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jteammember(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTeamMember: rtJTeamMember; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jteammember(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTeamMember: rtJTeamMember; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jtestone(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTestOne: rtJTestOne; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jtestone(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTestOne: rtJTestOne; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jthemecolor(p_DBC: JADO_CONNECTION; var p_rJThemeColor: rtJThemeColor):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jthemecolor(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJThemeColor: rtJThemeColor; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jtimecard(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjtimecard: rtjtimecard; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jtimecard(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjtimecard: rtjtimecard; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jtrak(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTrak: rtJTrak; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
function bJAS_Save_jtrak(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTrak: rtJTrak): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_juser(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUser: rtJUser; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_juser(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUser: rtJUser; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_juserpref(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUserPref: rtJUserPref; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_juserpref(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUserPref: rtJUserPref; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
//function bJAS_Load_jvhost(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJVHost: rtJVHost; p_bGetLock: boolean):boolean;
function bJAS_Load_jvhost(p_DBC: JADO_CONNECTION; var p_rJVHost: rtJVHost):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jvhost(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJVHost: rtJVHost; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_juserpreflink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUserPrefLink: rtJUserPrefLink; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_juserpreflink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUserPrefLink: rtJUserPrefLink; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
function bJAS_Load_jwidget(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJWidget: rtJWidget; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
function bJAS_Save_jwidget(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJWidget: rtJWidget; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================
{}
// Loads a single record from the database into jas structure (pascal record) you pass in.
// See uxxj_definitions.pp for table structure definitions. To use, you load up the UID
// field of your rtSomeStructure and then call the function. It will return true upon
// successfully loading the record from the database. False otherwise.
//function bJAS_Load_jworkqueue(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJWorkQueue: rtJWorkQueue; p_bGetLock: boolean):boolean;
{}
// Updates existing record in database or creates a new record. To use, you load up
// the jas structure (pascal record) with data and set the UID field to ZERO (though
// this field is typically a string, set it to '0') and a new record will be created.
// If you pass the UID field with the UID of a record in the table already, it will
// update the existing record with the data you loaded into the structure (second
// parameter of this function)
//function bJAS_Save_jworkqueue(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJWorkQueue: rtJWorkQueue; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//==============================================================================




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
function bJAS_Load_jadodbms(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJADODBMS: rtJADODBMS; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jadodbms'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113000,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113001, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jadodbms where JADB_JADODBMS_UID='+JAS.saDBMSUIntScrub(p_rJADODBMS.JADB_JADODBMS_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jadodbms', p_rJADODBMS.JADB_JADODBMS_UID, '0',201506200200);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201203090722,'Problem locking jadodbms record.','p_rJADODBMS.JADB_JADODBMS_UID:'+p_rJADODBMS.JADB_JADODBMS_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161810);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201203090723,'Unable to query jadodbms successfully','Query:'+saQry,SOURCEFILE,JAS,rs);
    end
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201203090724,'Record missing from jadodbms.','Query:'+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJADODBMS do begin
        //JADB_JADODBMS_UID:=rs.Fields.Get_saValue('');
        JADB_Name:=rs.Fields.Get_saValue('JADV_Name');
        JADB_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JADB_CreatedBy_JUser_ID');
        JADB_Created_DT                 :=rs.Fields.Get_saValue('JADB_Created_DT');
        JADB_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JADB_ModifiedBy_JUser_ID');
        JADB_Modified_DT                :=rs.Fields.Get_saValue('JADB_Modified_DT');
        JADB_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JADB_DeletedBy_JUser_ID');
        JADB_Deleted_DT                 :=rs.Fields.Get_saValue('JADB_Deleted_DT');
        JADB_Deleted_b                  :=rs.Fields.Get_saValue('JADB_Deleted_b');
        JAS_Row_b                       :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113002,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jadodbms(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJADODBMS: rtJADODBMS; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jadodbms'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113003,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113004, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJADODBMS.JADB_JADODBMS_UID)=0 then
  begin
    bAddNew:=true;
    p_rJADODBMS.JADB_JADODBMS_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jadodbms');
    bOk:=(u8Val(p_rJADODBMS.JADB_JADODBMS_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201203090725,'Problem getting an UID for new jadodbms record.','saJAS_GetNextUID table: jadodbms',SOURCEFILE);
    end;
    if bOk then
    begin
      saQry:='INSERT INTO jadodbms (JADB_JADODBMS_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJADODBMS.JADB_JADODBMS_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161811);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201203090726,'Problem creating a new jadodbms record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJADODBMS.JADB_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJADODBMS.JADB_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJADODBMS.JADB_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJADODBMS.JADB_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJADODBMS.JADB_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJADODBMS.JADB_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jadodbms', p_rJADODBMS.JADB_JADODBMS_UID, '0',201506200201);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201203090727,'Problem locking jadodbms record.','p_rJADODBMS.JADB_JADODBMS_UID:'+p_rJADODBMS.JADB_JADODBMS_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJADODBMS do begin
      saQry:='UPDATE jadodbms set '+
        //' JADB_JADODBMS_UID: ansistring;
        'JADB_Name='+JAS.saDBMSScrub(JADB_Name);
        if(bAddNew)then
        begin
          saQry+=',JADB_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JADB_CreatedBy_JUser_ID)+
          ',JADB_Created_DT='+JAS.saDBMSDateScrub(JADB_Created_DT);
        end;
        saQry+=
        ',JADB_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JADB_ModifiedBy_JUser_ID)+
        ',JADB_Modified_DT='+JAS.saDBMSDateScrub(JADB_Modified_DT)+
        ',JADB_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JADB_DeletedBy_JUser_ID)+
        ',JADB_Deleted_DT='+JAS.saDBMSDateScrub(JADB_Deleted_DT)+
        ',JADB_Deleted_b='+JAS.saDBMSBoolScrub(JADB_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JADB_JADODBMS_UID='+JAS.saDBMSUIntScrub(JADB_JADODBMS_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161812);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201203090728,'Problem updating jadodriver.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jadodbms', p_rJADODBMS.JADB_JADODBMS_UID, '0',201506200380) then
      begin
        JAS_Log(p_Context,cnLog_Error,201203090729,'Problem unlocking jadodbms record.','p_rJADO.JADB_JADODBMS_UID:'+p_rJADODBMS.JADB_JADODBMS_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113005,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





















//=============================================================================
function bJAS_Load_jadodriver(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJADODriver: rtJADODriver; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jadodriver'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113006,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113007, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jadodriver where JADV_JADODriver_UID='+JAS.saDBMSUIntScrub(p_rJADODriver.JADV_JADODriver_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jadodriver', p_rJADODriver.JADV_JADODriver_UID, '0',201506200202);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201203090532,'Problem locking jadodriver record.','p_rJADODriver.JADV_JADODriver_UID:'+p_rJADODriver.JADV_JADODriver_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161813);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201203090533,'Unable to query jadodriver successfully','Query:'+saQry,SOURCEFILE,JAS,rs);
    end
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201203090534,'Record missing from jadodriver.','Query:'+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJADODriver do begin
        //JADV_JADODriver_UID:=rs.Fields.Get_saValue('');
        JADV_Name:=rs.Fields.Get_saValue('JADV_Name');
        JADV_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JADV_CreatedBy_JUser_ID');
        JADV_Created_DT                 :=rs.Fields.Get_saValue('JADV_Created_DT');
        JADV_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JADV_ModifiedBy_JUser_ID');
        JADV_Modified_DT                :=rs.Fields.Get_saValue('JADV_Modified_DT');
        JADV_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JADV_DeletedBy_JUser_ID');
        JADV_Deleted_DT                 :=rs.Fields.Get_saValue('JADV_Deleted_DT');
        JADV_Deleted_b                  :=rs.Fields.Get_saValue('JADV_Deleted_b');
        JAS_Row_b                       :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113008,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jadodriver(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJADODriver: rtJADODriver; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jadodriver'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113009,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113010, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJADODriver.JADV_JADODriver_UID)=0 then
  begin
    bAddNew:=true;
    p_rJADODriver.JADV_JADODriver_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jadodriver');
    bOk:=(u8Val(p_rJADODriver.JADV_JADODriver_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201203090535,'Problem getting an UID for new jadodriver record.','saJAS_GetNextUID table: jadodriver',SOURCEFILE);
    end;
    if bOk then
    begin
      saQry:='INSERT INTO jadodriver (JADV_JADODriver_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJADODriver.JADV_JADODriver_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161814);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201203090536,'Problem creating a new jadodriver record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJADODriver.JADV_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJADODriver.JADV_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJADODriver.JADV_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJADODriver.JADV_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJADODriver.JADV_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJADODriver.JADV_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jadodriver', p_rJADODriver.JADV_JADODriver_UID, '0',201506200203);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201203090537,'Problem locking jadodriver record.','p_rJADODriver.JADV_JADODriver_UID:'+p_rJADODriver.JADV_JADODriver_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJADODriver do begin
      saQry:='UPDATE jadodriver set '+
        //' JADV_JADODriver_UID: ansistring;
        'JADV_Name='+JAS.saDBMSScrub(JADV_Name);
        if(bAddNew)then
        begin
          saQry+=',JADV_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JADV_CreatedBy_JUser_ID)+
          ',JADV_Created_DT='+JAS.saDBMSDateScrub(JADV_Created_DT);
        end;
        saQry+=
        ',JADV_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JADV_ModifiedBy_JUser_ID)+
        ',JADV_Modified_DT='+JAS.saDBMSDateScrub(JADV_Modified_DT)+
        ',JADV_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JADV_DeletedBy_JUser_ID)+
        ',JADV_Deleted_DT='+JAS.saDBMSDateScrub(JADV_Deleted_DT)+
        ',JADV_Deleted_b='+JAS.saDBMSBoolScrub(JADV_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JADV_JADODriver_UID='+JAS.saDBMSUINTScrub(JADV_JADODriver_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161815);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201203090538,'Problem updating jadodriver.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jadodriver', p_rJADODriver.JADV_JADODriver_UID, '0',201506200381) then
      begin
        JAS_Log(p_Context,cnLog_Error,201203090539,'Problem unlocking jadodriver record.','p_rJADODriver.JADV_JADODriver_UID:'+p_rJADODriver.JADV_JADODriver_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113011,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
//function bJAS_Load_jalias(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJAlias: rtJAlias; p_bGetLock: boolean): boolean;
function bJAS_Load_jalias(p_DBC: JADO_COnnection; var p_rJAlias: rtJAlias): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jalias'; sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210080346,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
//{IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210080347, sTHIS_ROUTINE_NAME);{ENDIF}
  //JAS:=p_DBC;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jalias where Alias_JAlias_UID='+JAS.saDBMSUIntScrub(p_rJAlias.Alias_JAlias_UID);
  bOk:=true;
  //if p_bGetLock then
  //begin
  //  bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jalias', p_rJAlias.Alias_JAlias_UID, '0',201506200204);
  //  if not bOK then
  //  begin
  //    JAS_Log(p_Context,cnLog_Error,201210080348,'Problem locking jalias record.','p_rJAlias.Alias_JAlias_UID:'+p_rJAlias.Alias_JAlias_UID,SOURCEFILE);
  //  end;
  //end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161816);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Error,201210080349,'Unable to query jalias successfully','Query:'+saQry,SOURCEFILE,JAS,rs);
      JLog(cnLog_Error,201210080349,'Unable to query jalias successfully Query:'+saQry,SOURCEFILE);
    end
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201210080350,'Record missing from jalias.','Query:'+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJAlias do begin
        //Alias_JAlias_UID            :=rs.Fields.Get_saValue('');
        Alias_JVHost_ID             :=rs.Fields.Get_saValue('Alias_JVHost_ID');
        Alias_Alias                 :=rs.Fields.Get_saValue('Alias_Alias');
        Alias_Path                  :=rs.Fields.Get_saValue('Alias_Path');
        Alias_VHost_b               :=rs.Fields.Get_saValue('Alias_VHost_b');
        Alias_CreatedBy_JUser_ID    :=rs.Fields.Get_saValue('Alias_CreatedBy_JUser_ID');
        Alias_Created_DT            :=rs.Fields.Get_saValue('Alias_Created_DT');
        Alias_ModifiedBy_JUser_ID   :=rs.Fields.Get_saValue('Alias_ModifiedBy_JUser_ID');
        Alias_Modified_DT           :=rs.Fields.Get_saValue('Alias_Modified_DT');
        Alias_DeletedBy_JUser_ID    :=rs.Fields.Get_saValue('Alias_DeletedBy_JUser_ID');
        Alias_Deleted_DT            :=rs.Fields.Get_saValue('Alias_Deleted_DT');
        Alias_Deleted_b             :=rs.Fields.Get_saValue('Alias_Deleted_b');
        JAS_Row_b                   :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210080351,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jalias(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJAlias: rtJAlias; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jalias'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210080352,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210080353, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJAlias.Alias_JAlias_UID)=0 then
  begin
    bAddNew:=true;
    p_rJAlias.Alias_JAlias_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jadodriver');
    bOk:=(u8Val(p_rJAlias.Alias_JAlias_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080354,'Problem getting an UID for new jalias record.','saJAS_GetNextUID table: jalias',SOURCEFILE);
    end;
    if bOk then
    begin
      saQry:='INSERT INTO jalias (Alias_JAlias_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJAlias.Alias_JAlias_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161817);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201210080355,'Problem creating a new jalias record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJAlias.Alias_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJAlias.Alias_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJAlias.Alias_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJAlias.Alias_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJAlias.Alias_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJAlias.Alias_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jalias', p_rJAlias.Alias_JAlias_UID, '0',201506200205);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080356,'Problem locking jalias record.','p_rJAlias.Alias_JAlias_UID:'+p_rJAlias.Alias_JAlias_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJAlias do begin
      saQry:='UPDATE jalias set '+
        // Alias_JAlias_UID='+JAS.saDBMSScrub()+
        ' Alias_JVHost_ID='+JAS.saDBMSUintScrub(Alias_JVHost_ID)+
        ',Alias_Alias='+JAS.saDBMSScrub(Alias_Alias)+
        ',Alias_Path='+JAS.saDBMSScrub(Alias_Path)+
        ',Alias_VHost_b='+JAS.saDBMSBoolScrub(Alias_VHost_b);
      if(bAddNew)then
      begin
        saQry+=
          ',Alias_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(Alias_CreatedBy_JUser_ID)+
          ',Alias_Created_DT='+JAS.saDBMSDateScrub(Alias_Created_DT);
      end;
        saQry+=
          ',Alias_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(Alias_ModifiedBy_JUser_ID)+
          ',Alias_Modified_DT='+JAS.saDBMSDateScrub(Alias_Modified_DT)+
          ',Alias_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(Alias_DeletedBy_JUser_ID)+
          ',Alias_Deleted_DT='+JAS.saDBMSDateScrub(Alias_Deleted_DT)+
          ',Alias_Deleted_b='+JAS.saDBMSBoolScrub(Alias_Deleted_b)+
          ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
          ' WHERE Alias_JAlias_UID='+JAS.saDBMSUINTScrub(Alias_JAlias_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161818);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080357,'Problem updating jalias.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jalias', p_rJAlias.Alias_JAlias_UID, '0',201506200382) then
      begin
        JAS_Log(p_Context,cnLog_Error,201210080358,'Problem unlocking jalias record.','p_rJAlias.Alias_JAlias_UID:'+p_rJAlias.Alias_JAlias_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210080359,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
function bJAS_Load_jblok(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlok: rtJBlok; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jblok'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113012,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113013, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jblok where JBlok_JBlok_UID='+JAS.saDBMSUIntScrub(p_rJBlok.JBlok_JBlok_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jblok', p_rJBlok.JBlok_JBlok_UID, '0',201506200206);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006072151,'Problem locking jblok record.','p_rJBlok.JBlok_JBlok_UID:'+p_rJBlok.JBlok_JBlok_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161819);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151504,'Unable to query jblok successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151505,'Record missing from jblok.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJBlok do begin
        //JBlok_JBlok_UID:=rs.Fields.Get_saValue('');
        JBlok_Name                      :=rs.Fields.Get_saValue('JBlok_Name');
        JBlok_JTable_ID                 :=rs.Fields.Get_saValue('JBlok_JTable_ID');
        JBlok_JScreen_ID                :=rs.Fields.Get_saValue('JBlok_JScreen_ID');
        JBlok_Columns_u                 :=rs.Fields.Get_saValue('JBlok_Columns_u');
        JBlok_JBlokType_ID              :=rs.Fields.Get_saValue('JBlok_JBlokType_ID');
        JBlok_Custom                    :=rs.Fields.Get_saValue('JBlok_Custom');
        JBlok_JCaption_ID               :=rs.Fields.Get_saValue('JBlok_JCaption_ID');
        JBlok_IconSmall                 :=rs.Fields.Get_saValue('JBlok_IconSmall');
        JBlok_IconLarge                 :=rs.Fields.Get_saValue('JBlok_IconLarge');
        JBlok_Position_u                :=rs.Fields.Get_saValue('JBlok_Position_u');
        JBlok_Help_ID                   :=rs.fields.Get_saValue('JBlok_Help_ID');
        JBlok_CreatedBy_JUser_ID        :=rs.Fields.Get_saValue('JBlok_CreatedBy_JUser_ID');
        JBlok_Created_DT                :=rs.Fields.Get_saValue('JBlok_Created_DT');
        JBlok_ModifiedBy_JUser_ID       :=rs.Fields.Get_saValue('JBlok_ModifiedBy_JUser_ID');
        JBlok_Modified_DT               :=rs.Fields.Get_saValue('JBlok_Modified_DT');
        JBlok_DeletedBy_JUser_ID        :=rs.Fields.Get_saValue('JBlok_DeletedBy_JUser_ID');
        JBlok_Deleted_DT                :=rs.Fields.Get_saValue('JBlok_Deleted_DT');
        JBlok_Deleted_b                 :=rs.Fields.Get_saValue('JBlok_Deleted_b');
        JAS_Row_b                       :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113014,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jblok(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlok: rtJBlok; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jblok'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113015,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113016, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJBlok.JBlok_JBlok_UID)=0 then
  begin
    bAddNew:=true;
    p_rJBlok.JBlok_JBlok_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jblok');
    bOk:=(u8Val(p_rJBlok.JBlok_JBlok_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151506,'Problem getting an UID for new jblok record.','saJAS_GetNextUID table: jblok',SOURCEFILE);
    end;
    if bOk then
    begin
      saQry:='INSERT INTO jblok (JBlok_JBlok_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJBlok.JBlok_JBlok_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161820);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151507,'Problem creating a new jblok record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJBlok.JBlok_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJBlok.JBlok_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJBlok.JBlok_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJBlok.JBlok_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJBlok.JBlok_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJBlok.JBlok_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jblok', p_rJBlok.JBlok_JBlok_UID, '0',201506200207);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151508,'Problem locking jblok record.','p_rJBlok.JBlok_JBlok_UID:'+p_rJBlok.JBlok_JBlok_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJBlok do begin
      saQry:='UPDATE jblok set '+
        // JBlok_JBlok_UID='+JAS.saDBMSScrub();
        'JBlok_JTable_ID='+JAS.saDBMSUIntScrub(JBlok_JTable_ID)+
        ',JBlok_JScreen_ID='+JAS.saDBMSUIntScrub(JBlok_JScreen_ID)+
        ',JBlok_Name='+JAS.saDBMSScrub(JBlok_Name)+
        ',JBlok_Columns_u='+JAS.saDBMSScrub(JBlok_Columns_u)+
        ',JBlok_JBlokType_ID='+JAS.saDBMSUIntScrub(JBlok_JBlokType_ID)+
        ',JBlok_Custom='+JAS.saDBMSScrub(JBlok_Custom)+
        ',JBlok_JCaption_ID='+JAS.saDBMSUIntScrub(JBlok_JCaption_ID)+
        ',JBlok_IconSmall='+JAS.saDBMSScrub(JBlok_IconSmall)+
        ',JBlok_IconLarge='+JAS.saDBMSScrub(JBlok_IconLarge)+
        ',JBlok_Position_u='+JAS.saDBMSIntScrub(JBlok_Position_u)+
        ',JBlok_Help_ID='+JAS.saDBMSUIntScrub(JBlok_Help_ID);
        if(bAddNew)then
        begin
          saQry+=',JBlok_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBlok_CreatedBy_JUser_ID)+
          ',JBlok_Created_DT='+JAS.saDBMSDateScrub(JBlok_Created_DT);
        end;
        saQry+=
        ',JBlok_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBlok_ModifiedBy_JUser_ID)+
        ',JBlok_Modified_DT='+JAS.saDBMSDateScrub(JBlok_Modified_DT)+
        ',JBlok_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBlok_DeletedBy_JUser_ID)+
        ',JBlok_Deleted_DT='+JAS.saDBMSDateScrub(JBlok_Deleted_DT)+
        ',JBlok_Deleted_b='+JAS.saDBMSBoolScrub(JBlok_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JBlok_JBlok_UID='+JAS.saDBMSUIntScrub(JBlok_JBlok_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161821);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151509,'Problem updating jblok.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jblok', p_rJBlok.JBlok_JBlok_UID, '0',201506200383) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151510,'Problem unlocking jblok record.','p_rJBlok.JBlok_JBlok_UID:'+p_rJBlok.JBlok_JBlok_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113017,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jblokbutton(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokButton: rtJBlokButton; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jblokbutton'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113018,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113019, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jblokbutton where JBlkB_JBlokButton_UID='+JAS.saDBMSUIntScrub(p_rJBlokButton.JBlkB_JBlokButton_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jblokbutton', p_rJBlokButton.JBlkB_JBlokButton_UID, '0',201506200208);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006072200,'Problem locking jblokbutton record.','p_rJBlokButton.JBlkB_JBlokButton_UID:'+p_rJBlokButton.JBlkB_JBlokButton_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161822);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151511,'Unable to query jblokbutton successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151512,'Record missing from jblokbutton.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJBlokButton do begin
        //JBlkB_JBlokButton_UID:=rs.Fields.Get_saValue('');
        JBlkB_JBlok_ID:=rs.Fields.Get_saValue('JBlkB_JBlok_ID');
        JBlkB_JCaption_ID:=rs.Fields.Get_saValue('JBlkB_JCaption_ID');
        JBlkB_Name:=rs.Fields.Get_saValue('JBlkB_Name');
        JBlkB_GraphicFileName:=rs.Fields.Get_saValue('JBlkB_GraphicFileName');
        JBlkB_Position_u:=rs.Fields.Get_saValue('JBlkB_Position_u');
        JBlkB_JButtonType_ID:=rs.Fields.Get_saValue('JBlkB_JButtonType_ID');
        JBlkB_CustomURL:=rs.Fields.Get_saValue('JBlkB_CustomURL');
        JBlkB_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JBlkB_CreatedBy_JUser_ID');
        JBlkB_Created_DT                 :=rs.Fields.Get_saValue('JBlkB_Created_DT');
        JBlkB_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JBlkB_ModifiedBy_JUser_ID');
        JBlkB_Modified_DT                :=rs.Fields.Get_saValue('JBlkB_Modified_DT');
        JBlkB_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JBlkB_DeletedBy_JUser_ID');
        JBlkB_Deleted_DT                 :=rs.Fields.Get_saValue('JBlkB_Deleted_DT');
        JBlkB_Deleted_b                  :=rs.Fields.Get_saValue('JBlkB_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113020,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jblokbutton(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokButton: rtJBlokButton; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jblokbutton'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113021,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113022, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJBlokButton.JBlkB_JBlokButton_UID)=0 then
  begin
    bAddNew:=true;
    p_rJBlokButton.JBlkB_JBlokButton_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jblokbutton');
    bOk:=(u8Val(p_rJBlokButton.JBlkB_JBlokButton_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151513,'Problem getting an UID for new jblokbutton record.','saJAS_GetNextUID table: jblokbutton',SOURCEFILE);
    end;
    if bOk then
    begin
      saQry:='INSERT INTO jblokbutton (JBlkB_JBlokButton_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJBlokButton.JBlkB_JBlokButton_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161823);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151514,'Problem creating a new jblokbutton record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJBlokButton.JBlkB_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJBlokButton.JBlkB_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJBlokButton.JBlkB_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJBlokButton.JBlkB_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJBlokButton.JBlkB_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJBlokButton.JBlkB_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jblokbutton', p_rJBlokButton.JBlkB_JBlokButton_UID, '0',201506200209);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151515,'Problem locking jblokbutton record.','p_rJBlokButton.JBlkB_JBlokButton_UID:'+p_rJBlokButton.JBlkB_JBlokButton_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJBlokButton do begin
      saQry:='UPDATE jblokbutton set '+
        //JBlkB_JBlokButton_UID='+JAS.saDBMSScrub()+
        'JBlkB_JBlok_ID='+JAS.saDBMSUIntScrub(JBlkB_JBlok_ID)+
        ',JBlkB_JCaption_ID='+JAS.saDBMSUIntScrub(JBlkB_JCaption_ID)+
        ',JBlkB_Name='+JAS.saDBMSScrub(JBlkB_Name)+
        ',JBlkB_GraphicFileName='+JAS.saDBMSScrub(JBlkB_GraphicFileName)+
        ',JBlkB_Position_u='+JAS.saDBMSIntScrub(JBlkB_Position_u)+
        ',JBlkB_JButtonType_ID='+JAS.saDBMSUIntScrub(JBlkB_JButtonType_ID)+
        ',JBlkB_CustomURL='+JAS.saDBMSScrub(JBlkB_CustomURL);
        if(bAddNew)then
        begin
          saQry+=',JBlkB_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBlkB_CreatedBy_JUser_ID)+
          ',JBlkB_Created_DT='+JAS.saDBMSDateScrub(JBlkB_Created_DT);
        end;
        saQry+=
        ',JBlkB_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBlkB_ModifiedBy_JUser_ID)+
        ',JBlkB_Modified_DT='+JAS.saDBMSDateScrub(JBlkB_Modified_DT)+
        ',JBlkB_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBlkB_DeletedBy_JUser_ID)+
        ',JBlkB_Deleted_DT='+JAS.saDBMSDateScrub(JBlkB_Deleted_DT)+
        ',JBlkB_Deleted_b='+JAS.saDBMSBoolScrub(JBlkB_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JBlkB_JBlokButton_UID='+JAS.saDBMSUIntScrub(JBlkB_JBlokButton_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161824);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151516,'Problem updating jblokbutton.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jblokbutton', p_rJBlokButton.JBlkB_JBlokButton_UID, '0',201506200384) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151517,'Problem unlocking jblokbutton record.','p_rJBlokButton.JBlkB_JBlokButton_UID:'+p_rJBlokButton.JBlkB_JBlokButton_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113023,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//----NEW BEGIN
//=============================================================================
function bJAS_Load_jbuttontype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJButtonType: rtJButtonType; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jbuttontype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113024,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113025, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jbuttontype where JBtnT_JButtonType_UID='+JAS.saDBMSUIntScrub(p_rJButtonType.JBtnT_JButtonType_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jbuttontype', p_rJButtonType.JBtnT_JButtonType_UID, '0',201506200210);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201009181230,'Problem locking jbuttontype record.','p_rJButtonType.JBtnT_JButtonType_UID:'+
        p_rJButtonType.JBtnT_JButtonType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161825);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201009181231,'Unable to query jbuttontype successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201009181232,'Record missing from jbuttontype.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJButtonType do begin
        //JBtnT_JButtonType_UID:=rs.Fields.Get_saValue('');
        JBtnT_Name:=rs.Fields.Get_saValue('JBtnT_Name');
        JBtnT_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JBtnT_CreatedBy_JUser_ID');
        JBtnT_Created_DT                 :=rs.Fields.Get_saValue('JBtnT_Created_DT');
        JBtnT_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JBtnT_ModifiedBy_JUser_ID');
        JBtnT_Modified_DT                :=rs.Fields.Get_saValue('JBtnT_Modified_DT');
        JBtnT_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JBtnT_DeletedBy_JUser_ID');
        JBtnT_Deleted_DT                 :=rs.Fields.Get_saValue('JBtnT_Deleted_DT');
        JBtnT_Deleted_b                  :=rs.Fields.Get_saValue('JBtnT_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113026,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jbuttontype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJButtonType: rtJButtonType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jbuttontype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113027,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113028, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJButtonType.JBtnT_JButtonType_UID)=0 then
  begin
    bAddNew:=true;
    p_rJButtonType.JBtnT_JButtonType_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jbuttontype');
    bOk:=(u8Val(p_rJButtonType.JBtnT_JButtonType_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201009181233,'Problem getting an UID for new jbuttontype record.','saJAS_GetNextUID table: jbuttontype',SOURCEFILE);
    end;
    if bOk then
    begin
      saQry:='INSERT INTO jbuttontype (JBtnT_JButtonType_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJButtonType.JBtnT_JButtonType_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161826);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201009181234,'Problem creating a new jbuttontype record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJButtonType.JBtnT_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJButtonType.JBtnT_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJButtonType.JBtnT_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJButtonType.JBtnT_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJButtonType.JBtnT_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJButtonType.JBtnT_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jbuttontype', p_rJButtonType.JBtnT_JButtonType_UID, '0',201506200211);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201009181235,'Problem locking jbuttontype record.','p_rJButtonType.JBtnT_JButtonType_UID:'+p_rJButtonType.JBtnT_JButtonType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJButtonType do begin
      saQry:='UPDATE jbuttontype set '+
        //JBtnT_JButtonType_UID='+JAS.saDBMSScrub()+
        ',JBtnT_Name='+JAS.saDBMSScrub(JBtnT_Name);
        if(bAddNew)then
        begin
          saQry+=',JBtnT_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBtnT_CreatedBy_JUser_ID)+
          ',JBtnT_Created_DT='+JAS.saDBMSDateScrub(JBtnT_Created_DT);
        end;
        saQry+=
        ',JBtnT_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBtnT_ModifiedBy_JUser_ID)+
        ',JBtnT_Modified_DT='+JAS.saDBMSDateScrub(JBtnT_Modified_DT)+
        ',JBtnT_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBtnT_DeletedBy_JUser_ID)+
        ',JBtnT_Deleted_DT='+JAS.saDBMSDateScrub(JBtnT_Deleted_DT)+
        ',JBtnT_Deleted_b='+JAS.saDBMSBoolScrub(JBtnT_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JBtnB_JButton_UID='+JAS.saDBMSUIntScrub(JBtnT_JButtonType_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161827);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201009181236,'Problem updating jbuttontype.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jbuttontype', p_rJButtonType.JBtnT_JButtonType_UID, '0',201506200385) then
      begin
        JAS_Log(p_Context,cnLog_Error,201009181237,'Problem unlocking jbuttontype record.','p_rJButtonType.JBtnT_JButtonType_UID:'+p_rJButtonType.JBtnT_JButtonType_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113029,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
//----NEW END




//=============================================================================
function bJAS_Load_jblokfield(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokField: rtJBlokField; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jblokfield'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113030,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113031, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jblokfield where JBlkF_JBlokField_UID='+JAS.saDBMSUIntScrub(p_rJBlokfield.JBlkF_JBlokField_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jblokfield', p_rJBlokfield.JBlkF_JBlokField_UID, '0',201506200212);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006072213,'Problem locking jblokfield record.','p_rJBlokfield.JBlkF_JBlokField_UID:'+p_rJBlokfield.JBlkF_JBlokField_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161828);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151518,'Unable to query jblokfield successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151519,'Record missing from jblokfield.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJBlokField do begin
        //JBlkF_JBlokField_UID              :=rs.Fields.Get_saValue('JBlkF_JBlokField_UID');
        JBlkF_JBlok_ID                    :=rs.Fields.Get_saValue('JBlkF_JBlok_ID');
        JBlkF_JColumn_ID                  :=rs.Fields.Get_saValue('JBlkF_JColumn_ID');
        JBlkF_Position_u                  :=rs.Fields.Get_saValue('JBlkF_Position_u');
        JBlkF_ReadOnly_b                  :=rs.Fields.Get_saValue('JBlkF_ReadOnly_b');
        JBlkF_JWidget_ID                  :=rs.Fields.Get_saValue('JBlkF_JWidget_ID');
        JBlkF_Widget_MaxLength_u          :=rs.Fields.Get_saValue('JBlkF_Widget_MaxLength_u');
        JBlkF_Widget_Width                :=rs.Fields.Get_saValue('JBlkF_Widget_Width');
        JBlkF_Widget_Height               :=rs.Fields.Get_saValue('JBlkF_Widget_Height');
        JBlkF_Widget_Password_b           :=rs.Fields.Get_saValue('JBlkF_Widget_Password_b');
        JBlkF_Widget_Date_b               :=rs.Fields.Get_saValue('JBlkF_Widget_Date_b');
        JBlkF_Widget_Time_b               :=rs.Fields.Get_saValue('JBlkF_Widget_Time_b');
        JBlkF_Widget_Mask                 :=rs.Fields.Get_saValue('JBlkF_Widget_Mask');
        JBlkF_Widget_OnBlur               :=rs.Fields.Get_saValue('JBlkF_Widget_OnBlur');
        JBlkF_Widget_OnChange             :=rs.Fields.Get_saValue('JBlkF_Widget_OnChange');
        JBlkF_Widget_OnClick              :=rs.Fields.Get_saValue('JBlkF_Widget_OnClick');
        JBlkF_Widget_OnDblClick           :=rs.Fields.Get_saValue('JBlkF_Widget_OnDblClick');
        JBlkF_Widget_OnFocus              :=rs.Fields.Get_saValue('JBlkF_Widget_OnFocus');
        JBlkF_Widget_OnKeyDown            :=rs.Fields.Get_saValue('JBlkF_Widget_OnKeyDown');
        JBlkF_Widget_OnKeypress           :=rs.Fields.Get_saValue('JBlkF_Widget_OnKeypress');
        JBlkF_Widget_OnKeyUp              :=rs.Fields.Get_saValue('JBlkF_Widget_OnKeyUp');
        JBlkF_Widget_OnSelect             :=rs.Fields.Get_saValue('JBlkF_Widget_OnSelect');
        JBlkF_ColSpan_u                   :=rs.Fields.Get_saValue('JBlkF_ColSpan_u');
        JBlkF_Width_is_Percent_b          :=rs.Fields.Get_saValue('JBlkF_Width_is_Percent_b ');
        JBlkF_Height_is_Percent_b         :=rs.Fields.Get_saValue('JBlkF_Height_is_Percent_b');
        JBlkF_Required_b                  :=rs.Fields.Get_saValue('JBlkF_Required_b');
        JBlkF_MultiSelect_b               :=rs.Fields.Get_saValue('JBlkF_MultiSelect_b');
        JBlkF_ClickAction_ID              :=rs.Fields.Get_saValue('JBlkF_ClickAction_ID');
        JBlkF_ClickActionData             :=rs.Fields.Get_saValue('JBlkF_ClickActionData');
        JBlkF_JCaption_ID                 :=rs.Fields.Get_saValue('JBlkF_JCaption_ID');
        JBlkF_Visible_b                   :=rs.Fields.Get_saValue('JBlkF_Visible_b');
        JBlkF_CreatedBy_JUser_ID          :=rs.Fields.Get_saValue('JBlkF_CreatedBy_JUser_ID');
        JBlkF_Created_DT                  :=rs.Fields.Get_saValue('JBlkF_Created_DT');
        JBlkF_ModifiedBy_JUser_ID         :=rs.Fields.Get_saValue('JBlkF_ModifiedBy_JUser_ID');
        JBlkF_Modified_DT                 :=rs.Fields.Get_saValue('JBlkF_Modified_DT');
        JBlkF_DeletedBy_JUser_ID          :=rs.Fields.Get_saValue('JBlkF_DeletedBy_JUser_ID');
        JBlkF_Deleted_DT                  :=rs.Fields.Get_saValue('JBlkF_Deleted_DT');
        JBlkF_Deleted_b                   :=rs.Fields.Get_saValue('JBlkF_Deleted_b');
        JAS_Row_b                         :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113032,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jblokfield(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokField: rtJBlokField; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jblokfield'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113033,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113034, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJBlokfield.JBlkF_JBlokField_UID)=0 then
  begin
    bAddNew:=true;
    p_rJBlokfield.JBlkF_JBlokField_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jblokfield');
    bOk:=(u8Val(p_rJBlokfield.JBlkF_JBlokField_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151520,'Problem getting an UID for new jblokfield record.','saJAS_GetNextUID table: jblokfield',SOURCEFILE);
    end;
    if bOk then
    begin
      saQry:='INSERT INTO jblokfield (JBlkF_JBlokField_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJBlokfield.JBlkF_JBlokField_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161829);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151521,'Problem creating a new jblokfield record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJBlokfield.JBlkF_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJBlokfield.JBlkF_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJBlokfield.JBlkF_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJBlokfield.JBlkF_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJBlokfield.JBlkF_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJBlokfield.JBlkF_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jblokfield', p_rJBlokfield.JBlkF_JBlokField_UID, '0',201506200213);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151522,'Problem locking jblokfield record.','p_rJBlokfield.JBlkF_JBlokField_UID:'+p_rJBlokfield.JBlkF_JBlokField_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJBlokField do begin
      saQry:='UPDATE jblokfield set '+
        //,JBlkF_JBlokField_UID              +JAS.saDBMSScrub(JBlkF_JBlokField_UID     );
        ' JBlkF_JBlok_ID='           +JAS.saDBMSUintScrub(JBlkF_JBlok_ID           )+
        ',JBlkF_JColumn_ID='         +JAS.saDBMSUIntScrub(JBlkF_JColumn_ID         )+
        ',JBlkF_Position_u='         +JAS.saDBMSUintScrub(JBlkF_Position_u         )+
        ',JBlkF_ReadOnly_b='         +JAS.saDBMSBoolScrub(JBlkF_ReadOnly_b         )+
        ',JBlkF_JWidget_ID='         +JAS.saDBMSUIntScrub(JBlkF_JWidget_ID         )+
        ',JBlkF_Widget_MaxLength_u=' +JAS.saDBMSUIntScrub(JBlkF_Widget_MaxLength_u )+
        ',JBlkF_Widget_Width='       +JAS.saDBMSUIntScrub(JBlkF_Widget_Width     )+
        ',JBlkF_Widget_Height='      +JAS.saDBMSUIntScrub(JBlkF_Widget_Height    )+
        ',JBlkF_Widget_Password_b='  +JAS.saDBMSBoolScrub(JBlkF_Widget_Password_b  )+
        ',JBlkF_Widget_Date_b='      +JAS.saDBMSBoolScrub(JBlkF_Widget_Date_b      )+
        ',JBlkF_Widget_Time_b='      +JAS.saDBMSBoolScrub(JBlkF_Widget_Time_b      )+
        ',JBlkF_Widget_Mask='        +JAS.saDBMSScrub(JBlkF_Widget_Mask            )+
        ',JBlkF_Widget_OnBlur='      +JAS.saDBMSScrub(JBlkF_Widget_OnBlur          )+
        ',JBlkF_Widget_OnChange='    +JAS.saDBMSScrub(JBlkF_Widget_OnChange        )+
        ',JBlkF_Widget_OnClick='     +JAS.saDBMSScrub(JBlkF_Widget_OnClick         )+
        ',JBlkF_Widget_OnDblClick='  +JAS.saDBMSScrub(JBlkF_Widget_OnDblClick      )+
        ',JBlkF_Widget_OnFocus='     +JAS.saDBMSScrub(JBlkF_Widget_OnFocus         )+
        ',JBlkF_Widget_OnKeyDown='   +JAS.saDBMSScrub(JBlkF_Widget_OnKeyDown       )+
        ',JBlkF_Widget_OnKeypress='  +JAS.saDBMSScrub(JBlkF_Widget_OnKeypress      )+
        ',JBlkF_Widget_OnKeyUp='     +JAS.saDBMSScrub(JBlkF_Widget_OnKeyUp         )+
        ',JBlkF_Widget_OnSelect='    +JAS.saDBMSScrub(JBlkF_Widget_OnSelect        )+
        ',JBlkF_ColSpan_u='          +JAS.saDBMSUintScrub(JBlkF_ColSpan_u          )+
        ',JBlkF_Width_is_Percent_b=' +JAS.saDBMSBoolScrub(JBlkF_Width_is_Percent_b )+
        ',JBlkF_Height_is_Percent_b='+JAS.saDBMSBoolScrub(JBlkF_Height_is_Percent_b)+
        ',JBlkF_Required_b='         +JAS.saDBMSBoolScrub(JBlkF_Required_b         )+
        ',JBlkF_MultiSelect_b='      +JAS.saDBMSBoolScrub(JBlkF_MultiSelect_b      )+
        ',JBlkF_ClickAction_ID='     +JAS.saDBMSUIntScrub(JBlkF_ClickAction_ID     )+
        ',JBlkF_ClickActionData='    +JAS.saDBMSScrub(JBlkF_ClickActionData        )+
        ',JBlkF_JCaption_ID='        +JAS.saDBMSUintScrub(JBlkF_JCaption_ID        )+
        ',JBlkF_Visible_b='          +JAS.saDBMSBoolScrub(JBlkF_Visible_b          );
        if bAddNew then
        begin
          saQry+=
          ',JBlkF_CreatedBy_JUser_ID=' +JAS.saDBMSUintScrub(JBlkF_CreatedBy_JUser_ID )+
          ',JBlkF_Created_DT='         +JAS.saDBMSDateScrub(JBlkF_Created_DT         );
        end;
        saQry+=
        ',JBlkF_ModifiedBy_JUser_ID='+JAS.saDBMSUintScrub(JBlkF_ModifiedBy_JUser_ID)+
        ',JBlkF_Modified_DT='        +JAS.saDBMSDateScrub(JBlkF_Modified_DT        )+
        ',JBlkF_DeletedBy_JUser_ID=' +JAS.saDBMSUintScrub(JBlkF_DeletedBy_JUser_ID )+
        ',JBlkF_Deleted_DT='         +JAS.saDBMSDateScrub(JBlkF_Deleted_DT         )+
        ',JBlkF_Deleted_b='          +JAS.saDBMSBoolScrub(JBlkF_Deleted_b          )+
        ',JAS_Row_b='                +JAS.saDBMSBoolScrub(JAS_Row_b                )+
        ' WHERE JBlkF_JBlokField_UID='+JAS.saDBMSUIntScrub(JBlkF_JBlokField_UID);
    end;//with
    //AS_Log(p_Context, cnLog_DEBUG,201002230323, 'bjas_save_jblokfield DEBUG','Query:'+saQry ,SOURCEFILE);
    bOk:=rs.Open(saQry, JAS,201503161830);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151523,'Problem updating jblokfield.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jblokfield', p_rJBlokfield.JBlkF_JBlokField_UID, '0',201506200386) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151524,'Problem unlocking jblokfield record.','p_rJBlokfield.JBlkF_JBlokField_UID:'+p_rJBlokfield.JBlkF_JBlokField_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113035,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
function bJAS_Load_jbloktype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokType: rtJBlokType; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jbloktype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113036,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113037, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jbloktype where JBkTy_JBlokType_UID='+JAS.saDBMSUIntScrub(p_rJBlokType.JBkTy_JBlokType_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jbloktype', p_rJBlokType.JBkTy_JBlokType_UID, '0',201506200214);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006090637,'Problem locking jbloktype record.','p_rJBlokType.JBkTy_JBlokType_UID:'+p_rJBlokType.JBkTy_JBlokType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161831);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230000,'Unable to query jbloktype successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002230001,'Record missing from jbloktype.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJBlokType do begin
        //JBkTy_JBlokType_UID:=rs.Fields.Get_saValue('');
        JBkTy_Name:=rs.Fields.Get_saValue('JBkTy_Name');
        JBkTy_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JBkTy_CreatedBy_JUser_ID');
        JBkTy_Created_DT                 :=rs.Fields.Get_saValue('JBkTy_Created_DT');
        JBkTy_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JBkTy_ModifiedBy_JUser_ID');
        JBkTy_Modified_DT                :=rs.Fields.Get_saValue('JBkTy_Modified_DT');
        JBkTy_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JBkTy_DeletedBy_JUser_ID');
        JBkTy_Deleted_DT                 :=rs.Fields.Get_saValue('JBkTy_Deleted_DT');
        JBkTy_Deleted_b                  :=rs.Fields.Get_saValue('JBkTy_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113038,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jbloktype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJBlokType: rtJBlokType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jbloktype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113039,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113040, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJBlokType.JBkTy_JBlokType_UID)=0 then
  begin
    bAddNew:=true;
    p_rJBlokType.JBkTy_JBlokType_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jbloktype');
    bOk:=(u8Val(p_rJBlokType.JBkTy_JBlokType_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230002,'Problem getting an UID for new jbloktype record.','saJAS_GetNextUID table: jbloktype',SOURCEFILE);
    end;
    if bOk then
    begin
      saQry:='INSERT INTO jbloktype (JBkTy_JBlokType_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJBlokType.JBkTy_JBlokType_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161832);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002230003,'Problem creating a new jbloktype record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJBlokType.JBkTy_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJBlokType.JBkTy_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJBlokType.JBkTy_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJBlokType.JBkTy_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJBlokType.JBkTy_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJBlokType.JBkTy_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jbloktype', p_rJBlokType.JBkTy_JBlokType_UID, '0',201506200215);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230004,'Problem locking jbloktype record.','p_rJBlokType.JBkTy_JBlokType_UID:'+p_rJBlokType.JBkTy_JBlokType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJBlokType do begin
      saQry:='UPDATE jbloktype set '+
        //' JBkTy_JBlokType_UID='+JAS.saDBMSScrub();
        ',JBkTy_Name='+JAS.saDBMSScrub(JBkTy_Name);
        if(bAddNew)then
        begin
          saQry+=',JBkTy_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBkTy_CreatedBy_JUser_ID)+
          ',JBkTy_Created_DT='+JAS.saDBMSDateScrub(JBkTy_Created_DT);
        end;
        saQry+=
        ',JBkTy_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBkTy_ModifiedBy_JUser_ID)+
        ',JBkTy_Modified_DT='+JAS.saDBMSDateScrub(JBkTy_Modified_DT)+
        ',JBkTy_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JBkTy_DeletedBy_JUser_ID)+
        ',JBkTy_Deleted_DT='+JAS.saDBMSDateScrub(JBkTy_Deleted_DT)+
        ',JBkTy_Deleted_b='+JAS.saDBMSBoolScrub(JBkTy_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JBkTy_JBlokType_UID='+JAS.saDBMSUintScrub(JBkTy_JBlokType_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161833);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230005,'Problem updating jbloktype.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jbloktype', p_rJBlokType.JBkTy_JBlokType_UID, '0',201506200387) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151510,'Problem unlocking jbloktype record.','JBkTy_JBlokType_UID:'+p_rJBlokType.JBkTy_JBlokType_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113041,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
function bJAS_Load_jcaption(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaption: rtJCaption; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jcaption'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113048,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113049, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jcaption where JCapt_JCaption_UID='+JAS.saDBMSUintScrub(p_rJCaption.JCapt_JCaption_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcaption', p_rJCaption.JCapt_JCaption_UID, '0',201506200216);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100642,'Problem locking jcaption record.','p_rJCaption.JCapt_JCaption_UID:'+p_rJCaption.JCapt_JCaption_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161834);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151532,'Unable to query jcaption successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151533,'Record missing from jcaption.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJCaption do begin
        //JCapt_JCaption_UID              :=rs.Fields.Get_saValue('JCapt_JCaption_UID');
        JCapt_Value                      :=rs.Fields.Get_saValue('JCapt_Value');
        JCapt_en                         :=rs.Fields.Get_saValue('JCapt_en');
        JCapt_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JCapt_CreatedBy_JUser_ID');
        JCapt_Created_DT                 :=rs.Fields.Get_saValue('JCapt_Created_DT');
        JCapt_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JCapt_ModifiedBy_JUser_ID');
        JCapt_Modified_DT                :=rs.Fields.Get_saValue('JCapt_Modified_DT');
        JCapt_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JCapt_DeletedBy_JUser_ID');
        JCapt_Deleted_DT                 :=rs.Fields.Get_saValue('JCapt_Deleted_DT');
        JCapt_Deleted_b                  :=rs.Fields.Get_saValue('JCapt_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113050,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jcaption(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaption: rtJCaption; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jcaption'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113051,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113052, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJCaption.JCapt_JCaption_UID)=0 then
  begin
    bAddNew:=true;
    p_rJCaption.JCapt_JCaption_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jcaption');
    bOk:=(u8Val(p_rJCaption.JCapt_JCaption_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151534,'Problem getting an UID for new jcaption record.','saJAS_GetNextUID table: jcaption',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jcaption (JCapt_JCaption_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJCaption.JCapt_JCaption_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161835);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151535,'Problem creating a new jcaption record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJCaption.JCapt_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCaption.JCapt_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJCaption.JCapt_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCaption.JCapt_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJCaption.JCapt_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJCaption.JCapt_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcaption', p_rJCaption.JCapt_JCaption_UID, '0',201506200217);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151536,'Problem locking jcaption record.','p_rJCaption.JCapt_JCaption_UID:'+p_rJCaption.JCapt_JCaption_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJCaption do begin
      saQry:='UPDATE jcaption set '+
        //' JCapt_JCaption_UID='+JAS.saDBMSScrub()+
        ' JCapt_Value='+JAS.saDBMSScrub(JCapt_Value)+
        ',JCapt_en='+JAS.saDBMSScrub(JCapt_EN);
        if(bAddNew)then
        begin
          saQry+=',JCapt_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCapt_CreatedBy_JUser_ID)+
          ',JCapt_Created_DT='+JAS.saDBMSDateScrub(JCapt_Created_DT);
        end;
        saQry+=
        ',JCapt_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCapt_ModifiedBy_JUser_ID)+
        ',JCapt_Modified_DT='+JAS.saDBMSDateScrub(JCapt_Modified_DT)+
        ',JCapt_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCapt_DeletedBy_JUser_ID)+
        ',JCapt_Deleted_DT='+JAS.saDBMSDateScrub(JCapt_Deleted_DT)+
        ',JCapt_Deleted_b='+JAS.saDBMSBoolScrub(JCapt_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JCapt_JCaption_UID='+JAS.saDBMSUIntScrub(JCapt_JCaption_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161836);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151537,'Problem updating jcaption.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jcaption', p_rJCaption.JCapt_JCaption_UID, '0',201506200388) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151538,'Problem unlocking jcaption record.','p_rJCaption.JCapt_JCaption_UID:'+p_rJCaption.JCapt_JCaption_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113053,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================











//=============================================================================
function bJAS_Load_jcase(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCase: rtJCase; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jcase'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113060,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113061, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jcase where JCase_JCase_UID='+JAS.saDBMSUIntScrub(p_rJCase.JCase_JCase_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcase', p_rJCase.JCase_JCase_UID, '0',201506200218);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201007060018,'Problem locking jcase record.','p_rJCase.JCase_JCase_UID:'+p_rJCase.JCase_JCase_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161837);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151544,'Unable to query jcase successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151545,'Record missing from jcase.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJCase do begin
        //JCase_JCase_UID                :=rs.Fields.Get_saValue('');
        JCase_Name                     :=rs.Fields.Get_saValue('JCase_Name');
        JCase_JCompany_ID              :=rs.Fields.Get_saValue('JCase_JCompany_ID');
        JCase_JPerson_ID               :=rs.Fields.Get_saValue('JCase_JPerson_ID');
        JCase_Responsible_Grp_ID       :=rs.Fields.Get_saValue('JCase_Responsible_Grp_ID');
        JCase_Responsible_Person_ID    :=rs.Fields.Get_saValue('JCase_Responsible_Person_ID');
        JCase_JCaseSource_ID           :=rs.Fields.Get_saValue('JCase_JCaseSource_ID');
        JCase_JCaseCategory_ID         :=rs.Fields.Get_saValue('JCase_JCaseCategory_ID');
        JCase_JCasePriority_ID         :=rs.Fields.Get_saValue('JCase_JCasePriority_ID');
        JCase_JCaseStatus_ID           :=rs.Fields.Get_saValue('JCase_JCaseStatus_ID');
        JCase_JCaseType_ID             :=rs.Fields.Get_saValue('JCase_JCaseType_ID');
        JCase_JSubject_ID              :=rs.Fields.Get_saValue('JCase_JSubject_ID');
        JCase_Desc                     :=rs.Fields.Get_saValue('JCase_Desc');
        JCase_Resolution               :=rs.Fields.Get_saValue('JCase_Resolution');
        JCase_Due_DT                   :=rs.Fields.Get_saValue('JCase_Due_DT');
        JCase_ResolvedBy_JUser_ID      :=rs.Fields.Get_saValue('JCase_ResolvedBy_JUser_ID');
        JCase_Resolved_DT              :=rs.Fields.Get_saValue('JCase_Resolved_DT');
        JCase_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JCase_CreatedBy_JUser_ID');
        JCase_Created_DT                 :=rs.Fields.Get_saValue('JCase_Created_DT');
        JCase_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JCase_ModifiedBy_JUser_ID');
        JCase_Modified_DT                :=rs.Fields.Get_saValue('JCase_Modified_DT');
        JCase_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JCase_DeletedBy_JUser_ID');
        JCase_Deleted_DT                 :=rs.Fields.Get_saValue('JCase_Deleted_DT');
        JCase_Deleted_b                  :=rs.Fields.Get_saValue('JCase_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113062,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jcase(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCase: rtJCase; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jcase'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113063,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113064, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJCase.JCase_JCase_UID)=0 then
  begin
    bAddNew:=true;
    p_rJCase.JCase_JCase_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jcase');
    bOk:=(u8Val(p_rJCase.JCase_JCase_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151546,'Problem getting an UID for new jcase record.','saJAS_GetNextUID table: jcase',SOURCEFILE);
    end;
    if bOk then
    begin
      saQry:='INSERT INTO jcase (JCase_JCase_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJCase.JCase_JCase_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161838);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151547,'Problem creating a new jcase record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJCase.JCase_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCase.JCase_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJCase.JCase_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCase.JCase_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJCase.JCase_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJCase.JCase_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcase', p_rJCase.JCase_JCase_UID, '0',201506200219);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151548,'Problem locking jcase record.','p_rJCase.JCase_JCase_UID:'+p_rJCase.JCase_JCase_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJCase do begin
      saQry:='UPDATE jcase set '+
       //' JCase_JCase_UID='+JAS.saDBMSScrub(JCase_JCase_UID)+
       ' JCase_Name='+JAS.saDBMSUIntScrub(JCase_Name)+
       ',JCase_JCompany_ID='+JAS.saDBMSUIntScrub(JCase_JCompany_ID)+
       ',JCase_JPerson_ID='+JAS.saDBMSUIntScrub(JCase_JPerson_ID)+
       ',JCase_Responsible_Grp_ID='+JAS.saDBMSUIntScrub(JCase_Responsible_Grp_ID)+
       ',JCase_Responsible_Person_ID='+JAS.saDBMSUIntScrub(JCase_Responsible_Person_ID)+
       ',JCase_Created_DT='+JAS.saDBMSDateScrub(JCase_Created_DT)+
       ',JCase_JCaseSource_ID='+JAS.saDBMSUIntScrub(JCase_JCaseSource_ID)+
       ',JCase_JCaseCategory_ID='+JAS.saDBMSUIntScrub(JCase_JCaseCategory_ID)+
       ',JCase_JCasePriority_ID='+JAS.saDBMSUIntScrub(JCase_JCasePriority_ID)+
       ',JCase_JCaseStatus_ID='+JAS.saDBMSUIntScrub(JCase_JCaseStatus_ID)+
       ',JCase_JCaseType_ID='+JAS.saDBMSUIntScrub(JCase_JCaseType_ID)+
       ',JCase_JSubject_ID='+JAS.saDBMSUIntScrub(JCase_JSubject_ID)+
       ',JCase_Desc='+JAS.saDBMSScrub(JCase_Desc)+
       ',JCase_Resolution='+JAS.saDBMSScrub(JCase_Resolution)+
       ',JCase_Resolved_DT='+JAS.saDBMSDateScrub(JCase_Resolved_DT)+
       ',JCase_Due_DT='+JAS.saDBMSDateScrub(JCase_Due_DT)+
       ',JCase_ResolvedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCase_ResolvedBy_JUser_ID)+
       ',JCase_Modified_DT='+JAS.saDBMSDateScrub(JCase_Modified_DT);
        if(bAddNew)then
        begin
          saQry+=',JCase_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCase_CreatedBy_JUser_ID)+
          ',JCase_Created_DT='+JAS.saDBMSDateScrub(JCase_Created_DT);
        end;
        saQry+=
        ',JCase_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCase_ModifiedBy_JUser_ID)+
        ',JCase_Modified_DT='+JAS.saDBMSDateScrub(JCase_Modified_DT)+
        ',JCase_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCase_DeletedBy_JUser_ID)+
        ',JCase_Deleted_DT='+JAS.saDBMSDateScrub(JCase_Deleted_DT)+
        ',JCase_Deleted_b='+JAS.saDBMSBoolScrub(JCase_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
       ' WHERE JCase_JCase_UID='+JAS.saDBMSUIntScrub(JCase_JCase_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161839);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151549,'Problem updating jcase.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jcase', p_rJCase.JCase_JCase_UID, '0',201506200389) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151550,'Problem unlocking jcase record.','p_rJCase.JCase_JCase_UID:'+p_rJCase.JCase_JCase_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113065,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jcasecategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseCategory: rtJCaseCategory; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jcasecategory'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113066,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113067, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jcasecategory where JCACT_JCaseCategory_UID='+JAS.saDBMSUintScrub(p_rJCaseCategory.JCACT_JCaseCategory_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcasecategory', p_rJCaseCategory.JCACT_JCaseCategory_UID, '0',201506200220);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100646,'Problem locking jcasecategory record.','p_rJCaseCategory.JCACT_JCaseCategory_UID:'+p_rJCaseCategory.JCACT_JCaseCategory_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161840);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151551,'Unable to query jcasecategory successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151552,'Record missing from jcasecategory.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJCaseCategory do begin
        //JCACT_JCaseCategory_UID:=rs.Fields.Get_saValue('');
        JCACT_Name:=rs.Fields.Get_saValue('JCACT_Name');
        JCACT_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JCACT_CreatedBy_JUser_ID');
        JCACT_Created_DT                 :=rs.Fields.Get_saValue('JCACT_Created_DT');
        JCACT_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JCACT_ModifiedBy_JUser_ID');
        JCACT_Modified_DT                :=rs.Fields.Get_saValue('JCACT_Modified_DT');
        JCACT_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JCACT_DeletedBy_JUser_ID');
        JCACT_Deleted_DT                 :=rs.Fields.Get_saValue('JCACT_Deleted_DT');
        JCACT_Deleted_b                  :=rs.Fields.Get_saValue('JCACT_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113068,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jcasecategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseCategory: rtJCaseCategory; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jcasecategory'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113069,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113070, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJCaseCategory.JCACT_JCaseCategory_UID)=0 then
  begin
    bAddNew:=true;
    p_rJCaseCategory.JCACT_JCaseCategory_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jcasecategory');
    bOk:=(u8Val(p_rJCaseCategory.JCACT_JCaseCategory_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151553,'Problem getting an UID for new jcasecategory record.','saJAS_GetNextUID table: jcasecategory',SOURCEFILE);
    end;
    if bOk then
    begin
      saQry:='INSERT INTO jcasecategory (JCACT_JCaseCategory_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJCaseCategory.JCACT_JCaseCategory_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161841);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151554,'Problem creating a new jcasecategory record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJCaseCategory.JCACT_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCaseCategory.JCACT_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJCaseCategory.JCACT_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCaseCategory.JCACT_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJCaseCategory.JCACT_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJCaseCategory.JCACT_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcasecategory', p_rJCaseCategory.JCACT_JCaseCategory_UID, '0',201506200221);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151555,'Problem locking jcasecategory record.','p_rJCaseCategory.JCACT_JCaseCategory_UID:'+p_rJCaseCategory.JCACT_JCaseCategory_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJCaseCategory do begin
      saQry:='UPDATE jcasecategory set '+
        //' JCACT_JCaseCategory_UID='+JAS.saDBMSScrub()+
        'JCACT_Name='+JAS.saDBMSScrub(JCACT_Name);
        if(bAddNew)then
        begin
          saQry+=',JCACT_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCACT_CreatedBy_JUser_ID)+
          ',JCACT_Created_DT='+JAS.saDBMSDateScrub(JCACT_Created_DT);
        end;
        saQry+=
        ',JCACT_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCACT_ModifiedBy_JUser_ID)+
        ',JCACT_Modified_DT='+JAS.saDBMSDateScrub(JCACT_Modified_DT)+
        ',JCACT_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCACT_DeletedBy_JUser_ID)+
        ',JCACT_Deleted_DT='+JAS.saDBMSDateScrub(JCACT_Deleted_DT)+
        ',JCACT_Deleted_b='+JAS.saDBMSBoolScrub(JCACT_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JCACT_JCaseCategory_UID='+JAS.saDBMSUIntScrub(JCACT_JCaseCategory_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161842);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151556,'Problem updating jcasecategory.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jcasecategory', p_rJCaseCategory.JCACT_JCaseCategory_UID, '0',201506200390) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151557,'Problem unlocking jcasecategory record.','p_rJCaseCategory.JCACT_JCaseCategory_UID:'+p_rJCaseCategory.JCACT_JCaseCategory_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113071,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
function bJAS_Load_jcasepriority(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCasePriority: rtJCasePriority; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jcasepriority'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113072,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113073, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jcasepriority where JCAPR_JCasePriority_UID='+JAS.saDBMSUIntScrub(p_rJCasePriority.JCAPR_JCasePriority_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcasepriority', p_rJCasePriority.JCAPR_JCasePriority_UID, '0',201506200222);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100648,'Problem locking jcase priority record.','p_rJCasePriority.JCAPR_JCasePriority_UID:'+p_rJCasePriority.JCAPR_JCasePriority_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161843);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151558,'Unable to query jcasepriority successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151559,'Record missing from jcasepriority.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJCasePriority do begin
        //JCAPR_JCasePriority_UID:=rs.Fields.Get_saValue('');
        JCAPR_Name:=rs.Fields.Get_saValue('JCAPR_Name');
        JCAPR_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JCAPR_CreatedBy_JUser_ID');
        JCAPR_Created_DT                 :=rs.Fields.Get_saValue('JCAPR_Created_DT');
        JCAPR_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JCAPR_ModifiedBy_JUser_ID');
        JCAPR_Modified_DT                :=rs.Fields.Get_saValue('JCAPR_Modified_DT');
        JCAPR_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JCAPR_DeletedBy_JUser_ID');
        JCAPR_Deleted_DT                 :=rs.Fields.Get_saValue('JCAPR_Deleted_DT');
        JCAPR_Deleted_b                  :=rs.Fields.Get_saValue('JCAPR_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113074,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jcasepriority(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCasePriority: rtJCasePriority; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jcasepriority'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113075,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113076, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJCasePriority.JCAPR_JCasePriority_UID)=0 then
  begin
    bAddNew:=true;
    p_rJCasePriority.JCAPR_JCasePriority_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jcasepriority');
    bOk:=(u8Val(p_rJCasePriority.JCAPR_JCasePriority_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151600,'Problem getting an UID for new jcasepriority record.','saJAS_GetNextUID table: jcasepriority',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jcasepriority (JCAPR_JCasePriority_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJCasePriority.JCAPR_JCasePriority_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161844);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151601,'Problem creating a new jcasepriority record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJCasePriority.JCAPR_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCasePriority.JCAPR_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJCasePriority.JCAPR_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCasePriority.JCAPR_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJCasePriority.JCAPR_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJCasePriority.JCAPR_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcasepriority', p_rJCasePriority.JCAPR_JCasePriority_UID, '0',201506200223);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151602,'Problem locking jcasepriority record.','p_rJCasePriority.JCAPR_JCasePriority_UID:'+p_rJCasePriority.JCAPR_JCasePriority_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJCasePriority do begin
      saQry:='UPDATE jcasepriority set '+
        //JCAPR_JCasePriority_UID='+JAS.saDBMSScrub()+
        'JCAPR_Name='+JAS.saDBMSScrub(JCAPR_Name);
        if(bAddNew)then
        begin
          saQry+=',JCAPR_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCAPR_CreatedBy_JUser_ID)+
          ',JCAPR_Created_DT='+JAS.saDBMSDateScrub(JCAPR_Created_DT);
        end;
        saQry+=
        ',JCAPR_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCAPR_ModifiedBy_JUser_ID)+
        ',JCAPR_Modified_DT='+JAS.saDBMSDateScrub(JCAPR_Modified_DT)+
        ',JCAPR_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCAPR_DeletedBy_JUser_ID)+
        ',JCAPR_Deleted_DT='+JAS.saDBMSDateScrub(JCAPR_Deleted_DT)+
        ',JCAPR_Deleted_b='+JAS.saDBMSBoolScrub(JCAPR_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JCAPR_JCasePriority_UID='+JAS.saDBMSUIntScrub(JCAPR_JCasePriority_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161845);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151603,'Problem updating jcasepriority.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jcasepriority', p_rJCasePriority.JCAPR_JCasePriority_UID, '0',201506200391) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151604,'Problem unlocking jcasepriority record.','p_rJCasePriority.JCAPR_JCasePriority_UID:'+p_rJCasePriority.JCAPR_JCasePriority_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113077,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jcasesource(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseSource: rtJCaseSource; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jcasesource'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113078,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113079, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jcasesource where JCASR_JCaseSource_UID='+JAS.saDBMSUIntScrub(p_rJCaseSource.JCASR_JCaseSource_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcasesource', p_rJCaseSource.JCASR_JCaseSource_UID, '0',201506200224);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100650,'Problem locking jcasesource record.','p_rJCaseSource.JCASR_JCaseSource_UID:'+p_rJCaseSource.JCASR_JCaseSource_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161846);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151605,'Unable to query jcasesource successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151606,'Record missing from jcasesource.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJCaseSource do begin
        //JCASR_JCaseSource_UID:=rs.Fields.Get_saValue('');
        JCASR_Name:=rs.Fields.Get_saValue('JCASR_Name');
        JCASR_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JCASR_CreatedBy_JUser_ID');
        JCASR_Created_DT                 :=rs.Fields.Get_saValue('JCASR_Created_DT');
        JCASR_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JCASR_ModifiedBy_JUser_ID');
        JCASR_Modified_DT                :=rs.Fields.Get_saValue('JCASR_Modified_DT');
        JCASR_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JCASR_DeletedBy_JUser_ID');
        JCASR_Deleted_DT                 :=rs.Fields.Get_saValue('JCASR_Deleted_DT');
        JCASR_Deleted_b                  :=rs.Fields.Get_saValue('JCASR_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113080,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jcasesource(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseSource: rtJCaseSource; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jcasesource'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113081,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113082, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJCaseSource.JCASR_JCaseSource_UID)=0 then
  begin
    bAddNew:=true;
    p_rJCaseSource.JCASR_JCaseSource_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jcasesource');
    bOk:=(u8Val(p_rJCaseSource.JCASR_JCaseSource_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151607,'Problem getting an UID for new jcasesource record.','saJAS_GetNextUID table: jcasesource',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jcasesource (JCASR_JCaseSource_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJCaseSource.JCASR_JCaseSource_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161847);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151608,'Problem creating a new jcasesource record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJCaseSource.JCASR_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCaseSource.JCASR_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJCaseSource.JCASR_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCaseSource.JCASR_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJCaseSource.JCASR_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJCaseSource.JCASR_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcasesource', p_rJCaseSource.JCASR_JCaseSource_UID, '0',201506200225);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151609,'Problem locking jcasesource record.','p_rJCaseSource.JCASR_JCaseSource_UID:'+p_rJCaseSource.JCASR_JCaseSource_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJCaseSource do begin
      saQry:='UPDATE jcasesource set '+
        //'JCASR_JCaseSource_UID='+JAS.saDBMSScrub()+
        'JCASR_Name='+JAS.saDBMSScrub(JCASR_Name);
        if(bAddNew)then
        begin
          saQry+=',JCASR_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCASR_CreatedBy_JUser_ID)+
          ',JCASR_Created_DT='+JAS.saDBMSDateScrub(JCASR_Created_DT);
        end;
        saQry+=
        ',JCASR_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCASR_ModifiedBy_JUser_ID)+
        ',JCASR_Modified_DT='+JAS.saDBMSDateScrub(JCASR_Modified_DT)+
        ',JCASR_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCASR_DeletedBy_JUser_ID)+
        ',JCASR_Deleted_DT='+JAS.saDBMSDateScrub(JCASR_Deleted_DT)+
        ',JCASR_Deleted_b='+JAS.saDBMSBoolScrub(JCASR_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JCASR_JCaseSource_UID='+JAS.saDBMSUIntScrub(JCASR_JCaseSource_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161847);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151610,'Problem updating jcasesource.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jcasesource', p_rJCaseSource.JCASR_JCaseSource_UID, '0',201506200392) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151611,'Problem unlocking jcasesource record.','p_rJCaseSource.JCASR_JCaseSource_UID:'+p_rJCaseSource.JCASR_JCaseSource_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113083,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
function bJAS_Load_jcasesubject(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseSubject: rtJCaseSubject; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jcasesubject'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113090,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113091, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jcasesubject where JCASB_JCaseSubject_UID='+JAS.saDBMSUIntScrub(p_rJCaseSubject.JCASB_JCaseSubject_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcasesubject', p_rJCaseSubject.JCASB_JCaseSubject_UID, '0',201506200226);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100655,'Problem locking jcasesubject record.','p_rJCaseSubject.JCASB_JCaseSubject_UID:'+p_rJCaseSubject.JCASB_JCaseSubject_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161848);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151619,'Unable to query jcasesubject successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151620,'Record missing from jcasesubject.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJCaseSubject do begin
        //JCASB_JCaseSubject_UID:=rs.Get_saValue('');
        JCASB_Name:=rs.Get_saValue('JCASB_Name');
        JCASB_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JCASB_CreatedBy_JUser_ID');
        JCASB_Created_DT                 :=rs.Fields.Get_saValue('JCASB_Created_DT');
        JCASB_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JCASB_ModifiedBy_JUser_ID');
        JCASB_Modified_DT                :=rs.Fields.Get_saValue('JCASB_Modified_DT');
        JCASB_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JCASB_DeletedBy_JUser_ID');
        JCASB_Deleted_DT                 :=rs.Fields.Get_saValue('JCASB_Deleted_DT');
        JCASB_Deleted_b                  :=rs.Fields.Get_saValue('JCASB_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113092,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jcasesubject(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseSubject: rtJCaseSubject; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jcasesubject'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113093,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113094, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJCaseSubject.JCASB_JCaseSubject_UID)=0 then
  begin
    bAddNew:=true;
    p_rJCaseSubject.JCASB_JCaseSubject_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jcasesubject');
    bOk:=(u8Val(p_rJCaseSubject.JCASB_JCaseSubject_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151621,'Problem getting an UID for new jcasesubject record.','saJAS_GetNextUID table: jcasesubject',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jblokfield (p_rJCaseSubject.JCASB_JCaseSubject_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJCaseSubject.JCASB_JCaseSubject_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161849);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151622,'Problem creating a new jcasesubject record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJCaseSubject.JCASB_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCaseSubject.JCASB_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJCaseSubject.JCASB_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCaseSubject.JCASB_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJCaseSubject.JCASB_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJCaseSubject.JCASB_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jblokfield', p_rJCaseSubject.JCASB_JCaseSubject_UID, '0',201506200227);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151623,'Problem locking jcasesubject record.','p_rJCaseSubject.JCASB_JCaseSubject_UID:'+p_rJCaseSubject.JCASB_JCaseSubject_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJCaseSubject do begin
      saQry:='UPDATE jcasesubject set '+
        //' JCASB_JCaseSubject_UID='+JAS.saDBMSScrub()+
        'JCASB_Name='+JAS.saDBMSScrub(JCASB_Name);
        if(bAddNew)then
        begin
          saQry+=',JCASB_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCASB_CreatedBy_JUser_ID)+
          ',JCASB_Created_DT='+JAS.saDBMSDateScrub(JCASB_Created_DT);
        end;
        saQry+=
        ',JCASB_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCASB_ModifiedBy_JUser_ID)+
        ',JCASB_Modified_DT='+JAS.saDBMSDateScrub(JCASB_Modified_DT)+
        ',JCASB_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCASB_DeletedBy_JUser_ID)+
        ',JCASB_Deleted_DT='+JAS.saDBMSDateScrub(JCASB_Deleted_DT)+
        ',JCASB_Deleted_b='+JAS.saDBMSBoolScrub(JCASB_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JCASB_JCaseSubject_UID='+JAS.saDBMSUIntScrub(JCASB_JCaseSubject_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161850);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151624,'Problem updating jcasesubject.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jcasesubject', p_rJCaseSubject.JCASB_JCaseSubject_UID, '0',201506200393) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151625,'Problem unlocking jcasesubject record.','p_rJCaseSubject.JCASB_JCaseSubject_UID:'+p_rJCaseSubject.JCASB_JCaseSubject_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113095,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jcasetype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseType: rtJCaseType; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jcasetype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113096,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113097, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jcasetype where JCATY_JCaseType_UID='+JAS.saDBMSUIntScrub(p_rJCaseType.JCATY_JCaseType_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcasetype', p_rJCaseType.JCATY_JCaseType_UID, '0',201506200228);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100656,'Problem locking jcasetype record.','p_rJCaseType.JCATY_JCaseType_UID:'+p_rJCaseType.JCATY_JCaseType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161851);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151626,'Unable to query jcasetype successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151627,'Record missing from jcasetype.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJCaseType do begin
        // JCATY_JCaseType_UID:=rs.Fields.Get_saValue('');
        JCATY_Name:=rs.Fields.Get_saValue('JCATY_Name');
        JCATY_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JCATY_CreatedBy_JUser_ID');
        JCATY_Created_DT                 :=rs.Fields.Get_saValue('JCATY_Created_DT');
        JCATY_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JCATY_ModifiedBy_JUser_ID');
        JCATY_Modified_DT                :=rs.Fields.Get_saValue('JCATY_Modified_DT');
        JCATY_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JCATY_DeletedBy_JUser_ID');
        JCATY_Deleted_DT                 :=rs.Fields.Get_saValue('JCATY_Deleted_DT');
        JCATY_Deleted_b                  :=rs.Fields.Get_saValue('JCATY_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113098,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jcasetype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCaseType: rtJCaseType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jcasetype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113099,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113100, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJCaseType.JCATY_JCaseType_UID)=0 then
  begin
    bAddNew:=true;
    p_rJCaseType.JCATY_JCaseType_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jcasetype');
    bOk:=(u8Val(p_rJCaseType.JCATY_JCaseType_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151628,'Problem getting an UID for new jcasetype record.','saJAS_GetNextUID table: jcasetype',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jcasetype (JCATY_JCaseType_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJCaseType.JCATY_JCaseType_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161852);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151629,'Problem creating a new jcasetype record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJCaseType.JCATY_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCaseType.JCATY_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJCaseType.JCATY_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCaseType.JCATY_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJCaseType.JCATY_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJCaseType.JCATY_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcasetype', p_rJCaseType.JCATY_JCaseType_UID, '0',201506200229);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151630,'Problem locking jcasetype record.','p_rJCaseType.JCATY_JCaseType_UID:'+p_rJCaseType.JCATY_JCaseType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJCaseType do begin
      saQry:='UPDATE jcasetype set '+
        //JCATY_JCaseType_UID
        'JCATY_Name='+JAS.saDBMSScrub(JCATY_Name);
        if(bAddNew)then
        begin
          saQry+=',JCATY_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCATY_CreatedBy_JUser_ID)+
          ',JCATY_Created_DT='+JAS.saDBMSDateScrub(JCATY_Created_DT);
        end;
        saQry+=
        ',JCATY_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCATY_ModifiedBy_JUser_ID)+
        ',JCATY_Modified_DT='+JAS.saDBMSDateScrub(JCATY_Modified_DT)+
        ',JCATY_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCATY_DeletedBy_JUser_ID)+
        ',JCATY_Deleted_DT='+JAS.saDBMSDateScrub(JCATY_Deleted_DT)+
        ',JCATY_Deleted_b='+JAS.saDBMSBoolScrub(JCATY_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JCATY_JCaseType_UID='+JAS.saDBMSUIntScrub(JCATY_JCaseType_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161853);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151631,'Problem updating jcasetype.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jcasetype', p_rJCaseType.JCATY_JCaseType_UID, '0',201506200394) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151632,'Problem unlocking jcasetype record.','p_rJCaseType.JCATY_JCaseType_UID:'+p_rJCaseType.JCATY_JCaseType_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113101,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================











//=============================================================================
function bJAS_Load_jcolumn(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJColumn: rtJColumn; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jcolumn'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113108,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113109, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jcolumn where JColu_JColumn_UID='+JAS.saDBMSUIntScrub(p_rJColumn.JColu_JColumn_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcolumn', p_rJColumn.JColu_JColumn_UID, '0',201506200230);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100700,'Problem locking jcolumn record.','p_rJColumn.JColu_JColumn_UID:'+p_rJColumn.JColu_JColumn_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161854);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151646,'Unable to query jcolumn successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Warn,201002151647,'Record missing from jcolumn.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJColumn do begin
        //JColu_JColumn_UID           :=rs.Fields.Get_saValue('JColu_JColumn_UID');
        JColu_Name                      :=rs.Fields.Get_saValue('JColu_Name');
        JColu_JTable_ID                 :=rs.Fields.Get_saValue('JColu_JTable_ID');
        JColu_JDType_ID                 :=rs.Fields.Get_saValue('JColu_JDType_ID');
        JColu_AllowNulls_b              :=rs.Fields.Get_saValue('JColu_AllowNulls_b');
        JColu_DefaultValue              :=rs.Fields.Get_saValue('JColu_DefaultValue');
        JColu_PrimaryKey_b              :=rs.Fields.Get_saValue('JColu_PrimaryKey_b');
        JColu_JAS_b                     :=rs.Fields.Get_saValue('JColu_JAS_b');
        JColu_JCaption_ID               :=rs.Fields.Get_saValue('JColu_JCaption_ID');
        JColu_DefinedSize_u             :=rs.Fields.Get_saValue('JColu_DefinedSize_u');
        JColu_NumericScale_u            :=rs.Fields.Get_saValue('JColu_NumericScale_u');
        JColu_Precision_u               :=rs.Fields.Get_saValue('JColu_Precision_u');
        JColu_Boolean_b                 :=rs.Fields.Get_saValue('JColu_Boolean_b');
        JColu_JAS_Key_b                 :=rs.Fields.Get_saValue('JColu_JAS_Key_b');
        JColu_AutoIncrement_b           :=rs.Fields.Get_saValue('JColu_AutoIncrement_b');
        JColu_LUF_Value                 :=rs.Fields.Get_saValue('JColu_LUF_Value');
        JColu_LD_CaptionRules_b         :=rs.Fields.Get_saValue('JColu_LD_CaptionRules_b');
        JColu_JDConnection_ID           :=rs.Fields.Get_saValue('JColu_JDConnection_ID');
        JColu_Desc                      :=rs.Fields.Get_saValue('JColu_Desc');
        JColu_Weight_u                  :=rs.Fields.Get_saValue('JColu_Weight_u');
        JColu_LD_SQL                    :=rs.Fields.Get_saValue('JColu_LD_SQL');
        JColu_LU_JColumn_ID             :=rs.Fields.Get_saValue('JColu_LU_JColumn_ID');
        JColu_CreatedBy_JUser_ID        :=rs.Fields.Get_saValue('JColu_CreatedBy_JUser_ID');
        JColu_Created_DT                :=rs.Fields.Get_saValue('JColu_Created_DT');
        JColu_ModifiedBy_JUser_ID       :=rs.Fields.Get_saValue('JColu_ModifiedBy_JUser_ID');
        JColu_Modified_DT               :=rs.Fields.Get_saValue('JColu_Modified_DT');
        JColu_DeletedBy_JUser_ID        :=rs.Fields.Get_saValue('JColu_DeletedBy_JUser_ID');
        JColu_Deleted_DT                :=rs.Fields.Get_saValue('JColu_Deleted_DT');
        JColu_Deleted_b                 :=rs.Fields.Get_saValue('JColu_Deleted_b');
        JAS_Row_b                       :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113110,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jcolumn(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJColumn: rtJColumn; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jcolumn'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113111,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113112, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJColumn.JColu_JColumn_UID)=0 then
  begin
    bAddNew:=true;
    p_rJColumn.JColu_JColumn_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jcolumn');
    bOk:=(u8Val(p_rJColumn.JColu_JColumn_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151648,'Problem getting an UID for new jcolumn record.','saJAS_GetNextUID table: jcolumn',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jcolumn (JColu_JColumn_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJColumn.JColu_JColumn_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161855);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151649,'Problem creating a new jcolumn record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJColumn.JColu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJColumn.JColu_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJColumn.JColu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJColumn.JColu_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJColumn.JColu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJColumn.JColu_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcolumn', p_rJColumn.JColu_JColumn_UID, '0',201506200231);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151650,'Problem locking jcolumn record.','p_rJColumn.JColu_JColumn_UID:'+p_rJColumn.JColu_JColumn_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJColumn do begin
      saQry:='UPDATE jcolumn set '+
        //' JColu_JColumn_UID='+JAS.saDBMSScrub()+
        'JColu_Name='+JAS.saDBMSScrub(JColu_Name)+
        ',JColu_JTable_ID='+JAS.saDBMSUIntScrub(JColu_JTable_ID)+
        ',JColu_JDType_ID='+JAS.saDBMSUIntScrub(JColu_JDType_ID)+
        ',JColu_AllowNulls_b='+JAS.saDBMSBoolScrub(JColu_AllowNulls_b)+
        ',JColu_DefaultValue='+JAS.saDBMSScrub(JColu_DefaultValue)+
        ',JColu_PrimaryKey_b='+JAS.saDBMSBoolScrub(JColu_PrimaryKey_b)+
        ',JColu_JAS_b='+JAS.saDBMSBoolScrub(JColu_JAS_b)+
        ',JColu_JCaption_ID='+JAS.saDBMSUIntScrub(JColu_JCaption_ID)+
        ',JColu_DefinedSize_u='+JAS.saDBMSUIntScrub(JColu_DefinedSize_u)+
        ',JColu_NumericScale_u='+JAS.saDBMSDecScrub(JColu_NumericScale_u)+
        ',JColu_Precision_u='+JAS.saDBMSDecScrub(JColu_Precision_u)+
        ',JColu_Boolean_b='+JAS.saDBMSBoolScrub(JColu_Boolean_b)+
        ',JColu_JAS_Key_b='+JAS.saDBMSBoolScrub(JColu_JAS_Key_b)+
        ',JColu_AutoIncrement_b='+JAS.saDBMSBoolScrub(JColu_AutoIncrement_b)+
        ',JColu_LUF_Value='+JAS.saDBMSScrub(JColu_LUF_Value)+
        ',JColu_LD_CaptionRules_b='+JAS.saDBMSBoolScrub(JColu_LD_CaptionRules_b)+
        ',JColu_JDConnection_ID='+JAS.saDBMSUIntScrub(JColu_JDConnection_ID)+
        ',JColu_Desc='+JAS.saDBMSScrub(JColu_Desc)+
        ',JColu_Weight_u='+JAS.saDBMSIntScrub(JColu_Weight_u)+
        ',JColu_LD_SQL='+JAS.saDBMSScrub(JColu_LD_SQL)+
        ',JColu_LU_JColumn_ID='+JAS.saDBMSUIntScrub(JColu_LU_JColumn_ID);
        if(bAddNew)then
        begin
          saQry+=',JColu_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JColu_CreatedBy_JUser_ID)+
          ',JColu_Created_DT='+JAS.saDBMSDateScrub(JColu_Created_DT);
        end;
        saQry+=
        ',JColu_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JColu_ModifiedBy_JUser_ID)+
        ',JColu_Modified_DT='+JAS.saDBMSDateScrub(JColu_Modified_DT)+
        ',JColu_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JColu_DeletedBy_JUser_ID)+
        ',JColu_Deleted_DT='+JAS.saDBMSDateScrub(JColu_Deleted_DT)+
        ',JColu_Deleted_b='+JAS.saDBMSBoolScrub(JColu_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JColu_JColumn_UID='+JAS.saDBMSUIntScrub(JColu_JColumn_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161856);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151651,'Problem updating jcolumn.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jcolumn', p_rJColumn.JColu_JColumn_UID, '0',201506200395) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151652,'Problem unlocking jcolumn record.','p_rJColumn.JColu_JColumn_UID:'+p_rJColumn.JColu_JColumn_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113113,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
function bJAS_Load_jcompany(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCompany: rtJCompany; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jcompany'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113114,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113115, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jcompany where JComp_JCompany_UID='+JAS.saDBMSUIntScrub(p_rJCompany.JComp_JCompany_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcompany', p_rJCompany.JComp_JCompany_UID, '0',201506200232);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100707,'Problem locking jcompany record.','p_rJCompany.JComp_JCompany_UID:'+p_rJCompany.JComp_JCompany_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161857);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151713,'Unable to query jcompany successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151714,'Record missing from jcompany.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJCompany do begin
        JComp_JCompany_UID        :=rs.Fields.Get_saValue('JComp_JCompany_UID');
        JComp_Name                :=rs.Fields.Get_saValue('JComp_Name');
        JComp_Desc                :=rs.Fields.Get_saValue('JComp_Desc');
        JComp_Primary_Person_ID   :=rs.Fields.Get_saValue('JComp_Primary_Person_ID');
        JComp_Phone               :=rs.Fields.Get_saValue('JComp_Phone');
        JComp_Fax                 :=rs.Fields.Get_saValue('JComp_Fax');
        JComp_Email               :=rs.Fields.Get_saValue('JComp_Email');
        JComp_Website             :=rs.Fields.Get_saValue('JComp_Website');
        JComp_Parent_ID           :=rs.Fields.Get_saValue('JComp_Parent_ID');
        JComp_Owner_JUser_ID      :=rs.Fields.Get_saValue('JComp_Owner_JUser_ID');
        JComp_Main_Addr1          :=rs.Fields.Get_saValue('JComp_Main_Addr1');
        JComp_Main_Addr2          :=rs.Fields.Get_saValue('JComp_Main_Addr2');
        JComp_Main_Addr3          :=rs.Fields.Get_saValue('JComp_Main_Addr3');
        JComp_Main_City           :=rs.Fields.Get_saValue('JComp_Main_City');
        JComp_Main_State          :=rs.Fields.Get_saValue('JComp_Main_State');
        JComp_Main_PostalCode     :=rs.Fields.Get_saValue('JComp_Main_PostalCode');
        JComp_Main_Country        :=rs.Fields.Get_saValue('JComp_Main_Country');
        JComp_Main_Longitude_d    :=rs.Fields.Get_saValue('JComp_Main_Longitude_d');
        JComp_Main_Latitude_d     :=rs.Fields.Get_saValue('JComp_Main_Latitude_d');
        JComp_Ship_Addr1          :=rs.Fields.Get_saValue('JComp_Ship_Addr1');
        JComp_Ship_Addr2          :=rs.Fields.Get_saValue('JComp_Ship_Addr2');
        JComp_Ship_Addr3          :=rs.Fields.Get_saValue('JComp_Ship_Addr3');
        JComp_Ship_City           :=rs.Fields.Get_saValue('JComp_Ship_City');
        JComp_Ship_State          :=rs.Fields.Get_saValue('JComp_Ship_State');
        JComp_Ship_PostalCode     :=rs.Fields.Get_saValue('JComp_Ship_PostalCode');
        JComp_Ship_Country        :=rs.Fields.Get_saValue('JComp_Ship_Country');
        JComp_Ship_Longitude_d    :=rs.Fields.Get_saValue('JComp_Ship_Longitude_d');
        JComp_Ship_Latitude_d     :=rs.Fields.Get_saValue('JComp_Ship_Latitude_d');
        JComp_Customer_b          :=rs.Fields.Get_saValue('JComp_Customer_b');
        JComp_Vendor_b            :=rs.Fields.Get_saValue('JComp_Vendor_b');
        JComp_CreatedBy_JUser_ID  :=rs.Fields.Get_saValue('JComp_CreatedBy_JUser_ID');
        JComp_Created_DT          :=rs.Fields.Get_saValue('JComp_Created_DT');
        JComp_ModifiedBy_JUser_ID :=rs.Fields.Get_saValue('JComp_ModifiedBy_JUser_ID');
        JComp_Modified_DT         :=rs.Fields.Get_saValue('JComp_Modified_DT');
        JComp_DeletedBy_JUser_ID  :=rs.Fields.Get_saValue('JComp_DeletedBy_JUser_ID');
        JComp_Deleted_DT          :=rs.Fields.Get_saValue('JComp_Deleted_DT');
        JComp_Deleted_b           :=rs.Fields.Get_saValue('JComp_Deleted_b');
        JAS_Row_b                 :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113116,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jcompany(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCompany: rtJCompany; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jcompany'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113117,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113118, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJCompany.JComp_JCompany_UID)=0 then
  begin
    bAddNew:=true;
    p_rJCompany.JComp_JCompany_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jcompany');
    bOk:=(u8Val(p_rJCompany.JComp_JCompany_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151715,'Problem getting an UID for new jcompany record.','saJAS_GetNextUID table: jcompany',SOURCEFILE);
    end;
    if bOk then
    begin
      saQry:='INSERT INTO jcompany (JComp_JCompany_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJCompany.JComp_JCompany_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161858);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151716,'Problem creating a new jcompany record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJCompany.JComp_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCompany.JComp_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJCompany.JComp_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCompany.JComp_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJCompany.JComp_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJCompany.JComp_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcompany', p_rJCompany.JComp_JCompany_UID, '0',201506200234);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151717,'Problem locking jcompany record.','p_rJCompany.JComp_JCompany_UID:'+p_rJCompany.JComp_JCompany_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJCompany do begin
      saQry:='UPDATE jcompany set '+
        // JComp_JCompany_UID
        'JComp_Name='             +JAS.saDBMSScrub(JComp_Name              )+
        ',JComp_Primary_Person_ID='+JAS.saDBMSUIntScrub(JComp_Primary_Person_ID )+
        ',JComp_Phone='            +JAS.saDBMSScrub(JComp_Phone             )+
        ',JComp_Fax='              +JAS.saDBMSScrub(JComp_Fax               )+
        ',JComp_Email='            +JAS.saDBMSScrub(JComp_Email             )+
        ',JComp_Website='          +JAS.saDBMSScrub(JComp_Website           )+
        ',JComp_Parent_ID='        +JAS.saDBMSUintScrub(JComp_Parent_ID     )+
        ',JComp_Owner_JUser_ID='   +JAS.saDBMSUIntScrub(JComp_Owner_JUser_ID)+
        ',JComp_Desc='             +JAS.saDBMSScrub(JComp_Desc              )+
        ',JComp_Main_Addr1='       +JAS.saDBMSScrub(JComp_Main_Addr1        )+
        ',JComp_Main_Addr2='       +JAS.saDBMSScrub(JComp_Main_Addr2        )+
        ',JComp_Main_Addr3='       +JAS.saDBMSScrub(JComp_Main_Addr3        )+
        ',JComp_Main_City='        +JAS.saDBMSScrub(JComp_Main_City         )+
        ',JComp_Main_State='       +JAS.saDBMSScrub(JComp_Main_State        )+
        ',JComp_Main_PostalCode='  +JAS.saDBMSScrub(JComp_Main_PostalCode   )+
        ',JComp_Ship_Addr1='       +JAS.saDBMSScrub(JComp_Ship_Addr1        )+
        ',JComp_Ship_Addr2='       +JAS.saDBMSScrub(JComp_Ship_Addr2        )+
        ',JComp_Ship_Addr3='       +JAS.saDBMSScrub(JComp_Ship_Addr3        )+
        ',JComp_Ship_City='        +JAS.saDBMSScrub(JComp_Ship_City         )+
        ',JComp_Ship_State='       +JAS.saDBMSScrub(JComp_Ship_State        )+
        ',JComp_Ship_PostalCode='  +JAS.saDBMSScrub(JComp_Ship_PostalCode   )+
        ',JComp_Main_Longitude_d=' +JAS.saDBMSDecScrub(JComp_Main_Longitude_d  )+
        ',JComp_Main_Latitude_d='  +JAS.saDBMSDecScrub(JComp_Main_Latitude_d   )+
        ',JComp_Ship_Longitude_d=' +JAS.saDBMSDecScrub(JComp_Ship_Longitude_d  )+
        ',JComp_Ship_Latitude_d='  +JAS.saDBMSDecScrub(JComp_Ship_Latitude_d   )+
        ',JComp_Customer_b='       +JAS.saDBMSBoolScrub(JComp_Customer_b        )+
        ',JComp_Vendor_b='         +JAS.saDBMSBoolScrub(JComp_Vendor_b        );
        if(bAddNew)then
        begin
          saQry+=',JComp_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JComp_CreatedBy_JUser_ID)+
          ',JComp_Created_DT='+JAS.saDBMSDateScrub(JComp_Created_DT);
        end;
        saQry+=
        ',JComp_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JComp_ModifiedBy_JUser_ID)+
        ',JComp_Modified_DT='        +JAS.saDBMSScrub(JComp_Modified_DT            )+
        ',JComp_DeletedBy_JUser_ID=' +JAS.saDBMSUIntScrub(JComp_DeletedBy_JUser_ID )+
        ',JComp_Deleted_DT='         +JAS.saDBMSScrub(JComp_Deleted_DT             )+
        ',JComp_Deleted_b='          +JAS.saDBMSBoolScrub(JComp_Deleted_b          )+
        ',JAS_Row_b='                +JAS.saDBMSBoolScrub(JAS_Row_b                )+
        ' WHERE JComp_JCompany_UID='+JAS.saDBMSUIntScrub(JComp_JCompany_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161859);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151718,'Problem updating jcompany.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jcompany', p_rJCompany.JComp_JCompany_UID, '0',201506200396) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151719,'Problem unlocking jcompany record.','p_rJCompany.JComp_JCompany_UID:'+p_rJCompany.JComp_JCompany_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113119,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
function bJAS_Load_jcompanypers(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCompanyPers: rtJCompanyPers; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jcompanypers'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113126,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113127, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jcompanypers where JCpyP_JCompanyPers_UID='+JAS.saDBMSUIntScrub(p_rJCompanyPers.JCpyP_JCompanyPers_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcompanypers', p_rJCompanyPers.JCpyP_JCompanyPers_UID, '0',201506200235);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100710,'Problem locking jcompanypers record.','p_rJCompanyPers.JCpyP_JCompanyPers_UID:'+p_rJCompanyPers.JCpyP_JCompanyPers_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161900);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151727,'Unable to query jcompany successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151728,'Record missing from jcompany.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJCompanyPers do begin
        //JCpyP_JCompanyPers_UID:=rs.Fields.Get_saValue('');
        JCpyP_JCompany_ID:=rs.Fields.Get_saValue('JCpyP_JCompany_ID');
        JCpyP_JPerson_ID:=rs.Fields.Get_saValue('JCpyP_JPerson_ID');
        JCpyP_DepartmentLU_ID:=rs.Fields.Get_saValue('JCpyP_DepartmentLU_ID');
        JCpyP_Title:=rs.Fields.Get_saValue('JCpyP_Title');
        JCpyP_ReportsTo_Person_ID:=rs.Fields.Get_saValue('JCpyP_ReportsTo_Person_ID');
        JCpyP_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JCpyP_CreatedBy_JUser_ID');
        JCpyP_Created_DT                 :=rs.Fields.Get_saValue('JCpyP_Created_DT');
        JCpyP_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JCpyP_ModifiedBy_JUser_ID');
        JCpyP_Modified_DT                :=rs.Fields.Get_saValue('JCpyP_Modified_DT');
        JCpyP_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JCpyP_DeletedBy_JUser_ID');
        JCpyP_Deleted_DT                 :=rs.Fields.Get_saValue('JCpyP_Deleted_DT');
        JCpyP_Deleted_b                  :=rs.Fields.Get_saValue('JCpyP_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113128,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jcompanypers(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJCompanyPers: rtJCompanyPers; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jcompanypers'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113129,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113130, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJCompanyPers.JCpyP_JCompanyPers_UID)=0 then
  begin
    bAddNew:=true;
    p_rJCompanyPers.JCpyP_JCompanyPers_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jcompanypers');
    bOk:=(u8Val(p_rJCompanyPers.JCpyP_JCompanyPers_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151729,'Problem getting an UID for new jcompanypers record.','saJAS_GetNextUID table: jcompanypers',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jcompanypers (JCpyP_JCompanyPers_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJCompanyPers.JCpyP_JCompanyPers_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161901);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151730,'Problem creating a new jcompanypers record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJCompanyPers.JCpyP_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCompanyPers.JCpyP_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJCompanyPers.JCpyP_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJCompanyPers.JCpyP_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJCompanyPers.JCpyP_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJCompanyPers.JCpyP_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jcompanypers', p_rJCompanyPers.JCpyP_JCompanyPers_UID, '0',201506200236);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151731,'Problem locking jcompanypers record.','p_rJCompanyPers.JCpyP_JCompanyPers_UID:'+p_rJCompanyPers.JCpyP_JCompanyPers_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJCompanyPers do begin
      saQry:='UPDATE jcompanypers set '+
        //' JCpyP_JCompanyPers_UID='+JAS.saDBMSScrub()+
        'JCpyP_JCompany_ID='+JAS.saDBMSUIntScrub(JCpyP_JCompany_ID)+
        ',JCpyP_JPerson_ID='+JAS.saDBMSUIntScrub(JCpyP_JPerson_ID)+
        ',JCpyP_DepartmentLU_ID='+JAS.saDBMSUIntScrub(JCpyP_DepartmentLU_ID)+
        ',JCpyP_Title='+JAS.saDBMSScrub(JCpyP_Title)+
        ',JCpyP_ReportsTo_Person_ID='+JAS.saDBMSUIntScrub(JCpyP_ReportsTo_Person_ID);
        if(bAddNew)then
        begin
          saQry+=',JCpyP_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCpyP_CreatedBy_JUser_ID)+
          ',JCpyP_Created_DT='+JAS.saDBMSDateScrub(JCpyP_Created_DT);
        end;
        saQry+=
        ',JCpyP_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCpyP_ModifiedBy_JUser_ID)+
        ',JCpyP_Modified_DT='+JAS.saDBMSDateScrub(JCpyP_Modified_DT)+
        ',JCpyP_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JCpyP_DeletedBy_JUser_ID)+
        ',JCpyP_Deleted_DT='+JAS.saDBMSDateScrub(JCpyP_Deleted_DT)+
        ',JCpyP_Deleted_b='+JAS.saDBMSBoolScrub(JCpyP_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JCpyP_JCompanyPers_UID='+JAS.saDBMSUIntScrub(JCpyP_JCompanyPers_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161902);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151732,'Problem updating jcompanypers.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jcompanypers', p_rJCompanyPers.JCpyP_JCompanyPers_UID, '0',201506200397) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151733,'Problem unlocking jcompanypers record.','p_rJCompanyPers.JCpyP_JCompanyPers_UID:'+p_rJCompanyPers.JCpyP_JCompanyPers_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113131,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================










//=============================================================================
function bJAS_Load_jdconnection(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJDConnection: rtJDConnection; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jdconnection'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113144,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113145, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jdconnection where JDCon_JDConnection_UID='+JAS.saDBMSUintScrub(p_rJDConnection.JDCon_JDConnection_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jdconnection', p_rJDConnection.JDCon_JDConnection_UID, '0',201506200237);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100714,'Problem locking jdconnection record.','p_rJDConnection.JDCon_JDConnection_UID:'+p_rJDConnection.JDCon_JDConnection_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161903);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151748,'Unable to query jdconnection successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151749,'Record missing from jdconnection.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJDConnection do begin
        //JDCon_JDConnection_UID:=rs.Fields.Get_saValue('');
        JDCon_Name:=rs.Fields.Get_saValue('JDCon_Name');
        JDCon_Desc:=rs.Fields.Get_saValue('JDCon_Desc');
        JDCon_DBC_Filename:=rs.Fields.Get_saValue('JDCon_DBC_Filename');
        JDCon_DSN:=rs.Fields.Get_saValue('JDCon_DSN');
        JDCon_DSN_FileBased_b:=rs.Fields.Get_saValue('JDCon_DSN_FileBased_b');
        JDCon_DSN_Filename:=rs.Fields.Get_saValue('JDCon_DSN_Filename');
        JDCon_Enabled_b:=rs.Fields.Get_saValue('JDCon_Enabled_b');
        JDCon_DBMS_ID:=rs.Fields.Get_saValue('JDCon_DBMS_ID');
        JDCon_Driver_ID:=rs.Fields.Get_saValue('JDCon_Driver_ID');
        JDCon_Username:=rs.Fields.Get_saValue('JDCon_Username');
        JDCon_Password:=rs.Fields.Get_saValue('JDCon_Password');
        JDCon_ODBC_Driver:=rs.Fields.Get_saValue('JDCon_ODBC_Driver');
        JDCon_Server:=rs.Fields.Get_saValue('JDCon_Server');
        JDCon_Database:=rs.Fields.Get_saValue('JDCon_Database');
        JDCon_JSecPerm_ID:=rs.Fields.Get_saValue('JDCon_JSecPerm_ID');
        JDCon_JAS_b:=rs.Fields.Get_saValue('JDCon_JAS_b');
        JDCon_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JDCon_CreatedBy_JUser_ID');
        JDCon_Created_DT                 :=rs.Fields.Get_saValue('JDCon_Created_DT');
        JDCon_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JDCon_ModifiedBy_JUser_ID');
        JDCon_Modified_DT                :=rs.Fields.Get_saValue('JDCon_Modified_DT');
        JDCon_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JDCon_DeletedBy_JUser_ID');
        JDCon_Deleted_DT                 :=rs.Fields.Get_saValue('JDCon_Deleted_DT');
        JDCon_Deleted_b                  :=rs.Fields.Get_saValue('JDCon_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113146,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jdconnection(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJDConnection: rtJDConnection; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jdconnection'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113147,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113148, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJDConnection.JDCon_JDConnection_UID)=0 then
  begin
    bAddNew:=true;
    p_rJDConnection.JDCon_JDConnection_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jdconnection');
    bOk:=(u8Val(p_rJDConnection.JDCon_JDConnection_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151750,'Problem getting an UID for new jdconnection record.','saJAS_GetNextUID table: jdconnection',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jdconnection (JDCon_JDConnection_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJDConnection.JDCon_JDConnection_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161904);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151751,'Problem creating a new jdconnection record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJDConnection.JDCon_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJDConnection.JDCon_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJDConnection.JDCon_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJDConnection.JDCon_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJDConnection.JDCon_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJDConnection.JDCon_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jdconnection', p_rJDConnection.JDCon_JDConnection_UID, '0',201506200238);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151752,'Problem locking jdconnection record.','p_rJDConnection.JDCon_JDConnection_UID:'+p_rJDConnection.JDCon_JDConnection_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJDConnection do begin
      saQry:='UPDATE jdconnection set '+
        //' JDCon_JDConnection_UID='+JAS.saDBMSScrub()+
        'JDCon_Name='+JAS.saDBMSScrub(JDCon_Name)+
        ',JDCon_Desc='+JAS.saDBMSScrub(JDCon_Desc)+
        ',JDCon_DBC_Filename='+JAS.saDBMSScrub(JDCon_DBC_Filename)+
        ',JDCon_DSN='+JAS.saDBMSScrub(JDCon_DSN)+
        ',JDCon_DSN_FileBased_b='+JAS.saDBMSBoolScrub(JDCon_DSN_FileBased_b)+
        ',JDCon_DSN_Filename='+JAS.saDBMSScrub(JDCon_DSN_Filename)+
        ',JDCon_Enabled_b='+JAS.saDBMSBoolScrub(JDCon_Enabled_b)+
        ',JDCon_DBMS_ID='+JAS.saDBMSUIntScrub(JDCon_DBMS_ID)+
        ',JDCon_Driver_ID='+JAS.saDBMSUIntScrub(JDCon_Driver_ID)+
        ',JDCon_Username='+JAS.saDBMSScrub(JDCon_Username)+
        ',JDCon_Password='+JAS.saDBMSScrub(JDCon_Password)+
        ',JDCon_ODBC_Driver='+JAS.saDBMSScrub(JDCon_ODBC_Driver)+
        ',JDCon_Server='+JAS.saDBMSScrub(JDCon_Server)+
        ',JDCon_Database='+JAS.saDBMSScrub(JDCon_Database)+
        ',JDCon_JSecPerm_ID='+JAS.saDBMSUIntScrub(JDCon_JSecPerm_ID)+
        ',JDCon_JAS_b='+JAS.saDBMSBoolScrub(JDCon_JAS_b);
        if(bAddNew)then
        begin
          saQry+=',JDCon_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JDCon_CreatedBy_JUser_ID)+
          ',JDCon_Created_DT='+JAS.saDBMSDateScrub(JDCon_Created_DT);
        end;
        saQry+=
        ',JDCon_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JDCon_ModifiedBy_JUser_ID)+
        ',JDCon_Modified_DT='+JAS.saDBMSDateScrub(JDCon_Modified_DT)+
        ',JDCon_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JDCon_DeletedBy_JUser_ID)+
        ',JDCon_Deleted_DT='+JAS.saDBMSDateScrub(JDCon_Deleted_DT)+
        ',JDCon_Deleted_b='+JAS.saDBMSBoolScrub(JDCon_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JDCon_JDConnection_UID='+JAS.saDBMSUIntScrub(JDCon_JDConnection_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161904);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151753,'Problem updating jdconnection.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jdconnection', p_rJDConnection.JDCon_JDConnection_UID, '0',201506200398) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151754,'Problem unlocking jdconnection record.','p_rJDConnection.JDCon_JDConnection_UID:'+p_rJDConnection.JDCon_JDConnection_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113149,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jdtype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJDType: rtJDType; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jdtype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113150,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113151, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jdtype where JDTyp_JDType_UID='+JAS.saDBMSUIntScrub(p_rJDType.JDTyp_JDType_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jdtype', p_rJDType.JDTyp_JDType_UID, '0',201506200240);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100715,'Problem locking jdtype record.','p_rJDType.JDTyp_JDType_UID:'+p_rJDType.JDTyp_JDType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161906);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151755,'Unable to query jdtype successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151756,'Record missing from jdtype.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJDType do begin
        //JDTyp_JDType_UID:=rs.Fields.Get_saValue('JDTyp_JDType_UID');
        JDTyp_Desc:=rs.Fields.Get_saValue('JDTyp_Desc');
        JDTyp_Notation:=rs.Fields.Get_saValue('JDTyp_Notation');
        JDTyp_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JDTyp_CreatedBy_JUser_ID');
        JDTyp_Created_DT                 :=rs.Fields.Get_saValue('JDTyp_Created_DT');
        JDTyp_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JDTyp_ModifiedBy_JUser_ID');
        JDTyp_Modified_DT                :=rs.Fields.Get_saValue('JDTyp_Modified_DT');
        JDTyp_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JDTyp_DeletedBy_JUser_ID');
        JDTyp_Deleted_DT                 :=rs.Fields.Get_saValue('JDTyp_Deleted_DT');
        JDTyp_Deleted_b                  :=rs.Fields.Get_saValue('JDTyp_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113152,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jdtype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJDType: rtJDType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jdtype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113153,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113154, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJDType.JDTyp_JDType_UID)=0 then
  begin
    bAddNew:=true;
    p_rJDType.JDTyp_JDType_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jdtype');
    bOk:=(u8Val(p_rJDType.JDTyp_JDType_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151757,'Problem getting an UID for new jdtype record.','saJAS_GetNextUID table: jdtype',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jdtype (JDTyp_JDType_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJDType.JDTyp_JDType_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161907);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151758,'Problem creating a new jdtype record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJDType.JDTyp_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJDType.JDTyp_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJDType.JDTyp_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJDType.JDTyp_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJDType.JDTyp_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJDType.JDTyp_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jdtype', p_rJDType.JDTyp_JDType_UID, '0',201506200241);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151759,'Problem locking jdtype record.','p_rJDType.JDTyp_JDType_UID:'+p_rJDType.JDTyp_JDType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJDType do begin
      saQry:='UPDATE jdtype set '+
        //JDTyp_JDType_UID='+JAS.saDBMSScrub()+
        'JDTyp_Desc='+JAS.saDBMSScrub(JDTyp_Desc)+
        ',JDTyp_Notation='+JAS.saDBMSScrub(JDTyp_Notation);
        if(bAddNew)then
        begin
          saQry+=',JDTyp_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JDTyp_CreatedBy_JUser_ID)+
          ',JDTyp_Created_DT='+JAS.saDBMSDateScrub(JDTyp_Created_DT);
        end;
        saQry+=
        ',JDTyp_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JDTyp_ModifiedBy_JUser_ID)+
        ',JDTyp_Modified_DT='+JAS.saDBMSDateScrub(JDTyp_Modified_DT)+
        ',JDTyp_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JDTyp_DeletedBy_JUser_ID)+
        ',JDTyp_Deleted_DT='+JAS.saDBMSDateScrub(JDTyp_Deleted_DT)+
        ',JDTyp_Deleted_b='+JAS.saDBMSBoolScrub(JDTyp_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JDTyp_JDType_UID='+JAS.saDBMSUIntScrub(JDTyp_JDType_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161908);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151800,'Problem updating jdtype.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jdtype', p_rJDType.JDTyp_JDType_UID, '0',201506200400) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151801,'Problem unlocking jdtype record.','p_rJDType.JDTyp_JDType_UID:'+p_rJDType.JDTyp_JDType_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113155,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

















//=============================================================================
function bJAS_Load_jfile(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFile: rtJFile; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jfile'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204290905,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204290906, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jfile where JFile_JFile_UID='+JAS.saDBMSUIntScrub(p_rJFile.JFile_JFile_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jfile', p_rJFile.JFile_JFile_UID, '0',201506200242);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201204290907,'Problem locking jfile record.','p_rJFile.JFile_JFile_UID:'+p_rJFile.JFile_JFile_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161909);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201204290908,'Unable to query jfile successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201204290909,'Record missing from jfile.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJFile do begin
        //JFile_JFile_UID           :=rs.Fields.Get_saValue('JFile_JFile_UID');
        JFile_en                  :=rs.Fields.Get_saValue('JFile_en');
        JFile_Name                :=rs.Fields.Get_saValue('JFile_Name');
        JFile_Path                :=rs.Fields.Get_saValue('JFile_Path');
        JFile_JTable_ID           :=rs.Fields.Get_saValue('JFile_JTable_ID');
        JFile_JColumn_ID          :=rs.Fields.Get_saValue('JFile_JColumn_ID');
        JFile_Row_ID              :=rs.Fields.Get_saValue('JFile_Row_ID');
        JFile_Orphan_b            :=rs.Fields.Get_saValue('JFile_Orphan_b');
        JFile_JSecPerm_ID         :=rs.Fields.Get_saValue('JFile_JSecPerm_ID');
        JFile_FileSize_u          :=rs.Fields.Get_saValue('JFile_FileSize_u');
        JFile_CreatedBy_JUser_ID  :=rs.Fields.Get_saValue('JFile_CreatedBy_JUser_ID');
        JFile_Created_DT          :=rs.Fields.Get_saValue('JFile_Created_DT');
        JFile_ModifiedBy_JUser_ID :=rs.Fields.Get_saValue('JFile_ModifiedBy_JUser_ID');
        JFile_Modified_DT         :=rs.Fields.Get_saValue('JFile_Modified_DT');
        JFile_DeletedBy_JUser_ID  :=rs.Fields.Get_saValue('JFile_DeletedBy_JUser_ID');
        JFile_Deleted_DT          :=rs.Fields.Get_saValue('JFile_Deleted_DT');
        JFile_Deleted_b           :=rs.Fields.Get_saValue('JFile_Deleted_b');
        JAS_Row_b                 :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204290910,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jfile(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFile: rtJFile; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jfile'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204290911,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204290912, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJFile.JFile_JFile_UID)=0 then
  begin
    bAddNew:=true;
    p_rJFile.JFile_JFile_UID:=saJAS_GetNextUID;
    bOk:=(u8Val(p_rJFile.JFile_JFile_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201204290913,'Problem getting an UID for new jfile record.','saJAS_GetNextUID table: jfile',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jfile (JFile_JFile_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJFile.JFile_JFile_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161910);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201204290914,'Problem creating a new jfile record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJFile.JFile_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJFile.JFile_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJFile.JFile_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJFile.JFile_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJFile.JFile_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJFile.JFile_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jfile', p_rJFile.JFile_JFile_UID, '0',201506200243);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201204290915,'Problem locking jfile record.','p_rJFile.JFile_JFile_UID:'+p_rJFile.JFile_JFile_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJFile do begin
      saQry:='UPDATE jfile set '+
      ' JFile_JFile_UID='              +JAS.saDBMSUIntScrub(JFile_JFile_UID)+
      ',JFile_en='                     +JAS.saDBMSScrub(JFile_en)+
      ',JFile_Name='                   +JAS.saDBMSScrub(JFile_Name)+
      ',JFile_Path='                   +JAS.saDBMSScrub(JFile_Path)+
      ',JFile_JTable_ID='              +JAS.saDBMSUIntScrub(JFile_JTable_ID)+
      ',JFile_JColumn_ID='             +JAS.saDBMSUIntScrub(JFile_JColumn_ID)+
      ',JFile_Row_ID='                 +JAS.saDBMSUIntScrub(JFile_Row_ID)+
      ',JFile_Orphan_b='               +JAS.saDBMSBoolScrub(JFile_Orphan_b)+
      ',JFile_JSecPerm_ID='            +JAS.saDBMSUIntScrub(JFile_JSecPerm_ID)+
      ',JFile_FileSize_u='             +JAS.saDBMSUIntScrub(JFile_FileSize_u);
      if bAddNew then
      begin
        saQry+=
          ',JFile_CreatedBy_JUser_ID=' +JAS.saDBMSUintScrub(JFile_CreatedBy_JUser_ID )+
          ',JFile_Created_DT='         +JAS.saDBMSDateScrub(JFile_Created_DT         );
      end;
      saQry+=
        ',JFile_ModifiedBy_JUser_ID='  +JAS.saDBMSUIntScrub(JFile_ModifiedBy_JUser_ID)+
        ',JFile_Modified_DT='          +JAS.saDBMSDateScrub(JFile_Modified_DT        )+
        ',JFile_DeletedBy_JUser_ID='   +JAS.saDBMSUintScrub(JFile_DeletedBy_JUser_ID )+
        ',JFile_Deleted_DT='           +JAS.saDBMSDateScrub(JFile_Deleted_DT         )+
        ',JFile_Deleted_b='            +JAS.saDBMSBoolScrub(JFile_Deleted_b          )+
        ',JAS_Row_b='                  +JAS.saDBMSBoolScrub(JAS_Row_b                )+
        ' WHERE JFile_JFile_UID='+JAS.saDBMSUIntScrub(JFile_JFile_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161911);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201204290916,'Problem updating jfile.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jfile', p_rJFile.JFile_JFile_UID, '0',201506200401) then
      begin
        JAS_Log(p_Context,cnLog_Error,201204290917,'Problem unlocking jfile record.','p_rJFile.JFile_JFile_UID:'+p_rJFile.JFile_JFile_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204290918,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




































//=============================================================================
function bJAS_Load_jfiltersave(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFilterSave: rtJFilterSave; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jfiltersave'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204031945,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204031946, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jfiltersave where JFtSa_JFilterSave_UID='+JAS.saDBMSUIntScrub(p_rJFilterSave.JFtSa_JFilterSave_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jfiltersave', p_rJFilterSave.JFtSa_JFilterSave_UID, '0',201506200244);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201204031947,'Problem locking jfiltersave record.','p_rJFilterSave.JFtSa_JFilterSave_UID:'+p_rJFilterSave.JFtSa_JFilterSave_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161912);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201204031948,'Unable to query jfiltersave successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201204031949,'Record missing from jfiltersave.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJFilterSave do begin
        //JFtSa_JFilterSave_UID:=rs.Fields.Get_saValue('JFtSa_JFilterSave_UID');
        JFtSa_Name                     :=rs.Fields.Get_saValue('JFtSa_Name');
        JFtSa_JBlok_ID                 :=rs.Fields.Get_saValue('JFtSa_JBlok_ID');
        JFtSa_Public_b                 :=rs.Fields.Get_saValue('JFtSa_Public_b');
        JFTSa_XML                      :=rs.Fields.Get_saValue('JFTSa_XML');
        JFtSa_CreatedBy_JUser_ID       :=rs.Fields.Get_saValue('JFtSa_CreatedBy_JUser_ID');
        JFtSa_Created_DT               :=rs.Fields.Get_saValue('JFtSa_Created_DT');
        JFtSa_ModifiedBy_JUser_ID      :=rs.Fields.Get_saValue('JFtSa_ModifiedBy_JUser_ID');
        JFtSa_Modified_DT              :=rs.Fields.Get_saValue('JFtSa_Modified_DT');
        JFtSa_DeletedBy_JUser_ID       :=rs.Fields.Get_saValue('JFtSa_DeletedBy_JUser_ID');
        JFtSa_Deleted_DT               :=rs.Fields.Get_saValue('JFtSa_Deleted_DT');
        JFtSa_Deleted_b                :=rs.Fields.Get_saValue('JFtSa_Deleted_b');
        JAS_Row_b                      :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204031950,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jfiltersave(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFilterSave: rtJFilterSave; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jfiltersave'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204031951,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204031952, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJFilterSave.JFtSa_JFilterSave_UID)=0 then
  begin
    bAddNew:=true;
    p_rJFilterSave.JFtSa_JFilterSave_UID:=saJAS_GetNextUID;
    bOk:=(u8Val(p_rJFilterSave.JFtSa_JFilterSave_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201204031953,'Problem getting an UID for new jfiltersave record.','saJAS_GetNextUID table: jfiltersave',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jfiltersave (JFtSa_JFilterSave_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJFilterSave.JFtSa_JFilterSave_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161915);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201204031954,'Problem creating a new jfiltersave record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJFilterSave.JFtSa_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJFilterSave.JFtSa_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJFilterSave.JFtSa_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJFilterSave.JFtSa_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJFilterSave.JFtSa_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJFilterSave.JFtSa_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jfiltersave', p_rJFilterSave.JFtSa_JFilterSave_UID, '0',201506200245);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201204031955,'Problem locking jfiltersave record.','p_rJFilterSave.JFtSa_JFilterSave_UID:'+p_rJFilterSave.JFtSa_JFilterSave_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJFilterSave do begin
      saQry:='UPDATE jfiltersave set '+
      ' JFtSa_JFilterSave_UID='      +JAS.saDBMSUintScrub(JFtSa_JFilterSave_UID    )+
      ',JFtSa_Name='                 +JAS.saDBMSScrub(JFtSa_Name               )+
      ',JFtSa_JBlok_ID='             +JAS.saDBMSUIntScrub(JFtSa_JBlok_ID           )+
      ',JFtSa_Public_b='             +JAS.saDBMSBoolScrub(JFtSa_Public_b           )+
      ',JFTSa_XML='                  +JAS.saDBMSScrub(JFTSa_XML                );
      if bAddNew then
      begin
        saQry+=
          ',JFtSa_CreatedBy_JUser_ID='   +JAS.saDBMSUintScrub(JFtSa_CreatedBy_JUser_ID )+
          ',JFtSa_Created_DT='           +JAS.saDBMSDateScrub(JFtSa_Created_DT         );
      end;
      saQry+=
        ',JFtSa_ModifiedBy_JUser_ID='  +JAS.saDBMSUIntScrub(JFtSa_ModifiedBy_JUser_ID)+
        ',JFtSa_Modified_DT='          +JAS.saDBMSDateScrub(JFtSa_Modified_DT        )+
        ',JFtSa_DeletedBy_JUser_ID='   +JAS.saDBMSUintScrub(JFtSa_DeletedBy_JUser_ID )+
        ',JFtSa_Deleted_DT='           +JAS.saDBMSDateScrub(JFtSa_Deleted_DT         )+
        ',JFtSa_Deleted_b='            +JAS.saDBMSBoolScrub(JFtSa_Deleted_b          )+
        ',JAS_Row_b='                  +JAS.saDBMSBoolScrub(JAS_Row_b                )+
        ' WHERE JFtSa_JFilterSave_UID='+JAS.saDBMSUIntScrub(JFtSa_JFilterSave_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161916);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201204031956,'Problem updating jfiltersave.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jfiltersave', p_rJFilterSave.JFtSa_JFilterSave_UID, '0',201506200402) then
      begin
        JAS_Log(p_Context,cnLog_Error,201204031957,'Problem unlocking jfiltersave record.','p_rJFilterSave.JFtSa_JFilterSave_UID:'+p_rJFilterSave.JFtSa_JFilterSave_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204031958,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
function bJAS_Load_jfiltersavedef(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFilterSaveDef: rtJFilterSaveDef; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jfiltersavedef'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204070030,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204070031, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jfiltersavedef where JFtSD_JFilterSaveDef_UID='+JAS.saDBMSUIntScrub(p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jfiltersavedef', p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID, '0',201506200250);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201204070032,'Problem locking jfiltersavedef record.','p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID:'+p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161917);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201204070033,'Unable to query jfiltersavedef successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201204031949,'Record missing from jfiltersavedef.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJFilterSaveDef do begin
        //JFtSD_JFilterSaveDef_UID       :=rs.Fields.Get_saValue('JFtSD_JFilterSaveDef_UID');
        JFtSD_JBlok_ID                 :=rs.Fields.Get_saValue('JFtSD_JBlok_ID');
        JFtSD_JFilterSave_ID           :=rs.Fields.Get_saValue('JFtSD_JFilterSave_ID');
        JFtSD_CreatedBy_JUser_ID       :=rs.Fields.Get_saValue('JFtSD_CreatedBy_JUser_ID');
        JFtSD_Created_DT               :=rs.Fields.Get_saValue('JFtSD_Created_DT');
        JFtSD_ModifiedBy_JUser_ID      :=rs.Fields.Get_saValue('JFtSD_ModifiedBy_JUser_ID');
        JFtSD_Modified_DT              :=rs.Fields.Get_saValue('JFtSD_Modified_DT');
        JFtSD_DeletedBy_JUser_ID       :=rs.Fields.Get_saValue('JFtSD_DeletedBy_JUser_ID');
        JFtSD_Deleted_DT               :=rs.Fields.Get_saValue('JFtSD_Deleted_DT');
        JFtSD_Deleted_b                :=rs.Fields.Get_saValue('JFtSD_Deleted_b');
        JAS_Row_b                      :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204070034,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jfiltersavedef(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJFilterSaveDef: rtJFilterSaveDef; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jfiltersavedef'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201204070035,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201204070036, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID)=0 then
  begin
    bAddNew:=true;
    p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID:=saJAS_GetNextUID;
    bOk:=(u8Val(p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201204070037,'Problem getting an UID for new jfiltersavedef record.','saJAS_GetNextUID table: jfiltersavedef',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jfiltersavedef (JFtSD_JFilterSaveDef_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161918);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201204070038,'Problem creating a new jfiltersavedef record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJFilterSaveDef.JFtSD_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJFilterSaveDef.JFtSD_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJFilterSaveDef.JFtSD_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJFilterSaveDef.JFtSD_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJFilterSaveDef.JFtSD_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJFilterSaveDef.JFtSD_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jfiltersavedef', p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID, '0',201506200251);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201204070039,'Problem locking jfiltersavedef record.','p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID:'+p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJFilterSaveDef do begin
      saQry:='UPDATE jfiltersavedef set '+
      ' JFtSD_JFilterSaveDef_UID='      +JAS.saDBMSUintScrub(JFtSD_JFilterSaveDef_UID    )+
      ',JFtSD_JBlok_ID='                +JAS.saDBMSUIntScrub(JFtSD_JBlok_ID           )+
      ',JFtSD_JFilterSave_ID='          +JAS.saDBMSUIntScrub(JFtSD_JFilterSave_ID);
      if bAddNew then
      begin
        saQry+=
          ',JFtSD_CreatedBy_JUser_ID='   +JAS.saDBMSUintScrub(JFtSD_CreatedBy_JUser_ID )+
          ',JFtSD_Created_DT='           +JAS.saDBMSDateScrub(JFtSD_Created_DT         );
      end;
      saQry+=
        ',JFtSD_ModifiedBy_JUser_ID='  +JAS.saDBMSUIntScrub(JFtSD_ModifiedBy_JUser_ID)+
        ',JFtSD_Modified_DT='          +JAS.saDBMSDateScrub(JFtSD_Modified_DT        )+
        ',JFtSD_DeletedBy_JUser_ID='   +JAS.saDBMSUintScrub(JFtSD_DeletedBy_JUser_ID )+
        ',JFtSD_Deleted_DT='           +JAS.saDBMSDateScrub(JFtSD_Deleted_DT         )+
        ',JFtSD_Deleted_b='            +JAS.saDBMSBoolScrub(JFtSD_Deleted_b          )+
        ',JAS_Row_b='                  +JAS.saDBMSBoolScrub(JAS_Row_b                )+
        ' WHERE JFtSD_JFilterSaveDef_UID='+JAS.saDBMSUIntScrub(JFtSD_JFilterSaveDef_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161919);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201204070040,'Problem updating jfiltersavedef.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jfiltersavedef', p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID, '0',201506200404) then
      begin
        JAS_Log(p_Context,cnLog_Error,201204070041,'Problem unlocking jfiltersavedef record.','p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID:'+p_rJFilterSaveDef.JFtSD_JFilterSaveDef_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201204070042,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
function bJAS_Load_jhelp(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJHelp: rtJHelp; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jhelp'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201212021517,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201212021518, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jhelp where Help_JHelp_UID='+JAS.saDBMSUIntScrub(p_rJHelp.Help_JHelp_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jhelp', p_rJHelp.Help_JHelp_UID, '0',201506200252);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201212021519,'Problem locking jhelp record.','p_rJHelp.Help_JHelp_UID:'+p_rJHelp.Help_JHelp_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161920);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201212021520,'Unable to query jhelp successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201212021521,'Record missing from jhelp.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJHelp do begin
        Help_JHelp_UID            := rs.fields.Get_saValue('Help_JHelp_UID');
        Help_VideoMP4_en          := rs.fields.Get_saValue('Help_VideoMP4_en');
        Help_HTML_en              := rs.fields.Get_saValue('Help_HTML_en');
        Help_HTML_Adv_en          := rs.fields.Get_saValue('Help_HTML_Adv_en'); 
        Help_Name                 := rs.fields.Get_saValue('Help_Name');
        Help_Poster               := rs.fields.Get_saValue('Help_Poster');
        Help_CreatedBy_JUser_ID   := rs.fields.Get_saValue('Help_CreatedBy_JUser_ID');
        Help_Created_DT           := rs.fields.Get_saValue('Help_Created_DT');
        Help_ModifiedBy_JUser_ID  := rs.fields.Get_saValue('Help_ModifiedBy_JUser_ID');
        Help_Modified_DT          := rs.fields.Get_saValue('Help_Modified_DT');
        Help_DeletedBy_JUser_ID   := rs.fields.Get_saValue('Help_DeletedBy_JUser_ID');
        Help_Deleted_DT           := rs.fields.Get_saValue('Help_Deleted_DT');
        Help_Deleted_b            := rs.fields.Get_saValue('Help_Deleted_b');
        JAS_Row_b                 := rs.fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201212021522,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jhelp(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJHelp: rtJHelp; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jhelp'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201212021523,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201212021524, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJHelp.Help_JHelp_UID)=0 then
  begin
    bAddNew:=true;
    p_rJHelp.Help_JHelp_UID:=saJAS_GetNextUID;
    bOk:=(u8Val(p_rJHelp.Help_JHelp_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201212021525,'Problem getting an UID for new jhelp record.','saJAS_GetNextUID table: jhelp',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jhelp (Help_JHelp_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJHelp.Help_JHelp_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161921);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201212021526,'Problem creating a new jhelp record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJHelp.Help_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJHelp.Help_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJHelp.Help_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJHelp.Help_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJHelp.Help_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJHelp.Help_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jhelp', p_rJHelp.Help_JHelp_UID, '0',201506200253);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201212021527,'Problem locking jhelp record.','p_rJHelp.Help_JHelp_UID:'+p_rJHelp.Help_JHelp_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJHelp do begin
      saQry:='UPDATE jhelp set '+
        ' Help_JHelp_UID            =' + JAS.saDBMSScrub(Help_JHelp_UID)+
        ',Help_VideoMP4_en          =' + JAS.saDBMSScrub(Help_VideoMP4_en)+
        ',Help_HTML_en              =' + JAS.saDBMSScrub(Help_HTML_en)+
        ',Help_HTML_Adv_en          =' + JAS.saDBMSScrub(Help_HTML_ADV_en)+
        ',Help_Name                 =' + JAS.saDBMSScrub(Help_Name)+
        ',Help_Poster               =' + JAS.saDBMSScrub(Help_Poster);
      if bAddNew then
      begin
        saQry+=
          ',Help_CreatedBy_JUser_ID   =' + JAS.saDBMSScrub(Help_CreatedBy_JUser_ID)+
          ',Help_Created_DT           =' + JAS.saDBMSScrub(Help_Created_DT);
      end;
      saQry+=
        ',Help_ModifiedBy_JUser_ID  =' + JAS.saDBMSScrub(Help_ModifiedBy_JUser_ID)+
        ',Help_Modified_DT          =' + JAS.saDBMSScrub(Help_Modified_DT)+
        ',Help_DeletedBy_JUser_ID   =' + JAS.saDBMSScrub(Help_DeletedBy_JUser_ID)+
        ',Help_Deleted_DT           =' + JAS.saDBMSScrub(Help_Deleted_DT)+
        ',Help_Deleted_b            =' + JAS.saDBMSScrub(Help_Deleted_b)+
        ',JAS_Row_b                 =' + JAS.saDBMSScrub(JAS_Row_b)+
        ' WHERE Help_JHelp_UID='+JAS.saDBMSUIntScrub(Help_JHelp_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161922);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201212021528,'Problem updating jhelp.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jhelp', p_rJHelp.Help_JHelp_UID, '0',201506200405) then
      begin
        JAS_Log(p_Context,cnLog_Error,201212021529,'Problem unlocking jhelp record.','p_rJHelp.Help_JHelp_UID:'+p_rJHelp.Help_JHelp_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201212021530,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









//=============================================================================
//function bJAS_Load_jindexfile(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIndexfile: rtJIndexfile; p_bGetLock: boolean): boolean;
function bJAS_Load_jindexfile(p_DBC: JADO_CONNECTION; var p_rJIndexfile: rtJIndexfile): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jindexfile'; sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210080427,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
//{IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210080428, sTHIS_ROUTINE_NAME);{ENDIF}
  //JAS:=p_DBC;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jindexfile where JIDX_JIndexFile_UID='+JAS.saDBMSUIntScrub(p_rJIndexFile.JIDX_JIndexFile_UID);
  bOk:=true;
  //if p_bGetLock then
  //begin
  //  bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jindexfile', p_rJIndexFile.JIDX_JIndexFile_UID, '0',201506200254);
  //  if not bOK then
  //  begin
  //    JAS_Log(p_Context,cnLog_Error,201210080429,'Problem locking jindexfile record.','p_rJIndexFile.JIDX_JIndexFile_UID:'+p_rJIndexFile.JIDX_JIndexFile_UID,SOURCEFILE);
  //  end;
  //end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161923);
    if not bOk then
    begin
      JLog(cnLog_Error,201210080430,'Unable to query jindexfile successfully Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151810,'Record missing from jindexfile.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJIndexfile do begin
        JIDX_JIndexFile_UID        := rs.Fields.Get_saValue('JIDX_JIndexFile_UID');
        JIDX_JVHost_ID             := rs.Fields.Get_saValue('JIDX_JVHost_ID');
        JIDX_Filename              := rs.Fields.Get_saValue('JIDX_Filename');
        JIDX_Order_u               := rs.fields.Get_savalue('JIDX_Order_u');
        JIDX_CreatedBy_JUser_ID    := rs.Fields.Get_saValue('JIDX_CreatedBy_JUser_ID');
        JIDX_Created_DT            := rs.Fields.Get_saValue('JIDX_Created_DT');
        JIDX_ModifiedBy_JUser_ID   := rs.Fields.Get_saValue('JIDX_ModifiedBy_JUser_ID');
        JIDX_Modified_DT           := rs.Fields.Get_saValue('JIDX_Modified_DT');
        JIDX_DeletedBy_JUser_ID    := rs.Fields.Get_saValue('JIDX_DeletedBy_JUser_ID');
        JIDX_Deleted_DT            := rs.Fields.Get_saValue('JIDX_Deleted_DT');
        JIDX_Deleted_b             := rs.Fields.Get_saValue('JIDX_Deleted_b');
        JAS_Row_b                  := rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210080431,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jindexfile(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIndexfile: rtJIndexfile; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jindexfile'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210080432,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210080433, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJIndexFile.JIDX_JIndexFile_UID)=0 then
  begin
    bAddNew:=true;
    p_rJIndexFile.JIDX_JIndexFile_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jindexfile');
    bOk:=(u8Val(p_rJIndexFile.JIDX_JIndexFile_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080434,'Problem getting an UID for new jindexfile record.','saJAS_GetNextUID table: jindexfile',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jindexfile (JIDX_JIndexFile_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJIndexFile.JIDX_JIndexFile_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161924);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201210080435,'Problem creating a new jindexfile record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJIndexfile.JIDX_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJIndexfile.JIDX_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJIndexfile.JIDX_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJIndexfile.JIDX_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJIndexfile.JIDX_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJIndexfile.JIDX_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jindexfile', p_rJIndexFile.JIDX_JIndexFile_UID, '0',201506200255);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080436,'Problem locking jindexfile record.','p_rJIndexFile.JIDX_JIndexFile_UID:'+p_rJIndexFile.JIDX_JIndexFile_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJIndexFile do begin
      saQry:='UPDATE jindexfile set '+
        ' JIDX_JIndexFile_UID='+JAS.saDBMSUIntScrub(JIDX_JIndexFile_UID)+
        ',JIDX_JVHost_ID='+JAS.saDBMSUIntScrub(JIDX_JVHost_ID)+
        ',JIDX_Filename='+JAS.saDBMSScrub(JIDX_Filename)+
        ',JIDX_Order_u='+JAS.saDBMSUIntScrub(JIDX_Order_u);
        if bAddNew then
        begin
          saQry+=
            ',JIDX_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIDX_CreatedBy_JUser_ID)+
            ',JIDX_Created_DT='+JAS.saDBMSDateScrub(JIDX_Created_DT);
        end;
        saQry+=
          ',JIDX_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIDX_ModifiedBy_JUser_ID)+
          ',JIDX_Modified_DT='+JAS.saDBMSUIntScrub(JIDX_Modified_DT)+
          ',JIDX_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIDX_DeletedBy_JUser_ID)+
          ',JIDX_Deleted_DT='+JAS.saDBMSDateScrub(JIDX_Deleted_DT)+
          ',JIDX_Deleted_b='+JAS.saDBMSBoolScrub(JIDX_Deleted_b)+
          ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
          ' WHERE JIDX_JIndexFile_UID='+JAS.saDBMSUIntScrub(JIDX_JIndexFile_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161924);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080437,'Problem updating jindustry.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jindexfile', p_rJIndexFile.JIDX_JIndexFile_UID, '0',201506200406) then
      begin
        JAS_Log(p_Context,cnLog_Error,201210080438,'Problem unlocking jindustry record.','p_rJIndexFile.JIDX_JIndexFile_UID:'+p_rJIndexFile.JIDX_JIndexFile_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210080439,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
function bJAS_Load_jindustry(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIndustry: rtJIndustry; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jindustry'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113162,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113163, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jindustry where JIndu_JIndustry_UID='+JAS.saDBMSUIntScrub(p_rJIndustry.JIndu_JIndustry_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jindustry', p_rJIndustry.JIndu_JIndustry_UID, '0',201506200256);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100719,'Problem locking jindustry record.','p_rJIndustry.JIndu_JIndustry_UID:'+p_rJIndustry.JIndu_JIndustry_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161925);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151809,'Unable to query jindustry successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151810,'Record missing from jindustry.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJIndustry do begin
        //JIndu_JIndustry_UID:=rs.Fields.Get_saValue('');
        JIndu_Name:=rs.Fields.Get_saValue('JIndu_Name');
        JIndu_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JIndu_CreatedBy_JUser_ID');
        JIndu_Created_DT                 :=rs.Fields.Get_saValue('JIndu_Created_DT');
        JIndu_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JIndu_ModifiedBy_JUser_ID');
        JIndu_Modified_DT                :=rs.Fields.Get_saValue('JIndu_Modified_DT');
        JIndu_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JIndu_DeletedBy_JUser_ID');
        JIndu_Deleted_DT                 :=rs.Fields.Get_saValue('JIndu_Deleted_DT');
        JIndu_Deleted_b                  :=rs.Fields.Get_saValue('JIndu_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113164,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jindustry(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIndustry: rtJIndustry; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jindustry'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113165,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113166, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJIndustry.JIndu_JIndustry_UID)=0 then
  begin
    bAddNew:=true;
    p_rJIndustry.JIndu_JIndustry_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jindustry');
    bOk:=(u8Val(p_rJIndustry.JIndu_JIndustry_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151811,'Problem getting an UID for new jindustry record.','saJAS_GetNextUID table: jindustry',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jindustry (p_rJIndustry.JIndu_JIndustry_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJIndustry.JIndu_JIndustry_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161926);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151812,'Problem creating a new jindustry record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJIndustry.JIndu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJIndustry.JIndu_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJIndustry.JIndu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJIndustry.JIndu_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJIndustry.JIndu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJIndustry.JIndu_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jindustry', p_rJIndustry.JIndu_JIndustry_UID, '0',201506200257);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151813,'Problem locking jindustry record.','p_rJIndustry.JIndu_JIndustry_UID:'+p_rJIndustry.JIndu_JIndustry_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJIndustry do begin
      saQry:='UPDATE jindustry set '+
        //' JIndu_JIndustry_UID='+JAS.saDBMSScrub()+
        'JIndu_Name='+JAS.saDBMSScrub(JIndu_Name);
        if(bAddNew)then
        begin
          saQry+=',JIndu_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIndu_CreatedBy_JUser_ID)+
          ',JIndu_Created_DT='+JAS.saDBMSDateScrub(JIndu_Created_DT);
        end;
        saQry+=
        ',JIndu_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIndu_ModifiedBy_JUser_ID)+
        ',JIndu_Modified_DT='+JAS.saDBMSDateScrub(JIndu_Modified_DT)+
        ',JIndu_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIndu_DeletedBy_JUser_ID)+
        ',JIndu_Deleted_DT='+JAS.saDBMSDateScrub(JIndu_Deleted_DT)+
        ',JIndu_Deleted_b='+JAS.saDBMSBoolScrub(JIndu_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JIndu_JIndustry_UID='+JAS.saDBMSUIntScrub(JIndu_JIndustry_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161927);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151814,'Problem updating jindustry.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jindustry', p_rJIndustry.JIndu_JIndustry_UID, '0',201506200407) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151815,'Problem unlocking jindustry record.','p_rJIndustry.JIndu_JIndustry_UID:'+p_rJIndustry.JIndu_JIndustry_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113167,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
function bJAS_Load_jinstalled(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInstalled: rtJInstalled; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jinstalled'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113168,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113169, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jinstalled where JInst_JInstalled_UID='+JAS.saDBMSUIntScrub(p_rJInstalled.JInst_JInstalled_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jinstalled', p_rJInstalled.JInst_JInstalled_UID, '0',201506200258);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100720,'Problem locking jinstalled record.','p_rJInstalled.JInst_JInstalled_UID:'+p_rJInstalled.JInst_JInstalled_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161928);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151816,'Unable to query jinstalled successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151817,'Record missing from jinstalled.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJInstalled do begin
        //JInst_JInstalled_UID
        JInst_JModule_ID:=rs.Fields.Get_saValue('JInst_JModule_ID');
        JInst_Enabled_b:=rs.Fields.Get_saValue('JInst_Enabled_b');
        JInst_Name:=rs.Fields.Get_saValue('JInst_Name');
        JInst_Desc:=rs.Fields.Get_saValue('JInst_Desc');
        JInst_JNote_ID:=rs.Fields.Get_saValue('JInst_JNote_ID');
        JInst_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JInst_CreatedBy_JUser_ID');
        JInst_Created_DT                 :=rs.Fields.Get_saValue('JInst_Created_DT');
        JInst_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JInst_ModifiedBy_JUser_ID');
        JInst_Modified_DT                :=rs.Fields.Get_saValue('JInst_Modified_DT');
        JInst_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JInst_DeletedBy_JUser_ID');
        JInst_Deleted_DT                 :=rs.Fields.Get_saValue('JInst_Deleted_DT');
        JInst_Deleted_b                  :=rs.Fields.Get_saValue('JInst_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113170,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jinstalled(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInstalled: rtJInstalled; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jinstalled'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113171,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113172, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJInstalled.JInst_JInstalled_UID)=0 then
  begin
    bAddNew:=true;
    p_rJInstalled.JInst_JInstalled_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jinstalled');
    bOk:=(u8Val(p_rJInstalled.JInst_JInstalled_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151818,'Problem getting an UID for new jinstalled record.','saJAS_GetNextUID table: jinstalled',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jinstalled (JInst_JInstalled_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJInstalled.JInst_JInstalled_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161929);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151819,'Problem creating a new jinstalled record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJInstalled.JInst_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJInstalled.JInst_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJInstalled.JInst_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJInstalled.JInst_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJInstalled.JInst_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJInstalled.JInst_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jinstalled', p_rJInstalled.JInst_JInstalled_UID, '0',201506200259);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151820,'Problem locking jinstalled record.','p_rJInstalled.JInst_JInstalled_UID:'+p_rJInstalled.JInst_JInstalled_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJInstalled do begin
      saQry:='UPDATE jinstalled set '+
        //' JInst_JInstalled_UID='+JAS.saDBMSScrub()+
        'JInst_JModule_ID='+JAS.saDBMSUIntScrub(JInst_JModule_ID)+
        ',JInst_Enabled_b='+JAS.saDBMSBoolScrub(JInst_Enabled_b)+
        ',JInst_Name='+JAS.saDBMSScrub(JInst_Name)+
        ',JInst_Desc='+JAS.saDBMSScrub(JInst_Desc)+
        ',JInst_JNote_ID='+JAS.saDBMSUIntScrub(JInst_JNote_ID);
        if(bAddNew)then
        begin
          saQry+=',JInst_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JInst_CreatedBy_JUser_ID)+
          ',JInst_Created_DT='+JAS.saDBMSDateScrub(JInst_Created_DT);
        end;
        saQry+=
        ',JInst_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JInst_ModifiedBy_JUser_ID)+
        ',JInst_Modified_DT='+JAS.saDBMSDateScrub(JInst_Modified_DT)+
        ',JInst_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JInst_DeletedBy_JUser_ID)+
        ',JInst_Deleted_DT='+JAS.saDBMSDateScrub(JInst_Deleted_DT)+
        ',JInst_Deleted_b='+JAS.saDBMSBoolScrub(JInst_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JInst_JInstalled_UID='+JAS.saDBMSScrub(JInst_JInstalled_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161930);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151821,'Problem updating jinstalled.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jinstalled', p_rJInstalled.JInst_JInstalled_UID, '0',201506200408) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151822,'Problem unlocking jinstalled record.','p_rJInstalled.JInst_JInstalled_UID:'+p_rJInstalled.JInst_JInstalled_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113173,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jinterface(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInterface: rtJInterface; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jinterface'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113174,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113175, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jinterface where JIntF_JInterface_UID='+JAS.saDBMSUIntScrub(p_rJInterface.JIntF_JInterface_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jinterface', p_rJInterface.JIntF_JInterface_UID, '0',201506200260);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100722,'Problem locking jinterface record.','p_rJInterface.JIntF_JInterface_UID:'+p_rJInterface.JIntF_JInterface_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161931);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230023,'Unable to query jinterface successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002230024,'Record missing from jinterface.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJInterface do begin
        //JIntF_JInterface_UID:=rs.Fields.Get_saValue('');
        JIntF_Name:=rs.Fields.Get_saValue('JIntF_Name');
        JIntF_Desc:=rs.Fields.Get_saValue('JIntF_Desc');
        JIntF_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JIntF_CreatedBy_JUser_ID');
        JIntF_Created_DT                 :=rs.Fields.Get_saValue('JIntF_Created_DT');
        JIntF_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JIntF_ModifiedBy_JUser_ID');
        JIntF_Modified_DT                :=rs.Fields.Get_saValue('JIntF_Modified_DT');
        JIntF_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JIntF_DeletedBy_JUser_ID');
        JIntF_Deleted_DT                 :=rs.Fields.Get_saValue('JIntF_Deleted_DT');
        JIntF_Deleted_b                  :=rs.Fields.Get_saValue('JIntF_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113176,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jinterface(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInterface: rtJInterface; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jinterface'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113177,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113178, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJInterface.JIntF_JInterface_UID)=0 then
  begin
    bAddNew:=true;
    p_rJInterface.JIntF_JInterface_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jinterface');
    bOk:=(u8Val(p_rJInterface.JIntF_JInterface_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230025,'Problem getting an UID for new jinterface record.','saJAS_GetNextUID table: jinterface',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jinterface (JIntF_JInterface_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJInterface.JIntF_JInterface_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161932);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002230026,'Problem creating a new jinterface record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJInterface.JIntF_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJInterface.JIntF_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJInterface.JIntF_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJInterface.JIntF_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJInterface.JIntF_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJInterface.JIntF_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jinterface', p_rJInterface.JIntF_JInterface_UID, '0',201506200261);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230027,'Problem locking jinterface record.','p_rJInterface.JIntF_JInterface_UID:'+p_rJInterface.JIntF_JInterface_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJInterface do begin
      saQry:='UPDATE jinterface set '+
        //' JIntF_JInterface_UID='+JAS.saDBMSScrub()+
        'JIntF_Name='+JAS.saDBMSScrub(JIntF_Name)+
        ',JIntF_Desc='+JAS.saDBMSScrub(JIntF_Desc);
        if(bAddNew)then
        begin
          saQry+=',JIntF_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIntF_CreatedBy_JUser_ID)+
          ',JIntF_Created_DT='+JAS.saDBMSDateScrub(JIntF_Created_DT);
        end;
        saQry+=
        ',JIntF_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIntF_ModifiedBy_JUser_ID)+
        ',JIntF_Modified_DT='+JAS.saDBMSDateScrub(JIntF_Modified_DT)+
        ',JIntF_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIntF_DeletedBy_JUser_ID)+
        ',JIntF_Deleted_DT='+JAS.saDBMSDateScrub(JIntF_Deleted_DT)+
        ',JIntF_Deleted_b='+JAS.saDBMSBoolScrub(JIntF_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JIntF_JInterface_UID='+JAS.saDBMSUIntScrub(JIntF_JInterface_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161933);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230028,'Problem updating jinterface.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jinterface', p_rJInterface.JIntF_JInterface_UID, '0',201506200409) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002230029,'Problem unlocking jinterface record.','p_rJInterface.JIntF_JInterface_UID:'+p_rJInterface.JIntF_JInterface_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113179,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================










//=============================================================================
function bJAS_Load_jinvoice(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInvoice: rtJInvoice; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jinvoice'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113180,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113181, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jinvoice where JIHdr_JInvoice_UID='+JAS.saDBMSUINtScrub(p_rJInvoice.JIHdr_JInvoice_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jinvoice', p_rJInvoice.JIHdr_JInvoice_UID, '0',201506200262);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100723,'Problem locking jinvoice record.','p_rJInvoice.JIHdr_JInvoice_UID:'+p_rJInvoice.JIHdr_JInvoice_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161934);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151823,'Unable to query jinvoice successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151824,'Record missing from jinvoice.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJInvoice do begin
        //JIHdr_JInvoice_UID         :=rs.Fields.Get_saValue('JIHdr_JInvoice_UID');
        JIHdr_DateInv_DT           :=rs.Fields.Get_saValue('JIHdr_DateInv_DT');
        JIHdr_DateShip_DT          :=rs.Fields.Get_saValue('JIHdr_DateShip_DT');
        JIHdr_DateOrd_DT           :=rs.Fields.Get_saValue('JIHdr_DateOrd_DT');
        JIHdr_POCust               :=rs.Fields.Get_saValue('JIHdr_POCust');
        JIHdr_POInternal           :=rs.Fields.Get_saValue('JIHdr_POInternal');
        JIHdr_ShipVia              :=rs.Fields.Get_saValue('JIHdr_ShipVia');
        JIHdr_Note01               :=rs.Fields.Get_saValue('JIHdr_Note01');
        JIHdr_Note02               :=rs.Fields.Get_saValue('JIHdr_Note02');
        JIHdr_Note03               :=rs.Fields.Get_saValue('JIHdr_Note03');
        JIHdr_Note04               :=rs.Fields.Get_saValue('JIHdr_Note04');
        JIHdr_Note05               :=rs.Fields.Get_saValue('JIHdr_Note05');
        JIHdr_Note06               :=rs.Fields.Get_saValue('JIHdr_Note06');
        JIHdr_Terms01              :=rs.Fields.Get_saValue('JIHdr_Terms01');
        JIHdr_Terms02              :=rs.Fields.Get_saValue('JIHdr_Terms02');
        JIHdr_Terms03              :=rs.Fields.Get_saValue('JIHdr_Terms03');
        JIHdr_Terms04              :=rs.Fields.Get_saValue('JIHdr_Terms04');
        JIHdr_Terms05              :=rs.Fields.Get_saValue('JIHdr_Terms05');
        JIHdr_Terms06              :=rs.Fields.Get_saValue('JIHdr_Terms06');
        JIHdr_Terms07              :=rs.Fields.Get_saValue('JIHdr_Terms07');
        JIHdr_SalesAmt_d           :=rs.Fields.Get_saValue('JIHdr_SalesAmt');
        JIHdr_MiscAmt_d            :=rs.Fields.Get_saValue('JIHdr_MiscAmt_d');
        JIHdr_SalesTaxAmt_d        :=rs.Fields.Get_saValue('JIHdr_SalesTaxAmt_d');
        JIHdr_ShipAmt_d            :=rs.Fields.Get_saValue('JIHdr_ShipAmt_d');
        JIHdr_TotalAmt_d           :=rs.Fields.Get_saValue('JIHdr_TotalAmt_d');
        JIHdr_BillToAddr01         :=rs.Fields.Get_saValue('JIHdr_BillToAddr01');
        JIHdr_BillToAddr02         :=rs.Fields.Get_saValue('JIHdr_BillToAddr02');
        JIHdr_BillToAddr03         :=rs.Fields.Get_saValue('JIHdr_BillToAddr03');
        JIHdr_BillToCity           :=rs.Fields.Get_saValue('JIHdr_BillToCity');
        JIHdr_BillToState          :=rs.Fields.Get_saValue('JIHdr_BillToState');
        JIHdr_BillToPostalCode     :=rs.Fields.Get_saValue('JIHdr_BillToPostalCode');
        JIHdr_ShipToAddr01         :=rs.Fields.Get_saValue('JIHdr_ShipToAddr01');
        JIHdr_ShipToAddr02         :=rs.Fields.Get_saValue('JIHdr_ShipToAddr02');
        JIHdr_ShipToAddr03         :=rs.Fields.Get_saValue('JIHdr_ShipToAddr03');
        JIHdr_ShipToCity           :=rs.Fields.Get_saValue('JIHdr_ShipToCity');
        JIHdr_ShipToState          :=rs.Fields.Get_saValue('JIHdr_ShipToState');
        JIHdr_ShipToPostalCode     :=rs.Fields.Get_saValue('JIHdr_ShipToPostalCode');
        JIHDr_JCompany_ID          :=rs.Fields.Get_saValue('JIHDr_JCompany_ID');
        JIHDr_JPerson_ID           :=rs.Fields.Get_saValue('JIHDr_JPerson_ID');
        JIHdr_CreatedBy_JUser_ID   :=rs.Fields.Get_saValue('JIHdr_CreatedBy_JUser_ID');
        JIHdr_Created_DT           :=rs.Fields.Get_saValue('JIHdr_Created_DT');
        JIHdr_ModifiedBy_JUser_ID  :=rs.Fields.Get_saValue('JIHdr_ModifiedBy_JUser_ID');
        JIHdr_Modified_DT          :=rs.Fields.Get_saValue('JIHdr_Modified_DT');
        JIHdr_DeletedBy_JUser_ID   :=rs.Fields.Get_saValue('JIHdr_DeletedBy_JUser_ID');
        JIHdr_Deleted_DT           :=rs.Fields.Get_saValue('JIHdr_Deleted_DT');
        JIHdr_Deleted_b            :=rs.Fields.Get_saValue('JIHdr_Deleted_b');
        JAS_Row_b                  :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113182,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jinvoice(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInvoice: rtJInvoice; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jinvoice'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113183,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113184, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJInvoice.JIHdr_JInvoice_UID)=0 then
  begin
    bAddNew:=true;
    p_rJInvoice.JIHdr_JInvoice_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jinvoice');
    bOk:=(u8Val(p_rJInvoice.JIHdr_JInvoice_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151825,'Problem getting an UID for new jinvoice record.','saJAS_GetNextUID table: jinvoice',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jinvoice (JIHdr_JInvoice_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJInvoice.JIHdr_JInvoice_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161935);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151826,'Problem creating a new jinvoice record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJInvoice.JIHdr_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJInvoice.JIHdr_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJInvoice.JIHdr_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJInvoice.JIHdr_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJInvoice.JIHdr_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJInvoice.JIHdr_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jinvoice', p_rJInvoice.JIHdr_JInvoice_UID, '0',201506200263);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151827,'Problem locking jinvoice record.','p_rJInvoice.JIHdr_JInvoice_UID:'+p_rJInvoice.JIHdr_JInvoice_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJInvoice do begin
      saQry:='UPDATE jinvoice set '+
        //' JIHdr_JInvoice_UID='+JAS.saDBMSScrub(JIHdr_JInvoice_UID)+
        'JIHdr_DateInv_DT='+JAS.saDBMSDateScrub(JIHdr_DateInv_DT)+
        ',JIHdr_DateShip_DT='+JAS.saDBMSDateScrub(JIHdr_DateShip_DT)+
        ',JIHdr_DateOrd_DT='+JAS.saDBMSDateScrub(JIHdr_DateOrd_DT)+
        ',JIHdr_POCust='+JAS.saDBMSScrub(JIHdr_POCust)+
        ',JIHdr_POInternal='+JAS.saDBMSScrub(JIHdr_POInternal)+
        ',JIHdr_ShipVia='+JAS.saDBMSScrub(JIHdr_ShipVia)+
        ',JIHdr_Note01='+JAS.saDBMSScrub(JIHdr_Note01)+
        ',JIHdr_Note02='+JAS.saDBMSScrub(JIHdr_Note02)+
        ',JIHdr_Note03='+JAS.saDBMSScrub(JIHdr_Note03)+
        ',JIHdr_Note04='+JAS.saDBMSScrub(JIHdr_Note04)+
        ',JIHdr_Note05='+JAS.saDBMSScrub(JIHdr_Note05)+
        ',JIHdr_Note06='+JAS.saDBMSScrub(JIHdr_Note06)+
        ',JIHdr_Terms01='+JAS.saDBMSScrub(JIHdr_Terms01)+
        ',JIHdr_Terms02='+JAS.saDBMSScrub(JIHdr_Terms02)+
        ',JIHdr_Terms03='+JAS.saDBMSScrub(JIHdr_Terms03)+
        ',JIHdr_Terms04='+JAS.saDBMSScrub(JIHdr_Terms04)+
        ',JIHdr_Terms05='+JAS.saDBMSScrub(JIHdr_Terms05)+
        ',JIHdr_Terms06='+JAS.saDBMSScrub(JIHdr_Terms06)+
        ',JIHdr_Terms07='+JAS.saDBMSScrub(JIHdr_Terms07)+
        ',JIHdr_SalesAmt_d='+JAS.saDBMSDecScrub(JIHdr_SalesAmt_d)+
        ',JIHdr_MiscAmt_d='+JAS.saDBMSDecScrub(JIHdr_MiscAmt_d)+
        ',JIHdr_SalesTaxAmt_d='+JAS.saDBMSDecScrub(JIHdr_SalesTaxAmt_d)+
        ',JIHdr_ShipAmt_d='+JAS.saDBMSDecScrub(JIHdr_ShipAmt_d)+
        ',JIHdr_TotalAmt_d='+JAS.saDBMSDecScrub(JIHdr_TotalAmt_d)+
        ',JIHdr_BillToAddr01='+JAS.saDBMSScrub(JIHdr_BillToAddr01)+
        ',JIHdr_BillToAddr02='+JAS.saDBMSScrub(JIHdr_BillToAddr02)+
        ',JIHdr_BillToAddr03='+JAS.saDBMSScrub(JIHdr_BillToAddr03)+
        ',JIHdr_BillToCity='+JAS.saDBMSScrub(JIHdr_BillToCity)+
        ',JIHdr_BillToState='+JAS.saDBMSScrub(JIHdr_BillToState)+
        ',JIHdr_BillToPostalCode='+JAS.saDBMSScrub(JIHdr_BillToPostalCode)+
        ',JIHdr_ShipToAddr01='+JAS.saDBMSScrub(JIHdr_ShipToAddr01)+
        ',JIHdr_ShipToAddr02='+JAS.saDBMSScrub(JIHdr_ShipToAddr02)+
        ',JIHdr_ShipToAddr03='+JAS.saDBMSScrub(JIHdr_ShipToAddr03)+
        ',JIHdr_ShipToCity='+JAS.saDBMSScrub(JIHdr_ShipToCity)+
        ',JIHdr_ShipToState='+JAS.saDBMSScrub(JIHdr_ShipToState)+
        ',JIHdr_ShipToPostalCode='+JAS.saDBMSScrub(JIHdr_ShipToPostalCode)+
        ',JIHDr_JCompany_ID='+JAS.saDBMSUIntScrub(JIHDr_JCompany_ID)+
        ',JIHDr_JPerson_ID='+JAS.saDBMSUIntScrub(JIHDr_JPerson_ID);
        if(bAddNew)then
        begin
          saQry+=',JIHdr_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIHdr_CreatedBy_JUser_ID)+
          ',JIHdr_Created_DT='+JAS.saDBMSDateScrub(JIHdr_Created_DT);
        end;
        saQry+=
        ',JIHdr_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIHdr_ModifiedBy_JUser_ID)+
        ',JIHdr_Modified_DT='+JAS.saDBMSDateScrub(JIHdr_Modified_DT)+
        ',JIHdr_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JIHdr_DeletedBy_JUser_ID)+
        ',JIHdr_Deleted_DT='+JAS.saDBMSDateScrub(JIHdr_Deleted_DT)+
        ',JIHdr_Deleted_b='+JAS.saDBMSBoolScrub(JIHdr_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JIHdr_JInvoice_UID='+JAS.saDBMSUIntScrub(JIHdr_JInvoice_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161936);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151828,'Problem updating jinvoice.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jinvoice', p_rJInvoice.JIHdr_JInvoice_UID, '0',201506200410) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151829,'Problem unlocking jinvoice record.','p_rJInvoice.JIHdr_JInvoice_UID:'+p_rJInvoice.JIHdr_JInvoice_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113185,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jinvoicelines(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInvoiceLines: rtJInvoiceLines; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jinvoicelines'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113186,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113187, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jinvoicelines where JILin_JInvoiceLines_UID='+JAS.saDBMSUIntScrub(p_rJInvoiceLines.JILin_JInvoiceLines_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jinvoicelines', p_rJInvoiceLines.JILin_JInvoiceLines_UID, '0',201506200264);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100724,'Problem locking jinvoicelines record.','p_rJInvoiceLines.JILin_JInvoiceLines_UID:'+p_rJInvoiceLines.JILin_JInvoiceLines_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161937);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151830,'Unable to query jinvoicelines successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151831,'Record missing from jinvoicelines.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJInvoiceLines do begin
        //JILin_JInvoiceLines_UID    :=rs.Fields.Get_saValue('JILin_JInvoiceLines_UID');
        JILin_JInvoice_ID          :=rs.Fields.Get_saValue('JILin_JInvoice_ID');
        JILin_ProdNoInternal       :=rs.Fields.Get_saValue('JILin_ProdNoInternal');
        JILin_ProdNoCust           :=rs.Fields.Get_saValue('JILin_ProdNoCust');
        JILin_JProduct_ID          :=rs.Fields.Get_saValue('JILin_JProduct_ID');
        JILin_QtyOrd_d             :=rs.Fields.Get_saValue('JILin_QtyOrd_d');
        JILin_DescA                :=rs.Fields.Get_saValue('JILin_DescA');
        JILin_DescB                :=rs.Fields.Get_saValue('JILin_DescB');
        JILin_QtyShip_d            :=rs.Fields.Get_saValue('JILin_QtyShip_d');
        JILin_PrcUnit_d             :=rs.Fields.Get_saValue('JILin_PrcUnit_d');
        JILin_PrcExt_d               :=rs.Fields.Get_saValue('JILin_PrcExt_d');
        JILin_SEQ_u                  :=rs.Fields.Get_saValue('JILin_SEQ_u');
        JILin_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JILin_CreatedBy_JUser_ID');
        JILin_Created_DT                 :=rs.Fields.Get_saValue('JILin_Created_DT');
        JILin_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JILin_ModifiedBy_JUser_ID');
        JILin_Modified_DT                :=rs.Fields.Get_saValue('JILin_Modified_DT');
        JILin_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JILin_DeletedBy_JUser_ID');
        JILin_Deleted_DT                 :=rs.Fields.Get_saValue('JILin_Deleted_DT');
        JILin_Deleted_b                  :=rs.Fields.Get_saValue('JILin_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113188,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jinvoicelines(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJInvoiceLines: rtJInvoiceLines; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jinvoicelines'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113189,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113190, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJInvoiceLines.JILin_JInvoiceLines_UID)=0 then
  begin
    bAddNew:=true;
    p_rJInvoiceLines.JILin_JInvoiceLines_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jinvoicelines');
    bOk:=(u8Val(p_rJInvoiceLines.JILin_JInvoiceLines_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151832,'Problem getting an UID for new jinvoicelines record.','saJAS_GetNextUID table: jinvoicelines',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jinvoicelines (JILin_JInvoiceLines_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJInvoiceLines.JILin_JInvoiceLines_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161938);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151833,'Problem creating a new jinvoicelines record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJInvoiceLines.JILin_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJInvoiceLines.JILin_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJInvoiceLines.JILin_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJInvoiceLines.JILin_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJInvoiceLines.JILin_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJInvoiceLines.JILin_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jinvoicelines', p_rJInvoiceLines.JILin_JInvoiceLines_UID, '0',201506200265);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151834,'Problem locking jinvoicelines record.','p_rJInvoiceLines.JILin_JInvoiceLines_UID:'+p_rJInvoiceLines.JILin_JInvoiceLines_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJInvoiceLines do begin
      saQry:='UPDATE jinvoicelines set '+
        //' JILin_JInvoiceLines_UID    : ansistring;
        'JILin_JInvoice_ID='+JAS.saDBMSUIntScrub(JILin_JInvoice_ID)+
        ',JILin_ProdNoInternal='+JAS.saDBMSScrub(JILin_ProdNoInternal)+
        ',JILin_ProdNoCust='+JAS.saDBMSScrub(JILin_ProdNoCust)+
        ',JILin_JProduct_ID='+JAS.saDBMSUIntScrub(JILin_JProduct_ID)+
        ',JILin_QtyOrd_d='+JAS.saDBMSDecScrub(JILin_QtyOrd_d)+
        ',JILin_DescA='+JAS.saDBMSScrub(JILin_DescA)+
        ',JILin_DescB='+JAS.saDBMSScrub(JILin_DescB)+
        ',JILin_QtyShip_d='+JAS.saDBMSDecScrub(JILin_QtyShip_d)+
        ',JILin_PrcUnit_d='+JAS.saDBMSDecScrub(JILin_PrcUnit_d)+
        ',JILin_PrcExt_d='+JAS.saDBMSDecScrub(JILin_PrcExt_d)+
        ',JILin_SEQ_u='+JAS.saDBMSUIntScrub(JILin_SEQ_u);
        if(bAddNew)then
        begin
          saQry+=',JILin_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JILin_CreatedBy_JUser_ID)+
          ',JILin_Created_DT='+JAS.saDBMSDateScrub(JILin_Created_DT);
        end;
        saQry+=
        ',JILin_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JILin_ModifiedBy_JUser_ID)+
        ',JILin_Modified_DT='+JAS.saDBMSDateScrub(JILin_Modified_DT)+
        ',JILin_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JILin_DeletedBy_JUser_ID)+
        ',JILin_Deleted_DT='+JAS.saDBMSDateScrub(JILin_Deleted_DT)+
        ',JILin_Deleted_b='+JAS.saDBMSBoolScrub(JILin_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JILin_JInvoiceLines_UID='+JAS.saDBMSUIntScrub(JILin_JInvoiceLines_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161939);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151835,'Problem updating jinvoicelines.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jinvoicelines', p_rJInvoiceLines.JILin_JInvoiceLines_UID, '0',201506200411) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151836,'Problem unlocking jinvoicelines record.','p_rJInvoiceLines.JILin_JInvoiceLines_UID:'+p_rJInvoiceLines.JILin_JInvoiceLines_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113191,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
function bJAS_Load_jiplist(p_DBC: JADO_CONNECTION; var p_rJIPList: rtJIPList): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jiplist'; sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210080315,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
//{IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210080316, sTHIS_ROUTINE_NAME);{ENDIF}
  //JAS:=p_DBC;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jiplist where JIPL_JPList_UID='+JAS.saDBMSUIntScrub(p_rJIPList.JIPL_JIPList_UID);
  bOk:=true;
  //if p_bGetLock then
  //begin
  //  bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jilist', p_rJIPList.JIPL_JIPList_UID, '0',201506200266);
  //  if not bOK then
  //  begin
  //    JAS_Log(p_Context,cnLog_Error,201210080317,'Problem locking jiplist record.','p_rJIPList.JIPL_JIPList_UID:'+p_rJIPList.JIPL_JIPList_UID,SOURCEFILE);
  //  end;
  //end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161940);
    if not bOk then
    begin
      JLog(cnLog_Error,201210080318,'Unable to query jiplist successfully Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201210080319,'Record missing from jiplist.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJIPList do begin
        JIPL_JIPList_UID            := rs.Fields.Get_saValue('JIPL_JIPList_UID');
        JIPL_IPListType_u           := rs.Fields.Get_saValue('JIPL_IPListType_u');
        JIPL_IPAddress              := rs.Fields.Get_saValue('JIPL_IPAddress');
        JIPL_InvalidLogins_u        := rs.fields.Get_saValue('JIPL_InvalidLogins_u');
        JIPL_CreatedBy_JUser_ID     := rs.Fields.Get_saValue('JIPL_CreatedBy_JUser_ID');
        JIPL_Created_DT             := rs.Fields.Get_saValue('JIPL_Created_DT');
        JIPL_ModifiedBy_JUser_ID    := rs.Fields.Get_saValue('JIPL_ModifiedBy_JUser_ID');
        JIPL_Modified_DT            := rs.Fields.Get_saValue('JIPL_Modified_DT');
        JIPL_DeletedBy_JUser_ID     := rs.Fields.Get_saValue('JIPL_DeletedBy_JUser_ID');
        JIPL_Deleted_DT             := rs.Fields.Get_saValue('JIPL_Deleted_DT');
        JIPL_Deleted_b              := rs.Fields.Get_saValue('JIPL_Deleted_b');
        JAS_Row_b                   := rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210080320,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jiplist(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIPList: rtJIPList; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jiplist'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210080321,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210080322, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJIPList.JIPL_JIPList_UID)=0 then
  begin
    bAddNew:=true;
    p_rJIPList.JIPL_JIPList_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jinvoicelines');
    bOk:=(u8Val(p_rJIPList.JIPL_JIPList_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080323,'Problem getting an UID for new jiplist record.','saJAS_GetNextUID table: jiplist',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jiplist (JIPL_JIPList_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJIPList.JIPL_JIPList_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161941);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201210080324,'Problem creating a new jiplist record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJIPList.JIPL_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJIPList.JIPL_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJIPList.JIPL_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJIPList.JIPL_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJIPList.JIPL_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJIPList.JIPL_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jiplist', p_rJIPList.JIPL_JIPList_UID, '0',201506200267);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080325,'Problem locking jiplist record.','p_rJIPList.JIPL_JIPList_UID:'+p_rJIPList.JIPL_JIPList_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJIPList do begin
      saQry:='UPDATE jiplist set '+
        ' JIPL_JIPList_UID='+             JAS.saDBMSUIntScrub(JIPL_JIPList_UID)+
        ',JIPL_IPListType_u='+            JAS.saDBMSScrub(JIPL_IPListType_u)+
        ',JIPL_IPAddress='+               JAS.saDBMSScrub(JIPL_IPAddress)+
        ',JIPL_InvalidLogins_u='+         JAS.saDBMSUIntScrub(JIPL_InvalidLogins_u);
      if(bAddNew)then
      begin
        saQry+=
          ',JIPL_CreatedBy_JUser_ID='+    JAS.saDBMSUIntScrub(JIPL_CreatedBy_JUser_ID)+
          ',JIPL_Created_DT='+            JAS.saDBMSDateScrub(JIPL_Created_DT);
      end;
      saQry+=
        ',JIPL_ModifiedBy_JUser_ID='+     JAS.saDBMSUIntScrub(JIPL_ModifiedBy_JUser_ID)+
        ',JIPL_Modified_DT='+             JAS.saDBMSDateScrub(JIPL_Modified_DT)+
        ',JIPL_DeletedBy_JUser_ID='+      JAS.saDBMSUIntScrub(JIPL_DeletedBy_JUser_ID)+
        ',JIPL_Deleted_DT='+              JAS.saDBMSDateScrub(JIPL_Deleted_DT)+
        ',JIPL_Deleted_b='+               JAS.saDBMSBoolScrub(JIPL_Deleted_b)+
        ',JAS_Row_b='+                    JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JIPL_JIPList_UID='+JAS.saDBMSUIntScrub(JIPL_JIPList_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161942);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080326,'Problem updating jiplist.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jiplist', p_rJIPList.JIPL_JIPList_UID, '0',201506200412) then
      begin
        JAS_Log(p_Context,cnLog_Error,201210080327,'Problem unlocking jiplist record.','p_rJIPList.JIPL_JIPList_UID:'+p_rJIPList.JIPL_JIPList_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210080328,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









//=============================================================================
function bJAS_Load_jiplistlu(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIPListLU: rtJIPListLU; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jiplistlu'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201211060942,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201211060943, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jiplistlu where IPLU_JIPListLU_UID='+JAS.saDBMSUIntScrub(p_rJIPListLU.IPLU_JIPListLU_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jiplistlu', p_rJIPListLU.IPLU_JIPListLU_UID, '0',201506200268);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201211060944,'Problem locking jiplistlu record.','p_rJIPListLU.IPLU_JIPListLU_UID:'+p_rJIPListLU.IPLU_JIPListLU_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161943);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201211060945,'Unable to query jiplistlu successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201211060946,'Record missing from jiplistlu.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJIPListLU do begin
        //IPLU_JIPListLU_UID           :=rs.fields.Get_saValue('');
        IPLU_Name                    :=rs.fields.Get_saValue('IPLU_Name');
        IPLU_CreatedBy_JUser_ID      :=rs.fields.Get_saValue('IPLU_CreatedBy_JUser_ID');
        IPLU_Created_DT              :=rs.fields.Get_saValue('IPLU_Created_DT');
        IPLU_DeletedBy_JUser_ID      :=rs.fields.Get_saValue('IPLU_DeletedBy_JUser_ID');
        IPLU_Deleted_b               :=rs.fields.Get_saValue('IPLU_Deleted_b');
        IPLU_Deleted_DT              :=rs.fields.Get_saValue('IPLU_Deleted_DT');
        IPLU_ModifiedBy_JUser_ID     :=rs.fields.Get_saValue('IPLU_ModifiedBy_JUser_ID');
        IPLU_Modified_DT             :=rs.fields.Get_saValue('IPLU_Modified_DT');
        JAS_Row_b                    :=rs.fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201211060947,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jiplistlu(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJIPListLU: rtJIPListLU; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jiplistlu'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201211060948,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201211060949, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJIPListLU.IPLU_JIPListLU_UID)=0 then
  begin
    bAddNew:=true;
    p_rJIPListLU.IPLU_JIPListLU_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jinvoicelines');
    bOk:=(u8Val(p_rJIPListLU.IPLU_JIPListLU_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201211060950,'Problem getting an UID for new jiplistlu record.','saJAS_GetNextUID table: jiplistlu',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jiplistlu (IPLU_JIPListLU_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJIPListLU.IPLU_JIPListLU_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161944);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201211060951,'Problem creating a new jiplistlu record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJIPListLU.IPLU_CreatedBy_JUser_ID      :=p_Context.rJSession.JSess_JUser_ID;
        p_rJIPListLU.IPLU_Created_DT              :=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJIPListLU.IPLU_ModifiedBy_JUser_ID     :=p_Context.rJSession.JSess_JUser_ID;
        p_rJIPListLU.IPLU_Modified_DT             :=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJIPListLU.IPLU_ModifiedBy_JUser_ID     :=p_Context.rJSession.JSess_JUser_ID;
    p_rJIPListLU.IPLU_Modified_DT             :=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jiplistlu', p_rJIPListLU.IPLU_JIPListLU_UID, '0',201506200269);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201211060952,'Problem locking jiplistlu record.','p_rJIPListLU.IPLU_JIPListLU_UID:'+p_rJIPListLU.IPLU_JIPListLU_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJIPListLU do begin
      saQry:='UPDATE jiplistlu set '+
        //' IPLU_JIPListLU_UID='+JAS.saDBMSScrub()+
        'IPLU_Name='+JAS.saDBMSScrub(IPLU_Name);
        if bAddNew then
        begin
          saQry+=',IPLU_CreatedBy_JUser_ID='+JAS.saDBMSUintScrub(IPLU_CreatedBy_JUser_ID)+
            ',IPLU_Created_DT='+JAS.saDBMSDateScrub(IPLU_Created_DT);
        end;
        saQry+=',IPLU_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(IPLU_DeletedBy_JUser_ID)+
          ',IPLU_Deleted_b='+JAS.saDBMSBoolScrub(IPLU_Deleted_b)+
          ',IPLU_Deleted_DT='+JAS.saDBMSDateScrub(IPLU_Deleted_DT)+
          ',IPLU_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(IPLU_ModifiedBy_JUser_ID)+
          ',IPLU_Modified_DT='+JAS.saDBMSDateScrub(IPLU_Modified_DT)+
          ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
          ' WHERE IPLU_JIPListLU_UID='+JAS.saDBMSUIntScrub(IPLU_JIPListLU_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161945);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201211060953,'Problem updating jiplistlu.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jiplistlu', p_rJIPListLU.IPLU_JIPListLU_UID, '0',201506200413) then
      begin
        JAS_Log(p_Context,cnLog_Error,201211060954,'Problem unlocking jiplistlu record.','p_rJIPListLU.IPLU_JIPListLU_UID:'+p_rJIPListLU.IPLU_JIPListLU_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201211060955,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================










//=============================================================================
function bJAS_Load_jjobq(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJJobQ: rtJJobQ; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jjobq'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113204,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113205, sTHIS_ROUTINE_NAME);{$ENDIF}
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jjobq where JJobQ_JJobQ_UID='+p_DBC.saDBMSUIntScrub(p_rJJobQ.JJobQ_JJobQ_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,p_DBC.ID,'jjobq', p_rJJobQ.JJobQ_JJobQ_UID, '0',201506200270);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100725,'Problem locking jjobq record.','p_rJJobQ.JJobQ_JJobQ_UID:'+p_rJJobQ.JJobQ_JJobQ_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,p_DBC,201503161946);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201004212102,'Unable to query jjobq successfully','Query: '+saQry,SOURCEFILE,p_DBC,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201004212103,'Record missing from jjobq.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJJobQ do begin
        //JJobQ_JJobQ_UID         :=rs.Fields.Get_saValue('JJobQ_JJobQ_UID');
        JJobQ_JUser_ID                   :=rs.Fields.Get_saValue('JJobQ_JUser_ID');
        JJobQ_JJobType_ID                :=rs.Fields.Get_saValue('JJobQ_JJobType_ID');
        JJobQ_Start_DT                   :=rs.Fields.Get_saValue('JJobQ_Start_DT');
        JJobQ_ErrorNo_u                  :=rs.Fields.Get_saValue('JJobQ_ErrorNo_u');
        JJobQ_Started_DT                 :=rs.Fields.Get_saValue('JJobQ_Started_DT');
        JJobQ_Running_b                  :=rs.Fields.Get_saValue('JJobQ_Running_b');
        JJobQ_Finished_DT                :=rs.Fields.Get_saValue('JJobQ_Finished_DT');
        JJobQ_Name                       :=rs.Fields.Get_saValue('JJobQ_Name');
        JJobQ_Repeat_b                   :=rs.Fields.Get_saValue('JJobQ_Repeat_b');
        JJobQ_RepeatMinute               :=rs.Fields.Get_saValue('JJobQ_RepeatMinute');
        JJobQ_RepeatHour                 :=rs.Fields.Get_saValue('JJobQ_RepeatHour');
        JJobQ_RepeatDayOfMonth           :=rs.Fields.Get_saValue('JJobQ_RepeatDayOfMonth');
        JJobQ_RepeatMonth                :=rs.Fields.Get_saValue('JJobQ_RepeatMonth');
        JJobQ_Completed_b                :=rs.Fields.Get_saValue('JJobQ_Completed_b');
        JJobQ_Result_URL                 :=rs.Fields.Get_saValue('JJobQ_Result_URL');
        JJobQ_ErrorMsg                   :=rs.Fields.Get_saValue('JJobQ_ErrorMsg');
        JJobQ_ErrorMoreInfo              :=rs.Fields.Get_saValue('JJobQ_ErrorMoreInfo');
        JJobQ_Enabled_b                  :=rs.Fields.Get_saValue('JJobQ_Enabled_b');
        JJobQ_Job                        :=rs.Fields.Get_saValue('JJobQ_Job');
        JJobQ_Result                     :=rs.Fields.Get_saValue('JJobQ_Result');
        JJobQ_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JJobQ_CreatedBy_JUser_ID');
        JJobQ_Created_DT                 :=rs.Fields.Get_saValue('JJobQ_Created_DT');
        JJobQ_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JJobQ_ModifiedBy_JUser_ID');
        JJobQ_Modified_DT                :=rs.Fields.Get_saValue('JJobQ_Modified_DT');
        JJobQ_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JJobQ_DeletedBy_JUser_ID');
        JJobQ_Deleted_DT                 :=rs.Fields.Get_saValue('JJobQ_Deleted_DT');
        JJobQ_Deleted_b                  :=rs.Fields.Get_saValue('JJobQ_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
        JJobQ_JTask_ID                   :=rs.Fields.Get_saValue('JJobQ_JTask_ID');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113206,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jjobq(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJJobQ: rtJJobQ; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jjobq'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113207,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113208, sTHIS_ROUTINE_NAME);{$ENDIF}

  //AS_Log(p_COntext,cnLog_Debug,201210242113,'bJAS_Save_JJobQ - ','',SOURCEFILE);
  //AS_Log(p_COntext,cnLog_Debug,201210242113,'BEGIN - bJAS_Save_JJobQ','',SOURCEFILE);

  DT:=now;
  bAddNew:=false;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  //AS_Log(p_COntext,cnLog_Debug,201210242113,'bJAS_Save_JJobQ - Init','',SOURCEFILE);
  if u8Val(p_rJJobQ.JJobQ_JJobQ_UID)=0 then
  begin
    //AS_Log(p_COntext,cnLog_Debug,201210242113,'bJAS_Save_JJobQ BEGIN - AddNew','',SOURCEFILE);
    bAddNew:=true;
    p_rJJobQ.JJobQ_JJobQ_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jjobq');
    bOk:=(u8Val(p_rJJobQ.JJobQ_JJobQ_UID)>0);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Error,201004212104,'Problem getting an UID for new jjobq record.','saJAS_GetNextUID table: jjobq',SOURCEFILE);
      JAS_Log(p_COntext,cnLog_Error,201004212104,'Problem getting an UID for new jjobq record.','saJAS_GetNextUID table: jjobq',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jjobq (JJobQ_JJobQ_UID) VALUES ('+ p_DBC.saDBMSUintScrub(p_rJJobQ.JJobQ_JJobQ_UID) + ')';
      bOk:=rs.Open(saQry,p_DBC,201503161947);
      if not bOk then
      begin
        //JAS_Log(p_Context,cnLog_Error,201004212105,'Problem creating a new jjobq record.','Query: '+saQry,SOURCEFILE);
        JAS_Log(p_Context,cnLog_Error,201004212105,'Problem creating a new jjobq record.','Query: '+saQry,SOURCEFILE,p_DBC,rs);
      end
      else
      begin
        p_bHaveLock:=true;//force locking because we created a new record
        p_rJJobQ.JJobQ_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJJobQ.JJobQ_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJJobQ.JJobQ_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJJobQ.JJobQ_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
    //AS_Log(p_COntext,cnLog_Debug,201210242113,'bJAS_Save_JJobQ - END - AddNew','',SOURCEFILE);
  end
  else
  begin
    p_rJJobQ.JJobQ_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJJobQ.JJobQ_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    //AS_Log(p_COntext,cnLog_Debug,201210242113,'bJAS_Save_JJobQ - BEGIN- No Lock - Get it','',SOURCEFILE);
    bOk:=bJAS_LockRecord(p_Context,p_DBC.ID,'jjobq', p_rJJobQ.JJobQ_JJobQ_UID, '0',201506200271);
    if not bOK then
    begin
      //JAS_Log(p_Context,cnLog_Error,201004212106,'Problem locking jjobq record.','p_rJJobQ.JJobQ_JJobQ_UID:'+p_rJJobQ.JJobQ_JJobQ_UID,SOURCEFILE);
      JAS_Log(p_COntext, cnLog_Error,201004212106,'Problem locking jjobq record.','p_rJJobQ.JJobQ_JJobQ_UID:'+p_rJJobQ.JJobQ_JJobQ_UID,SOURCEFILE);
    end;
    //AS_Log(p_COntext,cnLog_Debug,201210242113,'bJAS_Save_JJobQ - END- No Lock - Get it','',SOURCEFILE);
  end;

  if bOk then
  begin
    //AS_Log(p_COntext,cnLog_Debug,201210242113,'bJAS_Save_JJobQ - BEGIN- BUILD UPDATE Query ','',SOURCEFILE);
    with p_rJJobQ do begin
      saQry:='UPDATE jjobq set '+
        //' JJobQ_JJobQ_UID='+JAS.saDBMSScrub(JJobQ_JJobQ_UID)+
        'JJobQ_JUser_ID='             + p_DBC.saDBMSUIntScrub(JJobQ_JUser_ID)+
        ',JJobQ_JJobType_ID='         + p_DBC.saDBMSUIntScrub(JJobQ_JJobType_ID)+
        ',JJobQ_Start_DT='            + p_DBC.saDBMSDateScrub(JJobQ_Start_DT)+
        ',JJobQ_ErrorNo_u='           + p_DBC.saDBMSUIntScrub(JJobQ_ErrorNo_u)+
        ',JJobQ_Started_DT='          + p_DBC.saDBMSDateScrub(JJobQ_Started_DT)+
        ',JJobQ_Running_b='           + p_DBC.saDBMSBoolScrub(JJobQ_Running_b)+
        ',JJobQ_Finished_DT='         + p_DBC.saDBMSDateScrub(JJobQ_Finished_DT)+
        ',JJobQ_Name='                + p_DBC.saDBMSScrub(JJobQ_Name)+
        ',JJobQ_Repeat_b='            + p_DBC.saDBMSBoolScrub(JJobQ_Repeat_b)+
        ',JJobQ_RepeatMinute='        + p_DBC.saDBMSScrub(JJobQ_RepeatMinute)+
        ',JJobQ_RepeatHour='          + p_DBC.saDBMSScrub(JJobQ_RepeatHour)+
        ',JJobQ_RepeatDayOfMonth='    + p_DBC.saDBMSScrub(JJobQ_RepeatDayOfMonth)+
        ',JJobQ_RepeatMonth='         + p_DBC.saDBMSScrub(JJobQ_RepeatMonth)+
        ',JJobQ_Completed_b='         + p_DBC.saDBMSBoolScrub(JJobQ_Completed_b)+
        ',JJobQ_Result_URL='          + p_DBC.saDBMSScrub(JJobQ_Result_URL)+
        ',JJobQ_ErrorMsg='            + p_DBC.saDBMSScrub(JJobQ_ErrorMsg)+
        ',JJobQ_ErrorMoreInfo='       + p_DBC.saDBMSScrub(JJobQ_ErrorMoreInfo)+
        ',JJobQ_Enabled_b='           + p_DBC.saDBMSBoolScrub(JJobQ_Enabled_b)+
        ',JJobQ_Job='                 + p_DBC.saDBMSScrub(JJobQ_Job)+
        ',JJobQ_Result='              + p_DBC.saDBMSScrub(JJobQ_Result);
        if(bAddNew)then
        begin
          saQry+=',JJobQ_CreatedBy_JUser_ID='+p_DBC.saDBMSUIntScrub(JJobQ_CreatedBy_JUser_ID)+
          ',JJobQ_Created_DT='+p_DBC.saDBMSDateScrub(JJobQ_Created_DT);
        end;
        saQry+=
        ',JJobQ_ModifiedBy_JUser_ID=' + p_DBC.saDBMSUIntScrub(JJobQ_ModifiedBy_JUser_ID)+
        ',JJobQ_Modified_DT='         + p_DBC.saDBMSDateScrub(JJobQ_Modified_DT)+
        ',JJobQ_DeletedBy_JUser_ID='  + p_DBC.saDBMSIntScrub(JJobQ_DeletedBy_JUser_ID)+
        ',JJobQ_Deleted_DT='          + p_DBC.saDBMSDateScrub(JJobQ_Deleted_DT)+
        ',JJobQ_Deleted_b='           + p_DBC.saDBMSBoolScrub(JJobQ_Deleted_b)+
        ',JAS_Row_b='                 + p_DBC.saDBMSBoolScrub(JAS_Row_b)+
        ',JJobQ_JTask_ID='            + p_DBC.saDBMSUIntScrub(JJobQ_JTask_ID)+
        ' WHERE JJobQ_JJobQ_UID='     + p_DBC.saDBMSUIntScrub(JJobQ_JJobQ_UID);
    end;//with
    
    //AS_Log(p_Context,cnLog_DEBUG,201004212109,'SAVE jjobq. Debug','Query: '+saQry,SOURCEFILE);
    //AS_Log(p_COntext,cnLog_Debug,201210242113,'bJAS_Save_JJobQ - BEGIN- UPDATE QUERY','',SOURCEFILE);
    bOk:=rs.Open(saQry,p_DBC,201503161948);
    if not bOk then 
    begin
      //AS_Log(p_Context,cnLog_Error,201004212107,'Problem updating jjobq.','Query: '+saQry,SOURCEFILE);
      JAS_Log(p_Context,cnLog_Error,201004212107,'Problem updating jjobq.','Query: '+saQry,SOURCEFILE,p_DBC,rs);
    end;
    //AS_Log(p_COntext,cnLog_Debug,201210242113,'bJAS_Save_JJobQ - END - UPDATE QUERY','',SOURCEFILE);
 


    
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      //AS_Log(p_Context,cnLog_Debug,201004212108,'bJAS_Save_JJobQ - BEGIN Unlocking Record.','p_rJJobQ.JJobQ_JJobQ_UID:'+p_rJJobQ.JJobQ_JJobQ_UID,SOURCEFILE);
      if not bJAS_UnLockRecord(p_Context,p_DBC.ID,'jjobq', p_rJJobQ.JJobQ_JJobQ_UID, '0',201506200414) then
      begin
        //AS_Log(p_Context,cnLog_Error,201004212108,'Problem unlocking jjobq record.','p_rJJobQ.JJobQ_JJobQ_UID:'+p_rJJobQ.JJobQ_JJobQ_UID,SOURCEFILE);
      end;
      //AS_Log(p_COntext,cnLog_Debug,201210242113,'bJAS_Save_JJobQ - END - Unlocking Record','',SOURCEFILE);
    end;
  end;
  rs.Destroy;
  result:=bOk;
  //AS_Log(p_COntext,cnLog_Debug,201210242113,'END - bJAS_Save_JJobQ','',SOURCEFILE);
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113209,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================












//=============================================================================
//function bJAS_Load_jlanguage(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLanguage: rtJLanguage; p_bGetLock: boolean): boolean;
function bJAS_Load_jlanguage(p_DBC: JADO_CONNECTION; var p_rJLanguage: rtJLanguage): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jlanguage'; sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203251417,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
//{IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203251417, sTHIS_ROUTINE_NAME);{ENDIF}
  //JAS:=p_DBC;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jlanguage where JLang_JLanguage_UID='+JAS.saDBMSUIntScrub(p_rJLanguage.JLang_JLanguage_UID);
  bOk:=true;
  //if p_bGetLock then
  //begin
  //  bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jlanguage', p_rJLanguage.JLang_JLanguage_UID, '0',201506200272);
  //  if not bOK then
  //  begin
  //    JAS_Log(p_Context,cnLog_Error,201203251418,'Problem locking jlanguage record.','p_rJLanguage.JLang_JLanguage_UID:'+p_rJLanguage.JLang_JLanguage_UID,SOURCEFILE);
  //  end;
  //end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161949);
    if not bOk then
    begin
      JLog(cnLog_Error,201203251419,'Unable to query jjobq successfully Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201203251420,'Record missing from jlanguage.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJLanguage do begin
        //JLang_JLanguage_UID          :=rs.Fields.Get_saValue('JLang_');
        JLang_Name                   :=rs.Fields.Get_saValue('JLang_Name');
        JLang_NativeName             :=rs.Fields.Get_saValue('JLang_NativeName');
        JLang_Code                   :=rs.Fields.Get_saValue('JLang_Code');
        JLang_CreatedBy_JUser_ID     :=rs.Fields.Get_saValue('JLang_CreatedBy_JUser_ID');
        JLang_Created_DT             :=rs.Fields.Get_saValue('JLang_Created_DT');
        JLang_ModifiedBy_JUser_ID    :=rs.Fields.Get_saValue('JLang_ModifiedBy_JUser_ID');
        JLang_Modified_DT            :=rs.Fields.Get_saValue('JLang_Modified_DT');
        JLang_DeletedBy_JUser_ID     :=rs.Fields.Get_saValue('JLang_DeletedBy_JUser_ID');
        JLang_Deleted_DT             :=rs.Fields.Get_saValue('JLang_Deleted_DT');
        JLang_Deleted_b              :=rs.Fields.Get_saValue('JLang_Deleted_b');
        JAS_Row_b                    :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203251421,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jlanguage(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLanguage: rtJLanguage; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jlanguage'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203251422,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203251422, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJLanguage.JLang_JLanguage_UID)=0 then
  begin
    bAddNew:=true;
    p_rJLanguage.JLang_JLanguage_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jlanguage');
    bOk:=(u8Val(p_rJLanguage.JLang_JLanguage_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_COntext,cnLog_Error,201203251424,'Problem getting an UID for new jlanguage record.','saJAS_GetNextUID table: jlanguage',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jlanguage (JLang_JLanguage_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJLanguage.JLang_JLanguage_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161950);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201203251426,'Problem creating a new jlanguage record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=true;//force locking because we created a new record
        p_rJLanguage.JLang_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJLanguage.JLang_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJLanguage.JLang_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJLanguage.JLang_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJLanguage.JLang_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJLanguage.JLang_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jlanguage', p_rJLanguage.JLang_JLanguage_UID, '0',201506200273);
    if not bOK then
    begin
      JAS_Log(p_COntext, cnLog_Error,201203251428,'Problem locking jlanguage record.','p_rJLanguage.JLang_JLanguage_UID:'+p_rJLanguage.JLang_JLanguage_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJLanguage do begin
      saQry:='UPDATE jlanguage set '+
        //' JLang_JLanguage_UID='             +JAS.saDBMSUIntScrub(JLang_JLang_JLanguage_UID)+
        ' JLang_Name='                        +JAS.saDBMSScrub(JLang_Name               )+
        ',JLang_NativeName='                  +JAS.saDBMSScrub(JLang_NativeName         )+
        ',JLang_Code='                        +JAS.saDBMSScrub(JLang_Code               );
        if bAddNew then
        begin
          saQry+=',JLang_CreatedBy_JUser_ID=' +JAS.saDBMSUIntScrub(JLang_CreatedBy_JUser_ID )+
          ',JLang_Created_DT='                +JAS.saDBMSDateScrub(JLang_Created_DT         );
        end;
        saQry+=',JLang_ModifiedBy_JUser_ID='  +JAS.saDBMSUIntScrub(JLang_ModifiedBy_JUser_ID)+
        ',JLang_Modified_DT='                 +JAS.saDBMSDateScrub(JLang_Modified_DT        )+
        ',JLang_DeletedBy_JUser_ID='          +JAS.saDBMSUIntScrub(JLang_DeletedBy_JUser_ID )+
        ',JLang_Deleted_DT='                  +JAS.saDBMSDateScrub(JLang_Deleted_DT         )+
        ',JLang_Deleted_b='                   +JAS.saDBMSBoolScrub(JLang_Deleted_b          )+
        ',JAS_Row_b='                         +JAS.saDBMSBoolScrub(JAS_Row_b                )+
        ' WHERE JLang_JLanguage_UID='         +JAS.saDBMSUIntScrub(JLang_JLanguage_UID);


    end;//with
    bOk:=rs.Open(saQry, JAS,201503161951);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201203251429,'Problem updating jlanguage.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not p_bKeepLock then
      begin
        if not bJAS_UnLockRecord(p_Context,JAS.ID,'jlanguage', p_rJLanguage.JLang_JLanguage_UID, '0',201506200415) then
        begin
          JAS_Log(p_Context,cnLog_Error,201203251430,'Problem unlocking jjobq record.','p_rJLanguage.JLang_JLanguage_UID:'+p_rJLanguage.JLang_JLanguage_UID,SOURCEFILE);
        end;
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203251431,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
function bJAS_Load_jlead(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLead: rtJLead; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jlead'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113210,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113211, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jlead where JLead_JLead_UID='+JAS.saDBMSUIntScrub(p_rJLead.JLead_JLead_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jlead', p_rJLead.JLead_JLead_UID, '0',201506200274);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100726,'Problem locking jlead record.','p_rJLead.JLead_JLead_UID:'+p_rJLead.JLead_JLead_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161952);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151837,'Unable to query jlead successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151838,'Record missing from jlead.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJLead do begin
        //JLead_JLead_UID: ansistring;
        JLead_JLeadSource_ID      :=rs.Fields.Get_saValue('JLead_JLeadSource_ID');
        JLead_Owner_JUser_ID      :=rs.Fields.Get_saValue('JLead_Owner_JUser_ID');
        JLead_Private_b           :=rs.Fields.Get_saValue('JLead_Private_b');
        JLead_CompanyName         :=rs.Fields.Get_saValue('JLead_CompanyName');
        JLead_NameSalutation      :=rs.Fields.Get_saValue('JLead_NameSalutation');
        JLead_NameFirst           :=rs.Fields.Get_saValue('JLead_NameFirst');
        JLead_NameMiddle          :=rs.Fields.Get_saValue('JLead_NameMiddle');
        JLead_NameLast            :=rs.Fields.Get_saValue('JLead_NameLast');
        JLead_NameSuffix          :=rs.Fields.Get_saValue('JLead_NameSuffix');
        JLead_Desc                :=rs.Fields.Get_saValue('JLead_Desc');
        JLead_Gender              :=rs.Fields.Get_saValue('JLead_Gender');
        JLead_Home_Phone          :=rs.Fields.Get_saValue('JLead_Home_Phone');
        JLead_Mobile_Phone        :=rs.Fields.Get_saValue('JLead_Mobile_Phone');
        JLead_Work_Email          :=rs.Fields.Get_saValue('JLead_Work_Email');
        JLead_Work_Phone          :=rs.Fields.Get_saValue('JLead_Work_Phone');
        JLead_Fax                 :=rs.Fields.Get_saValue('JLead_Fax');
        JLead_Home_Email          :=rs.Fields.Get_saValue('JLead_Home_Email');
        JLead_Website             :=rs.Fields.Get_saValue('JLead_Website');
        JLead_Main_Addr1          :=rs.Fields.Get_saValue('JLead_Main_Addr1');
        JLead_Main_Addr2          :=rs.Fields.Get_saValue('JLead_Main_Addr2');
        JLead_Main_Addr3          :=rs.Fields.Get_saValue('JLead_Main_Addr3');
        JLead_Main_City           :=rs.Fields.Get_saValue('JLead_Main_City');
        JLead_Main_State          :=rs.Fields.Get_saValue('JLead_Main_State');
        JLead_Main_PostalCode     :=rs.Fields.Get_saValue('JLead_Main_PostalCode');
        JLead_Main_Country        :=rs.Fields.Get_saValue('JLead_Main_Country');
        JLead_Ship_Addr1          :=rs.Fields.Get_saValue('JLead_Ship_Addr1');
        JLead_Ship_Addr2          :=rs.Fields.Get_saValue('JLead_Ship_Addr2');
        JLead_Ship_Addr3          :=rs.Fields.Get_saValue('JLead_Ship_Addr3');
        JLead_Ship_City           :=rs.Fields.Get_saValue('JLead_Ship_City');
        JLead_Ship_State          :=rs.Fields.Get_saValue('JLead_Ship_State');
        JLead_Ship_PostalCode     :=rs.Fields.Get_saValue('JLead_Ship_PostalCode');
        JLead_Ship_Country        :=rs.Fields.Get_saValue('JLead_Ship_Country');
        JLead_Exist_JCompany_ID   :=rs.Fields.Get_saValue('JLead_Exist_JCompany_ID');
        JLead_Exist_JPerson_ID    :=rs.Fields.Get_saValue('JLead_Exist_JPerson_ID');
        JLead_LeadSourceAddl      :=rs.Fields.Get_saValue('JLead_LeadSourceAddl');
        JLead_CreatedBy_JUser_ID  :=rs.Fields.Get_saValue('JLead_CreatedBy_JUser_ID');
        JLead_Created_DT          :=rs.Fields.Get_saValue('JLead_Created_DT');
        JLead_ModifiedBy_JUser_ID :=rs.Fields.Get_saValue('JLead_ModifiedBy_JUser_ID');
        JLead_Modified_DT         :=rs.Fields.Get_saValue('JLead_Modified_DT');
        JLead_DeletedBy_JUser_ID  :=rs.Fields.Get_saValue('JLead_DeletedBy_JUser_ID');
        JLead_Deleted_DT          :=rs.Fields.Get_saValue('JLead_Deleted_DT');
        JLead_Deleted_b           :=rs.Fields.Get_saValue('JLead_Deleted_b');
        JAS_Row_b                 :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113212,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jlead(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLead: rtJLead; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jlead'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113213,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113214, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJLead.JLead_JLead_UID)=0 then
  begin
    bAddNew:=true;
    p_rJLead.JLead_JLead_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jlead');
    bOk:=(u8Val(p_rJLead.JLead_JLead_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151839,'Problem getting an UID for new jlead record.','saJAS_GetNextUID table: jlead',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jlead (p_rJLead.JLead_JLead_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJLead.JLead_JLead_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161953);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151840,'Problem creating a new jlead record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJLead.JLead_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJLead.JLead_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJLead.JLead_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJLead.JLead_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJLead.JLead_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJLead.JLead_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jlead', p_rJLead.JLead_JLead_UID, '0',201506200275);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151841,'Problem locking jlead record.','p_rJLead.JLead_JLead_UID:'+p_rJLead.JLead_JLead_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJLead do begin
      saQry:='UPDATE jlead set '+
        //' JLead_JLead_UID='+JAS.saDBMSScrub()+
        ' JLead_JLeadSource_ID='+JAS.saDBMSUIntScrub(JLead_JLeadSource_ID)+
        ',JLead_Owner_JUser_ID='+JAS.saDBMSUIntScrub(JLead_Owner_JUser_ID)+
        ',JLead_Private_b='+JAS.saDBMSBoolScrub(JLead_Private_b)+
        ',JLead_CompanyName='+JAS.saDBMSScrub(JLead_CompanyName)+
        ',JLead_NameSalutation='+JAS.saDBMSScrub(JLead_NameSalutation)+
        ',JLead_NameFirst='+JAS.saDBMSScrub(JLead_NameFirst)+
        ',JLead_NameMiddle='+JAS.saDBMSScrub(JLead_NameMiddle)+
        ',JLead_NameLast='+JAS.saDBMSScrub(JLead_NameLast)+
        ',JLead_NameSuffix='+JAS.saDBMSScrub(JLead_NameSuffix)+
        ',JLead_Desc='+JAS.saDBMSScrub(JLead_Desc)+
        ',JLead_Gender='+JAS.saDBMSScrub(JLead_Gender)+
        ',JLead_Home_Phone='+JAS.saDBMSScrub(JLead_Home_Phone)+
        ',JLead_Mobile_Phone='+JAS.saDBMSScrub(JLead_Mobile_Phone)+
        ',JLead_Work_Email='+JAS.saDBMSScrub(JLead_Work_Email)+
        ',JLead_Work_Phone='+JAS.saDBMSScrub(JLead_Work_Phone)+
        ',JLead_Fax='+JAS.saDBMSScrub(JLead_Fax)+
        ',JLead_Home_Email='+JAS.saDBMSScrub(JLead_Home_Email)+
        ',JLead_Website='+JAS.saDBMSScrub(JLead_Website)+
        ',JLead_Main_Addr1='+JAS.saDBMSScrub(JLead_Main_Addr1)+
        ',JLead_Main_Addr2='+JAS.saDBMSScrub(JLead_Main_Addr2)+
        ',JLead_Main_Addr3='+JAS.saDBMSScrub(JLead_Main_Addr3)+
        ',JLead_Main_City='+JAS.saDBMSScrub(JLead_Main_City)+
        ',JLead_Main_State='+JAS.saDBMSScrub(JLead_Main_State)+
        ',JLead_Main_PostalCode='+JAS.saDBMSScrub(JLead_Main_PostalCode)+
        ',JLead_Ship_Addr1='+JAS.saDBMSScrub(JLead_Ship_Addr1)+
        ',JLead_Ship_Addr2='+JAS.saDBMSScrub(JLead_Ship_Addr2)+
        ',JLead_Ship_Addr3='+JAS.saDBMSScrub(JLead_Ship_Addr3)+
        ',JLead_Ship_City='+JAS.saDBMSScrub(JLead_Ship_City)+
        ',JLead_Ship_State='+JAS.saDBMSScrub(JLead_Ship_State)+
        ',JLead_Ship_PostalCode='+JAS.saDBMSScrub(JLead_Ship_PostalCode)+
        ',JLead_Exist_JCompany_ID='+JAS.saDBMSUintScrub(JLead_Exist_JCompany_ID)+
        ',JLead_Exist_JPerson_ID='+JAS.saDBMSUintScrub(JLead_Exist_JPerson_ID)+
        ',JLead_LeadSourceAddl='+JAS.saDBMSUintScrub(JLead_LeadSourceAddl);
        if(bAddNew)then
        begin
          saQry+=',JLead_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JLead_CreatedBy_JUser_ID)+
            ',JLead_Created_DT='+JAS.saDBMSDateScrub(JLead_Created_DT);
        end;
        saQry+=
        ',JLead_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JLead_ModifiedBy_JUser_ID)+
        ',JLead_Modified_DT='+JAS.saDBMSDateScrub(JLead_Modified_DT)+
        ',JLead_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JLead_DeletedBy_JUser_ID)+
        ',JLead_Deleted_DT='+JAS.saDBMSDateScrub(JLead_Deleted_DT)+
        ',JLead_Deleted_b='+JAS.saDBMSBoolScrub(JLead_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JLead_JLead_UID='+JAS.saDBMSUintScrub(JLead_JLead_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161955);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151842,'Problem updating jlead.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jlead', p_rJLead.JLead_JLead_UID, '0',201506200416) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151843,'Problem unlocking jlead record.','p_rJLead.JLead_JLead_UID:'+p_rJLead.JLead_JLead_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113215,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jleadsource(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLeadSource: rtJLeadSource; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jleadsource'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113216,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113217, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jleadsource where JLDSR_JLeadSource_UID='+JAS.saDBMSUintScrub(p_rJLeadSource.JLDSR_JLeadSource_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jleadsource', p_rJLeadSource.JLDSR_JLeadSource_UID, '0',201506200276);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100727,'Problem locking jleadsource record.','p_rJLeadSource.JLDSR_JLeadSource_UID:'+p_rJLeadSource.JLDSR_JLeadSource_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161956);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151844,'Unable to query jleadsource successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151845,'Record missing from jleadsource.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJLeadSource do begin
        //JLDSR_JLeadSource_UID:=rs.Fields.Get_saValue('');
        JLDSR_Name:=rs.Fields.Get_saValue('JLDSR_Name');
        JLDSR_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JLDSR_CreatedBy_JUser_ID');
        JLDSR_Created_DT                 :=rs.Fields.Get_saValue('JLDSR_Created_DT');
        JLDSR_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JLDSR_ModifiedBy_JUser_ID');
        JLDSR_Modified_DT                :=rs.Fields.Get_saValue('JLDSR_Modified_DT');
        JLDSR_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JLDSR_DeletedBy_JUser_ID');
        JLDSR_Deleted_DT                 :=rs.Fields.Get_saValue('JLDSR_Deleted_DT');
        JLDSR_Deleted_b                  :=rs.Fields.Get_saValue('JLDSR_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113218,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jleadsource(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJLeadSource: rtJLeadSource; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jleadsource'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113219,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113220, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJLeadSource.JLDSR_JLeadSource_UID)=0 then
  begin
    bAddNew:=true;
    p_rJLeadSource.JLDSR_JLeadSource_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jleadsource');
    bOk:=(u8Val(p_rJLeadSource.JLDSR_JLeadSource_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151846,'Problem getting an UID for new jleadsource record.','saJAS_GetNextUID table: jleadsource',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jleadsource (JLDSR_JLeadSource_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJLeadSource.JLDSR_JLeadSource_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503161957);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151847,'Problem creating a new jleadsource record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJLeadSource.JLDSR_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJLeadSource.JLDSR_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJLeadSource.JLDSR_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJLeadSource.JLDSR_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJLeadSource.JLDSR_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJLeadSource.JLDSR_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jleadsource', p_rJLeadSource.JLDSR_JLeadSource_UID, '0',201506200277);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151848,'Problem locking jleadsource record.','p_rJLeadSource.JLDSR_JLeadSource_UID:'+p_rJLeadSource.JLDSR_JLeadSource_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJLeadSource do begin
      saQry:='UPDATE jleadsource set '+
        //' JLDSR_JLeadSource_UID='+JAS.saDBMSScrub()+
        'JLDSR_Name='+JAS.saDBMSScrub(JLDSR_Name);
        if(bAddNew)then
        begin
          saQry+=',JLDSR_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JLDSR_CreatedBy_JUser_ID)+
          ',JLDSR_Created_DT='+JAS.saDBMSDateScrub(JLDSR_Created_DT);
        end;
        saQry+=
        ',JLDSR_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JLDSR_ModifiedBy_JUser_ID)+
        ',JLDSR_Modified_DT='+JAS.saDBMSDateScrub(JLDSR_Modified_DT)+
        ',JLDSR_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JLDSR_DeletedBy_JUser_ID)+
        ',JLDSR_Deleted_DT='+JAS.saDBMSDateScrub(JLDSR_Deleted_DT)+
        ',JLDSR_Deleted_b='+JAS.saDBMSBoolScrub(JLDSR_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JLDSR_JLeadSource_UID='+JAS.saDBMSUIntScrub(JLDSR_JLeadSource_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503161958);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151849,'Problem updating jleadsource.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jleadsource',p_rJLeadSource.JLDSR_JLeadSource_UID, '0',201506200417) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151850,'Problem unlocking jleadsource record.','p_rJLeadSource.JLDSR_JLeadSource_UID:'+p_rJLeadSource.JLDSR_JLeadSource_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113221,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
function bJAS_Load_jmail(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJMail: rtJMail; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_JMail'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201506111322,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201506111323, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jmail where JMail_JMail_UID='+p_rJMail.JMail_JMail_UID;
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmail', p_rJMail.JMail_JMail_UID, '0',201506200278);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201506111324,'Problem locking jmail record.','p_rJMail.JMail_JMail_UID:'+p_rJMail.JMail_JMail_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201506111325);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201506111326,'Unable to query jmail successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201506111327,'Record missing from jmail.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJMail do begin
        //JMail_JMail_UID            
        JMail_To_User_ID            :=  rs.fields.Get_saValue('JMail_To_User_ID');
        JMail_From_User_ID          :=  rs.fields.Get_saValue('JMail_From_User_ID');
        JMail_Message               :=  rs.fields.Get_saValue('JMail_Message');
        JMail_Message_Code          :=  rs.fields.Get_saValue('JMail_Message_Code');
        JMail_CreatedBy_JUser_ID    :=  rs.fields.Get_saValue('JMail_CreatedBy_JUser_ID');
        JMail_Created_DT            :=  rs.fields.Get_saValue('JMail_Created_DT');
        JMail_ModifiedBy_JUser_ID   :=  rs.fields.Get_saValue('JMail_ModifiedBy_JUser_ID');
        JMail_Modified_DT           :=  rs.fields.Get_saValue('JMail_Modified_DT');
        JMail_DeletedBy_JUser_ID    :=  rs.fields.Get_saValue('JMail_DeletedBy_JUser_ID');
        JMail_Deleted_DT            :=  rs.fields.Get_saValue('JMail_Deleted_DT');
        JMail_Deleted_b             :=  rs.fields.Get_saValue('JMail_Deleted_b');
        JAS_Row_b                   :=  rs.fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201506111328,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jmail(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJMail: rtJMail; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_JMail'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201506111329,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201506111330, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJMail.JMail_JMail_UID)=0 then
  begin
    bAddNew:=true;
    p_rJMail.JMail_Jmail_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jmail'));
    bOk:=(u8val(p_rJmail.Jmail_Jmail_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201506111331,'Problem getting an UID for new jmail record.','saJAS_GetNextUID table: jmail',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jmail (JMail_JMail_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJmail.Jmail_Jmail_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201506111332);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201506111333,'Problem creating a new jmail record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJmail.Jmail_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJmail.Jmail_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJmail.Jmail_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJmail.Jmail_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJmail.Jmail_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJmail.Jmail_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmail', p_rJmail.Jmail_Jmail_UID, '0',201506200279);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201506111334,'Problem locking jmail record.','p_rJmail.Jmail_Jmail_UID:'+p_rJmail.Jmail_Jmail_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJmail do begin
      saQry:='UPDATE jmail set ' +
        //JMail_JMail_UID            
        'JMail_From_User_ID           = '+JAS.saDBMSUIntScrub(JMail_From_User_ID)+
        ',JMail_To_User_ID            = '+JAS.saDBMSUIntScrub(JMail_To_User_ID)+
        ',JMail_Message               = '+JAS.saDBMSScrub(JMail_Message)+
        ',JMail_Message_Code          = '+JAS.saDBMSUintScrub(JMail_Message_Code);
      if bAddnew then
      begin
        saQry+=',JMail_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JMail_CreatedBy_JUser_ID)+
          ',JMail_Created_DT='+JAS.saDBMSDateScrub(JMail_Created_DT);
      end;
      saQry+=
        ',JMail_ModifiedBy_JUser_ID   = '+JAS.saDBMSUIntScrub(JMail_ModifiedBy_JUser_ID)+
        ',JMail_Modified_DT           = '+JAS.saDBMSDateScrub(JMail_Modified_DT)+
        ',JMail_DeletedBy_JUser_ID    = '+JAS.saDBMSUIntScrub(JMail_DeletedBy_JUser_ID)+
        ',JMail_Deleted_DT            = '+JAS.saDBMSDateScrub(JMail_Deleted_DT)+
        ',JMail_Deleted_b             = '+JAS.saDBMSBoolScrub(JMail_Deleted_b)+
        ',JAS_Row_b                   = '+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' where JMail_JMail_UID='+JAS.saDBMSUIntScrub(JMail_JMail_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201506111335);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201506111336,'Problem updating jmail.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jmail', p_rJmail.Jmail_Jmail_UID, '0',201506200418) then
      begin
        JAS_Log(p_Context,cnLog_Error,201506111337,'Problem unlocking jmail record.','p_rJmail.Jmail_Jmail_UID:'+p_rJmail.JMail_Jmail_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201506111338,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








  
//=============================================================================
function bJAS_Load_jmenu(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJMenu: rtJMenu; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jmenu'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113222,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113223, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jmenu where JMenu_JMenu_UID='+JAS.saDBMSUIntScrub(inttostr(p_rJMenu.JMenu_JMenu_UID));
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmenu', inttostr(p_rJMenu.JMenu_JMenu_UID), '0',201506200280);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100731,'Problem locking jmenu record.','p_rJMenu.JMenu_JMenu_UID:'+inttostr(p_rJMenu.JMenu_JMenu_UID),SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503161959);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151858,'Unable to query jmenu successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151859,'Record missing from jmenu.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJMenu do begin
        //JMenu_JMenu_UID                   :=0;
        JMenu_JMenuParent_ID              :=u8Val(rs.Fields.Get_saValue('JMenu_JMenuParent_ID'));
        JMenu_JSecPerm_ID                 :=rs.Fields.Get_saValue('JMenu_JSecPerm_ID');
        JMenu_Name_en                     :=rs.Fields.Get_saValue('JMenu_Name_en');
        JMenu_URL                         :=rs.Fields.Get_saValue('JMenu_URL');
        JMenu_NewWindow_b                 :=rs.Fields.Get_saValue('JMenu_NewWindow_b');
        JMenu_IconSmall                   :=rs.Fields.Get_saValue('JMenu_IconSmall');
        JMenu_IconLarge                   :=rs.Fields.Get_saValue('JMenu_IconLarge');
        JMenu_ValidSessionOnly_b          :=rs.Fields.Get_saValue('JMenu_ValidSessionOnly_b');
        JMenu_SEQ_u                       :=rs.Fields.Get_saValue('JMenu_SEQ_u');
        JMenu_DisplayIfNoAccess_b         :=rs.Fields.Get_saValue('JMenu_DisplayIfNoAccess_b');
        JMenu_DisplayIfValidSession_b     :=rs.Fields.Get_saValue('JMenu_DisplayIfValidSession_b');
        JMenu_IconLarge_Theme_b           :=rs.Fields.Get_saValue('JMenu_IconLarge_Theme_b');
        JMenu_IconSmall_Theme_b           :=rs.Fields.Get_saValue('JMenu_IconSmall_Theme_b');
        JMenu_ReadMore_b                  :=rs.Fields.Get_saValue('JMenu_ReadMore_b');
        JMenu_Title_en                    :=rs.Fields.Get_saValue('JMenu_Title_en');
        JMenu_Data_en                     :=rs.Fields.Get_saValue('JMenu_Data_en');
        JMenu_CreatedBy_JUser_ID          :=rs.Fields.Get_saValue('JMenu_CreatedBy_JUser_ID');
        JMenu_Created_DT                  :=rs.Fields.Get_saValue('JMenu_Created_DT');
        JMenu_ModifiedBy_JUser_ID         :=rs.Fields.Get_saValue('JMenu_ModifiedBy_JUser_ID');
        JMenu_Modified_DT                 :=rs.Fields.Get_saValue('JMenu_Modified_DT');
        JMenu_DeletedBy_JUser_ID          :=rs.Fields.Get_saValue('JMenu_DeletedBy_JUser_ID');
        JMenu_Deleted_DT                  :=rs.Fields.Get_saValue('JMenu_Deleted_DT');
        JMenu_Deleted_b                   :=rs.Fields.Get_saValue('JMenu_Deleted_b');
        JAS_Row_b                         :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113224,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jmenu(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJMenu: rtJMenu; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jmenu'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113225,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113226, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if p_rJMenu.JMenu_JMenu_UID=0 then
  begin
    bAddNew:=true;
    p_rJMenu.JMenu_JMenu_UID:=iVal(saJAS_GetNextUID);//(p_Context,'0', 'jmenu'));
    bOk:=(p_rJMenu.JMenu_JMenu_UID>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151900,'Problem getting an UID for new jmenu record.','saJAS_GetNextUID table: jmenu',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jmenu (JMenu_JMenu_UID) VALUES ('+ JAS.saDBMSUintScrub(inttostr(p_rJMenu.JMenu_JMenu_UID)) + ')';
      bOk:=rs.Open(saQry,JAS,201503162000);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151901,'Problem creating a new jmenu record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJMenu.JMenu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJMenu.JMenu_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJMenu.JMenu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJMenu.JMenu_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJMenu.JMenu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJMenu.JMenu_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmenu', inttostr(p_rJMenu.JMenu_JMenu_UID), '0',201506200281);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151902,'Problem locking jmenu record.','p_rJMenu.JMenu_JMenu_UID:'+inttostr(p_rJMenu.JMenu_JMenu_UID),SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJMenu do begin
      saQry:='UPDATE jmenu set '+
        //' JMenu_JMenu_UID='+JAS.saDBMSScrub(inttostr(JMenu_JMenu_UID))+
        ' JMenu_JMenuParent_ID='+JAS.saDBMSUIntScrub(JMenu_JMenuParent_ID)+
        ',JMenu_JSecPerm_ID='+JAS.saDBMSUIntScrub(JMenu_JSecPerm_ID)+
        ',JMenu_Name_en='+JAS.saDBMSScrub(JMenu_Name_en)+
        ',JMenu_URL='+JAS.saDBMSScrub(JMenu_URL)+
        ',JMenu_NewWindow_b='+JAS.saDBMSBoolScrub(JMenu_NewWindow_b)+
        ',JMenu_IconSmall='+JAS.saDBMSScrub(JMenu_IconSmall)+
        ',JMenu_IconLarge='+JAS.saDBMSScrub(JMenu_IconLarge)+
        ',JMenu_ValidSessionOnly_b='+JAS.saDBMSBoolScrub(JMenu_ValidSessionOnly_b)+
        ',JMenu_SEQ_u='+JAS.saDBMSUIntScrub(JMenu_SEQ_u)+
        ',JMenu_DisplayIfNoAccess_b='+JAS.saDBMSBoolScrub(JMenu_DisplayIfNoAccess_b)+
        ',JMenu_DisplayIfValidSession_b='+JAS.saDBMSBoolScrub(JMenu_DisplayIfValidSession_b)+
        ',JMenu_IconLarge_Theme_b='+JAS.saDBMSBoolScrub(JMenu_IconLarge_Theme_b)+
        ',JMenu_IconSmall_Theme_b='+JAS.saDBMSBoolScrub(JMenu_IconSmall_Theme_b)+
        ',JMenu_ReadMore_b='+JAS.saDBMSBoolScrub(JMenu_ReadMore_b)+
        ',JMenu_Title_en='+JAS.saDBMSScrub(JMenu_Title_en)+
        ',JMenu_Data_en='+JAS.saDBMSScrub(JMenu_Data_en);
        if bAddNew then
        begin
          saQry+=',JMenu_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JMenu_CreatedBy_JUser_ID)+
            ',JMenu_Created_DT='+JAS.saDBMSDateScrub(JMenu_Created_DT);
        end;
        saQry+=
        ',JMenu_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JMenu_ModifiedBy_JUser_ID)+
        ',JMenu_Modified_DT='+JAS.saDBMSDateScrub(JMenu_Modified_DT)+
        ',JMenu_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JMenu_DeletedBy_JUser_ID)+
        ',JMenu_Deleted_DT='+JAS.saDBMSDateScrub(JMenu_Deleted_DT)+
        ',JMenu_Deleted_b='+JAS.saDBMSBoolScrub(JMenu_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JMenu_JMenu_UID='+JAS.saDBMSUIntScrub(inttostr(JMenu_JMenu_UID));
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162001);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151903,'Problem updating jmenu.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jmenu', inttostr(p_rJMenu.JMenu_JMenu_UID), '0',201506200419) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151904,'Problem unlocking jmenu record.','p_rJMenu.JMenu_JMenu_UID:'+inttostr(p_rJMenu.JMenu_JMenu_UID),SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113227,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
function bJAS_Load_jmime(p_DBC: JADO_CONNECTION; var p_rJMime: rtJMime): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jmime'; sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210080407,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
//{IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210080408, sTHIS_ROUTINE_NAME);{ENDIF}
  //JAS:=p_DBC;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jmime where MIME_JMime_UID='+JAS.saDBMSUIntScrub(p_rJMime.MIME_JMime_UID);
  bOk:=true;
  //if p_bGetLock then
  //begin
  //  bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmime', p_rJMime.MIME_JMime_UID, '0',201506200282);
  //  if not bOK then
  //  begin
  //    JAS_Log(p_Context,cnLog_Error,201210080409,'Problem locking jmime record.','p_rJMime.MIME_JMime_UID:'+p_rJMime.MIME_JMime_UID,SOURCEFILE);
  //  end;
  //end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162002);
    if not bOk then
    begin
      JLog(cnLog_Error,201210080410,'Unable to query jmime successfully Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JLog(cnLog_Warn,201210080411,'Record missing from jmime. Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJMime do begin
        //MIME_JMime_UID             :=rs.Fields.Get_saValue('MIME_JMime_UID');
        MIME_Name                  :=rs.Fields.Get_saValue('MIME_Name');
        MIME_Type                  :=rs.Fields.Get_saValue('MIME_Type');
        MIME_Enabled_b             :=rs.Fields.Get_saValue('MIME_Enabled_b');
        MIME_SNR_b                 :=rs.Fields.Get_saValue('MIME_SNR_b');
        MIME_CreatedBy_JUser_ID    :=rs.Fields.Get_saValue('MIME_CreatedBy_JUser_ID');
        MIME_Created_DT            :=rs.Fields.Get_saValue('MIME_Created_DT');
        MIME_ModifiedBy_JUser_ID   :=rs.Fields.Get_saValue('MIME_ModifiedBy_JUser_ID');
        MIME_Modified_DT           :=rs.Fields.Get_saValue('MIME_Modified_DT');
        MIME_DeletedBy_JUser_ID    :=rs.Fields.Get_saValue('MIME_DeletedBy_JUser_ID');
        MIME_Deleted_DT            :=rs.Fields.Get_saValue('MIME_Deleted_DT');
        MIME_Deleted_b             :=rs.Fields.Get_saValue('MIME_Deleted_b');
        JAS_Row_b                  :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210080412,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jmime(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJMime: rtJMime; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jmime'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210080413,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210080414, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJMime.MIME_JMime_UID)=0 then
  begin
    bAddNew:=true;
    p_rJMime.MIME_JMime_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jmodc');
    bOk:=(u8Val(p_rJMime.MIME_JMime_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080415,'Problem getting an UID for new jmime record.','saJAS_GetNextUID table: jmime',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jmodc (MIME_JMime_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJMime.MIME_JMime_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162003);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201210080416,'Problem creating a new jmime record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJMime.MIME_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJMime.MIME_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJMime.MIME_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJMime.MIME_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJMime.MIME_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJMime.MIME_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmime', p_rJMime.MIME_JMime_UID, '0',201506200283);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080417,'Problem locking jmime record.','p_rJMime.MIME_JMime_UID:'+p_rJMime.MIME_JMime_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJMime do begin
      saQry:='UPDATE jmime set '+
        ' MIME_JMime_UID='+JAS.saDBMSUIntScrub(MIME_JMime_UID)+
        ',MIME_Name='+JAS.saDBMSScrub(MIME_Name)+
        ',MIME_Type='+JAS.saDBMSScrub(MIME_Type)+
        ',MIME_Enabled_b='+JAS.saDBMSBoolScrub(MIME_Enabled_b)+
        ',MIME_SNR_b='+JAS.saDBMSBoolScrub(MIME_SNR_b);
      if(bAddNew)then
      begin
        saQry+=
          ',MIME_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(MIME_CreatedBy_JUser_ID)+
          ',MIME_Created_DT='+JAS.saDBMSDateScrub(MIME_Created_DT);
      end;
      saQry+=
        ',MIME_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(MIME_ModifiedBy_JUser_ID)+
        ',MIME_Modified_DT='+JAS.saDBMSDateScrub(MIME_Modified_DT)+
        ',MIME_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(MIME_DeletedBy_JUser_ID)+
        ',MIME_Deleted_DT='+JAS.saDBMSDateScrub(MIME_Deleted_DT)+
        ',MIME_Deleted_b='+JAS.saDBMSboolScrub(MIME_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE MIME_JMime_UID='+JAS.saDBMSUIntScrub(MIME_JMime_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162004);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080418,'Problem updating jmime.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jmime', p_rJMime.MIME_JMime_UID, '0',201506200420) then
      begin
        JAS_Log(p_Context,cnLog_Error,201210080419,'Problem unlocking jmime record.','p_rJMime.MIME_JMime_UID:'+p_rJMime.MIME_JMime_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210080420,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
function bJAS_Load_jmodc(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModC: rtJModC; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jmodc'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113228,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113229, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jblokfield where JModC_JModC_UID='+JAS.saDBMSUIntScrub(p_rJModC.JModC_JModC_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmodc', p_rJModC.JModC_JModC_UID, '0',201506200284);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100732,'Problem locking jmodc record.','p_rJModC.JModC_JModC_UID:'+p_rJModC.JModC_JModC_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162005);
    if not bOk then 
    begin
      JAS_Log(p_Context,cnLog_Error,201002151905,'Unable to query jmodc successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151906,'Record missing from jmodc.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJModC do begin
        //JModC_JModC_UID:=rs.Fields.Get_saValue('');
        JModC_JInstalled_ID:=rs.Fields.Get_saValue('JModC_JInstalled_ID');
        JModC_Column_ID:=rs.Fields.Get_saValue('JModC_Column_ID');
        JModC_Row_ID:=rs.Fields.Get_saValue('JModC_Row_ID');
        JModC_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JModC_CreatedBy_JUser_ID');
        JModC_Created_DT                 :=rs.Fields.Get_saValue('JModC_Created_DT');
        JModC_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JModC_ModifiedBy_JUser_ID');
        JModC_Modified_DT                :=rs.Fields.Get_saValue('JModC_Modified_DT');
        JModC_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JModC_DeletedBy_JUser_ID');
        JModC_Deleted_DT                 :=rs.Fields.Get_saValue('JModC_Deleted_DT');
        JModC_Deleted_b                  :=rs.Fields.Get_saValue('JModC_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113230,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jmodc(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModC: rtJModC; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jmodc'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113231,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113232, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJModC.JModC_JModC_UID)=0 then
  begin
    bAddNew:=true;
    p_rJModC.JModC_JModC_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jmodc');
    bOk:=(u8Val(p_rJModC.JModC_JModC_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151907,'Problem getting an UID for new jmodc record.','saJAS_GetNextUID table: jmodc',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jmodc (JModC_JModC_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJModC.JModC_JModC_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162006);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151908,'Problem creating a new jmodc record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJModC.JModC_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJModC.JModC_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJModC.JModC_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJModC.JModC_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJModC.JModC_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJModC.JModC_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmodc', p_rJModC.JModC_JModC_UID, '0',201506200285);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151909,'Problem locking jmodc record.','p_rJModC.JModC_JModC_UID:'+p_rJModC.JModC_JModC_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJModC do begin
      saQry:='UPDATE jmodc set '+
        //' JModC_JModC_UID='+JAS.saDBMSScrub()+
        'JModC_JInstalled_ID='+JAS.saDBMSUIntScrub(JModC_JInstalled_ID)+
        ',JModC_Column_ID='+JAS.saDBMSUIntScrub(JModC_Column_ID)+
        ',JModC_Row_ID='+JAS.saDBMSUIntScrub(JModC_Row_ID);
        if(bAddNew)then
        begin
          saQry+=',JModC_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JModC_CreatedBy_JUser_ID)+
          ',JModC_Created_DT='+JAS.saDBMSDateScrub(JModC_Created_DT);
        end;
        saQry+=
        ',JModC_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JModC_ModifiedBy_JUser_ID)+
        ',JModC_Modified_DT='+JAS.saDBMSDateScrub(JModC_Modified_DT)+
        ',JModC_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JModC_DeletedBy_JUser_ID)+
        ',JModC_Deleted_DT='+JAS.saDBMSDateScrub(JModC_Deleted_DT)+
        ',JModC_Deleted_b='+JAS.saDBMSBoolScrub(JModC_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JModC_JModC_UID='+JAS.saDBMSUIntScrub(JModC_JModC_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162007);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151910,'Problem updating jmodc.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jmodc', p_rJModC.JModC_JModC_UID, '0',201506200421) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151911,'Problem unlocking jmodc record.','p_rJModC.JModC_JModC_UID:'+p_rJModC.JModC_JModC_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113233,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









//=============================================================================
function bJAS_Load_jmodule(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModule: rtJModule; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jmodule'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113234,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113235, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jmodule where JModu_JModule_UID='+JAS.saDBMSUIntScrub(p_rJModule.JModu_JModule_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmodule', p_rJModule.JModu_JModule_UID, '0',201506200286);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100733,'Problem locking jmodule record.','p_rJModule.JModu_JModule_UID:'+p_rJModule.JModu_JModule_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162008);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151912,'Unable to query jmodule successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151913,'Record missing from jmodule.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJModule do begin
        //JModu_JModule_UID:=rs.Fields.Get_saValue('');
        JModu_Name:=rs.Fields.Get_saValue('JModu_Name');
        JModu_Version_Major_u            :=rs.Fields.Get_saValue('JModu_Version_Major_u');
        JModu_Version_Minor_u            :=rs.Fields.Get_saValue('JModu_Version_Minor_u');
        JModu_Version_Revision_u         :=rs.Fields.Get_saValue('JModu_Version_Revision_u');
        JModu_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JModu_CreatedBy_JUser_ID');
        JModu_Created_DT                 :=rs.Fields.Get_saValue('JModu_Created_DT');
        JModu_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JModu_ModifiedBy_JUser_ID');
        JModu_Modified_DT                :=rs.Fields.Get_saValue('JModu_Modified_DT');
        JModu_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JModu_DeletedBy_JUser_ID');
        JModu_Deleted_DT                 :=rs.Fields.Get_saValue('JModu_Deleted_DT');
        JModu_Deleted_b                  :=rs.Fields.Get_saValue('JModu_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113236,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jmodule(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModule: rtJModule; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jmodule'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113237,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113238, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJModule.JModu_JModule_UID)=0 then
  begin
    bAddNew:=true;
    p_rJModule.JModu_JModule_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jmodule');
    bOk:=(u8Val(p_rJModule.JModu_JModule_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151914,'Problem getting an UID for new jmodule record.','saJAS_GetNextUID table: jmodule',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jmodule (JModu_JModule_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJModule.JModu_JModule_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162009);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151915,'Problem creating a new jmodule record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJModule.JModu_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJModule.JModu_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJModule.JModu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJModule.JModu_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJModule.JModu_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJModule.JModu_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmodule', p_rJModule.JModu_JModule_UID, '0',201506200287);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151916,'Problem locking jmodule record.','p_rJModule.JModu_JModule_UID:'+p_rJModule.JModu_JModule_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJModule do begin
      saQry:='UPDATE jmodule set '+
        //' JModu_JModule_UID='+JAS.saDBMSScrub()+
        'JModu_Name='+JAS.saDBMSScrub(JModu_Name)+
        ',JModu_Version_Major_u='+JAS.saDBMSUIntScrub(JModu_Version_Major_u)+
        ',JModu_Version_Minor_u='+JAS.saDBMSUIntScrub(JModu_Version_Minor_u)+
        ',JModu_Version_Revision_u='+JAS.saDBMSUIntScrub(JModu_Version_Revision_u);
        if(bAddNew)then
        begin
          saQry+=',JModu_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JModu_CreatedBy_JUser_ID)+
          ',JModu_Created_DT='+JAS.saDBMSDateScrub(JModu_Created_DT);
        end;
        saQry+=
        ',JModu_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JModu_ModifiedBy_JUser_ID)+
        ',JModu_Modified_DT='+JAS.saDBMSDateScrub(JModu_Modified_DT)+
        ',JModu_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JModu_DeletedBy_JUser_ID)+
        ',JModu_Deleted_DT='+JAS.saDBMSDateScrub(JModu_Deleted_DT)+
        ',JModu_Deleted_b='+JAS.saDBMSBoolScrub(JModu_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JModu_JModule_UID='+JAS.saDBMSUIntScrub(JModu_JModule_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162010);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151917,'Problem updating jmodule.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jmodule', p_rJModule.JModu_JModule_UID, '0',201506200422) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151918,'Problem unlocking jmodule record.','p_rJModule.JModu_JModule_UID:'+p_rJModule.JModu_JModule_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113239,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
//---------------------------------------------------------------------------





//---------------------------------------------------------------------------
// jmoduleconfig
//---------------------------------------------------------------------------
//=============================================================================
function bJAS_Load_jmoduleconfig(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModuleConfig: rtJModuleConfig; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jmoduleconfig'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113240,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113241, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jmoduleconfig where JMCfg_JModuleConfig_UID='+JAS.saDBMSUintScrub(p_rJModuleConfig.JMCfg_JModuleConfig_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmoduleconfig', p_rJModuleConfig.JMCfg_JModuleConfig_UID, '0',201506200288);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006132104,'Problem locking jmoduleconfig record.','p_rJModuleConfig.JMCfg_JModuleConfig_UID:'+p_rJModuleConfig.JMCfg_JModuleConfig_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162011);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201006132105,'Unable to query jmoduleconfig successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201006132106,'Record missing from jmoduleconfig.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJModuleConfig do begin
        //JMCfg_JModuleConfig_UID   :=rs.Fields.Get_saValue('JMCfg_JModuleConfig_UID  ');
        JMCfg_JModuleSetting_ID   :=rs.Fields.Get_saValue('JMCfg_JModuleSetting_ID');
        JMCfg_Value               :=rs.Fields.Get_saValue('JMCfg_Value');
        JMCfg_JNote_ID           :=rs.Fields.Get_saValue('JMCfg_JNote_ID');
        JMCfg_JInstalled_ID       :=rs.Fields.Get_saValue('JMCfg_JInstalled_ID');
        JMCfg_JUser_ID            :=rs.Fields.Get_saValue('JMCfg_JUser_ID');
        JMCfg_Read_JSecPerm_ID    :=rs.Fields.Get_saValue('JMCfg_Read_JSecPerm_ID');
        JMCfg_Write_JSecPerm_ID   :=rs.Fields.Get_saValue('JMCfg_Write_JSecPerm_ID');
        JMCfg_CreatedBy_JUser_ID  :=rs.Fields.Get_saValue('JMCfg_CreatedBy_JUser_ID');
        JMCfg_Created_DT          :=rs.Fields.Get_saValue('JMCfg_Created_DT');
        JMCfg_ModifiedBy_JUser_ID :=rs.Fields.Get_saValue('JMCfg_ModifiedBy_JUser_ID');
        JMCfg_Modified_DT         :=rs.Fields.Get_saValue('JMCfg_Modified_DT');
        JMCfg_DeletedBy_JUser_ID  :=rs.Fields.Get_saValue('JMCfg_DeletedBy_JUser_ID');
        JMCfg_Deleted_DT          :=rs.Fields.Get_saValue('JMCfg_Deleted_DT');
        JMCfg_Deleted_b           :=rs.Fields.Get_saValue('JMCfg_Deleted_b');
        JAS_Row_b                 :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113242,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jmoduleconfig(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModuleConfig: rtJModuleConfig; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jmoduleconfig'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113243,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113244, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJModuleConfig.JMCfg_JModuleConfig_UID)=0 then
  begin
    bAddNew:=true;
    p_rJModuleConfig.JMCfg_JModuleConfig_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jmoduleconfig');
    bOk:=(u8Val(p_rJModuleConfig.JMCfg_JModuleConfig_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201006132107,'Problem getting an UID for new jmoduleconfig record.','saJAS_GetNextUID table: jmoduleconfig',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jmoduleconfig (JMCfg_JModuleConfig_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJModuleConfig.JMCfg_JModuleConfig_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162012);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201006132108,'Problem creating a new jmoduleconfig record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJModuleConfig.JMCfg_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJModuleConfig.JMCfg_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJModuleConfig.JMCfg_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJModuleConfig.JMCfg_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJModuleConfig.JMCfg_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJModuleConfig.JMCfg_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmoduleconfig', p_rJModuleConfig.JMCfg_JModuleConfig_UID, '0',201506200289);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006132109,'Problem locking jmoduleconfig record.','p_rJModuleConfig.JMCfg_JModuleConfig_UID:'+p_rJModuleConfig.JMCfg_JModuleConfig_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJModuleConfig do begin
      saQry:='UPDATE jmoduleconfig set '+
        //', JMCfg_JModuleConfig_UID   ='+JAS.saDBMSScrub()+
        'JMCfg_JModuleSetting_ID='      +JAS.saDBMSUintScrub(JMCfg_JModuleSetting_ID)+
        ',JMCfg_Value='                 +JAS.saDBMSScrub(JMCfg_Value)+
        ',JMCfg_JNote_ID='             +JAS.saDBMSUIntScrub(JMCfg_JNote_ID)+
        ',JMCfg_JInstalled_ID='         +JAS.saDBMSUIntScrub(JMCfg_JInstalled_ID)+
        ',JMCfg_JUser_ID='              +JAS.saDBMSUIntScrub(JMCfg_JUser_ID)+
        ',JMCfg_Read_JSecPerm_ID='      +JAS.saDBMSUIntScrub(JMCfg_Read_JSecPerm_ID)+
        ',JMCfg_Write_JSecPerm_ID='     +JAS.saDBMSUIntScrub(JMCfg_Write_JSecPerm_ID);
        if(bAddNew)then
        begin
          saQry+=
          ',JMCfg_CreatedBy_JUser_ID='  +JAS.saDBMSUIntScrub(JMCfg_CreatedBy_JUser_ID)+
          ',JMCfg_Created_DT='          +JAS.saDBMSDateScrub(JMCfg_Created_DT);
        end;
        saQry+=
        ',JMCfg_ModifiedBy_JUser_ID='  +JAS.saDBMSUIntScrub(JMCfg_ModifiedBy_JUser_ID)+
        ',JMCfg_Modified_DT='           +JAS.saDBMSDateScrub(JMCfg_Modified_DT)+
        ',JMCfg_DeletedBy_JUser_ID='    +JAS.saDBMSUIntScrub(JMCfg_DeletedBy_JUser_ID)+
        ',JMCfg_Deleted_DT='            +JAS.saDBMSDateScrub(JMCfg_Deleted_DT)+
        ',JMCfg_Deleted_b='             +JAS.saDBMSBoolScrub(JMCfg_Deleted_b)+
        ',JAS_Row_b='                   +JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JMCfg_JModuleConfig_UID='+JAS.saDBMSUIntScrub(JMCfg_JModuleConfig_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162013);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201006132110,'Problem updating jmoduleconfig.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jmoduleconfig', p_rJModuleConfig.JMCfg_JModuleConfig_UID, '0',201506200423) then
      begin
        JAS_Log(p_Context,cnLog_Error,201006132111,'Problem unlocking jmoduleconfig record.','p_rJModuleConfig.JMCfg_JModuleConfig_UID:'+p_rJModuleConfig.JMCfg_JModuleConfig_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113245,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
//---------------------------------------------------------------------------



//---------------------------------------------------------------------------
// jmodulesetting
//---------------------------------------------------------------------------
//=============================================================================
function bJAS_Load_jmodulesetting(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModuleSetting: rtJModuleSetting; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jmodulesetting'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113246,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113247, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jmodulesetting where JMSet_JModuleSetting_UID='+JAS.saDBMSUIntScrub(p_rJModuleSetting.JMSet_JModuleSetting_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmodulesetting', p_rJModuleSetting.JMSet_JModuleSetting_UID, '0',201506200290);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006132112,'Problem locking jmodulesetting record.','p_rJModuleSetting.JMSet_JModuleSetting_UID:'+p_rJModuleSetting.JMSet_JModuleSetting_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162014);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201006132113,'Unable to query jmodulesetting successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201006132114,'Record missing from jmodulesetting.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJModuleSetting do begin
        //JMSet_JModuleSetting_UID  :=rs.Fields.Get_saValue('JMSet_JModuleSetting_UID');
        JMSet_Name                :=rs.Fields.Get_saValue('JMSet_Name');
        JMSet_JCaption_ID         :=rs.Fields.Get_saValue('JMSet_JCaption_ID');
        JMSet_JNote_ID           :=rs.Fields.Get_saValue('JMSet_JNote_ID');
        JMSet_JModule_ID          :=rs.Fields.Get_saValue('JMSet_JModule_ID');
        JMSet_CreatedBy_JUser_ID  :=rs.Fields.Get_saValue('JMSet_CreatedBy_JUser_ID');
        JMSet_Created_DT          :=rs.Fields.Get_saValue('JMSet_Created_DT');
        JMSet_ModifiedBy_JUser_ID :=rs.Fields.Get_saValue('JMSet_ModifiedBy_JUser_ID');
        JMSet_Modified_DT         :=rs.Fields.Get_saValue('JMSet_Modified_DT');
        JMSet_DeletedBy_JUser_ID  :=rs.Fields.Get_saValue('JMSet_DeletedBy_JUser_ID');
        JMSet_Deleted_DT          :=rs.Fields.Get_saValue('JMSet_Deleted_DT');
        JMSet_Deleted_b           :=rs.Fields.Get_saValue('JMSet_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113248,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jmodulesetting(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJModuleSetting: rtJModuleSetting; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jmodulesetting'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113249,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113250, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJModuleSetting.JMSet_JModuleSetting_UID)=0 then
  begin
    bAddNew:=true;
    p_rJModuleSetting.JMSet_JModuleSetting_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jmodulesetting');
    bOk:=(u8Val(p_rJModuleSetting.JMSet_JModuleSetting_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201006132115,'Problem getting an UID for new jmodulesetting record.','saJAS_GetNextUID table: jmodulesetting',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jmodulesetting (JMSet_JModuleSetting_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJModuleSetting.JMSet_JModuleSetting_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162015);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201006132116,'Problem creating a new jmodulesetting record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJModuleSetting.JMSet_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJModuleSetting.JMSet_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJModuleSetting.JMSet_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJModuleSetting.JMSet_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJModuleSetting.JMSet_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJModuleSetting.JMSet_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jmodulesetting', p_rJModuleSetting.JMSet_JModuleSetting_UID, '0',201506200291);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006132117,'Problem locking jmodulesetting record.','p_rJModuleSetting.JMSet_JModuleSetting_UID:'+p_rJModuleSetting.JMSet_JModuleSetting_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJModuleSetting do begin
      saQry:='UPDATE jmodulesetting set '+
        //',JMSet_JModuleSetting_UID='+JAS.saDBMSScrub()+
        'JMSet_Name='                +JAS.saDBMSScrub(JMSet_Name)+
        ',JMSet_JCaption_ID='         +JAS.saDBMSUintScrub(JMSet_JCaption_ID)+
        ',JMSet_JNote_ID='           +JAS.saDBMSUIntScrub(JMSet_JNote_ID)+
        ',JMSet_JModule_ID='          +JAS.saDBMSUIntScrub(JMSet_JModule_ID);
        if(bAddNew)then
        begin
          saQry+=
          ',JMSet_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JMSet_CreatedBy_JUser_ID)+
          ',JMSet_Created_DT='        +JAS.saDBMSDateScrub(JMSet_Created_DT);
        end;
        saQry+=
        ',JMSet_ModifiedBy_JUser_ID=' +JAS.saDBMSUintScrub(JMSet_ModifiedBy_JUser_ID)+
        ',JMSet_Modified_DT='         +JAS.saDBMSDateScrub(JMSet_Modified_DT)+
        ',JMSet_DeletedBy_JUser_ID='  +JAS.saDBMSUIntScrub(JMSet_DeletedBy_JUser_ID)+
        ',JMSet_Deleted_DT='          +JAS.saDBMSDateScrub(JMSet_Deleted_DT)+
        ',JMSet_Deleted_b='           +JAS.saDBMSBoolScrub(JMSet_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JMSet_JModuleSetting_UID='+JAS.saDBMSUintScrub(JMSet_JModuleSetting_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162016);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201006132118,'Problem updating jmodulesetting.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jmodulesetting', p_rJModuleSetting.JMSet_JModuleSetting_UID, '0',201506200424) then
      begin
        JAS_Log(p_Context,cnLog_Error,201006132119,'Problem unlocking jmodulesetting record.','p_rJModuleSetting.JMSet_JModuleSetting_UID:'+p_rJModuleSetting.JMSet_JModuleSetting_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113251,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================










//=============================================================================
function bJAS_Load_jnote(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJNote: rtJNote; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jnote'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113252,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113253, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jnote where JNote_JNote_UID='+JAS.saDBMSUIntScrub(p_rJNote.JNote_JNote_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jnote', p_rJNote.JNote_JNote_UID, '0',201506200292);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100734,'Problem locking jnote record.','p_rJNote.JNote_JNote_UID:'+p_rJNote.JNote_JNote_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162017);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151919,'Unable to query jnote successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151920,'Record missing from jnote.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJNote do begin
        //JNote_JNote_UID:=rs.Fields.Get_saValue('JNote_JNote_UID');
        JNote_JTable_ID           :=rs.Fields.Get_saValue('JNote_JTable_ID');
        JNote_JColumn_ID          :=rs.Fields.Get_saValue('JNote_JColumn_ID');
        JNote_Row_ID              :=rs.Fields.Get_saValue('JNote_Row_ID');
        JNote_Orphan_b            :=rs.Fields.Get_saValue('JNote_Orphan_b');
        JNote_en                  :=rs.Fields.Get_saValue('JNote_en');
        JNote_CreatedBy_JUser_ID  :=rs.Fields.Get_saValue('JNote_CreatedBy_JUser_ID');
        JNote_Created_DT          :=rs.Fields.Get_saValue('JNote_Created_DT');
        JNote_ModifiedBy_JUser_ID :=rs.Fields.Get_saValue('JNote_ModifiedBy_JUser_ID');
        JNote_Modified_DT         :=rs.Fields.Get_saValue('JNote_Modified_DT');
        JNote_DeletedBy_JUser_ID  :=rs.Fields.Get_saValue('JNote_DeletedBy_JUser_ID');
        JNote_Deleted_DT          :=rs.Fields.Get_saValue('JNote_Deleted_DT');
        JNote_Deleted_b           :=rs.Fields.Get_saValue('JNote_Deleted_b');
        JAS_Row_b                 :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113254,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jnote(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJNote: rtJNote; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDATETIME;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jnote'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113255,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113256, sTHIS_ROUTINE_NAME);{$ENDIF}
  bAddNew:=false;
  DT:=now;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJNote.JNote_JNote_UID)=0 then
  begin
    bAddNew:=true;
    p_rJNote.JNote_JNote_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jnote');
    bOk:=(u8Val(p_rJNote.JNote_JNote_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151921,'Problem getting an UID for new jnote record.','saJAS_GetNextUID table: jnote',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jnote (JNote_JNote_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJNote.JNote_JNote_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162018);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151922,'Problem creating a new jnote record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJNote.JNote_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJNote.JNote_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJNote.JNote_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJNote.JNote_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
      end;
    end;
  end
  else
  begin
    p_rJNote.JNote_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
    p_rJNote.JNote_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jnote', p_rJNote.JNote_JNote_UID, '0',201506200293);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151923,'Problem locking jnote record.','p_rJNote.JNote_JNote_UID:'+p_rJNote.JNote_JNote_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJNote do begin
      saQry:='UPDATE jnote set '+
        //' JNote_JNote_UID='+JAS.saDBMSScrub()+
        'JNote_JTable_ID='           +JAS.saDBMSUIntScrub(JNote_JTable_ID)+
        ',JNote_JColumn_ID='          +JAS.saDBMSUIntScrub(JNote_JColumn_ID)+
        ',JNote_Row_ID='              +JAS.saDBMSUIntScrub(JNote_Row_ID)+
        ',JNote_Orphan_b='            +JAS.saDBMSIntScrub(JNote_Orphan_b)+
        ',JNote_en='                  +JAS.saDBMSScrub(JNote_en);
        if(bAddNew)then
        begin
          saQry+=',JNote_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JNote_CreatedBy_JUser_ID)+
          ',JNote_Created_DT='       +JAS.saDBMSDateScrub(JNote_Created_DT);
        end;
        saQry+=
        ',JNote_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JNote_ModifiedBy_JUser_ID)+
        ',JNote_Modified_DT='        +JAS.saDBMSDateScrub(JNote_Modified_DT)+
        ',JNote_DeletedBy_JUser_ID=' +JAS.saDBMSUIntScrub(JNote_DeletedBy_JUser_ID)+
        ',JNote_Deleted_DT='         +JAS.saDBMSDateScrub(JNote_Deleted_DT)+
        ',JNote_Deleted_b='          +JAS.saDBMSBoolScrub(JNote_Deleted_b)+
        ',JAS_Row_b='                +JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JNote_JNote_UID='    +JAS.saDBMSUIntScrub(JNote_JNote_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162019);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151924,'Problem updating jnote.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jnote', p_rJNote.JNote_JNote_UID, '0',201506200425) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151925,'Problem unlocking jnote record.','p_rJNote.JNote_JNote_UID:'+p_rJNote.JNote_JNote_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113257,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
function bJAS_Load_jperson(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJPerson: rtJPerson; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jperson'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113258,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113259, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jperson where JPers_JPerson_UID='+JAS.saDBMSUIntScrub(p_rJPerson.JPers_JPerson_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jperson', p_rJPerson.JPers_JPerson_UID, '0',201506200294);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100807,'Problem locking jperson record.','p_rJPerson.JPers_JPerson_UID:'+p_rJPerson.JPers_JPerson_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162020);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151933,'Unable to query jperson successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151934,'Record missing from jperson.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJPerson do begin
        //JPers_JPerson_UID:=rs.Fields.Get_saValue('JPers_JPerson_UID');
        JPers_Desc                        :=rs.Fields.Get_saValue('JPers_Desc');
        JPers_NameSalutation              :=rs.Fields.Get_saValue('JPers_NameSalutation');
        JPers_NameFirst                   :=rs.Fields.Get_saValue('JPers_NameFirst');
        JPers_NameMiddle                  :=rs.Fields.Get_saValue('JPers_NameMiddle');
        JPers_NameLast                    :=rs.Fields.Get_saValue('JPers_NameLast');
        JPers_NameSuffix                  :=rs.Fields.Get_saValue('JPers_NameSuffix');
        JPers_NameDear                    :=rs.Fields.Get_saValue('JPers_NameDear');
        JPers_Gender                      :=rs.Fields.Get_saValue('JPers_Gender');
        JPers_Private_b                   :=rs.Fields.Get_saValue('JPers_Private_b');
        JPers_Addr1                       :=rs.Fields.Get_saValue('JPers_Addr1');
        JPers_Addr2                       :=rs.Fields.Get_saValue('JPers_Addr2');
        JPers_Addr3                       :=rs.Fields.Get_saValue('JPers_Addr3');
        JPers_City                        :=rs.Fields.Get_saValue('JPers_City');
        JPers_State                       :=rs.Fields.Get_saValue('JPers_State');
        JPers_PostalCode                  :=rs.Fields.Get_saValue('JPers_PostalCode');
        JPers_Country                     :=rs.Fields.Get_saValue('JPers_Country');
        JPers_Home_Email                  :=rs.Fields.Get_saValue('JPers_Home_Email');
        JPers_Home_Phone                  :=rs.Fields.Get_saValue('JPers_Home_Phone');
        JPers_Latitude_d                  :=rs.Fields.Get_saValue('JPers_Latitude_d');
        JPers_Longitude_d                 :=rs.Fields.Get_saValue('JPers_Longitude_d');
        JPers_Mobile_Phone                :=rs.Fields.Get_saValue('JPers_Mobile_Phone');
        JPers_Private_b                   :=rs.Fields.Get_saValue('JPers_Private_b');
        JPers_Work_Email                  :=rs.Fields.Get_saValue('JPers_Work_Email');
        JPers_Work_Phone                  :=rs.Fields.Get_saValue('JPers_Work_Phone');
        JPers_Primary_Company_ID          :=rs.Fields.Get_saValue('JPers_Primary_Company_ID');
        JPers_Customer_b                  :=rs.Fields.Get_saValue('JPers_Customer_b');
        JPers_Vendor_b                    :=rs.Fields.Get_saValue('JPers_Vendor_b');
        JPers_DOB_DT                      :=rs.Fields.Get_saValue('JPers_DOB_DT');
        JPers_CC                          :=rs.fields.Get_saValue('JPers_CC');
        JPers_CCExpire                    :=rs.fields.Get_saValue('JPers_CCExpire');
        JPers_CCSecCode                   :=rs.Fields.Get_saValue('JPers_CCSecCode');
        JPers_CreatedBy_JUser_ID          :=rs.Fields.Get_saValue('JPers_CreatedBy_JUser_ID');
        JPers_Created_DT                  :=rs.Fields.Get_saValue('JPers_Created_DT');
        JPers_ModifiedBy_JUser_ID         :=rs.Fields.Get_saValue('JPers_ModifiedBy_JUser_ID');
        JPers_Modified_DT                 :=rs.Fields.Get_saValue('JPers_Modified_DT');
        JPers_DeletedBy_JUser_ID          :=rs.Fields.Get_saValue('JPers_DeletedBy_JUser_ID');
        JPers_Deleted_DT                  :=rs.Fields.Get_saValue('JPers_Deleted_DT');
        JPers_Deleted_b                   :=rs.Fields.Get_saValue('JPers_Deleted_b');
        JAS_Row_b                         :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113260,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jperson(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJPerson: rtJPerson; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jperson'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113261,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113262, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJPerson.JPers_JPerson_UID)=0 then
  begin
    bAddNew:=true;
    p_rJPerson.JPers_JPerson_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jperson');
    bOk:=(u8Val(p_rJPerson.JPers_JPerson_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151935,'Problem getting an UID for new jperson record.','saJAS_GetNextUID table: jperson',SOURCEFILE);
    end;

    if bok then
    begin
      saQry:='INSERT INTO jperson (JPers_JPerson_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJPerson.JPers_JPerson_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162021);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151936,'Problem creating a new jperson record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJPerson.JPers_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJPerson.JPers_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJPerson.JPers_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJPerson.JPers_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJPerson.JPers_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJPerson.JPers_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;


  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jperson', p_rJPerson.JPers_JPerson_UID, '0',201506200295);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151937,'Problem locking jperson record.','p_rJPerson.JPers_JPerson_UID:'+p_rJPerson.JPers_JPerson_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJPerson do begin
      saQry:='UPDATE jperson set '+
        //'JPers_JPerson_UID='+JAS.saDBMSScrub(JPers_JPerson_UID)+
        ' JPers_Desc='                 + JAS.saDBMSScrub(JPers_Desc)+
        ',JPers_NameSalutation='       + JAS.saDBMSScrub(JPers_NameSalutation)+
        ',JPers_NameFirst='            + JAS.saDBMSScrub(JPers_NameFirst)+
        ',JPers_NameMiddle='           + JAS.saDBMSScrub(JPers_NameMiddle)+
        ',JPers_NameLast='             + JAS.saDBMSScrub(JPers_NameLast)+
        ',JPers_NameSuffix='           + JAS.saDBMSScrub(JPers_NameSuffix)+
        ',JPers_NameDear='             + JAS.saDBMSScrub(JPers_NameDear)+
        ',JPers_Gender='               + JAS.saDBMSScrub(JPers_Gender)+
        ',JPers_Private_b='            + JAS.saDBMSBoolScrub(JPers_Private_b)+
        ',JPers_Addr1='                + JAS.saDBMSScrub(JPers_Addr1)+
        ',JPers_Addr2='                + JAS.saDBMSScrub(JPers_Addr2)+
        ',JPers_Addr3='                + JAS.saDBMSScrub(JPers_Addr3)+
        ',JPers_City='                 + JAS.saDBMSScrub(JPers_City)+
        ',JPers_State='                + JAS.saDBMSScrub(JPers_State)+
        ',JPers_PostalCode='           + JAS.saDBMSScrub(JPers_PostalCode)+
        ',JPers_Country='              + JAS.saDBMSScrub(JPers_Country)+
        ',JPers_Home_Email='           + JAS.saDBMSScrub(JPers_Home_Email)+
        ',JPers_Home_Phone='           + JAS.saDBMSScrub(JPers_Home_Phone)+
        ',JPers_Latitude_d='           + JAS.saDBMSDecScrub(JPers_Latitude_d)+
        ',JPers_Longitude_d='          + JAS.saDBMSDecScrub(JPers_Longitude_d)+
        ',JPers_Mobile_Phone='         + JAS.saDBMSScrub(JPers_Mobile_Phone)+
        ',JPers_Private_b='            + JAS.saDBMSBoolScrub(JPers_Private_b)+
        ',JPers_Work_Email='           + JAS.saDBMSScrub(JPers_Work_Email)+
        ',JPers_Work_Phone='           + JAS.saDBMSScrub(JPers_Work_Phone)+
        ',JPers_Primary_Company_ID='   + JAS.saDBMSUIntScrub(JPers_Primary_Company_ID)+
        ',JPers_Customer_b='           + JAS.saDBMSBoolScrub(JPers_Customer_b)+
        ',JPers_Vendor_b='             + JAS.saDBMSBoolScrub(JPers_Vendor_b)+
        ',JPers_DOB_DT='               + JAS.saDBMSDateScrub(JPers_DOB_DT)+
        ',JPers_CC='                   + JAS.saDBMSScrub(JPers_CC)+
        ',JPers_CCExpire='             + JAS.saDBMSDateScrub(JPers_CCEXpire)+
        ',JPers_CCSecCode='            + JAS.saDBMSUIntScrub(JPers_CCSecCode);
        if(bAddNew)then
        begin
          saQry+=',JPers_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPers_CreatedBy_JUser_ID)+
          ',JPers_Created_DT='+JAS.saDBMSDateScrub(JPers_Created_DT);
        end;
        saQry+=
        ',JPers_ModifiedBy_JUser_ID='  + JAS.saDBMSUIntScrub(JPers_ModifiedBy_JUser_ID)+
        ',JPers_Modified_DT='          + JAS.saDBMSDateScrub(JPers_Modified_DT)+
        ',JPers_DeletedBy_JUser_ID='   + JAS.saDBMSUIntScrub(JPers_DeletedBy_JUser_ID)+
        ',JPers_Deleted_DT='           + JAS.saDBMSDateScrub(JPers_Deleted_DT)+
        ',JPers_Deleted_b='            + JAS.saDBMSBoolScrub(JPers_Deleted_b)+
        ',JAS_Row_b='                  + JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JPers_JPerson_UID='     + JAS.saDBMSUIntScrub(JPers_JPerson_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162022);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151938,'Problem updating jperson.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jperson', p_rJPerson.JPers_JPerson_UID, '0',201506200426) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151939,'Problem unlocking jperson record.','p_rJPerson.JPers_JPerson_UID:'+p_rJPerson.JPers_JPerson_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113263,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================























//===========================================================================================

//=============================================================================
function bJAS_Load_jpriority(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjpriority: rtjpriority; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jpriority'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113402,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113403, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jpriority where JPrio_JPriority_UID='+JAS.saDBMSUIntScrub(p_rjpriority.JPrio_JPriority_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jpriority', p_rjpriority.JPrio_JPriority_UID, '0',201506200296);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100920,'Problem locking jpriority record.','p_rjpriority.JPrio_JPriority_UID:'+p_rjpriority.JPrio_JPriority_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162023);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311855,'Unable to query jpriority successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201005311856,'Record missing from jtaskpriority.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rjpriority do begin
        //JPrio_JPriority_UID:=rs.Fields.Get_saValue('JPrio_JPriority_UID');
        JPrio_en                         :=rs.Fields.Get_saValue('JPrio_en');
        JPrio_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JPrio_CreatedBy_JUser_ID');
        JPrio_Created_DT                 :=rs.Fields.Get_saValue('JPrio_Created_DT');
        JPrio_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JPrio_ModifiedBy_JUser_ID');
        JPrio_Modified_DT                :=rs.Fields.Get_saValue('JPrio_Modified_DT');
        JPrio_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JPrio_DeletedBy_JUser_ID');
        JPrio_Deleted_DT                 :=rs.Fields.Get_saValue('JPrio_Deleted_DT');
        JPrio_Deleted_b                  :=rs.Fields.Get_saValue('JPrio_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113404,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jpriority(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjpriority: rtjpriority; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jpriority'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113405,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113406, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rjpriority.JPrio_JPriority_UID)=0 then
  begin
    bAddNew:=true;
    p_rjpriority.JPrio_JPriority_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jtaskpriority');
    bOk:=(u8Val(p_rjpriority.JPrio_JPriority_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311857,'Problem getting an UID for new jpriority record.','saJAS_GetNextUID table: jpriority',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jpriority (JPrio_JPriority_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rjpriority.JPrio_JPriority_UID)+ ')';
      bOk:=rs.Open(saQry,JAS,201503162024);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311858,'Problem creating a new jpriority record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rjPriority.JPrio_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rjPriority.JPrio_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rjPriority.JPrio_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rjPriority.JPrio_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rjpriority.JPrio_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rjpriority.JPrio_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jpriority', p_rjpriority.JPrio_JPriority_UID, '0',201506200297);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311859,'Problem locking jpriority record.','p_rjpriority.JPrio_JPriority_UID:'+p_rJPriority.JPrio_JPriority_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rjpriority do begin
      saQry:='UPDATE jpriority set '+
        //' JPrio_JPriority_UID='+JAS.saDBMSScrub(JPrio_JPriority_UID)+
        'JPrio_en='+JAS.saDBMSScrub(JPrio_en);
        if(bAddNew)then
        begin
          saQry+=',JPrio_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPrio_CreatedBy_JUser_ID)+
          ',JPrio_Created_DT='+JAS.saDBMSDateScrub(JPrio_Created_DT);
        end;
        saQry+=
        ',JPrio_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPrio_ModifiedBy_JUser_ID)+
        ',JPrio_Modified_DT='+JAS.saDBMSDateScrub(JPrio_Modified_DT)+
        ',JPrio_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPrio_DeletedBy_JUser_ID)+
        ',JPrio_Deleted_DT='+JAS.saDBMSDateScrub(JPrio_Deleted_DT)+
        ',JPrio_Deleted_b='+JAS.saDBMSBoolScrub(JPrio_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JPrio_JPriority_UID='+JAS.saDBMSUIntScrub(JPrio_JPriority_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162025);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311860,'Problem updating jpriority.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jpriority', p_rjpriority.JPrio_JPriority_UID, '0',201506200427) then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311861,'Problem unlocking jpriority record.','p_rjpriority.JPrio_JPriority_UID:'+p_rjpriority.JPrio_JPriority_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113407,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//===========================================================================================






















//=============================================================================
function bJAS_Load_jproduct(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProduct: rtJProduct; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jproduct'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113270,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113271, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jproduct where JProd_JProduct_UID='+JAS.saDBMSUIntScrub(p_rJProduct.JProd_JProduct_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jproduct', p_rJProduct.JProd_JProduct_UID, '0',201506200298);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100810,'Problem locking jproduct record.','p_rJProduct.JProd_JProduct_UID:'+p_rJProduct.JProd_JProduct_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162026);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151947,'Unable to query jproduct successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151948,'Record missing from jproduct.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJProduct do begin
        //JProd_JProduct_UID:=rs.Fields.Get_saValue('');
        JProd_Number:=rs.Fields.Get_saValue('JProd_Number');
        JProd_Name:=rs.Fields.Get_saValue('JProd_Name');
        JProd_Desc:=rs.Fields.Get_saValue('JProd_Desc');
        JProd_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JProd_CreatedBy_JUser_ID');
        JProd_Created_DT                 :=rs.Fields.Get_saValue('JProd_Created_DT');
        JProd_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JProd_ModifiedBy_JUser_ID');
        JProd_Modified_DT                :=rs.Fields.Get_saValue('JProd_Modified_DT');
        JProd_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JProd_DeletedBy_JUser_ID');
        JProd_Deleted_DT                 :=rs.Fields.Get_saValue('JProd_Deleted_DT');
        JProd_Deleted_b                  :=rs.Fields.Get_saValue('JProd_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113272,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jproduct(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProduct: rtJProduct; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jproduct'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113273,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113274, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJProduct.JProd_JProduct_UID)=0 then
  begin
    bAddNew:=true;
    p_rJProduct.JProd_JProduct_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jproduct');
    bOk:=(u8Val(p_rJProduct.JProd_JProduct_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151949,'Problem getting an UID for new jproduct record.','saJAS_GetNextUID table: jproduct',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jproduct (JProd_JProduct_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJProduct.JProd_JProduct_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162027);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151950,'Problem creating a new jproduct record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJProduct.JProd_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJProduct.JProd_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJProduct.JProd_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJProduct.JProd_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJProduct.JProd_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJProduct.JProd_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jproduct', p_rJProduct.JProd_JProduct_UID, '0',201506200299);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151951,'Problem locking jproduct record.','p_rJProduct.JProd_JProduct_UID:'+p_rJProduct.JProd_JProduct_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJProduct do begin
      saQry:='UPDATE jproduct set '+
        //JProd_JProduct_UID='+JAS.saDBMSScrub()+
        'JProd_Number='+JAS.saDBMSScrub(JProd_Number)+
        ',JProd_Name='+JAS.saDBMSScrub(JProd_Name)+
        ',JProd_Desc='+JAS.saDBMSScrub(JProd_Desc);
        if(bAddNew)then
        begin
          saQry+=',JProd_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JProd_CreatedBy_JUser_ID)+
          ',JProd_Created_DT='+JAS.saDBMSDateScrub(JProd_Created_DT);
        end;
        saQry+=
        ',JProd_ModifiedBy_JUser_ID='+JAS.saDBMSIntScrub(JProd_ModifiedBy_JUser_ID)+
        ',JProd_Modified_DT='+JAS.saDBMSDateScrub(JProd_Modified_DT)+
        ',JProd_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JProd_DeletedBy_JUser_ID)+
        ',JProd_Deleted_DT='+JAS.saDBMSDateScrub(JProd_Deleted_DT)+
        ',JProd_Deleted_b='+JAS.saDBMSBoolScrub(JProd_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JProd_JProduct_UID='+JAS.saDBMSUIntScrub(JProd_JProduct_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162028);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151952,'Problem updating jproduct.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jproduct', p_rJProduct.JProd_JProduct_UID, '0',201506200428) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151953,'Problem unlocking jproduct record.','p_rJProduct.JProd_JProduct_UID:'+p_rJProduct.JProd_JProduct_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113275,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
function bJAS_Load_jproductgrp(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProductGrp: rtJProductGrp; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jproductgrp'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113276,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113277, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jproductgrp where JPrdG_JProductGrp_UID='+JAS.saDBMSUIntScrub(p_rJProductGrp.JPrdG_JProductGrp_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jproductgrp', p_rJProductGrp.JPrdG_JProductGrp_UID, '0',201506200300);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100811,'Problem locking jproductgrp record.','p_rJProductGrp.JPrdG_JProductGrp_UID:'+p_rJProductGrp.JPrdG_JProductGrp_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162029);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151954,'Unable to query jproductgrp successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151955,'Record missing from jproductgrp.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJProductGrp do begin
        //JPrdG_JProductGrp_UID:=rs.Fields.Get_saValue('JPrdG_JProductGrp_UID');
        JPrdG_Name:=rs.Fields.Get_saValue('JPrdG_Name');
        JPrdG_Desc:=rs.Fields.Get_saValue('JPrdG_Desc');
        JPrdG_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JPrdG_CreatedBy_JUser_ID');
        JPrdG_Created_DT                 :=rs.Fields.Get_saValue('JPrdG_Created_DT');
        JPrdG_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JPrdG_ModifiedBy_JUser_ID');
        JPrdG_Modified_DT                :=rs.Fields.Get_saValue('JPrdG_Modified_DT');
        JPrdG_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JPrdG_DeletedBy_JUser_ID');
        JPrdG_Deleted_DT                 :=rs.Fields.Get_saValue('JPrdG_Deleted_DT');
        JPrdG_Deleted_b                  :=rs.Fields.Get_saValue('JPrdG_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113278,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jproductgroup(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProductGrp: rtJProductGrp; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jproductgroup'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113279,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113280, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJProductGrp.JPrdG_JProductGrp_UID)=0 then
  begin
    bAddNew:=true;
    p_rJProductGrp.JPrdG_JProductGrp_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jproductgrp');
    bOk:=(u8Val(p_rJProductGrp.JPrdG_JProductGrp_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151956,'Problem getting an UID for new jproductgrp record.','saJAS_GetNextUID table: jproductgrp',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jproductgrp (JPrdG_JProductGrp_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJProductGrp.JPrdG_JProductGrp_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162030);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151957,'Problem creating a new jproductgrp record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJProductGrp.JPrdG_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJProductGrp.JPrdG_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJProductGrp.JPrdG_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJProductGrp.JPrdG_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJProductGrp.JPrdG_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJProductGrp.JPrdG_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jproductgrp', p_rJProductGrp.JPrdG_JProductGrp_UID, '0',201506200301);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151958,'Problem locking jproductgrp record.','p_rJProductGrp.JPrdG_JProductGrp_UID:'+p_rJProductGrp.JPrdG_JProductGrp_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJProductGrp do begin
      saQry:='UPDATE jproductgrp set '+
        //   JPrdG_JProductGrp_UID: ansistring;
        'JPrdG_Name='+JAS.saDBMSScrub(JPrdG_Name)+
        ',JPrdG_Desc='+JAS.saDBMSScrub(JPrdG_Desc);
        if(bAddNew)then
        begin
          saQry+=',JPrdG_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPrdG_CreatedBy_JUser_ID)+
          ',JPrdG_Created_DT='+JAS.saDBMSDateScrub(JPrdG_Created_DT);
        end;
        saQry+=
        ',JPrdG_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPrdG_ModifiedBy_JUser_ID)+
        ',JPrdG_Modified_DT='+JAS.saDBMSDateScrub(JPrdG_Modified_DT)+
        ',JPrdG_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPrdG_DeletedBy_JUser_ID)+
        ',JPrdG_Deleted_DT='+JAS.saDBMSDateScrub(JPrdG_Deleted_DT)+
        ',JPrdG_Deleted_b='+JAS.saDBMSBoolScrub(JPrdG_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JPrdG_JProductGrp_UID='+JAS.saDBMSUIntScrub(JPrdG_JProductGrp_UID);
    end;//with

    bOk:=rs.Open(saQry, JAS,201503162030);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151959,'Problem updating jproductgrp.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jproductgrp', p_rJProductGrp.JPrdG_JProductGrp_UID, '0',201506200429) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152000,'Problem unlocking jproductgrp record.','p_rJProductGrp.JPrdG_JProductGrp_UID:'+p_rJProductGrp.JPrdG_JProductGrp_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113281,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
function bJAS_Load_jproductqty(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProductQty: rtJProductQty; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jproductqty'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113282,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113283, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jproductqty where JPrdQ_JProductQty_UID='+JAS.saDBMSUIntScrub(p_rJProductQty.JPrdQ_JProductQty_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jproductqty', p_rJProductQty.JPrdQ_JProductQty_UID, '0',201506200302);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100813,'Problem locking jproductqty record.','p_rJProductQty.JPrdQ_JProductQty_UID:'+p_rJProductQty.JPrdQ_JProductQty_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162031);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152001,'Unable to query jproductqty successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152002,'Record missing from jproductqty.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJProductQty do begin
        //JPrdQ_JProductQty_UID:=rs.Fields.Get_saValue('');
        JPrdQ_Location_JCompany_ID:=rs.Fields.Get_saValue('JPrdQ_Location_JCompany_ID');
        JPrdQ_QtyOnHand_d         :=rs.Fields.Get_saValue('JPrdQ_QtyOnHand_d');
        JPrdQ_QtyOnOrder_d        :=rs.Fields.Get_saValue('JPrdQ_QtyOnOrder_d');
        JPrdQ_QtyOnBackOrder_d    :=rs.Fields.Get_saValue('JPrdQ_QtyOnBackOrder_d');
        JPrdQ_JProduct_ID         :=rs.Fields.Get_saValue('JPrdQ_JProduct_ID');
        JPrdQ_CreatedBy_JUser_ID  :=rs.Fields.Get_saValue('JPrdQ_CreatedBy_JUser_ID');
        JPrdQ_Created_DT          :=rs.Fields.Get_saValue('JPrdQ_Created_DT');
        JPrdQ_ModifiedBy_JUser_ID :=rs.Fields.Get_saValue('JPrdQ_ModifiedBy_JUser_ID');
        JPrdQ_Modified_DT         :=rs.Fields.Get_saValue('JPrdQ_Modified_DT');
        JPrdQ_DeletedBy_JUser_ID  :=rs.Fields.Get_saValue('JPrdQ_DeletedBy_JUser_ID');
        JPrdQ_Deleted_DT          :=rs.Fields.Get_saValue('JPrdQ_Deleted_DT');
        JPrdQ_Deleted_b           :=rs.Fields.Get_saValue('JPrdQ_Deleted_b');
        JAS_Row_b                 :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113284,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jproductqty(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJProductQty: rtJProductQty; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jproductqty'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113285,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113286, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJProductQty.JPrdQ_JProductQty_UID)=0 then
  begin
    bAddNew:=true;
    p_rJProductQty.JPrdQ_JProductQty_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jproductqty');
    bOk:=(u8Val(p_rJProductQty.JPrdQ_JProductQty_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152003,'Problem getting an UID for new jproductqty record.','saJAS_GetNextUID table: jproductqty',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jproductqty (JPrdQ_JProductQty_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJProductQty.JPrdQ_JProductQty_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162032);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152004,'Problem creating a new jblokfield record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJProductQty.JPrdQ_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJProductQty.JPrdQ_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJProductQty.JPrdQ_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJProductQty.JPrdQ_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJProductQty.JPrdQ_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJProductQty.JPrdQ_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jproductqty', p_rJProductQty.JPrdQ_JProductQty_UID, '0',201506200303);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152005,'Problem locking jproductqty record.','p_rJProductQty.JPrdQ_JProductQty_UID:'+p_rJProductQty.JPrdQ_JProductQty_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJProductQty do begin
      saQry:='UPDATE jproductqty set '+
        //' JPrdQ_JProductQty_UID='+JAS.saDBMSScrub(JPrdQ_JProductQty_UID)+
        'JPrdQ_Location_JCompany_ID='+JAS.saDBMSUIntScrub(JPrdQ_Location_JCompany_ID)+
        ',JPrdQ_QtyOnHand_d='+JAS.saDBMSDecScrub(JPrdQ_QtyOnHand_d)+
        ',JPrdQ_QtyOnOrder_d='+JAS.saDBMSDecScrub(JPrdQ_QtyOnOrder_d)+
        ',JPrdQ_QtyOnBackOrder_d='+JAS.saDBMSDecScrub(JPrdQ_QtyOnBackOrder_d)+
        ',JPrdQ_JProduct_ID='+JAS.saDBMSDecScrub(JPrdQ_JProduct_ID);
        if(bAddNew)then
        begin
          saQry+=',JPrdQ_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPrdQ_CreatedBy_JUser_ID)+
          ',JPrdQ_Created_DT='+JAS.saDBMSDateScrub(JPrdQ_Created_DT);
        end;
        saQry+=
        ',JPrdQ_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPrdQ_ModifiedBy_JUser_ID)+
        ',JPrdQ_Modified_DT='+JAS.saDBMSDateScrub(JPrdQ_Modified_DT)+
        ',JPrdQ_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPrdQ_DeletedBy_JUser_ID)+
        ',JPrdQ_Deleted_DT='+JAS.saDBMSDateScrub(JPrdQ_Deleted_DT)+
        ',JPrdQ_Deleted_b='+JAS.saDBMSBoolScrub(JPrdQ_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JPrdQ_JProductQty_UID='+JAS.saDBMSUintScrub(JPrdQ_JProductQty_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162033);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152006,'Problem updating jproductqty.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jproductqty', p_rJProductQty.JPrdQ_JProductQty_UID, '0',201506200430) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152007,'Problem unlocking jproductqty record.','p_rJProductQty.JPrdQ_JProductQty_UID:'+p_rJProductQty.JPrdQ_JProductQty_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113287,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
//---------------------------------------------------------------------------











//=============================================================================
function bJAS_Load_jproject(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjproject: rtjproject; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jproject'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113288,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113289, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jproject where JProj_JProject_UID='+JAS.saDBMSUIntScrub(p_rJProject.JProj_JProject_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jproject', p_rJProject.JProj_JProject_UID, '0',201506200304);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100814,'Problem locking jproject record.','p_rJProject.JProj_JProject_UID:'+p_rJProject.JProj_JProject_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162034);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311806,'Unable to query jproject successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201005311807,'Record missing from jproject.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJProject do begin
        //JProj_JProject_UID         :=rs.Fields.Get_saValue('JProj_JProject_UID');
        JProj_Name                 :=rs.Fields.Get_saValue('JProj_Name');
        JProj_Owner_JUser_ID       :=rs.Fields.Get_saValue('JProj_Owner_JUser_ID');
        JProj_URL                  :=rs.Fields.Get_saValue('JProj_URL');
        JProj_URL_Stage            :=rs.Fields.Get_saValue('JProj_URL_Stage');
        JProj_JProjectStatus_ID    :=rs.Fields.Get_saValue('JProj_JProjectStatus_ID');
        JProj_JProjectPriority_ID  :=rs.Fields.Get_saValue('JProj_JProjectPriority_ID');
        JProj_JProjectCategory_ID  :=rs.Fields.Get_saValue('JProj_JProjectCategory_ID');
        JProj_Progress_PCT_d       :=rs.Fields.Get_saValue('JProj_Progress_PCT_d');
        JProj_Hours_Worked_d       :=rs.Fields.Get_saValue('JProj_Hours_Worked_d');
        JProj_Hours_Sched_d        :=rs.Fields.Get_saValue('JProj_Hours_Scheduled_d');
        JProj_Hours_Project_d      :=rs.Fields.Get_saValue('JProj_Hours_Project_d');
        JProj_Desc                 :=rs.Fields.Get_saValue('JProj_Desc');
        JProj_Start_DT             :=rs.Fields.Get_saValue('JProj_Start_DT');
        JProj_Target_End_DT        :=rs.Fields.Get_saValue('JProj_Target_End_DT');
        JProj_Actual_End_DT        :=rs.Fields.Get_saValue('JProj_Actual_End_DT');
        JProj_Target_Budget_d      :=rs.Fields.Get_saValue('JProj_Target_Budget_d');
        JProj_JCompany_ID          :=rs.Fields.Get_saValue('JProj_JCompany_ID');
        JProj_JPerson_ID           :=rs.Fields.Get_saValue('JProj_JPerson_ID');
        JProj_CreatedBy_JUser_ID   :=rs.Fields.Get_saValue('JProj_CreatedBy_JUser_ID');
        JProj_Created_DT           :=rs.Fields.Get_saValue('JProj_Created_DT');
        JProj_ModifiedBy_JUser_ID  :=rs.Fields.Get_saValue('JProj_ModifiedBy_JUser_ID');
        JProj_Modified_DT          :=rs.Fields.Get_saValue('JProj_Modified_DT');
        JProj_DeletedBy_JUser_ID   :=rs.Fields.Get_saValue('JProj_DeletedBy_JUser_ID');
        JProj_Deleted_DT           :=rs.Fields.Get_saValue('JProj_Deleted_DT');
        JProj_Deleted_b            :=rs.Fields.Get_saValue('JProj_Deleted_b');
        JAS_Row_b                  :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113290,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jproject(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjproject: rtjproject; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jproject'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113291,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113292, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJProject.JProj_JProject_UID)=0 then
  begin
    bAddNew:=true;
    p_rJProject.JProj_JProject_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jproject');
    bOk:=(u8Val(p_rJProject.JProj_JProject_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311808,'Problem getting an UID for new jproject record.','saJAS_GetNextUID table: jproject',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jproject (JProj_JProject_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJProject.JProj_JProject_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162035);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311809,'Problem creating a new jproject record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJProject.JProj_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJProject.JProj_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJProject.JProj_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJProject.JProj_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJProject.JProj_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJProject.JProj_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jproject', p_rJProject.JProj_JProject_UID, '0',201506200305);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311810,'Problem locking jproject record.','p_rJProject.JProj_JProject_UID:'+p_rJProject.JProj_JProject_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJProject do begin
      saQry:='UPDATE jproject set '+
        //' JProj_JProject_UID='+JAS.saDBMSScrub(JProj_JProject_UID)+
        'JProj_Name='+JAS.saDBMSScrub(JProj_Name)+
        ',JProj_Owner_JUser_ID='+JAS.saDBMSUIntScrub(JProj_Owner_JUser_ID)+
        ',JProj_URL='+JAS.saDBMSScrub(JProj_URL)+
        ',JProj_URL_Stage='+JAS.saDBMSScrub(JProj_URL_Stage)+
        ',JProj_JProjectStatus_ID='+JAS.saDBMSUIntScrub(JProj_JProjectStatus_ID)+
        ',JProj_JProjectPriority_ID='+JAS.saDBMSUIntScrub(JProj_JProjectPriority_ID)+
        ',JProj_JProjectCategory_ID='+JAS.saDBMSUIntScrub(JProj_JProjectCategory_ID)+
        ',JProj_Progress_PCT_d='+JAS.saDBMSDecScrub(JProj_Progress_PCT_d)+
        ',JProj_Hours_Worked_d='+JAS.saDBMSDecScrub(JProj_Hours_Worked_d)+
        ',JProj_Hours_Sched_d='+JAS.saDBMSDecScrub(JProj_Hours_Sched_d)+
        ',JProj_Hours_Project_d='+JAS.saDBMSScrub(JProj_Hours_Project_d)+
        ',JProj_Desc='+JAS.saDBMSScrub(JProj_Desc)+
        ',JProj_Start_DT='+JAS.saDBMSDateScrub(JProj_Start_DT)+
        ',JProj_Target_End_DT='+JAS.saDBMSDateScrub(JProj_Target_End_DT)+
        ',JProj_Actual_End_DT='+JAS.saDBMSDateScrub(JProj_Actual_End_DT)+
        ',JProj_Target_Budget_d='+JAS.saDBMSScrub(JProj_Target_Budget_d)+
        ',JProj_JCompany_ID='+JAS.saDBMSScrub(JProj_JCompany_ID)+
        ',JProj_JPerson_ID='+JAS.saDBMSScrub(JProj_JPerson_ID);
        if(bAddNew)then
        begin
          saQry+=',JProj_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JProj_CreatedBy_JUser_ID)+
          ',JProj_Created_DT='+JAS.saDBMSDateScrub(JProj_Created_DT);
        end;
        saQry+=
        ',JProj_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JProj_ModifiedBy_JUser_ID)+
        ',JProj_Modified_DT='+JAS.saDBMSDateScrub(JProj_Modified_DT)+
        ',JProj_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JProj_DeletedBy_JUser_ID)+
        ',JProj_Deleted_DT='+JAS.saDBMSDateScrub(JProj_Deleted_DT)+
        ',JProj_Deleted_b='+JAS.saDBMSBoolScrub(JProj_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JProj_JProject_UID='+JAS.saDBMSUIntScrub(JProj_JProject_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162036);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311811,'Problem updating jproject.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jproject', p_rJProject.JProj_JProject_UID, '0',201506200431) then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311812,'Problem unlocking jproject record.','p_rJProject.JProj_JProject_UID:'+p_rJProject.JProj_JProject_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113293,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
function bJAS_Load_jprojectcategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjprojectcategory: rtjprojectcategory; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jprojectcategory'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113294,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113295, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jprojectcategory where JPjCt_JProjectCategory_UID='+JAS.saDBMSUIntScrub(p_rJProjectCategory.JPjCt_JProjectCategory_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jprojectcategory', p_rJProjectCategory.JPjCt_JProjectCategory_UID, '0',201506200306);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100815,'Problem locking jprojectcategory record.','p_rJProjectCategory.JPjCt_JProjectCategory_UID:'+p_rJProjectCategory.JPjCt_JProjectCategory_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162037);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311813,'Unable to query jprojectcategory successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201005311814,'Record missing from jprojectcategory.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJProjectCategory do begin
        //JPjCt_JProjectCategory_UID:=rs.Fields.Get_saValue();
        JPjCt_Name:=rs.Fields.Get_saValue('JPjCt_Name');
        JPjCt_Desc:=rs.Fields.Get_saValue('JPjCt_Desc');
        JPjCt_JCaption_ID:=rs.Fields.Get_saValue('JPjCt_JCaption_ID');
        JPjCt_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JPjCt_CreatedBy_JUser_ID');
        JPjCt_Created_DT                 :=rs.Fields.Get_saValue('JPjCt_Created_DT');
        JPjCt_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JPjCt_ModifiedBy_JUser_ID');
        JPjCt_Modified_DT                :=rs.Fields.Get_saValue('JPjCt_Modified_DT');
        JPjCt_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JPjCt_DeletedBy_JUser_ID');
        JPjCt_Deleted_DT                 :=rs.Fields.Get_saValue('JPjCt_Deleted_DT');
        JPjCt_Deleted_b                  :=rs.Fields.Get_saValue('JPjCt_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113296,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jprojectcategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjprojectcategory: rtjprojectcategory; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jprojectcategory'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113297,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113298, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJProjectCategory.JPjCt_JProjectCategory_UID)=0 then
  begin
    bAddNew:=true;
    p_rJProjectCategory.JPjCt_JProjectCategory_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jprojectcategory');
    bOk:=(u8Val(p_rJProjectCategory.JPjCt_JProjectCategory_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311815,'Problem getting an UID for new jprojectcategory record.','saJAS_GetNextUID table: jprojectcategory',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jprojectcategory (JPjCt_JProjectCategory_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJProjectCategory.JPjCt_JProjectCategory_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162038);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311816,'Problem creating a new jprojectcategory record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJProjectCategory.JPjCt_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJProjectCategory.JPjCt_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJProjectCategory.JPjCt_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJProjectCategory.JPjCt_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJProjectCategory.JPjCt_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJProjectCategory.JPjCt_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jprojectcategory', p_rJProjectCategory.JPjCt_JProjectCategory_UID, '0',201506200307);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311817,'Problem locking jprojectcategory record.','p_rJProjectCategory.JPjCt_JProjectCategory_UID:'+p_rJProjectCategory.JPjCt_JProjectCategory_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJProjectCategory do begin
      saQry:='UPDATE jprojectcategory set '+
        //' JPjCt_JProjectCategory_UID='+JAS.saDBMSScrub(JPjCt_JProjectCategory_UID)+
        'JPjCt_Name='+JAS.saDBMSScrub(JPjCt_Name)+
        ',JPjCt_Desc='+JAS.saDBMSScrub(JPjCt_Desc)+
        ',JPjCt_JCaption_ID='+JAS.saDBMSUIntScrub(JPjCt_JCaption_ID);
        if(bAddNew)then
        begin
          saQry+=',JPjCt_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPjCt_CreatedBy_JUser_ID)+
          ',JPjCt_Created_DT='+JAS.saDBMSDateScrub(JPjCt_Created_DT);
        end;
        saQry+=
        ',JPjCt_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPjCt_ModifiedBy_JUser_ID)+
        ',JPjCt_Modified_DT='+JAS.saDBMSDateScrub(JPjCt_Modified_DT)+
        ',JPjCt_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JPjCt_DeletedBy_JUser_ID)+
        ',JPjCt_Deleted_DT='+JAS.saDBMSDateScrub(JPjCt_Deleted_DT)+
        ',JPjCt_Deleted_b='+JAS.saDBMSBoolScrub(JPjCt_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JPjCt_JProjectCategory_UID='+JAS.saDBMSUIntScrub(JPjCt_JProjectCategory_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162039);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311818,'Problem updating jprojectcategory.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jprojectcategory', p_rJProjectCategory.JPjCt_JProjectCategory_UID, '0',201506200432) then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311819,'Problem unlocking jprojectcategory record.','p_rJProjectCategory.JPjCt_JProjectCategory_UID:'+p_rJProjectCategory.JPjCt_JProjectCategory_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113299,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
















//=============================================================================
function bJAS_Load_JQuickLink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJQuickLink: rtJQuickLink; p_bGetLock: boolean):boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_JQuickLink'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113306,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113307, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jquicklink where JQLnk_JQuickLink_UID='+JAS.saDBMSUIntScrub(p_rJQuickLink.JQLnk_JQuickLink_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jquicklink', p_rJQuickLink.JQLnk_JQuickLink_UID, '0',201506200308);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201012201200,'Problem locking jquicklink record.','p_rJQuickLink.JQLnk_JQuickLink_UID:'+p_rJQuickLink.JQLnk_JQuickLink_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162040);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201012201201,'Unable to query jquicklink successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201012201201,'Record missing from jquicklink.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJQuickLink do begin
        //JQLnk_JQuickLink_UID        :=rs.Fields.Get_saValue('JQLnk_JQuickLink_UID');
        JQLnk_Name                    :=rs.Fields.Get_saValue('JQLnk_Name');
        JQLnk_SecPerm_ID              :=rs.Fields.Get_saValue('JQLnk_SecPerm_ID');
        JQLnk_Desc                    :=rs.Fields.Get_saValue('JQLnk_Desc');
        JQLnk_URL                     :=rs.Fields.Get_saValue('JQLnk_URL');
        JQLnk_Icon                    :=rs.Fields.Get_saValue('JQLnk_Icon');
        JQLnk_CreatedBy_JUser_ID      :=rs.Fields.Get_saValue('JQLnk_CreatedBy_JUser_ID');
        JQLnk_Created_DT              :=rs.Fields.Get_saValue('JQLnk_Created_DT');
        JQLnk_ModifiedBy_JUser_ID     :=rs.Fields.Get_saValue('JQLnk_ModifiedBy_JUser_ID');
        JQLnk_Modified_DT             :=rs.Fields.Get_saValue('JQLnk_Modified_DT');
        JQLnk_DeletedBy_JUser_ID      :=rs.Fields.Get_saValue('JQLnk_DeletedBy_JUser_ID');
        JQLnk_Deleted_b               :=rs.Fields.Get_saValue('JQLnk_Deleted_b');
        JQLnk_Deleted_DT              :=rs.Fields.Get_saValue('JQLnk_Deleted_DT');
        JQLnk_Owner_JUser_ID          :=rs.Fields.Get_saValue('JQLnk_Owner_JUser_ID');
        JQLnk_Position_u              :=rs.Fields.Get_saValue('JQLnk_Position_u');
        JQLnk_ValidSessionOnly_b      :=rs.Fields.Get_saValue('JQLnk_ValidSessionOnly_b');
        JQLnk_DisplayIfNoAccess_b     :=rs.Fields.Get_saValue('JQLnk_DisplayIfNoAccess_b');
        JQLnk_DisplayIfValidSession_b :=rs.Fields.Get_saValue('JQLnk_DisplayIfValidSession_b');
        JQLnk_RenderAsUniqueDiv_b     :=rs.Fields.Get_saValue('JQLnk_RenderAsUniqueDiv_b');
        JQLnk_Private_Memo            :=rs.Fields.Get_saValue('JQLnk_Private_Memo');
        JQLnk_Private_b               :=rs.Fields.Get_saValue('JQLnk_Private_b');
        JAS_Row_b                     :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113308,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_JQuickLink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJQuickLink: rtJQuickLink; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_JQuickLink'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113309,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113310, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJQuickLink.JQLnk_JQuickLink_UID)=0 then
  begin
    bAddNew:=true;
    p_rJQuickLink.JQLnk_JQuickLink_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jquicklink');
    bOk:=(u8Val(p_rJQuickLink.JQLnk_JQuickLink_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201012201200,'Problem getting an UID for new jquicklink record.','saJAS_GetNextUID table: jquicklink',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jquicklink (JQLnk_JQuickLink_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJQuickLink.JQLnk_JQuickLink_UID)+ ')';
      bOk:=rs.Open(saQry,JAS,201503162041);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201012201201,'Problem creating a new jquicklink record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJQuickLink.JQLnk_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJQuickLink.JQLnk_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJQuickLink.JQLnk_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJQuickLink.JQLnk_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJQuickLink.JQLnk_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJQuickLink.JQLnk_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jquicklink', p_rJQuickLink.JQLnk_JQuickLink_UID, '0',201506200309);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201012201202,'Problem locking jquicklink record.','p_rJQuickLink.JQLnk_JQuickLink_UID:'+p_rJQuickLink.JQLnk_JQuickLink_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJQuickLink do begin
      saQry:='UPDATE jquicklink set '+
        //'JQLnk_JQuickLink_UID        : ansistring;
        'JQLnk_Name='+JAS.saDBMSScrub(JQLnk_Name)+
        ',JQLnk_SecPerm_ID='+JAS.saDBMSUIntScrub(JQLnk_SecPerm_ID)+
        ',JQLnk_Desc='+JAS.saDBMSScrub(JQLnk_Desc)+
        ',JQLnk_URL='+JAS.saDBMSIntScrub(JQLnk_URL)+
        ',JQLnk_Icon='+JAS.saDBMSScrub(JQLnk_Icon)+
        ',JQLnk_Owner_JUser_ID='+JAS.saDBMSUIntScrub(JQLnk_Owner_JUser_ID);
        if(bAddNew)then
        begin
          saQry+=',JQLnk_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JQLnk_CreatedBy_JUser_ID)+
          ',JQLnk_Created_DT='+JAS.saDBMSDateScrub(JQLnk_Created_DT);
        end;
        saQry+=',JQLnk_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JQLnk_ModifiedBy_JUser_ID)+
        ',JQLnk_Modified_DT='+JAS.saDBMSDateScrub(JQLnk_Modified_DT)+
        ',JQLnk_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JQLnk_DeletedBy_JUser_ID)+
        ',JQLnk_Deleted_b='+JAS.saDBMSBoolScrub(JQLnk_Deleted_b)+
        ',JQLnk_Deleted_DT='+JAS.saDBMSDateScrub(JQLnk_Deleted_DT)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ',JQLnk_Position_u='+JAS.saDBMSIntScrub(JQLnk_Position_u)+
        ',JQLnk_ValidSessionOnly_b='+JAS.saDBMSBoolScrub(JQLnk_ValidSessionOnly_b)+
        ',JQLnk_DisplayIfNoAccess_b='+JAS.saDBMSBoolScrub(JQLnk_DisplayIfNoAccess_b)+
        ',JQLnk_DisplayIfValidSession_b='+JAS.saDBMSBoolScrub(JQLnk_DisplayIfValidSession_b)+
        ',JQLnk_RenderAsUniqueDiv_b='+JAS.saDBMSBoolScrub(JQLnk_RenderAsUniqueDiv_b)+
        ',JQLnk_Private_Memo='+JAS.saDBMSScrub(JQLnk_Private_Memo)+
        ',JQLnk_Private_b='+JAS.saDBMSBoolScrub(JQLnk_Private_b)+
        ' WHERE JQLnk_JQuickLink_UID='+JAS.saDBMSUintScrub(JQLnk_JQuickLink_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162042);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201012201203,'Problem updating jquicklink.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jquicklink', p_rJQuickLink.JQLnk_JQuickLink_UID, '0',201506200434) then
      begin
        JAS_Log(p_Context,cnLog_Error,201012201204,'Problem unlocking jquicklink record.','p_rJQuickLink.JQLnk_JQuickLink_UID:'+p_rJQuickLink.JQLnk_JQuickLink_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113311,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
























//=============================================================================
function bJAS_Load_jscreen(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJScreen: rtJScreen; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jscreen'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113312,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113313, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jscreen where JScrn_JScreen_UID='+JAS.saDBMSUIntScrub(p_rJScreen.JScrn_JScreen_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jscreen', p_rJScreen.JScrn_JScreen_UID, '0',201506200310);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100901,'Problem locking jscreen record.','p_rJScreen.JScrn_JScreen_UID:'+p_rJScreen.JScrn_JScreen_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162043);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152022,'Unable to query jscreen successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152023,'Record missing from jscreen.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJScreen do begin
        //JScrn_JScreen_UID:=rs.Fields.Get_saValue('');
        JScrn_Name                :=rs.Fields.Get_saValue('JScrn_Name');
        JScrn_JScreenType_ID      :=rs.Fields.Get_saValue('JScrn_JScreenType_ID');
        JScrn_Template            :=rs.Fields.Get_saValue('JScrn_Template');
        JScrn_ValidSessionOnly_b  :=rs.Fields.Get_saValue('JScrn_ValidSessionOnly_b');
        JScrn_Detail_JScreen_ID   :=rs.Fields.Get_saValue('JScrn_Detail_JScreen_ID');
        JScrn_Desc                :=rs.Fields.Get_saValue('JScrn_Desc');
        JScrn_JSecPerm_ID         :=rs.Fields.Get_saValue('JScrn_JSecPerm_ID');
        JScrn_JCaption_ID         :=rs.Fields.Get_saValue('JScrn_JCaption_ID');
        JScrn_IconSmall           :=rs.Fields.Get_saValue('JScrn_IconSmall');
        JScrn_IconLarge           :=rs.Fields.Get_saValue('JScrn_IconLarge');
        JScrn_TemplateMini        :=rs.Fields.Get_saValue('JScrn_TemplateMini');
        JScrn_Modify_JSecPerm_ID  :=rs.Fields.Get_saValue('JScrn_Modify_JSecPerm_ID');
        JScrn_Help_ID             :=rs.Fields.Get_saValue('JScrn_Help_ID');
        JScrn_CreatedBy_JUser_ID  :=rs.Fields.Get_saValue('JScrn_CreatedBy_JUser_ID');
        JScrn_Created_DT          :=rs.Fields.Get_saValue('JScrn_Created_DT');
        JScrn_ModifiedBy_JUser_ID :=rs.Fields.Get_saValue('JScrn_ModifiedBy_JUser_ID');
        JScrn_Modified_DT         :=rs.Fields.Get_saValue('JScrn_Modified_DT');
        JScrn_DeletedBy_JUser_ID  :=rs.Fields.Get_saValue('JScrn_DeletedBy_JUser_ID');
        JScrn_Deleted_DT          :=rs.Fields.Get_saValue('JScrn_Deleted_DT');
        JScrn_Deleted_b           :=rs.Fields.Get_saValue('JScrn_Deleted_b');
        JAS_Row_b                 :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113314,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jscreen(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJScreen: rtJScreen; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jscreen'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113315,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113316, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJScreen.JScrn_JScreen_UID)=0 then
  begin
    bAddNew:=true;
    p_rJScreen.JScrn_JScreen_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jscreen');
    bOk:=(u8Val(p_rJScreen.JScrn_JScreen_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152024,'Problem getting an UID for new jscreen record.','saJAS_GetNextUID table: jscreen',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jscreen (JScrn_JScreen_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJScreen.JScrn_JScreen_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162044);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152025,'Problem creating a new jscreen record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJScreen.JScrn_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJScreen.JScrn_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJScreen.JScrn_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJScreen.JScrn_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJScreen.JScrn_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJScreen.JScrn_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jscreen', p_rJScreen.JScrn_JScreen_UID, '0',201506200311);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152026,'Problem locking jscreen record.','p_rJScreen.JScrn_JScreen_UID:'+p_rJScreen.JScrn_JScreen_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJScreen do begin
      saQry:='UPDATE jscreen set '+
        //' JScrn_JScreen_UID='+JAS.saDBMSScrub()+
        'JScrn_Name='                  +JAS.saDBMSScrub(JScrn_Name)+
        ',JScrn_JScreenType_ID='       +JAS.saDBMSUIntScrub(JScrn_JScreenType_ID)+
        ',JScrn_Template='             +JAS.saDBMSScrub(JScrn_Template)+
        ',JScrn_ValidSessionOnly_b='   +JAS.saDBMSBoolScrub(JScrn_ValidSessionOnly_b)+
        ',JScrn_Detail_JScreen_ID='    +JAS.saDBMSUIntScrub(JScrn_Detail_JScreen_ID)+
        ',JScrn_Desc='                 +JAS.saDBMSScrub(JScrn_Desc)+
        ',JScrn_JSecPerm_ID='          +JAS.saDBMSUIntScrub(JScrn_JSecPerm_ID)+
        ',JScrn_JCaption_ID='          +JAS.saDBMSUIntScrub(JScrn_JCaption_ID)+
        ',JScrn_IconSmall='            +JAS.saDBMSScrub(JScrn_IconSmall)+
        ',JScrn_IconLarge='            +JAS.saDBMSScrub(JScrn_IconLarge)+
        ',JScrn_TemplateMini='         +JAS.saDBMSUIntScrub(JScrn_TemplateMini)+
        ',JScrn_Modify_JSecPerm_ID='   +JAS.saDBMSUintScrub(JScrn_Modify_JSecPerm_ID)+
        ',JScrn_Help_ID='             +JAS.saDBMSUintScrub(JScrn_Help_ID);
        if(bAddNew)then
        begin
          saQry+=',JScrn_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JScrn_CreatedBy_JUser_ID)+
          ',JScrn_Created_DT='         +JAS.saDBMSDateScrub(JScrn_Created_DT);
        end;
        saQry+=
        ',JScrn_ModifiedBy_JUser_ID='  +JAS.saDBMSUIntScrub(JScrn_ModifiedBy_JUser_ID)+
        ',JScrn_Modified_DT='          +JAS.saDBMSDateScrub(JScrn_Modified_DT)+
        ',JScrn_DeletedBy_JUser_ID='   +JAS.saDBMSUIntScrub(JScrn_DeletedBy_JUser_ID)+
        ',JScrn_Deleted_DT='           +JAS.saDBMSDateScrub(JScrn_Deleted_DT)+
        ',JScrn_Deleted_b='            +JAS.saDBMSBoolScrub(JScrn_Deleted_b)+
        ',JAS_Row_b='                  +JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JScrn_JScreen_UID='+JAS.saDBMSUIntScrub(JScrn_JScreen_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162045);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152027,'Problem updating jscreen.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jscreen', p_rJScreen.JScrn_JScreen_UID, '0',201506200435) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152028,'Problem unlocking jscreen record.','p_rJScreen.JScrn_JScreen_UID:'+p_rJScreen.JScrn_JScreen_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113317,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jscreentype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJScreentype: rtJScreenType; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jscreentype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113318,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113319, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jscreentype where JScTy_JScreenType_UID='+JAS.saDBMSUIntScrub(p_rJScreenType.JScTy_JScreenType_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jscreentype', p_rJScreenType.JScTy_JScreenType_UID, '0',201506200312);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100903,'Problem locking jscreentype record.','p_rJScreenType.JScTy_JScreenType_UID:'+p_rJScreenType.JScTy_JScreenType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162046);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230013,'Unable to query jscreentype successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002230014,'Record missing from jscreentype.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJScreenType do begin
        //JScTy_JScreenType_UID:=rs.Fields.Get_saValue('');
        JScTy_Name:=rs.Fields.Get_saValue('JScTy_Name');
        JScTy_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('ScTy_CreatedBy_JUser_ID');
        JScTy_Created_DT                 :=rs.Fields.Get_saValue('ScTy_Created_DT');
        JScTy_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('ScTy_ModifiedBy_JUser_ID');
        JScTy_Modified_DT                :=rs.Fields.Get_saValue('ScTy_Modified_DT');
        JScTy_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('ScTy_DeletedBy_JUser_ID');
        JScTy_Deleted_DT                 :=rs.Fields.Get_saValue('ScTy_Deleted_DT');
        JScTy_Deleted_b                  :=rs.Fields.Get_saValue('ScTy_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113320,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
function bJAS_Save_jscreentype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJScreenType: rtJScreenType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jscreentype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113321,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113322, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJScreenType.JScTy_JScreenType_UID)=0 then
  begin
    bAddNew:=true;
    p_rJScreenType.JScTy_JScreenType_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jscreentype');
    bOk:=(u8Val(p_rJScreenType.JScTy_JScreenType_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230015,'Problem getting an UID for new jscreentype record.','saJAS_GetNextUID table: jscreentype',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jscreentype (JScTy_JScreenType_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJScreenType.JScTy_JScreenType_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162047);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002230016,'Problem creating a new jscreentype record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJScreenType.JScTy_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJScreenType.JScTy_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJScreenType.JScTy_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJScreenType.JScTy_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJScreenType.JScTy_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJScreenType.JScTy_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jscreentype', p_rJScreenType.JScTy_JScreenType_UID, '0',201506200313);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230017,'Problem locking jscreentype record.','p_rJScreenType.JScTy_JScreenType_UID:'+p_rJScreenType.JScTy_JScreenType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJScreenType do begin
      saQry:='UPDATE jscreentype set '+
        //' JScTy_JScreenType_UID='+JAS.saDBMSScrub()+
        'JScTy_Name='+JAS.saDBMSScrub(JScTy_Name);
        if(bAddNew)then
        begin
          saQry+=',JScTy_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JScTy_CreatedBy_JUser_ID)+
          ', JScTy_Created_DT='+JAS.saDBMSDateScrub(JScTy_Created_DT);
        end;
        saQry+=
        ',JScTy_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JScTy_ModifiedBy_JUser_ID)+
        ',JScTy_Modified_DT='+JAS.saDBMSDateScrub(JScTy_Modified_DT)+
        ',JScTy_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JScTy_DeletedBy_JUser_ID)+
        ',JScTy_Deleted_DT='+JAS.saDBMSDateScrub(JScTy_Deleted_DT)+
        ',JScTy_Deleted_b='+JAS.saDBMSBoolScrub(JScTy_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JScTy_JScreenType_UID='+JAS.saDBMSUIntScrub(JScTy_JScreenType_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162048);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002230018,'Problem updating jscreentype.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jscreentype', p_rJScreenType.JScTy_JScreenType_UID, '0',201506200436) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002230019,'Problem unlocking jscreentype record.','p_rJScreenType.JScTy_JScreenType_UID:'+p_rJScreenType.JScTy_JScreenType_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113323,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================









//=============================================================================
function bJAS_Load_jsecgrp(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrp: rtJSecGrp; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jsecgrp'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113324,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113325, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jsecgrp where JSGrp_JSecGrp_UID='+JAS.saDBMSUIntScrub(p_rJSecGrp.JSGrp_JSecGrp_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsecgrp', p_rJSecGrp.JSGrp_JSecGrp_UID, '0',201506200314);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,2010060904,'Problem locking jsecgrp record.','p_rJSecGrp.JSGrp_JSecGrp_UID:'+p_rJSecGrp.JSGrp_JSecGrp_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162049);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152036,'Unable to query jsecgrp successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152037,'Record missing from jsecgrp.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJSecGrp do begin
        //JSGrp_JSecGrp_UID:=rs.Fields.Get_saValue('');
        JSGrp_Name:=rs.Fields.Get_saValue('JSGrp_Name');
        JSGrp_Desc:=rs.Fields.Get_saValue('JSGrp_Desc');
        JSGrp_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JSGrp_CreatedBy_JUser_ID');
        JSGrp_Created_DT                 :=rs.Fields.Get_saValue('JSGrp_Created_DT');
        JSGrp_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JSGrp_ModifiedBy_JUser_ID');
        JSGrp_Modified_DT                :=rs.Fields.Get_saValue('JSGrp_Modified_DT');
        JSGrp_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JSGrp_DeletedBy_JUser_ID');
        JSGrp_Deleted_DT                 :=rs.Fields.Get_saValue('JSGrp_Deleted_DT');
        JSGrp_Deleted_b                  :=rs.Fields.Get_saValue('JSGrp_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113326,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jsecgrp(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrp: rtJSecGrp; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jsecgrp'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113327,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113328, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJSecGrp.JSGrp_JSecGrp_UID)=0 then
  begin
    bAddNew:=true;
    p_rJSecGrp.JSGrp_JSecGrp_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jsecgrp');
    bOk:=(u8Val(p_rJSecGrp.JSGrp_JSecGrp_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152038,'Problem getting an UID for new jsecgrp record.','saJAS_GetNextUID table: jsecgrp',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jsecgrp (JSGrp_JSecGrp_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJSecGrp.JSGrp_JSecGrp_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162050);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152039,'Problem creating a new jsecgrp record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJSecGrp.JSGrp_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecGrp.JSGrp_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJSecGrp.JSGrp_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecGrp.JSGrp_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJSecGrp.JSGrp_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJSecGrp.JSGrp_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsecgrp', p_rJSecGrp.JSGrp_JSecGrp_UID, '0',201506200315);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152040,'Problem locking jsecgrp record.','p_rJSecGrp.JSGrp_JSecGrp_UID:'+p_rJSecGrp.JSGrp_JSecGrp_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJSecGrp do begin
      saQry:='UPDATE jsecgrp set '+
        //' JSGrp_JSecGrp_UID='+JAS.saDBMSScrub()+
        'JSGrp_Name='+JAS.saDBMSScrub(JSGrp_Name)+
        ',JSGrp_Desc='+JAS.saDBMSScrub(JSGrp_Desc);
        if(bAddNew)then
        begin
          saQry+=',JSGrp_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSGrp_CreatedBy_JUser_ID)+
          ',JSGrp_Created_DT='+JAS.saDBMSDateScrub(JSGrp_Created_DT);
        end;
        saQry+=
        ',JSGrp_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSGrp_ModifiedBy_JUser_ID)+
        ',JSGrp_Modified_DT='+JAS.saDBMSDateScrub(JSGrp_Modified_DT)+
        ',JSGrp_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSGrp_DeletedBy_JUser_ID)+
        ',JSGrp_Deleted_DT='+JAS.saDBMSDateScrub(JSGrp_Deleted_DT)+
        ',JSGrp_Deleted_b='+JAS.saDBMSBoolScrub(JSGrp_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JSGrp_JSecGrp_UID='+JAS.saDBMSUIntScrub(JSGrp_JSecGrp_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162051);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152041,'Problem updating jsecgrp.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jsecgrp', p_rJSecGrp.JSGrp_JSecGrp_UID, '0',201506200437) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152042,'Problem unlocking jsecgrp record.','p_rJSecGrp.JSGrp_JSecGrp_UID:'+p_rJSecGrp.JSGrp_JSecGrp_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113329,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jsecgrplink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrpLink: rtJSecGrpLink; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jsecgrplink'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113330,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113331, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jsecgrplink where JSGLk_JSecGrpLink_UID='+JAS.saDBMSUIntScrub(p_rJSecGrpLink.JSGLk_JSecGrpLink_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsecgrplink', p_rJSecGrpLink.JSGLk_JSecGrpLink_UID, '0',201506200316);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100905,'Problem locking jsecgrplink record.','p_rJSecGrpLink.JSGLk_JSecGrpLink_UID:'+p_rJSecGrpLink.JSGLk_JSecGrpLink_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162052);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152043,'Unable to query jsecgrplink successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152044,'Record missing from jsecgrplink.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJSecGrpLink do begin
        //JSGLk_JSecGrpLink_UID:=rs.Fields.Get_saValue('');
        JSGLk_JSecPerm_ID:=rs.Fields.Get_saValue('');
        JSGLk_JSecGrp_ID:=rs.Fields.Get_saValue('');
        JSGLk_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JSGLk_CreatedBy_JUser_ID');
        JSGLk_Created_DT                 :=rs.Fields.Get_saValue('JSGLk_Created_DT');
        JSGLk_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JSGLk_ModifiedBy_JUser_ID');
        JSGLk_Modified_DT                :=rs.Fields.Get_saValue('JSGLk_Modified_DT');
        JSGLk_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JSGLk_DeletedBy_JUser_ID');
        JSGLk_Deleted_DT                 :=rs.Fields.Get_saValue('JSGLk_Deleted_DT');
        JSGLk_Deleted_b                  :=rs.Fields.Get_saValue('JSGLk_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113332,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jsecgrplink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrpLink: rtJSecGrpLink; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jsecgrplink'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113333,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113334, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJSecGrpLink.JSGLk_JSecGrpLink_UID)=0 then
  begin
    bAddNew:=true;
    p_rJSecGrpLink.JSGLk_JSecGrpLink_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jsecgrplink');
    bOk:=(u8Val(p_rJSecGrpLink.JSGLk_JSecGrpLink_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152045,'Problem getting an UID for new jsecgrplink record.','saJAS_GetNextUID table: jsecgrplink',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jsecgrplink (JSGLk_JSecGrpLink_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJSecGrpLink.JSGLk_JSecGrpLink_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162053);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152046,'Problem creating a new jsecgrplink record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJSecGrpLink.JSGLk_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecGrpLink.JSGLk_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJSecGrpLink.JSGLk_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecGrpLink.JSGLk_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJSecGrpLink.JSGLk_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJSecGrpLink.JSGLk_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsecgrplink', p_rJSecGrpLink.JSGLk_JSecGrpLink_UID, '0',201506200317);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152047,'Problem locking jsecgrplink record.','p_rJSecGrpLink.JSGLk_JSecGrpLink_UID:'+p_rJSecGrpLink.JSGLk_JSecGrpLink_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJSecGrpLink do begin
      saQry:='UPDATE jsecgrplink set '+
        //'JSGLk_JSecGrpLink_UID='+JAS.saDBMSScrub(JSGLk_JSecGrpLink_UID)+
        'JSGLk_JSecPerm_ID='+JAS.saDBMSUIntScrub(JSGLk_JSecPerm_ID)+
        ',JSGLk_JSecGrp_ID='+JAS.saDBMSUIntScrub(JSGLk_JSecGrp_ID);
        if(bAddNew)then
        begin
          saQry+=',JSGLk_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSGLk_CreatedBy_JUser_ID)+
          ',JSGLk_Created_DT='+JAS.saDBMSDateScrub(JSGLk_Created_DT);
        end;
        saQry+=
        ',JSGLk_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSGLk_ModifiedBy_JUser_ID)+
        ',JSGLk_Modified_DT='+JAS.saDBMSDateScrub(JSGLk_Modified_DT)+
        ',JSGLk_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSGLk_DeletedBy_JUser_ID)+
        ',JSGLk_Deleted_DT='+JAS.saDBMSDateScrub(JSGLk_Deleted_DT)+
        ',JSGLk_Deleted_b='+JAS.saDBMSBoolScrub(JSGLk_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JSGLk_JSecGrpLink_UID='+JAS.saDBMSUINtScrub(JSGLk_JSecGrpLink_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162054);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152048,'Problem updating jsecgrplink.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jsecgrplink', p_rJSecGrpLink.JSGLk_JSecGrpLink_UID, '0',201506200438) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152049,'Problem unlocking jsecgrplink record.','p_rJSecGrpLink.JSGLk_JSecGrpLink_UID:'+p_rJSecGrpLink.JSGLk_JSecGrpLink_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113335,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
function bJAS_Load_jsecgrpuserlink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrpUserLink: rtJSecGrpUserLink; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jsecgrpuserlink'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113336,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113337, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jsecgrpuserlink where JSGUL_JSecGrpUserLink_UID='+JAS.saDBMSUIntScrub(p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsecgrpuserlink', p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID, '0',201506200318);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100906,'Problem locking jsecgrpuserlink record.','p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID:'+p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162055);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152050,'Unable to query jsecgrpuserlink successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152051,'Record missing from jsecgrpuserlink.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJSecGrpUserLink do begin
        //JSGUL_JSecGrpUserLink_UID:=rs.Fields.Get_saValue('JSGUL_JSecGrpUserLink_UID');
        JSGUL_JSecGrp_ID:=rs.Fields.Get_saValue('JSGUL_JSecGrp_ID');
        JSGUL_JUser_ID:=rs.Fields.Get_saValue('JSGUL_JUser_ID');
        JSGUL_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JSGUL_CreatedBy_JUser_ID');
        JSGUL_Created_DT                 :=rs.Fields.Get_saValue('JSGUL_Created_DT');
        JSGUL_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JSGUL_ModifiedBy_JUser_ID');
        JSGUL_Modified_DT                :=rs.Fields.Get_saValue('JSGUL_Modified_DT');
        JSGUL_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JSGUL_DeletedBy_JUser_ID');
        JSGUL_Deleted_DT                 :=rs.Fields.Get_saValue('JSGUL_Deleted_DT');
        JSGUL_Deleted_b                  :=rs.Fields.Get_saValue('JSGUL_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113338,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jsecgrpuserlink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecGrpUserLink: rtJSecGrpUserLink; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jsecgrpuserlink'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113339,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113340, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID)=0 then
  begin
    bAddNew:=true;
    p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jsecgrpuserlink');
    bOk:=(u8Val(p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152052,'Problem getting an UID for new jsecgrpuserlink record.','saJAS_GetNextUID table: jsecgrpuserlink',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jsecgrpuserlink (JSGUL_JSecGrpUserLink_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162056);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152053,'Problem creating a new jsecgrpuserlink record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJSecGrpUserLink.JSGUL_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecGrpUserLink.JSGUL_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJSecGrpUserLink.JSGUL_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecGrpUserLink.JSGUL_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJSecGrpUserLink.JSGUL_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJSecGrpUserLink.JSGUL_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsecgrpuserlink', p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID, '0',201506200319);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152054,'Problem locking jsecgrpuserlink record.','p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID:'+p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJSecGrpUserLink do begin
      saQry:='UPDATE jsecgrpuserlink set '+
        //'JSGUL_JSecGrpUserLink_UID='+JAS.saDBMSScrub()+
        'JSGUL_JSecGrp_ID='+JAS.saDBMSUIntScrub(JSGUL_JSecGrp_ID)+
        ',JSGUL_JUser_ID='+JAS.saDBMSUIntScrub(JSGUL_JUser_ID);
        if(bAddNew)then
        begin
          saQry+=',JSGUL_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSGUL_CreatedBy_JUser_ID)+
          ',JSGUL_Created_DT='+JAS.saDBMSDateScrub(JSGUL_Created_DT);
        end;
        saQry+=
        ',JSGUL_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSGUL_ModifiedBy_JUser_ID)+
        ',JSGUL_Modified_DT='+JAS.saDBMSDateScrub(JSGUL_Modified_DT)+
        ',JSGUL_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSGUL_DeletedBy_JUser_ID)+
        ',JSGUL_Deleted_DT='+JAS.saDBMSDateScrub(JSGUL_Deleted_DT)+
        ',JSGUL_Deleted_b='+JAS.saDBMSBoolScrub(JSGUL_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JSGUL_JSecGrpUserLink_UID='+JAS.saDBMSUIntScrub(JSGUL_JSecGrpUserLink_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162057);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152055,'Problem updating jsecgrpuserlink.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jsecgrpuserlink', p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID, '0',201506200439) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152056,'Problem unlocking jsecgrpuserlink record.','p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID:'+p_rJSecGrpUserLink.JSGUL_JSecGrpUserLink_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113341,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================

//=============================================================================
function bJAS_Load_jseckey(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecKey: rtJSecKey; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jseckey'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113342,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113343, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jseckey where JSKey_JSecKey_UID='+JAS.saDBMSUIntScrub(p_rJSecKey.JSKey_JSecKey_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jseckey', p_rJSecKey.JSKey_JSecKey_UID, '0',201506200320);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201009020200,'Problem locking jseckey record.','p_rJSecKey.JSKey_JSecKey_UID:'+p_rJSecKey.JSKey_JSecKey_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162058);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201009020201,'Unable to query jseckey successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201009020202,'Record missing from jseckey.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJSecKey do begin
        //JSKey_JSecKey_UID           :=rs.Fields.Get_saValue('JSKey_JSecKey_UID');
        JSKey_KeyPub                :=rs.Fields.Get_saValue('JSKey_KeyPub');
        JSKey_KeyPvt                :=rs.Fields.Get_saValue('JSKey_KeyPvt');
        JSKey_CreatedBy_JUser_ID    :=rs.Fields.Get_saValue('JSKey_CreatedBy_JUser_ID');
        JSKey_Created_DT            :=rs.Fields.Get_saValue('JSKey_Created_DT');
        JSKey_ModifiedBy_JUser_ID   :=rs.Fields.Get_saValue('JSKey_ModifiedBy_JUser_ID');
        JSKey_Modified_DT           :=rs.Fields.Get_saValue('JSKey_Modified_DT');
        JSKey_DeletedBy_JUser_ID    :=rs.Fields.Get_saValue('JSKey_DeletedBy_JUser_ID');
        JSKey_Deleted_DT            :=rs.Fields.Get_saValue('JSKey_Deleted_DT');
        JSKey_Deleted_b             :=rs.Fields.Get_saValue('JSKey_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113344,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jseckey(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecKey: rtJSecKey; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jseckey'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113345,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113346, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJSecKey.JSKey_JSecKey_UID)=0 then
  begin
    bAddNew:=true;
    p_rJSecKey.JSKey_JSecKey_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jseckey');
    bOk:=(u8Val(p_rJSecKey.JSKey_JSecKey_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201009020203,'Problem getting an UID for new jseckey record.','saJAS_GetNextUID table: jseckey',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jseckey (JSKey_JSecKey_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJSecKey.JSKey_JSecKey_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162059);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201009020204,'Problem creating a new jseckey record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJSecKey.JSKey_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecKey.JSKey_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJSecKey.JSKey_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecKey.JSKey_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJSecKey.JSKey_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJSecKey.JSKey_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jseckey', p_rJSecKey.JSKey_JSecKey_UID, '0',201506200321);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201009020205,'Problem locking jseckey record.','p_rJSecKey.JSKey_JSecKey_UID:'+p_rJSecKey.JSKey_JSecKey_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJSecKey do begin
      saQry:='UPDATE jseckey set '+
        //'JSKey_JSecKey_UID='+JAS.saDBMSScrub()+
        'JSKey_KeyPub='+JAS.saDBMSScrub(JSKey_KeyPub)+
        ',JSKey_KeyPvt='+JAS.saDBMSScrub(JSKey_KeyPvt);
        if(bAddNew)then
        begin
          saQry+=',JSKey_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSKey_CreatedBy_JUser_ID)+
          ',JSKey_Created_DT='+JAS.saDBMSDateScrub(JSKey_Created_DT);
        end;
        saQry+=
        ',JSKey_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSKey_ModifiedBy_JUser_ID)+
        ',JSKey_Modified_DT='+JAS.saDBMSDateScrub(JSKey_Modified_DT)+
        ',JSKey_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSKey_DeletedBy_JUser_ID)+
        ',JSKey_Deleted_DT='+JAS.saDBMSDateScrub(JSKey_Deleted_DT)+
        ',JSKey_Deleted_b='+JAS.saDBMSBoolScrub(JSKey_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JSKey_JSecKey_UID='+JAS.saDBMSUIntScrub(JSKey_JSecKey_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162060);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201009020206,'Problem updating jseckey.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jseckey', p_rJSecKey.JSKey_JSecKey_UID, '0',201506200440) then
      begin
        JAS_Log(p_Context,cnLog_Error,201009020207,'Problem unlocking jseckey record.','p_rJSecKey.JSKey_JSecKey_UID:'+p_rJSecKey.JSKey_JSecKey_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113347,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================



//=============================================================================
function bJAS_Load_jsecperm(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecPerm: rtJSecPerm; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jsecperm'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113348,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113349, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jsecperm where JSPrm_JSecPerm_UID='+JAS.saDBMSUintScrub(p_rJSecPerm.JSPrm_JSecPerm_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsecperm', p_rJSecPerm.JSPrm_JSecPerm_UID, '0',201506200322);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100907,'Problem locking jsecperm record.','p_rJSecPerm.JSPrm_JSecPerm_UID:'+p_rJSecPerm.JSPrm_JSecPerm_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162061);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152057,'Unable to query jsecperm successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152058,'Record missing from jsecperm.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJSecPErm do begin
        //JSPrm_JSecPerm_UID:=rs.Fields.Get_saValue('');
        JSPrm_Name:=rs.Fields.Get_saValue('JSPrm_Name');
        JSPrm_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JSPrm_CreatedBy_JUser_ID');
        JSPrm_Created_DT                 :=rs.Fields.Get_saValue('JSPrm_Created_DT');
        JSPrm_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JSPrm_ModifiedBy_JUser_ID');
        JSPrm_Modified_DT                :=rs.Fields.Get_saValue('JSPrm_Modified_DT');
        JSPrm_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JSPrm_DeletedBy_JUser_ID');
        JSPrm_Deleted_DT                 :=rs.Fields.Get_saValue('JSPrm_Deleted_DT');
        JSPrm_Deleted_b                  :=rs.Fields.Get_saValue('JSPrm_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113350,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jsecperm(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecPerm: rtJSecPerm; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jsecperm'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113351,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113352, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJSecPerm.JSPrm_JSecPerm_UID)=0 then
  begin
    bAddNew:=true;
    p_rJSecPerm.JSPrm_JSecPerm_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jsecperm');
    bOk:=(u8Val(p_rJSecPerm.JSPrm_JSecPerm_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152059,'Problem getting an UID for new jsecperm record.','saJAS_GetNextUID table: jsecperm',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jsecperm (JSPrm_JSecPerm_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJSecPerm.JSPrm_JSecPerm_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162062);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152100,'Problem creating a new jsecperm record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJSecPerm.JSPrm_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecPerm.JSPrm_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJSecPerm.JSPrm_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecPerm.JSPrm_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJSecPerm.JSPrm_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJSecPerm.JSPrm_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsecperm', p_rJSecPerm.JSPrm_JSecPerm_UID, '0',201506200323);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152101,'Problem locking jsecperm record.','p_rJSecPerm.JSPrm_JSecPerm_UID:'+p_rJSecPerm.JSPrm_JSecPerm_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJsecPerm do begin
      saQry:='UPDATE jsecperm set '+
        //' JSPrm_JSecPerm_UID='+JAS.saDBMSScrub()+
        'JSPrm_Name='+JAS.saDBMSScrub(JSPrm_Name);
        if(bAddNew)then
        begin
          saQry+=',JSPrm_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSPrm_CreatedBy_JUser_ID)+
          ',JSPrm_Created_DT='+JAS.saDBMSDateScrub(JSPrm_Created_DT);
        end;
        saQry+=
        ',JSPrm_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSPrm_ModifiedBy_JUser_ID)+
        ',JSPrm_Modified_DT='+JAS.saDBMSDateScrub(JSPrm_Modified_DT)+
        ',JSPrm_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSPrm_DeletedBy_JUser_ID)+
        ',JSPrm_Deleted_DT='+JAS.saDBMSDateScrub(JSPrm_Deleted_DT)+
        ',JSPrm_Deleted_b='+JAS.saDBMSBoolScrub(JSPrm_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JSPrm_JSecPerm_UID='+JAS.saDBMSUintScrub(JSPrm_JSecPerm_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162063);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152102,'Problem updating jsecperm.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jsecperm', p_rJSecPerm.JSPrm_JSecPerm_UID, '0',201506200441) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152103,'Problem unlocking jsecperm record.','p_rJSecPerm.JSPrm_JSecPerm_UID:'+p_rJSecPerm.JSPrm_JSecPerm_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113353,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jsecpermuserlink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecPermUserLink: rtJSecPermUserLink; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jsecpermuserlink'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113354,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113355, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jsecpermuserlink where JSPUL_JSecPermUserLink_UID='+JAS.saDBMSUIntScrub(p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsecpermuserlink', p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID, '0',201506200324);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100909,'Problem locking jsecpermuserlink record.','p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID:'+p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162064);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152104,'Unable to query jsecpermuserlink successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152105,'Record missing from jsecpermuserlink.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJSecPermUserLink do begin
        //JSPUL_JSecPermUserLink_UID:=rs.Fields.Get_saValue('');
        JSPUL_JSecPerm_ID:=rs.Fields.Get_saValue('JSPUL_JSecPerm_ID');
        JSPUL_JUser_ID:=rs.Fields.Get_saValue('JSPUL_JUser_ID');
        JSPUL_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JSPUL_CreatedBy_JUser_ID');
        JSPUL_Created_DT                 :=rs.Fields.Get_saValue('JSPUL_Created_DT');
        JSPUL_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JSPUL_ModifiedBy_JUser_ID');
        JSPUL_Modified_DT                :=rs.Fields.Get_saValue('JSPUL_Modified_DT');
        JSPUL_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JSPUL_DeletedBy_JUser_ID');
        JSPUL_Deleted_DT                 :=rs.Fields.Get_saValue('JSPUL_Deleted_DT');
        JSPUL_Deleted_b                  :=rs.Fields.Get_saValue('JSPUL_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113356,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jsecpermuserlink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSecPermUserLink: rtJSecPermUserLink; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jsecpermuserlink'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113357,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113358, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID)=0 then
  begin
    bAddNew:=true;
    p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jsecpermuserlink');
    bOk:=(u8Val(p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152106,'Problem getting an UID for new jsecpermuserlink record.','saJAS_GetNextUID table: jsecpermuserlink',SOURCEFILE);
    end;

    if bok then
    begin
      saQry:='INSERT INTO jsecpermuserlink (JSPUL_JSecPermUserLink_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162065);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152107,'Problem creating a new jsecpermuserlink record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJSecPermUserLink.JSPUL_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecPermUserLink.JSPUL_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJSecPermUserLink.JSPUL_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSecPermUserLink.JSPUL_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJSecPermUserLink.JSPUL_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJSecPermUserLink.JSPUL_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsecpermuserlink', p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID, '0',201506200325);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152108,'Problem locking jsecpermuserlink record.','p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID:'+p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJSecPermUserLink do begin
      saQry:='UPDATE jsecpermuserlink set '+
        //' JSPUL_JSecPermUserLink_UID='+JAS.saDBMSScrub()+
        'JSPUL_JSecPerm_ID='+JAS.saDBMSUIntScrub(JSPUL_JSecPerm_ID)+
        ',JSPUL_JUser_ID='+JAS.saDBMSUIntScrub(JSPUL_JUser_ID);
        if(bAddNew)then
        begin
          saQry+=',JSPUL_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSPUL_CreatedBy_JUser_ID)+
          ',JSPUL_Created_DT='+JAS.saDBMSDateScrub(JSPUL_Created_DT);
        end;
        saQry+=
        ',JSPUL_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSPUL_ModifiedBy_JUser_ID)+
        ',JSPUL_Modified_DT'+JAS.saDBMSDateScrub(JSPUL_Modified_DT)+
        ',JSPUL_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSPUL_DeletedBy_JUser_ID)+
        ',JSPUL_Deleted_DT='+JAS.saDBMSDateScrub(JSPUL_Deleted_DT)+
        ',JSPUL_Deleted_b='+JAS.saDBMSBoolScrub(JSPUL_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JSPUL_JSecPermUserLink_UID='+JAS.saDBMSUIntScrub(JSPUL_JSecPermUserLink_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162066);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152109,'Problem updating jsecpermuserlink.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jsecpermuserlink', p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID, '0',201506200442) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152110,'Problem unlocking jsecpermuserlink record.','p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID:'+p_rJSecPermUserLink.JSPUL_JSecPermUserLink_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113359,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
function bJAS_Load_jsession(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSession: rtJSession; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jsession'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113360,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113361, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jsession where JSess_JSession_UID='+JAS.saDBMSUIntScrub(p_rJSession.JSess_JSession_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsession', p_rJSession.JSess_JSession_UID, '0',201506200326);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100735,'Problem locking jsession record.','p_rJSession.JSess_JSession_UID:'+p_rJSession.JSess_JSession_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162067);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151926,'Unable to query jsession successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002151927,'Record missing from jsession.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJSession do begin
        //JSess_JSession_UID:=rs.Fields.Get_saValue('JSess_JSession_UID');
        JSess_JSessionType_ID:=rs.Fields.Get_saValue('JSess_JSessionType_ID');
        JSess_JUser_ID:=rs.Fields.Get_saValue('JSess_JUser_ID');
        JSess_Connect_DT:=rs.Fields.Get_saValue('JSess_Connect_DT');
        JSess_LastContact_DT:=rs.Fields.Get_saValue('JSess_LastContact_DT');
        JSess_IP_ADDR:=rs.Fields.Get_saValue('JSess_IP_ADDR');
        JSess_Username:=rs.Fields.Get_saValue('JSess_Username');
        JSess_JJobQ_ID:=rs.Fields.Get_saValue('JSess_JJobQ_ID');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113362,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jsession(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSession: rtJSession; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jsession'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113363,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113364, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJSession.JSess_JSession_UID)=0 then
  begin
    p_rJSession.JSess_JSession_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jsession');
    bOk:=(u8Val(p_rJSession.JSess_JSession_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151928,
      'Problem getting an UID for new jsession record.','saJAS_GetNextUID table: jsession',SOURCEFILE);
    end;

    if bok then
    begin
      saQry:='INSERT INTO jsession (JSess_JSession_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJSession.JSess_JSession_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162068);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151929,'Problem creating a new jsession record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
      end;
    end;
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsession', p_rJSession.JSess_JSession_UID, '0',201506200327);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151930,'Problem locking jsession record.',
      'p_rJSession.JSess_JSession_UID:'+p_rJSession.JSess_JSession_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJSession do begin
      saQry:='UPDATE jsession set '+
        //' JSess_JSession_UID='+JAS.saDBMSScrub()+
         'JSess_JSessionType_ID='+JAS.saDBMSUIntScrub(JSess_JSessionType_ID)+
        ',JSess_JUser_ID='+JAS.saDBMSUIntScrub(JSess_JUser_ID)+
        ',JSess_Connect_DT='+JAS.saDBMSDateScrub(JSess_Connect_DT)+
        ',JSess_LastContact_DT='+JAS.saDBMSDateScrub(JSess_LastContact_DT)+
        ',JSess_IP_ADDR='+JAS.saDBMSScrub(JSess_IP_ADDR)+
        ',JSess_Username='+JAS.saDBMSScrub(JSess_Username)+
        ',JSess_JJobQ_ID='+JAS.saDBMSUIntScrub(JSess_JJobQ_ID)+
        ' WHERE JSess_JSession_UID='+JAS.saDBMSUIntScrub(JSess_JSession_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162069);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002151931,
        'Problem updating jsession.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jsession', p_rJSession.JSess_JSession_UID, '0',201506200443) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002151932,
          'Problem unlocking jsession record.',
          'p_rJSession.JSess_JSession_UID:'+p_rJSession.JSess_JSession_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113365,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
function bJAS_Load_jsessiontype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSessionType: rtJSessionType; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jsessiontype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113366,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113367, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jsessiontype where JSTyp_JSessionType_UID='+JAS.saDBMSUIntScrub(p_rJSessionType.JSTyp_JSessionType_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsessiontype', p_rJSessionType.JSTyp_JSessionType_UID, '0',201506200328);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100819,'Problem locking jsessiontype record.','p_rJSessionType.JSTyp_JSessionType_UID:'+p_rJSessionType.JSTyp_JSessionType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162070);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152008,'Unable to query jsessiontype successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152009,'Record missing from jsessiontype.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJSessionType do begin
        //JSTyp_JSessionType_UID:=rs.Fields.Get_saValue('');
        JSTyp_Name                       :=rs.Fields.Get_saValue('JSTyp_Name');
        JSTyp_Desc                       :=rs.Fields.Get_saValue('JSTyp_Desc');
        JSTyp_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JSTyp_CreatedBy_JUser_ID');
        JSTyp_Created_DT                 :=rs.Fields.Get_saValue('JSTyp_Created_DT');
        JSTyp_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JSTyp_ModifiedBy_JUser_ID');
        JSTyp_Modified_DT                :=rs.Fields.Get_saValue('JSTyp_Modified_DT');
        JSTyp_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JSTyp_DeletedBy_JUser_ID');
        JSTyp_Deleted_DT                 :=rs.Fields.Get_saValue('JSTyp_Deleted_DT');
        JSTyp_Deleted_b                  :=rs.Fields.Get_saValue('JSTyp_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113368,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jsessiontype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSessionType: rtJSessionType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jsessiontype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113369,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113370, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJSessionType.JSTyp_JSessionType_UID)=0 then
  begin
    bAddNew:=true;
    p_rJSessionType.JSTyp_JSessionType_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jsessiontype');
    bOk:=(u8Val(p_rJSessionType.JSTyp_JSessionType_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152010,'Problem getting an UID for new jsessiontype record.','saJAS_GetNextUID table: jsessiontype',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jsessiontype (JSTyp_JSessionType_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJSessionType.JSTyp_JSessionType_UID)+ ')';
      bOk:=rs.Open(saQry,JAS,201503162071);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152011,'Problem creating a new jsessiontype record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJSessionType.JSTyp_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSessionType.JSTyp_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJSessionType.JSTyp_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSessionType.JSTyp_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJSessionType.JSTyp_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJSessionType.JSTyp_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsessiontype', p_rJSessionType.JSTyp_JSessionType_UID, '0',201506200329);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152012,
      'Problem locking jsessiontype record.',
      'p_rJSessionType.JSTyp_JSessionType_UID:'+p_rJSessionType.JSTyp_JSessionType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJSessionType do begin
      saQry:='UPDATE jsessiontype set '+
        //' JSTyp_JSessionType_UID='+JAS.saDBMSScrub()+
        'JSTyp_Name='+JAS.saDBMSScrub(JSTyp_Name)+
        ',JSTyp_Desc='+JAS.saDBMSScrub(JSTyp_Desc);
        if(bAddNew)then
        begin
          saQry+=',JSTyp_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSTyp_CreatedBy_JUser_ID)+
          ',JSTyp_Created_DT='+JAS.saDBMSDateScrub(JSTyp_Created_DT);
        end;
        saQry+=
        ',JSTyp_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSTyp_ModifiedBy_JUser_ID)+
        ',JSTyp_Modified_DT='+JAS.saDBMSDateScrub(JSTyp_Modified_DT)+
        ',JSTyp_DeletedBy_JUser_ID='+JAS.saDBMSIntScrub(JSTyp_DeletedBy_JUser_ID)+
        ',JSTyp_Deleted_DT='+JAS.saDBMSDateScrub(JSTyp_Deleted_DT)+
        ',JSTyp_Deleted_b='+JAS.saDBMSBoolScrub(JSTyp_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JSTyp_JSessionType_UID='+JAS.saDBMSUIntScrub(JSTyp_JSessionType_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162072);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152013,'Problem updating jsessiontype.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jsessiontype', p_rJSessionType.JSTyp_JSessionType_UID, '0',201506200444) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152014,
          'Problem unlocking jsessiontype record.',
          'p_rJSessionType.JSTyp_JSessionType_UID:'+p_rJSessionType.JSTyp_JSessionType_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113371,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================




//=============================================================================
function bJAS_Load_jstatus(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjstatus: rtjstatus; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jstatus'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113408,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113409, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jstatus where JStat_JStatus_UID='+JAS.saDBMSUIntScrub(p_rjstatus.JStat_JStatus_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jstatus', p_rjstatus.JStat_JStatus_UID, '0',201506200330);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100922,'Problem locking jstatus record.','p_rjstatus.JStat_JStatus_UID:'+p_rjstatus.JStat_JStatus_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162073);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311862,'Unable to query jstatus successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201005311863,'Record missing from jstatus.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rjstatus do begin
        //JStat_JStatus_UID:=rs.Fields.Get_saValue('JTSta_JStatus_UID');
        JStat_Name                :=rs.Fields.Get_saValue('JStat_Name');
        JStat_Desc                :=rs.Fields.Get_saValue('JStat_Desc');
        JStat_JCaption_ID         :=rs.Fields.Get_saValue('JStat_JCaption_ID');
        JStat_CreatedBy_JUser_ID  :=rs.Fields.Get_saValue('JStat_CreatedBy_JUser_ID');
        JStat_Created_DT          :=rs.Fields.Get_saValue('JStat_Created_DT');
        JStat_ModifiedBy_JUser_ID :=rs.Fields.Get_saValue('JStat_ModifiedBy_JUser_ID');
        JStat_Modified_DT         :=rs.Fields.Get_saValue('JStat_Modified_DT');
        JStat_DeletedBy_JUser_ID  :=rs.Fields.Get_saValue('JStat_DeletedBy_JUser_ID');
        JStat_Deleted_DT          :=rs.Fields.Get_saValue('JStat_Deleted_DT');
        JStat_Deleted_b           :=rs.Fields.Get_saValue('JStat_Deleted_b');
        JAS_Row_b                 :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113410,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jstatus(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjstatus: rtjstatus; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jstatus'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113411,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113412, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rjstatus.JStat_JStatus_UID)=0 then
  begin
    bAddNew:=true;
    p_rjstatus.JStat_JStatus_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jstatus');
    bOk:=(u8Val(p_rjstatus.JStat_JStatus_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311864,'Problem getting an UID for new jstatus record.','saJAS_GetNextUID table: jstatus',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jstatus (JStat_JStatus_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rjstatus.JStat_JStatus_UID)+ ')';
      bOk:=rs.Open(saQry,JAS,201503162074);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311865,'Problem creating a new jstatus record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJStatus.JStat_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJStatus.JStat_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJStatus.JStat_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJStatus.JStat_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJStatus.JStat_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJStatus.JStat_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jstatus', p_rJStatus.JStat_JStatus_UID, '0',201506200331);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311866,'Problem locking jstatus record.','p_rJStatus.JStat_JStatus_UID:'+p_rJStatus.JStat_JStatus_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJStatus do begin
      saQry:='UPDATE jstatus set '+
        //' JStat_JStatus_UID='+JAS.saDBMSScrub(JStat_JStatus_UID)+
        'JStat_Name='+JAS.saDBMSScrub(JStat_Name)+
        ',JStat_Desc='+JAS.saDBMSScrub(JStat_Desc)+
        ',JStat_JCaption_ID='+JAS.saDBMSUIntScrub(JStat_JCaption_ID);
        if(bAddNew)then
        begin
          saQry+=',JStat_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JStat_CreatedBy_JUser_ID)+
          ',JStat_Created_DT='+JAS.saDBMSDateScrub(JStat_Created_DT);
        end;
        saQry+=
        ',JStat_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JStat_ModifiedBy_JUser_ID)+
        ',JStat_Modified_DT='+JAS.saDBMSDateScrub(JStat_Modified_DT)+
        ',JStat_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JStat_DeletedBy_JUser_ID)+
        ',JStat_Deleted_DT='+JAS.saDBMSDateScrub(JStat_Deleted_DT)+
        ',JStat_Deleted_b='+JAS.saDBMSBoolScrub(JStat_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JStat_JStatus_UID='+JAS.saDBMSUIntScrub(JStat_JStatus_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162075);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311867,'Problem updating jstatus.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jstatus', p_rJStatus.JStat_JStatus_UID, '0',201506200445) then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311868,'Problem unlocking jstatus record.','p_rJStatus.JStat_JStatus_UID:'+p_rJStatus.JStat_JStatus_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113413,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================





//=============================================================================
function bJAS_Load_jsysmodule(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSysModule: rtJSysModule; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jsysmodule'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113372,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113373, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jsysmodule where JSysM_JSysModule_UID='+JAS.saDBMSUIntScrub(p_rJSysModule.JSysM_JSysModule_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsysmodule', p_rJSysModule.JSysM_JSysModule_UID, '0',201506200332);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100910,'Problem locking jsysmodule record.','p_rJSysModule.JSysM_JSysModule_UID:'+p_rJSysModule.JSysM_JSysModule_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162076);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152111,'Unable to query jsysmodule successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152112,'Record missing from jsysmodule.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJSysModule do begin
        //JSysM_JSysModule_UID:=rs.Fields.Get_saValue('');
        JSysM_Name:=rs.Fields.Get_saValue('JSysM_Name');
        JSysM_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JSysM_CreatedBy_JUser_ID');
        JSysM_Created_DT                 :=rs.Fields.Get_saValue('JSysM_Created_DT');
        JSysM_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JSysM_ModifiedBy_JUser_ID');
        JSysM_Modified_DT                :=rs.Fields.Get_saValue('JSysM_Modified_DT');
        JSysM_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JSysM_DeletedBy_JUser_ID');
        JSysM_Deleted_DT                 :=rs.Fields.Get_saValue('JSysM_Deleted_DT');
        JSysM_Deleted_b                  :=rs.Fields.Get_saValue('JSysM_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113374,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jsysmodule(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJSysModule: rtJSysModule; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jsysmodule'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113375,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113376, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJSysModule.JSysM_JSysModule_UID)=0 then
  begin
    bAddNew:=true;
    p_rJSysModule.JSysM_JSysModule_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jsysmodule');
    bOk:=(u8Val(p_rJSysModule.JSysM_JSysModule_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152113,'Problem getting an UID for new jsysmodule record.','saJAS_GetNextUID table: jsysmodule',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jsysmodule (JSysM_JSysModule_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJSysModule.JSysM_JSysModule_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162077);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152114,'Problem creating a new jsysmodule record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJSysModule.JSysM_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSysModule.JSysM_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJSysModule.JSysM_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJSysModule.JSysM_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJSysModule.JSysM_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJSysModule.JSysM_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jsysmodule', p_rJSysModule.JSysM_JSysModule_UID, '0',201506200333);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152115,'Problem locking jsysmodule record.','p_rJSysModule.JSysM_JSysModule_UID:'+p_rJSysModule.JSysM_JSysModule_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJSysModule do begin
      saQry:='UPDATE jsysmodule set '+
        //' JSysM_JSysModule_UID='+JAS.saDBMSScrub()+
        'JSysM_Name='+JAS.saDBMSScrub(JSysM_Name);
        if(bAddNew)then
        begin
          saQry+=',JSysM_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSysM_CreatedBy_JUser_ID)+
          ',JSysM_Created_DT='+JAS.saDBMSDateScrub(JSysM_Created_DT);
        end;
        saQry+=
        ',JSysM_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSysM_ModifiedBy_JUser_ID)+
        ',JSysM_Modified_DT='+JAS.saDBMSDateScrub(JSysM_Modified_DT)+
        ',JSysM_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JSysM_DeletedBy_JUser_ID)+
        ',JSysM_Deleted_DT='+JAS.saDBMSDateScrub(JSysM_Deleted_DT)+
        ',JSysM_Deleted_b='+JAS.saDBMSBoolScrub(JSysM_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JSysM_JSysModule_UID='+JAS.saDBMSUIntScrub(JSysM_JSysModule_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162078);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152116,'Problem updating jsysmodule.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jsysmodule', p_rJSysModule.JSysM_JSysModule_UID, '0',201506200446) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152117,'Problem unlocking jsysmodule record.','p_rJSysModule.JSysM_JSysModule_UID:'+p_rJSysModule.JSysM_JSysModule_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113377,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
function bJAS_Load_jtable(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTable: rtJTable; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jtable'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113378,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113379, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jtable where JTabl_JTable_UID='+JAS.saDBMSUIntScrub(p_rJTable.JTabl_JTable_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtable', p_rJTable.JTabl_JTable_UID, '0',201506200334);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100911,'Problem locking jtable record.','p_rJTable.JTabl_JTable_UID:'+p_rJTable.JTabl_JTable_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162079);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152118,'Unable to query jtable successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Warn,201002152119,'Record missing from jtable.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJTable do begin
        //JTabl_JTable_UID:=rs.Fields.Get_saValue('JTabl_JTable_UID');
        JTabl_Name               :=rs.Fields.Get_saValue('JTabl_Name');
        JTabl_Desc               :=rs.Fields.Get_saValue('JTabl_Desc');
        JTabl_JTableType_ID      :=rs.Fields.Get_saValue('JTabl_JTableType_ID');
        JTabl_JDConnection_ID    :=rs.Fields.Get_saValue('JTabl_JDConnection_ID');
        JTabl_ColumnPrefix       :=rs.Fields.Get_saValue('JTabl_ColumnPrefix');
        JTabl_DupeScore_u        :=rs.Fields.Get_saValue('JTabl_DupeScore_u');
        JTabl_Perm_JColumn_ID    :=rs.Fields.Get_saValue('JTabl_Perm_JColumn_ID');
        JTabl_Owner_Only_b       :=rs.Fields.Get_saValue('JTabl_Owner_Only_b');
        JTabl_View_MySQL         :=rs.Fields.Get_saValue('JTabl_View_MySQL');
        JTabl_View_MSSQL         :=rs.Fields.Get_saValue('JTabl_View_MSSQL');
        JTabl_View_MSAccess      :=rs.Fields.Get_saValue('JTabl_View_MSAccess');
        JTabl_Add_JSecPerm_ID    :=rs.Fields.Get_saValue('JTabl_Add_JSecPerm_ID');
        JTabl_Update_JSecPerm_ID :=rs.Fields.Get_saValue('JTabl_Update_JSecPerm_ID');
        JTabl_View_JSecPerm_ID   :=rs.Fields.Get_saValue('JTabl_View_JSecPerm_ID');
        JTabl_Delete_JSecPerm_ID :=rs.Fields.Get_saValue('JTabl_Delete_JSecPerm_ID');
        JTabl_CreatedBy_JUser_ID :=rs.Fields.Get_saValue('JTabl_CreatedBy_JUser_ID');
        JTabl_Created_DT         :=rs.Fields.Get_saValue('JTabl_Created_DT');
        JTabl_ModifiedBy_JUser_ID:=rs.Fields.Get_saValue('JTabl_ModifiedBy_JUser_ID');
        JTabl_Modified_DT        :=rs.Fields.Get_saValue('JTabl_Modified_DT');
        JTabl_DeletedBy_JUser_ID :=rs.Fields.Get_saValue('JTabl_DeletedBy_JUser_ID');
        JTabl_Deleted_DT         :=rs.Fields.Get_saValue('JTabl_Deleted_DT');
        JTabl_Deleted_b          :=rs.Fields.Get_saValue('JTabl_Deleted_b');
        JAS_Row_b                :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113380,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jtable(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTable: rtJTable; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jtable'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113381,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113382, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJTable.JTabl_JTable_UID)=0 then
  begin
    bAddNew:=true;
    p_rJTable.JTabl_JTable_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jtable');
    bOk:=(u8Val(p_rJTable.JTabl_JTable_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152120,'Problem getting an UID for new jtable record.','saJAS_GetNextUID table: jtable',SOURCEFILE);
    end;

    if bok then
    begin
      saQry:='INSERT INTO jtable (JTabl_JTable_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJTable.JTabl_JTable_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162080);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152121,'Problem creating a new jtable record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJTable.JTabl_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJTable.JTabl_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJTable.JTabl_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJTable.JTabl_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJTable.JTabl_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJTable.JTabl_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtable', p_rJTable.JTabl_JTable_UID, '0',201506200335);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152122,'Problem locking jtable record.','p_rJTable.JTabl_JTable_UID:'+p_rJTable.JTabl_JTable_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJTable do begin
      saQry:='UPDATE jtable set '+
        //' JTabl_JTable_UID='+JAS.saDBMSScrub()+
        ' JTabl_Name='+JAS.saDBMSScrub(JTabl_Name)+
        ',JTabl_Desc='+JAS.saDBMSScrub(JTabl_Desc)+
        ',JTabl_JTableType_ID='+JAS.saDBMSUIntScrub(JTabl_JTableType_ID)+
        ',JTabl_JDConnection_ID='+JAS.saDBMSUIntScrub(JTabl_JDConnection_ID)+
        ',JTabl_ColumnPrefix='+JAS.saDBMSScrub(JTabl_ColumnPrefix)+
        ',JTabl_DupeScore_u='+JAS.saDBMSUIntScrub(JTabl_DupeScore_u)+
        ',JTabl_Perm_JColumn_ID='+JAS.saDBMSUIntScrub(JTabl_Perm_JColumn_ID)+
        ',JTabl_Owner_Only_b='+JAS.saDBMSBoolScrub(JTabl_Owner_Only_b)+
        ',JTabl_View_MySQL='+JAS.saDBMSScrub(JTabl_View_MySQL)+
        ',JTabl_View_MSSQL='+JAS.saDBMSScrub(JTabl_View_MSSQL)+
        ',JTabl_View_MSAccess='+JAS.saDBMSScrub(JTabl_View_MSAccess)+
        ',JTabl_Add_JSecPerm_ID='+JAS.saDBMSUIntScrub(JTabl_Add_JSecPerm_ID)+
        ',JTabl_Update_JSecPerm_ID='+JAS.saDBMSUIntScrub(JTabl_Update_JSecPerm_ID)+
        ',JTabl_View_JSecPerm_ID='+JAS.saDBMSUIntScrub(JTabl_View_JSecPerm_ID)+
        ',JTabl_Delete_JSecPerm_ID='+JAS.saDBMSUIntScrub(JTabl_Delete_JSecPerm_ID);
        
        if(bAddNew)then
        begin
          saQry+=',JTabl_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTabl_CreatedBy_JUser_ID)+
          ',JTabl_Created_DT='+JAS.saDBMSDateScrub(JTabl_Created_DT);
        end;
        saQry+=
        ',JTabl_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTabl_ModifiedBy_JUser_ID)+
        ',JTabl_Modified_DT='+JAS.saDBMSDateScrub(JTabl_Modified_DT)+
        ',JTabl_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTabl_DeletedBy_JUser_ID)+
        ',JTabl_Deleted_DT='+JAS.saDBMSDateScrub(JTabl_Deleted_DT)+
        ',JTabl_Deleted_b='+JAS.saDBMSBoolScrub(JTabl_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JTabl_JTable_UID='+JAS.saDBMSUIntScrub(JTabl_JTable_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162081);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152123,'Problem updating jtable.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jtable', p_rJTable.JTabl_JTable_UID, '0',201506200447) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152124,'Problem unlocking jtable record.','p_rJTable.JTabl_JTable_UID:'+p_rJTable.JTabl_JTable_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113383,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jtabletype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTableType: rtJTableType; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jtabletype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113384,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113385, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jtabletype where JTTyp_JTableType_UID='+JAS.saDBMSUIntScrub(p_rJTableType.JTTyp_JTableType_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtabletype',p_rJTableType.JTTyp_JTableType_UID, '0',201506200336);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100912,'Problem locking jtabletype record.','p_rJTableType.JTTyp_JTableType_UID:'+p_rJTableType.JTTyp_JTableType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162082);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152125,'Unable to query jtabletype successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152126,'Record missing from jtabletype.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJTableType do begin
        //JTTyp_JTableType_UID:=rs.Fields.Get_saValue('');
        JTTyp_Name:=rs.Fields.Get_saValue('JTTyp_Name');
        JTTyp_Desc:=rs.Fields.Get_saValue('JTTyp_Desc');
        JTTyp_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JTTyp_CreatedBy_JUser_ID');
        JTTyp_Created_DT                 :=rs.Fields.Get_saValue('JTTyp_Created_DT');
        JTTyp_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JTTyp_ModifiedBy_JUser_ID');
        JTTyp_Modified_DT                :=rs.Fields.Get_saValue('JTTyp_Modified_DT');
        JTTyp_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JTTyp_DeletedBy_JUser_ID');
        JTTyp_Deleted_DT                 :=rs.Fields.Get_saValue('JTTyp_Deleted_DT');
        JTTyp_Deleted_b                  :=rs.Fields.Get_saValue('JTTyp_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113386,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jtabletype(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTableType: rtJTableType; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jtabletype'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113387,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113388, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJTableType.JTTyp_JTableType_UID)=0 then
  begin
    bAddNew:=true;
    p_rJTableType.JTTyp_JTableType_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jtabletype');
    bOk:=(u8Val(p_rJTableType.JTTyp_JTableType_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152127,'Problem getting an UID for new jtabletype record.','saJAS_GetNextUID table: jtabletype',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jtabletype (JTTyp_JTableType_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJTableType.JTTyp_JTableType_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162083);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152128,'Problem creating a new jtabletype record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJTableType.JTTyp_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJTableType.JTTyp_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJTableType.JTTyp_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJTableType.JTTyp_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJTableType.JTTyp_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJTableType.JTTyp_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtabletype', p_rJTableType.JTTyp_JTableType_UID, '0',201506200337);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152129,'Problem locking jtabletype record.','p_rJTableType.JTTyp_JTableType_UID:'+p_rJTableType.JTTyp_JTableType_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJTableType do begin
      saQry:='UPDATE jtabletype set '+
        //' JTTyp_JTableType_UID='+JAS.saDBMSScrub()+
        'JTTyp_Name='+JAS.saDBMSScrub(JTTyp_Name)+
        ',JTTyp_Desc='+JAS.saDBMSScrub(JTTyp_Desc);
        if(bAddNew)then
        begin
          saQry+=',JTTyp_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTTyp_CreatedBy_JUser_ID)+
          ',JTTyp_Created_DT='+JAS.saDBMSDateScrub(JTTyp_Created_DT);
        end;
        saQry+=
        ',JTTyp_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTTyp_ModifiedBy_JUser_ID)+
        ',JTTyp_Modified_DT='+JAS.saDBMSDateScrub(JTTyp_Modified_DT)+
        ',JTTyp_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTTyp_DeletedBy_JUser_ID)+
        ',JTTyp_Deleted_DT='+JAS.saDBMSDateScrub(JTTyp_Deleted_DT)+
        ',JTTyp_Deleted_b='+JAS.saDBMSBoolScrub(JTTyp_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JTTyp_JTableType_UID='+JAS.saDBMSUIntScrub(JTTyp_JTableType_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162084);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152130,'Problem updating jtabletype.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jtabletype', p_rJTableType.JTTyp_JTableType_UID, '0',201506200448) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152131,'Problem unlocking jtabletype record.','p_rJTableType.JTTyp_JTableType_UID:'+p_rJTableType.JTTyp_JTableType_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113389,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
//---------------------------------------------------------------------------










//=============================================================================
function bJAS_Load_jtask(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjtask: rtjtask; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jtask'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113390,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113391, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jtask where JTask_JTask_UID='+JAS.saDBMSUIntScrub(p_rjtask.JTask_JTask_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtask', p_rjtask.JTask_JTask_UID, '0',201506200338);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100913,'Problem locking jtask record.','p_rjtask.JTask_JTask_UID:'+p_rjtask.JTask_JTask_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162085);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311834,'Unable to query jtask successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201005311835,'Record missing from jtask.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rjtask do begin
        //JTask_JTask_UID            :=rs.Fields.Get_saValue('JTask_JTask_UID');
        JTask_Name                 :=rs.Fields.Get_saValue('JTask_Name');
        JTask_Desc                 :=rs.Fields.Get_saValue('JTask_Desc');
        JTask_JTaskCategory_ID     :=rs.Fields.Get_saValue('JTask_JTaskCategory_ID');
        JTask_JProject_ID          :=rs.Fields.Get_saValue('JTask_JProject_ID');
        JTask_JStatus_ID           :=rs.Fields.Get_saValue('JTask_JStatus_ID');
        JTask_Due_DT               :=rs.Fields.Get_saValue('JTask_Due_DT');
        JTask_Duration_Minutes_Est :=rs.Fields.Get_saValue('JTask_Duration_Minutes_Est');
        JTask_JPriority_ID         :=rs.Fields.Get_saValue('JTask_JPriority_ID');
        JTask_Start_DT             :=rs.Fields.Get_saValue('JTask_Start_DT');
        JTask_Owner_JUser_ID       :=rs.Fields.Get_saValue('JTask_Owner_JUser_ID');
        JTask_SendReminder_b       :=rs.Fields.Get_saValue('JTask_SendReminder_b');
        JTask_ReminderSent_b       :=rs.Fields.Get_saValue('JTask_ReminderSent_b');
        JTask_ReminderSent_DT      :=rs.Fields.Get_saValue('JTask_ReminderSent_DT');
        JTask_Remind_DaysAhead_u   :=rs.Fields.Get_saValue('JTask_Remind_DaysAhead_u');
        JTask_Remind_HoursAhead_u  :=rs.Fields.Get_saValue('JTask_Remind_HoursAhead_u');
        JTask_Remind_MinutesAhead_u:=rs.Fields.Get_saValue('JTask_Remind_MinutesAhead_u');
        JTask_Remind_Persistantly_b:=rs.Fields.Get_saValue('JTask_Remind_Persistantly_b');
        JTask_Progress_PCT_d       :=rs.Fields.Get_saValue('JTask_Progress_PCT_d');
        JTask_JCase_ID             :=rs.Fields.Get_saValue('JTask_JCase_ID');
        JTask_Directions_URL       :=rs.Fields.Get_saValue('JTask_Directions_URL');
        JTask_CreatedBy_JUser_ID   :=rs.Fields.Get_saValue('JTask_CreatedBy_JUser_ID');
        JTask_Created_DT           :=rs.Fields.Get_saValue('JTask_Created_DT');
        JTask_ModifiedBy_JUser_ID  :=rs.Fields.Get_saValue('JTask_ModifiedBy_JUser_ID');
        JTask_Modified_DT          :=rs.Fields.Get_saValue('JTask_Modified_DT');
        JTask_URL                  :=rs.Fields.Get_saValue('JTask_URL');
        JTask_Milestone_b          :=rs.Fields.Get_saValue('JTask_Milestone_b');
        JTask_Budget_d             :=rs.Fields.Get_saValue('JTask_Budget_d');
        JTask_ResolutionNotes      :=rs.Fields.Get_saValue('JTask_ResolutionNotes');
        JTask_Completed_DT         :=rs.Fields.Get_saValue('JTask_Completed_DT');
        JTask_Related_JTable_ID      :=rs.Fields.Get_saValue('JTask_Related_JTable_ID');
        JTask_Related_Row_ID      :=rs.Fields.Get_saValue('JTask_Related_Row_ID');
        JTask_CreatedBy_JUser_ID   :=rs.Fields.Get_saValue('JTask_CreatedBy_JUser_ID');
        JTask_Created_DT           :=rs.Fields.Get_saValue('JTask_Created_DT');
        JTask_ModifiedBy_JUser_ID  :=rs.Fields.Get_saValue('JTask_ModifiedBy_JUser_ID');
        JTask_Modified_DT          :=rs.Fields.Get_saValue('JTask_Modified_DT');
        JTask_DeletedBy_JUser_ID   :=rs.Fields.Get_saValue('JTask_DeletedBy_JUser_ID');
        JTask_Deleted_DT           :=rs.Fields.Get_saValue('JTask_Deleted_DT');
        JTask_Deleted_b            :=rs.Fields.Get_saValue('JTask_Deleted_b');
        JAS_Row_b                  :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113392,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jtask(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjtask: rtjtask; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jtask'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113393,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113394, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if i8Val(p_rjtask.JTask_JTask_UID)=0 then
  begin
    bAddNew:=true;
    p_rjtask.JTask_JTask_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jtask');
    bOk:=(i8Val(p_rjtask.JTask_JTask_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311836,'Problem getting an UID for new jtask record.','saJAS_GetNextUID table: jtask',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jtask (JTask_JTask_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rjtask.JTask_JTask_UID)+ ')';
      bOk:=rs.Open(saQry,JAS,201503162086);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311837,'Problem creating a new jtask record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJTask.JTask_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJTask.JTask_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJTask.JTask_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJTask.JTask_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJTask.JTask_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJTask.JTask_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtask', p_rjtask.JTask_JTask_UID, '0',201506200339);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311838,'Problem locking jtask record.',
        'JAS.ID:'+JAS.ID+' '+
        'table: jtask '+
        'JTask_JTask_UID: '+p_rjtask.JTask_JTask_UID+' '+
        'Column: 0 ', SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rjtask do begin
      // this is a work around where I saw some bad data getting into the mix.
      if JAS.saDBMSDateScrub(JTask_Start_DT)='0000-00-00 NULL' then
      begin
        JTask_Start_DT:=saFormatDateTime(csDATETIMEFORMAT,now);
      end;


      saQry:='UPDATE jtask set '+
        //' JTask_JTask_UID='+JAS.saDBMSScrub(JTask_JTask_UID)+
        'JTask_Name='+JAS.saDBMSScrub(JTask_Name)+
        ',JTask_Desc='+JAS.saDBMSScrub(JTask_Desc)+
        ',JTask_JTaskCategory_ID='+JAS.saDBMSUIntScrub(JTask_JTaskCategory_ID)+
        ',JTask_JProject_ID='+JAS.saDBMSUIntScrub(JTask_JProject_ID)+
        ',JTask_JStatus_ID='+JAS.saDBMSUIntScrub(JTask_JStatus_ID)+
        ',JTask_Due_DT='+JAS.saDBMSDateScrub(JTask_Due_DT)+
        ',JTask_Duration_Minutes_Est='+JAS.saDBMSUIntScrub(JTask_Duration_Minutes_Est)+
        ',JTask_JPriority_ID='+JAS.saDBMSUIntScrub(JTask_JPriority_ID)+
        ',JTask_Start_DT='+JAS.saDBMSDateScrub(JTask_Start_DT)+
        ',JTask_Owner_JUser_ID='+JAS.saDBMSUIntScrub(JTask_Owner_JUser_ID)+
        ',JTask_SendReminder_b='+JAS.saDBMSBoolScrub(bVal(JTask_SendReminder_b))+
        ',JTask_ReminderSent_b='+JAS.saDBMSBoolScrub(bVal(JTask_ReminderSent_b))+
        ',JTask_ReminderSent_DT='+JAS.saDBMSDateScrub(JTask_ReminderSent_DT)+
        ',JTask_Remind_DaysAhead_u='+JAS.saDBMSUIntScrub(JTask_Remind_DaysAhead_u)+
        ',JTask_Remind_HoursAhead_u='+JAS.saDBMSUIntScrub(JTask_Remind_HoursAhead_u)+
        ',JTask_Remind_MinutesAhead_u='+JAS.saDBMSUIntScrub(JTask_Remind_MinutesAhead_u)+
        ',JTask_Remind_Persistantly_b='+JAS.saDBMSBoolScrub(JTask_Remind_Persistantly_b)+
        ',JTask_Progress_PCT_d='+JAS.saDBMSDecScrub(JTask_Progress_PCT_d)+
        ',JTask_JCase_ID='+JAS.saDBMSUIntScrub(JTask_JCase_ID)+
        ',JTask_Directions_URL='+JAS.saDBMSScrub(JTask_Directions_URL)+
        ',JTask_URL='+JAS.saDBMSScrub(JTask_URL)+
        ',JTask_Milestone_b='+JAS.saDBMSBoolScrub(bVal(JTask_Milestone_b))+
        ',JTask_Budget_d='+JAS.saDBMSDecScrub(JTask_Budget_d)+
        ',JTask_ResolutionNotes='+JAS.saDBMSScrub(JTask_ResolutionNotes)+
        ',JTask_Completed_DT='+JAS.saDBMSDateScrub(JTask_Completed_DT)+
        ',JTask_Related_JTable_ID='+JAS.saDBMSUIntScrub(JTask_Related_JTable_ID)+
        ',JTask_Related_Row_ID='+JAS.saDBMSUIntScrub(JTask_Related_Row_ID);
        if(bAddNew)then
        begin
          saQry+=',JTask_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTask_CreatedBy_JUser_ID)+
          ',JTask_Created_DT='+JAS.saDBMSDateScrub(JTask_Created_DT);
        end;
        saQry+=
        ',JTask_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTask_ModifiedBy_JUser_ID)+
        ',JTask_Modified_DT='+JAS.saDBMSDateScrub(JTask_Modified_DT)+
        ',JTask_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTask_DeletedBy_JUser_ID)+
        ',JTask_Deleted_DT='+JAS.saDBMSDateScrub(JTask_Deleted_DT)+
        ',JTask_Deleted_b='+JAS.saDBMSBoolScrub(JTask_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JTask_JTask_UID='+JAS.saDBMSUIntScrub(JTask_JTask_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162087);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311839,'Problem updating jtask.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jtask', p_rjtask.JTask_JTask_UID, '0',201506200449) then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311840,'Problem unlocking jtask record.','p_rjtask.JTask_JTask_UID:'+p_rjtask.JTask_JTask_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113395,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jtaskcategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjtaskcategory: rtjtaskcategory; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jtaskcategory'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113396,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113397, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jtaskcategory where JTCat_JTaskCategory_UID='+JAS.saDBMSUIntScrub(p_rjtaskcategory.JTCat_JTaskCategory_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtaskcategory', p_rjtaskcategory.JTCat_JTaskCategory_UID, '0',201506200340);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006100914,'Problem locking jtaskcategory record.','p_rjtaskcategory.JTCat_JTaskCategory_UID:'+p_rjtaskcategory.JTCat_JTaskCategory_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162088);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311841,'Unable to query jtaskcategory successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201005311842,'Record missing from jtaskcategory.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rjtaskcategory do begin
        //JTCat_JTaskCategory_UID:=rs.Fields.Get_saValue('JTCat_JTaskCategory_UID');
        JTCat_Name             :=rs.Fields.Get_saValue('JTCat_Name');
        JTCat_Desc             :=rs.Fields.Get_saValue('JTCat_Desc');
        JTCat_JCaption_ID      :=rs.Fields.Get_saValue('JTCat_JCaption_ID');
        JTCat_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JTCat_CreatedBy_JUser_ID');
        JTCat_Created_DT                 :=rs.Fields.Get_saValue('JTCat_Created_DT');
        JTCat_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JTCat_ModifiedBy_JUser_ID');
        JTCat_Modified_DT                :=rs.Fields.Get_saValue('JTCat_Modified_DT');
        JTCat_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JTCat_DeletedBy_JUser_ID');
        JTCat_Deleted_DT                 :=rs.Fields.Get_saValue('JTCat_Deleted_DT');
        JTCat_Deleted_b                  :=rs.Fields.Get_saValue('JTCat_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113398,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jtaskcategory(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjtaskcategory: rtjtaskcategory; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jtaskcategory'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113399,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113400, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rjtaskcategory.JTCat_JTaskCategory_UID)=0 then
  begin
    bAddNew:=true;
    p_rjtaskcategory.JTCat_JTaskCategory_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jtaskcategory');
    bOk:=(u8Val(p_rjtaskcategory.JTCat_JTaskCategory_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311843,'Problem getting an UID for new jtaskcategory record.','saJAS_GetNextUID table: jtaskcategory',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jtaskcategory (JTCat_JTaskCategory_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rjtaskcategory.JTCat_JTaskCategory_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162089);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311844,'Problem creating a new jtaskcategory record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rjtaskcategory.JTCat_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rjtaskcategory.JTCat_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rjtaskcategory.JTCat_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rjtaskcategory.JTCat_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rjtaskcategory.JTCat_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rjtaskcategory.JTCat_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtaskcategory', p_rjtaskcategory.JTCat_JTaskCategory_UID, '0',201506200341);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311845,'Problem locking jtaskcategory record.','p_rjtaskcategory.JTCat_JTaskCategory_UID:'+p_rjtaskcategory.JTCat_JTaskCategory_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rjtaskcategory do begin
      saQry:='UPDATE jtaskcategory set '+
        //' JTCat_JTaskCategory_UID='+JAS.saDBMSScrub(JTCat_JTaskCategory_UID)+
        'JTCat_Name='+JAS.saDBMSScrub(JTCat_Name)+
        ',JTCat_Desc='+JAS.saDBMSScrub(JTCat_Desc)+
        ',JTCat_JCaption_ID='+JAS.saDBMSUIntScrub(JTCat_JCaption_ID);
        if(bAddNew)then
        begin
          saQry+=',JTCat_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTCat_CreatedBy_JUser_ID)+
          ',JTCat_Created_DT='+JAS.saDBMSDateScrub(JTCat_Created_DT);
        end;
        saQry+=
        ',JTCat_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTCat_ModifiedBy_JUser_ID)+
        ',JTCat_Modified_DT='+JAS.saDBMSDateScrub(JTCat_Modified_DT)+
        ',JTCat_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTCat_DeletedBy_JUser_ID)+
        ',JTCat_Deleted_DT='+JAS.saDBMSDateScrub(JTCat_Deleted_DT)+
        ',JTCat_Deleted_b='+JAS.saDBMSBoolScrub(JTCat_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JTCat_JTaskCategory_UID='+JAS.saDBMSUIntScrub(JTCat_JTaskCategory_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162090);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311846,'Problem updating jtaskcategory.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jtaskcategory', p_rjtaskcategory.JTCat_JTaskCategory_UID, '0',201506200450) then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311847,'Problem unlocking jtaskcategory record.','p_rjtaskcategory.JTCat_JTaskCategory_UID:'+p_rjtaskcategory.JTCat_JTaskCategory_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113401,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
function bJAS_Load_jteam(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTeam: rtJTeam; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jteam'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113414,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113415, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jteam where JTeam_JTeam_UID='+JAS.saDBMSUIntScrub(p_rJteam.JTeam_JTeam_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jteam', p_rJteam.JTeam_JTeam_UID, '0',201506200342);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006101054,'Problem locking jteam record.','p_rJteam.JTeam_JTeam_UID:'+p_rJteam.JTeam_JTeam_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162091);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152132,'Unable to query jteam successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152133,'Record missing from jteam.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJTeam do begin
        //JTeam_JTeam_UID:=rs.Fields.Get_saValue('');
        JTeam_Parent_JTeam_ID:=rs.Fields.Get_saValue('JTeam_Parent_JTeam_ID');
        JTeam_JCompany_ID:=rs.Fields.Get_saValue('JTeam_JCompany_ID');
        JTeam_Name:=rs.Fields.Get_saValue('JTeam_Name');
        JTeam_Desc:=rs.Fields.Get_saValue('JTeam_Desc');
        JTeam_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JTeam_CreatedBy_JUser_ID');
        JTeam_Created_DT                 :=rs.Fields.Get_saValue('JTeam_Created_DT');
        JTeam_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JTeam_ModifiedBy_JUser_ID');
        JTeam_Modified_DT                :=rs.Fields.Get_saValue('JTeam_Modified_DT');
        JTeam_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JTeam_DeletedBy_JUser_ID');
        JTeam_Deleted_DT                 :=rs.Fields.Get_saValue('JTeam_Deleted_DT');
        JTeam_Deleted_b                  :=rs.Fields.Get_saValue('JTeam_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113416,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jteam(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTeam: rtJTeam; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jteam'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113417,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113418, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJteam.JTeam_JTeam_UID)=0 then
  begin
    bAddNew:=true;
    p_rJteam.JTeam_JTeam_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jteam');
    bOk:=(u8Val(p_rJteam.JTeam_JTeam_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152134,'Problem getting an UID for new jteam record.','saJAS_GetNextUID table: jteam',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jteam (JTeam_JTeam_UID) VALUES ('+ p_rJteam.JTeam_JTeam_UID + ')';
      bOk:=rs.Open(saQry,JAS,201503162092);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152135,'Problem creating a new jteam record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJteam.JTeam_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJteam.JTeam_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJteam.JTeam_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJteam.JTeam_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJteam.JTeam_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJteam.JTeam_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jteam', p_rJteam.JTeam_JTeam_UID, '0',201506200343);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152136,'Problem locking jteam record.','p_rJteam.JTeam_JTeam_UID:'+p_rJteam.JTeam_JTeam_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJTeam do begin
      saQry:='UPDATE jteam set '+
        //' JTeam_JTeam_UID='+JAS.saDBMSScrub()+
        'JTeam_Parent_JTeam_ID='+JAS.saDBMSUIntScrub(JTeam_Parent_JTeam_ID)+
        ',JTeam_JCompany_ID='+JAS.saDBMSUIntScrub(JTeam_JCompany_ID)+
        ',JTeam_Name='+JAS.saDBMSScrub(JTeam_Name)+
        ',JTeam_Desc='+JAS.saDBMSScrub(JTeam_Desc);
        if(bAddNew)then
        begin
          saQry+=',JTeam_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTeam_CreatedBy_JUser_ID)+
          ',JTeam_Created_DT='+JAS.saDBMSDateScrub(JTeam_Created_DT);
        end;
        saQry+=
        ',JTeam_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTeam_ModifiedBy_JUser_ID)+
        ',JTeam_Modified_DT='+JAS.saDBMSDateScrub(JTeam_Modified_DT)+
        ',JTeam_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTeam_DeletedBy_JUser_ID)+
        ',JTeam_Deleted_DT='+JAS.saDBMSDateScrub(JTeam_Deleted_DT)+
        ',JTeam_Deleted_b='+JAS.saDBMSBoolScrub(JTeam_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JTeam_JTeam_UID='+JAS.saDBMSUIntScrub(JTeam_JTeam_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162093);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152137,'Problem updating jteam.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jteam', p_rJteam.JTeam_JTeam_UID, '0',201506200451) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152138,'Problem unlocking jteam record.','p_rJteam.JTeam_JTeam_UID:'+p_rJteam.JTeam_JTeam_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113419,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_jteammember(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTeamMember: rtJTeamMember; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jteammember'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113420,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113421, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jteammember where JTMem_JTeamMember_UID='+JAS.saDBMSUIntScrub(p_rJTeamMember.JTMem_JTeamMember_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jteammember', p_rJTeamMember.JTMem_JTeamMember_UID, '0',201506200344);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006101155,'Problem locking jteammember record.','p_rJTeamMember.JTMem_JTeamMember_UID:'+p_rJTeamMember.JTMem_JTeamMember_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162094);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152139,'Unable to query jteammember successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152140,'Record missing from jteammember.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJTeamMember do begin
        //JTMem_JTeamMember_UID:=rs.Fields.Get_saValue('');
        JTMem_JTeam_ID:=rs.Fields.Get_saValue('JTMem_JTeam_ID');
        JTMem_JPerson_ID:=rs.Fields.Get_saValue('JTMem_JPerson_ID');
        JTMem_JCompany_ID:=rs.Fields.Get_saValue('JTMem_JCompany_ID');
        JTMem_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JTMem_CreatedBy_JUser_ID');
        JTMem_Created_DT                 :=rs.Fields.Get_saValue('JTMem_Created_DT');
        JTMem_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JTMem_ModifiedBy_JUser_ID');
        JTMem_Modified_DT                :=rs.Fields.Get_saValue('JTMem_Modified_DT');
        JTMem_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JTMem_DeletedBy_JUser_ID');
        JTMem_Deleted_DT                 :=rs.Fields.Get_saValue('JTMem_Deleted_DT');
        JTMem_Deleted_b                  :=rs.Fields.Get_saValue('JTMem_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113422,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jteammember(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTeamMember: rtJTeamMember; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jteammember'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113423,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113424, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJTeamMember.JTMem_JTeamMember_UID)=0 then
  begin
    bAddNew:=true;
    p_rJTeamMember.JTMem_JTeamMember_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jteammember');
    bOk:=(u8Val(p_rJTeamMember.JTMem_JTeamMember_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152141,'Problem getting an UID for new jteammember record.','saJAS_GetNextUID table: jteammember',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jteammember (JTMem_JTeamMember_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJTeamMember.JTMem_JTeamMember_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162095);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152142,'Problem creating a new jteammember record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJTeamMember.JTMem_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJTeamMember.JTMem_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJTeamMember.JTMem_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJTeamMember.JTMem_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJTeamMember.JTMem_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJTeamMember.JTMem_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jteammember', p_rJTeamMember.JTMem_JTeamMember_UID, '0',201506200345);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152143,'Problem locking jteammember record.','p_rJTeamMember.JTMem_JTeamMember_UID:'+p_rJTeamMember.JTMem_JTeamMember_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJTeamMember do begin
      saQry:='UPDATE jteammember set '+
        //' JTMem_JTeamMember_UID='+JAS.saDBMSScrub()+
        'JTMem_JTeam_ID='+JAS.saDBMSUIntScrub(JTMem_JTeam_ID)+
        ',JTMem_JPerson_ID='+JAS.saDBMSUIntScrub(JTMem_JPerson_ID)+
        ',JTMem_JCompany_ID='+JAS.saDBMSUIntScrub(JTMem_JCompany_ID);
        if(bAddNew)then
        begin
          saQry+=',JTMem_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTMem_CreatedBy_JUser_ID)+
          ',JTMem_Created_DT='+JAS.saDBMSDateScrub(JTMem_Created_DT);
        end;
        saQry+=
        ',JTMem_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTMem_ModifiedBy_JUser_ID)+
        ',JTMem_Modified_DT='+JAS.saDBMSDateScrub(JTMem_Modified_DT)+
        ',JTMem_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTMem_DeletedBy_JUser_ID)+
        ',JTMem_Deleted_DT='+JAS.saDBMSDateScrub(JTMem_Deleted_DT)+
        ',JTMem_Deleted_b='+JAS.saDBMSBoolScrub(JTMem_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JTMem_JTeamMember_UID='+JAS.saDBMSUIntScrub(JTMem_JTeamMember_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162096);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152144,'Problem updating jteammember.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jteammember', p_rJTeamMember.JTMem_JTeamMember_UID, '0',201506200452) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152145,'Problem unlocking jteammember record.','p_rJTeamMember.JTMem_JTeamMember_UID:'+p_rJTeamMember.JTMem_JTeamMember_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113425,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
function bJAS_Load_jtestone(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTestOne: rtJTestOne; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jtestone'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113426,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113427, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jtestone where JTes1_JTestOne_UID='+JAS.saDBMSUIntScrub(p_rJTestOne.JTes1_JTestOne_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtestone', p_rJTestOne.JTes1_JTestOne_UID, '0',201506200346);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006101059,'Problem locking jtestone record.','p_rJTestOne.JTes1_JTestOne_UID:'+p_rJTestOne.JTes1_JTestOne_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,201503162097);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152146,'Unable to query jtestone successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152147,'Record missing from jtestone.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJTestOne do begin
        //JTes1_JTestOne_UID:=rs.Fields.Get_saValue('');
        JTes1_Text:=rs.Fields.Get_saValue('JTes1_Text');
        JTes1_Boolean_b:=rs.Fields.Get_saValue('JTes1_Boolean_b');
        JTes1_Memo:=rs.Fields.Get_saValue('JTes1_Memo');
        JTes1_DateTime_DT:=rs.Fields.Get_saValue('JTes1_DateTime_DT');
        JTes1_Integer_i:=rs.Fields.Get_saValue('JTes1_Integer_i');
        JTes1_Currency_d:=rs.Fields.Get_saValue('JTes1_Currency_d');
        JTes1_Memo2:=rs.Fields.Get_saValue('JTes1_Memo2');
        JTes1_Added_DT:=rs.Fields.Get_saValue('JTes1_Added_DT');
        JTes1_RemoteIP:=rs.Fields.Get_saValue('JTes1_RemoteIP');
        JTes1_RemotePort_u:=rs.Fields.Get_saValue('JTes1_RemotePort');
        JTes1_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JTes1_CreatedBy_JUser_ID');
        JTes1_Created_DT                 :=rs.Fields.Get_saValue('JTes1_Created_DT');
        JTes1_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JTes1_ModifiedBy_JUser_ID');
        JTes1_Modified_DT                :=rs.Fields.Get_saValue('JTes1_Modified_DT');
        JTes1_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JTes1_DeletedBy_JUser_ID');
        JTes1_Deleted_DT                 :=rs.Fields.Get_saValue('JTes1_Deleted_DT');
        JTes1_Deleted_b                  :=rs.Fields.Get_saValue('JTes1_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113428,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jtestone(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTestOne: rtJTestOne; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jtestone'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113429,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113430, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJTestOne.JTes1_JTestOne_UID)=0 then
  begin
    bAddNew:=true;
    p_rJTestOne.JTes1_JTestOne_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jtestone');
    bOk:=(u8Val(p_rJTestOne.JTes1_JTestOne_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152148,'Problem getting an UID for new jtestone record.','saJAS_GetNextUID table: jtestone',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jtestone (JTes1_JTestOne_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJTestOne.JTes1_JTestOne_UID) + ')';
      bOk:=rs.Open(saQry,JAS,201503162098);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152149,'Problem creating a new jtestone record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJTestOne.JTes1_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJTestOne.JTes1_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJTestOne.JTes1_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJTestOne.JTes1_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJTestOne.JTes1_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJTestOne.JTes1_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtestone', p_rJTestOne.JTes1_JTestOne_UID, '0',201506200346);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152150,'Problem locking jtestone record.','p_rJTestOne.JTes1_JTestOne_UID:'+p_rJTestOne.JTes1_JTestOne_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJTestOne do begin
      saQry:='UPDATE jtestone set '+
        //' JTes1_JTestOne_UID='+JAS.saDBMSScrub()+
        'JTes1_Text='+JAS.saDBMSScrub(JTes1_Text)+
        ',JTes1_Boolean_b='+JAS.saDBMSBoolScrub(bVal(JTes1_Boolean_b))+
        ',JTes1_DateTime_DT='+JAS.saDBMSDAteScrub(JTes1_DateTime_DT)+
        ',JTes1_Integer_i='+JAS.saDBMSIntScrub(JTes1_Integer_i)+
        ',JTes1_Currency_d='+JAS.saDBMSDecScrub(JTes1_Currency_d)+
        ',JTes1_Added_DT='+JAS.saDBMSDateScrub(JTes1_Added_DT)+
        ',JTes1_RemoteIP='+JAS.saDBMSScrub(JTes1_RemoteIP)+
        ',JTes1_RemotePort_u='+JAS.saDBMSUIntScrub(JTes1_RemotePort_u)+
        ',JTes1_Memo='+JAS.saDBMSScrub(JTes1_Memo)+
        ',JTes1_Memo2='+JAS.saDBMSScrub(JTes1_Memo2);
        if(bAddNew)then
        begin
          saQry+=',JTes1_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTes1_CreatedBy_JUser_ID)+
          ',JTes1_Created_DT='+JAS.saDBMSDateScrub(JTes1_Created_DT);
        end;
        saQry+=
        ',JTes1_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTes1_ModifiedBy_JUser_ID)+
        ',JTes1_Modified_DT='+JAS.saDBMSDateScrub(JTes1_Modified_DT)+
        ',JTes1_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JTes1_DeletedBy_JUser_ID)+
        ',JTes1_Deleted_DT='+JAS.saDBMSDateScrub(JTes1_Deleted_DT)+
        ',JTes1_Deleted_b='+JAS.saDBMSBoolScrub(JTes1_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JTes1_JTestOne_UID='+JAS.saDBMSUIntScrub(JTes1_JTestOne_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,201503162099);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152151,'Problem updating jtestone.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jtestone', p_rJTestOne.JTes1_JTestOne_UID, '0',201506200453) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152152,'Problem unlocking jtestone record.','p_rJTestOne.JTes1_JTestOne_UID:'+p_rJTestOne.JTes1_JTestOne_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113431,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================








//=============================================================================
function bJAS_Load_jthemecolor(p_DBC: JADO_CONNECTION; var p_rjthemecolor: rtjthemecolor): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jthemecolor'; sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210090610,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
//{IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210090611, sTHIS_ROUTINE_NAME);{ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jthemecolor where THCOL_JThemeColor_UID='+JAS.saDBMSUIntScrub(p_rJThemeColor.THCOL_JThemeColor_UID);
  bOk:=true;
  //if p_bGetLock then
  //begin
  //  bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jthemecolor', p_rJTheme.THCOL_JThemeColor_UID, '0',201506200347);
  //  if not bOK then
  //  begin
  //    JAS_Log(p_Context,cnLog_Error,201210090612,'Problem locking jthemecolor record.',
  //      'p_rJThemeColor.THCOL_JThemeColor_UID:'+p_rJThemeColor.THCOL_JThemeColor_UID,SOURCEFILE);
  //  end;
  //end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,2015031621100);
    if not bOk then
    begin
      JLog(cnLog_Error,201210090613,'Unable to query jthemecolor successfully Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201005311905,'Record missing from jthemecolor.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rjthemecolor do begin
        THCOL_JThemeColor_UID       :=rs.Fields.get_saValue('THCOL_JThemeColor_UID');
        THCOL_Name                  :=rs.Fields.get_saValue('THCOL_Name');
        THCOL_Desc                  :=rs.Fields.get_saValue('THCOL_Desc');
        THCOL_CreatedBy_JUser_ID    :=rs.Fields.get_saValue('THCOL_CreatedBy_JUser_ID');
        THCOL_Created_DT            :=rs.Fields.get_saValue('THCOL_Created_DT');
        THCOL_ModifiedBy_JUser_ID   :=rs.Fields.get_saValue('THCOL_ModifiedBy_JUser_ID');
        THCOL_Modified_DT           :=rs.Fields.get_saValue('THCOL_Modified_DT');
        THCOL_DeletedBy_JUser_ID    :=rs.Fields.get_saValue('THCOL_DeletedBy_JUser_ID');
        THCOL_Deleted_DT            :=rs.Fields.get_saValue('THCOL_Deleted_DT');
        THCOL_Deleted_b             :=rs.Fields.get_saValue('THCOL_Deleted_b');
        JAS_Row_b                   :=rs.Fields.get_saValue('JAS_Row_b');
        THCOL_Template_Header       :=rs.Fields.get_saValue('THCOL_Template_Header');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210090614,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jthemecolor(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjthemecolor: rtjthemecolor; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jthemecolor'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210090615,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210090616, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJThemeColor.THCOL_JThemeColor_UID)=0 then
  begin
    bAddNew:=true;
    p_rJThemeColor.THCOL_JThemeColor_UID:=saJAS_GetNextUID;
    bOk:=(u8Val(p_rJThemeColor.THCOL_JThemeColor_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210090617,'Problem getting an UID for new jthemecolor record.','saJAS_GetNextUID table: jthemecolor',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jthemecolor (THCOL_JThemeColor_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rJThemeColor.THCOL_JThemeColor_UID)+ ')';
      bOk:=rs.Open(saQry,JAS,2015031621101);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201210090618,'Problem creating a new jthemecolor record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rjthemecolor.THCOL_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJThemecolor.THCOL_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJThemecolor.THCOL_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJThemecolor.THCOL_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rjthemecolor.THCOL_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rjthemecolor.THCOL_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jthemecolor', p_rJThemeColor.THCOL_JThemeColor_UID, '0',201506200348);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201210090619,'Problem locking jthemecolor record.','p_rJThemeColor.THCOL_JThemeColor_UID:'+p_rJThemeColor.THCOL_JThemeColor_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rjthemecolor do begin
      saQry:='UPDATE jthemecolor set '+
        // THCOL_JThemeColor_UID
        ' THCOL_Name='+JAS.saDBMSScrub(THCOL_Name)+
        ',THCOL_Desc='+JAS.saDBMSScrub(THCOL_Desc);
      if bAddNew then
      begin
        saQry+=
        ',THCOL_CreatedBy_JUser_ID='+JAS.saDBMSUintScrub(THCOL_CreatedBy_JUser_ID)+
        ',THCOL_Created_DT='+JAS.saDBMSDateScrub(THCOL_Created_DT);
      end;
      saQry+=
        ',THCOL_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(THCOL_ModifiedBy_JUser_ID)+
        ',THCOL_Modified_DT='+JAS.saDBMSDateScrub(THCOL_Modified_DT)+
        ',THCOL_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(THCOL_DeletedBy_JUser_ID)+
        ',THCOL_Deleted_DT='+JAS.saDBMSDateScrub(THCOL_Deleted_DT)+
        ',THCOL_Deleted_b='+JAS.saDBMSBoolScrub(THCOL_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ',THCOL_Template_Header='+JAS.saDBMSScrub(THCOL_Template_Header)+
        ' WHERE THCOL_JThemeColor_UID='+JAS.saDBMSUIntScrub(THCOL_JThemeColor_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,2015031621102);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210090620,'Problem updating jthemecolor.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jthemecolor', p_rJThemeColor.THCOL_JThemeColor_UID, '0',201506200454) then
      begin
        JAS_Log(p_Context,cnLog_Error,201210090621,'Problem unlocking jthemecolor record.','p_rJThemeColor.THCOL_JThemeColor_UID:'+p_rJThemeColor.THCOL_JThemeColor_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210090622,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
end;
//=============================================================================











//=============================================================================
function bJAS_Load_jtimecard(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjtimecard: rtjtimecard; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jtimecard'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113432,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113433, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jtimecard where TMCD_TimeCard_UID='+JAS.saDBMSUIntScrub(p_rjtimecard.TMCD_TimeCard_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtimecard', p_rjtimecard.TMCD_TimeCard_UID, '0',201506200349);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006101049,'Problem locking jtimecard record.','p_rjtimecard.TMCD_TimeCard_UID:'+p_rjtimecard.TMCD_TimeCard_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,2015031621103);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311904,'Unable to query jtimecard successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201005311905,'Record missing from jtimecard.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rjtimecard do begin
        //TMCD_TimeCard_UID           :=rs.Fields.Get_saValue('TMCD_TimeCard_UID');
        TMCD_Name                   :=rs.Fields.Get_saValue('TMCD_Name');
        TMCD_In_DT                  :=rs.Fields.Get_saValue('TMCD_In_DT');
        TMCD_Out_DT                 :=rs.Fields.Get_saValue('TMCD_Out_DT');
        TMCD_JNote_Public_ID        :=rs.Fields.Get_saValue('TMCD_JNote_Public_ID');
        TMCD_JNote_Internal_ID      :=rs.Fields.Get_saValue('TMCD_JNote_Internal_ID');
        TMCD_Reference              :=rs.Fields.Get_saValue('TMCD_Reference');
        TMCD_JProject_ID            :=rs.Fields.Get_saValue('TMCD_JProject_ID');
        TMCD_JTask_ID               :=rs.Fields.Get_saValue('TMCD_JTask_ID');
        TMCD_Billable_b             :=rs.Fields.Get_saValue('TMCD_Billable_b');
        TMCD_ManualEntry_b          :=rs.Fields.Get_saValue('TMCD_ManualEntry_b');
        TMCD_ManualEntry_DT         :=rs.Fields.Get_saValue('TMCD_ManualEntry_DT');
        TMCD_Exported_b             :=rs.Fields.Get_saValue('TMCD_Exported_b');
        TMCD_Exported_DT            :=rs.Fields.Get_saValue('TMCD_Exported_DT');
        TMCD_Uploaded_b             :=rs.Fields.Get_saValue('TMCD_Uploaded_b');
        TMCD_Uploaded_DT            :=rs.Fields.Get_saValue('TMCD_Uploaded_DT');
        TMCD_PayrateName            :=rs.Fields.Get_saValue('TMCD_PayrateName');
        TMCD_Payrate_d              :=rs.Fields.Get_saValue('TMCD_Payrate_d');
        TMCD_Expense_b              :=rs.Fields.Get_saValue('TMCD_Expense_b');
        TMCD_Imported_b             :=rs.Fields.Get_saValue('TMCD_Imported_b');
        TMCD_Imported_DT            :=rs.Fields.Get_saValue('TMCD_Imported_DT');
        TMCD_Note_Internal          :=rs.Fields.Get_saValue('TMCD_Note_Internal');
        TMCD_Note_Public            :=rs.Fields.Get_saValue('TMCD_Note_Public');
        TMCD_Invoice_Sent_b         :=rs.Fields.Get_saValue('TMCD_Invoice_Sent_b');
        TMCD_Invoice_Paid_b         :=rs.Fields.Get_saValue('TMCD_Invoice_Paid_b');
        TMCD_Invoice_No             :=rs.Fields.Get_saValue('TMCD_Invoice_No ');
        TMCD_CreatedBy_JUser_ID     :=rs.Fields.Get_saValue('TMCD_CreatedBy_JUser_ID');
        TMCD_Created_DT             :=rs.Fields.Get_saValue('TMCD_Created_DT');
        TMCD_ModifiedBy_JUser_ID    :=rs.Fields.Get_saValue('TMCD_ModifiedBy_JUser_ID');
        TMCD_Modified_DT            :=rs.Fields.Get_saValue('TMCD_Modified_DT');
        TMCD_DeletedBy_JUser_ID     :=rs.Fields.Get_saValue('TMCD_DeletedBy_JUser_ID');
        TMCD_Deleted_DT             :=rs.Fields.Get_saValue('TMCD_Deleted_DT');
        TMCD_Deleted_b              :=rs.Fields.Get_saValue('TMCD_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113434,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jtimecard(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rjtimecard: rtjtimecard; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jtimecard'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113435,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113436, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rjtimecard.TMCD_TimeCard_UID)=0 then
  begin
    bAddNew:=true;
    p_rjtimecard.TMCD_TimeCard_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jtimecard');
    bOk:=(u8Val(p_rjtimecard.TMCD_TimeCard_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311906,'Problem getting an UID for new jtimecard record.','saJAS_GetNextUID table: jtimecard',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jtimecard (TMCD_TimeCard_UID) VALUES ('+ JAS.saDBMSUintScrub(p_rjtimecard.TMCD_TimeCard_UID)+ ')';
      bOk:=rs.Open(saQry,JAS,2015031621104);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311907,'Problem creating a new jtimecard record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rjtimecard.TMCD_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rjtimecard.TMCD_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rjtimecard.TMCD_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rjtimecard.TMCD_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rjtimecard.TMCD_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rjtimecard.TMCD_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtimecard', p_rjtimecard.TMCD_TimeCard_UID, '0',201506200350);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311908,'Problem locking jtimecard record.','p_rjtimecard.TMCD_TimeCard_UID:'+p_rjtimecard.TMCD_TimeCard_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rjtimecard do begin
      saQry:='UPDATE jtimecard set '+
        //' TMCD_TimeCard_UID='+JAS.saDBMSScrub(TMCD_TimeCard_UID)+
        'TMCD_Name='+JAS.saDBMSScrub(TMCD_Name)+
        ',TMCD_In_DT='+JAS.saDBMSDateScrub(TMCD_In_DT)+
        ',TMCD_Out_DT='+JAS.saDBMSDateScrub(TMCD_Out_DT)+
        ',TMCD_JNote_Public_ID='+JAS.saDBMSUIntScrub(TMCD_JNote_Public_ID)+
        ',TMCD_JNote_Internal_ID='+JAS.saDBMSUIntScrub(TMCD_JNote_Internal_ID)+
        ',TMCD_Reference='+JAS.saDBMSScrub(TMCD_Reference)+
        ',TMCD_JProject_ID='+JAS.saDBMSUIntScrub(TMCD_JProject_ID)+
        ',TMCD_JTask_ID='+JAS.saDBMSUIntScrub(TMCD_JTask_ID)+
        ',TMCD_Billable_b='+JAS.saDBMSBoolScrub(TMCD_Billable_b)+
        ',TMCD_ManualEntry_b='+JAS.saDBMSBoolScrub(TMCD_ManualEntry_b)+
        ',TMCD_ManualEntry_DT='+JAS.saDBMSDateScrub(TMCD_ManualEntry_DT)+
        ',TMCD_Exported_b='+JAS.saDBMSBoolScrub(TMCD_Exported_b)+
        ',TMCD_Exported_DT='+JAS.saDBMSDateScrub(TMCD_Exported_DT)+
        ',TMCD_Uploaded_b='+JAS.saDBMSBoolScrub(TMCD_Uploaded_b)+
        ',TMCD_Uploaded_DT='+JAS.saDBMSDateScrub(TMCD_Uploaded_DT)+
        ',TMCD_PayrateName='+JAS.saDBMSScrub(TMCD_PayrateName)+
        ',TMCD_Payrate_d='+JAS.saDBMSDEcScrub(TMCD_Payrate_d)+
        ',TMCD_Expense_b='+JAS.saDBMSBoolScrub(TMCD_Expense_b)+
        ',TMCD_Imported_b='+JAS.saDBMSBoolScrub(TMCD_Imported_b)+
        ',TMCD_Imported_DT='+JAS.saDBMSDateScrub(TMCD_Imported_DT)+
        ',TMCD_Note_Internal='+JAS.saDBMSScrub(TMCD_Note_Internal)+                
        ',TMCD_Note_Public'+JAS.saDBMSScrub(TMCD_Note_Public)+                  
        ',TMCD_Invoice_Sent_b'+JAS.saDBMSScrub(TMCD_Invoice_Sent_b)+               
        ',TMCD_Invoice_Paid_b'+JAS.saDBMSScrub(TMCD_Invoice_Paid_b)+               
        ',TMCD_Invoice_No'+JAS.saDBMSScrub(TMCD_Invoice_No);
        if(bAddNew)then
        begin
          saQry+=',TMCD_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(TMCD_CreatedBy_JUser_ID)+
          ',TMCD_Created_DT='+JAS.saDBMSDateScrub(TMCD_Created_DT);
        end;
        saQry+=
        ',TMCD_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(TMCD_ModifiedBy_JUser_ID)+
        ',TMCD_Modified_DT='+JAS.saDBMSDateScrub(TMCD_Modified_DT)+
        ',TMCD_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(TMCD_DeletedBy_JUser_ID)+
        ',TMCD_Deleted_DT='+JAS.saDBMSDateScrub(TMCD_Deleted_DT)+
        ',TMCD_Deleted_b='+JAS.saDBMSBoolScrub(TMCD_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE TMCD_TimeCard_UID='+JAS.saDBMSUIntScrub(TMCD_TimeCard_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,2015031621105);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201005311909,'Problem updating jtimecard.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jtimecard', p_rjtimecard.TMCD_TimeCard_UID, '0',201506200455) then
      begin
        JAS_Log(p_Context,cnLog_Error,201005311910,'Problem unlocking jtimecard record.','p_rjtimecard.TMCD_TimeCard_UID:'+p_rjtimecard.TMCD_TimeCard_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113437,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================













//=============================================================================
function bJAS_Load_jtrak(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTrak: rtJTrak; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jtrak'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113438,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113439, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jtrak where JTrak_JTrak_UID='+JAS.saDBMSUIntScrub(p_rJTrak.JTrak_JTrak_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jtrak', p_rJTrak.JTrak_JTrak_UID, '0',201506200351);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006101101,'Problem locking jtrak record.','p_rJTrak.JTrak_JTrak_UID:'+p_rJTrak.JTrak_JTrak_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,2015031621106);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152153,'Unable to query jtrak successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152154,'Record missing from jtrak.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJTrak do begin
        //JTrak_JTrak_UID         :=rs.Fields.Get_saValue('JTrak_JTrak_UID');
        JTrak_JDConnection_ID          :=rs.Fields.Get_saValue('JTrak_JDConnection_ID');
        JTrak_JSession_ID              :=rs.Fields.Get_saValue('JTrak_JSession_ID');
        JTrak_JTable_ID                :=rs.Fields.Get_saValue('JTrak_JTable_ID');
        JTrak_Row_ID                   :=rs.Fields.Get_saValue('JTrak_Row_ID');
        JTrak_Col_ID                   :=rs.Fields.Get_saValue('JTrak_Col_ID');
        JTrak_JUser_ID                 :=rs.Fields.Get_saValue('JTrak_JUser_ID');
        JTrak_Create_b                 :=rs.Fields.Get_saValue('JTrak_Create_b');
        JTrak_Modify_b                 :=rs.Fields.Get_saValue('JTrak_Modify_b');
        JTrak_Delete_b                 :=rs.Fields.Get_saValue('JTrak_Delete_b');
        JTrak_When_DT                  :=rs.Fields.Get_saValue('JTrak_When_DT');
        JTrak_Before                   :=rs.Fields.Get_saValue('JTrak_Before');
        JTrak_After                    :=rs.Fields.Get_saValue('JTrak_After');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113440,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jtrak(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJTrak: rtJTrak): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jtrak'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203252138,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203252139, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  with p_rJTrak do begin
    //JTrak_JTrak_UID           :=
    saQry:=
      'INSERT INTO jtrak ('+
        'JTrak_JDConnection_ID,'+
        'JTrak_JSession_ID,'+
        'JTrak_JTable_ID,'+
        'JTrak_Row_ID,'+
        'JTrak_Col_ID,'+
        'JTrak_JUser_ID,'+
        'JTrak_Create_b,'+
        'JTrak_Modify_b,'+
        'JTrak_Delete_b,'+
        'JTrak_When_DT,'+
        'JTrak_Before,'+
        'JTrak_After'+
      ') VALUES (' +
         JAS.saDBMSUIntScrub(JTrak_JDConnection_ID)+','+
        JAS.saDBMSUIntScrub(JTrak_JSession_ID    )+','+
        JAS.saDBMSUIntScrub(JTrak_JTable_ID      )+','+
        JAS.saDBMSUIntScrub(JTrak_Row_ID         )+','+
        JAS.saDBMSUIntScrub(JTrak_Col_ID         )+','+
        JAS.saDBMSUIntScrub(JTrak_JUser_ID       )+','+
        JAS.saDBMSBoolScrub(JTrak_Create_b       )+','+
        JAS.saDBMSBoolScrub(JTrak_Modify_b       )+','+
        JAS.saDBMSBoolScrub(JTrak_Delete_b       )+','+
        JAS.saDBMSDateScrub(JTrak_When_DT        )+','+
        JAS.saDBMSScrub(JTrak_Before         )+','+
        JAS.saDBMSScrub(JTrak_After          )+' '+
      ')';
  end;//with
  bOk:=rs.open(saQry, JAS,2015031621107);
  if not bOk then
  begin
    JAS_LOG(p_Context, cnLog_Error, 201203252143, 'Trouble with query.','Query: '+saQry,SOURCEFILE,JAS,rs);
  end;
  rs.close;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203252145,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
function bJAS_Load_juser(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUser: rtJUser; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_juser'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113451,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113452, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from juser where JUser_JUser_UID='+JAS.saDBMSUIntScrub(p_rJUser.JUser_JUser_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'juser', inttostR(p_rJUser.JUser_JUser_UID), '0',201506200352);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006101104,'Problem locking juser record.','p_rJUser.JUser_JUser_UID:'+inttostR(p_rJUser.JUser_JUser_UID),SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,2015031621108);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152207,'Unable to query juser successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152208,'Record missing from juser.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJUser do begin
        //JUser_JUser_UID              :=rs.Fields.Get_saValue('');
        JUser_Name                   :=rs.Fields.Get_saValue('JUser_Name');
        JUser_Password               :=rs.Fields.Get_saValue('JUser_Password');
        JUser_JPerson_ID             :=u8Val(rs.Fields.Get_saValue('JUser_JPerson_ID'));
        JUser_Enabled_b              :=bVal(rs.Fields.Get_saValue('JUser_Enabled_b'));
        JUser_Admin_b                :=bVal(rs.Fields.Get_saValue('JUser_Admin_b'));
        JUser_Login_First_DT         :=rs.Fields.Get_saValue('JUser_Login_First_DT');
        JUser_Login_Last_DT          :=rs.Fields.Get_saValue('JUser_Login_Last_DT');
        JUser_Logins_Successful_u    :=u4Val(rs.Fields.Get_saValue('JUser_Logins_Successful_u'));
        JUser_Logins_Failed_u        :=u4Val(rs.Fields.Get_saValue('JUser_Logins_Failed_u'));
        JUser_Password_Changed_DT    :=rs.Fields.Get_saValue('JUser_Password_Changed_DT');
        JUser_AllowedSessions_u      :=u1Val(rs.Fields.Get_saValue('JUser_AllowedSessions_u'));
        JUser_DefaultPage_Login      :=rs.Fields.Get_saValue('JUser_DefaultPage_Login');
        JUser_DefaultPage_Logout     :=rs.Fields.Get_saValue('JUser_DefaultPage_Logout');
        JUser_JLanguage_ID           :=u8Val(rs.Fields.Get_saValue('JUser_JLanguage_ID'));
        JUser_Audit_b                :=bVal(rs.Fields.Get_saValue('JUser_Audit_b'));
        JUser_ResetPass_u            :=u8Val(rs.Fields.Get_saValue('JUser_ResetPass_u'));
        JUser_JVHost_ID              :=rs.Fields.Get_saValue('JUser_JVHost_ID');
        JUser_TotalJetUsers_d        :=rs.Fields.Get_saValue('JUser_TotalJetUsers_d');
        JUser_SIP_Exten              :=rs.fields.Get_saValue('JUser_SIP_Exten');
        JUser_SIP_Pass              :=rs.fields.Get_saValue('JUser_SIP_Pass');
        JUser_CreatedBy_JUser_ID     :=rs.Fields.Get_saValue('JUser_CreatedBy_JUser_ID');
        JUser_Created_DT             :=rs.Fields.Get_saValue('JUser_Created_DT');
        JUser_ModifiedBy_JUser_ID    :=rs.Fields.Get_saValue('JUser_ModifiedBy_JUser_ID');
        JUser_Modified_DT            :=rs.Fields.Get_saValue('JUser_Modified_DT');
        JUser_DeletedBy_JUser_ID     :=rs.Fields.Get_saValue('JUser_DeletedBy_JUser_ID');
        JUser_Deleted_DT             :=rs.Fields.Get_saValue('JUser_Deleted_DT');
        JUser_Deleted_b              :=rs.Fields.Get_saValue('JUser_Deleted_b');
        JAS_Row_b                    :=bVal(rs.Fields.Get_saValue('JAS_Row_b'));
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113453,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_juser(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUser: rtJUser; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_juser'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113454,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113455, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if p_rJUser.JUser_JUser_UID=0 then
  begin
    bAddNew:=true;
    p_rJUser.JUser_JUser_UID:=u8Val(saJAS_GetNextUID);//(p_Context,'0', 'juser');
    bOk:=p_rJUser.JUser_JUser_UID>0;
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152209,'Problem getting an UID for new juser record.','saJAS_GetNextUID table: juser',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO juser (JUser_JUser_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJUser.JUser_JUser_UID) + ')';
      bOk:=rs.Open(saQry,JAS,2015031621109);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152210,'Problem creating a new juser record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJUser.JUser_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJUser.JUser_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJUser.JUser_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJUser.JUser_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJUser.JUser_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJUser.JUser_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'juser', inttostR(p_rJUser.JUser_JUser_UID), '0',201506200353);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152211,'Problem locking juser record.','p_rJUser.JUser_JUser_UID:'+inttostR(p_rJUser.JUser_JUser_UID),SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJUser do begin
      saQry:='UPDATE juser set '+
        //' JUser_JUser_UID='+JAS.saDBMSScrub()+
        'JUser_Name='+JAS.saDBMSScrub(JUser_Name)+
        ',JUser_Password='+JAS.saDBMSScrub(JUser_Password)+
        ',JUser_JPerson_ID='+JAS.saDBMSUIntScrub(JUser_JPerson_ID)+
        ',JUser_Enabled_b='+JAS.saDBMSBoolScrub(JUser_Enabled_b)+
        ',JUser_Admin_b='+JAS.saDBMSBoolScrub(JUser_Admin_b)+
        ',JUser_Login_First_DT='+JAS.saDBMSDateScrub(JUser_Login_First_DT)+
        ',JUser_Login_Last_DT='+JAS.saDBMSDateScrub(JUser_Login_Last_DT)+
        ',JUser_Logins_Successful_u='+JAS.saDBMSUIntScrub(JUser_Logins_Successful_u)+
        ',JUser_Logins_Failed_u='+JAS.saDBMSUIntScrub(JUser_Logins_Failed_u)+
        ',JUser_Password_Changed_DT='+JAS.saDBMSDateScrub(JUser_Password_Changed_DT)+
        ',JUser_AllowedSessions_u='+JAS.saDBMSUIntScrub(JUser_AllowedSessions_u)+
        ',JUser_DefaultPage_Login='+JAS.saDBMSScrub(JUser_DefaultPage_Login)+
        ',JUser_DefaultPage_Logout='+JAS.saDBMSScrub(JUser_DefaultPage_Logout)+
        ',JUser_JLanguage_ID='+JAS.saDBMSUIntScrub(JUser_JLanguage_ID)+
        ',JUser_Audit_b='+JAS.saDBMSBoolScrub(JUser_Audit_b)+
        ',JUser_ResetPass_u='+JAS.saDBMSUIntScrub(JUser_ResetPass_u)+
        ',JUser_JVHost_ID='+JAS.saDBMSUintscrub(JUser_JVHost_ID)+
        ',JUser_TotalJetUsers_d='+JAS.saDBMSDecscrub(JUser_TotalJetUsers_d)+
        ',JUSER_SIP_Exten='+JAS.saDBMSScrub(JUser_SIP_Exten)+
        ',JUSER_SIP_Pass='+JAS.saDBMSScrub(JUser_SIP_Pass);
        if(bAddNew)then
        begin
          saQry+=',JUser_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JUser_CreatedBy_JUser_ID)+
          ',JUser_Created_DT='+JAS.saDBMSDateScrub(JUser_Created_DT);
        end;
        saQry+=
        ',JUser_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JUser_ModifiedBy_JUser_ID)+
        ',JUser_Modified_DT='+JAS.saDBMSDateScrub(JUser_Modified_DT)+
        ',JUser_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JUser_DeletedBy_JUser_ID)+
        ',JUser_Deleted_DT='+JAS.saDBMSDateScrub(JUser_Deleted_DT)+
        ',JUser_Deleted_b='+JAS.saDBMSBoolScrub(JUser_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JUser_JUser_UID='+JAS.saDBMSUIntScrub(JUser_JUser_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,2015031621110);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152212,'Problem updating juser.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'juser', Inttostr(p_rJUser.JUser_JUser_UID), '0',201506200456) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152213,'Problem unlocking juser record.','p_rJUser.JUser_JUser_UID:'+inttostR(p_rJUser.JUser_JUser_UID),SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113456,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
function bJAS_Load_juserpref(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUserPref: rtJUserPref; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_juserpref'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113457,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113458, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from juserpref where UserP_UserPref_UID='+JAS.saDBMSUIntScrub(p_rJUserPref.UserP_UserPref_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'juserpref', p_rJUserPref.UserP_UserPref_UID, '0',201506200354);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006101105,'Problem locking juserpref record.','p_rJUserPref.UserP_UserPref_UID:'+p_rJUserPref.UserP_UserPref_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,2015031621111);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152214,'Unable to query juserpref successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152215,'Record missing from juserpref.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJUserPref do begin
        //UserP_UserPref_UID:=rs.Fields.Get_saValue('');
        UserP_Name:=rs.Fields.Get_saValue('UserP_Name');
        UserP_Desc:=rs.Fields.Get_saValue('UserP_Desc');
        UserP_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('UserP_CreatedBy_JUser_ID');
        UserP_Created_DT                 :=rs.Fields.Get_saValue('UserP_Created_DT');
        UserP_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('UserP_ModifiedBy_JUser_ID');
        UserP_Modified_DT                :=rs.Fields.Get_saValue('UserP_Modified_DT');
        UserP_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('UserP_DeletedBy_JUser_ID');
        UserP_Deleted_DT                 :=rs.Fields.Get_saValue('UserP_Deleted_DT');
        UserP_Deleted_b                  :=rs.Fields.Get_saValue('UserP_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113459,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_juserpref(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUserPref: rtJUserPref; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_juserpref'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113460,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113461, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJUserPref.UserP_UserPref_UID)=0 then
  begin
    bAddNew:=true;
    p_rJUserPref.UserP_UserPref_UID:=saJAS_GetNextUID;//(p_Context,'0', 'juserpref');
    bOk:=(u8Val(p_rJUserPref.UserP_UserPref_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152216,'Problem getting an UID for new juserpref record.','saJAS_GetNextUID table: juserpref',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO juserpref (.UserP_UserPref_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJUserPref.UserP_UserPref_UID) + ')';
      bOk:=rs.Open(saQry,JAS,2015031621112);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152217,'Problem creating a new juserpref record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJUserPref.UserP_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJUserPref.UserP_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJUserPref.UserP_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJUserPref.UserP_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJUserPref.UserP_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJUserPref.UserP_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'juserpref', p_rJUserPref.UserP_UserPref_UID, '0',201506200360);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152218,'Problem locking juserpref record.','p_rJUserPref.UserP_UserPref_UID:'+p_rJUserPref.UserP_UserPref_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJUserPref do begin
      saQry:='UPDATE juserpref set '+
        //' UserP_UserPref_UID='+JAS.saDBMSScrub()+
        'UserP_Name='+JAS.saDBMSScrub(UserP_Name)+
        ',UserP_Desc='+JAS.saDBMSScrub(UserP_Desc);
        if(bAddNew)then
        begin
          saQry+=',UserP_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(UserP_CreatedBy_JUser_ID)+
          ',UserP_Created_DT='+JAS.saDBMSDateScrub(UserP_Created_DT);
        end;
        saQry+=
        ',UserP_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(UserP_ModifiedBy_JUser_ID)+
        ',UserP_Modified_DT='+JAS.saDBMSDateScrub(UserP_Modified_DT)+
        ',UserP_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(UserP_DeletedBy_JUser_ID)+
        ',UserP_Deleted_DT='+JAS.saDBMSDateScrub(UserP_Deleted_DT)+
        ',UserP_Deleted_b='+JAS.saDBMSBoolScrub(UserP_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE UserP_UserPref_UID='+JAS.saDBMSUIntScrub(UserP_UserPref_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,2015031621113);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152219,'Problem updating juserpref.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'juserpref', p_rJUserPref.UserP_UserPref_UID, '0',201506200457) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152220,'Problem unlocking juserpref record.','p_rJUserPref.UserP_UserPref_UID:'+p_rJUserPref.UserP_UserPref_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113462,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Load_juserpreflink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUserPrefLink: rtJUserPrefLink; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_juserpreflink'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113463,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113464, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from juserpreflink where UsrPL_UserPrefLink_UID='+JAS.saDBMSUIntScrub(p_rJUserPrefLink.UsrPL_UserPrefLink_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'juserpreflink', p_rJUserPrefLink.UsrPL_UserPrefLink_UID, '0',201506200361);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006101134,'Problem locking juserpreflink record.','p_rJUserPrefLink.UsrPL_UserPrefLink_UID:'+p_rJUserPrefLink.UsrPL_UserPrefLink_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,2015031621114);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152221,'Unable to query juserpreflink successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152222,'Record missing from juserpreflink.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJUserPrefLink do begin
        //UsrPL_UserPrefLink_UID:=rs.Fields.Get_saValue('');
        UsrPL_UserPref_ID:=rs.Fields.Get_saValue('UsrPL_UserPref_ID');
        UsrPL_User_ID:=rs.Fields.Get_saValue('UsrPL_User_ID');
        UsrPL_Value:=rs.Fields.Get_saValue('UsrPL_Value');
        UsrPL_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('UsrPL_CreatedBy_JUser_ID');
        UsrPL_Created_DT                 :=rs.Fields.Get_saValue('UsrPL_Created_DT');
        UsrPL_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('UsrPL_ModifiedBy_JUser_ID');
        UsrPL_Modified_DT                :=rs.Fields.Get_saValue('UsrPL_Modified_DT');
        UsrPL_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('UsrPL_DeletedBy_JUser_ID');
        UsrPL_Deleted_DT                 :=rs.Fields.Get_saValue('UsrPL_Deleted_DT');
        UsrPL_Deleted_b                  :=rs.Fields.Get_saValue('UsrPL_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113465,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_juserpreflink(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJUserPrefLink: rtJUserPrefLink; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_juserpreflink'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113466,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113467, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJUserPrefLink.UsrPL_UserPrefLink_UID)=0 then
  begin
    bAddNew:=true;
    p_rJUserPrefLink.UsrPL_UserPrefLink_UID:=saJAS_GetNextUID;//(p_Context,'0', 'juserpreflink');
    bOk:=(u8Val(p_rJUserPrefLink.UsrPL_UserPrefLink_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152223,'Problem getting an UID for new juserpreflink record.','saJAS_GetNextUID table: juserpreflink',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO juserpreflink (p_rJUserPrefLink.UsrPL_UserPrefLink_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJUserPrefLink.UsrPL_UserPrefLink_UID) + ')';
      bOk:=rs.Open(saQry,JAS,2015031621115);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152224,'Problem creating a new juserpreflink record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJUserPrefLink.UsrPL_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJUserPrefLink.UsrPL_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJUserPrefLink.UsrPL_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJUserPrefLink.UsrPL_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJUserPrefLink.UsrPL_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJUserPrefLink.UsrPL_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'juserpreflink', p_rJUserPrefLink.UsrPL_UserPrefLink_UID, '0',201506200362);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152225,'Problem locking juserpreflink record.','p_rJUserPrefLink.UsrPL_UserPrefLink_UID:'+p_rJUserPrefLink.UsrPL_UserPrefLink_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJUserPrefLink do begin
      saQry:='UPDATE juserpreflink set '+
        //' UsrPL_UserPrefLink_UID='+JAS.saDBMSScrub()+
        'UsrPL_UserPref_ID='+JAS.saDBMSUIntScrub(UsrPL_UserPref_ID)+
        ',UsrPL_User_ID='+JAS.saDBMSUIntScrub(UsrPL_User_ID)+
        ',UsrPL_Value='+JAS.saDBMSScrub(UsrPL_Value);
        if(bAddNew)then
        begin
          saQry+=',UsrPL_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(UsrPL_CreatedBy_JUser_ID)+
          ',UsrPL_Created_DT='+JAS.saDBMSDateScrub(UsrPL_Created_DT);
        end;
        saQry+=
        ',UsrPL_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(UsrPL_ModifiedBy_JUser_ID)+
        ',UsrPL_Modified_DT='+JAS.saDBMSDateScrub(UsrPL_Modified_DT)+
        ',UsrPL_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(UsrPL_DeletedBy_JUser_ID)+
        ',UsrPL_Deleted_DT='+JAS.saDBMSDateScrub(UsrPL_Deleted_DT)+
        ',UsrPL_Deleted_b='+JAS.saDBMSBoolScrub(UsrPL_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE UsrPL_UserPrefLink_UID='+JAS.saDBMSUIntScrub(UsrPL_UserPrefLink_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,2015031621116);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152226,'Problem updating juserpreflink.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'juserpreflink', p_rJUserPrefLink.UsrPL_UserPrefLink_UID, '0',201506200458) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152227,'Problem unlocking juserpreflink record.','p_rJUserPrefLink.UsrPL_UserPrefLink_UID:'+p_rJUserPrefLink.UsrPL_UserPrefLink_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113468,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
//function bJAS_Load_jvhost(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJVHost: rtJVHost; p_bGetLock: boolean): boolean;
function bJAS_Load_jvhost(p_DBC: JADO_CONNECTION; var p_rJVHost: rtJVHost): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jvhost'; sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210080247,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
//{IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210080248, sTHIS_ROUTINE_NAME);{ENDIF}
  //JAS:=p_DBC;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jvhost where VHost_JVHost_UID='+JAS.saDBMSUIntScrub(p_rJVHost.VHost_JVHost_UID);
  bOk:=true;
  //if p_bGetLock then
  //begin
  //  bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jvhost', p_rJVHost.VHost_JVHost_UID, '0',201506200363);
  //  if not bOK then
  //  begin
  //    JAS_Log(p_Context,cnLog_Error,201210080249,'Problem locking jvhost record.','p_rJVHost.VHost_JVHost_UID:'+p_rJVHost.VHost_JVHost_UID,SOURCEFILE);
  //  end;
  //end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,2015031621117);
    if not bOk then
    begin
      JLog(cnLog_Error,201210080250,'Unable to query jvhost successfully Query: '+saQry,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201210080251,'Record missing from juserpreflink.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJVHost do begin
        // VHost_JVHost_UID:=rs.Fields.Get_saValue('');
        VHost_ServerName             :=rs.Fields.Get_saValue('VHost_ServerName');
        VHost_WebRootDir:=rs.Fields.Get_saValue('VHost_WebRootDir');
        VHost_ServerIdent:=rs.Fields.Get_saValue('VHost_ServerIdent');
        VHost_ServerDomain:=rs.Fields.Get_saValue('VHost_ServerDomain');
        VHost_ServerIP:=rs.Fields.Get_saValue('VHost_ServerIP');
        VHost_ServerPort:=rs.Fields.Get_saValue('VHost_ServerPort');
        VHost_DefaultLanguage:=rs.Fields.Get_saValue('VHost_DefaultLanguage');
        VHost_DefaultColorTheme:=rs.Fields.Get_saValue('VHost_DefaultColorTheme');
        VHost_MenuRenderMethod:=          rs.Fields.Get_saValue('VHost_MenuRenderMethod');
        VHost_DefaultArea:=               rs.Fields.Get_saValue('VHost_DefaultArea');
        VHost_DefaultPage:=               rs.Fields.Get_saValue('VHost_DefaultPage');
        VHost_DefaultSection:=            rs.Fields.Get_saValue('VHost_DefaultSection');
        VHost_DefaultTop_JMenu_ID:=       rs.Fields.Get_saValue('VHost_DefaultTop_JMenu_ID');
        VHost_DefaultLoggedInPage:=       rs.Fields.Get_saValue('VHost_DefaultLoggedInPage');
        VHost_DefaultLoggedOutPage:=      rs.Fields.Get_saValue('VHost_DefaultLoggedOutPage');
        VHost_DataOnRight_b:=             rs.Fields.Get_saValue('VHost_DataOnRight_b');
        VHost_CacheMaxAgeInSeconds:=      rs.Fields.Get_saValue('VHost_CacheMaxAgeInSeconds');
        VHost_SystemEmailFromAddress:=    rs.Fields.Get_saValue('VHost_SystemEmailFromAddress');
        VHost_EnableSSL_b:=               rs.Fields.Get_saValue('VHost_EnableSSL_b');
        VHost_SharesDefaultDomain_b:=     rs.Fields.Get_saValue('VHost_SharesDefaultDomain_b');
        VHost_DefaultIconTheme:=          rs.Fields.Get_saValue('VHost_DefaultIconTheme');
        VHost_DirectoryListing_b:=        rs.Fields.Get_saValue('VHost_DirectoryListing_b');
        VHost_FileDir                  := rs.Fields.Get_saValue('VHost_FileDir');
        VHost_TemplateDir                  := rs.Fields.Get_saValue('VHost_TemplateDir');
        VHost_AccessLog                := rs.Fields.Get_saValue('VHost_AccessLog');
        VHost_ErrorLog                 := rs.Fields.Get_saValue('VHost_ErrorLog');
        VHost_JDConnection_ID          := rs.Fields.Get_saValue('VHost_JDConnection_ID');
        VHost_Enabled_b                :=  rs.Fields.Get_saValue('VHost_Enabled_b');
        VHost_CacheDir:=rs.Fields.Get_saValue('VHost_CacheDir');
        VHost_CreatedBy_JUser_ID:=rs.Fields.Get_saValue('VHost_CreatedBy_JUser_ID');
        VHost_Created_DT:=rs.Fields.Get_saValue('VHost_Created_DT');
        VHost_ModifiedBy_JUser_ID:=rs.Fields.Get_saValue('VHost_ModifiedBy_JUser_ID');
        VHost_Modified_DT:=rs.Fields.Get_saValue('VHost_Modified_DT');
        VHost_DeletedBy_JUser_ID:=rs.Fields.Get_saValue('VHost_DeletedBy_JUser_ID');
        VHost_Deleted_DT:=rs.Fields.Get_saValue('VHost_Deleted_DT');
        VHost_Deleted_b:=rs.Fields.Get_saValue('VHost_Deleted_b');
        JAS_Row_b:=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
//{IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210080252,sTHIS_ROUTINE_NAME,SOURCEFILE);{ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jvhost(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJVHost: rtJVHost; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jvhost'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201210080253,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201210080254, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJVHost.VHost_JVHost_UID)=0 then
  begin
    bAddNew:=true;
    p_rJVHost.VHost_JVHost_UID:=saJAS_GetNextUID;
    bOk:=(u8Val(p_rJVHost.VHost_JVHost_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080255,'Problem getting an UID for new jvhost record.','saJAS_GetNextUID table: jvhost',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jvhost (VHost_JVHost_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJVHost.VHost_JVHost_UID) + ')';
      bOk:=rs.Open(saQry,JAS,2015031621118);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201210080256,'Problem creating a new jvhost record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJVHost.VHost_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJVHost.VHost_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJVHost.VHost_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJVHost.VHost_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJVHost.VHost_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJVHost.VHost_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jvhost', p_rJVHost.VHost_JVHost_UID, '0',201506200364);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080257,'Problem locking jvhost record.','p_rJVHost.VHost_JVHost_UID:'+p_rJVHost.VHost_JVHost_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJVHost do begin
      saQry:='UPDATE jvhost set '+
        // VHost_JVHost_UID               : ansistring;
        ' VHost_ServerName='+              JAS.saDBMSScrub(VHost_ServerName)+
        ',VHost_WebRootDir='+              JAS.saDBMSScrub(VHost_WebRootDir)+
        ',VHost_FileDir='+                 JAS.saDBMSScrub(VHost_FileDir)+
        ',VHost_ServerIdent='+             JAS.saDBMSScrub(VHost_ServerIdent)+
        ',VHost_ServerDomain='+            JAS.saDBMSScrub(VHost_ServerDomain)+
        ',VHost_ServerIP='+                JAS.saDBMSScrub(VHost_ServerIP)+
        ',VHost_ServerPort='+              JAS.saDBMSIntScrub(VHost_ServerPort)+
        ',VHost_DefaultLanguage='+         JAS.saDBMSScrub(VHost_DefaultLanguage)+
        ',VHost_DefaultColorTheme='+       JAS.saDBMSScrub(VHost_DefaultColorTheme)+
        ',VHost_MenuRenderMethod='+        JAS.saDBMSScrub(VHost_MenuRenderMethod)+
        ',VHost_DefaultArea='+             JAS.saDBMSScrub(VHost_DefaultArea)+
        ',VHost_DefaultPage='+             JAS.saDBMSScrub(VHost_DefaultPage)+
        ',VHost_DefaultSection='+          JAS.saDBMSScrub(VHost_DefaultSection)+
        ',VHost_DefaultTop_JMenu_ID='+     JAS.saDBMSUIntScrub(VHost_DefaultTop_JMenu_ID)+
        ',VHost_DefaultLoggedInPage='+     JAS.saDBMSScrub(VHost_DefaultLoggedInPage)+
        ',VHost_DefaultLoggedOutPage='+    JAS.saDBMSScrub(VHost_DefaultLoggedOutPage)+
        ',VHost_DataOnRight_b='+           JAS.saDBMSBoolScrub(VHost_DataOnRight_b)+
        ',VHost_CacheMaxAgeInSeconds='+    JAS.saDBMSIntScrub(VHost_CacheMaxAgeInSeconds)+
        ',VHost_SystemEmailFromAddress='+  JAS.saDBMSScrub(VHost_SystemEmailFromAddress)+
        ',VHost_EnableSSL_b='+             JAS.saDBMSBoolScrub(VHost_EnableSSL_b)+
        ',VHost_SharesDefaultDomain_b='+   JAS.saDBMSBoolScrub(VHost_SharesDefaultDomain_b)+
        ',VHost_DefaultIconTheme='+        JAS.saDBMSScrub(VHost_DefaultIconTheme)+
        ',VHost_DirectoryListing_b='+      JAS.saDBMSBoolScrub(VHost_DirectoryListing_b)+
        ',VHost_FileDir='+                 JAS.saDBMSScrub(VHost_FileDir)+
        ',VHost_AccessLog='+               JAS.saDBMSScrub(VHost_AccessLog)+
        ',VHost_ErrorLog='+                JAS.saDBMSScrub(VHost_ErrorLog)+
        ',VHost_JDConnection_ID='+         JAS.saDBMSUIntScrub(VHost_JDConnection_ID)+
        ',VHOST_Enabled_b='+               JAS.saDBMSBoolScrub(VHost_Enabled_b)+
        ',VHost_TemplateDir='+             JAS.saDBMSScrub(VHost_TemplateDir)+
        ',VHost_CacheDir='+                JAS.saDBMSScrub(VHost_CacheDir);
      if bAddNew then
      begin
        saQry+=
          ',VHost_CreatedBy_JUser_ID='+      JAS.saDBMSUIntScrub(VHost_CreatedBy_JUser_ID)+
          ',VHost_Created_DT='+              JAS.saDBMSDateScrub(VHost_Created_DT);
      end;
      saQry+=
        ',VHost_ModifiedBy_JUser_ID='+     JAS.saDBMSUintScrub(VHost_ModifiedBy_JUser_ID)+
        ',VHost_Modified_DT='+             JAS.saDBMSDateScrub(VHost_Modified_DT)+
        ',VHost_DeletedBy_JUser_ID='+      JAS.saDBMSUintScrub(VHost_DeletedBy_JUser_ID)+
        ',VHost_Deleted_DT='+              JAS.saDBMSDateScrub(VHost_Deleted_DT)+
        ',VHost_Deleted_b='+               JAS.saDBMSBoolScrub(VHost_Deleted_b)+
        ',JAS_Row_b='+                     JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE VHost_JVHost_UID='+JAS.saDBMSUIntScrub(VHost_JVHost_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,2015031621119);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201210080258,'Problem updating jvhost.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jvhost', p_rJVHost.VHost_JVHost_UID, '0',201506200459) then
      begin
        JAS_Log(p_Context,cnLog_Error,201210080259,'Problem unlocking jvhost record.','p_rJVHost.VHost_JVHost_UID:'+p_rJVHost.VHost_JVHost_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201210080300,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================






//=============================================================================
function bJAS_Load_jwidget(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJWidget: rtJWidget; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jwidget'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113475,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113476, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jwidget where JWidg_JWidget_UID='+JAS.saDBMSUIntScrub(p_rJWidget.JWidg_JWidget_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jwidget', p_rJWidget.JWidg_JWidget_UID, '0',201506200365);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006101136,'Problem locking jwidget record.','p_rJWidget.JWidg_JWidget_UID:'+p_rJWidget.JWidg_JWidget_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,2015031621120);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152235,'Unable to query jwidget successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201002152235,'Record missing from jwidget.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJWidget do begin
        //JWidg_JWidget_UID:=rs.Fields.Get_saValue('');
        JWidg_Name:=rs.Fields.Get_saValue('JWidg_Name');
        JWidg_Procedure:=rs.Fields.Get_saValue('JWidg_Procedure');
        JWidg_Desc:=rs.Fields.Get_saValue('JWidg_Desc');
        JWidg_CreatedBy_JUser_ID         :=rs.Fields.Get_saValue('JWidg_CreatedBy_JUser_ID');
        JWidg_Created_DT                 :=rs.Fields.Get_saValue('JWidg_Created_DT');
        JWidg_ModifiedBy_JUser_ID        :=rs.Fields.Get_saValue('JWidg_ModifiedBy_JUser_ID');
        JWidg_Modified_DT                :=rs.Fields.Get_saValue('JWidg_Modified_DT');
        JWidg_DeletedBy_JUser_ID         :=rs.Fields.Get_saValue('JWidg_DeletedBy_JUser_ID');
        JWidg_Deleted_DT                 :=rs.Fields.Get_saValue('JWidg_Deleted_DT');
        JWidg_Deleted_b                  :=rs.Fields.Get_saValue('JWidg_Deleted_b');
        JAS_Row_b                        :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113477,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jwidget(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJWidget: rtJWidget; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jwidget'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113478,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113479, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJWidget.JWidg_JWidget_UID)=0 then
  begin
    bAddNew:=true;
    p_rJWidget.JWidg_JWidget_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jwidget');
    bOk:=(u8Val(p_rJWidget.JWidg_JWidget_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152236,'Problem getting an UID for new jwidget record.','saJAS_GetNextUID table: jwidget',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jwidget (JWidg_JWidget_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJWidget.JWidg_JWidget_UID) + ')';
      bOk:=rs.Open(saQry,JAS,2015031621121);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152237,'Problem creating a new jwidget record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJWidget.JWidg_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJWidget.JWidg_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJWidget.JWidg_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJWidget.JWidg_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJWidget.JWidg_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJWidget.JWidg_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jwidget', p_rJWidget.JWidg_JWidget_UID, '0',201506200366);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152238,'Problem locking jwidget record.','p_rJWidget.JWidg_JWidget_UID:'+p_rJWidget.JWidg_JWidget_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJWidget do begin
      saQry:='UPDATE jwidget set '+
        //' JWidg_JWidget_UID='+JAS.saDBMSScrub()+
        'JWidg_Name='+JAS.saDBMSScrub(JWidg_Name)+
        ',JWidg_Procedure='+JAS.saDBMSScrub(JWidg_Procedure)+
        ',JWidg_Desc='+JAS.saDBMSScrub(JWidg_Desc);
        if(bAddNew)then
        begin
          saQry+=',JWidg_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JWidg_CreatedBy_JUser_ID)+
          ',JWidg_Created_DT='+JAS.saDBMSDateScrub(JWidg_Created_DT);
        end;
        saQry+=
        ',JWidg_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JWidg_ModifiedBy_JUser_ID)+
        ',JWidg_Modified_DT='+JAS.saDBMSDateScrub(JWidg_Modified_DT)+
        ',JWidg_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JWidg_DeletedBy_JUser_ID)+
        ',JWidg_Deleted_DT='+JAS.saDBMSDateScrub(JWidg_Deleted_DT)+
        ',JWidg_Deleted_b='+JAS.saDBMSBoolScrub(JWidg_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JWidg_JWidget_UID='+JAS.saDBMSUIntScrub(JWidg_JWidget_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,2015031621122);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201002152239,'Problem updating jwidget.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jwidget', p_rJWidget.JWidg_JWidget_UID, '0',201506200460) then
      begin
        JAS_Log(p_Context,cnLog_Error,201002152240,'Problem unlocking jwidget record.','p_rJWidget.JWidg_JWidget_UID:'+p_rJWidget.JWidg_JWidget_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113480,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================







//=============================================================================
function bJAS_Load_jworkqueue(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJWorkQueue: rtJWorkQueue; p_bGetLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Load_jworkqueue'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113481,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113482, sTHIS_ROUTINE_NAME);{$ENDIF}
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  saQry:='select * from jworkqueue where JWrkQ_JWorkQueue_UID='+JAS.saDBMSUIntScrub(p_rJWorkQueue.JWrkQ_JWorkQueue_UID);
  bOk:=true;
  if p_bGetLock then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jworkqueue', p_rJWorkQueue.JWrkQ_JWorkQueue_UID, '0',201506200367);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201006101137,'Problem locking jworkqueue record.','p_rJWorkQueue.JWrkQ_JWorkQueue_UID:'+p_rJWorkQueue.JWrkQ_JWorkQueue_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,JAS,2015031621123);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201003012310,'Unable to query jworkqueue successfully','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      //JAS_Log(p_Context,cnLog_Warn,201003012311,'Record missing from jworkqueue.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      with p_rJWorkQueue do begin
        //JWrkQ_JWorkQueue_UID           :=rs.Fields.Get_saValue('');
        JWrkQ_JUser_ID            :=rs.Fields.Get_saValue('JWrkQ_JUser_ID');
        JWrkQ_Posted_DT           :=rs.Fields.Get_saValue('JWrkQ_Posted_DT');
        JWrkQ_Started_DT          :=rs.Fields.Get_saValue('JWrkQ_Started_DT');
        JWrkQ_Finished_DT         :=rs.Fields.Get_saValue('JWrkQ_Finished_DT');
        JWrkQ_Delivered_DT        :=rs.Fields.Get_saValue('JWrkQ_Delivered_DT');
        JWrkQ_Job_GUID            :=rs.Fields.Get_saValue('JWrkQ_Job_GUID');
        JWrkQ_Confirmed_b         :=rs.Fields.Get_saValue('JWrkQ_Confirmed_b');
        JWrkQ_Confirmed_DT        :=rs.Fields.Get_saValue('JWrkQ_Confirmed_DT');
        JWrkQ_JobType_ID          :=rs.Fields.Get_saValue('JWrkQ_JobType_ID');
        JWrkQ_JobDesc             :=rs.Fields.Get_saValue('JWrkQ_JobDesc');
        JWrkQ_Src_JUser_ID        :=rs.Fields.Get_saValue('JWrkQ_Src_JUser_ID');
        JWrkQ_Src_JDConnection_ID :=rs.Fields.Get_saValue('JWrkQ_Src_JDConnection_ID');
        JWrkQ_Src_JTable_ID       :=rs.Fields.Get_saValue('JWrkQ_Src_JTable_ID');
        JWrkQ_Src_Row_ID          :=rs.Fields.Get_saValue('JWrkQ_Src_Row_ID');
        JWrkQ_Src_Column_ID       :=rs.Fields.Get_saValue('JWrkQ_Src_Column_ID');
        JWrkQ_Src_Data            :=rs.Fields.Get_saValue('JWrkQ_Src_Data');
        JWrkQ_Src_RemoteIP        :=rs.Fields.Get_saValue('JWrkQ_Src_RemoteIP');
        JWrkQ_Src_RemotePort_u    :=rs.Fields.Get_saValue('JWrkQ_Src_RemotePort_u');
        JWrkQ_Dest_JUser_ID       :=rs.Fields.Get_saValue('JWrkQ_Dest_JUser_ID');
        JWrkQ_Dest_JDConnection_ID:=rs.Fields.Get_saValue('JWrkQ_Dest_JDConnection_ID');
        JWrkQ_Dest_JTable_ID      :=rs.Fields.Get_saValue('JWrkQ_Dest_JTable_ID');
        JWrkQ_Dest_Row_ID         :=rs.Fields.Get_saValue('JWrkQ_Dest_Row_ID');
        JWrkQ_Dest_Column_ID      :=rs.Fields.Get_saValue('JWrkQ_Dest_Column_ID');
        JWrkQ_Dest_Data           :=rs.Fields.Get_saValue('JWrkQ_Dest_Data');
        JWrkQ_Dest_RemoteIP       :=rs.Fields.Get_saValue('JWrkQ_Dest_RemoteIP');
        JWrkQ_Dest_RemotePort_u   :=rs.Fields.Get_saValue('JWrkQ_Dest_RemotePort_u');
        JWrkQ_CreatedBy_JUser_ID  :=rs.Fields.Get_saValue('JWrkQ_CreatedBy_JUser_ID');
        JWrkQ_Created_DT          :=rs.Fields.Get_saValue('JWrkQ_Created_DT');
        JWrkQ_ModifiedBy_JUser_ID :=rs.Fields.Get_saValue('JWrkQ_ModifiedBy_JUser_ID');
        JWrkQ_Modified_DT         :=rs.Fields.Get_saValue('JWrkQ_Modified_DT');
        JWrkQ_DeletedBy_JUser_ID  :=rs.Fields.Get_saValue('JWrkQ_DeletedBy_JUser_ID');
        JWrkQ_Deleted_DT          :=rs.Fields.Get_saValue('JWrkQ_Deleted_DT');
        JWrkQ_Deleted_b           :=rs.Fields.Get_saValue('JWrkQ_Deleted_b');
        JAS_Row_b                 :=rs.Fields.Get_saValue('JAS_Row_b');
      end;//with
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113483,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================


//=============================================================================
function bJAS_Save_jworkqueue(p_Context: TCONTEXT; p_DBC: JADO_CONNECTION; var p_rJWorkQueue: rtJWorkQueue; p_bHaveLock: boolean;p_bKeepLock: boolean): boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  JAS: JADO_CONNECTION;
  DT: TDateTime;
  bAddNew: boolean;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='bJAS_Save_jworkqueue'; {$ENDIF}

{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBIN(201203113484,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
{$IFDEF TRACKTHREAD}p_Context.JThread.TrackThread(201203113485, sTHIS_ROUTINE_NAME);{$ENDIF}
  DT:=now;
  bAddNew:=false;
  JAS:=p_DBC;
  rs:=JADO_RECORDSET.Create;
  bOk:=true;
  if u8Val(p_rJWorkQueue.JWrkQ_JWorkQueue_UID)=0 then
  begin
    bAddNew:=true;
    p_rJWorkQueue.JWrkQ_JWorkQueue_UID:=saJAS_GetNextUID;//(p_Context,'0', 'jworkqueue');
    bOk:=(u8Val(p_rJWorkQueue.JWrkQ_JWorkQueue_UID)>0);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201003012312,'Problem getting an UID for new jworkqueue record.','saJAS_GetNextUID table: jworkqueue',SOURCEFILE);
    end;

    if bOk then
    begin
      saQry:='INSERT INTO jworkqueue (JWrkQ_JWorkQueue_UID) VALUES ('+ JAS.saDBMSUIntScrub(p_rJWorkQueue.JWrkQ_JWorkQueue_UID) + ')';
      bOk:=rs.Open(saQry,JAS,2015031621124);
      if not bOk then
      begin
        JAS_Log(p_Context,cnLog_Error,201003012313,'Problem creating a new jworkqueue record.','Query: '+saQry,SOURCEFILE,JAS,rs);
      end
      else
      begin
        p_bHaveLock:=false; // Force Locking because we created a new record
        p_rJWorkQueue.JWrkQ_CreatedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJWorkQueue.JWrkQ_Created_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
        p_rJWorkQueue.JWrkQ_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
        p_rJWorkQueue.JWrkQ_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
      end;
    end;
  end
  else
  begin
    p_rJWorkQueue.JWrkQ_ModifiedBy_JUser_ID:=p_Context.rJSession.JSess_JUser_ID;
    p_rJWorkQueue.JWrkQ_Modified_DT:=saFormatDateTime(csDATETIMEFORMAT,DT);
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(p_Context,JAS.ID,'jworkqueue', p_rJWorkQueue.JWrkQ_JWorkQueue_UID, '0',201506200368);
    if not bOK then
    begin
      JAS_Log(p_Context,cnLog_Error,201003012314,'Problem locking jworkqueue record.','p_rJWorkQueue.JWrkQ_JWorkQueue_UID:'+p_rJWorkQueue.JWrkQ_JWorkQueue_UID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    with p_rJWorkQueue do begin
      saQry:='UPDATE jworkqueue set '+
        //'  JWrkQ_JWorkQueue_UID='+JAS.saDBMSScrub()+
        'JWrkQ_JUser_ID='+JAS.saDBMSUIntScrub(JWrkQ_JUser_ID)+
        ',JWrkQ_Posted_DT='+JAS.saDBMSDateScrub(JWrkQ_Posted_DT)+
        ',JWrkQ_Started_DT='+JAS.saDBMSDateScrub(JWrkQ_Started_DT)+
        ',JWrkQ_Finished_DT='+JAS.saDBMSDateScrub(JWrkQ_Finished_DT)+
        ',JWrkQ_Delivered_DT='+JAS.saDBMSDateScrub(JWrkQ_Delivered_DT)+
        ',JWrkQ_Job_GUID='+JAS.saDBMSScrub(JWrkQ_Job_GUID)+
        ',JWrkQ_Confirmed_b='+JAS.saDBMSBoolScrub(bVal(JWrkQ_Confirmed_b))+
        ',JWrkQ_Confirmed_DT='+JAS.saDBMSDateScrub(JWrkQ_Confirmed_DT)+
        ',JWrkQ_JobType_ID='+JAS.saDBMSUIntScrub(JWrkQ_JobType_ID)+
        ',JWrkQ_JobDesc='+JAS.saDBMSScrub(JWrkQ_JobDesc)+
        ',JWrkQ_Src_JUser_ID='+JAS.saDBMSUIntScrub(JWrkQ_Src_JUser_ID)+
        ',JWrkQ_Src_JDConnection_ID='+JAS.saDBMSUIntScrub(JWrkQ_Src_JDConnection_ID)+
        ',JWrkQ_Src_JTable_ID='+JAS.saDBMSUIntScrub(JWrkQ_Src_JTable_ID)+
        ',JWrkQ_Src_Row_ID='+JAS.saDBMSUIntScrub(JWrkQ_Src_Row_ID)+
        ',JWrkQ_Src_Column_ID='+JAS.saDBMSUIntScrub(JWrkQ_Src_Column_ID)+
        ',JWrkQ_Src_Data='+JAS.saDBMSScrub(JWrkQ_Src_Data)+
        ',JWrkQ_Src_RemoteIP='+JAS.saDBMSScrub(JWrkQ_Src_RemoteIP)+
        ',JWrkQ_Src_RemotePort_u='+JAS.saDBMSUIntScrub(JWrkQ_Src_RemotePort_u)+
        ',JWrkQ_Dest_JUser_ID='+JAS.saDBMSUIntScrub(JWrkQ_Dest_JUser_ID)+
        ',JWrkQ_Dest_JDConnection_ID='+JAS.saDBMSUIntScrub(JWrkQ_Dest_JDConnection_ID)+
        ',JWrkQ_Dest_JTable_ID='+JAS.saDBMSUIntScrub(JWrkQ_Dest_JTable_ID)+
        ',JWrkQ_Dest_Row_ID='+JAS.saDBMSUIntScrub(JWrkQ_Dest_Row_ID)+
        ',JWrkQ_Dest_Column_ID='+JAS.saDBMSUIntScrub(JWrkQ_Dest_Column_ID)+
        ',JWrkQ_Dest_Data='+JAS.saDBMSScrub(JWrkQ_Dest_Data)+
        ',JWrkQ_Dest_RemoteIP='+JAS.saDBMSScrub(JWrkQ_Dest_RemoteIP)+
        ',JWrkQ_Dest_RemotePort_u='+JAS.saDBMSUIntScrub(JWrkQ_Dest_RemotePort_u);
        if(bAddNew)then
        begin
          saQry+=',JWrkQ_CreatedBy_JUser_ID='+JAS.saDBMSUIntScrub(JWrkQ_CreatedBy_JUser_ID)+
          ',JWrkQ_Created_DT='+JAS.saDBMSDateScrub(JWrkQ_Created_DT);
        end;
        saQry+=
        ',JWrkQ_ModifiedBy_JUser_ID='+JAS.saDBMSUIntScrub(JWrkQ_ModifiedBy_JUser_ID)+
        ',JWrkQ_Modified_DT='+JAS.saDBMSDateScrub(JWrkQ_Modified_DT)+
        ',JWrkQ_DeletedBy_JUser_ID='+JAS.saDBMSUIntScrub(JWrkQ_DeletedBy_JUser_ID)+
        ',JWrkQ_Deleted_DT='+JAS.saDBMSDateScrub(JWrkQ_Deleted_DT)+
        ',JWrkQ_Deleted_b='+JAS.saDBMSBoolScrub(JWrkQ_Deleted_b)+
        ',JAS_Row_b='+JAS.saDBMSBoolScrub(JAS_Row_b)+
        ' WHERE JWrkQ_JWorkQueue_UID='+JAS.saDBMSUIntScrub(p_rJWorkQueue.JWrkQ_JWorkQueue_UID);
    end;//with
    bOk:=rs.Open(saQry, JAS,2015031621125);
    if not bOk then
    begin
      JAS_Log(p_Context,cnLog_Error,201003012315,'Problem updating jworkqueue.','Query: '+saQry,SOURCEFILE,JAS,rs);
    end;
    If rs.i4State=adStateOpen Then rs.Close;
    if not p_bKeepLock then
    begin
      if not bJAS_UnLockRecord(p_Context,JAS.ID,'jworkqueue', p_rJWorkQueue.JWrkQ_JWorkQueue_UID, '0',201506200461) then
      begin
        JAS_Log(p_Context,cnLog_Error,201003012316,'Problem unlocking jworkqueue record.','p_rJWorkQueue.JWrkQ_JWorkQueue_UID:'+p_rJWorkQueue.JWrkQ_JWorkQueue_UID,SOURCEFILE);
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
{$IFDEF DEBUGTHREADBEGINEND}p_Context.JThread.DBOUT(201203113486,sTHIS_ROUTINE_NAME,SOURCEFILE);{$ENDIF}
end;
//=============================================================================
















//=============================================================================
constructor TJASRECORD.Create(p_Context: TCONTEXT);
//=============================================================================
{$IFDEF ROUTINENAMES}var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.Create(p_Context: TCONTEXT);'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  self.Context:=p_Context;
  pvt_InitJasRecordClass;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
procedure TJASRECORD.pvt_InitJasRecordClass;
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.pvt_InitJasRecordClass;'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  clear_JDConnection(rJDConnection);
  clear_jtable(rJTable);
  clear_jcolumn(UID_rJColumn);
  MapXDL:=JFC_XDL.Create;
  Fields:=JADO_FIELDS.Create;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
Destructor TJASRECORD.Destroy;
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.Destroy;'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  MapXDL.Destroy;
  Fields.Destroy;
  inherited;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
function TJASRECORD.bAssignTable(p_JTabl_JTable_UID: ansistring): boolean;
//=============================================================================
var
  bOk: boolean;
  DBC: JADO_CONNECTION;
  rs: JADO_RECORDSET;
  saQry: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.bAssignTable(p_JTabl_JTable_UID: ansistring): boolean;'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  DBC:=self.Context.VHDBC;
  rs:=JADO_RECORDSET.create;

  clear_jtable(rJTable);
  clear_JDConnection(rJDConnection);
  clear_JColumn(UID_rJColumn);
  Fields.DeleteAll;

  rJTable.JTabl_JTable_UID:=p_JTabl_JTable_UID;

  bOk:=bJAS_Load_JTable(self.Context, DBC, rJTable,false);
  if not bOk then
  begin
    JAS_LOG(self.Context, cnLog_Error,201008071747,'TJASRECORD.bAssignTable - Unable to Load MetaData from JTable - p_JTabl_JTable_UID:'+p_JTabl_JTable_UID,'',SOURCEFILE,nil,nil);
  end;

  if bOk then
  begin
    rJDConnection.JDCon_JDConnection_UID:=rJTable.JTabl_JDConnection_ID;
    bOk:=bJAS_Load_JTable(self.Context, DBC, rJTable ,false);
    if not bOk then
    begin
      JAS_LOG(self.Context, cnLog_Error,201008071748,'TJASRECORD.bAssignTable - Unable to Load MetaData from JDConnection - p_JTabl_JTable_UID:'+p_JTabl_JTable_UID,'',SOURCEFILE,nil,nil);
    end;
  end;

  if bOk then
  begin
    if u8Val(rJDConnection.JDCon_JDConnection_UID)=0 then
    begin
      rJDConnection.JDCon_Name:='JAS';// Default to JAS Connection ZERO
    end
    else
    begin
      bOk:=bJAS_Load_JDCOnnection(self.Context, DBC, rJDConnection ,false);
      if not bOk then
      begin
        JAS_LOG(self.Context, cnLog_Error,201008082239,'TJASRECORD.bAssignTable - Unable to Load JDConnection - rJDConnection.JDCon_JDConnection_UID:'+rJDConnection.JDCon_JDConnection_UID,'',SOURCEFILE,nil,nil);
      end;
    end;
  end;

  if bOk then
  begin
    saQry:='select * from jcolumn where JColu_JTable_ID='+rJTable.JTabl_JTable_UID;
    //AS_LOG(self.Context, cnLog_Debug,201008082242,'TJASRECORD.bAssignTable - Loading columns Query.','Query: '+saQry,SOURCEFILE,nil,nil);

    bOk:=rs.Open(saQry, DBC,2015031621126);
    if not bOk then
    begin
      JAS_LOG(self.Context, cnLog_Error,201008071749,'TJASRECORD.bAssignTable - Trouble with Query.','Query: '+saQry,SOURCEFILE);
    end;
  end;

  // this block tries to get data type information by jcolumn table
  // taking special care to snag the primary key Column data
  // and stowing it aside for frequent references to it.

  //AS_LOG(self.Context, cnLog_Debug,201008082242,'TJASRECORD.bAssignTable - RS.EOL:'+saTrueFalsE(rs.eol),'Query: '+saQry,SOURCEFILE,nil,nil);
  if bOk and (rs.eol=false)then
  begin
    repeat
      if bVal(rs.fields.Get_saValue('JColu_JAS_Key_b')) then
      begin
        UID_rJColumn.JColu_JColumn_UID:=rs.fields.Get_saValue('JColu_JColumn_UID');
        bOk:=bJAS_Load_JColumn(self.Context, DBC, UID_rJColumn, false);
        if not bOk then
        begin
          JAS_LOG(self.Context, cnLog_Error,201008071750,'TJASRECORD.bAssignTable - Trouble with bJAS_Load_JColumn loading Primary Key Column info.','Query: '+saQry,SOURCEFILE);
        end;
      end;

      if bOk then
      begin
        if not fields.FoundItem_saName(  rs.fields.Get_saValue('JColu_Name'), true) then
        begin
          Fields.AppendItem;
          Fields.Item_saName:=rs.fields.Get_saValue('JColu_Name');
        end;
        JADO_FIELD(fields.lpitem).u8DefinedSize:=u8Val(rs.fields.Get_saValue('JColu_DefinedSize'));
        JADO_FIELD(fields.lpitem).i4NumericScale:=i4Val(rs.fields.Get_saValue('JColu_NumericScale'));
        JADO_FIELD(fields.lpitem).i4Precision:=i4Val(rs.fields.Get_saValue('JColu_Precision'));
        JADO_FIELD(fields.lpitem).u2JDType:=u2Val(rs.fields.Get_saValue('JColu_JDType_ID'));
        //JADO_FIELD(fields.lpitem).u2DrivID:=u2Val(rJDConnection.JDCon_Driver_ID); Not Needed for this Context. See JADO code for why.
      end;
      //AS_LOG(self.Context, cnLog_Debug,201008082243,'TJASRECORD.bAssignTable - LOOP. OK:'+saTrueFalse(bOk)+' Column:'+rs.fields.Get_saValue('JColu_Name'),'Query: '+saQry,SOURCEFILE,nil,nil);
    until (not bOk) or (not rs.MoveNext);
  end;

  //AS_LOG(self.Context, cnLog_Debug,201008082244,'TJASRECORD.bAssignTable - Fields at end of Routine:'+inttostR(fields.listcount),fields.saHTMLTable,SOURCEFILE,nil,nil);


  rs.close;
  rs.destroy;

  result:=bOk;

{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
procedure TJASRECORD.CopyFieldFrom(p_JADO_FIELD: JADO_FIELD);
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.CopyFieldFrom(p_JADO_FIELD: JADO_FIELD);'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  if p_JADO_FIELD<>nil then
  begin
    if MapXDL.FoundItem_saValue(p_JADO_FIELD.saName,true) then
    begin
      // Is field FOUND in MAPPED but Incoming name empty? (If SO Do NOT bring in field)
      if MapXDL.Item_saName<>'' then
      begin
        if Fields.FoundItem_saName(MapXDL.Item_saName,true) then
        begin
          // Copy Data to this field
          Fields.Item_saValue:=p_JADO_FIELD.saValue;
        end
        else
        begin
          Fields.Appenditem;
          Fields.Item_saName:=MapXDL.Item_saName;// Name As we Want it
          Fields.Item_saValue:=p_JADO_FIELD.saValue;
        end;
      end;
    end
    else
    begin
      // Not Found In MapXDL - Which Means bring it in RAW
      if Fields.FoundItem_saName(p_JADO_FIELD.saName,true) then
      begin
        // Copy Data to this field
        Fields.Item_saValue:=p_JADO_FIELD.saValue;
      end
      else
      begin
        Fields.Appenditem;
        Fields.Item_saName:=p_JADO_FIELD.saName;// Name it as is
        Fields.Item_saValue:=p_JADO_FIELD.saValue;
      end;
    end;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================



//=============================================================================
// We will add fields to our list for incoming
procedure TJASRECORD.CopyFrom(p_RS: JADO_RECORDSET);
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.CopyFrom(p_RS: JADO_RECORDSET);'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  if p_rs.fields.MoveFirst then
  begin
    repeat
      CopyFieldFrom(JADO_FIELD(p_RS.lpItem));
    until not p_rs.fields.movenext;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
procedure TJASRECORD.CopyTo(p_RS: JADO_RECORDSET);
//=============================================================================
{$IFDEF ROUTINENAMES}var  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.CopyTo(p_RS: JADO_RECORDSET);'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // Do not need this right now
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
procedure TJASRECORD.CopyFrom(p_JR: TJASRECORD);
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.CopyFrom(p_JR: TJASRECORD);'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // Do not need this right now
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
procedure TJASRECORD.CopyTo(p_JR: TJASRECORD);
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.CopyTo(p_JR: TJASRECORD);'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  // Do not need this right now
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
function TJASRECORD.bLoad(p_bGetLock: boolean):boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  SRC: JADO_CONNECTION;
  saUID: ansistring;
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.bLoad(p_bGetLock: boolean):boolean;'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  bOk:=true;
  SRC:=self.Context.DBCON(self.rJDConnection.JDCon_Name);
  rs:=JADO_RECORDSET.Create;

  if bOk then
  begin
    bOk:=SRC<>nil;
    if not bOk then
    begin
      JAS_Log(self.Context,cnLog_Error,201008082232,'TJASRECORD.bLoad - SRC Dataconnection is nil. self.rJDConnection.JDCon_Name: '+self.rJDConnection.JDCon_Name,'',SOURCEFILE);
    end;
  end;


  if bOk then
  begin
    bOk:=Fields.FoundItem_saName(UID_rJColumn.JColu_Name,true);
    if not bOK then
    begin
      JAS_Log(self.Context,cnLog_Error,201008071823,'TJASRECORD - UID Column Not In Field List - Unable to Load Record.','',SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    saUID:=Fields.Item_saValue;
    saQry:='select * from '+rJTable.JTabl_Name+
      ' where '+UID_rJColumn.JColu_Name+'='+SRC.saDBMSScrub(saUID);
    if p_bGetLock then
    begin
      bOk:=bJAS_LockRecord(self.Context,SRC.ID,rJTable.JTabl_Name, saUID, '0',201506200369);
      if not bOK then
      begin
        JAS_Log(self.Context,cnLog_Error,201008071823,'Problem locking '+rJTable.JTabl_Name+' record.','UID:'+saUID,SOURCEFILE);
      end;
    end;
  end;

  if bOk then
  begin
    bOk:=rs.Open(saQry,SRC,2015031621127);
    if not bOk then
    begin
      JAS_Log(self.Context,cnLog_Error,201008071824,'Unable to query '+rJTable.JTabl_Name+' successfully','Query: '+saQry,SOURCEFILE,SRC,rs);
    end
  end;

  if bOk then
  begin
    bOk:=(rs.EOL=false);
    if not bOk then
    begin
      JAS_Log(self.Context,cnLog_Warn,201008071825,'Record missing from '+rJTable.JTabl_Name+'.','Query: '+saQry,SOURCEFILE);
    end
    else
    begin
      if rs.fields.MoveFirst then
      begin
        repeat
          if not Fields.FoundItem_saName(JADO_FIELD(rs.fields.lpItem).saName,true) then
          begin
            Fields.AppendItem;
            JADO_FIELD(Fields.lpItem).saName:=JADO_FIELD(rs.fields.lpItem).saName;
          end;
          JADO_FIELD(Fields.lpItem).saValue:=JADO_FIELD(rs.fields.lpItem).saValue;
        until not rs.fields.MoveNext;
      end;
    end;
  end;
  rs.close;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================


//=============================================================================
function TJASRECORD.bSave(p_bHaveLock: boolean;p_bKeepLock: boolean):boolean;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  SRC: JADO_CONNECTION;
  DT: TDateTime;
  saUID: ansistring;

  rCreatedBy_JUser_ID: rtValuePair;
  rCreated_DT:rtValuePair;
  rModifiedBy_JUser_ID: rtValuePair;
  rModified_DT: rtValuePair;

{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.bSave(p_bHaveLock: boolean;p_bKeepLock: boolean):boolean;'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  DT:=now;
  SRC:=self.Context.DBCON(self.rJDConnection.JDCon_Name);
  rs:=JADO_RECORDSET.Create;
  bOk:=true;


  if bOk then
  begin
    bOk:=SRC<>nil;
    if not bOk then
    begin
      JAS_Log(self.Context,cnLog_Error,201008082233,'TJASRECORD.bSave - SRC Dataconnection is nil. self.rJDConnection.JDCon_Name: '+self.rJDConnection.JDCon_Name,'',SOURCEFILE);
    end;
  end;



  if bOk then
  begin
    if not Fields.FoundItem_saName(UID_rJColumn.JColu_Name) then
    begin
      // Must be a new Save because the UID wasn't in the list - so - the uid will be zero - so it's
      // going to be a new record whether or not the developer wanted it so :)
      Fields.AppendItem;
      Fields.Item_saName:=UID_rJColumn.JColu_Name;
    end;
    saUID:=Fields.Item_saValue;
  end;

  if bOk then
  begin
    if u8Val(saUID)=0 then
    begin
      //bAddNew:=true;
      saUID:=saJAS_GetNextUID;//(self.Context,SRC.ID, rJTable.JTabl_Name);
      bOk:=(u8Val(saUID)>0);
      if not bOk then
      begin
        JAS_Log(self.Context,cnLog_Error,201008071826,'Problem getting an UID for new '+rJTable.JTabl_Name+' record.','saJAS_GetNextUID table: '+rJTable.JTabl_Name,SOURCEFILE);
      end;
      if bOk then
      begin
        saQry:='INSERT INTO '+rJTable.JTabl_Name+' ('+UID_rJColumn.JColu_Name+') VALUES ('+ saUID + ')';
        bOk:=rs.Open(saQry,SRC,2015031621128);
        if bOk then
        begin
          p_bHaveLock:=false; // Force Locking because we created a new record
          rCreatedBy_JUser_ID.saName:=rJTable.JTabl_ColumnPrefix+'_CreatedBy_JUser_ID';
          rCreatedBy_JUser_ID.saValue:=self.Context.rJSession.JSess_JUser_ID;
          if not Fields.FoundItem_saName(rCreatedBy_JUser_ID.saName) then
          begin
            Fields.AppendItem;
            Fields.Item_saName:=rCreatedBy_JUser_ID.saName;
          end;
          if (Fields.Item_saValue='NULL') or (Fields.Item_saValue='') then
          begin
            Fields.Item_saValue:=rCreatedBy_JUser_ID.saValue;
          end;

          rCreated_DT.saName:=rJTable.JTabl_ColumnPrefix+'_Created_DT';
          rCreated_DT.saValue:=saFormatDateTime(csDATETIMEFORMAT,DT);
          if not Fields.FoundItem_saName(rCreated_DT.saName) then
          begin
            Fields.AppendItem;
            Fields.Item_saName:=rCreated_DT.saName;
          end;
          if (Fields.Item_saValue='NULL') or (Fields.Item_saValue='') then
          begin
            Fields.Item_saValue:=rCreated_DT.saValue;
          end;

          {
          rModifiedBy_JUser_ID.saName:=rJTable.JTabl_ColumnPrefix+'_ModifiedBy_JUser_ID';
          rModifiedBy_JUser_ID.saValue:=self.Context.rJSession.JSess_JUser_ID;
          if not Fields.FoundItem_saName(rModifiedBy_JUser_ID.saName) then
          begin
            Fields.AppendItem;
            Fields.Item_saName:=rModifiedBy_JUser_ID.saName;
          end;
          if (Fields.Item_saValue='NULL') or (Fields.Item_saValue='') then
          begin
            Fields.Item_saValue:=rModifiedBy_JUser_ID.saValue;
          end;

          rModified_DT.saName:=rJTable.JTabl_ColumnPrefix+'_Modified_DT';
          rModified_DT.saValue:=saFormatDateTime(csDATETIMEFORMAT,DT);
          if not Fields.FoundItem_saName(rModified_DT.saName) then
          begin
            Fields.AppendItem;
            Fields.Item_saName:=rModified_DT.saName;
          end;
          if (Fields.Item_saValue='NULL') or (Fields.Item_saValue='') then
          begin
            Fields.Item_saValue:=rModified_DT.saValue;
          end;
          }
        end
        else
        begin
          JAS_Log(self.Context,cnLog_Error,201008071827,'Problem creating a new '+rJTable.JTabl_Name+'.','Query: '+saQry,SOURCEFILE,SRC,rs);
        end;
      end;
    end
    else
    begin
      rModifiedBy_JUser_ID.saName:=rJTable.JTabl_ColumnPrefix+'_ModifiedBy_JUser_ID';
      rModifiedBy_JUser_ID.saValue:=self.Context.rJSession.JSess_JUser_ID;
      if not Fields.FoundItem_saName(rModifiedBy_JUser_ID.saName) then
      begin
        Fields.AppendItem;
        Fields.Item_saName:=rModifiedBy_JUser_ID.saName;
      end;
      if (Fields.Item_saValue='NULL') or (Fields.Item_saValue='') then
      begin
        Fields.Item_saValue:=rModifiedBy_JUser_ID.saValue;
      end;

      rModified_DT.saName:=rJTable.JTabl_ColumnPrefix+'_Modified_DT';
      rModified_DT.saValue:=saFormatDateTime(csDATETIMEFORMAT,DT);
      if not Fields.FoundItem_saName(rModified_DT.saName) then
      begin
        Fields.AppendItem;
        Fields.Item_saName:=rModified_DT.saName;
      end;
      if (Fields.Item_saValue='NULL') or (Fields.Item_saValue='') then
      begin
        Fields.Item_saValue:=rModified_DT.saValue;
      end;
    end;
  end;

  If rs.i4State=adStateOpen Then rs.Close;

  if bOk and (not p_bHaveLock) then
  begin
    bOk:=bJAS_LockRecord(self.Context,SRC.ID,rJTable.JTabl_Name, saUID, '0',201506200370);
    if not bOK then
    begin
      JAS_Log(self.Context,cnLog_Error,201008071828,'Problem locking '+rJTable.JTabl_Name+' record.','UID:'+saUID,SOURCEFILE);
    end;
  end;

  if bOk then
  begin
    if Fields.FoundItem_saName(UID_rJColumn.JColu_Name,true) then
    begin
      Fields.Item_saValue:=saUID;
    end;

    if Fields.Movefirst then
    begin
      saQry:='UPDATE '+rJTable.JTabl_Name+' SET ';
      repeat
        if Fields.N > 1 then saQry+=', ';
        case JADO_FIELD(Fields.lpItem).u2JDType of
        cnJDType_Unknown  : saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSScrub(JADO_FIELD(Fields.lpItem).saValue);

        cnJDType_i1       ,
        cnJDType_i2       ,
        cnJDType_i4       ,
        cnJDType_i8       ,
        cnJDType_i16      ,
        cnJDType_i32      : begin
          if (iVal(JADO_FIELD(Fields.lpItem).saValue)=0) and bVal(JADO_FIELD(Fields.lpItem).saValue) then
          begin
            saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSBoolScrub(true);// might not be ideal for all DBMS
          end
          else
          begin
            saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSIntScrub(JADO_FIELD(Fields.lpItem).saValue);
          end;
        end;

        cnJDType_u1       ,
        cnJDType_u2       ,
        cnJDType_u4       ,
        cnJDType_u8       ,
        cnJDType_u16      ,
        cnJDType_u32      : begin
          if (iVal(JADO_FIELD(Fields.lpItem).saValue)=0) and bVal(JADO_FIELD(Fields.lpItem).saValue) then
          begin
            saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSBoolScrub(true);// might not be ideal for all DBMS
          end
          else
          begin
            saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSUIntScrub(JADO_FIELD(Fields.lpItem).saValue);
          end;
        end;

        cnJDType_fp       ,
        cnJDType_fd       ,
        cnJDType_cur      : saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSDecScrub(JADO_FIELD(Fields.lpItem).saValue);

        cnJDType_ch       ,
        cnJDType_chu      : saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSScrub(JADO_FIELD(Fields.lpItem).saValue);

        cnJDType_b        : saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSBoolScrub(true);

        cnJDType_dt       : saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSDateScrub(JADO_FIELD(Fields.lpItem).saValue);

        cnJDType_s        ,
        cnJDType_su       ,
        cnJDType_sn       ,
        cnJDType_sun      : saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSScrub(JADO_FIELD(Fields.lpItem).saValue);
        cnJDType_bin      : saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSScrub(JADO_FIELD(Fields.lpItem).saValue);
        else begin
          saQry+=JADO_FIELD(Fields.lpItem).saName+'='+SRC.saDBMSScrub(JADO_FIELD(Fields.lpItem).saValue);
        end;//case
        end;//switch
      until (not Fields.MoveNext);

      //if(bAddNew)then
      //begin
      //  saQry+=', '+rCreatedBy_JUser_ID.saName+'='+SRC.saDBMSUIntScrub(rCreatedBy_JUser_ID.saValue)+
      //  ', '+rCreated_DT.saName+'='+SRC.saDBMSDateScrub(rCreated_DT.saValue);
      //end;
      saQry+=' WHERE '+UID_rJColumn.JColu_Name+'='+SRC.saDBMSUIntScrub(saUID);

      //writeln;
      //writeln(saQry);
      //halt(1);
      //writeln;
      //writeln(Fields.saHTMLTable);
      //writeln;

      //AS_Log(self.Context, cnLog_DEBUG,201008071828, 'DEBUG - TJASRECORD.bSave','Query:'+saQry ,SOURCEFILE);
      bOk:=rs.Open(saQry, SRC,2015031621129);
      if not bOk then
      begin
        JAS_Log(self.Context,cnLog_Error,201008071829,'Problem updating '+rJTable.JTabl_Name+'.','Query: '+saQry,SOURCEFILE,SRC,rs);
      end;
      If rs.i4State=adStateOpen Then rs.Close;
      if not p_bKeepLock then
      begin
        if not bJAS_UnLockRecord(self.Context,SRC.ID,rJTable.JTabl_NAme, saUID, '0',201506200462) then
        begin
          JAS_Log(self.Context,cnLog_Error,201008071830,'Problem unlocking '+rJTable.JTabl_Name+' record.','UID:'+saUID,SOURCEFILE);
        end;
      end;
    end;
  end;
  rs.Destroy;
  result:=bOk;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
end;
//=============================================================================

//=============================================================================
procedure TJASRECORD.Clear;//removes data - by setting field values to NULL
//=============================================================================
{$IFDEF ROUTINENAMES}  var sTHIS_ROUTINE_NAME: String; {$ENDIF}
Begin
{$IFDEF ROUTINENAMES}  sTHIS_ROUTINE_NAME:='TJASRECORD.Clear;'; {$ENDIF}
{$IFDEF TRACKTHREAD}sTHIS_ROUTINE_NAME:=sTHIS_ROUTINE_NAME;{$ENDIF}
{$IFDEF DEBUGLOGBEGINEND}
  DebugIn(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
  if Fields.MoveFirst then
  begin
    repeat
      fields.Item_saValue:='NULL';
    until (not fields.MoveNext);
    fields.MoveFirst;
  end;
{$IFDEF DEBUGLOGBEGINEND}
  DebugOUT(sTHIS_ROUTINE_NAME,SourceFile);
{$ENDIF}
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
