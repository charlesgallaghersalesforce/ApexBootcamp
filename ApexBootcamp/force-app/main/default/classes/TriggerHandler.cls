public class TriggerHandler {
    
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
    
    public void CreateActivityAssignments(List<Contact> contacts) {
        Set<ID> onboardingIDs = new Set<ID>();
        
        for (Contact contact : contacts) 
        {
            if (contact.Onboarding__c != null) 
            {
                onboardingIDs.add(contact.Onboarding__c);
            }
        }
        
        Map<ID, List<Onboarding_Activity__c>> activityMap = new Map<ID, List<Onboarding_Activity__c>>();
        for (Onboarding_Activity__c onboardingActivity : [select Id, Name, Onboarding__c
                                                          from Onboarding_Activity__c
                                                          where Onboarding__c IN :onboardingIDs
                                                         ]) {
            List<Onboarding_Activity__c> activities = activityMap.get(onboardingActivity.Onboarding__c);
                                                             
            if (activities == null) 
            {
                activities = new List<Onboarding_Activity__c>();
                activityMap.put(onboardingActivity.Onboarding__c, activities);
            }
                
            activities.add(onboardingActivity);
        }

        List<Activity_Assignment__c> assignments = new List<Activity_Assignment__c>();
        for (Contact contact : contacts) 
        {
            if (contact.Onboarding__c != null) 
            {
                for (Onboarding_Activity__c activity : activityMap.get(contact.Onboarding__c)) 
                {
                    assignments.add(new Activity_Assignment__c(Onboarding_Activity__c = activity.Id, Employee__c = contact.Id));
                }
            }
        }
        
        if (!assignments.isEmpty())
        {
            insert assignments;
        }
    }
}