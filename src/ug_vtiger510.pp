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
// JAS Compatible VTiger Functions - primarily for version 5.1.0 but
// there is a lot of cross over from 5.0.4
Unit ug_vtiger510;
//=============================================================================


//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_vtiger510.pp'}
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
,dos
,sysutils
,ug_misc
,ug_common
,ug_jegas
,ug_jfc_dl
,ug_jfc_xdl
,ug_jfc_xxdl
,ug_jfc_tokenizer
,ug_jfc_dir
,ug_jfc_threadmgr
,ug_jfC_matrix
,ug_tsfileio
,ug_jado
,uj_definitions
;
//=============================================================================

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
type TVTIGER510=class(JFC_XDL)
//=============================================================================
  constructor create(
    p_JADOC: JADO_CONNECTION; 
    p_saVTPrefix: Ansistring//< vTigerCRM table Prefix: ex: vtiger_
  );
  destructor destroy; override;
  
  // reference to actual connection to vTigerCRM passed at class instantiation
  // this class doesn't CREATE nor DESTROY this connection - its a reference
  public
  JADOC: JADO_CONNECTION;
  
  // This is the vtigercrm table prefix (with underscore appended internally)
  // passed when the class is instatiated.
  saVTPrefix: ansistring;

  // Returns Entity Table ID for passed modulename
  Function i4VTGetEntityTabID(p_saModuleName: ansistring): longint;
  
  // This function allows you to get at the fields that the i4VTGetEntityTabID
  // function pre-populates when you call it. Load the p_DataXDL with crmid
  // and any fields and values you want to update.
  function bVTUpdateCrmEntity(p_DataXDL: JFC_XDL): boolean;
  
  // This is how vTigerCRM tracks "entities" and whether these "entities"
  // are deleted - this is the core of their recycle bin one might say.
  // they track each entity in one main table - one autonumber counter you
  // might say shared by multiple tables.
  Function i4VTGetNewUniqueEntityID(p_saModuleName: ansistring): longint;

  // vTigerCRM has the notion of user defined "numbers" like you might have
  // for generating invoices with some letter infront followed by a number.
  // Well, vTigerCRM took their Invoice number paradigm and literally used that
  // code so that all entities could have the same kind of numbering paradigm. 
  // So, thats what this is, and thats why it returns a string datatype.
  // if it returns nothing ( '' ) then something failed.
  Function saVTIncrementModuleSeqNumber(p_saModuleName:ansistring): ansistring;

  // This adds a new contact to the vTigerCRM - with basically blank information
  // but the necessary values and records are created to make a contact that appears
  // in vTigerCRM correctly. The idea is we add the records first then the mate to 
  // this call - the update function for this entity, handles getting all the data 
  // in. this allows us to only have to write that code once versus having an
  // insert version and an update version of stowing data into this entity.
  function i4VTAddContact: longint;

  // This function takes an XDL of fields that span the contact entity 
  // and handles updating the fields in their appropriate tables. 
  // 
  // The data is passed as name/value pairs loaded in a JFC_XDL
  //
  // Assumed that at a minimum p_DataXDL has the contact id as 
  // Item_saName:='contactid' with its value in Item_saValue.
  Function bVTUpdateContact(p_DataXDL: JFC_XDL): boolean;

  // this works like the iVTAddContact function except this is for the leads entity
  Function i4VTAddLead:longint;

  // this works like the bUpdateContact function except this is for the leads entity
  Function bVTUpdateLead(p_DataXDL: JFC_XDL): boolean;
           

  // this works like the i4VTAddContact function except this is for the Accounts entity
  Function i4VTAddAccount: longint; 

  // this works like the bUpdateContact function except this is for the Accounts entity
  Function bVTUpdateAccount(p_DataXDL: JFC_XDL): boolean;
  
  // this works similiar to the i4VTAddContact function except its the users table 
  // and because we are not running the same codebase as vTigerCRM we can't generate
  // identical hashes for the passwords SO We COPY the Admin user's current 
  // password and other login specific information to ensure the added user,
  // once updated with a name, can in fact login. Therefore, one might say the
  // users created with this routine are locked with the admin password until the
  // administrator resets their password.
  function i4VTAddUser: longint;
  
  // this works similiar to the i4VTUpdateContact function except its the users table 
  // and because we are not running the same codebase as vTigerCRM we can't generate
  // identical hashes for the passwords SO We COPY the Admin user's current 
  // password and other login specific information when the record is created with 
  // i4AddUser. So use caution when sending data with this particular function as 
  // you could accidently render a user unusuable if you overwrite the important
  // fields that impact the vTigerCRM login Procedure. password is one example, but
  // user_hash is another. Naturally setting the deleted field to a 1 could be 
  // a problem also.
  // Once updated with a user name, the user should be able to login after the 
  // administrator resets their password if care was taken.
  function bVTUpdateUser(p_DataXDL: JFC_XDL): boolean;


  // used to generate vtigercrm user accesskey for the same named field
  // in the vtiger_users table
  function saVTAccessKey(p_i4Len: longint): ansistring;

  // this works like the i4VTAddContact function except this is for the Accounts entity
  Function i4VTAddTroubleTicket: longint; 

  // this works like the bUpdateContact function except this is for the Accounts entity
  Function bVTUpdateTroubleTicket(p_DataXDL: JFC_XDL): boolean;

  // this table has an autonumber column - so just load it with data and shoot.
  Function bVTAddTroubleTicketComment(
    p_saticketid       :ansistring;
    p_sacomments       :ansistring;
    p_saownerid        :ansistring;
    p_saownertype      :ansistring;
    p_sacreatedtime    :ansistring
  ): boolean;

  // this works like the i4VTAddContact function except this is for the Accounts entity
  Function i4VTAddRss: longint; 

  // this works like the bUpdateContact function except this is for the rss entity
  Function bVTUpdateRss(p_DataXDL: JFC_XDL): boolean;

  // this works like the iVTAddContact function except this is for the Potentials entity
  Function i4VTAddPotential:longint;

  // this works like the bUpdateContact function except this is for the Potentials entity
  Function bVTUpdatePotential(p_DataXDL: JFC_XDL): boolean;
  
  // this works like the iVTAddContact function except this is for the activity entity
  // except that you pass ZERO for normal operation where a id is automatically generated
  // but (as is the case with emails) you can call this function with the ID you want to use
  // for your new record. Emails are strange and leave the paradigm vtiger uses elsewhere.
  // email entity made, emaildetails record then activity with same id as email placed in
  // activity table.
  Function i4VTAddActivity(p_i4ActivityID: longint):longint;

  // this works like the bUpdateContact function except this is for the activity entity
  Function bVTUpdateActivity(p_DataXDL: JFC_XDL): boolean;

  // use to associate contact with an activity
  function bVTAddCntActivityRel(p_saContactID, p_saActivityID: ansistring): boolean;

  // use to disassociate contact from a activity
  function bVTDeleteCntActivityRel(p_saContactID, p_saActivityID: ansistring): boolean;

  // use to associate a potential with a contact
  function bVTAddCntPotentialRel(p_saContactID, p_saPotentialID: ansistring): boolean;

  // use to disassociate a potential from a contact
  function bVTDeleteCntPotentialRel(p_saContactID, p_saPotentialID: ansistring): boolean;

  // use to associate a Trouble Ticket/case with a CRM entity
  function bVTAddSETicketRel(p_saCRMID, p_saTicketID: ansistring): boolean;

  // use to disassociate contact from a activity
  function bVTDeleteSETicketRel(p_saCRMID, p_saTicketID: ansistring): boolean;


  // SEActivity rel is used for relating ANY crm entity with a calendar event, 
  // not all of the "ANY" is implemented in 5.1.0 - just lead, account, contact
  // use to associate a (supported) crm entity with an activity
  // Note: Emails are also recorded here where this table acts as a link between 
  // entity and email record 
  function bVTAddSEActivityRel(p_saCRMID, p_saActivityID: ansistring): boolean;

  // SEActivity rel is used for relating ANY crm entity with a calendar event, 
  // not not all of the "ANY" is implemented in 5.1.0 - just lead, account, contact
  // use to disassociate a (supported) crm entity from an activity
  function bVTDeleteSEActivityRel(p_saCRMID, p_saActivityID: ansistring): boolean;

  // this works like the iVTAddContact function except this is for the 
  Function i4VTAddServiceContracts:longint;

  // this works like the bUpdateContact function except this is for the 
  Function bVTUpdateServiceContracts(p_DataXDL: JFC_XDL): boolean;

  // this works like the iVTAddContact function except this is for the 
  Function i4VTAddNotes(p_saModuleName: ansistring):longint;

  // this works like the bUpdateContact function except this is for the 
  Function bVTUpdateNotes(p_DataXDL: JFC_XDL): boolean;

  // this works like the iVTAddContact function except this is for the 
  Function i4VTAddEmail:longint;

  // this works like the bUpdateContact function except this is for the 
  Function bVTUpdateEmail(p_DataXDL: JFC_XDL): boolean;
  

  // SENotesRel is used for relating ANY crm entity with a note record, 
  function bVTAddSENotesRel(p_saCRMID, p_saNotesID: ansistring): boolean;

  // SENotesRel is used for relating ANY crm entity with a note record, 
  function bVTDeleteSENotesRel(p_saCRMID, p_saNotesID: ansistring): boolean;

