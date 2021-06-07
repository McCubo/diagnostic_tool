global class VDT_AggregateResultIterable implements Iterable<AggregateResult> {

    private String query;

    global VDT_AggregateResultIterable(String soql){
      query = soql;
    }
  
    global Iterator<AggregateResult> Iterator(){
      return new VDT_AggregateResultIterator(query);
    }

}