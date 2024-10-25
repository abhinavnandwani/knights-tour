/* 
    Author          : Abhinav Nandwani
    Filename        : SPI_mnrch.sv
    Description     : 
*/

module SPI_mnrch(
    input clk,
    input rst_n,
    output SS_n,
    output SCLK,
    output MOSI,
    input MISO,
    input [15:0] cmd,
    input [15:0] resp,
    output done
);



