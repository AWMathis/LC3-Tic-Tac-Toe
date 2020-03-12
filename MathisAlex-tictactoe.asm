;-----------------------------------------------------------------
; Tic-Tac-Toe
; Project Starter Code  
;-----------------------------------------------------------------
;-----------------------------------------------------------------
; Main Program
;-----------------------------------------------------------------
 		.ORIG x3000
MAIN		LEA 	R0, WELCOME
		TRAP 	x22
		LD	R0, NEWLINE
		TRAP 	x21
		LDI	R2, DRAWBOARD_ADDR_ADDR
		JSRR 	R2
		LDI	R2, EVALBOARD_ADDR_ADDR
		JSRR 	R2		

;-----------------------------------------------------------------
; After EVALBOARD, R1 contains an exit code
; 0 = Keep Playing
; 1 = X wins
; 2 = O wins
; 3 = Cat Game
;-----------------------------------------------------------------
CHECK		ADD	R1, R1, #0	; Load condition codes
		BRp	GAMEOVER
MOVE		LDI	R2, GETVALIDINPUT_ADDR_ADDR
		JSRR	R2		
;-----------------------------------------------------------------
; After GETVALIDINPUT, R1 contains valid input char
;-----------------------------------------------------------------
		LD	R0, NEG_ASCII_q	
		ADD	R0, R0, R1	
		BRz	FINALMESSAGE	; User opted to quit
		;
		LDI	R2, UPDATEBOARD_ADDR_ADDR
		JSRR	R2
		;
		LDI	R2, DRAWBOARD_ADDR_ADDR
		JSRR	R2
		;
		LDI	R2, EVALBOARD_ADDR_ADDR
		JSRR	R2
		BRnzp	CHECK
GAMEOVER	LDI	R2, PRINTOUTCOME_ADDR_ADDR
		JSRR	R2
FINALMESSAGE	LEA	R0, THANKS
		TRAP	x22
		TRAP	x25	

DRAWBOARD_ADDR_ADDR 	.FILL DRAWBOARD_ADDR
EVALBOARD_ADDR_ADDR 	.FILL EVALBOARD_ADDR
GETVALIDINPUT_ADDR_ADDR .FILL GETVALIDINPUT_ADDR
UPDATEBOARD_ADDR_ADDR 	.FILL UPDATEBOARD_ADDR
PRINTOUTCOME_ADDR_ADDR 	.FILL PRINTOUTCOME_ADDR
;-----------------------------------------------------------------
; Constants
;-----------------------------------------------------------------
ROW1		.STRINGZ	"   |   |   "
ROW2		.STRINGZ	"   |   |   "
ROW3		.STRINGZ	"   |   |   "
ROW4		.STRINGZ	"-----------"
ROW5 		.STRINGZ	"   |   |   "
ROW6		.STRINGZ	"   |   |   "
ROW7		.STRINGZ	"   |   |   "
ROW8		.STRINGZ	"-----------"
ROW9		.STRINGZ	"   |   |   "
ROW10		.STRINGZ	"   |   |   "
ROW11 		.STRINGZ	"   |   |   "
WELCOME		.STRINGZ	"Welcome to Tic-Tac-Toe"
THANKS		.STRINGZ	"Thanks for playing Tic-Tac-Toe"
USERPROMPT	.STRINGZ	" - Which square? [1-9] > "
ASCII_X		.FILL 		x0058	
ASCII_O		.FILL		x004f	
NEG_ASCII_X	.FILL		xFFA8
NEG_ASCII_O	.FILL		xFFB1
NEG_ASCII_q	.FILL		xFF8F	; Negative of x0071 (ASCII 'q')
NEG_ASCII_SP	.FILL		xFFE0   
NEWLINE		.FILL		x000A	; LineFeed Character
;-----------------------------------------------------------------
; PLAYER : 0 = O
;          1 = X
; X always goes first (thus we initialize
; the memory location to 1.)
;-----------------------------------------------------------------
PLAYER		.FILL	x0001
;-----------------------------------------------------------------
;Pointer Table
;-------------
;Pointers to Board center squares.
;MODIFIED MODIFIED MODIFIED
;-----------------------------------------------------------------
TOPLEFT		.FILL	x302D	; Pointer to center of square 1
		.FILL	x3031	;     "        "         "    2
		.FILL	x3035	;     "        "         "    3
		.FILL	x305D	;     "        "         "    4
		.FILL	x3061	;     "        "         "    5
		.FILL	x3065	;     "        "         "    6
		.FILL	x308D	;     "        "         "    7
		.FILL	x3091	;     "        "         "    8
		.FILL	x3095	;     "        "         "    9
