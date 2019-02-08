
(* ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»   *)
(* º                                                        ºÛ  *)
(* º     Borland Pascal Version 7.0                         ºÛ  *)
(* º     Pack Man 2 - The Revenge. Level Editor Source.     ºÛ  *)
(* º                                                        ºÛ  *)
(* ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶Û  *)
(* º                                                        ºÛ  *)
(* º     Copyright (C) 1996 Diego Iastrubni                 ºÛ  *)
(* º                                                        ºÛ  *)
(* ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼Û  *)
(*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  *)


Program Pack_Man_Level_Editor;

{$IFDEF DPMI}
{$DEFINE NO_SOUNDS}
{$ENDIF}

{$IFNDEF NO_SOUNDS}
Uses XtndMode, Font8x16, Utils, SB, ADVHSC,
     PackMan1, PackMan2, PackMan3, PackMan4, PackMan5;
{$ELSE}
Uses XtndMode, Font8x16, Utils,
     PackMan1, PackMan2, PackMan3, PackMan4, PackMan5;
{$ENDIF}


Const
  (* Max stuff  *)
  MaxText         = 15;

  (* Files      *)
  FontFile        = 'C:\BP\DOS.FNT';

  (* Colors     *)
  TheTextColor     = 10;
  BackGroundColor  = 25;
  MarkerColor      = 10;
  ActiveColor      = LightRed;
  InActiveColor    = LightGray;
  MarkPictureColor = 11;
  FilesColor       = Cyan;

  (* Locations  *)
  LevelX1          = 030;
  LevelY1          = 030;
  LevelX2          = LevelX1 + (PicX+1)*(MaxX+2);
  LevelY2          = LevelY1 + (PicY+1)*(MaxY+2);

  BigBoxX1         = 10;
  BigBoxY1         = 300;
  BigBoxX2         = 640-BigBoxX1-10;
  BigBoxY2         = 400-10;

  Big_BoxX1        = LevelX2 + 20;
  Big_BoxY1        = 030;
  Big_BoxX2        = 640-BigBoxX1-10;
  Big_BoxY2        = LevelY2;

  SlotTextX1       = Big_BoxX1+10;
  SlotTextY1       = Big_BoxY1+10;
  SlotTextX2       = SlotTextX1 + 8*MaxText + 8;
  SlotTextY2       = SlotTextY1 + 20;

  LocationX        = SlotTextX1 + 60;
  LocationY        = SlotTextY1 + 30;

  SlotX1           = SlotTextX1;
  SlotY1           = LocationY;
  SlotX2           = SlotX1 + (PicX*3) + 4;
  SlotY2           = SlotY1 + (PicY*3);

  StuffX           = BigBoxX1 + 20;
  StuffY           = BigBoxY1 + 20;
  StuffTextX       = StuffX;
  StuffTextY       = StuffY + 20;

  ReadStrX         = StuffTextX;
  ReadStrY         = StuffTextY+20;

  ParamsX1         = BigBoxX2 - 100;
  ParamsY1         = BigBoxY1 + 10;
  ParamsX2         = BigBoxX2 - 10;
  ParamsY2         = BigBoxY2 - 10;

  M1X              = SlotTextX1;
  M1Y              = SlotTextY1 + 100;
  M2X              = M1X;
  M2Y              = M1Y + 20;
  M3X              = M2X;
  M3Y              = M2Y + 20;
  BonusX           = M3X;
  BonusY           = M3Y + 20;

  UserModeLoc      = ParamsY1+2;
  DrawModeLoc      = ParamsY1+20;

  LevelNumX        = 300;
  LevelNumY        = UserModeLoc;
  FileNameX        = LevelNumX;
  FileNameY        = LevelNumY + 20;

  MaxMousnters     = 4;

  (* Texts *)
  Texts: array[0..9] of String[MaxText] =
    ( 'Nothing             ',  'Wall                ',
      'Food                ',  'Cracker             ',
      'Mousnter wall       ',  'Pack-Man wall       ',
      'Both Wall           ',  'Black Hole          ',
      'Pack-Man Home       ',  'Mousnters Home      '
      );


  (* Used internaly *)
  AddX    = LevelX1+PicX;
  AddY    = LevelY1+PicY;
  SizeX   = PicX-1;
  SizeY   = PicY-1;
  PicX_2  = PicX div 2;
  PicY_2  = PicY div 2;


