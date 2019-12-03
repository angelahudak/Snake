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
/*Global variables*/
//ARM Global variables
extern int GameOver;
extern char Velocity;
extern int GameLost;
extern int GameWon;
extern UInt32 SnakeQYRecord;
extern UInt32 SnakeQXRecord;

//C Global variables
int nextX;
int nextY;
int foodX;
int foodY;
int headX;
int headY;
int tailX;
int tailY;
int snakeLength = 3;

//values for boarders
int upperLimitX = 49;
int lowerlimitX = 0;
int upperLimitY = 20;
int lowerLimitY = 3;

//Print values
char FOOD = 'O';
char SNAKE = '#';
char WALL = 'X';
char NOTHING = ' ';

/*
setDifficulty - sets the difficulty of the game to 1, 2, or 3
@params - int difficulty
@return(s) - null void
*/
void setDifficulty(int difficulty){
}

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
	PutCharI(x + 49);
	PutStringI(">;<", MAX_STRING);
	PutCharI(y + 49);
	PutStringI(">f\b", MAX_STRING);
	PutCharI(C);
	
	//restore cursor pos
	PutStringI("\033[u", MAX_STRING);
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
		if (x == ReadSnakeQ(i, SnakeQYRecord) && y == ReadSnakeQ(i, SnakeQYRecord)){
				return FALSE;}
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
	int foodValid = FALSE;
	int x;
	int y;
	while (!(foodValid)){
		x = (rand() % (upperLimitX - lowerlimitX + 1)) + lowerlimitX;
		y = (rand() % (upperLimitY - lowerLimitY + 1)) + lowerLimitY;
		foodValid = checkFood(x, y);
	}
	foodX = x;
	foodY = y;
	printChar(foodValid, foodX, foodY);
}

/*
enqueueNewSnakePos - enqueues the headX and headY values into the
	snake queues
@params - null
@return(s) - null void
*/
void enqueueNewSnakePos(){
	Enqueue(headY, SnakeQYRecord);
	Enqueue(headX, SnakeQXRecord);	
}

