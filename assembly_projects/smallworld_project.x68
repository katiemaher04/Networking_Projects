*Created by: Katie Maher
*StudentID: C00294512
*Completed 07/03/25
*Description: A text-based game where you choose a character and weapons and then your chance of survival is based on the luck of a random dice roll
*Endless mode not working effectively, screen randomly clears in the middle of the loop instead of continuing
*-------------------------------------------------------
* STARTING MEMORY ADDRESS FOR THE PROGRAMME $1000
*-------------------------------------------------------
	ORG $1000
*-------------------------------------------------------
*CHOOSE TO BE A MINI KNIGHT OR A TINY EXPLORER
*-------------------------------------------------------

*-------------------------------------------------------
*VALIDATION VALUES TO BE USED, MODIFY AS NEEDED
*-------------------------------------------------------
EXIT		EQU 0			;USED TO EXIT ASSEMBLY PROGRAM
MIN_POTIONS	EQU 1			;MIN NUMBER OF SMALL POTIONS
MAX_POTIONS	EQU 9			;MAX NUMBER OF SMALL POTIONS
MIN_WEAPONS	EQU 1			;MIN WEAPONS (NEEDLE SWORD, ACORN SHIELD)
MAX_WEAPONS	EQU 3			;MAX WEAPONS
WIN_POINT	EQU 5			;BRAVERY POINTS GAINED ON SUCCESS
LOSE_POINT	EQU 8			;BRAVERY POINTS LOST ON FAILURE

DANGER_LOC  EQU 100         ;USED FOR SIMPLE COLLISION DETECTION
                            ;* EXAMPLE FOR A HIT (GIANT FOOTSTEP)

*START OF GAME
START:
    MOVE.B  #100,$4000      ;PUT BRAVERY POINTS IN MEMORY LOCATION $4000
    LEA     $4000,A3        ;ASSIGN ADDRESS A3 TO THAT MEMORY LOCATION

    BSR     WELCOME         ;BRANCH TO THE WELCOME SUBROUTINE
    BSR     GAME            ;BRANCH TO THE GAME SUBROUTINE

*GAME LOOP
    ORG     $3000           ;THE REST OF THE PROGRAM IS TO BE LOCATED FROM 3000 ONWARDS

*-------------------------------------------------------
*-------------------GAME SUBROUTINE---------------------
*-------------------------------------------------------
GAME:
    BRA     GAMELOOP        ;BRANCH TO GAMELOOP SUBROUTINE
    RTS                     ;RETURN FROM GAME: SUBROUTINE
          
END:
    SIMHALT

*-------------------------------------------------------
*-------------------WELCOME SUBROUTINE------------------
*-------------------------------------------------------
WELCOME:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    LEA     WELCOME_MSG,A1  ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     WELCOME_INPUT   ;BRANCH TO WELCOME_INPUT SUBROUTINE
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     CONTINUE        ;BRANCH TO CONTINUE SUBROUTINE 
    RTS                     ;RETURN FROM WELCOME: SUBROUTINE

WELCOME_INPUT:
    MOVE.B  #4, D0           ; Read a single character from user input
    TRAP    #15             
    CMP.B   #1, D1          ;COMPARE USER INPUT WITH 1
    BEQ     MINI_KNIGHT     ;BRANCH IF EQUAL TO MINI KNIGHT SUBROUTINE
    BLT     INVALID_CHAR
    CMP.B   #2, D1          ;COMPARE USER INPUT WITH 2
    BEQ     TINY_EXPLORER   ;BRANCH IF EQUAL TO TINY EXPLORER SUBROUTINE
    BGT     INVALID_CHAR    ;if any other character is entered, brach to invalid subroutine
    RTS  

MINI_KNIGHT:
    LEA     MINI_KNIGHT_MSG, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS

TINY_EXPLORER:
    LEA     TINY_EXPLORER_MSG, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
