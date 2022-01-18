module vga_pic(
           input wire vga_clk,
           input wire sys_rst,
           input wire [1:0] x_flag,
           input wire [1:0] y_flag,
           input wire [9:0] pix_x,
           input wire [9:0] pix_y,

           output wire[9:0] score,
           output wire[11:0]pix_data_out
       );

//parameter  definiton
//--------------------- color constant ---------------------//
parameter RED       =   12'h000     ,
          ORANGE    =   12'hF00     ,
          YELLOW    =   12'h0F0     ,
          GREEN     =   12'h00F     ,
          CYAN      =   12'hFF0     ,
          BLUE      =   12'hF0F     ,
          PURPPLE   =   12'h0FF     ,
          BLACK     =   12'h000     ,
          WHITE     =   12'hFFF     ,
          GRAY      =   12'h777     ;

//--------------------- image constant ---------------------//
parameter SHIP_H    =   10'd80      ,   //lenth of ship
          SHIP_W    =   10'd80      ,   //width of ship
          SHIP_SIZE =   20'd6400    ;   //size  of ship

parameter POWER_H   =   10'd80      ,   //lenth of POWER
          POWER_W   =   10'd80      ,   //width of POWER
          POWER_SIZE=   20'd6400    ;   //size  of POWER

parameter STONE_H   =   10'd160     ,   //lenth of STONE
          STONE_W   =   10'd80      ,   //width of STONE
          STONE_SIZE=   20'd12800   ;   //size  of STONE

parameter BACK_H    =   10'd480     ,   //lenth of background
          BACK_W    =   10'd640     ,   //width of background
          BACK_SIZE =   20'd307200  ;   //size  of background

//wire  definiton
wire            ship_en     ;      //ship image read enable
wire            power_en    ;      //power image read enable
wire            stone_en    ;      //stone image read enable
wire    [11:0]  image_data  ;      //data from rom

//--------------------- reg definiton ---------------------//
//addr of items
reg     [19:0]  ship_addr   ;      //rom address of ship
reg     [19:0]  power_addr  ;      //rom address of power
reg     [19:0]  stone_addr  ;      //rom address of stone
reg     [19:0]  back_addr   ;      //rom address of background

//distance of items
reg     [9:0]   ship_x      ;      //move distance from source in X direction
reg     [9:0]   ship_y      ;      //move distance from source in Y direction
reg     [9:0]   power_x     ;      //move distance from source in X direction
reg     [9:0]   power_y     ;      //move distance from source in Y direction
reg     [9:0]   stone_x     ;
reg     [9:0]   stone_y     ;

reg     [9:0]   frame_cnt   ;

//get game_fail flag
reg   [9:0] rest_power = 10'd100    ;
reg   [2:0] time_cnt                ;
reg         get_power_en            ;
reg         get_power               ;
reg         game_fail               ;
reg         game_success            ;
reg         get_power_flag          ;

