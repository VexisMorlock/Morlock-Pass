#Persistent 
OnExit(ObjBindMethod(MyObject, "Exiting"))											;run exit script to clear directorys
setkeydelay, 0																		;needed to simulate paste
setworkingdir, Z:/																;set directory to external drive
ifexist, Manager.morlock															;checks for name list goto #submit to change
	goto Buttonok
Gui, Add, Text, x22 y9 w250 h20 +Center, Please Enter Your Password					;opening gui
Gui, Add, Edit, x22 y29 w250 h20 vpass +Center +password +limit16,
Gui, Add, Button, x102 y49 w80 h20 +default, OK
; Generated using SmartGUI Creator 4.0
Gui, Show, h77 w300, Encrypted!!													;/opening gui
Return
return

GuiClose:																			;kill app if kill opening gui
	ExitApp	
	return
	
mainGuiclose:																		;kill app if you kill main gui
	ExitApp
	return

class MyObject																		;App exiting process
{
    Exiting()
    {
	FileDelete, pass.morlock														;clean up pswd file
	FileDelete, Manager.morlock														;clean up name file
	global pswd:= 0000000000000000													;clear archive pass from memory
	Clipboard:=00000000000000000000													;replace clipboard
    }
}

ButtonOK:																			;after hit ok on opening gui
	Gui, Submit																		;save state of opeing gui/ hide
	Guicontrolget, pswd,, pass														;get master from user
	runwait, 7za.exe x key_Card.7z -p%pswd% -y Manager.morlock -r						;run 7z to extract names ;;can leave in dir if dont want to put in pswd 2 times #see submit
	global pswd:= 0000000000000000													;gets rid of pswd from memory
	Errorlevel:=0																	;force good error
	Fileread, List, Manager.morlock											;reads password names
	sleep, 500																		;wait 1/2 sec ajust if you want it to run faster
	if Errorlevel																	;if no file or password incorrect
	{
		gui, restore																;bring back onening gui
		exit
		return	
	}
	else																			;if file exist/ correct pswd
	{
		Gui, main:Add, Text, x22 y10 w250 h20 +Center, What Password Do You Need?		;main manager gui
		Gui, main:Add, ComboBox,vdrop x22 y35 w250, %List%
		Gui, main:Add, Edit, x22 y95 w250 h20 vpass2 +Center +password +limit16 Hwndp1,
		Gui, main:Add, Radio, x75 y60 h30 checked vradiogroup, Read
		Gui, main:Add, Radio, x150 y60 h30, Write
		Gui, main:Add, checkbox, x75 y120 vsave, Close
		Gui, main:Add, checkbox, x150 y120 vsavepswd, Save Pswd while open
		Gui, main:Add, Button, x100 y145 w80 h30 +Default gButtonSubmit, Submit
		; Generated using SmartGUI Creator 4.0
		Gui, main:Show, h185 w300, 											;/main manager gui
		Return
		}
Return
		
ButtonSubmit:																		;submit from main gui
	Gui, main:Submit,															;save gui state
	Guicontrolget, pswd,, pass2														;get master pswd from user
	if (pswd!="")
	{
		if (radiogroup=1)
		{
			runwait, 7za.exe x key_Card.7z -p%pswd% -y pass.morlock -r							;run 7z to extract pswd file as plain text
			global pswd:= 0000000000000000													;clear master pswd
			sleep, 500																		;wait 1/2 sec for extraction longer pswd file longer wait time
			IniRead, Clipboard, pass.morlock, SectionName, %drop%								;get pswd
			FileDelete, pass.morlock															;clean up pswd file
			FileDelete, Manager.morlock													;###### comment out to get rid of opening gui
			global ready:=1
		}
		else
		{
			msgbox, 276, WARNING!!!!!, are you sure you want to write to %drop%
			ifmsgbox Yes
			{
				goto, guipass
			}
			else
			{
				controlsettext,,,ahk_id %p1%
				gui, main:restore
			}
		}
	}
	else
	{
	msgbox you need a password
	gui, main:restore
	}
Return

guipass:
	gui, guinewpass:new,, %Drop%'s new password
	gui, guinewpass:+owner
	gui, guinewpass:+alwaysontop
	gui, guinewpass:add, Edit, w250 vpassnew +Center +password +limit16 Hwndp0,
	gui, guinewpass:add, button,gnewbutton x400 y-200 w1 h1 +default,
	gui, guinewpass:show, h40 w300,
	return
return

newbutton:
	gui, guinewpass:submit
	Guicontrolget, pswdnew,, passnew
	gui, guinewpass:destroy
	msgbox this is a box %pswd% %Drop%
	fileAppend, %Drop%|,Manager.morlock
	runwait, 7za.exe x key_Card.7z -p%pswd% -y pass.morlock -r							;run 7z to extract pswd file as plain text
	sleep, 500
	iniwrite, %pswdnew%, pass.morlock, SectionName, %Drop%
	runwait, 7za.exe a key_Card.7z *.morlock -p%pswd% -y
	global pswd:= 0000000000000000													;clear master pswd
	if (save =1)
	{
		goto, Guiclose
	}
	else
	{
		if (savepswd = 0)
		{
			controlsettext,,,ahk_id %p1%
		}
		FileDelete, pass.morlock															;clean up pswd file
		FileDelete, Manager.morlock	
		gui, main:restore
	}
return

	^v::
		if (ready=1)
		{
			Send, %clipboard%
			clipboard :=
			global ready := 0
			if (save =1)
			{
				goto, Guiclose
			}
			else
			{
				if (savepswd = 0)
				{
					controlsettext,,,ahk_id %p1%
				}
				gui, main:restore
			}
		}
		Return
