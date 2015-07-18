<?PHP
// =================================================================
// |    _________ _______  _______  ______  _______                |
// |   /___  ___// _____/ / _____/ / __  / / _____/                |  
// |      / /   / /__    / / ___  / /_/ / / /____                  |       
// |     / /   / ____/  / / /  / / __  / /____  /                  |
// |____/ /   / /___   / /__/ / / / / / _____/ / By: Jegas, LLC    |
// /_____/   /______/ /______/ /_/ /_/ /______/                    |
// |                 Under the Hood            JasonPSage@jegas.com|
// =================================================================  
// Jegas Application Server PHP API. 
// =================================================================  
// JASCID: 201012270042
// TODO: Make JAS API Routines such that they can remain local or
//       use the TCP JAS interface - i.e. create interface for 
//       communicating with JAS server via post mechanism or 
//       through webservices. 
// =================================================================  
include_once('jas_location.php');
include_once('config.jas.php');


//define('jegas_debug_messages','secure');
define('jegas_debug_messages','verbose');

$DBCON=NULL;// Array that allows referencing database index in JAS by connection name: Example: DBCON['JAS']['ID'] = jasdb.jdconnection.JDCon_JDConnection_UID
$gconnJAS=null; // JAS Mysql connection
$JADOC=NULL;// Array of MYSQL connections. For Index value to use see $DBCON array after they are initialized in Init_DB_Connections() function 


$gconnVT=null;// vtiger MYSQL connection
//$gconnVICI=null; // VICI MySQL connection
//$gconnPMOSWF=null; // PMOS WF MySQL connection
//$gconnPMOSRB=null; // PMOS RB MySQL connection
//$gconnPMOSRP=null; // PMOS RP MySQL connection

$gVTPrefix;
$gVTPrefix="vtiger";
// --
$gsJSID='0';// JAS session ID - ZERO denotes no session
$gsJASUsername = '';
$giRetryLimit=10;



// =================================================================  
// BEGIN - Generic - Non System Specific
// =================================================================  
//--------------------------------
Function ReportMySQLErrorandStop($p_ErrID, $p_rCon, $p_qry){
//--------------------------------
  try{
    if(mysql_errno($p_rCon)!=0){ 
      $Message="Error: " . $p_ErrID;
      if(jegas_debug_messages=="verbose"){ 
        $Message = $Message . " " . mysql_error($p_rCon) . " - Qry: " . $p_qry; 
      };
      die($Message);
    };
  }catch(Exception $e){
    die("200912142232 " . $e);
  };
};
//--------------------------------

//--------------------------------
Function ReportErrorandStop($p_ErrID, $p_sMsg){
//--------------------------------
  $Message = "Error: " . $p_ErrID;
  if(jegas_debug_messages=='verbose'){ 
    $Message .= ' - ' . $p_sMsg;
  }; 
  die($Message);
};
//--------------------------------

//--------------------------------
// This function came from http://www.webtoolkit.info/php-random-password-generator.html
function generatePassword($length=9, $strength=16) {
//--------------------------------
        $vowels = 'aeuy';
        $consonants = 'bdghjmnpqrstvz';
        if ($strength & 1) {
                $consonants .= 'BDGHJLMNPQRSTVWXZ';
        }
        if ($strength & 2) {
                $vowels .= "AEUY";
        }
        if ($strength & 4) {
                $consonants .= '23456789';
        }
        if ($strength & 8) {
                $consonants .= '@#$%';
        }
 
        $password = '';
        $alt = time() % 2;
        for ($i = 0; $i < $length; $i++) {
                if ($alt == 1) {
                        $password .= $consonants[(rand() % strlen($consonants))];
                        $alt = 0;
                } else {
                        $password .= $vowels[(rand() % strlen($vowels))];
                        $alt = 1;
                }
        }
        return $password;
}
//--------------------------------


//--------------------------------
function sTrueFalse($p_b){
  if ($p_b){ 
    return 'True';
  }else{
    return 'False';
  };
};
//--------------------------------


// =================================================================  
// END - Generic - Non System Specific
// =================================================================  






// =================================================================  
// BEGIN - JAS Database Specific
// =================================================================  
define('csLockTimeOutInMinutes','30');

//--------------------------------
function JADOC_CONNECT($p_sName){
//--------------------------------
  global $JADOC;
  global $DBCON;
    
  if($JADOC[$p_sName]==null){
    $JADOC[$p_sName]=mysql_connect($DBCON[$p_sName]['SERVER'], $DBCON[$p_sName]['USER'], $DBCON[$p_sName]['PASSWORD']);   
    if(!mysql_select_db($DBCON[$p_sName]['DATABASE'],$JADOC[$p_sName])){ 
      ReportErrorAndStop('201002111634',
        'Unable to connect to Connection ' . $p_sName . ' Database:' . $DBCON[$p_sName]['DATABASE'] .
        ' JDCon_JDConnection_UID:' .  $DBCON[$p_sName]['ID']
      ); 
    };
  };   
}; 
//--------------------------------


//--------------------------------
function Init_DB_Connections(){
//--------------------------------
  global $JADOC;
  global $DBCON;
  global $gconnJAS;
  
  // MAIN JAS Connection
  $DBCON['JAS']['ID']= '0';
  $DBCON['JAS']['USER']=jas_db_username;
  $DBCON['JAS']['PASSWORD']= jas_db_password;
  $DBCON['JAS']['SERVER']= jas_db_server;
  $DBCON['JAS']['DATABASE']= jas_db_name;
  $JADOC['JAS']=null;

  //die('201006271309 - jas_api.php Init_DB_Connections JAS Credentials:' .
  //  'ID: ' . $DBCON['JAS']['ID'] . ' ' .
  //  'USER: ' . $DBCON['JAS']['USER'] . ' ' .
  //  'PASSWORD: ' . $DBCON['JAS']['PASSWORD'] . ' ' .
  //  'SERVER: ' . $DBCON['JAS']['SERVER'] . ' ' .
  //  'DATABASE: ' . $DBCON['JAS']['DATABASE']
  //);
  JADOC_CONNECT('JAS');
  $gconnJAS=$JADOC['JAS'];
  
  
  // Now to load up the dynamic connections - currently - this code only 
  // works with mysql connections - however; perhaps this code can 
  // be expanded to use ODBC like JAS does natively. There is some code
  // references in processmaker to pear - I think it might be a php 
  // database solution - dunno - if we just added ODBC to PHP codebase I think 
  // we'd be ok also. For Now - PHP = mysql only. 
  $qryJAS="select * from jdconnection where JDCon_Enabled_b=true order by JDCon_Name";
  $qresultJAS=mysql_query($qryJAS,$JADOC['JAS']);  ReportMySQLErrorandStop('201002191911', $JADOC['JAS'], $qryJAS);
  if (mysql_num_rows($qresultJAS)>0){
    while($rowJASUser=mysql_fetch_array($qresultJAS)){
      $DBCON[$rowJASUser['JDCon_Name']]['ID']= $rowJASUser['JDCon_JDConnection_UID'];
      $DBCON[$rowJASUser['JDCon_Name']]['USER']= $rowJASUser['JDCon_Username'];
      $DBCON[$rowJASUser['JDCon_Name']]['PASSWORD']= $rowJASUser['JDCon_Password'];
      $DBCON[$rowJASUser['JDCon_Name']]['SERVER']= $rowJASUser['JDCon_Server'];
      $DBCON[$rowJASUser['JDCon_Name']]['DATABASE']= $rowJASUser['JDCon_Database'];
      $JADOC[$rowJASUser['JDCon_Name']]=null;
    };      
  };      
};
//--------------------------------




