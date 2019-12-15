----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/01/2019 10:43:41 PM
-- Design Name: 
-- Module Name: distributer - Behavioral
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
-------------
-- type note
-------------
-- waitlen_rgb_addr_zone_dep_array [array of record]: 6 *  waitlen_rgb_addr_zone_dep
-- dist_data_type [two dimensional array of record] : 20 * 6 * waitlen_rgb_addr_dep
-- valid_type [array of std_logic_vector] : 20 * (6 * std_logic)
----------------------------
-- function
-------------
-- distribute the 6 input data to 20*6 banks base on addr and zone
----------------------------


entity distributer is
port(
    din : in waitlen_rgb_addr_zone_dep_array;
    in_valid:  in std_logic_vector(camera_num - 1 downto 0);
    dout: out dist_data_type;        
    valid: out valid_type

);
end distributer;

architecture Behavioral of distributer is

begin
process(din, in_valid)
VARIABLE dep: integer range depth_width - 1 downto 0;
variable zon: integer range camera_num - 1 downto 0;
begin
    dout <= (others =>(others=>(others=>(others=>'0'))));
    valid <= (others=>(others=>'0'));
    for i in camera_num - 1 downto 0 loop
        if in_valid(i) = '1' then
            dep := conv_integer(din(i).depth);
            zon := conv_integer(din(i).zone);
            dout(dep)(zon) <= (waitlen => din(i).waitlen,
                               rgb => din(i).rgb,
                               out_addr => din(i).out_addr, 
                               depth =>din(i).depth);
            valid(dep)(zon) <= '1';
        end if;
    end loop;
end process;
end Behavioral;
