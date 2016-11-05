var _iwfLoggingEnabled = true;var _iwfDebugging = false;var __iwfCoreIncluded = true;function iwfGetById(id){var el = null;if (iwfIsString(id) || iwfIsNumber(id)) {el = document.getElementById(id);}	else if (typeof(id) == 'object') {
el = id;}
return el;}
function _iwfTextRecurse(el, remove){if (iwfAttribute(el, 'nodeType') == 3){ if (remove > 0){iwfRemoveNode(el);return null;} else {
var val = iwfAttribute(el, 'nodeValue');return val;}
} else {
if (remove > 0){for(var i=0;i<el.childNodes.length;i++){_iwfTextRecurse(el.childNodes[0], remove+1);iwfRemoveNode(el.childNodes[0]);}
if (remove > 1) {iwfRemoveNode(el);}
return null;} else {
var s = '';for(var i=0;i<el.childNodes.length;i++){var c = el.childNodes[i];s += _iwfTextRecurse(c, remove);}
return s;}
}
}
function iwfText(id, newText){var el = iwfGetById(id);if (!el) { if (!newText){var txt = iwfAttribute(el, 'innerText');if (!txt){txt = _iwfTextRecurse(el, 0);}
return txt;} else {
_iwfTextRecurse(el, 1);iwfAddText(el, newText);return null;}
}
function iwfCreateText(txt){var el = document.createTextNode(txt);if (!el){iwfLogFatal("could not create text node for text '" + txt + "'", true);}
return el;}
function iwfAddText(id, txt){var el = iwfGetById(id);if (!el) { return null; }
return iwfAddChild(el, iwfCreateText(txt));}
function iwfHtml(id, html){var el = iwfGetById(id);if (!el) { return null; }
if (html){el.innerHTML = html;}
return el.innerHTML;}
function iwfAddHtml(id, html){var el = iwfGetById(id);if (!el) { return null; }
el.innerHTML += html;return el;}
function iwfCreateTag(id, tagName){var el = document.createElement(tagName);if (!el){iwfLogFatal("could not create element '" + tagName + "'", true);} else {
if (id){iwfAttribute(el, 'id', id);}
}
return el;}
function iwfGetForm(id){var frm = iwfGetById(id);if (!frm){frm = document.forms ? document.forms[frm] : null;if (!frm){var allforms = iwfGetByTagName('form');for(var i=0;i<allforms.length;i++){if (iwfAttribute(allforms[i], 'name') == id){frm = allforms[i];break;}
}
}
}
return frm;}
function iwfCreateByNameWithinForm(form, nm, tagName, typeAtt, elParent){var elFrm = iwfGetForm(form);if (!elFrm){iwfLogFatal("IWF Core Error: Could not locate form by id, document.forms, or document[] named '" + form + "'", true);return false;}
var el = iwfCreateTag(null, tagName);if (!el){return null;}
iwfAttribute(el, 'name', nm);if (typeAtt){iwfAttribute(el, 'type', typeAtt);}
elParent = iwfGetById(elParent);if (elParent){elParent.appendChild(el);} else {
elFrm.appendChild(el);}
return el;}
function iwfGetByNameWithinForm(form, nm){var el = null;var frm = iwfGetForm(form);if (!frm){iwfLogFatal("IWF Core Error: Could not locate form by id, document.forms, or document[] named '" + form + "'", true);} else {
if (iwfIsString(nm) || iwfIsNumber(nm)) {for(var i=0;i<frm.elements.length;i++){if (frm.elements[i].name == nm || frm.elements[i].id == nm){el = frm.elements[i];break;}
}
} else {
el = id;}
}
return el;}
function iwfGetOrCreateByNameWithinForm(form, nm, tagNameOrHtml, typeAtt, elParent){var elFrm = iwfGetForm(form);if (!elFrm){iwfLogFatal("IWF Core Error: <form> with name or id of '" + form + "' could not be located.", true);return null;}
var el = iwfGetByNameWithinForm(form, nm);if (!el){el = iwfCreateByNameWithinForm(form, nm, tagNameOrHtml, typeAtt, elParent);}
return el;}
function iwfRemoveChild(parentId, id){var elParent = iwfGetById(parentId);if (elParent){var elChild = iwfGetById(id);if (elChild){elParent.removeChild(elChild);}
}
return elParent;}
function iwfGetOrCreateById(id, tagName, parentNodeId){var el = iwfGetById(id);if (!el){el = iwfCreateTag(id, tagName);iwfAttribute(el, 'name', id);if (parentNodeId){var elParent = iwfGetById(parentNodeId);if (elParent){iwfAddChild(elParent, el);} else if (parentNodeId.toLowerCase() == 'body'){
iwfAddChild(document.body, el);}
}
}
return el;}
function iwfAddChild(parentNodeId, childNodeId, atFront){var elChild = iwfGetById(childNodeId);if (!elChild) { return null; }
var elParent = iwfGetById(parentNodeId);if (!elParent) {var nodes = iwfGetByTagName(parentNodeId);if (nodes && nodes.length > 0){parent = nodes[0];} else {
return null;}
}
if (!atFront || !elParent.hasChildNodes()){elParent.appendChild(elChild);} else {
elParent.insertBefore(elChild, elParent.childNodes[0]);}
return elParent;}
function iwfRemoveNode(id){var el = iwfGetById(id);var elParent = iwfGetParent(id);if (!el || !elParent) { return false; }
elParent.removeChild(el);return true;}
function iwfElementToString(id){var el = iwfGetById(id);if (!el) { return 'element ' + id + ' does not exist.'; }
var s = '<' + el.tagName + ' ';var foundVal = false;if (el.attributes){for(var i=0;i<el.attributes.length;i++){var att = el.attributes[i];if (att.nodeName == 'value') foundVal = true;s += ' ' + att.nodeName + '="' + att.nodeValue + '" ';}
}
if (!foundVal && el.value){s += ' value="' + el.value + '" ';}
if (el.innerHTML == ''){s += ' />';} else {
s += '>' + el.innerHTML + '</' + el.tagName + '>';}
return s;}
function iwfGetByTagName(tagName, root) {var nodes = new Array();tagName = tagName || '*';root = root || document;if (root.all){if (tagName == '*'){nodes = root.all;} else {
nodes = root.all.tags(tagName);}
} else if (root.getElementsByTagName) {
nodes = root.getElementsByTagName(tagName);}
return nodes;}
function iwfGetByAttribute(tagName, attName, regex, callback) {var a, list, found = new Array();var reg = new RegExp(regex, 'i');list = iwfGetByTagName(tagName);for(var i=0;i<list.length;++i) {a = list[i].getAttribute(attName);if (!a) {a = list[i][attName];}
if (typeof(a)=='string' && a.search(regex) != -1) {found[found.length] = list[i];if (callback) { callback(list[i]); }
}
}
return found;}
function iwfAttribute(id, attName, newval){var el = iwfGetById(id);if (!el) { return null; }
var val = null;if (iwfExists(newval)){if (newval == null){iwfRemoveAttribute(el, attName);} else {
el.setAttribute(attName, newval);}
}
if (el[attName]){val = el[attName];} else if (el.getAttribute) {
val = el.getAttribute(attName);}
return val;}
function iwfRemoveAttribute(id, attName){var el = iwfGetById(id);if (el){el.removeAttribute(attName);}
return el;}
function iwfGetParent(id, useOffsetParent){var el = iwfGetById(id);if (!el) { return null; }
var cur = null;if (useOffsetParent && iwfExists(el.offsetParent)) { cur = el.offsetParent;} else if (iwfExists(el.parentNode)) { cur = el.parentNode;
} else if (iwfExists(el.parentElement)) { cur = el.parentElement; }
return cur;}
function iwfXmlEncode(s){if (!s){return '';}
var ret = s.replace(/&/gi, '&amp;').replace(/>/gi,'&gt;').replace(/</gi, '&lt;').replace(/'/gi, '&apos;').replace(/"/gi, '&quot;');return ret;}
function iwfXmlDecode(s){if (!s){return '';}
var ret = s.replace(/&gt;/gi, '>').replace(/&lt;/gi,'<').replace(/&apos;/gi, '\'').replace(/&quot;/gi, '"').replace(/&amp;/gi, '&');return ret;}
function iwfHtmlEncode(s){if (!s){return '';}
var ret = s.replace(/&/gi, '&amp;').replace(/>/gi,'&gt;').replace(/</gi, '&lt;').replace(/'/gi, '&apos;').replace(/"/gi, '&quot;');return ret;}
function iwfHtmlDecode(s){if (!s){return '';}
var ret = s.replace(/&gt;/gi, '>').replace(/&lt;/gi,'<').replace(/&apos;/gi, '\'').replace(/&quot;/gi, '"').replace(/&amp;/gi, '&');return ret;}
function iwfExists(){for(var i=0;i<arguments.length;i++){if(typeof(arguments[i])=='undefined') { return false; }
}
return true;}
function iwfIsString(s){return typeof(s) == 'string';}
function iwfIsNumber(n){return typeof(n) == 'number';}
function iwfIsBoolean(b){return typeof(b) == 'boolean';}
function iwfLastDay(val){var maxdy = -1;var dt = iwfDateFormat(val);var mo = iwfToInt(dt.substring(0,2));var dy = iwfToInt(dt.substring(3,2));var yr = iwfToInt(dt.substring(6,4));maxdy = 28;switch(mo){case 4:case 6:case 9:case 11:maxdy = 30;break;case 2:if (yr % 4 == 0 && (yr % 100 != 0 || yr % 400 == 0)){maxdy = 29;}
break;default:maxdy = 31;break;}
return maxdy;}
function _iwfIsDateObject(val){return (typeof(val) == 'object' && val.getMonth && val.getDate && val.getFullYear);}
function iwfIsDate(val){if (_iwfIsDateObject(val)){return true;}
var dt = iwfDateFormat(val);if(!dt){return false;} else {
var lastdy = iwfLastDay(dt);return lastdy > 0;}
}
function iwfDateFormat(val){if (_iwfIsDateObject(val)){var mo = '00' + (val.getMonth() + 1);mo = mo.substring(mo.length - 2);var dt = '00' + val.getDate();dt = dt.substring(dt.length - 2);return mo + '/' + dt + '/' + val.getFullYear();}
var delim = '/';if (val.indexOf(delim) == -1){delim = '-';}
var today = new Date();var mo = '00' + (today.getMonth() + 1);var dy = '00' + (today.getDate());var yr = today.getFullYear();var arr = val.split(delim);switch(arr.length){case 2:mo = '00' + arr[0];if (arr[1].length == 4){yr = arr[1];} else {
dy = '00' + arr[1];}
break;case 3:var yridx = 0;if (arr[0].length == 4){mo = '00' + arr[1];dy = '00' + arr[2];} else {
mo = '00' + arr[0];dy = '00' + arr[1];yridx = 2;}
switch(arr[yridx].length){case 1:yr = '200' + arr[yridx];break;case 2:if (arr[yridx] < 50){yr = '20' + arr[yridx];} else {
yr = '19' + arr[yridx];}
break;case 3:yr = '2' + arr[yridx];break;case 4:yr = arr[yridx];break;default:break;}
break;default:return null;break;}
mo = mo.substring(mo.length - 2);if (dy.length > 4){dy = dy.substr(2, 2);} else {
dy = dy.substring(dy.length - 2);}
return mo + '/' + dy + '/' + yr;}
var __iwfMonthArray = new Array('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');var __iwfWeekArray = new Array('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');function iwfToDate(val){if (_iwfIsDateObject(val)){return val;}
var sdt = iwfDateFormat(val);if (sdt){return new Date(sdt.substring(6,4), parseInt(sdt.substring(0,2),10) - 1, sdt.substring(3,2));} else {
return null;}
}
function iwfDateFormatLong(val){var dt = iwfToDate(val);return __iwfWeekArray[dt.getDay()] + ', ' + __iwfMonthArray[dt.getMonth()] + ' ' + dt.getDate() + ' ' + dt.getFullYear();}
function iwfDateFormatPretty(val){var dt = iwfToDate(val);return __iwfWeekArray[dt.getDay()] + ', ' + __iwfMonthArray[dt.getMonth()] + ' ' + dt.getDate();}
function iwfToInt(val, stripFormatting){var s = iwfIntFormat(val, stripFormatting);return parseInt(s, 10);}
function iwfToFloat(val, dp, stripFormatting){var s = iwfFloatFormat(val, dp, stripFormatting);return parseFloat(s);}
function iwfIntFormat(val, stripFormatting){return iwfFloatFormat(val, -1, stripFormatting);}
function iwfFloatFormat(val, dp, stripFormatting){if (stripFormatting && iwfIsString(val)){val = val.replace(/[^0-9\.]/gi,'');}
if (isNaN(val)) {val = 0.0;}
var s = '' + val;var pos = s.indexOf('.');if (pos == -1) {s += '.';pos += s.length;}
s += '0000000000000000000';s = s.substr(0,pos+dp+1);return s;}
function iwfDoAction(act, frm, id, targetElement){if (window.iwfOnFormValidate){if (!iwfOnFormValidate(act)){return;}
}
var frmId = frm;frm = iwfGetForm(frmId);if (!frm){iwfLogFatal('IWF Core Error: Could not locate form with id or name of ' + frmId, true);return;}
var elId = iwfGetOrCreateById('iwfId', 'input');if (!elId){iwfLogFatal('IWF Core Error: Could not create iwfId element!', true);return;} else {
iwfAttribute(elId, 'value', id);iwfRemoveAttribute(elId, 'disabled');if (!iwfGetParent(elId)){iwfAttribute(elId, 'type', 'hidden');if (!iwfAddChild(frm, elId)){iwfLogFatal('IWF Core Error: Created iwfId element, but could not append to form ' + frm.outerHTML, true);return;}
}
}
var elMode = iwfGetOrCreateById('iwfMode', 'input');if (!elMode){iwfLogFatal('IWF Core Error: Could not create iwfMode element!', true);return;} else {
iwfAttribute(elMode, 'value', act);iwfRemoveAttribute(elMode, 'disabled');if (!iwfGetParent(elMode)){iwfAttribute(elMode, 'type', 'hidden');if (!iwfAddChild(frm, elMode)){iwfLogFatal('IWF Core Error: Created iwfMode element, but could not append to form ' + frm.outerHTML, true);return;}
}
}
var elRealTarget = iwfGetById(targetElement);if (elRealTarget){var elTarget = iwfGetOrCreateById('iwfTarget', 'input');if (!elTarget){iwfLogFatal('IWF Core Error: Could not create iwfTarget element under form ' + frm.outerHTML, true);return;} else {
iwfAttribute(elTarget, 'value', iwfAttribute(elRealTarget, 'id'));iwfRemoveAttribute(elTarget, 'disabled');if (!iwfGetParent(elTarget)){iwfAttribute(elTarget, 'type', 'hidden');if (!iwfAddChild(frm, elTarget)){iwfLogFatal('IWF Core Error: Created iwfTarget element, but could not append to form ' + frm.outerHTML, true);return;}
}
}
if (!window.iwfRequest){iwfLogFatal("IWF Core Error: when using the iwfDo* functions and passing a targetElement, you must also reference the iwfajax.js file from your main html file.", true);} else {
iwfRequest(frm);}
} else {
frm.submit();}
}
function iwfDoEdit(formId, id, targetElement){iwfDoAction('edit', formId, id, targetElement);}
function iwfDoSave(formId, id, targetElement){iwfDoAction('save', formId, id, targetElement);}
function iwfDoDelete(formId, id, targetElement){iwfDoAction('delete', formId, id, targetElement);}
function iwfDoAdd(formId, id, targetElement){iwfDoAction('add', formId, id, targetElement);}
function iwfDoSelect(formId, id, targetElement){iwfDoAction('select', formId, id, targetElement);}
function iwfDoCancel(formId, id, targetElement){iwfDoAction('cancel', formId, id, targetElement);}
function iwfMailTo(uid, host){location.href = 'mailto:' + uid + '@' + host;}
function iwfClick(id){var el = iwfGetById(id);if (!el) { return; }
if (iwfAttribute(el, 'click')){el.click();} else {
}
}
function iwfClickLink(id){var el = iwfGetById(id);if (!el) { return; }
if (el.click){el.click();} else {
location.href = iwfAttribute(el, 'href');}
}
function iwfShowMessage(msg){var el = iwfGetById('msg');if (!el){alert(msg + '\n\nTo supress this alert, add a tag with an id of "msg" to this page.');} else {
el.innerHTML = msg.replace(/\n/, '<br />');}
}
var _iwfLoggedItems = "";function iwfLog(txt, showAlert){ if (_iwfLoggingEnabled){_iwfLoggedItems += txt + '\n';} else {
}
if (showAlert || _iwfDebugging){alert(txt);}
}
function iwfLogFatal(txt){ iwfLog(txt, true); }
function iwfHideLog(){iwfGetById("iwfLog").style.display="none";}
function iwfClearLog(){_iwfLoggedItems = '';iwfRefreshLog();}
function iwfRefreshLog(){iwfHideLog();iwfShowLog();}
function iwfShowLog(){if (!_iwfLoggingEnabled){alert("Logging for IWF has been disabled.\nSet the _iwfLoggingEnabled variable located in the iwfcore.js (or iwfconfig.js) file to true to enable logging.");} else {
var el = iwfGetOrCreateById('iwfLog', 'div', 'body');if (!el){alert(_iwfLoggedItems);} else {
el.style.position = 'absolute';el.style.zIndex = '999999';el.style.left = '10px';el.style.top = '200px';el.style.color = 'blue';el.style.width = '500px';el.style.height = '300px';el.style.overflow = 'scroll';el.style.padding = '5px 5px 5px 5px;';el.style.backgroundColor = '#efefef';el.style.border = '1px dashed blue';el.style.display = 'block';el.style.visibility = 'visible';el.id = 'iwfLog';el.innerHTML = "IWF Log <span style='width:100px'>&nbsp;</span><a href='javascript:iwfRefreshLog();'>refresh</a> <a href='javascript:iwfHideLog();'>close</a> <a href='javascript:iwfClearLog();'>clear</a>:<hr /><pre>" + _iwfLoggedItems.replace(/</gi, '&lt;').replace(/>/gi, '&gt;') + "</pre>";}
}
}
