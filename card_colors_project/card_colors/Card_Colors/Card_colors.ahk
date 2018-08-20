#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
LoopObj := Object()
Loop, Read, C:\Users\Chris\Desktop\ahk script\Card_Colors\data\networkfile.txt
{
   IfInString, A_LoopReadLine, NT:pm
   {
      StringSplit, FirstSplit, A_LoopReadLine, `:
      StringSplit, SecondSplit, FirstSplit2, `-
      LoopObj.Insert(SecondSplit1)
   }
}
var = 
Loop % LoopObj.length()
{
namevar .= LoopObj[A_Index] "`r`n"
}
MsgBox % namevar





































































