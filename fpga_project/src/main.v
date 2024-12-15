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
    assign du_new = (tmp1 == -1) ? du:
                    (tmp1 != -1) ? du + tmp1:
                    0;

    assign tmp2 = ((u + (du >> 8)) * 2047) >> 11;
    assign u_new = tmp2;

endmodule



module uart
#(
    parameter DELAY_FRAMES = 234 // 27,000,000 (27Mhz) / 115200 Baud rate
)
(
    input wire clk,
    input wire[7:0] data,
    input wire transmit, // whether to transmit or not
    output wire uart_tx,
    output wire ready // output flag if done

);

    reg [7:0] clock_counter = 0;
    reg [5:0] counter = 10;
    reg ready_reg = 1;
    reg bit = 1;

    always @(posedge clk) begin

        if(counter == 0)
        begin
            bit <= 0;
            ready_reg <= 0;
        end

        if(counter >= 1 && counter <= 8)
        begin
            bit <= data[counter - 1];
        end

        if(counter == 9)
        begin
            bit <= 1;
        end

        if(counter == 10)
        begin
            ready_reg <= 1;
            clock_counter <= 0;
            
            if(transmit == 1)
            begin
                counter <= 0;
            end

            else
            begin
                counter <= 10;
            end
        end


        if(counter != 10)
        begin
        if(clock_counter == 234)
            begin
                clock_counter <= 0;
                counter <= counter + 1;
            end

            else
            begin
                clock_counter <= clock_counter + 1;
            end
        end

end

    assign uart_tx = bit;
    assign ready = ready_reg;
endmodule


module transmit_array (
    input wire clk,
    input wire[31:0] u[100:0],
    input wire transmit, // whether to transmit or not
    output wire uart_tx,
    output wire ready // output flag if done

);

endmodule



module top (
    input wire clk,
    input wire uart_rx,
    output wire uart_tx,
    input wire button1,
    output wire [5:0] leds,
    input wire button2
    );

    reg[31:0] u_arr[99:0];
    reg[31:0] du_arr[99:0];
    wire[31:0] u_new_arr[99:0];
    wire[31:0] du_new_arr[99:0];


    reg[5:0] led_colors;
    reg[32:0] timing;
    reg[7:0] data = 49;
    wire complete;
    reg button_pressed = 0;
    reg transmit = 1;


    reg[31:0] u = 10;
    reg[31:0] du = 0;
    reg[31:0] uL = 0;
    reg[31:0] uR = 0;
    wire[31:0] u_new;

    wire[31:0] du_new;
   

    uart U1(.clk(clk), .data(data), .transmit(transmit), .uart_tx(uart_tx), .ready(complete));

    wave_unit W1(.u(u), .du(du), .uL(uL), .uR(uR), .u_new(u_new), .du_new(du_new));

    always @(posedge clk) begin
        u <= u_new;
        du <= du_new;
    end

    assign leds = 0;


endmodule
