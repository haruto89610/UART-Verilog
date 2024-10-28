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
    
)

endmodule

module main #(parameter sr = 4) (
    input wire clk,
    input [sr-1:0] rx
);
    wire BaudTickOut;

    BaudTickGen baud(
        .clk(clk),
        .BaudTick(BaudTickOut)
    );



endmodule