library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

-- declaration of the interface: input and output clock
entity ADCReader is
port(
-- the global clock and reset signals:
  clk_i   : in std_logic;
  reset_i : in std_logic;
  
  -- the data and control inputs
  data_o  : out signed(15 downto 0);
  start_i : in std_logic;
  
  -- asserted high if the state machine is idle
  is_idle_o : out std_logic;
  
  -- the SPI master
  spi_clk_o : out std_logic;
  spi_miso_i : in std_logic;
  spi_mosi_o : out std_logic;
  cnv_o : out std_logic
  
);
end ADCReader;


architecture arch of ADCReader is
  type state_t is  (idle, conv_high, conv_low, wait_busy, pre_clk_high, pre_clk_low, clk_set, bit_read, clk_low, latch_out, wait_low);
  signal current_state : state_t;
  signal next_state : state_t;
  signal data, data_next, data_out_next, data_out : std_logic_vector(15 downto 0);
 
  signal current_bit_counter : integer range 0 to 16;
  signal next_bit_counter : integer range 0 to 16;

  signal spi_clk : std_logic;
  signal spi_mosi: std_logic;
  signal cnv : std_logic;
  signal is_idle : std_logic;
  signal spi_miso : std_logic;
  signal start : std_logic;


begin

  spi_mosi_o <= '1';

  -- combinational logic block (transition function and output)
  process (current_state, current_bit_counter, start, data, spi_miso, start_i)
  begin
  
    -- defaults:
    spi_clk <= '0';
    cnv <= '1';
    is_idle <= '0';
    next_bit_counter <= current_bit_counter;
    data_next <= data;
    data_out_next <= data_out;
	 
    case current_state is
	   when idle =>
		  is_idle <= '1';
		  next_bit_counter <= 15;
		  if (start = '1')
		    then
			   next_state <= conv_low;
			 else
			   next_state <= idle;
			 end if;
		  
		when conv_low =>
		  cnv <= '0';
		  is_idle <= '0';
	     next_state <= clk_set;
		  
		when clk_set =>
		  cnv <= '0';
		  spi_clk <= '1';
	     next_state <= bit_read;
		  
		when clk_low =>
		  cnv <= '0';
		  spi_clk <= '0';
		  next_state <= bit_read;
		  
		when bit_read =>
		  cnv <= '0';
		  spi_clk <= '0';
		  data_next(current_bit_counter) <= spi_miso_i;
		  if current_bit_counter = 0
		    then
		      next_state <= latch_out;
				next_bit_counter <= 15;
			 else
				next_state <= clk_set; 
		      next_bit_counter <= current_bit_counter - 1;
			 end if;
			 
		 when latch_out =>
		   data_out_next <= data;
			next_state <= wait_low;
			 
		 when wait_low =>
		   if start_i = '1' then
			  next_state <= wait_low;
			else
			  next_state <= idle;
			end if;
		
		when others =>
		  next_state <= idle;
		  		  
	 end case;
  end process;
  
  
  
  -- registers
  process (clk_i, reset_i) is
  begin
    if (reset_i = '1') then
	   current_state <= idle;
		current_bit_counter <= 15;
		cnv_o <= '0';
		spi_clk_o <= '0';
		is_idle_o <= '1';
		data <= x"0000";
		spi_miso <= '0';
		start <= '0';
	 elsif (rising_edge(clk_i)) then
	   current_state <= next_state;
		current_bit_counter <= next_bit_counter;
		data <= data_next;
		data_out <= data_out_next;
		-- register the output signals
		spi_clk_o <= spi_clk;
      cnv_o <= cnv;
		is_idle_o <= is_idle;
		spi_miso <= spi_miso_i;
		start <= start_i;
	 end if;
  end process;
  
  data_o <= signed(data_out);
  

end arch;
