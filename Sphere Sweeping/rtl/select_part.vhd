--------------------------------------------------
-- Creat time: 2019-07-30 00:15:36
-- Platform: Linux
-- Engineer: ywang
-- University
-- Version
--------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

library work;
use work.omini_pkg.all;

------------------ type note
-- rgb_data [alias] : std_logic_vector(23 downto 0)
-- conf_line [record] : waitlen, interval, out_addr, zone, depth
-- waitlen_rgb_addr_zone_dep [record] : ... out_addr ... depth
----------------------------

------------------- function
-- Select the valid input pixels, which are mapped to output img, based on "interval" in config
-- special circumstances are concerned:
--  1. interval may be 0, so we need fifo for both pixel_in and conf
--  2. whenever interval = 0, fifo for pixel_in will filled by one more pixel, causing ordinary 
--     fifo to fill up definately, so special fifo are designed. 
--  3. whenever interval = 0, waitlen should - 1. In extreme circumstances waitlen could be negative,
--     so one more sign bit is added to waitlen. [custombuf.vhd] will do further work.
----------------------------

entity select_part is
port(
	clk	: in	std_logic;
	rst	: in	std_logic;
	pixel_i	: in	rgb_data;
	conf_in	: in	conf_line;
	valid_pixel: in std_logic;
	--first_pixel	: in	std_logic;        --blank???
	valid_conf: in std_logic;
	pixel_o	: out	waitlen_rgb_addr_zone_dep;
	valid	: out	std_logic;
	ready_conf	: out	std_logic
--	pixel_d_o: out rgb_addr;               --d means direct
--	valid_d: out std_logic
	--ready_pixel: out std_logic             --if it's ok for streaming data?
);
end entity;

architecture behaviral of select_part is
component fifo_generator_0 IS
  PORT (
    clk     : IN STD_LOGIC;
    srst    : IN STD_LOGIC;
    din     : IN STD_LOGIC_VECTOR(45 DOWNTO 0);     --in_interval_width+out_addr_width+overlap_rigeon_width+depth_width-1
    wr_en   : IN STD_LOGIC;
    rd_en   : IN STD_LOGIC;
    dout    : OUT STD_LOGIC_VECTOR(45 DOWNTO 0);
    full    : OUT STD_LOGIC;
    empty   : OUT STD_LOGIC
  );
END component;
component fifo_special IS
  PORT (
    clk     : IN STD_LOGIC;
    srst    : IN STD_LOGIC;
    din     : IN STD_LOGIC_VECTOR(23 DOWNTO 0);     --rgb
    wr_en   : IN STD_LOGIC;
    rd_en   : IN STD_LOGIC;
    oksub_in : in std_logic; 
    dout    : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
    empty    : OUT STD_LOGIC;
    oksub2   : OUT STD_LOGIC
  );
END component;
signal re, full, empty, re0, empty_r,empty_r_r, empty0, rstn:std_logic;
signal fifo_out, fifo_i: STD_LOGIC_VECTOR(45 DOWNTO 0);
signal pixel_data: STD_LOGIC_VECTOR(23 DOWNTO 0);
--signal conf_now, conf_next: conf_line;
signal inteval_count, inteval_count_n: STD_LOGIC_VECTOR(in_interval_width - 1 downto 0):=(others => '0');
--signal zero_count,zero_count_n: STD_LOGIC_VECTOR(4 downto 0):=(others => '0');        -- for counting consecutive zeros in interval
signal oksub2, oksub_in : std_logic;
--for simulation 
signal conf_out_r: conf_line;
begin
-- normal fifo for conf
conf_fifo:fifo_generator_0 port map(
    clk   => clk  ,
    srst  => rstn ,
    din   =>   fifo_i,
    wr_en => valid_conf,
    rd_en => re,
    dout  => fifo_out ,
    full  => full ,
    empty => empty
);
fifo_i <= trans(conf_in);
rstn <= not rst;
ready_conf <= not full;                                             -- TODO: think about the timing here, especially when io happens
re <= '1' when empty = '0' and (inteval_count = 2 or transcl(fifo_out).interval <= 1 or (oksub2 = '1' and inteval_count = 3 )) else '0';
--

--
pixel_in_fifo: fifo_special port map(
    clk   => clk  ,
    srst  => rst ,
    din   => pixel_i  ,
    wr_en => valid_pixel,
    oksub_in => oksub_in,
    rd_en => re0,
    dout  => pixel_data ,
    empty  => empty0 ,
    oksub2 => oksub2
);
--ready_pixel <= not full0;
re0 <= '0' when transcl(fifo_out).interval = 0 or empty0 = '1' else '1';
oksub_in <= '1' when inteval_count > 2 else '0';
 
valid <= '1' when inteval_count = 1 and empty_r_r = '0' else '0';           -- one more check
pixel_o.rgb <= pixel_data ;
pixel_o.out_addr <=  conf_out_r.out_addr;
pixel_o.depth <= conf_out_r.depth;
pixel_o.zone <= conf_out_r.zone;
-- When interval = 0, wait len should be subed by corresponding clk cycles(num for wait for input pixels)
-- Note: out put waitlen could be  < 0 for some special case. Will deal with it in the next block
--pixel_o.waitlen <= '0' & conf_out_r.waitlen  - zero_count;       --timing
pixel_o.waitlen <=  conf_out_r.waitlen;
-- pixel_d_o.rgb <= pixel_i ;
-- pixel_d_o.out_addr <=  transcl(fifo_out).out_addr;

count_reg:process(clk,rst)
begin
    if rising_edge(clk) then
        if rst = '0' then 
            inteval_count <= conv_std_logic_vector(1,in_interval_width);
--            zero_count <= (others => '0');
            empty_r <= '1';
            empty_r_r <= '1';
            conf_out_r <= (others => (others => '0'));
        else 
            inteval_count <= inteval_count_n;
--            zero_count <= zero_count_n;
            empty_r <= empty;
            empty_r_r <= empty_r;
            conf_out_r <= transcl(fifo_out);
        end if;
    end if;
end process;

inteval_count_n <= conv_std_logic_vector(1,in_interval_width)  when empty_r = '1' or (inteval_count = 1 and transcl(fifo_out).interval = 0)
            else   transcl(fifo_out).interval when inteval_count = 1
            else   inteval_count - 2  when oksub2 = '1' and inteval_count > 2
            else   inteval_count - 1;
--zero_count_n <= (others => '0') when empty_r = '1' else
--                zero_count + 1 when inteval_count = 1 and transcl(fifo_out).interval = 0 else                                    --timing
--                zero_count - 1 when oksub2 = '1' else 
--                zero_count;
                

end architecture;