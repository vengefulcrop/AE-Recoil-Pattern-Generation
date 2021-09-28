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
Loop, Read, patterns/Flatline.txt
    Pattern[A_Index]:=StrSplit(A_LoopReadLine, [A_Space, A_Tab])					;todo: find how to exclude new line empty space. Reads the document line by line, splits it on tabs and spaces

;-------Variables---------
																					;everything here was fine tuned for 5.3 in game sens
	yoursens := 5.3		;don't change unless you're done with tuning cmod and want to test this on your sens
	targetsens := 4
	
;current values are for flatline		
	wpmaxt := 2.97																	;purple mag firing time in s	
	cmodx := 0.58																	;multiplier. multiply all x or y coordinates by a number to control the strenght 
	cmody := 0.72			;values around 0.5-0.8 seem to work best for 5.3 sens

;controls and switches	
	rampx := 0	
	rampy := 0			
	out2txt := 0 																	;if set to 1 - output resulting calculations to a standart pattern array usable with existing scripts and save as txt
	oldout := 0																		;if set to 1, the script outputs in the old script format ("pointnumber:"x,y,t""), else - the new one (x,y,t)	
	outputfile  := "outputpattern.txt"												;output file name, can create a new file if it didn't exist, can override an existing file but will make it messy

	lmax := Pattern.maxindex()
	i := 1																			;current line index, don't change anything in this block
    time := (wpmaxt/lmax)*1000										;calc delay in milisecs
	t := 0																			;unused
	sensmod := yoursens/targetsens	

	
	fincmodx := cmodx
	fincmody := cmody
	
	
	rampxstart := 80
	rampxend := lmax
	rampxcmod := 0.5
	
	rampxcmodsub := rampxcmod - cmodx
	rampxstep := rampxcmodsub /((lmax - rampxstart) - (lmax - rampxend))
	
	
	rampystart := 60
	rampyend := lmax
	rampycmod := 0.1
	
	rampycmodsub := rampycmod - cmody
	rampystep := rampycmodsub /((lmax - rampystart) - (lmax - rampyend))


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

			if (rampx = 1) {
				if (i > rampxstart) AND (i < rampxend)
				{
					fincmodx += (rampxstep)
				}
			   
				else { 
					if (i = rampxend) {
					fincmodx := rampxcmod
					}
				}
				}
						
			if (rampy = 1) {
				if (i > rampystart) AND (i < rampyend)
				{
					fincmody += (rampystep)
				}
			   
				else { 
					if (i = rampyend) {
					fincmody := rampycmod
					}
				}
			  }
			
			x := ((Pattern[i][3]-Pattern[im][3])*fincmodx)*sensmod 					;todo: not sure where to place sensmod - here or in the dll call 
			y := ((Pattern[i][4]-Pattern[im][4])*fincmody)*sensmod
			
            ToolTip % fincmody " " fincmodx  " " i 																;"i" for line index, "x" or "y" for current coordinates etc

            if (!GetKeyState("LButton", "P") || a_index > lmax) {  ;break and return to default values if buttons not held
                DllCall("mouse_event", uint, 4, int, 0, int, 0, uint, 0, int, 0)
				i := 1
				im := 1
				t := 0
					if ((rampx = 1) || (rampy = 1))
					{
						fincmodx := cmodx 			;return cmod to initial values if ramp enabled
						fincmody := cmody
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
					if (oldout = 1) {
					
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
						}						  ;Rounds time var to one digit max after the coma, only when writing to a file
					  FileAppend, % a_index . ":" . " " . """" . Round(x) "," . Round(y) . "," . Round(time, 1) .  """" . nl . "," . ns , %outputfile%
									}
					else {
					  FileAppend, % Round(x) "," . Round(y) . "," . Round(time, 1) . "`n", %outputfile%
					}

				}

			}
			
        } 	
	}
    return
