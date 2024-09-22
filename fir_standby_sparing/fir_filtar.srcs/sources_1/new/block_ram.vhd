----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2024 09:04:43 PM
-- Design Name: 
-- Module Name: block_ram - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity block_ram is
    Generic(
        BRAM_SIZE :natural := 1024;
        WIDTH:     natural := 32
    );
    Port ( clk_i : in STD_LOGIC;
           rst_i : in STD_LOGIC;
           -- write port
           en_a : in STD_LOGIC;
           addr_a : in STD_LOGIC_VECTOR (log2c(BRAM_SIZE)-1 downto 0);
           din_a : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           -- read port
           en_b : in STD_LOGIC;
           addr_b : in STD_LOGIC_VECTOR (log2c(BRAM_SIZE)-1 downto 0);
           dout_b : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
           -- common
           );
end block_ram;

architecture Behavioral of block_ram is
    type ram_type is array (0 to BRAM_SIZE-1) of std_logic_vector(WIDTH-1 downto 0); -- 1024 words of 8 bits
    signal memory : ram_type; -- Initialize memory with zeros
begin
process(clk_i) begin
    if rising_edge(clk_i) then
            if (en_a = '1') then
                memory(to_integer(unsigned(addr_a))) <= din_a;
            end if;
            if (en_b = '1') then
                dout_b <= memory(to_integer(unsigned(addr_b)));
            end if;
    end if;
end process;

end Behavioral;
