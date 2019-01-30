  module top_xorexec_sva #(parameter int dwidth=8)
   (
    //clk and rst (active high)
    input clk,rst,
    
    //ififo interface
    input ififo_push,
    input ififo_not_full,
    input [7:0] idata,
    
    //ofifo interface
    input ofifo_pop,
    input ofifo_rdy,
    input [7:0] odata,

    input [2:0] exec_state 
    
    );


default clocking cb @(posedge clk);  endclocking

  //Hard assumptions --> Interface assertions
//Should always hold true for interface
//If ififo_pop is active, ififo_rdy should be true, prior cycle
as_ofifo_pop: assume property ( disable iff(rst) ofifo_pop |-> $past(ofifo_rdy)  );   

   
//Soft assumptions to explore design behavior   
//loop for multiple operands  
as_ififo_data: assume property ( idata >= 8'h4 );
   
//Stutter ififo_push
//as_ififo_push_stutter: assume property ( disable iff(rst) ififo_push |-> ~$past(ififo_push) );

//Multiple clocks in push_result state

logic [3:0] state_cnt ;
always @(posedge clk)
  if ( rst)
    state_cnt <= 0;
  else
    if (exec_state == 4)
      state_cnt <= state_cnt + 1 ;
    else
      state_cnt <= 0;

//cp_rdy: cover property ( disable iff(rst) ofifo_rdy |-> (state_cnt == 3'd2) );
   
//cp_rdy: cover property ( disable iff(rst) ofifo_rdy );
  
cp_rdy:   cover property ( disable iff(rst) ofifo_rdy |=> ~ofifo_rdy);
   
endmodule // top_xorexec

bind top_xorexec  top_xorexec_sva sva_inst (.*);

