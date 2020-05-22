library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Generates a tick signal for clock gating
entity TickGenerator is
generic (divider : integer := 50);
port(
  -- the global clock and reset signals:
  clk_i : in std_logic;
  reset_i : in std_logic;
  -- the tick output
  tick_o : out std_logic
);
end TickGenerator;


architecture arch of TickGenerator is
  signal current_counter, next_counter : unsigned(16 downto 0);
  signal tick : std_logic;
 
begin
  -- transition function and output
  process(current_counter) is
  begin
    -- defaults
    tick <= '0'; 
	 next_counter <= current_counter + 1;
	 
    if (current_counter = (divider-1)) then
		next_counter <= (others => '0');
	 end if;
	 
	 if (current_counter = 0) then
	   tick <= '1';
    end if;
  end process;
  
  -- registers (also re-synchronize the outputs)
  process (clk_i, reset_i) is
  begin
    if (reset_i = '1') then
	   tick_o <= '0';
		current_counter <= (others => '0');
	 elsif rising_edge(clk_i) then
	   tick_o <= tick;
		current_counter <= next_counter;
	 end if;
  end process;
end architecture;