//--------------------------------
function bJAS_LockRecord($p_sJDConnectionID, $p_sTableID, $p_sRowID){
//--------------------------------
  global $gconnJAS;
  global $gsJSID;
  global $gsJASUsername;
  global $giRetryLimit;
    
  $saQry='';
  $qr1=null;//query results 1 and 2
  $qr2=null;    
  $bGotTheLock=false;
  $bSuccess=true;    
  
  //if(strlen($p_sJDConnectionID)>1){die('201010121035 - bad connection passed: '.$p_sJDConnectionID.' '.$p_sTableID.' '.$p_sRowID);};  
  
  // PART #1------------------------------
  // (OLD: 1: Blast ANY OLD LOCKS or Locks without corresponding Session ID's)
  // Revised: Blast ANY OLD LOCKS or ones from sessions now gone
  $qry="DELETE FROM jlock where (JLock_Locked_DT < date_sub(now(), interval ".csLockTimeOutInMinutes." minute)) ";  
  mysql_query($qry, $gconnJAS);  ReportMySQLErrorandStop('200912151428', $gconnJAS, $qry);
  
  // NOTE: The ZERO connection ID's are there WHILE creating sessions, so can't blast those. Worst case they time out.
  $qry='SELECT JLock_JPConnection_ID from jlock inner join jpconnection on JLock_JPConnection_ID=JPCon_JPConnection_UID ' .
       'WHERE (JPCon_JPConnection_UID is null) and (JLock_JPConnection_ID<>0)';
  $qr2=mysql_query($qry, $gconnJAS);  ReportMySQLErrorandStop('200912151429', $gconnJAS, $qry);
  while($row=mysql_fetch_array($qr2)){
    $qry="DELETE FROM jlock where JLock_JPConnection_ID='" . $row['JLock_JPConnection_ID'] . "'";
    $qr1=mysql_query($qry, $gconnJAS);  ReportMySQLErrorandStop('200912151439', $gconnJAS, $qry);
  };
    
  // PART #2------------------------------
  // 2: First TRY to LOCK entire Table - if can't - someone else has it.
  //    (Loop to try a couple times) (TABLE LOCK= TABLE ID, ROWID=0)
  //echo "\nlock record: " . $p_sJDConnectionID . ' ' . $p_sTableID . ' ' . $p_sRowID;
  //if ($p_sTableID == 'JAS_jperson') { $p_sTableID=JAS_jperson; }; 
    
    
  $iRetry=0;  
  $qry="INSERT INTO jlock (JLock_JDConnection_ID,JLock_JPConnection_ID,JLock_Locked_DT,JLock_Table_ID, JLock_Row_ID, " .
        "JLock_Col_ID, JLock_Username) VALUES " .
         "(" . $p_sJDConnectionID .", ". $gsJSID . ",now(), " . $p_sTableID . ",0,0, '".mysql_real_escape_string($gsJASUsername) . "')";
  //$qry="INSERT INTO jlock (JLock_JDConnection_ID,JLock_JPConnection_ID,JLock_Locked_DT,JLock_Table_ID, JLock_Row_ID, " .
  //      "JLock_Col_ID, JLock_Username) VALUES " .
  //       "(" . '0' .", ". $gsJSID . ",now(), " . $p_sTableID . ",0,0, '".mysql_real_escape_string($gsJASUsername) . "')";
  do{
   $qr1=mysql_query($qry, $gconnJAS);
   if(mysql_errno($gconnJAS)<>0){ 
     $iRetry=$iRetry+1;; sleep(1);
   };
  }while(($iRetry<$giRetryLimit) and (mysql_errno($gconnJAS)<>0));
  $bSuccess=(mysql_errno($gconnJAS)==0);
  if($bSuccess==false){  
    ReportMySQLErrorandStop('201010121021',$gconnJAS,$qry);
    die('bJAS_LockRecord - 201002131822 - bSuccess==false qry:'.$qry); 
  };    
  
  // PART #3------------------------------
  // 3: Once Table Lock Established, (ROWID=0) - see if other locks row level exist,
  //    if they do - lose the table lock... keeping table locked not permitted, others own rows.
  if($bSuccess){
    // Table LOCK established. If ROW ID supplied is ZERO, see if we can "KEEP"
    // this table lock by checking if any rows in this table are locked.
    if(($p_sRowID)=='0'){
      $qry="SELECT COUNT(*) as MyCount FROM jlock WHERE (JLock_Table_ID='" . mysql_real_escape_string($p_sTableID) . "') and (JLock_Row_ID<>0) and (JLock_JDConnection_ID='" . mysql_real_escape_string($p_sJDConnectionID) . " ')";
      $qr1=mysql_query($qry, $gconnJAS);ReportMySQLErrorandStop('200912151506', $gconnJAS, $qry);
      $row=mysql_fetch_array($qr1);     
      if(intval($row['MyCount'])>0){
        die("YUP - I can't keep the Table Lock. So, let's blast the lock I just got...");
        // YUP - I can't keep the Table Lock. So, let's blast the lock I just got...
        $qry="DELETE FROM jlock where JLock_JDConnection_ID='" . mysql_real_escape_string($p_sJDConnectionID) ."', JLock_Table_ID='".mysql_real_escape_string($p_sTableID)."' and JLock_Row_ID=0";
        $qr1=mysql_query($qry, $gconnJAS);ReportMySQLErrorandStop('200912151510', $gconnJAS, $qry);
        $bSuccess=false;
        // This is how we return from the function as a failure...
        // By not calling the Error page thing, we don't create a error condition that generates a 
        // web page to the user. instead, this function just returns false because it was unable 
        // to get the ENTIRE TABLE LOCKED.
      }else{
        $bGotTheLock=true;// TABLE LOCK - Got IT
      };
    };
  };
  if($bSuccess==false){  die('bJAS_LockRecord - 201002131832 - bSuccess==false qry:'.$qry); };
  
  // PART #4------------------------------
  // 4: If a ROW ID is Specified, lock the ROW and then Lose the Table Lock. 
  //
  if($bSuccess){
    // Table LOCK established. If ROW ID supplied is NOT ZERO, see if we can 
    // Get the ROW locked we want.
    if(intval($p_sRowID)>0){
      $qry="INSERT INTO jlock (JLock_JDConnection_ID, JLock_JPConnection_ID,JLock_Locked_DT,JLock_Table_ID, " . 
           "JLock_Row_ID, JLock_Col_ID, JLock_Username) VALUES " .
           "('" . mysql_real_escape_string($p_sJDConnection) ."'," . $gsJSID . ",now(), " . $p_sTableID . "," . $p_sRowID . ",0,'" . mysql_real_escape_string($gsJASUsername) . "')";
      $iRetry=0;
      do{
        $qr1=mysql_query($qry, $gconnJAS);
        if(mysql_errno($gconnJAS)<>0){ $iRetry=$iRetry+1;; sleep(1); };
      }while(($iRetry<$giRetryLimit) and (mysql_errno($gconnJAS)<>0));
      $bSuccess=(mysql_errno($gconnJAS)==0);    
      //if($bSuccess==false){  die('bJAS_LockRecord - 201002131833 - bSuccess==false qry:'.$qry); };
      $bGotTheLock=$bSuccess;
      
      // NOW Blast our Table Lock - we didn't really want it anyways.
      // We don't worry about success flag because it is set the way we want.
      // This is a clean up measure.
      $qry="DELETE FROM jlock where (JLock_JDConnection_ID='" . mysql_real_escape_string($p_sJDConnectionID) ."') and (JLock_Table_ID='".mysql_real_escape_string($p_sTableID)."') and (JLock_Row_ID=0)";
      $qr1=mysql_query($qry, $gconnJAS);ReportMySQLErrorandStop('200912151517', $gconnJAS, $qry);
    };
  };  
    
  return $bGotTheLock;
};
//--------------------------------





//--------------------------------
// This function just validates that the LOCK indeed belongs to this session.
Function bJAS_RecordLockRecord($p_sJDConnectionID, $p_sTableID,$p_sRowID){
//--------------------------------
  global $gconnJAS;
  $qry="SELECT JLock_JPConnection_ID from jlock where (JLock_Table_ID='" . mysql_real_escape_string($p_sTableID) . "')" .
        " and (JLock_Row_ID='".mysql_real_escape_string($p_sRowID)."') and (JLock_JPConnection_ID='".mysql_real_escape_string($gsJSID)."')".
        " and (JLock_JDConnection_ID='" . mysql_real_escape_string($p_sJDConnectionID) . "')";
  $qresult = mysql_query($qry, $gconnJAS);ReportMySQLErrorandStop('200912151550', $gconnJAS, $qry);
  $rowcount=mysql_num_rows($qresult);
  return (mysql_num_rows($qresult)>0) ;
};
//--------------------------------


//--------------------------------
// Do to the Nature of this function, the result is not as important
// as the lockrecord one.
Function bJAS_UnlockRecord($p_sJDConnectionID, $p_sTableID, $p_sRowID){
//--------------------------------
  global $gconnJAS;
  $qry="DELETE FROM jlock where " .
        " JLock_Table_ID='".mysql_real_escape_string($p_sTableID)."' and " .
        " JLock_Row_ID='".mysql_real_escape_string($p_sRowID)."'".
        " and JLock_JPConnection_ID='". mysql_real_escape_string($gsJSID)."'".
        " and JLock_JDConnection_ID='". mysql_real_escape_string($p_sJDConnectionID)."'";
  $qresult = mysql_query($qry, $gconnJAS);
  ReportMySQLErrorandStop('201002131847 Unable to unlock record', $gconnJAS, $qry);
  return(mysql_error($gconnJAS)==0);
};
//--------------------------------


//--------------------------------
// Function PRESUMES that there IS a juid table record with a UID record 
// identical to the jtable.JTabl_JTable_UID value. These are one-to-one. 
// Yes, one UID per Table in Jegas that is MAINTAINED by Jegas.
Function sJAS_GetNextUID($p_sJDConnectionID, $p_sTableID){// as in jtable.JTabl_JTable_UID
//--------------------------------
  global $gconnJAS;
  $bOk=true;
  $qry='';
  $result='';
  $qresult=null;
  $bLocked=false;
  
  $bLocked=bJAS_LockRecord($p_sJDConnectionID,$p_sTableID,'0'); 
  if($bLocked){  
    // GET the UID we want.
    $qry="SELECT JUID_NextUID from juid WHERE JUID_JTable_ID='".mysql_real_escape_string($p_sTableID)."'";
    $qresult=mysql_query($qry, $gconnJAS);ReportMySQLErrorandStop('200912151558', $gconnJAS, $qry);
    $row=mysql_fetch_array($qresult);// we have our UID for our table :)
    $result=$row['JUID_NextUID'];
    //die("201002131812 - sJAS_GetNextUID test qry:"+$qry);
    
    // increment it for the next guy :)
    $qry="UPDATE juid set JUID_NextUID=JUID_NextUID+1 where JUID_JTable_ID='".mysql_real_escape_string($p_sTableID)."'";
    $qresult=mysql_query($qry, $gconnJAS);ReportMySQLErrorandStop('200912151607', $gconnJAS, $qry);
    if(!bJAS_UnlockRecord($p_sJDConnectionID,$p_sTableID,'0')){ 
      //trigger_error("200912151610 - Unable to unlock record", E_USER_WARNING);
      die('201002131848 - sJAS_GetNextUID unable to UNLOCK juid record for table UID increment.'); 
    };  
  }else{
    die('201002131820 - sJAS_GetNextUID unable to lock juid record for table UID increment.');
  };
  return $result;
};
//--------------------------------



