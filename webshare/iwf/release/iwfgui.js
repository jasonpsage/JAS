if (!__iwfCoreIncluded){iwfLogFatal("IWF Dependency Error: you must set a reference to the iwfcore.js file *before* iwfgui.js! I.E.:\n\n<script type='text/javascript' src='iwfcore.js'></script>\n<script type='text/javascript' src='iwfgui.js'></script>", true);}
var __iwfGuiIncluded = true;function iwfShow(id, reserveSpace){var el = iwfGetById(id);if (reserveSpace){if (iwfExists(el) && iwfExists(el.style) && iwfExists(el.style.visibility)) { el.style.visibility = ''; }
} else {
if (iwfExists(el) && iwfExists(el.style) && iwfExists(el.style.display)) { el.style.display = ''; }
}
}
function iwfHide(id, reserveSpace){var el = iwfGetById(id);if (reserveSpace){if (el && iwfExists(el.style) && iwfExists(el.style.visibility)) { el.style.visibility = 'hidden'; }
} else {
if (el && iwfExists(el.style) && iwfExists(el.style.display)) { el.style.display = 'none'; }
}
}
function iwfHideDelay(id, ms, reserveSpace){var el = iwfGetById(id);if (!el) { return; }
_iwfClearTimeout(el, "hidedelay", "visible", true);if (ms < 1){iwfHide(el, reserveSpace);} else {
_iwfSetTimeout(el, "hidedelay", "visible", "iwfHideDelay('" + el.id + "', 0, " + reserveSpace + ")", ms);}
}
function iwfShowDelay(id, ms, reserveSpace){var el = iwfGetById(id);if (!el) { return; }
_iwfClearTimeout(el, "showdelay", "visible", true);if (ms < 1){iwfShow(el, reserveSpace);} else {
_iwfSetTimeout(el, "showdelay", "visible", "iwfShowDelay('" + el.id + "', 0, " + reserveSpace + ")", ms);}
}
function iwfShowGently(id, pct, reserveSpace){var el = iwfGetById(id);if (!el) { return; }
_iwfClearTimeout(el, "showgently", "visible", true);var opacity = iwfOpacity(el);if (iwfIsHidden(el)){iwfOpacity(el, 0, false, false);iwfShow(el, reserveSpace);}
opacity = iwfOpacity(el, pct, true);if (opacity < 100) {_iwfSetTimeout(el, "showgently", "visible", "iwfShowGently('" + el.id + "'," + pct + ", " + reserveSpace + ")", 50);}
}
function iwfHideGently(id, pct, reserveSpace){var el = iwfGetById(id);if (!el) { return; }
if (iwfIsHidden(el)) {return; }
_iwfClearTimeout(el, "hidegently", "visible", true);var opacity = iwfOpacity(el);if (opacity <= 0){iwfHide(el, reserveSpace);iwfOpacity(el, 100, false, true);} else {
iwfOpacity(el, -pct, true);_iwfSetTimeout(el, "hidegently", "visible", "iwfHideGently('" + el.id + "'," + pct + ", " + reserveSpace + ")", 50);}
}
function iwfHideGentlyDelay(id, pct, ms, reserveSpace){var el = iwfGetById(id);if (!el) { return; }
if (iwfIsHidden(el)) { return; }
_iwfClearTimeout(el, "hidegentlydelay", "visible", true);if (ms < 1){iwfHideGently(el, pct, reserveSpace);} else {
_iwfSetTimeout(el, "hidegentlydelay", "visible", "iwfHideGentlyDelay('" + el.id + "'," + pct + ", 0, " + reserveSpace + ")", ms);}
}
function iwfShowGentlyDelay(id, pct, ms, reserveSpace){var el = iwfGetById(id);if (!el) { return; }
_iwfClearTimeout(el, "showgentlydelay", "visible", true);if (ms < 1){iwfShowGently(el, pct, reserveSpace);} else {
_iwfSetTimeout(el, "showgentlydelay", "visible", "iwfShowGentlyDelay('" + el.id + "'," + pct + ", 0, " + reserveSpace + ")", ms);}
}
function iwfOpacity(id, pct, relative, keepHiddenIfAlreadyHidden){var el = iwfGetById(id);if (el){if (iwfExists(pct) && pct != null){var newPct = iwfToFloat(pct, true);if (relative){newPct = iwfOpacity(id, null, false);newPct += pct;}
if (newPct < 0){newPct = 0;} else if (newPct > 100){
newPct = 100;}
if (iwfExists(el.style.opacity)) { el.style.opacity = newPct/100; }
else if (iwfExists(el.style.filter)) { el.style.filter = "alpha(opacity=" + newPct + ")"; }
else if (iwfExists(el.style.mozOpacity)) { el.style.mozOpacity = newPct/100; }
if (newPct > 0 && !keepHiddenIfAlreadyHidden){if (iwfIsHidden(id)){iwfShow(id);}
}
return newPct;} else {
var val = null;if (iwfExists(el.style.opacity)){if (el.style.opacity == ''){val = 100;} else {
val = iwfToFloat(el.style.opacity, 2, true) * 100;}
} else if (iwfExists(el.style.filter)) {
if (el.style.filter){if (el.style.filter.indexOf("opacity") == 0){val = 100;} else {
val = iwfToFloat(el.style.filter, 2, true);}
} else {
val = 100;}
} else if (iwfExists(el.style.mozOpacity)) {
if (el.style.mozOpacity == ''){val = 100;} else {
val = iwfToFloat(el.style.mozOpacity, 2, true) * 100;}
}
return val;}
}
}
function iwfIsShown(id){return !iwfIsHidden(id);}
function iwfIsHidden(id){var el = iwfGetById(id);var hidden = false;if (iwfExists(el.style) && iwfExists(el.style.visibility)) {hidden = el.style.visibility == 'hidden';}
if (iwfExists(el.style) && iwfExists(el.style.display)) {hidden = hidden || el.style.display == 'none';}
return hidden;}
function iwfToggle(id, reserveSpace){if (iwfIsHidden(id)) {iwfShow(id, reserveSpace);} else {
iwfHide(id, reserveSpace);}
}
function _iwfSetTimeout(id, name, category, fn, ms){var el = iwfGetById(id);if (!el) { return false; }
var att = iwfAttribute(el, 'iwfTimeoutCategory' + category);if (!att){} else if (att != name){
_iwfClearTimeout(el.id, att, category);} else {
}
iwfAttribute(el, 'iwfTimeoutCategory' + category, name);var timeoutid = setTimeout(fn, ms);iwfAttribute(el, 'iwfTimeoutId' + category, timeoutid);return true;}
function _iwfCheckTimeout(id, name, category){var el = iwfGetById(id);if (!el) { return false; }
var att = iwfAttribute(el, 'iwfTimeoutCategory' + category);if (!att || att == name){return true;} else {
return false;}
}
function _iwfClearTimeout(id, name, category, forceful){var el = iwfGetById(id);if (!el) { return; }
var att = iwfAttribute(el, 'iwfTimeoutCategory' + category);if (att == name || forceful){clearTimeout(iwfAttribute(el, 'iwfTimeoutId' + category));iwfRemoveAttribute(el, 'iwfTimeoutId' + category);iwfRemoveAttribute(el, 'iwfTimeoutCategory' + category);}
}
function iwfDelay(ms, fpOrString){function _iwfDelayExpired(){if (localIsString){eval(localFpOrString);} else {
if (!localArgs || localArgs.length == 0){localFpOrString();} else if (localArgs.length == 1){
localFpOrString(localArgs[0]);} else {
var s = 'localFpOrString(';for(var i=0;i<localArgs.length;i++){if (i > 0){s += ', ';}
if(localArgs[i] == null){s += 'null';} else if(iwfIsString(localArgs[i])){
s += '"' + localArgs[i].replace(/"/gi, '\\"') + '"';} else {
s += localArgs[i];}
}
s += ')';eval(s);}
}
delete localFpOrString;delete localIsString;delete localArgs;}
var localFpOrString = fpOrString;var localIsString = iwfIsString(fpOrString);var localArgs = null;if (!iwfIsString(fpOrString)){if (arguments && arguments.length > 0){localArgs = new Array();for(var i=2;i<arguments.length;i++){localArgs.push(arguments[i]);}
}
}
setTimeout(_iwfDelayExpired, ms);}
function iwfX1(id, newx){return iwfX(id, newx);}
function iwfFocusSelect(id, promptmsg){var el = iwfGetById(id);if (promptmsg){alert(promptmsg);}
if (!iwfIsHidden(id)){try {el.focus();el.select();} catch(e) { }
}
return false;}
function iwfFocus(id, promptmsg){var el = iwfGetById(id);if (promptmsg){alert(promptmsg);}
if (!iwfIsHidden(id)){try {el.focus();} catch(e) { }
}
return false;}
function iwfX(id, newx){var absx = 0;if (iwfIsNumber(newx)) {absx = iwfSetX(id, newx);} else {
var el = iwfGetById(id);if (!el) { return 0; }
if (iwfIsString(el.style.left) && el.style.left.length > 0){absx = iwfToInt(el.style.left, true);if (isNaN(absx)) {absx = 0;}
} else if (iwfExists(el.style.pixelLeft) && el.style.pixelLeft) {
absx = el.style.pixelLeft;} else {
while (el) {if (iwfExists(el.offsetLeft)) { absx += el.offsetLeft; }
el = iwfGetParent(el, true);}
}
}
return absx;}
function iwfSetX(id, newx){var el = iwfGetById(id);if (!el) { return null; }
if(iwfExists(el.style) && iwfIsString(el.style.left)) {el.style.left = newx + 'px';}	else if(iwfExists(el.style) && iwfExists(el.style.pixelLeft)) {
el.style.pixelLeft = newx;}	else if(iwfExists(el.left)) {
el.left = newx;}
return newx;}
function iwfY1(id, newy){var el = iwfGetById(id);return iwfY(el, newy);}
function iwfY(id, newy){var absy = 0;if (iwfIsNumber(newy)) {absy = iwfSetY(id, newy);} else {
var el = iwfGetById(id);if (!el) { return 0; }
if (iwfIsString(el.style.top) && el.style.top.length > 0){absy = iwfToInt(el.style.top, true);if (isNaN(absy)) {absy = 0;}
} else if (iwfExists(el.style.pixelTop) && el.style.pixelTop) {
absy = el.style.pixelTop;} else {
while (el) {if (iwfExists(el.offsetTop)) { absy += el.offsetTop; }
el = iwfGetParent(el, true);}
}
}
return absy;}
function iwfSetY(id, newy){var el = iwfGetById(id);if (!el) { return null; }
if (iwfExists(el.style)){if (iwfIsString(el.style.top)) {el.style.top = newy + 'px';} else if(iwfExists(el.style.pixelTop)) {
el.style.pixelTop = newy;} else if(iwfExists(el.top)) {
el.top = newy;}
}
return newy;}
function iwfZIndex(id, z){var el = iwfGetById(id);if (!el) { return 0; }
if (iwfExists(el)){if (iwfExists(z)){el.style.zIndex = z;}
return iwfToInt(el.style.zIndex, true);}
return 0;}
function iwfMoveTo(id1, xDest, yDest, totalTicks, motionType){var el = iwfGetById(id1);if (el){var origX = iwfX1(el);var origY = iwfY1(el);_iwfClearTimeout(el, "moveto", "position", true);_iwfMoveDockedItems(el, xDest, yDest, totalTicks, motionType);if (!totalTicks){iwfX1(id1, xDest);iwfY1(id1, yDest);} else {
_iwfMoveTo(id1, origX, origY, xDest, yDest, totalTicks, totalTicks, motionType);}
}
}
function _iwfMoveDockedItems(id, xDest, yDest, totalTicks, motionType){var elMaster = iwfGetById(id);if (elMaster){var dockers = iwfAttribute(elMaster, 'iwfDockers');if (dockers && dockers.length > 0){dockers = dockers.split(",");for(var i=0;i<dockers.length;i++){var elSlave = iwfGetById(dockers[i]);if (elSlave){var xOffset = iwfX(elMaster) - iwfX(elSlave);var yOffset = iwfY(elMaster) - iwfY(elSlave);var xEnd = xDest - xOffset;var yEnd = yDest - yOffset;iwfMoveTo(elSlave, xEnd, yEnd, totalTicks, motionType);}
}
}
}
}
function _iwfMoveTo(id1, xOrig, yOrig, xDest, yDest, ticksLeft, totalTicks, motionType){var el = iwfGetById(id1);if (!el){} else {
el_id = iwfAttribute(el, 'id');_iwfClearTimeout(el, "moveto", "position", true);var elX = iwfX1(el);var elY = iwfY1(el);var epsilon = 0.001;var xDone = false;if (elX > xDest){if (xDest + epsilon > elX){xDone = true;}
} else {
if (xDest - epsilon < elX){xDone = true;}
}
var yDone = false;if (elY > yDest){if (yDest + epsilon > elY){yDone = true;}
} else {
if (yDest - epsilon < elY){yDone = true;}
}
if (ticksLeft <= 0 || (xDone && yDone)){iwfX1(el, xDest);iwfY1(el, yDest);} else {
var pctLeft = ticksLeft / totalTicks;var xTotal = xDest - xOrig;var yTotal = yDest - yOrig;var xCur, yCur, rt;switch(motionType){case 'd':case 'dec':default:rt = pctLeft * pctLeft * pctLeft * pctLeft * pctLeft * pctLeft;xCur = xOrig + (xTotal - (rt * xTotal));yCur = yOrig + (yTotal - (rt * yTotal));break;case 'a':case 'acc':pctLeft = 1 - pctLeft;rt = pctLeft * pctLeft * pctLeft * pctLeft;xCur = xOrig + (rt * xTotal);yCur = yOrig + (rt * yTotal);break;case 'b':case 'both':if (pctDone > 0.75){rt = pctLeft * pctLeft * pctLeft * pctLeft;xCur = xOrig + (xTotal - (rt * xTotal));yCur = yOrig + (yTotal - (rt * yTotal));} else if (pctDone < 0.25){
pctLeft = 1 - pctLeft;rt = pctLeft * pctLeft * pctLeft * pctLeft; xCur = xOrig + (rt * xTotal);yCur = yOrig + (rt * yTotal);} else {
xCur = xOrig + (pctLeft * xTotal);yCur = yOrig + (pctLeft * yTotal);}
break;case 'lin':case 'linear':case 'l':xCur = xOrig + (pctLeft * xTotal);yCur = yOrig + (pctLeft * yTotal);break;}
iwfX1(el, xCur);iwfY1(el, yCur);ticksLeft--;var fn = "_iwfMoveTo('" + el_id + "', " + xOrig + ", " + yOrig + ", " + xDest + ", " + yDest + ", " + ticksLeft + ", " + totalTicks + ", '" + motionType + "')";_iwfSetTimeout(el, "moveto", "position", fn, 50);}
}
}
function iwfUnDockFrom(id1, id2){var elSlave = iwfGetById(id1);if (elSlave){var slaveId = iwfAttribute(elSlave, 'id');var dockedTo = iwfAttribute(elSlave, 'iwfDockedTo');if (dockedTo){var elMaster = iwfGetById(dockedTo);if (elMaster){var dockers = iwfAttribute(elMaster, 'iwfDockers');if (dockers && dockers.length > 0){var arrDockers = dockers.split(",");if (arrDockers.length == 0){arrDockers.push(dockers);}
for(var i=0;i<arrDockers.length;i++){if (arrDockers[i] == slaveId){arrDockers.splice(i, 1);var output = arrDockers.join(",");iwfAttribute(elMaster, 'iwfDockers', output);break;}
}
}
}
iwfAttribute(elSlave, 'iwfDockedTo', null);}
}
}
function iwfAlignTo(id1, id2, anchor1, anchor2, totalTicks, motionType){var elMover = iwfGetById(id1);var elStays = iwfGetById(id2);if (elMover && elStays){var newX = iwfX(elStays);var newY = iwfY(elStays);var anc = ((anchor1 +'  ').substr(0,2) + (anchor2 + '  ').substr(0,2)).toLowerCase();if (anc.charAt(0) == 'b'){newY -= iwfHeight(elMover);} else if (anc.charAt(0) == 'c'){
newY -= iwfHeight(elMover) / 2;}
var moverWidth;var staysWidth;if (anc.charAt(1) == 'r'){moverWidth = iwfWidth(elMover);newX -= moverWidth;} else if (anc.charAt(1) == 'c'){
moverWidth = iwfWidth(elMover);newX -= moverWidth / 2;}
if (anc.charAt(2) == 'b'){newY += iwfHeight(elStays);} else if (anc.charAt(2) == 'c'){
newY += iwfHeight(elStays) / 2;}
if (anc.charAt(3) == 'r'){staysWidth = iwfWidth(elStays);newX += staysWidth;} else if (anc.charAt(3) == 'c'){
staysWidth = iwfWidth(elStays);newX += staysWidth / 2;}
iwfMoveTo(elMover, newX, newY, totalTicks, totalTicks, motionType);}
}
function iwfDockTo(id1, id2, anchor1, anchor2, totalTicks, motionType){var elSlave = iwfGetById(id1);var elMaster = iwfGetById(id2);if (elSlave && elMaster){var dockers = iwfAttribute(elMaster,'iwfDockers');if(!dockers){dockers = iwfAttribute(elSlave, 'id');} else {
var arrDockers = dockers.split(",");if (arrDockers.length == 0){arrDockers = new Array(dockers);}
var slaveId = iwfAttribute(elSlave, 'id');var found = false;for(var i=0;i<arrDockers.length;i++){if (arrDockers[i] == slaveId){found = true;}
}
if (!found){dockers += "," + iwfAttribute(elSlave, 'id');}
}
iwfAttribute(elMaster, 'iwfDockers', dockers);iwfAttribute(elSlave, 'iwfDockedTo', iwfAttribute(elMaster, 'id'));iwfAlignTo(elSlave, elMaster, anchor1, anchor2, totalTicks, motionType);}
}
function iwfXScroll(id) {var scrollx=0;var el = iwfGetById(id);if (!el){if(document.documentElement && document.documentElement.scrollLeft) { scrollx=document.documentElement.scrollLeft; }
else if(document.body && iwfExists(document.body.scrollLeft)) { scrollx=document.body.scrollLeft; }
} else {
if (iwfIsNumber(el.scrollLeft)) { scrollx = el.scrollLeft; }
}
return scrollx;}
function iwfYScroll(id) {var scrolly=0;var el = iwfGetById(id);if (!el){if(document.documentElement && document.documentElement.scrollTop) { scrolly=document.documentElement.scrollTop; }
else if(document.body && iwfExists(document.body.scrollTop)) { scrolly=document.body.scrollTop; }
} else {
if (iwfIsNumber(el.scrollTop)) { scrolly = el.scrollTop; }
}
return scrolly;}
function iwfClientHeight(){var vHeight = 0;if(document.compatMode == 'CSS1Compat' && document.documentElement && document.documentElement.clientHeight) {vHeight = document.documentElement.clientHeight;} else if(document.body && document.body.clientHeight) {
vHeight = document.body.clientHeight;} else if(iwfExists(window.innerHeight,window.innerHeight,document.height)) {
vHeight = window.innerHeight;if(document.height>window.innerHeight) {vHeight -= 16;}
}
return vHeight;}
function iwfClientWidth(){var vWidth = 0;if(document.compatMode == 'CSS1Compat' && document.documentElement && document.documentElement.clientWidth) {vWidth = document.documentElement.clientWidth;} else if(document.body && document.body.clientWidth) {
vWidth = document.body.clientWidth;} else if(iwfExists(window.innerWidth,window.innerWidth,document.width)) {
vWidth = window.innerWidth;if(document.width>window.innerWidth) {vWidth -= 16;}
}
return vWidth;}
function iwfWidth(id, neww){var el = iwfGetById(id);if (!el) { return 0; }
var w = 0;if (iwfExists(el)){if (iwfExists(el.style)){if (iwfExists(el.offsetWidth) && iwfIsString(el.style.width)){if (neww) iwfDetermineWidth(el, neww);w = el.offsetWidth;} else if (iwfExists(el.style.pixelWidth)) {
if(neww) el.style.pixelWidth = neww;w = el.style.pixelWidth;} else {
w = -1;}
} else if (iwfExists(el.clip) && iwfExists(el.clip.right)) {
if(newh) e.clip.right = neww;w = el.clip.right;} else {
w = -2;}
}
return w;}
function iwfHeight(id, newh){var el = iwfGetById(id);if (!el) return 0;var h = 0;if (iwfExists(el)){if (iwfExists(el.style)){if (iwfExists(el.offsetHeight) && iwfIsString(el.style.height)){if (newh) iwfDetermineHeight(el, newh);h = el.offsetHeight;} else if (iwfExists(el.style.pixelHeight)) {
if(newh) el.style.pixelHeight = newh;h = el.style.pixelHeight;} else {
h = -1;}
} else if (iwfExists(el.clip) && iwfExists(el.clip.bottom)) {
if(newh) e.clip.bottom = newh;h = el.clip.bottom;} else {
h = -2;}
}
return h;}
function iwfY2(id, y2){var el = iwfGetById(id);if (iwfExists(el)) {var y1 = iwfY(el);if (iwfExists(y2)){iwfHeight(el, y2 - y1);}
return y1 + iwfHeight(el);}
return 0;}
function iwfX2(id, x2){var el = iwfGetById(id);if (iwfExists(el)) {var x1 = iwfX(el);if (iwfExists(x2)){iwfWidth(el, x2 - x1);}
return x1 + iwfWidth(el);}
return 0;}
function iwfDetermineStyle(el,prop){return parseInt(document.defaultView.getComputedStyle(el,'').getPropertyValue(prop),10);}
function iwfDetermineWidth(el,neww){var padl=0, padr=0, bdrl=0, bdrr=0;if (iwfExists(document.defaultView) && iwfExists(document.defaultView.getComputedStyle)){padl = iwfDetermineStyle(el,'padding-left');padr = iwfDetermineStyle(el,'padding-right');bdrl = iwfDetermineStyle(el,'border-left-width');bdrr = iwfDetermineStyle(el,'border-right-width');} else if(iwfExists(el.currentStyle,document.compatMode)){
if(document.compatMode=='CSS1Compat'){padl = iwfToInt(el.currentStyle.paddingLeft, true);padr = iwfToInt(el.currentStyle.paddingRight, true);bdrl = iwfToInt(el.currentStyle.borderLeftWidth, true);bdrr = iwfToInt(el.currentStyle.borderRightWidth, true);}
} else if(iwfExists(el.offsetWidth,el.style.width)){
el.style.width = neww + 'px';padl=el.offsetWidth - neww;}
if(isNaN(padl)) { padl=0; }
if(isNaN(padr)) { padr=0; }
if(isNaN(bdrl)) { bdrl=0; }
if(isNaN(bdrr)) { bdrr=0; }
var w2 = neww - padl - padr - bdrl - bdrr;if (isNaN(w2) || w2 < 0) { return; }
else { el.style.width = w2 + 'px'; }
}
function iwfDetermineHeight(el,newh){var padt=0, padb=0, bdrt=0, bdrb=0;if(iwfExists(document.defaultView) && iwfExists(document.defaultView.getComputedStyle)){padt = iwfDetermineStyle(el,'padding-top');padb = iwfDetermineStyle(el,'padding-bottom');bdrt = iwfDetermineStyle(el,'border-top-height');bdrb = iwfDetermineStyle(el,'border-bottom-height');} else if(iwfExists(el.currentStyle,document.compatMode)){
if(document.compatMode=='CSS1Compat'){padt = iwfToInt(el.currentStyle.paddingTop, true);padb = iwfToInt(el.currentStyle.paddingBottom, true);bdrt = iwfToInt(el.currentStyle.borderTopHeight, true);bdrb = iwfToInt(el.currentStyle.borderBottomHeight, true);}
} else if(iwfExists(el.offsetHeight, el.style.height)){
el.style.height = newh + 'px';padt = el.offsetHeight - newh;}
if(isNaN(padt)) { padt=0; }
if(isNaN(padb)) { padb=0; }
if(isNaN(bdrt)) { bdrt=0; }
if(isNaN(bdrb)) { bdrb=0; }
var h2 = newh - padt - padb - bdrt - bdrb;if(isNaN(h2) || h2 < 0) { return; }
else { el.style.height = h2 + 'px'; }
}
function iwfOverlaps(id1, id2) {var el1 = iwfGetById(id1);var el2 = iwfGetById(id2);if (!el1 || !el2) {return false;}
var x1a = iwfX(el1);var x1b = iwfX2(el1);var y1a = iwfY(el1);var y1b = iwfY2(el1);var x2a = iwfX(el2);var x2b = iwfX2(el2);var y2a = iwfY(el2);var y2b = iwfY2(el2);if(x1a > x2b || x1b < x2a || y1a > y2b || y1b < y2a) {return false;} else {
return true;}
}
function iwfXCenter(id) {var el = iwfGetById(id);if (!el) {return 0;}
return iwfX(el) + iwfWidth(el) / 2;}
function iwfYCenter(id) {var el = iwfGetById(id);if (!el) {return 0;}
return iwfY(el) + iwfHeight(el) / 2;}
function iwfAddEvent(id, eventName,callback) {var el = iwfGetById(id);if (!el) {return;}
var txt = callback;if (iwfIsString(callback)){callback = function() { eval(txt);};
}
if (el.addEventListener) {el.addEventListener(eventName.substr(2), callback, false);} else if (el.attachEvent) {
el.attachEvent(eventName, callback);} else {
iwfLogFatal("Couldn't add event " + eventName + " to element " + el.id + " because neither addEventListener nor attachEvent are implemented.", true);}
}
function iwfRemoveEvent(id, eventName, callback){var el = iwfGetById(id);if (!el) { return;}
if (el.removeEventListener) {el.removeEventListener(eventName.substr(2), callback, false);} else if (el.detachEvent) {
el.detachEvent(eventName, callback);} else {
iwfLogFatal("Couldn't remove event " + eventName + " from element " + el.id + " because neither removeEventListener nor detachEvent are implemented.", true);}
}
function iwfCallAttribute(id, eventName, evt){var el = iwfGetById(id);if (!el) { return false; }
var val = iwfAttribute(el, eventName);if (val){eval(val);}
if (el.fireEvent){el.fireEvent(eventName, evt);} else if (el.dispatchEvent){
var newEvent = null;if (document.createEvent){newEvent = document.createEvent("Events");} else {
newEvent = document.createEventObject();}
newEvent.initEvent(eventName, true, true); if (!el.dispatchEvent(newEvent)){return false;}
} else {
return false;}
return true;}
function iwfEvent(ev) {this.keyCode = 0;this.target = null;this.type = '';this.X = 0;this.Y = 0;var evt = ev || window.event;if(!evt) { return null; }
if(evt.type) { this.type = evt.type; }
if(evt.target) { this.target = evt.target; }
else if(evt.srcElement) { this.target = evt.srcElement; }
this.X = iwfX(evt.target);this.Y = iwfY(evt.target);if(iwfExists(evt.clientX,evt.clientY)) {this.X = evt.clientX + iwfXScroll();this.Y = evt.clientY + iwfYScroll();} else if (iwfExists(evt.offsetX, evt.offsetY)){
this.X = evt.offsetX;this.Y = evt.offsetY;}
if (evt.keyCode) { this.keyCode = evt.keyCode; }
else if (iwfExists(evt.which)) { this.keyCode = evt.which; }
return this;}
function iwfRollover(id, overurl){var el = iwfGetById(id);if (!el) { return; }
var rollover = null;if (overurl){rollover = overurl;} else {
iwfAttribute(el, "rolloversrc");}
if (!rollover) { return; }
el.iwfOrigSrc = el.src;el.iwfRolloverImg = new Image();el.iwfRolloverImg.src = rollover;iwfAddEvent(el, 'onmouseover', iwfDoRollover);iwfAddEvent(el, 'onmouseout', iwfDoRollover);}
function iwfDoRollover(ev){var evt = new iwfEvent(ev);var el = evt.target;if (el.src == el.iwfOrigSrc){iwfSwapImage(el, el.iwfRolloverImg);} else {
iwfSwapImage(el, el.iwfOrigSrc);}
}
function iwfPreloadImage(id, newimg){var el = iwfGetById(id);if (!el) { return; }
/* todo: preload images here */}
function iwfSwapImage(id, newimg){var el = iwfGetById(id);if (!el) { return; }
if (iwfIsString(newimg)){el.src = newimg;} else {
el.src = newimg.src;}
}
function iwfMapRollovers(){var nodes = iwfGetByTagName('img');for(var i=0;i<nodes.length;i++){iwfRollover(nodes[i]);}
}
var iwfDragger = {el:null, curTarget:null, targets:new Array()};
var iwfHiZ = 2;var iwfResizer = {elSrc:null, elTgt:null};
function iwfResize(resizeId, targetId){var resizer = iwfGetById(resizeId);if (!resizer) { return; }
var target = iwfGetById(targetId);if (!target) { return; }
iwfResizer.elSrc = resizer;iwfResizer.elTgt = target;iwfAttribute(resizer, 'iwfdragbegin', 'iwfResizeStart()');iwfAttribute(resizer, 'iwfdragmove', 'iwfResizeMove()');iwfAttribute(resizer, 'iwfdragend', 'iwfResizeEnd()');iwfDrag(resizer);}
function iwfResizeStart(){}
function iwfResizeMove(resizeId, targetId){var tgtX = iwfX(iwfResizer.elTgt);var tgtY = iwfY(iwfResizer.elTgt);var srcX2 = iwfX2(iwfResizer.elSrc);if (srcX2 - 100 < tgtX){srcX2 = tgtX + 100;}
var srcY2 = iwfY2(iwfResizer.elSrc);if (srcY2 - 50 < tgtY){srcY2 = tgtY + 50;}
if (iwfResizer.elTgt){var elContainer = iwfGetById(iwfResizer.elTgt.id + 'Container');if (elContainer){iwfHeight(elContainer, iwfHeight(iwfResizer.elTgt) - iwfHeight(iwfResizer.elTgt.id + 'TitleBar') - 2);}
}
}
function iwfResizeEnd(){iwfResizer.elSrc = null;iwfResizer.elTgt = null;}
function iwfDrag(id) {var el = iwfGetById(id);if (!el) { return; }
if (!iwfDragger.el) {el.iwfDragTarget = true;iwfAddEvent(el, 'onmousedown', iwfDragMouseDown);}
}
function iwfDragMouseDown(ev){var evt = new iwfEvent(ev);var el = evt.target;while(el && !el.iwfDragTarget) {el = iwfGetParent(el);}
if (el) {iwfDragger.el = el;iwfAddEvent(document, 'onmousemove', iwfDragMouseMove);iwfAddEvent(document, 'onmouseup', iwfDragMouseUp);if (ev && ev.preventDefault) { ev.preventDefault(); }
else if (window.event) { window.event.returnValue = false; }
else if (iwfExists(ev.cancelBubble)) { ev.cancelBubble = true; }
el.iwfDragOrigX = iwfX(el);el.iwfDragOrigY = iwfY(el);el.iwfDragOffsetX = evt.X - iwfX(el);el.iwfDragOffsetY = evt.Y - iwfY(el);iwfZIndex(el, iwfHiZ++);iwfCallAttribute(el, 'iwfdragbegin');}
}
function iwfDragMouseMove(ev){var evt = new iwfEvent(ev);if (iwfDragger.el) {if (evt && evt.preventDefault) { evt.preventDefault(); }
else if (window.event) { window.event.returnValue = false; }
else if (iwfExists(ev.cancelBubble)) { ev.cancelBubble = true; }
var el = iwfDragger.el;var newX = evt.X - el.iwfDragOffsetX;if (newX > iwfClientWidth() - iwfWidth(el)){newX = iwfClientWidth() - iwfWidth(el);}
if (newX < 0) {newX = 0;}
var newY = evt.Y - el.iwfDragOffsetY;if (newY > iwfClientHeight() - iwfHeight(el)){newY = iwfClientHeight() - iwfHeight(el);}
if (newY < 0) {newY = 0;}
iwfX(el, newX);iwfY(el, newY);for(var i=0;i<iwfDragger.targets.length;i++){if (!iwfDragger.curTarget && iwfOverlaps(iwfDragger.targets[i], iwfDragger.el)) {iwfDragOver(iwfDragger.targets[i]);break;}
}
iwfCallAttribute(el, 'iwfdragmove');}
}
function iwfDragMouseUp(ev) {if (iwfDragger.el) {if (ev && ev.preventDefault) { ev.preventDefault(); }
else if (window.event) { window.event.returnValue = false; }
else if (iwfExists(ev.cancelBubble)) { ev.cancelBubble = true; }
var evt = new iwfEvent(ev);iwfRemoveEvent(document, 'onmousedown', iwfDragMouseDown);iwfRemoveEvent(document, 'onmousemove', iwfDragMouseMove);iwfRemoveEvent(document, 'onmouseup', iwfDragMouseUp);iwfCallAttribute(iwfDragger.el, 'iwfdragend');iwfDragDrop();iwfDragger.el.iwfDragTarget = false;iwfDragger.el = null;}
}
function iwfDragOver(idTarget) {var tgt = iwfGetById(idTarget);if (!tgt) { return; }
if (!iwfDragger.el) { return;}
if (iwfDragger.curTarget) { return; }
iwfDragger.curTarget = tgt.id;tgt.iwfBackgroundColor = tgt.style.backgroundColor;tgt.style.backgroundColor = '#efefef';iwfDragger.el.iwfBorder = iwfDragger.el.style.border;iwfDragger.el.style.border = '3px solid blue';}
function iwfDragOut() {var tgt = iwfGetById(iwfDragger.curTarget);if (!tgt) { return; }
iwfDragger.curTarget = null;if (!iwfDragger.el) { return; }
iwfDragger.el.style.border = iwfDragger.el.iwfBorder;tgt.style.backgroundColor = tgt.iwfBackgroundColor;}
function iwfDragDrop() {var tgt = iwfGetById(iwfDragger.curTarget);iwfDragOut(iwfDragger.curTarget);if (!iwfDragger.el) { return; }
var src = iwfGetById(iwfDragger.el);if (src) {if (!tgt) {if (iwfDragger.targets.length > 0) {iwfMoveTo(tgt, iwfAttribute(iwfDragger.el, 'iwfDragOrigX'), iwfAttribute(iwfDragger.el, 'iwfDragOrigY'), 30);}
} else {
iwfDockTo(tgt, src, "tl", "tl", 30);}
}
}
function iwfMapDropTargets(node) {if (!node || !node.childNodes) {return;}
for(var i=0; i<node.childNodes.length;i++){if (iwfAttribute(node.childNodes[i], 'iwfDropTarget') == 'true'){iwfDragger.targets.push(iwfAttribute(node.childNodes[i], 'id'));}
iwfMapDropTargets(node.childNodes[i]);}
}
function iwfMapDraggables(node){if (!node) {return;} else if (!node.childNodes){
return;}
for(var i=0; i<node.childNodes.length;i++){if (iwfAttribute(node.childNodes[i], 'iwfDraggable') == 'true'){iwfMakeDraggable(node.childNodes[i]);}
}
}
function iwfMakeDraggable(id){var el = iwfGetById(id);if (!el) { return; }
if (iwfAttribute(el, 'iwfDraggableMapped') == 'true'){return;}
iwfAttribute(el, 'iwfDraggableMapped', 'true');iwfAttribute(el, 'iwfDragTarget', 'true');el.style.position = 'absolute';el.style.overflow = 'hidden';el.style.cursor = 'move';iwfAddEvent(el, 'onmousedown', 'iwfDrag("' + el.id + '");');}
function iwfMapWindows(node){if (!node) {return;} else if (!node.childNodes){
return;}
for(var i=0; i<node.childNodes.length;i++){if (iwfAttribute(node.childNodes[i], 'iwfWindow') == 'true'){iwfGetOrCreateWindow(node.childNodes[i]);}
}
}
function iwfGetOrCreateWindow(id){var el = iwfGetById(id);if (!el) { return null; }
if (iwfAttribute(el, 'iwfWindowCreated') == 'true'){return null;}
el.style.position = 'absolute';el.style.overflow = 'hidden';var elTitle = iwfGetOrCreateById(el.id + 'TitleBar', 'div');if (!elTitle) { return null; }
elTitle.style.backgroundColor = 'navy';elTitle.style.color = 'white';elTitle.style.cursor = 'move';elTitle.innerHTML = "&nbsp;" + iwfAttribute(el, 'iwfWindowTitle');iwfAddEvent(elTitle, 'onmousedown',  'iwfDrag("' + el.id + '");');var elContainer = iwfGetOrCreateById(el.id + 'Container', 'div');if (!elContainer) { return null; }
elContainer.style.width='100%';elContainer.style.height='90%';elContainer.style.overflow='scroll';elContainer.innerHTML = el.innerHTML;el.innerHTML = '';var elResizer = iwfGetOrCreateById(el.id + 'Resizer', 'div');if (!elResizer) { return null; }
elResizer.innerHTML = "<table border='0' cellspacing='0' cellpadding='0' width='100%' height='3px' ><tr ><td width='95%' style='cursor:s-resize'>&nbsp;</td><td style='cursor:se-resize'>&nbsp;</td></tr></table>";iwfAddEvent(elResizer, 'onmousedown', 'iwfResize("' + elResizer.id + '","' + el.id + '");');iwfAddChild(el, elTitle, true);iwfAddChild(el, elContainer);iwfAddChild(el, elResizer);iwfResize(elResizer, el);iwfAttribute(el, 'iwfWindowCreated', 'true');return el;}
