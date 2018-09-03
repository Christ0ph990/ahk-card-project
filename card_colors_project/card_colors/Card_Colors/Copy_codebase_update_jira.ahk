

;############################################################################################
;                  ################## Preamble ################
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
#Persistent
SendMode Input 
SetWorkingDir %A_ScriptDir%
SetFormat, float, 0.2
#Include %A_ScriptDir%\Functions.ahk
;FileRemoveDir, %A_ScriptDir%\data\, 1
FileCreateDir, %A_ScriptDir%\data\
FileCreateDir, %A_ScriptDir%\data\configs\
FileCreateDir, %A_ScriptDir%\data\network_responses\
FileCreateDir, %A_ScriptDir%\data\network_requests\
;FileRemoveDir, %A_ScriptDir%\assets\, 1
FileCreateDir, %A_ScriptDir%\assets\
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\curl.exe, %A_ScriptDir%\curl.exe,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\jq-win64.exe, %A_ScriptDir%\jq-win64.exe,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\assets\busy.ico, %A_ScriptDir%\assets\busy.ico,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\assets\copying.ico, %A_ScriptDir%\assets\copying.ico,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\assets\inactive.ico, %A_ScriptDir%\assets\inactive.ico,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\assets\jira.ico, %A_ScriptDir%\assets\jira.ico,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\data\cacert.pem, %A_ScriptDir%\data\cacert.pem,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\data\curl-ca-bundle.crt, %A_ScriptDir%\data\curl-ca-bundle.crt,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\data\configs\Trunk_search_config.txt, %A_ScriptDir%\data\configs\Trunk_search_config.txt,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\data\configs\Branch_search_config.txt, %A_ScriptDir%\data\configs\Branch_search_config.txt,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\data\configs\Twig_search_config.txt, %A_ScriptDir%\data\configs\Twig_search_config.txt,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\data\configs\TrunkConfig.txt, %A_ScriptDir%\data\configs\TrunkConfig.txt,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\data\configs\BranchConfig.txt, %A_ScriptDir%\data\configs\BranchConfig.txt,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\data\configs\TwigConfig.txt, %A_ScriptDir%\data\configs\TwigConfig.txt,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\data\configs\Trunk_search_config.json, %A_ScriptDir%\data\configs\Trunk_search_config.json,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\data\configs\Branch_search_config.json, %A_ScriptDir%\data\configs\Branch_search_config.json,1
FileInstall, D:\Github\card_colors_project\card_colors\Card_Colors\data\configs\Twig_search_config.json, %A_ScriptDir%\data\configs\Twig_search_config.json,1

;############################################################################################

;############################################################################################
;                  ################## Run on startup ################
RemoteSource = \\bullring\dmkbase\dcam
Menu, Tray, Icon, %A_ScriptDir%\assets\inactive.ico, 1
Menu,Tray, Tip, Local Codebase: Sleeping

InputBox, LocalDestination, Local codebase directory, Enter the directory of the local codebase repository., , , 130, , , , , D:\PowerMill_Builds
If (ErrorLevel = 1) or (ErrorLevel = 2)
{
    ExitApp
}
TrayTip, Codebase copy startup , Checking %RemoteSource% for new builds.
HideTrayTip()

Menu, Tray, Icon, %A_ScriptDir%\assets\busy.ico, 1
Menu,Tray, Tip, Local Codebase: Busy

Get_tbt_versions()
curl_networkfile("Trunk")
curl_networkfile("Branch")
curl_networkfile("Twig")
CopyIfNewer(RemoteSource,LocalDestination)

SetTimer, Timer, -500
return
;############################################################################################

