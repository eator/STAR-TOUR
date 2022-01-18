module spi_ctrl(
           input                sys_clk     ,
           input                rst         ,
           input                tran_en     , 
           output   reg   [3:0] spi_x_out   ,   // x direction data of accelerator 
           output   reg   [3:0] spi_y_out   ,   // y direction data of accelerator

           input                MISO        ,   //  get data from slave chip
           output   wire        SCLK        ,   //  spi clock
           output   wire        CSN         ,   //  spi chip valid signal
           output   wire        MOSI            //  send data to slave chip
       );   
       
reg     [15:0]  spi_data_in     ;
wire    [7:0]   spi_data_out    ;

accel spi(
          .sys_clk(sys_clk          ),
          .rst(rst                  ), 
          .tran_en(tran_en          ), 
          .data_tran(spi_data_in    ), 
          .data_rec(spi_data_out    ), 

          .MISO(MISO                ), 
          .SCLK(SCLK                ), 
          .CSN(CSN                  ), 
          .MOSI(MOSI                )  
      );

integer spi_cnt =   0                   ;
wire    [15:0]  seg_data                ;

assign seg_data[3:0]    =  spi_x_out % 10  ;
assign seg_data[7:4]    =  spi_x_out / 10  ;
assign seg_data[11:8]   =  spi_y_out % 10  ;
assign seg_data[15:12]  =  spi_y_out / 10  ;

always @ (posedge sys_clk) begin
    if(rst) begin
        spi_cnt     <=  0                   ;
        spi_x_out   <=  4'd0                ;
        spi_y_out   <=  4'd0                ;
        spi_data_in <=  16'h0               ;
    end

    spi_cnt <=  spi_cnt + 1                 ;

    if(spi_cnt == 1) begin
        spi_data_in <=  16'h0b0f            ;   //read y direction of high quality precision
    end
    else if(spi_cnt == 100) begin
        spi_y_out   <=  spi_data_out[3:0]   ;   //read y direction of high quality precision's 4 MSB digit data
    end
    else if(spi_cnt == 101) begin
        spi_data_in <=  16'h0b11            ;   //read x direction of high quality precision
    end
    else if(spi_cnt == 200) begin
        spi_x_out   <=  spi_data_out[3:0]   ;   //read x direction of high quality precision's 4 MSB digit data
        spi_cnt     <=  0;
    end
end

endmodule
