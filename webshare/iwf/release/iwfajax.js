var _iwfShowGuiProgress = iwfExists(window.iwfShow);if (!__iwfCoreIncluded || !__iwfXmlIncluded){iwfLogFatal("IWF Dependency Error: iwfajax.js is dependent upon both iwfcore.js and iwfxml.js, " +"so you *must* reference those files first.\n\nExample:\n\n" +"<" + "script type='text/javascript' src='iwfcore.js'></" + "script>\n" +"<" + "script type='text/javascript' src='iwfxml.js'></" + "script>\n<script type='text/javascript' src='iwfajax.js'></script>",true);}
var __iwfAjaxIncluded = true;function iwfRequestSync(urlOrForm, targetElementOnResponse, addToHistory, callback){return iwfRequest(urlOrForm, targetElementOnResponse, addToHistory, callback, true);}
function iwfRequest(urlOrForm, targetElementOnResponse, addToHistory, callback, synchronously){function iwfBindCallback(){if (req && req.readyState == 4) {_iwfOnRequestEnd();if (req.status == 200 || req.status == 0) {_iwfResponseHandler(req.responseText, localCallback, localTarget);} else {
_iwfOnRequestError(req.status, req.statusText, req.responseText);}
return;}
}
if (!iwfExists(synchronously)){synchronously = false;}
var url = null;var method = 'GET';var postdata = null;var isFromForm = true;var contentType = 'application/x-www-form-urlencoded';if (iwfIsString(urlOrForm)){isFromForm = false;var frm = iwfGetForm(urlOrForm);if (!frm){url = urlOrForm;method = 'GET';postdata = null;} else {
urlOrForm = frm;}
}
var localCallback = callback;var localTarget = targetElementOnResponse;if (!iwfIsString(urlOrForm)){var ctl = null;if (iwfExists(urlOrForm.form)){ctl = urlOrForm;urlOrForm = urlOrForm.form;}
if (!localTarget){localTarget = iwfAttribute(urlOrForm, 'iwfTarget');}
if (localTarget){var elTgt = iwfGetOrCreateByNameWithinForm(urlOrForm, 'iwfTarget', 'input', 'hidden');if (elTgt){iwfAttribute(elTgt, 'value', localTarget);iwfRemoveAttribute(elTgt, 'disabled');}
}
url = urlOrForm.action;method = urlOrForm.method.toUpperCase();var iframe = _iwfUploadFiles(urlOrForm, localCallback, localTarget);if (!iframe){switch(method){case "POST":postdata = _iwfGetFormData(urlOrForm, url, ctl);var frm = iwfGetForm(urlOrForm);if (frm){var enc = iwfAttribute(frm, 'encoding');if (!enc){enc = iwfAttribute(frm, 'enctype');}
if (enc){contentType = enc;}
}
break;case "GET":default:url = _iwfGetFormData(urlOrForm, url, ctl);break;}
} else {
}
}
if (iframe){} else {
if (location.href.indexOf('file:var pos = location.href.lastIndexOf('/');url = location.href.substring(0,pos+1) + url;} else {
url += ((url.indexOf('?') > -1) ? '&' : '?') + 'iwfRequestId=' + new Date().valueOf();}
var req = null;if (!addToHistory){req = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");req.onreadystatechange = iwfBindCallback;_iwfOnRequestStart();req.open(method, url, !synchronously);req.setRequestHeader('Content-Type', contentType);req.send(postdata);if (synchronously){_iwfOnRequestEnd();_iwfResponseHandler(req.responseText, localCallback, localTarget);}
} else {
return;var el = iwfGetById("iwfHistoryFrame");if (!el){iwfLogFatal("To enable history tracking in IWF, you must add an invisible IFRAME element to your page:\n<IFRAME id='iwfHistoryFrame' style='display:none'></IFRAME>", true);}
el.src = url;_iwfOnRequestStart();}
}
if (isFromForm){return false;} else {
}
}
function _iwfGetFormData(form, url, ctl){var method = form.method;if (!method) { method = "get"; }
var output = null;if (method == 'get'){output = url + ((url.indexOf('?') > -1) ? '&' : '?');} else {
output = '';}
for(var i=0;i<form.elements.length;i++){var el = form.elements[i];var nm = iwfAttribute(el, 'name');var val = null;if (!iwfAttribute(el, 'disabled') && nm){switch (el.tagName.toLowerCase()){case 'input':switch(iwfAttribute(el, 'type')){case 'checkbox':case 'radio':if (iwfAttribute(el, 'checked')){val = iwfAttribute(el, 'value');}
break;case 'button':if (el == ctl){val = iwfAttribute(el, 'value');}
break;case 'submit':if (el == ctl){val = iwfAttribute(el, 'value');}
break;case 'text':default:val = iwfAttribute(el, 'value');break;case 'file':val = iwfAttribute(el, 'value');break;case 'image':iwfLogFatal('TODO: implement <input type="image"> in _iwfGetFormData', true);val = iwfAttribute(el, 'value');break;case 'reset':iwfLogFatal('TODO: implement <input type="reset"> in _iwfGetFormData', true);break;case 'hidden':val = iwfAttribute(el, 'value');break;}
break;case 'textarea':val = iwfAttribute(el, 'innerText');break;case 'button':if (el == ctl){val = iwfAttribute(el, 'innerText');}
break;case 'select':for(var j=0;j<el.options.length;j++){if (iwfAttribute(el.options[j], 'selected')){if (!val){val = iwfAttribute(el.options[j], 'value');} else {
val += '+' + iwfAttribute(el.options[j], 'value');}
}
}
}
if (val){if (output.length > 0){output += '&';}
output += escape(nm) + '=' + escape(val);}
}
}
if (output.length == 0){return null;} else {
return output;}
}
function _iwfResponseReceived(doc){var xmlDoc = new iwfXmlDoc(doc.innerHTML);}
function _iwfResponseHandler(origText, callback, tgt){var doc = new iwfXmlDoc(origText);if (!doc.response){if (callback){callback(doc);} else {
iwfLogFatal("IWF Ajax Error: No callback defined for non-standard response:\n" + origText, true);}
} else {
if (doc.response.debugging == 'true'){iwfLoggingEnabled = true;iwfShowLog();}
var origTgt = tgt;for(var i=0; i< doc.response.childNodes.length; i++){var node = doc.response.childNodes[i];tgt = origTgt;if (node.nodeName.indexOf("#") != 0){if (!tgt) {tgt = node.target;}
if (node.errorCode && iwfToInt(node.errorCode, true) != 0){_iwfOnRequestError(node.errorCode, node.errorMessage);} else {
if (!node.type){node.type = "";}
switch(node.type.toLowerCase()){case "html":case "xhtml":var innerHtml = node.innerHtml();_iwfInsertHtml(innerHtml, tgt);break;case "javascript":case "js":var bomb = true;if (node.childNodes.length == 1){var js = node.childNodes[0];if (js.nodeName == '#cdata' || js.nodeName == '#comment'){bomb = false;var code = js.getText();eval(code);}
}
if (bomb){iwfLogFatal("IWF Ajax Error: When an <action> is defined of type javascript, it content must be contained by either a Comment (<!-- -->) or CDATA (<![CDATA[  ]]>).\nCDATA is the more appropriate manner, as this is the xml-compliant one.\nHowever, COMMENT is also allowed as this is html-compliant, such as within a <script> element.\n\n<action> xml returned:\n\n" + node.outerXml(), true);}
break;case "xml":if (callback){callback(node);}
break;case "debug":iwfLogFatal("IWF Debug: <action> type identified as 'debug'.\nXml received for current action:\n\n" + node.outerXml(), true);break;default:iwfLogFatal('IWF Ajax Error: <action> type of "' + node.type + '" is not a valid option.\n\nValid options:\n\'html\' or \'xhtml\' = parse as html and inject into element with the id specified by the target attribute\n\'javascript\' or \'js\' = parse as javascript and execute\n\'xml\' = parse as xml and call the callback specified when iwfRequest() was called\n\'debug\' = parse as xml and log/alert the result\n\n<action> xml returned:\n\n' + node.outerXml(), true);break;}
}
}
}
}
}
function _iwfInsertHtml(html, parentNodeId){if(!parentNodeId){parentNodeId = 'iwfContent';}
if(!parentNodeId){iwfLogFatal("IWF Ajax Error: <action> node with a type of 'html' does not have its target attribute specified to a valid element.\nPlease specify the id of the element into which the contents of the <action> node should be placed.\nTo fill the entire page, simply specify 'body'.", true);} else {
var el = iwfGetById(parentNodeId);if (!el){if (parentNodeId == 'body'){el = iwfGetByTagName('body');if (!el || el.length == 0){iwfLogFatal("IWF Ajax Error: Could not locate the tag named 'body'", true);return;} else {
el = el[0];}
} else {
iwfLogFatal('IWF Ajax Error: Could not locate element with id of ' + parentNodeId + ' into which the following html should be placed:\n\n' + html, true);return;}
}
var re = /<form/i;var match = re.exec(html);if (match && document.forms.length > 0){var elParent = el;while (elParent && elParent.tagName.toLowerCase() != 'form'){elParent = iwfGetParent(elParent);}
if (elParent && elParent.tagName.toLowerCase() == 'form'){iwfLogFatal('IWF Ajax Error: Attempting to inject html which contains a <form> node into a target element which is itself a <form> node, or is already contained by a <form> node.\nThis is bad html, and will not work appropriately on some major browsers.', true);}
}
el.innerHTML = html;var i = 0;while (iwfGetById('iwfScript' + i)){i++;}
var scriptStart = html.indexOf("<script");while(scriptStart > -1){scriptStart = html.indexOf(">", scriptStart) + 1;var scriptEnd = html.indexOf("</script>", scriptStart);var scriptHtml = html.substr(scriptStart, scriptEnd - scriptStart);var re = /^\s*<!--/;var match = re.exec(scriptHtml);if (!match){iwfLogFatal("IWF Ajax Error: Developer, you *must* put the <!-- and /" + "/--> 'safety net' around your script within all <script> tags.\nThe offending <script> tag contains the following code:\n\n" + scriptHtml + "\n\nThis requirement is due to how IWF injects the html so the browser is able to actually parse the script and make its contents available for execution.", true);}
try {var elScript = iwfGetOrCreateById('iwfScript' + i, 'script');elScript.type = 'text/javascript';elScript.defer = 'true';elScript.innerHTML = scriptHtml;iwfAppendChild('body', elScript);} catch(e){
var elDiv = iwfGetOrCreateById('iwfScript' + i, '<div style="display:none"></div>', 'body');elDiv.innerHTML = '<code>IE hack here</code><script id="iwfScript' + i + '" defer="true">' + scriptHtml + '</script' + '>';}
i++;scriptStart = html.indexOf("<script", scriptEnd+8);}
}
}
function iwfCleanScripts(){var i = 0;while(iwfRemoveNode('iwfScript' + (i++)));}
function _iwfIframeCallback(frameName, xml){var div = iwfGetById(frameName + "_callback");var localCallback = iwfAttribute(div, 'iwfFileUploadCallback');var localTarget = iwfAttribute(div, 'iwfFileUploadTarget');_iwfOnRequestEnd();_iwfResponseHandler(xml, localCallback, localTarget);}
function _iwfUploadFiles(frm, callback, target){var fileCount = 0;var i = 0;while (iwfGetById('iwfFileUpload' + i)){i++;}
var frameName = 'iwfFileUpload' + i;var js = '';var formName = iwfAttribute(frm, 'name');if (!formName) { formName = iwfAttribute(frm, 'id'); }
var formElements = "<input type='hidden' name='iwfIframeName' id='iwfIframeName' value='" + frameName + "' />";for(var i=0;i<frm.elements.length;i++){var el = frm.elements[i];var elString = iwfElementToString(el);if (el.tagName.toLowerCase() == 'input' && iwfAttribute(el, 'type').toLowerCase() == 'file' && iwfAttribute(el, 'value')){fileCount++;js += "document.forms[0].appendChild(window.parent.document.forms['" + formName + "']." + iwfAttribute(el, 'name') + ".cloneNode(true)); ";} else {
formElements += elString;}
}
var startFormTag = "<form name='" + formName +"' id='" + formName +"' action='" + iwfAttribute(frm, 'action');if (fileCount > 0){startFormTag += "' method='post' enctype='multipart/form-data'>";} else {
startFormTag += "' method='" + iwfAttribute(frm, 'method') +"' enctype='" + iwfAttribute(frm, 'enctype') + "'>";}
var html = "<html><body ";if (js && js.length > 0){html += 'onload="javascript:';html += js;html += "; setTimeout('document.forms[0].submit()', 100);";html += '">';} else {
html += '>';}
html += startFormTag;html += formElements;html += "<input type='submit' value='Go' name='iwfHiddenGo' id='iwfHiddenGo'/>";html += "</form></body></html>";if (fileCount > 0){var elUploadDiv = iwfGetOrCreateById('iwfFileUploadFrameHolder', 'div', 'body');var elCallback = iwfGetOrCreateById(frameName + '_callback', 'div', elUploadDiv);iwfAttribute(elCallback, 'iwfFileUploadCallback', callback);iwfAttribute(elCallback, 'iwfFileUploadTarget', target);var elUpload =  iwfGetOrCreateById(frameName, 'iframe', elUploadDiv);elUpload = window.frames[frameName];_iwfOnRequestStart();elUpload.document.open('text/html', 'replace');elUpload.document.write(html);elUpload.document.close();return elUpload;} else {
return null;}
}
var _iwfTotalRequests = 0;var _iwfPendingRequests = 0;var _iwfRequestTicker = null;var _iwfRequestTickCount = 0;var _iwfRequestTickDuration = 100;function _iwfGetBusyBar(inner){var b = iwfGetById('iwfBusy');if (!b){b = iwfGetOrCreateById('iwfBusy', 'div', 'body');b.className = 'iwfbusybar';if(b.style){b.style.position = 'absolute';b.style.border = '1px solid black';b.style.backgroundColor = '#efefef';b.style.textAlign = 'left';}
iwfWidth(b, 100);iwfHeight(b, 20);iwfZIndex(b, 9999);iwfX(b, 0);iwfY(b, 0);iwfHide(b);}
var bb = iwfGetById('iwfBusyBar');if(!bb){bb = iwfGetOrCreateById('iwfBusyBar', 'div', b);bb.style.backgroundColor = 'navy';bb.style.color = 'white';bb.style.textAlign = 'left';bb.style.paddingLeft = '5px';iwfWidth(bb, 1);iwfHeight(bb, 20);iwfX(bb, 0);iwfY(bb, 0);}
if(inner){return bb;} else {
return b;}
}
function _iwfOnRequestStart(){_iwfPendingRequests++;_iwfTotalRequests++;_iwfRequestTickDuration = 100;if (!_iwfRequestTicker){_iwfRequestTickCount = 0;if (window.iwfOnRequestStart){_iwfRequestTickDuration = iwfOnRequestStart();} else if (_iwfShowGuiProgress) {
var bb = _iwfGetBusyBar(true);iwfWidth(bb, 1);bb.innerHTML = '0%';iwfShow(_iwfGetBusyBar(false));} else {
window.status = 'busy.';}
if (!_iwfRequestTickDuration){_iwfRequestTickDuration = 100;}
_iwfRequestTicker = setInterval(_iwfOnRequestTick, _iwfRequestTickDuration);}
}
function _iwfOnRequestTick(){_iwfRequestTickCount++;if (window.iwfOnRequestTick){iwfOnRequestTick(_iwfRequestTickCount, _iwfRequestTickDuration, _iwfPendingRequests);} else if (!window.iwfOnRequestStart) {
if (_iwfShowGuiProgress) {var bar = _iwfGetBusyBar(true);if(bar){var w = iwfWidth(bar) + 1;if (w > 95){w = 95;}
iwfWidth(bar, w);bar.innerHTML = iwfIntFormat(w) + "%";}
} else {
window.status = 'busy...............................................'.substr(0, (_iwfRequestTickCount % 45) + 5);}
} else {
}
}
function _iwfOnRequestEnd(){_iwfPendingRequests--;if (_iwfPendingRequests < 1){_iwfPendingRequests = 0;_iwfTotalRequests = 0;clearInterval(_iwfRequestTicker);_iwfRequestTicker = null;if (window.iwfOnRequestEnd){iwfOnRequestEnd();} else if (!window.iwfOnRequestStart) {
if (_iwfShowGuiProgress) {var bar = _iwfGetBusyBar(true);if(bar){iwfWidth(bar, 100);bar.innerHTML = "Done";iwfHideGentlyDelay(_iwfGetBusyBar(false), 15, 500);}
} else {
window.status = 'done.';}
} else {
}
} else {
if (window.iwfOnRequestProgress){iwfOnRequestProgress(_iwfPendingRequests, _iwfTotalRequests);} else if (!window.iwfOnRequestStart) {
if (_iwfShowGuiProgress) {var pct = (1 - (_iwfPendingRequests/_iwfTotalRequests)) * 100;if (pct > 100){pct = 100;}
var bar = _iwfGetBusyBar(true);if(bar){iwfWidth(bar, pct);bar.innerHTML = "loading " + iwfIntFormat(pct) + "%";}
} else {
window.status = 'Remaining: ' + _iwfPendingRequests;}
} else {
}
}
}
function _iwfOnRequestError(code, msg, text){if (window.iwfOnRequestError){iwfOnRequestError(code, msg, text);} else {
iwfLogFatal("Error " + code + ": " + msg + ":\n\n" + text);}
}
