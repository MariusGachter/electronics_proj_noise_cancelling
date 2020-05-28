library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
--use IEEE.math_real.all;

-- Direct connection between the ADC1, ADC2 and DAC channel.
--
 -- Connections:
-- DAC: sound out
-- arduino_io( 0) : dac_cs_n   (chip select)
-- arduino_io( 1) : dac_sclk   (serial clock)
-- arduino_io( 2) : dac_din    (data in)
-- arduino_io( 3) : dac_clr_n  (clear the DAC)
-- ADC 1: sound in
-- arduino_io( 4) : adc1_cnv    (convert / chip select)
-- arduino_io( 5) : adc1_sck    (serial clock)
-- arduino_io(6) : adc1_sdi    (data in)
-- arduino_io(7) : adc1_sdo    (data out)
-- 
-- ADC 2: noise in
-- arduino_io( 8) : adc2_cnv    (convert / chip select)
-- arduino_io( 9) : adc2_sck    (serial clock)
-- arduino_io(10) : adc2_sdi    (data in)
-- arduino_io(11) : adc2_sdo    (data out)
--
-- BUS: 
-- io_spi_sclk             => ARDUINO_IO(12),
-- io_spi_mosi             => ARDUINO_IO(13),
-- io_spi_miso_write       => ARDUINO_IO(14),
-- io_spi_ss               => GPIO(1),
-- Also power the digital side of the DAC board with 3.3V and connect the ground.
-- CAUTION: DON'T USE THE 5V OUTPUT, USE 3.3V!



-- Here we define the inputs / outputs
entity NC is
port(
  MAX10_CLK1_50 : in std_logic;                         -- 50 HMz clock
  KEY           : in std_logic_vector(1 downto 0);      -- Buttons
  ARDUINO_IO    : inout std_logic_vector(15 downto 0);  -- Header pins
  GPIO          : inout std_logic_vector(35 downto 0);  -- for slave select
  LEDR          : out std_logic_vector(9 downto 0);     -- LEDs
  SW            : in  std_logic_vector(9 downto 0)      -- Switches
);
end NC;




-- The architecture statement describes the actual functionality
architecture arch of NC is
  -- clock, reset and tick signal
  signal clk   : std_logic;
  signal reset : std_logic;
  signal tick  : std_logic;
  
  -- signals for the adc1: sound in (names according to the data sheet)
  signal adc1_cnv   : std_logic;
  signal adc1_sdi   : std_logic;
  signal adc1_sdo   : std_logic;
  signal adc1_sck   : std_logic;
  
  -- signals for the adc2: noise in (names according to the data sheet)
  signal adc2_cnv   : std_logic;
  signal adc2_sdi   : std_logic;
  signal adc2_sdo   : std_logic;
  signal adc2_sck   : std_logic;

  -- signals going to the DAC (names according to the data sheet)
  signal dac_din   : std_logic;
  signal dac_sclk  : std_logic;
  signal dac_cs_n  : std_logic;
  signal dac_clr_n : std_logic;

  -- the value from the DAC
  signal adc_sound_in     : signed(15 downto 0);
  signal adc_noise_in	  : signed(15 downto 0);
  signal adc_noise_filtered : signed(15 downto 0);
  signal dac_sound_out	  : signed(15 downto 0);
  
  -- bus stuff
  signal in_gain_coeff  : std_logic_vector(31 downto 0);
  signal gain_multiplier : signed(31 downto 0);
  signal coeff_gain : signed(15 downto 0);
  
  -- FIR parameters
constant numOfStages       : integer := 51; -- don't forget to adjust the number of stages when you drop in your filter
constant numOfBitsInput    : integer := 16;
constant numOfBitsOutput   : integer := 16;
  
constant fir_coeffs : real_vector(numOfStages-1 downto 0) := 
      (-1.2617788331236998e-21, -- this is b0 from pyFDA
		0.00017058199681154544,   -- this is b1 from pyFDA
		-0.0010195793480159015,   -- you can use floating point here
		-0.001800881541766439,    -- since it will be converted to fixed point
		0.0010835038619198554,    -- at compile times
		0.005084631910084775,
		0.0021163657477657515,
		-0.006940624353012838,
		-0.008051331580765111,
		0.0032623891551672177,
		0.009931283218029422,
		0.0023489523025099564,
		-0.0025395485266159756,
		0.003062120540777498,
		-0.00412525249487453,
		-0.025541910291494593,
		-0.012401392515955907,
		0.04584344996598513,
		0.06025754115438894,
		-0.028661511960910827,
		-0.11052429173415769,
		-0.03918753636035152,
		0.1137982023526964,
		0.12234515440159036,
		-0.04877738709275036,
		0.8405341423858895,
		-0.048777387092750354,
		0.12234515440159034,
		0.11379820235269639,
		-0.039187536360351514,
		-0.11052429173415768,
		-0.02866151196091082,
		0.06025754115438893,
		0.045843449965985106,
		-0.012401392515955902,
		-0.025541910291494586,
		-0.004125252494874529,
		0.0030621205407774968,
		-0.0025395485266159743,
		0.0023489523025099547,
		0.009931283218029422,
		0.0032623891551672177,
		-0.008051331580765106,
		-0.00694062435301283,
		0.0021163657477657485,
		0.005084631910084768,
		0.0010835038619198554,
		-0.0018008815417664382,
		-0.0010195793480159009,
		0.00017058199681154533,
		-1.2617788331236998e-21		-- b50 in my case (b0 to b50 --> 51 stages in total)
       );
  
