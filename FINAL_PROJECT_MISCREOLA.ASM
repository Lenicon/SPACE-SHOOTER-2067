; Filename: FINAL_PROJECT_MISCREOLA.ASM
; Name: Hertz Lenin C. Miscreola
; Date: November 25, 2025
; Description:
; SPACE SHOOTER 2067
; Press A and D to move left and right, and W to shoot bullet.
; You can have your own account.
; Up to 3 accounts can be registered.

;=============================
; Macro: newline
; Puts a newline
;=============================
newline macro
    mov ah,02h
    mov dl, 0ah
    int 21h
endm

;==============================
; Macro: setCursor
; Puts the cursor to row and col
;==============================
setCursor MACRO r, c
  mov al, r
  mov row, al
  mov al, c
  mov col, al
  call setCursorProc
ENDM

;==============================
; Macro: drawChar
; Draws a character at a specified row and column with a color attribute
; Parameters:
; r - row
; c - column
; ch - character to display
; attr - color attribute
;==============================
drawChar MACRO r, c, char, attr
  setCursor r, c
  mov al, char
  mov character, al
  mov al, attr
  mov color, al
  call drawCharProc
ENDM

;==============================
; Macro: eraseChar
; Erases a character at a specified row and column (draws space)
;==============================
eraseChar MACRO r, c
drawChar r, c, ' ', 07h
ENDM

;==============================
; Macro: showText
; Displays text given in the console
;==============================
showText MACRO text
  lea dx,text
  mov ah,09h
  int 21h
ENDM


;==============================
; Macro: compareInput
; Compares inputs and sends to fail if not equal
; a - Stored info
; b - Inputted info
; fail - Label to jump if fail
;==============================
compareInput MACRO a, b, fail
  MOV DI, OFFSET a
  MOV SI, OFFSET b
  CALL CompareString
  CMP AL, 1
  jne fail
endm


;==============================
; Macro: storeInput
; Stores inputs to storage
; a - Storage where input goes
; b - Input that will be stored
;==============================
storeInput macro a, b
  MOV DI, OFFSET a
  MOV SI, OFFSET b
  CALL copyString
endm


.model small
.stack 100h
.data
  ; For procedures
  row db 0
  col db 0
  character db 'A'
  color db 07h


  ; For login/register
  nametxt db "SPACE SHOOTER 2067$"
  signuptxt db "SIGNUP $"
  logintxt db "LOGIN $"
  formtxt db "FORM$"
  instruction1 db "Press 1 to $"
  instruction2 db "Press 2 to QUIT$"
  switcher db 0

  loginFailMsg db "Incorrect Username / Password!$"
  signupFailMsg db "Max Registered Users Reached!$"
  signupSuccMsg db "Registered sucessfully, please login.$" 

  promptUser db "Enter username  (5 letters): $"
  promptPass db "Enter password (5 letters): $"
  userInput    db 6 DUP('$')
  passInput    db 6 DUP('$')
  
  userStored_1   db 6 DUP('$')
  passStored_1   db 6 DUP('$')
  registered_1   db 0   ; 0 = no user yet, 1 = user exists
  highscore_1 dw 0

  userStored_2   db 6 DUP('$')
  passStored_2   db 6 DUP('$')
  registered_2   db 0   ; 0 = no user yet, 1 = user exists
  highscore_2 dw 0

  userStored_3   db 6 DUP('$')
  passStored_3   db 6 DUP('$')
  registered_3   db 0   ; 0 = no user yet, 1 = user exists
  highscore_3 dw 0

  current_user db 0
  score dw 0

  ; For random generation
  seed dw ?
  rand_range db 59 ; Divisor for the range [0, 58]
  rand_num db 0

  player db 'A','$'
  enemy db 'W', '$'
  bullet db '|', '$'

  player_x db 29
  player_y db 15
  player_old_x db 9

  bullet_current_y db 14
  bullet_current_x db 0
  bullet_old_y db 14
  bullet_active db 0

  enemy_spawn_y db 3
  enemy_current_x db 0
  enemy_current_y db 3
  enemy_old_y db 4
  enemy_active db 0
  enemy_can_move db 0
  enemy_max_y db 16


  timer db 51
  prev_second db 255

  titleMsg db 'Welcome to SPACE SHOOTER 2067','$'
  creditMsg db 'Made by Hertz Lenin C. Miscreola',13,10,'$'
  controlsMsg db 'Controls: A = Move Left | D = Move Right | W = Shoot Up',13,10,'$'
  controlsMsg2 db 'Controls:',13,10,'               A = Move Left',13,10,'               D = Move Right',13,10,'               W = Shoot Up','$'
  playMsg db 'Press P to Play','$'
  quitMsg db 'Press Q to Quit','$'
  delaccMsg db 'Press 0 to Delete Account$'
  
  exitMsg db 'Thanks for playing!',13,10,'$'
  highscoreMsg db 'High-Score: ','$'
  scoreMsg db 'Score: ','$'
  timerMsg db 'Timer: ','$'

  line db 13,10,'----------------------------------------------------------','$'

