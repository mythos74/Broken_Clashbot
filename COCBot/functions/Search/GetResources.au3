;Uses the getGold,getElixir... functions and uses CompareResources until it meets conditions.
;Will wait ten seconds until getGold returns a value other than "", if longer than 10 seconds - calls checkNextButton
;-clicks next if checkNextButton returns true, otherwise will restart the bot.

Func GetResources() ;Reads resources
	While 1
		Local $i = 0
		Local $x = 0
		Local $txtDead = "Live"
		While getGold(51, 66) = "" ; Loops until gold is readable
			If _Sleep(500) Then ExitLoop (2)
			$i += 1
			If $i >= 20 Then ; If gold cannot be read by 10 seconds
				If checkNextButton() And $x <= 20 Then ;Checks for Out of Sync or Connection Error during search
					Click(750, 500) ;Click Next
					If _Sleep(1000) Then ExitLoop
				$x += 1
				Else
					SetLog("Cannot locate Next button, Restarting Bot", $COLOR_RED)
					If $DebugMode = 1 Then
						_CaptureRegion()
						_GDIPlus_ImageSaveToFile($hBitmap, $dirDebug & "NoNextRes-" & @HOUR & @MIN & @SEC & ".png")
					EndIf
					If $PushBulletEnabled = 1 Then
						_Push("Disconnected", "Your bot got disconnected while searching for enemy..")
					EndIf
					checkMainScreen()
					$Restart = True
					$DCattack = 1
					ExitLoop (2)
				EndIf
				$i = 0
			EndIf
		WEnd
		If _Sleep(300) Then ExitLoop (2)

		$searchDead = checkDeadBase()
		$searchTH = checkTownhall()
		$searchGold = getGold(51, 66)
		$searchElixir = getElixir(51, 66 + 29)
		$searchTrophy = getTrophy(51, 66 + 90)

		If $searchDead Then $txtDead = "Dead"

		If $searchTrophy <> "" Then
			$searchDark = getDarkElixir(51, 66 + 57)
		Else
			$searchDark = 0
			$searchTrophy = getTrophy(51, 66 + 60)
		EndIf

		If $searchTH = "-" Then
			$THLoc = "-"
			$THquadrant = "-"
			$THx = 0
			$THy = 0
		Else
			$THquadrant = 0
			If $WideEdge = 1 Then
				If ((((85 - 389) / (528 - 131)) * ($THx - 131)) + 389 > $THy) Then
					$THquadrant = 1
				ElseIf ((((237 - 538) / (723 - 337)) * ($THx - 337)) + 538 > $THy) Then
					$THquadrant = 4
				Else
					$THquadrant = 7
				EndIf
				If ((((388 - 85) / (725 - 330)) * ($THx - 330)) + 85 > $THy) Then
					$THquadrant = $THquadrant + 2
				ElseIf ((((537 - 238) / (535 - 129)) * ($THx - 129)) + 238 > $THy) Then
					$THquadrant = $THquadrant + 1
				EndIf
			Else
				If ((((70 - 374) / (508 - 110)) * ($THx - 110)) + 374 > $THy) Then
					$THquadrant = 1
				ElseIf ((((252 - 552) / (742 - 358)) * ($THx - 358)) + 552 > $THy) Then
					$THquadrant = 4
				Else
					$THquadrant = 7
				EndIf
				If ((((373 - 70) / (744 - 350)) * ($THx - 350)) + 70 > $THy) Then
					$THquadrant = $THquadrant + 2
				ElseIf ((((552 - 253) / (516 - 108)) * ($THx - 108)) + 253 > $THy) Then
					$THquadrant = $THquadrant + 1
				EndIf
			EndIf
			If $THquadrant >= 1 And $THquadrant <= 4 Then $THLoc = "Out"
			If $THquadrant = 5 Then $THLoc = "In"
			If $THquadrant >= 6 And $THquadrant <= 9 Then $THLoc = "Out"
		EndIf

		$SearchCount += 1 ; Counter for number of searches
		SetLog("(" & $SearchCount & ") [G]: " & $searchGold & Tab($searchGold, 7) & "[E]: " & $searchElixir & Tab($searchElixir, 7) & "[D]: " & $searchDark & Tab($searchDark, 4) & "[T]: " & $searchTrophy & Tab($searchTrophy, 3) & "[TH]: " & $searchTH & (($searchTH <> "-") ? ("-Q" & $THquadrant) : ("")) & ", " & $THLoc & ", " & $txtDead, $COLOR_BLUE)
		ExitLoop
	WEnd
EndFunc   ;==>GetResources