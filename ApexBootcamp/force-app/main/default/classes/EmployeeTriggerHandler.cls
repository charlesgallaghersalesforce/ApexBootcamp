public inherited sharing class EmployeeTriggerHandler {

    /*
        When a new employee Contact is created, generate a set of Onboarding Activities for them.
    */
    public void CreateActivityAssignments(List<Contact> contacts) {

        // Gather the Ids of all Onboarding__c records we will need
        // Use a set because multiple contacts might have same onboarding, but we only need to collect all unique Ids
        Set<ID> onboardingIDs = new Set<ID>();
        for (Contact contact : contacts) {
            if (contact.Onboarding__c != null)  {
                onboardingIDs.add(contact.Onboarding__c);
            }
        }

        if (onboardingIDs.isEmpty()) {
            // None of the new contacts have an onboarding -- there's nothing further to do.
            return;
        }
        
        // Select all the Onboarding__c records along with all their child Onboarding_Activity__c records
        // Onboarding_Activities__r indicates a relationship where Onboarding__c has related Onboarding_Activity__c records
        // The map constructor will automatically map them by their ID
        Map<Id, Onboarding__c> onboardingMap = new Map<Id, Onboarding__c>(
            [
                SELECT
                    Id,
                    (SELECT Id, Name FROM Onboarding_Activities__r)
                FROM 
                    Onboarding__c
                WHERE
                    Id IN :onboardingIDs
            ]
        );

        // Build out assignments for each contact
        List<Activity_Assignment__c> assignments = new List<Activity_Assignment__c>();
        for (Contact contact : contacts) {
            if (contact.Onboarding__c != null) {

                // Retrieve the onboarding from the map
                Onboarding__c onboarding = onboardingMap.get(contact.Onboarding__c);

                // Add each assignment to list of new assignments
                for (Onboarding_Activity__c activity : onboarding.Onboarding_Activities__r) {
                    assignments.add(
                        new Activity_Assignment__c(
                            Onboarding_Activity__c = activity.Id, 
                            Employee__c = contact.Id));
                }
            }
        }

        // Insert the assignments -- if there are any
        if (!assignments.isEmpty()) {
            insert assignments;
        }
    }

}