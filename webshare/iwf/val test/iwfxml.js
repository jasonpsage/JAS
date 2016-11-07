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
//
// This reduces file size by about 30%, give or take.
//
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

if (!window.iwfGetById){
	iwfLog("IWF Dependency Error: iwfxml.js is dependent upon iwfcore.js, so you *must* reference that file first.\n\nExample:\n\n<script type='text/javascript' src='iwfcore.js'></script>\n<script type='text/javascript' src='iwfxml.js'></script>", true);
}


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

	// note this root node is not an array, as there will always
	// be exactly 1 root.
	var node = new iwfXmlNode(xml);
	this.childNodes = new Array();
	this.childNodes.push(node);
	this[node.nodeName] = node;

	this._html = false;

}

iwfXmlDoc.prototype.toString = function(pretty){
	this._html = false;
	return this.outerXml(pretty);
}

iwfXmlDoc.prototype.outerXml = function(pretty){
	if (!this.childNodes || this.childNodes.length < 1){
		return null;
	} else {
		var writer = new iwfWriter(true, pretty, this._html);
		return this.childNodes[0].outerXml(writer);
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

iwfXmlNode.prototype.outerXml = function(writer){
	return this._serialize(writer, false);
}

iwfXmlNode.prototype.innerXml = function(writer){
	return this._serialize(writer, true)
}

iwfXmlNode.prototype.outerHtml = function() {
	this._htmlMode = true;
	var ret = this.outerXml();
	this._htmlMode = false;
	return ret;
}

iwfXmlNode.prototype.innerHtml = function() {
	this._htmlMode = true;
	var ret = this.innerXml();
	this._htmlMode = false;
	return ret;
}

iwfXmlNode.prototype._serialize = function(writer, innerOnly){
	var pretty = false;
	if (typeof(writer) == 'boolean'){
		pretty = writer;
		writer = false;
	}
	if (!writer){
		writer = new iwfWriter(true, pretty, this._htmlMode);
	}

	if (!innerOnly){
		writer.writeNodeOpen(this.nodeName);
		for(var i=0;i<this.attributes.length;i++){
			writer.writeAttribute(this.attributeNames[i], this.attributes[i], this.attributeQuotes[i]);
		}
	}

	writer._writeRawText(this._text);
	for(var i=0;i<this.childNodes.length;i++){
		this.childNodes[i].outerXml(writer);
	}

	if (!innerOnly){
		writer.writeNodeClose();
	}

	return writer.toString();
}

iwfXmlNode.prototype.removeAttribute = function(name){
	name = this._normalize(name);
	for(var i=0;i<this.attributeNames.length;i++){
		if (this.attributeNames[i] == name){

			// found the attribute. splice it out of all the arrays.
			this.attributeQuotes.splice(j, 1);
			this.attributeNames.splice(j, 1);
			this.attributes.splice(j, 1);
			// remove from our object and jump out of the loop
			delete this[name];
			break;


//			// found the attribute.  move all ones following it down one
//			for(var j=i;j<this.attributeNames.length-1;j++){
//				this.attributeQuotes[j] = this.attributeQuotes[j+1];
//				this.attributeNames[j] = this.attributeNames[j+1];
//				this.attributes[j] = this.attributes[j+1];
//			}
//			// pop off the last one, as it's now a duplicate
//			this.attributeQuotes.pop();
//			this.attributeNames.pop();
//			this.attributes.pop();
//			delete this[name];
//			break;
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
	name = this._normalize(name);
	if (!this[name]){
		this.attributeQuotes.push(quotesToUse);
		this.attributeNames.push(name);
		this.attributes.push(val);
	}
	this[name] = val;
}

iwfXmlNode.prototype.addChildNode = function(node, nodeName){
	if (nodeName && nodeName.length > 0 && nodeName.indexOf("#") == 0){
		var txt = node;
		node = new iwfXmlNode('', this);

		// 2006-08-15 thanks Val for reporting the namespace bug...
		node.origNodeName = nodeName;
		iwfLog('addChildNode before: ' + this.origNodeName + ' - ' + this.nodeName);
		node.nodeName = this._normalize(nodeName);
		iwfLog('addChildNode after: ' + this.origNodeName + ' - ' + this.nodeName);

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

			if (!this.childNodes[node.nodeName]){
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
				iwfLog('IWF Xml Parsing Error: undefined type of ' + type + ' returned for xml starting with "' + remainingXml + '"', true);
				break;
		}

	}

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
				return 'whitespace'
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

	var firstSpace = xml.indexOf(" ");
	var firstApos = xml.indexOf("'");
	var firstQuote = xml.indexOf('"');
	var firstGt = xml.indexOf(">");

	if (firstGt == -1){
		iwfLog("IWF Xml Parsing Error: Bad xml; no > found for an open node.", true);
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
			this.nodeName = xml.substr(1,firstGt-2);
		} else {
// <h1>
			this.nodeName = xml.substr(1,firstGt-1);
		}
		this.origNodeName = this.nodeName;
		if (this.nodeName && this.nodeName.length > 0){
			this.nodeName = this._normalize(this.nodeName);
		}

		iwfLog('_parseName: ' + this.origNodeName + ' - ' + this.nodeName);

		// return starting at > so parseAtts knows there are no atts.
		return xml.substr(firstGt);
	} else {
// <h1 >
// <h1 att='val'>
// <h1 att='val'/>
		this.nodeName = xml.substr(1,firstSpace-1);
		this.origNodeName = this.nodeName;
		if (this.nodeName && this.nodeName.length > 0){
			this.nodeName = this._normalize(this.nodeName);
		}

		iwfLog('_parseName (space): ' + this.origNodeName + ' - ' + this.nodeName);

		// eat everything up to the space, return the rest
		return xml.substr(firstSpace);
	}

}

iwfXmlNode.prototype._parseAtts = function(xml){


	xml = this.ltrim(xml);
	var firstGt = xml.indexOf(">");
	if (firstGt == -1){
		iwfLog("IWF Xml Parsing Error: Bad xml; no > found when parsing atts for " + this.nodeName, true);
		return '';
	} else if (firstGt == 0){
		// no atts.
		return xml.substr(firstGt+1);
	} else {
		// at least one att exists.
		var attxml = xml.substr(0, firstGt);
		var re = /\s*?([^=]*?)=(['"])(.*?)(\2)/;
		var matches= re.exec(attxml)
		while(matches){
			attxml = this.ltrim(attxml.substr(matches[0].length));
			var attname = this._normalize(this.ltrim(matches[1]));
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
		iwfLog('IWF Xml Parsing Error: Bad xml; no </' + this.origNodeName + ' found', true);
		return '';
	} else {
		var firstLt = xml.indexOf(">",firstGt);
		if (firstLt == -1){
			iwfLog('IWF Xml Parsing Error: Bad xml; no > found after </' + this.origNodeName, true);
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
		iwfLog("IWF Xml Parsing Error: Bad xml: " + nodeName + " does not have ending " + endMoniker, true);
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

iwfXmlNode.prototype._normalize = function(nm){
//	return nm;
	return nm.replace(/-/gi, '_').replace(/:/gi, '__');
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
	this._htmlMode = htmlMode
}

iwfWriter.prototype.writePretty = function(lfBeforeTabbing){
	if (this._prettyPrint){
		if (lfBeforeTabbing){
			this.writeRaw('\n');
		}

		// assumption is most xml won't have a maximum node depth exceeding 30...
		var tabs = '\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t';
		while (tabs.length < this._nodeStack.length){
			// but some xml might exceed node depth of 30, so keep tacking on another 30 tabs until we have enough...
			// I know this is an awkward way of doing it, but I wanted to avoid looping and concatenating for "most" xml...
			tabs += tabs;
		}
		this.writeRaw(tabs.substr(0,this._nodeStack.length));
	}
}

iwfWriter.prototype.writeNode = function(name, txt){
	this.writeNodeOpen(name);
	this.writeText(txt);
	this.writeNodeClose();
}

iwfWriter.prototype.writeNodeOpen = function(name){
	if (this._nodeOpened){
		this.writeRaw(">");
	}
	this._nodeOpened = false;

	this.writePretty(true);

	switch(name){
		case '#pi':
			this.writeRaw('<?');
			break;
		case '#text':
			// do nothing
			break;
		case '#cdata':
			this.writeRaw('<![CDATA[');
			break;
		case '#comment':
			this.writeRaw('<!--');
			break;
		default:
			this.writeRaw("<" + this._normalize(name));
			this._nodeOpened = true;
			break;
	}
	this._nodeStack.push(name);
}

iwfWriter.prototype.writeAttribute = function(name, val, quotes){
	if (!this._nodeOpened){
		iwfLog("IWF Xml Parsing Error: Appending attribute '" + this._normalize(name) +
			"' when no open node exists!", true);
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

	this.writeRaw(" " + this._normalize(name) + "=" + quotes + attval + quotes);
}

iwfWriter.prototype.writeAtt = function(name, val, quotes){
	this.writeAttribute(name, val, quotes);
}

iwfWriter.prototype._writeRawText = function(txt){
	if (!txt || txt.length == 0){
		// no text to write. do nothing.
		return;
	} else {
		if (this._nodeOpened){
			this.writeRaw(">");
			this._nodeOpened = false;
		}

		this.writeRaw(txt);
	}
}

iwfWriter.prototype.writeText = function(txt){
	if (!txt || txt.length == 0){
		// no text to write. do nothing.
		return;
	} else {
		if (this._nodeOpened){
			this.writeRaw(">");
			this._nodeOpened = false;
			this.writePretty(true);
		}

		this.writeRaw(iwfXmlEncode(txt));
	}
}

iwfWriter.prototype.writeNodeClose = function(){
	if (this._nodeStack.length > 0){
		var name = this._nodeStack.pop();

		if (!this._nodeOpened && name != '#text'){
			this.writePretty(true);
		}

		switch(name){
			case '#pi':
				this.writeRaw("?>");
				break;
			case '#text':
				// do nothing
				break;
			case '#cdata':
				this.writeRaw("]]>");
				break;
			case '#comment':
				this.writeRaw("-->");
				break;
			default:
				if (this._nodeOpened){
					//! hack for <script /> and <div /> needing to be <script></script> or <div></div>
					switch(name){
						case 'script':
						case 'div':
							this.writeRaw("></" + this._normalize(name) + ">");
							break;
						default:
							this.writeRaw("/>");;
							break;
					}
				} else {
					this.writeRaw("</" + this._normalize(name) + ">");
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

iwfWriter.prototype._normalize = function(name){
//	return name;
	return name.replace(/__/gi, ':').replace(/_/gi, '-');
}
// -----------------------------------
// End: Xml Writer Object
// -----------------------------------

