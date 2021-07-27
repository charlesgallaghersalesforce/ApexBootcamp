public with sharing class OnboardingController {

    @AuraEnabled(cacheable=true)
    public static OnboardingData getOnboardingSummary(String recordId) {
        System.debug('getOnboardingSummary for: ' + recordId);

        OnboardingData data = new OnboardingData();
        data.name = 'Test ';
        data.startDate = Date.today();
        data.endDate = Date.today() + 90;
        data.status = 'Far Behind';
        data.aheadBehind = '1h';
        data.weekNo = 1;
        data.achieved = 10;
        data.target = 20;

        return data;

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
    }
}
