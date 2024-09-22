library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity tb_voter is
-- No ports in the test bench
end entity tb_voter;

architecture Behavioral of tb_voter is

    -- Parameters and signals for connecting to the voter module
    constant WIDTH : natural := 16;      -- Same width as in the voter entity
    constant SPARE : natural := 3;       -- Number of spare channels
    signal clk    : std_logic := '0';    -- Clock signal
    signal rst_n  : std_logic := '0';    -- Reset signal
    signal voter_i : std_logic_vector(2*SPARE*WIDTH-1 downto 0) := (others => '0'); -- Input to voter
    signal voter_o : std_logic_vector(WIDTH-1 downto 0);  -- Output from voter

    -- Clock period (simulation purposes)
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.voter
        generic map (
            WIDTH => WIDTH,
            SPARE => SPARE
        )
        port map (
            clk     => clk,
            rst_n   => rst_n,
            voter_i => voter_i,
            voter_o => voter_o
        );

    -- Clock generation process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process to drive inputs and observe outputs
    stimulus_process : process
    begin
        -- Reset the system
        rst_n <= '0';
        wait for clk_period * 2;
        rst_n <= '1';
        wait for clk_period * 2;

        -- Test case 1: Inputs are all zero
        voter_i <= (others => '0');
        wait for clk_period * 5;

        -- Test case 2: First set of signals match
        voter_i <= (std_logic_vector(to_unsigned(1000, WIDTH)) & std_logic_vector(to_unsigned(1000, WIDTH)) &
                    std_logic_vector(to_unsigned(500, WIDTH)) & std_logic_vector(to_unsigned(500, WIDTH)) &
                    std_logic_vector(to_unsigned(200, WIDTH)) & std_logic_vector(to_unsigned(200, WIDTH)));
        wait for clk_period * 5;

        -- Test case 3: A different match
        voter_i <= (std_logic_vector(to_unsigned(1500, WIDTH)) & std_logic_vector(to_unsigned(1500, WIDTH)) &
                    std_logic_vector(to_unsigned(700, WIDTH)) & std_logic_vector(to_unsigned(700, WIDTH)) &
                    std_logic_vector(to_unsigned(300, WIDTH)) & std_logic_vector(to_unsigned(300, WIDTH)));
        wait for clk_period * 5;

        -- Test case 4: No matches (output should stick to previous valid match)
        voter_i <= (std_logic_vector(to_unsigned(200, WIDTH)) & std_logic_vector(to_unsigned(200, WIDTH)) &
                    std_logic_vector(to_unsigned(400, WIDTH)) & std_logic_vector(to_unsigned(400, WIDTH)) &
                    std_logic_vector(to_unsigned(600, WIDTH)) & std_logic_vector(to_unsigned(800, WIDTH)));
        wait for clk_period * 5;

        -- Test case 5: No matches (output should stick to previous valid match)
        voter_i <= (std_logic_vector(to_unsigned(200, WIDTH)) & std_logic_vector(to_unsigned(200, WIDTH)) &
                    std_logic_vector(to_unsigned(300, WIDTH)) & std_logic_vector(to_unsigned(400, WIDTH)) &
                    std_logic_vector(to_unsigned(600, WIDTH)) & std_logic_vector(to_unsigned(800, WIDTH)));
        wait for clk_period * 5;
        
        -- Finish simulation
        wait;
    end process;

end architecture Behavioral;