library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

-------------------------------------------------- pkg

package omini_pkg is
constant camera_num:        integer:=   6;      --number of camera, also img num [fixed]            -- TODO: add reconfig
constant PE_num:            integer:=   10;     --number of PEs in array (2 input at this stage)
-- constant color_width:       integer:=   8;      --0-255 for RGB
constant out_addr_width:    integer:=   21;     --log2(1200) + log2(600) 
constant in_interval_width: integer:=   7;      --describing intervels between pixels mapped to output in input img
constant SSD_width:         integer:=   16;      --SSD calculation precision
constant depth_width:       integer:=   5;      --
constant depth_num:         integer:=   20;     -- fixed                                             -- TODO: add reconfig
constant zone_width: integer:= 3;     -- assuming 6 seperate overlaping rigeons, need 3 bits
constant wait_len_width: integer:= 10;
constant acc_num : integer:= 6;
constant out_img_h: integer:= 6;
constant acc_array_length: integer:= 100;
subtype rgb_data is std_logic_vector(23 downto 0);

--in following records' name: '_' means 'and'
type conf_line is record
    waitlen: std_logic_vector(wait_len_width - 1 downto 0);
    interval: std_logic_vector(in_interval_width-1 downto 0);             
    out_addr: std_logic_vector(out_addr_width-1 downto 0);
    zone:     std_logic_vector(zone_width-1 downto 0);                    
    depth:    std_logic_vector(depth_width-1 downto 0);
end record;
type waitlen_rgb_addr_zone_dep is record
    waitlen: std_logic_vector(wait_len_width - 1 downto 0);     --one more bit for sign
    rgb: std_logic_vector(23 downto 0);
    out_addr: std_logic_vector(out_addr_width-1 downto 0);
    zone:     std_logic_vector(zone_width-1 downto 0);   
    depth:    std_logic_vector(depth_width-1 downto 0);
end record;
type waitlen_rgb_addr_zone_dep_array is array (camera_num - 1 downto 0) of waitlen_rgb_addr_zone_dep;
type waitlen_rgb_addr_dep is record
    waitlen: std_logic_vector(wait_len_width-1 downto 0);     --one more bit for sign
    rgb: std_logic_vector(23 downto 0);
    out_addr: std_logic_vector(out_addr_width-1 downto 0);
    depth:    std_logic_vector(depth_width-1 downto 0);
end record;
type rgb_addr_dep is record
    rgb: std_logic_vector(23 downto 0);
    out_addr: std_logic_vector(out_addr_width-1 downto 0);
    depth:    std_logic_vector(depth_width-1 downto 0);
end record;
type rgb_addr is record
    rgb: std_logic_vector(23 downto 0);
    out_addr: std_logic_vector(out_addr_width-1 downto 0);
end record;
type out_format is array (acc_num - 1 downto 0) of rgb_addr;
type rgb1_rgb2_addr_dep is record
    rgb1 :std_logic_vector(23 downto 0);
    rgb2: std_logic_vector(23 downto 0);
    out_addr:std_logic_vector(out_addr_width-1 downto 0);
    depth:    std_logic_vector(depth_width-1 downto 0);
end record;
type ssd_rgb_addr_dep is record
    ssd: std_logic_vector(SSD_width-1 downto 0);
    rgb: rgb_data;
    out_addr: std_logic_vector(out_addr_width-1 downto 0);
    depth:    std_logic_vector(depth_width-1 downto 0);
end record;
type addr_rgb_depth is record
    out_addr: std_logic_vector(out_addr_width-1 downto 0);
    rgb : rgb_data;
    depth: std_logic_vector(depth_width-1 downto 0);
end record;
type data_count_sign is record 
    data: ssd_rgb_addr_dep;
    count: std_logic_vector(4 downto 0);
    sign: std_logic;                        -- sign for whether at the end of the array, which means could accept new addr's value
