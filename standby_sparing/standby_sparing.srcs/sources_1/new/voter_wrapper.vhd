----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/18/2024 05:36:05 PM
-- Design Name: 
-- Module Name: voter_wrapper - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity voter_wrapper is
Generic(
        WIDTH : natural := 17;
        SPARE : natural := 5
        );
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           voter_i : in STD_LOGIC_VECTOR (2*SPARE*WIDTH-1 downto 0);
           voter_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           error_o : out STD_LOGIC);
end voter_wrapper;

architecture Behavioral of voter_wrapper is
signal voter_i_s: STD_LOGIC_VECTOR (2*SPARE*WIDTH-1 downto 0);
signal voter_o_s: STD_LOGIC_VECTOR (WIDTH-1 downto 0);
signal error_o_s: STD_LOGIC;
begin

process (clk) is
begin
    if (rising_edge(clk)) then
        if (rst_n = '0') then
            voter_i_s <= (others => '0');
            voter_o <= (others => '0');
            error_o <= '0';
        else
            voter_i_s <= voter_i;
            voter_o <= voter_o_s;
            error_o <= error_o_s;
        end if;
    end if;
end process;

voter_instance:
entity work.voter(behavioral)
    generic map (WIDTH => WIDTH,
                 SPARE => SPARE
    )
    port map (clk => clk,
              rst_n => rst_n,
              voter_i => voter_i_s,
              voter_o => voter_o_s,
              error_o => error_o_s);

end Behavioral;
