module wave_unit(
    input wire signed[31:0] u,
    input wire signed[31:0] du,
    input wire signed[31:0] uL,
    input wire signed[31:0] uR,
    output wire signed[31:0] u_new,
    output wire signed[31:0] du_new
    );

    wire signed[63:0] tmp1;
    wire signed[63:0] tmp2;
    

        
    assign tmp1 = ((4 * (uL + uR - 2*u)) >>> 8);
    assign du_new = (tmp1 == -1) ? du:
                    (tmp1 != -1) ? du + tmp1:
                    0;

    assign tmp2 = (((u + (du >>> 8)) * 2047) >>> 11);
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
            ready_reg <= 0;
            bit <= 0;
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
            clock_counter <= 0;
            
            if(transmit == 1)
            begin
                ready_reg <= 0;
                counter <= 0;
            end

            else
            begin
                ready_reg <= 1;
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
    input wire[32*20-1:0] u,
    input wire transmit, // whether to transmit or not
    output wire uart_tx,
    output wire ready // output flag if done

);

    reg[31:0] current_byte = 20*4; // what byte are we on
    wire[7:0] data; // what is the data in that byte
    reg transmit_byte = 0; // whether to transmit the next byte

    wire uart_ready;
    
    reg ready_reg;
    


    uart U(.clk(clk), .data(data), .transmit(transmit_byte), .uart_tx(uart_tx), .ready(uart_ready));


    always @(posedge clk) begin

    // header
    if(current_byte < 4 && current_byte >= 0) // 4 bytes of header
    begin
        if(uart_ready && transmit_byte == 0)
        begin
            transmit_byte <= 1;
            current_byte <= current_byte + 1;
        end
        else
        begin
            transmit_byte <= 0;
        end
    end

    // data
    if(current_byte <= 4 + 20*4 && current_byte >= 4) // header + 20 ints
    begin
        if(uart_ready && transmit_byte == 0)
        begin
            transmit_byte <= 1;
            current_byte <= current_byte + 1;
        end
        else
        begin
            transmit_byte <= 0;
        end
    end

    // wait
    if(current_byte == 4 + 20*4) // header + 20 ints
        begin
        ready_reg <= 1;
        transmit_byte <= 0;

        if(uart_ready && transmit)
        begin
            current_byte <= 0;
            ready_reg <= 0;
            transmit_byte <= 1;
        end
    end

    end

    assign ready = ready_reg;
    assign data = (current_byte >= 4) ? u[(current_byte - 4)*8+:8]:
                  'b1;

endmodule



module top (
    input wire clk,
    input wire uart_rx,
    output wire uart_tx,
    input wire button1,
    output wire [5:0] leds,
    input wire button2
    );

    reg[32*20 - 1:0] u_arr;
    reg[32*20 - 1:0] du_arr;


    reg[5:0] led_colors;
    reg[32:0] timing;
    // reg[7:0] data = 49;
    wire complete;
    reg button_pressed = 0;
    reg transmit = 1;


    wire signed[31:0] u;
    wire signed[31:0] du;
    wire signed[31:0] uL;
    wire signed[31:0] uR;

    wire signed[31:0] u_new;
    wire signed[31:0] du_new;

    reg[7:0] i_u = 1;

    integer i;
    initial begin
        for (i = 0; i < 20; i = i + 1) begin
            u_arr[(i)*32+:32] <= (i > 10 && i < 15) ? 200000000:
                        0;                 
            du_arr[i] <= 0;
            
        end
    end

    transmit_array T1(.clk(clk), .u(u_arr), .transmit('b1), .uart_tx(uart_tx), .ready(complete));
    wave_unit W1(.u(u), .du(du), .uL(uL), .uR(uR), .u_new(u_new), .du_new(du_new));

    //uart U(.clk(clk), .data(data), .transmit('b1), .uart_tx(uart_tx), .ready(complete));

    reg[15:0] iter = 0;

    always @(posedge clk) begin
        u_arr[0+:32] <= u_arr[32+:32];        // edge case 1
        u_arr[19*32+:32] <= u_arr[18*32+:32]; // edge case 2

        if (i_u < 19)
        begin
            u_arr[i_u*32+:32] <= u_new;
            du_arr[i_u*32+:32] <= du_new;
            
            i_u <= i_u + 1;
            
        end

        if (i_u == 19 && iter < 10000)
        begin
            i_u <= 1;
            iter = iter + 1;
        end

    end

    assign leds = 0;

    assign u = u_arr[i_u*32+:32];
    assign du = du_arr[i_u*32+:32];
    assign uL = u_arr[(i_u - 1)*32+:32];
    assign uR = u_arr[(i_u + 1)*32+:32];

endmodule
