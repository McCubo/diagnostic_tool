/**
 * @description 
 * @author BASE Life Science
 * @since 2021.03.01
 */
global class VDT_AggregateResultIterator implements Iterator<AggregateResult> {

    AggregateResult [] results {get;set;}

    //  tracks which result item is returned
    Integer index {get; set;} 
         
    global VDT_AggregateResultIterator(String query) {
      index = 0;
      results = Database.query(query);            
    } 
  
    global boolean hasNext(){ 
      return results != null && !results.isEmpty() && index < results.size(); 
    }    
  
    global AggregateResult next(){        
      return results[index++];            
    }  
}