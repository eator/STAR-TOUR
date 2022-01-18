module accel(
           input               sys_clk          ,   //  system clock -- 100Hz
           input               rst              ,   //  reset signal -- high voltage valid
           input               tran_en          ,   //  spi data transmission enable
           input        [15:0] data_tran        ,   //  reg instruction of accelerator 
           output  reg  [7:0]  data_rec         ,   //  receive inst from master chip

           //standard SPI signal
           input               MISO             ,   //  get data from slave chip
           output  reg         SCLK             ,   //  spi clock
           output  reg         CSN              ,   //  spi chip valid signal
           output  reg         MOSI                 //  send data to slave chip
       );

//state machine configuration
reg     [5:0]     state     ;
always @(posedge sys_clk or posedge rst) begin
    if(rst) begin
        state   <=  6'd0    ;
        CSN     <=  1'b1    ;
        SCLK    <=  1'b0    ;
        MOSI    <=  1'b0    ;
        data_rec<=  8'd0    ;
    end
    else if(tran_en) begin  //transmission enable 
        if(state == 6'd50) begin
            state  <=  6'd0                 ;
        end

        CSN    <=  1'b0                     ; // pull down chip select signal

        case(state)

            //intergrate odd num state
            6'd1    , 6'd3  , 6'd5  , 6'd7  ,
            6'd9    , 6'd11 , 6'd13 , 6'd15 ,
            6'd17   , 6'd19 , 6'd21 , 6'd23 ,
            6'd25   , 6'd27 , 6'd29 , 6'd31 ,
            6'd33   :
            begin
                SCLK   <=  1'b1             ;
                state  <=  state + 1'b1     ;
            end

            6'd0:    // send 15'th digit instruction signal
            begin
                MOSI    <=  data_tran[15]   ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd2:    // send 14'th digit instruction signal
            begin
                MOSI    <=  data_tran[14]   ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd4:    // send 13'th digit instruction signal
            begin
                MOSI    <=  data_tran[13]   ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd6:    // send 12'th digit instruction signal
            begin
                MOSI    <=  data_tran[12]   ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd8:    // send 11'th digit instruction signal
            begin
                MOSI    <=  data_tran[11]   ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd10:   // send 10'th digit instruction signal
            begin
                MOSI    <=  data_tran[10]   ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd12:   // send 9'th digit instruction signal
            begin
                MOSI    <=  data_tran[9]    ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd14:   // send 8'th digit instruction signal
            begin
                MOSI    <=  data_tran[8]    ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd16:   // send 7'th digit instruction signal
            begin
                MOSI    <=  data_tran[7]    ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd18:   // send 6'th digit instruction signal
            begin
                MOSI    <=  data_tran[6]    ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd20:   // send 5'th digit instruction signal
            begin
                MOSI    <=  data_tran[5]    ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd22:   // send 4'th digit instruction signal
            begin
                MOSI    <=  data_tran[4]    ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd24:   // send 3'th digit instruction signal
            begin
                MOSI    <=  data_tran[3]    ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd26:   // send 2'th digit instruction signal
            begin
                MOSI    <=  data_tran[2]    ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd28:   // send 1'th digit instruction signal
            begin
                MOSI    <=  data_tran[1]    ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end
            6'd30:   // send 0'th digit instruction signal
            begin
                MOSI    <=  data_tran[0]    ;
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end

            //intergrate even num state
            6'd32   , 6'd34 , 6'd36 , 6'd38 ,
            6'd40   , 6'd42 , 6'd44 , 6'd46 , 
            6'd48   :                       
            begin
                SCLK    <=  1'b0            ;
                state   <=  state + 1'b1    ;
            end

            6'd35:    // receive 7'th digit data
            begin
                SCLK        <=  1'b1        ;
                state       <=  state + 1'b1;
                data_rec[7] <=  MISO        ;
            end
            6'd37:    // receive 6'th digit data
            begin
                SCLK        <=  1'b1        ;
                state       <=  state + 1'b1;
                data_rec[6] <=  MISO        ;
            end
            6'd39:    // receive 5'th digit data
            begin
                SCLK        <=  1'b1        ;
                state       <=  state + 1'b1;
                data_rec[5] <=  MISO        ;
            end
            6'd41:    // receive 4'th digit data
            begin
                SCLK        <=  1'b1        ;
                state       <=  state + 1'b1;
                data_rec[4] <=  MISO        ;
            end
            6'd43:    // receive 3'th digit data
            begin
                SCLK        <=  1'b1        ;
                state       <=  state + 1'b1;
                data_rec[3] <=  MISO        ;
            end
            6'd45:    // receive 2'th digit data
            begin
                SCLK        <=  1'b1        ;
                state       <=  state + 1'b1;
                data_rec[2] <=  MISO        ;
            end
            6'd47:    // receive 1'th digit data
            begin
                SCLK        <=  1'b1        ;
                state       <=  state + 1'b1;
                data_rec[1] <=  MISO        ;
            end
            6'd49:    // receive 0'th digit data
            begin
                SCLK        <=  1'b1        ;
                state       <=  state + 1'b1;
                data_rec[0] <=  MISO        ;
                CSN         <=  1'b1        ;
            end
            default:
                ;
        endcase
    end
    else begin
        state   <=  6'd0    ;
        CSN     <=  1'b1    ;
        SCLK    <=  1'b0    ;
        MOSI    <=  1'b0    ;
        data_rec<=  8'd0    ;
    end
end

endmodule
