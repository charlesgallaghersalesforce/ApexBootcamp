public with sharing class OnboardingController {

    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getOnboardingSummary(String recordId) {

        // Initialize the response object that will be returned to the LWC
        ResponseWrapper response = new ResponseWrapper();

        try {

            // Get contact information from the current record 
            Contact employee = getContactInformation(recordId);

            // Get list of activity assignments related to the employee's contact record
            List<Activity_Assignment__c> activityAssignments = getActivityAssignments(recordId);

            // Initialize our totals
            Decimal minutesAchieved = 0;
            Decimal minutesExpected = 0;
            Decimal totalMinutesInOnboarding = 0;
            Date today = Date.today();

            // Create the OnboardingData object and set the values
            OnboardingData data = new OnboardingData();
            data.name = 'Onboarding - ' + employee.FirstName + ' ' + employee.LastName;
            data.startDate = employee.Start_Date__c;
            data.endDate = employee.Onboarding_End_Date__c;

            // Calculate the minutes achieved from all completed activity assignments
            for (Activity_Assignment__c assignment : activityAssignments) {
                totalMinutesInOnboarding += assignment.Onboarding_Activity__r.Expected_Duration__c;
                if (assignment.Status__c == 'Completed') {
                    minutesAchieved += assignment.Onboarding_Activity__r.Expected_Duration__c;
                }
            }

            // Calculate minutes expected and week number
            if (today > employee.Onboarding_End_Date__c) {
                minutesExpected = totalMinutesInOnboarding;
                data.weekNo = Integer.valueOf((employee.Start_Date__c.daysBetween(today)/7));
            } else if (today > employee.Start_Date__c && today <= employee.Onboarding_End_Date__c) {
                // Calculate the minutes expected based on today's date
                Integer totalDaysInOnboarding = employee.Start_Date__c.daysBetween(today);
                minutesExpected = (totalDaysInOnboarding * totalMinutesInOnboarding) / 90;
                // Calculate week number
                data.weekNo = Integer.valueOf((totalDaysInOnboarding/7));
            } else {
                // Onboarding's start date is in the future
                // Minutes expected should continue to be zero, week number should also be 0
                data.weekNo = 0;
            }

            // Calculate ahead/behind based on minutes achieved and minutes expected
            Decimal aheadBehind = (minutesAchieved - minutesExpected).setscale(1);
            if (aheadBehind >= 0) {
                data.aheadBehind = aheadBehind + ' minutes ahead';
            } else {
                aheadBehind = aheadBehind * -1;
                data.aheadBehind = aheadBehind + ' minutes behind';
            }

            data.achieved = minutesAchieved;
            data.target = minutesExpected.setscale(1);
            data.totalOnboarding = totalMinutesInOnboarding;

            // Determine the current status based on the current progress
            data.status = 'On Pace';
            if (today > employee.Start_Date__c) {
                Decimal progress = minutesAchieved / minutesExpected;
                if (progress > 1.2) {
                    data.status = 'Ahead of Pace';
                } else if (progress >= 1.0 && progress <= 1.2) {
                    data.status = 'On Pace';
                } else if (progress < 1.0 && progress > 0.8) {
                    data.status = 'Slightly Behind';
                } else {
                    data.status = 'Far Behind';   
                }
            }

            // Set status and data object to the response object
            response.status = 'success';
            response.data = data;
            
        } catch (Exception e) {
            // Set status and error to the response 
            response.status = 'error';
            response.errorMessage = e.getMessage();
        }

        return response;

    }

    public static Contact getContactInformation(String contactId) {
        return [SELECT Id, FirstName, LastName, Start_Date__c, Onboarding_End_Date__c FROM Contact WHERE Id =: contactId];
    }

    public static List<Activity_Assignment__c> getActivityAssignments(String employeeId) {
        return [SELECT Id, Name, Status__c, Actual_Minutes__c,
                Onboarding_Activity__r.Name, Onboarding_Activity__r.Expected_Duration__c, Onboarding_Activity__r.Trailhead_Points__c, 
                Onboarding_Activity__r.Type__c, Onboarding_Activity__r.URL__c, Onboarding_Activity__r.Onboarding__r.Type__c
                FROM Activity_Assignment__c 
                WHERE Employee__c =: employeeId];
    }

    public class ResponseWrapper {
        @AuraEnabled public String status;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public OnboardingData data;
    }

    public class OnboardingData {
        @AuraEnabled public String name;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String status;
        @AuraEnabled public String aheadBehind;
        @AuraEnabled public Decimal weekNo;
        @AuraEnabled public Decimal achieved;
        @AuraEnabled public Decimal target;
        @AuraEnabled public Decimal totalOnboarding;
    }
}