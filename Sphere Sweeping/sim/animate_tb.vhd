----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/12/2019 03:28:38 PM
-- Design Name: 
-- Module Name: animate_tb - Behavioral
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
use IEEE.std_logic_arith.all;           --containing the function conv_std_logic_vector
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


library work;
use work.omini_pkg.all;

entity animate_tb is
--  Port ( );
end animate_tb;

architecture Behavioral of animate_tb is
component omini_top is
    port(
        clk	           : in    std_logic;
        rst	           : in    std_logic;
        video_in       : in    video_data;
        conf_in	       : in    conf_line_array;
        valid_pixel	   : in    std_logic;
        valid_conf     : in     std_logic_vector(camera_num - 1 downto 0);
        ready_conf	   : out    std_logic_vector(camera_num - 1 downto 0);
        out_valid      : out	std_logic_vector(acc_num - 1 downto 0);
        data_out       : out	out_format
    );
end component;

signal clk, rst: std_logic;
signal video_in: video_data;
signal valid_pixel: std_logic;
signal valid_conf,valid_conf1,valid_conf2: std_logic_vector(camera_num -1 downto 0);
signal ready_conf: std_logic_vector(camera_num -1 downto 0);
signal out_valid: std_logic_vector(acc_num - 1 downto 0);
signal data_out: out_format;
signal conf_in: conf_line_array;
begin
inst_omini_top:omini_top port map(
	video_in	=> video_in,
	valid_pixel	=> valid_pixel,
	clk	=> clk,
	valid_conf	=> valid_conf,
	ready_conf	=> ready_conf,
	out_valid	=> out_valid,
	rst	=> rst,
	data_out	=> data_out,
	conf_in	=> conf_in
);

read_conf: process  
     type char_file is file of character;
     file c_file_handle: char_file;
     variable C: character;
     variable char_count: integer := 0;
begin
     file_open(c_file_handle, "test_file.txt", READ_MODE);
     while not endfile(c_file_handle) loop
         read (c_file_handle, C) ;    
         char_count = char_count + 1;  -- Keep track of the number of
     -- characters
     end loop;
     file_close(c_file_handle);
end process;

-- The following example demonstrates how you can use the text I/O features 
-- of VHDL to write test data from a file using a process:
--
write_input: process  
     type char_file is file of character;
     file c_file_handle: char_file;
     variable C: character := "W";
     variable char_count: integer := 0;
begin
     file_open(c_file_handle, "test_file.txt", WRITE_MODE);
     while not endfile(c_file_handle) loop
         write (c_file_handle, C) ;    
         char_count = char_count + 1;  -- Keep track of the number of
     -- characters
     end loop;
     file_close(c_file_handle);
end process;

end Behavioral;