end;
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
constructor TVTIGER510.create(
    p_JADOC: JADO_CONNECTION; 
    p_saVTPrefix: Ansistring// vTigerCRM table Prefix: ex: vtiger_
);
//=============================================================================
begin
  self.JADOC:=p_JADOC;
  self.saVTPrefix:=p_saVTPrefix;
  if saRightStr(self.saVTPrefix,1)<>'_' then self.saVTPrefix:=self.saVTPrefix+'_';
end;
//=============================================================================

//=============================================================================
destructor TVTIGER510.destroy;
//=============================================================================
begin
end;
//=============================================================================


//=============================================================================
function TVTIGER510.saVTAccessKey(p_i4Len: longint): ansistring;
//=============================================================================
var 
  saSource: ansistring;
  i4: longint;
begin
  result:='';
  saSource:='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  for i4:=1 to p_i4Len do
  begin
    result+=saSource[random(length(saSource))+1];
  end;
end;
//=============================================================================


//=============================================================================
Function TVTIGER510.i4VTGetEntityTabID(p_saModuleName: ansistring): longint;
//=============================================================================
var 
  saQry: Ansistring;
  bOk: boolean;
  rs: JADO_RECORDSET;
begin
  result:=0;
  rs:=JADO_RECORDSET.Create;
  // gets tabid for "module" (entity) from entityname table
  saQry:= 'select tabid from ' + saVTPrefix + 'entityname where modulename=' +
    JADOC.saDBMSScrub(p_saModuleName);
          
  bOk:=rs.Open(saQry, JADOC);
  if not bOk then
  begin
    JLog(cnLog_Error,201003141907,'TVTIGER510.i4VTGetEntityTabID - saQry:'+saQry,SourceFile);
  end;
  
  if bOk then 
  begin 
    bOk:=(rs.eol=false);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141908,'TVTIGER510.i4VTGetEntityTabID - No Rows Returned:'+saQry,SourceFile);
    end;
  end;
  
  if bOk then
  begin
    result:=iVal(rs.Fields.Get_saValue('tabid'));
  end;  
  rs.close;  
  rs.destroy;    
