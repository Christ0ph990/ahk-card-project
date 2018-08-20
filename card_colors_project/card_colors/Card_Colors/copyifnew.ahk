#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
#Persistent
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;############################################################################################
;                  ################## Functions ################
#Include %A_ScriptDir%\Functions.ahk

;############################################################################################

;############################################################################################
;                  ################## AUTOEXECUTE ################

RemoteSource = %A_ScriptDir%\data\remote																; Change this to \\bullring for real deal
LocalDestination = %A_ScriptDir%\data\local																; Change this to my local build area

RunOnStartup:
TrayTip, Codebase copy startup , Checking %RemoteSource% for new builds.

Get_tbt_versions()

curl_networkfile("Trunk")
curl_networkfile("Branch")
curl_networkfile("Twig")

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
Sleep, % target * 1000																					; (milliseconds)
TrayTip, Codebase copy , Checking %RemoteSource% for new builds.
CopyIfNewer(RemoteSource,LocalDestination)

Gosub, Timer
return

CheckTrunk:
trunk_LoopObj := Object()
Loop, Read, %A_ScriptDir%\data\networkfile.txt
{
   IfInString, A_LoopReadLine, NT:pm
   {
		SplitArray1 := StrSplit(A_LoopReadLine, "`:")
		SplitArray2 := StrSplit(SplitArray1[2],"`-", " `t")
		;StringSplit, FirstSplit, A_LoopReadLine, `:
		;StringSplit, SecondSplit, FirstSplit2, `-, " `t"
		trunk_LoopObj.Insert(SplitArray2[1])
   }
}
SplitArray1 := ""
SplitArray2 := ""

Loop % trunk_LoopObj.length()
{
    If(trunk_LoopObj[A_Index] = codebase_name)
    {
        MsgBox % codebase_name . " should be the same as " . trunk_LoopObj[A_Index]
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
