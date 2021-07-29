public class TriggerHandler 
{
    //Activity Validation
    public void ValidateActivityPoints(List<Onboarding_Activity__c> activities) 
    {
        //Goes through every activity that got passed from Trigger.New
        for (Onboarding_Activity__c activity : activities) 
        {
            //Validates that if the activity type is Modules then it should have associated trailhead points
            if (activity.Type__c == 'Module' && (activity.Trailhead_Points__c == null || activity.Trailhead_Points__c == 0)) 
            {
                //Displays the validation error to the user
                activity.addError(activity.Name + ' is a Trailhead Module and requires Points > 0');
            }
        }
    }
}