Procedure IncByRange( Var n: Integer; Min,Max: Integer ); Assembler;
Asm
   LES          BX,     n
   MOV          AX,     ES:[BX]
   INC          AX
   CMP          AX,     Max
   JNG          @Continue
   MOV          AX,     Min
@Continue:
   MOV          ES:[BX],AX
End;

Procedure DecByRange( Var n: Integer; Min,Max: Integer ); Assembler;
Asm
   LES          BX,     n
   MOV          AX,     ES:[BX]
   DEC          AX
   CMP          AX,     Min
   JNL          @Continue
   MOV          AX,     Max
@Continue:
   MOV          ES:[BX],AX
End;

Procedure LocalPutPixel( x,y: Integer; Color: Byte ); Far;
Begin
  XtndMode.PutPixel( LevelX1+PicX+x, LevelY1+PicY+y, Color );
End;

Procedure LocalPutPixel2( x,y: Integer; Color: Byte ); Far;
Begin
  XtndMode.PutPixel( x*2+1, y*2  , Color );
  XtndMode.PutPixel( x*2  , y*2  , Color );
  XtndMode.PutPixel( x*2+1, y*2+1, Color );
  XtndMode.PutPixel( x*2  , y*2+1, Color );
End;

(* Initilisation procedures *)
Procedure InitAll;
Begin
  Randomize;
  Load_World_1;
  New( Font );
  LoadFont( FontFile, Font^ );

{$IFNDEF NO_SOUNDS}
  UsingSB:= ResetDSP( bp220h );
  If Not UsingSB Then UsingSB:= ResetDSP( bp240h );
{$ENDIF}
End;

Procedure InitScreen;
Var
  c: Byte;
  i: Integer;
Begin
  ClearScreen( BackGroundColor );
  PutPixel:= XtndMode.PutPixel;
  SetAllPals( Palette );

  Box3D( LevelX1, LevelY1, LevelX2, LevelY2, False );
  Box3D( Big_BoxX1, Big_BoxY1, Big_BoxX2, Big_BoxY2, False );
  Box3D( BigBoxX1, BigBoxY1, BigBoxX2, BigBoxY2, False );

  c:= Internal;
  Internal:= BackGroundColor;

  Box3D( SlotTextX1-4, SlotTextY1-2, SlotTextX2+4, SlotTextY2-2, True  );
  Box3D( LocationX-2, LocationY-2, LocationX+6*8+4, LocationY+18, True  );
  Box3D( SlotX1-2, SlotY1-2, SlotX2, SlotY2, True );

  Box3D( ParamsX1-2, ParamsY1-2, ParamsX2+2, ParamsY2+2, True );
  Box3D( StuffX-3, StuffY-3, StuffX+11*(PicX+2), StuffY+PicY+2, True );
  Internal:= c;
  For i:= 0 to 9 do
    DrawPic( StuffX+i*(PicX+2), StuffY, GetPic(i)^ );
End;

(* Drawing Procedures       *)
Procedure DrawPic2( x, y, num: Integer );
Begin
  Case num of
    opClear,
    opCracker,
    opFood         : DrawPic( x, y, GetPic(num)^);
    opPackManHome  : DrawPic( x, y, Pictures[12] );
    opMounstersHome: DrawPic( x, y, Pictures[0] );
    opWall         : Box( x, y, x+SizeX, y+SizeY, Blue );
    opMonsWall     : Begin
                       Box( x, y, x+SizeX, y+SizeY, Blue );
                       PutPixel( x+4, y+5, White );
                     End;
    opPackWall     : Begin
                       Box( x, y, x+SizeX, y+SizeY, Blue );
                       PutPixel( x+1, y+2, White );
                       PutPixel( x+8, y+2, White );
                       PutPixel( x+1, y+8, White );
                       PutPixel( x+8, y+8, White );
                     End;
    opBothWall     : Begin
                       Box( x, y, x+SizeX, y+SizeY, Blue );
                       PutPixel( x+1, y+2, White );
                       PutPixel( x+8, y+2, White );
                       PutPixel( x+1, y+8, White );
                       PutPixel( x+8, y+8, White );
                       PutPixel( x+4, y+5, White );
                     End;
    opBlackHole    : Begin
                       Box( x, y, x+SizeX, y+SizeY, Black );
                       Line( x, y, x+SizeX, y+SizeY, White );
                       Line( x+SizeX, y, x, y+SizeY, White );
                     End;
  End;
