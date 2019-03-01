/* customPortalJS
This JS static resource contains all the jQuery functions used but the portal pages
*/
//do not allow enter key to save/submit, users must use the buttons provided.
   $(document).ready(function() {
      $(window).keydown(function(event){
        if(event.keyCode == 13) {
          event.preventDefault();
          return false;
        }
      });
    });

//$(document).ready(function() {
$(window).on('load', function() {
    /*
    Used by: PortalProfileCompanyDetails, PortalProfileBankDetails
    Why? : to be able to render the different sections of the page based on the users
    radio button selection for adding bank account/s details
    */
    //Make sure the Bank Account info is all showing up correctly
    //default all sections to be hidden initially, except for Cancel, we will let the user do that!

    console.log('inside');

    jQuery('[id$=divAusBank]').hide();
    jQuery('[id$=divIntBank]').hide();

    jQuery('[id$=theSave]').hide();
    jQuery('[id$=theCancel]').show();

    jQuery('[id$=divBankAcc2]').hide();

    jQuery('[id$=divYes2]').hide();

    jQuery('[id$=divBankAcc3]').hide();
    jQuery('[id$=divYes3]').hide();

    jQuery('[id$=timeEntryError]').hide();
    jQuery('[id$=breakEntryError]').hide();
    jQuery('[id$=abnEntryError]').hide();
    jQuery('[id$=tfnEntryError]').hide();


    //bank allocation errors - lets hide them to begin with
    jQuery('[id$=showTotalInfo_overA]').hide();
    jQuery('[id$=showTotalInfo_underA]').hide();
    jQuery('[id$=showTotalInfo_overB]').hide();
    jQuery('[id$=showTotalInfo_underB]').hide();
    jQuery('[id$=showSaveError]').hide();
    jQuery('[id$=showFixedErrorA]').hide();
    jQuery('[id$=showFixedErrorB]').hide();
    jQuery('[id$=showFixedErrorExpA]').hide();
    jQuery('[id$=showFixedErrorExpB]').hide();

    //mobile MyProfile pages needs this
    jQuery('[id$=editBlock]').hide();

    /*
    Used by: PortalTimesheetViewEntry, PortalExpenseViewEntry, PortalTimesheetsHome, PortalExpensesHome
    Why? : to be able to change the styling based on the status picklist value
    */
    //add and remove styling based on the status
    $('#table_id td.status #theStatus').each(function(){
	console.log('remove style');
       var theStatus = $(this).text();
        console.log(theStatus);
       if(theStatus == 'New'){
           //console.log('New');
           $(this).addClass("statusNew");
           $(this).removeClass("statusApproved statusSubmitted statusRejected");
       }else if(theStatus == 'Approved'){
           //console.log('Approved');
           $(this).addClass("statusApproved");
           $(this).removeClass("statusNew  statusSubmitted statusRejected");
       }else if(theStatus == 'Submitted'){
           //console.log('Approved');
           $(this).addClass("statusSubmitted");
           $(this).removeClass("statusNew statusApproved statusRejected");
       }else if(theStatus == 'Rejected'){
           //console.log('Approved');
           $(this).addClass("statusRejected");
           $(this).removeClass("statusNew statusApproved statusSubmitted");
       }else{
           $(this).removeClass();
       }
    });
    /*
    Used by: PortalProfileTaxDetails
    Why? : to be able to render sections correctly as the user completes the tax questions
    */
    //default all sections to be hidden initially
    jQuery('[id$=div_reasonTFN]').hide();
    jQuery('[id$=div_hasTFN]').hide();
    jQuery('[id$=div_DecForm]').hide();

    jQuery('[id$=div_Loan]').hide();
    jQuery('[id$=div_Debt]').hide();

    //show/hide tax fields
    jQuery('input:radio[name$=tfnRadio]').change(function(){
       var radio_value = $(this).val();
        if(radio_value == 'no'){
            jQuery('[id$=div_reasonTFN]').show();
            jQuery('[id$=div_hasTFN]').hide();
            jQuery('[id$=div_DecForm]').hide();
        }else if(radio_value == 'yes'){
            jQuery('[id$=div_reasonTFN]').hide();
            jQuery('[id$=div_hasTFN]').show();
            jQuery('[id$=div_DecForm]').show();
        }else{
            jQuery('[id$=div_reasonTFN]').hide();
            jQuery('[id$=div_hasTFN]').hide();
            jQuery('[id$=div_DecForm]').hide();
        }
    });
    jQuery('input:radio[name$=tfnReasonRadio]').change(function(){
       var radio_value = $(this).val();
        if(radio_value == 'newApp'){
            jQuery('[id$=div_reasonTFN]').show();
            jQuery('[id$=div_DecForm]').show();
        }else if(radio_value == 'under18'){
            jQuery('[id$=div_reasonTFN]').show();
            jQuery('[id$=div_DecForm]').show();
        }else if(radio_value == 'exemptClaim'){
            jQuery('[id$=div_reasonTFN]').show();
            jQuery('[id$=div_DecForm]').show();
        }else{
            jQuery('[id$=div_reasonTFN]').hide();
            jQuery('[id$=div_DecForm]').show();
        }
    });
    jQuery('input:radio[name$=loanRadio]').change(function(){
       var radio_value = $(this).val();
        if(radio_value == 'yes'){
            jQuery('[id$=div_Loan]').show();
        }else if(radio_value == 'no'){
            jQuery('[id$=div_Loan]').hide();
        }else{
            jQuery('[id$=div_Loan]').hide();
        }
    });
    jQuery('input:radio[name$=debtRadio]').change(function(){
       var radio_value = $(this).val();
        if(radio_value == 'yes'){
            jQuery('[id$=div_Debt]').show();
        }else if(radio_value == 'no'){
            jQuery('[id$=div_Debt]').hide();
        }else{
            jQuery('[id$=div_Debt]').hide();
        }
    });


    /*
    Used by: PortalProfileSuperDetails
    Why? : to be able to render sections correctly as the user completes the super details
    */
    //default all sections to be hidden initially
    jQuery('[id$=div_apraRSA]').hide();
    //jQuery('[id$=div_superOutput').show();
    jQuery('[id$=div_SMSF]').hide();
    jQuery('[id$=div_empNom]').hide();
    jQuery('[id$=showSave]').hide();
    jQuery('[id$=div_apraRSA_2]').hide();
    jQuery('[id$=div_haveNum]').hide();

    //show/hide Super Edit fields
    jQuery('input:radio[name$=superRadio]').change(function(){
        var radio_value = $(this).val();
        if(radio_value == 'apraRSA'){
            jQuery('[id$=div_apraRSA]').show();
            jQuery('[id$=div_SMSF]').hide();
            jQuery('[id$=div_empNom]').hide();
            jQuery('[id$=showSave]').show();
        }else if(radio_value == 'smsf'){
            jQuery('[id$=div_apraRSA]').hide();
            jQuery('[id$=div_SMSF]').show();
            jQuery('[id$=div_empNom]').hide();
            jQuery('[id$=showSave]').show();
        }else if(radio_value == 'empNom'){
            jQuery('[id$=div_apraRSA]').hide();
            jQuery('[id$=div_SMSF]').hide();
            jQuery('[id$=div_empNom]').show();
            jQuery('[id$=showSave]').show();
        }else{
            jQuery('[id$=div_apraRSA]').hide();
            jQuery('[id$=div_SMSF]').hide();
            jQuery('[id$=div_empNom]').hide();
            jQuery('[id$=showSave]').hide();
        }
    });
    //show/hide Super Edit fields
    jQuery('input:radio[name$=superRadio_2]').change(function(){
        var radio_value = $(this).val();
        if(radio_value == 'Yes'){
            jQuery('[id$=div_haveNum]').show();
            jQuery('[id$=showSave]').show();

        }else if(radio_value == 'No'){
            jQuery('[id$=div_haveNum]').hide();
            jQuery('[id$=showSave]').show();
        }else{
            jQuery('[id$=div_haveNum]').hide();
            jQuery('[id$=showSave]').hide();
        }
    });


    //get ready for Google address autocomplete
    initialize();
});
/*
Used by: PortalProfileSuperDetails
Why? : to be able to auto-search for a super fund
*/
//this section auto-searches funds for APRA/RSA
var PLACEHOLDER1 = 'Enter Fund Name Here';
var fundObjects;
var queryTerm;
jQuery('[id$=div_apraRSA_2]').hide();

//Fund text input area for APRA/RSA
$('[id$=fundTextBox]').autocomplete({

    minLength: 3,
    source: function(request, response) {
        queryTerm = request.term;
        Portal_ProfileSuperDetails_Controller.searchFund(request.term, function(result, event){
            if(event.type == 'exception') {
                alert(event.message);
            } else {
                        fundObjects = result;
                        response(fundObjects);
                        console.log('fundObjects: ',fundObjects);
                    }
        });
    },
    focus: function( event, ui ) {
        console.log('FOCUS event: ',event,'ui: ',ui);
        $('[id$=fundTextBox]').val( ui.item.Super_Search_Field__c );
        return false;
    },
    select: function( event, ui ) {
        console.log('SELECT event: ',event,'ui: ',ui);
        $('[id$=fundTextBox]').val( ui.item.Super_Search_Field__c );
        $('[id$=searchFundId]').val( ui.item.Id );
        paraFunctionFS(ui.item.value);
        jQuery('[id$=div_apraRSA_2]').show();
        return false;
    }
}).data("ui-autocomplete" )._renderItem = function( ul, item ) {
    var entry = "<a>" + item.Super_Search_Field__c;

    entry = entry + "</a>";
    entry = entry.replace(queryTerm, "<b>" + queryTerm + "</b>");

    return $( "<li></li>" )
    .data( "ui-autocomplete-item", item )
    .append( entry )
    .appendTo( ul );
};


// Add or remove placeholder values
$('[id$=fundTextBox]').val(PLACEHOLDER1);
$('[id$=fundTextBox]').on("focus",  function(event){
    $tgt = $(event.target);
    if($tgt.val() === PLACEHOLDER1 ){
        $tgt.val('');
        $tgt.removeClass('placeHolder');
    }
});
$('[id$=fundTextBox]').on( "blur",  function(event){
    $tgt = $(event.target);
    console.log('BLUR',event);
    if($tgt.val() === '' ){
        $tgt.val(PLACEHOLDER1);
        $tgt.addClass('placeHolder');
    }
});


