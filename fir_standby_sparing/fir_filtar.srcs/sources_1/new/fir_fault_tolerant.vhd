----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/20/2024 06:26:34 PM
-- Design Name: 
-- Module Name: fir_fault_tolerant - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fir_fault_tolerant is
generic(fir_ord : natural := 5;
        WIDTH : natural := 17;
        FIXED_POINT_POSITION : natural := 1;
        BRAM_SIZE : natural := 4096;
        NUM_OF_SPARE_PAIRS: natural := 4);
    Port (clk_i : in STD_LOGIC;
        rst_i  : in std_logic;
        we_i : in STD_LOGIC;
        start : in STD_LOGIC;
        
        coef_addr_i : std_logic_vector(log2c(fir_ord)-1 downto 0);
        coef_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        -- AXI SLAVE INTERFACE
        
        en_1 : in STD_LOGIC;
        addr_1 : in STD_LOGIC_VECTOR (log2c(BRAM_SIZE)-1 downto 0);
        data_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        -- AXI MASTER INTERFACE
        
        en_2 : in STD_LOGIC;
        addr_2 : in STD_LOGIC_VECTOR (log2c(BRAM_SIZE)-1 downto 0);
        data_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        ready : out STD_LOGIC_VECTOR (NUM_OF_SPARE_PAIRS*2-1 downto 0);
        error_o: out STD_LOGIC
        );
end fir_fault_tolerant;

architecture Behavioral of fir_fault_tolerant is
type std_2d_width is array (NUM_OF_SPARE_PAIRS*2-1 downto 0) of
std_logic_vector(WIDTH-1 downto 0);
signal voter_in : std_2d_width:=(others=>(others=>'0'));
signal data_s: STD_LOGIC_VECTOR (2*NUM_OF_SPARE_PAIRS*WIDTH-1 downto 0);
signal data_o_s: STD_LOGIC_VECTOR (2*NUM_OF_SPARE_PAIRS*WIDTH-1 downto 0);

 attribute dont_touch :string;
 attribute dont_touch of data_s: signal is "true";
begin


redundant_fir_filtars:
for j in 0 to NUM_OF_SPARE_PAIRS*2-1 generate
uut_fir_filter:
 entity work.fir_filtar_bram(behavioral)
 generic map(fir_ord=>fir_ord,
            FIXED_POINT_POSITION=>FIXED_POINT_POSITION,
            WIDTH=>WIDTH,
            BRAM_SIZE => BRAM_SIZE)
 port map(clk_i=>clk_i,
         rst_i=>rst_i,
         we_i=>we_i,
         start => start,
         coef_i=>coef_i,
         coef_addr_i=>coef_addr_i,
         en_1 => en_1,
         addr_1 => addr_1,
         data_i=>data_i,
         en_2 => en_2,
         addr_2 => addr_2,
         data_o=>data_s((j+1)*WIDTH-1 downto j*WIDTH),
         ready => ready(j));
 end generate;
 
voter:
entity work.voter_stanby_sparing(behavioral)
 generic map(WIDTH => WIDTH,
             PAIR_OF_SPARES => NUM_OF_SPARE_PAIRS)
 port map(clk=>clk_i,
         rst_i=>rst_i,
         voter_i=>data_s,
         voter_o => data_o,
         error_o => error_o);
end Behavioral;
