/*This batch is used to check the compliance of a subscription
Modifed by YRU on 12/04/2021 Ticket 004
*/

global class BatchSubscriptionComplianceCheck implements Database.Batchable<sObject> {
    private static final String ELEMENTS_MANQUANTS = 'Éléments manquants';
    private static final String IMMO_NEUF = 'Conformité Immo neuf';
	private static final String CONF_PUB='Conformité Pub';
	DateTime todaysDate = System.today();

    
    global (Database.QueryLocator |List<SBQQ__Subscription__c>) start(Database.BatchableContext cnx) { 
         String query='SELECT Id, CompanyAddressCity__c, OrderNumber__c, CompanyAddressCountry__c, CompanyPhone__c, ContactGender__c, ContactLastName__c, 
                 ContactFirstName__c, Companyindustry__c, CompanyName__c, PrintVolume__c, BroadcastSoftware__c, PromoterDescription__c, SBQQ__RequiredById__c,
                 FlowType__c, BroadcastPartner__c, PostalCode__c, Souscription_Conforme__c, ComplianceProcess__c, Status__c, AccessStoreState__c, 
                 ProductWorkflow__c, AccessUserId__c, KilometerRadius__c, AccessStoreId__c, CompanyAddressStreet__c, CompanyAddressZipcode__c, LeadPhone__c,
                 ContractEmail__c, CompanySegment__c, CompanySiret__c,EffectiveEndDate__c,MissingInformations__c FROM SBQQ__Subscription__c WHERE Status__c = :ELEMENTS_MANQUANTS
                 AND Souscription_Conforme__c = false';
         return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext cnx, List<SBQQ__Subscription__c> scope) {
        try {
            List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
            for(SBQQ__Subscription__c sub : scope) {
               if (sub.ComplianceProcess__c == IMMO_NEUF) {
                    SBQQ__Subscription__c subImmo = setConformiteImmoNeuf(sub);
                    if (subImmo != null) {
                        if (sub.SBQQ__RequiredById__c != null) {
                           setParentConforme(sub.SBQQ__RequiredById__c);
                       }
                    }else{
					MissingInformations__c=''
					retur ()
					}
                }
			   if (sub.ComplianceProcess__c == CONF_PUB) {	
			        SBQQ__Subscription__c subPub = setConformitePub(sub);
					if(subPub!=null){
					   if(sub.EffectiveEndDate__c > todaysDate)
					}
			        
            }
        } catch(Exception e) {
            Logs.error('BatchSubscriptionComplianceCheck','Batch Compliance Check', e);
        }
    }
    
    global void finish(Database.BatchableContext cnx) {
    }
    

    private SBQQ__Subscription__c setConformiteImmoNeuf(SBQQ__Subscription__c sub) {
        if(sub.PromoterDescription__c != null && sub.FlowType__c != null && sub.ProductWorkflow__c != null
          && sub.ContractEmail__c != null && sub.CompanySiret__c != null && sub.CompanyName__c != null
          && sub.CompanyAddressStreet__c != null && sub.CompanyAddressZipcode__c != null && sub.CompanyAddressCity__c != null
          && sub.CompanyPhone__c != null && sub.ContactGender__c != null && sub.ContactFirstName__c != null 
          && sub.ContactLastName__c != null && sub.LeadPhone__c != null) {
            sub.Souscription_Conforme__c = true;
            update sub;
            return sub;
        }else{
		sub.MissingInformations__c=IMMO_NEUF;
		update sub;
        return null;
		}
    }
    
    private void setParentConforme(String parentId) {
        SBQQ__Subscription__c[] parentSub = [SELECT Id, Souscription_Conforme__c,Status__c FROM SBQQ__Subscription__c WHERE Status__c = :ELEMENTS_MANQUANTS 
                                           AND Souscription_Conforme__c = false AND Id = :parentId];
        if (parentSub.size() > 0) {
            parentSub[0].Souscription_Conforme__c = true;
            UPDATE parentSub[0];
        }
    }
	private SBQQ__Subscription__c setConformitePub(SBQQ__Subscription__c sub){
	    if(sub.FlowType__c != null && sub.ProductWorkflow__c != null
          && sub.ContractEmail__c != null && sub.CompanySiret__c != null && sub.CompanyName__c != null
          && sub.CompanyAddressStreet__c != null && sub.CompanyAddressZipcode__c != null && sub.CompanyAddressCity__c != null
          && sub.CompanyPhone__c != null && sub.ContactGender__c != null && sub.ContactFirstName__c != null 
          && sub.ContactLastName__c != null && sub.LeadPhone__c != null && sub.EffectiveEndDate__c > todaysDate){
		  sub.Souscription_Conforme__c = true;
		  update sub;
          return sub;
		}else{
		sub.MissingInformations__c=CONF_PUB;
		update sub;
		return null;
		}
	}
}
