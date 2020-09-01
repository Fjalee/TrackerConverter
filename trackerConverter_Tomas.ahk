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
        splitFullStringsIntoLinesAndPutIntoArray()
        changeFirstLine()
        deleteUnwantedDealtLines()
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

changeFirstLine(){
    global game
    for i, element in game{
        firstLine := element.line[1]
        StringTrimLeft, lineWPlatfNameDel, firstLine, 14
        recreatedLine := "PokerStars Hand #" lineWPlatfNameDel
        element.line[1] := recreatedLine
    }
}

deleteUnwantedDealtLines(){
    global game
    for i, elementI in game{
        for j, elementJ in elementI.line{
            stopped := 0
            if (elementJ = "*** HOLE CARDS ***"){
                stopped := 1
                break
            }
        }
        if (!stopped)
            MsgBox, Error func deleteUnwantedDealtLine()

        k := 10
        while (k > 1){
            k--
            elIndex := j+k
            line := elementI.line[elIndex]
            
            IfInString, line, Dealt to 
            {
                IfNotInString, line, Dealt to Hero
                {
                    elementI.line.RemoveAt(elIndex)
                }
            }
        }
    }
}