/*
Used by: PortalProfileCompanyDetails, PortalProfilePersonalDetails
Why? : to be able to autocomplete address details using the Google API
*/
// This example displays an address form, using the autocomplete feature
// of the Google Places API to help users fill in the information.
var autoCompleteOne;

function initialize() {

    // Create the autocomplete object, restricting the search
    // to geographical location types.
    autoCompleteOne = new google.maps.places.Autocomplete(
        (document.getElementById('autocomplete_one')),
        { types: ['geocode'] });

    // When the user selects an address from the dropdown,
    // populate the address fields in the form.
    google.maps.event.addListener(autoCompleteOne, 'place_changed', function() {
        fillInAddress('one');
    });
}

function fillInAddress(addressNo) {

    var place;

    // Get the place details from the autocomplete object.
    if (addressNo == 'one') {
        place = autoCompleteOne.getPlace();
    }

    // Variables to extract from response
    var street = '';
    var city = '';
    var state = '';
    var postcode = '';
    var country = '';

    // Get each component of the address from the place details
    // and fill the corresponding field on the form.
    for (var i = 0; i < place.address_components.length; i++) {

        // The Google address type
        var addressType = place.address_components[i].types[0];

        // Set address variables
        if (addressType == 'street_number') {
            street = place.address_components[i]['long_name'];
        }
        else if (addressType == 'route') {
            street += ' ' + place.address_components[i]['long_name'];
        }
        else if (addressType == 'locality') {
            city = place.address_components[i]['long_name'];
        }
        else if (addressType == 'administrative_area_level_1') {
            state = place.address_components[i]['long_name'];
        }
        else if (addressType == 'administrative_area_level_2' && state == '') {
            state = place.address_components[i]['long_name'];
        }
        else if (addressType == 'country') {
            country = place.address_components[i]['long_name'];
        }
        else if (addressType == 'postal_code') {
            postcode = place.address_components[i]['long_name'];
        }
    }

    // Pass values to input fields
    $('.' + addressNo + 'Street').val(street);
    $('.' + addressNo + 'City').val(city);
    $('.' + addressNo + 'State').val(state);
    $('.' + addressNo + 'PostalCode').val(postcode);
    $('.' + addressNo + 'Country').val(country);
}

/*AUS or INT BANK ON CHANGE FUNCTION*/
function radioBankType(evt,val){
    console.log('bank toggle radioBankType');

    var radio_value= val.value;

    console.log('radio_value:: ',radio_value);

    /* show/hide Aus or Int bank details
    ** If Aus selected show BA 1 details, and assume Pay entire,
    ** unless user selects to add another account */

    if(radio_value == 'aus1'){

        document.getElementById('divAusBank').style.display = "block";
        document.getElementById('divBankAcc2').style.display = "block";

        document.getElementById('chooseAlloc_BA1').style.display = "none";
        document.getElementById('divYes2').style.display = "none";
        document.getElementById('divIntBank').style.display = "none";
        document.getElementById('divPercent1').style.display = "none";
        document.getElementById('divFixed1').style.display = "none";
        //jQuery('[id$=divAusBank]').show();
        //jQuery('[id$=chooseAlloc_BA1').hide();
        //jQuery('[id$=divBankAcc2').show();
        //jQuery('[id$=divYes2').hide();
        //jQuery('[id$=divIntBank]').hide();

    }
    if(radio_value == 'int1'){
        document.getElementById('divAusBank').style.display = "none";
        document.getElementById('divIntBank').style.display = "block";
        //jQuery('[id$=divAusBank]').hide();
        //jQuery('[id$=divIntBank]').show();
    }
}
/*AUS BANK ACCOUNT 2 ON CHANGE FUNCTION*/
function radio_chgBA2(evt,val){
    console.log('bank toggle radio_chgBA2');

    var radio_value= val.value;
    var bAlloc1 = $('input:radio[name$=Allocation1]:checked' ).val();

    checkPercentTotal();

    console.log('radio_value:: ',radio_value);

    //Want to do Bank Account 2?

    if(radio_value == 'Yes'){
        document.getElementById('divYes2').style.display = "block";
        document.getElementById('divBankAcc2').style.display = "block";
        document.getElementById('chooseAlloc_BA1').style.display = "block";
        document.getElementById('divBankAcc3').style.display = "block";
        /*jQuery('[id$=divYes2]').show();
        jQuery('[id$=divBankAcc2]').show();
        jQuery('[id$=chooseAlloc_BA1').show();
        jQuery('[id$=divBankAcc3]').show();*/

        document.getElementById('chooseAlloc_BA2').style.display = "none";
        document.getElementById('pR1info').style.display = "none";
        //jQuery('[id$=chooseAlloc_BA2').hide();

        if(bAlloc1 == 'percent1'){
            document.getElementById('divPercent1').style.display = "block";
            //jQuery('[id$=divPercent1]').show();
        }
        if(bAlloc1 == 'fixed1'){
            document.getElementById('divFixed1').style.display = "block";
            //jQuery('[id$=divFixed1]').show();
        }
    }
    if(radio_value == 'No'){
        document.getElementById('divYes2').style.display = "none";
        document.getElementById('divBankAcc3').style.display = "none";
        document.getElementById('chooseAlloc_BA1').style.display = "none";
        document.getElementById('divPercent1').style.display = "none";
        document.getElementById('divFixed1').style.display = "none";

        /*jQuery('[id$=divYes2]').hide();
        jQuery('[id$=divBankAcc3]').hide();
        jQuery('[id$=chooseAlloc_BA1').hide();
        jQuery('[id$=divPercent1').hide();
        jQuery('[id$=divFixed1').hide();*/

        document.getElementById('pR1info').style.display = "block";
        document.getElementById('theSave').style.display = "block";
        document.getElementById('theCancel').style.display = "none";
        /*jQuery('[id$=pR1info').show();
        jQuery('[id$=theSave]').show();
        jQuery('[id$=theCancel]').hide();*/
    }
}

//CHECK PERCENT OR FIXED FOR AUS BANK ACC 1
function radio_Allocation1(evt,val) {
    console.log('bank toggle radio_Allocation1');

    var radio_value= val.value;

    checkPercentTotal();

    console.log('radio_value:: ',radio_value);

    if(radio_value == 'percent1'){
        document.getElementById('divPercent1').style.display = "block";
        document.getElementById('divFixed1').style.display = "none";
        /*jQuery('[id$=divPercent1').show();
        jQuery('[id$=divFixed1').hide();*/
    }
    if(radio_value == 'fixed1'){
        document.getElementById('divFixed1').style.display = "block";
        document.getElementById('divPercent1').style.display = "none";

        /*jQuery('[id$=divFixed1').show();
        jQuery('[id$=divPercent1').hide();*/
    }
}
//show/hide Bank Account 3 based on selection
function radio_chgBA3(evt,val){
    console.log('bank toggle radio_chgBA3');

    var radio_value= val.value;
    var bAlloc1 = $('input:radio[name$=Allocation1]:checked' ).val();
    var bAlloc2 = $('input:radio[name$=Allocation2]:checked' ).val();

    checkPercentTotal();

    console.log('radio_value:: ',radio_value);

    if(radio_value == 'Yes'){
        document.getElementById('divYes3').style.display = "block";
        document.getElementById('divBankAcc3').style.display = "block";
        document.getElementById('chooseAlloc_BA2').style.display = "block";
        document.getElementById('pR2info').style.display = "none";
        /*jQuery('[id$=divYes3]').show();
        jQuery('[id$=divBankAcc3]').show();
        jQuery('[id$=chooseAlloc_BA2').show();
        jQuery('[id$=pR2info]').hide();*/

        if(bAlloc1 == 'percent1'){
            document.getElementById('divPercent1').style.display = "block";
            //jQuery('[id$=divPercent1]').show();
        }
        if(bAlloc1 == 'fixed1'){
            document.getElementById('divFixed1').style.display = "block";
            //jQuery('[id$=divFixed1]').show();
        }
        if(bAlloc2 == 'percent2'){
            document.getElementById('divPercent2').style.display = "block";
            //jQuery('[id$=divPercent2]').show();
        }
        if(bAlloc2 == 'fixed2'){
            document.getElementById('divFixed2').style.display = "block";
            //jQuery('[id$=divFixed2]').show();
        }
    }
    if(radio_value == 'No'){
        document.getElementById('divYes3').style.display = "none";
        document.getElementById('chooseAlloc_BA2').style.display = "none";
        document.getElementById('divPercent2').style.display = "none";
        document.getElementById('divFixed2').style.display = "none";
        document.getElementById('pR2info').style.display = "block";

        /*jQuery('[id$=divYes3]').hide();
          jQuery('[id$=chooseAlloc_BA2').hide();
          jQuery('[id$=divPercent2]').hide();
          jQuery('[id$=divFixed2]').hide();
          jQuery('[id$=pR2info]').show();*/
    }

}

//CHECK PERCENT OR FIXED FOR AUS BANK ACC 2
function radio_Allocation2(evt,val) {
    console.log('bank toggle radio_Allocation2');

    var radio_value= val.value;
    var bAlloc1 = $('input:radio[name$=Allocation1]:checked' ).val();

    checkPercentTotal();

    console.log('radio_value:: ',radio_value);

    if(radio_value == 'percent2'){
        document.getElementById('divPercent2').style.display = "block";
        document.getElementById('divFixed2').style.display = "none";
        /*jQuery('[id$=divPercent2').show();
        jQuery('[id$=divFixed2').hide();*/
    }
    if(radio_value == 'fixed2'){
        document.getElementById('divFixed2').style.display = "block";
        document.getElementById('divPercent2').style.display = "none";

        /*jQuery('[id$=divFixed1').show();
        jQuery('[id$=divPercent1').hide();*/
    }
    if(bAlloc1 == 'percent1'){
        document.getElementById('divPercent1').style.display = "block";
        //jQuery('[id$=divPercent1]').show();
    }
    if(bAlloc1 == 'fixed1'){
        document.getElementById('divFixed1').style.display = "block";
        //jQuery('[id$=divFixed1]').show();
    }
}

