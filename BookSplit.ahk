#singleinstance, force
#Persistent
SetBatchLines -1
info =
(
BookSplit
version 0.1
Made in Autohotkey by jbarcelo
Adapted from BookCrop from nod5.dcmembers.com
Free Software -- http://www.gnu.org/licenses/gpl-3.0.html
Tested in Win7 x64

WHAT IT DOES
1. Drag and drop a folder of jpeg or tif images.
2. Show the images present in the folder in sequence
3. Click in the image and divide the image in two. Left and Right
4. Show the Next image


SETUP
- Get and install latest GraphicsMagick (Q8 version is faster)
- Get Jpegtran from libjpeg-turbo (faster than jpegclub version):
  - Download libjpeg-turbo-1.4.90-gcc.exe (64bit: gcc64.exe) or newer
  - Unzip the exe and browse \bin subfolder
  - copy jpegtran.exe + libjpeg-62.dll and place next to BookSplit.exe

NOTES
BookSplit split all and only jpeg or tif files in the dropped folder.
Other files and subfolders are ignored.

Advice: Use split to subfolder, so you can redo if you split in the wrong place.
Preview works well only if all input images have same size.
)
xwintitle = BookSplit

Gui,6: font, s8 cgray
Gui,6: Add, Text,x290 y345 gsplash, ?
Gui,6: font, s12 bold
Gui,6: Add, GroupBox, x5 y2 w290 h300
Gui,6: Add, Text,x78 y125 h130 w200 vtxt,Drop .jpg folder
Gui,6: Show,h360 w300,%xwintitle%

checkini()
if splash = 1
 goto splash
return