End;

Procedure DrawLevel( Var ALevel: TLevelRec; UserMode: Boolean );
Var
  x,y: Integer;
Begin
  For x:= 0 to MaxX do
    Line( LevelX1+PicX+x*(PicX+1)-1, LevelY1+PicY-1,
          LevelX1+PicX+x*(PicX+1)-1, LevelY2-PicY-3, Black );
  For y:= 0 to MaxY do
    Line( LevelX1+PicX-1, LevelY1+PicY+y*(PicY+1)-1,
          LevelX2-PicX-3, LevelY1+PicY+y*(PicY+1)-1, Black );

  Utils.PutPixel:= LocalPutPixel;
  If UserMode
    Then For y:= 0 to MaxY-1 do
           For x:= 0 to MaxX-1 do
             DrawPic( x*(PicX+1), y*(PicY+1), GetPic(ALevel.Buffer[x,y])^ )
    Else For y:= 0 to MaxY-1 do
           For x:= 0 to MaxX-1 do
             DrawPic2( x*(PicX+1), y*(PicY+1), ALevel.Buffer[x,y] );
  Utils.PutPixel:= XtndMode.PutPixel;
End;

Procedure ShowSlot( PicNum,x,y: Byte; UserMode: Boolean );

Function Str(Num: Integer): String;
Var
  S: String;
Begin
  System.Str( Num:3,S );
  Str:=s;
End;

Begin
  Color:= TheTextColor;
  Back:= BackGroundColor;
  WriteStr( LocationX , LocationY , Str(X)+Str(Y) );
  WriteStr( SlotTextX1, SlotTextY1, Texts[PicNum] );
  Utils.PutPixel:= LocalPutPixel2;
  If UserMode
    Then DrawPic( (SlotX1 div 2)+3, (SlotY1 div 2)+2, GetPic(PicNum)^ )
    Else DrawPic2( (SlotX1 div 2)+3, (SlotY1 div 2)+2, PicNum );
  Utils.PutPixel:= XtndMode.PutPixel;
End;

Procedure ShowParams( UserMode, DrawMode: Boolean );
Begin
  Back:= BackGroundColor;
  If UserMode Then Color:= ActiveColor Else Color:= InActiveColor ;
  WriteStr( ParamsX1+2, UserModeLoc, 'USER MODE' );
  If DrawMode Then Color:= ActiveColor Else Color:= InActiveColor ;
  WriteStr( ParamsX1+2, DrawModeLoc, 'DRAW MODE' );
End;

Procedure WriteMouns( M1, M2, M3, Bonus: Byte );
Var
  s: String[3];
Begin
  Color:= TheTextColor;
  Back:= Internal;
  Str( M1:3, S );
  WriteStr( M1X, M1Y, 'Normal : '+S );
  Str( M2:3, S );
  WriteStr( M2X, M2Y, 'Chase  : '+S );
  Str( M3:3, S );
  WriteStr( M3X, M3Y, 'Hunt   : '+S );
  Str( Bonus:3, S );
  WriteStr( BonusX, BonusY, 'Bonus  : '+S );
End;

Procedure WriteFiles( Level: String; LevelNum: Byte );
Const
  NoneStr = 'NO NAME            ';
Var
  S: String[3];
Begin
  Back := Internal;
  Color:= FilesColor;

  If Level<>''
     Then WriteStr( FileNameX, FileNameY, Level )
     Else WriteStr( FileNameX, FileNameY, NoneStr );
  Str( LevelNum:3, S );
  WriteStr( LevelNumX, LevelNumY, 'Level #: '+S );
