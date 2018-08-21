;########################################################################################################################
UpdateJsonFiles()
{
	global
	tbt_filepath := ""
	update_trunk_json := ""
	update_branch_json := ""
	update_twig_json := ""
	If(update_Trunk = True)
	{
		tbt_filepath := A_ScriptDir . "\data\TrunkFilter.json"
		file := FileOpen(tbt_filepath, "w `n")
		file.Writeline("{")
		file.Writeline(A_Tab . """name"":"" Trunk Codebase Available"",")
		file.Write(A_Tab . """jql"":""type = sub-task AND (")
		
		loop % LoopObj_Trunk.length()
		{
			file.Write("text ~ " . LoopObj_Trunk[A_Index] . " OR ")
			
			If(A_Index = 70)
			{
				file.Writeline("text ~ " . LoopObj_Trunk[A_Index] . ")""")
				break
			}
		}
		
		file.Writeline("}")
		file.close()
		update_trunk_json := true
		tbt_filepath := ""
		
	}
	
	If(update_Branch = True)
	{
		tbt_filepath := A_ScriptDir . "\data\BranchFilter.json"
		file := FileOpen(tbt_filepath, "w `n")
		file.Writeline("{")
		file.Writeline(A_Tab . """name"":"" Branch Codebase Available"",")
		file.Write(A_Tab . """jql"":""type = sub-task AND (")
		
		loop % LoopObj_Branch.length()
		{
			file.Write("text ~ " . LoopObj_Branch[A_Index] . " OR ")
			
			If(A_Index = 70)
			{
				file.Writeline("text ~ " . LoopObj_Branch[A_Index] . ")""")
				break
			}
		}
		
		file.Writeline("}")
		file.close()
		update_branch_json := true
		tbt_filepath := ""
	}
	
	If(update_Twig = True)
	{
		tbt_filepath := A_ScriptDir . "\data\TwigFilter.json"
		file := FileOpen(tbt_filepath, "w `n")
		file.Writeline("{")
		file.Writeline(A_Tab . """name"":"" Twig Codebase Available"",")
		file.Write(A_Tab . """jql"":""type = sub-task AND (")
		
		loop % LoopObj_Twig.length()
		{
			file.Write("text ~ " . LoopObj_Twig[A_Index] . " OR ")
			If(A_Index = 70)
			{
				file.Writeline("text ~ " . LoopObj_Twig[A_Index] . ")""")
				break
			}
		}
		
		file.Writeline("}")
		file.close()
		update_twig_json := true
		tbt_filepath := ""
	}
	Return
}
;########################################################################################################################
;########################################################################################################################
CopyIfNewer(RemoteDir,LocalDir)
{
	global
	copy_happen := ""
    codebase_name := ""
	RemoteFolderNames := ""
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
			EnvSub, time, % RemoteDateOrdTime_Obj[A_Index], seconds  													; Subtract the source file's time from the destination's.
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
			Menu, Tray, Icon, %A_ScriptDir%\assets\copying.ico, 1
			codebase_name := RemoteDateOrdName_Obj[A_Index]
			Gosub, Check_tbt
			
			TrayTip, Codebase copy, % "Updating local PowerMill codebase with " . RemoteDateOrdName_Obj[A_Index] . "."
			RemotePath := RemoteDir . "\" . RemoteDateOrdName_Obj[A_Index]
			LocalPath := LocalDir . "\" . RemoteDateOrdName_Obj[A_Index]
			FileCopyDir, %RemotePath%, %LocalPath%, 1   																; Copy with overwrite=yes
			if ErrorLevel
			{
				MsgBox, Could not copy "%RemotePath%" to "%LocalPath%".
				ExitApp
			}
			FileSetTime,, %LocalPath%, M, 2, 0
			Menu, Tray, Icon, %A_ScriptDir%\assets\busy.ico, 1
			;FileCreateDir, %LocalDir%\%A_LoopFileName%																	; Uncomment this line to initialise the local area with empty folders.
			Gosub, Update_json
			Gosub, Curl_to_jira
		}
	}
    codebase_name := ""
	If (copy_happen = False)
	{
		TrayTip, Codebase copy ,There were no codebases to copy.
	}
	Return
}

;########################################################################################################################
;########################################################################################################################
Get_tbt_versions()
{
	global
	tbt_FolderNames := ""
	tbt_FolderArray := ""
	tbt_FolderNameObj := Object()
	tbt_FolderTimeObj := Object()
	
	Loop, Files, \\bullring\devbase\devdisk\dmk\configs\*, D
	{
		tbt_FolderNames := tbt_FolderNames . A_LoopFileTimeModified . "`t" . A_LoopFileName . "`n"
	}
	
	Sort, tbt_FolderNames, R
	
	Loop, Parse, tbt_FolderNames, `n
	{
		if (A_LoopField = "")
		{
			continue 																									; Omit the last linefeed (blank item) at the end of the list.
		}
		tbt_FolderArray := StrSplit(A_LoopField, A_Tab, " `t")
		tbt_FolderNameObj.Insert(tbt_FolderArray[2])
		tbt_FolderTimeObj.Insert(tbt_FolderArray[1])
	}
	tbt_FolderNames := ""
	tbt_FolderArray := ""	
	
	Loop, 5
	{
		If (tbt_FolderNameObj[A_Index] = "pmint")
		{
			tbt_TrunkCode := tbt_FolderNameObj[A_Index]																	; tbt_TrunkCode should be used as a variable in the curl URL to get the html file
			continue
		}
		If (InStr(tbt_FolderNameObj[A_Index], "T", True))
		{
			continue
		}
		If (InStr(tbt_FolderNameObj[A_Index], "B", True))
		{
			continue
		}
		If (InStr(tbt_FolderNameObj[A_Index], "pm20"))
		{
			tbt_TwigCode := tbt_FolderNameObj[A_Index]																	; tbt_TwigCode should be used as a variable in the curl URL to get the html file
			continue
		}
		else{
			tbt_BranchCode := tbt_FolderNameObj[A_Index]																; tbt_BranchCode should be used as a variable in the curl URL to get the html file
		}
	}
	return
}
;########################################################################################################################
;########################################################################################################################

curl_networkfile(tbt_version)
{
	global
	configString := "tbt_" . tbt_version . "Code"
	curlString := "curl file:////bullring/devbase/devdisk/dmk/configs/" . %configString% . "/files/closed.html -o """ . A_ScriptDir . "/data/network_responses/" . tbt_version "_networkfile.txt"""
	RunWait % "PowerShell.exe -Command ""& {" . curlString . "}""", , Hide
	tbt_version := ""
	return
}
;########################################################################################################################
;########################################################################################################################

curl_jirajson(tbt_version)
{
	global
	Menu, Tray, Icon, %A_ScriptDir%\assets\jira.ico, 1
	RunWait, % comspec . A_Space . "/c" . A_Space . A_ScriptDir . "\curl.exe -K" . A_Space . """" . A_ScriptDir . "\data\configs\" . tbt_version . "Config.txt"" |" . A_Space . A_ScriptDir . "\jq-win64.exe . >" . A_ScriptDir . "\data\network_responses\" . tbt_version . "_parsed_output.txt", ,hide
	tbt_version := ""
	return
}
;########################################################################################################################
;########################################################################################################################

folder_match_tbt(tbt_version)
{
	global
	current_obj_name := "LoopObj_" . tbt_version
	%current_obj_name% := Object()
	Loop, Read, % A_ScriptDir . "\data\network_responses\" . tbt_version . "_networkfile.txt"
	{
		IfInString, A_LoopReadLine, NT:pm
		{
				SplitArray1 := StrSplit(A_LoopReadLine, "`:")
				SplitArray2 := StrSplit(SplitArray1[2],"`-", " `t")
				%current_obj_name%.Insert(SplitArray2[1])
		}
	}
	SplitArray1 := ""
	SplitArray2 := ""
    Loop % %current_obj_name%.length()
    {
        If(%current_obj_name%[A_Index] = codebase_name)
        {
            is_in_%tbt_version% := True 
        }
    }
	tbt_version := ""
	current_obj_name :=
	return
}

;########################################################################################################################
;########################################################################################################################