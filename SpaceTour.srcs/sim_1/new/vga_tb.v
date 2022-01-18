`timescale 1ns / 1ps
module  vga_color_tb();
//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire            hsync       ;
wire    [11:0]  rgb         ;
wire            vsync       ;

//reg   define
reg             sys_clk     ;
reg             sys_rst     ;

//********************************************************************//
//**************************** Clk And Rst ***************************//
//********************************************************************//

//sys_clk, sys_rst initialization
initial
    begin
        sys_clk     =   1'b1;
        sys_rst     <=  1'b1;
        #200
        sys_rst     <=  1'b0;
    end

//sys_clk generation
always  #10 sys_clk = ~sys_clk  ;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- vga_colorbar_inst -------------
vga_colorbar    vga_colorbar_inst
(
    .sys_clk    (sys_clk    ),  
    .sys_rst    (sys_rst    ),  

    .hsync      (hsync      ),  //output herizontal synchronization signal, 1bit
    .vsync      (vsync      ),  //output vertical synchronization signal, 1bit
    .rgb        (rgb        )   //output RGB pixel data, 12bit
);

endmodule