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
		this.moteIF.registerListener(new ReliableTestSerialMsg(), this);
	}

	public void sendPackets() {
		int counter = 0;
		ReliableTestSerialMsg payload = new ReliableTestSerialMsg();

		try {
			while (true) {
				System.out.println("Sending packet " + counter);
				payload.set_counter(counter);
				moteIF.send(0, payload);
				counter++;
				try {
					Thread.sleep(1000);
				} catch (InterruptedException exception) {
				}
			}
		} catch (IOException exception) {
			System.err
					.println("Exception thrown when sending packets. Exiting.");
			System.err.println(exception);
		}
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
		serial.sendPackets();
	}

}