End;

Procedure DrawMarker( WhereX, WhereY: Integer; Color: Byte );
Var
  xx,yy: Integer;
Begin
  PutPixel( WhereX*(PicX+1)+AddX      -1, WhereY*(PicY+1)+AddY      -1, Color );
  PutPixel( WhereX*(PicX+1)+AddX+SizeX+1, WhereY*(PicY+1)+AddY      -1, Color );
  PutPixel( WhereX*(PicX+1)+AddX      -1, WhereY*(PicY+1)+AddY+SizeY+1, Color );
  PutPixel( WhereX*(PicX+1)+AddX+SizeX+1, WhereY*(PicY+1)+AddY+SizeY+1, Color );
End;

Procedure DrawCursor( WhereX,WhereY: Integer );
Begin
  If (Timer div 4) mod 2 <> 0
    Then DrawMarker( WhereX, WhereY, MarkerColor )
    Else DrawMarker( WhereX, WhereY, Black       )
End;

Procedure MarkPicture( n: Byte; Active: Boolean );
Var
  c: Byte;
Begin
  If Not Active Then c:= Internal Else c:= MarkPictureColor;

  Box( StuffX+n*(PicX+2)-1, StuffY-1, StuffX+n*(PicX+2)+PicX+1, StuffY+PicY, c );
  DrawPic( StuffX+n*(PicX+2), StuffY, GetPic(n)^ );

  Color:= TheTextColor;
  Back := Internal;
  If Active Then WriteStr( StuffTextX, StuffTextY, Texts[n] );
End;

(* Execution procedures     *)
Procedure RunProgram;
Var
  MustQuit  : Boolean;
  Code      : TKBCode;
  MonsHome,
  PackHome,
  Cursor    : TPoint;
  DrawMode,
  UserMode  : Boolean;
  CurLevel  : Byte;
  Active    : Integer;
  LevelName : String[20];
  Tmp       : TLevelBuf;

Procedure Redraw;
Begin
  InitScreen;
  DrawLevel( Levels[CurLevel], Usermode );
  ShowParams( UserMode, DrawMode );
  With Levels[CurLevel] do WriteMouns( M1, M2, M3, Bonus_Chanse );
  With Cursor do  ShowSlot( Levels[CurLevel].Buffer[x-1,y-1], x, y, UserMode );
  WriteFiles( LevelName, CurLevel );
  MarkPicture( Active, True  );
End;

Procedure SaveLevel;
Var
  F: File;
Begin
  If LevelName = '' Then Exit;
  Assign( F, LevelName );
  ReWrite( F, 1 );
  BlockWrite( F, Signature, 41 );
  BlockWrite( F, Levels, SizeOf(Levels) );
  Close( F );
End;

Procedure SaveBuffer;
Var
  F: File;
Begin
  If LevelName = '' Then Exit;
  Assign( F, LevelName );
  ReWrite( F, 1 );
  BlockWrite( F, Levels[CurLevel].Buffer, SizeOf(Levels[CurLevel].Buffer) );
  Close( F );
End;

Procedure LoadLevel;
Var
  F: File;
  S: array[0..40] of char;
Begin
  If (LevelName = '') or Not FileExist(LevelName) Then Exit;
  Assign(F, LevelName);
  Reset( F, 1 );
  If FileSize(F) = SizeOf(TLevelBuf)
    Then BlockRead( F, Levels[CurLevel].Buffer, SizeOf(TLevelBuf) )
    Else Begin
           BlockRead( F, S, 41 );
           If S = Signature
             Then BlockRead( F, Levels, SizeOf(Levels) );
         End;
  Close( F );
  DrawLevel( Levels[CurLevel], UserMode );
  ShowParams( Usermode, DrawMode );
  With Cursor Do ShowSlot( Levels[CurLevel].Buffer[x-1,y-1], x, y, UserMode );
  With Levels[CurLevel] do WriteMouns( M1, M2, M3, Bonus_Chanse );
End;

