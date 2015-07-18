__iwfBase64Table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";function iwfToByteArray(s){var ba = new Array();for(var i=0;i<s.length;i++){ba[i] = s.charCodeAt(i);}
return ba;}
function iwfToString(byteArray){var output = '';for(var i=0;i<byteArray.length;i++){var newChar = String.fromCharCode(byteArray[i]);if (byteArray[i] | 0x00 == 0x00){output += newChar;}
}
return output;}
function iwfToBase64(plainData) {var output = '';var insertedChars = 0;if (typeof(plainData) == 'string'){plainData = iwfToByteArray(plainData);}
for(var i=0;i<plainData.length;i+=3){output += _iwfEncode3To4(new Array(plainData[i], plainData[i+1], plainData[i+2]));if ((output.length - insertedChars) % 80 == 0){output += '\r\n';insertedChars += 2;}
}
return output;}
function iwfFromBase64(base64Text, returnAsBytes){var output = new Array();base64Text = base64Text.replace(/[\r\n]/gi, '');for(var i=0;i<base64Text.length;i+=4){var temp = _iwfDecode4To3(base64Text.substr(i, 4));output.push(temp[0], temp[1], temp[2]);}
if (returnAsBytes){return output;} else {
return iwfToString(output);}
}
function _iwfDecode4To3(base64Chars){var b64Bytes = new Array(4);var output = new Array(3);var lshift = new Array(2, 4, 6);var rshift = new Array(4, 2, 0);var mask = new Array(0xFF, 0xFF, 0x3F);for(var i=0;i<4;i++){if (base64Chars.charAt(i) == '='){b64Bytes[i] = 0;} else {
b64Bytes[i] = __iwfBase64Table.indexOf(base64Chars.charAt(i)) & 0xFF;}
}
for(var i=0;i<3;i++){output[i] = ((b64Bytes[i] << (i * 2) + 2) | (b64Bytes[i+1] >>> (6 - ((i+1) * 2)) & mask[i])) & 0xFF;}
return output;}
function _iwfEncode3To4(plainBytes){var bytes = new Array(3);var nulls = new Array(false, false, false);var flags = new Array(2);for(var i=0;i<bytes.length;i++){if (typeof(plainBytes[i]) != 'undefined') {bytes[i] = plainBytes[i];} else {
nulls[i] = true;}
}
var part1 = null;var part2 = null;var output = '';var mask = new Array(0x03, 0x0F, 0x3F);var lshift = new Array(4, 2, 0);var rshift = new Array(4, 6, 0);output += __iwfBase64Table.charAt((bytes[0] >>> 2) & 0xFF);for(var i=0; i<3; i++){if (nulls[i]){output += '=';} else {
output += __iwfBase64Table.charAt(((((bytes[i] & mask[i]) << lshift[i]) & 0xFF) | ((bytes[i+1] >>> rshift[i]) & 0xFF)) & 0xFF);}
}
return output;}