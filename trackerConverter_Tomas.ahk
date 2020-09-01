#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

;TODO reset vars for new file

inputFolder := "C:\trackerConverterInput"
game := {}


\::
    Loop Files, %inputFolder%\*.txt
    {
        fileDir = %inputFolder%\%A_LoopFileName%
        inputString := input(fileDir)

        splitTextIntoObjects(inputString)
    }
return

input(fileDir){
    FileRead, inputString, %fileDir%
    return inputString
}

splitTextIntoObjects(inputString){
    global game

    newStringTtemp := StrSplit(inputString, "`n`r`n`r`n")
    
    for i, element in newStringTtemp{
        gameObject := {}
        gameObject.fullString := element
        game.Push(gameObject)
    }
}

