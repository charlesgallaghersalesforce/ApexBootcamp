public with sharing class OnboardingController {

    @AuraEnabled(cacheable=true)
    public static String getOnboardingSummary(String recordId) {

        ResponseWrapper response = new ResponseWrapper();

        try {
            Contact employee = getContactInformation(recordId);
            List<Activity_Assignment__c> activityAssignments = getActivityAssignments(recordId);

            Decimal minutesAchieved = 0;
            Decimal minutesExpected = 0;
            Decimal totalMinutesInOnboarding = 0;
            Date today = Date.today();

            for (Activity_Assignment__c assignment : activityAssignments) {
                totalMinutesInOnboarding += assignment.Onboarding_Activity__r.Expected_Duration__c;
                if (assignment.Status__c == 'Completed') {
                    minutesAchieved += assignment.Onboarding_Activity__r.Expected_Duration__c;
                }
            }

            OnboardingData data = new OnboardingData();
            data.name = 'Onboarding - ' + employee.FirstName + ' ' + employee.LastName;
            data.startDate = employee.Start_Date__c;
            data.endDate = employee.Onboarding_End_Date__c;
            System.debug('startDate: ' + employee.Start_Date__c + ' endDate: ' + employee.Onboarding_End_Date__c);
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
                data.weekNo = 0;
            }
            Decimal aheadBehind = (minutesAchieved - minutesExpected);
            if (aheadBehind >= 0) {
                data.aheadBehind = aheadBehind + ' minutes ahead';
            } else {
                aheadBehind = aheadBehind * -1;
                data.aheadBehind = aheadBehind + ' minutes behind';
            }
            data.achieved = minutesAchieved;
            data.target = minutesExpected;
            data.totalOnboarding = totalMinutesInOnboarding;

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

            response.status = 'success';
            response.data = data;
            
        } catch (Exception e) {
            response.status = 'error';
            response.errorMessage = e.getMessage();
        }

        return JSON.serialize(response, true);

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
        public String status;
        public String errorMessage;
        public OnboardingData data;
    }

    public class OnboardingData {
        public String name;
        public Date startDate;
        public Date endDate;
        public String status;
        public String aheadBehind;
        public Decimal weekNo;
        public Decimal achieved;
        public Decimal target;
        public Decimal totalOnboarding;
    }
}
