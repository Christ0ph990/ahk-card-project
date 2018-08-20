#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
#Persistent
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;############################################################################################
;                  ################## AUTOEXECUTE ################
CopyIfNewer(CopySource,CopyDest)
{
    global
	copy_happen := False
    codebase_name := ""
	Loop, Files, %CopySource%\*, D
	{
		file_exist := false
		copy_it := False
        codebase_name := ""
		file_exist := FileExist(CopyDest . "\" . A_LoopFileName)
		;IfNotExist CopyDest"\"A_LoopFileName  ; Always copy if target file doesn't yet exist.
		;{
		;	copy_it := True
		;	copy_happen := True
		;}
		if (FileExist(CopyDest . "\" . A_LoopFileName))
		{
			FileGetTime, time, %CopyDest%\%A_LoopFileName%
			EnvSub, time, %A_LoopFileTimeModified%, seconds  ; Subtract the source file's time from the destination's.
			if time < 0  ; Source file is newer than destination file.
			{
				copy_it := True
				copy_happen := True
			}
		}
		else
		{
			file_exist := false
		}
		
		if (copy_it = True) OR (file_exist = false)
		{
            codebase_name := A_LoopFileName
            Gosub, CheckTrunk
            ;Gosub, CheckBranch
            ;GoSub, CheckTwig
			TrayTip, Codebase copy ,Updating local PowerMill codebase with %A_LoopFileName%.
			FileCopyDir, %A_LoopFileFullPath%, %CopyDest%\%A_LoopFileName%, 1   ; Copy with overwrite=yes
			if ErrorLevel
			{
				MsgBox, Could not copy "%A_LoopFileFullPath%" to "%CopyDest%\%A_LoopFileName%".
			}
			FileSetTime, , %CopyDest%\%A_LoopFileName%, M, 2, 0
			;FileCreateDir, %CopyDest%\%A_LoopFileName%
		}
	}
    codebase_name := ""
	If (copy_happen = False)
	{
		TrayTip, Codebase copy ,There were no codebases to copy.
	}
Return
}
Source = C:\Users\Chris\Desktop\ahk script\Card_Colors\data\remote
Destination = C:\Users\Chris\Desktop\ahk script\Card_Colors\data\local

RunOnStartup:
TrayTip, Codebase copy startup , Checking %Source% for new builds.
CopyIfNewer(Source,Destination)
SetTimer, Timer, -500
return
;############################################################################################

TIMER:
target := A_Now
EnvAdd, target, 1, h
if (target < A_Now)
{   ; time(today) has passed already, so use time(tomorrow)
    EnvAdd, target, 1, d
}
; Calculate how many seconds until the target time is reached.
EnvSub, target, %A_Now%, Seconds
; Sleep until the target is reached.
Sleep, % target * 1000 ; (milliseconds)
TrayTip, Codebase copy , Checking %Source% for new builds.
CopyIfNewer(Source,Destination)

Gosub, Timer
return

CheckTrunk:
LoopObj := Object()
Loop, Read, C:\Users\Chris\Desktop\ahk script\Card_Colors\data\networkfile.txt
{
   IfInString, A_LoopReadLine, NT:pm
   {
      StringSplit, FirstSplit, A_LoopReadLine, `:
      StringSplit, SecondSplit, FirstSplit2, `-, " `t"
      LoopObj.Insert(SecondSplit1)
   }
}
Loop % LoopObj.length()
{
    If(LoopObj[A_Index] = codebase_name)
    {
        MsgBox % codebase_name . " should be the same as " . LoopObj[A_Index]
    }
}
return

;CheckBranch:
;return
;
;CheckTwig:
;return

+Esc::
ExitApp
