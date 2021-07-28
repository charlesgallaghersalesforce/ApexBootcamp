trigger ValidatePoints on Onboarding_Activity__c (before insert, before update, after update) 
{
    TriggerHandler handler = new TriggerHandler();
    
    if(Trigger.isInsert || Trigger.isUpdate)
    {
    	handler.ValidateActivityPoints(Trigger.New);
    }
}