;-----------------------------------------------------------------

; EVALBOARD subroutine -
; Args: 
;	R1 - Upon exit, contains a code indicating 
;	     the status of the game.
;		0 = game still in progress
;		1 = X wins
;   		2 = O wins
;		3 = Cat Game (draw)
;
; 1. Determine if the board is full (to detect cat game)
; 2. Check all 8 possible win scenarios
; 3. Set exit code in R1
;-----------------------------------------------------------------
EVALBOARD	ST	R0, EV_R0	; Save R0
		ST	R2, EV_R2	; Save R2
		ST	R3, EV_R3	; Save R3
		ST	R4, EV_R4	; Save R4	
		ST	R5, EV_R5	; Save R5
		ST	R6, EV_R6	; Save R6
		ST	R7, EV_R7	; Save Return Address
;-----------------------------------------------------------------
; Setup the base of the pointer table
;-----------------------------------------------------------------
		LD	R0, EV_TOPLEFT_ADDR
		ADD	R0, R0, #-1	; R0 contains base of pointer table
;-----------------------------------------------------------------
; First check for a full board and set EV_FULLBOARD to:
; 0 = board is full
; 1 = board contains at least one empty square
;-----------------------------------------------------------------
		AND	R2, R2, #0
		ADD	R2, R2, #9
		LD	R3, NEG_ASCII_SP
		AND	R4, R4, #0	; R4 countains the value we'll store to EV_FULLBOARD
EV_LOOP		ADD	R5, R0, R2	 
		LDR	R5, R5, #0	
		LDR	R5, R5, #0	; square n 
		ADD	R5, R5, R3
		BRz	EV_FOUNDSPACE	; if we find a space, note it and exit loop
		ADD	R2, R2, #-1	
		BRp	EV_LOOP		
		BRnzp	EV_NOSPACE	
EV_FOUNDSPACE	ADD	R4, R4, #1
EV_NOSPACE	ST	R4, EV_FULLBOARD
;-----------------------------------------------------------------
; Now check all 8 possible win combinations
;-----------------------------------------------------------------
		AND	R1, R1, #0	; R1 contains our exit code
 		ADD	R2, R0, #5	; pointer to pointer to center square
		LDR	R2, R2, #0	; pointer to center square
		LDR	R2, R2, #0	; center square ('X', 'O', or ' ')
		LD	R3, NEG_ASCII_SP
		ADD	R3, R3, R2
		BRz	EV_CHECK5	; If the center square is a space, 
					; skip these four checks
		NOT	R3, R2		
		ADD	R3, R3, #1	; now we have ASCII_NEG_X or ASCII_NEG_O
EV_CHECK1	ADD	R2, R0, #4	; pointer to pointer to square 4
		LDR	R2, R2, #0	; etc...
		LDR	R2, R2, #0	; square 4
		ADD	R2, R2, R3	
		BRnp	EV_CHECK2
		ADD	R2, R0, #6
		LDR	R2, R2, #0
		LDR	R2, R2, #0	; square 6
		ADD	R2, R2, R3	
		BRz	EV_WINNER	; found a winner!
EV_CHECK2	ADD	R2, R0, #2	
		LDR	R2, R2, #0	
		LDR	R2, R2, #0	; square 2
		ADD	R2, R2, R3	
		BRnp	EV_CHECK3
		ADD	R2, R0, #8
		LDR	R2, R2, #0
		LDR	R2, R2, #0	; square 8
		ADD	R2, R2, R3	
		BRz	EV_WINNER	; found a winner!
EV_CHECK3	ADD	R2, R0, #1	
		LDR	R2, R2, #0	
		LDR	R2, R2, #0	; square 1
		ADD	R2, R2, R3	
		BRnp	EV_CHECK4
		ADD	R2, R0, #9
		LDR	R2, R2, #0
		LDR	R2, R2, #0	; square 9
		ADD	R2, R2, R3	
		BRz	EV_WINNER	; found a winner!
