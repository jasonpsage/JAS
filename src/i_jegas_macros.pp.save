{==============================================================================
|    _________ _______  _______  ______  _______  Jegas, LLC                  |
|   /___  ___// _____/ / _____/ / __  / / _____/  JasonPSage@jegas.com        |
|      / /   / /__    / / ___  / /_/ / / /____                                |
|     / /   / ____/  / / /  / / __  / /____  /                                |
|____/ /   / /___   / /__/ / / / / / _____/ /                                 |
/_____/   /______/ /______/ /_/ /_/ /______/                                  |
|                 Under the Hood                                              |
===============================================================================
                       Copyright(c)2012 Jegas, LLC
==============================================================================}

{$MACRO ON}
//=============================================================================
// Filename: i_Jegas_Macros.pp}
// Author  : Jason Sage}
// Created : 2006-03-19}
// Purpose : Jegas API - FreePascal Implementation}
//           Global Macros and Global Compiler Directives}
//=============================================================================

//=============================================================================
// Global Compiler Directives
//=============================================================================
// ROUTINENAMES Must be used in conjunction with
// DEBUGLOGBEGINEND,DEBUGTHREADBEGINEND,TRACKTHREAD
// But you can optionally use any one or all three
// of them - they just need ROUTINENAMES defined.
{DEFINE ROUTINENAMES}
{DEFINE TRACKTHREAD}
{DEFINE DEBUGLOGBEGINEND}  // use for debugging only
{DEFINE DEBUGTHREADBEGINEND}
//=============================================================================

//=============================================================================
// MACROS to ALLOW ENDIAN SCALABLE INTEGER and USIGNED INTEGER DATATYPES
//=============================================================================
{$IFDEF CPU32}
  {$DEFINE UINT:=CARDINAL}
  {$DEFINE INT:=LONGINT}
{$ELSE}
  {$DEFINE UINT:=UInt64}
  {$DEFINE INT:=Int64}
{$ENDIF}
//=============================================================================




//=============================================================================
// Include ODBC Support
//=============================================================================
{$DEFINE ODBC}
//=============================================================================



//=============================================================================
// Macros for making declarations of libraries (DLL or Shared Libs) easier
// Note - Your program has to define mac_libname 
//=============================================================================
// Going With STDCALL On all platforms as I don't care if other languages call
// this and stdcall is faster.
{$IFDEF Win32}
  {$DEFINE MAC_EXPORT:=stdcall;export}
  {$DEFINE MAC_IMPORT:=stdcall;external mac_libname}
{$ELSE}
  {DEFINE MAC_EXPORT:=cdecl;exports}
  {DEFINE MAC_IMPORT:=cdecl;external mac_libname}
{$ENDIF}
//=============================================================================



//=============================================================================
// Internationalization Define - LANGUAGES_TO_INCLUDE
// This define defaults to ALL which means IF there is hardcoded text in the 
// source code for multiple languages they ALL will be included. If this is
// set to "en" (english) then only English will be compiled in. when more 
// languages are added, you must write the code to honor this define or it 
// loses it's value. You can include all or an individual language.
// Language ordinals are defined in uxxg_common.pp. See see declarations 
// like: cnLANG_ENGLISH and cnLANG_ALL to see where these values are defined
// and what they are.
//
// LANGUAGES_TO_INCLUDE Values:
// 0 (Zero) = All languages coded for will be compiled into the final EXE
// 1 = Only ENGLISH language will be compiled into the final EXE
{$DEFINE LANGUAGES_TO_INCLUDE:='0'}
//=============================================================================


//*****************************************************************************
// eof
//*****************************************************************************
