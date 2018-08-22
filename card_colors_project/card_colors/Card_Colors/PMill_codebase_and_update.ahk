#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
#Persistent
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;############################################################################################
;                  ################## Functions ################
#Include %A_ScriptDir%\Functions.ahk
SetFormat, float, 0.2
;############################################################################################

;############################################################################################
;                  ################## AUTOEXECUTE ################
Menu, Tray, Icon, %A_ScriptDir%\assets\inactive.ico, 1
RemoteSource = \\bullring\dmkbase\dcam																; Change this to \\bullring for real deal
LocalDestination = D:\PowerMill_Builds																; Change this to my local build area

RunOnStartup:
TrayTip, Codebase copy startup , Checking %RemoteSource% for new builds.
Menu, Tray, Icon, %A_ScriptDir%\assets\busy.ico, 1
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
humantime := (target / 60)
humantime .= Format
TrayTip, Codebase copy , Check complete`, next check in %humantime% minutes.
Menu, Tray, Icon, %A_ScriptDir%\assets\inactive.ico, 1
Sleep, % target * 1000																					; (milliseconds)
TrayTip, Codebase copy , Checking %RemoteSource% for new builds.

Menu, Tray, Icon, %A_ScriptDir%\assets\busy.ico, 1
Get_tbt_versions()

curl_networkfile("Trunk")
curl_networkfile("Branch")
curl_networkfile("Twig")
CopyIfNewer(RemoteSource,LocalDestination)

Gosub, Timer
return

Check_tbt:
update_Trunk := ""
update_Branch := ""
update_Twig := ""

folder_match_tbt("Trunk")
If(is_in_Trunk = True)
{
    update_Trunk := True
}

folder_match_tbt("Branch")
If(is_in_Branch = True)
{
    update_Branch := True
}

folder_match_tbt("Twig")
If(is_in_Twig = True)
{
    update_Twig := True
}
return

Update_json:
UpdateJsonFiles()
return

Curl_to_jira:
If(update_trunk_json = true)
{
    curl_jirajson("Trunk")
}
If(update_branch_json = true)
{
    curl_jirajson("Branch")
}
If(update_twig_json = true)
{
    curl_jirajson("Twig")
}
return

+Esc::
ExitApp