.code

;==============================
; MAIN PROCEDURE
;==============================
main proc
  mov ax,@data
  mov ds,ax
  ; ask for login
  jmp signupForm
  ; call signupForm



;=================================
; SIGNUP FORM PROCEDURE
;=================================
signupForm:
  ; Switch switcher to 0 to indicate its signup
; startsignup:

  cmp registered_1, 0
  je allowsignup
  cmp registered_2, 0
  je allowsignup
  cmp registered_3, 0
  je allowsignup

  setCursor 8, 0
  showText signupFailMsg
  call waitKey
  jmp loginForm

  allowsignup:

  mov switcher, 0
  
  ; Clear Screen
  call clearScreen

  setCursor 0, 0
  showText nametxt

  newline
  showText instruction1
  showText logintxt

  newline
  showText instruction2
  
  newline
  newline
  showText signuptxt
  showText formtxt

  ; Ask for username
  newline
  showText promptUser
  MOV SI, OFFSET userInput
  call readString
  
  ; Check if theres space to store a user
  cmp registered_1, 0
  jne cannot_store_in_user1
  can_store_in_user1:
    storeInput userStored_1, userInput
    mov current_user, 1 ; Set current user
    jmp end_storing_user
  cannot_store_in_user1:

  cmp registered_2, 0
  jne cannot_store_in_user2
  can_store_in_user2:
    storeInput userStored_2, userInput
    ; mov al, 2
    mov current_user, 2 ; Set current user
    jmp end_storing_user
  cannot_store_in_user2:

  cmp registered_3, 0
  jne cannot_store_in_user3
  can_store_in_user3:
    storeInput userStored_3, userInput
    ; mov al, 3
    mov current_user, 3 ; Set current user
    jmp end_storing_user
  cannot_store_in_user3:

  end_storing_user:

  ; Ask user for password
  ; newline
  showText promptPass
  MOV SI, OFFSET passInput
  call readString

  ; Place password in current user
  cmp current_user, 1
  jne not_stored_pass_1
  stored_pass_1:
    storeInput passStored_1, passInput
    mov al, 1
    mov registered_1, al
    jmp end_storing_pass
  not_stored_pass_1:

  cmp current_user, 2
  jne not_stored_pass_2
  stored_pass_2:
    storeInput passStored_2, passInput
    mov al, 1
    mov registered_2, al
    jmp end_storing_pass
  not_stored_pass_2:

  cmp current_user, 3
  jne not_stored_pass_3
  stored_pass_3:
    storeInput passStored_3, passInput
    mov al, 1
    mov registered_3, al
    jmp end_storing_pass
  not_stored_pass_3:

  newline
  showText signupFailMsg

  call waitKey
  jmp signupForm

  end_storing_pass:

  newline
  showText signupSuccMsg

  call waitKey
  jmp loginForm



