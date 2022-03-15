/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (tb_ifc intf_lab2);

  //timeunit 1ns/1ns;

  int seed = 555;

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    intf_lab2.write_pointer  = 5'h00;         // initialize write pointer
    intf_lab2.read_pointer   = 5'h1F;         // initialize read pointer
    intf_lab2.load_en        = 1'b0;          // initialize load control line
    intf_lab2.reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge intf_lab2.clk) ;     // hold in reset for 2 clock cycles
    intf_lab2.reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge intf_lab2.clk) intf_lab2.load_en = 1'b1;  // enable writing to register
    repeat (3) begin
      @(posedge intf_lab2.clk) randomize_transaction;
      @(negedge intf_lab2.clk) print_transaction;
    end
    @(posedge intf_lab2.clk) intf_lab2.load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<=2; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge intf_lab2.clk) intf_lab2.read_pointer = i;
      @(negedge intf_lab2.clk) print_results;
    end

    @(posedge intf_lab2.clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    intf_lab2.operand_a     <= $random(seed)%16;                 // between -15 and 15
    intf_lab2.operand_b     <= $unsigned($random)%16;            // between 0 and 15
    intf_lab2.opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    intf_lab2.write_pointer <= temp++;
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", intf_lab2.write_pointer);
    $display("  opcode = %0d (%s)", intf_lab2.opcode, intf_lab2.opcode.name);
    $display("  operand_a = %0d",   intf_lab2.operand_a);
    $display("  operand_b = %0d\n", intf_lab2.operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", intf_lab2.read_pointer);
    $display("  opcode = %0d (%s)", intf_lab2.instruction_word.opc, intf_lab2.instruction_word.opc.name);
    $display("  operand_a = %0d",   intf_lab2.instruction_word.op_a);
    $display("  operand_b = %0d\n", intf_lab2.instruction_word.op_b);
  endfunction: print_results

endmodule: instr_register_test
