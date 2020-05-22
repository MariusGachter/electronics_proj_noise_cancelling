-- Generator : SpinalHDL v1.4.0    git head : ecb5a80b713566f417ea3ea061f9969e73770a7f
-- Date      : 22/05/2020, 14:55:00
-- Component : ApbBus

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

package pkg_enum is
  type fsm_enumDefinition is (boot,fsm_stateIdle,fsm_statePrepareRead,fsm_stateRead,fsm_statePrepareWrite,fsm_stateWrite);

  function pkg_mux (sel : std_logic;one : fsm_enumDefinition;zero : fsm_enumDefinition) return fsm_enumDefinition;
  function pkg_toStdLogicVector_defaultEncoding (value : fsm_enumDefinition) return std_logic_vector;
  function pkg_tofsm_enumDefinition_defaultEncoding (value : std_logic_vector(2 downto 0)) return fsm_enumDefinition;
end pkg_enum;

package body pkg_enum is
  function pkg_mux (sel : std_logic;one : fsm_enumDefinition;zero : fsm_enumDefinition) return fsm_enumDefinition is
  begin
    if sel = '1' then
      return one;
    else
      return zero;
    end if;
  end pkg_mux;

  function pkg_tofsm_enumDefinition_defaultEncoding (value : std_logic_vector(2 downto 0)) return fsm_enumDefinition is
  begin
    case value is
      when "000" => return boot;
      when "001" => return fsm_stateIdle;
      when "010" => return fsm_statePrepareRead;
      when "011" => return fsm_stateRead;
      when "100" => return fsm_statePrepareWrite;
      when "101" => return fsm_stateWrite;
      when others => return boot;
    end case;
  end;
  function pkg_toStdLogicVector_defaultEncoding (value : fsm_enumDefinition) return std_logic_vector is
  begin
    case value is
      when boot => return "000";
      when fsm_stateIdle => return "001";
      when fsm_statePrepareRead => return "010";
      when fsm_stateRead => return "011";
      when fsm_statePrepareWrite => return "100";
      when fsm_stateWrite => return "101";
      when others => return "000";
    end case;
  end;
end pkg_enum;


library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package pkg_scala2hdl is
  function pkg_extract (that : std_logic_vector; bitId : integer) return std_logic;
  function pkg_extract (that : std_logic_vector; base : unsigned; size : integer) return std_logic_vector;
  function pkg_cat (a : std_logic_vector; b : std_logic_vector) return std_logic_vector;
  function pkg_not (value : std_logic_vector) return std_logic_vector;
  function pkg_extract (that : unsigned; bitId : integer) return std_logic;
  function pkg_extract (that : unsigned; base : unsigned; size : integer) return unsigned;
  function pkg_cat (a : unsigned; b : unsigned) return unsigned;
  function pkg_not (value : unsigned) return unsigned;
  function pkg_extract (that : signed; bitId : integer) return std_logic;
  function pkg_extract (that : signed; base : unsigned; size : integer) return signed;
  function pkg_cat (a : signed; b : signed) return signed;
  function pkg_not (value : signed) return signed;


  function pkg_mux (sel : std_logic;one : std_logic;zero : std_logic) return std_logic;
  function pkg_mux (sel : std_logic;one : std_logic_vector;zero : std_logic_vector) return std_logic_vector;
  function pkg_mux (sel : std_logic;one : unsigned;zero : unsigned) return unsigned;
  function pkg_mux (sel : std_logic;one : signed;zero : signed) return signed;


  function pkg_toStdLogic (value : boolean) return std_logic;
  function pkg_toStdLogicVector (value : std_logic) return std_logic_vector;
  function pkg_toUnsigned(value : std_logic) return unsigned;
  function pkg_toSigned (value : std_logic) return signed;
  function pkg_stdLogicVector (lit : std_logic_vector) return std_logic_vector;
  function pkg_unsigned (lit : unsigned) return unsigned;
  function pkg_signed (lit : signed) return signed;

  function pkg_resize (that : std_logic_vector; width : integer) return std_logic_vector;
  function pkg_resize (that : unsigned; width : integer) return unsigned;
  function pkg_resize (that : signed; width : integer) return signed;

  function pkg_extract (that : std_logic_vector; high : integer; low : integer) return std_logic_vector;
  function pkg_extract (that : unsigned; high : integer; low : integer) return unsigned;
  function pkg_extract (that : signed; high : integer; low : integer) return signed;

  function pkg_shiftRight (that : std_logic_vector; size : natural) return std_logic_vector;
  function pkg_shiftRight (that : std_logic_vector; size : unsigned) return std_logic_vector;
  function pkg_shiftLeft (that : std_logic_vector; size : natural) return std_logic_vector;
  function pkg_shiftLeft (that : std_logic_vector; size : unsigned) return std_logic_vector;

  function pkg_shiftRight (that : unsigned; size : natural) return unsigned;
  function pkg_shiftRight (that : unsigned; size : unsigned) return unsigned;
  function pkg_shiftLeft (that : unsigned; size : natural) return unsigned;
  function pkg_shiftLeft (that : unsigned; size : unsigned) return unsigned;

  function pkg_shiftRight (that : signed; size : natural) return signed;
  function pkg_shiftRight (that : signed; size : unsigned) return signed;
  function pkg_shiftLeft (that : signed; size : natural) return signed;
  function pkg_shiftLeft (that : signed; size : unsigned; w : integer) return signed;

  function pkg_rotateLeft (that : std_logic_vector; size : unsigned) return std_logic_vector;