/*
Used by: PortalExpensesHome
Why? : to be able to navigate the diff Expense status tabs and have the
styling display correctly
*/
//change div based on tab clicked
function openStatusTab(evt, tabName) {
    var i, x, tablinks;
	console.log('inside openstatus');
    x = document.getElementsByClassName("tsTab");
	console.log('tstab >>> ' + x);
    for (i = 0; i < x.length; i++) {
	console.log('inside openstatus1');
        x[i].style.display = "none";
    }
    tablinks = document.getElementsByClassName("tablink");
	console.log('length ::' + document.getElementsByClassName("tablink")[0].id);
	console.log('length1 ::' + document.getElementsByClassName("tablink")[1].id);
	console.log('length1 ::' + document.getElementsByClassName("tablink")[2].id);
	
    for (i = 0; i < x.length; i++) {
	console.log('inside openstatus2');
	console.log('cls >>> ' + tablinks[i]);
	console.log('cls111 >>> ' + tablinks[i].className);
        tablinks[i].className = tablinks[i].className.replace(" w3-border-red", "");
    }
    document.getElementById(tabName).style.display = "block";
  // evt.currentTarget.firstElementChild.className += "w3-border-red"; //commented this line due to reason that switching over the tabs didn't work
}
/*
Used by: PortalTimesheetViewEntry
Why? : to be able to navigate the days of the week via tabs and have the
styling display correctly
*/
//change div based on tab clicked
function openTStab(evt, tabName) {
    var i, x, tablinks;
    x = document.getElementsByClassName("tsTab");
    for (i = 0; i < x.length; i++) {
        x[i].style.display = "none";
    }
    tablinks = document.getElementsByClassName("tablink");
    for (i = 0; i < x.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" selectedTimeEntry", "");
    }
    document.getElementById(tabName).style.display = "block";
    evt.currentTarget.firstElementChild.className += " selectedTimeEntry";
}
//for mobile Timesheet Entry - it works differently
function openTStabM(evt, tabName) {

    var i, x, tablinks,tsm;
    x = document.getElementsByClassName("tsTabM");
    tsm = document.getElementsByClassName("tsDayMenu");

    for (i = 0; i < x.length; i++) {
        x[i].style.display = "none";
    }
    for (i = 0; i < tsm.length; i++) {
        tsm[i].style.display = "none";
    }
    tablinks = document.getElementsByClassName("tablink");
    for (i = 0; i < x.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" selectedTimeEntry", "");
        x[i].className = x[i].className.replace(" tsTabMHide","");
    }
    document.getElementById(tabName).style.display = "block";
    evt.currentTarget.firstElementChild.className += " selectedTimeEntry";
    document.getElementById("weekView").style.display = "none";
    document.getElementById("weekViewLink").style.display = "none";
    document.getElementById("allDays").style.display = "block";

}

//Used by the (Mobile) Timesheet Entry Page
function goBackToTSEMenu(evt, tabName){
  var tsm, x;
  tsm = document.getElementsByClassName("tsDayMenu");
  x = document.getElementsByClassName("tsTabM");

  for (i = 0; i < tsm.length; i++) {
       tsm[i].style.display = "block";
  }
  for (i = 0; i < x.length; i++) {
      x[i].className = x[i].style.display = "none";
  }
    document.getElementById("weekView").style.display = "block";
    document.getElementById("weekViewLink").style.display = "block";
    document.getElementById("allDays").style.display = "none";
}

//change Entry div from read to edit and vice versa
function toggleEntry(evt, divNameBlock, divNameNone){
    console.log('toggle: ',divNameBlock,divNameNone);
        document.getElementById(divNameBlock).style.display = "block";
        document.getElementById(divNameNone).style.display = "none";
}
//Highlight the correct tab in the time entry page
function highlightTab(evt, tabName) {
    document.getElementById(tabName).style.display = "block";
    evt.currentTarget.firstElementChild.className += " selectedTimeEntry";
}


/*
Used by: PortalContracts
Why? : to be able to open an Agreement in a popup window
*/

function openModal(myUrl){

        var newWin = window.open(myUrl,'Modal','modal=1,height=1200,width=1000,left=150,top=100,resizable=no,scrollbars=yes,toolbar=no,status=no,location=no');

    }

/*
Used by: PortalTimesheetViewEntry, PortalExpenseViewEntry, PortalTimesheetsHome, PortalExpensesHome
Why? : to be able to change the styling based on the status picklist value
*/
//add and remove styling based on the status
$(document).ready(function(){
    $('#table_id td.status #theStatus').each(function(){
       var theStatus = $(this).text();
        //console.log(theStatus);
       if(theStatus == 'New'){
           //console.log('New');
           $(this).addClass("statusNew");
           $(this).removeClass("statusApproved statusSubmitted statusRejected");
       }else if(theStatus == 'Approved'){
           //console.log('Approved');
           $(this).addClass("statusApproved");
           $(this).removeClass("statusNew  statusSubmitted statusRejected");
       }else if(theStatus == 'Submitted'){
           //console.log('Approved');
           $(this).addClass("statusSubmitted");
           $(this).removeClass("statusNew statusApproved statusRejected");
       }else if(theStatus == 'Rejected'){
           //console.log('Approved');
           $(this).addClass("statusRejected");
           $(this).removeClass("statusNew statusApproved statusSubmitted");
       }else{
           $(this).removeClass();
       }
    });
});

/* ValidateABN
* Used by PortalProfileSuperDetails
* Why??
*  Checks ABN for validity using the published ABN checksum algorithm.
*  To verify an ABN:
*  To verify an ABN:
*  1. Subtract 1 from the first (left) digit to give a new eleven digit number
*  2. Multiply each of the digits in this new number by its weighting factor
*  3. Sum the resulting 11 products
*  4. Divide the total by 89, noting the remainder
*  5. If the remainder is zero the number is valid
*/

function validateABN (val, buttonId) {

	var weights, abn, result;

    weights = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19];
    abn = val.value;
    result = false;

    //console.log('onBlur happened, got abn value',abn);

    if (abn.length != 11) {
        alert("Error, the Australian Business Number should contain exactly 11 characters !");
        jQuery('[id$=abnEntryError]').show();
        //hide save button
        buttonId.hide();
        //exit;
    }

	// check length is 11 digits
	if (abn.length === 11) {
	    //console.log('we are validating');

		// apply ato check method
		var sum = 0, weight;
		for (var index = 0; index <= weights.length - 1; index++) {
			weight = weights[index];
			digit = abn[index] - (index ? 0 : 1);
			sum += weight * digit;
		}
		result = sum % 89 === 0;
		//console.log('result',result);

		if(result == false){
		    alert("Error, the ABN you have entered is invalid !");
		    jQuery('[id$=abnEntryError]').show();
            //hide save button
            buttonId.hide();
		   // exit;
		}else if(result == true){
		    //make sure we can save and hide the error message
		    jQuery('[id$=abnEntryError]').hide();
            //hide save button
            buttonId.show();
            //exit;
		}
	}
	return result;
}

function validateTFN(val, buttonId,msgId){
     var tfn = val.value;
     console.log(tfn);
     //$('#tfn').val();

     //remove spaces and update
     tfn = tfn.replace(/\s+/g, '');
     $('#tfn').val(tfn);

     //remove hyphens and update
     tfn = tfn.replace(/[-]/g, '');
     $('#tfn').val(tfn);

     //validate only digits
     var isNumber = /^[0-9]+$/.test(tfn);
     console.log('isNumber',isNumber);
     if(!isNumber) {
         //return doError('Invalid TFN, only numbers are allowed.');
         buttonId.hide();
         msgId.show();
     }

     //validate length
     var length = tfn.length;
     console.log('length:',length);
     if(length != 9) {
         //return doError('Invalid TFN, must have 9 digits.');
         buttonId.hide();
         msgId.show();
     }

     var digits = tfn.split('');

     //do the calcs
     var sum = (digits[0]*1)
             + (digits[1]*4)
             + (digits[2]*3)
             + (digits[3]*7)
             + (digits[4]*5)
             + (digits[5]*8)
             + (digits[6]*6)
             + (digits[7]*9)
             + (digits[8]*10);

     var remainder = sum % 11;

     if(remainder == 0) {
         //doSuccess('Valid TFN, hooray!');

        buttonId.show();
        msgId.hide();
     } else {
         //return doError('Invalid TFN, check the digits.');
         buttonId.hide();
         msgId.show();
     }
}

//Used by PortalProfileBankDetails to check if the Fixed Amount is to 2 decimal places
function isMoney(val,msgId){

    var theNum = val.value;
    var num = parseFloat(theNum);
    var cleanNum = num.toFixed(2);

    console.log('num: ',num);
    console.log('cleanNum: ',cleanNum);

    if(num/cleanNum < 1) {
        msgId.show();
    }else{
        msgId.hide();
    }

}

function isNumberDecimal(evt){
    var charCode = (evt.which) ? evt.which : event.keyCode

    console.log('evt charCode:',charCode);

    if (charCode != 46 && charCode > 31 && (charCode < 48 || charCode > 57)){
        console.log('NOPE');
        return false;
    }
    return true;
}

//Used by PortalTimesheetViewEntry, PortalProfileSuperDetails, PortalProfileBankDetails
//Only allow numbers to be entered into a text field
function isNumberKey(evt)
{
    var charCode = (evt.which) ? evt.which : event.keyCode


    console.log('evt charCode:',charCode);
    //alert('evt charCode:'+charCode);


    if (charCode > 31 && (charCode < 48 || charCode > 57)){
        return false;
    }

    return true;
}
/*check Phone number format*/
function isPhNumKey(evt){
    var charCode = (evt.which) ? evt.which : event.keyCode

        console.log('evt charCode:',charCode);

        if (charCode > 31 && charCode != 43 && (charCode < 48 || charCode > 57)){
            return false;
        }
        return true;
    }

    /*check email format*/
    function checkEmail(sEmail,buttonId,inputId,errorMsgId){

        console.log('EMAIL:',sEmail);
        var filter = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if (filter.test(sEmail)) {
            errorMsgId.css("display","none");
            buttonId.show();
            inputId.css("background-color","");
            inputId.css("color","#4C5E70");
            return true;
        }
        else {
            //alert('Please enter a valid email address');
            errorMsgId.css("display","block");
            buttonId.hide();
            inputId.css("background-color","red");
            inputId.css("color","white");
        }
    }
