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
        splitFullStringIntoLinesAndPutIntoArray()
    }
return

input(fileDir){
    FileRead, inputString, %fileDir%
    return inputString
}

splitTextIntoObjects(inputString){
    global game

    gamesFullStringsArray := StrSplit(inputString, "`n`r`n`r`n")
    
    for i, element in gamesFullStringsArray{
        gameObject := {}
        gameObject.fullString := element
        game.Push(gameObject)
    }
}

splitFullStringIntoLinesAndPutIntoArray(){
    global game
    for i, element in game{
        line := StrSplit(element.fullString, "`n")
        element.line := line
    }
}

