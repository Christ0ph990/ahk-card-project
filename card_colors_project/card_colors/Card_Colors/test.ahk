﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

tbt_version := "Trunk"
	RunWait, % comspec . A_Space . "/k" . A_Space . A_ScriptDir . "\curl.exe -K" . A_Space . """" . A_ScriptDir . "\data\configs\" . tbt_version . "Config.txt""", ,