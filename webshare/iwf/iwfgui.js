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

	iwfLog("current vis=" + iwfStyle(el, 'visibility') + "; current disp=" + iwfStyle(el, 'display'));



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