;=================================
; LOGIN FORM PROCEDURE
;=================================
loginForm:
startlogin:
  ; Switch switcher to 1 to indicate its login
  mov score, 0
  mov player_x, 29
  mov switcher, 1

  ; Clear Screen
  call clearScreen
  
  setCursor 0, 0
  showText nametxt

  newline
  showText instruction1
  showText signuptxt

  newline
  showText instruction2

  newline
  newline
  showText logintxt
  showText formtxt

  ; Ask for username
  newline
  showText promptUser
  MOV SI, OFFSET userInput
  call readString

  compareInput userStored_1, userInput, login_not_user1
  jmp goto_password_login
  
  login_not_user1:
  compareInput userStored_2, userInput, login_not_user2
  jmp goto_password_login
  
  login_not_user2:
  compareInput userStored_3, userInput, login_fail

  goto_password_login:
  ; Ask for password
  ; newline
  showText promptPass
  MOV SI, OFFSET passInput
  call readString

  compareInput passStored_1, passInput, pass_not_user1
  mov current_user, 1
  jmp goto_mainmenu_game
  
  pass_not_user1:
  compareInput passStored_2, passInput, pass_not_user2
  mov current_user, 2
  jmp goto_mainmenu_game
  
  pass_not_user2:
  compareInput passStored_3, passInput, login_fail
  mov current_user, 3

  goto_mainmenu_game:

  jmp mainMenu

login_fail:
  newline
  showText loginFailMsg
  call waitKey
  jmp startlogin




; GAME MAIN MENU AFTER LOGIN
mainMenu:
  ; Clear Screen
  call clearScreen

  ; Display Main Menu
  setCursor 0, 21
  showText titleMsg

  setCursor 1, 20
  showText creditMsg

  setCursor 3, 15
  showText controlsMsg2
  
  setCursor 3, 46
  showText scoreMsg
  mov ax, [score]
  call printNum

  setCursor 4, 41
  showText highscoreMsg
  
  cmp current_user, 1
  jne not_hs_1
  hs_1:
    mov ax, [highscore_1]
    jmp print_hs
  not_hs_1:



jmp ignoreportal3
portal2loginForm2:
  jmp loginForm
ignoreportal3:



  cmp current_user, 2
  jne not_hs_2
  hs_2:
    mov ax, [highscore_2]
    jmp print_hs
  not_hs_2:

  cmp current_user, 3
  jne not_hs_3
  hs_3:
    mov ax, [highscore_3]
    jmp print_hs
  not_hs_3:
  
  print_hs:
  call printNum

  setCursor 8, 28
  showText playMsg

  setCursor 9, 28
  showText quitMsg
  setCursor 10, 22
  showText delaccMsg

  askAgain:

  mov ah,07h
  int 21h
  cmp al, 'Q'
  je portal2loginForm2
  cmp al, 'q'
  je portal2loginForm2
  cmp al, 'P'
  je startGame
  cmp al, 'p'
  je startGame
  cmp al, '0'
  jne dont_delete_account
    call deleteAccount
    jmp portal2loginForm2
  dont_delete_account:
  
  jmp askAgain

  startGame:
  call clearScreen

  ; Initialize drawings
  showText controlsMsg
  showText scoreMsg
  setCursor 1, 20
  showText timerMsg
  showText line
  drawChar player_y, player_x, 'A', 0Eh


  ; Reset variables
  mov timer, 51
  mov enemy_active, 0
  mov bullet_active, 0
  mov score, 0


  jmp gameLoop

exitGame:
  call exitProg

gameLoop:

  ;--- Draw UI ---;
  setCursor 1, 7
  mov ax, [score]
  call printNum
  setCursor 1, 27
  xor ax, ax
  mov al, timer
  call printNum
  call rng

  ; xor ax, ax
  ; mov al, rand_num
  ; call printNum

  ;--- End Draw GUI ---;


  ; Spawn Enemy if no enemy is active
  cmp enemy_active, 1
  je activeEnemy
  call spawnEnemy
  activeEnemy:
    ; Run enemy logic procedure if enemy is active
    call enemyLogic


  cmp bullet_active, 0
  je inactiveBullet
  call bulletLogic
  inactiveBullet:

  call updateTimer
  cmp al, timer
  je endGame

  ;--- Input Handling ---;
  call getInput

  ; Keep game looping and running if no input
  ; cmp al, 0
  ; je noInput
  
  cmp al, 'Q'
  je endGame
  cmp al, 'q'
  je endGame
  cmp al, 'A'
  je moveLeft
  cmp al, 'a'
  je moveLeft
  cmp al, 'D'
  je moveRight
  cmp al, 'd'
  je moveRight
  cmp al, 'W'
  je shootUp
  cmp al, 'w'
  je shootUp

  jmp keepLooping
  ;--- End Input Handling ---;

shootUp:
  call shootUpProc
  jmp gameLoop
moveLeft:
  call moveLeftProc
  jmp gameLoop
