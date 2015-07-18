// =========================================================================
/// IWF - Interactive Website Framework.  Javascript library for creating
/// responsive thin client interfaces.
///
/// Copyright (C) 2005 Brock Weaver brockweaver@users.sourceforge.net
///
///     This library is free software; you can redistribute it and/or modify
/// it under the terms of the GNU Lesser General Public License as published
/// by the Free Software Foundation; either version 2.1 of the License, or
/// (at your option) any later version.
///
///     This library is distributed in the hope that it will be useful, but
/// WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
/// or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
/// License for more details.
///
///    You should have received a copy of the GNU Lesser General Public License
/// along with this library; if not, write to the Free Software Foundation,
/// Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
///
/// Brock Weaver
/// brockweaver@users.sourceforge.net
/// 8772 NE 94th Ave
/// Bondurant, IA 50035
///
//! http://iwf.sourceforge.net/
// =========================================================================
//! NOTE: To minimize file size, strip all fluffy comments (except the LGPL, of course!)
//! using the following regex (global flag and multiline on):
//!            ^\t*//([^/!].*|$)
//
// This reduces file size by about 30%, give or take.
//
//!  To rip out only logging statements (commented or uncommented):
//!            ^/{0,2}iwfLog.*
// =========================================================================

// --------------------------------------------------------------------------
//! iwfcore.js
//
// Core functions
//
//! Dependencies:
//! (none)
//
//! Brock Weaver - brockweaver@users.sourceforge.net
//! v 0.2 - 2005-11-14
//! iwfcore bug patch
//! --------------------------------------------------------------------------
//! - fixed iwfAttribute to return most current value instead of initial value
//!
//! v 0.1 - 2005-06-05
//! Initial release.
//! --------------------------------------------------------------------------

// -----------------------------------
// Begin: Configurable variables
// -----------------------------------

// set to true to enable logging.  Logging simply means certain values are appended to a string. nothing is written out or communicated over the wire anywhere.
var _iwfLoggingEnabled = true;


// -----------------------------------
// End: Configurable variables
// -----------------------------------


// -----------------------------------
// Begin: Element Utility Functions
// -----------------------------------

function iwfGetById(id){
	var el = null;
	if (iwfIsString(id) || iwfIsNumber(id)) el = document.getElementById(id);
	else if (typeof(id) == 'object') el = id;
	return el;
}

function iwfGetForm(id){
	var frm = iwfGetById(id);
	if (!frm){
		// or by forms collection...
		frm = document.forms ? document.forms[frm] : null;
		if (!frm){
			// or by tag elements...
			var allforms = iwfGetByTagName('form');
			for(var i=0;i<allforms.length;i++){
				if (iwfAttribute(allforms[i], 'name') == id){
					frm = allforms[i];
					break;
				}
			}
		}
	}
	return frm;
}

function iwfGetByNameWithinForm(form, nm){
	var frm = iwfGetForm(form);
	if (!frm){
		iwfLog("IWF Core Error: Could not locate form by id, document.forms, or document[] named '" + form + "'", true);
		return null;
	} else {
		// find element within this form with given id.
		var el = null;
		if (iwfIsString(nm) || iwfIsNumber(nm)) {
			for(var i=0;i<frm.elements.length;i++){
				if (frm.elements[i].name == nm || frm.elements[i].id == nm){
					el = frm.elements[i];
					break;
				}
			}
		} else {
			el = id;
		}
//iwfLog('iwfGetByNameWithinForm returning:\n\n' + iwfElementToString(el), true);
		return el;
	}
}

function iwfGetOrCreateByNameWithinForm(form, nm, tagNameOrHtml, typeAtt){
	var elFrm = iwfGetForm(form);

	if (!elFrm){
		iwfLog("IWF Core Error: <form> with name or id of '" + form + "' could not be located.", true);
		return;
	}

	var el = iwfGetByNameWithinForm(form, nm);
	if (!el){
		// element does not exist. create it.
		el = document.createElement(tagNameOrHtml);
		iwfAttribute(el, 'name', nm);

		if (typeAtt){
			iwfAttribute(el, 'type', typeAtt);
		}

		elFrm.appendChild(el);
	}

	return el;
}

function iwfRemoveChild(parentId, id){
	var elParent = iwfGetById(parentId);
	if (elParent){
		var elChild = iwfGetById(id);
		if (elChild){
			elParent.removeChild(elChild);
		}
	}
	return elParent;
}

