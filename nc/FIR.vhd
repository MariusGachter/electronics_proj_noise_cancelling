library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- we need floating point math during compilation only
use IEEE.math_real.all;

-- This is a simple fully parameterized FIR filter 
--
-- Two architectures:
-- Pipeline: Up to ?? MHz on MAX10
-- FSM (much smaller, good for lower sampling rates)
--
-- Yves Acremann, 04.04.2019
-- Robin Oswald, 02.04.2019
--

entity FIR is
generic(
  numOfBitsInput    : integer := 16;
  -- make sure this is not larger than what is calculated internally!  
  numOfBitsOutput   : integer := 16;
  numOfBitsInternal : integer := 18;
  numOfStages       : integer;
  
  -- the coeffs; make sure they are ]-1, 1[
  coeffs : real_vector --(numOfStages-1 downto 0)
);

port(
  clk_i : std_logic;
  reset_i : std_logic;
  
  -- input strobe for the input sampling rate
  tick_i   : in  std_logic;
  signal_i : in  signed(numOfBitsInput-1 downto 0);
  signal_o : out signed(numOfBitsOutput-1 downto 0)
);
end FIR;






-----------------------
-- THE PIPELINE --
-----------------------
architecture pipeline of FIR is
  -- implementation in the transposed form
  subtype internal_signal_t is signed(numOfBitsInternal-1 downto 0);
  type pipelineArray_t is array(numOfStages-1 downto 0) of internal_signal_t;
  
  -- the input signal:
  signal sig_in : internal_signal_t;
  
  -- the delay and sum pipeline: delay in and out
  signal sumOut : pipelineArray_t;
  signal delOut : pipelineArray_t;
  -- output signals of the multipliers
  signal multOut : pipelineArray_t;
  -- the output as a std_logic_vector, already scaled to ]-1, 1[
  signal outVector : std_logic_vector(numOfBitsInternal-1 downto 0);
  
begin

  -- flipflops
  process(clk_i, reset_i, tick_i) is
  begin
    if (reset_i = '1') then
      genReset : for k in 0 to numOfStages-1 loop
        delOut(k) <= (others => '0');
      end loop;
      outVector <= (others => '0');
    elsif rising_edge(clk_i) and (tick_i = '1') then
      -- generate the pipeline
      genPipeline: for k in 0 to numOfStages-2 loop
        delOut(k) <= sumOut(k+1);
      end loop;
      -- trick to simplify the structure: The last summand is always 0
      delOut(numOfStages-1) <= (others => '0');
      
      -- the output as a std_logic_vector (scaled to ]-1, 1[ ):
      outVector <= std_logic_vector(shift_left(sumOut(0), numOfBitsInternal - numOfBitsOutput));
    end if;
  end process;
  
  
  
  -- generate the multiplier and adder structures
  genAdderChain : for k in 0 to numOfStages-1 generate
    -- convert the floating point coefficient to a correct signed value
    constant coeff_signed : internal_signal_t := 
       to_signed(integer(
          round((coeffs(k)*(2**real(numOfBitsInternal-1))))),
       numOfBitsInternal);
  begin
    -- output of the multiplier: shifted by numOfBitsInternal!
    multOut(k) <= resize(shift_right(coeff_signed * sig_in, numOfBitsInternal-1), numOfBitsInternal);
    -- the adder
    sumOut(k) <= multOut(k) + delOut(k);
  end generate;
  
  
  
  -- the input signal:
  sig_in <= resize(signal_i, numOfBitsInternal);
  
  
  -- shift the output signal:
  signal_o <= signed(outVector(numOfBitsInternal-1 
                      downto (numOfBitsInternal-numOfBitsOutput)));
  
end pipeline;









-----------------------
-- THE STATE MACHINE --
-----------------------
architecture statemachine of FIR is
  --- Signal definitions ---
    
  -- FSM signals
  type state_t is (idle, prepare, iterate, finish);
  signal state_current, state_next : state_t;
  signal iteration_current, iteration_next: Integer range 0 to numOfStages := 0;
  
  -- internal types
  subtype internal_signal_t is signed(numOfBitsInternal-1 downto 0);
  type array_t is array(numOfStages-1 downto 0) of internal_signal_t;
  
  -- a history of previous inputs x[k]
  signal previousInputs : array_t;
  
  -- the running sum
  signal runningSum_current: internal_signal_t;
  signal runningSum_next   : internal_signal_t;
  
  -- the filter coefficients as table of signed fixed-point numbers
  signal coeff_t : array_t;

  -- the register holding the output, already scaled ]-1, 1[
  signal outputRegister : std_logic_vector(numOfBitsInternal-1 downto 0);
    
begin
  -- Convert coefficients from float to fixed point
  -- This is done at compile time and generates a LUT
  gen_coeffs: for k in 0 to numOfStages-1 generate
    constant coeff_signed : internal_signal_t := 
        to_signed(integer(round((coeffs(k)*(2**real(numOfBitsInternal-1))))), numOfBitsInternal);
  begin
    coeff_t(k) <= coeff_signed;
  end generate; 
  


  -- the FIR state machine:
  -- transition function and output function
  process(state_current, iteration_current, tick_i, runningSum_current) 
  begin
     -- default:
     state_next <= state_current;
     iteration_next <= 0;
     runningSum_next <= runningSum_current;

     -- specifics:
     case state_current is
       when idle =>
         -- Idle: Wait for work
         if tick_i = '1' then
           state_next <= prepare;
         end if;
      

       when prepare =>
         state_next <= iterate;
         -- Reset the iteration counter and the sum
         iteration_next <= 0;
         runningSum_next <= to_signed(0, numOfBitsInternal);
        

       when iterate =>
          -- Calculate the sum y[n] = b[0]x[n] + b[1]x[n-1] + ... 
          -- one term at a time
          runningSum_next <= runningSum_current + 
              resize(shift_right(coeff_t(iteration_current) 
                 * previousInputs(iteration_current), numOfBitsInternal-1), numOfBitsInternal);
          -- update the iteration counter
          iteration_next <= iteration_current + 1;
          -- and check, if we are done
          if iteration_current = numOfStages - 1 then
            state_next <= finish;
          else
            state_next <= iterate;
          end if;
    

       when finish =>
         -- jump to idle (in the registers, we also update the output register)
         state_next <= idle;

     end case;
  end process;  
  



  -- Sequential logic:
  --    state registers
  --    summing register
  --    output register
  --    the shift register for the input signal
  process(clk_i, reset_i)
  begin
    if (reset_i = '1') then
      -- reset everything
      state_current <= idle;
      iteration_current <= 0;
      outputRegister <= (others => '0');
      runningSum_current <= to_signed(0, numOfBitsInternal);
      -- we reset all the registers containing old inputs x[i] to 0
      genReset : for k in 0 to numOfStages - 1 loop
         previousInputs(k) <= to_signed(0, numOfBitsInternal);
      end loop;
      
    elsif rising_edge(clk_i) then

      -- Drive state transitions
      state_current <= state_next;
      iteration_current  <= iteration_next;
      runningSum_current <= runningSum_next;



      -- Shift the registers containing old inputs x[i] by one.
      -- In order to be compatible with the pipeline, we do that on each tick.
      if tick_i = '1' then
        genShift: for k in 0 to numOfStages-2 loop
          previousInputs(k+1) <= previousInputs(k);
        end loop;
        previousInputs(0) <= resize(signal_i, numOfBitsInternal);
      end if;

      
      
      -- output the result once calculation is finished
      -- (the output as a std_logic_vector, scaled to ]-1, 1[ ):
      if state_current = finish then
        outputRegister <= std_logic_vector(shift_left(runningSum_current, numOfBitsInternal - numOfBitsOutput));
      end if; -- result Ready


    end if; -- clk
  end process;


  -- connect the output signal to the output register
  signal_o <= signed(outputRegister(numOfBitsInternal-1 
                      downto (numOfBitsInternal-numOfBitsOutput)));
end statemachine;
