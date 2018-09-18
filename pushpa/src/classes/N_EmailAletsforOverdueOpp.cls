public class N_EmailAletsforOverdueOpp {
    public static void emailAletsforOverDueOpportunities(){
        N_EmailAletsforOverdueOpp.listOpportunity('24');
        system.debug('24 hours List sended');
        N_EmailAletsforOverdueOpp.listOpportunity('48');
    }
    
    // list the opportunities overdue of close date
    public static void listOpportunity(string hours){
        Map<String,List<Opportunity>> ListOppValue=new Map<String,List<Opportunity>>();
        Map<String,String> userIdtoEmailId=new Map<String,String>();
        list<user> userlist=new list<user>();
        userlist=[select id ,Email from user where isActive=true];
        
        
        //list the active user 
        for(user UserName:userList){
            userIdtoEmailId.put(UserName.Id,UserName.email);
        }
        
        system.debug('UserIdtoEmailId='+UserIdtoEmailId);
        
        //active user over due close dtae of opportunities
        List<Opportunity> oppList=new List<Opportunity>();
        if(hours == '24'){
            oppList=[select id,name,closedate,Account.Name,amount,stageName,Ownerid from Opportunity where closedate = Yesterday  and stageName NOT In ('closed won','closed lost','closed shelved') and  Ownerid in:userlist];
        }
        else{
            oppList=[select id,name,closedate,Account.Name,amount,stageName,Ownerid from Opportunity where closedate<=N_days_ago:2  and stageName NOT In ('closed won','closed lost','closed shelved') and  Ownerid in:userlist];
        }
        for(Opportunity opp:oppList){
                        
            if( ListOppValue.containsKey(userIdtoEmailId.get(opp.OwnerId)) ){
                list<opportunity> temp1=new List<opportunity>();
                temp1=ListOppValue.get(userIdtoEmailId.get(opp.OwnerId));
                temp1.add(opp);
                ListOppValue.put(userIdtoEmailId.get(opp.OwnerId),temp1);
            }
            else{
                list<opportunity> temp=new List<opportunity>();
                temp.add(opp);
                ListOppValue.put(userIdtoEmailId.get(opp.OwnerId),temp);
            }
        }
        
        system.debug('OpptoCloseDate='+ListOppValue);
        if(ListOppValue.size() != 0){
             system.debug('size--no list'+ListOppValue.size());
            N_EmailAletsforOverdueOpp.sendAlertToOwner(ListOppValue,hours);
        }
    }
    
    
    // send mail of list of opportinities to individual user  
    public static void sendAlertToOwner(Map<String,List<Opportunity>> ListOppValue,string hours){
        //send mails to each user with opportunities list
        for(string usernames:ListOppValue.keyset()){
            string bodyMessage='',message,regardsFrom;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {usernames};
                mail.setToAddresses(toAddresses);
            
            if(hours == '24'){
                message='Please find below one or more opportunities whose close date is in the recent past, please update the same at the earliest in Salesforce.';
                regardsFrom='Regards'+'</br>'+'Salesforce Team';
                OrgWideEmailAddress[] OrgId = [select Id from OrgWideEmailAddress where Address = 'information.systems@brillio.com'];
                mail.setSubject('Close date for the opportunity needs an update');
                if ( OrgId.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(OrgId.get(0).Id);
                }
            }
            else{
                mail.setSubject('Close date for the opportunity is in the past – need action!');
                mail.setSenderDisplayName('Ashish Mahadwar');
                mail.emailPriority = 'Highest';
                message='Please find below one or more opportunities whose close date is overdue for the last 2 days, update the same at the earliest in Salesforce.';
                regardsFrom='Warm Regards'+ '</br>' +'Ashish Mahadwar';
            }
            bodyMessage='<html><head><style>table{font-family: arial, sans-serif;border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd;text-align: left;padding: 8px;}tr:nth-child(even) {background-color: #dddddd;}</style></head><body>Hi, <br/><br/>'+message+'<br/><br/><br/><table><tr><th>Account Name</th><th>opportunity Name</th><th>Current Close Date</th><th>Opportunity Amount($)</th></tr>';
            
            List<opportunity> oppList=ListOppValue.get(usernames);
            for(Opportunity opp : oppList){
                mail.setPlainTextBody('');
                bodyMessage+='<tr><td>'+opp.Account.name+'</td><td><a href="https://brillio.lightning.force.com/'+opp.Id+'">'+Opp.Name+'</a></td><td>'+opp.CloseDate.format()+'</td><td>'+opp.Amount+'</td></tr>';
            }
            
            bodyMessage+='</table> </br><br/>'+regardsFrom+'</body></html>';
            mail.setHtmlBody(bodyMessage);
            system.debug('---data-----'+usernames);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail});
            
        }
        system.debug('emails are send successfully');
    } 
}