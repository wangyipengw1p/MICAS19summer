----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/02/2019 12:12:59 AM
-- Design Name: 
-- Module Name: acc_array - Behavioral
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
-- ssd_rgb_addr_dep [record]
-- addr_rgb_depth [record]
----------------------------
--------------------function
-- 
-- 
----------------------------
entity acc_array is
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

end acc_array;

architecture Behavioral of acc_array is
component acc is 
port(
    clk : in std_logic;
    rst : in std_logic;
    din : in ssd_rgb_addr_dep;
    in_valid : in std_logic;
    result_in : in rgb_addr;
    rin_valid : in std_logic;
    target_in : in data_count_sign;
    --tin_valid : in std_logic;
    shift_sign_in: in std_logic;
    shift_sign_out : out std_logic;
    target_out: out data_count_sign;
    -- tout_valid: out std_logic;
    dout : out ssd_rgb_addr_dep;
    out_valid: out std_logic;
    result_out : out rgb_addr;
    rout_valid : out std_logic
);
end component;
component fifo_generator_1 IS
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(65 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(65 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
END component;
type acc_type is array (length-2 downto 0) of ssd_rgb_addr_dep;
type result_type is array (length-2 downto 0) of rgb_addr;
type target_type is array (length-1 downto 1) of data_count_sign;
signal din_valid, rin_valid : std_logic_vector(length-2 downto 0);
signal acc_in: acc_type;
signal result_in: result_type;
signal fifo_in :ssd_rgb_addr_dep;
signal fifo_in_valid: std_logic;
signal firstin: ssd_rgb_addr_dep;
signal firstvalid, re, full, empty, empty_r: std_logic;      -- TODO: can't be full, need some logic to guarantee
signal fifo_out : STD_LOGIC_VECTOR(65 DOWNTO 0);
signal no_connection : data_count_sign;
signal no_con: std_logic;
signal shift_sign_in:std_logic_vector(length-2 downto 0);
signal  target_in: target_type;
signal rstn : std_logic;
--add reg for pipeline
signal din_r:ssd_rgb_addr_dep;
signal in_valid_r: std_logic;


begin

--process(din, in_valid,empty,empty_r,fifo_out)
--begin
--    if  in_valid = '1' then 
--        firstin <= din;
--        firstvalid <= '1';
--        re <= '0';
--    elsif empty = '0' and empty_r = '1' then
--        firstin <= din;
--        firstvalid <= '0';
--        re <= '1';
--    elsif empty_r = '0' and empty = '1' then         -- FIXME: the last one of the fifo output won't be get [use a reg to stroe a clk cycle of input]
--        firstin <= transsr(fifo_out);     
--        firstvalid <= '1';
--        re <= '0'; 
--    elsif empty_r = '0' then
--        firstin <= transsr(fifo_out);     
--        firstvalid <= '1';
--        re <= '1'; 
--    else
--        firstin <= din;             -- don't care
--        firstvalid <= '0';
--        re <= '0';
--    end if;    
--end process;
process(din_r, in_valid_r,empty,empty_r,fifo_out)
begin
    if  in_valid_r = '1' then 
        firstin <= din_r;
        firstvalid <= '1';
        re <= '0';
    elsif empty = '0' and empty_r = '1' then
        firstin <= din_r;
        firstvalid <= '0';
        re <= '1';
    elsif empty_r = '0' and empty = '1' then         -- FIXME: the last one of the fifo output won't be get [use a reg to stroe a clk cycle of input]
        firstin <= transsr(fifo_out);     
        firstvalid <= '1';
        re <= '0'; 
    elsif empty_r = '0' then
        firstin <= transsr(fifo_out);     
        firstvalid <= '1';
        re <= '1'; 
    else
        firstin <= din_r;             -- don't care
        firstvalid <= '0';
        re <= '0';
    end if;    
end process;
universal_reg: process(clk, rst)
begin
if rising_edge(clk) then 
    if rst = '0' then 
        empty_r <= '1';
        din_r <= (others=>(others=>'0'));
        in_valid_r <= '0';
    else 
        empty_r <= empty;
        din_r<=din;
        in_valid_r <= in_valid;
    end if;
end if;
end process;
--inst_fifo_front: fifo_generator_1 port map(
--    clk => clk,
--    srst => rst,
--    din => trans(din),                  
--    wr_en =>  in_valid,
--    rd_en => re_front,
--    dout => fifo_out_front,
--    full => full_front,
--    empty => empty_front
--);
first_acc:acc port map(
    clk => clk,
    rst => rst,
    din => firstin,
    in_valid => firstvalid,
    dout => acc_in(length - 2),
    out_valid => din_valid(length - 2),
    result_in => (others=>(others=>'0')),
    rin_valid => '0',
    result_out => result_in(length - 2),
    rout_valid => rin_valid(length - 2),
    target_in => target_in(length - 1),
    target_out => no_connection,
    shift_sign_in => '0',
    shift_sign_out => shift_sign_in(length - 2)
);
main_acc_array: for i in length - 2 downto 1 generate
    inst_acc: acc port map(
        clk => clk,
        rst => rst,
        din => acc_in(i),
        in_valid => din_valid(i),
        dout => acc_in(i-1),
        out_valid => din_valid(i-1),
        result_in => result_in(i),
        rin_valid => rin_valid(i),
        result_out => result_in(i-1),
        rout_valid => rin_valid(i-1),
        target_in => target_in(i),
        target_out => target_in(i+1),
        shift_sign_in => shift_sign_in(i),
        shift_sign_out => shift_sign_in(i-1)
    );
end generate;

last_acc: acc port map(
    clk => clk,
    rst => rst,
    din => acc_in(0),
    in_valid => din_valid(0),
    dout => fifo_in,
    out_valid => fifo_in_valid,
    result_in => result_in(0),
    rin_valid => rin_valid(0),
    result_out => dout,
    rout_valid => valid,
    target_in => (sign => '1', data => (others => (others => '0')), count => (others => '0')),
    target_out => target_in(1),
    shift_sign_in => shift_sign_in(0),
    shift_sign_out => no_con
);
rstn <= not rst;
inst_fifo_back: fifo_generator_1 port map(
    clk => clk,
    srst => rstn,
    din => trans(fifo_in),                  
    wr_en =>  fifo_in_valid,
    rd_en => re,
    dout => fifo_out,
    full => full,
    empty => empty
    
    
);

end Behavioral;