function iwfGetOrCreateById(id, tagNameOrHtml, parentNodeId){
	var el = iwfGetById(id);
	if (!el){
		// element does not exist. create it.
		el = document.createElement(tagNameOrHtml);
		iwfAttribute(el, 'id', id);
		iwfAttribute(el, 'name', id);

		if (parentNodeId){
			var elParent = iwfGetById(parentNodeId);
			if (elParent){
				iwfAddChild(elParent, el);
			} else if (parentNodeId.toLowerCase() == 'body'){
				iwfAddChild(document.body, el);
			}
		}


	}
	return el;
}

function iwfAddChild(parentNodeId, childNodeId, atFront){

		var elChild = iwfGetById(childNodeId);
		if (!elChild) return null;

		// get the element who is to be the parent
		var elParent = iwfGetById(parentNodeId);

		// parent not found, try by tagName
		if (!elParent) {
			var nodes = iwfGetByTagName(parentNodeId);
			if (nodes && nodes.length > 0){
				// always use the first element with that tag name as the parent (think 'body')
				parent = nodes[0];
			} else {
				// couldn't find by id or tag name.  bomb out.
				return null;
			}
		}



		if (!atFront || !elParent.hasChildNodes()){
			// append as last child of elParent
			elParent.appendChild(elChild);
		} else {
			// append as first child of elParent
			elParent.insertBefore(elChild, elParent.childNodes[0]);
		}

		return elParent;
}

function iwfRemoveNode(id){
	var el = iwfGetById(id);
	var elParent = iwfGetParent(id);
	iwfLog(iwfElementToString(el), true);
	if (!el || !elParent) return false;
	elParent.removeChild(el);
	return true;
}

function iwfElementToString(id){
	var el = iwfGetById(id);
	if (!el) return 'element ' + id + ' does not exist.';

	var s = '<' + el.tagName + ' ';

//	for(att in el){
//		iwfLog('att ' + att);
//		s += ' ' + att.nodeName + '="' + att.nodeValue + '" ';
//	}

	var foundVal = false;
	if (el.attributes){
		for(var i=0;i<el.attributes.length;i++){
			var att = el.attributes[i];
			if (att.nodeName == 'value') foundVal = true;
			s += ' ' + att.nodeName + '="' + att.nodeValue + '" ';
		}
	}

	if (!foundVal && el.value){
		s += ' value="' + el.value + '" ';
	}
	if (el.innerHTML == ''){
		s += ' />';
	} else {
		s += '>' + el.innerHTML + '</' + el.tagName + '>';
	}

	return s;
}

function iwfGetByTagName(tagName, root) {
	var nodes = new Array();
	tagName = tagName || '*';
	root = root || document;
	if (root.all){
		if (tagName == '*'){
			nodes = root.all;
		} else {
			nodes = root.all.tags(tagName);
		}
	} else if (root.getElementsByTagName) {
		nodes = root.getElementsByTagName(tagName);
	}
	return nodes;
}

function iwfGetByAttribute(tagName, attName, regex, callback) {
	var a, list, found = new Array();
	var reg = new RegExp(regex, 'i');
	list = iwfGetByTagName(tagName);
	for(var i=0;i<list.length;++i) {
		a = list[i].getAttribute(attName);
		if (!a) {a = list[i][attName];}
		if (typeof(a)=='string' && a.search(regex) != -1) {
			found[found.length] = list[i];
			if (callback) callback(list[i]);
		}
	}
	return found;
}

function iwfAttribute(id, attName, newval){
	var el = iwfGetById(id);
	if (!el) return;

	var val = null;
	if (iwfExists(newval)){
		if (newval == null){
			// remove it, don't set it to null.
			iwfRemoveAttribute(el, attName);
		} else {
			el.setAttribute(attName, newval);
		}
	}
	// 2005-11-14 Brock Weaver
	// added check for attribute on el before trying getAttribute method
	// (Thanks J.P. Jarolim!)
	if (el[attName]){
		val = el[attName];
	} else if (el.getAttribute) {
		val = el.getAttribute(attName);
	}
	return val;
}

function iwfRemoveAttribute(id, attName){
	var el = iwfGetById(id);
	if (el){
		el.removeAttribute(attName);
	}
	return el;
}