;------------
checkini() {
	global
	xini = %A_ScriptFullPath%.ini
	ifnotexist, %xini%
	{
		xinitext =
			(
			[%xwintitle%]
			splash=1
			subdir=1
			)
		FileAppend, %xinitext%, %xini%
	}
	xval = splash,subdir
	Loop, Parse, xval,`,
	 IniRead, %A_LoopField%, %xini%, %xwintitle%, %A_LoopField%, %A_space%
	splash := splash != 0 ? 1:0
	subdir := subdir != 0 ? 1:0
	
}
;------------
#IfWinActive, BookSplit ahk_class AutoHotkeyGUI

Tab:: goto splash


;------------
splash:
	WinGetPos,mainx,mainy, mainw,, %xwintitle%
	mainx += mainw

	Gui 7:+LastFoundExist
	IfWinExist
	{
		gui,7: destroy
		return
	}
	Gui, 7: +ToolWindow -SysMenu -Caption -resize +AlwaysOnTop +0x800000
	Gui, 7: Add, Text,, %info%
	Gui, 7: Add, Text,h1, %space%
	Gui, 7: Add, Checkbox,xm Checked%splash% section vsplashbox gsplashbox, show on startup
	Gui, 7: Add, Checkbox,xm Checked%subdir% section vsubdirbox gsubdirbox, split to subfolder
	
	Gui, 7: Add, Link,ys xm+200,<a href="http://nod5.dcmembers.com/">nod5.dcmembers.com</a>
	Gui, 7: Add, Link,yp+20 xm+200,<a href="http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick-binaries/">graphicsmagick.org</a>
	Gui, 7: Add, Link,yp+20 xm+200,<a href="http://sourceforge.net/projects/libjpeg-turbo/files/">libjpeg-turbo</a>
	Gui, 7: show, x%mainx% y%mainy%
	return
;------------

7GuiEscape: 
	gui,7: destroy
	return

splashbox: 
	Gui, Submit, NoHide
	IniWrite, %splashbox%, %xini%, %xwintitle%, splash
	return
subdirbox:
	Gui, Submit, NoHide
	IniWrite, %subdirbox%, %xini%, %xwintitle%, subdir
	subdir := subdirbox
	return
	;--------------------
	checkpaths() {   
		global
		SetRegView, 32   ;note: autochecks Wow6432Node if on win64
		RegRead, binpath, HKEY_LOCAL_MACHINE, SOFTWARE\GraphicsMagick\Current, BinPath  
		SetRegView, 64
		If !FileExist(binpath "\gm.exe")
			RegRead, binpath, HKEY_LOCAL_MACHINE, SOFTWARE\GraphicsMagick\Current, BinPath  
		If !FileExist(binpath "\gm.exe")
			msgbox, Error: GraphicsMagick not found.`nInstall it and try again.
		If !FileExist(A_Scriptdir "\jpegtran.exe") or !FileExist(A_Scriptdir "\libjpeg-62.dll")
			msgbox, Error: jpegtran.exe and/or libjpeg-62.dll not found.`nPlace them next to BookSplit.
		If FileExist(binpath "\gm.exe") and FileExist(A_Scriptdir "\jpegtran.exe") and FileExist(A_Scriptdir "\libjpeg-62.dll")
			tool = %binpath%\gm.exe
	}
;--------------------
6GuiDropFiles:
5GuiDropFiles:
 
	ar := "", al := ""
	checkpaths()
	if tool =
	 return
	xext =

	Loop, parse, A_GuiEvent, `n
	{
		FirstFile = %A_LoopField%
		Break
	}
	FileGetAttrib, xattrib, %firstfile%
	SplitPath, firstfile,,xdir,xext
	if xattrib not contains D           ;no directory
		if xext not in jpg,tif             ;no jpg or tif
			return                            

	if xattrib contains D
		xdir = %firstfile%
	t = %xdir%\%A_scriptname%_over.png
	filedelete %t%
	xtimestart := A_now

	Gui,5: destroy
	Gui,6: destroy
	Gui,7: destroy

	;GET IMAGE DIMENSIONS
	getdim(xdimfile) {
		global
		Img := ComObjCreate("WIA.ImageFile")
		Img.LoadFile(xdimfile)
		imgw := Img.Width , imgh := Img.Height
		sh := A_ScreenHeight-130  ;try fit pic to screen height
		prop :=  sh/imgh 		      ;Exact proportion pic/source height, for later upscale
		sw := imgw*prop
		swmax := A_ScreenWidth-100	
		if sw > swmax		;if too wide then fit screen width
			sw := A_ScreenWidth-100, prop := sw/imgw, sh := imgh*prop
		sh := Round(sh), sw := Round(sw)
	}
	
    if xext in jpg,tif  ;No single image preview allowed
		reload
	

	at := Object() , aj := Object()  ;tiff or jpg array
	Loop, %xdir%\*.jpg		;prepare multi image overlay
		aj.Insert(A_LoopFileFullpath)
	Loop, %xdir%\*.tif		
		at.Insert(A_LoopFileFullpath)
	if (aj.MaxIndex() == 0 and at.MaxIndex() == 0)
		return
	xext := aj.MaxIndex() >= at.MaxIndex() ? "jpg" : "tif" ;DO MOST COMMON FILETYPE
	ado := aj.MaxIndex() >= at.MaxIndex() ? aj : at

	
	; Show the first file
    numFile:= 1
	getdim(ado[numFile])	;get first file dimensions
	currentFile:=ado[numFile]
	
	
	RunWait "%tool%" convert -size %sw%x%sh% "%currentFile%" -sample %sw%x%sh%  "%t%" ,,hide
 
	makegui()
	return
	

makegui() {
	global
	Gui,5: destroy
	Gui,6: destroy
	sh := sh < 50 ? A_screenheight-100 : sh
	sw := sw < 50 ? A_screenwidth : sw

	Gui,5: margin,0,0
	Gui,5: font, s12 bold
	
	hbut := sh+5, htot := sh+40, xspl := sw-10
	Gui,5: Add, Button, x100 y%hbut% vback gback, Back
	GuiControl,5: Enable, back
	
	Gui,5: Add, Button, x200 y%hbut% vnext gnext, Next
	GuiControl,5: Enable, next 
	
	Gui,5: Add, Button, x300 y%hbut% visleft gisleft,  is left
	GuiControl,5: Enable, isright
	
	Gui,5: Add, Button, x400 y%hbut% visright gisright,  is right
	GuiControl,5: Enable, isright
	
	Gui,5: font, s8 cgray norm
	Gui,5: Show,w%sw% h%htot%,%xwintitle%
	Gui,5: Add, Text,x%xspl% yp+10 gsplash, ?
	Gui,5: +LastFound
	MainhWnd := WinExist()

	Gui, 6: margin,0,0									;image child window
	;Gui, 6: Add, Pic, vpic gpic, %t%		
	Gui, 6: Add, Pic, vpic gpic, %t%		
	Gui, 6: +Owner -Caption -SysMenu -resize +ToolWindow +0x800000 
	Gui, 6: Show, x0 y0
	Gui, 6: +LastFound
	pichWnd := WinExist()
	Gui, 6: +Parent%MainhWnd%
}

determinePath(ByRef ado, ByRef ar, byRef xdir, byRef subdir, byRef xtimestart) {	
		
	if (ado != ar) ;if ar then reuse xdir2 set in al array split
	   xdir2 := xdir
	if (subdir == 1)
	{
		if (ado != ar) 
		  xdir2 = %xdir%\%xtimestart%
		FileCreateDir, %xdir2%
	}
     
	return xdir2
}

;--------------------
pic:
	if xext in single
	 return

    MouseGetPos, xo  
	x :=0 , y :=0, w :=round( xo/prop ) , h :=imgh
    lx :=Round(xo/prop) -1, ly :=0, lw :=Round( (sw-xo)/prop ), lh :=imgh
	
	; SPLIT
	xdir2:= determinePath(ado,  ar, xdir,subdir, xtimestart)
    SplitPath, currentFile,xname,,,xnoext 
	cropper := xext == "tif" ? tool : A_scriptdir "\jpegtran.exe"
	  
	
	if (xext == "tif")
		{
			 Run "%cropper%" convert  -crop %LW%x%LH%+%LX%+%LY% "%currentFile%" "%xdir2%\%xnoext%_R.%xext%",,hide
			 Run "%cropper%" convert  -crop %W%x%H%+%X%+%Y% "%currentFile%""%xdir2%\%xnoext%_L.%xext%" ,,hide
		}
		else   ;jpg
		{
			Run "%cropper%"  -crop %LW%x%LH%+%LX%+%LY% -outfile "%xdir2%\%xnoext%_R.%xext%" "%currentFile%",,hide
			Run "%cropper%"  -crop %W%x%H%+%X%+%Y% -outfile "%xdir2%\%xnoext%_L.%xext%" "%currentFile%",,hide
		}
		sleep 10
	
	
	;Get next File
	numFile:= numFile+1
	if (numFile > ado._MaxIndex()){
		FileDelete, %t%
		Gui,5: destroy
	    Gui,6: destroy
	    Gui,7: destroy
		reload
		return
	}
		 
	getdim(ado[numFile])	;get first file dimensions
	currentFile:=ado[numFile]
	RunWait "%tool%" convert -size %sw%x%sh% "%currentFile%" -sample %sw%x%sh%  "%t%" ,,hide
	makegui()
	
	return
	;------------
back:
     if (numFile > 1) {
		numFile:= numFile-1
		currentFile:=ado[numFile]
		getdim(ado[numFile])
		RunWait "%tool%" convert -size %sw%x%sh% "%currentFile%" -sample %sw%x%sh%  "%t%" ,,hide
		makegui() 
		}	 
	 return
	  
next:
	if (numFile < ado._MaxIndex()) {
		numFile:= numFile+1
		currentFile:=ado[numFile]
		getdim(ado[numFile])
		RunWait "%tool%" convert -size %sw%x%sh% "%currentFile%" -sample %sw%x%sh%  "%t%" ,,hide
		makegui()
		return
	} else
	 reload
	;------------
isleft:
    xdir2:= determinePath(ado,  ar,xdir,subdir, xtimestart)
    SplitPath, currentFile,xname,,,xnoext
    FileCopy, %currentFile%, %xdir2%\%xnoext%_L.%xext%
	goto next
	
	  
isright:
    xdir2:= determinePath(ado,  ar,xdir,subdir, xtimestart)
    SplitPath, currentFile,xname,,,xnoext
	FileCopy, %currentFile%, %xdir2%\%xnoext%_R.%xext%
	goto next
	
;--------------------


6GuiClose:
5GuiClose:
FileDelete, %t%
ExitApp


