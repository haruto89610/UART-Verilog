module BaudTickGen (
    input wire clk,
    output reg BaudTick
);
    reg [15:0] acc = 0;
    
    always @(posedge clk) begin
        if (acc >= 434) begin
            acc <= 0;
            BaudTick <= 1;
        end else begin
            acc <= acc + 1;
            BaudTick <= 0;
        end
    end

endmodule

module OverSampling #(parameter sr = 4) (
    input wire clk,
    input [sr-1:0] rx,
    output reg out
);
    reg [$clog2(sr+1)-1:0] count;

    always @(posedge clk) begin
        for (int i = 0; i < sr; i++) begin
            if (rx[i]) begin
                count <= count + 1'b1;
            end
        end
        out <= (count > (sr/2));
    end

endmodule

module CrossDomainClock (
    input wire clk1,
    input wire clk2,
    input wire dataIn,
    output reg syncOut
);
    reg FF2Out, FF1Out;
    
    always @(posedge clk1) begin
        FF1Out <= dataIn;
    end

    always @(posedge clk2) begin
        FF2Out <= FF1Out;
        syncOut <= FF2Out;
    end

endmodule

module main #(parameter sr = 4) (
    input wire clk,
    input wire UART_clk, //clk from PC
    input wire rx_in,
    output reg [7:0] rx_byte,
    output reg rx_out
);
    wire BaudTickOut;
    wire rx_sync, rx_oversample;

    BaudTickGen baud(
        .clk(clk),
        .BaudTick(BaudTickOut)
    );

    CrossDomainClock sync_clk (
        .clk1(clk),
        .clk2(UART_clk),
        .dataIn(rx_in),
        .syncOut(rx_sync)
    );

    OverSampling #( //TODO: paramaterize all variable to sr
        .sr(sr)
    ) OverSample (
        .clk(clk),
        .rx({rx_sync, rx_sync, rx_sync, rx_sync}),
        .out(rx_oversample)
    );

    //TODO: implement FSM
    reg [3:0] bit_count;
    reg [9:0] shift_reg;

    always @(posedge clk) begin
        if (BaudTickOut) begin
            if (!rx_oversample && !rx_out) begin
                shift_reg <= 10'b0;
                bit_count <= 0;
                rx_out <= 0;
            end else if (bit_count < 10) begin
                shift_reg <= {rx_oversample, shift_reg[9:1]};
                bit_count <= bit_count + 1;
            end else if (bit_count == 10) begin
                rx_out <= 1;
            end
        end
    end

endmodule