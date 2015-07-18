function CheckIfSubmitting(){
	if (window.event){
	  if ((window.event.keyCode==13) && (!document.getElementById("changepassword").checked)){
	    SubmitForm();
	  }else{
	    return window.event.keyCode;
	  };
	}else{
	  return null;
	};
};

function bChecknewpasswords(){
  var bSuccess=false;
  try{
      if((document.getElementById("newpassword1").value==0) && ((document.getElementById("newpassword2").value==''))){
        document.getElementById("warning").innerHTML='New Password is Blank.';
        bSuccess=false;
      } else {
        if((document.getElementById("newpassword1").value != document.getElementById("newpassword2").value)){
	        document.getElementById("warning").innerHTML='Passwords do not match.';
	        bSuccess=false;
	        //document.getElementById("submitbutton").disabled=true;
        } else {
          document.getElementById("warning").innerHTML='';
          //document.getElementById("submitbutton").disabled=false;
          bSuccess=true;
        };
      };
    }catch(e){
      bSuccess=true;
    };
    return bSuccess;
};

function showpasswordchange(){
  if(document.getElementById("changepassword").checked){
    document.getElementById("showpassworddiv1").innerHTML='<p>New Password</p><input name="newpassword1" id="newpassword1" type="password" "maxlength="32" />';
    document.getElementById("showpassworddiv2").innerHTML='<p>Confirm New Password</p><input name="newpassword2" id="newpassword2" type="password" maxlength="32" />';
    document.getElementById("warning").innerHTML='';
    document.getElementById("submitbutton").disabled=false;
  }else{
    document.getElementById("showpassworddiv1").innerHTML='';
    document.getElementById("showpassworddiv2").innerHTML='';
    document.getElementById("warning").innerHTML='';
    document.getElementById("submitbutton").disabled=false;
  };  
};

function SubmitLoginForm(){
  var bSuccess = true;
  if (document.getElementById("changepassword").checked==true){
    bSuccess = bChecknewpasswords();
  };
  if(bSuccess==true){
    document.getElementById("frmlogin").submit();
  };
};



