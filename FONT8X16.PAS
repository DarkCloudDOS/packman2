
(* ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»	*)
(* º							    ºÛ	*)
(* º	 Borland Pascal Units.				    ºÛ	*)
(* º	 Font8x16 Interface Unit			    ºÛ	*)
(* º							    ºÛ	*)
(* ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶Û	*)
(* º							    ºÛ	*)
(* º	 Copyright (C) 1995,1996 Diego Iastrubni	    ºÛ	*)
(* º							    ºÛ	*)
(* ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼Û	*)
(*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß	*)

Unit Font8x16;

{$G+,S-}

Interface

Const
  SetChar = 0;
  GetChar = 1;

Type
  Characters  = Char;
  PFont       = ^TFont;
  TLetter     = array[1..16] of Byte;
  TFont       = array[Characters] of TLetter;

{ ÄÄ Graphics Output ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
Procedure WriteLetter( x,y: Word; c: Char );
Procedure WriteStr( x,y: Word; Text: String );
Procedure ReadStr( x,y: Word; Var Str; L: Byte );

{ ÄÄ Font manipulation ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
Procedure GetSetChar( Chr: Char ; var Data; GetSet: Byte; Size: Word);
Procedure SetBiosFont( Var Font: TFont );
Procedure LoadFont( Name: String; Var Temp: TFont );

Const
  Font : PFont = nil;
  Color: Byte = 7;
  Back : Byte = 0;

Implementation

Uses Utils;

{ ÄÄ Graphics Output ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
Procedure WriteLetter( x,y: Word; c: Char );
Var
  d,n: Byte;
Begin
  For d:= 1 to 16 do
    For n:= 0 to 7 do
      If GetBit(Font^[c,d],n)
	Then PutPixel( x+(8-n) , y+d, Color)
	Else PutPixel( x+(8-n) , y+d, Back )
End;

Procedure WriteStr( x,y: Word; Text: String );
Var
  n,d: Word;
  c: Char;
Begin
  d:= 0;
  For n:= 1 to Length( Text ) do
    Begin
      c:= Text[n];
      WriteLetter( x+d, y, c );
      Inc(d,8)
    End;
End;

Procedure ReadStr( x,y: Word; Var Str; L: Byte );
Var
  Count: Byte;
  Temp: Char;
  S: String;
  ShouldWrite: Boolean;
  UserStr: String absolute Str;
Begin
  Count:= 1;
  ShouldWrite:= True;
  S:= UserStr;
  If Length(s)>L Then s[0]:= Chr(l);
  WriteStr( x,y, S );
  Line( (Length(S))*8+x+4, y+2, (Length(s))*8+x+4, y+15 , Color);
  Repeat
    Temp:= Ascii;
    Case Temp of
      #32..#127: If S[0]<>Char(L)
	     Then S:= S+Temp
	     Else ShouldWrite:= False;
      #08: Begin
	     Line( (Length(s))*8+x+4, y+2, (Length(s))*8+x+4, y+15 , Back);
	     If S[0]<>#0 Then
	       Begin
		 Dec( S[0] );
		 WriteLetter( (Length(s))*8+x, y,' ');
	       End;
	     ShouldWrite:= False;
	   end;
      Else ShouldWrite:= False;
    End;
    If ShouldWrite Then WriteLetter( (Length(s)-1)*8+x, y, Temp);
    ShouldWrite:= True;

    If S[0]<>Char(L) Then
      Line( (Length(s))*8+x+4, y+2, (Length(s))*8+x+4, y+15 , Color );
  Until Temp in [#27, #13];
  If Temp<>#27 Then UserStr:= s;
  WriteLetter( (Length(s))*8+x, y, ' ');
End;

{ ÄÄ Font manipulation ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ }
Procedure SetBiosFont( Var Font: TFont );
Var
  C: Char;
Begin
  For c:= #0 to #255 do
    GetSetChar( C, Font[c], GetChar, SizeOf(TLetter) );
End;

Procedure LoadFont( Name: String; Var Temp: TFont );
Var
  F: File;
Begin
  Assign( F,Name );
  Reset( F, SizeOf(TFont) );
  BlockRead( F, Temp, 1 );
  Close( F );
End;

Procedure GetSetChar( Chr: Char ; var Data; GetSet: Byte; Size: Word); Assembler;
Asm
	PUSH	DS
	MOV	AL,	32
	MUL	Chr
	CMP	GetSet, GetChar
	JE	@GoGet
	MOV	DI,	AX
	MOV	AX,	SegA000
	MOV	ES,	AX
	MOV	CX,	Size
	SHR	CX,	1
	LDS	SI,	Data
	JMP	@Start
@GoGet:
	MOV	SI,	AX
	MOV	AX,	SegA000
	MOV	DS,	AX
	MOV	CX,	Size
	SHR	CX,	1
	LES	DI,	DATA
@Start:
	CLI
	MOV	DX,	03c4h
	MOV	AX,	0402h
	OUT	DX,	AX
	MOV	AX,	0704h
	OUT	DX,	AX
	MOV	DX,	03CEh
	MOV	AX,	0204h
	OUT	DX,	AX
	MOV	AX,	0005h
	OUT	DX,	AX
	MOV	AX,	0006h
	OUT	DX,	AX
	REP	MOVSW
	MOV	DX,	03C4h
	MOV	AX,	0302h
	OUT	DX,	AX
	MOV	AX,	0304h
	OUT	DX,	AX
	MOV	DX,	03CEh
	MOV	AX,	0004h
	OUT	DX,	AX
	MOV	AX,	1005h
	OUT	DX,	AX
	MOV	AX,	0E06h
	OUT	DX,	AX
	STI
	POP	DS
end;

End.
