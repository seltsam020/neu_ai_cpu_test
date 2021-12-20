`include "lib/defines.vh"
module EX(
    input wire clk,
    input wire rst,
    // input wire flush,
    input wire [`StallBus-1:0] stall,

    input wire [`ID_TO_EX_WD-1:0] id_to_ex_bus,
    
//    input wire [67:0] id_to_ex_2,

    output wire [`EX_TO_MEM_WD-1:0] ex_to_mem_bus,
    
    output wire [37:0] ex_to_id_bus,

    output wire data_sram_en,
    output wire [3:0] data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    output wire inst_is_load,
    
    output wire stallreq_for_ex,
    output wire [65:0]ex_to_mem1,
    output wire [65:0]ex_to_id_2,
    output wire ready_ex_to_id
);

    reg [`ID_TO_EX_WD-1:0] id_to_ex_bus_r;
//    reg [67:0] id_to_ex_2_r;

    always @ (posedge clk) begin
        if (rst) begin
            id_to_ex_bus_r <= `ID_TO_EX_WD'b0;
//            id_to_ex_2_r <= 68'b0;
        end
        // else if (flush) begin
        //     id_to_ex_bus_r <= `ID_TO_EX_WD'b0;
        // end
        else if (stall[2]==`Stop && stall[3]==`NoStop) begin
            id_to_ex_bus_r <= `ID_TO_EX_WD'b0;
//            id_to_ex_2_r <= 68'b0;
        end
        else if (stall[2]==`NoStop) begin
            id_to_ex_bus_r <= id_to_ex_bus;
//            id_to_ex_2_r <= id_to_ex_2;
        end
    end
    wire [31:0] ex_pc, inst;
    wire [11:0] alu_op;
    wire [2:0] sel_alu_src1;
    wire [3:0] sel_alu_src2;
    wire data_ram_en;
    wire [3:0] data_ram_wen;
    wire [3:0] data_ram_read;
    wire rf_we;
    wire [4:0] rf_waddr;
    wire sel_rf_res;
    wire [31:0] rf_rdata1, rf_rdata2;
    reg is_in_delayslot;
    wire [1:0] lo_hi_r;
    wire [1:0] lo_hi_w;
    wire w_hi_we;
    wire w_lo_we;
    wire w_hi_we3;
    wire w_lo_we3;
    wire [31:0] hi_i;
    wire [31:0] lo_i;
    wire[31:0] hi_o;
    wire[31:0] lo_o;

    assign {
        ex_pc,          // 158:127
        inst,           // 126:95
        alu_op,         // 94:83
        sel_alu_src1,   // 82:80
        sel_alu_src2,   // 79:76
        data_ram_en,    // 75
        data_ram_wen,   // 74:71
        rf_we,          // 70            // write
        rf_waddr,       // 69:65         //write
        sel_rf_res,     // 64
        rf_rdata1,         // 63:32      //rs
        rf_rdata2,          // 31:0      //rt
        lo_hi_r,                        //readÐÅºÅ
        lo_hi_w,                        //writeÐÅºÅ
        lo_o,                           //loÖµ
        hi_o,                            //hiÖµ
        data_ram_read
    } = id_to_ex_bus_r;
    
    
    
//    wire inst_lsa;
//    assign inst_lsa  = (inst[31:26]==6'b01_1100)  & (inst[10:8]==3'b111) & (inst[5:0]==6'b11_0111);
//    wire [2:0] zuoyi;
//    assign zuoyi = inst_lsa ? (inst[7:6] + 1'b1) :  3'b0;
    
//   wire [31:0] aaa;
    
//    assign aaa = inst[7:6] == 2'b11 ?  ({rf_rdata1[27:0],4'b0}):
//                  inst[7:6] == 2'b00 ?  ({rf_rdata1[30:0],1'b0}):
//                  inst[7:6] == 2'b01 ?  ({rf_rdata1[29:0],2'b0}):
//                  inst[7:6] == 2'b10 ?  ({rf_rdata1[28:0],3'b0}):
//                  32'b0;
//    assign rf_rdata1 = inst_lsa ? aaa : rf_rdata1;
  
