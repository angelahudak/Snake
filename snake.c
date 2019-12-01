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
int snakeLength = 3;
extern Velocity;

//values for boarders
int upperLimitX = 49;
int lowerlimitX = 0;
int upperLimitY = 20;
int lowerLimitY = 3;

//Print values
char FOOD = 'O';
char SNAKE = '#';
char WALL = 'X';

/*
printChar -  moves the cursor to the x,y positions
	given in arguments, deletes the char there and
	replaces it with an argument. The cursor is returned
	to its starting position
@params - char C, int x, int y
@return(s) - null void
*/
void printChar(char C, int x, int y){
	//ensure continuity while printing
	__asm("CPSID I");
	//save the cursor pos
	PutStringI("\033[s", MAX_STRING);
	
	PutStringI("\033[<", MAX_STRING);
	PutCharI(x + 39);
	PutStringI(">;<", MAX_STRING);
	PutCharI(y + 39);
	PutStringI(">f\b", MAX_STRING);
	PutCharI(C);
	
	//restore cursor pos
	PurtStringI("\033[u", MAX_STRING);
	__asm("CPSIE I");
}

/*
checkFood - checks a given x,y corrdinate to see if it is a valid
	placement for a new piece of food.
@params - int x, int y
@return(s) - int Boolean (1 = TRUE, 0 = FALSE)
*/
int checkFood(int x, int y){
	for (int i;snakeLength; i++){
		if (x == ReadSnakeQ(i, &SnakeQYRecord) && /
			y == ReadSnakeQ(i, &SnakeQYRecord){
				return FLASE;}
	}
	return TRUE;
}

/*
spawnFood - randomly spawns a piece of food in valid spot on the
	board, updates the coordinates for the food, and prints in the new
	food char
@params - null
@returns - null void
*/
void spawnFood(){
	int foodValid = FLASE;
	while (!(foodValid)){
		x = (rand() % (upperLimitX - lowerlimitX + 1)) + lowerlimitX;
		y = (rand() % (upperLimitY - lowerLimitY + 1)) + lowerLimitY;
		foodValid = checkFood(x, y);
	}
	foodX = x;
	foodY = y;
	printChar(foodValid, foodX, foodY);
}

void enqueueNewSnakePos(){
	Enqueue(headY, &snakeQYRecord);
	Enqueue(headX, &snakeQXRecord);	
}


int nextSpaceValid(char v){
	//velocity is up
	if (v = 'w'){
		nextY ++;
		if (nextY == upperLimitY || nextY == lowerLimitY){return FALSE;}
		for (int i;snakeLength; i++){
			if (nextX == ReadSnakeQ(i, &SnakeQYRecord) && nextY == ReadSnakeQ(i, &SnakeQYRecord){
				return FLASE;
			}
		}
	}
	//velcoity if left
	else if (v = 'a'){
		nextX --;
		if (nextX == lowerlimitX || nextX == upperLimitX){return FALSE;}
		for (int i;snakeLength; i++){
			if (nextX == ReadSnakeQ(i, &SnakeQYRecord) && nextY == ReadSnakeQ(i, &SnakeQYRecord){
				return FLASE;
			}
		}
	}
	//velocity is down
	else if (v = 's'){
		nextY --;
		if (nextY == upperLimitY || nextY == lowerLimitY){return FALSE;}
		for (int i;snakeLength; i++){
			if (nextX == ReadSnakeQ(i, &SnakeQYRecord) && nextY == ReadSnakeQ(i, &SnakeQYRecord){
				return FLASE;
			}
		}
	}
	//velocity is right
	else if (v = 'd'){
		nextX ++;
		if (nextX == lowerlimitX || nextX == upperLimitX){return FALSE;}
		for (int i;snakeLength; i++){
			if (nextX == ReadSnakeQ(i, &SnakeQYRecord) && nextY == ReadSnakeQ(i, &SnakeQYRecord){
				return FLASE;
			}
		}
	}
	return TRUE;
}

/*
*advanceTheSnake - uses the velocity variable to advance the snake to the
* nextSpace coordinates. Will delete the tail only if
* nextSpace coordinates != food coordinates
*@params - null
*@return - null
*/
void advanceTheSnake(char vel){
	switch(vel){
		case 'w':
			headY++;
			enqueueNewSnakePos();
			printChar(SNAKE, headX, headY);
			break;
		case 'a':
			headX --;
			enqueueNewSnakePos();
			printChar(SNAKE, headX, headY);
			break;
		case 's':
			headY --;
			enqueueNewSnakePos();
			printChar(SNKAE, headX, headY);
			break;
		case 'd':
			headX ++;
			enqueueNewSnakePos();
			printChar(SNAKE, headX, headY);
			break;
	}
	if (!(nextX == foodX && nextY == foodY){
		
	}
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
