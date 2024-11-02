/*
 * Copyright (c) 2024 Siddharth Nema
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_control_block (
    input wire clk,
    
    input  wire [7:0] ui_in,    // Dedicated inputs - only bits 0 to 3 are used
    output wire [7:0] uo_out,   // Dedicated outputs - first half of the the output signals (only bits 0 to 6 used)
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output) - set to all outputs - lower half of the output signals

    input  wire [7:0] uio_in,   // IOs: Input path - not used
    input  wire ena,      // always 1 when the design is powered, so you can ignore it
    input  wire rst_n     // reset_n - low to reset
);

// Assign the inputs to wires
wire [3:0] opcode = ui_in [3:0];
assign uio_oe = 8'hff;    // Configure the bidirectional pins to be all outputs

/* Supported Instructions' Opcodes */
localparam OP_HLT = 4'h0;
// localparam OP_NOP = 4'h1;  // Comment this out to avoid error with unused param.
localparam OP_ADD = 4'h2;
localparam OP_SUB = 4'h3;
localparam OP_LDA = 4'h4;
localparam OP_OUT = 4'h5;
localparam OP_STA = 4'h6;
localparam OP_JMP = 4'h7;


/* Output Control Signals */
localparam SIG_PC_INC = 14;             // C_P
localparam SIG_PC_EN = 13;              // E_P
localparam SIG_PC_LOAD = 12;            // L_P
localparam SIG_MAR_ADDR_LOAD_N = 11;    // \L_MA
localparam SIG_MAR_MEM_LOAD_N = 10;     // \L_MD
localparam SIG_RAM_EN_N = 9;            // \CE
localparam SIG_RAM_LOAD_N = 8;          // \L_R
localparam SIG_IR_LOAD_N = 7;           // \L_I
localparam SIG_IR_EN_N = 6;             // \E_I
localparam SIG_REGA_LOAD_N = 5;         // \L_A
localparam SIG_REGA_EN = 4;             // E_A
localparam SIG_ADDER_SUB = 3;           // S_U 
localparam SIG_REGB_EN = 2;             // E_U
localparam SIG_REGB_LOAD_N = 1;         // \L_B
localparam SIG_OUT_LOAD_N = 0;          // \L_O

/* Internal Regs */
reg [2:0] stage;
reg [14:0] control_signals;

/* Micro-Operation Stages */
parameter T0 = 0, T1 = 1, T2 = 2, T3 = 3, T4 = 4, T5 = 5; 

/* Stage Transition Logic */
always @(negedge clk) begin
    if (!rst_n) begin           // Check if reset is asserted, if yes, put into a holding stage
      stage <= 6;
    end
 	else begin                   // If reset is not asserted, do the stages sequentially
      if (stage == 6) begin        
          stage <= 0;
      end 
      else begin
          stage <= stage + 1;
      end
    end
end

/* Micro-Operation Logic */
always @(negedge clk) begin
    control_signals <= 15'b000111111100011; // All signals are deasserted

    case(stage)
        T0: begin
            control_signals[SIG_PC_EN] <= 1;
            control_signals[SIG_MAR_ADDR_LOAD_N] <= 0;
        end 
        T1: begin
            if (opcode != OP_HLT) begin
                control_signals[SIG_PC_INC] <= 1;
            end
        end
        T2: begin
            control_signals[SIG_RAM_EN_N] <= 0;
            control_signals[SIG_IR_LOAD_N] <= 0;
        end
        T3: begin
            case (opcode)
                OP_ADD, OP_SUB, OP_LDA, OP_STA: begin
                    control_signals[SIG_IR_EN_N] <= 0;
                    control_signals[SIG_MAR_ADDR_LOAD_N] <= 0;
                end
                OP_OUT: begin
                    control_signals[SIG_REGA_EN] <= 1;
                    control_signals[SIG_OUT_LOAD_N] <= 0;
                end
                OP_JMP: begin
                    control_signals[SIG_IR_EN_N] <= 0;
                    control_signals[SIG_PC_LOAD] <= 1;
                end
                default: begin
                // Do nothing (leave control_signals unchanged)
                end
            endcase
        end
        T4: begin
            case (opcode)
                OP_ADD, OP_SUB: begin
                    control_signals[SIG_RAM_EN_N] <= 0;
                    control_signals[SIG_REGB_LOAD_N] <= 0;
                end
                OP_LDA: begin
                    control_signals[SIG_RAM_EN_N] <= 0;
                    control_signals[SIG_REGA_LOAD_N] <= 0;
                end
                OP_STA: begin
                    control_signals[SIG_REGA_EN] <= 1;
                    control_signals[SIG_MAR_MEM_LOAD_N] <= 0;
                end
                default: begin
                // Do nothing (leave control_signals unchanged)
                end
            endcase
        end
        T5: begin
            case (opcode)
                OP_ADD: begin
                    control_signals[SIG_REGB_EN] <= 1;
                    control_signals[SIG_REGA_LOAD_N] <= 0;
                end
                OP_SUB: begin
                    control_signals[SIG_ADDER_SUB] <= 1;
                    control_signals[SIG_REGB_EN] <= 1;
                    control_signals[SIG_REGA_LOAD_N] <= 0;
                end
                OP_STA: begin
                    control_signals[SIG_RAM_LOAD_N] <= 0;
                end
                default: begin
                // Do nothing (leave control_signals unchanged)
                end
            endcase
        end
    endcase
end

    wire _unused = &{ena, uio_in,  ui_in[7:4]};
    assign uo_out [7] = 0; // Assign this (not driving anything) to 0
    assign uo_out [6:0] = control_signals[14:8];
    assign uio_out [7:0] = control_signals[7:0];

endmodule
