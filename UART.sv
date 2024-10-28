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

module OverSampling (
    input wire clk,
    input wire rx,
    output reg 
);

endmodule