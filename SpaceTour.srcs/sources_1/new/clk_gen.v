module clk_gen(
           input        clk,    //system clock
           input        rst,
           output reg   clk_25hz//output clock of 25Hz
       );
       
reg clk_50hz;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        clk_25hz <= 1'b0;
        clk_50hz <= 1'b0;
    end
    else begin
        clk_50hz <= ~clk_50hz;
        if(clk_50hz) begin
            clk_25hz <= ~clk_25hz;
        end
    end
end
endmodule