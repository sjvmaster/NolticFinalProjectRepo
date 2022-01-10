import {LightningElement, api, track} from 'lwc';
import {refreshApex} from "@salesforce/apex";
import addVisit from '@salesforce/apex/AttendanceSheetController.addVisit';

export default class AttendanceSheetChild extends LightningElement {
    @api attendee;
    @api superiorOptions;
    @api visitDate;
    @track arrivalTime;
    @track leavingTime;
    @track superior;
    @track isPresent;

    get isModifiable(){
        return !this.isDisabled && this.isPresent;
    }
    get isNotModifiable(){
        return !this.isModifiable;
    }
    get isDisabled() {
        console.log(this.attendee.SunVisits__r);
        if (this.attendee.SunVisits__r) {
            console.log(this.attendee.SunVisits__r[0].ArrivalTime__c);
            this.isPresent = true;
            let arrivalMs = this.attendee.SunVisits__r[0].ArrivalTime__c;
            let leavingMs = this.attendee.SunVisits__r[0].LeavingTime__c;
            let arrivalDt = new Date(arrivalMs);
            let leavingDt = new Date(leavingMs);
            console.log(this.arrivalTime);

            this.arrivalTime = arrivalDt.getUTCHours().toString().padStart(2,'0') + ':' + arrivalDt.getUTCMinutes().toString().padStart(2,'0');
            this.leavingTime = leavingDt.getUTCHours().toString().padStart(2,'0') + ':' + leavingDt.getUTCMinutes().toString().padStart(2,'0');
            this.superior = this.attendee.SunVisits__r[0].Superior__c;
            return true
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
                    visitorId: this.attendee.Id,
                    visitDate: this.visitDate,
                    arrivalTime: this.arrivalTime,
                    leavingTime: this.leavingTime,
                    superiorId: this.superior,
                }).then(result => {
                    console.log('Visit created');
                    refreshApex()
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
        console.log('superior' + this.superior);
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