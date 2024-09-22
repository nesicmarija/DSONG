----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/20/2024 12:26:56 PM
-- Design Name: 
-- Module Name: fir_filtar_bram - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fir_filtar_bram is
generic(fir_ord : natural := 20;
        WIDTH : natural := 17;
        FIXED_POINT_POSITION : natural := 1;
        BRAM_SIZE : natural := 4096);
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
        ready : out STD_LOGIC
        );
end fir_filtar_bram;

architecture Behavioral of fir_filtar_bram is
signal fir_data_i, fir_data_o, d_s: std_logic_vector (WIDTH-1 downto 0);
signal fir_en_i, fir_en_o: std_logic;
signal dout_b_s: std_logic_vector (WIDTH-1 downto 0);
signal fir_addr_i_reg, fir_addr_i_nxt: STD_LOGIC_VECTOR (log2c(BRAM_SIZE)-1 downto 0);
signal fir_addr_o_reg, fir_addr_o_nxt: STD_LOGIC_VECTOR (log2c(BRAM_SIZE)-1 downto 0);
type state_type is (IDLE,FIR_WORKING_1, FIR_WORKING_2, FIR_WORKING_3);
signal state_reg, state_nxt: state_type;

begin

input_block_ram:
entity work.block_ram (behavioral)
    generic map (WIDTH => WIDTH,
                 BRAM_SIZE => BRAM_SIZE)
    port map (
        clk_i => clk_i,
        rst_i => rst_i,
        -- write port
        en_a  => en_1,
        addr_a => addr_1,
        din_a => data_i,
        --read port
        en_b => fir_en_i,
        addr_b => fir_addr_i_reg,
        dout_b => fir_data_i
    );

fir_filtar:
entity work.fir_filtar(behavioral)
    generic map (fir_ord => fir_ord,
                 WIDTH => WIDTH,
                 FIXED_POINT_POSITION => FIXED_POINT_POSITION
    )
    port map (clk_i => clk_i,
              rst_i => rst_i,
              we_i  => we_i,
              coef_i => coef_i,
              coef_addr_i => coef_addr_i,
              data_i => fir_data_i,
              data_o => fir_data_o);

output_block_ram:
entity work.block_ram (behavioral)
    generic map (WIDTH => WIDTH,
                 BRAM_SIZE => BRAM_SIZE)
    port map (
        clk_i => clk_i,
        rst_i => rst_i,
        -- write port
        en_a  => fir_en_o,
        addr_a => fir_addr_o_reg,
        din_a => fir_data_o,
        --read port
        en_b => en_2,
        addr_b => addr_2,
        dout_b => data_o
    );

process(clk_i) is
begin
    if (rising_edge(clk_i)) then
        if (rst_i = '1') then
            state_reg <= IDLE;
            fir_addr_i_reg <= (others => '0');
            fir_addr_o_reg <= (others => '0');
        else
            state_reg <= state_nxt;
            fir_addr_i_reg <= fir_addr_i_nxt;
            fir_addr_o_reg <= fir_addr_o_nxt;
        end if;
    end if;
end process;

process(start,state_nxt, state_reg, fir_addr_i_reg, fir_addr_o_reg) is
begin
    ready <= '0';
    case state_reg is
        when IDLE =>
            ready <= '1';
            fir_addr_i_nxt <= (others => '0');
            fir_en_i <= '0';
            
            fir_addr_o_nxt <= (others => '0');
            fir_en_o <= '0';
            if (start = '0') then
                state_nxt <= IDLE;
            else
                state_nxt <= FIR_WORKING_1;
            end if;
        when FIR_WORKING_1 =>
            fir_en_i <= '1';
            fir_addr_i_nxt <= std_logic_vector( unsigned(fir_addr_i_reg) + 1 );
            
            fir_en_o <= '0';
            fir_addr_o_nxt <= (others => '0');
            if (to_integer(unsigned(fir_addr_i_reg)) = fir_ord+2) then
                state_nxt <= FIR_WORKING_2;
            else
                state_nxt <= FIR_WORKING_1;
            end if;
        when FIR_WORKING_2 =>
            fir_en_i <= '1';
            fir_addr_i_nxt <= std_logic_vector( unsigned(fir_addr_i_reg) + 1 );
            
            fir_en_o <= '1';
            fir_addr_o_nxt <= std_logic_vector( unsigned(fir_addr_o_reg) + 1 );
            if (to_integer(unsigned(fir_addr_i_reg)) = BRAM_SIZE-1) then
                state_nxt <= FIR_WORKING_3;
            else
                state_nxt <= FIR_WORKING_2;
            end if;
        when FIR_WORKING_3 =>
            fir_en_i <= '0';
            
            fir_en_o <= '1';
            fir_addr_o_nxt <= std_logic_vector( unsigned(fir_addr_o_reg) + 1 );
            if (to_integer(unsigned(fir_addr_o_reg)) = BRAM_SIZE-1) then
                state_nxt <= IDLE;
            else
                state_nxt <= FIR_WORKING_3;
            end if;
    end case;
end process;
end Behavioral;