end  pkg_scala2hdl;

package body pkg_scala2hdl is
  function pkg_extract (that : std_logic_vector; bitId : integer) return std_logic is
  begin
    return that(bitId);
  end pkg_extract;


  function pkg_extract (that : std_logic_vector; base : unsigned; size : integer) return std_logic_vector is
   constant elementCount : integer := (that'length-size)+1;
   type tableType is array (0 to elementCount-1) of std_logic_vector(size-1 downto 0);
   variable table : tableType;
  begin
    for i in 0 to elementCount-1 loop
      table(i) := that(i + size - 1 downto i);
    end loop;
    return table(to_integer(base));
  end pkg_extract;


  function pkg_cat (a : std_logic_vector; b : std_logic_vector) return std_logic_vector is
    variable cat : std_logic_vector(a'length + b'length-1 downto 0);
  begin
    cat := a & b;
    return cat;
  end pkg_cat;


  function pkg_not (value : std_logic_vector) return std_logic_vector is
    variable ret : std_logic_vector(value'high downto 0);
  begin
    ret := not value;
    return ret;
  end pkg_not;


  function pkg_extract (that : unsigned; bitId : integer) return std_logic is
  begin
    return that(bitId);
  end pkg_extract;


  function pkg_extract (that : unsigned; base : unsigned; size : integer) return unsigned is
   constant elementCount : integer := (that'length-size)+1;
   type tableType is array (0 to elementCount-1) of unsigned(size-1 downto 0);
   variable table : tableType;
  begin
    for i in 0 to elementCount-1 loop
      table(i) := that(i + size - 1 downto i);
    end loop;
    return table(to_integer(base));
  end pkg_extract;


  function pkg_cat (a : unsigned; b : unsigned) return unsigned is
    variable cat : unsigned(a'length + b'length-1 downto 0);
  begin
    cat := a & b;
    return cat;
  end pkg_cat;


  function pkg_not (value : unsigned) return unsigned is
    variable ret : unsigned(value'high downto 0);
  begin
    ret := not value;
    return ret;
  end pkg_not;


  function pkg_extract (that : signed; bitId : integer) return std_logic is
  begin
    return that(bitId);
  end pkg_extract;


  function pkg_extract (that : signed; base : unsigned; size : integer) return signed is
   constant elementCount : integer := (that'length-size)+1;
   type tableType is array (0 to elementCount-1) of signed(size-1 downto 0);
   variable table : tableType;
  begin
    for i in 0 to elementCount-1 loop
      table(i) := that(i + size - 1 downto i);
    end loop;
    return table(to_integer(base));
  end pkg_extract;


  function pkg_cat (a : signed; b : signed) return signed is
    variable cat : signed(a'length + b'length-1 downto 0);
  begin
    cat := a & b;
    return cat;
  end pkg_cat;


  function pkg_not (value : signed) return signed is
    variable ret : signed(value'high downto 0);
  begin
    ret := not value;
    return ret;
  end pkg_not;



  -- unsigned shifts
  function pkg_shiftRight (that : unsigned; size : natural) return unsigned is
  begin
    if size >= that'length then
      return "";
    else
      return shift_right(that,size)(that'high-size downto 0);
    end if;
  end pkg_shiftRight;

  function pkg_shiftRight (that : unsigned; size : unsigned) return unsigned is
  begin
    return shift_right(that,to_integer(size));
  end pkg_shiftRight;

  function pkg_shiftLeft (that : unsigned; size : natural) return unsigned is
  begin
    return shift_left(resize(that,that'length + size),size);
  end pkg_shiftLeft;

  function pkg_shiftLeft (that : unsigned; size : unsigned) return unsigned is
  begin
    return shift_left(resize(that,that'length + 2**size'length - 1),to_integer(size));
  end pkg_shiftLeft;


  -- std_logic_vector shifts
  function pkg_shiftRight (that : std_logic_vector; size : natural) return std_logic_vector is
  begin
    return std_logic_vector(pkg_shiftRight(unsigned(that),size));
  end pkg_shiftRight;

  function pkg_shiftRight (that : std_logic_vector; size : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(pkg_shiftRight(unsigned(that),size));
  end pkg_shiftRight;

  function pkg_shiftLeft (that : std_logic_vector; size : natural) return std_logic_vector is
  begin
    return std_logic_vector(pkg_shiftLeft(unsigned(that),size));
  end pkg_shiftLeft;

  function pkg_shiftLeft (that : std_logic_vector; size : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(pkg_shiftLeft(unsigned(that),size));
  end pkg_shiftLeft;

  -- signed shifts
  function pkg_shiftRight (that : signed; size : natural) return signed is
  begin
    return signed(pkg_shiftRight(unsigned(that),size));
  end pkg_shiftRight;

  function pkg_shiftRight (that : signed; size : unsigned) return signed is
  begin
    return shift_right(that,to_integer(size));
  end pkg_shiftRight;

  function pkg_shiftLeft (that : signed; size : natural) return signed is
  begin
    return signed(pkg_shiftLeft(unsigned(that),size));
  end pkg_shiftLeft;

  function pkg_shiftLeft (that : signed; size : unsigned; w : integer) return signed is
  begin
    return shift_left(resize(that,w),to_integer(size));
  end pkg_shiftLeft;

  function pkg_rotateLeft (that : std_logic_vector; size : unsigned) return std_logic_vector is
  begin
    return std_logic_vector(rotate_left(unsigned(that),to_integer(size)));
  end pkg_rotateLeft;

  function pkg_extract (that : std_logic_vector; high : integer; low : integer) return std_logic_vector is
    variable temp : std_logic_vector(high-low downto 0);
  begin
    temp := that(high downto low);
    return temp;
  end pkg_extract;

  function pkg_extract (that : unsigned; high : integer; low : integer) return unsigned is
    variable temp : unsigned(high-low downto 0);
  begin
    temp := that(high downto low);
    return temp;
  end pkg_extract;

  function pkg_extract (that : signed; high : integer; low : integer) return signed is
    variable temp : signed(high-low downto 0);
  begin
    temp := that(high downto low);
    return temp;
  end pkg_extract;

  function pkg_mux (sel : std_logic;one : std_logic;zero : std_logic) return std_logic is
  begin
    if sel = '1' then
      return one;
    else
      return zero;
    end if;
  end pkg_mux;

  function pkg_mux (sel : std_logic;one : std_logic_vector;zero : std_logic_vector) return std_logic_vector is
    variable ret : std_logic_vector(zero'range);  begin
    if sel = '1' then
      ret := one;
    else
      ret := zero;
    end if;
    return ret;  end pkg_mux;

  function pkg_mux (sel : std_logic;one : unsigned;zero : unsigned) return unsigned is
    variable ret : unsigned(zero'range);  begin
    if sel = '1' then
      ret := one;
    else
      ret := zero;
    end if;
    return ret;  end pkg_mux;

  function pkg_mux (sel : std_logic;one : signed;zero : signed) return signed is
    variable ret : signed(zero'range);  begin
    if sel = '1' then
      ret := one;
    else
      ret := zero;
    end if;
    return ret;  end pkg_mux;

  function pkg_toStdLogic (value : boolean) return std_logic is
  begin
    if value = true then
      return '1';
    else
      return '0';
    end if;
  end pkg_toStdLogic;

  function pkg_toStdLogicVector (value : std_logic) return std_logic_vector is
    variable ret : std_logic_vector(0 downto 0);
  begin
    ret(0) := value;
    return ret;
  end pkg_toStdLogicVector;

  function pkg_toUnsigned (value : std_logic) return unsigned is
    variable ret : unsigned(0 downto 0);
  begin
    ret(0) := value;
    return ret;
  end pkg_toUnsigned;

  function pkg_toSigned (value : std_logic) return signed is
    variable ret : signed(0 downto 0);
  begin
    ret(0) := value;
    return ret;
  end pkg_toSigned;

  function pkg_stdLogicVector (lit : std_logic_vector) return std_logic_vector is
    variable ret : std_logic_vector(lit'length-1 downto 0);
  begin
    ret := lit;    return ret;
  end pkg_stdLogicVector;

  function pkg_unsigned (lit : unsigned) return unsigned is
    variable ret : unsigned(lit'length-1 downto 0);
  begin
    ret := lit;    return ret;
  end pkg_unsigned;

  function pkg_signed (lit : signed) return signed is
    variable ret : signed(lit'length-1 downto 0);
  begin
    ret := lit;    return ret;
  end pkg_signed;

  function pkg_resize (that : std_logic_vector; width : integer) return std_logic_vector is
  begin
    return std_logic_vector(resize(unsigned(that),width));
  end pkg_resize;


  function pkg_resize (that : unsigned; width : integer) return unsigned is
	  variable ret : unsigned(width-1 downto 0);
  begin
    if that'length = 0 then
       ret := (others => '0');
    else
       ret := resize(that,width);
    end if;
		return ret;
  end pkg_resize;
 
  function pkg_resize (that : signed; width : integer) return signed is
	  variable ret : signed(width-1 downto 0);
  begin
    if that'length = 0 then
       ret := (others => '0');
    elsif that'length >= width then
       ret := that(width-1 downto 0);
    else
       ret := resize(that,width);
    end if;
		return ret;
  end pkg_resize;
 end pkg_scala2hdl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_scala2hdl.all;
use work.all;
use work.pkg_enum.all;


entity BufferCC is
  port(
    io_dataIn : in std_logic;
    io_dataOut : out std_logic;
    clk : in std_logic;
    reset : in std_logic
  );
end BufferCC;

architecture arch of BufferCC is

  signal buffers_0 : std_logic;
  signal buffers_1 : std_logic;
begin
  io_dataOut <= buffers_1;
  process(clk)
  begin
    if rising_edge(clk) then
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end if;
  end process;

end arch;


--BufferCC_1 remplaced by BufferCC


--BufferCC_2 remplaced by BufferCC

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_scala2hdl.all;
use work.all;
use work.pkg_enum.all;


entity SpiReceiver is
  port(
    io_spi_sclk : in std_logic;
    io_spi_mosi : in std_logic;
    io_spi_miso_write : out std_logic;
    io_spi_miso_writeEnable : out std_logic;
    io_spi_ss : in std_logic;
    io_address : out unsigned(14 downto 0);
    io_write : out std_logic;
    io_addrReady : out std_logic;
    io_dataToSend : in std_logic_vector(31 downto 0);
    io_dataReceived : out std_logic_vector(31 downto 0);
    io_dataReady : out std_logic;
    clk : in std_logic;
    reset : in std_logic
  );
end SpiReceiver;

architecture arch of SpiReceiver is
  signal io_spi_sclk_buffercc_io_dataOut : std_logic;
  signal io_spi_ss_buffercc_io_dataOut : std_logic;
  signal io_spi_mosi_buffercc_io_dataOut : std_logic;
  signal zz_1 : std_logic;
  signal zz_2 : std_logic;
  signal zz_3 : std_logic;

  signal spi_sclk : std_logic;
  signal spi_mosi : std_logic;
  signal spi_miso_write : std_logic;
  signal spi_miso_writeEnable : std_logic;
  signal spi_ss : std_logic;
  signal addressBitCounter_willIncrement : std_logic;
  signal addressBitCounter_willClear : std_logic;
  signal addressBitCounter_valueNext : unsigned(4 downto 0);
  signal addressBitCounter_value : unsigned(4 downto 0);
  signal addressBitCounter_willOverflowIfInc : std_logic;
  signal addressBitCounter_willOverflow : std_logic;
  signal addressBuffer : std_logic_vector(15 downto 0);
  signal dataBitCounter_willIncrement : std_logic;
  signal dataBitCounter_willClear : std_logic;
  signal dataBitCounter_valueNext : unsigned(5 downto 0);
  signal dataBitCounter_value : unsigned(5 downto 0);
  signal dataBitCounter_willOverflowIfInc : std_logic;
  signal dataBitCounter_willOverflow : std_logic;
  signal dataReceiveBuffer : std_logic_vector(31 downto 0);
  signal spi_ss_regNext : std_logic;
  signal spi_sclk_regNext : std_logic;
  signal spi_sclk_regNext_1 : std_logic;
  signal spi_sclk_regNext_2 : std_logic;
  signal spi_sclk_regNext_3 : std_logic;
begin
  zz_1 <= ((not spi_ss) and spi_ss_regNext);
  zz_2 <= pkg_toStdLogic(addressBitCounter_value < pkg_unsigned("10000"));
  zz_3 <= pkg_toStdLogic(dataBitCounter_value < pkg_unsigned("100000"));
  io_spi_sclk_buffercc : entity work.BufferCC
    port map ( 
      io_dataIn => io_spi_sclk,
      io_dataOut => io_spi_sclk_buffercc_io_dataOut,
      clk => clk,
      reset => reset 
    );
  io_spi_ss_buffercc : entity work.BufferCC
    port map ( 
      io_dataIn => io_spi_ss,
      io_dataOut => io_spi_ss_buffercc_io_dataOut,
      clk => clk,
      reset => reset 
    );
  io_spi_mosi_buffercc : entity work.BufferCC
    port map ( 
      io_dataIn => io_spi_mosi,
      io_dataOut => io_spi_mosi_buffercc_io_dataOut,
      clk => clk,
      reset => reset 
    );
  spi_sclk <= io_spi_sclk_buffercc_io_dataOut;
  spi_ss <= io_spi_ss_buffercc_io_dataOut;
  spi_mosi <= io_spi_mosi_buffercc_io_dataOut;
  io_spi_miso_write <= spi_miso_write;
  io_spi_miso_writeEnable <= spi_miso_writeEnable;
  process(zz_1,zz_2,spi_sclk,spi_sclk_regNext_1)
  begin
    addressBitCounter_willIncrement <= pkg_toStdLogic(false);
    if zz_1 = '0' then
      if zz_2 = '1' then
        if ((not spi_sclk) and spi_sclk_regNext_1) = '1' then
          addressBitCounter_willIncrement <= pkg_toStdLogic(true);
        end if;
      end if;
    end if;
  end process;

  process(zz_1)
  begin
    addressBitCounter_willClear <= pkg_toStdLogic(false);
    if zz_1 = '1' then
      addressBitCounter_willClear <= pkg_toStdLogic(true);
    end if;
  end process;

  addressBitCounter_willOverflowIfInc <= pkg_toStdLogic(addressBitCounter_value = pkg_unsigned("10000"));
  addressBitCounter_willOverflow <= (addressBitCounter_willOverflowIfInc and addressBitCounter_willIncrement);
  process(addressBitCounter_willOverflow,addressBitCounter_value,addressBitCounter_willIncrement,addressBitCounter_willClear)
  begin
    if addressBitCounter_willOverflow = '1' then
      addressBitCounter_valueNext <= pkg_unsigned("00000");
    else
      addressBitCounter_valueNext <= (addressBitCounter_value + pkg_resize(unsigned(pkg_toStdLogicVector(addressBitCounter_willIncrement)),5));
    end if;
    if addressBitCounter_willClear = '1' then
      addressBitCounter_valueNext <= pkg_unsigned("00000");
    end if;
  end process;

  process(zz_1,zz_2,zz_3,spi_sclk,spi_sclk_regNext_3)
  begin
    dataBitCounter_willIncrement <= pkg_toStdLogic(false);
    if zz_1 = '0' then
      if zz_2 = '0' then
        if zz_3 = '1' then
          if ((not spi_sclk) and spi_sclk_regNext_3) = '1' then
            dataBitCounter_willIncrement <= pkg_toStdLogic(true);
          end if;
        end if;
      end if;
    end if;
  end process;

  process(zz_1)
  begin
    dataBitCounter_willClear <= pkg_toStdLogic(false);
    if zz_1 = '1' then
      dataBitCounter_willClear <= pkg_toStdLogic(true);
    end if;
  end process;

  dataBitCounter_willOverflowIfInc <= pkg_toStdLogic(dataBitCounter_value = pkg_unsigned("100000"));
  dataBitCounter_willOverflow <= (dataBitCounter_willOverflowIfInc and dataBitCounter_willIncrement);
  process(dataBitCounter_willOverflow,dataBitCounter_value,dataBitCounter_willIncrement,dataBitCounter_willClear)
  begin
    if dataBitCounter_willOverflow = '1' then
      dataBitCounter_valueNext <= pkg_unsigned("000000");
    else
      dataBitCounter_valueNext <= (dataBitCounter_value + pkg_resize(unsigned(pkg_toStdLogicVector(dataBitCounter_willIncrement)),6));
    end if;
    if dataBitCounter_willClear = '1' then
      dataBitCounter_valueNext <= pkg_unsigned("000000");
    end if;
  end process;

  io_addrReady <= pkg_toStdLogic(addressBitCounter_value = pkg_unsigned("10000"));
  io_address <= unsigned(pkg_extract(addressBuffer,14,0));
  io_write <= pkg_extract(addressBuffer,15);
  spi_miso_write <= pkg_extract(io_dataToSend,to_integer((pkg_unsigned("11111") - pkg_resize(dataBitCounter_value,5))));
  spi_miso_writeEnable <= pkg_toStdLogic(true);
  io_dataReceived <= dataReceiveBuffer;
  io_dataReady <= pkg_toStdLogic(dataBitCounter_value = pkg_unsigned("100000"));
  process(clk, reset)
  begin
    if reset = '1' then
      addressBitCounter_value <= pkg_unsigned("00000");
      dataBitCounter_value <= pkg_unsigned("000000");
    elsif rising_edge(clk) then
      addressBitCounter_value <= addressBitCounter_valueNext;
      dataBitCounter_value <= dataBitCounter_valueNext;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      spi_ss_regNext <= spi_ss;
      if zz_1 = '1' then
        addressBuffer <= pkg_stdLogicVector("0000000000000000");
        dataReceiveBuffer <= pkg_stdLogicVector("00000000000000000000000000000000");
      else
        if zz_2 = '1' then
          if (spi_sclk and (not spi_sclk_regNext)) = '1' then
            addressBuffer <= pkg_resize(pkg_cat(addressBuffer,pkg_toStdLogicVector(spi_mosi)),16);
          end if;
        else
          if zz_3 = '1' then
            if (spi_sclk and (not spi_sclk_regNext_2)) = '1' then
              dataReceiveBuffer <= pkg_resize(pkg_cat(dataReceiveBuffer,pkg_toStdLogicVector(spi_mosi)),32);
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      spi_sclk_regNext <= spi_sclk;
      spi_sclk_regNext_1 <= spi_sclk;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      spi_sclk_regNext_2 <= spi_sclk;
      spi_sclk_regNext_3 <= spi_sclk;
    end if;
  end process;

end arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_scala2hdl.all;
use work.all;
use work.pkg_enum.all;


entity SpiApbDriver is
  port(
    io_spi_sclk : in std_logic;
    io_spi_mosi : in std_logic;
    io_spi_miso_write : out std_logic;
    io_spi_miso_writeEnable : out std_logic;
    io_spi_ss : in std_logic;
    io_apb_PADDR : out unsigned(31 downto 0);
    io_apb_PSEL : out std_logic_vector(0 downto 0);
    io_apb_PENABLE : out std_logic;
    io_apb_PREADY : in std_logic;
    io_apb_PWRITE : out std_logic;
    io_apb_PWDATA : out std_logic_vector(31 downto 0);
    io_apb_PRDATA : in std_logic_vector(31 downto 0);
    clk : in std_logic;
    reset : in std_logic
  );
end SpiApbDriver;

architecture arch of SpiApbDriver is
  signal spiReceiver_1_io_spi_miso_write : std_logic;
  signal spiReceiver_1_io_spi_miso_writeEnable : std_logic;
  signal spiReceiver_1_io_address : unsigned(14 downto 0);
  signal spiReceiver_1_io_write : std_logic;
  signal spiReceiver_1_io_addrReady : std_logic;
  signal spiReceiver_1_io_dataReceived : std_logic_vector(31 downto 0);
  signal spiReceiver_1_io_dataReady : std_logic;

  signal spiDataSendReg : std_logic_vector(31 downto 0);
  signal fsm_wantExit : std_logic;
  signal fsm_stateReg : fsm_enumDefinition;
  signal fsm_stateNext : fsm_enumDefinition;
  signal zz_1 : std_logic;
  signal zz_1_regNext : std_logic;
  signal zz_2 : std_logic;
  signal zz_2_regNext : std_logic;
begin
  spiReceiver_1 : entity work.SpiReceiver
    port map ( 
      io_spi_sclk => io_spi_sclk,
      io_spi_mosi => io_spi_mosi,
      io_spi_miso_write => spiReceiver_1_io_spi_miso_write,
      io_spi_miso_writeEnable => spiReceiver_1_io_spi_miso_writeEnable,
      io_spi_ss => io_spi_ss,
      io_address => spiReceiver_1_io_address,
      io_write => spiReceiver_1_io_write,
      io_addrReady => spiReceiver_1_io_addrReady,
      io_dataToSend => spiDataSendReg,
      io_dataReceived => spiReceiver_1_io_dataReceived,
      io_dataReady => spiReceiver_1_io_dataReady,
      clk => clk,
      reset => reset 
    );
  io_spi_miso_write <= spiReceiver_1_io_spi_miso_write;
  io_spi_miso_writeEnable <= spiReceiver_1_io_spi_miso_writeEnable;
  fsm_wantExit <= pkg_toStdLogic(false);
  process(fsm_stateReg)
  begin
    io_apb_PSEL(0) <= pkg_toStdLogic(false);
    case fsm_stateReg is
      when pkg_enum.fsm_stateIdle =>
      when pkg_enum.fsm_statePrepareRead =>
        io_apb_PSEL(0) <= pkg_toStdLogic(true);
      when pkg_enum.fsm_stateRead =>
        io_apb_PSEL(0) <= pkg_toStdLogic(true);
      when pkg_enum.fsm_statePrepareWrite =>
        io_apb_PSEL(0) <= pkg_toStdLogic(true);
      when pkg_enum.fsm_stateWrite =>
        io_apb_PSEL(0) <= pkg_toStdLogic(true);
      when others =>
    end case;
  end process;

  process(fsm_stateReg)
  begin
    io_apb_PENABLE <= pkg_toStdLogic(false);
    case fsm_stateReg is
      when pkg_enum.fsm_stateIdle =>
      when pkg_enum.fsm_statePrepareRead =>
        io_apb_PENABLE <= pkg_toStdLogic(true);
      when pkg_enum.fsm_stateRead =>
        io_apb_PENABLE <= pkg_toStdLogic(true);
      when pkg_enum.fsm_statePrepareWrite =>
        io_apb_PENABLE <= pkg_toStdLogic(true);
      when pkg_enum.fsm_stateWrite =>
        io_apb_PENABLE <= pkg_toStdLogic(true);
      when others =>
    end case;
  end process;

  process(fsm_stateReg)
  begin
    io_apb_PWRITE <= pkg_toStdLogic(false);
    case fsm_stateReg is
      when pkg_enum.fsm_stateIdle =>
      when pkg_enum.fsm_statePrepareRead =>
      when pkg_enum.fsm_stateRead =>
      when pkg_enum.fsm_statePrepareWrite =>
        io_apb_PWRITE <= pkg_toStdLogic(true);
      when pkg_enum.fsm_stateWrite =>
        io_apb_PWRITE <= pkg_toStdLogic(true);
      when others =>
    end case;
  end process;

  io_apb_PADDR <= pkg_resize(spiReceiver_1_io_address,32);
  io_apb_PWDATA <= spiReceiver_1_io_dataReceived;
  process(fsm_stateReg,zz_1,zz_1_regNext,zz_2,zz_2_regNext,io_apb_PREADY)
  begin
    fsm_stateNext <= fsm_stateReg;
    case fsm_stateReg is
      when pkg_enum.fsm_stateIdle =>
        if (zz_1 and (not zz_1_regNext)) = '1' then
          fsm_stateNext <= pkg_enum.fsm_statePrepareRead;
        end if;
        if (zz_2 and (not zz_2_regNext)) = '1' then
          fsm_stateNext <= pkg_enum.fsm_statePrepareWrite;
        end if;
      when pkg_enum.fsm_statePrepareRead =>
        if io_apb_PREADY = '1' then
          fsm_stateNext <= pkg_enum.fsm_stateRead;
        end if;
      when pkg_enum.fsm_stateRead =>
        fsm_stateNext <= pkg_enum.fsm_stateIdle;
      when pkg_enum.fsm_statePrepareWrite =>
        fsm_stateNext <= pkg_enum.fsm_stateWrite;
      when pkg_enum.fsm_stateWrite =>
        if io_apb_PREADY = '1' then
          fsm_stateNext <= pkg_enum.fsm_stateIdle;
        end if;
      when others =>
        fsm_stateNext <= pkg_enum.fsm_stateIdle;
    end case;
  end process;

  zz_1 <= (spiReceiver_1_io_addrReady and (not spiReceiver_1_io_write));
  zz_2 <= (spiReceiver_1_io_dataReady and spiReceiver_1_io_write);
  process(clk, reset)
  begin
    if reset = '1' then
      spiDataSendReg <= pkg_stdLogicVector("00000000000000000000000000000000");
      fsm_stateReg <= pkg_enum.boot;
    elsif rising_edge(clk) then
      fsm_stateReg <= fsm_stateNext;
      case fsm_stateReg is
        when pkg_enum.fsm_stateIdle =>
        when pkg_enum.fsm_statePrepareRead =>
        when pkg_enum.fsm_stateRead =>
          spiDataSendReg <= io_apb_PRDATA;
        when pkg_enum.fsm_statePrepareWrite =>
        when pkg_enum.fsm_stateWrite =>
        when others =>
      end case;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      zz_1_regNext <= zz_1;
      zz_2_regNext <= zz_2;
    end if;
  end process;

end arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_scala2hdl.all;
use work.all;
use work.pkg_enum.all;


entity ApbBus is
  port(
    io_spi_sclk : in std_logic;
    io_spi_mosi : in std_logic;
    io_spi_miso_write : out std_logic;
    io_spi_miso_writeEnable : out std_logic;
    io_spi_ss : in std_logic;
    io_inGain : in std_logic_vector(31 downto 0);
    clk : in std_logic;
    reset : in std_logic
  );
end ApbBus;

architecture arch of ApbBus is
  signal zz_1 : std_logic;
  signal zz_2 : std_logic_vector(31 downto 0);
  signal busMaster_io_spi_miso_write : std_logic;
  signal busMaster_io_spi_miso_writeEnable : std_logic;
  signal busMaster_io_apb_PADDR : unsigned(31 downto 0);
  signal busMaster_io_apb_PSEL : std_logic_vector(0 downto 0);
  signal busMaster_io_apb_PENABLE : std_logic;
  signal busMaster_io_apb_PWRITE : std_logic;
  signal busMaster_io_apb_PWDATA : std_logic_vector(31 downto 0);

  signal busCtrl_askWrite : std_logic;
  signal busCtrl_askRead : std_logic;
  signal busCtrl_doWrite : std_logic;
  signal busCtrl_doRead : std_logic;
begin
  busMaster : entity work.SpiApbDriver
    port map ( 
      io_spi_sclk => io_spi_sclk,
      io_spi_mosi => io_spi_mosi,
      io_spi_miso_write => busMaster_io_spi_miso_write,
      io_spi_miso_writeEnable => busMaster_io_spi_miso_writeEnable,
      io_spi_ss => io_spi_ss,
      io_apb_PADDR => busMaster_io_apb_PADDR,
      io_apb_PSEL => busMaster_io_apb_PSEL,
      io_apb_PENABLE => busMaster_io_apb_PENABLE,
      io_apb_PREADY => zz_1,
      io_apb_PWRITE => busMaster_io_apb_PWRITE,
      io_apb_PWDATA => busMaster_io_apb_PWDATA,
      io_apb_PRDATA => zz_2,
      clk => clk,
      reset => reset 
    );
  io_spi_miso_write <= busMaster_io_spi_miso_write;
  io_spi_miso_writeEnable <= busMaster_io_spi_miso_writeEnable;
  zz_1 <= pkg_toStdLogic(true);
  process(busMaster_io_apb_PADDR,io_inGain)
  begin
    zz_2 <= pkg_stdLogicVector("00000000000000000000000000000000");
    case busMaster_io_apb_PADDR is
      when "00000000000000000000000001100100" =>
        zz_2(31 downto 0) <= io_inGain;
      when others =>
    end case;
  end process;

  busCtrl_askWrite <= ((pkg_extract(busMaster_io_apb_PSEL,0) and busMaster_io_apb_PENABLE) and busMaster_io_apb_PWRITE);
  busCtrl_askRead <= ((pkg_extract(busMaster_io_apb_PSEL,0) and busMaster_io_apb_PENABLE) and (not busMaster_io_apb_PWRITE));
  busCtrl_doWrite <= (((pkg_extract(busMaster_io_apb_PSEL,0) and busMaster_io_apb_PENABLE) and zz_1) and busMaster_io_apb_PWRITE);
  busCtrl_doRead <= (((pkg_extract(busMaster_io_apb_PSEL,0) and busMaster_io_apb_PENABLE) and zz_1) and (not busMaster_io_apb_PWRITE));
end arch;

