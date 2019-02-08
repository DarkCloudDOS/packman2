
(* ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»   *)
(* º                                                        ºÛ  *)
(* º     Borland Pascal Version 7.0                         ºÛ  *)
(* º     Pack Man 2 - The Revenge. Source.                  ºÛ  *)
(* º                                                        ºÛ  *)
(* ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶Û  *)
(* º                                                        ºÛ  *)
(* º     Copyright (C) 1996,7 Diego Iastrubni               ºÛ  *)
(* º                                                        ºÛ  *)
(* ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼Û  *)
(*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  *)

{ ÛÛ   Û  ÛÛ  Û Û    ÛÛ Û  ŞÛİ Û Û ÛÛ  }
{ Û Û ÛÜÛ ÛÜÛ ÛÛ    Û   Û  Û Û Û Û Û Û }
{ ÛÛ  Û Û Û Û Û Û    ÛÛ ÛÛ ŞÛİ ÛÛÛ ÛÛ  }

Program Pack_Man_2__The_Revenge;


    (*                                                      *)
    (*  Bugs. . .                                           *)
    (*                                                      *)
    (*    If the computer boots up druning game (something  *)
    (*    with EMM386) see PACKMAN.DOC to fix the problem.  *)
    (*                                                      *)
    (*    Press Ctrl+F9 on youre own responsibilitie...     *)
    (*                                                      *)


{$IFDEF DPMI}
{$DEFINE NO_SOUNDS}
{$ENDIF}

{$A+,B-,D+,E+,G+,I+,L+,N+,O-,Q-,R-,S-,X+}
{$M 16384,0,655360}

{$IFNDEF NO_SOUNDS}
Uses Utils, Font8x8, SB, ADVHSC,
     PackMan1, PackMan2, PackMan3, PackMan4, PackMan5;
{$ELSE}
Uses Utils, Font8x8,
     PackMan1, PackMan2, PackMan3, PackMan4, PackMan5;
{$ENDIF}

Const
  Very_Easy_Level = 'PACKMAN.VEL';
  Level_Pic_Name  = 'SCREEN.CEL';
  Font_File       = 'PACKMAN.FNT';

  Minimum_Memory_Recomeded =
     (* External files     *)
    SizeOf(TBigPic)*3     +                { 3 big pictures      }
    10800 + 5000  + 8000  +                { 3 HSC files (music) }
    13300 + 34850 + 19500 +
     5800 + 15000 + 58000 +                { 6 waves (sounds)    }
     (* Internal variables *)
    40+SizeOf(TCharacter)*MaxMons;         { TWaves              }


Var
  BlackPal       : TPalette;        { Two virtual palette used            }
  LevelPal       : TPalette;        { by the game                         }
  LevelPic       : Pointer;         { The picture that u c between levels }
  PackManFont    : TFont;           { The font used by game               }
  S              : String;
  Level          : TPMLevel;
  Level_Finished : Boolean;
  LevelNumber    : Byte;
  i,j            : Word;

Procedure NewPauseProcedure; Far;
Var
  B: Boolean;
Begin
  DoneKeys;
  Repeat
    If b
      Then Fade( BlackPal, 0, 240, 0 )
      Else Fade( Palette , 0, 240, 0 );
    b:= not b;
  Until KeyDown;
  Ascii;
  InitKeys;
  SetAllPals(Palette);
End;

{ Text mode output }
Procedure WriteText( x, y: Word; S: String; Color: Byte );
Var
  n,j : Byte;
  SLen: Byte absolute s;
Begin
  n:= 0;
  If s<>'' Then
    For n:= 1 to SLen do
      CharXY( x+n-1, y, S[n], Color );
  For j:= n to 80-1-x do
    CharXY( x+j, y, ' ', Color );
End;

{ Graphics }
Procedure LoadCELPal( CelName: String; Var Palette: TPalette);
Var
  F : File;
Begin
  Assign( F, CelName );
  Reset( F, 1 );
  Seek( F, 32 );
  BlockRead( F, Palette, SizeOf(TPalette) );
  Close( F );
End;

Function GetColor( Color, Back: Byte ): Byte; Assembler;
Asm
	MOV	AL,	Color
	MOV	BL,	Back
	SHL	BL,	4
	OR 	AL,	BL
End;

Procedure Show_Level( Number: Byte; Player: PPlayer );
Var
  s: String[2];
  i: Byte;
Begin
  WaitRetrace;
  GCLS(0);
  SetAllPals( LevelPal );
  PutImage( 0, 0, LevelPic );
  Str(Number,S);
  WriteStr2( 100, 50, 'Level number '+s );

{  For i:= 0 to Player^.Lives do
     PutImage( 50+i*20, 100, Pics[4] )}

{$IFNDEF NO_SOUNDS}
  If UsingSB Then PlayWave( Waves^[5] );
{$ENDIF}
  Ascii;
  GCLS(0);
  SetAllPals(BlackPal);
End;


Procedure LoadNewWorld;
Begin
  SetAllPals( BlackPal );
  GCLS( 0 );
  Color:= 10;
  WriteStr( 100, 50, 'Loading World 2.' );
  Fade( Palette, 0, 255, 0 );
{$IFNDEF NO_SOUNDS}
  UnLoadHSC;
  UnLoadWaves;
{$ENDIF}
  UnLoadPictures;
  Load_World_2;
  FirstWorld:= False;
  WriteStr( 100, 80, 'Press any key. . . ' );
  Ascii;
  Fade( BlackPal, 0, 255, 0 );
