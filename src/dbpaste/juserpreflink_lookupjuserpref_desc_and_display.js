<script language="javascript">
  var sResult ='';
  function callbackajax_gothelp(doc){
    try{
      sResult=sURIDecode(decodeURI(String(doc.getText())));
    }catch(eX){
      confirm(eX.message);
      sResult='<p>Trouble loading help for this preference.</p>';
    };
    document.getElementById('divPrefHelp').innerHTML=sResult;
  };
  function ajax_gethelp(){
    var sURL='/.?jasapi=userprefhelp&UID=[@UsrPL_UserPref_ID@]';
    iwfRequest(sURL,null,null,callbackajax_gothelp,false);
  };
  ajax_gethelp();
</script>
<div id="divPrefHelp"></div>