//--------------------------------
// returns juser_juser_uid
function sJASPerson_To_JASUser($p_JPers_JPerson_UID){
//--------------------------------
  global $gconnJAS;
  $result='';
  $qry="select JUser_JUser_UID from juser where JUser_JPerson_ID='" . mysql_real_escape_string($p_JPers_JPerson_UID) . "'";
  $qresult = mysql_query($qry,$gconnJAS); ReportMySQLErrorandStop('200912151350', $gconnJAS, $qry);
  $rowcount=mysql_num_rows($qresult);
  if($rowcount==0){ // Must add the juser record
    $result=sJAS_GetNextUID('0',JAS_juser);
    if($result!=''){
      $qry="insert into juser (JUser_JUser_UID, JUser_Name,JUser_Password,JUser_JPerson_ID,JUser_Enabled,JUser_SystemUser) VALUES (";
      $qry.="'".mysql_real_escape_string($result)."',";
      $qry.="'".mysql_real_escape_string('AUTO_'.generatePassword())."',";
      $qry.="'".mysql_real_escape_string(generatePassword())."',";
      $qry.="'".mysql_real_escape_string($p_JPers_JPerson_UID)."',";
      $qry.="'".mysql_real_escape_string('true')."',";
      $qry.="'".mysql_real_escape_string('false')."')";//end of field list
      $qresult = mysql_query($qry,$gconnJAS); ReportMySQLErrorandStop('200912151639', $gconnJAS, $qry);
    }else{
      ReportErrorandStop('200912152052','sJAS_GetNextUID(\'0\',JAS_juser) returned empty string.');
    };
  }else{
    $row=mysql_fetch_array($qresult);
    $result=$row['JUser_JUser_UID'];
  };
  return $result;  
};
//--------------------------------

//--------------------------------
// used when authentication was previously provided: vTiger Portal Login for example
// or other integrated system: processmaker, joomla, mydbr... whatever.
// TODO: implement solution to allow multiple login sessions from same user.
//       this version doesn't create a new session each time, but recycles 
//       existing connection. 
function bJAS_CreateSession_Authenticated($p_JUser_JUser_UID){
//--------------------------------
  global $gconnJAS;
  global $gsJASUsername;
  global $gsJSID;
  $qry="select JUser_Name from juser where JUser_JUser_UID='" . mysql_real_escape_string($p_JUser_JUser_UID) . "'";
  $qresult = mysql_query($qry,$gconnJAS); ReportMySQLErrorandStop('200912151725', $gconnJAS, $qry);
  $rowcount=mysql_num_rows($qresult);
  if($rowcount>0){
    $row=mysql_fetch_array($qresult);
    $gsJASUsername=$row['JUser_Name'];
    $qry="select JPCon_JPConnection_UID from jpconnection where JPCon_JUser_ID='" . mysql_real_escape_string($p_JUser_JUser_UID) . "'";
    $qresult = mysql_query($qry,$gconnJAS); ReportMySQLErrorandStop('200912152116', $gconnJAS, $qry);
    $JPCon_JPConnection_UID='';
    $rowcount=mysql_num_rows($qresult);
    if($rowcount==0){
      $JPCon_JPConnection_UID=sJAS_GetNextUID('0',JAS_jpconnection);
      $qry="insert into jpconnection (JPCon_JPConnection_UID,JPCon_Connect_DT) VALUES ('" . 
          mysql_real_escape_string($JPCon_JPConnection_UID) . "',now())";
      $qresult = mysql_query($qry,$gconnJAS); ReportMySQLErrorandStop('200912151714', $gconnJAS, $qry);
    }else{
      $row=mysql_fetch_array($qresult);
      $JPCon_JPConnection_UID=$row['JPCon_JPConnection_UID'];
    };
    $qry="update jpconnection set " . 
      "JPCon_JPType_ID=1,".
      "JPCon_JUser_ID='" .mysql_real_escape_string($p_JUser_JUser_UID) . "',".
      "JPCon_LastContact_DT=now(),".
      "JPCon_IP_ADDR='" . mysql_real_escape_string(getenv(REMOTE_ADDR)) . "',".
      "JPCon_Username='" . mysql_real_escape_string($gsJASUsername) ."'".
      " where JPCon_JPConnection_UID='" . mysql_real_escape_string($JPCon_JPConnection_UID) . "'";
    $qresult = mysql_query($qry,$gconnJAS); ReportMySQLErrorandStop('200912151741', $gconnJAS, $qry);
    $gsJSID=$JPCon_JPConnection_UID;
    $_SESSION['JSID']=$gsJSID;  
    return true;
  }else{
    return false;
  };
};
//--------------------------------



//--------------------------------
function JAS_DEBUG( $p_code, $p_message, $p_sourcefile ){
//--------------------------------
  global $gconnJAS;
  $qry="insert into jdebug (JDBug_Code, JDBug_Message) values ( '" . mysql_real_escape_string($p_code) . "', '" . mysql_real_escape_string($p_message) . " Sourcefile: " . mysql_real_escape_string($p_sourcefile) . "' )";
  $qresult = mysql_query($qry,$gconnJAS); ReportMySQLErrorandStop('201007111413', $gconnJAS, $qry);
}
//--------------------------------








// =================================================================  
// END - JAS Database Specific
// =================================================================  