Procedure ChangeUserMode;
Begin
  UserMode:= Not UserMode;
  DrawLevel( Levels[CurLevel], UserMode );
  ShowParams( Usermode, DrawMode );
  With Cursor Do ShowSlot( Levels[CurLevel].Buffer[x-1,y-1], x, y, UserMode );
End;

Procedure ChangeDrawMode;
Begin
  DrawMode:= Not DrawMode;
  ShowParams( Usermode, DrawMode );
End;

Procedure View;
Var
  x,y: Byte;
  P: TPalette;
Begin
  FillPal( P, 0,0,0 );
  WaitRetrace;
  SetMCGA;
  SetAllPals( P );
  Utils.PutPixel:= MPutPixel;
  Background:= BigPicture[0];
  For y:= 0 to MaxY-1 do
    For x:= 0 to MaxX-1 do
      DrawPic( x*PicX, y*PicY, GetPic(Levels[CurLevel].Buffer[x,y])^ );
  SetAllPals( Palette );
  Ascii;

  Utils.PutPixel:= XtndMode.PutPixel;
  Background:= nil;
  WaitRetrace;
  InitXtended;
  Redraw;
End;

Procedure Test;
Var
  TheLevel: TLevel;
  b: TLevelBuf;
  p: TPalette;
  i: Integer;
Begin
  SetMCGA;
  FillPal( P, 0,0,0 );
  SetAllPals( P );
  {$IFNDEF NO_SOUNDS}
  PlaySongMemory( Songs[0].TheSong );
  {$ENDIF}
  Utils.PutPixel:= MPutPixel;
  BackGround:= BigPicture[0];
  InitKeys;

  b:= Levels[CurLevel].Buffer;
  TheLevel.Init( 10 );
  TheLevel.Buffer:= @Levels[CurLevel].Buffer;
  TheLevel.Find_Homes;
  TheLevel.DrawLevel;

  TheLevel.InsertCharacter( New( PPlayer, Init( @TheLevel )), True );
  If Levels[CurLevel].M1<>0 Then
    For i:= 1 to Levels[CurLevel].M1 do
      TheLevel.InsertCharacter( New( PMounster, Init( @TheLevel )), False );
  If Levels[CurLevel].M2<>0 Then
    For i:= 1 to Levels[CurLevel].M2 do
      TheLevel.InsertCharacter( New( PChase_Mounster, Init( @TheLevel )), False );
  If Levels[CurLevel].M3<>0 Then
    For i:= 1 to Levels[CurLevel].M3 do
      TheLevel.InsertCharacter( New( PHunt_Mounster, Init( @TheLevel )), False );

  SetAllPals( Palette );
  TheLevel.Execute;
  TheLevel.Done;
  BackGround:= nil;
  DoneKeys;
  Levels[CurLevel].Buffer:= b;

  Utils.PutPixel:= XtndMode.PutPixel;

  {$IFNDEF NO_SOUNDS}
    FadeSong;
    Step_Fade( p, 0, 255, 1 );
    StopSong;
  {$ELSE}
    Step_Fade( p, 0, 255, 1 );
  {$ENDIF}

  InitXtended;
  Redraw;
End;

Procedure FillLevel;
Begin
  FillChar( Levels[CurLevel].Buffer, SizeOf(Levels[CurLevel].Buffer), Active );
  DrawLevel( Levels[CurLevel], UserMode );
End;

Procedure SelectLeft;
Begin
  MarkPicture( Active, False );
  Inc( Active );
  DecByRange( Active, 1, 10 );
  Dec( Active );
  MarkPicture( Active, True  );
End;

Procedure SelectRight;
Begin
  MarkPicture( Active, False );
  Inc( Active );
  IncByRange( Active, 1, 10 );
  Dec( Active );
  MarkPicture( Active, True  );
End;

Procedure SelectCurrent;
Begin
  MarkPicture( Active, False );
  With Cursor do
    Active:= Levels[CurLevel].Buffer[x-1,y-1];
  MarkPicture( Active, True  );
End;