EV_CHECK4	ADD	R2, R0, #3	
		LDR	R2, R2, #0	
		LDR	R2, R2, #0	; square 3
		ADD	R2, R2, R3	
		BRnp	EV_CHECK5
		ADD	R2, R0, #7
		LDR	R2, R2, #0
		LDR	R2, R2, #0	; square 7
		ADD	R2, R2, R3	
		BRz	EV_WINNER	; found a winner!
EV_CHECK5	ADD	R2, R0, #1	
		LDR	R2, R2, #0	
		LDR	R2, R2, #0	; top left square ('X', 'O', or ' ')
		LD	R3, NEG_ASCII_SP
		ADD	R3, R3, R2
		BRz	EV_CHECK6	; If the top left square is a space, 
					; skip these two checks
		NOT	R3, R2		
		ADD	R3, R3, #1	; now we have ASCII_NEG_X or ASCII_NEG_O
		ADD	R2, R0, #4	
		LDR	R2, R2, #0	
		LDR	R2, R2, #0	; square 4
		ADD	R2, R2, R3	
		BRnp	EV_CHECK6
		ADD	R2, R0, #7
		LDR	R2, R2, #0
		LDR	R2, R2, #0	; square 7
		ADD	R2, R2, R3	
		BRz	EV_WINNER	; found a winner!
EV_CHECK6	ADD	R2, R0, #2	
		LDR	R2, R2, #0	
		LDR	R2, R2, #0	; square 2
		ADD	R2, R2, R3	
		BRnp	EV_CHECK7
		ADD	R2, R0, #3
		LDR	R2, R2, #0
		LDR	R2, R2, #0	; square 3
		ADD	R2, R2, R3	
		BRz	EV_WINNER	; found a winner!
EV_CHECK7	ADD	R2, R0, #9	
		LDR	R2, R2, #0	
		LDR	R2, R2, #0	; bottom right square ('X', 'O', or ' ')
		LD	R3, NEG_ASCII_SP
		ADD	R3, R3, R2
		BRz	EV_CHECK8	; If the bottom right square is a space, 
					; skip these two checks
		NOT	R3, R2		
		ADD	R3, R3, #1	; now we have ASCII_NEG_X or ASCII_NEG_O
		ADD	R2, R0, #6	
		LDR	R2, R2, #0	
		LDR	R2, R2, #0	; square 6
		ADD	R2, R2, R3	
		BRnp	EV_CHECK8
		ADD	R2, R0, #3
		LDR	R2, R2, #0
		LDR	R2, R2, #0	; square 3
		ADD	R2, R2, R3	
		BRz	EV_WINNER	; found a winner!
EV_CHECK8	ADD	R2, R0, #8	
		LDR	R2, R2, #0	
		LDR	R2, R2, #0	; square 8
		ADD	R2, R2, R3	
		BRnp	EV_CHECKCAT
		ADD	R2, R0, #7
		LDR	R2, R2, #0
		LDR	R2, R2, #0	; square 7
		ADD	R2, R2, R3	
		BRz	EV_WINNER	; found a winner!
;-----------------------------------------------------------------
; If we didn't have a winner, check to see if we had a cat game
;-----------------------------------------------------------------
EV_CHECKCAT	LD	R2, EV_FULLBOARD
		BRp	EV_EXIT
		ADD	R1, R1, #3	; R1 = 3 indicating we had a cat game.
		BRnzp	EV_EXIT
;-----------------------------------------------------------------
; If we have a winner, R3 contains the negative ascii code 
; of the winner's character
;-----------------------------------------------------------------
EV_WINNER	LD	R2, ASCII_X
		ADD	R2, R2, R3
		BRnp	EV_O_WINS	
		ADD	R1, R1, #1	; R1 = 1 indicating X won
		BRnzp	EV_EXIT				
EV_O_WINS	ADD	R1, R1, #2	; R1 = 2 indicating O won
;-----------------------------------------------------------------
; Restore the registers and return with exit code in R1
;-----------------------------------------------------------------
EV_EXIT		LD	R0, EV_R0	; Restore R0
		LD	R2, EV_R2	; Restore R2
		LD	R3, EV_R3	; Restore R3
		LD	R4, EV_R4	; Restore R4
		LD	R5, EV_R5	; Restore R5
		LD	R6, EV_R6	; Restore R6
		LD	R7, EV_R7	; Restore R7
		RET
