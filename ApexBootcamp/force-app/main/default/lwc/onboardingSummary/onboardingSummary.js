import { LightningElement, api } from 'lwc';
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
            this.onboardingData = responseWrapper.data;
            let startDate = new Date(this.onboardingData.startDate).toLocaleDateString();
            this.onboardingData.startDate = startDate;
            let endDate = new Date(this.onboardingData.endDate).toLocaleDateString();
            this.onboardingData.endDate = endDate;
            this.progressActual = ((this.onboardingData.achieved / this.onboardingData.totalOnboarding) * 100).toFixed(0);
            this.progressTarget = ((this.onboardingData.target / this.onboardingData.totalOnboarding) * 100).toFixed(0);

            if (!responseWrapper.status || !responseWrapper.data) {
                console.log(`There was an issue retrieving onboarding data ${responseWrapper.status}`);
            }

        } catch(error) {
            console.log(`There was an issue retrieving onboarding data ${error}`);
        } finally {
            this.handleDoneLoading();
        }
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