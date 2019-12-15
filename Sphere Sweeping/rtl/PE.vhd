----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/01/2019 11:32:47 PM
-- Design Name: 
-- Module Name: PE - Behavioral
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
-- buf_sign_subtype [array of std_logic_vector] : 6 * std_logic_vector(5 downto 0)
-- rgb1_rgb2_addr_dep_subtype [array of record] : 6 * rgb1_rgb2_addr_dep
-- ssd_addr_dep [record]
----------------------------
--------------------function
-- Accept one of the 6 buf value(the one whose fifocount is the largest) and calculate 
-- the SSD of 2 pixels.
----------------------------

entity PE is
port(
    clk : in std_logic;
    rst : in std_logic;
    buf_sign : in buf_sign_subtype;
    din : in rgb1_rgb2_addr_dep_subtype;
    buf_en : out std_logic_vector(camera_num-1 downto 0);
    dout: out ssd_rgb_addr_dep;
    valid : out std_logic
);
end PE;

architecture Behavioral of PE is                                -- TODO: 6 is fixed here
component mult_gen_0 IS
  PORT (
    A : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    P : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END component;

--signal A, B: rgb_data;
signal valid_r, valid_n: std_logic;
signal c1, c2, c3, c4:std_logic_vector(5 downto 0);
signal n1, n2, n3, n4, nn, nn_r:integer range 5 downto 0;
--signal dout_r, dout_n: ssd_rgb_addr_dep;
signal r1, b1, g1, r2, b2, g2, rs, bs,gs : std_logic_vector(7 downto 0);
signal tmp, tmpr, tmpg, tmpb : std_logic_vector(15 downto 0);
begin
c1 <= buf_sign(5) when buf_sign(5) > buf_sign(4) else buf_sign(4);
n1 <= 5 when buf_sign(5) > buf_sign(4) else 4;
c2 <= buf_sign(3) when buf_sign(3) > buf_sign(2) else buf_sign(2);
n2 <= 3 when buf_sign(3) > buf_sign(2) else 2;
c3 <= buf_sign(1) when buf_sign(1) > buf_sign(0) else buf_sign(0);
n3 <= 1 when buf_sign(1) > buf_sign(0) else 0;
n4 <= n1 when c1 > c2 else n2;
c4 <= c1 when c1 > c2 else c2;
nn <= n3 when c3 > c4 else n4;
buf_en <=   "000000" when  valid_n = '0' else
            "100000" when nn = 5 else
            "010000" when nn = 4 else
            "001000" when nn = 3 else
            "000100" when nn = 2 else
            "000010" when nn = 1 else
            "000001";
--valid and nn should be a clk cycle later
universal_reg:process(clk,rst)
begin
    if rising_edge(clk) then
        if rst = '0' then 
            valid_r <='0';
            --dout_r <= (others =>(others =>'0'));
            nn_r <= 0;
        else 
            valid_r <= valid_n;
            --dout_r <= dout_n;
            nn_r <= nn;
        end if;
    end if;
end process;
r1 <= din(nn_r).rgb1(23 downto 16);
r2 <= din(nn_r).rgb2(23 downto 16);
g1 <= din(nn_r).rgb1(15 downto 8);
g2 <= din(nn_r).rgb2(15 downto 8);
b1 <= din(nn_r).rgb1(7 downto 0);
b2 <= din(nn_r).rgb2(7 downto 0);
rs <= r1-r2;
bs <= b1-b2;
gs <= g1-g2;
mul_r:mult_gen_0 port map(
    a => rs,
    b => rs,
    p => tmpr
);
mul_g:mult_gen_0 port map(
    a => gs,
    b => gs,
    p => tmpg
);
mul_b:mult_gen_0 port map(
    a => bs,
    b => bs,
    p => tmpb
);
tmp <= tmpr+tmpg+tmpb;             --???

dout.out_addr <= din(nn_r).out_addr;
dout.depth <= din(nn_r).depth;
dout.rgb <= din(nn_r).rgb1;                   ---???
dout.ssd <= ("00" & tmp(15 downto 2) - tmp - tmp);                   ---???   /6

valid <= valid_r;
valid_n <= '0' when buf_sign(0) = "000000" and buf_sign(5) = "000000" and buf_sign(4) = "000000" and buf_sign(3) = "000000" and buf_sign(2) = "000000" and buf_sign(1) = "000000"
 else '1';
end Behavioral;
