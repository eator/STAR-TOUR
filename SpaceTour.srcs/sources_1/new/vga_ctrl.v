module vga_ctrl(
           input  wire          vga_clk ,
           input  wire          sys_rst ,
           input  wire [11:0]   pix_data,
           output wire [9:0]    pix_x   ,
           output wire [9:0]    pix_y   ,
           output wire          hsync   ,
           output wire          vsync   ,
           output wire [11:0]   rgb
       );

wire            rgb_valid       ;   //VGA valid displaying region signal
wire            pix_data_req    ;   //pixel data request signal before send data

//reg   define
reg     [9:0]   cnt_h           ;   //herizontal synchronization signal
reg     [9:0]   cnt_v           ;   //vertical synchronization signal

parameter   H_SYNC    =   10'd96  ,   //herizontal synchronization amount
            H_BACK    =   10'd40  ,   //herizontal time series back-edge amount
            H_LEFT    =   10'd8   ,   //herizontal time series left border amount
            H_VALID   =   10'd640 ,   //herizontal valid displaying pixel amount
            H_RIGHT   =   10'd8   ,   //herizontal time series right border amount
            H_FRONT   =   10'd8   ,   //herizontal time series front-edge amount
            H_TOTAL   =   10'd800 ;   //herizontal sum amount

parameter   V_SYNC    =   10'd2   ,   //vertical synchronization amount
            V_BACK    =   10'd25  ,   //vertical time series back-edge amount
            V_TOP     =   10'd8   ,   //vertical time series top border amount
            V_VALID   =   10'd480 ,   //vertical valid displaying pixel amount
            V_BOTTOM  =   10'd8   ,   //vertical time series bottom border amount
            V_FRONT   =   10'd2   ,   //vertical time series front-edge amount
            V_TOTAL   =   10'd525 ;   //vertical sum amount

always @(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        cnt_h   <=  10'd0   ;
    else if(cnt_h == H_TOTAL - 1'd1)
        cnt_h   <=  10'd0   ;
    else
        cnt_h   <=  cnt_h + 1'd1   ;
end
assign  hsync = (cnt_h  <=  H_SYNC - 1'd1) ? 1'b1 : 1'b0  ;

// get cnt_v
always @(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst) begin
        cnt_v   <=  10'd0 ;
    end
    else if((cnt_v == V_TOTAL - 1'd1) && (cnt_h == H_TOTAL-1'd1)) begin
        cnt_v   <=  10'd0 ;
    end
    else if(cnt_h == H_TOTAL - 1'd1)
        cnt_v <=  cnt_v + 1'd1 ;
    else
        cnt_v <=  cnt_v ;
end

assign  vsync = (cnt_v  <=  V_SYNC - 1'd1) ? 1'b1 : 1'b0;


//get rgb_valid assignment
assign  rgb_valid = (((cnt_h >= H_SYNC + H_BACK + H_LEFT)
                      && (cnt_h < H_SYNC + H_BACK + H_LEFT + H_VALID))
                     &&((cnt_v >= V_SYNC + V_BACK + V_TOP)
                        && (cnt_v < V_SYNC + V_BACK + V_TOP + V_VALID)))
        ? 1'b1 : 1'b0;

//get pix_data_req assignment, (before send data(1 clock in advance))
assign  pix_data_req = (((cnt_h >= H_SYNC + H_BACK + H_LEFT - 1'b1)
                         && (cnt_h < H_SYNC + H_BACK + H_LEFT + H_VALID - 1'b1))
                        &&((cnt_v >= V_SYNC + V_BACK + V_TOP)
                           && (cnt_v < V_SYNC + V_BACK + V_TOP + V_VALID)))
        ? 1'b1 : 1'b0;


//get pix_x and pix_y
assign  pix_x = (pix_data_req == 1'b1)
        ? (cnt_h - (H_SYNC + H_BACK + H_LEFT - 1'b1)) : 10'h3ff;
assign  pix_y = (pix_data_req == 1'b1)
        ? (cnt_v - (V_SYNC + V_BACK + V_TOP)) : 10'h3ff;

//get rgb data
assign  rgb = (rgb_valid == 1'b1) ? pix_data : 12'b0 ;

endmodule