// =================================================================  
// BEGIN - vTiger Specific
// =================================================================  
  
  // Below are a number of functions mostly added to help get data into the CRM.
  // a non API method was chosen for speed of execution. The API adds quite a bit 
  // more code execution that isn't necessary for adding accounts, contacts, leads and just poking
  // around.
  
  //--------------------------------
  Function iVTGetEntityTabID($p_sModuleName){
  //--------------------------------
    global $gVTPrefix;
    global $gconnVT;
    // gets tabid for "module" (entity) from entityname table
    $qry = "select tabid from " . $gVTPrefix . "_entityname where modulename='" . mysql_real_escape_string($p_sModuleName) . "'";
    $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200910210316', $gconnVT, $qry); 
    $rowcount=mysql_num_rows($qresult);
    if($rowcount==1){
      $row=mysql_fetch_array($qresult);
      return $row['tabid'];
    }else{
      return 0;
    };
  }
  //--------------------------------
  
  //--------------------------------
  Function iVTGetNewUniqueEntityID($p_sModuleName){ 
  //--------------------------------
    global $gVTPrefix;
    global $gconnVT;
    // use this is make the initial crmentity record and get a unique id number for say the "Accounts" module
    $iTabID = iVTGetEntityTabID($p_sModuleName);
    if($iTabID > 0){
      $qry = "select id from " . $gVTPrefix . "_crmentity_seq";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200910210319', $gconnVT, $qry);
      //$rowcount=mysql_num_rows($qresult);
      $row=mysql_fetch_array($qresult);
      $iSeq = $row['id'] + 1;
      //die('Tabid:' . $iTabID . 'test: iseq=' . $iSeq . ' row[id]:' . $row['id'] . ' row:' . $row . ' Qry:' . $qry . " err: " . mysql_error($p_rCon) . " rowcount:" . $rowcount);
      
      // If above trick for incrementing seq doesn't work try this (which we did... should add lock table for this maybe for mysql and others maybe too)
      //$iSeq = $iSeq + 1;
      $qry = "update " . $gVTPrefix . "_crmentity_seq set id=" . $iSeq;
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200910210321', $gconnVT, $qry);
      
      $qry = "";
      $qry .= "insert into " . $gVTPrefix . "_crmentity ";
      $qry .= "(crmid, smcreatorid, smownerid, modifiedby, setype, description, createdtime, modifiedtime, viewedtime, status, version, presence, deleted) ";
      $qry .= " values (";
      $qry .= $iSeq . ","; // crmid
      $qry .= '1 , ';      // smcreatorid
      $qry .= '1 ,'; // smownerid
      $qry .= '0 ,'; // modifiedby
      $qry .= "'" . mysql_real_escape_string($p_sModuleName) . "',"; // setype
      $qry .= "'',"; // decription
      $qry .= "now(),"; // createdtime
      $qry .= "now(),"; // modifiedtime
      $qry .= "null,"; // viewedtime
      $qry .= "null,"; // status
      $qry .= "0 ,"; // version
      $qry .= "1 ,"; // presence
      $qry .= "0 "; // deleted
      $qry .= ")";
      $qresult = mysql_query($qry,$gconnVT);ReportMySQLErrorandStop('200910210326', $gconnVT, $qry);
      return $iSeq;
    }else{
      return 0;
    }
  }
  //--------------------------------

  
  //--------------------------------
  Function sVTIncrementModuleSeqNumber($p_ModuleName){
  //--------------------------------
    global $gVTPrefix;
    global $gconnVT;
    $qry="LOCK TABLES " . $gVTPrefix . "_modentity_num WRITE;";
    $qresult = mysql_query($qry,$gconnVT);ReportMySQLErrorandStop('200911021658', $gconnVT, $qry);
    $qry="select prefix, cur_id from " . $gVTPrefix . "_modentity_num where active=1 and semodule='" . mysql_real_escape_string($p_ModuleName) . "'";
    $qresult = mysql_query($qry,$gconnVT);ReportMySQLErrorandStop('200911011659', $gconnVT, $qry);
    $rowcount=mysql_num_rows($qresult);
    if($rowcount==1){
      $row=mysql_fetch_array($qresult);
      $result=$row['prefix'] . $row['cur_id'];
      $qry="update " . $gVTPrefix . "_modentity_num ";
      $qry .= "SET cur_id = cur_id+1 where active=1 and semodule='" . mysql_real_escape_string($p_ModuleName) . "'";
      $qresult = mysql_query($qry,$gconnVT);ReportMySQLErrorandStop('200911021701', $gconnVT, $qry); 
      $qry="UNLOCK TABLES; ";
      $qresult = mysql_query($qry,$gconnVT);ReportMySQLErrorandStop('200911021702', $gconnVT, $qry);
      return $result;
    }else{
      $Message='Unexpected results. Expected one row. got: ' . $rowcount . " - 200911021659";
      if(jegas_debug=='true'){
        $Message .= " Qry: " . $qry;
      };
      // attempt unlock before giving up
      $qry="UNLOCK TABLES; ";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911021700', $gconnVT, $qry);
      die($Message);
    };
  };
  //--------------------------------



  //--------------------------------
  Function iVTAddContact(){
  //--------------------------------
    global $gVTPrefix;
    global $gconnVT;
    $ModuleName="Contacts";
    $contactid=iVTGetNewUniqueEntityID($ModuleName);  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
    if($contactid>0){
      $contact_no=sVTIncrementModuleSeqNumber($ModuleName);
      // Add Contact Record;
      // insert into contact (i think) requires (or it won't show);
      //    insert into _contactaddress;
      //    insert into _contactsubdetails;
      //    insert into _contactscf;
      $qry = "insert into " . $gVTPrefix . "_contactdetails (contactid, contact_no) values (" . $contactid . ",'". mysql_real_escape_string($contact_no) ."')";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200910281230', $gconnVT, $qry); 
      
      $qry = "insert into " . $gVTPrefix . "_contactaddress (contactaddressid) values (" . $contactid . ")";
      $qresult = mysql_query($qry,$gconnVT);ReportMySQLErrorandStop('200910281231', $gconnVT, $qry);
      
      $qry = "insert into " . $gVTPrefix . "_contactsubdetails (contactsubscriptionid) values (" . $contactid . ")";
      $qresult = mysql_query($qry,$gconnVT);ReportMySQLErrorandStop('200910281232', $gconnVT, $qry);
      
      $qry = "insert into " . $gVTPrefix . "_contactscf (contactid) values (" . $contactid . ")";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200910281234', $gconnVT, $qry);
    }
    return $contactid;
  }
  //--------------------------------


  //--------------------------------
  Function bVTUpdateContact($p_Data){
  //--------------------------------
    global $gVTPrefix;
    global $gconnVT;
    // Assumed that at a minimum $p_Data has the contact id as $p_Data['contactid']
    
    //----------- Ok - now for the contactdetails table
    $qry = "";
    $qry .= "update " . $gVTPrefix . "_contactdetails SET ";
    $qry .= " contactid=" . $p_Data['contactid']; // this just makes comma work right
    $field='accountid';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='salutation';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='firstname';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='lastname';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='email';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='phone';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='mobile';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='title';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='department';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='fax';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='reportsto';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='training';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='usertype';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='contacttype';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='otheremail';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='yahooid';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='donotcall';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='emailoptout';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='imagename';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='reference';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='notify_owner';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $qry .= " WHERE contactid=" . $p_Data['contactid'];
    $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200912171155', $gconnVT, $qry); 
    

    $qry = "";
    $qry .= "update " . $gVTPrefix . "_contactaddress SET ";
    $qry .= " contactaddressid=" . $p_Data['contactid']; // this just makes comma work right
    $field='mailingcity';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='mailingstreet';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='mailingcountry';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='othercountry';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='mailingstate';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='mailingpobox';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='othercity';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='otherstate';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='mailingzip';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='otherzip';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='otherstreet';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='otherpobox';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $qry .= " WHERE contactaddressid=" . $p_Data['contactid'];
    $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911021825', $gconnVT, $qry);

    $qry = "";
    $qry .= "update " . $gVTPrefix . "_contactsubdetails SET ";
    $qry .= " contactsubscriptionid=" . $p_Data['contactid']; // this just makes comma work right
    $field='homephone';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='otherphone';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='assistant';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='assistantphone';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='birthday';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='laststayintouchrequest';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='laststayintouchsavedate';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='leadsource';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $qry .= " WHERE contactsubscriptionid=" . $p_Data['contactid'];
    $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200912021826', $gconnVT, $qry); 
  };
  //--------------------------------


  //--------------------------------
  Function iVTAddLead(){
  //--------------------------------
    global $gVTPrefix;
    global $gconnVT;
    $ModuleName="Leads";
    $leadid=iVTGetNewUniqueEntityID($ModuleName);  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
    if($leadid>0){
      $lead_no=sVTIncrementModuleSeqNumber($ModuleName);
      // Add lead Record;
      // insert into lead (i think) requires (or it won't show);
      //    insert into _leadaddress;
      //    insert into _leadsubdetails;
      //    insert into _leadscf;
      $qry = "insert into " . $gVTPrefix . "_leaddetails (leadid, lead_no) values (" . $leadid . ",'". mysql_real_escape_string($lead_no) ."')";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911021835', $gconnVT, $qry);
      
      $qry = "insert into " . $gVTPrefix . "_leadsubdetails (leadsubscriptionid) values (" . $leadid . ")";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911021839', $gconnVT, $qry); 

      $qry = "insert into " . $gVTPrefix . "_leadaddress (leadaddressid) values (" . $leadid . ")";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911021836', $gconnVT, $qry);
      
      $qry = "insert into " . $gVTPrefix . "_leadscf (leadid) values (" . $leadid . ")";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911021838', $gconnVT, $qry); 
    }
    return $leadid;
  }
  //--------------------------------



  //--------------------------------
  Function bVTUpdateLead($p_Data){
  //--------------------------------
    global $gVTPrefix;
    global $gconnVT;
    // Assumed that at a minimum $p_Data has the lead id as $p_Data['leadid']
    // Note Leads has a unique address table and requires a second update if 
    // you want to enter a non-billing address. Be sure to set the 'leadaddresstype'
    // correctly.
    
    //----------- Ok - now for the leaddetails table
    $qry = "";
    $qry .= "update " . $gVTPrefix . "_leaddetails SET ";
    $qry .= " leadid=" . $p_Data['leadid']; // this just makes comma work right
    $field='email';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='interest';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='firstname';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='salutation';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='lastname';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='company';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='annualrevenue';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='industry';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='campaign';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='rating';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='leadstatus';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='leadsource';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='converted';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='designation';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='licencekeystatus';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='space';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='comments';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='priority';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='demorequest';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='partnercontact';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='productversion';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='product';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='maildate';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='nextstepdate';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='fundingsituation';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='purpose';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='evaluationstatus';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='transferdate';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='revenuetype';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='noofemployees';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='yahooid';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='assignleadchk';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $qry .= " WHERE leadid=" . $p_Data['leadid'];
    $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911021824', $gconnVT, $qry);
    
    $qry = "";
    $qry .= "update " . $gVTPrefix . "_leadaddress SET ";
    $qry .= " leadaddressid=" . $p_Data['leadid']; // this just makes comma work right
    $field='city';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='code';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='state';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='pobox';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='country';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='phone';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='mobile';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='fax';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='lane';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='leadaddresstype';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $qry .= " WHERE leadaddressid=" . $p_Data['leadid'];
    $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911021825', $gconnVT, $qry);

    $qry = "";
    $qry .= "update " . $gVTPrefix . "_leadsubdetails SET ";
    $qry .= " leadsubscriptionid=" . $p_Data['leadid']; // this just makes comma work right
    $field='website';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='callornot';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='readornot';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='empct';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $qry .= " WHERE leadsubscriptionid=" . $p_Data['leadid'];
    $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911021826', $gconnVT, $qry);
    
    //$qry .= " WHERE leadid=" . $p_Data['leadid'];
    //$qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200910281233', $gconnVT, $qry);
    return true;
  };
  //--------------------------------




  //--------------------------------
  Function iVTAddAccount(){
  //--------------------------------
    global $gVTPrefix;
    global $gconnVT;
    $ModuleName="Accounts";
    $accountid=iVTGetNewUniqueEntityID($ModuleName);  // inserts into _crmentity for us and handles the SEQ ID table/id next row value;
    if($accountid>0){
      $account_no=sVTIncrementModuleSeqNumber($ModuleName);

      $qry = "insert into " . $gVTPrefix . "_account (accountid, account_no) values (" . $accountid . ",'". mysql_real_escape_string($account_no) ."')";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911030013', $gconnVT, $qry);
      
      $qry = "insert into " . $gVTPrefix . "_accountbillads (accountaddressid) values (" . $accountid . ")";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911030014', $gconnVT, $qry); 

      $qry = "insert into " . $gVTPrefix . "_accountshipads (accountaddressid) values (" . $accountid . ")";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911030015', $gconnVT, $qry);
      
      $qry = "insert into " . $gVTPrefix . "_accountscf (accountid) values (" . $accountid . ")";
      $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911030016', $gconnVT, $qry); 
    }
    return $accountid;
  }
  //--------------------------------



  //--------------------------------
  Function bVTUpdateAccount($p_Data){
  //--------------------------------
    global $gVTPrefix;
    global $gconnVT;
    // Assumed that at a minimum $p_Data has the account id as $p_Data['accountid']
    // Note Account entity has TWO unique address tables
    //----------- Ok - now for the account table
    $qry = "";
    $qry .= "update " . $gVTPrefix . "_account SET ";
    $qry .= " accountid=" . $p_Data['accountid']; // this just makes comma work right
    $field='accountname';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='parentid';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='account_type';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='industry';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='annualrevenue';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='rating';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='ownership';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='siccode';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='tickersymbol';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='phone';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='otherphone';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='email1';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='email2';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='website';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='fax';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='employees';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='emailoptout';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='notify_owner';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $qry .= " WHERE accountid=" . $p_Data['accountid'];
    $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911030017', $gconnVT, $qry);
    
    $qry = "";
    $qry .= "update " . $gVTPrefix . "_accountbillads SET ";
    $qry .= " accountaddressid=" . $p_Data['accountid']; // this just makes comma work right
    $field='bill_city';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='bill_code';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='bill_country';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='bill_state';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='bill_street';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='bill_pobox';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $qry .= " WHERE accountaddressid=" . $p_Data['accountid'];
    $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911030018', $gconnVT, $qry);

    $qry = "";
    $qry .= "update " . $gVTPrefix . "_accountshipads SET ";
    $qry .= " accountaddressid=" . $p_Data['accountid']; // this just makes comma work right
    $field='ship_city';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='ship_code';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='ship_country';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='ship_state';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='ship_pobox';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $field='ship_street';if(isset($p_Data[$field])){ $qry .= ", ". $field . " = "; if(is_null($p_Data[$field])){ $qry .= "null"; } else { $qry.="'" . mysql_real_escape_string($p_Data[$field]) . "'"; }};
    $qry .= " WHERE accountaddressid=" . $p_Data['accountid'];
    $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200911030019', $gconnVT, $qry);

    return true;
  };
  //--------------------------------
