/**
 * @description A class for automatically attaching metadata to log messages
 * like Quiddity and RequestID
 */
public inherited sharing class VDT_LogMessage {
    private static final String EXCEPTION_STRING_FORMAT = 'Exception: [{0}] {1} \n StackTrace: {2}';

    /**
     * @description public read only property for the request ID. Privately set.
     */
    public String requestId {
        get {
            if (requestId == null) {
                requestId = Request.getCurrent().getRequestId();
            }
            return requestId;
        }
        private set;
    }

    /**
     * @description Public read only property for quiddity. Privately set.
     */
    public Quiddity quiddity {
        get {
            if (quiddity == null) {
                quiddity = Request.getCurrent().getQuiddity();
            }
            return quiddity;
        }
        private set;
    }

    /**
     * @description Public message property.
     */
    public String message { get; set; }

    /**
     * @description Public severity property.
     */
    public VDT_LogSeverity severity { get; set; }

    /**
     * @description converts this object to an event for publishing
     * @return      `SObject`
     */
    public SObject toEvent() {
        return new VDT_Log__e(
            Log_Message__c = this.message,
            Request_Id__c = this.requestId,
            Quiddity__c = this.quiddity?.name(),
            Severity__c = this.severity?.name()
        );
    }

    /**
     * @description   Constructor accepting a message to log.
     * Severity is auto set to info
     * @param message
     */
    public VDT_LogMessage(String message) {
        this.message = message;
        this.severity = VDT_LogSeverity.INFO;
    }

    /**
     * @description Constructor accepting an exception object.
     * @param ex
     */
    public VDT_LogMessage(Exception ex) {
        this.message = String.format(
            EXCEPTION_STRING_FORMAT,
            new List<String>{
                ex.getTypeName(),
                ex.getMessage(),
                ex.getStackTraceString()
            }
        );
        this.severity = VDT_LogSeverity.ERROR;
    }
}