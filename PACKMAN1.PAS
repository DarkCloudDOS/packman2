
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

Unit PackMan1;

Interface

Uses Utils,SB;

Const
(* Maximum minimum stuff    *)
  MaxSounds = 6;   { Maximum numbers of waves to load      }
  MaxSongs  = 3;   { Maximun number of songs to load       }
  MaxBigPic = 2;   { Number of big pictures                }
  ScreenX   = 320; { Screen width                          }
  ScreenY   = 200; { Screen hieght                         }
  PicX      = 10;  { Picture width                         }
  PicY      = 10;  { Picture height                        }
  MaxX      = 32;  { Max slots on X                        }
  MaxY      = 20;  { Max slots on Y                        }
  MaxLevel  = 10;  { Number of level in the game           }
  MaxMons   = 10;  { Maximun number of mounters in level   }

(* Song numbers            *)
  snStrongSong = 2;

(* Siganture of level file *)
  Signature: array[0..40] of Char
    = 'PACK - MAN 2 THE REVENGE. Level file.'#26;

Type
  FileStr = String[12];

  THSCRecord = Record
    TheSong: Pointer;
    Size: Word;
  End;

  TPoint = Record
    x,y: Integer
  End;


  UnSigned_LongInt = 0..$10000000;

  PBigPic    = ^TBigPic;
  PPicture   = ^TPicture;
  PPictures  = ^TPictures;
  PLevelBuf  = ^TLevelBuf;
{$IFNDEF NO_SOUNDS}
  PWaves     = ^TWaves;
  PSongs     = ^TSongs;
{$ENDIF}

  TBigPic    = array[0..ScreenY-1,0..ScreenX-1]  of Byte;
  TPicture   = array[0..PicY-1,0..PicX-1]        of Byte;
  TPictures  = array[0..45]                      of TPicture;
  TLevelBuf  = array[0..MaxX-1,0..MaxY-1]        of Byte;
  TBigPics   = array[0..MaxBigPic ]              of PBigPic;
{$IFNDEF NO_SOUNDS}
  TWaves     = array[0..MaxSounds-1]             of WAVE_RECORD;
  TSongs     = array[0..MaxSongs]                of THSCRecord;
{$ENDIF}

Function  GetPic( n: Word ): PPicture;
Procedure DrawPic( x,y: Word; APic: TPicture );
Procedure LoadPalFile( Const Name: String; Var Palette: TPalette );
Procedure LoadPictures( Name: FileStr; WorldNumber: Byte );
Procedure UnLoadPictures;

{$IFNDEF NO_SOUNDS}
Procedure LoadWaves1;
Procedure LoadHsc1;
Procedure LoadWaves2;
Procedure LoadHsc2;
Procedure UnLoadWaves;
Procedure UnLoadHsc;
{$ENDIF}

Procedure Load_World_1;
Procedure Load_World_2;

Var
  Palette    : TPalette;
  Pictures   : TPictures;
  BigPicture : TBigPics;
  Background : PBigPic;
{$IFNDEF NO_SOUNDS}
  Waves      : PWaves;
  Songs      : TSongs;
  UsingSB    : Boolean;
{$ENDIF}


Implementation


Const
  World1    = 0;
  World2    = 1;

  World1Pal  = 'WORLD1.COL';
  World2Pal  = 'WORLD2.COL';

  World1_Pictures = 'WORLD1.PMP';
  World2_Pictures = 'WORLD2.PMP';

  Big_Pic_File: array[World1..World2,0..MaxBigPic-1] of FileStr  =
    ( ('PACKMAN.CEL', 'PACKMAN2.CEL'),
      ('PACKMAN3.CEL','PACKMAN4.CEL') );
  Wave_Files: array[0..MaxSounds-1] of FileStr =
   ( 'DEADDOG.WAV', 'HEREDOG.WAV', 'NIII.WAV',
     'TRI5.WAV'   , 'HAPPY.WAV'  , 'HULKSTER.WAV' );
  Hsc_Files: array[0..MaxSongs-1] of FileStr =
   ( 'ADTHELIB.HSC', 'WVBOMBE.HSC', 'FIGHT.HSC' );


Function GetPic( n: Word ): PPicture;
Const
  PicTable: Array[0..14] of Byte =
   ( 30, 20, 22, 21, 20,
     20, 20, 30, 30, 30,
     27, 28, 29, 31, 32 );
Begin
  If n in [0..14]
    Then GetPic:= @Pictures[PicTable[n]]
    Else GetPic:= @Pictures[30]
End;

Procedure DrawPic( x,y: Word; APic: TPicture );
Var
  xx, yy: Word;
  c     : Byte;