/*
Used by: PortalProfileCompanyDetails, PortalProfileBankDetails
Why? : to be able to confirm the user has provided the 100% accumulation for
all bank accounts prior to allowing them to save.
*/
//this function will check if we are over or under 100%
//and prevent user from saving, a message will also be presented to the user
//function updated as we have more preventative measures in the process flow now

function checkPercentTotal(){

    var p1, p2, p3, ptot;

    var pA1 = $('input:radio[name$=Allocation1]:checked' ).val();
    var pA2 = $('input:radio[name$=Allocation2]:checked' ).val();

    var pB2 = $('input:radio[name$=chgBA2]:checked').val();
    var pB3 = $('input:radio[name$=chgBA3]:checked' ).val();

    p1 = jQuery('[id$=perTot1]').val();
    p2 = jQuery('[id$=perTot2]').val();

    /*console.log('pA1: ', pA1);
    console.log('pA2: ', pA2);
    console.log('pB2: ', pB2);
    console.log('pB3: ', pB3);*/

    //only check we are not over 100 on Bank Acc 1
    if(pA1 == 'percent1' && pA2 != 'percent2'){

        ptot=p1/1;

        if(ptot > 100){
            console.log('We are over B1!');

            jQuery('[id$=theSave]').hide();
            jQuery('[id$=theCancel]').show();

            jQuery('[id$=showTotalInfo_overA]').show();
            jQuery('[id$=showSaveError]').show();
        }else {

            console.log('We are ok for B1!');

            jQuery('[id$=theSave]').show();
            jQuery('[id$=theCancel]').hide();
            jQuery('[id$=showSaveError]').hide();

            jQuery('[id$=showTotalInfo_overA]').hide();
        }
    }
    if(pA1 != 'percent1'){
        p1 = 0;
        console.log('We are ok for B1!');

        jQuery('[id$=theSave]').show();
        jQuery('[id$=theCancel]').hide();
        jQuery('[id$=showSaveError]').hide();

        jQuery('[id$=showTotalInfo_overA]').hide();
    }

    if(pA1 == 'fixed1' && pA2 == 'fixed2'){

        ptot = 0;
        console.log('1 and 2 are fixed');

        jQuery('[id$=showTotalInfo_overA]').hide();
        jQuery('[id$=showTotalInfo_underA]').hide();
        jQuery('[id$=showTotalInfo_overB]').hide();
        jQuery('[id$=showTotalInfo_underB]').hide();
        jQuery('[id$=theSave]').show();
        jQuery('[id$=theCancel]').hide();
    }
    //if we want a 2nd & 3rd Bank Account lets check the total % for BA1 and BA2
    if(pA2 == 'percent2' && pB2 == 'Yes'){
        console.log('time to include B2');

        ptot = p1/1+p2/1;

        if(ptot > 100){
            console.log('We are over B1&B2!--> ptot: ',ptot);

            jQuery('[id$=theSave]').hide();
            jQuery('[id$=theCancel]').show();

            jQuery('[id$=showTotalInfo_overA]').show();
            jQuery('[id$=showTotalInfo_overB]').show();
            jQuery('[id$=showSaveError]').show();
        }else {
            console.log('We are ok for B1 & B2!');

            jQuery('[id$=theSave]').show();
            jQuery('[id$=theCancel]').hide();

            jQuery('[id$=showTotalInfo_overA]').hide();
            jQuery('[id$=showTotalInfo_overB]').hide();
            jQuery('[id$=showSaveError]').hide();
        }
    }

    /*if(pB2 == 'No' ){
        console.log('All OK Only B1');

        jQuery('[id$=showTotalInfo_overA]').hide();
        jQuery('[id$=showTotalInfo_underA]').hide();
        jQuery('[id$=showTotalInfo_overB]').hide();
        jQuery('[id$=showTotalInfo_underB]').hide();
        jQuery('[id$=theSave]').show();
        jQuery('[id$=theCancel]').hide();
    }else if(pB3 == 'Yes' ){
        console.log('All OK we have a B3');

        jQuery('[id$=showTotalInfo_overA]').hide();
        jQuery('[id$=showTotalInfo_underA]').hide();
        jQuery('[id$=showTotalInfo_overB]').hide();
        jQuery('[id$=showTotalInfo_underB]').hide();
        jQuery('[id$=theSave]').show();
        jQuery('[id$=theCancel]').hide();
    }*/

    console.log('p1:', p1, 'p2: ', p2, 'p3: ',p3);
    console.log('ptot:', ptot);

}

//Used by PortalExpenseViewEntry
//Check if Description is blank
function descCannotBeBlank(evt,type,val){

    var textCheck = jQuery('[id$=descD]').val();
    var textCheck2 = jQuery('[id$=descDd]').val();
    var theCheck = val;
    console.log('theCheck',theCheck);
    console.log('textCheck: ',textCheck);
    console.log('textCheck2: ',textCheck2);


    if(type == 'm'){
        if(textCheck == '' || theCheck==''){
           jQuery('[id$=descDSave]').css("display","none");
           jQuery('[id$=descD]').css("background-color","red");
           jQuery('[id$=error_DescD]').css("display","block");
        }else{
           jQuery('[id$=descDSave]').css("display","block");
           jQuery('[id$=descD]').css("background-color","");
           jQuery('[id$=error_DescD]').css("display","none");
        }
    }else if(type == 'dt' ){
        if(textCheck2 =='' || theCheck==''){
           jQuery('[id$=descDdSave]').css("display","none");
           jQuery('[id$=descDd]').css("background-color","red");
           jQuery('[id$=error_DescDd]').css("display","block");
        }else{
           jQuery('[id$=descDdSave]').css("display","block");
           jQuery('[id$=descDd]').css("background-color","");
           jQuery('[id$=error_DescDd]').css("display","none");
        }
    }

}

//Used by PortalTimesheetViewEntry,
//Check if hrs and mins entered are valid
//Check if break start end times are between Start End
//Check if break start is before break end
//Handle midnight boundaries

//so that we can handle iPhone, we need to get all the values after the event trigger, so each of the following functions will
//be called by each day and type so we have all the values we need before passing through the validation function

