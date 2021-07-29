trigger ValidatePoints on Onboarding_Activity__c (before insert, before update, after update) 
{
    TriggerHandler handler = new TriggerHandler();
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            System.debug('Trigger.New: ' + Trigger.New);
            handler.ValidateActivityPoints(Trigger.New);
        } 
    }
}