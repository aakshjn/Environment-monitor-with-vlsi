`timescale 1ns / 1ps
// ==============================================================================
// 										  Define Module
// ==============================================================================
module lcd(inputs1,inputs2,
    btnr,
    clk,
    JD,
	 JE,
	 op1
    );

	// ===========================================================================
	// 										Port Declarations
	// ===========================================================================
    input btnr;								// use BTNR as reset input
    input clk;
   input [4:0] inputs1;
   input [7:0] inputs2;									// 100 MHz clock input
    output reg [3:0] op1;
   //lcd input signals
   //s  ignal on connector JA
    output [7:0] JE;							//output bus, used for data transfer (DB)
   // signal on connector JB
   //JB[4]register selection pin  (RS)
   //JB[5]selects between read/write modes (RW)
   //JB[6]enable signal for starting the data read/write (E)
    output [6:4] JD;
integer cal,cal1;
integer ppm;
	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
	wire [7:0] JE;
	wire [6:4] JD;
   //LCD control state machine
	parameter [3:0] stFunctionSet = 0,						// Initialization states
						 stDisplayCtrlSet = 1,
						 stDisplayClear = 2,
						 stPowerOn_Delay = 3,					// Delay states
						 stFunctionSet_Delay = 4,
						 stDisplayCtrlSet_Delay = 5,
						 stDisplayClear_Delay = 6,
						 stInitDne = 7,							// Display characters and perform standard operations
						 stActWr = 8,
						 stCharDelay = 9;							// Write delay for operations	
	reg[0:23][9:0] LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h66},		// 15, e
						{2'b10, 8'h3A},		// 16, :
			//			{2'b10, a},		// 17, g
					{2'b00, 8'h18}		// 23, Shift left
	};
	reg [4:0] lcd_cmd_ptr;
	/* These constants are used to initialize the LCD pannel.

		--  FunctionSet:
								Bit 0 and 1 are arbitrary
								Bit 2:  Displays font type(0=5x8, 1=5x11)
								Bit 3:  Numbers of display lines (0=1, 1=2)
								Bit 4:  Data length (0=4 bit, 1=8 bit)
								Bit 5-7 are set
		--  DisplayCtrlSet:
								Bit 0:  Blinking cursor control (0=off, 1=on)
								Bit 1:  Cursor (0=off, 1=on)
								Bit 2:  Display (0=off, 1=on)
								Bit 3-7 are set
		--  DisplayClear:
								Bit 1-7 are set	*/
		
	reg [6:0] clkCount = 7'b0000000;
	reg [20:0] count = 21'b000000000000000000000;	// 21 bit count variable for timing delays
	wire delayOK;													// High when count has reached the right delay time
	reg oneUSClk;													// Signal is treated as a 1 MHz clock	
	reg [3:0] stCur = stPowerOn_Delay;						// LCD control state machine
	reg [3:0] stNext;
	wire writeDone;
	reg [4:0] lcd_cmd_ptr;	
always@(posedge clk)
begin
cal1 =((1*inputs2[0])+(2*inputs2[1])+(4*inputs2[2])+(8*inputs2[3])+(16*inputs2[4])+(32*inputs2[5])+(64*inputs2[6])+(128*inputs2[7]));
    if (cal1<=0)
    LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h30},		// 17, 0
						{2'b00, 8'h18}		// 23, Shift left
					};
else if(cal1<=10)
    LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h31},		// 17, 1
    					{2'b10, 8'h30},		// 18, 0
					{2'b00, 8'h18}		// 23, Shift left
					};
else if(cal1    <=20)
     LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h32},		// 17, 2
						{2'b10, 8'h30},		// 18, 0
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};
else if(cal1    <=21)
     LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h32},		// 17, 2
						{2'b10, 8'h31},		// 18, 1
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};
else if(cal1    <=22)
     LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h32},		// 17, 2
						{2'b10, 8'h32},		// 18, 2
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};
else if(cal1    <=23)
     LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h32},		// 17, 2
						{2'b10, 8'h33},		// 18, 3
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};
	else if(cal1    <=24)
     LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h32},		// 17, 2
						{2'b10, 8'h34},		// 18, 4
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};

	else if(cal1    <=25)
     LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h32},		// 17, 2
						{2'b10, 8'h35},		// 18, 5
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					    {2'b00, 8'h18}		// 23, Shift left
					 };
	 else if(cal1    <=26)
     LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h32},		// 17, 2
						{2'b10, 8'h36},		// 18, 6
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					    {2'b00, 8'h18}		// 23, Shift left
					    };
	 else if(cal1    <=27)
     LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h32},		// 17, 2
						{2'b10, 8'h37},		// 18, 7
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					    {2'b00, 8'h18}		// 23, Shift left
					};
	  else if(cal1    <=28)
     LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h32},		// 17, 2
						{2'b10, 8'h38},		// 18, 8
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					    {2'b00, 8'h18}		// 23, Shift left
					};
	 else if(cal1    <=29)
     LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h32},		// 17, 2
						{2'b10, 8'h39},		// 18, 9
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					    {2'b00, 8'h18}		// 23, Shift left
					};
     else if(cal1<=30)
     LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h33},		// 17, 3
      					{2'b10, 8'h30},		// 18, 0
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};
					
					
					
					
else if(cal1<=40)
    LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h34},		// 17, 4
						{2'b10, 8'h30},		// 18, 0
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};
	else if(cal1<=50)
    LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h35},		// 17, 5
						{2'b10, 8'h30},		// 18, 0
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};
	else if(cal1<=60)
    LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h36},		// 17, 6
						{2'b10, 8'h30},		// 18, 0
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};
	else if(cal1<=70)
    LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h37},		// 17, 7
						{2'b10, 8'h30},		// 18, 0
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};
		else if(cal1<=80)
    LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h38},		// 17, 8
						{2'b10, 8'h30},		// 18, 0
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};
   else if(cal1<=90)
    LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h39},		// 17, 9
						{2'b10, 8'h30},		// 18, 0
//						{2'b10, 8'h65},		// 19, l
//						{2'b10, 8'h3A},		// 20, e
//						{2'b10, 8'h6E},		// 21, n
//						{2'b10, 8'h74},		// 22, t
					{2'b00, 8'h18}		// 23, Shift left
					};
	else if(cal1>=90)
    LCD_CMDS = {
						{2'b00, 8'h3C},		// 0, Function Set
						{2'b00, 8'h0C},		// 1, Display ON, Cursor OFF, Blink OFF
						{2'b00, 8'h01},		// 2, Clear Display
						{2'b00, 8'h02},		// 3, Return Home
						{2'b10, 8'h54},		// 4, T
						{2'b10, 8'h65},		// 5, e
						{2'b10, 8'h6D},		// 6, m
						{2'b10, 8'h70},		// 7, p
						{2'b10, 8'h65},		// 8, e
						{2'b10, 8'h72},		// 9, r
						{2'b10, 8'h61},		// 11, a
						{2'b10, 8'h74},		// 12, t
						{2'b10, 8'h75},		// 13, u						
						{2'b10, 8'h72},		// 14, r
						{2'b10, 8'h65},		// 15, e
						{2'b10, 8'h3A},		// 16, :
						{2'b10, 8'h31},		// 17, 1
						{2'b10, 8'h30},		// 18, 0
						{2'b10, 8'h30},		// 19, 0
					{2'b00, 8'h18}		// 23, Shift left
					};
end
always@(posedge clk)
begin
cal =((1*inputs1[0])+(2*inputs1[1])+(4*inputs1[2])+(8*inputs1[3])+(16*inputs1[4]));
   // ppm= 2.71**((7.35-($log10(((0.1/(cal*0.15625))-0.02))))/3.15);
    if(cal<=9)
    ppm=(10+(14/9)*(cal));
    else if (cal<=20)
    ppm=(cal+15);
    else if (cal<=30)
    ppm=((31/10)*(cal)-3); 
    else if (cal>=31)
    ppm = 70;
    
      
    if (ppm<=10)
     op1[3:0]=4'b0001;
     else if (ppm<=18)
     op1[3:0]=4'b0010;
     else if (ppm<=26)
     op1[3:0]=4'b0011;
     else if (ppm<=34)
     op1[3:0]=4'b0100; 
     else if (ppm<=42)
     op1[3:0]=4'b0101;
     else if (ppm<=50)
     op1[3:0]=4'b0110;
     else if (ppm<=58)
     op1[3:0]=4'b0111;
      else if (ppm>=66)
     op1[3:0]=4'b1000;
end
	

	// ===========================================================================
	// 										Implementation
	// ===========================================================================

	// This process counts to 100, and then resets.  It is used to divide the clock signal.
	// This makes oneUSClock peak aprox. once every 1microsecond
	always @(posedge clk) begin

			if(clkCount == 7'b1100100) begin
					clkCount <= 7'b0000000;
					oneUSClk <= ~oneUSClk;
			end
			else begin
					clkCount <= clkCount +      1'b1;
			end

	end


	// This process increments the count variable unless delayOK = 1.
	always @(posedge oneUSClk) begin
	
			if(delayOK == 1'b1) begin
					count <= 21'b000000000000000000000;
			end
			else begin
					count <= count + 1'b1;
			end
	
	end


	// Determines when count has gotten to the right number, depending on the state.
	assign delayOK = (
				((stCur == stPowerOn_Delay) && (count == 21'b111101000010010000000)) ||				// 2000000	 	-> 20 ms
				((stCur == stFunctionSet_Delay) && (count == 21'b000000000111110100000)) ||		// 4000 			-> 40 us
				((stCur == stDisplayCtrlSet_Delay) && (count == 21'b000000000111110100000)) ||	// 4000 			-> 40 us
				((stCur == stDisplayClear_Delay) && (count == 21'b000100111000100000000)) ||		// 160000 		-> 1.6 ms
				((stCur == stCharDelay) && (count == 21'b000111111011110100000))						// 260000		-> 2.6 ms - Max Delay for character writes and shifts
	) ? 1'b1 : 1'b0;


	// writeDone goes high when all commands have been run	
	assign writeDone = (lcd_cmd_ptr == 5'd23) ? 1'b1 : 1'b0;

	
	// Increments the pointer so the statemachine goes through the commands
	always @(posedge oneUSClk) begin
			if((stNext == stInitDne || stNext == stDisplayCtrlSet || stNext == stDisplayClear) && writeDone == 1'b0) begin
					lcd_cmd_ptr <= lcd_cmd_ptr + 1'b1;
			end
			else if(stCur == stPowerOn_Delay || stNext == stPowerOn_Delay) begin
					lcd_cmd_ptr <= 5'b00000;
			end
			else begin
					lcd_cmd_ptr <= lcd_cmd_ptr;
			end
	end
	
	
	// This process runs the LCD state machine
	always @(posedge oneUSClk) begin
			if(btnr == 1'b1) begin
					stCur <= stPowerOn_Delay;
			end
			else begin
					stCur <= stNext;
			end
	end
	

	// This process generates the sequence of outputs needed to initialize and write to the LCD screen
	always @(stCur or delayOK or writeDone or lcd_cmd_ptr) begin
			case (stCur)
				// Delays the state machine for 20ms which is needed for proper startup.
				stPowerOn_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stFunctionSet;
						end
						else begin
							stNext <= stPowerOn_Delay;
						end
				end
					
				// This issues the function set to the LCD as follows 
				// 8 bit data length, 1 lines, font is 5x8.
				stFunctionSet : begin
						stNext <= stFunctionSet_Delay;
				end
				
				// Gives the proper delay of 37us between the function set and
				// the display control set.
				stFunctionSet_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stDisplayCtrlSet;
						end
						else begin
							stNext <= stFunctionSet_Delay;
						end
				end
				
				// Issuse the display control set as follows
				// Display ON,  Cursor OFF, Blinking Cursor OFF.
				stDisplayCtrlSet : begin
						stNext <= stDisplayCtrlSet_Delay;
				end

				// Gives the proper delay of 37us between the display control set
				// and the Display Clear command. 
				stDisplayCtrlSet_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stDisplayClear;
						end
						else begin
							stNext <= stDisplayCtrlSet_Delay;
						end
				end
				
				// Issues the display clear command.
				stDisplayClear	: begin
						stNext <= stDisplayClear_Delay;
				end

				// Gives the proper delay of 1.52ms between the clear command
				// and the state where you are clear to do normal operations.
				stDisplayClear_Delay : begin
						if(delayOK == 1'b1) begin
							stNext <= stInitDne;
						end
						else begin
							stNext <= stDisplayClear_Delay;
						end
				end
				
				// State for normal operations for displaying characters, changing the
				// Cursor position etc.
				stInitDne : begin		
						stNext <= stActWr;
				end

				// stActWr
				stActWr : begin
						stNext <= stCharDelay;
				end
					
				// Provides a max delay between instructions.
				stCharDelay : begin
						if(delayOK == 1'b1) begin
							stNext <= stInitDne;
						end
						else begin
							stNext <= stCharDelay;
						end
				end

				default : stNext <= stPowerOn_Delay;

			endcase
	end
		
		
	// Assign outputs
	assign JD[4] = LCD_CMDS[lcd_cmd_ptr][9];
	assign JD[5] = LCD_CMDS[lcd_cmd_ptr][8];
	assign JE = LCD_CMDS[lcd_cmd_ptr][7:0];
	assign JD[6] = (stCur == stFunctionSet || stCur == stDisplayCtrlSet || stCur == stDisplayClear || stCur == stActWr) ? 1'b1 : 1'b0;
//always@(posedge clk)
//assign cal =((1*inputs1[0])+(2*inputs1[1])+(4*inputs1[2])+(8*inputs1[3])+(16*inputs1[4]));
//assign V= cal*0.15625;
//assign Rs=(0.1/V)-0.02;
//assign j=log(Rs);
//assign ppm= exp((10.5-j)/4.5);

endmodule