function mobDayTimeCheck(evt,type,day,mD){

    var startHrs,startMins,endHrs,endMins,bStartHrs,bStartMins,bEndHrs,bEndMins,timeCheck,timeType,timeError,breakError,saveButton,cellCSSvar;
    

    //type will be: sHrs, sMins, eHrs, eMins, bShrs, bSmins, bEhrs, bEmins and this will determine the values for timeCheck and cellCSSvar
    //mD determines if this is for mobile or desktop;

    if(mD == 'm'){
        if(day == '1'){
            startHrs = jQuery('[id$=sthrs_md1]').val();
            startMins = jQuery('[id$=stmins_md1]').val();
            endHrs = jQuery('[id$=endhrs_md1]').val();
            endMins = jQuery('[id$=endmins_md1]').val();
            bStartHrs = jQuery('[id$=bShrs_md1]').val();
            bStartMins = jQuery('[id$=bSmins_md1]').val();
            bEndHrs = jQuery('[id$=bEhrs_md1]').val();
            bEndMins = jQuery('[id$=bEmins_md1]').val();
            timeError = jQuery('[id$=tEError_DM1]');
            breakError = jQuery('[id$=tEError_DM1_BT2]');
            saveButton = jQuery('[id$=saveD1M]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_md1]').val();cellCSSvar = jQuery('[id$=sthrs_md1]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_md1]').val();cellCSSvar = jQuery('[id$=stmins_md1]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_md1]').val();cellCSSvar = jQuery('[id$=endhrs_md1]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_md1]').val();cellCSSvar = jQuery('[id$=endmins_md1]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_md1]').val();cellCSSvar = jQuery('[id$=bShrs_md1]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_md1]').val();cellCSSvar = jQuery('[id$=bSmins_md1]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_md1]').val();cellCSSvar = jQuery('[id$=bEhrs_md1]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_md1]').val();cellCSSvar = jQuery('[id$=bEmins_md1]');timeType = 'mins';}
        }
        if(day == '2'){
            startHrs = jQuery('[id$=sthrs_md2]').val();
            startMins = jQuery('[id$=stmins_md2]').val();
            endHrs = jQuery('[id$=endhrs_md2]').val();
            endMins = jQuery('[id$=endmins_md2]').val();
            bStartHrs = jQuery('[id$=bShrs_md2]').val();
            bStartMins = jQuery('[id$=bSmins_md2]').val();
            bEndHrs = jQuery('[id$=bEhrs_md2]').val();
            bEndMins = jQuery('[id$=bEmins_md2]').val();
            timeError = jQuery('[id$=tEError_DM2]');
            breakError = jQuery('[id$=tEError_DM2_BT2]');
            saveButton = jQuery('[id$=saveD2M]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_md2]').val();cellCSSvar = jQuery('[id$=sthrs_md2]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_md2]').val();cellCSSvar = jQuery('[id$=stmins_md2]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_md2]').val();cellCSSvar = jQuery('[id$=endhrs_md2]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_md2]').val();cellCSSvar = jQuery('[id$=endmins_md2]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_md2]').val();cellCSSvar = jQuery('[id$=bShrs_md2]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_md2]').val();cellCSSvar = jQuery('[id$=bSmins_md2]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_md2]').val();cellCSSvar = jQuery('[id$=bEhrs_md2]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_md2]').val();cellCSSvar = jQuery('[id$=bEmins_md2]');timeType = 'mins';}
        }
        if(day == '3'){
            startHrs = jQuery('[id$=sthrs_md3]').val();
            startMins = jQuery('[id$=stmins_md3]').val();
            endHrs = jQuery('[id$=endhrs_md3]').val();
            endMins = jQuery('[id$=endmins_md3]').val();
            bStartHrs = jQuery('[id$=bShrs_md3]').val();
            bStartMins = jQuery('[id$=bSmins_md3]').val();
            bEndHrs = jQuery('[id$=bEhrs_md3]').val();
            bEndMins = jQuery('[id$=bEmins_md3]').val();
            timeError = jQuery('[id$=tEError_DM3]');
            breakError = jQuery('[id$=tEError_DM3_BT2]');
            saveButton = jQuery('[id$=saveD3M]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_md3]').val();cellCSSvar = jQuery('[id$=sthrs_md3]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_md3]').val();cellCSSvar = jQuery('[id$=stmins_md3]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_md3]').val();cellCSSvar = jQuery('[id$=endhrs_md3]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_md3]').val();cellCSSvar = jQuery('[id$=endmins_md3]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_md3]').val();cellCSSvar = jQuery('[id$=bShrs_md3]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_md3]').val();cellCSSvar = jQuery('[id$=bSmins_md3]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_md3]').val();cellCSSvar = jQuery('[id$=bEhrs_md3]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_md3]').val();cellCSSvar = jQuery('[id$=bEmins_md3]');timeType = 'mins';}
        }
        if(day == '4'){
            startHrs = jQuery('[id$=sthrs_md4]').val();
            startMins = jQuery('[id$=stmins_md4]').val();
            endHrs = jQuery('[id$=endhrs_md4]').val();
            endMins = jQuery('[id$=endmins_md4]').val();
            bStartHrs = jQuery('[id$=bShrs_md4]').val();
            bStartMins = jQuery('[id$=bSmins_md4]').val();
            bEndHrs = jQuery('[id$=bEhrs_md4]').val();
            bEndMins = jQuery('[id$=bEmins_md4]').val();
            timeError = jQuery('[id$=tEError_DM4]');
            breakError = jQuery('[id$=tEError_DM4_BT2]');
            saveButton = jQuery('[id$=saveD4M]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_md4]').val();cellCSSvar = jQuery('[id$=sthrs_md4]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_md4]').val();cellCSSvar = jQuery('[id$=stmins_md4]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_md4]').val();cellCSSvar = jQuery('[id$=endhrs_md4]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_md4]').val();cellCSSvar = jQuery('[id$=endmins_md4]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_md4]').val();cellCSSvar = jQuery('[id$=bShrs_md4]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_md4]').val();cellCSSvar = jQuery('[id$=bSmins_md4]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_md4]').val();cellCSSvar = jQuery('[id$=bEhrs_md4]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_md4]').val();cellCSSvar = jQuery('[id$=bEmins_md4]');timeType = 'mins';}
        }
        if(day == '5'){
            startHrs = jQuery('[id$=sthrs_md5]').val();
            startMins = jQuery('[id$=stmins_md5]').val();
            endHrs = jQuery('[id$=endhrs_md5]').val();
            endMins = jQuery('[id$=endmins_md5]').val();
            bStartHrs = jQuery('[id$=bShrs_md5]').val();
            bStartMins = jQuery('[id$=bSmins_md5]').val();
            bEndHrs = jQuery('[id$=bEhrs_md5]').val();
            bEndMins = jQuery('[id$=bEmins_md5]').val();
            timeError = jQuery('[id$=tEError_DM5]');
            breakError = jQuery('[id$=tEError_DM5_BT2]');
            saveButton = jQuery('[id$=saveD5M]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_md5]').val();cellCSSvar = jQuery('[id$=sthrs_md5]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_md5]').val();cellCSSvar = jQuery('[id$=stmins_md5]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_md5]').val();cellCSSvar = jQuery('[id$=endhrs_md5]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_md5]').val();cellCSSvar = jQuery('[id$=endmins_md5]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_md5]').val();cellCSSvar = jQuery('[id$=bShrs_md5]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_md5]').val();cellCSSvar = jQuery('[id$=bSmins_md5]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_md5]').val();cellCSSvar = jQuery('[id$=bEhrs_md5]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_md5]').val();cellCSSvar = jQuery('[id$=bEmins_md5]');timeType = 'mins';}
        }
        if(day == '6'){
            startHrs = jQuery('[id$=sthrs_md6]').val();
            startMins = jQuery('[id$=stmins_md6]').val();
            endHrs = jQuery('[id$=endhrs_md6]').val();
            endMins = jQuery('[id$=endmins_md6]').val();
            bStartHrs = jQuery('[id$=bShrs_md6]').val();
            bStartMins = jQuery('[id$=bSmins_md6]').val();
            bEndHrs = jQuery('[id$=bEhrs_md6]').val();
            bEndMins = jQuery('[id$=bEmins_md6]').val();
            timeError = jQuery('[id$=tEError_DM6]');
            breakError = jQuery('[id$=tEError_DM6_BT2]');
            saveButton = jQuery('[id$=saveD6M]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_md6]').val();cellCSSvar = jQuery('[id$=sthrs_md6]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_md6]').val();cellCSSvar = jQuery('[id$=stmins_md6]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_md6]').val();cellCSSvar = jQuery('[id$=endhrs_md6]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_md6]').val();cellCSSvar = jQuery('[id$=endmins_md6]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_md6]').val();cellCSSvar = jQuery('[id$=bShrs_md6]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_md6]').val();cellCSSvar = jQuery('[id$=bSmins_md6]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_md6]').val();cellCSSvar = jQuery('[id$=bEhrs_md6]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_md6]').val();cellCSSvar = jQuery('[id$=bEmins_md6]');timeType = 'mins';}
        }
        if(day == '7'){
            startHrs = jQuery('[id$=sthrs_md7]').val();
            startMins = jQuery('[id$=stmins_md7]').val();
            endHrs = jQuery('[id$=endhrs_md7]').val();
            endMins = jQuery('[id$=endmins_md7]').val();
            bStartHrs = jQuery('[id$=bShrs_md7]').val();
            bStartMins = jQuery('[id$=bSmins_md7]').val();
            bEndHrs = jQuery('[id$=bEhrs_md7]').val();
            bEndMins = jQuery('[id$=bEmins_md7]').val();
            timeError = jQuery('[id$=tEError_DM7]');
            breakError = jQuery('[id$=tEError_DM7_BT2]');
            saveButton = jQuery('[id$=saveD7M]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_md7]').val();cellCSSvar = jQuery('[id$=sthrs_md7]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_md7]').val();cellCSSvar = jQuery('[id$=stmins_md7]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_md7]').val();cellCSSvar = jQuery('[id$=endhrs_md7]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_md7]').val();cellCSSvar = jQuery('[id$=endmins_md7]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_md7]').val();cellCSSvar = jQuery('[id$=bShrs_md7]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_md7]').val();cellCSSvar = jQuery('[id$=bSmins_md7]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_md7]').val();cellCSSvar = jQuery('[id$=bEhrs_md7]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_md7]').val();cellCSSvar = jQuery('[id$=bEmins_md7]');timeType = 'mins';}
        }
    }
    if(mD == 'D'){
        if(day == '1'){
            startHrs = jQuery('[id$=sthrs_d1]').val();
            startMins = jQuery('[id$=stmins_d1]').val();
            endHrs = jQuery('[id$=endhrs_d1]').val();
            endMins = jQuery('[id$=endmins_d1]').val();
            bStartHrs = jQuery('[id$=bShrs_d1]').val();
            bStartMins = jQuery('[id$=bSmins_d1]').val();
            bEndHrs = jQuery('[id$=bEhrs_d1]').val();
            bEndMins = jQuery('[id$=bEmins_d1]').val();
            timeError = jQuery('[id$=tEError_D1]');
            breakError = jQuery('[id$=tEError_D1_BT]');
            saveButton = jQuery('[id$=saveD1]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_d1]').val();cellCSSvar = jQuery('[id$=sthrs_d1]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_d1]').val();cellCSSvar = jQuery('[id$=stmins_d1]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_d1]').val();cellCSSvar = jQuery('[id$=endhrs_d1]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_d1]').val();cellCSSvar = jQuery('[id$=endmins_d1]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_d1]').val();cellCSSvar = jQuery('[id$=bShrs_d1]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_d1]').val();cellCSSvar = jQuery('[id$=bSmins_d1]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_d1]').val();cellCSSvar = jQuery('[id$=bEhrs_d1]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_d1]').val();cellCSSvar = jQuery('[id$=bEmins_d1]');timeType = 'mins';}
        }
        if(day == '2'){
            startHrs = jQuery('[id$=sthrs_d2]').val();
            startMins = jQuery('[id$=stmins_d2]').val();
            endHrs = jQuery('[id$=endhrs_d2]').val();
            endMins = jQuery('[id$=endmins_d2]').val();
            bStartHrs = jQuery('[id$=bShrs_d2]').val();
            bStartMins = jQuery('[id$=bSmins_d2]').val();
            bEndHrs = jQuery('[id$=bEhrs_d2]').val();
            bEndMins = jQuery('[id$=bEmins_d2]').val();
            timeError = jQuery('[id$=tEError_D2]');
            breakError = jQuery('[id$=tEError_D2_BT]');
            saveButton = jQuery('[id$=saveD2]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_d2]').val();cellCSSvar = jQuery('[id$=sthrs_d2]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_d2]').val();cellCSSvar = jQuery('[id$=stmins_d2]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_d2]').val();cellCSSvar = jQuery('[id$=endhrs_d2]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_d2]').val();cellCSSvar = jQuery('[id$=endmins_d2]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_d2]').val();cellCSSvar = jQuery('[id$=bShrs_d2]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_d2]').val();cellCSSvar = jQuery('[id$=bSmins_d2]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_d2]').val();cellCSSvar = jQuery('[id$=bEhrs_d2]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_d2]').val();cellCSSvar = jQuery('[id$=bEmins_d2]');timeType = 'mins';}
        }
        if(day == '3'){
            startHrs = jQuery('[id$=sthrs_d3]').val();
            startMins = jQuery('[id$=stmins_d3]').val();
            endHrs = jQuery('[id$=endhrs_d3]').val();
            endMins = jQuery('[id$=endmins_d3]').val();
            bStartHrs = jQuery('[id$=bShrs_d3]').val();
            bStartMins = jQuery('[id$=bSmins_d3]').val();
            bEndHrs = jQuery('[id$=bEhrs_d3]').val();
            bEndMins = jQuery('[id$=bEmins_d3]').val();
            timeError = jQuery('[id$=tEError_D3]');
            breakError = jQuery('[id$=tEError_D3_BT]');
            saveButton = jQuery('[id$=saveD3]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_d3]').val();cellCSSvar = jQuery('[id$=sthrs_d3]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_d3]').val();cellCSSvar = jQuery('[id$=stmins_d3]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_d3]').val();cellCSSvar = jQuery('[id$=endhrs_d3]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_d3]').val();cellCSSvar = jQuery('[id$=endmins_d3]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_d3]').val();cellCSSvar = jQuery('[id$=bShrs_d3]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_d3]').val();cellCSSvar = jQuery('[id$=bSmins_d3]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_d3]').val();cellCSSvar = jQuery('[id$=bEhrs_d3]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_d3]').val();cellCSSvar = jQuery('[id$=bEmins_d3]');timeType = 'mins';}
        }
        if(day == '4'){
            startHrs = jQuery('[id$=sthrs_d4]').val();
            startMins = jQuery('[id$=stmins_d4]').val();
            endHrs = jQuery('[id$=endhrs_d4]').val();
            endMins = jQuery('[id$=endmins_d4]').val();
            bStartHrs = jQuery('[id$=bShrs_d4]').val();
            bStartMins = jQuery('[id$=bSmins_d4]').val();
            bEndHrs = jQuery('[id$=bEhrs_d4]').val();
            bEndMins = jQuery('[id$=bEmins_d4]').val();
            timeError = jQuery('[id$=tEError_D4]');
            breakError = jQuery('[id$=tEError_D4_BT]');
            saveButton = jQuery('[id$=saveD4]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_d4]').val();cellCSSvar = jQuery('[id$=sthrs_d4]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_d4]').val();cellCSSvar = jQuery('[id$=stmins_d4]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_d4]').val();cellCSSvar = jQuery('[id$=endhrs_d4]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_d4]').val();cellCSSvar = jQuery('[id$=endmins_d4]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_d4]').val();cellCSSvar = jQuery('[id$=bShrs_d4]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_d4]').val();cellCSSvar = jQuery('[id$=bSmins_d4]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_d4]').val();cellCSSvar = jQuery('[id$=bEhrs_d4]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_d4]').val();cellCSSvar = jQuery('[id$=bEmins_d4]');timeType = 'mins';}
        }
        if(day == '5'){
            startHrs = jQuery('[id$=sthrs_d5]').val();
            startMins = jQuery('[id$=stmins_d5]').val();
            endHrs = jQuery('[id$=endhrs_d5]').val();
            endMins = jQuery('[id$=endmins_d5]').val();
            bStartHrs = jQuery('[id$=bShrs_d5]').val();
            bStartMins = jQuery('[id$=bSmins_d5]').val();
            bEndHrs = jQuery('[id$=bEhrs_d5]').val();
            bEndMins = jQuery('[id$=bEmins_d5]').val();
            timeError = jQuery('[id$=tEError_D5]');
            breakError = jQuery('[id$=tEError_D5_BT]');
            saveButton = jQuery('[id$=saveD5]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_d5]').val();cellCSSvar = jQuery('[id$=sthrs_d5]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_d5]').val();cellCSSvar = jQuery('[id$=stmins_d5]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_d5]').val();cellCSSvar = jQuery('[id$=endhrs_d5]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_d5]').val();cellCSSvar = jQuery('[id$=endmins_d5]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_d5]').val();cellCSSvar = jQuery('[id$=bShrs_d5]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_d5]').val();cellCSSvar = jQuery('[id$=bSmins_d5]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_d5]').val();cellCSSvar = jQuery('[id$=bEhrs_d5]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_d5]').val();cellCSSvar = jQuery('[id$=bEmins_d5]');timeType = 'mins';}
        }
        if(day == '6'){
            startHrs = jQuery('[id$=sthrs_d6]').val();
            startMins = jQuery('[id$=stmins_d6]').val();
            endHrs = jQuery('[id$=endhrs_d6]').val();
            endMins = jQuery('[id$=endmins_d6]').val();
            bStartHrs = jQuery('[id$=bShrs_d6]').val();
            bStartMins = jQuery('[id$=bSmins_d6]').val();
            bEndHrs = jQuery('[id$=bEhrs_d6]').val();
            bEndMins = jQuery('[id$=bEmins_d6]').val();
            timeError = jQuery('[id$=tEError_D6]');
            breakError = jQuery('[id$=tEError_D6_BT]');
            saveButton = jQuery('[id$=saveD6]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_d6]').val();cellCSSvar = jQuery('[id$=sthrs_d6]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_d6]').val();cellCSSvar = jQuery('[id$=stmins_d6]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_d6]').val();cellCSSvar = jQuery('[id$=endhrs_d6]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_d6]').val();cellCSSvar = jQuery('[id$=endmins_d6]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_d6]').val();cellCSSvar = jQuery('[id$=bShrs_d6]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_d6]').val();cellCSSvar = jQuery('[id$=bSmins_d6]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_d6]').val();cellCSSvar = jQuery('[id$=bEhrs_d6]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_d6]').val();cellCSSvar = jQuery('[id$=bEmins_d6]');timeType = 'mins';}
        }
        if(day == '7'){
            startHrs = jQuery('[id$=sthrs_d7]').val();
            startMins = jQuery('[id$=stmins_d7]').val();
            endHrs = jQuery('[id$=endhrs_d7]').val();
            endMins = jQuery('[id$=endmins_d7]').val();
            bStartHrs = jQuery('[id$=bShrs_d7]').val();
            bStartMins = jQuery('[id$=bSmins_d7]').val();
            bEndHrs = jQuery('[id$=bEhrs_d7]').val();
            bEndMins = jQuery('[id$=bEmins_d7]').val();
            timeError = jQuery('[id$=tEError_D7]');
            breakError = jQuery('[id$=tEError_D7_BT]');
            saveButton = jQuery('[id$=saveD7]');

            if(type=='sHrs'){timeCheck=jQuery('[id$=sthrs_d7]').val();cellCSSvar = jQuery('[id$=sthrs_d7]');timeType = 'hrs';}
            if(type=='sMins'){timeCheck=jQuery('[id$=stmins_d7]').val();cellCSSvar = jQuery('[id$=stmins_d7]');timeType = 'mins';}
            if(type=='eHrs'){timeCheck=jQuery('[id$=endhrs_d7]').val();cellCSSvar = jQuery('[id$=endhrs_d7]');timeType = 'hrs';}
            if(type=='eMins'){timeCheck=jQuery('[id$=endmins_d7]').val();cellCSSvar = jQuery('[id$=endmins_d7]');timeType = 'mins';}
            if(type=='bShrs'){timeCheck=jQuery('[id$=bShrs_d7]').val();cellCSSvar = jQuery('[id$=bShrs_d7]');timeType = 'hrs';}
            if(type=='bSmins'){timeCheck=jQuery('[id$=bSmins_d7]').val();cellCSSvar = jQuery('[id$=bSmins_d7]');timeType = 'mins';}
            if(type=='bEhrs'){timeCheck=jQuery('[id$=bEhrs_d7]').val();cellCSSvar = jQuery('[id$=bEhrs_d7]');timeType = 'hrs';}
            if(type=='bEmins'){timeCheck=jQuery('[id$=bEmins_d7]').val();cellCSSvar = jQuery('[id$=bEmins_d7]');timeType = 'mins';}
        }
    }

    newValidateAllTimes(timeType,startHrs,startMins,endHrs,endMins,bStartHrs,bStartMins,bEndHrs,bEndMins,timeCheck,timeError,saveButton,breakError,cellCSSvar);

}

