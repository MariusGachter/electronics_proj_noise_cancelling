import spinal.core._
import spinal.lib._
import spinal.lib.com.spi._
import spinal.lib.bus.amba3.apb._
import spinal.lib.fsm._

/**
 * author: Yves Acremann
 */

/**
 * SPI slave part to receive the address as well as the
 * read / write command bit (the last bit sent by the master).
 * After receiving these bits, the reception is stopped.
 **/
class SpiReceiver extends Component {
	val io = new Bundle{
		val spi = master(SpiSlave())         // the SPI port
		val address      = out UInt(15 bits) // the address (reveiced)
		val write        = out Bool          // the write bit (received)
		val addrReady    = out Bool          // '1' if the address has been received
		val dataToSend   = in  Bits(32 bits) // the data to be sent to the SPI master
		val dataReceived = out Bits(32 bits) // the data recived from the SPI master
		val dataReady    = out Bool          // true as soon as the data is ready
	}
	
	// re-synchronize the SPI data signals to the internal clock
	val spi = io.spi.slaveResync()
	
	// the counters and registers for the address and data
	val addressBitCounter = Counter(16+1)
	val addressBuffer = Reg(Bits(16 bits))
	
	// the counter and register for the received data
	val dataBitCounter = Counter(32+1)
	val dataReceiveBuffer = Reg(Bits(32 bits))

	
	
	
	// Reset everything on a falling slave select
	when(spi.ss.fall){
		addressBitCounter.clear()
		addressBuffer.clearAll
		dataBitCounter.clear()
		dataReceiveBuffer.clearAll
	} otherwise{
		// First: Receive the address:
		when (addressBitCounter < 16){
            // Register the data on rising edges of the serial clock
	        when(spi.sclk.rise){addressBuffer := (addressBuffer ## spi.mosi).resized}
            // Update the counter on falling edges of the serial clock
		    when(spi.sclk.fall){addressBitCounter.increment()}
		} otherwise{
		    // If the address is done: receive (and send) the data
		    when(dataBitCounter < 32){
			when (spi.sclk.rise){dataReceiveBuffer := (dataReceiveBuffer ## spi.mosi).resized}
			when (spi.sclk.fall){dataBitCounter.increment()}
		    } 
		}
	}
	// connect the input / output: address
	io.addrReady   := (addressBitCounter === 16)
	io.address     := addressBuffer(14 downto 0).asUInt
	// the signal for indicating a write access
	io.write       := addressBuffer(15)
	
	// the MISO: Start with the lowest bit using the dataBitCounter
	spi.miso.write := io.dataToSend.asBits(31-dataBitCounter.resize(5))
	spi.miso.writeEnable := True
	
	// the data received is given to the user
	io.dataReceived := dataReceiveBuffer
	io.dataReady    := (dataBitCounter === 32)
}



/**
 * This is the main class: It connects the SPI interface (slave)
 * to the APB3 bus as a master.
 **/
class SpiApbDriver extends Component {
	
	// the bus specs (the address bus width needs to be checked...)
	val apbConfig = Apb3Config(
      addressWidth  = 32,
      dataWidth     = 32,
      selWidth      = 1,
      useSlaveError = false)
      
    // inputs and outputs
	val io = new Bundle{
		val spi = master(SpiSlave())         // the SPI port
		val apb = master(Apb3(apbConfig))	 // the APB bus
	}
	
	
	val spiReceiver = new SpiReceiver
	spiReceiver.io.spi <> io.spi
	
	// register storing the read value from the bus (needed by the
	// spiReceiver)
	val spiDataSendReg = Reg(Bits(32 bits)) init(0)
	
	// state machine driving the APB3 bus signals
	val fsm = new StateMachine{
		// state declaration:
		val stateIdle 		= new State with EntryPoint
		val statePrepareRead 	= new State
		val stateRead 		= new State
		val statePrepareWrite 	= new State
		val stateWrite 		= new State
		
		// the defaults: all bus control signals are false
		io.apb.PSEL(0) := False
		io.apb.PENABLE := False
		io.apb.PWRITE  := False
		
		// wait for either receiving an address and a read command
		// or receiving a write command and receiving the data
		stateIdle.whenIsActive{
			when((spiReceiver.io.addrReady & !spiReceiver.io.write).rise){
				goto(statePrepareRead)
			}
			when((spiReceiver.io.dataReady & spiReceiver.io.write).rise){
				goto(statePrepareWrite)
			}
		}
		
		// Prepare for reading
		// Wait for the data to be ready from the bus and go to read
		statePrepareRead.whenIsActive{
			io.apb.PSEL(0) := True
			io.apb.PENABLE := True
			//io.apb.PWRITE  := False
			when(io.apb.PREADY){
				goto(stateRead)
			}
		}
		
		// store the result and go to idle
		stateRead.whenIsActive{
			io.apb.PSEL(0) := True
			io.apb.PENABLE := True
			//io.apb.PWRITE  := False
			spiDataSendReg := io.apb.PRDATA
			goto(stateIdle)
		}
		
		
		// writing: prepare and to to write
		statePrepareWrite.whenIsActive{
			io.apb.PWRITE  := True
			io.apb.PSEL(0) := True
			io.apb.PENABLE := True
			goto(stateWrite)
		}
		
		// Wait for the slave to acknowledge and to idle
		stateWrite.whenIsActive{
			io.apb.PWRITE  := True
			io.apb.PSEL(0) := True
			io.apb.PENABLE := True
			when(io.apb.PREADY){
				goto(stateIdle)
			}
		}
		
	}// fsm
	io.apb.PADDR  := spiReceiver.io.address.resize(32)
	io.apb.PWDATA := spiReceiver.io.dataReceived
	spiReceiver.io.dataToSend := spiDataSendReg

}


