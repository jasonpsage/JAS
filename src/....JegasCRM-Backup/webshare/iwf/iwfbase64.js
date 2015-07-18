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
//! iwfbase64.js
//
// Client side base 64 encoding and decoding according to
// RFC 1421.
// see http://tools.ietf.org/html/rfc1421 for details ...
//
//! Dependencies:
//! none
//
//! Brock Weaver - brockweaver@users.sourceforge.net
// --------------------------------------------------------------------------
//! v 0.8 - 2007-02-05
//! Initial release.
//
//! Known Issues:
//!  None
//
// =========================================================================

__iwfBase64Table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

function iwfToByteArray(s){
	var ba = new Array();
	for(var i=0;i<s.length;i++){
		ba[i] = s.charCodeAt(i);
	}
	return ba;
}

function iwfToString(byteArray){
	var output = '';
	for(var i=0;i<byteArray.length;i++){
		var newChar = String.fromCharCode(byteArray[i]);
		if (byteArray[i] | 0x00 == 0x00){
			// exclude nulls from the output string
			output += newChar;
		}
	}
	return output;
}

function iwfToBase64(plainData) {
	var output = '';
	var insertedChars = 0;
	if (typeof(plainData) == 'string'){
		// encoding a string - first convert to byte array
		plainData = iwfToByteArray(plainData);
	}

	// encode the byte array into base64 chars
	for(var i=0;i<plainData.length;i+=3){
		output += _iwfEncode3To4(new Array(plainData[i], plainData[i+1], plainData[i+2]));
		if ((output.length - insertedChars) % 80 == 0){
			// insert a new line every 80 base64 characters
			output += '\r\n';
			insertedChars += 2;
		}
	}
	return output;
}

function iwfFromBase64(base64Text, returnAsBytes){

	var output = new Array();
	// rip out all new lines
	base64Text = base64Text.replace(/[\r\n]/gi, '');
	for(var i=0;i<base64Text.length;i+=4){
		var temp = _iwfDecode4To3(base64Text.substr(i, 4));
		output.push(temp[0], temp[1], temp[2]);
	}

	if (returnAsBytes){
		// output as byte array
		return output;
	} else {
		// output as string
		return iwfToString(output);
	}

}

// >>> is zero-fill right shift operator
// asc  h          e          l          l          o
// dec  104        101        108        108        111
// bin  011010 00  0110 0101  01 101100  011011 00  0110 1111
// b64  011010 000110   010101   101100  011011 000110   111100 000000 (last 8 bits padded on end)
// b64i 26     6        21       44      27     6        60     0
// b64c a      G        V        s	     b      G        8      =

//  DDDDDD
//  ddEEEE
//  eeeeFF
//  ffffff

function _iwfDecode4To3(base64Chars){

	var b64Bytes = new Array(4);
	var output = new Array(3);
	var lshift = new Array(2, 4, 6);
	var rshift = new Array(4, 2, 0);
	var mask = new Array(0xFF, 0xFF, 0x3F);

	// translate base64 chars into their byte representations
	for(var i=0;i<4;i++){
		if (base64Chars.charAt(i) == '='){
			b64Bytes[i] = 0;
		} else {
			b64Bytes[i] = __iwfBase64Table.indexOf(base64Chars.charAt(i)) & 0xFF;
		}
	}

	// realign 4 bytes of 6-bit data back to 3 bytes of 8-bit data
	for(var i=0;i<3;i++){
		output[i] = ((b64Bytes[i] << (i * 2) + 2) | (b64Bytes[i+1] >>> (6 - ((i+1) * 2)) & mask[i])) & 0xFF;
	}

	return output;

}

function _iwfEncode3To4(plainBytes){

	var bytes = new Array(3);
	var nulls = new Array(false, false, false);
	var flags = new Array(2);
	for(var i=0;i<bytes.length;i++){
		if (typeof(plainBytes[i]) != 'undefined') {
			bytes[i] = plainBytes[i];
		} else {
			nulls[i] = true;
		}
	}
	var part1 = null;
	var part2 = null;
	var output = '';

	var mask = new Array(0x03, 0x0F, 0x3F);
	var lshift = new Array(4, 2, 0);
	var rshift = new Array(4, 6, 0);

	// first 6 bits of first byte are handled differently than the remaining 18...
	output += __iwfBase64Table.charAt((bytes[0] >>> 2) & 0xFF);

	for(var i=0; i<3; i++){
		if (nulls[i]){
			output += '=';
		} else {
			output += __iwfBase64Table.charAt(((((bytes[i] & mask[i]) << lshift[i]) & 0xFF) | ((bytes[i+1] >>> rshift[i]) & 0xFF)) & 0xFF);
		}
	}

	return output;

}