end record;
type conf_line_array is array (camera_num - 1 downto 0) of conf_line;
type video_data is array (camera_num - 1 downto 0) of rgb_data;     --??? stream format?
type waitlen_rgb_addr_dep_array is array (camera_num - 1 downto 0) of waitlen_rgb_addr_dep;
type dist_data_subtype is array(camera_num - 1 downto 0) of waitlen_rgb_addr_dep; 
type dist_data_type is array (depth_num - 1 downto 0) of dist_data_subtype;
type valid_type is array (depth_num - 1 downto 0) of std_logic_vector(camera_num - 1 downto 0);
type buf_sign_subtype is array (camera_num - 1 downto 0) of std_logic_vector(5 downto 0); --64 fifo depth at the out of buf
type buf_sign_type is array (depth_num - 1 downto 0) of buf_sign_subtype;
type rgb1_rgb2_addr_dep_subtype is array (camera_num - 1 downto 0) of rgb1_rgb2_addr_dep;
type rgb1_rgb2_addr_dep_type is array (depth_num - 1 downto 0) of rgb1_rgb2_addr_dep_subtype;
type pe_out_type is array (depth_num - 1 downto 0) of ssd_rgb_addr_dep;
type arbi_out_type is array(acc_num-1 downto 0) of ssd_rgb_addr_dep;
type acc_group_out_type is array(acc_num-1 downto 0) of addr_rgb_depth;
--type arbiter_in_count_type is array (depth_num - 1 downto 0) of std_logic_vector(5 downto 0);
type arbiter_en_type is array (acc_num-1 downto 0) of std_logic_vector(depth_num - 1 downto 0);
type arbiter_count_subtype is array (depth_num - 1 downto 0) of std_logic_vector(5 downto 0);
type arbiter_count_down_sampled_subtype is array (depth_num - 1 downto 0) of std_logic_vector(1 downto 0);
type arbiter_count_type is array (acc_num - 1 downto 0) of arbiter_count_down_sampled_subtype;
function trans(A:conf_line) return std_logic_vector;
function transcl(B:std_logic_vector(wait_len_width+in_interval_width+out_addr_width+zone_width+depth_width-1 downto 0)) return conf_line; 
function trans(A:ssd_rgb_addr_dep) return std_logic_vector;
function transsr(B:std_logic_vector) return ssd_rgb_addr_dep;
function trans (A:rgb1_rgb2_addr_dep) return std_logic_vector;
function transrr (B:std_logic_vector) return rgb1_rgb2_addr_dep;
end package;
----------------------
package body omini_pkg is
function trans(A:conf_line) return std_logic_vector is
begin
    return A.waitlen&A.interval & A.out_addr & A.zone & A.depth;
end function;
function transcl(B:std_logic_vector(wait_len_width+in_interval_width+out_addr_width+zone_width+depth_width-1 downto 0)) return conf_line is 
variable A:conf_line;
begin
    A.waitlen :=B(wait_len_width+in_interval_width+out_addr_width+zone_width+depth_width-1 downto in_interval_width+out_addr_width+zone_width+depth_width);
    A.interval := B(in_interval_width+out_addr_width+zone_width+depth_width-1 downto depth_width+zone_width+out_addr_width);
    A.out_addr := B(depth_width+zone_width+out_addr_width-1 downto depth_width+zone_width);
    A.zone := B(depth_width+zone_width-1 downto depth_width);
    A.depth := B(depth_width-1 downto 0);
    return A;
end function;
function trans(A:ssd_rgb_addr_dep) return std_logic_vector is 
begin
    return A.ssd & A.rgb & A.out_addr & A.depth;
end function;
function transsr(B:std_logic_vector) return ssd_rgb_addr_dep is 
variable A:ssd_rgb_addr_dep;
begin
    A.ssd := B(ssd_width+out_addr_width+24+depth_width-1 downto depth_width+out_addr_width+24);
    A.rgb := B(depth_width+out_addr_width+24-1 downto depth_width+out_addr_width);
    A.out_addr := B(depth_width+out_addr_width-1 downto depth_width);
    A.depth := B(depth_width-1 downto 0);
    return A;
end function;

function trans (A:rgb1_rgb2_addr_dep) return std_logic_vector is 
begin
    return A.rgb1 & a.rgb2 & a.out_addr & a.depth;
end function;
function transrr (B:std_logic_vector) return rgb1_rgb2_addr_dep is 
variable A: rgb1_rgb2_addr_dep;
begin
    A.rgb1 := B(24+out_addr_width+24+depth_width-1 downto depth_width+out_addr_width+24);
    A.rgb2 := B(depth_width+out_addr_width+24-1 downto depth_width+out_addr_width);
    A.out_addr := B(depth_width+out_addr_width-1 downto depth_width);
    A.depth := B(depth_width-1 downto 0);
    return A;
end function;
end package body;
-------------------------------------------------- pkg