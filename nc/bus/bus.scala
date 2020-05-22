import spinal.core._
import spinal.lib._
import spinal.lib.com.spi._
import spinal.lib.bus.amba3.apb._

/**
 * author: Yves Acremann
 */
 
/***
 * This is a simple example of how do wire up an APB bus driven by
 * a simple SPI interface and how to connect some peripherals
 ***/

// define a simple system containing a driven signal as well as an input
class ApbBus extends Component {
	
	// tne input / output declaration
	val io = new Bundle{
		// the SPI interface
		val spi    = master(SpiSlave())
		
		
		val outGain = out Bits(32 bits)
		
		
		// an output
		//val outReg = out Bits(32 bits)
		// an input
		//val inReg  = in  Bits(32 bits)
	}
	
	// the bus master instance
	val busMaster = new SpiApbDriver
	// connect the SPI bus to the IO signals
	busMaster.io.spi <> io.spi
	
	
	// now we need the slave factory to attach stuff to the bus:
	val busCtrl = Apb3SlaveFactory(busMaster.io.apb)
	
	
	//attach the gain coefficient to the bus
	busCtrl.driveAndRead(io.outGain, address = 100)
	
	
	// add an output on address 10 which we can also read back:
	//busCtrl.driveAndRead(io.outReg, address = 10)
	
	// add an input on address 20
	//busCtrl.read(io.inReg, address = 20)
	
}






//Generate the ApbTest's VHDL
object ApbTestVhdl {
  def main(args: Array[String]) {
    SpinalVhdl(new ApbBus)
  }
}

