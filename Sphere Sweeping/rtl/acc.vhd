----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/02/2019 02:41:53 AM
-- Design Name: 
-- Module Name: acc - Behavioral
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
-- addr_rgb_depth_count_sign [record] : sign = '1' means could accept new addr's value (at the end of array)
----------------------------
--------------------function
-- find the lowest SSD and its corresponding rgb and depth
-- Serrial connected acc(s) are the waiting zone 
--------
-- TODO: reject depth that's outof range [may get data deerectly from BRAM]
----------------------------
entity acc is
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
end acc;

architecture Behavioral of acc is
signal buf, buf_n:ssd_rgb_addr_dep:=(others =>(others => '0'));
signal out_valid_r, rout_valid_r, out_valid_n,rout_valid_n: std_logic:='0';
signal target, target_n:data_count_sign:=(sign => '1', count =>(others => '0'), data => (others =>(others => '0')));
signal result, result_n: rgb_addr:=(others =>(others => '0'));
signal pick,replace,pick_target_as_result,pick_target_as_result_r: std_logic;
begin

replace <= '1' when (in_valid = '1' and target.sign = '1') or (pick= '1' and din.ssd < target.data.ssd)
            else '0';
pick <= '1' when in_valid = '1' and din.out_addr = target.data.out_addr else '0';
pick_target_as_result <= '1' when target.count = depth_num and rin_valid = '0' else '0';


universal_reg:process(clk,rst)
begin
    if rising_edge(clk) then
        if rst = '0' then 
            -- count <= (others => '0');
            buf <= (others =>(others => '0'));
            target <= (sign => '1', count =>(others => '0'), data => (others =>(others => '0')));
            result <= (others =>(others => '0'));
            out_valid_r <= '0';
            --tout_valid_r <= '0';
            rout_valid_r <= '0';
            pick_target_as_result_r <= '0';
        else 
            -- count <= target_n.count;
            buf <= buf_n;
            target <= target_n;
            result <= result_n;
            out_valid_r <= out_valid_n;
            --tout_valid_r <= tout_valid_n;
            rout_valid_r <= rout_valid_n;
            pick_target_as_result_r <= pick_target_as_result;
        end if;
    end if;
end process;
rout_valid_n <= '1' when pick_target_as_result = '1' else rin_valid;
out_valid_n <= in_valid when pick = '0' else '0';
buf_n <= din;
result_n <= result_in;

target_comb:process(target, shift_sign_in, target_in,replace, in_valid, rin_valid,din,pick)
begin

    target_n <= target;     --default resume
    if shift_sign_in = '1' then 
        ----data
        if in_valid = '1' and target_in.data.out_addr = din.out_addr and din.ssd < target_in.data.ssd then target_n.data <= din; else target_n.data <= target_in.data; end if;
        ---- count
        if in_valid = '1' and target_in.data.out_addr = din.out_addr then target_n.count <= target_in.count + 1; else target_n.count <= target_in.count; end if;
        ----sign
        target_n.sign <= target_in.sign;
    else
        ---- data
        if replace = '1' then target_n.data <= din; end if ;
        ---- count
        target_n.count <= target.count;
        if pick_target_as_result = '1' then                                   -------------------------------
            target_n.count <= (others => '0'); 
        elsif  target.count < depth_num and pick = '1' then 
            target_n.count <= target.count+1;
        --else resume and wait for the result to be written
        end if; 
        ---- sign 
        if replace = '1' and in_valid = '1' then target_n.sign <= '0';end if;
    end if; 
    
end process;
----------------------
-- out
----------------------
shift_sign_out <= '1' when shift_sign_in = '1' or (target_n.count = 0 and target.count = depth_num )else '0';                    ------------------------------!!!
out_valid <=  out_valid_r;         -- special !! ??in_valid when target_n.count = 0 and target.sign = '0' else   
rout_valid <= rout_valid_r;
target_out <= target;
result_out <= (out_addr => target.data.out_addr, rgb => target.data.rgb) when pick_target_as_result_r = '1'
              else result;
dout <= buf;
end Behavioral;