Procedure SetMap;
Begin
  With Cursor do
    Begin
      Levels[CurLevel].Buffer[x-1,y-1]:= Active;
      If UserMode
        Then DrawPic ( x*(PicX+1)+LevelX1-1, y*(PicY+1)+LevelY1-1, GetPic(Levels[CurLevel].Buffer[x-1,y-1])^ )
        Else DrawPic2( x*(PicX+1)+LevelX1-1, y*(PicY+1)+LevelY1-1, Levels[CurLevel].Buffer[x-1,y-1] )
    End;
End;

Procedure ReadM1Num;
Var
  S: String[3];
  i: Integer;
Begin
  With Cursor do
    DrawMarker( X-1, Y-1, Black );
  Str( Levels[CurLevel].M1, S );
  Back:= Internal;
  ReadStr( ReadStrX, ReadStrY, S, 3 );
  Box( ReadStrX, ReadStrY, ReadStrX + 8*20, ReadStrY+16, Internal );
  Val( S, Levels[CurLevel].M1, i );
  With Levels[CurLevel] do
    WriteMouns( M1, M2, M3, Bonus_Chanse );
End;

Procedure ReadM2Num;
Var
  S: String[3];
  i: Integer;
Begin
  With Cursor do
    DrawMarker( X-1, Y-1, Black );
  Str( Levels[CurLevel].M2, S );
  Back:= Internal;
  ReadStr( ReadStrX, ReadStrY, S, 3 );
  Box( ReadStrX, ReadStrY, ReadStrX + 8*20, ReadStrY+16, Internal );
  Val( S, Levels[CurLevel].M2, i );
  With Levels[CurLevel] do
    WriteMouns( M1, M2, M3, Bonus_Chanse );
End;

Procedure ReadM3Num;
Var
  S: String[3];
  i: Integer;
Begin
  With Cursor do
    DrawMarker( X-1, Y-1, Black );
  Str( Levels[CurLevel].M3, S );
  Back:= Internal;
  ReadStr( ReadStrX, ReadStrY, S, 3 );
  Box( ReadStrX, ReadStrY, ReadStrX + 8*20, ReadStrY+16, Internal );
  Val( S, Levels[CurLevel].M3, i );
  With Levels[CurLevel] do
    WriteMouns( M1, M2, M3, Bonus_Chanse );
End;

Procedure ReadLevelName;
Var
  S: String[3];
  i: Integer;
Begin
  With Cursor do
    DrawMarker( X-1, Y-1, Black );
  Back:= Internal;
  ReadStr( ReadStrX, ReadStrY, LevelName, 20 );
  Box( ReadStrX, ReadStrY, ReadStrX + 8*20, ReadStrY+16, Internal );
  WriteFiles( LevelName, CurLevel );
End;

Procedure SetLevel( NewLevel: Byte );
Begin
  If Not (NewLevel<MaxLevel)
    and (NewLevel = CurLevel) Then Exit;

  CurLevel:= NewLevel;
  WriteFiles( LevelName, CurLevel );
  ShowParams( Usermode, DrawMode );
  With Cursor Do ShowSlot( Levels[CurLevel].Buffer[x-1,y-1], x, y, UserMode );
  With Levels[CurLevel] do WriteMouns( M1, M2, M3, Bonus_Chanse );
  DrawLevel( Levels[CurLevel], UserMode );
End;

Procedure IncLevel;
Var
  Tmp: Integer;
Begin
  Tmp:= CurLevel+1;
  IncByRange( Tmp, 1, 10 );
  SetLevel( Tmp - 1 );
End;

Procedure DecLevel;
Var
  Tmp: Integer;
Begin
  Tmp:= CurLevel+1;
  DecByRange( Tmp, 1, 10 );
  SetLevel( Tmp - 1 );
End;

