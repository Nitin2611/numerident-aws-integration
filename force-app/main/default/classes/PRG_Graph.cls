public with sharing class PRG_Graph {

    public List<WedgeData> getCaseData() {
        List<WedgeData> data = new List<WedgeData>();
        List<AggregateResult> Aggs = [Select count(Id) Nb,Priority from Case where isClosed = false group by Priority];
        for (AggregateResult Agg:Aggs){
	        data.add(new WedgeData((string)Agg.get('Priority'), (integer)Agg.Get('Nb')));
        }
        return data;
    }

    public List<WedgeData> getOrdonnanceData() {
        List<WedgeData> data = new List<WedgeData>();
        List<AggregateResult> Aggs = [Select count(Id) Nb,Statut__c from Ordonnance__c group by Statut__c];
        for (AggregateResult Agg:Aggs){
	        data.add(new WedgeData((string)Agg.get('Statut__c'), (integer)Agg.Get('Nb')));
        }
        return data;
    }

    // Wrapper class
    public class WedgeData {

        public String name { get; set; }
        public Integer data { get; set; }

        public WedgeData(String name, Integer data) {
            if(string.isblank(name)){
            	this.name = '-';	
            }else{
            	this.name = name;
            }
            this.data = data;
        }
    }
}