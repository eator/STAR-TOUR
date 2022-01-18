module rand_core(
           input               clk,        //系统时钟信号
           input               rst,        //复位信号，高电平有效
           input               new,        //新随机数产生信号，上升沿有效

           output reg  [31:0] rand_code
       );

parameter seed      = 32'h3ecd12;           //开始种子
parameter feedback  = 32'h280c97;           //反馈系数

reg [31:0] time_seed;
reg        reset_seed_d;
reg        new_d;
reg [31:0] new_cnt;

//计算新的位
/* 注^号在verilog中可作为单目运算符使用，表示位异或 */
wire feedback_item = ^(feedback & rand_code);

//new信号次数计数器
//当new了2^31-1次后，产生种子重装载信号
wire reset_seed; //种子重装信号，低电平有效
assign reset_seed = (new_cnt == ~(32'd0)) ? 1'b0:1'b1;
always @(posedge clk or posedge rst) begin
    if(rst)
        new_cnt <= 32'd0;
    else if(new_d & (~new))
        new_cnt <= new_cnt + 1'b1;
    else if(new_cnt == ~(32'd0))
        new_cnt <= 32'd0;
end

//信号缓存器更新块
always @(posedge clk or posedge rst) begin
    if(rst)
        new_d <= 1'b0;
    else
        new_d <= new;
end

//clk计数器实现种子更新
always @(posedge clk or posedge rst) begin
    if(rst)
        time_seed <= 32'd0;
    else
        time_seed <= time_seed + 1'b1;
end

//M序列模块
always @(posedge clk or posedge rst) begin
    if(rst)
        rand_code <= seed;
    else if(!reset_seed)
        rand_code <= rand_code ^ time_seed;
    else if(~new_d & new)
        rand_code <= {feedback_item,rand_code[31:1]};
    //防止进入全0死锁状态
    else if(rand_code == 32'd0)
        rand_code <= seed;
end

endmodule
