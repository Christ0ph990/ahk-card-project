#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

file := FileOpen("TrunkFilter.JSON", "w")
file.Writeline("{")
file.Writeline("    ""name"":""Trunk Codebase Available"",")
file.Writeline("    ""jql"":""type = sub-task AND ()"",")
file.Writeline("}")
file.close()
ExitApp

+Esc::
ExitApp