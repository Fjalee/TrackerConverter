#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

;TODO reset vars for new file

inputFolder := "C:\trackerConverterInput"
game := {}, times := 0

\::
    createInputFolderIfNotExists(inputFolder)

    Loop Files, %inputFolder%\*.txt
    {
        times++
        game := {}

        fileDir = %inputFolder%\%A_LoopFileName%
        inputString := input(fileDir)

        splitTextIntoObjects(inputString)
        game.Pop()

        splitFullStringsIntoLinesAndPutIntoArray()

        changeFirstLine()

        deleteUnwantedDealtLines()

        makeNewFullStringsForObjects()

        newTxtText := makeNewTxtFileString()

        rewriteFile(fileDir, newTxtText)

    }
    MsgBox, Converted %times% files in`n%inputFolder%
return

ESC::
	ExitApp
return

createInputFolderIfNotExists(fileDir){
    if !FileExist(fileDir){
        FileCreateDir, %fileDir%
        MsgBox, created directory %fileDir%`n`nEXITING SCRIPT
        ExitApp
    }
}

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
        indexHoleCardLine := getIndexHoldeCardLine(elementI)
        removeAllDealtLinesButHero(elementI, indexHoleCardLine)
    }
}
getIndexHoldeCardLine(thisGame){
    for i, element in thisGame.line{
        if (element = "*** HOLE CARDS ***"){
            return i
        }
    }
    MsgBox, Error func getIndexHoldeCardLine
}
removeAllDealtLinesButHero(game, indexHoleCardLine){
    amountOfDealt := 0  ;For error
    amountOfOpponentsDealt := 0 ;For error

    i := 10
    while (i > 1){
        j++
        i--
        elIndex := indexHoleCardLine+i
        line := game.line[elIndex]

        IfInString, line, Dealt to 
        {
            amountOfDealt++
            IfNotInString, line, Dealt to Hero
            {
                amountOfOpponentsDealt++
                game.line.RemoveAt(elIndex)
            }
        }
    }

    if (amountOfDealt-1 != amountOfOpponentsDealt)
        MsgBox, Error func removeAllDealtLinesButHero
}

makeNewFullStringsForObjects(){
    global game
    for i, element in game{
        newString := ""
        for j, line in element.line{
            newString := newString "`n" line
        }
        StringTrimLeft, newString, newString, 1
        element.newFullString := newString
    }
}

makeNewTxtFileString(){
    global game
    newTxtString := ""
    for i, element in game{
        newTxtString := newTxtString "`n`n" element.newFullString
    }
    StringTrimLeft, newTxtString, newTxtString, 2
    return newTxtString
}

rewriteFile(fileDir, newText){
    FileDelete, %fileDir%
    FileAppend, %newText%, %fileDir%
}