;############################################################################################
TIMER:
target := A_Now
EnvAdd, target, 1, h
if (target < A_Now) 																					; time(today) has passed already, so use time(tomorrow)
{   
    EnvAdd, target, 1, d
}
; Calculate how many seconds until the target time is reached.
EnvSub, target, %A_Now%, Seconds
humantime := (target / 60)
humantime .= Format
TrayTip, Codebase copy , Check complete`, next check in %humantime% minutes.
Menu, Tray, Icon, %A_ScriptDir%\assets\inactive.ico, 1
Menu, Tray, Tip, Local Codebase: Check complete`, next check in %humantime% minutes. 
; Sleep until the target is reached.
;Sleep, % target * 1000	
Loop
{
humantime -= 1    
Menu, Tray, Tip, Local Codebase: Check complete`, next check in %humantime% minutes.
Sleep, 60000
} until (humantime = 0 )

TrayTip, Codebase copy , Checking %RemoteSource% for new builds.
Menu, Tray, Icon, %A_ScriptDir%\assets\busy.ico, 1

Get_tbt_versions()
curl_networkfile("Trunk")
curl_networkfile("Branch")
curl_networkfile("Twig")
CopyIfNewer(RemoteSource,LocalDestination)

Gosub, Timer
return
;############################################################################################

;############################################################################################
Check_tbt:
update_Trunk := ""
update_Branch := ""
update_Twig := ""

Menu,Tray, Tip, Local Codebase: Checking if new build is in Trunk.
folder_match_tbt("Trunk")
If(is_in_Trunk = True)
{
    update_Trunk := True
}

Menu,Tray, Tip, Local Codebase: Checking if new build is in Branch.
folder_match_tbt("Branch")
If(is_in_Branch = True)
{
    update_Branch := True
}

Menu, Tray, Tip, Local Codebase: Checking if new build is in Twig.
folder_match_tbt("Twig")
If(is_in_Twig = True)
{
    update_Twig := True
}
return
;############################################################################################

;############################################################################################
Curl_issues_from_jira:

Menu, Tray, Icon, %A_ScriptDir%\assets\jira.ico, 1	
If(update_Trunk = True)
	{
        Menu,Tray, Tip, Local Codebase: Getting sub-tasks with comments for Trunk.
        Get_jira_issues("Trunk")
    }
If(update_Branch = True)
	{
        Menu,Tray, Tip, Local Codebase: Getting sub-tasks with comments for Branch.
        Get_jira_issues("Branch")
    }
If(update_Twig = True)
    {
        Menu,Tray, Tip, Local Codebase: Getting sub-tasks with comments for Twig.
        Get_jira_issues("Twig")
    }
return
;############################################################################################

;############################################################################################
Extract_issue_keys_from_filter:
arg1 := ""
arg2 := """key"":"
arg3 := """"
arg4 := 4
arg5 := ""
Menu, Tray, Icon, %A_ScriptDir%\assets\busy.ico, 1
If(update_Trunk = True)
{
    Menu,Tray, Tip, Local Codebase: Extracting identified issue keys from Trunk filter.
    arg1 := A_ScriptDir . "\data\network_responses\Trunk_search_parsed_output.json"
    arg5 := "Trunk"
    Loop_file_extract_data_to_array(arg1, arg2, arg3, arg4, arg5)
}
If(update_Branch = True)
{
    Menu,Tray, Tip, Local Codebase: Extracting identified issue keys from Branch filter.
    arg1 := A_ScriptDir . "\data\network_responses\Branch_search_parsed_output.json"
    arg5 := "Branch"
    Loop_file_extract_data_to_array(arg1, arg2, arg3, arg4, arg5)
}
If(update_Twig = True)
{
    Menu,Tray, Tip, Local Codebase: Extracting identified issue keys from Twig filter.
    arg1 := A_ScriptDir . "\data\network_responses\Twig_search_parsed_output.json"
    arg5 := "Twig"
    Loop_file_extract_data_to_array(arg1, arg2, arg3, arg4, arg5)
}
return
;############################################################################################

;############################################################################################
Curl_to_jira:
Menu, Tray, Icon, %A_ScriptDir%\assets\jira.ico, 1
If(update_Trunk = True)
{
    Menu,Tray, Tip, Local Codebase: Posting trunk.cb.ready property to sub-tasks.
    curl_jirajson("Trunk")
}
If(update_Branch = True)
{
    Menu,Tray, Tip, Local Codebase: Posting branch.cb.ready property to sub-tasks.
    curl_jirajson("Branch")
}
If(update_Twig = True)
{
    Menu,Tray, Tip, Local Codebase: Posting twig.cb.ready property to sub-tasks.
    curl_jirajson("Twig")
}
return
;############################################################################################

+Esc::
ExitApp
