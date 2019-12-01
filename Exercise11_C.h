/*********************************************************************/
/* Lab Exercise Eleven                                               */
/* Adjusts a servo to one of five positions [1, 5] using  mixed C    */
/* and assembly language.  Prompts user to enter a number from 1 to  */
/* 5, generates a voltage in the range (0, 3.3] V proportional to    */
/* the user's number, converts the voltage to a 10-bit number, and   */
/* set's the servo position [1, 5] based on the magnitude of the 10- */
/* bit digital value.                                                */
/* Name:  R. W. Melton                                               */
/* Date:  November 11, 2019                                          */
/* Class:  CMPE 250                                                  */
/* Section:  All sections                                            */
/*********************************************************************/
typedef int Int32;
typedef short int Int16;
typedef char Int8;
typedef unsigned int UInt32;
typedef unsigned short int UInt16;
typedef unsigned char UInt8;

/*assembly variables*/
extern char Velocity;
extern int GameActive;

/* assembly language subroutines */
char GetCharI (void);
void GetStringI (char String[], int StringBufferCapacity);
void Init_UART0_IRQ (void);
void PutCharI (char Character);
void PutNumHexI (UInt32);
void PutNumI (UInt8);
void PutStringI (char String[], int StringBufferCapacity);
void NewLineI (void);
int Dequeue(UInt32);
void Enqueue(Int8, UInt32);
Int8 ReadSnakeQ(Int8, UInt32);
Int8 ReadFirstQ(UInt32);