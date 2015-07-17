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
Unit ug_sugarcrm550a;
//=============================================================================

//=============================================================================
// Global Directives
//=============================================================================
{$INCLUDE i_jegas_macros.pp}
{$DEFINE SOURCEFILE:='ug_sugarcrm550a.pp'}
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
type TSUGAR550A=class(JFC_XDL)
//=============================================================================
  public
  constructor create(p_JADOC: JADO_CONNECTION);
  destructor destroy; override;
  public
  TableXDL: JFC_XDL;
  
  
  //---------------------------------------------------------------------------
  {}
  JADOC: JADO_CONNECTION;//< This class doesn't create NOR destroy this
  {}
  //---------------------------------------------------------------------------
  //  accounts
  //  accounts_audit
  //  accounts_bugs
  //  accounts_cases
  //  accounts_contacts
  //  accounts_cstm
  //  accounts_opportunities
  //  accounts_otrs
  //  acl_actions
  //  acl_roles
  //  acl_roles_actions
  //  acl_roles_users
  //  address_book
  //  bugs
  //  bugs_audit
  //  calls
  //  calls_contacts
  //  calls_users
  //  campaign_log
  //  campaign_trkrs
  //  campaigns
  //  campaigns_audit
  //  cases
  //  cases_audit
  //  cases_bugs
  //  cases_cstm
  //  config
  //  contacts
  //  contacts_audit
  //  contacts_bugs
  //  contacts_cases
  //  contacts_cstm
  //  contacts_otrs
  //  contacts_users
  //  contracts
  //  contracts_audit
  //  contracts_cstm
  //  contracts_product
  //  currencies
  //  custom_fields
  //  dashboards
  //  document_revisions
  //  documents
  //  email_addr_bean_rel
  //  email_addresses
  //  email_cache
  //  email_marketing
  //  email_marketing_prospect_lists
  //  email_templates
  //  emailman
  //  emailman_sent_
  //  emails
  //  emails_accounts
  //  emails_beans
  //  emails_bugs
  //  emails_cases
  //  emails_contacts
  //  emails_email_addr_rel
  //  emails_leads
  //  emails_opportunities
  //  emails_project_tasks
  //  emails_projects
  //  emails_prospects
  //  emails_tasks
  //  emails_text
  //  emails_users
  //  feeds
  //  fields_meta_data
  //  files
  //  folders
  //  folders_rel
  //  folders_subscriptions
  //  iframes
  //  import_maps
  //  inbound_email
  //  inbound_email_autoreply
  //  inbound_email_cache_ts
  //  leads
  //  leads_audit
  //  leads_cstm
  //  linked_documents
  //  meetings
  //  meetings_contacts
  //  meetings_users
  //  notes
  //  opportunities
  //  opportunities_audit
  //  opportunities_contacts
  //  otrs
  //  outbound_email
  //  project
  //  project_relation
  //  project_task
  //  project_task_audit
  //  projects_accounts
  //  projects_bugs
  //  projects_cases
  //  projects_contacts
  //  projects_opportunities
  //  projects_products
  //  prospect_list_campaigns
  //  prospect_lists
  //  prospect_lists_prospects
  //  prospects
  //  relationships
  //  releases
  //  roles
  //  roles_modules
  //  roles_users
  //  saved_search
  //  schedulers
  //  schedulers_times
  //  session_active
  //  session_history
  //  tasks
  //  tracker
  //  travels
  //  travels_contacts
  //  travels_users
  //  upgrade_history
  //  user_preferences
  //  users
  //  users_feeds
  //  users_last_import
  //  users_objective
  //  users_signatures
  //  vcals
  //  versions
  //---------------------------------------------------------------------------

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
constructor TSUGAR550A.create(p_JADOC: JADO_CONNECTION);
//=============================================================================
begin
  self.JADOC:=p_JADOC;
  
  // Tables in alphabetical order originally, but tables needed to be processed
  // first in a Sugar to vTigerCRM conversion were moved to the top so they 
  // would be processed first.
  self.TableXDL:=JFC_XDL.Create;
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='currencies';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='users';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='accounts';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='contacts';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='cases';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='leads';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='opportunities';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='accounts_opportunities';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='opportunities_contacts';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='meetings';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='meetings_contacts';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='meetings_users';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='calls';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='calls_contacts';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='calls_users';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='documents';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='document_revisions';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails';
  
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='accounts_audit';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='accounts_bugs';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='accounts_cases';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='accounts_contacts';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='accounts_cstm';
  ////self.TableXDL.AppendItem; self.TableXDL.Item_saName:='accounts_otrs';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='acl_actions';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='acl_roles';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='acl_roles_actions';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='acl_roles_users';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='address_book';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='bugs';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='bugs_audit';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='campaign_log';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='campaign_trkrs';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='campaigns';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='campaigns_audit';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='cases_audit';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='cases_bugs';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='cases_cstm';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='config';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='contacts_audit';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='contacts_bugs';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='contacts_cases';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='contacts_cstm';
  ////self.TableXDL.AppendItem; self.TableXDL.Item_saName:='contacts_otrs';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='contacts_users';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='contracts';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='contracts_audit';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='contracts_cstm';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='contracts_product';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='custom_fields';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='dashboards';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='email_addr_bean_rel';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='email_addresses';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='email_cache';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='email_marketing';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='email_marketing_prospect_lists';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='email_templates';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emailman';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emailman_sent_';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_accounts';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_beans';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_bugs';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_cases';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_contacts';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_email_addr_rel';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_leads';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_opportunities';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_project_tasks';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_projects';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_prospects';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_tasks';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_text';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='emails_users';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='feeds';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='fields_meta_data';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='files';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='folders';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='folders_rel';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='folders_subscriptions';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='iframes';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='import_maps';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='inbound_email';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='inbound_email_autoreply';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='inbound_email_cache_ts';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='leads_audit';
  ////self.TableXDL.AppendItem; self.TableXDL.Item_saName:='leads_cstm';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='linked_documents';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='opportunities_audit';
  ////self.TableXDL.AppendItem; self.TableXDL.Item_saName:='otrs';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='outbound_email';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='project';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='project_relation';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='project_task';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='project_task_audit';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='projects_accounts';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='projects_bugs';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='projects_cases';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='projects_contacts';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='projects_opportunities';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='projects_products';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='prospect_list_campaigns';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='prospect_lists';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='prospect_lists_prospects';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='prospects';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='relationships';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='releases';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='roles';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='roles_modules';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='roles_users';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='saved_search';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='schedulers';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='schedulers_times';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='session_active';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='session_history';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='tasks';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='tracker';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='travels';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='travels_contacts';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='travels_users';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='upgrade_history';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='user_preferences';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='users_feeds';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='users_last_import';
  //self.TableXDL.AppendItem; self.TableXDL.Item_saName:='users_objective';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='users_signatures';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='vcals';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='versions';
  self.TableXDL.AppendItem; self.TableXDL.Item_saName:='notes';
end;
//=============================================================================

//=============================================================================
destructor TSUGAR550A.destroy;
//=============================================================================
begin
  self.TableXDL.Destroy;
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
