public class N_EmailoflistOfopp_tooneUser {
    
    public static void sendemail(){
        
        list<User> Userlist=new list<User>();
        Userlist=[select id,name from User];
        
        map<id,List<Opportunity>> UserOpportunityList=new Map<id,List<Opportunity>>();
        
        List<Opportunity> OppList=new List<Opportunity>();
        OppList=[select id,name,ownerid,closedate,stagename from Opportunity where closedate>:system.today() and stagename NOT In ('Closed won','Closed Lost','Closed Shelve')];
        
        for(Opportunity opp:OppList){
            if(UserOpportunityList.containskey(opp.OwnerId)){
                List<Opportunity> TempOppList=New List<Opportunity>();
                TempOppList.add(opp);
                UserOpportunityList.put(opp.Ownerid,TempOppList);
                system.debug('--TempOpportunityList---' +UserOpportunityList);
            }
            
            else{
                List<Opportunity> TempOppList1=new List<Opportunity>();
                TempOppList1.add(opp);
                UserOpportunityList.put(opp.Ownerid,TempOppList1);
                
            }
        }
        
        //built ISP rule engine which automates the creation of day to day tasks 
        }

}