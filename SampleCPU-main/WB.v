`include "lib/defines.vh"
module WB(
    input wire clk,
    input wire rst,
    // input wire flush,
    input wire [`StallBus-1:0] stall,

    input wire [`MEM_TO_WB_WD-1:0] mem_to_wb_bus,

    output wire [`WB_TO_RF_WD-1:0] wb_to_rf_bus,
    
    output wire [37:0] wb_to_id_bus,
    
    output wire [31:0] debug_wb_pc,
    output wire [3:0] debug_wb_rf_wen,
    output wire [4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata,
    
    input wire[65:0] mem_to_wb1 ,
    output wire[65:0]wb_to_id_wf,
    output wire[65:0] wb_to_id_2 
);

    reg [`MEM_TO_WB_WD-1:0] mem_to_wb_bus_r;
    reg [65:0] mem_to_wb1_r;

    always @ (posedge clk) begin
        if (rst) begin
            mem_to_wb_bus_r <= `MEM_TO_WB_WD'b0;
            mem_to_wb1_r <= 66'b0;
        end
        // else if (flush) begin
        //     mem_to_wb_bus_r <= `MEM_TO_WB_WD'b0;
        // end
        else if (stall[4]==`Stop && stall[5]==`NoStop) begin
            mem_to_wb_bus_r <= `MEM_TO_WB_WD'b0;
            mem_to_wb1_r <= 66'b0;
        end
        else if (stall[4]==`NoStop) begin
            mem_to_wb_bus_r <= mem_to_wb_bus;
            mem_to_wb1_r <= mem_to_wb1;
        end
    end

    wire [31:0] wb_pc;
    wire rf_we;
    wire [4:0] rf_waddr;
    wire [31:0] rf_wdata;
    
    wire w_hi_we;
    wire w_lo_we;
    wire [31:0]hi_i;
    wire [31:0]lo_i;
     
    assign {
        wb_pc,
        rf_we,
        rf_waddr,
        rf_wdata
    } = mem_to_wb_bus_r;
    
    assign 
    {
        w_hi_we,
        w_lo_we,
        hi_i,
        lo_i
    } = mem_to_wb1_r;
    
    assign wb_to_id_wf=
    {
        w_hi_we,
        w_lo_we,
        hi_i,
        lo_i
    };
    
    assign wb_to_id_2=
    {
        w_hi_we,
        w_lo_we,
        hi_i,
        lo_i
    };
    
    // assign wb_to_rf_bus = mem_to_wb_bus_r[`WB_TO_RF_WD-1:0];
    assign wb_to_rf_bus = {
        rf_we,
        rf_waddr,
        rf_wdata
    };
    assign wb_to_id_bus = {
        rf_we,
        rf_waddr,
        rf_wdata
    };

    assign debug_wb_pc = wb_pc;
    assign debug_wb_rf_wen = {4{rf_we}};
    assign debug_wb_rf_wnum = rf_waddr;
    assign debug_wb_rf_wdata = rf_wdata;

    
endmodule