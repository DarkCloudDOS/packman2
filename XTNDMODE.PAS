
(* ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออป	*)
(* บ							    บÛ	*)
(* บ	 Borland Pascal Units.				    บÛ	*)
(* บ	 XtndMode Interface Unit			    บÛ	*)
(* บ	 dark - cloud programming.			    บÛ	*)
(* วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถÛ	*)
(* บ							    บÛ	*)
(* บ	 Copyright (C) 1996,1997			    บÛ	*)
(* บ							    บÛ	*)
(* ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออผÛ	*)
(*  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿	*)

Unit XtndMode;

{$G+,S-,D+,L+}

Interface

Const
  MaxX	   = 640;
  MaxY	   = 400;

Procedure InitXtended;
Procedure PutPixel( x, y: Integer; Color: Byte );
Function  GetPixel( x, y: Integer ): Byte;
Procedure ClearScreen( Color: Byte );

Implementation

Procedure InitXtended; ASSEMBLER;
Var
  ScreenMode: Byte absolute $40:$49;
Asm
	MOV	AX,	04F02H
	MOV	BX,	00100H
	INT	10H
	MOV	DX,	003C4h
	MOV	AL,	1
	OUT	DX,	Al
	INC	DX
	IN	AL,	DX
	OR	AL,	020h
	OUT	DX,	Al
	MOV	DX,	003C4H
	MOV	AX,	00604H
	OUT	DX,	AX
	MOV	DX,	003D4H
	MOV	AX,	0E317H
	OUT	DX,	AX
	MOV	DX,	003D4H
	MOV	AX,	00014H
	OUT	DX,	AX
	MOV	DX,	003C4H
	MOV	AX,	00F02H
	OUT	DX,	AX
	MOV	ES,	SegA000
	XOR	DI,	DI
	XOR	AX,	AX
	MOV	CX,	$FFFF/2
	REP	STOSW
	MOV	DX,	3DAh
@L1:	IN	AL,	DX
	TEST	AL,	08h
	JNZ	@L1
	MOV	DX,	03C4h
	MOV	AL,	1
	OUT	DX,	Al
	INC	DX
	IN	AL,	Dx
	AND	AL,	0DFh
	OUT	DX,	AL

	PUSH	DS
	MOV	DS,	Seg0040
	MOV	ScreenMode, 13H
	POP	DS
End;

Procedure PutPixel( x, y: Integer; Color: Byte ); Assembler;
Asm
   MOV	CX,	X
   AND	CX,	3
   MOV	AX,	0100H
   SHL	AX,	CL
   ADD	AX,	2
   MOV	DX,	03C4h
   OUT	DX,	AX

   MOV	DI,	Y
   MOV	AX,	Y
   SHL	DI,	7
   SHL	AX,	5
   ADD	DI,	AX
   MOV	AX,	X
   SHR	AX,	2
   ADD	DI,	AX
   MOV	AL,	Color
   MOV	ES,	SegA000
   MOV	ES:[DI],AL
End;

Function GetPixel( x, y: Integer ): Byte; Assembler;
Asm
   MOV	DX,	$3CE
   MOV	AL,	04
   OUT	DX,	AL
   MOV	AX,	x
   AND	AX,	03
   INC	DX
   OUT	DX,	AX

   MOV	DI,	Y
   MOV	AX,	Y
   SHL	DI,	7
   SHL	AX,	5
   ADD	DI,	AX
   MOV	AX,	X
   SHR	AX,	2
   ADD	DI,	AX
   MOV	ES,	SegA000
   MOV	AL,	ES:[DI]
End;

Procedure ClearScreen( Color: Byte ); Assembler;
Asm
        MOV     DX,     03C4H
	MOV     AX,     0F02H
        OUT     DX,     AX
        MOV     ES,     SegA000
        XOR     DI,     DI
        MOV     AL,     Color
        MOV     AH,     AL
	MOV     CX,     $FFFF/2
	REP     STOSW
End;


End.
