﻿#NoTrayIcon
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
SetWorkingDir %A_ScriptDir%

;********************************************************************************

flName = %1%

shouldRun = %2%

shouldUpdate = %3%

SplitPath, flName,, dir

newSetupExe := dir . "\SH2EEsetup_new.exe"
destSetupExe := dir . "\SH2EEsetup.exe"

if FileExist(newSetupExe)
{
	while FileExist(flName)
	{
		Sleep, 1000
		FileDelete, %flName%
	}
	FileMove, %newSetupExe%, %destSetupExe%
	
	if shouldRun = true
	{
		if shouldUpdate = true
			Run, "%destSetupExe%" -update,,UseErrorLevel
		else
			Run, "%destSetupExe%",,UseErrorLevel
	}
}

Run, %ComSpec% /c del "%A_ScriptFullPath%", , Hide
ExitApp

;********************************************************************************