moveRight:
  call moveRightProc
keepLooping:
  jmp gameLoop

jmp ignoreportal2
portal2loginForm:
  jmp loginForm
ignoreportal2:

jmp ignoreportal1
portal2signupForm:
  jmp signupForm
ignoreportal1:
  

endGame:
  mov ax, score        ; AX = score
  
  mov bl, current_user

  user_1a:
    cmp bl, 1
    jne user_2a
    cmp ax, highscore_1    ; compare AX with highscore
    jbe notGreater       ; Jump if Below or Equal (score <= highscore)
    jmp continue_setting_highscore

  user_2a:
    cmp bl, 2
    jne user_3a
    cmp ax, highscore_2    ; compare AX with highscore
    jbe notGreater       ; Jump if Below or Equal (score <= highscore)
    jmp continue_setting_highscore

  user_3a:
    cmp bl, 3
    jne no_current_user
    cmp ax, highscore_3    ; compare AX with highscore
    jbe notGreater       ; Jump if Below or Equal (score <= highscore)

  continue_setting_highscore:
  ; ---- score > highscore ----
  mov bl, current_user
  ; Check which user is currently logged in and then update their highscore
  user_1b:
    cmp bl, 1
    jne user_2b
    mov highscore_1, ax    ; update highscore
    jmp finish_setup_hs

  user_2b:
    cmp bl, 2
    jne user_3b
    mov highscore_2, ax    ; update highscore
    jmp finish_setup_hs
  
  user_3b:
    cmp bl, 3
    jne no_current_user
    mov highscore_3, ax    ; update highscore
  
  finish_setup_hs:
  no_current_user:
  notGreater:
  jmp mainMenu



;==============================================
; FORM PROCEDURES
;==============================================
;--------------------------------------------
; Read string into userInput/passInput
; stops at Enter
;--------------------------------------------
readString PROC
    ; MOV SI, OFFSET userInput
    XOR CX, CX

ReadLoop:
    MOV AH, 1
    INT 21H         ; AL = key pressed

    ; ==== CHECK KEYS ====
    CMP AL, '1'
    jne dontcheckswitcher
    ;   ; check if its in login or registration form and switch accordingly
    ;   ; if 1 - loginform
    ;   ; if 0 - registerform
      ; mov al, switcher
    
      cmp switcher, 1
      je portal2signupForm
      cmp switcher, 0
      je portal2loginForm
    
    dontcheckswitcher:
    
    CMP AL, '2'
    jne dontexitgame
    call exitProg
    dontexitgame:

    ; ==== ENTER KEY ====
    CMP AL, 13
    JE DoneRead

    ; ==== NORMAL CHARACTER ====
    MOV [SI], AL
    INC SI
    INC CX
    CMP CX, 5     ; limit input to 5
    JE limitReachedNewline
    JMP ReadLoop

limitReachedNewline:
    newline
DoneRead:
    MOV BYTE PTR [SI], '$'
    RET
readString ENDP


;---------------------------------------------
; Copy string SI → DI
;---------------------------------------------
copyString PROC
CopyLoop:
    MOV AL, [SI]
    MOV [DI], AL
    CMP AL, '$'
    JE CopyDone
    INC SI
    INC DI
    JMP CopyLoop

CopyDone:
    RET
copyString ENDP

;---------------------------------------------
; Compare two strings (DI vs SI)
; returns AL=1 if match, 0 if not
;---------------------------------------------
compareString PROC
CompareLoop:
    MOV AL, [SI]
    MOV BL, [DI]
    CMP AL, BL
    JNE NotMatch
    CMP AL, '$'
    JE Match
    INC SI
    INC DI
    JMP CompareLoop

Match:
    MOV AL, 1
    RET

NotMatch:
    MOV AL, 0
    RET
compareString ENDP

;---------------------------------------------
; Wait for key press
;---------------------------------------------
waitKey PROC
    MOV AH, 7
    INT 21H
    RET
waitKey ENDP