end;
//=============================================================================

  
//=============================================================================
Function TVTIGER510.i4VTGetNewUniqueEntityID(p_saModuleName: ansistring): longint;
//=============================================================================
var
 i4TabID: longint;
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saSeq: ansistring;
begin
  bOk:=true;
  result:=0;
  rs:=JADO_RECORDSET.Create;
  // use this is make the initial crmentity record and get a unique id number for say the "Accounts" module
  i4TabID:= i4VTGetEntityTabID(p_saModuleName);
  bOk:=(i4TabID>0);
  
  if bOk then
  begin
    saSeq:=JADOC.saGetNextID(saVTPrefix+'crmentity');
    bOk:=iVal(saSeq)>0;
    if not bOk then
    begin
      JLog(cnLog_Error,201003141909,'TVTIGER510.i4VTGetNewUniqueEntityID - saGetNextID call returned invalid result saSeq:'+saSeq,SourceFile);
    end;
  end;
  
  if bOk then
  begin
    saQry:='';
    saQry += 'insert into ' + saVTPrefix + 'crmentity (';
    saQry += 'crmid, smcreatorid, smownerid, modifiedby, setype, description, createdtime, modifiedtime, viewedtime, status, version, presence, deleted';
    saQry += ') values (';
    saQry += saSeq + ','; // crmid
    saQry += '1 , ';// smcreatorid
    saQry += '1 ,'; // smownerid
    saQry += '0 ,'; // modifiedby
    saQry += JADOC.saDBMSScrub(p_saModuleName)+ ','; // setype
    saQry += ''''','; // description
    saQry += 'now(),'; // createdtime
    saQry += 'now(),'; // modifiedtime
    saQry += 'null,'; // viewedtime
    saQry += 'null,'; // status
    saQry += '0 ,'; // version
    saQry += '1 ,'; // presence
    saQry += '0 '; // deleted
    saQry += ')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141913,'TVTIGER510.i4VTGetNewUniqueEntityID - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  if bOk then result:=iVal(saSeq);  
  rs.destroy;
end;
//=============================================================================


//=============================================================================
// Assumed that at a minimum p_DataXDL has crmid loaded.
Function TVTIGER510.bVTUpdateCrmEntity(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  result:=false;
  rs:=JADO_RECORDSET.Create;
  
  saQry:='';
  saQry+='update '+saVTPrefix+'crmentity SET ';
  saQry+=' crmid=' + p_DataXDL.Get_saValue('crmid'); // this just makes comma work right
  saField:='smcreatorid';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='smownerid';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='modifiedby';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='setype';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='description';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='createdtime';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='modifiedtime';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='viewedtime';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='status';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if((p_DataXDL.Item_saValue='NULL')or(p_DataXDL.Item_saValue='')) then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='version';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='presence';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='deleted';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;  
  saField:=grJASConfig.saServerID+'_id';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;  
  saQry += ' WHERE crmid=' + p_DataXDL.Get_saValue('crmid');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then
  begin
    JLog(cnLog_Error,201003142340,'TVTIGER510.bVTUpdateCrmEntity - saQry:'+saQry,SourceFile);
  end;
  rs.close;

  result:=bOk;
  rs.Destroy;
  
end;
//=============================================================================







//=============================================================================
Function TVTIGER510.saVTIncrementModuleSeqNumber(p_saModuleName:ansistring): ansistring;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  result:='';
  rs:=JADO_RECORDSET.Create;
  saQry:='LOCK TABLES ' + saVTPrefix + 'modentity_num WRITE';
  bOk:=rs.open(saQry,JADOC);
  if not bOk then
  begin
    JLog(cnLog_Error,201003141914,'TVTIGER510.saVTIncrementModuleSeqNumber - saQry:'+saQry,SourceFile);
  end;
  rs.close;
  
  if bOk then
  begin
    saQry:='select prefix, cur_id from '+saVTPrefix+'modentity_num where active=1 and semodule='+
      JADOC.saDBMSSCrub(p_saModuleName);
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141915,'TVTIGER510.saVTIncrementModuleSeqNumber - saQry:'+saQry,SourceFile);
    end;
  end;
  
  if bOk then
  begin
    bOk:=(rs.eol=false);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141916,'TVTIGER510.saVTIncrementModuleSeqNumber - No Records Returned - saQry:'+saQry,SourceFile);
    end;
  end;
  
  if bOk then
  begin
    result:=rs.Fields.Get_saValue('prefix')+rs.Fields.Get_saValue('cur_id');
    rs.close;
    saQry:='update ' + saVTPrefix + 'modentity_num ' +
      'SET cur_id = cur_id+1 where active=1 and semodule=' + JADOC.saDBMSScrub(p_saModuleName);
    bOk:=rs.Open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141917,'TVTIGER510.saVTIncrementModuleSeqNumber - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  
  if bOk then
  begin
    saQry:='UNLOCK TABLES';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141918,'TVTIGER510.saVTIncrementModuleSeqNumber - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  rs.destroy;
end;
//=============================================================================

//=============================================================================
Function TVTIGER510.i4VTAddContact: longint;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 i4ContactID: longint;
 saContactNo: ansistring;
 saModuleName: ansistring;
begin
  rs:=JADO_RECORDSET.Create;
  saModuleName:='Contacts';
  result:=0;
  
  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
  i4ContactID:=i4VTGetNewUniqueEntityID(saModuleName);  
  bOk:=(i4ContactID>0);
  if not bOk then
  begin
    JLog(cnLog_Error,201003141919,'TVTIGER510.i4VTAddContact - i4ContactID=ZERO',SourceFile);
  end;
  
  if bOk then
  begin
    saContactNo:=saVTIncrementModuleSeqNumber(saModuleName);
    bOk:=length(saContactNO)>0;
    if not bOk then
    begin JLog(cnLog_Error,201003141920,'TVTIGER510.i4VTAddContact - saContactNo length is ZERO',SourceFile);
    end;
  end;
  
  if bOk then
  begin
    // Add Contact Record;
    // insert into contact (i think) requires (or it won't show);
    //    insert into _contactaddress;
    //    insert into _contactsubdetails;
    //    insert into _contactscf;
    saQry:='insert into ' + saVTPrefix + 'contactdetails (contactid, contact_no) values (' + inttostr(i4contactid) + ',' +
      JADOC.saDBMSScrub(saContactNo)+')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin JLog(cnLog_Error,201003141921,'TVTIGER510.i4VTAddContact - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  
  if bOk then
  begin
    saQry:='insert into '+saVTPrefix+'contactaddress (contactaddressid) values (' + inttostr(i4contactid) + ')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin JLog(cnLog_Error,201003141922,'TVTIGER510.i4VTAddContact - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
      
  if bOk then
  begin
    saQry:='insert into '+saVTPrefix+'contactsubdetails (contactsubscriptionid) values (' + inttostr(i4contactid) + ')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin JLog(cnLog_Error,201003141923,'TVTIGER510.i4VTAddContact - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;        
    
  if bOk then
  begin
    saQry:='insert into '+saVTPrefix+'contactscf (contactid) values (' + inttostr(i4contactid) + ')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin JLog(cnLog_Error,201003141924,'TVTIGER510.i4VTAddContact - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;        
  
  if bOk then
  begin
    result:=i4ContactID;  
  end;
  rs.Destroy;
end;
//=============================================================================


//=============================================================================
// Assumed that at a minimum $p_Data has the contact id as $p_Data['contactid']
Function TVTIGER510.bVTUpdateContact(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  result:=false;
  rs:=JADO_RECORDSET.Create;
  
  // Assumed that at a minimum $p_Data has the contact id as $p_Data['contactid']
  
  //----------- Ok - now for the contactdetails table
  saQry:='';
  saQry+='update '+saVTPrefix+'contactdetails SET ';
  saQry+=' contactid=' + p_DataXDL.Get_saValue('contactid'); // this just makes comma work right
  saField:='accountid';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='salutation';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='firstname';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='lastname';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='email';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='phone';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='mobile';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='title';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='department';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='fax';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='reportsto';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='training';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='usertype';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='contacttype';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='otheremail';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='yahooid';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='donotcall';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='emailoptout';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='imagename';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='reference';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='notify_owner';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='jegas_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=grJASConfig.saServerID+'_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saQry += ' WHERE contactid=' + p_DataXDL.Get_saValue('contactid');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then
  begin JLog(cnLog_Error,201003141925,'TVTIGER510.bVTUpdateContact - saQry:'+saQry,SourceFile);
  end;
  rs.close;
    
  if bOk then
  begin
    saQry:= '';
    saQry += 'update ' + saVTPrefix + 'contactaddress SET ';
    saQry += ' contactaddressid=' + p_DataXDL.Get_saValue('contactid'); // this just makes comma work right
    saField:='mailingcity';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='mailingstreet';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='mailingcountry';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='othercountry';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='mailingstate';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='mailingpobox';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='othercity';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='otherstate';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='mailingzip';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='otherzip';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='otherstreet';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='otherpobox';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saQry += ' WHERE contactaddressid=' + p_DataXDL.Get_saValue('contactid');
    bOk:=rs.open(saQry,JADOC);
    if not bok then 
    begin
      JLog(cnLog_Error,201003141926,'TVTIGER510.bVTUpdateContact - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;

  if bOk then 
  begin
    saQry:='';
    saQry += 'update ' + saVTPrefix+'contactsubdetails SET ';
    saQry += ' contactsubscriptionid='+p_DataXDL.Get_saValue('contactid'); // this just makes comma work right
    saField:='homephone';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='otherphone';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='assistant';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='assistantphone';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='birthday';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='laststayintouchrequest';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='laststayintouchsavedate';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='leadsource';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saQry += ' WHERE contactsubscriptionid=' + p_DataXDL.Get_saValue('contactid');
    bOk:=rs.open(saQry,JADOC);
    if not bok then 
    begin
      JLog(cnLog_Error,201003141927,'TVTIGER510.bVTUpdateContact - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
        
  result:=bOk;
  rs.Destroy;
  
end;
//=============================================================================


//=============================================================================
Function TVTIGER510.i4VTAddLead:longint;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 i4LeadID: longint;
 saLeadNo: ansistring;
 saModuleName: ansistring;

begin
  result:=0;
  bOk:=true;
  rs:=JADO_RECORDSET.create;
  
  saModuleName:='Leads';
  i4LeadID:=i4VTGetNewUniqueEntityID(saModuleName);  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
  bOk:=(i4LeadID>0);
  if not bOk then
  begin
    JLog(cnLog_Error,201003141928,'TVTIGER510.i4VTAddLead - i4LeadID=ZERO',SourceFile);
  end;
  
  if bOk then
  begin
    saLeadNo:=saVTIncrementModuleSeqNumber(saModuleName);
    bOk:=length(saLeadNo)>0;
    if not bOk then
    begin JLog(cnLog_Error,201003141929,'TVTIGER510.i4VTAddLead - saLeadNo length=ZERO',SourceFile);
    end;
  end;
    
  if bOk then
  begin  
    // Add lead Record;
    // insert into lead (i think) requires (or it won't show);
    //    insert into _leadaddress;
    //    insert into _leadsubdetails;
    //    insert into _leadscf;
    saQry:='insert into ' + saVTPrefix+ 'leaddetails (leadid, lead_no) values (' + inttostr(i4LeadID)+ ','+JADOC.saDBMSScrub(saLeadNo)+')';
    bOk:=rs.open(saQry, JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141930,'TVTIGER510.i4VTAddLead - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  
  if bOk then
  begin
    saQry:='insert into ' + saVTPrefix + 'leadsubdetails (leadsubscriptionid) values (' + inttostr(i4LeadID)+ ')';
    bOk:=rs.open(saQry, JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141931,'TVTIGER510.i4VTAddLead - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
    
  if bOk then
  begin
    saQry:='insert into '+saVTPrefix+'leadaddress (leadaddressid) values (' + inttostr(i4LeadID)+ ')';
    bOk:=rs.open(saQry, JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141932,'TVTIGER510.i4VTAddLead - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
    
  if bOk then
  begin
    saQry:='insert into ' +saVTPrefix+'leadscf (leadid) values (' + inttostr(i4LeadID)+ ')';
    bOk:=rs.open(saQry, JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141933,'TVTIGER510.i4VTAddLead - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  if bOk then
  begin
    result:=i4LeadID;
  end;  
  
  rs.destroy;
end;
//=============================================================================



//=============================================================================
Function TVTIGER510.bVTUpdateLead(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  rs:=JADO_RECORDSET.Create;

  // Assumed that at a minimum $p_Data has the lead id as $p_Data['leadid']
  // Note Leads has a unique address table and requires a second update if 
  // you want to enter a non-billing address. Be sure to set the 'leadaddresstype'
  // correctly.
  
  //----------- Ok - now for the leaddetails table
  saQry:='';
  saQry += 'update ' +saVTPrefix+ 'leaddetails SET ';
  saQry += ' leadid='+p_DataXDL.Get_saValue('leadid'); // this just makes comma work right
  saField:='email';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='interest';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='firstname';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='salutation';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='lastname';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='company';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='annualrevenue';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='industry';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='campaign';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='rating';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='leadstatus';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='leadsource';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='converted';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='designation';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='licencekeystatus';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='space';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='comments';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='priority';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='demorequest';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='partnercontact';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='productversion';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='product';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='maildate';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='nextstepdate';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='fundingsituation';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='purpose';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='evaluationstatus';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='transferdate';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='revenuetype';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='noofemployees';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='yahooid';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='assignleadchk';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saQry += ' WHERE leadid=' + p_DataXDL.Get_saValue('leadid');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then 
  begin
    JLog(cnLog_Error,201003141934,'TVTIGER510.bVTUpdateLead - saQry:'+saQry,SourceFile);
  end;
  rs.close;
  
  if bOk then
  begin
    saQry:='';
    saQry += 'update ' +saVTPrefix+ 'leadaddress SET ';
    saQry += ' leadaddressid='  + p_DataXDL.Get_saValue('leadid'); // this just makes comma work right
    saField:='city';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='code';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='state';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='pobox';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='country';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='phone';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='mobile';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='fax';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='lane';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='leadaddresstype';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saQry += ' WHERE leadaddressid=' + p_DataXDL.Get_saValue('leadid');
    bOk:=rs.open(saQry,JADOC);
    if not bOk then 
    begin
      JLog(cnLog_Error,201003141935,'TVTIGER510.bVTUpdateLead - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;    

  if bOk then
  begin
    saQry:='';
    saQry += 'update ' +saVTPrefix+ 'leadsubdetails SET ';
    saQry += ' leadsubscriptionid='  + p_DataXDL.Get_saValue('leadid'); // this just makes comma work right
    saField:='website';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='callornot';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='readornot';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='empct';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saQry += ' WHERE leadsubscriptionid='  + p_DataXDL.Get_saValue('leadid');
    bOk:=rs.open(saQry,JADOC);
    if not bOk then 
    begin
      JLog(cnLog_Error,201003141936,'TVTIGER510.bVTUpdateLead - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;    
  
  result:=bOk;
  rs.destroy;
end;
//=============================================================================




//=============================================================================
Function TVTIGER510.i4VTAddAccount: longint; 
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 i4AccountID: longint;
 saAccountNo: ansistring;
 saModuleName: ansistring;
begin
  result:=0;
  rs:=JADO_RECORDSET.create;
  saModuleName:='Accounts';
  i4AccountID:=i4VTGetNewUniqueEntityID(saModuleName);  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
  bOk:=(i4AccountID>0);
  if not bOk then
  begin
    JLog(cnLog_Error,201003141937,'TVTIGER510.i4VTAddAccount - i4AccountID=ZERO',SourceFile);
  end;
  
  if bOk then
  begin
    saAccountNo:=saVTIncrementModuleSeqNumber(saModuleName);
    bOk:=length(saAccountNo)>0;
    if not bOk then
    begin
      JLog(cnLog_Error,201003141938,'TVTIGER510.i4VTAddAccount - saAccountNo length = ZERO',SourceFile);
    end;
  end;
  
  if bOk then
  begin
    saQry:='insert into ' +saVTPrefix+ 'account (accountid, account_no) values (' + inttostr(i4AccountID) + ',' + JADOC.saDbMSScrub(saAccountNo) +')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141939,'TVTIGER510.i4VTAddAccount - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
    
  if bOk then
  begin  
    saQry:='insert into ' +saVTPrefix+ 'accountbillads (accountaddressid) values (' + inttostr(i4AccountID) + ')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141940,'TVTIGER510.i4VTAddAccount - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  
  if bOk then
  begin  
    saQry:='insert into ' +saVTPrefix+ 'accountshipads (accountaddressid) values (' + inttostr(i4AccountID) + ')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141941,'TVTIGER510.i4VTAddAccount - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
    
  if bOk then
  begin  
    saQry:='insert into ' +saVTPrefix+ 'accountscf (accountid) values (' + inttostr(i4AccountID) + ')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141942,'TVTIGER510.i4VTAddAccount - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;

  if bOk then
  begin
    result:=i4AccountID;
  end;
  rs.destroy;
end;
//=============================================================================



//=============================================================================
Function TVTIGER510.bVTUpdateAccount(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  rs:=JADO_RECORDSET.Create;
  
  // Assumed that at a minimum $p_Data has the account id as $p_Data['accountid']
  // Note Account entity has TWO unique address tables
  //----------- Ok - now for the account table
  saQry:='';
  saQry += 'update ' +saVTPrefix+ 'account SET ';
  saQry += ' accountid=' + p_DataXDL.Get_saValue('accountid'); // this just makes comma work right
  saField:='accountname';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='parentid';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='account_type';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='industry';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='annualrevenue';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='rating';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='ownership';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='siccode';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='tickersymbol';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='phone';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='otherphone';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='email1';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='email2';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='website';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='fax';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='employees';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='emailoptout';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='notify_owner';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='jegas_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=grJASConfig.saServerID+'_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saQry += ' WHERE accountid=' + p_DataXDL.Get_saValue('accountid');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then
  begin
    JLog(cnLog_Error,201003141943,'bVTUpdateAccount - saQry:'+saQry,SourceFile);
  end;
  rs.close;  
  
  if bOk then
  begin
    saQry:='';
    saQry += 'update ' +saVTPrefix+ 'accountbillads SET ';
    saQry += ' accountaddressid=' + p_DataXDL.Get_saValue('accountid'); // this just makes comma work right
    saField:='bill_city';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='bill_code';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='bill_country';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='bill_state';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='bill_street';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='bill_pobox';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saQry += ' WHERE accountaddressid=' +p_DataXDL.Get_saValue('accountid');
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141944,'bVTUpdateAccount - saQry:'+saQry,SourceFile);
    end;
    rs.close;  
  end;
  
  if bOk then
  begin
    saQry:='';
    saQry += 'update ' +saVTPrefix+ 'accountshipads SET ';
    saQry += ' accountaddressid=' +p_DataXDL.Get_saValue('accountid'); // this just makes comma work right
    saField:='ship_city';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='ship_code';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='ship_country';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='ship_state';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='ship_pobox';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saField:='ship_street';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
    saQry += ' WHERE accountaddressid=' + p_DataXDL.Get_saValue('accountid');
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141945,'bVTUpdateAccount - saQry:'+saQry,SourceFile);
    end;
    rs.close;  
  end;
  
  result:=bOk;
  rs.destroy;
end;
//=============================================================================


//=============================================================================
function TVTIGER510.i4VTAddUser: longint;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  i4ID: longint;
  saField: ansistring;
begin
  result:=0;
  rs:=JADO_RECORDSET.Create;
  
  i4ID:=iVal(JADOC.saGetNextID(saVTPrefix + 'users'));
  bOk:=(i4ID>0);
  if not bOk then
  begin
    JLog(cnLog_Error,201003141946,'TVTIGER510.i4VTAddUser - bad saGetNextID result:'+inttostr(i4ID),SourceFile);
  end;  
  
  // Now we need to Borrow some Information from the Admin Record 1 Which we do in fact
  // ASSUME is there.
  if bOk then
  begin
    saQry:='select * from ' + saVTPrefix + 'users where id=1';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141951,'TVTIGER510.i4VTAddUser - saQry:'+saQry,SourceFile);
    end;
  end;

  if bOk then
  begin
    saQry:='insert into ' + saVTPrefix + 'users (';
    saQry+='id,user_name,user_password,user_hash,date_format,hour_format,start_hour,end_hour,confirm_password,crypt_type,cal_color,currency_id,';
    saQry+='tz,holidays,namedays,workdays,weekstart,activity_view,lead_view,reminder_interval,';
    saQry+='accesskey';
    saQry+=')VALUES(';
    saQry+=inttostr(i4ID) +',';//id
    saQry+='''temp'',';//user_name
    saField:='user_password';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='user_hash';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='date_format';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='hour_format';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='start_hour';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='end_hour';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='confirm_password';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='crypt_type';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='cal_color';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='currency_id';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='tz';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='holidays';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='namedays';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='workdays';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='weekstart';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='activity_view';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='lead_view';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saField:='reminder_interval';if rs.Fields.Get_saValue(saField)='NULL' then begin saQry+='null' end else begin saQry+=JADOC.saDBMSScrub(rs.Fields.Get_saValue(saField)); end; saQry+=',';
    saQry+=JADOC.saDBMSScrub(saVTAccessKey(16));//access_key
    saQry+=')';
    rs.close;
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003141952,'TVTIGER510.i4VTAddUser - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  
  if bOk then
  begin
    saQry:='insert into ' + saVTPrefix+'user2role (userid,roleid) values(';
    saQry+=inttostr(i4ID) +',''H1'')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003142202,'TVTIGER510.i4VTAddUser - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  

  if bOk then result:=i4ID;
  rs.destroy;