// =================================================================  
// END - vTiger Specific
// =================================================================  







// =================================================================  
// BEGIN - vTiger + JAS Integration Specific
// =================================================================  
//--------------------------------
// returns new JAS JPers_JPerson_UID value if successful.
// This is not one of those functions I really want to write twice... 
// but I'll make a go of it anyways .. here goes... B^) -- Jason  
//  
function svTigerContact_To_JASPerson($p_vTigerContactID){// number but treated as string
//--------------------------------
  global $gconnVT;// vtiger MYSQL connection
  global $gconnJAS; // JAS Mysql connection
  global $gVTPrefix;
  global $DBCON;
  
  $JPers_JPerson_UID='';
  $qry=   "select * from " . $gVTPrefix . "_contactdetails ";
  $qry .= " inner join vtiger_crmentity on contactid=crmid ";
  $qry .= " where contactid='" . mysql_real_escape_string($p_vTigerContactID) . "'";    
  $qry .= " and (deleted <> 1)";
  $qresult = mysql_query($qry,$gconnVT); ReportMySQLErrorandStop('200912151804', $gconnVT, $qry);
  if(mysql_num_rows($qresult)>0){
    // ok we got one or more records - should be one... so let's grab the first record info :)
    $row=mysql_fetch_array($qresult);
    
    // Ok - let's do a minimal dedupe search in jperson - using the new JPers_vTiger_Contact_ID field
    $qry="select JPers_JPerson_UID from jperson where JPers_vTiger_Contact_ID='".mysql_real_escape_string($p_vTigerContactID)."'";
    $qresult = mysql_query($qry,$gconnJAS); ReportMySQLErrorandStop('200912151804', $gconnJAS, $qry);
    if(mysql_num_rows($qresult)>0){
      // this JAS JPerson record already exists - so get the UID
      $rowJPerson=mysql_fetch_array($qresult);
      $JPers_JPerson_UID=$rowJPerson['JPers_JPerson_UID'];
    }else{
      //echo "201010121254: svTigerContact_To_JASPerson getnextuid \n";
      $JPers_JPerson_UID=sJAS_GetNextUID('0',JAS_jperson);
      $qry="insert into jperson (JPers_JPerson_UID) values ('".mysql_real_escape_string($JPers_JPerson_UID)."')";
      $qresult = mysql_query($qry,$gconnJAS); ReportMySQLErrorandStop('200912151804', $gconnJAS, $qry);
    };
    if($JPers_JPerson_UID>''){
      // we have a record to work with and the contact data - So let's begin the data thunking
      //qqq
      //echo "201010121253: svTigerContact_To_JASPerson lockrecord \n";
      if(bJAS_LockRecord($DBCON['JAS']['ID'],JAS_jperson, $JPers_JPerson_UID)){
        $qry="update jperson set ";
        $name='';
        if(strlen($row['firstname'])>0){$name=$row['firstname'];$qry.="JPers_NameFirst='" . mysql_real_escape_string($row['firstname']) . "',";};
        if(strlen($row['lastname'])>0){if(strlen($name)>0){$name.=" ";};$name.=$row['lastname'];$qry.="JPers_NameLast='" . mysql_real_escape_string($row['lastname']) . "',";};
        if(strlen($name)>0){$qry.="JPers_Name='" . mysql_real_escape_string($name) . "',";}; 
        if(strlen($row['salutation'])>0){$qry.="JPers_NameSalutation='" . mysql_real_escape_string($row['salutation']) . "',";};
        // TODO: implement these and other contact fields - such as addresses from vtiger etc.
        // JPers_Primary_Company_ID
        // JPers_Primary_Address_ID
        // JPers_Primary_WorkAddress_ID
        // JPers_Primary_Phone_ID
        // JPers_Primary_Email_ID
        // JPers_Primary_Web_ID
        // JPers_Primary_Mobile_ID
        // JPers_Primary_Pager_ID
        $qry.="JPers_vTiger_Contact_ID='" . mysql_real_escape_string($p_vTigerContactID) . "'";
        $qry.=" where JPers_JPerson_UID='" . mysql_real_escape_string($JPers_JPerson_UID)."'"; 
        $qresult = mysql_query($qry,$gconnJAS); ReportMySQLErrorandStop('200912151926', $gconnJAS, $qry);
        
        // TODO: Insert more code for more complete "migration"
        
        // When All done - release all locks - we only have one ATM .. but this code will grow I'm sure.
        if(!bJAS_UnLockRecord($DBCON['JAS']['ID'],JAS_jperson, $JPers_JPerson_UID)){ trigger_error("200912151928 - Unable to unlock record", E_USER_WARNING); };
        return $JPers_JPerson_UID;
      };
    };    
  }else{
    return '';//nothing we can do - it doesnt exist
  };      
};
//--------------------------------

// =================================================================  
// END - vTiger + JAS Integration Specific
// =================================================================  

// =================================================================  
// BEGIN - VICI + JAS Integration Specific
// =================================================================

//// adds VICI Users to JAS Users if they do not already exist in JAS
//function bVICIUsers_To_JASUsers(){
////--------------------------------
//  global $gconnJAS;
//  global $gconnVICI;
//  $qryVICI="select * from vicidial_users";
//  $qresultVICI = mysql_query($qryVICI,$gconnVICI); ReportMySQLErrorandStop('201002102227', $gconnVICI, $qry);
//  while ($rowVICI=mysql_fetch_array($qresultVICI)){
//    $qryJAS="SELECT * FROM juser WHERE JUSER_Name='".$rowVICI["user"]."'";
////    echo($qryJAS . '<br />');
//    $qresultJAS=mysql_query($qryJAS,$gconnJAS);  ReportMySQLErrorandStop('201002110014', $gconnJAS, $qryJAS);
//    if (!mysql_num_rows($qresultJAS)){
//      $result=sJAS_GetNextUID('0',JAS_juser);
//      $qryJAS="INSERT INTO juser (JUser_JUser_UID) VALUES('".mysql_real_escape_string($result)."')";
//      echo($qryJAS . '<br />');
//      mysql_query($qryJAS,$gconnJAS);  ReportMySQLErrorandStop('201002110230', $gconnJAS, $qryJAS);
//      if(bJAS_LockRecord(JAS_juser,mysql_real_escape_string($result))){
//        $qryJAS="UPDATE juser SET JUser_Name='".$rowVICI["user"]."', ";
//        $qryJAS.="JUser_Password='".$rowVICI["pass"]."', ";
//        $qryJAS.="JUser_VICI_User_ID='".$rowVICI["user_id"]."' ";
//        // $gryJAS.="JUser_????='".$rowVICI["user_group"]."' ";
//        $qryJAS.="WHERE JUser_JUser_UID='".mysql_real_escape_string($result)."'";
//        echo($qryJAS . '<br />');
//        mysql_query($qryJAS,$gconnJAS);  ReportMySQLErrorandStop('201002110218', $gconnJAS, $qryJAS);
//        bJAS_UnlockRecord(JAS_juser,mysql_real_escape_string($result));
//      }else{
//        die('201002131839 - Unable to lock juser table record.');
//      };
//    }
//  }
//};
////--------------------------------