INVALID_CHAR:
    LEA     INVALID_MSG,A1  ; Load invalid input message
    MOVE.B  #14,D0          ; Print the message
    TRAP    #15             
    BRA     WELCOME_INPUT      ; Prompt again for input
*-------------------------------------------------------
*---------GAMEPLAY INPUT VALUES SUBROUTINE--------------
*-------------------------------------------------------    
INPUT:
    BSR     POTIONS         ;BRANCH TO POTION INPUT SUBROUTINE
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     CONTINUE        ;BRANCH TO CONTINUE SUBROUTINE
    BSR     WEAPONS         ;BRANCH TO WEAPONS INPUT SUBROUTINE
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     CONTINUE        ;BRANCH TO CONTINUE SUBROUTINE
    RTS

*-------------------------------------------------------
*----------------GAMELOOP (MAIN LOOP)-------------------
*------------------------------------------------------- 
GAMELOOP:
    BSR     INPUT           ;BRANCH TO INPUT SUBROUTINE
    BSR     UPDATE          ;BRANCH TO UPDATE GAME SUBROUTINE 
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN 
    BSR     DRAW            ;BRANCH TO DRAW GAME SUBROUTINE               
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN 
    BSR     GAMEPLAY        ;BRANCH TO GAMEPLAY SUBROUTINE
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN        
    BSR     HUD             ;BRANCH TO HUD SUBROUTINE
    ;BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN
    BSR     REPLAY          ;BRANCH TO REPLAY SUBROUTINE 
    BSR     CLEAR_SCREEN    ;CLEARS THE SCREEN
    RTS                     ;RETURN FROM GAMELOOP: SUBROUTINE       

*-------------------------------------------------------
*----------------UPDATE QUEST PROGRESS------------------
*  COMPLETE QUEST
*------------------------------------------------------- 
UPDATE:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE   
    LEA     UPDATE_MSG,A1   ;ASSIGN MESSAGE TO ADDRESS REGISTER A1 
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    RTS                     

*-------------------------------------------------------
*-----------------DRAW QUEST UPDATES--------------------
* DRAW THE GAME PROGRESS INFORMATION, STATUS REGARDING
* QUEST
*------------------------------------------------------- 
DRAW:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE            
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE    
    LEA     DRAW_MSG,A1     ;ASSIGN MESSAGE TO ADDRESS REGISTER A1     
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    RTS                     ;RETURN FROM DRAW: SUBROUTINE

*-------------------------------------------------------
*--------------------POTIONS INVENTORY---------------------
* NUMBER OF POTIONS TO BE USED IN A QUEST 
*------------------------------------------------------- 
POTIONS: 
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    LEA     POTIONS_MSG,A1  ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     POTION_INPUT    ;BRANCH TO SUBROUTINE TO INPUT AMOUNT OF POTIONS
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    RTS                     ;RETURN FROM POTIONS: SUBROUTINE
    
POTION_INPUT:
    MOVE.B  #4, D0           ; Read a single character from user input
    TRAP    #15             
    CMP.B   #MIN_POTIONS, D1 ; Compare input with MIN_POTIONS
    BLT     INVALID_INPUT   ; If less, go to INVALID_INPUT

    CMP.B   #MAX_POTIONS,D1 ; Compare input with MAX_POTIONS
    BGT     INVALID_INPUT   ; If greater, go to INVALID_INPUT
    RTS                     ; Return from subroutine

INVALID_INPUT:
    LEA     INVALID_MSG,A1  ; Load invalid input message
    MOVE.B  #14,D0          ; Print the message
    TRAP    #15             
    BRA     POTION_INPUT      ; Prompt again for input


*-------------------------WEAPONS-----------------------
* NUMBER OF WEAPONS
*-------------------------------------------------------   
WEAPONS:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    LEA     WEAPONS_MSG,A1  ;ASSIGN MESSAGE TO ADDRESS REGISTER A1      
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     WEAPONS_INPUT
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    RTS                     ;RETURN FROM WEAPONS: SUBROUTINE
    
