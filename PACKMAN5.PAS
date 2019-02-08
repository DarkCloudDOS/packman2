
(* ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออป   *)
(* บ                                                        บÛ  *)
(* บ     Borland Pascal Version 7.0                         บÛ  *)
(* บ     Pack Man 2 - The Revenge. Source.                  บÛ  *)
(* บ                                                        บÛ  *)
(* วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถÛ  *)
(* บ                                                        บÛ  *)
(* บ     Copyright (C) 1996,7 Diego Iastrubni               บÛ  *)
(* บ                                                        บÛ  *)
(* ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออผÛ  *)
(*  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿  *)

Unit PackMan5;

Interface

Uses PackMan1, PackMan2, PackMan3, PackMan4;

Const

(* How much times in a seconds cycle palette *)
  PalEffectFreq =   60;  { once in every 60 m-Sec            }

  FadeBonusTime = 7000;  { How much timeon screen 7000 m-Sec }
  Fade_Time     = 15000;  { Time of darkness 2500 m-Sec       }

Type
  PLevelRec   = ^TLevelRec;
  PLevelarray = ^TLevelArray;
  PPMLevel    = ^TPMLevel;


  TLevelRec = Record
    Buffer       : TLevelBuf;
    M1           : Byte;
    M2           : Byte;
    M3           : Byte;
    Bonus_Chanse : Byte;
  End;

  TLevelArray = array[0..MaxLevel-1] of TLevelRec;

  TPMLevel = Object(TLevel)
    Constructor Init( LevelNumber: Byte );
    Procedure NewBonus; Virtual;
  End;

(* Bonuses *)
  PFadeBonus = ^TFadeBonus;
  TFadeBonus = Object(TBonus)
    FadeScreen: Boolean;
    MySpot    : ^Byte;
    Constructor Init( ALevel: PLevel );
    Destructor Done; Virtual;
    Procedure UpDate; Virtual;
    Procedure CheckUser;
  End;

(* Effects *)
  PPaletteEffect = ^TEffectPalette;
  TEffectPalette = Object(TEffect)
    Constructor Init( ALevel: PLevel );
    Destructor Done; Virtual;
    Procedure UpDate; Virtual;
  End;

(* Levels loading for using with TPMLevel *)
Function LoadLevel( Name: String ): Boolean;


Var
  Levels       : TLevelArray;  { The levels loaded by LoadLevel }
  FirstWorld   : Boolean;

Implementation

{$IFNDEF NO_SOUNDS}
Uses Utils, SB, ADVHsc;
{$ELSE}
Uses Utils;
{$ENDIF}


Var
  SavePalette  : TPalette;     { Used internbaly by TEffectPal  }
  PaletteUsed  : Boolean;      {}

(* TPMLevel *)
Constructor TPMLevel.Init( LevelNumber: Byte );
Var
  i: Integer;
Begin
  TLevel.Init( MaxMons );
  Buffer:= @Levels[LevelNumber].Buffer;
  Find_Homes;

  If Levels[LevelNumber].M1<>0 Then
    For i:= 1 to Levels[LevelNumber].M1 do
      InsertCharacter( New( PMounster, Init( @Self)), False );

  If Levels[LevelNumber].M2<>0 Then
    For i:= 1 to Levels[LevelNumber].M2 do
      InsertCharacter( New( PChase_Mounster, Init( @Self)), False );

  If Levels[LevelNumber].M3<>0 Then
    For i:= 1 to Levels[LevelNumber].M3 do
      InsertCharacter( New( PHunt_Mounster, Init( @Self)), False );

  InsertCharacter( New( PPlayer, Init( @Self)), True );
End;

Procedure TPMLevel.NewBonus;
Begin
  Case Random(10) of
    0: SetBonus( New( PFadeBonus, Init(@Self)));
    1:;
    2:;
    3:;
    4:;
  End;
End;

   (* Effects *)

(* TFadeBonus *)
Constructor TFadeBonus.Init( ALevel: PLevel );
Begin
  TBonus.Init( ALevel^.Pack_Man_Home, ALevel );
  Time:= FadeBonusTime;
  With Location do
    Begin
      TheLevel^.Buffer^[x,y]:= opFadeBonus;
      MySpot:= @TheLevel^.Buffer^[x,y];
      DrawBonus;
   End;
End;

Destructor TFadeBonus.Done;
Begin
  If FadeScreen and PaletteUsed Then
    Begin
      SetAllPals( SavePalette );
      Palette:= SavePalette;
      PaletteUsed:= False;
    End;
  TBonus.Done;
End;

Procedure TFadeBonus.UpDate;
Begin
  If FadeScreen
    Then Begin
           Dec( Time );
           If Time = 0 Then TheLevel^.DoneBonus;
         End
    Else CheckUser;
End;

Procedure TFadeBonus.CheckUser;
Var
  i: Integer;
Begin
  TBonus.UpDate;
  If MySpot^ = opClear
     Then Begin
            If Not PaletteUsed Then
              Begin
                SavePalette:= Palette;
                PaletteUsed:= True;
              End;

            Time:= Fade_Time;
            For i:= 0 to 255 do
              Begin
                  { Make gray palette: New Color = R+G+B/3 }
                Palette[i,0]:= (Palette[i,0]+Palette[i,1]+Palette[i,2]) div 3;
                Palette[i,1]:= Palette[i,0];
                Palette[i,2]:= Palette[i,0];
              End;
            SetAllPals( Palette );
            FadeScreen:= True;
          End;
End;

   (* Bonuses *)

(* TEffectPalette *)
Constructor TEffectPalette.Init( ALevel: PLevel );
Begin
  TEffect.Init( ALevel );
  If Not PaletteUsed
    Then Begin
           SavePalette:= Palette;
           PaletteUsed:= True;
         End
End;

Destructor TEffectPalette.Done;
Begin
  Palette:= SavePalette;
  SetAllPals( Palette );
  TEffect.Done;
End;

Procedure TEffectPalette.UpDate;
Begin
  Inc( Time );
  If Time = PalEffectFreq Then Begin
    Time:= 0;
    If FirstWorld
      Then Begin
             CyclePal( 21, 31, True );
             CyclePal( (32*5), (32*5)+5, False );
             CyclePal( (32*6), (32*6)+15, False );
           End
      Else Begin
             CyclePal( 26, 31, True );
             CyclePal( 144, 159, False );
             CyclePal( (32*6), (32*6)+15, False );
           End
  End;
End;

(* Level loading *)
Function LoadLevel( Name: String ): Boolean;
Var
  F: File;
  S: array[0..40] of char;
Begin
  If (Name = '') or Not FileExist(Name) Then Exit;
  Assign(F, Name);
  Reset( F, 1 );
  BlockRead( F, S, 41 );
  If S = Signature
     Then Begin
            BlockRead( F, Levels, SizeOf(Levels) );
            LoadLevel:= IOResult = 0 ;
          End
     Else LoadLevel:= False;
  Close( F );
End;

End.
