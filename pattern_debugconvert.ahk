#NoEnv
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input
SetWorkingDir %A_ScriptDir%

SetBatchLines -1            
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1

;-------Pattern arrays----

Pattern := Object()
Loop, Read, patterns/r301_SFnew.txt
    Pattern[A_Index]:=StrSplit(A_LoopReadLine, [A_Space, A_Tab])					;todo: find how to exclude new line empty space. Reads the document line by line, splits it on tabs and spaces

;-------Variables---------
																					;everything here was fine tuned for 5.3 in game sens
	sens := 5.3																		;don't change unless you're done with tuning cmod and want to test this on your sens
	
;current values are for the new r301 pattern		
	wpmaxt := 2.5																	;purple mag firing time in s	
	cmodx := 0.85																	;multiplier. multiply all x or y coordinates by a number to control the strenght 
	cmody := 0.68 																	;values around 0.5-0.8 seem to work best for 5.3 sens

	
	linecor := 0																	;1 to enable manual by-line cmod correction
	out2txt := 0 																	;if set to 1 - output resulting calculations to a standart pattern array usable with existing scripts ("pointnumber:"x,y,t"") and save as txt
	outputfile  := "r301new_out3.txt"												;output file name, can create a new file if it didn't exist, can override an existing file but will make it messy

	i := 1																			;current line index, don't change anything in this block
    time := (wpmaxt/Pattern.maxindex())*1000										;calc delay in milisecs
	t := 0																			;unused
	sensmod := 5.3/sens	

	;rawin := 0																		;don't touch
	;rawout := 0
    tempoutputfile = TEMP_%outputfile%

	~$*LButton::
	   if (GetKeyState("LButton", "P") && GetKeyState("RButton", "P")) {  			;if rbutton and lbutton are held physically
       Loop
        {   
		    im := i-1																;"im" is previous line's index, used for calculations, fall back to 1 if "i" is less than one
 		    if (im < 1) 
			   {
			    im += 1
			   }		
			   
		;--line specific pattern correction--
			
			;manually change compensation strenght (cmodx,cmody) when the script reaches a certain line in the raw AE pattern, requires linecor set to 1
			;values below are for demonstration purposes
			
		if (linecor = 1) {
	        if (i = 70) 
			   {
			    cmody := 0.53
			   }
            if (i = 110) 
			   {
			    cmodx := 0.85
			   }		
			}
		;--end line specific pattern correction--
			
			;subtract each preceding absolute coordinate from the following one to get relative coords
			x := ((Pattern[i][3]-Pattern[im][3])*cmodx)*sensmod 					;todo: not sure where to place sensmod - here or in the dll call 
			y := ((Pattern[i][4]-Pattern[im][4])*cmody)*sensmod

            ToolTip % i																;"i" for line index, "x" or "y" for current coordinates etc

            if (!GetKeyState("LButton", "P") || a_index > Pattern.maxindex()) {  ;break and return to default values if buttons not held
                DllCall("mouse_event", uint, 4, int, 0, int, 0, uint, 0, int, 0)
				i := 1
				im := 1
				t := 0
					if (linecor = 1) 
					{
						cmodx := 0.85 ;return cmod to initial values if linecor enabled
						cmody := 0.68
					}
                break 
				}
			else
			{
			    sleep time
			    DllCall("mouse_event", uint, 0x01, uint, Round(x), uint, Round(y))	;since mouse_event operates in full pixels only, it's better to round or somehow trim the resulting value.
			    i += 1																;this could also mean that higher screen resolutions could result in more accurate script based recoil 
																					;control since you can move mouse by pixels more precisely
																					
				;--text output----------											the following code is responsible for writing the resulting pattern to a txt using the old format

				if( out2txt = 1) {
				   if (Mod(a_index, 3) = 0 ) {										;insert ENTER at the end of the line when three blocks are in place
				      nl := "`n"
					  }
					  else {
					  nl := ""
					  }
				   if (nl = "`n" ) {
				      ns := ""
					  }
					  else {
					  ns := " "
					  }																;Rounds time var to one digit max after the coma, only when writing to a file
	            FileAppend, % a_index . ":" . " " . """" . Round(x) "," . Round(y) . "," . Round(time, 1) .  """" . nl . "," . ns , %outputfile%
				
				;unused, not working properly
				;FileRead, rawin, %tempoutputfile%
				     ;NewStr := StrReplace(rawout, "'", """)
                ;StringReplace, rawout, rawin,',", All
                ;FileAppend, % rawout, %outputfile%
				}

			}
			
        } 	
		}
    return