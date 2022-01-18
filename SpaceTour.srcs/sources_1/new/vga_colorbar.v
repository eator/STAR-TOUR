module  vga_colorbar
(
    input   wire            sys_clk     ,  
    input   wire            sys_rst     ,   

    output  wire            hsync       ,   
    output  wire            vsync       ,   
    output  wire    [11:0]  rgb             
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire define
wire            vga_clk ; 
wire            rst     ;  
wire    [9:0]   pix_x   ;   
wire    [9:0]   pix_y   ;   
wire    [11:0]  pix_data;   


assign  rst = sys_rst   ;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- clk_gen_inst -------------
clk_gen clk_gen_m(
            .clk(sys_clk),
            .rst(rst),
            .clk_25hz(vga_clk)
        );

//------------- vga_ctrl_inst -------------
vga_ctrl  vga_ctrl_inst
(
    .vga_clk    (vga_clk    ),  
    .sys_rst    (rst        ), 
    .pix_data   (pix_data   ),  

    .pix_x      (pix_x      ), 
    .pix_y      (pix_y      ),  
    .hsync      (hsync      ),  
    .vsync      (vsync      ),  
    .rgb        (rgb        )   
);

//------------- vga_pic_inst -------------
vga_pic vga_pic_inst
(
    .vga_clk    (vga_clk    ),  
    .sys_rst    (rst        ), 
    .pix_x      (pix_x      ), 
    .pix_y      (pix_y      ),  

    .pix_data   (pix_data   )   

);

endmodule
