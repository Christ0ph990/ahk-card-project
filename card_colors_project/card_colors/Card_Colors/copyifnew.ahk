#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
#Persistent
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;############################################################################################
;                  ################## AUTOEXECUTE ################
CopyIfNewer(RemoteDir,LocalDir)
{
	global
	copy_happen := False
    codebase_name := ""
	RemoteFolderNames :=
	RemoteDateOrdName_Obj := Object()
	RemoteDateOrdTime_Obj := Object()
	
	Loop, Files, %RemoteDir%\*, D
	{
		RemoteFolderNames := RemoteFolderNames . A_LoopFileTimeModified . "`t" . A_LoopFileName . "`n"
	}
	
	Sort, RemoteFolderNames, R
	
	Loop, Parse, RemoteFolderNames, `n
	{
		if (A_LoopField = "")
		{
			continue 																									; Omit the last linefeed (blank item) at the end of the list.
		}
		RemoteFolderArray := StrSplit(A_LoopField, A_Tab, " `t")
		RemoteDateOrdName_Obj.Insert(RemoteFolderArray[2])
		RemoteDateOrdTime_Obj.Insert(RemoteFolderArray[1])
	}
	RemoteFolderNames := ""
	RemoteFolderArray := ""
	
	Loop % RemoteDateOrdName_Obj.length()
	{
		file_exist := false
		copy_it := False
		codebase_name := ""
		file_exist := FileExist(LocalDir . "\" . RemoteDateOrdName_Obj[A_Index])
		if (FileExist(LocalDir . "\" . RemoteDateOrdName_Obj[A_Index]))
		{
			FileGetTime, time, % LocalDir . "\" . RemoteDateOrdName_Obj[A_Index]
			EnvSub, time, % RemoteDateOrdTime_Obj[A_Index], seconds  															; Subtract the source file's time from the destination's.
			if time < 0 																								; Source file is newer than destination file.
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
			codebase_name := RemoteDateOrdName_Obj[A_Index]
			Gosub, CheckTrunk
			;Gosub, CheckBranch
			;GoSub, CheckTwig
			TrayTip, Codebase copy, % "Updating local PowerMill codebase with " . RemoteDateOrdName_Obj[A_Index] . "."
			RemotePath := RemoteDir . "\" . RemoteDateOrdName_Obj[A_Index]
			LocalPath := LocalDir . "\" . RemoteDateOrdName_Obj[A_Index]
			FileCopyDir, %RemotePath%, %LocalPath%, 1   										; Copy with overwrite=yes
			if ErrorLevel
			{
				MsgBox, Could not copy "%RemotePath%" to "%LocalPath%".
				ExitApp
			}
			FileSetTime,, %LocalPath%, M, 2, 0
			;FileCreateDir, %LocalDir%\%A_LoopFileName%																	; Uncomment this line to initialise the local area with empty folders.
		}
	}
    codebase_name := ""
	If (copy_happen = False)
	{
		TrayTip, Codebase copy ,There were no codebases to copy.
	}
Return
}
RemoteSource = %A_ScriptDir%\data\remote
LocalDestination = %A_ScriptDir%\data\local

RunOnStartup:
TrayTip, Codebase copy startup , Checking %RemoteSource% for new builds.
CopyIfNewer(RemoteSource,LocalDestination)
SetTimer, Timer, -500
return
;############################################################################################

TIMER:
target := A_Now
EnvAdd, target, 1, h
if (target < A_Now) 																					; time(today) has passed already, so use time(tomorrow)
{   
    EnvAdd, target, 1, d
} 																										; Calculate how many seconds until the target time is reached.
EnvSub, target, %A_Now%, Seconds 																		; Sleep until the target is reached.
Sleep, % target * 1000 ; (milliseconds)
TrayTip, Codebase copy , Checking %RemoteSource% for new builds.
CopyIfNewer(RemoteSource,LocalDestination)

Gosub, Timer
return

CheckTrunk:
LoopObj := Object()
Loop, Read, %A_ScriptDir%\data\networkfile.txt
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