begin

  -- instantiate the ADCReader ADC1 --> sound_in
  adc_sound: entity work.ADCReader
    port map(
      clk_i   => clk,
      reset_i => reset,
  
      data_o  => adc_sound_in,
      start_i => tick,
  
      -- asserted high if the state machine is idle
      is_idle_o => open,
  
      -- the SPI master
      spi_clk_o  => adc1_sck,
      spi_miso_i => adc1_sdo,
      spi_mosi_o => adc1_sdi,
      cnv_o      => adc1_cnv
  );  
  
  -- instantiate the tick generator
  tickGen : entity work.TickGenerator
    -- here we set the sampling rate:
    generic map (divider => 50)
    port map(
    clk_i => clk,
    reset_i => reset,
    tick_o =>  tick
  );
  
  -- instantiate the ADCReader ADC2 --> noise_in
  adc_noise: entity work.ADCReader
    port map(
      clk_i   => clk,
      reset_i => reset,
  
      data_o  => adc_noise_in,
      start_i => tick,
  
      -- asserted high if the state machine is idle
      is_idle_o => open,
  
      -- the SPI master
      spi_clk_o  => adc2_sck,
      spi_miso_i => adc2_sdo,
      spi_mosi_o => adc2_sdi,
      cnv_o      => adc2_cnv
  ); 


  -- instantiate the DACWriter
  dac : entity work.DACWriter port map(
     clk_i   => clk,
     reset_i => reset,
  
     start_i => tick,
	  -- the data and control inputs
     data_i  => dac_sound_out,
  
     is_idle_o => open,
  
     -- the SPI master outputs (according to the data sheet)
     spi_clk_o     => dac_sclk,
     spi_mosi_o    => dac_din,
     spi_cs_o      => dac_cs_n,
     dac_reset_o_n => dac_clr_n
  );
  

  -- instantiate the bus
  myBus : entity work.ApbBus
  port map(
    io_spi_sclk             => ARDUINO_IO(12),
    io_spi_mosi             => ARDUINO_IO(13),
    io_spi_miso_write       => ARDUINO_IO(14),
    io_spi_miso_writeEnable => open,
    io_spi_ss               => GPIO(1),
	 
    io_outGain  => in_gain_coeff,
    clk => MAX10_CLK1_50,
    reset => reset);
	 
  
  -- instantiate the FIR
  firFilter : entity work.FIR(pipeline) -- statemachine or pipeline
    generic map(
      numOfBitsInput => numOfBitsInput,
      -- make sure this is not larger than what is calculated internally!  
      numOfBitsOutput => numOfBitsOutput,
      numOfStages    => numOfStages,
      coeffs => fir_coeffs
    )
    port map(
      clk_i => clk,
      reset_i => reset,
  
      -- input strobe for the input sampling rate
      tick_i   => tick,
      signal_i => adc_noise_in,
      signal_o => adc_noise_filtered
  );	 
  
  -- reset and clk
  reset <= not key(0);
  clk   <= MAX10_CLK1_50;

  
  LEDR(9 downto 0) <= std_logic_vector(unsigned(in_gain_coeff)(9 downto 0));
  
  --coeff_gain <= to_signed(100,16);
  --coeff_gain <= signed(in_gain_coeff(15 downto 0));
  --gain_multiplier <= adc_sound_in*coeff_gain;
  --dac_sound_out <= gain_multiplier(29 downto 14);
  
  
  dac_sound_out <= signed(adc_sound_in*2000 + adc_noise_filtered*signed(in_gain_coeff(15 downto 0)))(29 downto 14);
  --dac_sound_out <= adc_noise_in;
  --dac_sound_out <= adc_sound_in;
  arduino_io(0)  <= dac_cs_n;
  arduino_io(1)  <= dac_sclk;
  arduino_io(2)  <= dac_din;
  arduino_io(3)  <= dac_clr_n;

  -- the signals for the DAC:
  arduino_io( 4) <= adc1_cnv;
  arduino_io( 5) <= adc1_sck;
  arduino_io(6) <= adc1_sdi;
  adc1_sdo <= arduino_io(7);
  
  -- the signals for the DAC:
  arduino_io( 8) <= adc2_cnv;
  arduino_io( 9) <= adc2_sck;
  arduino_io(10) <= adc2_sdi;
  adc2_sdo <= arduino_io(11);
  
  
end arch;
