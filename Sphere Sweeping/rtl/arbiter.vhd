----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/01/2019 11:49:48 PM
-- Design Name: 
-- Module Name: arbiter - Behavioral
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
-- pe_out_type [array of record] : 20(depth_num) * ssd_rgb_addr_dep
-- arbi_out_type [array of record] : 20(num of acc arrays) * ssd_rgb_addr_dep
----------------------------
--------------------function
-- Distribute the results of 20 PE to 6 acc arrays based on out_addr
-- simply split based on output img width, (1200/6 * 600) * 6
----------------------------
entity arbiter is 
port(
    clk: in std_logic;
    rst: in std_logic;
    din: in pe_out_type;
    pe_valid : in std_logic_vector(depth_num - 1 downto 0);
    dout : out arbi_out_type;
    valid : out std_logic_vector(acc_num - 1 downto 0)
);
end entity;


architecture Behavioral of arbiter is
component fifo_generator_3 IS
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(65 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(65 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    data_count : out std_logic_vector(5 downto 0)
  );
END component;
component con_part is 
port(
    clk,rst : in  std_logic;
    din: in pe_out_type;
    count: in arbiter_count_down_sampled_subtype;
--    count : in arbiter_in_count_type;
    en_out: out std_logic_vector(depth_num - 1 downto 0);
    data_out : out ssd_rgb_addr_dep;
    valid : out std_logic
);
end component;
type fifo_out_type is array (depth_num - 1 downto 0) of STD_LOGIC_VECTOR(65 DOWNTO 0);

type con_data_type is array (acc_num - 1 downto 0) of pe_out_type;
signal re, full, empty,empty_r: std_logic_vector(depth_num - 1 downto 0);
signal fifo_out:fifo_out_type;
--signal fifo_o, fifo_o_n: pe_out_type;
--signal in_count,in_count_n:  arbiter_in_count_type;
--signal con_data: con_data_type;
signal en_out_array:arbiter_en_type;
signal rstn : std_logic;
signal count_subarray: arbiter_count_subtype;
signal count_subarray_down_sampled, count_subarray_r:arbiter_count_down_sampled_subtype;
signal count_array : arbiter_count_type;
----- for sim
signal fifo_o_format:pe_out_type;
begin

fifo_format: for i in depth_num-1 downto 0 generate
    fifo_o_format(i) <= transsr(fifo_out(i));
end generate;

in_signals: for i in depth_num-1 downto 0 generate
    inst_in_fifo: fifo_generator_3 port map(
        clk => clk,
        srst => rstn,
        din => trans(din(i)),                  
        wr_en =>  pe_valid(i),
        rd_en => re(i),
        dout => fifo_out(i),
        full => full(i),
        empty => empty(i),
        data_count => count_subarray(i)
    );
-- save timing
count_subarray_down_sampled(i) <= "00" when count_subarray(i) = 0 
                            else  "01" when count_subarray(i) > 0 and count_subarray(i) < 5
                            else  "10" when count_subarray(i) >= 5 and count_subarray(i) <= 16
                            else  "11";
end generate;
rstn <= not rst;
-- save empty and count_subarray for one clk cycle
-- empty_r is use to generate the first re signal for fifo
-- count_subarray_r is used to deal with timing
uni_reg: process(clk,rst)
begin
    if rising_edge(clk) then
        if rst = '0' then 
            empty_r <= (others => '1');
            count_subarray_r<= (others =>(others =>'0'));
        else 
            empty_r <= empty;
            count_subarray_r<=count_subarray_down_sampled;
        end if;
    end if;
end process;

--in_count_comb:process(in_count, pe_valid)
--begin
--    in_count_n <= in_count;
--    for i in depth_num-1 downto 0 loop
--        if pe_valid(i) = '1' then in_count_n(i) <= in_count(i) +1; end if;
--    end loop;
--end process;

--fifo_o_comb:process(fifo_o, fifo_out, pe_en,empty)                       -- TODO: think about the timing
--begin
--    fifo_o_n <= fifo_o;
--    for i in depth_num-1 downto 0 loop
--        if pe_en(i) = '1' then fifo_o_n(i) <= transsr(fifo_out(i));end if;
--        if empty(i) = '0' then fifo_o_n(i) <= (others => (others => '0')); end if;
--    end loop;
--end process;

interconnect_1: process(fifo_out,count_subarray_r)
begin
count_array <= (others => (others => (others => '0')));
for i in depth_num-1 downto 0 loop
    for j in 0  to acc_num - 1 loop
        if transsr(fifo_out(i)).out_addr(20 downto 10) >= out_img_h/acc_num*j and transsr(fifo_out(i)).out_addr(20 downto 10) <= out_img_h/acc_num*(j+1)-1 then
            count_array(acc_num-1-j)(i) <= count_subarray_r(i);
        end if;
    end loop;
end loop;
end process;
interconnect_2: for j in acc_num - 1 downto 0 generate
    inst_con_part: con_part port map(
        clk => clk,
        rst => rst,
        din => fifo_o_format,
        count => count_array(j),
        en_out => en_out_array(j),
        data_out => dout(j),
        valid => valid(j)
    );
end generate;
re_comb:process(en_out_array,empty_r,empty)
begin
    re <= (others=>'0');
    for i in depth_num - 1 downto 0 loop
    if empty_r(i) = '1' and empty(i) = '0' then re(i) <= '1';end if;
    
    for j in acc_num - 1 downto 0 loop
        if en_out_array(j)(i) = '1' then re(i) <= '1';end if;           
    end loop;
    
    if empty(i) = '1' then re(i) <= '0';end if;
    end loop;
end process;




end Behavioral;
