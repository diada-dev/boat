Global Dim _Fonts.s(0)

Procedure EnumFontFamProc(*lpelf.ENUMLOGFONT,*lpntm.NEWTEXTMETRIC,FontType,lparam)
    Protected Font.s=PeekS(@*lpelf\elfLogFont\lfFaceName[0])
    Protected i=ArraySize(_Fonts())
    If Font
        _Fonts(i)=Font
        ReDim _Fonts(i+1)
    EndIf
    ProcedureReturn 1
EndProcedure

Procedure GetFonts()
    Protected hWnd=GetDesktopWindow_()
    Protected hDC=GetDC_(hWnd)
    EnumFontFamilies_(hDC,0,@EnumFontFamProc(),0)
    ReDim _Fonts(ArraySize(_Fonts())-1)
    ReleaseDC_(hWnd,hDC)
    ProcedureReturn ArraySize(_Fonts())+1
  EndProcedure
  
;Byte.b  = 2        ; Byte (8 bit) variable
;Long.l  = 400000   ; Long (32 bit) variable

Structure HitList
  Score.l
  Name.s
EndStructure

Structure GameObject
  x.l
  y.l
  full.b
EndStructure


Enumeration
  #WINDOW_MAIN
  #IMAGE_MAN
  #IMAGE_KAT
  #IMAGE_FUEL
EndEnumeration

