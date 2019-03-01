/**
 * Created by adelaide on 04/06/18.
 * Wrapper to hold allowance entries with selected flag for mobile entry
 *
 */

public with sharing class Portal_Allowance_Wrapper{
    public Adhoc_Allowances__c alwEntry {get;set;}
    public Boolean selected {get; set;}
    public Boolean show {get;set;}

    public Portal_Allowance_Wrapper(Adhoc_Allowances__c alwRec, Boolean selected) {

        this.alwEntry = alwRec;

        this.selected = selected;
        system.debug('WrapperALW: '+this.alwEntry+'selected: '+this.selected);
        if(selected){
            show = false;
        }else{
            show = true;
        }
    }
}