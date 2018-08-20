LookForNewer(CopySource,CopyDest)
{
    global
    copy_happen = n
	Loop, Files, %CopySource%\*, D
	{
		copy_it = n
		IfNotExist, %CopyDest%\%A_LoopFileName%  ; Always copy if target file doesn't yet exist.
		{
			copy_it = y
			copy_happen = y
		}
		else
		{
			FileGetTime, time, %CopyDest%\%A_LoopFileName%
			EnvSub, time, %A_LoopFileTimeModified%, seconds  ; Subtract the source file's time from the destination's.
			if time < 0  ; Source file is newer than destination file.
			{
				copy_it = y
				copy_happen = y
			}
        }
    }
Return
}

CopyTheFile()
{
    global
		if copy_it = y
		{
			TrayTip, Codebase copy ,Updating local PowerMill codebase with %A_LoopFileName%.
			FileCopyDir, %A_LoopFileFullPath%, %CopyDest%\%A_LoopFileName%, 1   ; Copy with overwrite=yes
			if ErrorLevel
			{
				MsgBox, Could not copy "%A_LoopFileFullPath%" to "%CopyDest%\%A_LoopFileName%".
			}
			FileSetTime, , %CopyDest%\%A_LoopFileName%, M, 2, 0
			;FileCreateDir, %CopyDest%\%A_LoopFileName%
		}
	If (%copy_happen% = n)
	{
		TrayTip, Codebase copy ,There were no codebases to copy.
	}
}