----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/08/2019 03:12:43 PM
-- Design Name: 
-- Module Name: con_part - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

library work;
use work.omini_pkg.all;




entity con_part is
port(
    clk,rst: in std_logic;
    din : in pe_out_type;
    count: in arbiter_count_down_sampled_subtype;
    en_out: out std_logic_vector(depth_num - 1 downto 0);
    data_out : out ssd_rgb_addr_dep;
    valid : out std_logic
);
end con_part;

architecture Behavioral of con_part is
--constant comp_width:integer:=3;
type stage_data_type is array (integer range<>) of std_logic_vector(1 downto 0);
type stage_num_type is array (integer range<>) of integer range 19 downto 0;
signal one: stage_data_type(9 downto 0);
signal one_num: stage_num_type(9 downto 0);
signal two, two_r: stage_data_type(4 downto 0);
signal two_num, two_num_r: stage_num_type(4 downto 0);
signal three: stage_data_type(1 downto 0);
signal three_num: stage_num_type(1 downto 0);
--comparater
--stage one
signal a: std_logic_vector(1 downto 0);
signal an, bn, fn: integer range 19 downto 0;

signal en : std_logic_vector(depth_num - 1 downto 0);
--signal data_o: std_logic_vector(5 downto 0);
begin
-- chooes the max value of din.rgb(comp_width-1 downto 0), which act as random picking
-- Note that invalid din are set to 0 in previous block.
stage_one:for i in 9 downto 0 generate
    one(i) <= count(i*2+1) when count(i*2+1) > count(i*2) else count(i*2);
    one_num(i) <= i*2+1 when count(i*2+1) > count(i*2) else i*2; 
end generate;

regs:process(clk, rst)
begin
if rising_edge(clk) then 
    if rst = '0' then 
        two_r <= (others =>(others => '0'));
        two_num_r <= (others => 0);
    else 
        two_r <= two;
        two_num_r <= two_num;
    end if;
end if;
end process;

stage_two:for i in 4 downto 0 generate
    two(i) <= one(i*2+1) when one(i*2+1) > one(i*2) else one(i*2);
    two_num(i) <= one_num(i*2+1) when one(i*2+1) > one(i*2) else one_num(i*2); 
end generate;
stage_three:for i in 1 downto 0 generate
    three(i) <= two_r(i*2+1) when two_r(i*2+1) > two_r(i*2) else two_r(i*2);
    three_num(i) <= two_num_r(i*2+1) when two_r(i*2+1) > two_r(i*2) else two_num_r(i*2); 
end generate;
-- others left
a <= three(1) when  three(1) > three(0) else three(0);
an <= three_num(1)when  three(1) > three(0) else three_num(0);
fn <= an when a > two_r(4) else two_num_r(4);
data_out <= din(fn);
en <= "10000000000000000000" when fn = 19 else
      "01000000000000000000" when fn = 18 else
      "00100000000000000000" when fn = 17 else
      "00010000000000000000" when fn = 16 else
      "00001000000000000000" when fn = 15 else
      "00000100000000000000" when fn = 14 else
      "00000010000000000000" when fn = 13 else
      "00000001000000000000" when fn = 12 else
      "00000000100000000000" when fn = 11 else
      "00000000010000000000" when fn = 10 else
      "00000000001000000000" when fn = 9 else
      "00000000000100000000" when fn = 8 else
      "00000000000010000000" when fn = 7 else
      "00000000000001000000" when fn = 6 else
      "00000000000000100000" when fn = 5 else
      "00000000000000010000" when fn = 4 else
      "00000000000000001000" when fn = 3 else
      "00000000000000000100" when fn = 2 else
      "00000000000000000010" when fn = 1 else
      "00000000000000000001" ;
    
-- must have at least valid din to generate valid output
 en_out <= en when a > 0 or two(4) > 0 else (others => '0');
 valid <= '1' when a > 0 or two(4) > 0 else '0';



end Behavioral;
