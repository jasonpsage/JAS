{=============================================================================
|    _________ _______  _______  ______  _______             Get out of the  |
|   /___  ___// _____/ / _____/ / __  / / _____/               Mainstream... |
|      / /   / /__    / / ___  / /_/ / / /____                Jump into the  |
|     / /   / ____/  / / /  / / __  / /____  /                   Jetstream   |
|____/ /   / /___   / /__/ / / / / / _____/ /                                |
/_____/   /______/ /______/ /_/ /_/ /______/                                 |
|         Virtually Everything IT(tm)                         info@jegas.com |
==============================================================================
                       Copyright(c)2016 Jegas, LLC
=============================================================================}

//=============================================================================
// HardCoded Path/Filename Settings for IPC_????_FILE units
//=============================================================================
// Note: Filename format for fifo is: YYYYMMDDHHnnSS
{$MACRO ON}
{$IFDEF Windows}
  {$DEFINE PATH_IPC_IN:='.\data\fifo\in\'}
  {$DEFINE PATH_IPC_OUT:='.\data\fifo\out\'}
{$ELSE}
  {$DEFINE PATH_IPC_IN:='./data/fifo/in/'}
  {$DEFINE PATH_IPC_OUT:='./data/fifo/out/'}
{$ENDIF}
//=============================================================================
{ }
{ This include is used by the file based inter-process commuication units.
The values in the paths above are compiled (hardcoded) into the executables
as it stands. Naturally this can be made configuarable in any application
you like that uses it. }