#FLAGS = #PB_Window_SystemMenu | #PB_Window_ScreenCentered|#PB_Window_ScreenCentered | #PB_Window_MinimizeGadget

    Dim Ice.GameObject(99)
    Dim Man.GameObject(99)
    Dim Fuel.GameObject(99)
    
    Dim TopHit.HitList(3)
     If OpenFile(0,"top.txt")
       For i=0 To 3
         TopHit(i)\Name=ReadString(0)
         TopHit(i)\Score=Val(ReadString(0))
       Next i
     EndIf
     CloseFile(0)
     
    F1.s="valentina.ttf"
    F2.s=""
    
    QuantBefore.i=GetFonts()

    Dim FontsBefore.s(ArraySize(_Fonts()))
    For i=0 To QuantBefore-1
        FontsBefore(i)=_Fonts(i)
    Next

    R=AddFontResource_(F1.s+F2.s)
    SendMessage_(#HWND_BROADCAST,#WM_FONTCHANGE,0,0)
    
    ReDim _Fonts.s(0)
    QuantAfter.i=GetFonts()

    Dim FontsAfter.s(ArraySize(_Fonts()))
    For i=0 To QuantAfter-1
        FontsAfter(i)=_Fonts(i)
    Next
    
    FontName.s=""
    For i=0 To ArraySize(FontsBefore())
        If FontsBefore(i)<>FontsAfter(i)
            FontName.s=FontsAfter(i)
            Break
        EndIf
    Next
    If FontName.s=""
        FontName.s=FontsAfter(ArraySize(FontsAfter()))
    EndIf
    
    LoadFont(9,FontName.s,20) 
    LoadFont(10,FontName.s,30) 

    UsePNGImageDecoder()
    LoadImage(#IMAGE_MAN,  "man.png")  
    LoadImage(#IMAGE_KAT,  "katerok.png")  
    LoadImage(#IMAGE_FUEL, "fuel.png")  
;/////////////////////////////////////////////////////////////////////////////////    
OpenWindow(#WINDOW_MAIN, 0, 0, 500, 500, "Спасай утопающих", #FLAGS)
    waitingTime=ElapsedMilliseconds() + 1000
StartPrg:
     
    If StartDrawing(WindowOutput(#WINDOW_MAIN))
       Box(0, 0, 500, 500, RGB(135, 135, 255))
       DrawingFont(FontID(10))
       DrawText(70, 30, "Топ-лист спасателей:", RGB(Random(255), Random(255), Random(255)),RGB(135, 135, 255)) 
       DrawingFont(FontID(9))       
       For i=0 To 3

         DrawText(30, 140 + i*60 , TopHit(i)\Name, RGB(Random(255), Random(255), Random(255)),RGB(135, 135, 255))
         DrawText(400,140 + i*60 , Str(TopHit(i)\Score), RGB(Random(255), Random(255), Random(255)),RGB(135, 135, 255))
       Next i
       
       DrawText(100, 460 , "Нажмите любую клавишу", RGB(Random(255), Random(255), Random(255)),RGB(135, 135, 255)) 

       StopDrawing()
    EndIf
    
    startTime=ElapsedMilliseconds()  
    Repeat
      Ev = WindowEvent()
      If Ev = #PB_Event_CloseWindow
        Goto EndPrg
      EndIf
      
      If ElapsedMilliseconds()>waitingTime
        For r=4 To 255
          If GetAsyncKeyState_(r)=-32767
            ;Score = 1010
            ;Goto Hit_Test
            Goto StartGame
           EndIf
        Next r
      EndIf
    Until ElapsedMilliseconds()>startTime + 10
      Goto StartPrg
      
StartGame:

  For i = 0 To 99
    Ice(i)\full = 0
    Man(i)\full = 0
    Fuel(i)\full = 0
  Next i
  XS=240
  Score = 0
  Fuel = 5
  Fire = 0
  Terminate = 0
  
Game_cycle:

        If GetAsyncKeyState_(37)<>0
          If XS>0
            XS=XS-20
          EndIf
        ElseIf GetAsyncKeyState_(39)<>0
          If XS<480
            XS=XS+20
          EndIf
        EndIf
        
        If (Fire = 0)  And (GetAsyncKeyState_(32)=-32767) And (Fuel>0)
          Fire = 5
          Fuel = Fuel - 1
        ElseIf Fire>0
          Fire = Fire - 1
        EndIf
  
  
   For r = 0 To Random(3)
    If Random(1)
       For i = 0 To 99
         If Ice(i)\full = 0
           Ice(i)\x = Random(25)*20
           Ice(i)\y = 500;
           Ice(i)\full = 1
           Break
         EndIf
       Next i  
     EndIf 
    Next r
     
    If Random(1)
       For i = 0 To 99
         If Man(i)\full = 0
           Man(i)\x = Random(25)*20
           Man(i)\y = 500;
           Man(i)\full = 1
           Break
         EndIf
       Next i  
     EndIf 
     
    If Random(20) = 0
       For i = 0 To 99
         If Fuel(i)\full = 0
           Fuel(i)\x = Random(25)*20
           Fuel(i)\y = 500;
           Fuel(i)\full = 1
           Break
         EndIf
       Next i  
     EndIf 
     
     For i = 0 To 99
         If Man(i)\full
           Man(i)\y = Man(i)\y - 20;
               If Man(i)\y=-20
                 Man(i)\full = 0
               ElseIf (Man(i)\y<=20) And (Man(i)\x = XS)
                 Man(i)\full = 0
                 Score = Score + 10
               ElseIf (Man(i)\y=40) And (Man(i)\x = XS) And (Fire > 0)
                  Terminate = 2
                  Goto Game_end 
               EndIf  
         EndIf
             
         If Ice(i)\full
           Ice(i)\y = Ice(i)\y - 20;
               If (Ice(i)\y=-20) Or ((Ice(i)\y=20) And (Ice(i)\x = XS) And Fire > 0)
                 Ice(i)\full = 0
               ElseIf (Ice(i)\y<=20) And (Ice(i)\x = XS)
                 Terminate = 1
                 Goto Game_end
               EndIf  
        EndIf 
             
        If Fuel(i)\full
          Fuel(i)\y = Fuel(i)\y - 20;
          
               If (Fuel(i)\y<=20) And (Fuel(i)\x = XS)
                 Fuel(i)\full = 0
                 Fuel = Fuel + 1
                 Score = Score + 2
               ElseIf (Fuel(i)\y=40) And (Fuel(i)\x = XS) And (Fire > 0)
                  Terminate = 3
                  Goto Game_end 
               EndIf  
         EndIf  
             
     Next i  


     If StartDrawing(WindowOutput(#WINDOW_MAIN))
       Box(0, 0, 500, 500, RGB(135, 135, 255))
       
       
       For i = 0 To 99
         If Man(i)\full
           ;Box(Man(i)\x, Man(i)\y, 20, 20, RGB(0, 0, 0))
           DrawImage(ImageID(#IMAGE_MAN), Man(i)\x, Man(i)\y)
         EndIf
             
         If Ice(i)\full
              Box(Ice(i)\x, Ice(i)\y, 20, 20, RGB(255, 255, 255))
         EndIf       
         
         If Fuel(i)\full
             DrawImage(ImageID(#IMAGE_FUEL), Fuel(i)\x, Fuel(i)\y)
         EndIf 
       Next i 
       
       If Fire>0
         Box(XS, 40, 20, 20, RGB(255, 255, 128))
       EndIf
       
       DrawImage(ImageID(#IMAGE_KAT), XS, 0)
       DrawingFont(FontID(9))
       DrawText(10, 460 , "Очки:" + Str(Score), RGB(255, 255, 128),RGB(135, 135, 255))
       DrawText(300, 460 , "Огонь:" + Str(Fuel), RGB(255, 255, 128),RGB(135, 135, 255))      
       
       StopDrawing()
    EndIf      
    
    startTime=ElapsedMilliseconds()
    Repeat
      Ev = WindowEvent()
      If Ev = #PB_Event_CloseWindow
        Goto EndPrg
      EndIf
      
      If GetAsyncKeyState_(#VK_ESCAPE)=-32767
         Goto Game_pause  
      EndIf  
      
    Until ElapsedMilliseconds()>startTime + 150
    Goto Game_cycle  
    
    
 Game_pause:
 
     If StartDrawing(WindowOutput(#WINDOW_MAIN))
       DrawingFont(FontID(10))
       DrawText(190, 190, "Пауза", RGB(Random(255), Random(255), Random(255)),RGB(135, 135, 255)) 
       StopDrawing()
     EndIf

    startTime=ElapsedMilliseconds()
    Repeat
      Ev = WindowEvent()
      If Ev = #PB_Event_CloseWindow
        Goto EndPrg
      EndIf
      
      If GetAsyncKeyState_(#VK_ESCAPE)=-32767
        Goto Game_cycle  
      EndIf  
      
    Until ElapsedMilliseconds()>startTime + 10
    Goto Game_pause  
    
Game_end: 
     If Terminate = 1
         TerminteStr.s = "Вы утонули" 
         TerminateX = 150
     ElseIf Terminate = 2
         TerminteStr.s = "Убийца!!!" 
         TerminateX = 180  
     EndIf
     
     
Game_end_paused:     
     If StartDrawing(WindowOutput(#WINDOW_MAIN))
        If Terminate<3
          DrawingFont(FontID(10))
          DrawText(TerminateX, 190, TerminteStr, RGB(Random(255), Random(255), Random(255)),RGB(135, 135, 255))
        Else
          Box(XS-20, 0, 60, 60, RGB(Random(255), Random(255), Random(255)))
        EndIf
        StopDrawing()
     EndIf
      

    startTime=ElapsedMilliseconds()
    Repeat
      Ev = WindowEvent()
      If Ev = #PB_Event_CloseWindow
        Goto EndPrg
      EndIf
      
      For r=4 To 255
          If GetAsyncKeyState_(r)=-32767
            Goto Hit_test
           EndIf
       Next r
      
    Until ElapsedMilliseconds()>startTime + 10
    Goto Game_end_paused
    
Hit_Test:
   For Test = 0 To 3
     If TopHit(Test)\Score<Score
       Break;
     EndIf
   Next Test
   ;Test = Test + 1
   Debug Test
   
   If Test < 3 
   For f= 0 To 3-Test
     If (2-f)>=0  
       TopHit(3-f)\score = TopHit(2-f)\Score
       TopHit(3-f)\Name = TopHit(2-f)\Name
     EndIf
   Next f
   EndIf
   If Test < 4 
     StringGadget(0,145, 250,  225, 35, "")
     SetGadgetFont(0,FontID(9))
     
name_enter:
        If StartDrawing(WindowOutput(#WINDOW_MAIN))
          DrawingFont(FontID(10))
          DrawText(150, 190, "Введите имя", RGB(Random(255), Random(255), Random(255)),RGB(135, 135, 255))
          StopDrawing()
        EndIf
        
    startTime=ElapsedMilliseconds()
    Repeat

        
      Ev = WindowEvent()
      If Ev = #PB_Event_CloseWindow
        Goto EndPrg
      EndIf
      
      If GetAsyncKeyState_(13)=-32767
        Goto save_name 
      EndIf  
      
    Until ElapsedMilliseconds()>startTime + 10
    Goto name_enter 
  
save_name:     
     TopHit(Test)\score = Score
     TopHit(Test)\Name = GetGadgetText(0)
     FreeGadget(0)
   EndIf
   
   If Test < 4 
     CreateFile(0, "top.txt")
       For i=0 To 3
         WriteStringN(0,TopHit(i)\Name)
         WriteStringN(0,Str(TopHit(i)\Score))
       Next i
     CloseFile(0)      
   EndIf

     
   waitingTime = ElapsedMilliseconds() + 3000
   Goto StartPrg  
   
EndPrg:    

End
; IDE Options = PureBasic 4.50 (Windows - x86)
; CursorPosition = 235
; FirstLine = 209
; Folding = -
; EnableXP
; Executable = katerok.exe
; DisableDebugger