import {LightningElement, api, wire, track} from 'lwc';
import getContactsByGroupId from '@salesforce/apex/AttendanceSheetController.getContactsByGroupId';
import getParentContacts from '@salesforce/apex/AttendanceSheetController.getParentContacts';
import {refreshApex} from "@salesforce/apex";


export default class AttendanceSheet extends LightningElement {
    @api recordId;
    @track currentDateValue;
    @track parentContacts;
    @track error;

    get currentDate(){
        if (this.currentDateValue) {
            console.log(this.currentDateValue);
            return this.currentDateValue;
        }
        else{
            let dt = new Date(Date.now());
            console.log('Current date' + dt);
            let dt_value = dt.getFullYear().toString()
                + '-' + (dt.getMonth() + 1).toString().padStart(2,'0')
                + '-' +  dt.getDate().toString().padStart(2,'0');
            console.log('Current date' + dt_value);
            this.currentDateValue = dt_value;
            return dt_value;
        }
    }
    @wire(getContactsByGroupId, {groupId: '$recordId', dateStr: '$currentDateValue' })
    attendees;
    @wire(getParentContacts, {})
    wiredParentsContacts({error, data}){
        if (data) {
            let tempArray = [];
            for(let i=0; i<data.length; i++) {
                tempArray.push({ label: data[i].Name, value: data[i].Id});
            }
            this.parentContacts = tempArray
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.parentContacts = undefined;
        }
    };

    handleDateChange(event){
        this.currentDateValue = event.target.value;
        refreshApex(this.attendees).catch(error => console.log(error));
    }

}