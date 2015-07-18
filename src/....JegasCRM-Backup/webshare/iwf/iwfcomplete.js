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
//!  To rip out all comments (LGPL or otherwise):
//!            ^\t*//(.*|$)
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
var _iwfDebugging = false;

// -----------------------------------
// End: Configurable variables
// -----------------------------------

var __iwfCoreIncluded = true;


// -----------------------------------
// Begin: Element Utility Functions
// -----------------------------------

function iwfGetById(id){
	var el = null;
	if (iwfIsString(id) || iwfIsNumber(id)) {
		el = document.getElementById(id);
	}	else if (typeof(id) == 'object') {
		el = id;
	}
	return el;
}

function _iwfTextRecurse(el, remove){
	//iwfLog(iwfAttribute(el, 'nodeType'), true);
	if (iwfAttribute(el, 'nodeType') == 3){ // 3 is #text in xml parlance. 1 is "normal" element.
		// text node. return node value.
		if (remove > 0){
			iwfRemoveNode(el);
			return null;
		} else {
			var val = iwfAttribute(el, 'nodeValue');
			//iwfLog("found text node, returning value of '" + val + "'", true);
			return val;
		}
	} else {
		if (remove > 0){
			for(var i=0;i<el.childNodes.length;i++){
				_iwfTextRecurse(el.childNodes[0], remove+1);
				iwfRemoveNode(el.childNodes[0]);
			}
			if (remove > 1) {
				iwfRemoveNode(el);
			}
			return null;
		} else {
			var s = '';
			for(var i=0;i<el.childNodes.length;i++){
				var c = el.childNodes[i];
				s += _iwfTextRecurse(c, remove);
			}
			return s;
		}
	}
}

function iwfText(id, newText){
	var el = iwfGetById(id);
	if (!el) { iwfLog("could not find " + id, true); return null; }

	if (!newText){
		// read existing text
		var txt = iwfAttribute(el, 'innerText');
		if (!txt){
			txt = _iwfTextRecurse(el, 0);
		}
		return txt;

	} else {
		// blow away all existing children (elements or text nodes, regardless)
		_iwfTextRecurse(el, 1);

		// write one text node
		iwfAddText(el, newText);

		return null;
	}


}

function iwfCreateText(txt){
	var el = document.createTextNode(txt);
	if (!el){
		iwfLogFatal("could not create text node for text '" + txt + "'", true);
	}
	return el;
}

function iwfAddText(id, txt){
	var el = iwfGetById(id);
	if (!el) { return null; }
	return iwfAddChild(el, iwfCreateText(txt));
}

function iwfHtml(id, html){
	var el = iwfGetById(id);
	if (!el) { return null; }
	if (html){
		el.innerHTML = html;
	}
	return el.innerHTML;
}

function iwfAddHtml(id, html){
	var el = iwfGetById(id);
	if (!el) { return null; }
	el.innerHTML += html;
	return el;
//	var newEl = iwfCreateHtml(null, html);
//	if (!newEl){
//		iwfLogFatal("could not add html '" + html + "' to element id=" + id);
//	}
//	return newEl;
}