/*
nextSpaceValid - tells if the next space will be valid
	given a velocity char, will also increment the nextX or
	nextY value accordingly
@params - char v (velocity)
@returns - null void
*/
int nextSpaceValid(char v){
	//velocity is up
	if (v == 'w'){
		nextY ++;
		if (nextY == upperLimitY || nextY == lowerLimitY){return FALSE;}
		for (int i;snakeLength; i++){
			if (nextX == ReadSnakeQ(i, SnakeQYRecord) && nextY == ReadSnakeQ(i, SnakeQYRecord)){
				return FALSE;
			}
		}
	}
	//velcoity if left
	else if (v == 'a'){
		nextX --;
		if (nextX == lowerlimitX || nextX == upperLimitX){return FALSE;}
		for (int i;snakeLength; i++){
			if (nextX == ReadSnakeQ(i, SnakeQYRecord) && nextY == ReadSnakeQ(i, SnakeQYRecord)){
				return FALSE;
			}
		}
	}
	//velocity is down
	else if (v == 's'){
		nextY --;
		if (nextY == upperLimitY || nextY == lowerLimitY){return FALSE;}
		for (int i;snakeLength; i++){
			if (nextX == ReadSnakeQ(i, SnakeQYRecord) && nextY == ReadSnakeQ(i, SnakeQYRecord)){
				return FALSE;
			}
		}
	}
	//velocity is right
	else if (v == 'd'){
		nextX ++;
		if (nextX == lowerlimitX || nextX == upperLimitX){return FALSE;}
		for (int i;snakeLength; i++){
			if (nextX == ReadSnakeQ(i, SnakeQYRecord) && nextY == ReadSnakeQ(i, SnakeQYRecord)){
				return FALSE;
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
			printChar(SNAKE, headX, headY);
			break;
		case 'd':
			headX ++;
			enqueueNewSnakePos();
			printChar(SNAKE, headX, headY);
			break;
	}
	//only adavnce the tail if no food is eaten
	if (!(nextX == foodX && nextY == foodY)){
		printChar(NOTHING, tailX, tailY);
		Dequeue(SnakeQXRecord);
		Dequeue(SnakeQYRecord);
		tailX = ReadFirstQ(SnakeQXRecord);
		tailY = ReadFirstQ(SnakeQYRecord);
	}
	else if (nextX == foodX && nextY == foodY) {snakeLength ++;}
}

/*********************************************************************/
/*Main C Function */
int main (void){
    //initialize interrupts in critial region
    __asm("CPSID I");
    Init_UART0_IRQ();
    Init_PIT_IRQ();
    __asm("CPSIE I");

    //present user instructions for PuTTy
    for (;;){/*main loop*/
			//init game local variables
			char userInput = 'A';
			GameOver = TRUE;
			
			//prompt user for <enter> key
			PutStringI("Please edit you PuTTy Terminal Settings:\n", MAX_STRING);										//row 22
			PutStringI("Right-Click/Change Settings.../Terminal/Force Off x2\n", MAX_STRING);				//row 21
	    
			//difficulty computation
			PutStringI("Press >1< >2< or >3< to slect your difficulty", MAX_STRING);								//row 20
			while (!(userInput == '1' || userInput == '2' || userInput == '3')){
				userInput = GetCharI();
			}
			setDifficulty(userInput - 48);
			
			//wait for user >enter< loop
			PutStringI("Press the <enter> key to play Snake\n", MAX_STRING);												//row 19			
			while (!(userInput == 0x0D)){
				userInput = GetCharI();
			}
			//print board
			//starting snake coordinates
			//Column:   0123456789...
			PutStringI("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n", MAX_STRING); 			//row 18
			PutStringI("X                                                X\n", MAX_STRING); 			//row 17
			PutStringI("X                                                X\n", MAX_STRING); 			//row 16
			PutStringI("X                                                X\n", MAX_STRING); 			//row 15
			PutStringI("X                                                X\n", MAX_STRING); 			//row 14
			PutStringI("X                                                X\n", MAX_STRING); 			//row 13
			PutStringI("X                                                X\n", MAX_STRING); 			//row 12
			PutStringI("X                                                X\n", MAX_STRING); 			//row 11
			PutStringI("X              ###                    O          X\n", MAX_STRING); 			//row 10
			PutStringI("X                                                X\n", MAX_STRING); 			//row 9
			PutStringI("X                                                X\n", MAX_STRING); 			//row 8
			PutStringI("X                                                X\n", MAX_STRING); 			//row 7
			PutStringI("X                                                X\n", MAX_STRING); 			//row 6
			PutStringI("X                                                X\n", MAX_STRING); 			//row 5
			PutStringI("X                                                X\n", MAX_STRING); 			//row 4
			PutStringI("X                                                X\n", MAX_STRING); 			//row 3
			PutStringI("X                                                X\n", MAX_STRING); 			//row 2
			PutStringI("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n", MAX_STRING); 			//row 1
			//	   	 |_|<-cursor will return here																								//row 0
			
			//set variables
			Velocity = 'D';
			foodX = 39;
			foodY = 10;
			headX = 18;
			headY = 10;
			tailX = 15;
			tailY = 10;
			
			//Init queues to record snake values
			InitSnakeQs();
			
			//enqueue back 2 snake x coordinates
			Enqueue(15, SnakeQXRecord);
			Enqueue(16, SnakeQXRecord);
			
			//enqueue last 2 snake y coordinates
			Enqueue(10, SnakeQYRecord);
			Enqueue(10, SnakeQYRecord);
			
			//snake first snake head coordinates
			enqueueNewSnakePos();

			//enable game control booleans
			GameActive = TRUE;
			GameOver = FALSE;
			
			//main game loop
			while (GameOver == FALSE)
			
			//enable normal recieving
			GameActive = FALSE;
			
			//game over sequence	
			if (GameLost == TRUE){
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
			else if (GameWon == TRUE){
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
