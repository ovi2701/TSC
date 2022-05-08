/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter:
 * User-defined type definitions
 **********************************************************************/
package instr_register_pkg;
  //timeunit 1ns/1ns;

  typedef enum logic [3:0] {
  	ZERO,
    PASSA,
    PASSB,
    ADD,
    SUB,
    MULT,
    DIV,
    MOD
  } opcode_t;

  typedef logic signed [31:0] operand_t;
  typedef logic signed [63:0] operand_r;
  
  typedef logic [4:0] address_t;
  
  typedef struct {
    opcode_t  opc;
    operand_t op_a;
    operand_t op_b;
    operand_r result;
  } instruction_t;

endpackage: instr_register_pkg

//tema: adaugati in structura de instruction_word un semnal result si in dut, in functie de ce tim de opcode trb sa facem operatia corespunzatoare
//trb in dut sa facem un switch in care vom avea tipul de op si in result punem rez