//    assign {
//        lo_hi_r,                        //readÐÅºÅ
//        lo_hi_w,                        //writeÐÅºÅ
//        lo_o,                           //loÖµ
//        hi_o                            //hiÖµ
//      }= id_to_ex_2_r;
    
    assign w_lo_we3 = lo_hi_w[0]==1'b1 ? 1'b1:1'b0;
    assign w_hi_we3 = lo_hi_w[1]==1'b1 ? 1'b1:1'b0;
    
    assign inst_is_load =  (inst[31:26] == 6'b10_0011) ? 1'b1 :1'b0;
    
    
    wire [31:0] imm_sign_extend, imm_zero_extend, sa_zero_extend;
    assign imm_sign_extend = {{16{inst[15]}},inst[15:0]};
    assign imm_zero_extend = {16'b0, inst[15:0]};
    assign sa_zero_extend = {27'b0,inst[10:6]};

    wire [31:0] alu_src1, alu_src2;
    wire [31:0] alu_result, ex_result;

    assign alu_src1 = sel_alu_src1[1] ? ex_pc :
                      sel_alu_src1[2] ? sa_zero_extend : rf_rdata1;

    assign alu_src2 = sel_alu_src2[1] ? imm_sign_extend :
                      sel_alu_src2[2] ? 32'd8 :
                      sel_alu_src2[3] ? imm_zero_extend : rf_rdata2;
    
    alu u_alu(
    	.alu_control (alu_op ),
        .alu_src1    (alu_src1    ),
        .alu_src2    (alu_src2    ),
        .alu_result  (alu_result  )
    );

    assign ex_result =  lo_hi_r[0] ? lo_o :
                         lo_hi_r[1] ? hi_o :
                         alu_result;


    assign data_sram_en = data_ram_en ;
    assign data_sram_wen = (data_ram_read==4'b0101 && ex_result[1:0] == 2'b00 )? 4'b0001: 
                            (data_ram_read==4'b0101 && ex_result[1:0] == 2'b01 )? 4'b0010:
                            (data_ram_read==4'b0101 && ex_result[1:0] == 2'b10 )? 4'b0100:
                            (data_ram_read==4'b0101 && ex_result[1:0] == 2'b11 )? 4'b1000:
                            (data_ram_read==4'b0111 && ex_result[1:0] == 2'b00 )? 4'b0011:
                            (data_ram_read==4'b0111 && ex_result[1:0] == 2'b10 )? 4'b1100:
                            data_ram_wen;
    assign data_sram_addr = ex_result ;
    assign data_sram_wdata = data_sram_wen==4'b1111 ? rf_rdata2 : 
                              data_sram_wen==4'b0001 ? {24'b0,rf_rdata2[7:0]} :
                              data_sram_wen==4'b0010 ? {16'b0,rf_rdata2[7:0],8'b0} :
                              data_sram_wen==4'b0100 ? {8'b0,rf_rdata2[7:0],16'b0} :
                              data_sram_wen==4'b1000 ? {rf_rdata2[7:0],24'b0} :
                              data_sram_wen==4'b0011 ? {16'b0,rf_rdata2[15:0]} :
                              data_sram_wen==4'b1100 ? {rf_rdata2[15:0],16'b0} :
                              32'b0;
    
    assign ex_to_mem_bus = {
        ex_pc,          // 75:44
        data_ram_en,    // 43
        data_ram_wen,   // 42:39
        sel_rf_res,     // 38
        rf_we,          // 37
        rf_waddr,       // 36:32
        ex_result,       // 31:0
        data_ram_read
    };
   
    
    assign ex_to_id_bus = {
        rf_we,          // 37
        rf_waddr,       // 36:32
        ex_result       // 31:0
    };
    
    wire w_hi_we1;
    wire w_lo_we1;
    wire mult;
    wire multu;
    assign mult = (inst[31:26] == 6'b00_0000) & (inst[15:6] == 10'b0000000000) & (inst[5:0] == 6'b01_1000);
    assign multu= (inst[31:26] == 6'b00_0000) & (inst[15:6] == 10'b0000000000) & (inst[5:0] == 6'b01_1001);
    assign w_hi_we1 = mult | multu ;
    assign w_lo_we1 = mult | multu ;
    
    // MUL part
//    wire [63:0] mul_result;
//    wire mul_signed; // ï¿½Ð·ï¿½ï¿½Å³Ë·ï¿½ï¿½ï¿½ï¿?
//    wire [31:0] mul_1;
//    wire [31:0] mul_2;
//    assign mul_1 = w_hi_we1 ? alu_src1 : 32'b0;
//    assign mul_2 = w_hi_we1 ? alu_src2 : 32'b0;
//    assign mul_signed = mult;

//    mul u_mul(
//    	.clk        (clk            ),
//        .resetn     (~rst           ),
//        .mul_signed (mul_signed     ),
//        .ina        (  mul_1    ), // ï¿½Ë·ï¿½Ô´ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½1
//        .inb        (  mul_2    ), // ï¿½Ë·ï¿½Ô´ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½2
//        .result     (mul_result     ) // ï¿½Ë·ï¿½ï¿½ï¿½ï¿? 64bit
//    );
    wire [63:0] mul_result;
    wire mul_ready_i;
//    wire [31:0] mul_1;
//    wire [31:0] mul_2;
    wire mul_begin;
//    assign mul_1 = w_hi_we1 ? alu_src1 : 32'b0;
//    assign mul_2 = w_hi_we1 ? alu_src2 : 32'b0;
    wire mul_signed;
    assign mul_signed = mult;
    assign mul_begin = mult | multu ;

    mul_plus u_mul_plus(
    	.clk        (clk            ),
    	.start_i      (mul_begin),
    	.mul_sign     (mul_signed),
        .opdata1_i    (  rf_rdata1    ), // ï¿½Ë·ï¿½Ô´ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½1
        .opdata2_i    (  rf_rdata2    ), // ï¿½Ë·ï¿½Ô´ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½2
        .result_o     (mul_result     ), // ï¿½Ë·ï¿½ï¿½ï¿½ï¿? 64bit
        .ready_o      (mul_ready_i      )
    );

    // DIV part
    wire [63:0] div_result;
    wire inst_div, inst_divu;
    wire div_ready_i;
    reg stallreq_for_div;
    wire w_hi_we2;
    wire w_lo_we2;
    assign stallreq_for_ex = (stallreq_for_div & div_ready_i==1'b0) | (mul_begin & mul_ready_i==1'b0);
    assign ready_ex_to_id = div_ready_i | mul_ready_i;
    
    assign inst_div = (inst[31:26] == 6'b00_0000) & (inst[15:6] == 10'b0000000000) & (inst[5:0] == 6'b01_1010);
    assign inst_divu= (inst[31:26] == 6'b00_0000) & (inst[15:6] == 10'b0000000000) & (inst[5:0] == 6'b01_1011);
    assign w_hi_we2 = inst_div | inst_divu;
    assign w_lo_we2 = inst_div | inst_divu;
    

    reg [31:0] div_opdata1_o;
    reg [31:0] div_opdata2_o;
    reg div_start_o;
    reg signed_div_o;
    


    div u_div(
    	.rst          (rst          ),
        .clk          (clk          ),
        .signed_div_i (signed_div_o ),
        .opdata1_i    (div_opdata1_o    ),
        .opdata2_i    (div_opdata2_o    ),
        .start_i      (div_start_o      ),
        .annul_i      (1'b0      ),
        .result_o     (div_result     ), // ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿? 64bit
        .ready_o      (div_ready_i      )
    );

    always @ (*) begin
        if (rst) begin
            stallreq_for_div = `NoStop;
            div_opdata1_o = `ZeroWord;
            div_opdata2_o = `ZeroWord;
            div_start_o = `DivStop;
            signed_div_o = 1'b0;
        end
        else begin
            stallreq_for_div = `NoStop;
            div_opdata1_o = `ZeroWord;
            div_opdata2_o = `ZeroWord;
            div_start_o = `DivStop;
            signed_div_o = 1'b0;
            case ({inst_div,inst_divu})
                2'b10:begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o = rf_rdata1;
                        div_opdata2_o = rf_rdata2;
                        div_start_o = `DivStart;
                        signed_div_o = 1'b1;
                        stallreq_for_div = `Stop;
                    end
                    else if (div_ready_i == `DivResultReady) begin
                        div_opdata1_o = rf_rdata1;
                        div_opdata2_o = rf_rdata2;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b1;
                        stallreq_for_div = `NoStop;
                    end
                    else begin
                        div_opdata1_o = `ZeroWord;
                        div_opdata2_o = `ZeroWord;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `NoStop;
                    end
                end
                2'b01:begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o = rf_rdata1;
                        div_opdata2_o = rf_rdata2;
                        div_start_o = `DivStart;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `Stop;
                    end
                    else if (div_ready_i == `DivResultReady) begin
                        div_opdata1_o = rf_rdata1;
                        div_opdata2_o = rf_rdata2;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `NoStop;
                    end
                    else begin
                        div_opdata1_o = `ZeroWord;
                        div_opdata2_o = `ZeroWord;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `NoStop;
                    end
                end
                default:begin
                end
            endcase
        end
    end
    
    assign lo_i = w_lo_we1 ? mul_result[31:0]:
                   w_lo_we2 ?div_result[31:0]:
                   w_lo_we3 ? rf_rdata1:
                    32'b0;
    assign hi_i = w_hi_we1 ? mul_result[63:32]:
                   w_hi_we2 ? div_result[63:32]:
                   w_hi_we3 ? rf_rdata1:
                    32'b0;
    assign w_hi_we = w_hi_we1 | w_hi_we2 | w_hi_we3;
    assign w_lo_we = w_lo_we1 | w_lo_we2 | w_lo_we3;
        assign ex_to_mem1 =
    {
        w_hi_we,
        w_lo_we,
        hi_i,
        lo_i
    };
    assign ex_to_id_2=
    {
        w_hi_we,
        w_lo_we,
        hi_i,
        lo_i
    };

    // mul_result ï¿½ï¿½ div_result ï¿½ï¿½ï¿½ï¿½Ö±ï¿½ï¿½Ê¹ï¿½ï¿½
    
    
endmodule