//// adds VICI Users to JAS Users if they do not already exist in JAS
//// this routine is design to be used once to bring vici users into a clean jas
//// system; i.e., all vici user and groups deleted from jas and added as a result of this routine.
//function bVICIUsers_To_JASUsers(){
////--------------------------------
//  global $gconnJAS;
//  global $gconnVICI;
//  // read in all vici user records
//  $qryVICI="select * from vicidial_users";
//  $qresultVICIUsers = mysql_query($qryVICIUsers,$gconnVICI); ReportMySQLErrorandStop('201002171452', $gconnVICI, $qryVICIUsers);
//  // for each of the vici users
//  
//  while ($rowVICIUser=mysql_fetch_array($qresultVICIUser)){
//    //see if the user is already in jas
//    $qryJAS="SELECT * FROM juser WHERE JUSER_Name='".$rowVICIUser["user"]."'";
//    $qresultJAS=mysql_query($qryJA,$gconnJAS);  ReportMySQLErrorandStop('201002171453', $gconnJAS, $qryJAS);
//    //  if user already exists in jas
//
//    if (mysql_num_rows($qresultJAS)>0){
//        //then set vici record = jas user and group data
//        //  get the jas user row
//        $rowJASUser=mysql_fetch_array(qresultJASUser);
//        //  try to get the jas jperson record for this juser
//        $qryJASPerson="select * from jperson WHERE JPers_JPerson_UID='".$rowJASUser['JUser_JPerson_ID']."'";
//        $qresultJASPerson=mysql_query($qryJASPerson,$gconnJAS); ReportMySQLErrorandStop('201002181143', $gconnJAS, $qryJASPerson);
//
//        //  if there is not a jperson 
//        if (mysql_num_rows($qresultJASPerson)==0){
//            //  construct first and last name for the record from vici user file if possible
//            $name = explode(" ",$rowVICIUser['full_name']);
//                if ($name[0]==""){
//                    $firstName="NoFirstName";
//                    $lastName="NoLastName";
//                }elseif($name[1]==""){
//                    $firstName=$name[0];
//                    $lastName="NoLastName";
//                }else{
//                    $firstName=$name[0];
//                    $lastName=$name[1]; 
//                }               
//            //  create a jperson record
//            $result=sJAS_GetNextUID('0',JAS_jperson);
//            $qryJASPerson1="INSERT jperson ("
//                    ."JPers_Jperson_UID,"
//                    ."JPers_Name,"
//                    ."JPers_First,"
//                    ."JPers_Last) "
//                ."VALUES('"
//                    .mysql_real_escape_string($result)."', '"
//                    .$rowVici['full_name']."' '"
//                    .$firstName."', '"
//                    .$lastName."')";
//            $qresultJASPerson1=mysql_query($qryJASPerson1,$gconnJAS); ReportMySQLErrorandStop('201002182041', $gconnJAS, $qryJASPerson1);
//            // and relate the new jperson record to the juser record
//            $qryJASUser1="UPDATE juser SET JUser_JPerson_ID='".mysql_real_escape_string($result)."' WHERE JUser_JUser_ID='".$rowJASUser['JUser_JUser_ID']."'";
//            $qresultJASUser1=mysql_query($qryJASUser1,$gconnJAS); ReportMySQLErrorandStop('201002182106', $gconnJAS, $qryJASUser1);
//
//            // update the vicidial_user record with jas data
//            $gryVIVIUser1="UPDATE vicidial_users SET"
//            ."user='".$rowJASUser['JUser_VICI_Name']."',"
//            ."pass='".$rowJASUser['JUser_Password']."',"
//            ."full_name='".$firstName." ".$lastName."'";
//            $qresultVICIUser1=mysql_query($qryVICIUser1,$gconnVICI); ReportMySQLErrorandStop('201002182106', $gconnVICI, $qryVICIUser1);
//          
//        }
//    }else{
//            echo "
//            
//            
//            //gotsta cover the group thing here
//            
//            
//            
//            
//            
//            
//            
//        //else create new user record in jas
//            //if the vici user's group is NOT in jas
//                //then create a new group in jas
//            //link the new jas user to the vici group in jas
//    
//      $result=sJAS_GetNextUID('0',JAS_juser);
//      $qryJAS="INSERT INTO juser (JUser_JUser_UID) VALUES('".mysql_real_escape_string($result)."')";
//      mysql_query($qryJAS,$gconnJAS);  ReportMySQLErrorandStop('201002171454', $gconnJAS, $qryJAS);
//      if(bJAS_LockRecord(JAS_juser,mysql_real_escape_string($result))){
//        $qryJAS="UPDATE juser SET JUser_Name='".$rowVICI["user"]."', ";
//        $qryJAS.="JUser_Password='".$rowVICI["pass"]."', ";
//        $qryJAS.="JUser_VICI_User_ID='".$rowVICI["user_id"]."' ";
//        // $gryJAS.="JUser_????='".$rowVICI["user_group"]."' ";
//        $qryJAS.="WHERE JUser_JUser_UID='".mysql_real_escape_string($result)."'";
//        echo($qryJAS . '<br />');
//        mysql_query($qryJAS,$gconnJAS);  ReportMySQLErrorandStop('201002171455', $gconnJAS, $qryJAS);
//        bJAS_UnlockRecord(JAS_juser,mysql_real_escape_string($result));
//      }else{
//        die('201002131839 - Unable to lock juser table record.');
//      };
//    }
//  }
//};
////--------------------------------

//// adds VICI Users to JAS Users if they do not already exist in JAS
//function bVICIUsers_To_JASUsers(){
////--------------------------------
//  global $gconnJAS;
//  global $gconnVICI;
//  $qryVICI="select * from vicidial_users";
//  $qresultVICI = mysql_query($qryVICI,$gconnVICI); ReportMySQLErrorandStop('201002102227', $gconnVICI, $qry);
//  while ($rowVICI=mysql_fetch_array($qresultVICI)){
//    $qryJAS="SELECT * FROM juser WHERE JUSER_Name='".$rowVICI["user"]."'";
////    echo($qryJAS . '<br />');
//    $qresultJAS=mysql_query($qryJAS,$gconnJAS);  ReportMySQLErrorandStop('201002110014', $gconnJAS, $qryJAS);
//    if (!mysql_num_rows($qresultJAS)){
//      $result=sJAS_GetNextUID('0',JAS_juser);
//      $qryJAS="INSERT INTO juser (JUser_JUser_UID) VALUES('".mysql_real_escape_string($result)."')";
//      echo($qryJAS . '<br />');
//      mysql_query($qryJAS,$gconnJAS);  ReportMySQLErrorandStop('201002110230', $gconnJAS, $qryJAS);
//      if(bJAS_LockRecord('0',JAS_juser,mysql_real_escape_string($result))){
//        $qryJAS="UPDATE juser SET JUser_Name='".$rowVICI["user"]."', ";
//        $qryJAS.="JUser_Password='".$rowVICI["pass"]."', ";
//        $qryJAS.="JUser_VICI_User_ID='".$rowVICI["user_id"]."' ";
//        // $gryJAS.="JUser_????='".$rowVICI["user_group"]."' ";
//        $qryJAS.="WHERE JUser_JUser_UID='".mysql_real_escape_string($result)."'";
//        echo($qryJAS . '<br />');
//        mysql_query($qryJAS,$gconnJAS);  ReportMySQLErrorandStop('201002110218', $gconnJAS, $qryJAS);
//        bJAS_UnlockRecord('0',JAS_juser,mysql_real_escape_string($result));
//      }else{
//        die('201002131839 - Unable to lock juser table record.');
//      };
//    }
//  }
//};
////--------------------------------

