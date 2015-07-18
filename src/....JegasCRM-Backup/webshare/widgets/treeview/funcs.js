// Functions from the TreeView Functions Demo
function op() {
 // This function is for folders that do not open pages themselves.
 // See the online instructions for more information.
}

// Note: To use the following two functions in a frameless layout, 
// move the functions to the main page in that frameless layout and 
// follow the instructions in the demoFuncsNodes.js file.
function exampleFunction(message) {
 alert("TreeView nodes can call JavaScript functions\n" + message)
}

// Note: If you rename the "windowWithoutToolbar" function, please 
// don't give it a name that starts with "op".  If you start the
// name with "op", you will conflict with the TreeView code.
function windowWithoutToolbar(urlStr, width, height) { 
 window.open(urlStr, '_blank', 'location=no,status=no,scrollbars=no,menubar=no,toolbar=no,directories=no,resizable=no,width=' + width + ',height=' + height) 
}
