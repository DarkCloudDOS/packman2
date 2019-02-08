
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

Unit PackMan4;

Interface

Uses PackMan1, PackMan2;

Type
(* TMounster : a stupid mounster that moves arround     *)
(*             in the level and does nothing, just dies *)
  PMounster = ^TMounster;
  TMounster = Object(TCharacter)
    Constructor Init( ALevel: PLevel );
    Function  GetPicture( ADirection, AFrame: Byte ): PPicture; Virtual;
    Procedure UpDate; Virtual;
    Procedure HandleDirection; Virtual;
    Procedure SetState( AState: Byte; Enable: Boolean ); Virtual;
    Procedure NewSpeed( Restore: Boolean ); Virtual;
    Procedure Go_Home; Virtual;

    Procedure MoveArround;
    Procedure Go_To( Var Path: TLevelBuf );
  End;

(* TChase_Mousnter : A mounster that gets closer to the player  *)
(*                   when it is close enough, otherwise acts    *)
(*                   like TMounster                             *)
  PChase_Mounster = ^TChase_Mounster;
  TChase_Mounster = Object(TMounster)
    Procedure HandleDirection; Virtual;
    Procedure NewSpeed( Restore: Boolean ); Virtual;
    Function  ClosestDirection: Byte;
    Function  FarestDirection: Byte;
  End;

(* THunt_Mounster : A smart mounster that find the way to the   *)
(*                  player and hunts it                         *)
  PHunt_Mounster = ^THunt_Mounster;
  THunt_Mounster = Object(TChase_Mounster)
    Procedure HandleDirection; Virtual;
  End;

Implementation


(* TMounster *)
Constructor TMounster.Init( ALevel: PLevel );
Begin
  TCharacter.Init( ALevel );
  Location      := TheLevel^.Mounsters_Home;
  Direction     := drUp;
  Speed.Frames  := Speed.Frames*3;
  Speed.Movement:= Speed.Movement+3;
  OKPlaces      := [opClear, opFood, opCracker, opMonsWall,
                    opBothWall, opPackManHome, opMounstersHome];

  If Random(30)>15
    Then Speed.Movement:= Speed.Movement + Random(3)
    Else Speed.Movement:= Speed.Movement - Random(3);
  If Random(30)<15
    Then Speed.Frames:= Speed.Frames + Random(3)
    Else Speed.Frames:= Speed.Frames - Random(3);
End;

Function TMounster.GetPicture( ADirection, AFrame: Byte ): PPicture;
Begin
 If GetState(sfDead)
   Then GetPicture:= @(Pictures[AFrame+23])
   Else GetPicture:= @(Pictures[AFrame])
End;

Procedure TMounster.UpDate;
Begin
  If (TheLevel^.Player<>nil) and Not GetState(sfDead) and
     (LongInt(TheLevel^.Player^.Location) = LongInt(Location)) then
      If TheLevel^.Player^.GetState( sfStrong )
        Then SetState( sfDead, True )
        Else TheLevel^.Player^.SetState( sfDead, True );

  TCharacter.UpDate;
End;

Procedure TMounster.HandleDirection;
Begin
  If GetState(sfDead)
    Then Go_to( MonsHomePath )
    Else MoveArround;
End;

Procedure TMounster.SetState( AState: Byte; Enable: Boolean );
Begin
  If (AState = sfDead) and Not GetState(sfDead) and Enable
    Then TheLevel^.Player^.SetState( sfEatMons, True );

  If (AState = sfDead) and Not Enable and
     (TheLevel^.Player^.State and sfStrong<>0)
     Then Exit;
  TCharacter.SetState( AState, Enable );
End;

Procedure TMounster.NewSpeed( Restore: Boolean );
Begin
  If Restore
    Then Dec( Speed.Movement, 2 )
    Else Inc( Speed.Movement, 2 )
End;

Procedure TMounster.Go_Home;
Begin
  LongInt(Virtual):= $00000000;
  Location        := TheLevel^.Mounsters_Home;
  Direction       := drUp;
  Draw;
End;

Procedure TMounster.MoveArround;
Const
  DirTable : array [1..4] of Byte = ( drDown, drUp, drRight, drLeft );
