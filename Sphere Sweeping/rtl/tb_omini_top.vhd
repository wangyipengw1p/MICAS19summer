--------------------------------------------------
-- Creat time: 2019-08-09 09:32:26
-- Platform: Linux
-- Engineer: ywang
-- University
-- Version
--------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;           --containing the function conv_std_logic_vector
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;


library work;
use work.omini_pkg.all;
entity tb_omini_top is
end entity;

architecture behaviral of tb_omini_top is
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


process
begin
clk <= '1';
wait for 5 ns;
clk <= '0';
wait for 5 ns;
end process;
rst <= '0', '1' after 10 ns;

-- test 1
--valid_pixel <= '0', '1' after 10 ns, '0' after 100 ns;
--video:for i in 5 downto 0 generate
--    video_in(i) <=  conv_std_logic_vector(0,8) &conv_std_logic_vector(0,8) &conv_std_logic_vector(0,8)  ,
--                    conv_std_logic_vector(1,8) &conv_std_logic_vector(1,8) &conv_std_logic_vector(1,8)  after 10 ns,
--                    conv_std_logic_vector(2,8) &conv_std_logic_vector(2,8) &conv_std_logic_vector(2,8)  after 20 ns,
--                    conv_std_logic_vector(3,8) &conv_std_logic_vector(3,8) &conv_std_logic_vector(3,8)  after 30 ns,
--                    conv_std_logic_vector(4,8) &conv_std_logic_vector(4,8) &conv_std_logic_vector(4,8)  after 40 ns,
--                    conv_std_logic_vector(5,8) &conv_std_logic_vector(5,8) &conv_std_logic_vector(5,8)  after 50 ns,
--                    conv_std_logic_vector(6,8) &conv_std_logic_vector(6,8) &conv_std_logic_vector(6,8)  after 60 ns,
--                    conv_std_logic_vector(7,8) &conv_std_logic_vector(7,8) &conv_std_logic_vector(7,8)  after 70 ns,
--                    conv_std_logic_vector(8,8) &conv_std_logic_vector(8,8) &conv_std_logic_vector(8,8)  after 80 ns,
--                    conv_std_logic_vector(9,8) &conv_std_logic_vector(9,8) &conv_std_logic_vector(9,8)  after 90 ns,
--                    conv_std_logic_vector(10,8)&conv_std_logic_vector(10,8)&conv_std_logic_vector(10,8)  after 100 ns;
--end generate;
--valid_conf <= "000000", "111111"after 10 ns, "000000" after 50 ns;
--conf:for i in 5 downto 1 generate
--    conf_in(i) <=  (others => (others =>'0')),
--                    (waitlen => conv_std_logic_vector(1,10),interval => conv_std_logic_vector(1,7), out_addr => conv_std_logic_vector(0,11)&conv_std_logic_vector(1,11), zone => conv_std_logic_vector(i,3), depth=> conv_std_logic_vector(0,5)) after 10 ns,
--                    (waitlen => conv_std_logic_vector(0,10),interval => conv_std_logic_vector(0,7), out_addr => conv_std_logic_vector(0,11)&conv_std_logic_vector(0,11), zone => conv_std_logic_vector(i-1,3), depth=> conv_std_logic_vector(0,5)) after 20 ns,
--                    (waitlen => conv_std_logic_vector(1,10),interval => conv_std_logic_vector(0,7), out_addr => conv_std_logic_vector(1,11)&conv_std_logic_vector(0,11), zone => conv_std_logic_vector(i-1,3), depth=> conv_std_logic_vector(0,5)) after 30 ns,
--                    (waitlen => conv_std_logic_vector(0,10),interval => conv_std_logic_vector(3,7), out_addr => conv_std_logic_vector(1,11)&conv_std_logic_vector(1,11), zone => conv_std_logic_vector(i,3), depth=> conv_std_logic_vector(0,5)) after 40 ns;
                    
--end generate;
--conf_in(0) <=  (others => (others =>'0')),
--                    (waitlen => conv_std_logic_vector(1,10),interval => conv_std_logic_vector(1,7), out_addr => conv_std_logic_vector(0,11)&conv_std_logic_vector(1,11), zone => conv_std_logic_vector(0,3), depth=> conv_std_logic_vector(0,5)) after 10 ns,
--                    (waitlen => conv_std_logic_vector(0,10),interval => conv_std_logic_vector(0,7), out_addr => conv_std_logic_vector(0,11)&conv_std_logic_vector(0,11), zone => conv_std_logic_vector(5,3), depth=> conv_std_logic_vector(0,5)) after 20 ns,
--                    (waitlen => conv_std_logic_vector(1,10),interval => conv_std_logic_vector(0,7), out_addr => conv_std_logic_vector(1,11)&conv_std_logic_vector(0,11), zone => conv_std_logic_vector(5,3), depth=> conv_std_logic_vector(0,5)) after 30 ns,
--                    (waitlen => conv_std_logic_vector(0,10),interval => conv_std_logic_vector(3,7), out_addr => conv_std_logic_vector(1,11)&conv_std_logic_vector(1,11), zone => conv_std_logic_vector(0,3), depth=> conv_std_logic_vector(0,5)) after 40 ns;
--test 2
valid_pixel <= '0', '1' after 170 ns;
valid_conf1 <= "000000", "111111"after 170 ns;
valid_conf <= valid_conf1 and ready_conf;
video1:for i in 5 downto 0 generate
    process
    begin
        wait for 10 ns;
        video_in(i) <= conv_std_logic_vector(1,8) &conv_std_logic_vector(1,8) &conv_std_logic_vector(1,8);
        wait for 10 ns;
        video_in(i) <= conv_std_logic_vector(2,8) &conv_std_logic_vector(2,8) &conv_std_logic_vector(2,8);
        wait for 10 ns;
        video_in(i) <= conv_std_logic_vector(3,8) &conv_std_logic_vector(3,8) &conv_std_logic_vector(3,8);
        wait for 10 ns;
        video_in(i) <= conv_std_logic_vector(4,8) &conv_std_logic_vector(4,8) &conv_std_logic_vector(4,8);
        wait for 10 ns;
        video_in(i) <= conv_std_logic_vector(5,8) &conv_std_logic_vector(5,8) &conv_std_logic_vector(5,8);
        wait for 10 ns;
        video_in(i) <= conv_std_logic_vector(6,8) &conv_std_logic_vector(6,8) &conv_std_logic_vector(6,8);
        wait for 10 ns;
        video_in(i) <= conv_std_logic_vector(7,8) &conv_std_logic_vector(7,8) &conv_std_logic_vector(7,8);
        wait for 10 ns;
        video_in(i) <= conv_std_logic_vector(8,8) &conv_std_logic_vector(8,8) &conv_std_logic_vector(8,8);
    end process;
