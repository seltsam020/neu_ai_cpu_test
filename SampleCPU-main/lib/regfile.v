`include "defines.vh"
module regfile(
    input wire clk,
    input wire [4:0] raddr1,
    output wire [31:0] rdata1,
    input wire [4:0] raddr2,
    output wire [31:0] rdata2,

    input wire [37:0] ex_to_id_bus,
    input wire [37:0] mem_to_id_bus,
    input wire [37:0] wb_to_id_bus,
    input wire [65:0] ex_to_id_2,
    input wire [65:0] mem_to_id_2,
    input wire [65:0] wb_to_id_2,
    
    input wire we,
    input wire [4:0] waddr,
    input wire [31:0] wdata,
    
//    input wire we,
     //write
     input wire w_hi_we,
     input wire w_lo_we,
     input wire [31:0] hi_i,
     input wire [31:0] lo_i,
     //read
     input wire r_hi_we,
     input wire r_lo_we,
     output wire[31:0] hi_o,
     output wire[31:0] lo_o
    
);

    reg [31:0] reg_array [31:0];
    reg [31:0] hi;
    reg [31:0] lo;
    // write
    always @ (posedge clk) begin
        if (we && waddr!=5'b0) begin
            reg_array[waddr] <= wdata;
        end
    end
    always @ (posedge clk) begin
        if (w_hi_we ) begin
            hi <= hi_i;
        end
        if (w_lo_we ) begin
            lo <= lo_i;
        end
    end
//        assign hi = w_hi_we ? hi_i :32'b0;
//        assign lo = w_lo_we ? lo_i :32'b0;

    wire [31:0] ex_result;
    wire ex_rf_we;
    wire [4:0] ex_rf_waddr;
    assign {
        ex_rf_we,          // 37
        ex_rf_waddr,       // 36:32
        ex_result       // 31:0
    } = ex_to_id_bus;
//       mem_to_id
    wire [31:0] mem_rf_wdata;
    wire mem_rf_we;
    wire [4:0] mem_rf_waddr;
    assign {
        mem_rf_we,      // 37
        mem_rf_waddr,   // 36:32
        mem_rf_wdata    // 31:0
    } = mem_to_id_bus;
//        wb_to_id
    wire [31:0] wb1_rf_wdata;
    wire wb1_rf_we;
    wire [4:0] wb1_rf_waddr;
    assign {
        wb1_rf_we,      // 37
        wb1_rf_waddr,   // 36:32
        wb1_rf_wdata    // 31:0
    } = wb_to_id_bus;
    
    wire hi_ex_we;
    wire lo_ex_we;
    wire [31:0] hi_ex;
    wire [31:0] lo_ex;
    wire hi_mem_we;
    wire lo_mem_we;
    wire [31:0] hi_mem;
    wire [31:0] lo_mem;
    wire hi_wb_we;
    wire lo_wb_we;
    wire [31:0] hi_wb;
    wire [31:0] lo_wb;
    assign{
        hi_ex_we,
        lo_ex_we,
        hi_ex,
        lo_ex
    } = ex_to_id_2;
    
    assign{
        hi_mem_we,
        lo_mem_we,
        hi_mem,
        lo_mem
    } = mem_to_id_2;
    
    assign{
        hi_wb_we,
        lo_wb_we,
        hi_wb,
        lo_wb
    } = wb_to_id_2;
    
    // read out 1
    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : 
    ((raddr1 == ex_rf_waddr)&& ex_rf_we) ? ex_result : 
    ((raddr1 == mem_rf_waddr)&& mem_rf_we) ? mem_rf_wdata : 
    ((raddr1 == wb1_rf_waddr)&& wb1_rf_we) ? wb1_rf_wdata :
    reg_array[raddr1];
    

    // read out2
    assign rdata2 = (raddr2 == 5'b0) ? 32'b0 : 
    ((raddr2 == ex_rf_waddr)&& ex_rf_we) ? ex_result :
    ((raddr2 == mem_rf_waddr)&& mem_rf_we) ? mem_rf_wdata : 
    ((raddr2 == wb1_rf_waddr)&& wb1_rf_we) ? wb1_rf_wdata : 
    reg_array[raddr2];
    
    assign hi_o = hi_ex_we ? hi_ex:
                   hi_mem_we ? hi_mem:
                   hi_wb_we ? hi_wb:
                     (r_hi_we) ? hi :
                     32'b0;
    assign lo_o = lo_ex_we ? lo_ex:
                   lo_mem_we ? lo_mem:
                   lo_wb_we ? lo_wb:
                     (r_lo_we) ? lo : 
                     32'b0;
     
endmodule