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
//!  To rip out all comments (LGPL or otherwise):
//!            ^\t*//(.*|$)
//!  To rip out only logging statements (commented or uncommented):
//!            ^/{0,2}iwfLog.*
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
//! iwfconfig.js
//
// Variables a developer using IWF may wish to change to customize IWF for their app
//
//! Dependencies:
//! (none)
//
//! Brock Weaver - brockweaver@users.sourceforge.net
//! v 0.2 - 2005-11-14
//! core bug patch
// --------------------------------------------------------------------------
//! v 0.1 - 2005-06-17
//! Initial release.
// --------------------------------------------------------------------------

// -----------------------------------
// Begin: Configurable variables, IWF-wide
// -----------------------------------

// All variables are shown with their default code!

//! -- iwfcore.js
//! set to true to enable logging.  Logging simply means certain values are appended to a string. nothing is written out or communicated over the wire anywhere.
_iwfLoggingEnabled = true;
_iwfDebugging = false;

//! -- iwfgui.js
//! (none)

//! -- iwfxml.js
//! (none)

//! -- iwfajax.js
//! if this is hardcoded to true, iwfgui.js *must* be included in all pages that reference iwfajax.js as well.
//! if false, the "busy bar" is not shown, and in its place the window.status is updated.
_iwfShowGuiProgress = iwfExists(window.iwfShow); // && false;


// -----------------------------------
// End: Configurable variables, IWF-wide
// -----------------------------------

// -----------------------------------
// Begin: Initializers
// -----------------------------------
//if (window.iwfMapRollovers){
//	iwfMapRollovers();
//}

//if (window.iwfMapDropTargets){
//	iwfMapDropTargets(document);
//}

if (window.iwfMapWindows){
	iwfMapWindows(document.body);
}

if (window.iwfMapDraggables){
	iwfMapDraggables(document.body);
}
// -----------------------------------
// End: Initializers
// -----------------------------------
