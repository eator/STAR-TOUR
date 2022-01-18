module  game_top
        (
            input   wire            sys_clk     ,   //  system clock -- 100Hz
            input   wire            sys_rst     ,   //  reset signal -- high voltage valid
            input   wire            [1:0] x_flag,   //  ship move in X direction --right/left
            input   wire            [1:0] y_flag,   //  ship move in Y direction --up/down

            output  wire            hsync       ,   //  herizontal synchronization signal
            output  wire            vsync       ,   //  vertical synchronization signal
            output  wire    [11:0]  rgb         ,   //  rgb output data of pixel
            output  wire    [7:0]   san         ,   //  seven digit tube chip delect
            output  wire    [7:0]   sseg        ,   //  seven digit tube data 

            input                   tran_en     ,   //  spi data transmission enable
            input                   MISO        ,   //  get data from slave chip 
            output  wire            SCLK        ,   //  spi clock
            output  wire            CSN         ,   //  spi chip valid signal
            output  wire            MOSI            //  send data to slave chip
        );

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

wire            vga_clk ;   //vga work clock -- 25MHz
wire            rst     ;   //reset signal
wire    [9:0]   pix_x   ;   //x direction of pixel position
wire    [9:0]   pix_y   ;   //y direction of pixel position
wire    [11:0]  pix_data;   //12 digit color data

assign  rst = sys_rst;


//---- divide system clock into 25Hz ------
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
//------------- spi_ctrl_inst -------------
wire    [3:0] spi_x_out     ;
wire    [3:0] spi_y_out     ;
wire    [1:0] acc_x_flag    ;
wire    [1:0] acc_y_flag    ;

assign  acc_x_flag = (((spi_x_out > 0) && (spi_x_out <= 4)) ? 2'b10 : (((spi_x_out > 11) && (spi_x_out <= 15)) ? 2'b01 :2'b00));
assign  acc_y_flag = (((spi_y_out > 0) && (spi_y_out <= 4)) ? 2'b10 : (((spi_y_out > 11) && (spi_y_out <= 15)) ? 2'b01 :2'b00));

spi_ctrl spi(
          .sys_clk(sys_clk          ),
          .rst(rst                  ), 
          .tran_en(tran_en          ), 
          .spi_x_out(spi_x_out      ), 
          .spi_y_out(spi_y_out      ), 

          .MISO(MISO                ), 
          .SCLK(SCLK                ), 
          .CSN(CSN                  ), 
          .MOSI(MOSI                )  
      );

//------------- vga_pic_inst -------------
wire [9:0] score;
wire [11:0]seg_data;
assign seg_data[3:0] = score % 10       ;
assign seg_data[7:4] = (score / 10) % 10;
assign seg_data[11:8]= (score / 100)    ;

vga_pic vga_pic_inst
        (
            .vga_clk    (vga_clk    ),
            .sys_rst    (rst        ),
            .x_flag     (tran_en ? 
                acc_x_flag : x_flag ),
 
            .y_flag     (tran_en ? 
                acc_y_flag : y_flag ),

            .pix_x      (pix_x      ),
            .pix_y      (pix_y      ),

            .score      (score      ),
            .pix_data_out(pix_data  )
        );

//------------- display7_inst -------------
display7 show_score(
             .clk(vga_clk           ),
             .rst(rst               ),
             .idata(seg_data        ),

             .san(san               ),
             .sseg(sseg             )
         );

endmodule