End;

Begin
{ Fast way of clearing screen }
  WaitRetrace;
  SetText;
  TextCursor( $20, $20 );
  CursorXY( 0, 15 );
  WriteText(  0, 0, ' Pack Man 2 - The Revenge system operation.', GetColor(White,Blue)  );

  Randomize;
  FillPal( BlackPal, 0, 0, 0 );
  LoadFont( Font_File, PackManFont );
  Font          := @PackManFont;
  Utils.PutPixel:= MPutPixel;
  PauseProc     := NewPauseProcedure;

{$IFNDEF NO_SOUNDS}
  WriteText( 0, 4,'Sound card: ', $07);

{ Auto dectect sound card}
  UsingSB:= ResetDSP( bp220h );          { Try base port 220 }
  If UsingSB
    Then WriteText( 20, 4, 'Base port address 220h.', GetColor(White,Black) )
    Else Begin
	   UsingSB:= ResetDSP( bp240h ); { Try base port 240 }
	   If UsingSB
	      Then WriteText( 20, 4, 'Base port address 240h.', GetColor(White,Black) )
	      Else WriteText( 20, 4, 'Not found.', GetColor(LightGray,Black) )
	 End;
{$ENDIF}

  Str(MemAvail,S);
  WriteText(  0, 5, 'Memory aviable', GetColor(LightGray,Black) );
  WriteText( 20, 5, S+' bytes', GetColor(White,Black)  );
  WriteText(  0, 6, 'Loading graphics...', GetColor(LightGray,Black) );
  LoadCel(Level_Pic_Name,LevelPic);
  LoadCelPal( Level_Pic_Name, LevelPal );
  
    If MemAvail<Minimum_Memory_Recomeded Then
    Begin
      Str( Minimum_Memory_Recomeded, s );
      WriteText(0, 8,
      'Low memory warning!! There is not enough memory to load all the grapihcs!',
      GetColor(Red,Black+$8) );
      WriteText(0, 9, 'Minimum memory recomeded '+S, GetColor(Red,Black)  );
    End;

  For i:= 0 to 7 do
    For j:= 0 to 7 do
      FontMap[i,j]:= 0;

  If MaxAvail< SizeOf(TCharacter)*MaxMons+100 Then
    Begin
      FillScreen( #32, GetColor(lightGray,Black));
      TextCursor( 6, 7);
      CursorXY( 0, 2 );
      WriteText( 0, 0, 'Not enough memory. Aborting.',
        GetColor(lightGray,Black) );
      Wait( 1500 );
      Exit;
    End;

  Load_World_1;
  FirstWorld := True;
  LevelNumber:= 0;

  WriteText( 0, 10, 'If the computer gets stuck see PACKMAN.DOC for bugs.',
   GetColor(LightGray,Black+$8) );

  LoadLevel( Very_Easy_Level );
  WriteText( 0, 12, 'Press any key . . .', GetColor(LightGray,Black) );
  Ascii;

  SetMCGA;
  SetAllPals( BlackPal );

  Repeat
    If LevelNumber = 4 Then LoadNewWorld;
    Show_Level( LevelNumber+1, PPlayer(Level.Player) );
    Level.Init( LevelNumber );

    Background:= BigPicture[Random(2)];
{$IFNDEF NO_SOUNDS}
    If UsingSB Then Begin
      PlayWave( Waves^[3+Random(2)] );
      PlaySongMemory( Songs[Random(2)].TheSong );
    End;
{$ENDIF}
    Repeat
      InitKeys;
      Level.DrawLevel;
      Step_Fade( Palette, 0, 255, 14 );

      i:= Level.Execute;
{$IFNDEF NO_SOUNDS}
      If (i = LevelFinished) or (i = Break) Then FadeSong;
{$ENDIF}
      Step_Fade( BlackPal, 0, 255, 14 );
      GCLS( 0 );
      DoneKeys;
    Until (i = LevelFinished) or (i = Break);

    Inc( LevelNumber );
    Level.Done;
  Until (i = Break) or (LevelNumber = MaxLevel);

  Background:= nil;
{$IFNDEF NO_SOUNDS}
  StopSong;
{$ENDIF}

  SetText;
  WriteText( 0, 0, ''                                                 ,GetColor(White,Blue));
  WriteText( 0, 1, ' Pack Man 2 - The Revenge'                        ,GetColor(White,Blue));
  WriteText( 0, 2, 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'  ,GetColor(White,Blue));
  WriteText( 0, 3, ''                                                 ,GetColor(Yellow,Blue));
  WriteText( 0, 4, 'Shareware, totaly free. Programmed by DGI.'       ,GetColor(White,Blue));
  WriteText( 0, 5, 'Graphix made by Pablo Iastrubni.'                 ,GetColor(White,Blue));
  WriteText( 0, 6, 'Distrivuted by dark-cloud team on the internet:'  ,GetColor(White,Blue));
  WriteText( 0, 7, ''                                                 ,GetColor(Yellow,Blue));
  WriteText( 14,7, 'http://www.geocities.com/SiliconValley/Vista/1595',GetColor(Yellow,Blue));
  CursorXY( 0, 8 );
End.
