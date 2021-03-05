/**
 * @description Generic logging framework that persists across DML reversions
 * by publishing a Platform Event
 */
public inherited sharing class VDT_Log {
    /**
     * @description private instance of this log class that backs the
     * singleton get() method.
     */
    private static VDT_Log currentInstance;

    /**
     * @description private list of VDT_LogMessage objects to be published in the
     * future
     */
    private List<VDT_LogMessage> buffer;

    /**
     * @description establishes the buffer, if one doesn't yet exist
     * private, to ensure we can't directly construct this class. Use the
     * Singleton, Luke.
     */
    private VDT_Log() {
        buffer = new List<VDT_LogMessage>();
    }

    /**
     * @description Singleton pattern `get` method.
     * @return     `VDT_Log`
     */
    public static VDT_Log get() {
        if (currentInstance == null) {
            currentInstance = new VDT_Log();
        }
        return currentInstance;
    }

    /**
     * @description Add a message to the buffer without publishing it.
     * Assumes a null severity
     * @param messageToLog  The string message to add to the buffer.
     */
    public void add(String messageToLog) {
        this.add(messageToLog, null);
    }

    /**
     * @description Add a message to the buffer without publishing it.
     * @param messageToLog The string message to add to the buffer.
     * @param severity     VDT_LogSeverity enum
     */
    public void add(String messageToLog, VDT_LogSeverity severity) {
        VDT_LogMessage msg = new VDT_LogMessage(messageToLog);
        if (severity != null) {
            msg.severity = severity;
        }
        buffer.add(msg);
    }

    /**
     * @description Add an formated exception message to the buffer without
     * publishing it. Assumes a null Severity
     * @param exceptionToLog Exception to format and log
     */
    public void add(Exception exceptionToLog) {
        this.add(exceptionToLog, null);
    }

    /**
     * @description Add an formated exception message to the buffer without
     * publishing it.
     * @param exceptionToLog Exception to format and log
     * @param severity       VDT_LogSeverity enum
     */
    public void add(Exception exceptionToLog, VDT_LogSeverity severity) {
        VDT_LogMessage msg = new VDT_LogMessage(exceptionToLog);
        if (severity != null) {
            msg.severity = severity;
        }
        buffer.add(msg);
    }

    /**
     * @description Publish any messages currently in the buffer, without adding
     * any new ones.
     */
    public void publish() {
        List<SObject> rawLogs = new List<SObject>();
        for (VDT_LogMessage msg : this.buffer) {
            rawLogs.add(msg.toEvent());
        }
        system.debug('rawLogs :: ' + rawLogs);
        EventBus.publish(rawLogs);
        this.buffer.clear();
    }

    /**
     * @description Auto-format exception details, add it to the log buffer,
     * and then publish the current buffer. Use the equivelent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param exceptionToLog exception to format and log
     */
    public void publish(Exception exceptionToLog) {
        this.buffer.add(new VDT_LogMessage(exceptionToLog));
        this.publish();
    }

    /**
     * @description Auto-format a custom log message string, add it to the log
     * buffer, and then publish the current buffer. Use the equivelent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param messageToLog String to log
     */
    public void publish(String messageToLog) {
        this.buffer.add(new VDT_LogMessage(messageToLog));
        this.publish();
    }
}