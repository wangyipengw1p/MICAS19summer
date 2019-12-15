----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/01/2019 04:24:44 PM
-- Design Name: 
-- Module Name: omini_top - Behavioral
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
-- File gragh:
--  in --> 
--  inselect(inst_select_part[select_part.vhd] * 6) --> inst_distributer[distributer.vhd] -->
--   core((buf_group(inst_buf[custombuf.vhd] * 20) + inst_PE[PE.vhd]) * 6) --> 
--  inst_arbiter[arbiter.vhd] --> acc_array_group[inat_acc_array[acc_array.vhd] * 6)  -->
--  --> out
-------------------------
-- Function:
-- This module receives video stream, selects pixels based on configuration, generate the SSD, and 
-- output rgb with the minimun SSD through all depths, as well as output address, which lets the 
-- cpu to do the sorting and 
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

library work;
use work.omini_pkg.all;



entity omini_top is
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
end entity;


architecture Behavioral of omini_top is
-----------------------------------components
component select_part is
port(
	clk	       : in	std_logic;
	rst	       : in	std_logic;
	pixel_i	       : in	rgb_data;
	conf_in	   : in	conf_line;
	valid_pixel: in std_logic;
	valid_conf : in std_logic;
	pixel_o	   : out	waitlen_rgb_addr_zone_dep;
	valid	   : out	std_logic;
	ready_conf	: out	std_logic
);
end component;
component distributer is 
port(
    din : in waitlen_rgb_addr_zone_dep_array;
    in_valid: in std_logic_vector(camera_num - 1 downto 0);
    dout: out dist_data_type;        
    valid: out valid_type       --20*6

);
end component;
component custombuf is 
port(
    clk : in std_logic;
    rst : in std_logic;
    valid_in : in std_logic;
    din :in waitlen_rgb_addr_dep;
    out_en : in std_logic;
    out_sign : out std_logic_vector(5 downto 0);       --64 depth fifo                                           ###
    dout :  out rgb1_rgb2_addr_dep
);
end component;
component PE is
port(
    clk : in std_logic;
    rst : in std_logic;
    buf_sign : in buf_sign_subtype;
    din : in rgb1_rgb2_addr_dep_subtype;
    buf_en : out std_logic_vector(camera_num-1 downto 0);
    dout: out ssd_rgb_addr_dep;
    valid : out std_logic
);
end component;
component arbiter is 
port(
    clk: in std_logic;
    rst: in std_logic;
    din: in pe_out_type;
    pe_valid : in std_logic_vector(depth_num - 1 downto 0);
    dout : out arbi_out_type;
    valid : out std_logic_vector(acc_num - 1 downto 0)
);
end component;
component acc_array is 
generic(
        length : integer
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        din : in ssd_rgb_addr_dep;
        in_valid : in std_logic;
        dout : out rgb_addr;
        valid : out std_logic
    );
end component;
------------------------------  signals
signal sele2dist: waitlen_rgb_addr_zone_dep_array;
signal select_valid: std_logic_vector(camera_num - 1 downto 0);
signal dist2buff: dist_data_type;
signal dist_valid: valid_type;
signal buf_en: valid_type;
signal buf_sign:buf_sign_type;
signal buf_out:rgb1_rgb2_addr_dep_type;
signal pe_out:pe_out_type;
signal pe_valid: std_logic_vector(depth_num - 1 downto 0);
signal arbi_out: arbi_out_type;
signal arbi_valid:  std_logic_vector(acc_num - 1 downto 0);
signal acc_out: acc_group_out_type;
signal acc_valid: std_logic_vector(acc_num-1 downto 0);
-----
begin
-----
inselect: for i in camera_num - 1 downto 0 generate
    inst_select_part: select_part port map(
        clk => clk,
        rst => rst,
        pixel_i => video_in(i),
        conf_in => conf_in(i),
        valid_pixel => valid_pixel,
        valid_conf => valid_conf(i),
        pixel_o => sele2dist(i),
        valid => select_valid(i),
        ready_conf => ready_conf(i)
    );
end generate;
inst_distributer: distributer port map(
    din => sele2dist,
    in_valid => select_valid,
    dout => dist2buff,
    valid => dist_valid
);

core: for d in depth_num-1 downto 0 generate
    buff_group:for i in camera_num - 1 downto 0 generate
        inst_buff: custombuf port map(
            clk => clk,
            rst => rst,
            valid_in => dist_valid(d)(i),
            din => dist2buff(d)(i),
            out_en => buf_en(d)(i),
            out_sign => buf_sign(d)(i),       --6
            dout => buf_out(d)(i)
        );
    end generate;
    inst_PE: PE port map(
        clk => clk,
        rst => rst,
        buf_sign => buf_sign(d),
        din => buf_out(d),
        buf_en =>buf_en(d),
        dout => pe_out(d),
        valid => pe_valid(d)
    );
end generate;
inst_arbiter: arbiter port map(
    clk => clk,
    rst =>rst,
    din => pe_out,
    pe_valid => pe_valid,
    dout => arbi_out,
    valid => arbi_valid
);
acc_array_group:for i in acc_num - 1 downto 0 generate
    inst_acc_array: acc_array
    generic map(
        length => 4                                                         ---!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
    ) 
    port map(
        clk=> clk,
        rst => rst,
        din => arbi_out(i),
        in_valid => arbi_valid(i),
        dout => data_out(i),
        valid => out_valid(i)
    );
end generate;


end Behavioral;
