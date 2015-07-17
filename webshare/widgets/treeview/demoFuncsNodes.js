//
// Copyright (c) 2006 by Conor O'Mahony.
// For enquiries, please email GubuSoft@GubuSoft.com.
// Please keep all copyright notices below.
// Original author of TreeView script is Marcelino Martins.
//
// This document includes the TreeView script.
// The TreeView script can be found at http://www.TreeView.net.
// The script is Copyright (c) 2006 by Conor O'Mahony.
//

// Decide if the names are links or just the icons
USETEXTLINKS = 1  //replace 0 with 1 for hyperlinks

// Decide if the tree is to start all open or just showing the root folders
STARTALLOPEN = 0 //replace 0 with 1 to show the whole tree

HIGHLIGHT = 1

foldersTree = gFld("<i>Flags and maps</i>", "demoFuncsRightFrame.html")
  foldersTree.treeID = "Funcs"
  aux1 = insFld(foldersTree, gFld("Flags", "javascript:parent.op()"))
      insDoc(aux1, gLnk("R", "Germany", "http://www.treeview.net/treemenu/demopics/beenthere_germany.gif"))
      insDoc(aux1, gLnk("R", "Greece", "http://www.treeview.net/treemenu/demopics/beenthere_greece.gif"))
      insDoc(aux1, gLnk("R", "Italy", "http://www.treeview.net/treemenu/demopics/beenthere_italy.gif"))
      insDoc(aux1, gLnk("R", "Portugal", "http://www.treeview.net/treemenu/demopics/beenthere_portugal.gif"))
      insDoc(aux1, gLnk("R", "United Kingdom", "http://www.treeview.net/treemenu/demopics/beenthere_unitedkingdom.gif"))
      insDoc(aux1, gLnk("R", "United States", "http://www.treeview.net/treemenu/demopics/beenthere_unitedstates.gif"))
  aux1 = insFld(foldersTree, gFld("Maps", "javascript:parent.op()"))
	  insDoc(aux1, gLnk("R", "North America", "http://www.treeview.net/treemenu/demopics/beenthere_america.gif"))
	  insDoc(aux1, gLnk("R", "Europe", "http://www.treeview.net/treemenu/demopics/beenthere_europe.gif"))

  // If your tree instead of the regular http links has "javascript:function(arg)"
  // links, and the type of the argument is string, special care is needed regarding
  // the quotes and double quotes. Please use exactly the same kind of 
  // quotes or double quotes used in this example (they change from folder to document).
  // Use the exact same number of backslashes for escaping the (double)quote 
  // characters, and pay attention not only to the (double)quotes surrouding the 
  // strings, but also to any (double)quote characters inside of that string

  // If you are going to use a frameless layout, you will need to move the functions 
  // exampleFunction and windowWithoutToolbar to the main page and change
  // parent.functionname to window.functionname in this file

  //Note the "S" target in the first argument of gLnk
  aux1 = insFld(foldersTree, gFld("<i>javascript:</i> links", "javascript:parent.op()"))
      //Use \" to delimit your string arguments and \\\" inside 
	  insDoc(aux1, gLnk("S", "Window w/o bars", "javascript:parent.windowWithoutToolbar(\\\'http://www.treeview.net/treemenu/demopics/beenthere_tuscany.gif\\\', 410, 415)"))
      //Use \\\' to delimit your string arguments and \\\\\\' inside
	  //Double quote characters (") are not allowed in the string argument
	  insDoc(aux1, gLnk("S", "A <i>js:</i> doc", "javascript:parent.exampleFunction(\\\'Special care with: &quot; and \\\\\\'\\\')"))
	  //Single quote characters (') are not allowed in the string argument but you can replace them with &#39;
	  aux2 = insFld(aux1, gFld("A <i>js:</i> folder", "javascript:parent.exampleFunction(\"Take special care with: \\\" and &#39;\")"))


