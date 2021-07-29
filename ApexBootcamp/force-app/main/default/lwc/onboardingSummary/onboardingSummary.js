import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOnboardingSummary from '@salesforce/apex/OnboardingController.getOnboardingSummary';

export default class OnboardingSummary extends LightningElement {
    @api recordId;
    isLoading;
    onboardingData;
    progressActual;
    progressTarget;

    isRendered = false;
    renderedCallback() {
        if (!this.isRendered) {
            this.isRendered = true;
            this.getOnboardingData();
        }
    }

    async getOnboardingData() {
        try {
            this.handleLoading();
            const result = await getOnboardingSummary({recordId: this.recordId});
            let responseWrapper = JSON.parse(result);

            if (!responseWrapper.status || !responseWrapper.data) {
                const errorEvent = new ShowToastEvent({
                    title: `There was an issue retrieving onboarding data ${responseWrapper.errorMessage}`,
                    variant: 'error'
                });
                this.dispatchEvent(errorEvent);
                return;
            }

            this.onboardingData = responseWrapper.data;
            let startDate = this.adjustForTimezone(new Date(this.onboardingData.startDate));
            this.onboardingData.startDate = startDate.toLocaleDateString();
            let endDate = this.adjustForTimezone(new Date(this.onboardingData.endDate));
            this.onboardingData.endDate = endDate.toLocaleDateString();
            this.progressActual = ((this.onboardingData.achieved / this.onboardingData.totalOnboarding) * 100).toFixed(0);
            this.progressTarget = ((this.onboardingData.target / this.onboardingData.totalOnboarding) * 100).toFixed(0);

        } catch(error) {
            const errorEvent = new ShowToastEvent({
                title: `Error retrieving onboarding data: ${error}`,
                variant: 'error'
            });
            this.dispatchEvent(errorEvent);
        } finally {
            this.handleDoneLoading();
        }
    }

    adjustForTimezone(date){
        var timeOffsetInMS = date.getTimezoneOffset() * 60000;
        date.setTime(date.getTime() + timeOffsetInMS);
        return date
    }

    // Handles loading event
    handleLoading() { 
        this.isLoading = true;
    }
    
    // Handles done loading event
    handleDoneLoading() {
        this.isLoading = false;
    }

    get isFarBehind() {
        return this.onboardingData.status == 'Far Behind' ? true : false;
    }
    get isSlightlyBehind() {
        return this.onboardingData.status == 'Slightly Behind' ? true : false;
    }
    get isOnPace() {
        return this.onboardingData.status == 'On Pace' ? true : false;
    }
    get isAheadOfPace() {
        return this.onboardingData.status == 'Ahead of Pace' ? true : false;
    }
}