EV_TOPLEFT_ADDR	.FILL	x30FC ;EV_TOPLEFT_ADDR	.FILL	x30F7
EV_FULLBOARD	.BLKW 	1		
EV_R0		.BLKW	1
EV_R2 		.BLKW	1
EV_R3 		.BLKW	1
EV_R4		.BLKW	1
EV_R5		.BLKW	1
EV_R6 		.BLKW	1
EV_R7 		.BLKW	1
;-----------------------------------------------------------------
; *** DO NOT MODIFY ANY CODE ABOVE THIS LINE! ***
; *** MAKE ALL YOUR CHANGES AND ADDITIONS BELOW THIS LINE! ***
;-----------------------------------------------------------------
; JumpTable
; ---------
; You should update this table with the address of your 
; subroutines.  
;
; EVALBOARD_ADDR stays as is.
;-----------------------------------------------------------------
EVALBOARD_ADDR		.FILL	x3105
GETVALIDINPUT_ADDR	.FILL	x3255
UPDATEBOARD_ADDR	.FILL	x328B
DRAWBOARD_ADDR		.FILL	x32A8
PRINTOUTCOME_ADDR	.FILL	x32DB
;-----------------------------------------------------------------
; Extend to the end of page x18 (up to and including address x31FF)
;----------------------------------------------------------------- 
PAGEFILLER	.BLKW   91 ;PAGEFILLER	.BLKW   96
;-----------------------------------------------------------------
; Page x19 Pointer table to page x18 constants
;
; Use this table when you need to reference items on the previous 
; page.
;-----------------------------------------------------------------
; The next line starts at address x3200
;-----------------------------------------------------------------
USERPROMPT_ADDR	.FILL	x30DA ;USERPROMPT_ADDR	.FILL	x30D5
PLAYER_ADDR	.FILL	x30FB
TOPLEFT_ADDR	.FILL	x30FC
ROW1_ADDR	.FILL	x3020
ROW2_ADDR	.FILL	x302C
ROW3_ADDR	.FILL	x3038
ROW4_ADDR	.FILL	x3044	
ROW5_ADDR	.FILL	x3050
ROW6_ADDR	.FILL	x305C
ROW7_ADDR	.FILL	x3068
ROW8_ADDR	.FILL	x3074
ROW9_ADDR	.FILL	x3080
ROW10_ADDR	.FILL	x308C
ROW11_ADDR	.FILL	x3098
ASCII__X	.FILL	x0058 ; Notice there are two underscores
ASCII__O	.FILL	x004F 
NEW_LINE	.FILL	x000A 
;-----------------------------------------------------------------
; Constants for page x19
; Put your own constants here
;-----------------------------------------------------------------

GETVALIDINPUTR0	.FILL	#0
GETVALIDINPUTR2	.FILL	#0
GETVALIDINPUTR7	.FILL	#0
NEGDEC		.FILL	#-48
ASCII_Q		.FILL	#-113
ASCII_SP	.FILL	#-32
INPUTERRMSG	.STRINGZ	"Invalid input"
SPACEOCCUPIED	.STRINGZ	"Space occupied"

UPDATEBOARDR0	.FILL	#0
UPDATEBOARDR2	.FILL	#0
UPDATEBOARDR3	.FILL	#0

DRAWBOARDR0	.FILL	#0
DRAWBOARDR7	.FILL	#0

PRINTOUTCOMER0	.FILL	#0
PRINTOUTCOMER7	.FILL	#0
XMSG		.STRINGZ	"X Wins!"
OMSG		.STRINGZ	"O Wins!"
CATMSG		.STRINGZ	"Cat Game!"
;-----------------------------------------------------------------
; GETVALIDINPUT subroutine 
; Args:
;	R1 - When subroutine returns, this register 
;	     contains the input, ASCII 1-9, or ASCII 'q'.
; 
; 1. Prompt the current player for which square he/she wants.
; 2. If the player inputs anything other than a number 1-9 or the 
;    letter 'q', print an error message and reprompt them.
; 3. If the player chooses an occupied square, print an error message
;    and reprompt them.
;-----------------------------------------------------------------

;Store any variables which will be modified
GETVALIDINPUT	ST	R0,GETVALIDINPUTR0 ;Store variables 
		ST	R2,GETVALIDINPUTR2
		ST	R7,GETVALIDINPUTR7


