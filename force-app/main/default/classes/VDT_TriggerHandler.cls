/**
 * Trigger Handler base class
 */
public with sharing class VDT_TriggerHandler {

	private VDT_TriggerHandler() {}
    
    /**
     * Trigger Handler interface class
     */
    public interface Delegate {
        
        void prepareBefore();
        void prepareAfter();

        void beforeInsert(List<sObject> objList);
        void beforeUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap);
        void beforeDelete(Map<Id, sObject> newMap);

        void afterInsert(Map<Id, sObject> newMap);
        void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap);
        void afterDelete(Map<Id, sObject> oldMap);
        void afterUndelete(Map<Id, sObject> newMap);

        void finish();
        
    }


    /**
     * Trigger Handler Delegate Base class
     * When creating new Trigger Handler extend it from this one
     * Implementation requires the method to have no logic
     */
    @SuppressWarnings('sf:EmptyMethodInAbstractClassShouldBeAbstract')
    public abstract class DelegateBase implements Delegate {

        public virtual void prepareBefore() {}
        public virtual void prepareAfter() {}

        public virtual void beforeInsert(List<sObject> objList) {}
        public virtual void beforeUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {}
        public virtual void beforeDelete(Map<Id, sObject> newMap) {}

        public virtual void afterInsert(Map<Id, sObject> newMap) {}
        public virtual void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {}
        public virtual void afterDelete(Map<Id, sObject> oldMap) {}
        public virtual void afterUndelete(Map<Id, sObject> newMap) {}

        public virtual void finish() {}

        protected virtual void validateRun() {
            if (!Trigger.isExecuting) {
                throw new TriggerHandlerException('Trigger handler class cannot be called outside of trigger execution');
            }
        }
    }

    /**
     * execute execute Trigger Handler logic
     * @param  d delegate
     */
    public static void execute(Delegate d) {
        if (toBeBypassedSet.contains(String.valueOf(d).split(':')[0])) {
            return;
        }

        if (Trigger.isBefore) {
            d.prepareBefore();

            if (Trigger.isInsert) {
                d.beforeInsert(Trigger.new);
            } else if (Trigger.isUpdate) {
                d.beforeUpdate(Trigger.oldMap, Trigger.newMap);
            } else if (Trigger.isDelete) {
                d.beforeDelete(Trigger.oldMap);
            }
        } else {
            d.prepareAfter();

            if (Trigger.isInsert) {
                d.afterInsert(Trigger.newMap);
            } else if (Trigger.isUpdate) {
                d.afterUpdate(Trigger.oldMap, Trigger.newMap);
            } else if (Trigger.isDelete) {
                d.afterDelete(Trigger.oldMap);
            } else if (Trigger.isUndelete) {
                d.afterUndelete(Trigger.newMap);
            }
        }

        d.finish();
    }


    private static Set<String> toBeBypassedSet = new Set<String>();

    /**
     * bypassTrigger bypass Trigger Handler
     * @param  triggerHandlerClass Trigger Handler class
     */
    public static void bypassTrigger(System.Type triggerHandlerClass) {
        toBeBypassedSet.add(triggerHandlerClass.getName());
    }

    /**
     * allowTrigger remove bypass from Trigger Handler
     * @param  triggerHandlerClass Trigger Handler class
     */
    public static void allowTrigger(System.Type triggerHandlerClass) {
        toBeBypassedSet.remove(triggerHandlerClass.getName());
    }

    /**
     * Custom exception class for Trigger Handler errors
     */
    public class TriggerHandlerException extends Exception {}
}