function newValidateAllTimes(type,valSTh,valSTm,valETh,valETm,valBSh,valBSm,valBEh,valBEm,checkVar,errorMsgId,buttonId,breakErrorMsgId,cellCSSvar){
        var startHrs = valSTh;
        var startMins = valSTm;
        var endHrs = valETh;
        var endMins = valETm;
        var bStartHrs = valBSh;
        var bStartMins = valBSm;
        var bEndHrs = valBEh;
        var bEndMins = valBEm;

        var timeType=type;
        var timeCheck=checkVar;
        var zeroTime = '00:00:00';
        var minToMidTime = '23:59:00';
        var timeId = cellCSSvar;
        var errMsgId = errorMsgId;
        var bErrmsgId = breakErrorMsgId;



        //for checking each break times are within Start End times (we may also handle midnight boundaries
        var start = startHrs + ':'+ startMins + ':00';
        var end = endHrs +':' + endMins + ':00';
        var bStart = bStartHrs +':' + bStartMins + ':00';
        var bEnd = bEndHrs +':' + bEndMins + ':00';

        console.log('start',start);
        console.log('end',end);
        console.log('bStart',bStart);
        console.log('bEnd',bEnd);
        console.log('timeId',timeId);
        console.log('errorMsgId',errorMsgId);

    //for validating time entered is within 24hr/60min boundaries

    //if user has tried to tab out of cell check we have min length, checkBreakStartEnd(start,end,bStart,bEnd,buttonId,timeId,errorMsgId,breakErrorMsgId)
    checkBreakStartEnd(start,end,bStart,bEnd,buttonId,timeId,errMsgId,bErrmsgId);

       if(timeType == 'hrs'){
           if(timeCheck>23 || timeCheck<0 || timeCheck.length !=2){
                console.log('check hrs NOT OK');
               //hrs entered is greater than 23 so show an error message and
               //hide the relevant save button and all submit buttons just in case

               //alert('GOT HERE!!!');

               //hide that days save button, show the error msg and highlight the div
               //buttonId.hide();
               buttonId.css("display","none");

               timeId.css("background-color","red");

               errorMsgId.css("display","block");

               //make sure to hide all the submit buttons, just in case
               jQuery('[id$=submitButton1]').hide();
               jQuery('[id$=submitButton2]').hide();
               jQuery('[id$=submitButton3]').hide();
           }
           if(timeCheck<=23 && timeCheck>=0 && timeCheck.length == 2){
                console.log('check hrs OK');
               //hrs entered ok so make sure we clean up any errors

               //show that days save button, hide the error msg and unhighlight the div
               timeId.css("background-color","");
               errorMsgId.css("display","none");
               buttonId.css("display","block");

               //make sure to hide all the submit buttons, just in case
               jQuery('[id$=submitButton1]').show();
               jQuery('[id$=submitButton2]').show();
               jQuery('[id$=submitButton3]').show();
           }
           console.log('check hrs');
       }
       if(timeType =='mins') {
           if(timeCheck>59 || timeCheck<0 || timeCheck.length !=2 ){
               //mins entered is greater than 59 so show an error message and
               //hide the relevant save button and all submit buttons just in case

               //hide that days save button, show the error msg and highlight the div
               //buttonId.hide();
               buttonId.css("display","none");
               timeId.css("background-color","red");
               errorMsgId.css("display","block");

               //make sure to hide all the submit buttons, just in case
               jQuery('[id$=submitButton1]').hide();
               jQuery('[id$=submitButton2]').hide();
               jQuery('[id$=submitButton3]').hide();
           }
           if(timeCheck<=59 && timeCheck>=0 && timeCheck.length == 2){
               //mins entered is ok so clean up any shown errors etc

               //show that days save button, hide the error msg and highlight the div
               //buttonId.show();
               timeId.css("background-color","");
               errorMsgId.css("display","none");

               //make sure to hide all the submit buttons, just in case
               jQuery('[id$=submitButton1]').show();
               jQuery('[id$=submitButton2]').show();
               jQuery('[id$=submitButton3]').show();
           }
           console.log('check mins');
       }

        //finally, check START END hrs - don't show the buttons if we till have errors across the times
      if(start > minToMidTime || start < zeroTime || end > minToMidTime || end < zeroTime || startHrs.length != 2 || endHrs.length != 2 || startMins.length != 2 || endMins.length != 2){
          //time entered is incorrect
          //hide the relevant save button and all submit buttons just in case
          console.log('time issues!');

          //hide that days save button, show the error msg and highlight the div
          buttonId.css("display","none");

          //make sure to hide all the submit buttons, just in case
          jQuery('[id$=submitButton1]').hide();
          jQuery('[id$=submitButton2]').hide();
          jQuery('[id$=submitButton3]').hide();
      }

      //finally, check BREAK START END hrs - don't show the buttons if we have errors across the times
       if(bStart > minToMidTime || bStart < zeroTime || bEnd > minToMidTime || bEnd < zeroTime || bStartHrs.length != 2 || bEndHrs.length != 2 || bStartMins.length != 2 || bEndMins.length != 2){
           //time entered is incorrect
           //hide the relevant save button and all submit buttons just in case
           console.log('time issues!');

           //hide that days save button, show the error msg and highlight the div
           //buttonId.hide();
           buttonId.css("display","none");

           //make sure to hide all the submit buttons, just in case
           jQuery('[id$=submitButton1]').hide();
           jQuery('[id$=submitButton2]').hide();
           jQuery('[id$=submitButton3]').hide();
       }
}