// adds VICI Users to JAS Users if they do not already exist in JAS
// this routine is design to be used once to bring vici users into a clean jas
// system; i.e., all vici user and groups deleted from jas and added as a result of this routine.
function bVICIUsers_To_JASUsers($p_sVICI, $p_sJAS){
//--------------------------------
try{
  global $DBCON;
  global $JADOC;
  JADOC_CONNECT('VICI');
  
  $VICI=$JADOC[$p_sVICI];
  $VICIID=$DBCON[$p_sVICI]['ID'];
  
  $JAS=$JADOC[$p_sJAS];
  $JASID=$DBCON[$p_sJAS]['ID'];
  
  // read in all vici user records
  $qryVICI="select * from vicidial_users";
  $qresultVICIUsers = mysql_query($qryVICI,$VICI); ReportMySQLErrorandStop('201002171452', $VICI, $qryVICI);
  // for each of the vici users
  while ($rowVICIUser=mysql_fetch_array($qresultVICIUsers)){  
  
    // is user in jas?
    $qryJAS="SELECT * FROM juser WHERE JUSER_Name='".$rowVICIUser["user"]."'";
    $qresultJAS=mysql_query($qryJAS,$JAS);  ReportMySQLErrorandStop('201002171453', $JAS, $qryJAS);
    $rowJASUser=mysql_fetch_array($qresultJAS);
    if (mysql_num_rows($qresultJAS)>0){// yes, user exists in jas
        //echo "found a juser in jas with username = ".$rowJASUser['JUser_Name']."<br>";
       //  try to get the jas jperson record for this juser
        $qryJASPerson="select * from jperson WHERE JPers_JPerson_UID='".$rowJASUser['JUser_JPerson_ID']."'";
        $qresultJASPerson=mysql_query($qryJASPerson,$JAS); ReportMySQLErrorandStop('201002181143', $JAS, $qryJASPerson);
        $rowJASPerson=mysql_fetch_array($qresultJASPerson);
        // does jperson exist for this juser?
        if (mysql_num_rows($qresultJASPerson)==0){// no, jperson does not exist for this user
            //echo "    no jperson exists for this juser<br>";
            // build jperson record with vici user data
            //  construct first and last name for the record from vici user file if possible
            $name = explode(" ",$rowVICIUser['full_name']);
            $jPersonUID=sJAS_GetNextUID($JASID,JAS_jperson);
            if ($name[0]==""){
                $firstName="FN_".$jPersonUID;
                $lastName="LN_".$jPersonUID;
            }elseif($name[1]==""){
                $firstName=$name[0];
                $lastName="LN_".$jPersonUID;
            }else{
                $firstName=$name[0];
                $lastName=$name[1]; 
            }               
            //  create a jperson record UID
            
            $qryJASPerson1="INSERT jperson ("
                    ."JPers_Jperson_UID,"
                    ."JPers_Name,"
                    ."JPers_NameFirst,"
                    ."JPers_NameLast) "
                ."VALUES('"
                    .mysql_real_escape_string($jPersonUID)."', '"
                    .$firstName." ".$lastName."', '"
                    .$firstName."', '"
                    .$lastName."')";
            $qresultJASPerson1=mysql_query($qryJASPerson1,$JAS); ReportMySQLErrorandStop('201002182041', $JAS, $qryJASPerson1);
            // and relate the new jperson record to the juser record
            $qryJASUser1="UPDATE juser SET JUser_JPerson_ID='".mysql_real_escape_string($jPersonUID)."' WHERE JUser_JUser_UID='".$rowJASUser['JUser_JUser_UID']."'";
            $qresultJASUser1=mysql_query($qryJASUser1,$JAS); ReportMySQLErrorandStop('201002182106', $JAS, $qryJASUser1);
        }else{// yes, jperson exists for this user
            //save first and last name data for later vici user update
            $firstName=$rowJASPerson['JPers_NameFirst'];
            $lastName=$rowJASPerson['JPers_NameLast'];
            //echo "   yes, a jperson exists for this user first=  ".$firstName." last = ".$lastName."<br>";
        }        

        // is there a link to a group record that matches the vici group?
        $qryJASGrpLnk="SELECT lnk.JSGUL_JSecGrp_ID, lnk.JSGUL_JUser_ID, grp.JSGrp_JSecGrp_UID, grp.JSGrp_Name FROM jsecgrpuserlink AS lnk, jsecgrp AS grp WHERE ";
        $qryJASGrpLnk.="lnk.JSGUL_JSecGrp_ID=grp.JSGrp_JSecGrp_UID AND lnk.JSGUL_JUser_ID='".$rowJASUser['JUser_JUser_UID']."' AND ";
        $qryJASGrpLnk.="grp.JSGrp_Name='".$rowVICIUser['user_group']."'";
        $qryresultJASGrpLnk=mysql_query($qryJASGrpLnk,$JAS); ReportMySQLErrorandStop('201002181713', $JAS, $qryJASGrpLnk);
        if (mysql_num_rows($qryresultJASGrpLnk)==0){ // no, there is no link to group record that matches the vici group
            // does a group record exist for this vici group?
            $qryJASGrp="SELECT * FROM jsecgrp WHERE JSGrp_Name='".$rowVICIUser['user_group']."'";
            $gryresultJASGrp=mysql_query($qryJASGrp,$JAS); ReportMySQLErrorandStop('201002181748', $JAS, $qryJASGrp);
            if (mysql_num_rows($gryresultJASGrp)==0){// no group record
                // create the group record
                //echo "no group record<br><br>";
                $jGrpUID=sJAS_GetNextUID($JASID,JAS_jsecgrp);
                $qryJASGrp="INSERT INTO jsecgrp (JSGrp_JSecGrp_UID, JSGrp_Name) VALUES ('".$jGrpUID."', '".$rowVICIUser['user_group']."')";
                $gryresultJASGrp=mysql_query($qryJASGrp,$JAS); ReportMySQLErrorandStop('201002181758', $JAS, $qryJASGrp);
            }else{
                // get the UID of the existing group table
                $rowGrpUID=mysql_fetch_array($gryresultJASGrp);
                $jGrpUID=$rowGrpUID['JSGrp_JSecGrp_UID'];
            }       
            // link group to juser
            $jGrpLnkUID=sJAS_GetNextUID($JASID,JAS_jsecgrpuserlink);
            $qryJASGrpLnk="INSERT INTO jsecgrpuserlink (JSGUL_JSecGrp_ID, JSGUL_JUser_ID, JSGUL_JSecGrpUserLink_UID) VALUES ('";
            $qryJASGrpLnk.=$jGrpUID."', '".$rowJASUser['JUser_JUser_UID']."', '".$jGrpLnkUID."')";
            $gryresultJASGrpLnk=mysql_query($qryJASGrpLnk,$JAS); ReportMySQLErrorandStop('201002181758', $JAS, $qryJASGrpLnk);
        }        
        // update vici user data with data collected above
        // TODO: after Mike McCuen gives us the go aheads
    }else{        
        // no - juser does not exist in jas
        //echo "did not find a juser in jas<br>";
        // does a jperson record exist for this name?
        $qryJASPerson="SELECT JPers_JPerson_UID FROM jperson WHERE JPers_Name='".$rowVICIUser['full_name']."'";
        $gryresultJASPerson=mysql_query($qryJASPerson,$JAS); ReportMySQLErrorandStop('201002181901', $JAS, $qryJASPerson);
        $rowJASPerson=mysql_fetch_array($gryresultJASPerson);
        if (mysql_num_rows($gryresultJASPerson)==0){    // no
            // create it
            $jPersonUID=sJAS_GetNextUID($JASID,JAS_jperson); 
            $name = explode(" ",$rowVICIUser['full_name']);
            if ($name[0]==""){
                $firstName="FN_".$jPersonUID;
                $lastName="LN_".$jPersonUID;
            }elseif($name[1]==""){
                $firstName=$name[0];
                $lastName="LN_".$jPersonUID;
            }else{
                $firstName=$name[0];
                $lastName=$name[1]; 
            }               
            //  create a jperson record UID
            $qryJASPerson1="INSERT jperson ("
                    ."JPers_Jperson_UID,"
                    ."JPers_Name,"
                    ."JPers_NameFirst,"
                    ."JPers_NameLast) "
                ."VALUES('"
                    .mysql_real_escape_string($jPersonUID)."', '"
                    .$firstName." ".$lastName."', '"
                    .$firstName."', '"
                    .$lastName."')";
            $qresultJASPerson1=mysql_query($qryJASPerson1,$JAS); ReportMySQLErrorandStop('201002182041', $JAS, $qryJASPerson1);
        }else{
            // yes - there is a jperson record already
            // record it's UID
            $jPersonUID=$rowJASPerson['user_id'];
         }       
        // is there a jsecgrp for this vici group name?
            // does a group record exist for this vici group?
            $qryJASGrp="SELECT * FROM jsecgrp WHERE JSGrp_Name='".$rowVICIUser['user_group']."'";
            $gryresultJASGrp=mysql_query($qryJASGrp,$JAS); ReportMySQLErrorandStop('201002181748', $JAS, $qryJASGrp);
            if (mysql_num_rows($gryresultJASGrp)==0){// no group record
                // create the group record
                echo "no group record<br><br>";
                $jGrpUID=sJAS_GetNextUID($JASID,JAS_jsecgrp);
                $qryJASGrp="INSERT INTO jsecgrp (JSGrp_JSecGrp_UID, JSGrp_Name) VALUES ('".$jGrpUID."', '".$rowVICIUser['user_group']."')";
                $gryresultJASGrp=mysql_query($qryJASGrp,$JAS); ReportMySQLErrorandStop('201002181758', $JAS, $qryJASGrp);
            }else{
                // get the UID of the existing group table
                $rowGrpUID=mysql_fetch_array($gryresultJASGrp);
                $jGrpUID=$rowGrpUID['JSGrp_JSecGrp_UID'];
            }       
                
        // create juser
        $result=sJAS_GetNextUID($JASID,JAS_juser);
        $qryJAS="INSERT INTO juser (JUser_JUser_UID, JUser_Name, JUser_Password, JUser_VICI_User_ID, JUser_JPerson_ID) VALUES('";
        $qryJAS.=mysql_real_escape_string($result)."', '";
        $qryJAS.=$rowVICIUser['user']."', '";
        $qryJAS.=$rowVICIUser['pass']."', '";
        $qryJAS.=$rowVICIUser['user_id']."', '";
        $qryJAS.=$jPersonUID."')";
        //echo "$qryJAS<br>";
        mysql_query($qryJAS,$JAS);  ReportMySQLErrorandStop('201002182006', $JAS, $qryJAS);
        // create jsecgrp - juser link in jsecgrplink
        $jGrpLnkUID=sJAS_GetNextUID($JASID,JAS_jsecgrpuserlink);
        $qryJASGrpLnk="INSERT INTO jsecgrpuserlink (JSGUL_JSecGrp_ID, JSGUL_JUser_ID, JSGUL_JSecGrpUserLink_UID) VALUES ('";
        $qryJASGrpLnk.=$jGrpUID."', '".$result."', '".$jGrpLnkUID."')";
        $gryresultJASGrpLnk=mysql_query($qryJASGrpLnk,$JAS); ReportMySQLErrorandStop('201002181758', $JAS, $qryJASGrpLnk);
    }    
  }          
  }catch(Exception $e){
    die("error in bVICIUsers_To_JASUsers 201002191049 " . $e);
  }
}
//--------------------------------






//// this is a one time use function to load the vicidial_user_groups
//// table with user_group's gleaned from the vicidial_users records 
//function findViciGroups(){
////--------------------------------
//  global $gconnJAS;
//  global $gconnVICI;
//  $qryVICI="select user_group from vicidial_users GROUP BY user_group";
//  $qresultVICI = mysql_query($qryVICI,$gconnVICI); ReportMySQLErrorandStop('201002102227', $gconnVICI, $qry);
//  while ($rowVICI=mysql_fetch_array($qresultVICI)){
//    if ($rowVICI['user_group']!='ADMIN'){
//        $qryVICI_1="INSERT INTO vicidial_user_groups (
//                user_group, 
//                group_name, 
//                allowed_campaigns, 
//                forced_timeclock_login, 
//                shift_enforcement, 
//                agent_status_viewable_groups,
//                agent_status_view_time) 
//            VALUES('"
//                .$rowVICI['user_group']."', "
//                ."'VICIDIAL ".$rowVICI['user_group']."', "
//                ."'-ALL-CAMPAIGNS---', "
//                ."'N' , "
//                ."'OFF', "
//                ."'--ALL-GROUPS--', "
//                ."'N')";
//        $qresultVICI_1=mysql_query($qryVICI_1,$gconnVICI); ReportMySQLErrorandStop('201002102227', $gconnVICI, $qryVICI_1 );
//    }
//  }
//};
////--------------------------------

