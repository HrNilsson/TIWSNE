/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'AckMsg'
 * message type.
 */

public class AckMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 1;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 22;

    /** Create a new AckMsg of size 1. */
    public AckMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new AckMsg of the given data_length. */
    public AckMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new AckMsg with the given data_length
     * and base offset.
     */
    public AckMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new AckMsg using the given byte array
     * as backing store.
     */
    public AckMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new AckMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public AckMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new AckMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public AckMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new AckMsg embedded in the given message
     * at the given base offset.
     */
    public AckMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new AckMsg embedded in the given message
     * at the given base offset and length.
     */
    public AckMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <AckMsg> \n";
      try {
        s += "  [cookie=0x"+Long.toHexString(get_cookie())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: cookie
    //   Field type: short, unsigned
    //   Offset (bits): 0
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'cookie' is signed (false).
     */
    public static boolean isSigned_cookie() {
        return false;
    }

    /**
     * Return whether the field 'cookie' is an array (false).
     */
    public static boolean isArray_cookie() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'cookie'
     */
    public static int offset_cookie() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'cookie'
     */
    public static int offsetBits_cookie() {
        return 0;
    }

    /**
     * Return the value (as a short) of the field 'cookie'
     */
    public short get_cookie() {
        return (short)getUIntBEElement(offsetBits_cookie(), 8);
    }

    /**
     * Set the value of the field 'cookie'
     */
    public void set_cookie(short value) {
        setUIntBEElement(offsetBits_cookie(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'cookie'
     */
    public static int size_cookie() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'cookie'
     */
    public static int sizeBits_cookie() {
        return 8;
    }

}