function addTimes (startTime, endTime) {
  var times = [ 0, 0, 0 ]
  var max = times.length

  var a = (startTime || '').split(':')
  var b = (endTime || '').split(':')

  // normalize time values
  for (var i = 0; i < max; i++) {
    a[i] = isNaN(parseInt(a[i])) ? 0 : parseInt(a[i])
    b[i] = isNaN(parseInt(b[i])) ? 0 : parseInt(b[i])
  }

  // store time values
  for (var i = 0; i < max; i++) {
    times[i] = a[i] + b[i]
  }

  var hours = times[0]
  var minutes = times[1]
  var seconds = times[2]

  if (seconds >= 60) {
    var m = (seconds / 60) << 0
    minutes += m
    seconds -= 60 * m
  }

  if (minutes >= 60) {
    var h = (minutes / 60) << 0
    hours += h
    minutes -= 60 * h
  }

  return ('0' + hours).slice(-2) + ':' + ('0' + minutes).slice(-2) + ':' + ('0' + seconds).slice(-2)
}

//Break function called by validateAll function
function checkBreakStartEnd(start,end,bStart,bEnd,buttonId,timeId,errorMsgId,breakErrorMsgId){
    var zeroTime = '00:00:00';
    var start = start;
    var end = end;
    var bStart = bStart;
    var bEnd = bEnd;


    console.log('CHECK THE BREAK OK!!!');

    //Check our Break is within the Start and End times
    //if its not midnight conditions and we have time entered for break start/end
    //&& (bStart > zeroTime && bEnd > zeroTime)
    if(start > end ){
        //we have a midnight situation so update the end time to be +24hrs
        //convert time to seconds so we can add a day
        var twentyFour = '24:00:00';

        end = addTimes(end,twentyFour);

        //convert back to string for comparison

        console.log('end midnight hrs:' , end);
        if(bStart < start){
            bStart = addTimes(bStart,twentyFour);
            console.log('bStart midnight hrs:' , bStart);
        }
        if(bStart > start){
            if(bEnd < bStart){
                bEnd = addTimes(bEnd,twentyFour);
                console.log('bEnd midnight hrs:' , bEnd);
            }
        }
    }

    console.log('now we are checking Breaks');
    //its not a midnight crossing time entry

    //only if break start AND break end are greater than zero time checks required
    if(bEnd != zeroTime && bStart != zeroTime){
        //if break start is earlier than time start
        if(bStart < start){

            console.log('bStart < start');
            //hide that days save button, show the error msg and highlight the div
            buttonId.css("display","none");
            breakErrorMsgId.css("display","block");
            breakErrorMsgId.empty();
            breakErrorMsgId.append('Break input error: break start cannot be before time start');
            //timeId.css("background-color","red");

            //make sure to hide all the submit buttons, just in case
           jQuery('[id$=submitButton1]').hide();
           jQuery('[id$=submitButton2]').hide();
           jQuery('[id$=submitButton3]').hide();
        }
        if(bStart > end){

            console.log('bStart > end');
            //if break start is after end time
            //hide that days save button, show the error msg and highlight the div
            buttonId.css("display","none");
            breakErrorMsgId.css("display","block");
            breakErrorMsgId.empty();
            breakErrorMsgId.append('Break input error: break start cannot be after time end');
            //timeId.css("background-color","red");

            //make sure to hide all the submit buttons, just in case
           jQuery('[id$=submitButton1]').hide();
           jQuery('[id$=submitButton2]').hide();
           jQuery('[id$=submitButton3]').hide();
        }
        if(bEnd < start){

            console.log('bEnd < start');
            //hide that days save button, show the error msg and highlight the div
             //if break end is before start time
            buttonId.css("display","none");
            breakErrorMsgId.css("display","block");
            breakErrorMsgId.empty();
            breakErrorMsgId.append('Break input error: break end cannot be before time start');
            //timeId.css("background-color","red");

            //make sure to hide all the submit buttons, just in case
           jQuery('[id$=submitButton1]').hide();
           jQuery('[id$=submitButton2]').hide();
           jQuery('[id$=submitButton3]').hide();
        }
        if(bEnd > end){

            console.log('bEnd > end');
            //hide that days save button, show the error msg and highlight the div
            //if break end is after end time
            buttonId.css("display","none");
            breakErrorMsgId.css("display","block");
            breakErrorMsgId.empty();
            breakErrorMsgId.append('Break input error: break end cannot be after time end');
            //timeId.css("background-color","red");

            //make sure to hide all the submit buttons, just in case
           jQuery('[id$=submitButton1]').hide();
           jQuery('[id$=submitButton2]').hide();
           jQuery('[id$=submitButton3]').hide();
        }
        if(bStart > bEnd){

            console.log('bStart > bEnd');
            //hide that days save button, show the error msg and highlight the div
            //if break end is after end time
            buttonId.css("display","none");
            breakErrorMsgId.css("display","block");
            breakErrorMsgId.empty();

            timeId.css("background-color","red");

            //make sure to hide all the submit buttons, just in case
           jQuery('[id$=submitButton1]').hide();
           jQuery('[id$=submitButton2]').hide();
           jQuery('[id$=submitButton3]').hide();

           breakErrorMsgId.append('Break input error: break start cannot be after break end');
        }
    }
    //final check
    if((bStart == zeroTime && bEnd == zeroTime) ||(bStart <= bEnd && (bStart >= start && bStart <= end && bEnd >= start && bEnd <= end ))){

       console.log('bREAKS ARE OK');
       //show that days save button, hide the error msg and highlight the div
       buttonId.css("display","block");
       breakErrorMsgId.css("display","none");
       breakErrorMsgId.empty();
       //timeId.css("background-color","");


       //make sure to hide all the submit buttons, just in case
       jQuery('[id$=submitButton1]').show();
       jQuery('[id$=submitButton2]').show();
       jQuery('[id$=submitButton3]').show();
    }
}

//Used by PortalTimesheetViewEntry,
//Only allow numbers up to 999 to be entered into break field

function checkBreakMins(type,evt,val,buttonId,timeId,errorMsgId)
{
    var timeType=type;
    console.log('type: ',type);
    console.log('evt:',evt);
    console.log('val:',val);
    console.log('buttonId:',buttonId);
    console.log('timeId:',timeId);
    console.log('errorMsgId',errorMsgId);

    if(timeType == 'break'){
        if(val>999 || val<0){
            //mins entered is greater than 999 so show an error message and
            //hide the relevant save button and all submit buttons just in case
            //jQuery('[id$=timeEntryError]').show();

            //hide that days save button, show the error msg and highlight the div
            buttonId.hide();
            timeId.css("background-color","red");
            errorMsgId.css("display","block");
            //errorMsgId.show();

            //make sure to hide all the submit buttons, just in case
            jQuery('[id$=submitButton1]').hide();
            jQuery('[id$=submitButton2]').hide();
            jQuery('[id$=submitButton3]').hide();
        }
        if(val<=999 && val>0 && val.length==2){
            //mins entered is ok so hide error message etc

            //show that days save button, hide the error msg and unhighlight the div
            buttonId.show();
            timeId.css("background-color","");
            errorMsgId.css("display","none");
            //errorMsgId.hide();

            //make sure to hide all the submit buttons, just in case
            jQuery('[id$=submitButton1]').show();
            jQuery('[id$=submitButton2]').show();
            jQuery('[id$=submitButton3]').show();
        }
    }

    return true;
}

