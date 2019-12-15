----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/01/2019 11:18:41 PM
-- Design Name: 
-- Module Name: custombuf - Behavioral
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

------------------ type note
-- waitlen_rgb_addr_dep [record] : ... out_addr, depth
-- rgb1_rgb2_addr_dep [record]
----------------------------

--------------------function
-- A fifo which could access random addr, relized by BRAM
-- BRAM depth: 512 which also should be the  longest waitlen
-- Basically, pointer float up per clk cycle. check addr+waitlen is the current operating address.
-- No matter which circumstance, as long as valid, we write din to BRAM. Note that BRAM is in read
-- first mode. So if the data in that addr is "valid"(not 0 or old value of last round), two rgbs with
-- other conf are puched into fifo. Data driven by re is not used in this design.
----------------------------

entity custombuf is
port(
    clk : in std_logic;
    rst : in std_logic;
    valid_in : in std_logic;
    din :in waitlen_rgb_addr_dep;
    out_en : in std_logic;
    out_sign : out std_logic_vector(5 downto 0);       --64 depth fifo                                           ###
    dout :  out rgb1_rgb2_addr_dep
);
end custombuf;

architecture Behavioral of custombuf is
component blk_mem_gen_0 IS
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
  );
END component;
component fifo_generator_2 IS
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(73 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(73 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    data_count : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
  );
END component;
type shift_type is array (2 downto 0) of rgb_addr_dep;
signal we: STD_LOGIC_VECTOR(0 DOWNTO 0);
signal addr, addra,addr_n: STD_LOGIC_VECTOR(9 DOWNTO 0):= (others => '0');       -- Note that boundary is auto dealed with. 0 - 511 - 0
signal rout: rgb_data;
--signal count, count_n:std_logic_vector(5 downto 0):=(others => '0');
signal full, empty: std_logic;          -- no connection maybe used for debug
signal fifo_in, fifo_out: STD_LOGIC_VECTOR(73 DOWNTO 0);
signal fifo_en, rstn: std_logic;
signal din_wait1, din_wait2:waitlen_rgb_addr_dep;
signal en_wait1, en_wait2:std_logic:='0';
--signal sign,sign_n: std_logic_vector(1023 downto 0):= (others => '0');         --sign that whether the data in BRAM is "valid"
--signal tmp_addr: STD_LOGIC_VECTOR(10 DOWNTO 0);
begin
inst_bram:blk_mem_gen_0 port map(                       
    clka =>clk,
    wea  => we,
    addra => addra,
    dina => din.rgb,
    douta => rout
);

universal_reg:process(clk,rst)
begin
    if rising_edge(clk) then
        if rst = '0' then 
            addr <= (others => '0');
            din_wait1 <= (others => (others => '0'));
            din_wait2 <= (others => (others => '0'));
            en_wait1 <= '0';
            en_wait2 <= '0';
--            count <= (others => '0');
--            sign <= (others => '0');
        else 
            addr <= addr_n;
            din_wait1 <= din;
            din_wait2 <=din_wait1;
            en_wait1 <= fifo_en;
            en_wait2 <= en_wait1;
--            count <= count_n;
--            sign <= sign_n;
        end if;
    end if;
end process;
addr_n <= addr + 1 when valid_in = '1' else addr;
we(0) <= valid_in ;
 -- address for read or write
 -- note that waitlen could < 0
 -- use std_logic_unsigned library here
--addra <= addr + din.waitlen(9 downto 0) when din.waitlen(10) = '0' else addr - not din.waitlen(9 downto 0) - 1;     
addra <= addr + din.waitlen;
fifo_en <= '1' when valid_in = '1' and din.waitlen = 0 else '0';
--count_n <= count+1 when fifo_en = '1' and out_en = '0'        --counter for out_fifo, shows how many datas are in fifo, used by next block: PE
--     else  count-1 when fifo_en = '0' and out_en = '1' 
--     else  count;
--out_sign <= count;
fifo_in <= rout & din_wait2.rgb & din_wait2.out_addr & din_wait2.depth;
--sign_comb:process(sign, addra, valid_in)
--begin
--    sign_n <= sign;
--    if valid_in = '1' then sign_n(conv_integer(addra)) <= not sign(conv_integer(addra)); end if;
--end process;

rstn <= not rst;
out_fifo: fifo_generator_2 port map(
    clk => clk,
    srst => rstn,
    din => fifo_in,               --trans
    wr_en => en_wait2,
    rd_en => out_en,
    dout => fifo_out,
    full => full,
    empty => empty,
    data_count => out_sign
    
);

dout <= transrr(fifo_out);


end Behavioral;