Begin
  For yy:= 0 to PicY-1 do
    For xx:= 0  to PicX-1 do
      Begin
        c:= APic[yy,xx];
        If (c = 0) and (Background<>nil) Then c:= Background^[yy+y,xx+x];
        PutPixel( xx+x, yy+y, c );
      End;
End;

Procedure LoadPalFile( Const Name: String; Var Palette: TPalette );
Var
  F: File of TPalette;
Begin
  Assign( F, Name );
  Reset( F );
  Read( F, Palette );
  Close( F );
End;

Procedure LoadPictures( Name: FileStr; WorldNumber: Byte );
Var
  F: File;
  i: Byte;
  w: Word;
Begin
  Assign( F, Name );
  Reset( F, 1 );
  BlockRead( F, w, 2 ); { number of pictures in the file }
  BlockRead( F, Pictures, SizeOf(TPicture)*31 );
  Close( F );

  For i:= 0 to MaxBigPic-1 Do
    If MaxAvail>=SizeOf(TBigPic) Then
    Begin
      New( BigPicture[i] );
      FillChar( BigPicture[i]^, SizeOf(BigPicture[i]^), 0 );
      Assign( F, Big_Pic_File[WorldNumber][i] );
      Reset( F, 1 );
      Seek( F, 800 );
      BlockRead( F, BigPicture[i]^, ScreenX*ScreenY );
      Close( F );
   End;
End;

Procedure UnLoadPictures;
Var
  i: Byte;
Begin
  For i:= 0 to MaxBigPic-1 Do
    If BigPicture[i]<>nil Then Dispose( BigPicture[i] );
End;

{$IFNDEF NO_SOUNDS}
Procedure LoadWaves1;
Var
  i: Integer;
Begin
  New( Waves );
  FillChar( Waves^, SizeOf(Waves^), 0 );
  For i:= 0 to MaxSounds-1 do
    LoadWave( Wave_Files[i], Waves^[i] );
End;

Procedure LoadHSC1;
Var
  i: Integer;
  F: File;
Begin
  FillChar( Songs, SizeOf(Songs), 0 );
  For i:= 0 to MaxSongs-1 do
    Begin
      Assign( F, HSC_Files[i] );
      Reset( F, 1 );
      Songs[i].Size:= FileSize(F);
      With Songs[i] do
        TheSong:= MemAlloc(Size);
{      GetMem( Songs[i].TheSong, Songs[i].Size );}
      With Songs[i] do
       If TheSong<>nil Then
          BlockRead(F, TheSong^, Size );
      Close( F );
    End;
End;

Procedure LoadWaves2;
Var
  i: Integer;
Begin
  New( Waves );
  FillChar( Waves^, SizeOf(Waves^), 0 );
  For i:= 0 to MaxSounds-1 do
    LoadWave( Wave_Files[i], Waves^[i] );
End;

Procedure LoadHSC2;
Var
  i: Integer;
  F: File;
Begin
  FillChar( Songs, SizeOf(Songs), 0 );
  For i:= 0 to MaxSongs-1 do
    Begin
      Assign( F, HSC_Files[i] );
      Reset( F, 1 );
      Songs[i].Size:= FileSize(F);
      GetMem( Songs[i].TheSong, Songs[i].Size );
      With Songs[i] do
        BlockRead(F, TheSong^, Size );
      Close( F );
    End;
End;

Procedure UnLoadWaves;
Var
  i: Integer;
Begin
  If Waves<> nil Then
    Begin
      For i:= 0 to MaxSounds-1 do
        If Waves^[i].Data<>nil Then
          With Waves^[i] do
            FreeMem( Data, DataSize );
      Dispose( Waves );
    End;
  FillChar( Waves, 0, SizeOf(Waves) );
End;

Procedure UnLoadHsc;
Var
  i: Integer;
Begin
  For i:= 0 to MaxSongs-1 do
    If Songs[i].TheSong<>nil Then
      With Songs[i] do
        FreeMem( TheSong, Size );
  FillChar( Songs, 0, SizeOf(Songs) );
End;
{$ENDIF}

Procedure Load_World_1;
Begin
  LoadPalFile( World1Pal, Palette );
{$IFNDEF NO_SOUNDS}
  LoadWaves1;
  LoadHsc1;
{$ENDIF}
  LoadPictures( World1_Pictures, World1 );
End;

Procedure Load_World_2;
Begin
  LoadPalFile( World2Pal, Palette );
{$IFNDEF NO_SOUNDS}
  LoadWaves2;
  LoadHsc2;
{$ENDIF}
  LoadPictures( World2_Pictures, World2 );
End;

End.