//Used by PortalTimesheetViewEntry, for LEAVE TIME START/END
//Only allow numbers up to 23 to be entered into hr field
//Only allow numbers up to 59 to be entered into min field
//Only allow numbers up to 999 to be entered into break field
//allow only 2 digit numbers for all fields
function checkTimeEntry(type,evt,val,buttonId,timeId,errorMsgId)
{
    var timeType=type;
    console.log('type: ',type);
    console.log('evt:',evt);
    console.log('val:',val);
    console.log('buttonId:',buttonId);
    console.log('timeId:',timeId);
    console.log('errorMsgId',errorMsgId);

    //if user has tried to tab out of cell check we have min length
    if(timeType == 'hrs'){
        if(val>23 || val<0 || val.length != 2){

            //hrs entered is greater than 23 so show an error message and
            //hide the relevant save button and all submit buttons just in case
            //alert('greater than 23 hrs please fix');
            //jQuery('[id$=timeEntryError]').show();

            //hide that days save button, show the error msg and highlight the div
            buttonId.hide();
            timeId.css("background-color","red");
            errorMsgId.css("display","block");
            //errorMsgId.show();

            //make sure to hide all the submit buttons, just in case
            jQuery('[id$=submitButton1]').hide();
            jQuery('[id$=submitButton2]').hide();
            jQuery('[id$=submitButton3]').hide();
        }
        if(val<=23 && val>=0 && val.length == 2){

            //hrs entered ok so make sure we clean up any errors

            //show that days save button, hide the error msg and unhighlight the div
            buttonId.show();
            timeId.css("background-color","");
            errorMsgId.css("display","none");
            //errorMsgId.hide();

            //make sure to hide all the submit buttons, just in case
            jQuery('[id$=submitButton1]').show();
            jQuery('[id$=submitButton2]').show();
            jQuery('[id$=submitButton3]').show();
        }
    }else if(timeType =='mins') {
        if(val>59 || val<0 || val.length != 2){
            //mins entered is greater than 59 so show an error message and
            //hide the relevant save button and all submit buttons just in case
            //jQuery('[id$=timeEntryError]').show();

            //hide that days save button, show the error msg and highlight the div
            buttonId.hide();
            timeId.css("background-color","red");
            errorMsgId.css("display","block");
            //errorMsgId.show();

            //make sure to hide all the submit buttons, just in case
            jQuery('[id$=submitButton1]').hide();
            jQuery('[id$=submitButton2]').hide();
            jQuery('[id$=submitButton3]').hide();
        }
        if(val<=59 && val>=0 && val.length == 2){
            //mins entered is ok so clean up any shown errors etc

            //show that days save button, hide the error msg and highlight the div
            buttonId.show();
            timeId.css("background-color","");
            errorMsgId.css("display","none");
            //errorMsgId.hide();

            //make sure to hide all the submit buttons, just in case
            jQuery('[id$=submitButton1]').show();
            jQuery('[id$=submitButton2]').show();
            jQuery('[id$=submitButton3]').show();
        }
    }

    return true;
}

function setStyle()
{
    
    $('#table_id td.status #theStatus').each(function(){
    console.log('remove style');
       var theStatus = $(this).text();
       
        console.log(theStatus);
       if(theStatus == 'New'){
           //console.log('New');
           $(this).addClass("statusNew");
           $(this).removeClass("statusApproved statusSubmitted statusRejected");
       }else if(theStatus == 'Approved'){
           //console.log('Approved');
           $(this).addClass("statusApproved");
           $(this).removeClass("statusNew  statusSubmitted statusRejected");
       }else if(theStatus == 'Submitted'){
           //console.log('Approved');
           $(this).addClass("statusSubmitted");
           $(this).removeClass("statusNew statusApproved statusRejected");
       }else if(theStatus == 'Rejected'){
           //console.log('Approved');
           $(this).addClass("statusRejected");
           $(this).removeClass("statusNew statusApproved statusSubmitted");
       }else{
           $(this).removeClass();
       }
    });
}

/*
Used by: PortalProfileCompanyDetails, PortalProfileBankDetails
Why? : to be able to auto-search bsbs - this is not currently in use!!
*/
//this section auto-searches bsbs for Bank Accounts 1, 2 and 3

/*
var PLACEHOLDER1 = 'Enter BSB Here';
var bsbObjects1;
var queryTerm1;

//BSB for Bank Account 1
$('[id$=bsbTextBox]').autocomplete({
    minLength: 3,
    source: function(request, response) {
        queryTerm1 = request.term;
        Portal_ProfileBankDetails_Controller.searchBSB(request.term, function(result, event){
            if(event.type == 'exception') {
                alert(event.message);
            } else {
                        bsbObjects1 = result;
                        response(bsbObjects1);
                    }
        });
    },
    focus: function( event, ui ) {
        $('[id$=bsbTextBox]').val( ui.item.value );
        return false;
    },
    select: function( event, ui ) {
        $('[id$=bsbTextBox]').val( ui.item.value );
        $('[id$=searchBSBId]').val( ui.item.key );
        paraFunction1(ui.item.value);
        return false;
    },
})
.data( "ui-autocomplete" )._renderItem = function( ul, item ) {
    var entry = "<a>" + item.value;

    entry = entry + "</a>";
    entry = entry.replace(queryTerm1, "<b>" + queryTerm1 + "</b>");

    return $( "<li></li>" )
    .data( "item.ui-autocomplete", item )
    .append( entry )
    .appendTo( ul );
};

// Add or remove placeholder values
$('[id$=bsbTextBox]').val(PLACEHOLDER1);
$('[id$=bsbTextBox]').on("focus",  function(event){
    $tgt = $(event.target);
    if($tgt.val() === PLACEHOLDER1 ){
        $tgt.val('');
        $tgt.removeClass('placeHolder');
    }
});
$('[id$=bsbTextBox]').on( "blur",  function(event){
    $tgt = $(event.target);
    if($tgt.val() === '' ){
        $tgt.val(PLACEHOLDER1);
        $tgt.addClass('placeHolder');
    }
});

var PLACEHOLDER2 = 'Enter BSB Here';
var bsbObjects2;
var queryTerm2;

//BSB for Bank Account 2
$('[id$=bsbTextBox2]').autocomplete({
    minLength: 3,
    source: function(request, response) {
        queryTerm2 = request.term;
        Portal_ProfileBankDetails_Controller.searchBSB(request.term, function(result, event){
            if(event.type == 'exception') {
            alert(event.message);
            } else {
                    bsbObjects2 = result;
                    response(bsbObjects2);
                }
        });
    },
    focus: function( event, ui ) {
        $('[id$=bsbTextBox2]').val( ui.item.value );
        return false;
    },
    select: function( event, ui ) {
        $('[id$=bsbTextBox2]').val( ui.item.value );
        $('[id$=searchBSBId2]').val( ui.item.key );
        paraFunction2(ui.item.value);
        return false;
    },
})
.data( "ui-autocomplete" )._renderItem = function( ul, item ) {
    var entry = "<a>" + item.value;

    entry = entry + "</a>";
    entry = entry.replace(queryTerm2, "<b>" + queryTerm2 + "</b>");

    return $( "<li></li>" )
    .data( "item.ui-autocomplete", item )
    .append( entry )
    .appendTo( ul );
};

// Add or remove placeholder values
$('[id$=bsbTextBox2]').val(PLACEHOLDER2);
$('[id$=bsbTextBox2]').on("focus",  function(event){
    $tgt = $(event.target);
    if($tgt.val() === PLACEHOLDER2 ){
        $tgt.val('');
        $tgt.removeClass('placeHolder');
    }
});
$('[id$=bsbTextBox2]').on( "blur",  function(event){
    $tgt = $(event.target);
    if($tgt.val() === '' ){
        $tgt.val(PLACEHOLDER2);
        $tgt.addClass('placeHolder');
    }
});

var PLACEHOLDER3 = 'Enter BSB Here';
var bsbObjects3;
var queryTerm3;

//BSB for Bank Account 3
$('[id$=bsbTextBox3]').autocomplete({
    minLength: 3,
    source: function(request, response) {
        queryTerm3 = request.term;
        Portal_ProfileBankDetails_Controller.searchBSB(request.term, function(result, event){
            if(event.type == 'exception') {
                alert(event.message);
            } else {
                    bsbObjects3 = result;
                    response(bsbObjects3);
                    }
        });
    },
    focus: function( event, ui ) {
        $('[id$=bsbTextBox3]').val( ui.item.value );
        return false;
    },
    select: function( event, ui ) {
        $('[id$=bsbTextBox3]').val( ui.item.value );
        $('[id$=searchBSBId3]').val( ui.item.key );
        paraFunction3(ui.item.value);
        return false;
    },
})
.data( "ui-autocomplete" )._renderItem = function( ul, item ) {
    var entry = "<a>" + item.value;

    entry = entry + "</a>";
    entry = entry.replace(queryTerm3, "<b>" + queryTerm3 + "</b>");

    return $( "<li></li>" )
    .data( "item.ui-autocomplete", item )
    .append( entry )
    .appendTo( ul );
};

// Add or remove placeholder values
$('[id$=bsbTextBox3]').val(PLACEHOLDER3);
$('[id$=bsbTextBox3]').on("focus",  function(event){
    $tgt = $(event.target);
    if($tgt.val() === PLACEHOLDER3 ){
        $tgt.val('');
        $tgt.removeClass('placeHolder');
    }
});
$('[id$=bsbTextBox3]').on( "blur",  function(event){
    $tgt = $(event.target);
    if($tgt.val() === '' ){
        $tgt.val(PLACEHOLDER3);
        $tgt.addClass('placeHolder');
    }
});
*/