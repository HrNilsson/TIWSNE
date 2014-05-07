import java.io.IOException;

import net.tinyos.message.Message;
import net.tinyos.message.MessageListener;
import net.tinyos.message.MoteIF;
import net.tinyos.packet.BuildSource;
import net.tinyos.packet.PhoenixSource;
import net.tinyos.util.PrintStreamMessenger;


public class PCFileTransferer implements MessageListener {
	
	private MoteIF moteIF;

	public PCFileTransferer(MoteIF moteIF) {
		this.moteIF = moteIF;
		this.moteIF.registerListener(new SerialDataMsg(), this);
	}
	
	public void sendFile(String infilename, int moteId)
	{
		SerialDataMsg payload = new SerialDataMsg();
		//læs fil
		
		//while(!done)
		//	copy data to payload.get_data()
		//	moteIF.send(moteId, payload);		
	}
	
	public void receiveFile(String outFilename, int moteId)
	{
		
	}
	
	public void messageReceived(int to, Message message) {
		SerialDataMsg msg = (SerialDataMsg) message;
		System.out.println("Received serialdata packet");
	}	

	private static void usage() {
		System.err.println("usage: PCFileTransferer [-comm <source>]");
	}

	public static void main(String[] args) throws Exception {
		String source = null;
		if (args.length == 2) {
			if (!args[0].equals("-comm")) {
				usage();
				System.exit(1);
			}
			source = args[1];
		} else if (args.length != 0) {
			usage();
			System.exit(1);
		}

		PhoenixSource phoenix;

		if (source == null) {
			phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
		} else {
			phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
		}

		MoteIF mif = new ReliableMoteIF(phoenix);
		PCFileTransferer serial = new PCFileTransferer(mif);
		
		//serial.sendPackets();
	}

}
