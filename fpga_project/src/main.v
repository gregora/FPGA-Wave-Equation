module wave_unit(
    input wire[31:0] u,
    input wire[31:0] du,
    input wire[31:0] uL,
    input wire[31:0] uR,
    output wire[31:0] u_new,
    output wire[31:0] du_new
    );

    wire[63:0] tmp1;
    wire[63:0] tmp2;
    

        
    assign tmp1 = 4 * (uL + uR - 2*u) >> 8;
    assign du_new = du + tmp1;

    /*
    if(tmp1 == -1)
    begin
        assign tmp1 = 0;
    end
    */

    /*
    if(du_new == -1)
    begin
        assign du_new = 0;
    end
    */

    assign tmp2 = ((u + (du >> 8)) * 2047) >> 11;
    assign u_new = tmp2;

endmodule



module top (
    input wire clk,
    input wire uart_rx,
    output wire uart_tx,
    input wire button1,
    output wire [5:0] leds,
    input wire button2
    );

    reg[5:0] led_colors;
    reg[32:0] timing;
    reg[7:0] data = 48;
    wire complete;
    reg button_pressed = 0;
    reg transmit = 0;


    reg[15:0] u = 10;
    reg[15:0] du = 0;
    reg[15:0] uL = 0;
    reg[15:0] uR = 0;
    wire[15:0] u_new;
    wire[15:0] du_new;
   
    wave_unit W1(.u(u), .du(du), .uL(uL), .uR(uR), .u_new(u_new), .du_new(du_new));

    assign leds = 0;

endmodule
