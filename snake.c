/*********************************************************************/
/* Snake with KL46z FRDM board with mixed ARM Assembly and C99       */
/* Name:  Gabriel Dombrowski & Angela Hudak                          */
/* Date:  2, December 2019                                           */
/* Class:  CMPE 250                                                  */
/* Section:  Teusdays 1400 L2                                        */
/*-------------------------------------------------------------------*/
/*********************************************************************/
/*Defines*/
#include "MKL46Z4.h"
#include "Exercise11_C.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>


#define FALSE      (0)
#define TRUE       (1)
#define MAX_STRING (79)
#define REFRESH_SCREEN
/*********************************************************************/
/*Support C Functions */
/*Global variables*/
int GAME_OVER;
int nextX;
int nextY;
int foodX;
int foodY;
int headX;
int headY;
int tailX;
int tailY;

//values for boarders
int upperLimitX = 49;
int lowerlimitX = 0;
int upperLimitY = 20;
int lowerLimitY = 3;

/*
*moveSnake - gets the value of the current velocity and prints a snake
*           char in that direction from the current head location.
*           It then enqueues that value to the snake queue. If
*           nextSpace == food, it exits. If nextSpace == ' ' it
*           dequeus a snake char from the snake queue and prints a ' '
*           at the coordinate.
*@params-null
*@return-null
*/
void moveSnake(){
	if (nextX == foodX & nextY == foodY){
	}
	else if (nextX == 0 | nextX == 49){
	}
	else if (nextY == 3 || nextY == 20){
	}
	else{
	}
  }

/*
*checkGameLost - if nextSpace == snake or boarder, then GAME_OVER = 1
*@params - null
*@return - int (bool 1=True, 0=False)
*/
int checkGameLost(){
    }

/*
*gameWon - the game is won if the number of values enqueued in the snake
*						queues is equal to the board area
*@params - null
*@return - null
*/
int gameWon(){
    }

/*
*advanceTheSnake - uses the velocity variable to advance the snake to the
* nextSpace coordinates. Will delete the tail only if
* nextSpace coordinates != food coordinates
*@params - null
*@return - null
*/
void advanceTheSnake(){
}
/*
*writeChar - writes a character to the coordinates of the parameters
* using escape sequences
*Input - char c, int x, int y
*Output - null
*/
void writeChar(char c, int x, int y){
}

/*
*spawnFood - spawns a food char at a random coordinate that is not currently
*snake and updates the foodX and foodY variables
*inputs - null
*outputs - null
*/
void spawnFood(){
}
/*********************************************************************/
/*Main C Function */
int main (void){
    //initialize interrupts in critial region
    __asm("CPSID I");
    Init_UART0_IRQ();
    //Init_PIT_IRQ
    __asm("CPSIE I");

    //present user instructions for PuTTy
    for (;;){/*main loop*/
			//init game local variables
			char userInput = 'A';
			GAME_OVER = TRUE;
			
			//prompt user for <enter> key
			PutStringI("Please edit you PuTTy Terminal Settings:", MAX_STRING);										//row 21
			NewLineI();
			PutStringI("Right-Click/Change Settings.../Terminal/Force Off x2", MAX_STRING);				//row 20
			NewLineI();
			PutStringI("Press the <enter> key to play Snake", MAX_STRING);												//row 19
			NewLineI();
			
			while (!(userInput == 0x0D)){
				userInput = GetCharI();
			}
			//print board
			//starting snake coordinates
			//Column:   0123456789...
			PutStringI("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/n", MAX_STRING); 			//row 18
			PutStringI("X                                                X/n", MAX_STRING); 			//row 17
			PutStringI("X                                                X/n", MAX_STRING); 			//row 16
			PutStringI("X                                                X/n", MAX_STRING); 			//row 15
			PutStringI("X                                                X/n", MAX_STRING); 			//row 14
			PutStringI("X                                                X/n", MAX_STRING); 			//row 13
			PutStringI("X                                                X/n", MAX_STRING); 			//row 12
			PutStringI("X                                                X/n", MAX_STRING); 			//row 11
			PutStringI("X              ###                    O          X/n", MAX_STRING); 			//row 10
			PutStringI("X                                                X/n", MAX_STRING); 			//row 9
			PutStringI("X                                                X/n", MAX_STRING); 			//row 8
			PutStringI("X                                                X/n", MAX_STRING); 			//row 7
			PutStringI("X                                                X/n", MAX_STRING); 			//row 6
			PutStringI("X                                                X/n", MAX_STRING); 			//row 5
			PutStringI("X                                                X/n", MAX_STRING); 			//row 4
			PutStringI("X                                                X/n", MAX_STRING); 			//row 3
			PutStringI("X                                                X/n", MAX_STRING); 			//row 2
			PutStringI("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/n", MAX_STRING); 			//row 1
      //set variables
			Velocity = 'D';
			foodX = 39;
			foodY = 10;
			headX = 18;
			headY = 10;
			tailX = 15;
			tailY = 10;
			
			//enabkle game control booleans
			GameActive = TRUE;
			GAME_OVER = FALSE;
			while (GAME_OVER == FALSE){/*game loop*/
        GAME_OVER = checkGameLost();
				GAME_OVER = gameWon();
        }
			GameActive = TRUE;
			//game over sequence	
			if (checkGameLost() == TRUE){
				//move cursor for new input
				PutStringI("\033[<21>;<0>",MAX_STRING);
				//print failure message
				PutStringI("GAME OVER!", MAX_STRING);
				NewLineI();
				PutStringI("Press <enter> to restart...", MAX_STRING);
				userInput = 'A';
				while (!(userInput == 0x0D)){
					userInput = GetCharI();
				}
			}
			//game won sequence
			if (gameWon() == TRUE){
				//move cursor for new input
				PutStringI("\033[<21>;<0>",MAX_STRING);
				//print failure message
				PutStringI("YOU WIN!", MAX_STRING);
				NewLineI();
				PutStringI("Press <enter> to restart...", MAX_STRING);
				userInput = 'A';
				while (!(userInput == 0x0D)){
					userInput = GetCharI();
				}
				//clear the screen and moe the cursor to (0,0)
				PutStringI("\033[2J", MAX_STRING);
			}
    }
    return (0);
    }
/*********************************************************************/
