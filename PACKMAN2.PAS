
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

Unit PackMan2;

Interface

Uses Utils, PackMan1;

Const
  { Times for effect }
  Bonnus_Every     =  10000;    { 10000 m-Sec }
  Change_Time      =   2000;    {  2000 m-Sec }
  Find_Path_Freq   =   2500;    {  2500 m-Sec }

  { Keys scan code }
  scEsc    = 01;
  scF11    = 87;
  scF12    = 88;
  scP      = 25;

  { Maximum and minimum stuff }
  MaxFrame  = 4;           { Number of frames that a character has }
  MaxVirX   = PicX div 2;  { Maximum movment between a place       }
  MaxVirY   = PicY div 2;
  MaxCollectionSize = 65520 div SizeOf(Pointer);

  { Direction constants (can be used also as scan codes) }
  drNoDirection = 57;  { Stays in the sane place. Key : Space }
  drUp          = 72;  { Move up. Key : Cursor Up             }
  drDown        = 80;  { Move down. Key: Cursor Down          }
  drRight       = 77;  { Move right. Key : Cursor Right       }
  drLeft        = 75;  { Move left. Key : Cursor Left         }
  drUp_         = 17;  { Move up. Key : "W"                   }
  drDown_       = 45;  { Move down. Key: "X"                  }
  drRight_      = 32;  { Move right. Key : "D"                }
  drLeft_       = 30;  { Move left. Key : "A"                 }

  { Bits for TCharacters }
  sfShouldDraw = $01;  { Used internaly to draw character     }
  sfDead       = $02;  { If teh character is dead             }
  sfStrong     = $04;  { If is Strong (See PackMan2)          }
  sfMoved      = $08;  { If moved (for sound)                 }
  sfEatMons    = $10;  { That's how Mousnters tell the palyer }
                       { they've been eaten                   }

  { Delay time before level begins  }
  DelayTime    = 900;   { 40 m-Sec                             }

  { Execute return }
  Player_Dead    = 1;
  Break          = 2;
  LevelFinished  = 3;

  { OK Places     }
  opClear          = 0;
  opWall           = 1;
  opFood           = 2;
  opCracker        = 3;
  opMonsWall       = 4;
  opPackWall       = 5;
  opBothWall       = 6;
  opBlackHole      = 7;
  opPackManHome    = 8;
  opMounstersHome  = 9;

  opFadeBonus      = 10;


Type
  TPauseProc = Procedure;

  TSpeedRec = Record
    Movement,
    Frames : Word;
  End;

  PItemList   = ^TItemList;
  PCharacter  = ^TCharacter;
  PBonus      = ^TBonus;
  PEffect     = ^TEffect;
  PLevel      = ^TLevel;

  TItemList  = array[0..MaxCollectionSize - 1] of PCharacter;
  ByteSet    = Set Of Byte;

     (* TObject *)

  PObject = ^TObject;
  TObject = Object
    Constructor Init;
    Destructor Done; Virtual;
    Procedure Free;
  End;

  TCharacter = Object(TObject)
    TheLevel  : PLevel;
    Buffer    : PLevelBuf;
    Location  : TPoint;
    Virtual   : TPoint;
    Speed     : TSpeedRec;
    Frame     : Byte;
    Direction : Byte;
    State     : Byte;
    OKPlaces  : ByteSet;

    Constructor Init( ALevel: PLevel );
    Procedure HandleDirection; Virtual;
    Procedure UpDate; Virtual;
    Function  GetPicture( ADirection, AFrame: Byte ): PPicture; Virtual;
    Procedure SetState( AState: Byte; Enable: Boolean ); Virtual;
    Function  GetState( AState: Byte ): Boolean;
    Procedure NewSpeed( Restore: Boolean ); Virtual;
    Procedure Go_Home; Virtual;

    Procedure HandleMovement;
    Procedure HandleFrames;
    Procedure Draw;
    Function  CanMove( ADirection: Byte ): Boolean;
    Function  MovementDone: Boolean;
    Function  GetIndex( n: Byte ): Byte;
    Function  GetColorUnder( dx,dy: Integer ): Byte;
  End;

  TBonus = Object(TObject)
    TheLevel : PLevel;
    Location : TPoint;
    Time     : LongInt;
    SaveUnder: Byte;
    Constructor Init( ALocation: TPoint; ALevel: PLevel );
    Destructor Done; Virtual;
    Procedure UpDate; Virtual;
    Procedure DrawBonus;
  End;

  TEffect = Object(TObject)
    Time     : LongInt;
    TheLevel : PLevel;
    Constructor Init( ALevel: PLevel );
    Destructor Done; Virtual;
    Procedure UpDate; Virtual;
  End;

  TLevel = Object(TObject)
    Count         : Integer;
    Limit         : Integer;
    Items         : PItemList;
    Player        : PCharacter;
    Bonus         : PBonus;
    Effect        : PEffect;
    Buffer        : PLevelBuf;
    Pack_Man_Home : TPoint;
    Mounsters_Home: TPoint;
    Timer         : UnSigned_LongInt;
    Bonus_Timer   : Word;
    FoodCount     : Word;
    Bonus_Chanse  : Byte;
    Constructor Init( Monsters: Byte );
    Destructor Done; virtual;
    Procedure Insert( Item: PCharacter );
    Procedure InsertCharacter( ACharacter: PCharacter; IsPlayer: Boolean );
    Procedure Find_Homes;
    Procedure DrawLevel;
    Function Execute: Word;

    Procedure ChangeSpeeds;
    Procedure RestoreSpeeds;
    Procedure NewBonus; Virtual;

    Procedure SetBonus( ABonus: PBonus );
    Procedure DoneBonus;
    Procedure SetEffect( AEffect: PEffect );
    Procedure DoneEffect;
  End;


Procedure DefaultPauseProc;
Procedure FindPath( x, y: Integer; Var Path, Buffer: TLevelBuf; OKPlaces: ByteSet );

Var
  MonsHomePath,
  PackManPath : TLevelBuf;

Const
  PauseProc  : TPauseProc  = DefaultPauseProc;

Implementation

(* Local Procedures *)
Procedure PMPutPixel( x,y: Integer; Color: Byte );
Begin
  If x >= 320 Then x:= x - 320;
  If x < 0    Then x:= x + 320;
  If y >= 200 Then y:= y - 200;
  If y < 0    Then y:= y + 200;

  MPutPixel( x, y, Color );
End;

(* TObject *)
Constructor TObject.Init;
Type
  Image = Record
    Link: Word;
    Data: Record End
  End;
Begin
  FillChar( Image(Self).Data, SizeOf(Self) - SizeOf(TObject), 0 );
End;

Destructor TObject.Done;
Begin
End;

Procedure TObject.Free;
Begin
  Dispose( PObject(@Self), Done );
End;

(* TCharacter *)
Constructor TCharacter.Init( ALevel: PLevel );
Begin
  TObject.Init;

  TheLevel          := ALevel;
  Buffer            := TheLevel^.Buffer;
  Direction         := drNoDirection;
  Speed.Frames      := 50;
  Speed.Movement    := 16;
  LongInt(Location) := $00020001;
End;

Procedure TCharacter.HandleDirection;
Begin
End;

Procedure TCharacter.SetState( AState: Byte; Enable: Boolean );
Begin
  If Enable
    Then State:= State or AState
    Else State:= State and Not AState;

  Case AState of
    sfShouldDraw: If Not Enable Then Draw;
  End;
End;

Function TCharacter.GetState( AState: Byte ): Boolean;
Begin
  GetState:= Boolean(AState and State)
End;

Procedure TCharacter.NewSpeed( Restore: Boolean );
Begin
End;

Procedure TCharacter.Go_Home;
Begin
End;

Procedure TCharacter.UpDate;
Begin
  If MovementDone
    Then HandleDirection;

  If TheLevel^.Timer mod Speed.Movement = 0
    Then HandleMovement;

  If TheLevel^.Timer mod Speed.Frames = 0
    Then HandleFrames;

  If GetState( sfShouldDraw )
    Then SetState( sfShouldDraw, False );
End;

Function TCharacter.GetPicture( ADirection, AFrame: Byte ): PPicture;
Begin
End;

Procedure TCharacter.HandleMovement;
var b: boolean;
Begin
  If CanMove(Direction) Then
    With Virtual do
      Begin
        Case Direction of
          drRight: If X<>MaxVirX
                     Then Inc( X )
                     Else Begin
                            X:= -MaxVirX;
                            Inc( Location.X )
                          End;
          drLeft : If X<>-MaxVirX
                     Then Dec( X )
                     Else Begin
                            X:= MaxVirX;
                            Dec( Location.X )
                          End;
          drUp   : If Y<>-MaxVirY
                     Then Dec( Y )
                     Else Begin
                            Y:= MaxVirY;
                            Dec( Location.Y )
                          End;
          drDown : If Y<>MaxVirY
                     Then Inc( Y )
                     Else Begin
                            Y:= -MaxVirY;
                            Inc( Location.Y )
                          End
        End;
        SetState( sfShouldDraw, True );
      End
    Else With Virtual do
      Begin
        Case Direction of
          drRight: If X<0 Then Inc( X );
          drLeft : If X>0 Then Dec( X );
          drUp   : If Y>0 Then Dec( Y );
          drDown : If Y<0 Then Inc( Y ) ;
        End;
        SetState( sfShouldDraw, True );
      End;

  If Location.X = MaxX Then Location.X:= 0;
  If Location.X = -1   Then Location.X:= MaxX-1;
  If Location.Y = MaxY Then Location.Y:= 0;
  If Location.Y = -1   Then Location.Y:= MaxY-1;
End;

Procedure TCharacter.HandleFrames;
Begin
  Inc( Frame );
  If Frame = Maxframe Then Frame:= 0;
  SetState( sfShouldDraw, True );
End;

Function GetRealX( x: ShortInt ): Integer;
Begin
  GetRealX:= x*PicX
End;

Function GetRealY( y: ShortInt ): Integer;
Begin
  GetRealY:= y*PicY
End;

Procedure TCharacter.Draw;
Var
  x,y: ShortInt;
  c  : ShortInt;
  p  : PPicture;
Begin
  P:= GetPicture( GetIndex(Direction),Frame );
  For y:= 0 to PicY-1 do
    For x:= 0 to PicX-1 do
      Begin
         c:= P^[y,x];
         If c<>0
          Then PMPutPixel( GetRealX(Location.X) + Virtual.X + x,
                           GetRealY(Location.Y) + Virtual.Y + y, c )
          Else PMPutPixel( GetRealX(Location.X) + Virtual.X + x,
                           GetRealY(Location.Y) + Virtual.Y + y,
                           GetColorUnder( Virtual.X+x, Virtual.Y+y ) )
      End
End;

Function TCharacter.CanMove( ADirection: Byte ): Boolean;
Begin
  With Location do
    Case ADirection of
      drRight_,
      drRight: CanMove:= (X=MaxX-1) or (Buffer^[X+1,Y] in OKPlaces);
      drLeft_,
      drLeft : CanMove:= (X   =  0) or (Buffer^[X-1,Y] in OKPlaces);
      drUp_,
      drUp   : CanMove:= (Y   =  0) or (Buffer^[X,Y-1] in OKPlaces);
      drDown_,
      drDown : CanMove:= (Y=MaxY-1) or (Buffer^[X,Y+1] in OKPlaces);
      drNoDirection: CanMove:= True;
      Else CanMove:= False;
    End;
End;

Function TCharacter.MovementDone: Boolean;
Begin
  MoveMentDone:= Not LongBool(Virtual)
End;

Function TCharacter.GetIndex( n: Byte ): Byte;
Begin
  Case n of
    drUp   : GetIndex:= 1;
    drDown : GetIndex:= 2;
    drRight: GetIndex:= 3;
    drLeft : GetIndex:= 4;
    Else GetIndex:= 3
  End
End;

Function TCharacter.GetColorUnder( dx,dy: Integer ): Byte;
Var
  x, y,
  xx,yy : Integer;
  c: Byte;
Begin
  x:= Location.X;
  y:= Location.Y;
  xx:= dx;
  yy:= dy;

  If xx < 0      Then Begin Dec(x); xx:= PicX + xx End;
  If xx > PicX-1 Then Begin Inc(x); xx:= xx - PicX End;
  If yy < 0      Then Begin Dec(y); yy:= PicY + yy End;
  If yy > PicY-1 Then Begin Inc(y); yy:= yy - PicY End;

  If x = MaxX Then x:= 0;
  If x = -1   Then x:= MaxX-1;
  If y = MaxY Then y:= 0;
  If y = -1   Then y:= MaxY-1;

  c:= GetPic(Buffer^[x,y])^[yy,xx];
  If (c = 0) and (Background<>nil) Then c:= Background^[y*PicY+yy,x*PicX+xx];
  GetColorUnder:= c;
End;

(* TBonus *)
Constructor TBonus.Init( ALocation: TPoint; ALevel: PLevel );
Begin
  TObject.Init;
  TheLevel := ALevel;
  Location := ALocation;
  With Location do SaveUnder:= TheLevel^.Buffer^[X,Y]
End;

Destructor TBonus.Done;
Begin
  If TheLevel<>nil Then
    With Location do TheLevel^.Buffer^[X,Y]:= SaveUnder;
  DrawBonus;
End;

Procedure TBonus.UpDate;
Begin
   Dec(Time);
   If Time = 0 Then TheLevel^.DoneBonus;
End;

Procedure TBonus.DrawBonus;
Begin
  With Location do
    DrawPic( x*PicX, y*PicY, GetPic(TheLevel^.Buffer^[x,y])^ );
End;

(* TEffect *)
Constructor TEffect.Init( ALevel: PLevel );
Begin
  TObject.Init;
  TheLevel:= ALevel
End;

Destructor TEffect.Done;
Begin
End;

Procedure TEffect.UpDate;
Begin
  Dec( Time );
  If Time = 0
    Then TheLevel^.DoneEffect;
End;

(* TLevel *)
Constructor TLevel.Init( Monsters: Byte );
Begin
  TObject.Init;
  Limit:= Monsters;
  Count:= 0;
  GetMem( Pointer(Items), SizeOf(Pointer)*Limit );
  FillChar( Pointer(Items)^, SizeOf(Pointer)*Limit, 0 );
End;

Destructor TLevel.Done;
Var
  i: Integer;
Begin
  DoneEffect;
  DoneBonus;
  For i:=0 to Count-1 do
    If Items^[i]<>nil Then Dispose( Items^[i], Done );
  FreeMem( Pointer(Items), SizeOf(Pointer)*Limit );
End;

Procedure TLevel.Insert( Item: PCharacter );
Begin
  If Count<Limit-1 Then
    Begin
      Items^[Count]:= Item;
      Inc(Count)
    End
End;

Procedure TLevel.InsertCharacter( ACharacter: PCharacter; IsPlayer: Boolean  );
Begin
  If ACharacter = nil Then Exit;
  Insert( ACharacter );
  If IsPlayer Then Player:= ACharacter;
End;

Function MakeLong(A, B: Integer): Longint; InLine($5A/$58);
{ Asm POP DX; POP AX; END; }

Procedure TLevel.Find_Homes;
Var
  i,j: Integer;
Begin
  LongInt(Pack_Man_Home) := $FFFFFFFF;
  LongInt(Mounsters_Home):= $FFFFFFFF;
  FoodCount              := 0;

  For i:=0 to MaxX-1 do
    For j:=0 to MaxY-1 do
      Begin
        If Buffer^[i,j] = opMounstersHome Then
          LongInt(Mounsters_Home):= MakeLong(i,j) Else
            If Buffer^[i,j] = opPackManHome Then
              LongInt(Pack_Man_Home):= MakeLong(i,j);
        If (Buffer^[i,j] = opFood) or (Buffer^[i,j] = opCracker)
          Then Inc( FoodCount );
      End;

  With Mounsters_Home do
    FindPath( x, y, MonsHomePath, Buffer^, {[255] - [opWall,opPackWall] );}
    [opClear, opFood, opCracker, opMonsWall,
    opBothWall, opPackManHome, opMounstersHome]);
End;

Procedure TLevel.DrawLevel;
Var
  d,j: Byte;
Begin
  For j:= 0 to MaxY-1 do
    For d:= 0 to MaxX-1 do
      DrawPic( d*PicX, j*PicY, GetPic(Buffer^[d,j])^ );
End;

Function TLevel.Execute;
Var
  i,j : Integer;
Begin
  For i:= 0 to Count-1 do
    Items^[i]^.Go_Home;

  While Not Player^.GetState(sfDead) and Not Key[scEsc] and (FoodCount<>0) do
    Begin
      Wait( 1 );
      If Bonus_Timer = 0 Then
        Begin
          Bonus_Timer:= Bonnus_Every + Random(Change_Time);
          If Bonus = nil Then NewBonus;
        End;
   { Update the characters, bonus and effect  }
      For i:= 0 to Count-1 do
        Items^[i]^.UpDate;
      If Bonus<> nil Then Bonus^.UpDate;
      If Effect<>nil Then Effect^.UpDate;

   { Handle special functions like pause and cheats }
      Case Port[$60] of
        scF11: NewBonus;
        scF12: FoodCount:= 0;{}
        scP  : PauseProc;    {}
      End;

      If Timer mod Find_Path_Freq=0 Then
        With PLayer^.Location do
          FindPath( x, y, PackManPath, Buffer^,
                    [opClear, opFood, opCracker, opMonsWall,
                    opBothWall, opPackManHome, opMounstersHome] );
{                    [255] - [opWall,opPackWall] );}

      Inc( Timer );
      Dec( Bonus_Timer );
    End;

  If FoodCount = 0
    Then Execute:= LevelFinished
    Else If Key[scEsc]
           Then Execute:= Break
           Else If Player^.GetState(sfDead)
                   Then Execute:= Player_Dead
                   Else Execute:= 0;