end generate;

-- camera 5 downto 1   
conf1:for i in 5 downto 1 generate
process
begin
for d in 19 downto 0 loop
            wait for 10 ns;
            if ready_conf(i) = '0' then  wait until ready_conf(i) = '1';wait for 10 ns; end if;
            conf_in(i) <=       (waitlen => conv_std_logic_vector(1,10),interval => conv_std_logic_vector(1,7), out_addr => conv_std_logic_vector(5-i+1,11)&conv_std_logic_vector(0,10), zone => conv_std_logic_vector(i,3), depth=> conv_std_logic_vector(d,5));
            wait for 10 ns;
            if ready_conf(i) = '0' then  wait until ready_conf(i) = '1';wait for 10 ns; end if;
            conf_in(i) <=       (waitlen => conv_std_logic_vector(0,10),interval => conv_std_logic_vector(2,7), out_addr => conv_std_logic_vector(5-i+0,11)&conv_std_logic_vector(0,10), zone => conv_std_logic_vector(i-1,3), depth=> conv_std_logic_vector(d,5));
            wait for 10 ns;
           if ready_conf(i) = '0' then  wait until ready_conf(i) = '1';wait for 10 ns; end if;
            conf_in(i) <=       (waitlen => conv_std_logic_vector(1,10),interval => conv_std_logic_vector(0,7), out_addr => conv_std_logic_vector(5-i+0,11)&conv_std_logic_vector(1,10), zone => conv_std_logic_vector(i-1,3), depth=> conv_std_logic_vector(d,5));
            wait for 10 ns;
            if ready_conf(i) = '0' then  wait until ready_conf(i) = '1';wait for 10 ns; end if;
            conf_in(i) <=        (waitlen => conv_std_logic_vector(0,10),interval => conv_std_logic_vector(5,7), out_addr => conv_std_logic_vector(5-i+1,11)&conv_std_logic_vector(1,10), zone => conv_std_logic_vector(i,3), depth=> conv_std_logic_vector(d,5));

end loop;
end process;
end generate;
--camera 0
process
begin
 for d in 19  downto 0 loop
  wait for 10 ns;
  if ready_conf(0) = '0' then  wait until ready_conf(0) = '1';wait for 10 ns; end if; 
  conf_in(0) <=       (waitlen => conv_std_logic_vector(1,10),interval => conv_std_logic_vector(1,7), out_addr => conv_std_logic_vector(0,11)&conv_std_logic_vector(0,10), zone => conv_std_logic_vector(0,3), depth=> conv_std_logic_vector(d,5));
  wait for 10 ns;
  if ready_conf(0) = '0' then  wait until ready_conf(0) = '1';wait for 10 ns; end if; 
  conf_in(0) <=       (waitlen => conv_std_logic_vector(0,10),interval => conv_std_logic_vector(2,7), out_addr => conv_std_logic_vector(5,11)&conv_std_logic_vector(0,10), zone => conv_std_logic_vector(5,3), depth=> conv_std_logic_vector(d,5));
  wait for 10 ns;
  if ready_conf(0) = '0' then  wait until ready_conf(0) = '1';wait for 10 ns; end if; 
  conf_in(0) <=       (waitlen => conv_std_logic_vector(1,10),interval => conv_std_logic_vector(0,7), out_addr => conv_std_logic_vector(5,11)&conv_std_logic_vector(1,10), zone => conv_std_logic_vector(5,3), depth=> conv_std_logic_vector(d,5));
  wait for 10 ns;
  if ready_conf(0) = '0' then  wait until ready_conf(0) = '1';wait for 10 ns; end if; 
  conf_in(0) <=        (waitlen => conv_std_logic_vector(0,10),interval => conv_std_logic_vector(5,7), out_addr => conv_std_logic_vector(0,11)&conv_std_logic_vector(1,10), zone => conv_std_logic_vector(0,3), depth=> conv_std_logic_vector(d,5));
 end loop;
end process;
       
end architecture;