end;
//=============================================================================
  
//=============================================================================
function TVTIGER510.bVTUpdateUser(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  rs:=JADO_RECORDSET.Create;

  saQry:='';
  saQry += 'update ' +saVTPrefix+ 'users SET ';
  saQry += ' id=' + p_DataXDL.Get_saValue('id'); // this just makes comma work right
  
  saField:=trim('id                ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('user_name         ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('user_password     ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('user_hash         ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('cal_color         ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('first_name        ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('last_name         ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('reports_to_id     ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('is_admin          ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('currency_id       ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('description       ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('date_entered      ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('date_modified     ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('modified_user_id  ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('title             ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('department        ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('phone_home        ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('phone_mobile      ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('phone_work        ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('phone_other       ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('phone_fax         ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('email1            ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('email2            ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('yahoo_id          ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('status            ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('signature         ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('address_street    ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('address_city      ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('address_state     ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('address_country   ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('address_postalcode');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('user_preferences  ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('tz                ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('holidays          ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('namedays          ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('workdays          ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('weekstart         ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('date_format       ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('hour_format       ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('start_hour        ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('end_hour          ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('activity_view     ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('lead_view         ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('imagename         ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('deleted           ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('confirm_password  ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('internal_mailer   ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('reminder_interval ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('reminder_next_time');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('crypt_type        ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('accesskey         ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim('jegas_id          ');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=trim(grJASConfig.saServerID+'_id');if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saQry += ' WHERE id=' + p_DataXDL.Get_saValue('id');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then
  begin
    JLog(cnLog_Error,201003141952,'TVTIGER510.bVTUpdateUser - saQry:'+saQry,SourceFile);
  end;
  //Log(cnLog_Debug,201003141952,'TVTIGER510.bVTUpdateUser - saQry:'+saQry,SourceFile);
  //Log(cnLog_Debug,201003141952,'p_DataXDL.saHTMLTable:'+p_DataXDL.saHTMLTable,SourceFile);
  rs.close;  
  rs.destroy;
  result:=bOk;
end;
//=============================================================================







//=============================================================================
Function TVTIGER510.i4VTAddTroubleTicket: longint;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 i4TicketID: longint;
 saTicketNo: ansistring;
 saModuleName: ansistring;
begin
  rs:=JADO_RECORDSET.Create;
  saModuleName:='HelpDesk';
  result:=0;
  
  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
  i4ticketID:=i4VTGetNewUniqueEntityID(saModuleName);  
  bOk:=(i4TicketID>0);
  if not bOk then
  begin
    JLog(cnLog_Error,201003150528,'TVTIGER510.i4VTAddTroubleTicket - i4TicketID=ZERO',SourceFile);
  end;
  
  if bOk then
  begin
    saTicketNo:=saVTIncrementModuleSeqNumber(saModuleName);
    bOk:=length(saTicketNO)>0;
    if not bOk then
    begin
      JLog(cnLog_Error,201003150529,'TVTIGER510.i4VTAddTroubleTicket - saTicketNo length is ZERO',SourceFile);
    end;
  end;
  
  if bOk then
  begin
    // Add Contact Record;
    // insert into contact (i think) requires (or it won't show);
    //    insert into _contactaddress;
    //    insert into _contactsubdetails;
    //    insert into _contactscf;
    saQry:='insert into ' + saVTPrefix + 'troubletickets (ticketid, ticket_no) values (' + inttostr(i4ticketid) + ',' +
      JADOC.saDBMSScrub(saTicketNo)+')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003150530,'TVTIGER510.i4VTAddTroubleTicket - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  
  if bOk then
  begin
    saQry:='insert into '+saVTPrefix+'ticketcf (ticketid) values (' + inttostr(i4ticketid) + ')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003150531,'TVTIGER510.i4VTAddTroubleTicket - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;        
  
  if bOk then
  begin
    result:=i4TicketID;  
  end;
  rs.Destroy;
end;
//=============================================================================


//=============================================================================
// Assumed that at a minimum $p_Data has the contact id as $p_Data['contactid']
Function TVTIGER510.bVTUpdateTroubleTicket(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  result:=false;
  rs:=JADO_RECORDSET.Create;
  
  // Assumed that at a minimum $p_Data has the contact id as $p_Data['contactid']
  
  //----------- Ok - now for the contactdetails table
  saQry:='';
  saQry+='update '+saVTPrefix+'troubletickets SET ';
  saQry+=' ticketid=' + p_DataXDL.Get_saValue('ticketid'); // this just makes comma work right
  saField:='ticket_no';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='groupname';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='parent_id';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='product_id';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='priority';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='severity';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='status';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='category';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='title';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='solution';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='update_log';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='version_id';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='hours';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='days';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='jegas_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=grJASConfig.saServerID+'_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saQry += ' WHERE ticketid=' + p_DataXDL.Get_saValue('ticketid');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then
  begin
    JLog(cnLog_Error,201003141925,'TVTIGER510.bVTUpdateTroubleTicket - saQry:'+saQry,SourceFile);
  end;
  rs.close;
    
  result:=bOk;
  rs.Destroy;
  
end;
//=============================================================================



//=============================================================================
Function TVTIGER510.bVTAddTroubleTicketComment(
  p_saticketid       :ansistring;
  p_sacomments       :ansistring;
  p_saownerid        :ansistring;
  p_saownertype      :ansistring;
  p_sacreatedtime    :ansistring
): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  rs:=JADO_RECORDSET.Create;
  saQry:='insert into ' + saVTPrefix + 'ticketcomments (';
  saQry+='ticketid,comments,ownerid,ownertype,createdtime';
  saQry+=')values(';
  saQry+=JADOC.saDBMSScrub(p_saticketid)+',';
  saQry+=JADOC.saDBMSScrub(p_sacomments)+',';
  saQry+=JADOC.saDBMSScrub(p_saownerid)+',';
  saQry+=JADOC.saDBMSScrub(p_saownertype)+',';
  saQry+=JADOC.saDBMSScrub(p_sacreatedtime);
  saQry+=')';
  bOk:=rs.open(saQry,JADOC);
  if not bOk then
  begin
    JLog(cnLog_Error,201003150530,'TVTIGER510.i4VTAddTroubleTicket - saQry:'+saQry,SourceFile);
  end;
  rs.close;
  result:=bOk;  
  rs.Destroy;
end;
//=============================================================================







//=============================================================================
function TVTIGER510.i4VTAddRSS: longint;
//=============================================================================
var
  rs: JADO_RECORDSET;
  saQry: ansistring;
  bOk: boolean;
  i4ID: longint;
begin
  result:=0;
  rs:=JADO_RECORDSET.Create;
  
  i4ID:=iVal(JADOC.saGetNextID(saVTPrefix + 'rss'));
  bOk:=(i4ID>0);
  if not bOk then
  begin JLog(cnLog_Error,201003150746,'TVTIGER510.i4VTAddRSS - bad saGetNextID result:'+inttostr(i4ID),SourceFile);
  end;  
  
  if bOk then
  begin
    saQry:='insert into ' + saVTPrefix + 'rss (rssid) VALUES ('+inttostr(i4ID)+')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003150747,'TVTIGER510.i4VTAddRSS - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  
  if bOk then result:=i4ID;
  rs.destroy;
end;
//=============================================================================
  
//=============================================================================
function TVTIGER510.bVTUpdateRSS(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  rs:=JADO_RECORDSET.Create;

  saQry:='';
  saQry += 'update ' +saVTPrefix+ 'rss SET ';
  saQry += ' rssid=' + p_DataXDL.Get_saValue('rssid'); // this just makes comma work right

  saField:='rssurl';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='rsstitle';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='rsstype';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='starred';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='jegas_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=grJASConfig.saServerID+'_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;

  saQry += ' WHERE rssid=' + p_DataXDL.Get_saValue('rssid');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then
  begin
    JLog(cnLog_Error,201003150748,'TVTIGER510.bVTUpdateRSS - saQry:'+saQry,SourceFile);
  end;
  rs.close;  
  rs.destroy;
  result:=bOk;
end;
//=============================================================================




//=============================================================================
Function TVTIGER510.i4VTAddPotential:longint;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 i4PotentialID: longint;
 saPotentialNo: ansistring;
 saModuleName: ansistring;

begin
  result:=0;
  bOk:=true;
  rs:=JADO_RECORDSET.create;
  
  saModuleName:='Potentials';
  i4PotentialID:=i4VTGetNewUniqueEntityID(saModuleName);  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
  bOk:=(i4PotentialID>0);
  if not bOk then
  begin
    JLog(cnLog_Error,201003191043,'TVTIGER510.i4VTAddPotential - i4PotentialID=ZERO',SourceFile);
  end;
  
  if bOk then
  begin
    saPotentialNo:=saVTIncrementModuleSeqNumber(saModuleName);
    bOk:=length(saPotentialNo)>0;
    if not bOk then
    begin JLog(cnLog_Error,201003191044,'TVTIGER510.i4VTAddPotential - saPotentialNo length=ZERO',SourceFile);
    end;
  end;
    
  if bOk then
  begin  
    // Add potential Record;
    saQry:='insert into ' + saVTPrefix+ 'potential (potentialid, potential_no) values (' + inttostr(i4PotentialID)+ ','+JADOC.saDBMSScrub(saPotentialNo)+')';
    bOk:=rs.open(saQry, JADOC);
    if not bOk then
    begin JLog(cnLog_Error,201003191045,'TVTIGER510.i4VTAddPotential - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;

  if bOk then
  begin
    saQry:='insert into '+saVTPrefix+'potentialscf (potentialid) values (' + inttostr(i4PotentialID)+ ')';
    bOk:=rs.open(saQry, JADOC);
    if not bOk then
    begin JLog(cnLog_Error,201003191047,'TVTIGER510.i4VTAddPotential - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
    
  if bOk then
  begin
    result:=i4PotentialID;
  end;  
  
  rs.destroy;
end;
//=============================================================================



//=============================================================================
Function TVTIGER510.bVTUpdatePotential(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  rs:=JADO_RECORDSET.Create;

  // Assumed that at a minimum $p_Data has the potential id as $p_Data['potentialid']
  
  //----------- Ok - now for the leaddetails table
  saQry:='';
  saQry += 'update ' +saVTPrefix+ 'potential SET ';
  saQry += ' potentialid='+p_DataXDL.Get_saValue('potentialid'); // this just makes comma work right
  saField:='potential_no';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='related_to';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='potentialname';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='amount';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='currency';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='closingdate';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='typeofrevenue';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='nextstep';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='private';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='probability';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='campaignid';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='sales_stage';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='potentialtype';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='leadsource';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='productid';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='productversion';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='quotationref';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='partnercontact';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='remarks';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='runtimefee';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='followupdate';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='evaluationstatus';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='description';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='forecastcategory';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='outcomeanalysis';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='jegas_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=grJASConfig.saServerID+'_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saQry += ' WHERE potentialid=' + p_DataXDL.Get_saValue('potentialid');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then 
  begin JLog(cnLog_Error,201003191048,'TVTIGER510.bVTUpdatePotential; - saQry:'+saQry,SourceFile);
  end;
  rs.close;

  result:=bOk;
  rs.destroy;
end;
//=============================================================================



//=============================================================================
Function TVTIGER510.i4VTAddActivity(p_i4ActivityID: longint):longint;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 i4ActivityID: longint;
 saModuleName: ansistring;

begin
  result:=0;
  bOk:=true;
  rs:=JADO_RECORDSET.create;
  
  saModuleName:='Calendar';
  if p_i4ActivityID=0 then 
  begin
    i4ActivityID:=i4VTGetNewUniqueEntityID(saModuleName);  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
  end
  else
  begin
    i4ActivityID:=p_i4ActivityID;// emails work like this - the crmentity is created as email, then activity record made using emailid.
  end;
  bOk:=(i4ActivityID>0);
  if not bOk then
  begin JLog(cnLog_Error,2010031913030,'TVTIGER510.i4VTAddActivity - i4ActivityID=ZERO',SourceFile);
  end;
  
  if bOk then
  begin  
    // Add Record;
    saQry:='insert into ' + saVTPrefix+ 'activity (activityid) values (' + inttostr(i4ActivityID)+ ')';
    bOk:=rs.open(saQry, JADOC);
    if not bOk then
    begin JLog(cnLog_Error,2010031913032,'TVTIGER510.i4VTAddActivity - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;

  if bOk then
  begin
    saQry:='insert into '+saVTPrefix+'activitycf (activityid) values (' + inttostr(i4ActivityID)+ ')';
    bOk:=rs.open(saQry, JADOC);
    if not bOk then
    begin JLog(cnLog_Error,2010031913033,'TVTIGER510.i4VTAddActivity - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
    
  if bOk then
  begin
    result:=i4ActivityID;
  end;  
  
  rs.destroy;
end;
//=============================================================================



//=============================================================================
Function TVTIGER510.bVTUpdateActivity(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  rs:=JADO_RECORDSET.Create;

  // Assumed that at a minimum $p_Data has the activity id as $p_Data['activityid']
  
  //----------- Ok - now for the leaddetails table
  saQry:='';
  saQry += 'update ' +saVTPrefix+ 'activity SET ';
  saQry += ' activityid='+p_DataXDL.Get_saValue('activityid'); // this just makes comma work right
  saField:='subject';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='semodule';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='activitytype';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='date_start';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='due_date';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='time_start';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='time_end';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='sendnotification';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='duration_hours';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='duration_minutes';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='status';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='eventstatus';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='priority';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='location';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='notime';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='visibility';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='recurringtype';if(p_DataXDL.FoundItem_saName(saField))then begin saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='jegas_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=grJASConfig.saServerID+'_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saQry += ' WHERE activityid=' + p_DataXDL.Get_saValue('activityid');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then 
  begin JLog(cnLog_Error,2010031913034,'TVTIGER510.bVTUpdateActivity; - saQry:'+saQry,SourceFile);
  end;
  rs.close;

  result:=bOk;
  rs.destroy;
end;
//=============================================================================

//=============================================================================
// use to associate contact with an activity
function TVTIGER510.bVTAddCntActivityRel(p_saContactID, p_saActivityID: ansistring): boolean;
//=============================================================================
var 
 RS: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  saQry:='select contactid, activityid from '+saVTPrefix+'cntactivityrel where contactid='+JADOC.saDBMSScrub(p_saContactID)+' and activityid=' + JADOC.saDBMSScrub(p_saActivityID);
  bOk:=rs.open(saQry, JADOC);
  if not bOK then
  begin JLog(cnLog_Error, 201003191523, 'TVTIGER510.bVTAddCntActivityRel - problem with query:'+saQry, SOURCEFILE);
  end;
  
  if bOk then
  begin
    if rs.eol = true then
    begin
      rs.close;
      saQry:='insert into '+saVTPrefix+'cntactivityrel (contactid, activityid) VALUES ('+JADOC.saDBMSScrub(p_saContactID)+','+JADOC.saDBMSScrub(p_saActivityID)+')';
      bOk:=rs.open(saQry, JADOC);
      if not bOK then
      begin
        JLog(cnLog_error, 201003191527, 'TVTIGER510.bVTAddCntActivityRel - problem with query:'+saQry, SOURCEFILE);
      end;
    end;  
  end;
  rs.close;
  rs.Destroy;
  result:=bOk;  
end;
//=============================================================================

//=============================================================================
// use to disassociate contact from a activity
function TVTIGER510.bVTDeleteCntActivityRel(p_saContactID, p_saActivityID: ansistring): boolean;
//=============================================================================
var 
 RS: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  saQry:='delete from '+saVTPrefix+'cntactivityrel where contactid='+JADOC.saDBMSScrub(p_saContactID)+' and activityid=' + JADOC.saDBMSScrub(p_saActivityID);
  bOk:=rs.open(saQry, JADOC);
  if not bOK then
  begin
    JLog(cnLog_error, 201003191528, 'TVTIGER510.bVTDeleteCntActivityRel - problem with query:'+saQry, SOURCEFILE);
  end;
  rs.close;    
  rs.Destroy;
  result:=bOk;  
end;
//=============================================================================

//=============================================================================
// use to associate a potential with a contact
function TVTIGER510.bVTAddCntPotentialRel(p_saContactID, p_saPotentialID: ansistring): boolean;
//=============================================================================
var 
 RS: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  saQry:='select contactid, potentialid from '+saVTPrefix+'cntpotentialrel where contactid='+JADOC.saDBMSScrub(p_saContactID)+' and potentialid=' + JADOC.saDBMSScrub(p_saPotentialID);
  bOk:=rs.open(saQry, JADOC);
  if not bOK then
  begin
    JLog(cnLog_error, 201003191531, 'TVTIGER510.bVTAddCntPotentialRel - problem with query:'+saQry, SOURCEFILE);
  end;
  
  if bOk then
  begin
    if rs.eol = true then
    begin
      rs.close;
      saQry:='insert into '+saVTPrefix+'cntpotentialrel (contactid, potentialid) VALUES ('+JADOC.saDBMSScrub(p_saContactID)+','+JADOC.saDBMSScrub(p_saPotentialID)+')';
      bOk:=rs.open(saQry, JADOC);
      if not bOK then
      begin
        JLog(cnLog_error, 201003191532, 'TVTIGER510.bVTAddCntPotentialRel - problem with query:'+saQry, SOURCEFILE);
      end;
    end;  
  end;
  rs.close;
  rs.Destroy;
  result:=bOk;  
end;
//=============================================================================

//=============================================================================
// use to disassociate a potential from a contact
function TVTIGER510.bVTDeleteCntPotentialRel(p_saContactID, p_saPotentialID: ansistring): boolean;
//=============================================================================
var 
 RS: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  saQry:='delete from '+saVTPrefix+'cntpotentialrel where contactid='+JADOC.saDBMSScrub(p_saContactID)+' and potentialid=' + JADOC.saDBMSScrub(p_saPotentialID);
  bOk:=rs.open(saQry, JADOC);
  if not bOK then
  begin
    JLog(cnLog_error, 201003191529, 'TVTIGER510.bVTDeleteCntPotentialRel - problem with query:'+saQry, SOURCEFILE);
  end;
  rs.close;    
  rs.Destroy;
  result:=bOk;  
end;
//=============================================================================

//=============================================================================
// SEActivity rel is used for relating ANY crm entity with a calendar event, 
// not not all of the "ANY" is implemented in 5.1.0 - just lead, account, contact
// use to associate a (supported) crm entity with an activity
function TVTIGER510.bVTAddSEActivityRel(p_saCRMID, p_saActivityID: ansistring): boolean;
//=============================================================================
var 
 RS: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  saQry:='select crmid, activityid from '+saVTPrefix+'seactivityrel where crmid='+JADOC.saDBMSScrub(p_saCRMID)+' and activityid=' + JADOC.saDBMSScrub(p_saActivityID);
  bOk:=rs.open(saQry, JADOC);
  if not bOK then
  begin
    JLog(cnLog_error, 201003191523, 'TVTIGER510.bVTAddSEActivityRel - problem with query:'+saQry, SOURCEFILE);
  end;
  
  if bOk then
  begin
    if rs.eol = true then
    begin
      rs.close;
      saQry:='insert into '+saVTPrefix+'seactivityrel (crmid, activityid) VALUES ('+JADOC.saDBMSScrub(p_saCRMID)+','+JADOC.saDBMSScrub(p_saActivityID)+')';
      bOk:=rs.open(saQry, JADOC);
      if not bOK then
      begin
        JLog(cnLog_error, 201003191527, 'TVTIGER510.bVTSEActivityRel - problem with query:'+saQry, SOURCEFILE);
      end;
    end;  
  end;
  rs.close;
  rs.Destroy;
  result:=bOk;  
end;
//=============================================================================

//=============================================================================
// SEActivity rel is used for relating ANY crm entity with a calendar event, 
// not not all of the "ANY" is implemented in 5.1.0 - just lead, account, contact
// use to disassociate a (supported) crm entity from an activity
function TVTIGER510.bVTDeleteSEActivityRel(p_saCRMID, p_saActivityID: ansistring): boolean;
//=============================================================================
var 
 RS: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  saQry:='delete from '+saVTPrefix+'seactivityrel where crmid='+JADOC.saDBMSScrub(p_saCRMID)+' and activityid=' + JADOC.saDBMSScrub(p_saActivityID);
  bOk:=rs.open(saQry, JADOC);
  if not bOK then
  begin
    JLog(cnLog_error, 201003191530, 'TVTIGER510.bVTDeleteSEActivityRel - problem with query:'+saQry, SOURCEFILE);
  end;
  rs.close;    
  rs.Destroy;
  result:=bOk;  
end;
//=============================================================================



//=============================================================================
// use to associate a Trouble Ticket/case with a CRM entity
function TVTIGER510.bVTAddSETicketRel(p_saCRMID, p_saTicketID: ansistring): boolean;
//=============================================================================
var 
 RS: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  saQry:='select crmid, ticketid from '+saVTPrefix+'seticketrel where crmid='+JADOC.saDBMSScrub(p_saCRMID)+' and activityid=' + JADOC.saDBMSScrub(p_saTicketID);
  bOk:=rs.open(saQry, JADOC);
  if not bOK then
  begin
    JLog(cnLog_error, 201003191714, 'TVTIGER510.bVTAddSETicketRel - problem with query:'+saQry, SOURCEFILE);
  end;
  
  if bOk then
  begin
    if rs.eol = true then
    begin
      rs.close;
      saQry:='insert into '+saVTPrefix+'seticketrel (crmid, ticketid) VALUES ('+JADOC.saDBMSScrub(p_saCRMID)+','+JADOC.saDBMSScrub(p_saTicketID)+')';
      bOk:=rs.open(saQry, JADOC);
      if not bOK then
      begin
        JLog(cnLog_error, 201003191713, 'TVTIGER510.bVTSEActivityRel - problem with query:'+saQry, SOURCEFILE);
      end;
    end;  
  end;
  rs.close;
  rs.Destroy;
  result:=bOk;  
end;
//=============================================================================

//=============================================================================
// use to disassociate contact from a activity
function TVTIGER510.bVTDeleteSETicketRel(p_saCRMID, p_saTicketID: ansistring): boolean;
//=============================================================================
var 
 RS: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  saQry:='delete from '+saVTPrefix+'seticketrel where crmid='+JADOC.saDBMSScrub(p_saCRMID)+' and ticketid=' + JADOC.saDBMSScrub(p_saTicketID);
  bOk:=rs.open(saQry, JADOC);
  if not bOK then
  begin
    JLog(cnLog_error, 201003191712, 'TVTIGER510.bVTDeleteSETicketRel - problem with query:'+saQry, SOURCEFILE);
  end;
  rs.close;    
  rs.Destroy;
  result:=bOk;  
end;
//=============================================================================









//=============================================================================
Function TVTIGER510.i4VTAddServiceContracts: longint; 
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 i4ServiceContractsID: longint;
 saContractNo: ansistring;
 saModuleName: ansistring;
begin
  result:=0;
  rs:=JADO_RECORDSET.create;
  saModuleName:='ServiceContracts';
  i4ServiceContractsID:=i4VTGetNewUniqueEntityID(saModuleName);  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
  bOk:=(i4ServiceContractsID>0);
  if not bOk then
  begin
    JLog(cnLog_Error,201003191647,'TVTIGER510.i4VTAddServiceContracts - i4ServiceContractsID=ZERO',SourceFile);
  end;
  
  if bOk then
  begin
    saContractNo:=saVTIncrementModuleSeqNumber(saModuleName);
    bOk:=length(saContractNo)>0;
    if not bOk then
    begin JLog(cnLog_Error,201003191648,'TVTIGER510.i4VTAddServiceContracts - saContractNo length = ZERO',SourceFile);
    end;
  end;
  
  if bOk then
  begin
    saQry:='insert into ' +saVTPrefix+ 'servicecontracts (servicecontractsid, contract_no) values (' + inttostr(i4ServiceContractsID) + ',' + JADOC.saDbMSScrub(saContractNo) +')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin JLog(cnLog_Error,201003191714,'TVTIGER510.i4VTAddServiceContracts - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
    
  if bOk then
  begin  
    saQry:='insert into ' +saVTPrefix+ 'servicecontractscf (servicecontractsid) values (' + inttostr(i4ServiceContractsID) + ')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin JLog(cnLog_Error,201003191715,'TVTIGER510.i4VTAddServiceContracts - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  
  if bOk then
  begin
    result:=i4ServiceContractsID;
  end;
  rs.destroy;
end;
//=============================================================================



//=============================================================================
Function TVTIGER510.bVTUpdateServiceContracts(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  rs:=JADO_RECORDSET.Create;
  
  // Assumed that at a minimum $p_Data has the servicecontractsid as $p_Data['servicecontractsid']
  // Note Account entity has TWO unique address tables
  //----------- Ok - now for the account table
  saQry:='';
  saQry += 'update ' +saVTPrefix+ 'servicecontracts SET ';
  saQry += ' servicecontractsid=' + p_DataXDL.Get_saValue('servicecontractsid'); // this just makes comma work right
  saField:='start_date';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='end_date';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='sc_related_to';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='tracking_unit';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='total_units';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='used_units';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='subject';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='due_date';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='planned_duration';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='actual_duration';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='contract_status';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='priority';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='contract_type';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='progress';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='contract_no';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='jegas_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=grJASConfig.saServerID+'_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saQry += ' WHERE servicecontractsid=' + p_DataXDL.Get_saValue('servicecontractsid');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then
  begin
    JLog(cnLog_Error,201003191717,'bVTUpdateServiceContracts - saQry:'+saQry,SourceFile);
  end;
  rs.close;  
  
  result:=bOk;
  rs.destroy;
end;
//=============================================================================



//=============================================================================
// this works like the iVTAddContact function except this is for the Potentials entity
// Modules:
// Documents
Function TVTIGER510.i4VTAddNotes(p_saModuleName: ansistring):longint;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 i4NotesID: longint;
 saNoteNo: ansistring;
begin
  result:=0;
  rs:=JADO_RECORDSET.create;
  i4NotesID:=i4VTGetNewUniqueEntityID(p_saModuleName);  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
  bOk:=(i4NotesID>0);
  if not bOk then
  begin
    JLog(cnLog_Error,201003192019,'TVTIGER510.i4VTAddNotes - i4NotesID=ZERO',SourceFile);
  end;
  
  if bOk then
  begin
    saNoteNo:=saVTIncrementModuleSeqNumber(p_saModuleName);
    bOk:=length(saNoteNo)>0;
    if not bOk then
    begin
      JLog(cnLog_Error,201003191648,'TVTIGER510.i4VTAddNotes - saNotesNo length = ZERO',SourceFile);
    end;
  end;


  if bOk then
  begin
    saQry:='insert into ' +saVTPrefix+ 'notes (notesid,note_no) values (' + inttostr(i4NotesID)+','+JADOC.saDBMSSCrub(saNoteNo)+')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,2010031929020,'TVTIGER510.i4VTAddNotes - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
    
  if bOk then
  begin  
    saQry:='insert into ' +saVTPrefix+ 'notescf (notesid) values (' + inttostr(i4NotesID) + ')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin
      JLog(cnLog_Error,201003192021,'TVTIGER510.i4VTAddNotes - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;
  
  if bOk then
  begin
    result:=i4NotesID;
  end;
  rs.destroy;
end;
//=============================================================================

//=============================================================================
// this works like the bUpdateContact function except this is for the Potentials entity
Function TVTIGER510.bVTUpdateNotes(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  rs:=JADO_RECORDSET.Create;
  
  // Assumed that at a minimum $p_Data has the notesid as $p_Data['notesid']
  // Note Account entity has TWO unique address tables
  //----------- Ok - now for the account table
  saQry:='';
  saQry += 'update ' +saVTPrefix+ 'notes SET ';
  saQry += ' notesid=' + p_DataXDL.Get_saValue('notesid'); // this just makes comma work right
  saField:='note_no';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='title';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='filename';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='notecontent';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='folderid';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='filetype';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='filelocationtype';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='filedownloadcount';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='filestatus';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='filesize';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='fileversion';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='jegas_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=grJASConfig.saServerID+'_id';if(p_DataXDL.FoundItem_saName(saField))then begin  saQry += ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saQry += ' WHERE notesid=' + p_DataXDL.Get_saValue('notesid');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then
  begin
    JLog(cnLog_Error,201003192022,'bVTUpdateNotes - saQry:'+saQry,SourceFile);
  end;
  rs.close;  
  
  result:=bOk;
  rs.destroy;
end;
//=============================================================================






//=============================================================================
// this works like the iVTAddContact function except this is for the Potentials entity
Function TVTIGER510.i4VTAddEmail:longint;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 i4EmailID: longint;
 saModuleName: ansistring;
begin
  rs:=JADO_RECORDSET.Create;
  saModuleName:='Emails';
  result:=0;
  
  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
  i4EmailID:=i4VTGetNewUniqueEntityID(saModuleName);  
  bOk:=(i4EmailID>0);
  if not bOk then
  begin
    JLog(cnLog_Error,201003192312,'TVTIGER510.i4VTAddEmail - i4EmailID=ZERO',SourceFile);
  end;
  
  if bOk then
  begin
    saQry:='insert into ' + saVTPrefix + 'emaildetails (emailid) values (' + inttostr(i4EmailID) + ')';
    bOk:=rs.open(saQry,JADOC);
    if not bOk then
    begin JLog(cnLog_Error,201003192313,'TVTIGER510.i4VTAddEmail - saQry:'+saQry,SourceFile);
    end;
    rs.close;
  end;

  if bOk then
  begin
    result:=i4EmailID;  
  end;
  rs.Destroy;
end;
//=============================================================================


//=============================================================================
// this works like the bUpdateContact function except this is for the Potentials entity
Function TVTIGER510.bVTUpdateEmail(p_DataXDL: JFC_XDL): boolean;
//=============================================================================
var
 rs: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
 saField: ansistring;
begin
  result:=false;
  rs:=JADO_RECORDSET.Create;
  
  // Assumed that at a minimum $p_Data has the email id as $p_Data['emailid']
  
  //----------- Ok - now for the contactdetails table
  saQry:='';
  saQry+='update '+saVTPrefix+'emaildetails SET ';
  saQry+=' emailid=' + p_DataXDL.Get_saValue('emailid'); // this just makes comma work right
  saField:='from_email';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='to_email';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='cc_email';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='bcc_email';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='assigned_user_email';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='idlists';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='email_flag';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:='jegas_id';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saField:=grJASConfig.saServerID+'_id';if(p_DataXDL.FoundItem_saName(saField))then begin saQry+= ', '+ saField + ' = '; if(p_DataXDL.Item_saValue='NULL') then begin saQry += 'null'; end else begin  saQry+=JADOC.saDBMSScrub(p_DataXDL.Item_saValue) ; end; end;
  saQry += ' WHERE emailid=' + p_DataXDL.Get_saValue('emailid');
  bOk:=rs.open(saQry,JADOC);
  if not bOk then
  begin
    JLog(cnLog_Error,201003192314,'TVTIGER510.bVTUpdateEmail - saQry:'+saQry,SourceFile);
  end;
  rs.close;
  result:=bOk;
  rs.Destroy;
  
end;
//=============================================================================






//=============================================================================
function TVTIGER510.bVTAddSENotesRel(p_saCRMID, p_saNotesID: ansistring): boolean;
//=============================================================================
var 
 RS: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  saQry:='select crmid, notesid from '+saVTPrefix+'senotesrel where crmid='+JADOC.saDBMSScrub(p_saCRMID)+' and notesid=' + JADOC.saDBMSScrub(p_saNotesID);
  bOk:=rs.open(saQry, JADOC);
  if not bOK then
  begin
    JLog(cnLog_Error, 201004302128, 'TVTIGER510.bVTAddSENoptesRel - problem with query:'+saQry, SOURCEFILE);
  end;
  
  if bOk then
  begin
    if rs.eol = true then
    begin
      rs.close;
      saQry:='insert into '+saVTPrefix+'senotesrel (crmid, notesid) VALUES ('+JADOC.saDBMSScrub(p_saCRMID)+','+JADOC.saDBMSScrub(p_saNotesID)+')';
      bOk:=rs.open(saQry, JADOC);
      if not bOK then
      begin
        JLog(cnLog_error, 201004302129, 'TVTIGER510.bVTSENotesRel - problem with query:'+saQry, SOURCEFILE);
      end;
    end;  
  end;
  rs.close;
  rs.Destroy;
  result:=bOk;  
end;
//=============================================================================

//=============================================================================
function TVTIGER510.bVTDeleteSENotesRel(p_saCRMID, p_saNotesID: ansistring): boolean;
//=============================================================================
var 
 RS: JADO_RECORDSET;
 saQry: ansistring;
 bOk: boolean;
begin
  bOk:=true;
  rs:=JADO_RECORDSET.Create;
  saQry:='delete from '+saVTPrefix+'senotesrel where crmid='+JADOC.saDBMSScrub(p_saCRMID)+' and notesid=' + JADOC.saDBMSScrub(p_saNotesID);
  bOk:=rs.open(saQry, JADOC);
  if not bOK then
  begin
    JLog(cnLog_error, 201004302130, 'TVTIGER510.bVTDeleteSENoteRel - problem with query:'+saQry, SOURCEFILE);
  end;
  rs.close;    
  rs.Destroy;
  result:=bOk;  
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