WEAPONS_INPUT:
    MOVE.B  #4, D0           ; Read a single character from user input
    TRAP    #15             ; User input is stored in D1 
    CMP.B   #1, D1
    BEQ     NEEDLE_SWORD
    BLT     INVALID_WEAPON
    CMP.B   #2, D1
    BEQ     ACORN_SHIELD
    BGT     INVALID_WEAPON
    RTS
    
NEEDLE_SWORD:
    LEA     NEEDLE_MSG, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
ACORN_SHIELD:
    LEA     ACORN_MSG, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
INVALID_WEAPON:
    LEA     INVALID_MSG,A1  ; Load invalid input message
    MOVE.B  #14,D0          ; Print the message
    TRAP    #15             
    BRA     WEAPONS_INPUT      ; Prompt again for input
*-------------------------------------------------------
*---GAME PLAY (QUEST PROGRESS)--------------------------
*------------------------------------------------------- 
GAMEPLAY:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    LEA     GAMEPLAY_MSG,A1 ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    MOVE.B  #4,D0           ;MOVE LITERAL 4 TO DO               
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    BSR     RANDOM_ENEMY_POS      ;BRANCH TO RANDOM ENEMY POSITION SUBROUTINE
    RTS                     ;RETURN FROM GAMEPLAY: SUBROUTINE

*-------------------------------------------------------
*-----------------HEADS UP DISPLAY (SCORE)--------------
*-------------------------------------------------------   
HUD:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE
    LEA     HUD_MSG,A1      ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    MOVE.B  (A3),D1         ;RETRIEVE THE VALUE A3 POINT TO AND MOVE TO D1
    MOVE.B  #3,D0           ;MOVE LITERAL 3 TO DO    
    TRAP    #15             
    CMP.L   #110, D1        ;COMPARE FINAL SCORE WITH 110
    BLT     FINISH1         ;IF LESS THAN, BRANCH TO THE FIRST FINISH SUBROUTINE
    
    CMP.L   #160, D1        ;COMPARE SCORE WITH 160
    BLT     FINISH2         ;IF < BRANCH TO FINISH2
    BGE     FINISH3         IF >= BRANCH TO FINISH3
     
    BSR     DECORATE        ;BRANCH TO DECORATE SUBROUTINE    
    RTS                     

FINISH1:
    LEA     FINISH_MSG1, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
FINISH2:
    LEA     FINISH_MSG2, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
    
FINISH3:
    LEA     FINISH_MSG3, A1
    MOVE.B  #14, D0
    TRAP    #15
    RTS
*-------------------------------------------------------
*-----------------------BEING ATTACKED------------------
* THIS COULD BE USED FOR COLLISION DETECTION
*COLLISION DETECTION WORKS AS TWO DICE ROLLS FROM 1-20
*IF THE TWO NUMBERS GENERATED ARE THE SAME THEN COLLISION OCCURS
*-------------------------------------------------------
RANDOM_ENEMY_POS:
    MOVE.B #8, D0           ; Load immediate value 8 into Data Register D0 (for system call code related to random number generation)
    TRAP #15                ; Trap to BIOS service (generating random number or handling internal system functions)

    AND.L #$7FFFF, D1      ; Perform a bitwise AND with D1 and the mask $7FFFF to limit the randomness to a specific range
    DIVU #30, D1           ; Divide unsigned value in D1 by 20, result goes into D1 (this reduces the range of the random value)

    SWAP D1                 ; Swap the high and low parts of D1 (to manipulate the number format)

    ADDQ.W #1, D1           ; Add 1 to the value in D1 (to adjust the final result)

    MOVE.W D1, D2           ; Move the value in D1 to D2 to preserve it for later use

    CLR.L D1                ; Clear D1 register to prepare for further operations
    
