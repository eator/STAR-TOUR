`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/21 23:47:59
// Design Name: 
// Module Name: accel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module accel(
    input  clk,
    input  rst,
    output reg LED_INT1,
    output reg LED_INT2,
    
    // UART port
    output TXD,
    input  RXD,
    output CTS,
    input  RTS,
    
    // SPI port
    output ACL_CSN,
    output ACL_MOSI,
    input  ACL_MISO,
    output ACL_SCLK,
    input  ACL_INT1,
    input  ACL_INT2
    );

    // Direct connect LED to interrupt pins 把LED接到两个中断引脚上
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            LED_INT1 <= 1'b0;
            LED_INT2 <= 1'b0;
        end
        else begin
            LED_INT1 <= ACL_INT1;
            LED_INT2 <= ACL_INT2;
        end
    end

    // SPI controller 调用前面写好的SPI控制模块
    reg        SPI_ready;
    reg  [7:0] SPI_inst;
    reg        SPI_rdh_wrl;
    reg  [7:0] SPI_reg_addr;
    reg  [7:0] SPI_dout;
    wire [7:0] SPI_din;
    wire       SPI_din_valid;
    SPI_transmitter SPI_transmitter(
        .clk        (clk),
        .rst        (rst),
        
        // SPI port
        .CSN        (ACL_CSN),
        .SCLK       (ACL_SCLK),
        .MOSI       (ACL_MOSI),
        .MISO       (ACL_MISO),
        
        // Control port
        .ready      (SPI_ready),
        .inst       (SPI_inst),
        .rdh_wrl    (SPI_rdh_wrl),
        .reg_addr   (SPI_reg_addr),
        .dout       (SPI_dout),
        .din        (SPI_din),
        .din_valid  (SPI_din_valid)
    );

    // Data IO with UART  调用UART_transmitter.v和syn_fifo.v
    wire [3:0] uart_din;
    reg  [3:0] uart_din_d;
    wire       uart_din_valid;
    reg  [7:0] uart_dout;
    reg        uart_dout_ready;
    UART_transmitter UART_transmitter(
        .clk         (clk),
        .rst         (rst),
        
        // UART port
        .TXD         (TXD),
        .RXD         (RXD),
        .CTS         (CTS),
        .RTS         (RTS),
        
        // Control port
        .dout        (uart_dout),
        .dout_ready  (uart_dout_ready),
        .din         (uart_din),
        .din_valid   (uart_din_valid)
    );

    // Command control  新的串口控制逻辑
    // [27:24] rdh_wrl
    // [23:16] inst
    // [15: 8] reg_addr
    // [ 7: 0] din
    reg [27:0] UART_cmd_buf;
    reg [3:0]  din_count;
    always @(posedge clk) begin
        if(rst) begin
            UART_cmd_buf <= 28'h0000000;
            uart_dout_ready <= 1'b0;
            uart_dout <= 8'h00;
            din_count <= 4'd0;
            SPI_ready <= 1'b0;
            SPI_inst <= 8'h00;
            SPI_rdh_wrl <= 1'b0;
            SPI_reg_addr <= 8'h00;
            SPI_dout <= 8'h00;
        end
        else if(uart_din_valid && din_count < 4'd7) begin
            UART_cmd_buf <= {UART_cmd_buf[23:0], uart_din};
            if(din_count[0]) begin
                uart_dout <= {uart_din_d, uart_din};
                uart_dout_ready <= 1'b1;
            end
            else begin
                uart_din_d <= uart_din;
            end
            din_count <= din_count + 4'd1;
        end
        else if(uart_din_valid && din_count == 4'd7) begin
            uart_dout <= {uart_din_d, uart_din};
            uart_dout_ready <= 1'b1;
            din_count <= 4'd0;
            SPI_ready <= 1'b1;
            SPI_inst <= UART_cmd_buf[19:12];
            if(UART_cmd_buf[23:20] == 4'b0000) begin
                SPI_rdh_wrl <= 1'b0;
            end
            else if(UART_cmd_buf[23:20] == 4'b0001) begin
                SPI_rdh_wrl <= 1'b1;
            end
            SPI_reg_addr <= UART_cmd_buf[11:4];
            SPI_dout <= {UART_cmd_buf[3:0], uart_din};
        end
        else if(SPI_din_valid) begin
            uart_dout <= SPI_din;
            uart_dout_ready <= 1'b1;
        end
        else begin
            uart_dout_ready <= 1'b0;
            SPI_ready <= 1'b0;
        end
    end

endmodule

