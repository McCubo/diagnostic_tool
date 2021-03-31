public abstract class TerritoryManagement {
    public static DescribeSObjectResult TERRITORY_DESCR;
	
	protected Map<String, String> TERRITORY_MAP = new Map<String, String> {
        'TerritoryId' => 'territoryId',
        'Territory2Id' => 'territoryId'
    };
	
	public Map<Id, Map<String, String>> extractSObject(List<SObject> sObjects) {
        Map<Id, Map<String, String>> result = new Map<Id, Map<String, String>>();
        for (SObject sObj: sObjects) {
            Set<String> fields = sObj.getPopulatedFieldsAsMap().keySet();
            Map<String, String> data = new Map<String, String>();
            for (String field: fields) {
                String key = TERRITORY_MAP.containsKey(field) ? TERRITORY_MAP.get(field) : field;
                data.put(key, (String) sObj.get(field));
            }
            result.put((Id) sObj.get('Id'), data);
        }

        return result;
    }
    
    public String getLabelForTerritoryObject(){
		return getTerritoryDescribe().getLabelPlural();
	}
    
    // For territory only
    public abstract DescribeSObjectResult getTerritoryDescribe();
    public abstract List<String> getTerritoryNames(Set<Id> ids);
    public abstract Map<Id, Map<String, String>> getTerritories();
    public abstract Map<Id, Map<String, String>> getTerritories(Set<Id> territoryIds);
    public abstract Map<Id, Map<String, String>> getTerritoriesByNames(List<String> names);

    // For user territory
    public abstract Set<Id> getUserTerritories(Id userId);
    public abstract Map<Id, Map<String, String>> getUserTerritories(Set<Id> userIds, Set<Id> territoryIds);

    // for accountshare territory
    public List<AccountShare> getAccounts(Set<Id> accountIds, Boolean includeTerrAssignRule) {
        Set<String> rowCauses = new Set<String>{'TerritoryManual', 'Territory2AssociationManual'};
        if (includeTerrAssignRule) {
            rowCauses.add('Territory');
        }

        return (List<AccountShare>) Database.query('Select Id, AccountId, UserOrGroupId From AccountShare Where AccountId In :accountIds And RowCause In :rowCauses');
    }

}