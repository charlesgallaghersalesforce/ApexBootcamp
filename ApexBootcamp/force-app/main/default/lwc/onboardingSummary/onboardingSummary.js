import { LightningElement, wire, api, track } from 'lwc';
import getOnboardingSummary from '@salesforce/apex/OnboardingController.getOnboardingSummary';

export default class OnboardingSummary extends LightningElement {
    @api recordId;
    loaded = false;
    planName;
    startDate;
    endDate;
    status;
    aheadBehind;
    weekNo;
    achieved;
    target;
    currentStage;
    progress;
    planStages = [];

    @wire(getOnboardingSummary, {recordId: '$recordId'})
    wiredPlan({ error, data }) {
        if (data) {
            this.loaded = true;
            this.planName = data.name;
            var planStartDate = new Date(data.startDate);
            var planStartDay = planStartDate.getDate() + 1;
            var planStartMonth = planStartDate.getMonth() + 1;
            this.startDate = planStartMonth + '/' + planStartDay + '/' + planStartDate.getFullYear();
            var planEndDate = new Date(data.endDate);
            var planEndDay = planEndDate.getDate() + 1;
            var planEndMonth = planEndDate.getMonth() + 1;
            this.endDate = planEndMonth + '/' + planEndDay + '/' + planStartDate.getFullYear();
            this.status = data.status;
            this.aheadBehind = data.aheadBehind;
            this.weekNo = data.weekNo;
            this.achieved = data.achieved;
            this.target = data.target;
            this.currentStage = data.currentStage;
            if (data.target == 0) {
                this.progress = 0;
            } else {
                var progressTmp = (data.achieved / data.target) * 100;
                this.progress = progressTmp.toFixed(0);
            }
            this.planStages = data.planStages;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.planName = undefined;
        }
    }

    get isFarBehind() {
        return this.status == 'Far Behind' ? true : false;
    }
    get isSlightlyBehind() {
        return this.status == 'Slightly Behind' ? true : false;
    }
    get isOnPace() {
        return this.status == 'On Pace' ? true : false;
    }
    get isAheadOfPace() {
        return this.status == 'Ahead of Pace' ? true : false;
    }
}