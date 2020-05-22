library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- Writes to the DAC on the Electronics for Physicists ADC/DAC board
-- using the SPI interface.
-- The data is registered at the beginning of the transmission.
--
-- Yves Acremann, 20.3.2019
--
entity DACWriter is
port(
-- the global clock and reset signals:
  clk_i   : in std_logic;
  reset_i : in std_logic;
  
  -- the data and control inputs
  data_i  : in signed(15 downto 0);
  start_i : in std_logic;
  
  -- asserted high if the state machine is idle
  is_idle_o : out std_logic;
  
  -- the SPI master outputs
  spi_clk_o     : out std_logic;
  spi_mosi_o    : out std_logic;
  spi_cs_o      : out std_logic;
  dac_reset_o_n : out std_logic
  
);
end DACWriter;





architecture arch of DACWriter is

  signal dataToSend     : std_logic_vector(15 downto 0);  -- the data as bits
  signal dataToSendNext : std_logic_vector(15 downto 0);  -- the data as bits (registered)

  -- the states:
  --  idle:      wait for start
  --  cs_low:    sets the chip select to '0' to start the transmission
  --  set_clk:   sets the SPI clock signal. In addition we update the
  --             bit counter (as its output gets active on the next clock cycle)
  --  clear_clk: sets the SPI clock signal to '0'. 
  --  wait_low:  sets the chip select to '1' and waits for the start to get '0'.
  type state_t is  (idle, cs_low, set_clk, clear_clk, wait_low);

  signal current_state, next_state : state_t;

  -- the bit counter used to address the individual bits (also part of the state)
  signal current_bit_counter, next_bit_counter : integer range 0 to 16 := 15;

begin

  
  
  
  -- transition function (f)
  process (current_state, current_bit_counter, start_i, dataToSend)
  begin
  
    -- default: don't change state
	next_bit_counter <= current_bit_counter;
	next_state <= current_state;
        dataToSendNext <= dataToSend;
	
    case current_state is
    
       -- idle: init the bit counter to 15,
       -- wait for start
	   when idle =>
		  next_bit_counter <= 15;
		  if (start_i = '1')
		  then
                     next_state <= cs_low;
                     -- convert the input data to a std_logic_vector (and use a register for that!)
                     -- (in this case, the DAC uses the center of the unsigned range for
                     -- 0V output.)
                     dataToSendNext <= std_logic_vector(data_i + to_signed(32767, 16));
		  end if;
        		
	   when cs_low =>
	      next_state <= set_clk;
	      
	   -- here, we set the clock.
	   -- In addition, we update the bit counter for the next bit.
	   -- (gets active on the next clock cycle)
	   when set_clk =>
	      if (current_bit_counter = 0)
		  then
		     next_state <= wait_low;
			  next_bit_counter <= 15;
		  else
			  next_state <= clear_clk;
		     next_bit_counter <= current_bit_counter - 1;
		  end if;
		  
	   when clear_clk =>
		  next_state <= set_clk;
			
	    -- wait until the start is '0' again.
	    -- In addition, we set the CS to '1' (see ooutput function)
		when wait_low =>
		   if start_i = '0' then
			  next_state <= idle;
		   end if;
		  		  
	 end case;
  end process;
  
  
  
  
  
  -- output function (g):
  process (current_state, current_bit_counter, dataToSend)
  begin
  
    -- we always set the mosi to the current bit
    spi_mosi_o <= dataToSend(current_bit_counter);
	
    case current_state is
	   when idle =>
	      spi_cs_o  <= '1';
		  spi_clk_o <= '0';
		  is_idle_o <= '1';
		
	   when cs_low =>
		  spi_cs_o  <= '0';
		  is_idle_o <= '0';
		  spi_clk_o <= '0';
		  
	   when set_clk =>
		  spi_cs_o  <= '0';
		  spi_clk_o <= '1';
		  is_idle_o <= '0';
		  
	   when clear_clk =>
		  spi_cs_o  <= '0';
		  spi_clk_o <= '0';
		  is_idle_o <= '0';
			 
	   when wait_low =>
		  spi_cs_o  <= '1';
		  spi_clk_o <= '0';
		  is_idle_o <= '0';
		   
	 end case;
  end process;
  -- the reset signal for the DAC: 
  dac_reset_o_n <= not reset_i;
  
  
  
  -- the registers:
  process (clk_i, reset_i) is
  begin
    if (reset_i = '1') then
	    current_state <= idle;
		current_bit_counter <= 15;
                dataToSend <= (others => '0');
	 elsif (rising_edge(clk_i)) then
	   current_state <= next_state;
	   current_bit_counter <= next_bit_counter;
           dataToSend <= dataToSendNext;
	 end if;
  end process;
  

  
  
  

end arch;
