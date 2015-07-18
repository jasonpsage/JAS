if (!__iwfCoreIncluded){iwfLogFatal("IWF Dependency Error: iwfxml.js is dependent upon iwfcore.js, so you *must* reference that file first.\n\nExample:\n\n<script type='text/javascript' src='iwfcore.js'></script>\n<script type='text/javascript' src='iwfxml.js'></script>", true);}
var __iwfXmlIncluded = true;function iwfXmlDoc(xml){if (!xml || xml.length == 0){return;}
this.loadXml(xml);}
iwfXmlDoc.prototype.loadXml = function(xml){this.pis = new Array();this._parsePIs(xml);this.childNodes = new Array();var node = new iwfXmlNode(xml);this.childNodes.push(node);this[node.nodeName] = node;}
iwfXmlDoc.prototype.outerXml = function(pretty, asHtml){var writer = new iwfWriter(true, pretty, asHtml);var buf = '';if (this.pis){for (var i = 0; i < this.pis.length; i++){buf += this.pis[i];buf += (i < this.pis.length - 1) ? "\n" : "";}
}
if (this.childNodes.length > 0){buf += this.childNodes[0].outerXml(writer);}
return buf;}
iwfXmlDoc.prototype.toString = function(pretty, asHtml){return this.outerXml(pretty, asHtml);}
iwfXmlDoc.prototype._parsePIs = function(xml){if (!xml || xml.length == 0) { return; }
var BEGIN_MONIKER = "<?";var END_MONIKER = "?>";var begin = xml.indexOf(BEGIN_MONIKER);var end = xml.indexOf(END_MONIKER);while (begin > -1 && end > begin) {var pi = xml.substr(begin, end + END_MONIKER.length);this.pis.push(pi);xml = xml.substr(end + END_MONIKER.length);begin = xml.indexOf(BEGIN_MONIKER);end = xml.indexOf(END_MONIKER);}
}
function iwfXmlNode(xml, parent){this.childNodes = new Array();this._text = '';this.attributes = new Array();this.attributeNames = new Array();this.attributeQuotes = new Array();this.namespaces = new Array();this.nodeName = 'UNKNOWN';this._parent = parent;this._isEmpty = false;if (!xml || xml.length == 0){return;} else {
this._parseXml(xml);}
this._htmlMode = false;}
iwfXmlNode.prototype.toString = function(innerOnly){if (innerOnly){return this.innerXml();} else {
return this.outerXml();}
}
iwfXmlNode.prototype.cloneNode = function(addToParent){var copy = new iwfXmlNode(this.outerXml());if (addToParent) {copy._parent = this._parent;copy._parent[copy.nodeName].push(copy);var originalIndex = this._parent.indexOfNode(this);if (originalIndex < 0) {originalIndex = this._parent.childNodes.length - 1;}
var deleteCount = this._parent.childNodes.length - originalIndex - 1;var endArray = this._parent.childNodes.splice(originalIndex + 1, deleteCount);this._parent.childNodes = this._parent.childNodes.concat(copy, endArray);}
return copy;}
iwfXmlNode.prototype.outerXml = function(writer){return this._serialize(writer, false, false, false);}
iwfXmlNode.prototype.innerXml = function(writer){return this._serialize(writer, true, false, true);}
iwfXmlNode.prototype.outerHtml = function(writer) {return this._serialize(writer, false, true, false);}
iwfXmlNode.prototype.innerHtml = function(writer) {return this._serialize(writer, true, true, true);}
iwfXmlNode.prototype._serialize = function(writer, pretty, asHtml, innerOnly){var pretty = false;if (iwfIsBoolean(writer)){pretty = writer;writer = false;}
if (!writer){writer = new iwfWriter(true, pretty, asHtml);}
if (!innerOnly){writer.writeNodeOpen(this.nodeName);for(var i=0;i<this.attributes.length;i++){writer.writeAttribute(i == 0, this.attributeNames[i], this.attributes[i], this.attributeQuotes[i]);}
}
writer.writeText(this._text, false);for(var i=0;i<this.childNodes.length;i++){this.childNodes[i].outerXml(writer);}
if (!innerOnly){writer.writeNodeClose();}
return writer.toString();}
iwfXmlNode.prototype.indexOfNode = function(node){for (var i = 0; i < this.childNodes.length; i++) {if (this.childNodes[i] == node) {return i;}
}
return -1;}
iwfXmlNode.prototype.removeAttribute = function(name){for(var i=0;i<this.attributeNames.length;i++){if (this.attributeNames[i] == name){this.attributeQuotes.splice(i, 1);this.attributeNames.splice(i, 1);this.attributes.splice(i, 1);delete this[name];break;}
}
}
iwfXmlNode.prototype.removeChildNode = function(node){for(var i=0;i<this.childNodes.length;i++){if (node == this.childNodes[i]){this.childNodes.splice(k, 1);var arr = this[node.nodeName];if (arr){if (arr.length > 1){var j = 0;for(j=0;i<arr.length;i++){if (arr[j] == node){arr.splice(j, 1);break;}
}
} else {
delete arr;}
}
break;}
}
}
iwfXmlNode.prototype.addAttribute = function(name, val, quotesToUse){if (!quotesToUse){quotesToUse = "'";}
if (!this[name]){this.attributeQuotes.push(quotesToUse);this.attributeNames.push(name);this.attributes.push(val);}
this[name] = val;if (name.indexOf("xmlns__") == 0 && name.length > 7) {var prefix = name.split("__")[1];if (!this.namespaces[prefix]) {this.namespaces[prefix] = val;}
}
}
iwfXmlNode.prototype.addChildNode = function(node, nodeName){if (nodeName && nodeName.length > 0 && nodeName.indexOf("#") == 0){var txt = this.trim(node);node = new iwfXmlNode('', this);node.origNodeName = nodeName;node.nodeName = this.normalize(nodeName);node._text = txt;this.childNodes.push(node);} else {
if (typeof(node) == 'string'){node = new iwfXmlNode(node, this);}
if (node.nodeName.indexOf("#") == 0){node._text = txt;this.childNodes.push(node);} else {
if (!this[node.nodeName]){this[node.nodeName] = new Array();}
this[node.nodeName].push(node);this.childNodes.push(node);}
}
}
iwfXmlNode.prototype.getText = function(){var txt = '';if (this.nodeName.indexOf('#') == 0){txt = this._text;}
for(var i=0;i<this.childNodes.length;i++){txt += this.childNodes[i].getText();}
return txt;}
iwfXmlNode.prototype.setText = function(newText){if (this.nodeName.indexOf('#') == 0){this._text = newText;}
else if (this.childNodes.length == 0) {this.addChildNode(newText, "#text");} else {
this.childNodes[0].setText(newText);}
}
iwfXmlNode.prototype.findNSByPrefix = function(prefix){if (this.namespaces && this.namespaces[prefix]) {return this.namespaces[prefix];} else if (this._parent) {
return this._parent.findNSByPrefix(prefix);} else {
return null;}
}
iwfXmlNode.prototype._parseXml = function(xml){var remainingXml = xml;while(remainingXml.length > 0){var type = this._determineNodeType(remainingXml);switch(type){case 'open':remainingXml = this._parseName(remainingXml);remainingXml = this._parseAtts(remainingXml);if (this._parent){this._parent.addChildNode(this, null);}
if (!this._isEmpty){remainingXml = this._parseChildren(remainingXml);} else {
return remainingXml;}
break;case 'text':return this._parseText(remainingXml);case 'close':return this._parseClosing(remainingXml);case 'end':return '';case 'pi':remainingXml = this._parsePI(remainingXml);break;case 'comment':return this._parseComment(remainingXml);case 'cdata':return this._parseCDATA(remainingXml);case 'directive':return this._parseDirective(remainingXml);case 'whitespace':remainingXml = this._parseWhitespace(remainingXml);if (this._parent){return remainingXml;}
break;default:iwfLogFatal('IWF Xml Parsing Error: undefined type of ' + type + ' returned for xml starting with "' + remainingXml + '"', true);break;}
}
return '';}
iwfXmlNode.prototype._determineNodeType = function(xml){if (!xml || xml.length == 0){return 'end';}
var trimmed = this.ltrim(xml);var firstTrimmedLt = trimmed.indexOf("<");switch(firstTrimmedLt){case -1:if (trimmed.length == 0){return 'whitespace';} else {
return 'text';}
case 0:var firstLt = xml.indexOf("<");if (firstLt > 0){return 'whitespace';} else {
switch(trimmed.charAt(1)){case '?':return 'pi';case '!':if (trimmed.substr(0,4) == '<!--'){return 'comment';} else if (trimmed.substr(0,9) == '<![CDATA[') {
return 'cdata';} else if (trimmed.toUpperCase().substr(0,9) == '<!DOCTYPE') {
return 'directive';} else {
return 'unknown: ' + trimmed.substr(0,10);}
case '/':return 'close';default:return 'open';}
}
default:return 'text';}
}
iwfXmlNode.prototype._parseName = function(xml){xml = xml.replace("\r\n", " ");xml = xml.replace("\n", " ");var firstSpace = xml.indexOf(" ");var firstApos = xml.indexOf("'");var firstQuote = xml.indexOf('"');var firstGt = xml.indexOf(">");if (firstGt == -1){iwfLogFatal("IWF Xml Parsing Error: Bad xml; no > found for an open node.", true);return '';}
if (xml.charAt(firstGt-1) == '/'){this._isEmpty = true;}
if (firstSpace > firstGt || firstSpace == -1){if (this._isEmpty){this.nodeName = this.trim(xml.substr(1,firstGt-2));} else {
this.nodeName = this.trim(xml.substr(1,firstGt-1));}
this.origNodeName = this.nodeName;if (this.nodeName && this.nodeName.length > 0){this.nodeName = this.normalize(this.nodeName);}
this._parseQName(this.nodeName);return xml.substr(firstGt);} else {
this.nodeName = this.trim(xml.substr(1,firstSpace-1));this.origNodeName = this.nodeName;if (this.nodeName && this.nodeName.length > 0){this.nodeName = this.normalize(this.nodeName);}
this._parseQName(this.nodeName);return xml.substr(firstSpace);}
}
iwfXmlNode.prototype._parseQName = function(qname){if (qname && qname.indexOf("__") > 0) {var parts = qname.split("__");this.prefix = parts[0];this.localName = parts[1];} else {
this.localName = qname;}
}
iwfXmlNode.prototype._parseAtts = function(xml){xml = this.ltrim(xml);var firstGt = xml.indexOf(">");if (firstGt == -1){iwfLogFatal("IWF Xml Parsing Error: Bad xml; no > found when parsing atts for " + this.nodeName, true);return '';} else if (firstGt == 0){
return xml.substr(firstGt+1);} else {
var attxml = xml.substr(0, firstGt);var re = /\s*?([^=]*?)=(['"])(.*?)(\2)/;var matches= re.exec(attxml);while(matches){attxml = this.ltrim(attxml.substr(matches[0].length));var attname = this.normalize(this.ltrim(matches[1]));var attval = matches[3];var quotesToUse = matches[2];this.addAttribute(attname, attval, quotesToUse);re = /\s*?([^=]*?)=(['"])(.*?)(\2)/;matches = re.exec(attxml);}
return xml.substr(firstGt+1);}
}
iwfXmlNode.prototype._parseChildren = function(xml){if (xml && xml.length > 0){var endnode = "</" + this.origNodeName + ">";while (xml && xml.length > 0 && xml.indexOf(endnode) > 0){var childNode = new iwfXmlNode('', this);xml = childNode._parseXml(xml);}
}
return xml;}
iwfXmlNode.prototype._parseClosing = function(xml){var firstGt = xml.indexOf("</");if (firstGt == -1){iwfLogFatal('IWF Xml Parsing Error: Bad xml; no </' + this.origNodeName + ' found', true);return '';} else {
var firstLt = xml.indexOf(">",firstGt);if (firstLt == -1){iwfLogFatal('IWF Xml Parsing Error: Bad xml; no > found after </' + this.origNodeName, true);return '';} else {
var result = xml.substr(firstLt+1);return result;}
}
}
iwfXmlNode.prototype._parseText = function(xml){return this._parsePoundNode(xml, "#text", "", "<", false);}
iwfXmlNode.prototype._parsePI = function(xml){var result = this._eatXml(xml, "?>", true);return result;}
iwfXmlNode.prototype._parseComment = function(xml){return this._parsePoundNode(xml, "#comment", "<!--", "-->", true);}
iwfXmlNode.prototype._parseCDATA = function(xml){return this._parsePoundNode(xml, "#cdata", "<![CDATA[", "]]>", true);}
iwfXmlNode.prototype._parseDirective = function(xml){return this._parsePoundNode(xml, '#directive', '<!DOCTYPE', '>', true);}
iwfXmlNode.prototype._parseWhitespace = function(xml){var result = '';if (this._parent && this._parent.nodeName.toLowerCase() == 'pre'){result = this._parsePoundNode(xml, "#text", "", "<", false);} else {
result = this._eatXml(xml, "<", false);}
return result;}
iwfXmlNode.prototype._parsePoundNode = function(xml, nodeName, beginMoniker, endMoniker, eatMoniker){var end = xml.indexOf(endMoniker);if (end == -1){iwfLogFatal("IWF Xml Parsing Error: Bad xml: " + nodeName + " does not have ending " + endMoniker, true);return '';} else {
var len = beginMoniker.length;var s = xml.substr(len, end - len);if (this._parent){this._parent.addChildNode(s, nodeName);}
var result = xml.substr(end + (eatMoniker ? endMoniker.length : 0));return result;}
}
iwfXmlNode.prototype._eatXml = function(xml, moniker, eatMoniker){var pos = xml.indexOf(moniker);if (eatMoniker){pos += moniker.length;}
return xml.substr(pos);}
iwfXmlNode.prototype.trim = function(s){return s.replace(/^\s*|\s*$/g,"");}
iwfXmlNode.prototype.ltrim = function(s){return s.replace(/^\s*/g,"");}
iwfXmlNode.prototype.rtrim = function(s){return s.replace(/\s*$/g,"");}
iwfXmlNode.prototype.normalize = function(nm){return nm.replace(/:/gi, '__');}
function iwfWriter(suppressProcessingInstruction, prettyPrint, htmlMode) {this._buffer = new String();if (!suppressProcessingInstruction){this.writeRaw("<?xml version='1.0' ?>");}
this._nodeStack = new Array();this._nodeOpened = false;this._prettyPrint = prettyPrint;this._htmlMode = htmlMode;}
iwfWriter.prototype.writePretty = function(writeLineFeed, writeTabs){if (this._prettyPrint){if (writeLineFeed){this.writeRaw('\n');}
if (writeTabs){var tabs = '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t';while (tabs.length < this._nodeStack.length){tabs += tabs;}
var depth = this._nodeStack.length;if (depth < 0) { depth = 0; }
this.writeRaw(tabs.substr(0,depth));}
}
}
iwfWriter.prototype.writeNode = function(name, txt){this.writeNodeOpen(name);this.writeText(txt, true);this.writeNodeClose();}
iwfWriter.prototype.writeNodeOpen = function(name){if (this._nodeOpened){this.writeRaw(">");}
this._nodeOpened = false;switch(name){case '#pi':this.writePretty(true, true);this.writeRaw('<?');break;case '#text':break;case '#cdata':this.writePretty(true, false);this.writeRaw('<![CDATA[');break;case '#comment':this.writePretty(true, true);this.writeRaw('<!--');break;default:this.writePretty(true, true);this.writeRaw("<" + this.normalize(name));this._nodeOpened = true;break;}
this._nodeStack.push(name);}
iwfWriter.prototype.writeAttribute = function(first, name, val, quotes){if (!this._nodeOpened){iwfLogFatal("IWF Xml Parsing Error: Appending attribute '" + this.normalize(name) + "' when no open node exists!", true);}
var attval = val;if (!quotes){quotes = "'";}
if (this._htmlMode){if (quotes == "'"){attval = attval.replace(/&quot;/gi, '\\"').replace(/'/gi, '&apos;').replace(/>/gi, '&gt;');} else {
attval = attval.replace(/&apos;/gi, "\\'").replace(/"/gi, '&quot;').replace(/>/gi, '&gt;');}
} else {
attval = iwfXmlEncode(attval);}
if (!first) { this.writePretty(true, true); }
this.writeRaw(" " + this.normalize(name) + "=" + quotes + attval + quotes);}
iwfWriter.prototype.writeAtt = function(first, name, val, quotes){this.writeAttribute(first, name, val, quotes);}
iwfWriter.prototype.writeText = function(txt, encodeAsXml){if (!txt || txt.length == 0){return;} else {
if (this._nodeOpened){this.writeRaw(">");this._nodeOpened = false;}
this.writePretty(true, true);if (encodeAsXml){this.writeRaw(iwfXmlEncode(txt));} else {
this.writeRaw(txt);}
}
}
iwfWriter.prototype.writeNodeClose = function(){if (this._nodeStack.length > 0){var name = this._nodeStack.pop();switch(name){case '#pi':this.writePretty(true, true);this.writeRaw("?>");break;case '#text':break;case '#cdata':this.writePretty(true, true);this.writeRaw("]]>");break;case '#comment':this.writePretty(true, true);this.writeRaw("-->");break;default:if (this._nodeOpened){switch(name){case 'script':case 'div':this.writeRaw("></" + this.normalize(name) + ">");break;default:this.writeRaw("/>");break;}
} else {
this.writePretty(true, true);this.writeRaw("</" + this.normalize(name) + ">");}
break;}
this._nodeOpened = false;}
}
iwfWriter.prototype.writeRaw = function(xml){this._buffer += xml;}
iwfWriter.prototype.toString = function(){return this._buffer;}
iwfWriter.prototype.clear = function(){this.buffer = new String();}
iwfWriter.prototype.normalize = function(name){return name.replace(/__/gi, ':');}