deleteAccount proc

  mov al, current_user

  cmp al, 1
  jne dont_delete_user1
    mov byte ptr userStored_1, '$'
    mov byte ptr passStored_1, '$'
    mov highscore_1, 0
    mov registered_1, 0
    jmp finish_deleting
  dont_delete_user1:

  cmp al, 2
  jne dont_delete_user2
    mov byte ptr userStored_2, '$'
    mov byte ptr passStored_2, '$'
    mov highscore_2, 0
    mov registered_2, 0
    jmp finish_deleting
  dont_delete_user2:

  cmp al, 3
  jne dont_delete_user3
    mov byte ptr userStored_3, '$'
    mov byte ptr passStored_3, '$'
    mov highscore_3, 0
    mov registered_3, 0
    jmp finish_deleting
  dont_delete_user3:

  finish_deleting:
  ret
deleteAccount endp

;========================================
; END FORM PROCEDURES
;========================================



;==============================
; Player Input Handling procedures
;==============================
moveLeftProc proc   ; move player to the left
  mov al, player_x
  mov player_old_x, al
  cmp al, 0
  jne toLeft
  
  ; Looping player around
  mov player_x, 58  ; teleport to the very right
  jmp exitMoveLeft

  toLeft:
  dec al
  mov player_x, al

  exitMoveLeft:
  eraseChar player_y, player_old_x
  drawChar player_y, player_x, 'A', 0Eh
  ret
moveLeftProc endp

moveRightProc proc   ; move player to the very left
  mov al, player_x
  mov player_old_x, al
  cmp al, 58
  jne toRight
  
  ; Looping player around
  mov player_x, 0  ; teleport to the very left
  jmp exitMoveRight

  toRight:
  inc al
  mov player_x, al

  exitMoveRight:
  eraseChar player_y, player_old_x
  drawChar player_y, player_x, 'A', 0Eh
  ret
moveRightProc endp

shootUpProc proc
  cmp bullet_active, 1
  je exitShootUp
  
  mov bullet_active, 1
  mov bullet_current_y, 14
  mov bullet_old_y, 14
  mov al, player_x
  mov bullet_current_x, al

  ; drawChar bullet_current_y, bullet_current_x, '|', 0BH 

  exitShootUp:
    ret
shootUpProc endp


;==============================
; Bullet Logic procedure
;==============================
bulletLogic PROC
  ; move bullets up
  mov al, bullet_current_y
  mov bullet_old_y, al
  dec al
  cmp bullet_current_y, 4
  je bulletDespawn

  mov bullet_current_y, al
  ; eraseChar bullet_old_y, bullet_current_x
  drawChar bullet_current_y, bullet_current_x, '|', 0BH

  ; Check if bullet and enemy aligns in x axis
  mov al, bullet_current_x
  cmp enemy_current_x, al
  jne jumpToBulletMiss1
  
  ; Check if bullet and enemy aligns in y axis
  mov al, bullet_current_y
  cmp enemy_current_y, al
  jne jumpToBulletMiss1

  bulletHit:
    ; If enemy gets hit by bullet
    mov ax, score
    add ax, 10
    mov score, ax
    mov enemy_active, 0
    mov enemy_can_move, 0
    eraseChar enemy_current_y, enemy_current_x

  bulletDespawn:
    ; bullet disappears
    call delay
    mov bullet_active, 0
    eraseChar 14, bullet_current_x
    eraseChar 13, bullet_current_x

    jmp bcontinue1
    jumpToBulletMiss1:
      jmp jumpToBulletMiss2
    bcontinue1:

    eraseChar 12, bullet_current_x
    eraseChar 11, bullet_current_x
    eraseChar 10, bullet_current_x

    jmp bcontinue2
    jumpToBulletMiss2:
      jmp jumpToBulletMiss3
    bcontinue2:

    eraseChar 9, bullet_current_x
    eraseChar 8, bullet_current_x
    eraseChar 7, bullet_current_x

    jmp bcontinue3
    jumpToBulletMiss3:
      jmp bulletMiss
    bcontinue3:

    eraseChar 6, bullet_current_x
    eraseChar 5, bullet_current_x
    eraseChar 4, bullet_current_x

  bulletMiss:
    ret
bulletLogic ENDP


;==============================
; Delay procedure
;==============================
delay PROC
    mov ah, 2Ch
    int 21h          ; DL = hundredths (0-99)
    mov bl, dl       ; store starting tick

waitLoop:
    mov ah, 2Ch
    int 21h
    sub dl, bl       ; elapsed = current - start
    jb wrapped       ; handle wrap around (99 -> 0)

    cmp dl, 50
    jb waitLoop      ; < 50 hundredths → keep waiting
    ret

