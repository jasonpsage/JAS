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
//! iwfobjects.js
//
// Utility Objects
//
//! Dependencies:
//! iwfcore.js
//
//! Brock Weaver - brockweaver@users.sourceforge.net
//! v 0.8 - 2007-01-04
//! Initial release.
//! --------------------------------------------------------------------------

// -----------------------------------
// Begin: Dependency Check
// -----------------------------------

if (!__iwfCoreIncluded){
	iwfLogFatal("IWF Dependency Error: iwfobjects.js is dependent upon iwfcore.js, so you *must* reference that file first.\n\nExample:\n\n<script type='text/javascript' src='iwfcore.js'></script><script type='text/javascript' src='iwfobjects.js'></script>", true);
}

// -----------------------------------
// End: Dependency Check
// -----------------------------------

var __iwfObjectsIncluded = true;

//Array.prototype.clear = function(){
//	while(this.length > 0){
//		this.pop();
//	}
//}

//Array.prototype.toString = function(){
//	var s = '';
//	for(key in this){
//		if (typeof(this[key]) != 'function'){
//			s += key + '=' + this[key] + '\n';
//		}
//	}
//	return s;
//}

/*
// -----------------------------------
// Begin: Array Object
// -----------------------------------
function IwfArray(){
	this.length = 0;
	this.keys = new Array();
}


IwfArray.prototype.shift = function(key, val){
	return this._add(0, key, val);
}

IwfArray.prototype.unshift = function(){
	return this._remove(0);
}

IwfArray.prototype.push = function(key){
	alert("push2");
	return this._add(this.length, key, null);

}
IwfArray.prototype.pop = function(){
	return this._remove(this.length-1);
}

IwfArray.prototype._add = function(idx, key, val){

	if (!iwfIsNumber(idx)){
		// make sure we don't try to use null or undefined for an index
		idx = 0;
	}

	//iwfLog("key=" + key + "val=" + val, true);
	if (!iwfExists(val)){
		// they specified only key, which is actually the value.
		// append only by index
		iwfLog("adding by index only, key doesn't exist: " + key, true);

		val = key;
		key = '_' + this.length;

	} else {
		// they specified both key and value.
		// append both by index and key
	}

	// now, key contains key to use
	// now, val contains val to write


	// assume array is {a,b,c,d,e} (length 5)
	// given idx=0, key=null, val='f'
	// given idx=2, key=null, val='f'
	// given idx=5, key=null, val='f'


	this.length++;
	if (key){
		this.keys.length++;
	}

	// move all items above given index up one
	for(var i=this.length;i>idx;i--){
		this[i] = this[i-1];
		if (key) {
			this.keys[i] = this.keys[i-1];
		}
	}
	// assign at given index
	this[idx] = val;
	if (key){
		this.keys[idx] = key;
	}

	return val;

}

IwfArray.prototype._remove = function(idx){
	var key = this.keys[idx];
	var val = this[idx];


	// move all items after given index down one
	for(var i=idx;i<this.length;i++){
		this[i] = this[i+1];
		if (key) {
			this.keys[i] = this.keys[i+1];
		}
	}

	// remove the last one as it's now a dupe
	if (this.length > 0){
		this[this.length-1] = null;
		if (key){
			this.keys[this.length-1] = null;
		}
		this.length--;
		if (key){
			this.keys._remove(idx);
		}
	}

	return val;
}

IwfArray.prototype.find = function(idOrIndex){
	if (iwfIsNumber(idOrIndex)){
		// look up by index
		return this[idOrIndex];
	} else if (iwfIsString(idOrIndex)){
		// it's the id.
		for(var i=0;i<this.length;i++){
			var item = this[i];
			if (item && item.id == idOrIndex){
				return item;
			}
		}
	}
	return null;
}

IwfArray.prototype.clear = function(){
	while(this.length > 0){
		this._remove[this.length-1];
	}
}

IwfArray.prototype.toString = function(){
	var s = '';
	for(var i=0;i<this.length;i++){
		s += i.toString() + ':' + this.keys[i] + ':' + this[i] + '\n';
	}
	return s;
}
// -----------------------------------
// End: Array Object
// -----------------------------------
*/
