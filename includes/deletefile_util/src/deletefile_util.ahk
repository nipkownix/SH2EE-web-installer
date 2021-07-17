#NoTrayIcon
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

while FileExist(flName)
{
    Sleep, 1000
	FileDelete, %flName%
}

;********************************************************************************