// =================================================================  
// END - VICI + JAS Integration Specific
// =================================================================  


// =================================================================  
// BEGIN - PMOS + JAS Integration Specific
// =================================================================

// the following group of functions perform the suite of PMOS
// Web Service calls
    $sessionId=null; // set in wsLogin and used by other web service functions
    $client=null;   // set in wsLogin and used by other web service functions
    $endpoint=WS_WSDL_URL;

    // Set up PMOS Web Service Calls
    ini_set("soap.wsdl_cache_enabled", "0"); // enabling WSDL cache

    
    // PMOS SOAP login web service function
    function jas_wsLogin(){ 
    //--------------------------------
      try{
        global $sessionId;
        global $client;
        global $endpoint;
        $client = new SoapClient($endpoint); // defined in config.jas.php
        // login to admin/admin
        $pass = 'md5:' . md5('admin');
        $params = array(array('userid'=>'admin', 'password'=>$pass));
        $result =$client->__SoapCall('login', $params);
        if ($result->status_code == 0){ 
        $sessionId=$result->message;
        }else{
            die("Unable to connect to ProcessMaker."."Error Number: ".$result->status_code.
                "Error Message: ".$result->message);
        }       
      }catch(Exception $e){
        die("error in wsLogin 201002141853 " . $e);
      }
    }

    // PMOS SOAP userList web service function
    // returns an array of users with username and guid
    function aWSUserList(){
    //--------------------------------
      try{
        global $sessionId;
        global $client;
        $params = array(array('sessionId'=>$sessionId));
        $result = $client->__SoapCall('userList', $params);
        $usersArray = $result->users;
        if (is_array($usersArray))
            return $usersArray;
        else 
            print "Error in aWSUserList: $usersArray->name <br>";
        }catch(Exception $e){
        die("error in aWSUserList 201002141929a " . $e);
      }
    }
    //--------------------------------
    
    //--------------------------------
    // PMOS SOAP groupList web service function
    // returns an array of groups with groupname and guid
    function aWSGroupList(){
    //--------------------------------
      try{
        global $sessionId;
        global $client;
        $params = array(array('sessionId'=>$sessionId));
        $result = $client->__SoapCall('groupList', $params);
        $groupsArray = $result->groups;
        if (is_array($groupsArray))
            return $groupsArray;
        else 
             print "Error in aWSGroupList: $groupsArray->name <br>";
        }catch(Exception $e){
        die("error in aWSGroupList 201002142014 " . $e);
      }
    }
    //--------------------------------
    
    // PMOS SOAP roleList web service function
    // returns an array of groups with groupname and guid
    function aWSRoleList(){
    //--------------------------------
      try{
        global $sessionId;
        global $client;
        $params = array(array('sessionId'=>$sessionId));
        $result = $client->__SoapCall('roleList', $params);
        $rolesArray = $result->roles;
        if (is_array($rolesArray))
            return $rolesArray;
        else 
             print "Error in aWSRoleList: $rolesArray->name <br>";
        }catch(Exception $e){
        die("error in aWSRoleList 201002150934 " . $e);
      }
    }
    //--------------------------------
    
    // PMOS SOAP createUser web service function
    // returns an array 
    // array->status_code
    // array->message    
    // array->userUID note: this is what documentation says, but doesn't seem to work
    // array->timestamp
    //
    // status_code/message combinations are
    // 0 = userID
    // 7 = User ID: $userId already exists!
    // 25= User ID is required
    // 26= Password is required
    // 27= Firstname is required
    function aWSCreateUser($p_UserId="", $p_FirstName="", $p_LastName="", $p_eMail="", $p_Role="", $p_Password=""){// $p_UserId, $p_FirstName, $p_Password are required
    //--------------------------------
      try{
        global $sessionId;
        global $client;
        $params = array(array('sessionId'   =>$sessionId,
                                'userId'    =>$p_UserId,
                                'firstname' =>$p_FirstName,
                                'lastname'  =>$p_LastName,
                                'email'     =>$p_eMail,
                                'role'      =>$p_Role,
                                'password'  =>$p_Password));
        $result = $client->__SoapCall('createUser', $params);
        return $result;
        }catch(Exception $e){
        die("error in aWSCreateUser 201002151036 " . $e);
        }
    }
    //--------------------------------
    
    //--------------------------------
    
    // PMOS SOAP assignUserToGroup web service function
    // returns an array 
    // array->status_code
    // array->message    
    // array->timestamp
    //
    // status_code/message combinations are
    // 0 = Command executed successfully
    // 3 = User not registered in the system
    // 8 = User exists in the group
    // 9 = Group not registered in the system

    function aWSAssignUserToGroup($p_UserId="", $p_GroupId=""){// all parameters are required
    //--------------------------------
      try{
        global $sessionId;
        global $client;
        $params = array(array('sessionId'   =>$sessionId,
                                'userId'    =>$p_UserId,
                                'groupId'   =>$p_GroupId));
        $result = $client->__SoapCall('assignUserToGroup', $params);
        return $result;
        }catch(Exception $e){
        die("error in aWSAssignUserToGroup 201002151329 " . $e);
        }
    }
    //--------------------------------
  
    
//    
//    $params = array(array('sessionId'=>$sessionId, 'userId' => 'howdy4',
//   'firstname'=>'Howdy', 'lastname'=>'Foobar', 'email'=>'howdy@example.com', 
//   'role'=>'PROCESSMAKER_ADMIN', 'password'=>'HowDy123'));
//    $result = $client->__SoapCall('createUser', $params);
//    if ($result->status_code == 0) 
//   print "$result->message\nUser UID: $result->userUID";  
//    else 
//   print "Unable to create user.\nError Number: $result->status_code\n" .
//         "Error Message: $result->message\n";

// returns an array of all the PMOS users in the specified PMOS 
// database the array contains an array of all the fields in the 
// wf_workflow.USER table
//
function aGetPMOSUsers($p_PMOSWF){
//--------------------------------
  global $DBCON;
  global $JADOC;
  JADOC_CONNECT($p_PMOSWF);
  
  $PMOSWF=$JADOC[$p_PMOSWF];
  $PMOSWFID=$DBCON[$p_PMOSWF]['ID'];
  
  $JAS=$JADOC[$p_sJAS];
  $JASID=$DBCON[$p_sJAS]['ID'];


  try{
    $userArray = array();
    $userData = array();
    $counter = 0;
    $qryPMOS="SELECT * FROM dev1_wf_workflow.USERS;";
    $qresultPMOS = mysql_query($qryPMOS,$PMOSWF); ReportMySQLErrorandStop('201002141213', $PMOSWF, $qryPMOS);  
    while ($rowPMOS=mysql_fetch_array($qresultPMOS)){
        $userData["USR_UID"] = $rowPMOS["USR_UID"];
        $userData["USR_USERNAME"] = $rowPMOS["USR_USERNAME"];
        $userData["USR_PASSWORD"] = $rowPMOS["USR_PASSWORD"];
        $userData["USR_FIRSTNAME"] = $rowPMOS["USR_FIRSTNAME"];
        $userData["USR_LASTNAME"] = $rowPMOS["USR_LASTNAME"];
        $userData["USR_EMAIL"] = $rowPMOS["USR_EMAIL"];
        $userData["USR_DUE_DATE"] = $rowPMOS["USR_DUE_DATE"];
        $userData["USR_CREATE_DATE"] = $rowPMOS["USR_CREATE_DATE"];
        $userData["USR_UPDATE_DATE"] = $rowPMOS["USR_UPDATE_DATE"];
        $userData["USR_STATUS"] = $rowPMOS["USR_STATUS"];
        $userData["USR_COUNTRY"] = $rowPMOS["USR_COUNTRY"];
        $userData["USR_CITY"] = $rowPMOS["USR_CITY"];
        $userData["USR_LOCATION"] = $rowPMOS["USR_LOCATION"];
        $userData["USR_ADDRESS"] = $rowPMOS["USR_ADDRESS"];
        $userData["USR_PHONE"] = $rowPMOS["USR_PHONE"];
        $userData["USR_FAX"] = $rowPMOS["USR_FAX"];
        $userData["USR_CELLULAR"] = $rowPMOS["USR_CELLULAR"];
        $userData["USR_ZIP_CODE"] = $rowPMOS["USR_ZIP_CODE"];
        $userData["USR_DEPARTMENT"] = $rowPMOS["USR_DEPARTMENT"];
        $userData["USR_POSITION"] = $rowPMOS["USR_POSITION"];
        $userData["USR_RESUME"] = $rowPMOS["USR_RESUME"];
        $userData["USR_BIRTHDAY"] = $rowPMOS["USR_BIRTHDAY"];
        $userData["USR_ROLE"] = $rowPMOS["USR_ROLE"];
        $userArray[$counter] = $userData;
        echo $counter." = ".$userArray[$counter]["USR_UID"] ." username = ".$userArray[$counter]["USR_USERNAME"]." firstname = ".$userArray[$counter]["USR_FIRSTNAME"]."<br>";
        ++$counter;
    }
    echo "rGetPMOSUsers"."<br>";

  }catch(Exception $e){
    die("201002141130 " . $e);
  };
}
//--------------------------------


// =================================================================  
// END - PMOS + JAS Integration Specific
// ================================================================= 







// =================================================================  
// INIT  
// =================================================================  
Init_DB_Connections();  
// =================================================================  

// =================================================================  
// EOF
// =================================================================  
?>
