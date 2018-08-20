;########################################################################################################################
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
			codebase_name := RemoteDateOrdName_Obj[A_Index]
			Gosub, CheckTrunk
			;Gosub, CheckBranch
			;GoSub, CheckTwig
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
	curlString := "curl file:////bullring/devbase/devdisk/dmk/configs/" . %configString% . "/files/closed.html -o """ . A_ScriptDir . "/data/" . tbt_version "network_file.txt"""
	RunWait % "PowerShell.exe -noexit -Command ""& {" . curlString . "}""", ,
	return
}
;########################################################################################################################
;########################################################################################################################