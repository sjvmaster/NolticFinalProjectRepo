import {LightningElement, api, track} from 'lwc';
import {refreshApex} from "@salesforce/apex";
import addVisit from '@salesforce/apex/AttendanceSheetController.addVisit';

export default class AttendanceSheetChild extends LightningElement {
    @api attendeeInternal;
    @api attendeeVisits;
    @api
    set attendee(value) {
        this.attendeeInternal = value;
        this.attendeeVisits = value.SunVisits__r;
    }
    get attendee(){
        return this.attendeeInternal;
    }
    @api superiorOptions;

    @api
    set visitDateFromParent(value){
        if (this.visitDate) {
            this.attendeeVisits=undefined;
            this.arrivalTime=undefined;
            this.leavingTime=undefined;
            this.superior=undefined;
            this.isPresent=false;
            this.alreadySubmitted=false;
        }
        this.visitDate = value;
    };
    get visitDateFromParent(){
        return this.visitDate;
    }
    visitDate;
    alreadySubmitted;
    @track arrivalTime;
    @track leavingTime;
    @track superior;
    @track isPresent;

    get isModifiable(){
        return !this.isDisabled && this.isPresent && !this.alreadySubmitted;
    }

    get isNotModifiable(){
        return !this.isModifiable;
    }

    get isDisabled() {
        if (this.attendeeVisits) {
            this.isPresent = true;
            let arrivalMs = this.attendeeVisits[0].ArrivalTime__c;
            let leavingMs = this.attendeeVisits[0].LeavingTime__c;
            let arrivalDt = new Date(arrivalMs);
            let leavingDt = new Date(leavingMs);

            this.arrivalTime = arrivalDt.getUTCHours().toString().padStart(2,'0') + ':' + arrivalDt.getUTCMinutes().toString().padStart(2,'0');
            this.leavingTime = leavingDt.getUTCHours().toString().padStart(2,'0') + ':' + leavingDt.getUTCMinutes().toString().padStart(2,'0');
            this.superior = this.attendeeVisits[0].Superior__c;
            return true;
        }
        return false;
    }

    handleSubmitVisit(event){
        if (this.isPresent){
            const allValid = [
                ...this.template.querySelectorAll('lightning-input, lightning-combobox'),
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if (allValid) {
                addVisit({
                    visitorId: this.attendeeInternal.Id,
                    visitDate: this.visitDate,
                    arrivalTime: this.arrivalTime,
                    leavingTime: this.leavingTime,
                    superiorId: this.superior,
                }).then(result => {
                    this.alreadySubmitted = true;
                    console.log('Visit created');
                }).catch(error => console.log(error));
            } else {
                event.target.setCustomValidity('Please update the invalid fields entries and try again.');
            }
        }
    }

    handleIsPresentChange(event) {
        this.isPresent = event.target.checked;
    }
    handleArrivalTimeChange(event) {
        let arrivalTimeControl = event.target;
        this.arrivalTime = arrivalTimeControl.value;
        if (this.isPresent) {
            if(!this.arrivalTime){
                arrivalTimeControl.setCustomValidity('Please Enter the Arrival Time');
            }else{
                if (this.leavingTime && this.leavingTime < this.arrivalTime){
                    arrivalTimeControl.setCustomValidity('Arrival Time should be before Leaving Time');
                }
                else {
                    arrivalTimeControl.setCustomValidity('');
                }
            }
            arrivalTimeControl.reportValidity();
        }
    }
    handleLeavingTimeChange(event) {
        let leavingTimeControl = event.target;
        this.leavingTime = leavingTimeControl.value;
        if (this.isPresent) {
            if(!this.leavingTime){
                leavingTimeControl.setCustomValidity('Please Enter the Leaving Time');
            }
            else {
                if (this.arrivalTime && this.leavingTime < this.arrivalTime){
                    leavingTimeControl.setCustomValidity('Leaving Time should be after Arrival Time');
                }
                else {
                    leavingTimeControl.setCustomValidity('');
                }
            }
            leavingTimeControl.reportValidity();
        }
    }
    handleSuperiorChange(event) {
        let superiorControl = event.target;
        this.superior = superiorControl.value;
        if (this.isPresent) {
            if(!this.superior){
                superiorControl.setCustomValidity('Please Enter the Superior Person');
            }else{
                superiorControl.setCustomValidity('');
            }
            superiorControl.reportValidity();
        }
    }
}