Begin
  If Not CanMove(Direction) and MovementDone Then
    While Not CanMove(Direction) do
      Direction:= DirTable[Random(4)+1];

  If MovementDone and (Random(300)<150) Then
    While Not CanMove(Direction) do
      Direction:= DirTable[Random(4)+1];

  If MovementDone Then
    Case Direction of
      drUp, drDown:
        If CanMove(drLeft)  and (Random(500)<15) Then Direction:= drLeft Else
        If CanMove(drRight) and (Random(500)<15) Then Direction:= drRight;
      drLeft, drRight:
        If CanMove(drUp)   and (Random(500)<15) Then Direction:= drUp Else
        If CanMove(drDown) and (Random(500)<15) Then Direction:= drDown;
     End;
End;

Procedure TMounster.Go_to( Var Path: TLevelBuf );
Var
  CurrPlace : Byte;
Begin
  CurrpLace:= Path[Location.X,Location.Y];
  If CurrPlace = 1
    Then {If (TheLevel^.Player^.State and sfStrong<>0)
           Then} Begin SetState( sfDead, False ) End
    Else Begin
           If Path[Location.X+1,Location.Y]<CurrPlace Then Direction:= drRight Else
           If Path[Location.X-1,Location.Y]<CurrPlace Then Direction:= drLeft  Else
           If Path[Location.X,Location.Y-1]<CurrPlace Then Direction:= drUp    Else
           If Path[Location.X,Location.Y+1]<CurrPlace Then Direction:= drDown {Else
             SetState( sfDead, False )}
         End
End;


(* TChase_Mousnter *)
Procedure TChase_Mounster.HandleDirection;
Var
  NewDirection: Byte;
Begin
  If TheLevel^.Player^.GetState(sfStrong)
    Then Begin
           NewDirection:= FarestDirection;
           If (NewDirection <> drNoDirection) and Not GetState(sfDead)
             Then Direction:= NewDirection
             Else TMounster.HandleDirection;
         End
    Else Begin
           NewDirection:= ClosestDirection;
           If (NewDirection <> drNoDirection) and Not GetState(sfDead)
             Then Direction:= NewDirection
             Else TMounster.HandleDirection;
         End;
End;

Procedure TChase_Mounster.NewSpeed( Restore: Boolean );
Begin
  If Restore
    Then Dec( Speed.Movement, 4 )
    Else Inc( Speed.Movement, 4 )
End;


Function TChase_Mounster.ClosestDirection: Byte;
Var
  DX, DY  : Integer;
  dr1,dr2 : Byte;
Begin
  Dr1:= $FF;
  Dr2:= $FF;

  If TheLevel^.Player<>nil
    Then Begin
           DX:= Location.X - TheLevel^.Player^.Location.X;
           DY:= Location.Y - TheLevel^.Player^.Location.Y;
         End
    Else Begin
           DX:= 0;
           DY:= 0;
         End;

  If DX>0
    Then Dr1:= drLeft
    Else Dr1:= drRight;
  If DY>0
    Then Dr2:= drUp
    Else Dr2:= drDown;

  If (Abs(DY)<7) and (Abs(DX)<13)
    Then If CanMove(Dr1) and (Abs(DX)>Abs(DY))
           Then ClosestDirection:= Dr1
           Else If CanMove(Dr2)
                  Then ClosestDirection:= Dr2
                  Else ClosestDirection:= drNoDirection
    Else ClosestDirection:= drNoDirection;
End;

Function TChase_Mounster.FarestDirection: Byte;
Var
  DX, DY  : Integer;
  dr1,dr2 : Byte;
Begin
  Dr1:= $FF;
  Dr2:= $FF;

  If TheLevel^.Player<>nil
    Then Begin
           DX:= Location.X - TheLevel^.Player^.Location.X;
           DY:= Location.Y - TheLevel^.Player^.Location.Y;
         End
    Else Begin
           DX:= 0;
           DY:= 0;
         End;

  If DX>0
    Then Dr1:= drRight
    Else Dr1:= drLeft;
  If DY>0
    Then Dr2:= drDown
    Else Dr2:= drUp;

  If (Abs(DY)<7) and (Abs(DX)<13)
    Then If CanMove(Dr1) and (Abs(DX)>Abs(DY))
           Then FarestDirection:= Dr1
           Else If CanMove(Dr2)
                  Then FarestDirection:= Dr2
                  Else FarestDirection:= drNoDirection
    Else FarestDirection:= drNoDirection;
End;

(*  THunt_Mounster  *)
Procedure THunt_Mounster.HandleDirection;
Begin
  If GetState(sfDead)
    Then TChase_Mounster.HandleDirection
    Else Go_to( PackManPath ) { Find Pack-man instead of home }
End;

End.
