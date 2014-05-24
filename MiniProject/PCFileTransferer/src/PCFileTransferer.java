import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.concurrent.LinkedBlockingQueue;

import net.tinyos.message.Message;
import net.tinyos.message.MessageListener;
import net.tinyos.message.MoteIF;
import net.tinyos.packet.BuildSource;
import net.tinyos.packet.PhoenixSource;
import net.tinyos.util.PrintStreamMessenger;


public class PCFileTransferer implements MessageListener {
	
	static final int IMAGELENGTH = 256*256; //FIXME: Hardcoded!
	
	private MoteIF moteIF;
	private LinkedBlockingQueue<short[]> dataQueue = new LinkedBlockingQueue<short[]>();

	public PCFileTransferer(MoteIF moteIF) {
		this.moteIF = moteIF;
		this.moteIF.registerListener(new SerialDataMsg(), this);
	}
	
	public void sendFile(String inFilename, int moteId)
	{
		SerialDataMsg payload = new SerialDataMsg();
		FileInputStream inFile = null;

		byte[] bFileChunk = new byte[SerialDataMsg.totalSize_data()];
		long bytesSent = 0;
		long fileSize = new File(inFilename).length();

		try {
			inFile = new FileInputStream(inFilename);
			
			//short counter = 1;
			
			while(bytesSent < fileSize)
			{
				long bytesLeft = fileSize - bytesSent;
				int bytesToSend = 0;
				
				//how much to send?
				if(bytesLeft >  bFileChunk.length)
					bytesToSend = bFileChunk.length;
				else
					bytesToSend = (int) bytesLeft;
				
				inFile.read(bFileChunk, 0, bytesToSend);
				
				for(int i = 0; i < bytesToSend; i++)
				{
					payload.setElement_data(i, bFileChunk[i]);
				}
				
				//testing
				//payload.setElement_data(0, counter);
				//payload.setElement_data(111, counter);
				//counter = (short) (++counter % 7);
				
				moteIF.send(moteId, payload);
				
				bytesSent += bytesToSend;
			}			
			
			inFile.close();

			System.out.println("Done sending " + inFilename);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void receiveFile(String outFilename, int moteId, int receiveBlockSize)
	{
		FileOutputStream outFile = null;
		try {
			outFile = new FileOutputStream(outFilename);
			long bytesReceived = 0;
			
			while(bytesReceived < IMAGELENGTH)
			{
				byte[] bData = null;
				short[] sData = dataQueue.take();
				
				int bytesToCopy = receiveBlockSize;
				if((bytesReceived + bytesToCopy) > IMAGELENGTH)
					bytesToCopy = (int) (IMAGELENGTH - bytesReceived);
					
				bData = new byte[bytesToCopy];
				
				for(int i = 0; i < bytesToCopy; i++)
				{
					bData[i] = (byte) sData[i];
				}
	
				outFile.write(bData);
				bytesReceived += bytesToCopy;
			}
			
			outFile.flush();
			outFile.close();

			System.out.println("Done receiving " + outFilename);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}	
	
	public void messageReceived(int to, Message message) {
		SerialDataMsg msg = (SerialDataMsg) message;
		
		try {
			dataQueue.put(msg.get_data());
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		
		//System.out.println("Received serialdata packet");
	}	

	private static void usage() {
		System.err.println("usage: PCFileTransferer -s <sendFilePath> OR -r <receiveFilePath> <receiveBlockSize> [-comm <source>][-m <sendToMoteId>]");
	}

	public static void main(String[] args) throws Exception {
		String source = null;
		String sendFilePath = null;
		String receiveFilePath = null;
		int receiveBlockSize = 112;
		int moteId = 0;
		
		//parse args
		for(int i = 0; i < args.length; i++)
		{	
			if(args[i].equals("-s"))
			{
				sendFilePath = args[i+1];
				i++;
			}
			else if(args[i].equals("-r"))
			{				
				receiveFilePath = args[i+1];
				receiveBlockSize = Integer.parseInt(args[i+2]);
				i += 2;
			}
			else if(args[i].equals("-comm"))
			{
				source = args[i+1];
				i++;
			}
			else if(args[i].equals("-m"))
			{
				moteId = Integer.parseInt(args[i+1]);
				i++;
			}
			else
			{
				usage();
				System.exit(1);
			}			
		}
		
		//in or outfilepath must be specified, not both
		if(!(sendFilePath != null ^ receiveFilePath != null))
		{
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
		
		if(sendFilePath != null)
		{
			serial.sendFile(sendFilePath, moteId);
		}
		else if(receiveFilePath != null)
		{
			serial.receiveFile(receiveFilePath, moteId, receiveBlockSize);
		}
		
		phoenix.shutdown(); //close connection to mote source
	}

}
