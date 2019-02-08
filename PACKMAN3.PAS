
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

Unit PackMan3;

Interface

Uses PackMan1, PackMan2;

Const
{ The Time for the hunt music to play }
  CrackerTime =  9000;  {  9000 m-Sec }

{ How much time before the music stops to fade it }
  SongTime    =  2000;  {  2000 m-Sec }

{ How much time to add when you eat a mounster    }
  EatMonsTime =   500;  {   500 m-Sec }

Type
  PPlayer = ^TPlayer;
  TPLayer = Object(TCharacter)
    Time: Word;
    Constructor Init( ALevel: PLevel );
    Function GetPicture( ADirection, AFrame: Byte ): PPicture; Virtual;
    Procedure UpDate; Virtual;
    Procedure HandleDirection; Virtual;
    Procedure SetState( AState: Byte; Enable: Boolean ); Virtual;
    Procedure NewSpeed( Restore: Boolean ); Virtual;
    Procedure Go_Home; Virtual;
  End;

Implementation

{$IFNDEF NO_SOUNDS}
Uses Utils, PackMan5, SB, ADVHSC;
{$ELSE}
Uses Utils, PackMan5;
{$ENDIF}

Const
  Not_80 = Not $80;

(* TPlayer *)
Constructor TPlayer.Init( ALevel: PLevel );
Begin
  TCharacter.Init( ALevel );
  OKPlaces:= [opClear, opFood, opCracker, opPackWall,
              opBothWall, opPackManHome,
              opFadeBonus ];
  Location:= TheLevel^.Pack_Man_Home;
End;

Function TPlayer.GetPicture( ADirection, AFrame: Byte ): PPicture;
Begin
  GetPicture:= @(Pictures[ADirection shl 2 + AFrame])
End;

Procedure TPlayer.UpDate;
Begin
  If Time<>0
    Then Begin
           Dec( Time );
           If Time = 0 Then SetState(sfStrong, False );
         End;
{$IFNDEF NO_SOUNDS}
  If Time = SongTime Then FadeSong;
{$ENDIF}
  TCharacter.UpDate;
End;

Procedure TPlayer.HandleDirection;
Var
  NewDirection: Byte;
Begin
  Case Port[$60] and Not_80 of
    drUp,   drUp_    : NewDirection:= drUp;
    drDown, drDown_  : NewDirection:= drDown;
    drLeft, drLeft_  : NewDirection:= drLeft;
    drRight,drRight_ : NewDirection:= drRight;
    drNoDirection    : NewDirection:= drNoDirection;
    Else NewDirection:= $FF;
  End;

  If CanMove(NewDirection) Then Direction:= NewDirection;

  Case Buffer^[Location.X,Location.Y] of
    opFood   : Begin
                 Dec( TheLevel^.FoodCount );
                 Buffer^[Location.X,Location.Y]:= 0
               End;
    opCracker: Begin
                 {$IFNDEF NO_SOUNDS}
                 If UsingSB Then PlayWave( Waves^[1] );
                 {$ENDIF}
                 Dec( TheLevel^.FoodCount );
                 Buffer^[Location.X,Location.Y]:= opClear;
                 SetState( sfStrong, True );
               End;
    {$IFNDEF NO_SOUNDS}
    opPackWall,
    opBothWall: If UsingSB Then PlayWave( Waves^[2] );
    {$ENDIF}
    opFadeBonus: Buffer^[Location.X,Location.Y]:= opClear;
  End;
End;

Procedure TPlayer.SetState( AState: Byte; Enable: Boolean );
Begin
{$IFNDEF NO_SOUNDS}
  If (AState = sfDead) and Enable and UsingSB Then
    PlayWave( Waves^[0] );

  If (AState = sfStrong) Then
    If Enable
      Then Begin
             If State and sfStrong = 0 Then TheLevel^.ChangeSpeeds;
             TheLevel^.SetEffect( New( PPaletteEffect, Init(TheLevel)));
             Time:= CrackerTime;
             If UsingSB Then PlaySongMemory( Songs[snStrongSong].TheSong )
           End
      Else Begin
             If State and sfStrong <> 0 Then TheLevel^.RestoreSpeeds;
             If UsingSB Then PlaySongMemory( Songs[Random(2)].TheSong );
             TheLevel^.DoneEffect;
           End;
{$ELSE}
  If (AState = sfStrong) Then
    If Enable
      Then Begin
             Time:= CrackerTime;
             If State and sfStrong = 0 Then TheLevel^.ChangeSpeeds;
             TheLevel^.SetEffect( New( PPaletteEffect, Init(TheLevel)));
           End
      Else If State and sfStrong <> 0 Then TheLevel^.RestoreSpeeds;
{$ENDIF}

  TCharacter.SetState( AState, Enable );
  If (AState = sfEatMons) and Enable and (Time>SongTime) Then
    Begin
      Inc( Time, EatMonsTime );
      SetState( sfEatMons, False );
    End;
End;

Procedure TPlayer.NewSpeed( Restore: Boolean );
Begin
  If Restore
    Then Begin Inc(Speed.Movement); End
    Else Begin Dec(Speed.Movement); End
End;

Procedure TPlayer.Go_Home;
Begin
  SetState( sfDead, False );
  LongInt(Virtual):= $00000000;
  Location        := TheLevel^.Pack_Man_Home;
  Direction       := drNoDirection;
  Draw;
End;

End.
