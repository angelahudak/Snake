# __ARM and C99 Snake__
## _An In-Terminal Snake Game Made with Embedded Programming_

### Summary
    ARM Snake is the result of the final project (Exercise 12) for CMPE - 250 Assembly and Embedded Programming course provided at Rochester Institute of Technology. The program was created to be embedded on a FRDM board with a KL46z Central Processing Unit (CPU). The game will run in a terminal provided by a Serial COM port and the PuTTY application.

# Development
    In the development process our development team created a high-level pseudo-code in oder to flush out the functions/subroutines needed to achieve the desired functionality. The development process began by creating shells for these functions/subroutines that consisted of a commented header describing the parameters and return value(s) for each. For this the desired programming was created. Any additional solution code was added to fix any bugs or fatal issues that occured.
## Developers
- _Gabriel Dombrowski_
- _AngelHudak_

## Functionality
1. When the program starts it wil instruct the user to modify the PuTTY Terminal settings to enable escape sequences.
2. The program will print a prompt string to select difficulty wait for a user input of '1', '2', or '3'.
3. The program will prompt the user to press the >enter< key to begin playing and wait for a carrage return (CR = #0x0D) input.
4. The program will initialize the snake queues, print the board, enable the gameActive boolean, PIT interrupts, and begin refreshing the board using escape sequences until the gameOver boolean is true.
    > The game will refresh at a speed determinded by the user selected difficulty level (1 = 10Hz, 2 = 13Hz, and 3 = 15Hz).
    > At every refresh the snake will be advanced one character in the direction of the velocioty and will lose one character off of its tail if the next space is not food.
    > The game will enable a boolean variable that will cause the Recieve interupt to only change the snakes velocity under certain conditions and NOT use the Recieve Queue while the game is active.
    > The game will end if the next space if a snake character or wall character (GAME OVER!), or if the length of the snake is equal to the area of the board (YOU WIN!).
5. When the game ends the prgram will disable all game state variables, display either __"GAMEOVER"__ or __"YOU WIN!"__, prompt the player to press the >enter< key to rest the program, and wait for a CR character.
6. The program will clear the terminal and move the cursor back to its origonal position using escape sequences, then start over from step one.

![Snake State Diagram](ARMC99_Snake_StateDiagram.PNG)

### C99 Functions Porgress Checklist
[ ] void main(int [ ])
[ ] void spawnFood( )
[ ] int isGameOver( )
[ ] void putChar(int x, int y)
[ ] void advanceTheSnake( )

### ARM Assembly Subroutines Porgress Checklist
[ ] Init_Snake_Game
[x] Init_Queue
[x] Dequeue
[x] Enqueue
[ ] Init_PIT_IRQ
[ ] PIT_IRQHandler
[ ] Init_UART0_IRQ
[ ] UART0_IRQHandler
[x] GetCharI
[x] PutCharI
[x] PutStringI
[x] NewLineI
[ ] ReadSnakeQueues

## Enhancements
    Appart from the Minimum Viable Product our development team is working on adding the following enhancements to ARM and C99 Snake
1. [ ] Difficulty Levels -  increased difficulty based increasing speed (ie. refresh rate) of the snake and addition of increasing amounts of “walls” on the board besides the boarders.
2. [ ] ARM/C99Snake Wrap Around - instead of the Snake dying when hitting the wall it will wrap around to the other side of the screen at the same column/row it was traveling in.
3. [ ] Increased Graphics Package - Using more in-depth escape sequences create different colors for the snake food and borders as well as obscure ASCII values for blocks.
