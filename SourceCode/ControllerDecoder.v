`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Huang Yifan (hyf15@mail.ustc.edu.cn)
// 
// Design Name: RV32I Core
// Module Name: Controller Decoder
// Tool Versions: Vivado 2017.4.1
// Description: Controller Decoder Module
// 
//////////////////////////////////////////////////////////////////////////////////

//  功能说明
    //  对指令进行译码，将其翻译成控制信号，传输给各个部件
// 输入
    // Inst              待译码指令
// 输出
    // jal               jal跳转指令
    // jalr              jalr跳转指令
    // op2_src           ALU的第二个操作数来源。为1时，op2选择imm，为0时，op2选择reg2
    // ALU_func          ALU执行的运算类型
    // br_type           branch的判断条件，可以是不进行branch
    // load_npc          写回寄存器的值的来源（PC或者ALU计算结果）, load_npc == 1时选择PC
    // wb_select         写回寄存器的值的来源（Cache内容或者ALU计算结果），wb_select == 1时选择cache内容
    // load_type         load类型
    // src_reg_en        指令中src reg的地址是否有效，src_reg_en[1] == 1表示reg1被使用到了，src_reg_en[0]==1表示reg2被使用到了
    // reg_write_en      通用寄存器写使能，reg_write_en == 1表示需要写回reg
    // cache_write_en    按字节写入data cache
    // imm_type          指令中立即数类型
    // alu_src1          alu操作数1来源，alu_src1 == 0表示来自reg1，alu_src1 == 1表示来自PC
    // alu_src2          alu操作数2来源，alu_src2 == 2’b00表示来自reg2，alu_src2 == 2'b01表示来自reg2地址，alu_src2 == 2'b10表示来自立即数
// 实验要求
    // 补全模块


`include "Parameters.v"   
`define OP_JAL    7'b1101111 //JAL的操作码
`define OP_JALR   7'b1100111 //JALR的操作码
`define OP_Load   7'b0000011 //Load类指令的操作码
`define OP_Store  7'b0100011 //Store类指令的操作码
`define OP_Branch 7'b1100011 //Branch类指令的操作码
`define OP_LUI    7'b0110111 //LUI的操作码
`define OP_AUIPC  7'b0010111 //AUIPC的操作码
`define OP_RegReg 7'b0110011 //寄存器-寄存器算术指令的操作码
`define OP_RegImm 7'b0010011 //寄存器-立即数算术指令的操作码
module ControllerDecoder(
    input wire [31:0] inst,
    output wire jal,
    output wire jalr,
    output wire op2_src,
    output reg [3:0] ALU_func,
    output reg [2:0] br_type,
    output wire load_npc,
    output wire wb_select,
    output reg [2:0] load_type,
    output reg [1:0] src_reg_en,
    output reg reg_write_en,
    output reg [3:0] cache_write_en,
    output wire alu_src1,
    output wire [1:0] alu_src2,
    output reg [2:0] imm_type
    );
    // TODO: Complete this module

    wire [6:0]op;
    wire [2:0]func3;
    wire [6:0]func7;
    assign op=inst[6:0];
    assign func3=inst[14:12];
    assign func7=inst[31:25];
    
    assign jal      = op==`OP_JAL;
    assign jalr     = op==`OP_JALR;
    assign op2_src  = (op==`OP_RegImm||op==`OP_Branch||op==`OP_LUI||op==`OP_AUIPC||op==`OP_Load||op==`OP_JAL||op==`OP_JALR||op==`OP_Store)?1:0;//todo,wrong here  
    assign load_npc = (op==`OP_JAL||op==`OP_JALR);//好像是对的，jal,jalr选择pc+4存回通用寄存器中..todo
    //memtoregd
    assign wb_select= (op==`OP_Load);//load指令选择data cache，其余选择aluout
    assign alu_src1 = (op==`OP_AUIPC);//此时将alu计算pc+(imm扩展)
    //alu_src2 alusrc2d
    assign alu_src2[0] = (op==`OP_RegImm)&&(func3==3'b001||func3==3'b101);//slli,srli,srai时移位次数来自shamt不需要扩展
    assign alu_src2[1] = (op!=`OP_RegReg)&&(op!=`OP_Branch)&&(~((op==`OP_RegImm)&&(func3==3'b001||func3==3'b101)));//op=branch,alu without imm,slli,srli,srai,=0
    always@(*)begin
        case(op)//ALU_func
            `OP_RegReg:
                case(func3)
                    3'b000:ALU_func=(func7==7'b0000000)?`ADD:`SUB;
                    3'b001:ALU_func=`SLL;
                    3'b010:ALU_func=`SLT;
                    3'b011:ALU_func=`SLTU;
                    3'b100:ALU_func=`XOR;
                    3'b101:ALU_func=(func7==7'b0000000)?`SRL:`SRA;
                    3'b110:ALU_func=`OR;
                    3'b111:ALU_func=`AND;
                endcase
            `OP_RegImm:
                case(func3)
                    3'b000:ALU_func=`ADD;//ADDI
                    3'b001:ALU_func=`SLL;//SLLI
                    3'b010:ALU_func=`SLT;//SLTI
                    3'b011:ALU_func=`SLTU;//SLTIU
                    3'b100:ALU_func=`XOR;//XORI
                    3'b101:ALU_func=(func7==7'b0000000)?`SRL:`SRA;
                    3'b110:ALU_func=`OR;//ORI
                    3'b111:ALU_func=`AND;//ANDI
                endcase
            `OP_LUI:ALU_func=`LUI;
            default:ALU_func=`ADD;
        endcase

        case(op)//br_type
            `OP_Branch:
                case(func3)
                    3'b000:br_type=`BEQ;
                    3'b001:br_type=`BNE;
                    3'b100:br_type=`BLT;
                    3'b101:br_type=`BGE;
                    3'b110:br_type=`BLTU;
                    3'b111:br_type=`BGEU;
                endcase
            default:br_type=`NOBRANCH;
        endcase

        case(op)//load_type
            `OP_Load:
                case(func3)
                    3'b000:load_type=`LB;
                    3'b001:load_type=`LH;
                    3'b010:load_type=`LW;
                    3'b100:load_type=`LBU;
                    3'b101:load_type=`LHU;
                endcase
            `OP_Store:load_type=`NOREGWRITE;//store and branch don't write reg
            `OP_Branch:load_type=`NOREGWRITE;
            default:load_type=`LW;//default like alu lw
        endcase

        //src_reg_en[1] denotes reg1 being used
        if (op==`OP_LUI||op==`OP_AUIPC||op==`OP_JAL)
            src_reg_en[1]=1'b0;
        else 
            src_reg_en[1]=1'b1;

        //src_reg_en[0] denotes reg2 being used
        if(op==`OP_Store||op==`OP_RegReg||op==`OP_Branch)
            src_reg_en[0]=1'b1;
        else
            src_reg_en[0]=1'b0;

        //reg_write_en is valid if op!=store or branch
        reg_write_en=(op!=`OP_Store&&op!=`OP_Branch);

        //cache_write_en   memwrited    todo
        case(op)
            `OP_Store:
                case(func3)
                    3'b000:cache_write_en=4'b0001;
                    3'b001:cache_write_en=4'b0011;
                    3'b010:cache_write_en=4'b1111;
                endcase
            default:cache_write_en=4'b0000;
        endcase

        //imm_type
        case(op)
            `OP_LUI:   imm_type=`UTYPE;
            `OP_AUIPC:   imm_type=`UTYPE;
            `OP_JAL:   imm_type=`JTYPE;
            `OP_JALR:   imm_type=`ITYPE;
            `OP_Branch:   imm_type=`BTYPE;
            `OP_Load:   imm_type=`ITYPE;
            `OP_Store:   imm_type=`STYPE;
            `OP_RegImm:   imm_type=`ITYPE;
            `OP_RegReg:   imm_type=`RTYPE;
        endcase
    end
endmodule