wrapped:
    add dl, 100      ; fix wraparound difference
    cmp dl, 20
    jb waitLoop
    ret
delay ENDP


;==============================
; Enemy Logic procedure
;==============================
enemyLogic proc
  ; Enemy keeps moving downwards if active. Moves down per second.
  cmp enemy_can_move, 1
  jne enemyIdle
  enemyMove:
    mov enemy_can_move, 0
    mov al, enemy_current_y
    mov enemy_old_y, al
    eraseChar enemy_old_y, enemy_current_x
    inc enemy_current_y
    drawChar enemy_current_y, enemy_current_x, 'X', 04h
    
    ; Despawn if reaches the bottom
    mov al, enemy_current_y
    cmp enemy_max_y, al
    jne enemyIdle

    enemyDespawn:
      eraseChar enemy_current_y, enemy_current_x
      mov al, enemy_spawn_y
      mov enemy_current_y, al
      mov enemy_old_y, al
      mov enemy_active, 0
  
  enemyIdle:
  ret
enemyLogic endp

;==============================
; Set Cursor procedure
;==============================
setCursorProc proc
  mov ah, 02h
  mov bh, 00h
  mov dh, row
  mov dl, col
  int 10h
  ret
setCursorProc endp


;==============================
; Draw Character procedure
;==============================
drawCharProc proc
  mov ah,09h ; Write character at cursor
  mov al,character
  mov bl,color
  mov cx,1
  int 10h
  ret
drawCharProc endp


;==============================
; Spawn Enemy procedure
;==============================
spawnEnemy proc
  mov al, enemy_spawn_y
  mov enemy_current_y, al
  mov enemy_old_y, al
  mov al, rand_num
  mov enemy_current_x, al
  drawChar enemy_spawn_y, enemy_current_x, 'X', 04h
  mov enemy_active, 1
  ret
spawnEnemy endp

;==============================
; Timer procedure
;==============================
updateTimer PROC
getTime:
  mov ah, 2Ch
  int 21h             ; DH = seconds (00–59)

  cmp dh, prev_second
  je exitTimer        ; same second -> do nothing

  mov prev_second, dh ; store current second
  dec timer           ; decrease timer
  mov enemy_can_move, 1

exitTimer:

  ret

updateTimer ENDP



;==============================
; Random Number Generation procedure
;==============================
rng PROC
  
  mov ah, 2Ch      ; get system time
  int 21h          ; DL = hundredth of second (0-99)

  xor ax, ax
  mov al, dl       ; use time as seed

  mov bl, rand_range   ; range = 0 - 36
  div bl               ; AL / BL

  mov rand_num, ah ; remainder is now 0-36 (fits in db ✅)

  ret

rng ENDP


;==============================
; Input procedure
;==============================
getInput PROC
  mov ah,01h
  int 16h
  jz noKey         ; jump if no key pressed

  mov ah,00h
  int 16h          ; read key
  mov al, al       ; AL now has ASCII key
  ret

noKey:
  mov al,0
  ret
getInput ENDP


;=============================
; Clear screen procedure
;=============================
clearScreen proc
  mov ah,00h
  mov al,03h
  int 10h
  ret
clearScreen endp

;==============================
; Print numbers procedure
;==============================
printNum proc

  push bx
  push cx

  mov bx, 10
  xor cx, cx

  cmp ax, 0
  jne divide

  ; print '0'
  mov dl, '0'
  mov ah, 02h
  int 21h
  jmp done

  divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz divide

  print:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print

  done:
    pop cx
    pop bx
    ret

printNum endp


;===========================================================
; StrCmp: AL=0 if equal, 1 if different
;===========================================================
StrCmp proc
cmp_loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne notEq
    cmp al, 0
    je equals
    inc si
    inc di
    jmp cmp_loop
equals:
    mov al, 0
    ret
notEq:
    mov al, 1
    ret
StrCmp endp


;==============================
; Exit procedure
;==============================
exitProg proc
  ; Reset video mode
  mov ah,00h
  mov al,03h
  int 10h

  ; Display exit message
  showText exitMsg

  mov ah,4Ch           ; Terminate program
  int 21h
  jmp endme
exitProg endp

endme:
main endp
end main