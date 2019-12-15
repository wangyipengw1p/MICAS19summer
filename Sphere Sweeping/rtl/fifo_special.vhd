----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/01/2019 05:45:30 PM
-- Design Name: 
-- Module Name: fifo_special - Behavioral
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
-------------------------------------------
--special FIFO for input RGB
-----------
-- When interval = 0, input RGB will stack in fifo. This 
-- special one could dump 2 input RGBs whenever interval >= 2.
-------------------------------------------

entity fifo_special is

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

end fifo_special;

architecture Behavioral of fifo_special is
type fifo_type is array (0 to 63) of  STD_LOGIC_VECTOR(23 DOWNTO 0); 
signal fifo, fifo_n: fifo_type:=(others => (others => '0'));
signal raddr, waddr, raddr_n, waddr_n: unsigned(5 downto 0):= "000000";
--signal dout_reg, dout_next:STD_LOGIC_VECTOR(23 DOWNTO 0);
begin
oksub2 <= '1' when oksub_in = '1' AND waddr - raddr > 1 else '0';

empty <= '1' when raddr = waddr  else '0';
process(clk,srst)
begin
    if rising_edge(clk) then
        if srst = '0' then 
            fifo <= (others => (others => '0'));
            raddr <= "000000";
            waddr <= "000000";
           -- dout_reg <= (others => '0');
        else 
            --if wr_en = '1' then fifo(to_integer(waddr)) <= din; end if;
            fifo <= fifo_n;
            raddr <= raddr_n;
            waddr <= waddr_n;
           -- dout_reg <= dout_next;
        end if;
    end if;
end process;
process(raddr, waddr,rd_en,wr_en,oksub_in)
begin
    raddr_n <= raddr;
    waddr_n <= waddr;
    -- when more than 2 items in fifo, asserts the oksub2 sign.
    -- (raddr - waddr > 0 and raddr - waddr < 63) is to deal with the special case, when finish a round
    if rd_en = '1' and (waddr - raddr > 1 or (raddr - waddr > 0 and raddr - waddr < 63))and oksub_in = '1' then raddr_n <= raddr + 2;        --!
    elsif rd_en = '1' then  raddr_n <= raddr + 1;
    end if;
    if wr_en = '1' then waddr_n <= waddr + 1; end if;
end process;
process( wr_en, din, rd_en,fifo,raddr,waddr)
begin
fifo_n <= fifo;
if wr_en = '1' then fifo_n(to_integer(waddr)) <= din; end if;
end process;
dout <= fifo(to_integer(raddr));

end Behavioral;