function iwfCreateTag(id, tagName){
	var el = document.createElement(tagName);
	if (!el){
		iwfLogFatal("could not create element '" + tagName + "'", true);
	} else {
		if (id){
			iwfAttribute(el, 'id', id);
		}
	}
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

function iwfCreateByNameWithinForm(form, nm, tagName, typeAtt, elParent){
	var elFrm = iwfGetForm(form);
	if (!elFrm){
		iwfLogFatal("IWF Core Error: Could not locate form by id, document.forms, or document[] named '" + form + "'", true);
		return false;
	}
	var el = iwfCreateTag(null, tagName);
	if (!el){
		return null;
	}
	iwfAttribute(el, 'name', nm);

	if (typeAtt){
		iwfAttribute(el, 'type', typeAtt);
	}

	elParent = iwfGetById(elParent);
	if (elParent){
		elParent.appendChild(el);
	} else {
		elFrm.appendChild(el);
	}
	return el;
}

function iwfGetByNameWithinForm(form, nm){
	var el = null;
	var frm = iwfGetForm(form);
	if (!frm){
		iwfLogFatal("IWF Core Error: Could not locate form by id, document.forms, or document[] named '" + form + "'", true);
	} else {
		// find element within this form with given id.
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
	}
	return el;
}

function iwfGetOrCreateByNameWithinForm(form, nm, tagNameOrHtml, typeAtt, elParent){
	var elFrm = iwfGetForm(form);

	if (!elFrm){
		iwfLogFatal("IWF Core Error: <form> with name or id of '" + form + "' could not be located.", true);
		return null;
	}

	var el = iwfGetByNameWithinForm(form, nm);
	if (!el){
		// element does not exist. create it.
		el = iwfCreateByNameWithinForm(form, nm, tagNameOrHtml, typeAtt, elParent);
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

function iwfGetOrCreateById(id, tagName, parentNodeId){
	var el = iwfGetById(id);
	if (!el){
		// element does not exist. create it.
		el = iwfCreateTag(id, tagName);
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
		if (!elChild) { return null; }

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
	//iwfLog(iwfElementToString(el), true);
	if (!el || !elParent) { return false; }
	elParent.removeChild(el);
	return true;
}

function iwfElementToString(id){
	var el = iwfGetById(id);
	if (!el) { return 'element ' + id + ' does not exist.'; }

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
			if (callback) { callback(list[i]); }
		}
	}
	return found;
}

function iwfAttribute(id, attName, newval){
	var el = iwfGetById(id);
	if (!el) { return null; }

	var val = null;
	if (iwfExists(newval)){
		if (newval == null){
			// remove it, don't set it to null.
			iwfRemoveAttribute(el, attName);
		} else {
			if (el[attName]){
				el[attName] = newval;
			} else {
				el.setAttribute(attName, newval);
			}
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
	if (!el) { return null; }
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
		if(typeof(arguments[i])=='undefined') { return false; }
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

function iwfLastDay(val){

	var maxdy = -1;
	var dt = iwfDateFormat(val);
	var mo = iwfToInt(dt.substring(0,2));
	var dy = iwfToInt(dt.substring(3,2));
	var yr = iwfToInt(dt.substring(6,4));
	maxdy = 28;
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

	return maxdy;
}

function _iwfIsDateObject(val){
	return (typeof(val) == 'object' && val.getMonth && val.getDate && val.getFullYear);
}

function iwfIsDate(val){
	if (_iwfIsDateObject(val)){
		return true;
	}

	var dt = iwfDateFormat(val);
	if(!dt){
		return false;
	} else {
		// determine if the month/day makes sense.
		var lastdy = iwfLastDay(dt);
		return lastdy > 0;
	}
}

function iwfDateFormat(val){
	if (_iwfIsDateObject(val)){
		var mo = '00' + (val.getMonth() + 1);
		mo = mo.substring(mo.length - 2);
		var dt = '00' + val.getDate();
		dt = dt.substring(dt.length - 2);
		return mo + '/' + dt + '/' + val.getFullYear();
	}

	if (!val) { return ''; }

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
			//! possibles: 9/2/1, 9/02/04, 09/02/2004, 9/2/2004, 2004/09/02, 2004/9/2, 2004/9/02
			var yridx = 0;
			if (arr[0].length == 4){
				mo = '00' + arr[1];
				dy = '00' + arr[2];
			} else {
				mo = '00' + arr[0];
				dy = '00' + arr[1];
				yridx = 2;
			}
			switch(arr[yridx].length){
				case 1:
					yr = '200' + arr[yridx];
					break;
				case 2:
					if (arr[yridx] < 50){
						yr = '20' + arr[yridx];
					} else {
						yr = '19' + arr[yridx];
					}
					break;
				case 3:
					//! 3 digits... assume 2000 I guess
					yr = '2' + arr[yridx];
					break;
				case 4:
					yr = arr[yridx];
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
	if (dy.length > 4){
		dy = dy.substr(2, 2);
	} else {
		dy = dy.substring(dy.length - 2);
	}
	return mo + '/' + dy + '/' + yr;

}

var __iwfMonthArray = new Array('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
var __iwfWeekArray = new Array('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');

function iwfToDate(val){
	if (_iwfIsDateObject(val)){
		return val;
	}
	var sdt = iwfDateFormat(val);
	if (sdt){
		return new Date(sdt.substring(6,4), parseInt(sdt.substring(0,2),10) - 1, sdt.substring(3,2));
	} else {
		return null;
	}
}

var iwfIntMinValue = -2147483648; // min value for 4 signed bytes
var iwfIntMaxValue = 2147483648;  // max value for 4 signed bytes

function iwfRandomInt(minValue, maxValue){
	if (!iwfExists(minValue) || !iwfIsNumber(minValue)){
		minValue = iwfIntMinValue;
	}
	if (!iwfExists(maxValue) || !iwfIsNumber(maxValue)){
		maxValue = iwfIntMaxValue;
	}

	if (minValue > maxValue){
		iwfLogFatal("invalid values for minValue (" + minValue + ") and maxValue (" + maxValue + ") in function iwfRandomInt.", true);
	}
//	alert(minValue + '\n' + maxValue);

	var range = Math.abs(maxValue - minValue);
	var newValue = Math.floor(Math.random() * range);
	newValue += minValue;
//	alert('range=' + range + ' for min=' + minValue + ' and max=' + maxValue + '\nnewvalue=' + newValue);
	return newValue;
}

function iwfDateFormatLong(val){
	var dt = iwfToDate(val);
	return __iwfWeekArray[dt.getDay()] + ', ' + __iwfMonthArray[dt.getMonth()] + ' ' + dt.getDate() + ' ' + dt.getFullYear();
}

function iwfDateFormatPretty(val){
	var dt = iwfToDate(val);
	return __iwfWeekArray[dt.getDay()] + ', ' + __iwfMonthArray[dt.getMonth()] + ' ' + dt.getDate();
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
		val = val.replace(/[^0-9\.\-]/gi,'');
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
		iwfLogFatal('IWF Core Error: Could not locate form with id or name of ' + frmId, true);
		return;
	}

	// get or create the iwfId
	var elId = iwfGetOrCreateById('iwfId', 'input');

	if (!elId){
		iwfLogFatal('IWF Core Error: Could not create iwfId element!', true);
		return;
	} else {
		iwfAttribute(elId, 'value', id);
		iwfRemoveAttribute(elId, 'disabled');

		if (!iwfGetParent(elId)){
			// our element has not been added to the document yet.
			iwfAttribute(elId, 'type', 'hidden');
			if (!iwfAddChild(frm, elId)){
				iwfLogFatal('IWF Core Error: Created iwfId element, but could not append to form ' + frm.outerHTML, true);
				return;
			}
		}
	}


	// get or create the iwfMode
	var elMode = iwfGetOrCreateById('iwfMode', 'input');
	if (!elMode){
		iwfLogFatal('IWF Core Error: Could not create iwfMode element!', true);
		return;
	} else {
		iwfAttribute(elMode, 'value', act);
		iwfRemoveAttribute(elMode, 'disabled');
		if (!iwfGetParent(elMode)){
			// our element has not been added to the document yet.
			iwfAttribute(elMode, 'type', 'hidden');
			if (!iwfAddChild(frm, elMode)){
				iwfLogFatal('IWF Core Error: Created iwfMode element, but could not append to form ' + frm.outerHTML, true);
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
			iwfLogFatal('IWF Core Error: Could not create iwfTarget element under form ' + frm.outerHTML, true);
			return;
		} else {
			iwfAttribute(elTarget, 'value', iwfAttribute(elRealTarget, 'id'));
			iwfRemoveAttribute(elTarget, 'disabled');
			if (!iwfGetParent(elTarget)){
				// our element has not been added to the document yet.
				iwfAttribute(elTarget, 'type', 'hidden');
				if (!iwfAddChild(frm, elTarget)){
					iwfLogFatal('IWF Core Error: Created iwfTarget element, but could not append to form ' + frm.outerHTML, true);
					return;
				}
			}
		}

		if (!window.iwfRequest){
			iwfLogFatal("IWF Core Error: when using the iwfDo* functions and passing a targetElement, you must also reference the iwfajax.js file from your main html file.", true);
		} else {
//alert('calling iwfRequest(' + frm + ')');
			iwfRequest(frm);
		}
	} else {
		// do a normal html submit, since they didn't specify a particular target
//iwfLog('doing frm.submit()', true);
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

function iwfCallLater(stringToEval){
	// yay for lazy evaluation outside of current activation context!
	return function() {
		eval(stringToEval);
	};
}

function iwfMailTo(uid, host){
	// this is just so an email doesn't have to be output to the browser in raw text for
	// email harvesters to grab...
	location.href = 'mailto:' + uid + '@' + host;
}

function iwfClick(id){
	var el = iwfGetById(id);
	if (!el) { return; }

	if (iwfAttribute(el, 'click')){
		el.click();
	} else {
		iwfLog("could not click '" + id + "'", true);
	}
}

function iwfClickLink(id){
	var el = iwfGetById(id);
	if (!el) { return; }

	if (el.click){
		el.click();
	} else {
		location.href = iwfAttribute(el, 'href');
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
function iwfLog(txt, showAlert){ //IWFANCHOR
	if (_iwfLoggingEnabled){
		_iwfLoggedItems += txt + '\n';
	} else {
		//! send to big bit bucket in the sky (/dev/null)
	}
	if (showAlert || _iwfDebugging){
		alert(txt);
	}
}

function iwfLogFatal(txt){ //IWFANCHOR
	iwfLog(txt, true); //IWFANCHOR
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
			el.style.padding = '5px 5px 5px 5px;';
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
// --------------------------------------------------------------------------
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
// --------------------------------------------------------------------------
//! NOTE: To minimize file size, strip all fluffy comments (except the LGPL, of course!)
//! using the following regex (global flag and multiline on):
//!            ^\t*//([^/!].*|$)
//!  To rip out all comments (LGPL or otherwise):
//!            ^\t*//(.*|$)
//!  To rip out only logging statements (commented or uncommented):
//!            ^/{0,2}iwfLog.*
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
//! iwfxml.js
//
// Javascript-based xml parser
//
//! Dependencies:
//! iwfcore.js
//
//! Valentin Crettaz - valentin@crettaz.ch
//! v 0.7 - 2006-08-23
//! Added the setText() function in iwfXmlNode to be able to set the text
//! content of any given node.
//! PIs are not eaten up anymore but they are stored as child nodes instead.
//! All carriage returns are replaced by spaces before parsing attributes in
//! order to accomodate element whose attributes are declared on separate lines.
//! The processing instruction are now stored at the document level in the pis array.
//! The textual content of an element is trimmed before being added to its parent
//! in order to prevent unnecessary whitespaces to be prepended/appended to the
//! text content.
//! The comment nodes are serialized on a single line instead of on multiple lines.
//! When serializing a document, the first attribute is always written on the
//! first line.
// --------------------------------------------------------------------------
//! Valentin Crettaz - valentin@crettaz.ch
//! v 0.6 - 2006-08-19
//! Added support for nodes (elements + attributes) with namespace moniker (:)
//! Note the string '__' replaces the ':' to make valid javascript.
//! So to reference a namespaced element or attribute node such as
//! SOAP:Envelope or xmlns:tns
//!     var se = doc.SOAP__Envelope.xmlns__tns;
//! The only previous alternative was:
//!     var se = doc.["SOAP:Envelope"]["xmlns:tns"];
//! Added support for retrieving the prefix and the local name of
//! namespace-qualified elements, i.e. the node representing SOAP:Envelope
//! now contains two attributes called prefix ("SOAP") and localName ("Envelope")
//! All the declared namespaces are now stored as a property map in the
//! declaring element in which the namespace prefix is the key.
// --------------------------------------------------------------------------
//! Brock Weaver - brockweaver@users.sourceforge.net
//! v 0.4 - 2006-08-15
//! Fixed xml parser so namespaced node names can be retrieved (a colon in
//! a javascript property identifier is invalid javascript, so xml nodes with
//! a name of "SOAP:Envelope" could only be referenced via doc["SOAP:Envelope"]
//! and not doc.SOAP:Envelope.  Namespaced elements now have their colon
//! silently converted to
// --------------------------------------------------------------------------
//! Brock Weaver - brockweaver@users.sourceforge.net
//! v 0.5 - 2006-08-15
//! Added support for nodes with namespace moniker (:)
//! Note the string '_-' replaces the ':' to make valid javascript.
//! So to reference a namespaced node such as SOAP:Envelope
//!     var se = doc.SOAP_-Envelope;
//! The only previous alternative was:
//!     var se = doc.["SOAP:Envelope"];
//! Thanks Val
// --------------------------------------------------------------------------
//! Brock Weaver - brockweaver@users.sourceforge.net
//! v 0.2 - 2005-11-14
//! core bug patch
// --------------------------------------------------------------------------
//! Brock Weaver - brockweaver@users.sourceforge.net
//! v 0.1 - 2005-06-05
//! Initial release.
// --------------------------------------------------------------------------
// This class is meant to ease the burden of parsing xml.
// Xml is parsed into sets of arrays, in a hierarchical format.
// Each node is an array (of length 1, if applicable)
// The root node is an exception, as it is simply a node and not an array,
// as there is always only a single root node.
// Each attribute is a property of the current element in the node array.
// Useful for loading xml from server into a nice, easy-to-use format
// --------------------------------------------------------------------------

if (!__iwfCoreIncluded){
	iwfLogFatal("IWF Dependency Error: iwfxml.js is dependent upon iwfcore.js, so you *must* reference that file first.\n\nExample:\n\n<script type='text/javascript' src='iwfcore.js'></script>\n<script type='text/javascript' src='iwfxml.js'></script>", true);
}

var __iwfXmlIncluded = true;

// -----------------------------------
// Begin: Xml Document Object
// -----------------------------------

function iwfXmlDoc(xml){
	if (!xml || xml.length == 0){
		return;
	}
	this.loadXml(xml);
}

iwfXmlDoc.prototype.loadXml = function(xml){

	// store document-level PIs
	this.pis = new Array();
	this._parsePIs(xml);

	// note this root node is not an array, as there will always be exactly 1 root.
	this.childNodes = new Array();
	var node = new iwfXmlNode(xml);
	this.childNodes.push(node);
	this[node.nodeName] = node;
}

iwfXmlDoc.prototype.outerXml = function(pretty, asHtml){
	// outputs as raw xml, optionally with pretty formatting or optionally as html (escaped <>&"' for displaying in browsers properly)
	var writer = new iwfWriter(true, pretty, asHtml);
	var buf = '';
	if (this.pis){
		for (var i = 0; i < this.pis.length; i++){
			buf += this.pis[i];
			buf += (i < this.pis.length - 1) ? "\n" : "";
		}
	}
	if ((this.childNodes != "undefined")&&(this.childNodes != undefined)){
    if (this.childNodes.length > 0){
      buf += this.childNodes[0].outerXml(writer);
    }
  };
	return buf;
}

iwfXmlDoc.prototype.toString = function(pretty, asHtml){
	return this.outerXml(pretty, asHtml);
}

iwfXmlDoc.prototype._parsePIs = function(xml){
	if (!xml || xml.length == 0) { return; }

	var BEGIN_MONIKER = "<?";
	var END_MONIKER = "?>";
	var begin = xml.indexOf(BEGIN_MONIKER);
	var end = xml.indexOf(END_MONIKER);
	while (begin > -1 && end > begin) {
		var pi = xml.substr(begin, end + END_MONIKER.length);
		this.pis.push(pi);
		xml = xml.substr(end + END_MONIKER.length);
		begin = xml.indexOf(BEGIN_MONIKER);
		end = xml.indexOf(END_MONIKER);
	}
}

// -----------------------------------
// End: Xml Document Object
// -----------------------------------


// -----------------------------------
// Begin: Xml Node Object
// -----------------------------------


// --------------------------------------------------------------------------
//! iwfXmlNode
//
//! Brock Weaver - brockweaver@users.sourceforge.net
//! v 0.1 - 2005-06-05
//! Initial release.
// --------------------------------------------------------------------------
// This class is used to represent a single xml node.
// All xml is kept except processing instructions.
// There are issues with "<" and ">" chars embedded within
// the xml as text.  This is technically not valid xml, so
// it is technically not a problem I guess.

function iwfXmlNode(xml, parent){

	this.childNodes = new Array();
	this._text = '';
	this.attributes = new Array();
	this.attributeNames = new Array();
	this.attributeQuotes = new Array();
	this.namespaces = new Array();
	this.nodeName = 'UNKNOWN';
	this._parent = parent;
	this._isEmpty = false;


	if (!xml || xml.length == 0){
		return;
	} else {
		this._parseXml(xml);
	}

	this._htmlMode = false;


}

iwfXmlNode.prototype.toString = function(innerOnly){
	if (innerOnly){
		return this.innerXml();
	} else {
		return this.outerXml();
	}
}

iwfXmlNode.prototype.cloneNode = function(addToParent){
	var copy = new iwfXmlNode(this.outerXml());
	if (addToParent) {
		copy._parent = this._parent;
		// push it onto the parent's object's array
		copy._parent[copy.nodeName].push(copy);
		// push it onto the parent's childNodes array
		var originalIndex = this._parent.indexOfNode(this);
		if (originalIndex < 0) {
			//should never happen, but still append the node at the end
			originalIndex = this._parent.childNodes.length - 1;
		}
		var deleteCount = this._parent.childNodes.length - originalIndex - 1;
		var endArray = this._parent.childNodes.splice(originalIndex + 1, deleteCount);
		this._parent.childNodes = this._parent.childNodes.concat(copy, endArray);
	}
	return copy;
}

iwfXmlNode.prototype.outerXml = function(writer){
	return this._serialize(writer, false, false, false);
}

iwfXmlNode.prototype.innerXml = function(writer){
	return this._serialize(writer, true, false, true);
}

iwfXmlNode.prototype.outerHtml = function(writer) {
	return this._serialize(writer, false, true, false);
}

iwfXmlNode.prototype.innerHtml = function(writer) {
	return this._serialize(writer, true, true, true);
}

iwfXmlNode.prototype._serialize = function(writer, pretty, asHtml, innerOnly){
	var pretty = false;
	if (iwfIsBoolean(writer)){
		pretty = writer;
		writer = false;
	}
	if (!writer){
		writer = new iwfWriter(true, pretty, asHtml);
	}

	if (!innerOnly){
		writer.writeNodeOpen(this.nodeName);
		for(var i=0;i<this.attributes.length;i++){
			writer.writeAttribute(i == 0, this.attributeNames[i], this.attributes[i], this.attributeQuotes[i]);
		}
	}

	writer.writeText(this._text, false);
	for(var i=0;i<this.childNodes.length;i++){
		this.childNodes[i].outerXml(writer);
	}

	if (!innerOnly){
		writer.writeNodeClose();
	}


	return writer.toString();
}

iwfXmlNode.prototype.indexOfNode = function(node){
	for (var i = 0; i < this.childNodes.length; i++) {
		if (this.childNodes[i] == node) {
			return i;
		}
	}
	return -1;
}

iwfXmlNode.prototype.removeAttribute = function(name){
	for(var i=0;i<this.attributeNames.length;i++){
		if (this.attributeNames[i] == name){

			// found the attribute. splice it out of all the arrays.
			this.attributeQuotes.splice(i, 1);
			this.attributeNames.splice(i, 1);
			this.attributes.splice(i, 1);
			// remove from our object and jump out of the loop
			delete this[name];
			break;
		}
	}
}

iwfXmlNode.prototype.removeChildNode = function(node){
	for(var i=0;i<this.childNodes.length;i++){
		if (node == this.childNodes[i]){
			// remove from childNodes array
			this.childNodes.splice(k, 1);
			var arr = this[node.nodeName];
			if (arr){
				if (arr.length > 1){
					var j = 0;
					for(j=0;i<arr.length;i++){
						if (arr[j] == node){
							arr.splice(j, 1);
							break;
						}
					}
				} else {
					delete arr;
				}
			}
			break;
		}
	}
}

iwfXmlNode.prototype.addAttribute = function(name, val, quotesToUse){
	if (!quotesToUse){
		// assume apostrophes
		quotesToUse = "'";
	}
	if (!this[name]){
		this.attributeQuotes.push(quotesToUse);
		this.attributeNames.push(name);
		this.attributes.push(val);
	}
	this[name] = val;

	//the attribute is a namespace declaration, so store it once.
	if (name.indexOf("xmlns__") == 0 && name.length > 7) {
		var prefix = name.split("__")[1];
		if (!this.namespaces[prefix]) {
			this.namespaces[prefix] = val;
		}
	}
}

iwfXmlNode.prototype.addChildNode = function(node, nodeName){
	if (nodeName && nodeName.length > 0 && nodeName.indexOf("#") == 0){
		var txt = this.trim(node);
		node = new iwfXmlNode('', this);

		// 2006-08-15 thanks Val for reporting the namespace bug...
		node.origNodeName = nodeName;
		// iwfLog('addChildNode before: ' + this.origNodeName + ' - ' + this.nodeName);
		node.nodeName = this.normalize(nodeName);
		// iwfLog('addChildNode after: ' + this.origNodeName + ' - ' + this.nodeName);

		node._text = txt;


		// push it onto the childNodes array
		this.childNodes.push(node);

	} else {

		// make a node object out of it if they gave us a string...
		if (typeof(node) == 'string'){
			node = new iwfXmlNode(node, this);
		}

		if (node.nodeName.indexOf("#") == 0){
			// is a special node -- duplicate names may exist...
			node._text = txt;

			// push it onto the childNodes array
			this.childNodes.push(node);

		} else {

			if (!this[node.nodeName]){
				// no other child node with this name exists yet.

				// make a new array off of our object
				this[node.nodeName] = new Array();
			}
			// push it onto our object's array
			this[node.nodeName].push(node);

			// push it onto the childNodes array
			this.childNodes.push(node);
		}
	}
}

iwfXmlNode.prototype.getText = function(){
	var txt = '';

	if (this.nodeName.indexOf('#') == 0){
		txt = this._text;
	}
	for(var i=0;i<this.childNodes.length;i++){
		txt += this.childNodes[i].getText();
	}
	return txt;
}

iwfXmlNode.prototype.setText = function(newText){
	//Node is already a text node
	if (this.nodeName.indexOf('#') == 0){
		this._text = newText;
	}

	//Node is an element, either create the new text node or update it
	else if (this.childNodes.length == 0) {
		this.addChildNode(newText, "#text");
	} else {
		this.childNodes[0].setText(newText);
	}
}

iwfXmlNode.prototype.findNSByPrefix = function(prefix){
	if (this.namespaces && this.namespaces[prefix]) {
		return this.namespaces[prefix];
	} else if (this._parent) {
		return this._parent.findNSByPrefix(prefix);
	} else {
		return null;
	}
}

iwfXmlNode.prototype._parseXml = function(xml){

	var remainingXml = xml;

	while(remainingXml.length > 0){
		var type = this._determineNodeType(remainingXml);
		switch(type){
			case 'open':
				remainingXml = this._parseName(remainingXml);
				remainingXml = this._parseAtts(remainingXml);
				if (this._parent){
					this._parent.addChildNode(this, null);
				}

				if (!this._isEmpty){
					remainingXml = this._parseChildren(remainingXml);
					// we still need to parse out the close node, so don't jump out yet!
				} else {
					return remainingXml;
				}
				break;

			case 'text':
				return this._parseText(remainingXml);

			case 'close':
				return this._parseClosing(remainingXml);

			case 'end':
				return '';

			case 'pi':
				// return this._parsePI(remainingXml);
				remainingXml = this._parsePI(remainingXml);
				break;

			case 'comment':
				return this._parseComment(remainingXml);

			case 'cdata':
				return this._parseCDATA(remainingXml);

			case 'directive':
				return this._parseDirective(remainingXml);

			case 'whitespace':
				remainingXml = this._parseWhitespace(remainingXml);
				if (this._parent){
					return remainingXml;
				}
				break;

			default:
				iwfLogFatal('IWF Xml Parsing Error: undefined type of ' + type + ' returned for xml starting with "' + remainingXml + '"', true);
				break;
		}

	}

	return '';

}

iwfXmlNode.prototype._determineNodeType = function(xml){


	if (!xml || xml.length == 0){
		return 'end';
	}

	var trimmed = this.ltrim(xml);

	var firstTrimmedLt = trimmed.indexOf("<");

	switch(firstTrimmedLt){
		case -1:
			// this is either insignificant whitespace or text
			if (trimmed.length == 0){
				return 'whitespace';
			} else {
				return 'text';
			}
		case 0:
			// this is either an open node or insignificant whitespace.
			var firstLt = xml.indexOf("<");
			if (firstLt > 0){
				return 'whitespace';
			} else {
				switch(trimmed.charAt(1)){
					case '?':
						return 'pi';
					case '!':
						if (trimmed.substr(0,4) == '<!--'){
							return 'comment';
						} else if (trimmed.substr(0,9) == '<![CDATA[') {
							return 'cdata';
						} else if (trimmed.toUpperCase().substr(0,9) == '<!DOCTYPE') {
							return 'directive';
						} else {
							return 'unknown: ' + trimmed.substr(0,10);
						}
					case '/':
						return 'close';
					default:
						return 'open';
				}
			}

		default:
			// this is a text node
			return 'text';
	}
}

iwfXmlNode.prototype._parseName = function(xml){
	// we know xml starts with <.

	// replace all carriage return and line feeds by a space
	xml = xml.replace("\r\n", " ");
	// replace all line feeds by a space
	xml = xml.replace("\n", " ");

	var firstSpace = xml.indexOf(" ");
	var firstApos = xml.indexOf("'");
	var firstQuote = xml.indexOf('"');
	var firstGt = xml.indexOf(">");

	if (firstGt == -1){
		iwfLogFatal("IWF Xml Parsing Error: Bad xml; no > found for an open node.", true);
		return '';
	}

	// see if it's an empty node...
	if (xml.charAt(firstGt-1) == '/'){
		this._isEmpty = true;
	}

	// see if there is a possibility that atts exist
	if (firstSpace > firstGt || firstSpace == -1){
		if (this._isEmpty){
// <h1/>
			this.nodeName = this.trim(xml.substr(1,firstGt-2));
		} else {
// <h1>
			this.nodeName = this.trim(xml.substr(1,firstGt-1));
		}
		this.origNodeName = this.nodeName;
		if (this.nodeName && this.nodeName.length > 0){
			this.nodeName = this.normalize(this.nodeName);
		}

		//store the prefix and localName separately if the element is namespaced
		this._parseQName(this.nodeName);

		// iwfLog('_parseName: ' + this.origNodeName + ' - ' + this.nodeName);

		// return starting at > so parseAtts knows there are no atts.
		return xml.substr(firstGt);
	} else {
// <h1 >
// <h1 att='val'>
// <h1 att='val'/>
		this.nodeName = this.trim(xml.substr(1,firstSpace-1));
		this.origNodeName = this.nodeName;
		if (this.nodeName && this.nodeName.length > 0){
			this.nodeName = this.normalize(this.nodeName);
		}

		//store the prefix and localName separately if the element is namespaced
		this._parseQName(this.nodeName);

		// iwfLog('_parseName (space): ' + this.origNodeName + ' - ' + this.nodeName);

		// eat everything up to the space, return the rest
		return xml.substr(firstSpace);
	}

}

iwfXmlNode.prototype._parseQName = function(qname){
	if (qname && qname.indexOf("__") > 0) {
		var parts = qname.split("__");
		this.prefix = parts[0];
		this.localName = parts[1];
	} else {
		this.localName = qname;
	}
}

iwfXmlNode.prototype._parseAtts = function(xml){


	xml = this.ltrim(xml);
	var firstGt = xml.indexOf(">");
	if (firstGt == -1){
		iwfLogFatal("IWF Xml Parsing Error: Bad xml; no > found when parsing atts for " + this.nodeName, true);
		return '';
	} else if (firstGt == 0){
		// no atts.
		return xml.substr(firstGt+1);
	} else {
		// at least one att exists.
		var attxml = xml.substr(0, firstGt);
		var re = /\s*?([^=]*?)=(['"])(.*?)(\2)/;
		var matches= re.exec(attxml);
		while(matches){
			attxml = this.ltrim(attxml.substr(matches[0].length));
			var attname = this.normalize(this.ltrim(matches[1]));
			var attval = matches[3];
			var quotesToUse = matches[2];
			this.addAttribute(attname, attval, quotesToUse);

			re = /\s*?([^=]*?)=(['"])(.*?)(\2)/;
			matches = re.exec(attxml);
		}


		// return everything after the end of the att list and the > which closes the start of the node.
		return xml.substr(firstGt+1);
	}
}

iwfXmlNode.prototype._parseChildren = function(xml){
	// we are at the > which closes the open node.

	if (xml && xml.length > 0){
		var endnode = "</" + this.origNodeName + ">";
		while (xml && xml.length > 0 && xml.indexOf(endnode) > 0){

			// do not pass the xml to the constructor, as that may cause an infinite loop.
			var childNode = new iwfXmlNode('', this);
			xml = childNode._parseXml(xml);
		}

		// note we don't cut off the close node here, as the _parseXml function will do this for us.

	}

	return xml;
}



iwfXmlNode.prototype._parseClosing = function(xml){
	var firstGt = xml.indexOf("</");
	if (firstGt == -1){
		iwfLogFatal('IWF Xml Parsing Error: Bad xml; no </' + this.origNodeName + ' found', true);
		return '';
	} else {
		var firstLt = xml.indexOf(">",firstGt);
		if (firstLt == -1){
			iwfLogFatal('IWF Xml Parsing Error: Bad xml; no > found after </' + this.origNodeName, true);
			return '';
		} else {
			var result = xml.substr(firstLt+1);
			return result;
		}
	}
}

iwfXmlNode.prototype._parseText = function(xml){
	return this._parsePoundNode(xml, "#text", "", "<", false);
}

iwfXmlNode.prototype._parsePI = function(xml){
	var result = this._eatXml(xml, "?>", true);
	return result;
}

iwfXmlNode.prototype._parseComment = function(xml){
	return this._parsePoundNode(xml, "#comment", "<!--", "-->", true);
}

iwfXmlNode.prototype._parseCDATA = function(xml){
	return this._parsePoundNode(xml, "#cdata", "<![CDATA[", "]]>", true);
}

iwfXmlNode.prototype._parseDirective = function(xml){
	return this._parsePoundNode(xml, '#directive', '<!DOCTYPE', '>', true);
}

iwfXmlNode.prototype._parseWhitespace = function(xml){
	var result = '';
	if (this._parent && this._parent.nodeName.toLowerCase() == 'pre'){
		// hack for supporting HTML's <pre> node. ugly, I know :)
		result = this._parsePoundNode(xml, "#text", "", "<", false);
	} else {
		// whitespace is insignificant otherwise
		result = this._eatXml(xml, "<", false);
	}
	return result;
}

iwfXmlNode.prototype._parsePoundNode = function(xml, nodeName, beginMoniker, endMoniker, eatMoniker){
	// simply slurp everything up until the first endMoniker, starting after the beginMoniker
	var end = xml.indexOf(endMoniker);
	if (end == -1){
		iwfLogFatal("IWF Xml Parsing Error: Bad xml: " + nodeName + " does not have ending " + endMoniker, true);
		return '';
	} else {
		var len = beginMoniker.length;
		var s = xml.substr(len, end - len);
		if (this._parent){
			this._parent.addChildNode(s, nodeName);
		}
		var result = xml.substr(end + (eatMoniker ? endMoniker.length : 0));
		return result;
	}
}

iwfXmlNode.prototype._eatXml = function(xml, moniker, eatMoniker){
	var pos = xml.indexOf(moniker);

	if (eatMoniker){
		pos += moniker.length;
	}

	return xml.substr(pos);

}

iwfXmlNode.prototype.trim = function(s){
	return s.replace(/^\s*|\s*$/g,"");
}

iwfXmlNode.prototype.ltrim = function(s){
	return s.replace(/^\s*/g,"");
}

iwfXmlNode.prototype.rtrim = function(s){
	return s.replace(/\s*$/g,"");
}

iwfXmlNode.prototype.normalize = function(nm){
//	return nm;
	return nm.replace(/:/gi, '__');
}

// -----------------------------------
// End: Xml Node Object
// -----------------------------------







// -----------------------------------
// Begin: Xml Writer Object
// -----------------------------------


// --------------------------------------------------------------------------
//! iwfWriter
//
//! Brock Weaver - brockweaver@users.sourceforge.net
//
//! v 0.1 - 2005-06-05
//! Initial release.
// --------------------------------------------------------------------------
// This class is meant to ease the creation of xml strings.
// Note it is not a fully-compliant xml generator.
// --------------------------------------------------------------------------


function iwfWriter(suppressProcessingInstruction, prettyPrint, htmlMode) {
	this._buffer = new String();
	if (!suppressProcessingInstruction){
		this.writeRaw("<?xml version='1.0' ?>");
	}
	this._nodeStack = new Array();
	this._nodeOpened = false;
	this._prettyPrint = prettyPrint;
	this._htmlMode = htmlMode;
}

iwfWriter.prototype.writePretty = function(writeLineFeed, writeTabs){
	if (this._prettyPrint){
		if (writeLineFeed){
			this.writeRaw('\n');
		}

		// assumption is most xml won't have a maximum node depth exceeding 30...
		if (writeTabs){
			var tabs = '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t';
			while (tabs.length < this._nodeStack.length){
				// but some xml might exceed node depth of 30, so keep tacking on another 30 tabs until we have enough...
				// I know this is an awkward way of doing it, but I wanted to avoid looping and concatenating for "most" xml...
				tabs += tabs;
			}
			var depth = this._nodeStack.length;
			if (depth < 0) { depth = 0; }
			this.writeRaw(tabs.substr(0,depth));
		}
	}
}

iwfWriter.prototype.writeNode = function(name, txt){
	this.writeNodeOpen(name);
	this.writeText(txt, true);
	this.writeNodeClose();
}

iwfWriter.prototype.writeNodeOpen = function(name){
	if (this._nodeOpened){
		this.writeRaw(">");
	}
	this._nodeOpened = false;

	switch(name){
		case '#pi':
			this.writePretty(true, true);
			this.writeRaw('<?');
			break;
		case '#text':
			// do nothing
			break;
		case '#cdata':
			this.writePretty(true, false);
			this.writeRaw('<![CDATA[');
			break;
		case '#comment':
			this.writePretty(true, true);
			this.writeRaw('<!--');
			break;
		default:
			this.writePretty(true, true);
			this.writeRaw("<" + this.normalize(name));
			this._nodeOpened = true;
			break;
	}
	this._nodeStack.push(name);
}

iwfWriter.prototype.writeAttribute = function(first, name, val, quotes){
	if (!this._nodeOpened){
		iwfLogFatal("IWF Xml Parsing Error: Appending attribute '" + this.normalize(name) + "' when no open node exists!", true);
	}
	var attval = val;


	if (!quotes){
		quotes = "'";
	}

	// browsers handle html attributes in a special way:
	// only the character that matches the html delimiter for the attribute should be xml-escaped.
	// the OTHER quote character (' or ", whichever) needs to be javascript-escaped,
	//
	// the iwfXmlNode class also needs the > char escaped to be functional -- I need to fix that!
	// But for right now, this hack gets things working at least.
	//
	// Like I said, I'm getting lazy :)
	//

		if (this._htmlMode){
			// we're kicking out html, so xml escape only the quote character that matches the delimiter and the > sign.
			// We also need to javascript-escape the quote char that DOES NOT match the delimiter but is xml-escaped.
			if (quotes == "'"){
				// we're using apostrophes to delimit html.
				attval = attval.replace(/&quot;/gi, '\\"').replace(/'/gi, '&apos;').replace(/>/gi, '&gt;');
			} else {
				// we're using quotes to delimit html
				attval = attval.replace(/&apos;/gi, "\\'").replace(/"/gi, '&quot;').replace(/>/gi, '&gt;');
			}
		} else {
			attval = iwfXmlEncode(attval);
		}

	if (!first) { this.writePretty(true, true); }
	this.writeRaw(" " + this.normalize(name) + "=" + quotes + attval + quotes);
}

iwfWriter.prototype.writeAtt = function(first, name, val, quotes){
	this.writeAttribute(first, name, val, quotes);
}

iwfWriter.prototype.writeText = function(txt, encodeAsXml){
	if (!txt || txt.length == 0){
		// no text to write. do nothing.
		return;
	} else {
		if (this._nodeOpened){
			this.writeRaw(">");
			this._nodeOpened = false;
		}
//		this.writeRaw('[');
		this.writePretty(true, true);
		if (encodeAsXml){
			this.writeRaw(iwfXmlEncode(txt));
		} else {
			this.writeRaw(txt);
		}
//		this.writeRaw(']');
	}
}

iwfWriter.prototype.writeNodeClose = function(){
	if (this._nodeStack.length > 0){
		var name = this._nodeStack.pop();

		switch(name){
			case '#pi':
				this.writePretty(true, true);
				this.writeRaw("?>");
				break;
			case '#text':
				// do nothing
				break;
			case '#cdata':
				this.writePretty(true, true);
				this.writeRaw("]]>");
				break;
			case '#comment':
				this.writePretty(true, true);
				this.writeRaw("-->");
				break;
			default:
				if (this._nodeOpened){
					//! hack for <script /> and <div /> needing to be <script></script> or <div></div>
					switch(name){
						case 'script':
						case 'div':
							this.writeRaw("></" + this.normalize(name) + ">");
							break;
						default:
							this.writeRaw("/>");
							break;
					}
				} else {
					this.writePretty(true, true);
					this.writeRaw("</" + this.normalize(name) + ">");
				}
				break;
		}
		this._nodeOpened = false;
	}
}

iwfWriter.prototype.writeRaw = function(xml){
	this._buffer += xml;
}

iwfWriter.prototype.toString = function(){
	return this._buffer;
}

iwfWriter.prototype.clear = function(){
	this.buffer = new String();
}

iwfWriter.prototype.normalize = function(name){
	return name.replace(/__/gi, ':');
}
// -----------------------------------
// End: Xml Writer Object
// -----------------------------------

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
// --------------------------------------------------------------------------
//! NOTE: To minimize file size, strip all fluffy comments (except the LGPL, of course!)
//! using the following regex (global flag and multiline on):
//!            ^\t*//([^/!].*|$)
//!  To rip out all comments (LGPL or otherwise):
//!            ^\t*//(.*|$)
//!  To rip out only logging statements (commented or uncommented):
//!            ^/{0,2}iwfLog.*
// --------------------------------------------------------------------------


// --------------------------------------------------------------------------
//
//! iwfajax.js
//
// Thread-safe background xml request via XmlHttpRequest object
//
//! Dependencies:
//! iwfxml.js
//! iwfcore.js
//! iwfgui.js (optional -- pretty progress bar)
//
//! Brock Weaver - brockweaver@users.sourceforge.net
// --------------------------------------------------------------------------
//! v 0.4 - 2006-05-25
//! Added rudimentary support for uploading files via an iframe request
//! Currently only works with Firefox though, still trying to rectify that.
//! This is for you, smeaggie
//!
//! Fixed bug causing select tag values to not be submitted
//! Thanks Richard
// --------------------------------------------------------------------------
//! v 0.3 - 2006-02-26
//! ajax bug patch - misnamed request variable caused spurious timer behavior
//! Thank you marbie!
// --------------------------------------------------------------------------
//! v 0.2 - 2005-11-14
//! core bug patch
// --------------------------------------------------------------------------
//! v 0.1 - 2005-06-05
//! Initial release.
//
//! Known Issues:
//!  AddToHistory does not work
//!  Iframe not implemented
//
// =========================================================================




// show progress bar if they included iwfgui.js, window.status otherwise.
var _iwfShowGuiProgress = iwfExists(window.iwfShow);






// -----------------------------------
// Begin: Dependency Check
// -----------------------------------

if (!__iwfCoreIncluded || !__iwfXmlIncluded){
	iwfLogFatal("IWF Dependency Error: iwfajax.js is dependent upon both iwfcore.js and iwfxml.js, " +
		"so you *must* reference those files first.\n\nExample:\n\n" +
		"<" + "script type='text/javascript' src='iwfcore.js'></" + "script>\n" +
		"<" + "script type='text/javascript' src='iwfxml.js'></" + "script>\n<script type='text/javascript' src='iwfajax.js'></script>",
		 true);
}

// -----------------------------------
// End: Dependency Check
// -----------------------------------

var __iwfAjaxIncluded = true;

// -----------------------------------
// Begin: AJAX Request and Response
// -----------------------------------



//-------------------------------------
// BEGIN- JEGAS LCC - LEAN POST VERSION
//-------------------------------------
function iwfRequestPost(p_sUrl, targetElementOnResponse, callback, synchronously, p_sPostData){
	// we use a javascript feature here called "inner functions"
	// using these means the local variables retain their values after the outer function
	// has returned.  this is useful for thread safety, so
	// reassigning the onreadystatechange function doesn't stomp over earlier requests.
	function iwfBindCallback(){
		if (req && req.readyState == 4) {
			// was an xmlhttp request
			_iwfOnRequestEnd();
			if (req.status == 200 || req.status == 0) {
	//iwfLog('exact response from server:\n\n' + req.responseText, true);
				_iwfResponseHandler(req.responseText, localCallback, localTarget);
			} else {
				_iwfOnRequestError(req.status, req.statusText, req.responseText);
			}
			return;
		}
	}

	if (!iwfExists(synchronously)){
		synchronously = false;
	}

	// determine how to hit the server...
	var url = p_sUrl;
	var method = 'POST';
	var postdata = "\r\n"+p_sPostData;
	var contentType = 'application/x-www-form-urlencoded';

	// use a local variable to hold our callback and target until the inner function is called...
	var localCallback = callback;
	var localTarget = targetElementOnResponse;
	// prevent any browser caching of our url by requesting a unique url everytime...
	if (location.href.indexOf('file://') > -1){
		// hack for allowing non-IIS hosted shares in IE7
		// make sure it's fully pathed and ignore timestamp parameter
		var pos = location.href.lastIndexOf('/');
		url = location.href.substring(0,pos+1) + url;
	} else {
		url += ((url.indexOf('?') > -1) ? '&' : '?') + 'iwfRequestId=' + new Date().valueOf();
	}

	//iwfLog("url = " + url);
	//iwfLog("method = " + method);
	//iwfLog("postdata = " + postdata);
	//iwfLog("contenttype = " + contentType);

        //confirm("url = " + url);
        //confirm("method = " + method);
        //confirm("postdata = " + postdata);
        //confirm("contenttype = " + contentType);



	var req = null;
	//iwfLog("using XHR to perform request...");
	// use XHR to perform the request, as this will
	// prevent the browser from adding it to history.
	req = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
  // bind our callback
	req.onreadystatechange = iwfBindCallback;

	// show progress if it's not already visible...
	_iwfOnRequestStart();

	// hit the server
  //iwfLog("opening connection...", true);
  //iwfLog('synchronously=' + synchronously);
	req.open(method, url, !synchronously);
  //iwfLog("setting header...", true);
	req.setRequestHeader('Content-Type', contentType);
  //iwfLog("sending request...", true);
	req.send(postdata);
  //iwfLog("request sent.", true);

	// if synchronously, the inner function is not called.  call it here.
	if (synchronously){
    //iwfLog('sync, response=\n' + req.responseText + '\n\n\n  calling ResponseHandler...');
		_iwfOnRequestEnd();
		_iwfResponseHandler(req.responseText, localCallback, localTarget);
	}

	// if this is called from the form.onsubmit event, make sure the form doesn't submit...
	// return absolutely nothing so anchor tags don't hork the current page
}
//-------------------------------------
// END--- JEGAS LCC - LEAN POST VERSION
//-------------------------------------



function iwfRequestSync(urlOrForm, targetElementOnResponse, addToHistory, callback){
	return iwfRequest(urlOrForm, targetElementOnResponse, addToHistory, callback, true);
}

function iwfRequest(urlOrForm, targetElementOnResponse, addToHistory, callback, synchronously){

	// we use a javascript feature here called "inner functions"
	// using these means the local variables retain their values after the outer function
	// has returned.  this is useful for thread safety, so
	// reassigning the onreadystatechange function doesn't stomp over earlier requests.

	function iwfBindCallback(){
		if (req && req.readyState == 4) {
			// was an xmlhttp request
			_iwfOnRequestEnd();
			if (req.status == 200 || req.status == 0) {
	//iwfLog('exact response from server:\n\n' + req.responseText, true);
				_iwfResponseHandler(req.responseText, localCallback, localTarget);
			} else {
				_iwfOnRequestError(req.status, req.statusText, req.responseText);
			}
			return;
		}
	}

	if (!iwfExists(synchronously)){
		synchronously = false;
	}

	// determine how to hit the server...
	var url = null;
	var method = 'GET';
	var postdata = null;
	var isFromForm = true;
	var contentType = 'application/x-www-form-urlencoded';
  if (iwfIsString(urlOrForm)){
		// if we get here, they either specified the url or the name of the form.
		// either way, flag so we return nothing.
		isFromForm = false;

		var frm = iwfGetForm(urlOrForm);
		if (!frm){
			// is a url.
			url = urlOrForm;
			method = 'GET';
			postdata = null;
		} else {
			// is name of a form.
			// fill with the form object.
			urlOrForm = frm;
		}
    


	}

	// use a local variable to hold our callback and target until the inner function is called...
	var localCallback = callback;
	var localTarget = targetElementOnResponse;
  if (!iwfIsString(urlOrForm)){
    confirm('!iwfIsString(urlOrForm)');
		var ctl = null;


		// is a form or a control in the form.
		if (iwfExists(urlOrForm.form)){
			// is a control in the form. jump up to the form.
			ctl = urlOrForm;
			urlOrForm = urlOrForm.form;
		}


		// if they passed a form and no local target, lookup the form.iwfTarget attribute and use it if possible
		if (!localTarget){
				localTarget = iwfAttribute(urlOrForm, 'iwfTarget');
		}

		if (localTarget){
			var elTgt = iwfGetOrCreateByNameWithinForm(urlOrForm, 'iwfTarget', 'input', 'hidden');
			if (elTgt){
				iwfAttribute(elTgt, 'value', localTarget);
				iwfRemoveAttribute(elTgt, 'disabled');
			}
		}


		url = urlOrForm.action;
		method = urlOrForm.method.toUpperCase();


		// if there are any files to upload, do them using the traditional
		// file upload via a hidden iframe tag...
		var iframe = _iwfUploadFiles(urlOrForm, localCallback, localTarget);
		if (!iframe){
			switch(method){
				case "POST":

					postdata = _iwfGetFormData(urlOrForm, url, ctl);

					// we also need to properly set the content-type header...
					var frm = iwfGetForm(urlOrForm);
					if (frm){
						var enc = iwfAttribute(frm, 'encoding');
						if (!enc){
							enc = iwfAttribute(frm, 'enctype');
						}
						if (enc){
							contentType = enc;
						}
					}

					break;
				case "GET":
				default:
					url = _iwfGetFormData(urlOrForm, url, ctl);
					break;
			}
		} else {
			// we uploaded via the iframe. nothing to do
		}

	}

	if (iframe){
		// form contained a <input type='file'> element, so
		// we already created an iframe and posted it.

	} else {
		// prevent any browser caching of our url by requesting a unique url everytime...
		if (location.href.indexOf('file://') > -1){
			// hack for allowing non-IIS hosted shares in IE7
			// make sure it's fully pathed and ignore timestamp parameter
			var pos = location.href.lastIndexOf('/');
			url = location.href.substring(0,pos+1) + url;
		} else {
			url += ((url.indexOf('?') > -1) ? '&' : '?') + 'iwfRequestId=' + new Date().valueOf();
		}

	//iwfLog("url = " + url);
	//iwfLog("method = " + method);
	//iwfLog("postdata = " + postdata);
	//iwfLog("contenttype = " + contentType);

        //confirm("url = " + url);
        //confirm("method = " + method);
        //confirm("postdata = " + postdata);
        //confirm("contenttype = " + contentType);



		var req = null;
		if (!addToHistory){
	//iwfLog("using XHR to perform request...");
			// use XHR to perform the request, as this will
			// prevent the browser from adding it to history.
			req = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");

			// bind our callback
			req.onreadystatechange = iwfBindCallback;

			// show progress if it's not already visible...
			_iwfOnRequestStart();

			// hit the server
//iwfLog("opening connection...", true);
//iwfLog('synchronously=' + synchronously);
			req.open(method, url, !synchronously);
//iwfLog("setting header...", true);
			req.setRequestHeader('Content-Type', contentType);
//iwfLog("sending request...", true);
			req.send(postdata);
//iwfLog("request sent.", true);

			// if synchronously, the inner function is not called.  call it here.
			if (synchronously){
//iwfLog('sync, response=\n' + req.responseText + '\n\n\n  calling ResponseHandler...');
				_iwfOnRequestEnd();
				_iwfResponseHandler(req.responseText, localCallback, localTarget);
			}

		} else {
			// use an IFRAME element to perform the request,
			// as this will cause the browser to add it to history.
			// TODO: make this work!!!
iwfLog("using IFRAME to perform request...");
iwfLog('request and add to history not implemented yet!!!', true);
			return;

			var el = iwfGetById("iwfHistoryFrame");
			if (!el){
				iwfLogFatal("To enable history tracking in IWF, you must add an invisible IFRAME element to your page:\n<IFRAME id='iwfHistoryFrame' style='display:none'></IFRAME>", true);
			}

			el.src = url;

			// show progress if it's not already visible...
			_iwfOnRequestStart();


		}

	}

	// if this is called from the form.onsubmit event, make sure the form doesn't submit...
	if (isFromForm){
		return false;
	} else {
		// return absolutely nothing so anchor tags don't hork the current page
	}

}

function _iwfGetFormData(form, url, ctl){

	var method = form.method;
	if (!method) { method = "get"; }

	var output = null;

	if (method == 'get'){
		output = url + ((url.indexOf('?') > -1) ? '&' : '?');
	} else {
		output = '';
	}


	// if there is a target specified in the <form> tag,
	// copy its contents to a hidden <input type='hidden'> tag.

//iwfLog("total elements in form named '" + form.name + "': " + form.elements.length);
	for(var i=0;i<form.elements.length;i++){
		var el = form.elements[i];
		var nm = iwfAttribute(el, 'name');
		var val = null;
		if (!iwfAttribute(el, 'disabled') && nm){
			switch (el.tagName.toLowerCase()){
				case 'input':
					switch(iwfAttribute(el, 'type')){
						case 'checkbox':
						case 'radio':
							if (iwfAttribute(el, 'checked')){
								val = iwfAttribute(el, 'value');
							}
							break;
						case 'button':
							if (el == ctl){
								val = iwfAttribute(el, 'value');
							}
							break;
						case 'submit':
							if (el == ctl){
								val = iwfAttribute(el, 'value');
							}
							break;
						case 'text':
						default:
							val = iwfAttribute(el, 'value');
							break;
						case 'file':
							// note: see the _iwfUploadFiles() method that is called before we enter this loop!
//							iwfLog('TODO: implement <input type="file"> in _iwfGetFormData', true);
							val = iwfAttribute(el, 'value');
							break;
						case 'image':
							iwfLogFatal('TODO: implement <input type="image"> in _iwfGetFormData', true);
							val = iwfAttribute(el, 'value');
							break;
						case 'reset':
							iwfLogFatal('TODO: implement <input type="reset"> in _iwfGetFormData', true);
							break;
						case 'hidden':
							val = iwfAttribute(el, 'value');
							break;
					}
					break;
				case 'textarea':
					val = iwfAttribute(el, 'innerText');
					break;
				case 'button':
					if (el == ctl){
						val = iwfAttribute(el, 'innerText');
					}
					break;
				case 'select':
					for(var j=0;j<el.options.length;j++){
						// 2006-05-25 fixed this if check, thanks Richard
						if (iwfAttribute(el.options[j], 'selected')){
							if (!val){
								val = iwfAttribute(el.options[j], 'value');
							} else {
								val += '+' + iwfAttribute(el.options[j], 'value');
							}
						}
					}
			}

			if (val){
				if (output.length > 0){
					output += '&';
				}
				output += escape(nm) + '=' + escape(val);
			}
		}
	}
//iwfLog('sending via xmlhttp:\n' + output, true);
	if (output.length == 0){
		return null;
	} else {
		return output;
	}
}

function _iwfResponseReceived(doc){
iwfLog('iframeloaded');
	var xmlDoc = new iwfXmlDoc(doc.innerHTML);
}

function _iwfResponseHandler(origText, callback, tgt){
	var doc = new iwfXmlDoc(origText);
	iwfLog(doc.outerXml(true));
	if (!doc.response){
		// not in our default xml format.
		// just throw out the xml to the callback, if any
		if (callback){
			callback(doc);
		} else {
			iwfLogFatal("IWF Ajax Error: No callback defined for non-standard response:\n" + origText, true);
		}
	} else {
		if (doc.response.debugging == 'true'){
			iwfLoggingEnabled = true;
			iwfLog("IWF Ajax Debugging:\nParsed response:\n\n" + doc.response.outerXml(true), true);
			iwfShowLog();
		}

		// 2006-02-28 Thanks to Colin, targets are now properly reset on each iteration...
		var origTgt = tgt;

		for(var i=0; i< doc.response.childNodes.length; i++){
			var node = doc.response.childNodes[i];
			tgt = origTgt;
			if (node.nodeName.indexOf("#") != 0){
//iwfLog('node.target=' + node.target + '\ntgt=' + tgt);
				if (!tgt) {
					// server target is ignored if a client target exists.
					tgt = node.target;
				}
        //------------------------------
        // BEGIN --JEGAS - trying handling errors on client side in callback
        // so we comment these lines out
        //------------------------------
        //if (node.errorCode && iwfToInt(node.errorCode, true) != 0){
				//	// an error occurred.
        //  _iwfOnRequestError(node.errorCode, node.errorMessage);
				//} else
        //------------------------------
        // END --JEGAS - don't forget to pull up bracket below to the else we commented out.
        //------------------------------
        {
					if (!node.type){
						node.type = "";
					}
					switch(node.type.toLowerCase()){
						case "html":
						case "xhtml":
							var innerHtml = node.innerHtml();
//iwfLog('parsed html response:\n\n' + innerHtml);
							_iwfInsertHtml(innerHtml, tgt);
							break;
						case "javascript":
						case "js":
							var bomb = true;
							if (node.childNodes.length == 1){
								var js = node.childNodes[0];
								if (js.nodeName == '#cdata' || js.nodeName == '#comment'){
									bomb = false;
									var code = js.getText();
									eval(code);
								}
							}
							if (bomb){
								iwfLogFatal("IWF Ajax Error: When an <action> is defined of type javascript, it content must be contained by either a Comment (<!-- -->) or CDATA (<![CDATA[  ]]>).\nCDATA is the more appropriate manner, as this is the xml-compliant one.\nHowever, COMMENT is also allowed as this is html-compliant, such as within a <script> element.\n\n<action> xml returned:\n\n" + node.outerXml(), true);
							}
							break;
						case "xml":
							if (callback){
								callback(node);
							}
							break;
						case "debug":
							iwfLogFatal("IWF Debug: <action> type identified as 'debug'.\nXml received for current action:\n\n" + node.outerXml(), true);
							break;
						default:
							iwfLogFatal('IWF Ajax Error: <action> type of "' + node.type + '" is not a valid option.\n\nValid options:\n\'html\' or \'xhtml\' = parse as html and inject into element with the id specified by the target attribute\n\'javascript\' or \'js\' = parse as javascript and execute\n\'xml\' = parse as xml and call the callback specified when iwfRequest() was called\n\'debug\' = parse as xml and log/alert the result\n\n<action> xml returned:\n\n' + node.outerXml(), true);
							break;
					}
				}
			}
		}
	}

}

function _iwfInsertHtml(html, parentNodeId){
	if(!parentNodeId){
		parentNodeId = 'iwfContent';
		iwfLog("IWF Ajax Warning: <action> with a type of 'html' does not have its target attribute specified, so using the default of 'iwfContent'.");
	}

	if(!parentNodeId){
			iwfLogFatal("IWF Ajax Error: <action> node with a type of 'html' does not have its target attribute specified to a valid element.\nPlease specify the id of the element into which the contents of the <action> node should be placed.\nTo fill the entire page, simply specify 'body'.", true);
	} else {
		var el = iwfGetById(parentNodeId);
		if (!el){
			if (parentNodeId == 'body'){
				el = iwfGetByTagName('body');
				if (!el || el.length == 0){
					iwfLogFatal("IWF Ajax Error: Could not locate the tag named 'body'", true);
					return;
				} else {
					el = el[0];
				}
			} else {
					iwfLogFatal('IWF Ajax Error: Could not locate element with id of ' + parentNodeId + ' into which the following html should be placed:\n\n' + html, true);
					return;
			}
		}

//iwfLog(iwfElementToString(el));
//iwfLog(html);

		// trying to shove a <form> node inside another <form> node is a bad thing.
		// make sure we don't do that here.
		var re = /<form/i;
		var match = re.exec(html);
		if (match && document.forms.length > 0){
			// our html to inject contains a form node.
			// bubble up the chain until we find a <form> node, or we have no parents
			var elParent = el;
			while (elParent && elParent.tagName.toLowerCase() != 'form'){
				elParent = iwfGetParent(elParent);
			}

			if (elParent && elParent.tagName.toLowerCase() == 'form'){
				iwfLogFatal('IWF Ajax Error: Attempting to inject html which contains a <form> node into a target element which is itself a <form> node, or is already contained by a <form> node.\nThis is bad html, and will not work appropriately on some major browsers.', true);
			}
		}


		el.innerHTML = html;


		// if there is a script element, we have to explicitly add it to the body element,
		// as IE and firefox just don't like it when you try to add it as part of the innerHTML
		// property.  Go figure.

		var i = 0;
		// don't stomp on any existing scripts...
		while (iwfGetById('iwfScript' + i)){
			i++;
		}

		var scriptStart = html.indexOf("<script");
		while(scriptStart > -1){
			scriptStart = html.indexOf(">", scriptStart) + 1;

			// copy contents of script into a default holder
			var scriptEnd = html.indexOf("</script>", scriptStart);
			var scriptHtml = html.substr(scriptStart, scriptEnd - scriptStart);

			var re = /^\s*<!--/;
			var match = re.exec(scriptHtml);
			if (!match){
				iwfLogFatal("IWF Ajax Error: Developer, you *must* put the <!-- and /" + "/--> 'safety net' around your script within all <script> tags.\nThe offending <script> tag contains the following code:\n\n" + scriptHtml + "\n\nThis requirement is due to how IWF injects the html so the browser is able to actually parse the script and make its contents available for execution.", true);
			}

			// this code is the worst hack in this entire framework.
			// the code in the try portion should work anywhere -- but
			// IE barfs when you try to set the innerHTML on a script element.
			// not only that, but IE won't parse script unless a visible element
			// is contained in the innerHTML when it is set, so we need the <code>IE hack here</code>
			// and it cannot be removed.
			// I don't understand why creating a new node and setting its innerHTML causes the browsers
			// to parse and execute the script, but it does.
			// Note there is a major leak here, as we do not try to reuse existing iwfScriptXXXX elements
			// in case they are in use by other targets.  To clean these up, simply call iwfCleanScripts
			// periodically.  This is so app-dependent, I didn't want to try to keep track of everything
			// and possibly miss a case, causing really weird results that only show up occassionally.
			//
			// Plus I'm getting lazy. :)
			//
			try {
				//! moz (DOM)
				var elScript = iwfGetOrCreateById('iwfScript' + i, 'script');
				elScript.type = 'text/javascript';
				elScript.defer = 'true';
				elScript.innerHTML = scriptHtml;

				iwfAppendChild('body', elScript);

			} catch(e){
iwfLog("IE Hack for injecting script tag...", true);
				//! IE hack
				// IE needs a visible tag within a non-script element to have scripting apply... Don't ask me why, ask the IE team why.
				// My guess is the visible element causes the page to at least partially re-render, which in turn kicks off any script parsing
				// code in IE.
				var elDiv = iwfGetOrCreateById('iwfScript' + i, '<div style="display:none"></div>', 'body');
				elDiv.innerHTML = '<code>IE hack here</code><script id="iwfScript' + i + '" defer="true">' + scriptHtml + '</script' + '>';
			}

			i++;

			scriptStart = html.indexOf("<script", scriptEnd+8);
		}
	}
}

function iwfCleanScripts(){
	var i = 0;
	while(iwfRemoveNode('iwfScript' + (i++)));

}

function _iwfIframeCallback(frameName, xml){
	var div = iwfGetById(frameName + "_callback");

	var localCallback = iwfAttribute(div, 'iwfFileUploadCallback');
	var localTarget = iwfAttribute(div, 'iwfFileUploadTarget');

	_iwfOnRequestEnd();
	_iwfResponseHandler(xml, localCallback, localTarget);


}

function _iwfUploadFiles(frm, callback, target){
	// Extra nasty hack here!
	// spin through all the form elements, copying all
	// the <input type='file'> ones into a new iframe so
	// we can post those using 'normal' web posting functionality.
	// once this is done,

	var fileCount = 0;

	// note form is hard-coded to appropriate ENCTYPE and METHOD for uploading a file

	var i = 0;
	// don't stomp on any existing iframes...
	while (iwfGetById('iwfFileUpload' + i)){
		// blow away the iframe if we've done this before (suppress history!)
//			iwfRemoveNode('iwfFileUpload' + i);
//			if (window.frames['iwfFileUpload' + i]) window.frames['iwfFileUpload' + i] = null;
		i++;
	}

	var frameName = 'iwfFileUpload' + i;

	var js = '';

	var formName = iwfAttribute(frm, 'name');
	if (!formName) { formName = iwfAttribute(frm, 'id'); }


	var formElements = "<input type='hidden' name='iwfIframeName' id='iwfIframeName' value='" + frameName + "' />";
	for(var i=0;i<frm.elements.length;i++){
			var el = frm.elements[i];
			var elString = iwfElementToString(el);
			if (el.tagName.toLowerCase() == 'input' && iwfAttribute(el, 'type').toLowerCase() == 'file' && iwfAttribute(el, 'value')){
				// is a file input control.
				// extra special hack from 7th level of hell to get this to work.
				fileCount++;
				// clone the node from the source document into our current document
				js += "document.forms[0].appendChild(window.parent.document.forms['" + formName + "']." + iwfAttribute(el, 'name') + ".cloneNode(true)); ";
//				js += 'document.forms[0]["' + iwfAttribute(el, 'name') + '"].value = "' + iwfAttribute(el, 'value') + '"; ';
			} else {
				// copy this element
//			iwfLog('element=' + elString, true);
				formElements += elString;
			}
	}

	var startFormTag = "<form name='" + formName +
								"' id='" + formName +
								"' action='" + iwfAttribute(frm, 'action');

	if (fileCount > 0){
		// hard code the enctype and method
		startFormTag += "' method='post' enctype='multipart/form-data'>";
	} else {
		startFormTag += "' method='" + iwfAttribute(frm, 'method') +
							 "' enctype='" + iwfAttribute(frm, 'enctype') + "'>";
	}


	var html = "<html><body ";
	if (js && js.length > 0){
		html += 'onload="javascript:';
		html += js;
		// yep, another horrible hack!  Submitting the form on body load doesn't work in FF.
		// so add a 100 ms delay and it works.  Go figure.
		html += "; setTimeout('document.forms[0].submit()', 100);";
		html += '">';
	} else {
		html += '>';
	}
	html += startFormTag;
	html += formElements;
	html += "<input type='submit' value='Go' name='iwfHiddenGo' id='iwfHiddenGo'/>";
	html += "</form></body></html>";



//iwfLog('html to write to hidden iframe:\n' + html, true);
	if (fileCount > 0){

		iwfLog("submitting via iframe named " + frameName + ": " + html);


		// create a div to hold all the iframes we may create (so we can hide them!)
		var elUploadDiv = iwfGetOrCreateById('iwfFileUploadFrameHolder', 'div', 'body');

//		if (!iwfIsHidden(elUploadDiv)) { iwfHide(elUploadDiv); }

		// create a div just to hold the event handler (for async callbacks)
		var elCallback = iwfGetOrCreateById(frameName + '_callback', 'div', elUploadDiv);
		iwfAttribute(elCallback, 'iwfFileUploadCallback', callback);
		iwfAttribute(elCallback, 'iwfFileUploadTarget', target);

		// now, we have a new IFrame tag containing the html to post.
		var elUpload =  iwfGetOrCreateById(frameName, 'iframe', elUploadDiv);
		// hack here.  both FF and IE require a reference to the object
		// via the frames collection.  Don't ask me why, I just know this works...

		elUpload = window.frames[frameName];

		// show progress if it's not already visible...
		_iwfOnRequestStart();

		elUpload.document.open('text/html', 'replace');
		elUpload.document.write(html);
		elUpload.document.close();


		// link up the callback
		// (note this isn't fired natively, we fudge it.  See _iwfIframeCallback method)


		// as soon as this is added to the document, it will post.
		// TODO: add someway of pausing code here until upload is completed!
		//       also, a progress bar would be good...

//		iwfLog(fileCount + ' file(s) uploaded.', true);

		return elUpload;

	} else {
		// form didn't contain a <input type='file'> element, so do nothing!
		return null;
	}

}


var _iwfTotalRequests = 0;
var _iwfPendingRequests = 0;
var _iwfRequestTicker = null;
var _iwfRequestTickCount = 0;
var _iwfRequestTickDuration = 100;


// TODO: make the styles applied be configurable variables at the top of this file.
function _iwfGetBusyBar(inner){
	var b = iwfGetById('iwfBusy');
	if (!b){
		b = iwfGetOrCreateById('iwfBusy', 'div', 'body');
		b.className = 'iwfbusybar';
		iwfStyle(b, 'position', 'absolute');
		iwfStyle(b, 'border', '1px solid black');
		iwfStyle(b, 'backgroundColor', '#efefef');
		iwfStyle(b, 'textAlign', 'left');

		iwfWidth(b, 100);
		iwfHeight(b, 20);
		iwfZIndex(b, 9999);

		iwfX(b, 0);
		iwfY(b, 0);

//		iwfX(b, iwfClientWidth() - iwfWidth(b)-5);
//		iwfY(b, iwfClientHeight() - iwfHeight(b)-5);

		iwfHide(b);
	}



	var bb = iwfGetById('iwfBusyBar');
	if(!bb){
		bb = iwfGetOrCreateById('iwfBusyBar', 'div', b);
		iwfStyle(bb, 'backgroundColor', 'navy');
		iwfStyle(bb, 'color', 'white');
		iwfStyle(bb, 'textAlign', 'left');
		iwfStyle(bb, 'paddingLeft', '5px');
		iwfWidth(bb, 1);
		iwfHeight(bb, 20);
		iwfX(bb, 0);
		iwfY(bb, 0);
	}

	if(inner){
		return bb;
	} else {
		return b;
	}

}

function _iwfOnRequestStart(){
	_iwfPendingRequests++;
	_iwfTotalRequests++;

	_iwfRequestTickDuration = 100;

	if (!_iwfRequestTicker){
		_iwfRequestTickCount = 0;
		if (window.iwfOnRequestStart){
			_iwfRequestTickDuration = iwfOnRequestStart();
		} else if (_iwfShowGuiProgress) {
			// use gui busy implementation
			var bb = _iwfGetBusyBar(true);
			iwfWidth(bb, 1);
			bb.innerHTML = '0%';
			iwfShow(_iwfGetBusyBar(false));
		} else {
			// use default busy implementation...
			window.status = 'busy.';
		}
		if (!_iwfRequestTickDuration){
			_iwfRequestTickDuration = 100;
		}
		_iwfRequestTicker = setInterval(_iwfOnRequestTick, _iwfRequestTickDuration);
	}
}

function _iwfOnRequestTick(){
	_iwfRequestTickCount++;
	if (window.iwfOnRequestTick){
		// Marburg (marbie) pointed out a variable misnaming here.  Thank you marbie!
		iwfOnRequestTick(_iwfRequestTickCount, _iwfRequestTickDuration, _iwfPendingRequests);
	} else if (!window.iwfOnRequestStart) {
		if (_iwfShowGuiProgress) {
			// use gui busy implementation
			var bar = _iwfGetBusyBar(true);
			if(bar){
				var w = iwfWidth(bar) + 1;
				if (w > 95){
					w = 95;
				}
				iwfWidth(bar, w);
				bar.innerHTML = iwfIntFormat(w) + "%";
			}
		} else {
			// use default busy implementation...
			window.status = 'busy...............................................'.substr(0, (_iwfRequestTickCount % 45) + 5);
		}
	} else {
		// they didn't define a tick function,
		// but they did define a start one, so do nothing.
	}
}

function _iwfOnRequestEnd(){
	_iwfPendingRequests--;
	if (_iwfPendingRequests < 1){
		_iwfPendingRequests = 0;
		_iwfTotalRequests = 0;
		clearInterval(_iwfRequestTicker);
		_iwfRequestTicker = null;
		if (window.iwfOnRequestEnd){
			iwfOnRequestEnd();
		} else if (!window.iwfOnRequestStart) {
			if (_iwfShowGuiProgress) {
			// use gui busy implementation
				var bar = _iwfGetBusyBar(true);
				if(bar){
					iwfWidth(bar, 100);
					bar.innerHTML = "Done";
					iwfHideGentlyDelay(_iwfGetBusyBar(false), 15, 500);
				}
			} else {
				// use default busy implementation...
				window.status = 'done.';
			}
		} else {
			// they didn't define an end function,
			// but they did define a start one, so do nothing.
		}

	} else {
		if (window.iwfOnRequestProgress){
			iwfOnRequestProgress(_iwfPendingRequests, _iwfTotalRequests);
		} else if (!window.iwfOnRequestStart) {
			if (_iwfShowGuiProgress) {
			// use gui busy implementation
				var pct = (1 - (_iwfPendingRequests/_iwfTotalRequests)) * 100;
				if (pct > 100){
					pct = 100;
				}
				var bar = _iwfGetBusyBar(true);
				if(bar){
					iwfWidth(bar, pct);
					bar.innerHTML = "loading " + iwfIntFormat(pct) + "%";
				}
			} else {
				// use default busy implementation...
				window.status = 'Remaining: ' + _iwfPendingRequests;
			}
		} else {
			// they didn't define an end function,
			// but they did define a start one, so do nothing.
		}
	}
}

function _iwfOnRequestError(code, msg, text){
	if (window.iwfOnRequestError){
		iwfOnRequestError(code, msg, text);
	} else {
		iwfLogFatal("Error " + code + ": " + msg + ":\n\n" + text);
	}
}

// -----------------------------------
// End: AJAX Request and Response
// -----------------------------------
// --------------------------------------------------------------------------
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
// --------------------------------------------------------------------------
//! NOTE: To minimize file size, strip all fluffy comments (except the LGPL, of course!)
//! using the following regex (global flag and multiline on):
//!            ^\t*//([^/!].*|$)
//!  To rip out all comments (LGPL or otherwise):
//!            ^\t*//(.*|$)
//!  To rip out only logging statements (commented or uncommented):
//!            ^/{0,2}iwfLog.*
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
//! iwfgui.js
//
// GUI inspection and manipulation functions
//
//! Dependencies:
//! iwfcore.js
//
//! Brock Weaver - brockweaver@users.sourceforge.net
//! v 0.2 - 2005-11-14
//! core bug patch
// --------------------------------------------------------------------------
//! v 0.1 - 2005-06-05
//! Initial release.
// --------------------------------------------------------------------------
// Issues:
//  Timeouts have hiccups sometimes when they begin to overlap
//  Not tested on Safari -- I need a Mac!
//  _iwfMoveTo() has some calculation problems with certain motionType values
// --------------------------------------------------------------------------

// -----------------------------------
// Dependency Check
if (!__iwfCoreIncluded){
	iwfLogFatal("IWF Dependency Error: you must set a reference to the iwfcore.js file *before* iwfgui.js! I.E.:\n\n<script type='text/javascript' src='iwfcore.js'></script>\n<script type='text/javascript' src='iwfgui.js'></script>", true);
}
// -----------------------------------

var __iwfGuiIncluded = true;

function iwfBugit(id){
	var el = iwfGetById(id);
//	alert('att display of ' + id + ' = "' + el.style.display + '"'); //\ncurr display = "' + el.runtimeStyle.display + '"');

}

function iwfStyle(id, styleName, newVal){
	var el = iwfGetById(id);
	if (!el) { return false; }
	var ret = '';
	if (el.currentStyle) {
		ret = el.currentStyle[styleName];
	} else {
		try {
			ret = document.defaultView.getComputedStyle(el,null).getPropertyValue(styleName);
	  } catch(e) {
		}
	}
	if (iwfExists(newVal)){
		if (el.runtimeStyle){
//			alert('runtimeStyle ' + styleName + ' to ' + newVal);
			el.runtimeStyle[styleName] = newVal;
			ret = newVal;
		} else {
//			document.defaultView.getComputedStyle(el, null).setPropertyValue(styleName, newVal);
			iwfLog('setting style ' + styleName + ' to ' + newVal);
			ret = el.style[styleName] = newVal;
		}
	}
	return ret;
}

// -----------------------------------
// Begin: Visibility
// -----------------------------------

function iwfShow(id, reserveSpace, displayMode){
	var el = iwfGetById(id);
	if (!el) { return false; }

	iwfLog("current vis=" + iwfStyle(el, 'visbility') + "; current disp=" + iwfStyle(el, 'display'));



	if (reserveSpace){
		var disp = 'visible';
		if (iwfExists(displayMode) && displayMode != null){
			disp = displayMode;
		}
		iwfStyle(el, 'visibility', disp);
	} else {
		var disp = 'block';
		if (iwfExists(displayMode) && displayMode != null){
			disp = displayMode;
		}
		iwfLog("display='" + disp + "'. exists? " + iwfExists(displayMode));
		iwfStyle(el, 'display', disp);
	}
}

function iwfHide(id, reserveSpace){
	var el = iwfGetById(id);
	if (reserveSpace){
		iwfStyle(el, 'visibility', 'hidden');
	} else {
		iwfStyle(el, 'display', 'none');
	}
}

function iwfHideDelay(id, ms, reserveSpace){
	var el = iwfGetById(id);
	if (!el) { return; }

	// wipeout any other re-visibling timeouts we have (nice spelling, eh?)
	_iwfClearTimeout(el, "hideshow", "visible", true);

	if (ms < 1){
		iwfHide(el, reserveSpace);
	} else {
		_iwfSetTimeout(el, "hideshow", "visible", "iwfHideDelay('" + el.id + "', 0, " + reserveSpace + ")", ms);
	}
}

function iwfShowDelay(id, ms, reserveSpace, displayMode){
	var el = iwfGetById(id);
	if (!el) { return; }

	// wipeout any other re-visibling timeouts we have (nice spelling, eh?)
	_iwfClearTimeout(el, "hideshow", "visible", true);

	if (ms < 1){
		iwfShow(el, reserveSpace);
	} else {
		if (iwfExists(displayMode) && displayMode != null){
			_iwfSetTimeout(el, "hideshow", "visible", "iwfShowDelay('" + el.id + "', 0, " + reserveSpace + ", '" + displayMode + "')", ms);
		} else {
			_iwfSetTimeout(el, "hideshow", "visible", "iwfShowDelay('" + el.id + "', 0, " + reserveSpace + ")", ms);
		}
	}
}

function iwfShowGently(id, pct, reserveSpace, maxPct, displayMode){

	var el = iwfGetById(id);
	if (!el) { return; }

	if (!iwfExists(maxPct)){
		maxPct = 100;
	}

	// wipeout any other re-visibling timeouts we have (nice spelling, eh?)
	_iwfClearTimeout(el, "hideshow", "visible", true);

	var opacity = iwfOpacity(el);
	if (iwfIsHidden(el)){
		// set opacity to 0
		iwfOpacity(el, 0, false, false);

		// show it
		iwfShow(el, reserveSpace, displayMode);
	}

	// adjust opacity up by the given percentage
	if (pct > maxPct){
		pct = maxPct;
	}
	opacity = iwfOpacity(el, pct, true);

	if (opacity < maxPct) {
		// set a timeout
		if (iwfExists(displayMode) && displayMode != null){
			_iwfSetTimeout(el, "hideshow", "visible", "iwfShowGently('" + el.id + "'," + pct + ", " + reserveSpace + ", " + maxPct + ", '" + displayMode + "')", 50);
		} else {
			_iwfSetTimeout(el, "hideshow", "visible", "iwfShowGently('" + el.id + "'," + pct + ", " + reserveSpace + ", " + maxPct + ", null)", 50);
		}
	}
}

function iwfHideGently(id, pct, reserveSpace, minPct){
	var el = iwfGetById(id);
	if (!el) { return; }

	if (iwfIsHidden(el)) {return; }

	if (!iwfExists(minPct)){
		minPct = 0;
	}

	// wipeout any other re-visibling timeouts we have (nice spelling, eh?)
	_iwfClearTimeout(el, "hideshow", "visible", true);

	var opacity = iwfOpacity(el);
	iwfLog('opacity=' + opacity);
	if (opacity <= minPct){

		opacity = minPct;

		// hide it if opacity is 0
		if (opacity <= 0){
			iwfHide(el, reserveSpace);
			// set opacity back to fully opaque, so when they iwfShow() it,
			// the element isn't fully transparent and looks like iwfShow() didn't work
			iwfOpacity(el, 100, false, true);
		}

	} else {
		// make it less opaque...
		iwfOpacity(el, -pct, true);

		// set our timeout
		_iwfSetTimeout(el, "hideshow", "visible", "iwfHideGently('" + el.id + "'," + pct + ", " + reserveSpace + ", " + minPct + ")", 50);
	}
}

function iwfHideGentlyDelay(id, pct, reserveSpace, minPct, ms){
	var el = iwfGetById(id);
	if (!el) { return; }

	if (iwfIsHidden(el)) { return; }

	// wipeout any other re-visibling timeouts we have (nice spelling, eh?)
	_iwfClearTimeout(el, "hideshow", "visible", true);


	if (ms < 1){
		iwfHideGently(el, pct, reserveSpace);
	} else {
		_iwfSetTimeout(el, "hideshow", "visible", "iwfHideGentlyDelay('" + el.id + "'," + pct + ", " + reserveSpace + ", " + minPct + ", 0)", ms);
	}

}

function iwfShowGentlyDelay(id, pct, reserveSpace, maxPct, displayMode, ms){
	var el = iwfGetById(id);
	if (!el) { return; }


	// wipeout any other re-visibling timeouts we have (nice spelling, eh?)
	_iwfClearTimeout(el, "hideshow", "visible", true);

	if (ms < 1){
		iwfShowGently(el, pct, reserveSpace, maxPct, displayMode);
	} else {
		if (iwfExists(displayMode) && displayMode != null){
			_iwfSetTimeout(el, "hideshow", "visible", "iwfShowGentlyDelay('" + el.id + "'," + pct + ", " + reserveSpace + ", " + maxPct + ", '" + displayMode + "', 0)", ms);
		} else {
			_iwfSetTimeout(el, "hideshow", "visible", "iwfShowGentlyDelay('" + el.id + "'," + pct + ", " + reserveSpace + ", " + maxPct + ", null, 0)", ms);
		}
	}
}

function iwfOpacity(id, pct, relative, keepHiddenIfAlreadyHidden){
	var el = iwfGetById(id);
	if (el){
		if (iwfExists(pct) && pct != null){
			// set opacity
			var newPct = iwfToFloat(pct, true);
			if (relative){
				// lookup current opacity
				newPct = iwfOpacity(id, null, false);

				// modify pct by that much
				newPct += pct;
			}

			if (newPct < 0){
				newPct = 0;
			} else if (newPct > 100){
				newPct = 100;
			}

//			alert('opacity=' + iwfStyle(el, 'opacity') + '\nfilter=' + iwfStyle(el, 'filter') + '\nfilter exists=' + iwfExists(iwfStyle(el, 'filter')));

			if (document.all){
				// yuck ie hack!
				if (iwfStyle(el, 'filter')) { iwfStyle(el, 'filter', "alpha(opacity=" + newPct + ")"); }
				else if (iwfStyle(el, 'opacity')) { iwfStyle(el, 'opacity', newPct/100); }
				else if (iwfStyle(el, 'mozOpacity')) { iwfStyle(el, 'mozOpacity', newPct/100); }
			} else {
				if (iwfExists(iwfStyle(el, 'opacity'))) { iwfStyle(el, 'opacity', newPct/100); }
				else if (iwfExists(iwfStyle(el, 'filter'))) { iwfStyle(el, 'filter', "alpha(opacity=" + newPct + ")"); }
				else if (iwfExists(iwfStyle(el, 'mozOpacity'))) { iwfStyle(el, 'mozOpacity', newPct/100); }
			}

			// also display it if opacity > 0 and !keepHidden
			if (newPct > 0 && !keepHiddenIfAlreadyHidden){
				if (iwfIsHidden(id)){
					iwfShow(id);
				}
			}

			return newPct;

		} else {
			// get current opacity
			var val = null;
			if (document.all){
				if (iwfExists(iwfStyle(el, 'filter'))) {
					val = iwfStyle(el, 'filter');
					if (val.indexOf("opacity") == 0){
						val = 100;
					} else {
						val = iwfToFloat(val, 2, true);
					}
				} else if (iwfExists(iwfStyle(el, 'opacity'))){
					val = iwfStyle(el, 'opacity');
					if (val == ''){
						val = 100;
					} else {
						val = iwfToFloat(val, 2, true) * 100;
					}
				} else if (iwfExists(iwfStyle(el, 'mozOpacity'))) {
					val = iwfStyle(el, 'mozOpacity');
					if (val == ''){
						val = 100;
					} else {
						val = iwfToFloat(val, 2, true) * 100;
					}
				}
			} else {
				if (iwfExists(iwfStyle(el, 'opacity'))){
					val = iwfStyle(el, 'opacity');
					if (val == ''){
						val = 100;
					} else {
						val = iwfToFloat(val, 2, true) * 100;
					}
				} else if (iwfExists(iwfStyle(el, 'filter'))) {
					val = iwfStyle(el, 'filter');
					if (val.indexOf("opacity") == 0){
						val = 100;
					} else {
						val = iwfToFloat(val, 2, true);
					}
				} else if (iwfExists(iwfStyle(el, 'mozOpacity'))) {
					val = iwfStyle(el, 'mozOpacity');
					if (val == ''){
						val = 100;
					} else {
						val = iwfToFloat(val, 2, true) * 100;
					}
				}
			}

			return val;
		}
	}
}

function iwfIsDisabled(id){
	var el = iwfGetById(id);
	if (!el) { return false; }
	return iwfAttribute(el, 'disabled') != null;
}

function iwfIsEnabled(id){
	return !iwfIsDisabled(id);
}

function iwfDisable(id){
	var el = iwfGetById(id);
	if (!el) { return; }
	iwfAttribute(el, 'disabled', 'disabled');
}

function iwfEnable(id){
	var el = iwfGetById(id);
	if (!el) { return; }
	iwfAttribute(el, 'disabled', null);
}

function iwfIsShown(id){
	return !iwfIsHidden(id);
}

function iwfIsHidden(id){
	var el = iwfGetById(id);
	if (!el) { return false; }

	var hidden = iwfStyle(el, 'visibility') == 'hidden' || iwfStyle(el, 'display') == 'none';
	return hidden;
}

function iwfToggle(id, reserveSpace){
	if (iwfIsHidden(id)) {
		iwfShow(id, reserveSpace);
	} else {
		iwfHide(id, reserveSpace);
	}
}



// -----------------------------------
// End: Visibility
// -----------------------------------

// -----------------------------------
// Begin: Timers
// -----------------------------------

function _iwfSetTimeout(id, name, category, fn, ms){
	var el = iwfGetById(id);
	if (!el) { return false; }

	var att = iwfAttribute(el, 'iwfTimeoutCategory' + category);
	if (!att){
		// that attribute doesn't exist yet, or is null
	} else if (att != name){
		// attribute exists but doesn't match our name.
		// clear out the existing one, since the category matches.
		_iwfClearTimeout(el.id, att, category);
	} else {
		// attribute matches our name.
	}

	iwfAttribute(el, 'iwfTimeoutCategory' + category, name);
	iwfLog('setting timeout for ' + name + ' to ' + fn);
	var timeoutid = setTimeout(fn, ms);
	iwfAttribute(el, 'iwfTimeoutId' + category, timeoutid);
	return true;
}

function _iwfCheckTimeout(id, name, category){
//return true;

	var el = iwfGetById(id);
	if (!el) { return false; }

	var att = iwfAttribute(el, 'iwfTimeoutCategory' + category);
	if (!att || att == name){
		return true;
	} else {
		return false;
	}

}

function _iwfClearTimeout(id, name, category, forceful){
	var el = iwfGetById(id);
	if (!el) { return; }

	var att = iwfAttribute(el, 'iwfTimeoutCategory' + category);

	if (att == name || forceful){
		iwfLog('clearing timeout for ' + att);
		clearTimeout(iwfAttribute(el, 'iwfTimeoutId' + category));
		iwfRemoveAttribute(el, 'iwfTimeoutId' + category);
		iwfRemoveAttribute(el, 'iwfTimeoutCategory' + category);
	}

}

function iwfDelay(ms, fpOrString){
	// note this inner function creates a closure...
	function _iwfDelayExpired(){
		if (localIsString){
			// passed a string. eval it.
//iwfLog("_iwfDelayExpired: calling string of:\n" + localFpOrString, true);
			eval(localFpOrString);
		} else {
			// they passed a function pointer.
			// call it, passing any args we were given.
			if (!localArgs || localArgs.length == 0){
				localFpOrString();
			} else if (localArgs.length == 1){
				localFpOrString(localArgs[0]);
			} else {
				var s = 'localFpOrString(';
				for(var i=0;i<localArgs.length;i++){
					if (i > 0){
						s += ', ';
					}
					if(localArgs[i] == null){
						s += 'null';
					} else if(iwfIsString(localArgs[i])){
						s += '"' + localArgs[i].replace(/"/gi, '\\"') + '"';
					} else {
						s += localArgs[i];
					}
				}
				s += ')';
//iwfLog("_iwfDelayExpired: calling fp of:\n" + s, true);
				eval(s);
			}
		}
		delete localFpOrString;
		delete localIsString;
		delete localArgs;
	}

	var localFpOrString = fpOrString;
	var localIsString = iwfIsString(fpOrString);
	var localArgs = null;

	if (!iwfIsString(fpOrString)){
		if (arguments && arguments.length > 0){
			localArgs = new Array();
			for(var i=2;i<arguments.length;i++){
//iwfLog('args[' + i + '] = ' + arguments[i], true);
				localArgs.push(arguments[i]);
			}
		}
	}
	setTimeout(_iwfDelayExpired, ms);
}

// -----------------------------------
// End: Timers
// -----------------------------------


// -----------------------------------
// Begin: Positioning
// -----------------------------------

function iwfX1(id, newx){
	return iwfX(id, newx);
}

function iwfSelectOption(id, val, matchText){
	var el = iwfGetById(id);
	if (!el) { return; }
	var sel = -1;
	for(var i=0;i<el.options.length;i++){
		var opt = el.options[i];
		var check = ((opt.value == val) || (matchText ? (opt.text == val) : false));
//		alert('curval=' + iwfAttribute(opt, 'value') + '\nval=' + val + '\nselect it? ' + check);
		opt.selected = check;
	}
}

function iwfFocusSelect(id, promptmsg){
	var el = iwfGetById(id);
	if (promptmsg){
		alert(promptmsg);
	}
	if (!iwfIsHidden(id)){
		try {
			el.focus();
			el.select();
		} catch(e) { }
	}
	return false;
}

function iwfFocus(id, promptmsg){
	var el = iwfGetById(id);
	if (promptmsg){
		alert(promptmsg);
	}
	if (!iwfIsHidden(id)){
		try {
			el.focus();
		} catch(e) { }
	}
	return false;
}



function iwfX(id, newx){
	var absx = 0;

	if (iwfIsNumber(newx)) {
		absx = iwfSetX(id, newx);
	} else {
		var el = iwfGetById(id);
		if (!el) { return 0; }
		var left = iwfStyle(el, 'left');
		var pixelLeft = iwfStyle(el, 'pixelLeft');
		if (iwfIsString(left) && left.length > 0){
			absx = iwfToInt(left, true);
			if (isNaN(absx)) {
				absx = 0;
			}
		} else if (iwfIsNumber(pixelLeft)) {
			absx = pixelLeft;
		} else {
			while (el) {
				if (iwfExists(el.offsetLeft)) { absx += el.offsetLeft; }
				el = iwfGetParent(el, true);
			}
		}
	}

	iwfLog('absx=' + absx);

	return absx;
}

function iwfSetX(id, newx){
	var el = iwfGetById(id);
	if (!el) { return null; }
	var left = iwfStyle(el, 'left');
	var pixelLeft = iwfStyle(el, 'pixelLeft');
	if(iwfIsString(left)) {
		iwfStyle(el, 'left', newx + 'px');
	}	else if(pixelLeft) {
		iwfStyle(el, 'pixelLeft', newx);
	}	else if(iwfAttribute(el, 'left')) {
		iwfAttribute(el, 'left', newx);
	}
	return newx;
}

function iwfY1(id, newy){
	var el = iwfGetById(id);
	return iwfY(el, newy);
}

function iwfY(id, newy){
	var absy = 0;

	if (iwfIsNumber(newy)) {
		absy = iwfSetY(id, newy);
	} else {
		var el = iwfGetById(id);
		if (!el) { return 0; }

		var top = iwfStyle(el, 'top');
		var pixelTop = iwfStyle(el, 'pixelTop');

		if (iwfIsString(top) && top.length > 0){
			absy = iwfToInt(top, true);
			if (isNaN(absy)) {
				absy = 0;
			}
		} else if (iwfIsNumber(pixelTop)) {
			absy = pixelTop;
		} else {
			while (el) {
				if (iwfExists(el.offsetTop)) { absy += el.offsetTop; }
				el = iwfGetParent(el, true);
			}
		}
	}

	return absy;
}

function iwfSetY(id, newy){
	var el = iwfGetById(id);
	if (!el) { return null; }
	var top = iwfStyle(el, 'top');
	var pixelTop = iwfStyle(el, 'pixelTop');
	if (iwfIsString(top)) {
		iwfStyle(el, 'top', newy + 'px');
	} else if(pixelTop) {
		iwfStyle(el, 'pixelTop', newy);
	} else if(iwfAttribute(el, 'top')) {
		iwfAttribute(el, 'top', newy);
	}
 	return newy;
}

function iwfZIndex(id, z){
	var el = iwfGetById(id);
	if (!el) { return 0; }

	var zind = iwfStyle(el, 'zIndex');

	if (iwfExists(z)){
		iwfStyle(el, 'zIndex', z);
	}
	return iwfToInt(iwfStyle(el, 'zIndex'), true);
}

function iwfMoveTo(id1, xDest, yDest, totalTicks, motionType, callback, rate){

	var el = iwfGetById(id1);

	if (el){
		var origX = iwfX1(el);
		var origY = iwfY1(el);
//		alert(origX + '\n' + origY);

		// wipeout any other repositioning timeouts we have...
		_iwfClearTimeout(el, "moveto", "position", true);

		// move any elements we have docked to us
		_iwfMoveDockedItems(el, xDest, yDest, totalTicks, motionType, rate);

		if (!iwfExists(totalTicks) || totalTicks == 0){
			// do it immediately.
			iwfX1(id1, xDest);
			iwfY1(id1, yDest);
		} else {
//			alert('animating...');
			// animate the movement
			_iwfMoveTo(id1, origX, origY, xDest, yDest, totalTicks, totalTicks, motionType, callback, rate);
		}
	}

}

function _iwfMoveDockedItems(id, xDest, yDest, totalTicks, motionType, rate){
	var elMaster = iwfGetById(id);
	if (elMaster){
		var dockers = iwfAttribute(elMaster, 'iwfDockers');
//iwfLog("Dockers for " + iwfAttribute(elMaster, 'id') + ":\n" + dockers, true);
		if (dockers && dockers.length > 0){
			// there is one or more items docked to us
			// tell them to move with us!
			dockers = dockers.split(",");
			for(var i=0;i<dockers.length;i++){
				var elSlave = iwfGetById(dockers[i]);
				if (elSlave){
//iwfLog("found element '" + dockers[i] + "' which is docked to element " + iwfAttribute(elMaster, 'id'), true);
					var xOffset = iwfX(elMaster) - iwfX(elSlave);
					var yOffset = iwfY(elMaster) - iwfY(elSlave);
					var xEnd = xDest - xOffset;
					var yEnd = yDest - yOffset;
					iwfMoveTo(elSlave, xEnd, yEnd, totalTicks, motionType, null, rate);
				}
			}
		}
	}
}

function _iwfMoveTo(id1, xOrig, yOrig, xDest, yDest, ticksLeft, totalTicks, motionType, callback, rate){
//iwfLog("_iwfMoveTo(" + id1 + ", " + xOrig + ", " + yOrig + ", " + xDest + ", " + yDest + ", " + ticksLeft + ", " + totalTicks + ", '" + motionType + "')");
	var el = iwfGetById(id1);
	if (!el){
//iwfLog("could not locate el with id of " + id1);
	} else {
		el_id = iwfAttribute(el, 'id');

		_iwfClearTimeout(el, "moveto", "position", true);


		var elX = parseInt(iwfX1(el), 10);
		var elY = parseInt(iwfY1(el), 10);

		xDest = parseInt(xDest, 10);
		yDest = parseInt(yDest, 10);


		var xDone = elX == xDest;

		var yDone = elY == yDest;

		if ((ticksLeft <= 0) || (xDone && yDone)){
			//! time is up / motion is "close enough"
			iwfLog('xDone=' + xDone + '; xDest=' + xDest + '; xint=' + elX + '; x=' + xCur);
			iwfLog('yDone=' + yDone + '; yDest=' + yDest + '; yint=' + elY + '; y=' + yCur);
			if (xDone && yDone){
				iwfLog("Stopping because both x and y are 'close enough'");
			} else {
				iwfLog("stopping because ran out of ticks");
			}
//iwfLog("_iwfMoveTo time is up / motion is done.");
			iwfX1(el, xDest);
			iwfY1(el, yDest);

			var txt = callback;
			if (iwfIsString(callback)){
				eval(txt);
			}

		} else {

			var pctLeft = ticksLeft / totalTicks;


			var xTotal = xDest - xOrig;
			var yTotal = yDest - yOrig;

			var xCur, yCur, rt;

			rate = (iwfIsNumber(rate) ? rate : 10);
			rt = Math.pow(pctLeft, rate);

			switch(motionType){
				case 'd':
				case 'dec':
				default:
//					rt = pctLeft * pctLeft * pctLeft * pctLeft * pctLeft * pctLeft * pctLeft * pctLeft * pctLeft;
//					rt = pctLeft * pctLeft * pctLeft * pctLeft * pctLeft * pctLeft;
					xCur = xOrig + (xTotal - (rt * xTotal));
					yCur = yOrig + (yTotal - (rt * yTotal));
					break;
				case 'a':
				case 'acc':
					pctLeft = 1 - pctLeft;
//					rt = pctLeft * pctLeft * pctLeft * pctLeft;
					xCur = xOrig + (rt * xTotal);
					yCur = yOrig + (rt * yTotal);
					break;
				case 'b':
				case 'both':
					if (pctLeft > 0.75){
						// 3/4 yet to go -- accelerate
						pctLeft = 1 - pctLeft;
						// rt = pctLeft * pctLeft * pctLeft * pctLeft * pctLeft * pctLeft;
						xCur = xOrig + (rt * xTotal);
						yCur = yOrig + (rt * yTotal);

					} else if (pctLeft < 0.25){
						// 1/4 yet to go -- decelerate
						// rt = pctLeft * pctLeft * pctLeft * pctLeft;
						xCur = xOrig + (xTotal - (rt * xTotal));
						yCur = yOrig + (yTotal - (rt * yTotal));

					} else {
						// between 1/4 and 3/4 done -- linear
						pctLeft = 1 - pctLeft;
						xCur = xOrig + (pctLeft * xTotal);
						yCur = yOrig + (pctLeft * yTotal);
					}
					break;
				case 'lin':
				case 'linear':
				case 'l':
					// use linear motion
					pctLeft = 1 - pctLeft;
					xCur = xOrig + (pctLeft * xTotal);
					yCur = yOrig + (pctLeft * yTotal);
					break;
			}

			iwfX1(el, xCur);
			iwfY1(el, yCur);

			iwfLog('xDone=' + xDone + '; xDest=' + xDest + '; xint=' + elX + '; x=' + xCur);
			iwfLog('yDone=' + yDone + '; yDest=' + yDest + '; yint=' + elY + '; y=' + yCur);


			ticksLeft--;

			var fn = "_iwfMoveTo('" + el_id + "', " + xOrig + ", " + yOrig + ", " + xDest + ", " + yDest + ", " + ticksLeft + ", " + totalTicks + ", '" + motionType + "', '" + callback + "', " + rate + ")";
//iwfLog("timeout set to call: " + fn);
			_iwfSetTimeout(el, "moveto", "position", fn, 50);
		}
	}
}

function iwfUnDockFrom(id1, id2){
	var elSlave = iwfGetById(id1);

	if (elSlave){
		var slaveId = iwfAttribute(elSlave, 'id');
		// determine who elSlave is docked to
		var dockedTo = iwfAttribute(elSlave, 'iwfDockedTo');
		if (dockedTo){
			// elSlave says he's docked to the guy with id of dockedTo.
			// grab that guy.
			var elMaster = iwfGetById(dockedTo);
//iwfLog("dockedTo:" + iwfAttribute(elMaster, 'id'), true);
			if (elMaster){
				// elMaster is the guy elSlave is docked to.
				// tell elMaster to remove elSlave from his docker list

				var dockers = iwfAttribute(elMaster, 'iwfDockers');
//iwfLog("undocking items from " + iwfAttribute(elMaster, 'id') + ":\n" + dockers, true);
				if (dockers && dockers.length > 0){
					var arrDockers = dockers.split(",");
					if (arrDockers.length == 0){
						arrDockers.push(dockers);
					}
//iwfLog('arrDockers=' + arrDockers + '\nlength=' + arrDockers.length, true);
					for(var i=0;i<arrDockers.length;i++){
//iwfLog("undocking is checking " + arrDockers[i] + " against " + slaveId, true);
						if (arrDockers[i] == slaveId){
							// undock elSlave from elMaster
							arrDockers.splice(i, 1);

							var output = arrDockers.join(",");
//iwfLog("writing iwfDockers=" + output);

							// write this back to elMaster
							iwfAttribute(elMaster, 'iwfDockers', output);
							break;
						}
					}
				}
			}
			// tell elSlave he's no longer docked to elMaster.
			iwfAttribute(elSlave, 'iwfDockedTo', null);
		}
	}
}

function iwfAlignTo(id1, id2, anchor1, anchor2, totalTicks, motionType){
	var elMover = iwfGetById(id1);
	var elStays = iwfGetById(id2);

	if (elMover && elStays){

		var newX = iwfX(elStays);
		var newY = iwfY(elStays);

		var anc = ((anchor1 +'  ').substr(0,2) + (anchor2 + '  ').substr(0,2)).toLowerCase();
//iwfLog("anchor encoding: " + anc);
		if (anc.charAt(0) == 'b'){
			newY -= iwfHeight(elMover);
		} else if (anc.charAt(0) == 'c'){
			newY -= iwfHeight(elMover) / 2;
		}

		var moverWidth;
		var staysWidth;
		if (anc.charAt(1) == 'r'){
			moverWidth = iwfWidth(elMover);
 			newX -= moverWidth;
		} else if (anc.charAt(1) == 'c'){
			moverWidth = iwfWidth(elMover);
			newX -= moverWidth / 2;
		}
		if (anc.charAt(2) == 'b'){
			newY += iwfHeight(elStays);
		} else if (anc.charAt(2) == 'c'){
			newY += iwfHeight(elStays) / 2;
		}
		if (anc.charAt(3) == 'r'){
			staysWidth = iwfWidth(elStays);
			newX += staysWidth;
		} else if (anc.charAt(3) == 'c'){
			staysWidth = iwfWidth(elStays);
			newX += staysWidth / 2;
		}

//iwfLog(iwfAttribute(elMover, 'id') + ' width:' + moverWidth + '\n' + iwfAttribute(elStays, 'id') + ' width:' + staysWidth);

		// move to those alignment points
		iwfMoveTo(elMover, newX, newY, totalTicks, totalTicks, motionType);
	}
}

function iwfDockTo(id1, id2, anchor1, anchor2, totalTicks, motionType){
	var elSlave = iwfGetById(id1);
	var elMaster = iwfGetById(id2);

	if (elSlave && elMaster){

		// dock elSlave to elMaster...

		// pull all items currently docked to elMaster
		var dockers = iwfAttribute(elMaster,'iwfDockers');
		// append elSlave to that list
		if(!dockers){
			dockers = iwfAttribute(elSlave, 'id');
		} else {
			var arrDockers = dockers.split(",");
			if (arrDockers.length == 0){
				arrDockers = new Array(dockers);
			}

			var slaveId = iwfAttribute(elSlave, 'id');
			var found = false;
			for(var i=0;i<arrDockers.length;i++){
				if (arrDockers[i] == slaveId){
					found = true;
				}
			}
			if (!found){
				// elSlave is not in elMaster's list of dockers yet.  add him.
				dockers += "," + iwfAttribute(elSlave, 'id');
			}
		}

		// write list back to elMaster
		iwfAttribute(elMaster, 'iwfDockers', dockers);

		// have elSlave remember who he's docked to
		iwfAttribute(elSlave, 'iwfDockedTo', iwfAttribute(elMaster, 'id'));


//iwfLog("dockers for " + iwfAttribute(elMaster, 'id') + " = " + dockers, true);


		iwfAlignTo(elSlave, elMaster, anchor1, anchor2, totalTicks, motionType);

	}


}

function iwfXScroll(id) {
	var scrollx=0;
	var el = iwfGetById(id);
	if (!el){
		if(document.documentElement && document.documentElement.scrollLeft) { scrollx=document.documentElement.scrollLeft; }
		else if(document.body && iwfExists(document.body.scrollLeft)) { scrollx=document.body.scrollLeft; }
	} else {
		if (iwfIsNumber(el.scrollLeft)) { scrollx = el.scrollLeft; }
	}
	return scrollx;
}
function iwfYScroll(id) {
	var scrolly=0;
	var el = iwfGetById(id);
	if (!el){
		if(document.documentElement && document.documentElement.scrollTop) { scrolly=document.documentElement.scrollTop; }
		else if(document.body && iwfExists(document.body.scrollTop)) { scrolly=document.body.scrollTop; }
	} else {
		if (iwfIsNumber(el.scrollTop)) { scrolly = el.scrollTop; }
	}
	return scrolly;
}



// -----------------------------------
// End: Positioning
// -----------------------------------

// -----------------------------------
// Begin: Size
// -----------------------------------

function iwfClientHeight(){
  var vHeight = 0;
	if(document.compatMode == 'CSS1Compat' && document.documentElement && document.documentElement.clientHeight) {
		vHeight = document.documentElement.clientHeight;
	} else if(document.body && document.body.clientHeight) {
		vHeight = document.body.clientHeight;
	} else if(iwfExists(window.innerHeight,window.innerHeight,document.height)) {
		vHeight = window.innerHeight;
		if(document.height>window.innerHeight) {
			vHeight -= 16;
		}
	}
  return vHeight;
}

function iwfClientWidth(){
	var vWidth = 0;
	if(document.compatMode == 'CSS1Compat' && document.documentElement && document.documentElement.clientWidth) {
		vWidth = document.documentElement.clientWidth;
	} else if(document.body && document.body.clientWidth) {
		vWidth = document.body.clientWidth;
	} else if(iwfExists(window.innerWidth,window.innerWidth,document.width)) {
		vWidth = window.innerWidth;
		if(document.width>window.innerWidth) {
			vWidth -= 16;
		}
	}
	return vWidth;
}

function iwfWidth(id, neww){
	var el = iwfGetById(id);
	if (!el) {
		// assume entire page (not client area -- aka visible area,
		// but entire page size which includes area that spills past the
		// visible portion)
		var cw = iwfClientWidth();
		var sw = document.body.scrollWidth;
		return Math.max(cw, sw);
	}
	var w = 0;

	var width = iwfStyle(el, 'width');
	var pixelWidth = iwfStyle(el, 'pixelWidth');

	if (iwfExists(el.offsetWidth) && iwfIsString(width)){
		if (neww) {
			iwfDetermineWidth(el, neww);
		}
		w = el.offsetWidth;
	} else if (iwfExists(pixelWidth)) {
		if(neww) {
			iwfStyle(el, 'pixelWidth', neww);
		}
		w = iwfStyle(el, 'pixelWidth');
	} else {
		w = -1;
	}

//iwfLog('width of ' + iwfAttribute(el, 'id') + ' = ' + w, true);

	return w;
}

function iwfHeight(id, newh){
	var el = iwfGetById(id);
	if (!el) {
		// assume entire page (not client area -- aka visible area,
		// but entire page size which includes area that spills past the
		// visible portion)
		var ch = iwfClientHeight();
		var sh = document.body.scrollHeight;
		return Math.max(ch, sh);
	}
	var h = 0;
	var height = iwfStyle(el, 'height');
	var pixelHeight = iwfStyle(el, 'pixelHeight');
	if (iwfExists(el.offsetHeight) && iwfIsString(height)){
		if (newh) {
			iwfDetermineHeight(el, newh);
		}
		h = el.offsetHeight;
	} else if (pixelHeight) {
		if(newh) {
			iwfStyle(el, 'pixelHeight', newh);
		}
		h = iwfStyle(el, 'pixelHeight');
	} else {
		h = -1;
	}
	return h;
}

function iwfY2(id, y2){
	var el = iwfGetById(id);
	if (iwfExists(el)) {
		var y1 = iwfY(el);
		if (iwfExists(y2)){
			iwfHeight(el, y2 - y1);
		}
		return y1 + iwfHeight(el);
	}
	return 0;
}

function iwfX2(id, x2){
	var el = iwfGetById(id);
	if (iwfExists(el)) {
		var x1 = iwfX(el);
		if (iwfExists(x2)){
			iwfWidth(el, x2 - x1);
		}
		return x1 + iwfWidth(el);
	}
	return 0;
}

function iwfDetermineStyle(el,prop){
	return parseInt(document.defaultView.getComputedStyle(el,'').getPropertyValue(prop),10);
}
function iwfDetermineWidth(el,neww){
	var padl=0, padr=0, bdrl=0, bdrr=0;
	if (iwfExists(document.defaultView) && iwfExists(document.defaultView.getComputedStyle)){
		padl = iwfDetermineStyle(el,'padding-left');
		padr = iwfDetermineStyle(el,'padding-right');
		bdrl = iwfDetermineStyle(el,'border-left-width');
		bdrr = iwfDetermineStyle(el,'border-right-width');

	} else if(iwfExists(el.currentStyle,document.compatMode)){
		if(document.compatMode=='CSS1Compat'){
			padl = iwfToInt(el.currentStyle.paddingLeft, true);
			padr = iwfToInt(el.currentStyle.paddingRight, true);
			bdrl = iwfToInt(el.currentStyle.borderLeftWidth, true);
			bdrr = iwfToInt(el.currentStyle.borderRightWidth, true);
		}
	} else if(iwfExists(el.offsetWidth,iwfStyle(el, 'width'))){
		iwfStyle(el, 'width', neww + 'px');
		padl=el.offsetWidth - neww;
	}

	if(isNaN(padl)) { padl=0; }
	if(isNaN(padr)) { padr=0; }
	if(isNaN(bdrl)) { bdrl=0; }
	if(isNaN(bdrr)) { bdrr=0; }

	var w2 = neww - padl - padr - bdrl - bdrr;
	if (isNaN(w2) || w2 < 0) { return; }
	else { iwfStyle(el, 'width', w2 + 'px'); }
}

function iwfDetermineHeight(el,newh){
	var padt=0, padb=0, bdrt=0, bdrb=0;
	if(iwfExists(document.defaultView) && iwfExists(document.defaultView.getComputedStyle)){
		padt = iwfDetermineStyle(el,'padding-top');
		padb = iwfDetermineStyle(el,'padding-bottom');
		bdrt = iwfDetermineStyle(el,'border-top-height');
		bdrb = iwfDetermineStyle(el,'border-bottom-height');
	} else if(iwfExists(el.currentStyle,document.compatMode)){
		if(document.compatMode=='CSS1Compat'){
			padt = iwfToInt(el.currentStyle.paddingTop, true);
			padb = iwfToInt(el.currentStyle.paddingBottom, true);
			bdrt = iwfToInt(el.currentStyle.borderTopHeight, true);
			bdrb = iwfToInt(el.currentStyle.borderBottomHeight, true);
		}
	} else if(iwfExists(el.offsetHeight, iwfStyle(el, 'height'))){
		iwfStyle(el, 'height', newh + 'px');
		padt = el.offsetHeight - newh;
	}

	if(isNaN(padt)) { padt=0; }
	if(isNaN(padb)) { padb=0; }
	if(isNaN(bdrt)) { bdrt=0; }
	if(isNaN(bdrb)) { bdrb=0; }

	var h2 = newh - padt - padb - bdrt - bdrb;

	if(isNaN(h2) || h2 < 0) { return; }
	else { iwfStyle(el, 'height', h2 + 'px'); }
}

function iwfOverlaps(id1, id2) {
	var el1 = iwfGetById(id1);
	var el2 = iwfGetById(id2);

	if (!el1 || !el2) {return false;}

	var x1a = iwfX(el1);
	var x1b = iwfX2(el1);
	var y1a = iwfY(el1);
	var y1b = iwfY2(el1);

	var x2a = iwfX(el2);
	var x2b = iwfX2(el2);
	var y2a = iwfY(el2);
	var y2b = iwfY2(el2);

	if(x1a > x2b || x1b < x2a || y1a > y2b || y1b < y2a) {
		return false;
	} else {
		return true;
	}

}

function iwfFillClient(id){
	var el = iwfGetById(id);
	if (!el) { return; }
	iwfX(el, iwfXScroll());
	iwfY(el, iwfYScroll());
	iwfWidth(el, iwfClientWidth());
	iwfHeight(el, iwfClientHeight());
}

function iwfFillPage(id){
	var el = iwfGetById(id);
	if (!el) { return; }
	iwfX(el, 0);
	iwfY(el, 0);
//	iwfWidth(el, 20000);
//	iwfHeight(el, 20000);
	iwfWidth(el, iwfPageWidth());
	iwfHeight(el, iwfPageHeight());
}

function iwfPageWidth(){
	return iwfWidth();
}

function iwfPageHeight(){
	return iwfHeight();
}

function iwfXCenterClient(){
	var w = iwfClientWidth();
	var xoff = iwfXScroll();
	return (w / 2) + xoff
}

function iwfYCenterClient(){
	var h = iwfClientHeight();
	var yoff = iwfYScroll();
	return (h / 2) + yoff;
}

function iwfCenterInClient(id){
	var el = iwfGetById(id);
	if (!el) { return; }
	var w = iwfXCenterClient();
	var h = iwfYCenterClient();
	iwfX(el, w - (iwfWidth(el) / 2));
	iwfY(el, h - (iwfHeight(el) / 2));
}

function iwfCenterInPage(id){
	var el = iwfGetById(id);
	if (!el) { return; }
	var w = iwfWidth(document.body) / 2;
	var h = iwfWidth(document.body) / 2;
	iwfX(el, (w - iwfWidth(el) / 2));
	iwfY(el, (h - iwfHeight(el) / 2));
}

function iwfXCenter(id) {
	var el = iwfGetById(id);
	if (!el) {return 0;}
	return iwfX(el) + iwfWidth(el) / 2;
}

function iwfYCenter(id) {
	var el = iwfGetById(id);
	if (!el) {return 0;}
	return iwfY(el) + iwfHeight(el) / 2;
}

// -----------------------------------
// End: Size
// -----------------------------------

// -----------------------------------
// Begin: Event
// -----------------------------------

function iwfAddEvent(id, eventName,callback) {
	var el = iwfGetById(id);
	if (!el) {return;}

	var txt = callback;
	if (iwfIsString(callback)){
		callback = function() { eval(txt);};
	}

	if (el.addEventListener) {
		el.addEventListener(eventName.substr(2), callback, false);
	} else if (el.attachEvent) {
//iwfLog('attaching event ' + eventName + ' to element ' + el.id + ' with the callback:\n' + callback, true);
		el.attachEvent(eventName, callback);
	} else {
		iwfLogFatal("Couldn't add event " + eventName + " to element " + el.id + " because neither addEventListener nor attachEvent are implemented.", true);
	}
}

function iwfRemoveEvent(id, eventName, callback){
	var el = iwfGetById(id);
	if (!el) { return;}
	if (el.removeEventListener) {
		el.removeEventListener(eventName.substr(2), callback, false);
	} else if (el.detachEvent) {
		el.detachEvent(eventName, callback);
	} else {
		iwfLogFatal("Couldn't remove event " + eventName + " from element " + el.id + " because neither removeEventListener nor detachEvent are implemented.", true);
	}
}

function iwfCallAttribute(id, eventName, evt){
	var el = iwfGetById(id);
	if (!el) { return false; }

	var val = iwfAttribute(el, eventName);
//iwfLog("calling attribute " + eventName + "=" + val, true);
	if (val){
		eval(val);
	}

//	return;




	if (el.fireEvent){
iwfLog("firing event " + eventName + " on el " + el.id);
		el.fireEvent(eventName, evt);
	} else if (el.dispatchEvent){
		// chop off the "on" at the beginning...
//		eventName = eventName.substr(2);
//		iwfLog(eventName, true);
		var newEvent = null;
		if (document.createEvent){
			newEvent = document.createEvent("Events");
		} else {
			newEvent = document.createEventObject();
		}
		newEvent.initEvent(eventName, true, true); //, document.defaultView, 1, 0, 0, 0, 0, false, false, false, false, 0, null);
iwfLog("dispatching event " + eventName + " on el " + el.id);
		if (!el.dispatchEvent(newEvent)){
iwfLog("Could not el.dispatchEvent failed!", true);
			return false;
		}
	} else {
iwfLog("Could not el.fireEvent or el.dispatchEvent!", true);
		return false;
	}
	return true;
}

function iwfEvent(ev) {
	this.keyCode = 0;
	this.target = null;
	this.type = '';
	this.X = 0;
	this.Y = 0;
	var evt = ev || window.event;
	if(!evt) { return null; }

	if(evt.type) { this.type = evt.type; }
	if(evt.target) { this.target = evt.target; }
	else if(evt.srcElement) { this.target = evt.srcElement; }

	this.X = iwfX(evt.target);
	this.Y = iwfY(evt.target);

	if(iwfExists(evt.clientX,evt.clientY)) {
		this.X = evt.clientX + iwfXScroll();
		this.Y = evt.clientY + iwfYScroll();
	} else if (iwfExists(evt.offsetX, evt.offsetY)){
		this.X = evt.offsetX;
		this.Y = evt.offsetY;
	}

	if (evt.keyCode) { this.keyCode = evt.keyCode; }
	else if (iwfExists(evt.which)) { this.keyCode = evt.which; }

	return this;
}

// -----------------------------------
// End: Event
// -----------------------------------


// -----------------------------------
// Begin: Image
// -----------------------------------
function iwfRollover(id, overurl){
	var el = iwfGetById(id);
	if (!el) { return; }
	var rollover = null;
	if (overurl){
		rollover = overurl;
	} else {
		iwfAttribute(el, "rolloversrc");
	}
	if (!rollover) { return; }
	el.iwfOrigSrc = el.src;
	el.iwfRolloverImg = new Image();
	el.iwfRolloverImg.src = rollover;
	iwfAddEvent(el, 'onmouseover', iwfDoRollover);
	iwfAddEvent(el, 'onmouseout', iwfDoRollover);
}

function iwfDoRollover(ev){
	var evt = new iwfEvent(ev);
	var el = evt.target;
	if (el.src == el.iwfOrigSrc){
		iwfSwapImage(el, el.iwfRolloverImg);
	} else {
		iwfSwapImage(el, el.iwfOrigSrc);
	}
}

function iwfPreloadImage(id, newimg){
	var el = iwfGetById(id);
	if (!el) { return; }
	/* todo: preload images here */
}

function iwfSwapImage(id, newimg){
	var el = iwfGetById(id);
	if (!el) { return; }
	if (iwfIsString(newimg)){
		el.src = newimg;
	} else {
		el.src = newimg.src;
	}
}

// preload images and attach event handlers for rollovers
function iwfMapRollovers(){
	var nodes = iwfGetByTagName('img');
	for(var i=0;i<nodes.length;i++){
		iwfRollover(nodes[i]);
	}
}

// -----------------------------------
// End: Image
// -----------------------------------


// -----------------------------------
// Begin: Drag-N-Drop
// -----------------------------------

var iwfDragger = {el:null, curTarget:null, targets:new Array()};
var iwfHiZ = 2;

var iwfResizer = {elSrc:null, elTgt:null};

function iwfResize(resizeId, targetId){
	var resizer = iwfGetById(resizeId);
	if (!resizer) { return; }

	var target = iwfGetById(targetId);
	if (!target) { return; }

	iwfResizer.elSrc = resizer;
	iwfResizer.elTgt = target;


	// set the drag start / move / stop
	iwfAttribute(resizer, 'iwfdragbegin', 'iwfResizeStart()');
	iwfAttribute(resizer, 'iwfdragmove', 'iwfResizeMove()');
	iwfAttribute(resizer, 'iwfdragend', 'iwfResizeEnd()');

	iwfDrag(resizer);

}

function iwfResizeStart(){

}

function iwfResizeMove(resizeId, targetId){
	// elSrc should have already been moved to its new location.
	// make elTgt fit to it.
	var tgtX = iwfX(iwfResizer.elTgt);
	var tgtY = iwfY(iwfResizer.elTgt);

	var srcX2 = iwfX2(iwfResizer.elSrc);
	if (srcX2 - 100 < tgtX){
		srcX2 = tgtX + 100;
	}

	var srcY2 = iwfY2(iwfResizer.elSrc);
	if (srcY2 - 50 < tgtY){
		srcY2 = tgtY + 50;
	}
//iwfLog("srcX2:" + srcX2 + "\tsrcY2:" + srcY2);
//	iwfX1(iwfResizer.elSrc, srcX2 - iwfWidth(iwfResizer.elSrc));
//	iwfY1(iwfResizer.elSrc, srcY2 - iwfHeight(iwfResizer.elSrc));

//	iwfX2(iwfResizer.elTgt, srcX2);
//	iwfY2(iwfResizer.elTgt, srcY2);

	// if container exists, make it occupy all but titlebar space...
	if (iwfResizer.elTgt){
		var elContainer = iwfGetById(iwfResizer.elTgt.id + 'Container');
		if (elContainer){
			iwfHeight(elContainer, iwfHeight(iwfResizer.elTgt) - iwfHeight(iwfResizer.elTgt.id + 'TitleBar') - 2);
		}
	}


}

function iwfResizeEnd(){

iwfLog(iwfElementToString(iwfResizer.elSrc), true);

	iwfResizer.elSrc = null;
	iwfResizer.elTgt = null;
}

function iwfDrag(id) {

	var el = iwfGetById(id);
	if (!el) { return; }

//iwfLog(iwfElementToString(el), true);
	if (!iwfDragger.el) {
		el.iwfDragTarget = true;
		iwfAddEvent(el, 'onmousedown', iwfDragMouseDown);
		// BROCK: sync issues here in IE when there is no container.
		// HACK: force a container always? hmmmm...
//		iwfFireEvent(el, 'onmousedown');
	}
}
function iwfDragMouseDown(ev){

	var evt = new iwfEvent(ev);
	var el = evt.target;
	while(el && !el.iwfDragTarget) {
		el = iwfGetParent(el);
	}
	if (el) {

		iwfDragger.el = el;

		iwfAddEvent(document, 'onmousemove', iwfDragMouseMove);
		iwfAddEvent(document, 'onmouseup', iwfDragMouseUp);



		if (ev && ev.preventDefault) { ev.preventDefault(); }
		else if (window.event) { window.event.returnValue = false; }
		else if (iwfExists(ev.cancelBubble)) { ev.cancelBubble = true; }

		el.iwfDragOrigX = iwfX(el);
		el.iwfDragOrigY = iwfY(el);
		el.iwfDragOffsetX = evt.X - iwfX(el);
		el.iwfDragOffsetY = evt.Y - iwfY(el);


		iwfZIndex(el, iwfHiZ++);

		iwfCallAttribute(el, 'iwfdragbegin');
	}
}

function iwfDragMouseMove(ev){
	var evt = new iwfEvent(ev);

	if (iwfDragger.el) {
		if (evt && evt.preventDefault) { evt.preventDefault(); }
		else if (window.event) { window.event.returnValue = false; }
		else if (iwfExists(ev.cancelBubble)) { ev.cancelBubble = true; }

		var el = iwfDragger.el;


		var newX = evt.X - el.iwfDragOffsetX;
		if (newX > iwfClientWidth() - iwfWidth(el)){
					newX = iwfClientWidth() - iwfWidth(el);
		}
		if (newX < 0) {
			newX = 0;
		}

		var newY = evt.Y - el.iwfDragOffsetY;
		if (newY > iwfClientHeight() - iwfHeight(el)){
			newY = iwfClientHeight() - iwfHeight(el);
		}
		if (newY < 0) {
			newY = 0;
		}


		iwfX(el, newX);
		iwfY(el, newY);

		// and hilite any drop targets...
		for(var i=0;i<iwfDragger.targets.length;i++){
			if (!iwfDragger.curTarget && iwfOverlaps(iwfDragger.targets[i], iwfDragger.el)) {
				iwfDragOver(iwfDragger.targets[i]);
				break;
			}
		}

		iwfCallAttribute(el, 'iwfdragmove');

	}
}

function iwfDragMouseUp(ev) {
	if (iwfDragger.el) {
		if (ev && ev.preventDefault) { ev.preventDefault(); }
		else if (window.event) { window.event.returnValue = false; }
		else if (iwfExists(ev.cancelBubble)) { ev.cancelBubble = true; }

		var evt = new iwfEvent(ev);
		iwfRemoveEvent(document, 'onmousedown', iwfDragMouseDown);
		iwfRemoveEvent(document, 'onmousemove', iwfDragMouseMove);
		iwfRemoveEvent(document, 'onmouseup', iwfDragMouseUp);

		iwfCallAttribute(iwfDragger.el, 'iwfdragend');

		iwfDragDrop();
		iwfDragger.el.iwfDragTarget = false;
		iwfDragger.el = null;
	}
}

function iwfDragOver(idTarget) {
	var tgt = iwfGetById(idTarget);
	if (!tgt) { return; }

	if (!iwfDragger.el) { return;}

	if (iwfDragger.curTarget) { return; }


	iwfDragger.curTarget = tgt.id;


	tgt.iwfBackgroundColor = iwfStyle(tgt, 'backgroundColor');
	iwfStyle(tgt, 'backgroundColor', '#efefef');

	iwfDragger.el.iwfBorder = iwfStyle(iwfDragger.el, 'border');
	iwfStyle(iwfDragger.el, 'border', '3px solid blue');

}

function iwfDragOut() {

	var tgt = iwfGetById(iwfDragger.curTarget);
	if (!tgt) { return; }

	iwfDragger.curTarget = null;


	if (!iwfDragger.el) { return; }



	iwfStyle(iwfDragger.el, 'border', iwfDragger.el.iwfBorder);
	iwfStyle(tgt, 'backgroundColor', tgt.iwfBackgroundColor);


}

function iwfDragDrop() {

	var tgt = iwfGetById(iwfDragger.curTarget);

	iwfDragOut(iwfDragger.curTarget);



	if (!iwfDragger.el) { return; }

	var src = iwfGetById(iwfDragger.el);

	if (src) {
		if (!tgt) {
			if (iwfDragger.targets.length > 0) {
				// targets exist, but none were dropped on. return to original x/y
				iwfMoveTo(tgt, iwfAttribute(iwfDragger.el, 'iwfDragOrigX'), iwfAttribute(iwfDragger.el, 'iwfDragOrigY'), 30);
			}
		} else {
			// target found. dock to it.
			iwfDockTo(tgt, src, "tl", "tl", 30);
		}
	}
}

function iwfMapDropTargets(node) {

	if (!node || !node.childNodes) {
iwfLog('No childNodes found for ' + iwfElementToString(node), true);
		return;
	}

	for(var i=0; i<node.childNodes.length;i++){
iwfLog('child=' + iwfElementToString(node.childNodes[i]), true);
		if (iwfAttribute(node.childNodes[i], 'iwfDropTarget') == 'true'){
			iwfDragger.targets.push(iwfAttribute(node.childNodes[i], 'id'));
		}
		iwfMapDropTargets(node.childNodes[i]);
	}


}

function iwfMapDraggables(node){
	if (!node) {
iwfLog("when mapping draggables, node not found");
		return;
	} else if (!node.childNodes){
iwfLog("No childNodes found for " + iwfElementToString(node.childNodes[i]));
		return;
	}

	for(var i=0; i<node.childNodes.length;i++){
		if (iwfAttribute(node.childNodes[i], 'iwfDraggable') == 'true'){
iwfLog("Found draggable to map: " + iwfElementToString(node.childNodes[i]));
			iwfMakeDraggable(node.childNodes[i]);
		}
	}
}

function iwfMakeDraggable(id){
	var el = iwfGetById(id);
	if (!el) { return; }

	if (iwfAttribute(el, 'iwfDraggableMapped') == 'true'){
		// element has already been mapped for dragging. escape.
		return;
	}

	// mark it as being mapped as a drag target
	iwfAttribute(el, 'iwfDraggableMapped', 'true');
	iwfAttribute(el, 'iwfDragTarget', 'true');

	// make sure window is absolutely positioned and overflow is okay
	iwfStyle(el, 'position', 'absolute');
	iwfStyle(el, 'overflow', 'hidden');
	iwfStyle(el, 'cursor', 'move');

	iwfAddEvent(el, 'onmousedown', 'iwfDrag("' + el.id + '");');

}

function iwfMapWindows(node){
	if (!node) {
iwfLog("when mapping windows, node not found");
		return;
	} else if (!node.childNodes){
iwfLog("No childNodes found for " + iwfElementToString(node.childNodes[i]));
		return;
	}

	for(var i=0; i<node.childNodes.length;i++){
		if (iwfAttribute(node.childNodes[i], 'iwfWindow') == 'true'){
iwfLog("Found window to map: " + iwfElementToString(node.childNodes[i]));
			iwfGetOrCreateWindow(node.childNodes[i]);
		}
	}
}

function iwfGetOrCreateWindow(id){
	var el = iwfGetById(id);
	if (!el) { return null; }

	if (iwfAttribute(el, 'iwfWindowCreated') == 'true'){
		// window has already been created. escape.
		return null;
	}

	// make sure window is absolutely positioned and overflow is okay
	iwfStyle(el, 'position', 'absolute');
	iwfStyle(el, 'overflow', 'hidden');

	// create a title bar
	var elTitle = iwfGetOrCreateById(el.id + 'TitleBar', 'div');
	if (!elTitle) { return null; }

	iwfStyle(elTitle, 'backgroundColor', 'navy');
	iwfStyle(elTitle, 'color', 'white');
	iwfStyle(elTitle, 'cursor', 'move');
	elTitle.innerHTML = "&nbsp;" + iwfAttribute(el, 'iwfWindowTitle');

	// dragging title bar should move the window
	iwfAddEvent(elTitle, 'onmousedown',  'iwfDrag("' + el.id + '");');


	// create the container which will contain all other html specified in the div
	var elContainer = iwfGetOrCreateById(el.id + 'Container', 'div');
	if (!elContainer) { return null; }

	iwfStyle(elContainer, 'width', '100%');
	iwfStyle(elContainer, 'height', '90%');
	iwfStyle(elContainer, 'overflow', 'scroll');

	// transfer window contents into the new container
	elContainer.innerHTML = el.innerHTML;
	// clear the window
	el.innerHTML = '';


	// create the resizer which will handle resizing
	var elResizer = iwfGetOrCreateById(el.id + 'Resizer', 'div');
	if (!elResizer) { return null; }


	elResizer.innerHTML = "<table border='0' cellspacing='0' cellpadding='0' width='100%' height='3px' ><tr ><td width='95%' style='cursor:s-resize'>&nbsp;</td><td style='cursor:se-resize'>&nbsp;</td></tr></table>";
//	elResizer.innerHTML = '<span style="width:90%;background-color:red;color:white;cursor:s-resize;padding-right:30px;">blah</span><span style="width:20px;color:black;background-color:gray;cursor:se-resize">*</span>';



	// set style properties on resizer
//	iwfX(elResizer, iwfX(el) + 20);
//	iwfY(elResizer, iwfY(el) + 20);
//	iwfZIndex(elResizer, 9999999);
//	iwfHeight(elResizer, 15);
//	iwfWidth(elResizer, 15);
//	elTitle.style.cursor = 'move';
//	elResizer.style.position = 'absolute';
//	elResizer.style.borderStyle = 'solid';
//	elResizer.style.borderColor = 'black';
//	elResizer.style.borderWidth = '1px';
//	elResizer.backgroundColor = 'white';
//	elResizer.style.overflow = 'hidden';
//	elResizer.style.textAlign = 'center';
//	elResizer.style.cursor = 'se-resize';
//	elResizer.innerHTML = '-';

	// dragging the resizer should resize the window
	iwfAddEvent(elResizer, 'onmousedown', 'iwfResize("' + elResizer.id + '","' + el.id + '");');


	// add title bar to window
	iwfAddChild(el, elTitle, true);

	// add container to window
	iwfAddChild(el, elContainer);

	// add resizer to window
	iwfAddChild(el, elResizer);

//	iwfX(elResizer, iwfX2(el) - 15);
//	iwfY(elResizer, iwfY2(el) - 15);

iwfLog(iwfElementToString(elResizer),true);

	// align resizer to bottom right of window
	iwfResize(elResizer, el);



	// add the flag saying we've created the window
	iwfAttribute(el, 'iwfWindowCreated', 'true');

	return el;

}

// -----------------------------------
// End: Drag-N-Drop
// -----------------------------------

