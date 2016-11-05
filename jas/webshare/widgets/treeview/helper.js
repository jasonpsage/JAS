// helper.js is code Taken from a demo
//---
// The JavaScript for the buttons at the bottom of the left-hand frame follows.  
// These functions expand all nodes in the tree, collapse all nodes in the tree,
// open a specific node in the tree, or load a particular document in the 
// right-hand frame.
//
// The buttons in this demo are in a separate frame both from the actual tree 
// and from the actual content.  If you want to include the buttons in the same 
// frame as the tree, or in the same frame as the documents, move these 
// functions to the appropriate file.  For example, in the case of this example,
// if you want to display the buttons on the same frame as the tree, move these 
// functions to the demoFuncs.html file.  If you move these functions, you must
// update the DOM paths used to access the functions and used by the functions 
// themselves.

// The expandTree function expands all children nodes for the specified node. 
// The specified node must be a folder node. 
// When the specified node is the root node, this function opens all nodes in 
// the tree.  When the specified is not the root node, only the children of the 
// specified node are opened.
// Note that for some very large trees, the browser may time out when this 
// function is used.
function expandTree(folderObj) {
  var childObj;
  var i;
  
  // Open the folder
  if (!folderObj.isOpen)
    clickOnNodeObj(folderObj)
  
  // Call this function for all children
  for (i=0 ; i < folderObj.nChildren; i++)  {
    childObj = folderObj.children[i]
    if (typeof childObj.setState != "undefined") { // If this is a folder
      expandTree(childObj)
    }
  }
}

// The collapseTree function closes all nodes in the tree. 
function collapseTree() {
  // Close all folder nodes
  clickOnNodeObj(foldersTree)
  // Restore the tree to the top level
  clickOnNodeObj(foldersTree)
}

// The openFolderInTree function open all children nodes of the specified 
// node.  Note that in order to open a folder, we need to open the parent
// folders all the way to the root.  (Of course, this does not affect 
// selection highlight.)
function openFolderInTree(linkID) {
  var folderObj;
  folderObj = findObj(linkID);
  folderObj.forceOpeningOfAncestorFolders();
  if (!folderObj.isOpen)
   clickOnNodeObj(folderObj);
} 

// The loadSynchPage function load the appropriate document, as if
// the specified node on the tree was clicked.  This function also
// synchronizes the frames and highlights the selection (if highlight 
// is enabled).
function loadSynchPage(linkID) {
  var folderObj;
  docObj = findObj(linkID);
  docObj.forceOpeningOfAncestorFolders();
  clickOnLink(linkID,docObj.link,'basefrm'); 
  
  // Scroll the tree to show the selected node.
  // For this function to work with frameless pages, you will need to
  // remove the following code and also probably change other code in 
  // these functions.
  if (typeof document.body != "undefined") // To handle scrolling not working with NS4
   document.body.scrollTop=docObj.navObj.offsetTop
} 