always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        game_fail <= 1'b0;
    else if((ship_en && stone_en) && (!game_success))
        game_fail <= 1'b1;
    else if((rest_power <= 10'd0) && (!game_success))
        game_fail <= 1'b1;
    else
        game_fail <= game_fail;
end

always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        time_cnt     <= 3'd0;
    else if(time_cnt == 3'd6)
        time_cnt     <= time_cnt;
    else if(frame_cnt == 10'd600)
        time_cnt     <= time_cnt + 3'd1;
    else
        time_cnt     <= time_cnt;
end

always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        game_success <= 1'b0;
    else if((!game_fail) && time_cnt == 3'd6)
        game_success <= 1'b1;
    else
        game_success <= game_success;
end

always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst) begin
        get_power_en    <=  1'b1;
        rest_power      <=  10'd100;
    end
    else if(frame_cnt == 10'd600)
        get_power_en    <=  1'b1;
    else if(get_power && get_power_en && (!game_fail)) begin
        get_power_en    <=  1'b0;
        rest_power      <=  rest_power + 10'd10;
    end
    else if(game_fail)
        rest_power      <=  10'd0;
    else if(game_success)
        rest_power      <=  10'd999;
    else if(((frame_cnt % 60) == 10'd0) && ((pix_x == (BACK_W - 10'd1)) && (pix_y == (BACK_H - 10'd1))))
        rest_power      <=  rest_power - 10'd1;
    else begin
        get_power_en    <=  get_power_en;
        rest_power      <=  rest_power;
    end
end

//set rest power
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        get_power   <=  1'b0;
    else if(get_power == 1'b1)
        get_power   <=  1'b0;
    else if(ship_en && power_en)
        get_power   <=  1'b1;
    else
        get_power   <=  get_power;
end

assign  score = rest_power;

//get pix_data_out to external module
assign  pix_data_out = ((game_fail || game_success) ? 12'd0 : image_data);

//set displaying area of items(stone, power and ship)
assign  stone_en = (((pix_x >= (stone_x))
                     && (pix_x < (stone_x + STONE_W)))
                    &&((pix_y >= (stone_y))
                       && ((pix_y < (stone_y + STONE_H)))));

assign  power_en = (((pix_x >= (power_x))
                     && (pix_x < (power_x + POWER_W)))
                    &&((pix_y >= (power_y))
                       && ((pix_y < (power_y + POWER_H)))));

assign  ship_en = (((pix_x >= (ship_x))
                    && (pix_x < (SHIP_W + ship_x)))
                   &&((pix_y >= (BACK_H - SHIP_H - ship_y))
                      && ((pix_y < (BACK_H - ship_y)))));

//--------------------------------------------------------------------------
//set displaying address of stone
wire            rand_stone_en   ;
wire            rand_power_en   ;
wire    [31:0]  rand_no         ;

//get frame_cnt
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        frame_cnt <= 10'd0;
    else if(frame_cnt == 10'd600)
        frame_cnt <= 10'd0;
    else if((pix_x == (BACK_W - 10'd1)) && (pix_y == (BACK_H - 10'd1)))
        frame_cnt <= frame_cnt + 10'd1;
    else
        frame_cnt <= frame_cnt;
end

assign  rand_stone_en   = (stone_y == (BACK_H - STONE_H - 20'd1));
assign  rand_power_en   = (frame_cnt == 10'd599);

rand_core rand(
              .clk(vga_clk                          ),
              .rst(sys_rst                          ),
              .new((rand_stone_en || rand_power_en) ),
              .rand_code(rand_no                    )
          );

//set the random position of stone emerged in X direction
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        stone_x   <=  10'd0;
    else if((stone_y == (BACK_H - STONE_H - 10'd1)))
        stone_x   <=  (rand_no % 400);
    else
        stone_x   <=  stone_x;
end

//get distance of stone in Y direction
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        stone_y  <=  10'd0;
    else if(stone_y == (BACK_H - STONE_H - 10'd1))
        stone_y  <=  10'd0;
    else if((pix_x == (BACK_W - 10'd1)) && (pix_y == (BACK_H - 10'd1)))
        stone_y  <=  stone_y + 10'd1;
    else
        stone_y  <=  stone_y;
end

//get power_x and power_y
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst) begin
        power_x <= 10'd0;
        power_y <= 10'd0;
    end
    else if(frame_cnt == 10'd600) begin
        power_x <= (rand_no % (320*560)) % 560;
        power_y <= (rand_no % (320*560)) / 560;
    end
    else begin
        power_x <= power_x;
        power_y <= power_y;
    end
end
//--------------------------------------------------------------------------


//get movement of ship in X direction
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        ship_x  <=  10'd0;
    else if(((ship_x == BACK_W - SHIP_W) && (x_flag == 2'b01)) || ((ship_x == 10'd0) && (x_flag == 2'b10)))
        ship_x  <=  ship_x;
    else if((x_flag == 2'b01) && (pix_x == BACK_W - 1 && pix_y == BACK_H - 1))
        ship_x  <=  ship_x + 10'd1;
    else if((x_flag == 2'b10) && (pix_x == BACK_W - 1 && pix_y == BACK_H - 1))
        ship_x  <=  ship_x - 10'd1;
    else
        ship_x  <=  ship_x;
end

//get movement of ship in Y direction
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        ship_y  <=  10'd0;
    else if(((ship_y == BACK_H - SHIP_H) && (y_flag == 2'b01)) || ((ship_y == 10'd0) && (y_flag == 2'b10)))
        ship_y  <=  ship_y;
    else if((y_flag == 2'b01) && (pix_x == BACK_W - 1 && pix_y == BACK_H - 1))
        ship_y  <=  ship_y + 10'd1;
    else if((y_flag == 2'b10) && (pix_x == BACK_W - 1 && pix_y == BACK_H - 1))
        ship_y  <=  ship_y - 10'd1;
    else
        ship_y  <=  ship_y;
end


/*
reg [9:0] row_cnt;
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        row_cnt <=  10'd0;
    else if((pix_x == BACK_W - 1 && pix_y == BACK_H - 1))
        row_cnt <=  (row_cnt + 1'b1) % BACK_H;
    else
        row_cnt <=  row_cnt;
end
*/

//get back_addr
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        back_addr   <=  20'd0;
    else if((pix_x == BACK_W - 1 && pix_y == BACK_H - 1))
        back_addr   <=  20'd0;
    else
        back_addr   <=  pix_y * BACK_W + pix_x;
end

//get stone_addr
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        stone_addr   <=  BACK_SIZE;
    else    if(stone_addr == BACK_SIZE + STONE_SIZE  - 1'b1)
        stone_addr   <=  BACK_SIZE;
    else    if(stone_en == 1'b1)
        stone_addr   <=  stone_addr + 1'b1;
    else
        stone_addr   <=  stone_addr;
end

//get power_addr
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        power_addr   <=  BACK_SIZE + STONE_SIZE;
    else    if(power_addr == BACK_SIZE + STONE_SIZE + POWER_SIZE - 1'b1)
        power_addr   <=  BACK_SIZE + STONE_SIZE;
    else    if(power_en == 1'b1)
        power_addr   <=  power_addr + 1'b1;
    else
        power_addr   <=  power_addr;
end

//get ship_addr
always@(posedge vga_clk or posedge sys_rst) begin
    if(sys_rst)
        ship_addr    <=  BACK_SIZE + STONE_SIZE + POWER_SIZE;
    else    if(ship_addr == BACK_SIZE + STONE_SIZE + POWER_SIZE + SHIP_SIZE  - 1'b1)
        ship_addr    <=  BACK_SIZE + STONE_SIZE + POWER_SIZE;
    else    if(ship_en == 1'b1)
        ship_addr    <=  ship_addr + 1'b1;
    else
        ship_addr    <=  ship_addr;
end

//get image data from rom
image_data readrom(
               .clka(vga_clk),         
               .ena(1'b1),             
               .wea(1'b0),            
               .addra(stone_en ? stone_addr :
                      (ship_en ? ship_addr :
                       ((power_en && get_power_en) ? power_addr :
                        back_addr))),  

               .dina(12'd0),           
               .douta(image_data)     
           );

endmodule
