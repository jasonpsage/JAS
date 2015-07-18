if (!__iwfCoreIncluded){iwfLogFatal("IWF Dependency Error: iwfobjects.js is dependent upon iwfcore.js, so you *must* reference that file first.\n\nExample:\n\n<script type='text/javascript' src='iwfcore.js'></script><script type='text/javascript' src='iwfobjects.js'></script>", true);}
var __iwfObjectsIncluded = true;/*function IwfArray(){this.length = 0;this.keys = new Array();}
IwfArray.prototype.shift = function(key, val){return this._add(0, key, val);}
IwfArray.prototype.unshift = function(){return this._remove(0);}
IwfArray.prototype.push = function(key){alert("push2");return this._add(this.length, key, null);}
IwfArray.prototype.pop = function(){return this._remove(this.length-1);}
IwfArray.prototype._add = function(idx, key, val){if (!iwfIsNumber(idx)){idx = 0;}
if (!iwfExists(val)){val = key;key = '_' + this.length;} else {
}
this.length++;if (key){this.keys.length++;}
for(var i=this.length;i>idx;i--){this[i] = this[i-1];if (key) {this.keys[i] = this.keys[i-1];}
}
this[idx] = val;if (key){this.keys[idx] = key;}
return val;}
IwfArray.prototype._remove = function(idx){var key = this.keys[idx];var val = this[idx];for(var i=idx;i<this.length;i++){this[i] = this[i+1];if (key) {this.keys[i] = this.keys[i+1];}
}
if (this.length > 0){this[this.length-1] = null;if (key){this.keys[this.length-1] = null;}
this.length--;if (key){this.keys._remove(idx);}
}
return val;}
IwfArray.prototype.find = function(idOrIndex){if (iwfIsNumber(idOrIndex)){return this[idOrIndex];} else if (iwfIsString(idOrIndex)){
for(var i=0;i<this.length;i++){var item = this[i];if (item && item.id == idOrIndex){return item;}
}
}
return null;}
IwfArray.prototype.clear = function(){while(this.length > 0){this._remove[this.length-1];}
}
IwfArray.prototype.toString = function(){var s = '';for(var i=0;i<this.length;i++){s += i.toString() + ':' + this.keys[i] + ':' + this[i] + '\n';}
return s;}
*/