;Determine current player and output coresponding letter
INPUTCONT	LDI	R0, PLAYER_ADDR ;START OF INPUT LOOP
		BRz	PLAYERO 
PLAYERX		LD	R0, ASCII__X
		OUT
		BRnzp	INPUTCONT2
PLAYERO		LD	R0, ASCII__O
		OUT

;Get user input and determine if it is #1-9 or "q"
INPUTCONT2	LD	R0, USERPROMPT_ADDR 
		PUTS ;Prompt user
		GETC
		OUT ;Read and echo character
		ADD	R1,R0,#0 ; R1=R0 (Copy read character to R1)
		LD	R0, NEW_LINE
		OUT	;Output newline
		LD	R0, NEGDEC
		ADD	R0,R1,R0 ;Subtract #-48 to determine if character is at least "0"
		BRnz	INPUTERR
		ADD	R0,R0,#-10 ;Check if number is less than "9"
		BRzp	INPUTQCHK ; if input is >0 and >9 check for q
		BRn	INPUTAVAIL ;If input is 1-9, check availability

;Convert ASCII space to decimal and load address of space #1
INPUTAVAIL	LD	R0, NEGDEC
		ADD	R0,R1,R0 ;place decimal form of input into R0
		LD	R2, TOPLEFT_ADDR

;Checks input and loads appropriate memory location
INPUTAVAIL2	ADD	R0, R0, #-1
		BRz	INPUTCONT3
		ADD	R2, R2, #1 ;Increment memory
		BRnzp	INPUTAVAIL2


;If space is not a "space" character, return as occupied
INPUTCONT3	LDR	R0, R2, #0 ;Store space marked by R2 in R0
		LDR	R0, R0, #0
		LD	R2, ASCII_SP
		ADD	R0,R0,R2 ;Check if space is empty
		BRz 	INPUTRET
		BRnp	INPUTOCCUPIED

;Print error message ("Space occupied") and return to beginning of loop
INPUTOCCUPIED	LEA	R0, SPACEOCCUPIED
		PUTS
		LD	R0, NEW_LINE
		OUT	;Output newline
		BRnzp	INPUTCONT		

;Check if inputted character is "q" if not goto error subroutine
INPUTQCHK	LD	R0, ASCII_Q
		ADD	R0,R1,R0 ;Add #-113 (negative ASCII "q") and test
		BRz	INPUTRET ;GOTO Return
		BRnp	INPUTERR ;GOTO Error


;Print error message ("Invalid input") and go to start of input loop
INPUTERR	LEA	R0, INPUTERRMSG
		PUTS	;Output error message
		LD	R0, NEW_LINE
		OUT	;Output newline
		BRnzp	INPUTCONT ;Restart input loop

;Restore all modified variables and return
INPUTRET	LD	R0, GETVALIDINPUTR0 ;Restore Variables
		LD	R2, GETVALIDINPUTR2
		LD	R7, GETVALIDINPUTR7
		RET