function iwfGetParent(id, useOffsetParent){
	var el = iwfGetById(id);
	if (!el) return null;
	var cur = null;
	if (useOffsetParent && iwfExists(el.offsetParent)) { cur = el.offsetParent;
	} else if (iwfExists(el.parentNode)) { cur = el.parentNode;
	} else if (iwfExists(el.parentElement)) { cur = el.parentElement; }
	return cur;
}

// -----------------------------------
// End: Element Utility Functions
// -----------------------------------


// -----------------------------------
// Begin: Encoding Utility Functions
// -----------------------------------

function iwfXmlEncode(s){
	if (!s){
		return '';
	}
	var ret = s.replace(/&/gi, '&amp;').replace(/>/gi,'&gt;').replace(/</gi, '&lt;').replace(/'/gi, '&apos;').replace(/"/gi, '&quot;');
//alert('after xmlencoding: \n\n\n' + ret);
	return ret;
}

function iwfXmlDecode(s){
	if (!s){
		return '';
	}
	var ret = s.replace(/&gt;/gi, '>').replace(/&lt;/gi,'<').replace(/&apos;/gi, '\'').replace(/&quot;/gi, '"').replace(/&amp;/gi, '&');
//alert('after xmldecoding: \n\n\n' + ret);
	return ret;
}

function iwfHtmlEncode(s){
	if (!s){
		return '';
	}
	var ret = s.replace(/&/gi, '&amp;').replace(/>/gi,'&gt;').replace(/</gi, '&lt;').replace(/'/gi, '&apos;').replace(/"/gi, '&quot;');
//alert('after xmlencoding: \n\n\n' + ret);
	return ret;
}

function iwfHtmlDecode(s){
	if (!s){
		return '';
	}
	var ret = s.replace(/&gt;/gi, '>').replace(/&lt;/gi,'<').replace(/&apos;/gi, '\'').replace(/&quot;/gi, '"').replace(/&amp;/gi, '&');
//alert('after xmldecoding: \n\n\n' + ret);
	return ret;
}
// -----------------------------------
// End: Encoding Utility Functions
// -----------------------------------


// -----------------------------------
// Begin: Conversion / Formatting Utility Functions
// -----------------------------------

function iwfExists(){
	for(var i=0;i<arguments.length;i++){
		if(typeof(arguments[i])=='undefined') return false;
	}
	return true;
}

function iwfIsString(s){
	return typeof(s) == 'string';
}

function iwfIsNumber(n){
	return typeof(n) == 'number';
}

function iwfIsBoolean(b){
	return typeof(b) == 'boolean';
}

function iwfIsDate(val){
	var dt = iwfDateFormat(val);
	if(!dt){
		return false;
	} else {
		// determine if the month/day makes sense.
		var mo = iwfToInt(dt.substring(0,2));
		var dy = iwfToInt(dt.substring(3,2));
		var yr = iwfToInt(dt.substring(6,4));
		var maxdy = 28;
		switch(mo){
			case 4:
			case 6:
			case 9:
			case 11:
				maxdy = 30;
				break;
			case 2:
				// check leap year
				if (yr % 4 == 0 && (yr % 100 != 0 || yr % 400 == 0)){
					maxdy = 29;
				}
				break;
			default:
				// 1, 3, 5, 7, 8, 10, 12
				maxdy = 31;
				break;
		}
		return dy > 0 && dy <= maxdy;
	}
}

function iwfDateFormat(val){
	var delim = '/';
	if (val.indexOf(delim) == -1){
		delim = '-';
	}

	var today = new Date();
	var mo = '00' + (today.getMonth() + 1);
	var dy = '00' + (today.getDate());
	var yr = today.getFullYear();
	var arr = val.split(delim);
	switch(arr.length){
		case 2:
			//! possibles:  9/2, 9/2004, 09/06,
			//! assume first is always month
			mo = '00' + arr[0];
			if (arr[1].length == 4){
				//! assume second is year.
				yr = arr[1];
			} else {
				//! assume second is date.
				dy = '00' + arr[1];
			}
			break;
		case 3:
			//! possibles: 9/2/1, 9/02/04, 09/02/2004, 9/2/2004
			mo = '00' + arr[0];
			dy = '00' + arr[1];
			switch(arr[2].length){
				case 1:
					yr = '200' + arr[2];
					break;
				case 2:
					if (arr[2] < 50){
						yr = '20' + arr[2];
					} else {
						yr = '19' + arr[2];
					}
					break;
				case 3:
					//! 3 digits... assume 2000 I guess
					yr = '2' + arr[2];
					break;
				case 4:
					yr = arr[2];
					break;
				default:
					break;
			}
			break;
		default:
			// invalid date.
			return null;
			break;
	}
	mo = mo.substring(mo.length - 2);
	dy = dy.substring(dy.length - 2);
	return mo + '/' + dy + '/' + yr;

}

function iwfToInt(val, stripFormatting){
	var s = iwfIntFormat(val, stripFormatting);
	return parseInt(s, 10);
}

function iwfToFloat(val, dp, stripFormatting){
	var s = iwfFloatFormat(val, dp, stripFormatting);
	return parseFloat(s);
}

function iwfIntFormat(val, stripFormatting){
	return iwfFloatFormat(val, -1, stripFormatting);
}

function iwfFloatFormat(val, dp, stripFormatting){
	if (stripFormatting && iwfIsString(val)){
		val = val.replace(/[^0-9\.]/gi,'');
	}
	if (isNaN(val)) {
		val = 0.0;
	}

	var s = '' + val;
	var pos = s.indexOf('.');
	if (pos == -1) {
		s += '.';
		pos += s.length;
	}
	s += '0000000000000000000';
	s = s.substr(0,pos+dp+1);
	return s;
}

// -----------------------------------
// End: Conversion / Formatting Utility Functions
// -----------------------------------

// -----------------------------------
// Begin: Form Submittal Utility Functions
// -----------------------------------
function iwfDoAction(act, frm, id, targetElement){
	// validate the form first
	if (window.iwfOnFormValidate){
		if (!iwfOnFormValidate(act)){
			return;
		}
	}

	var frmId = frm;
	// try by id first...
	frm = iwfGetForm(frmId);

	if (!frm){
		iwfLog('IWF Core Error: Could not locate form with id or name of ' + frmId, true);
		return;
	}

	// get or create the iwfId
	var elId = iwfGetOrCreateById('iwfId', 'input');

	if (!elId){
		iwfLog('IWF Core Error: Could not create iwfId element!', true);
		return;
	} else {
		iwfAttribute(elId, 'value', id);
		iwfRemoveAttribute(elId, 'disabled');

		if (!iwfGetParent(elId)){
			// our element has not been added to the document yet.
			iwfAttribute(elId, 'type', 'hidden');
			if (!iwfAddChild(frm, elId)){
				iwfLog('IWF Core Error: Created iwfId element, but could not append to form ' + frm.outerHTML, true);
				return;
			}
		}
	}


	// get or create the iwfMode
	var elMode = iwfGetOrCreateById('iwfMode', 'input');
	if (!elMode){
		iwfLog('IWF Core Error: Could not create iwfMode element!', true);
		return;
	} else {
		iwfAttribute(elMode, 'value', act);
		iwfRemoveAttribute(elMode, 'disabled');
		if (!iwfGetParent(elMode)){
			// our element has not been added to the document yet.
			iwfAttribute(elMode, 'type', 'hidden');
			if (!iwfAddChild(frm, elMode)){
				iwfLog('IWF Core Error: Created iwfMode element, but could not append to form ' + frm.outerHTML, true);
				return;
			}
		}
	}

	// make our request
	var elRealTarget = iwfGetById(targetElement);
	if (elRealTarget){
		// use ajax because they specified a particular element to shove the results into.

		// get or create the iwfTarget
		var elTarget = iwfGetOrCreateById('iwfTarget', 'input');
		if (!elTarget){
			iwfLog('IWF Core Error: Could not create iwfTarget element under form ' + frm.outerHTML, true);
			return;
		} else {
			iwfAttribute(elTarget, 'value', iwfAttribute(elRealTarget, 'id'));
			iwfRemoveAttribute(elTarget, 'disabled');
			if (!iwfGetParent(elTarget)){
				// our element has not been added to the document yet.
				iwfAttribute(elTarget, 'type', 'hidden');
				if (!iwfAddChild(frm, elTarget)){
					iwfLog('IWF Core Error: Created iwfTarget element, but could not append to form ' + frm.outerHTML, true);
					return;
				}
			}
		}

		if (!window.iwfRequest){
			iwfLog("IWF Core Error: when using the iwfDo* functions and passing a targetElement, you must also reference the iwfajax.js file from your main html file.", true);
		} else {
//alert('calling iwfRequest(' + frm + ')');
			iwfRequest(frm);
		}
	} else {
		// do a normal html submit, since they didn't specify a particular target
iwfLog('doing frm.submit()', true);
		frm.submit();
	}
}

function iwfDoEdit(formId, id, targetElement){
		iwfDoAction('edit', formId, id, targetElement);
}
function iwfDoSave(formId, id, targetElement){
		iwfDoAction('save', formId, id, targetElement);
}
function iwfDoDelete(formId, id, targetElement){
		iwfDoAction('delete', formId, id, targetElement);
}
function iwfDoAdd(formId, id, targetElement){
		iwfDoAction('add', formId, id, targetElement);
}
function iwfDoSelect(formId, id, targetElement){
		iwfDoAction('select', formId, id, targetElement);
}
function iwfDoCancel(formId, id, targetElement){
		iwfDoAction('cancel', formId, id, targetElement);
}

function iwfMailTo(uid, host){
	// this is just so an email doesn't have to be output to the browser in raw text for
	// email harvesters to grab...
	location.href = 'mailto:' + uid + '@' + host;
}

function iwfClickLink(id){
	var el = iwfGetById(id);
	if (!el) return;

	if (el.click){
		el.click();
	} else {
		location.href = el.href;
	}
}

function iwfShowMessage(msg){
	var el = iwfGetById('msg');
	if (!el){
//		window.status = msg;
		alert(msg + '\n\nTo supress this alert, add a tag with an id of "msg" to this page.');
	} else {
		el.innerHTML = msg.replace(/\n/, '<br />');
	}
}


// -----------------------------------
// End: Form Submittal Utility Functions
// -----------------------------------

// -----------------------------------
// Begin: Logging Utility Functions
// -----------------------------------

var _iwfLoggedItems = "";
function iwfLog(txt, showAlert){
	if (_iwfLoggingEnabled){
		_iwfLoggedItems += txt + '\n';
	} else {
		//! send to big bit bucket in the sky (/dev/null)
	}
	if (showAlert){
		alert(txt);
	}
}

function iwfHideLog(){
	iwfGetById("iwfLog").style.display="none";
}

function iwfClearLog(){
	_iwfLoggedItems = '';
	iwfRefreshLog();
}

function iwfRefreshLog(){
	iwfHideLog();
	iwfShowLog();
}

function iwfShowLog(){
	if (!_iwfLoggingEnabled){
		alert("Logging for IWF has been disabled.\nSet the _iwfLoggingEnabled variable located in the iwfcore.js (or iwfconfig.js) file to true to enable logging.");
	} else {
		var el = iwfGetOrCreateById('iwfLog', 'div', 'body');
		if (!el){
			alert(_iwfLoggedItems);
		} else {
			el.style.position = 'absolute';
			el.style.zIndex = '999999';
			el.style.left = '10px';
			el.style.top = '200px';
			el.style.color = 'blue';
			el.style.width = '500px';
			el.style.height = '300px';
			el.style.overflow = 'scroll';
			el.style.padding = '5px 5px 5px 5px;'
			el.style.backgroundColor = '#efefef';
			el.style.border = '1px dashed blue';
			el.style.display = 'block';
			el.style.visibility = 'visible';
			el.id = 'iwfLog';
//			el.innerHTML = "IWF Log <span style='width:100px'>&nbsp;</span><a href='javascript:iwfRefreshLog();'>refresh</a> <a href='javascript:iwfHideLog();'>close</a> <a href='javascript:iwfClearLog();'>clear</a>:<hr />" + iwfXmlEncode(_iwfLoggedItems).replace(/\n/gi, '<br />').replace(/\t/gi,'&nbsp;&nbsp;&nbsp;&nbsp;');
			el.innerHTML = "IWF Log <span style='width:100px'>&nbsp;</span><a href='javascript:iwfRefreshLog();'>refresh</a> <a href='javascript:iwfHideLog();'>close</a> <a href='javascript:iwfClearLog();'>clear</a>:<hr /><pre>" + _iwfLoggedItems.replace(/</gi, '&lt;').replace(/>/gi, '&gt;') + "</pre>";

		}
	}
}


// -----------------------------------
// End: Logging Utility Functions
// -----------------------------------