End;

Procedure TLevel.ChangeSpeeds;
Var
  i: Integer;
Begin
  For i:= 0 to Count-1 do
    Items^[i]^.NewSpeed( False );
End;

Procedure TLevel.RestoreSpeeds;
Var
  i: Integer;
Begin
  For i:= 0 to Count-1 do
    Items^[i]^.NewSpeed( True );
End;

Procedure TLevel.NewBonus;
Begin
End;

Procedure TLevel.SetBonus( ABonus: PBonus );
Begin
  If (Bonus = nil) and (ABonus<>nil)
    Then Bonus:= ABonus
    Else Dispose( ABonus, Done );
End;

Procedure TLevel.DoneBonus;
Begin
  If Bonus<>nil Then Dispose( Bonus, Done );
  Bonus:= nil;
End;

Procedure TLevel.SetEffect( AEffect: PEffect );
Begin
  If (Effect = nil) and (AEffect<>nil)
    Then Effect:= AEffect
    Else Dispose( AEffect, Done );
End;

Procedure TLevel.DoneEffect;
Begin
  If Effect<>nil Then Dispose( Effect, Done );
  Effect:= nil;
End;

(* Procedures of the unit *)
Procedure DefaultPauseProc;
Begin
End;

Procedure FindPath( x, y: Integer; Var Path, Buffer: TLevelBuf; OKPlaces: ByteSet );
Var
  Xc,Yc,
  Index     : Byte;
  Finished  : Boolean;
Begin
  For xc:= 0 to MaxX-1 do
    For yc:= 0 to MaxY-1 do
     If Buffer[xc,yc] in OKPlaces
       Then Path[xc,yc]:= 0
       Else Path[xc,yc]:= $FF;

  Index:= 1;
  Path[X,Y]:= Index;

  Repeat
    Finished:= True;
    For Xc:= 0 To MaxX-1 Do
      For Yc:= 0 To MaxY-1 Do
        If Path[Xc,Yc] = Index Then Begin
          If (Xc<MaxX-1) and (Path[Xc+1,Yc] = 0) Then Path[Xc+1,Yc]:= Index+1;
          If (Xc>00)     and (Path[Xc-1,Yc] = 0) Then Path[Xc-1,Yc]:= Index+1;
          If (Yc<MaxY-1) and (Path[Xc,Yc+1] = 0) Then Path[Xc,Yc+1]:= Index+1;
          If (Yc>00)     and (Path[Xc,Yc-1] = 0) Then Path[Xc,Yc-1]:= Index+1;
          Finished:= False;
        End;
    Inc(Index);
  Until Finished;
End;

End.
