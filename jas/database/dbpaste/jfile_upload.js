<!-- jfile data screen - file upload -->
<div id="divupload" style="display: none;">
  <a href=".?action=fileupload" target="_blank" title="Click to upload file">Upload file</a>
  <img class="image" src="[@JASDIRICON@]LGPL/CrystalProject/64x64/devices/network_local.png" />
</div>
<div id="divdownload" style="display: none;">
  <img class="image" src="[@JASDIRICONTHEME@]64/places/archive-folder.png" />
  <a href=".?action=filedownload&UID=[@UID@]" target="_blank" title="Click to download file">Download file</a>
</div>
<script language="javascript">
  var elDiv  = document.getElementById('divupload');
  var elDown  = document.getElementById('divdownload');
  if((cnJBlokMode_New==[#JBLOKMODE#])||(cnJBlokMode_Edit==[#JBLOKMODE#])){ elDiv.style.display=''; }else
  if(cnJBlokMode_View==[#JBLOKMODE#]){ elDown.style.display=''; };
</script>


