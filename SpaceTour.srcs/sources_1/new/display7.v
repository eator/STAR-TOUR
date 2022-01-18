module display7(
           input   wire        clk     ,    //  system clock -- 100Hz
           input   wire        rst     ,    //  reset signal -- high voltage valid
           input   wire[11:0]  idata   ,    //  decimal digit, three digit, each uses 4 binary bit 

           output  reg [7:0]   san     ,    //  seven digit tube chip delect
           output  reg [7:0]   sseg         //  seven digit tube data
       );


reg [17:0]  cnt_ctrl            ;   //use low 15 digits to divide clock(25MHZ/2^15)
reg [3:0]   curr_data           ;   //current displaying data

always@(posedge clk, posedge rst) begin
    if(rst)
        cnt_ctrl <= 0           ;
    else
        cnt_ctrl <= cnt_ctrl + 1;
end

//select display segment
always@(cnt_ctrl[17:15]) begin
    case(cnt_ctrl[17:15])
        3'b000:
            san <= 8'b1111_1110;
        3'b001:
            san <= 8'b1111_1101;
        3'b010:
            san <= 8'b1111_1011;
        3'b011:
            san <= 8'b1111_0111;
        3'b100:
            san <= 8'b1110_1111;
        3'b101:
            san <= 8'b1101_1111;
        3'b110:
            san <= 8'b1011_1111;
        3'b111:
            san <= 8'b0111_1111;
    endcase
end

//put data into segment
always@(cnt_ctrl[17:15]) begin
    case(cnt_ctrl[17:15])
        3'b000:
            curr_data <= idata[3:0] ;
        3'b001:
            curr_data <= idata[7:4] ;
        3'b010:
            curr_data <= idata[11:8];
        default:
            curr_data <= 4'b1111    ;
    endcase
end

//actual display segment
always@(curr_data) begin
    case(curr_data)
        4'h0:
            sseg <= 8'hc0;
        4'h1:
            sseg <= 8'hf9;
        4'h2:
            sseg <= 8'ha4;
        4'h3:
            sseg <= 8'hb0;
        4'h4:
            sseg <= 8'h99;
        4'h5:
            sseg <= 8'h92;
        4'h6:
            sseg <= 8'h82;
        4'h7:
            sseg <= 8'hf8;
        4'h8:
            sseg <= 8'h80;
        4'h9:
            sseg <= 8'h90;
        default:
            sseg <= 8'hff;
    endcase
end

endmodule