;-----------------------------------------------------------------
; UPDATEBOARD subroutine
; Args:
;	R1 - contains an ASCII code for a number 1-9 
; 
; 1. Based on MEMORY[PLAYER] you know whether X or O just took a turn.
; 2. Store the appropriate charater (X or O) in memory to the middle
;    of the Tic-Tac-Toe square denoted by the contents of R1.
;    (i.e. MEMORY[PLAYER] = 1 and R1 = 7, store an 'X' in the
;    middle of the bottom-left square on the board.
;-----------------------------------------------------------------

;Store vallues which will be modified and check current player
UPDATEBOARD	ST	R0, UPDATEBOARDR0 ;Store values
		ST	R2, UPDATEBOARDR2
		ST	R3, UPDATEBOARDR3
		LDI	R2, PLAYER_ADDR
		BRz	UPDATEMAKEO

;Load ASCII value of current player to R2
UPDATEMAKEX	LD	R2, ASCII__X
		BRnzp	UPDATECONT
UPDATEMAKEO	LD	R2, ASCII__O

;Convert ASCII character (selected space) to a decimal number
UPDATECONT	LD	R0, NEGDEC
		ADD	R0, R1,R0 ;R0 contains decimal form of space number
		LD	R3, TOPLEFT_ADDR

;Increment memory until correct address is found
UPDATELOOP	ADD	R0, R0, #-1
		BRz	UPDATELOOP2
		ADD	R3, R3, #1 ;Increment memory
		BRnzp	UPDATELOOP
UPDATELOOP2	LDR	R3, R3, #0
		STR	R2, R3, #0 ;Store character in memory
		BRnzp	UPDATEBOARDRET


;Change current player
UPDATEBOARDRET	AND	R2, R2, #0
		LDI	R0, PLAYER_ADDR
		BRz	UPDATETOX
UPDATETOO	STI	R2, PLAYER_ADDR ;Store #0 in PLAYER
		BRnzp	UPDATEBOARDRET2
UPDATETOX	ADD	R2, R2, #1
		STI	R2, PLAYER_ADDR ;store #1 in PLAYER

;Restores modified values and returns
UPDATEBOARDRET2	LD	R0, UPDATEBOARDR0 ;Restore values and return
		LD	R2, UPDATEBOARDR2
		LD	R3, UPDATEBOARDR3
		RET


;-----------------------------------------------------------------
; DRAWBOARD - Print the board
;-----------------------------------------------------------------
DRAWBOARD 	ST	R0, DRAWBOARDR0 ;Store values
		ST	R7, DRAWBOARDR7

;Each block loads the address of a line and a newline then prints them one after another.
		LD	R0, ROW1_ADDR
		PUTS	;Load and print a row (repeat for all rows)
		LD	R0, NEW_LINE
		OUT	;Output newline

		LD	R0, ROW2_ADDR
		PUTS
		LD	R0, NEW_LINE
		OUT	;Output newline

		LD	R0, ROW3_ADDR
		PUTS
		LD	R0, NEW_LINE
		OUT	;Output newline

		LD	R0, ROW4_ADDR
		PUTS
		LD	R0, NEW_LINE
		OUT	;Output newline

		LD	R0, ROW5_ADDR
		PUTS
		LD	R0, NEW_LINE
		OUT	;Output newline

		LD	R0, ROW6_ADDR
		PUTS
		LD	R0, NEW_LINE
		OUT	;Output newline

		LD	R0, ROW7_ADDR
		PUTS
		LD	R0, NEW_LINE
		OUT	;Output newline

		LD	R0, ROW8_ADDR
		PUTS
		LD	R0, NEW_LINE
		OUT	;Output newline

		LD	R0, ROW9_ADDR
		PUTS
		LD	R0, NEW_LINE
		OUT	;Output newline

		LD	R0, ROW10_ADDR
		PUTS
		LD	R0, NEW_LINE
		OUT	;Output newline

		LD	R0, ROW11_ADDR
		PUTS
		LD	R0, NEW_LINE
		OUT	;Output newline
		LD	R0, NEW_LINE
		OUT	;Output newline (Two newlines for a cleaner look)

;Restores modified values and returns
DRAWBOARDRET	LD	R0, DRAWBOARDR0 ;Restore values and return
		LD	R7, DRAWBOARDR7
		RET


;-----------------------------------------------------------------
; PRINTOUTCOME subroutine
; Args : 
;	R1 - Contains a number 1-3
;		1 = X wins
;		2 = O wins
; 		3 = Cat Game
; 1. Print a message declaring the outcome of the game.
;-----------------------------------------------------------------
;Determines which number is contained in R1
PRINTOUTCOME	ST	R0, PRINTOUTCOMER0
		ST	R7, PRINTOUTCOMER7
		ADD R1, R1, #-1
		BRz	XWIN
		ADD R1, R1, #-1
		BRz	OWIN
		ADD R1, R1, #-1
		BRz	CATWIN	
		BRnzp	PRINTOUTCOMERET

;Loads the correct message		
XWIN		LEA	R0, XMSG
		BRnzp	OUTCOME2
OWIN		LEA	R0, OMSG
		BRnzp	OUTCOME2
CATWIN		LEA	R0, CATMSG
		BRnzp	OUTCOME2		

;Prints message showing winner and a newline
OUTCOME2	PUTS ;Print winning message
		LD	R0, NEW_LINE
		OUT	;Output newline
		BRnzp	PRINTOUTCOMERET

;Restores modified values and returns
PRINTOUTCOMERET	LD	R0, PRINTOUTCOMER0
		LD	R7, PRINTOUTCOMER7
		RET



		.END