Begin
  FillChar( Levels, SizeOf(Levels), 0 );

  LongInt(Cursor)  := $00010001;
  LongInt(MonsHome):= $FFFFFFFF;
  LongInt(PackHome):= $FFFFFFFF;
  DrawMode         := False;
  UserMode         := False;
  Active           := 0;
  CurLevel         := 0;
  LevelName        := '';
  Tmp              := Levels[CurLevel].Buffer;
  Redraw;

  Repeat

    If KeyDown
      Then Word(Code):= GetKBCode
      Else Word(Code):= 0;

    Case Code.KeyCode of
      kbNoKey: DrawCursor( Cursor.X-1, Cursor.Y-1 );
      kbGrayMinus: DecLevel;
      kbGrayPlus : IncLevel;
      kbShiftTab:ChangeUserMode;
      kbF2   : SaveLevel;
      kbF3   : LoadLevel;
      kbF4   : ReadLevelName;
      kbF5   : ReadM1Num;
      kbF6   : ReadM2Num;
      kbF7   : ReadM3Num;
      kbF8   : SaveBuffer;
      kbF9   : Tmp:= Levels[CurLevel].Buffer;
      kbF10  : Begin
                 Levels[CurLevel].Buffer:= Tmp;
                 With Cursor Do ShowSlot( Levels[CurLevel].Buffer[x-1,y-1], x, y, UserMode );
                 With Levels[CurLevel] do WriteMouns( M1, M2, M3, Bonus_Chanse );
                 DrawLevel( Levels[CurLevel], UserMode );
               End;
      kbIns  : ChangeDrawMode;
      kbDel  : FillLevel;
      kbTab  : SelectCurrent;
      kbAltV : View;
      kbAltT : Test;
      kbAltR : Begin initXtended; Redraw End;
      kbEnter: SetMap;
      kbUp   : With Cursor do Begin
                 DrawMarker( X-1, Y-1, Black );
                 DecByRange( Y, 1, MaxY );
                 ShowSlot( Levels[CurLevel].Buffer[x-1,y-1], x, y, UserMode );
                 ShowParams( UserMode, DrawMode );
                 If DrawMode Then SetMap;
               End;
      kbDown : With Cursor do Begin
                 DrawMarker( Cursor.X-1, Cursor.Y-1, Black );
                 IncByRange( Cursor.Y, 1, MaxY );
                 ShowSlot( Levels[CurLevel].Buffer[x-1,y-1], x, y, UserMode );
                 ShowParams( UserMode, DrawMode );
                 If DrawMode Then SetMap;
               End;
      kbRight: With Cursor do Begin
                 DrawMarker( Cursor.X-1, Cursor.Y-1, Black );
                 IncByRange( Cursor.X, 1, MaxX );
                 ShowSlot( Levels[CurLevel].Buffer[x-1,y-1], x, y, UserMode );
                 ShowParams( UserMode, DrawMode );
                 If DrawMode Then SetMap;
               End;
      kbLeft : With Cursor do Begin
                 DrawMarker( Cursor.X-1, Cursor.Y-1, Black );
                 DecByRange( Cursor.X, 1, MaxX );
                 ShowSlot( Levels[CurLevel].Buffer[x-1,y-1], x, y, UserMode );
                 ShowParams( UserMode, DrawMode );
                 If DrawMode Then SetMap;
               End;
      kbAlt0  : SetLevel( 0 );
      kbAlt1  : SetLevel( 1 );
      kbAlt2  : SetLevel( 2 );
      kbAlt3  : SetLevel( 3 );
      kbAlt4  : SetLevel( 4 );
      kbAlt5  : SetLevel( 5 );
      kbAlt6  : SetLevel( 6 );
      kbAlt7  : SetLevel( 7 );
      kbAlt8  : SetLevel( 8 );
      kbAlt9  : SetLevel( 9 );
      Else Case Code.Ascii of
             ^M         : ChangeUserMode;
             ^V         : ChangeDrawMode;
             ','        : SelectLeft;
             '.'        : SelectRight;
             ^T, 'T','t': Test;
             'V','v'    : View;
             #32        : SetMap;
             '0'..'9'   : Begin
                            MarkPicture( Active, False );
                            Active:= Ord(Code.Ascii) - Ord('0');
                            MarkPicture( Active, True );
                          End;
           End;
    End; { Case Code.KeyCode }
  Until Code.KeyCode = kbAltX;
End;

(* Exit procedures          *)
Procedure DoneAll;
Begin
  Dispose( Font );
  WaitRetrace;
  SetText;
End;

Begin
  InitAll;
  InitXtended;
  RunProgram;
  DoneAll;
End.
