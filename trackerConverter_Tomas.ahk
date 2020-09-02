#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

inputFolder := "C:\trackerConverterInput"
game := {}

\::
    times := 0
    createInputFolderIfNotExists(inputFolder)

    MsgBox, After pressing OK the conversion will begin...
    Loop Files, %inputFolder%\*.txt
    {
        times++
        game := {}

        fileDir = %inputFolder%\%A_LoopFileName%
        inputString := input(fileDir)
        newLineKind := checkWhichKindNewLine(inputString)

        splitTextIntoObjects(inputString, newLineKind)
        game.Pop()

        splitFullStringsIntoLinesAndPutIntoArray()

        changeFirstLine()

        deleteUnwantedDealtLines()

        initiateShowsCounts()
        deleteShowDownIfNotEnaughShows()

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

splitTextIntoObjects(inputString, newLineKind){
    global game

    gamesFullStringsArray := StrSplit(inputString, newLineKind)
    
    for i, element in gamesFullStringsArray{
        gameObject := {}
        gameObject.fullString := element
        game.Push(gameObject)
    }

    if (gamesFullStringsArray.Length() <= 1){
        MsgBox, Error func splitTextIntoObjects, no double newline found`nEXITING SCRIPT
        ExitApp
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

        firstLineName := SubStr(firstLine, 1, 14)
        if (firstLineName != "Poker Hand #HD"){
            MsgBox, Error func changeFirstLine, first line doesnt contain "Poker Hand #HD", first 14 chars are "%firstLineName%"`nEXITING SCRIPT
            ExitApp
        }

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

initiateShowsCounts(){
    global game
    for i, element in game{
        showsCount := 0
        for j, line in element.line{
            IfInString, line, shows
            {
                showsCount++
                showsStringWithSymbols := ": shows ["
                IfNotInString, line, %showsStringWithSymbols%
                    MsgBox, Error func getShowsCounts line:`n%line%
            }
        }
        game[i].showsCount := showsCount
    }
}

deleteShowDownIfNotEnaughShows(){
    global game
    for i, element in game{
        if (element.showsCount < 2){
            showDownRemoved := 0
            for j, line in element.line{
                if (line = "*** SHOWDOWN ***"){
                    zz:=0
                    element.line.RemoveAt(j)
                    showDownRemoved := 1
                    break
                }
            }
            if (showDownRemoved = 0)
                MsgBox, Error func deleteShowDownIfNotEnaughShows cant find SHOWDOWN
        }
    }
}

checkWhichKindNewLine(inputString){
    nrFound := 0
    nFound := 0
    nr := "`n`r`n`r`n"
    n := "`n`n`n"
    IfInString, inputString, %nr%
        nrFound := 1
    IfInString, inputString, %n%
        nFound := 1

    if (nrFound && nFound)
        MsgBox, Error func checkWhichKindNewLine, both kind of newlines
    else if (nrFound)
        return "`n`r`n`r`n"
    else if (nFound)
        return "`n`n`n"
    else if (!nFound && !nrFound)
        MsgBox, Error func checkWhichKindNewLine, Cant find double newline
}