RANDOM_PLAYER_POS:
    MOVE.B #8, D0           ; Load immediate value 8 into Data Register D0 (for system call code related to random number generation)
    TRAP #15                ; Trap to BIOS service (generating random number or handling internal system functions)

    AND.L #$7FFFF, D1      ; Perform a bitwise AND with D1 and the mask $7FFFF to limit the randomness to a specific range
    DIVU #20, D1           ; Divide unsigned value in D1 by 30, result goes into D1 (this reduces the range of the random value)

    SWAP D1                 ; Swap the high and low parts of D1 (to manipulate the number format)

    ADDQ.W #1, D1           ; Add 1 to the value in D1 (to adjust the final result)

    MOVE.W D1, D3           ; Move the value in D1 to D3 to preserve it for later use

    CLR.L D1                ; Clear D1 register to prepare for further operations
    
COLLISION:                  
    MOVE.B  D2,D1           ;MOVE RANDOM ENEMY POSITION TO D1
    CMP     D3,D1            ;ARE PLAYER AND ENEMY POSITIONS THE SAME?
    BNE     COLLISION_MISS  ;  IF NOT, BRANCH TO COLLISION_MISS
    BSR     COLLISION_HIT   ;  ELSE, BRANCH TO COLLISION_HIT
    RTS                     ;RETURN FROM COLLISION: SUBROUTINE  
COLLISION_HIT:
    LEA     HIT_MSG,A1      ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE    #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     LOSE_POINTS
    RTS                     ;RETURN FROM COLLISION_HIT: SUBROUTINE
    
COLLISION_MISS:
    LEA     MISS_MSG,A1		;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE    #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    BSR     ADD_POINTS
    RTS                     ;RETURN FROM COLLISION_MISS: SUBROUTINE

LOSE_POINTS:
    MOVE.B (A3),D1
    SUB.B   #20, D1 ;SUBTRACT LOSING POINTS FROM BRAVERY POINTS
    MOVE.B  D1, (A3)
    MOVE.B  #3,D0           ;MOVE LITERAL 3 TO DO    
    TRAP    #15  
    RTS
ADD_POINTS:
    MOVE.B  (A3),D1         
    ADD.B   #10, D1   ;ADD WINNING POINTS TO BRAVERY POINTS
    MOVE.B  D1, (A3)
    MOVE.B  #3,D0           ;MOVE LITERAL 3 TO DO    
    TRAP    #15  
    BRA     GAMEPLAY    ;LOOP CONTINUES UNTIL PLAYER IS ATTACKED
*-------------------------------------------------------
*--------------------------LOOP-------------------------
*-------------------------------------------------------
LOOP:
    MOVE.B  #5, D3          ;LOOP COUNTER D3=5
NEXT:
    LEA     LOOP_MSG,A1     ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO          
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    SUB     #1,D3           ;DECREMENT LOOP COUNTER
    BNE     NEXT            ;REPEAT UNTIL D0=0

*-------------------------------------------------------
*------------------SCREEN DECORATION--------------------
*-------------------------------------------------------
DECORATE:
    MOVE.B  #60, D3         ;LOOP COUNTER D3=60
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
OUT:
    LEA     LOOP_MSG,A1     ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    SUB     #1,D3           ;DECREMENT LOOP COUNTER
    BNE     OUT             ;REPEAT UNTIL D0=0
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    RTS                     ;RETURN FROM DECORATE: SUBROUTINE
    
CLEAR_SCREEN: 
    MOVE.B  #11,D0          ;CLEAR SCREEN
    MOVE.W  #$FF00,D1       ;SET COLOUR
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    RTS                     ;RETURN FROM CLEAR_SCREEN: SUBROUTINE                

*-------------------------------------------------------
*------------------------REPLAY-------------------------
*-------------------------------------------------------
REPLAY:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    LEA     REPLAY_MSG,A1   ;ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          ;MOVE LITERAL 14 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    
    MOVE.B  #4,D0           ;MOVE LITERAL 4 TO DO
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0

    CMP     #EXIT,D1        ;COMPARE D1 TO EXIT
    BEQ     END             ;IF EQUAL, BRANCH TO END
    BSR     GAMEPLAY        ;BRANCH TO GAMEPLAY SUBROUTINE
    
