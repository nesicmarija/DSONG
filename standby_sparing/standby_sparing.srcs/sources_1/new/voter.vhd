----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/12/2024 04:32:57 PM
-- Design Name: 
-- Module Name: voter - Behavioral
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
use work.util_pkg.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity voter is
    Generic(
        WIDTH : natural := 17;
        SPARE : natural := 3
        );
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           voter_i : in STD_LOGIC_VECTOR (2*SPARE*WIDTH-1 downto 0);
           voter_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           error_o : out STD_LOGIC);
end voter;

architecture Behavioral of voter is

type std_2d is array (SPARE-1 downto 0) of
std_logic_vector(WIDTH-1 downto 0);
signal voter_in_signal_nxt, voter_in_signal_reg : std_2d:=(others=>(others=>'0'));
signal voter_in_fdu : std_2d:=(others=>(others=>'0'));
signal eq_o: STD_LOGIC_VECTOR (SPARE-1 downto 0);
signal mux_sel_reg, mux_sel_nxt: STD_LOGIC_VECTOR (log2c(SPARE)-1 downto 0);
signal mux_out: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
signal eq_relevant: std_logic; 
begin

-- There are 2*SPARE inputs of width WIDTH
-- They are separated into inputs from FIR filtar,
-- and inputs from a Fault Detection Unit (FDU)
assing_inputs:
for i in 0 to SPARE-1 generate
     voter_in_signal_nxt(i) <= voter_i((2*i+1)*WIDTH-1 downto 2*i*WIDTH);
     voter_in_fdu(i) <= voter_i((2*i+2)*WIDTH-1 downto (2*i+1)*WIDTH);
end generate;

-- If signal is equal to its FDU output, eq = '1'
process(voter_in_signal_nxt,voter_in_fdu) is
begin
    loop_ff: for i in 0 to SPARE-1 loop
     if(voter_in_signal_nxt(i) = voter_in_fdu(i)) then
        eq_o(i) <= '1';
     else
        eq_o(i) <= '0';
     end if;
    end loop loop_ff;
end process;

process(clk) is
begin
    if (rising_edge(clk)) then
        if (rst_n = '0') then
            mux_sel_reg <= (others => '0'); -- Reset the register to zero
            voter_in_signal_reg <= (others => (others => '0'));
        else
            mux_sel_reg <= mux_sel_nxt;
            voter_in_signal_reg <= voter_in_signal_nxt;
        end if;
    end if;
end process;

-- MUX that choose which pair eq signal is relevant
eq_relevant <= eq_o(to_integer(unsigned(mux_sel_reg)));

-- If fault detected, switching to next pair
process(eq_relevant,mux_sel_reg, mux_sel_nxt) is
begin
    if (eq_relevant = '0') then
            mux_sel_nxt <= mux_sel_reg + 1;
        else
            mux_sel_nxt <= mux_sel_reg;
        end if;
end process;

-- MUX that choose which signal is selected to be output
mux_out <= voter_in_signal_reg(to_integer(unsigned(mux_sel_reg)));
voter_o <= mux_out;

-- signal error_o is equal to '1' when every pair has fault
process(eq_o) is
begin
    if(eq_o = 0) then
        error_o <= '1';
    else
        error_o <= '0';
    end if;
end process;
end Behavioral;
