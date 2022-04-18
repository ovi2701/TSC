/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test

  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (
  tb_ifc.TB intf_lab2
  );

  //timeunit 1ns/1ns;
  //tipmul este 0

  //initial begin
  class first_test;
  parameter NR_OF_OPERATIONS = 10;
  virtual tb_ifc.TB intf_lab2;

  covergroup my_coverage;

    OPA_COVER:coverpoint intf_lab2.cb.operand_a{
      bins opA_negative [] = {[-15:-1]};
      bins opA_zero = {0};
      bins opA_positive [] = {[1:15]};
    }

    OPB_COVER:coverpoint intf_lab2.cb.operand_b{
      bins opB_zero = {0};
      bins opB_positive [] = {[1:15]};
    }
  
    OPCODE_COVER:coverpoint intf_lab2.cb.opcode{
      bins opcode_zero = {0};
      bins opcode_positive [] = {[1:7]};
    }

    RES_COVER:coverpoint intf_lab2.cb.instruction_word.res{
      bins res_neg [] = {[-30:-1]};
      bins res_zero = {0};
      bins res_pos [] = {[1:30]};

    }

  endgroup
  //seed-ul reprezinta valoarea initiala cu care se incepe random-izarea si se foloseste pt a stabiliza codul, pt a avea aceleasi rez pe cod cu aceleasi valori random
  //int seed = 555;

   function new(virtual tb_ifc.TB intf_lab2);
      my_coverage = new();
      this.intf_lab2 = intf_lab2;
    endfunction

  task run();
	//valorile din display afisate in transcript la inceput
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
	$display("first header");
    intf_lab2.cb.write_pointer  <= 5'h00;         // initialize write pointer
    intf_lab2.cb.read_pointer   <= 5'h1F;         // initialize read pointer
    intf_lab2.cb.load_en        <= 1'b0;          // initialize load control line
    intf_lab2.cb.reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge intf_lab2.cb) ;     // hold in reset for 2 clock cycles //asteptam doua fronturi pozitive de ceas
    intf_lab2.cb.reset_n        <= 1'b1;          // deassert reset_n (active low)
	
	//o functie are timpi de simulare 0, iar taskul poate avea valori temporale, adica poate avea timpi de simulare diferiti de 0!!!!

    $display("\nWriting values to register stack...");
    @(posedge intf_lab2.cb) intf_lab2.cb.load_en <= 1'b1;  // enable writing to register
    repeat (NR_OF_OPERATIONS) begin
      @(posedge intf_lab2.cb) randomize_transaction;
      @(negedge intf_lab2.cb) print_transaction;
    end
    @(posedge intf_lab2.cb) intf_lab2.cb.load_en <= 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<NR_OF_OPERATIONS; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge intf_lab2.cb) intf_lab2.cb.read_pointer <= i;
      @(negedge intf_lab2.cb) print_results;
	end
	
    @(posedge intf_lab2.cb) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  //end
  endtask

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    // intf_lab2.cb.operand_a     <= $random(seed)%16;                 // between -15 and 15
    // intf_lab2.cb.operand_b     <= $unsigned($random)%16;            // between 0 and 15
    // intf_lab2.cb.opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type  //converteste index in string

    intf_lab2.cb.operand_a     <= $signed($urandom)%16;                 // between -15 and 15
    intf_lab2.cb.operand_b     <= $unsigned($urandom)%16;            // between 0 and 15
    intf_lab2.cb.opcode        <= opcode_t'($unsigned($urandom)%8);  // between 0 and 7, cast to opcode_t type  //converteste index in string
    intf_lab2.cb.write_pointer <= temp++;
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", intf_lab2.cb.write_pointer);
    $display("  opcode = %0d (%s)", intf_lab2.cb.opcode, intf_lab2.cb.opcode.name);
    $display("  operand_a = %0d",   intf_lab2.cb.operand_a);
    $display("  operand_b = %0d\n", intf_lab2.cb.operand_b);
	$display("Printing transaction: %d ns ",$time);
  my_coverage.sample();
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", intf_lab2.cb.read_pointer);
    $display("  opcode = %0d (%s)", intf_lab2.cb.instruction_word.opc, intf_lab2.cb.instruction_word.opc.name);
    $display("  operand_a = %0d",   intf_lab2.cb.instruction_word.op_a);
    $display("  operand_b = %0d\n", intf_lab2.cb.instruction_word.op_b);
	$display("Printing results: %d ns ",$time);
  my_coverage.sample();
  endfunction: print_results
 
endclass: first_test

  initial begin 
    first_test ft;
    ft = new(intf_lab2);
    //ft.intf_lab2 = intf_lab2;
    ft.run();
  end

endmodule: instr_register_test


//daca vrem sa cream o clasa, se pune totul in acea clasa in afara de initial begin sau variabile interne(ex:seed)
//declaram o variabila in clasa pentru interfata: virtual tb_ifc.nume_modport.nume_interfata

//tema: coverpoint pentru rezultat