*-------------------------------------------------------
*------------------------CONTINUE-------------------------
*-------------------------------------------------------
CONTINUE:
    BSR     ENDL            ;BRANCH TO ENDL SUBROUTINE
    RTS                     ;RETURN FROM SUBROUTINE 

ENDL:
    MOVEM.L D0/A1,-(A7)     ;SAVE D0 AND A1
    MOVE    #14,D0          ;MOVE LITERAL 14 TO DO
    LEA     CRLF,A1         ;ASSIGN CRLF TO ADDRESS REGISTER A1
    TRAP    #15             ;TRAP AND INTERPRET VALUE IN D0
    MOVEM.L (A7)+,D0/A1     ;RESTORE D0 AND A1
    RTS                     ;RETURN FROM ENDL: SUBROUTINE
    
*-------------------------------------------------------
*-------------------DATA DECLARATIONS--------------------
*-------------------------------------------------------

CRLF:           DC.B    $0D,$0A,0
WELCOME_MSG:    DC.B    '************************************************************'
                DC.B    $0D,$0A
                DC.B    'WELCOME TO THE MINIATURE KINGDOM! '
                DC.B    $0D,$0A
                DC.B    'CHOOSE YOUR ADVENTURER:'
                DC.B    $0D,$0A
                DC.B    '1. MINI KNIGHT (TINY BUT BRAVE)'
                DC.B    $0D,$0A
                DC.B    '2. TINY EXPLORER (FAST AND CLEVER)'
                DC.B    $0D,$0A
                DC.B    '************************************************************'
                DC.B    $0D,$0A,0
POTIONS_MSG:    DC.B    'COLLECT SMALL POTIONS TO SHRINK! ENTER QUANTITY: ',0
WEAPONS_MSG:    DC.B    'EQUIP TINY WEAPONS: 1. NEEDLE SWORD, 2. ACORN SHIELD.',0
GAMEPLAY_MSG:   DC.B    'TINY ADVENTURE BEGINS!',0
UPDATE_MSG:     DC.B    'UPDATING QUEST STATUS...',0
DRAW_MSG:       DC.B    'REDRAWING MINIATURE WORLD...',0
HIT_MSG:        DC.B    'OH NO! STEPPED ON BY A GIANT!',0
MISS_MSG:       DC.B    'SAFE! HID UNDER A LEAF.',0
LOOP_MSG:       DC.B    '.',0
REPLAY_MSG:     DC.B    'ENTER 0 TO QUIT, ANY OTHER NUMBER TO CONTINUE: ',0
CONTINUE_MSG:   DC.B    'PRESS ANYKEY TO CONTINUE: ',0
HUD_MSG:        DC.B    'BRAVERY POINTS: ',0
INVALID_MSG:    DC.B    'INVALID! ENTER A VALID NUMBER:',0
MINI_KNIGHT_MSG DC.B    'YOU ARE A MINI KNIGHT! PREPARE TO FIGHT WITH COURAGE!',0
TINY_EXPLORER_MSG DC.B  'YOU ARE A TINY EXPLORER! DEFEND AND PROTECT THE BITE-SIZED LANDS!',0
NEEDLE_MSG      DC.B    'NEEDLE SWORD! MINATURE ATTACK!',0
ACORN_MSG       DC.B    'ACORN SHIELD! NO FOE BIG OR SMALL CAN GET TO YOU!',0
FINISH_MSG1     DC.B    $0D,$0A
                DC.B    'YOU DID NOT STAND A CHANCE!',0
FINISH_MSG2     DC.B    $0D,$0A
                DC.B    'GOOD EFFORT!',0
FINISH_MSG3     DC.B    $0D,$0A
                DC.B    'THE GIANTS ARE SCARED OF YOU!',0
HEALTH:         DS.W    1   ;PLAYERS HEALTH
SCORE:          DS.W    1   ;RESERVE SPACE FOR SCORE


    END START







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
