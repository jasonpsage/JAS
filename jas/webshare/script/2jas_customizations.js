// This file is for putting customizations in and configuration information
// into for user applications utilizing JAS. Note this file is included 
// stock jas: (Jas)/webroot/index.jas
//==============================================================================

function sVRoosterVideoPath(p_VREvent_UID){
  // Has Slash at end of domain
  //var s = sMainURL+'download/';
  var s = '/download/';

  //0123 4567 8901 2345 678E sVRoosterVideoPath
  
  s = s + p_VREvent_UID.substring(0,4)+'/'+
          p_VREvent_UID.substring(4,8)+'/'+
          p_VREvent_UID.substring(8,12)+'/'+
          p_VREvent_UID.substring(12,16)+'/'+
          p_VREvent_UID.substring(16,19)+'E/';
  return s;
}

//==============================================================================


//==============================================================================
function callbackajax_createvideo(doc){
  if((doc.errorCode!='')&&(doc.errorCode!='0')){
    alert('NOTICE: ' +doc.errorCode+' '+doc.errorMessage);
  }else{
    if(doc.makevideo[0].getText()=="0"){ alert('Error 0: Occurred - Are you logged in?');} else
    if(doc.makevideo[0].getText()=="1"){ alert('SUCCESS! Your video is in queue to be processed. You will be notified when it it is ready.'); } else
    if(doc.makevideo[0].getText()=="2"){ alert('Error 2: Invalid Event ID'); } else
    if(doc.makevideo[0].getText()=="3"){ alert('Error 3: Invalid Switch Camera Time'); } else
    if(doc.makevideo[0].getText()=="4"){ alert('Error 4: Unable to lock this event record.'); } else
    if(doc.makevideo[0].getText()=="5"){ alert('Error 5: This Event is already being processed'); } else
    if(doc.makevideo[0].getText()=="6"){ alert('Error 6: There was a problem accessing the database while gathering videos to be processed.'); } else
    if(doc.makevideo[0].getText()=="7"){ alert('Error 7: You need at least two videos that are flagged to be processed to to create a video.'); } else
    if(doc.makevideo[0].getText()=="8"){ alert('Error 8: Trouble preparing to mark videos as busy processing.'); } else
    if(doc.makevideo[0].getText()=="9"){ alert('Error 9: Trouble setting videos status to busy.'); } else
    if(doc.makevideo[0].getText()=="10"){ alert('Error 10: Failed to Set Event Status'); } else
    if(doc.makevideo[0].getText()=="11"){ alert('Error 11: Unable to add this job to the queue.'); } else
    alert('Unknown Error');
  };

}
//==============================================================================

//==============================================================================
function ajax_createvideo(p_UID, p_JSID, p_CamSw, p_Res){
  var sURL='.?userapi=makevideo&eventid='+encodeURI(p_UID)+
           '&switchcamtime='+encodeURI(p_CamSw)+
           '&JSID='+encodeURI(p_JSID)+'&resolution='+encodeURI(p_Res);
  iwfRequest(sURL,null,null,callbackajax_createvideo,false);
};
//==============================================================================




//==============================================================================
function callbackajax_sharevideoviaemail(doc){
  alert(doc);
};
//==============================================================================

//==============================================================================
function ShareVideoViaEmail(p_VideoUID){
  var sEmail=prompt('Enter the email address of the person you wish to share this video with below','[Type Email Address]');
  if (sEmail!=null && sEmail!=""){
      var sURL='.?jasapi=email&type=sharevideo&uid='+encodeURI(p_VideoUID)+'&email='+encodeURI(sEmail);
      iwfRequest(sURL,null,null,callbackajax_sharevideoviaemail,false);
  }else{
    alert('Email cancelled.');
  };
};
//==============================================================================










//==============
// EOF
//==============