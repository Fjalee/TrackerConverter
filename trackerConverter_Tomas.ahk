#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

;TODO reset vars for new file

inputFolder := "C:\trackerConverterInput"
game := {}
newPlatform := "PokerStars", oldPlatformNameCount := 5    ;;Can be changed if need to change from/inot different names


\::
    Loop Files, %inputFolder%\*.txt
    {
        fileDir = %inputFolder%\%A_LoopFileName%
        inputString := input(fileDir)

        splitTextIntoObjects(inputString)
        splitFullStringsIntoLinesAndPutIntoArray()
        changePlatformNames()
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

splitFullStringsIntoLinesAndPutIntoArray(){
    global game
    for i, element in game{
        line := StrSplit(element.fullString, "`n")
        element.line := line
    }
}

changePlatformNames(){
    global game, newPlatform, oldPlatformNameCount
    for i, element in game{
        firstLine := element.line[1]
        StringTrimLeft, lineWPlatfNameDel, firstLine, %oldPlatformNameCount%
        recreatedLine := newPlatform lineWPlatfNameDel
        element.line[1] := recreatedLine
    }
}

