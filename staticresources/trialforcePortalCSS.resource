/* trialforcePortalCSS */

/* Salesforce Lightning Fonts in use */
@font-face {
  font-family: 'Salesforce Sans';
  src: url('//cdnjs.cloudflare.com/ajax/libs/design-system/2.4.4/fonts/SalesforceSans-Light.ttf') format('truetype'), url('//cdnjs.cloudflare.com/ajax/libs/design-system/2.4.4/fonts/SalesforceSans-Light.woff') format('woff');
  font-style: normal;
  font-weight: 300;
}
@font-face {
  font-family: 'Salesforce Sans';
  src: url('//cdnjs.cloudflare.com/ajax/libs/design-system/2.4.4/fonts/SalesforceSans-Regular.ttf') format('truetype'), url('//cdnjs.cloudflare.com/ajax/libs/design-system/2.4.4/fonts/SalesforceSans-Regular.woff') format('woff');
  font-style: normal;
  font-weight: 400;
}
@font-face {
  font-family: 'Salesforce Sans';
  src: url('//cdnjs.cloudflare.com/ajax/libs/design-system/2.4.4/fonts/SalesforceSans-Italic.ttf') format('truetype'), url('//cdnjs.cloudflare.com/ajax/libs/design-system/2.4.4/fonts/SalesforceSans-Italic.woff') format('woff');
  font-style: italic;
  font-weight: 400;
}
@font-face {
  font-family: 'Salesforce Sans';
  src: url('//cdnjs.cloudflare.com/ajax/libs/design-system/2.4.4/fonts/SalesforceSans-Bold.ttf') format('truetype'), url('//cdnjs.cloudflare.com/ajax/libs/design-system/2.4.4/fonts/SalesforceSans-Bold.woff') format('woff');
  font-style: bold;
  font-weight: 700;
}
@font-face {
  font-family: 'Salesforce Sans';
  src: url('//cdnjs.cloudflare.com/ajax/libs/design-system/2.4.4/fonts/SalesforceSans-BoldItalic.ttf') format('truetype'), url('//cdnjs.cloudflare.com/ajax/libs/design-system/2.4.4/fonts/SalesforceSans-BoldItalic.woff') format('woff');
  font-style: italic;
  font-weight: 700;
}
input::-webkit-outer-spin-button,
input::-webkit-inner-spin-button {
    /* display: none; <- Crashes Chrome on hover */
    -webkit-appearance: none;
    margin: 0; /* <-- Apparently some margin are still there even though it's hidden */
}
#noscript-warning {
    background-color: ##000000;
    color: #FFFFFF;
    font-family: sans-serif;
    font-size: 120%;
    font-weight: bold;
    left: 0;
    padding: 5px 0;
    position: fixed;
    text-align: center;
    top: 0;
    width: 100%;
    z-index: 101;
}

body.modal-open{position: fixed;}

body {
	color: #4C5E70;
	font-family: 'Salesforce Sans', 'Helvetica' !important;
	font-size: 16px;
	line-height: 21px;
	background: none !important;
	padding-top: 0px;
	padding-left: 239px;
	/*overflow-x: hidden;*/

	position: absolute;
	height:100%;
}
.loginWindow {
    background-color: white;/*var(--sideBarColour);*/
    padding-left: 25%;
}
.loginPanel {
    width: 450px;
    padding-left: 40px;
    padding-right:40px;
    background-color: white; /*#F3F9FF;*/
}
/*DFP IE11 support requires hard code of colour*/
.logoBar {
	height: 60px;
	width: 100%;
	background-color: #000000; /*var(--logoBarColour);*/
	color:white;
    box-shadow: inset 0 1px 2px 0 rgba(0,0,0,0.14);
    position: fixed;
    z-index: 4;
    margin-top: 0;
    top: 0;
    left: 0;
}
/*DFP IE11 support requires hard code of colour*/
.sideBar{
	background-color: #000000; /*var(--sideBarColour);*/
	position: absolute;
	top: 0;
	left: 0;
	width:239px;
	height:100%;
	border:none;
	display:block;
	z-index: 1;
	outline: none;
	white-space: normal;
	padding: 60px 15px 20px;
}
.mobileLogoBar {
    display:none;
}

.pwrdBy{
    cellspacing:0px;
    width:100%;
    border:0px;
    text-align:right;
    columns:1;
}
.pwrdByLogo{
    margin-top:15px;
    margin-right:50px;
    height:30px;
    width:auto;
}

.pageContent{
	background-color: white;
	display: block;
	margin-top:87px;
	margin-left:67px;
}

.errMsg{
    color:red;
    font-size:10pt;
    font-style:italic;
    line-height:11pt;
}
.sideBarLinks{
    display: block;
    outline: 0;
	height:23px;
	width: 226px;
    padding: 5.3% 2%;
    vertical-align: middle;
    text-decoration: none;
    color: #2F2F2F;
    background-color: #F3F9FF;
    text-align: left;
    cursor: pointer;
    white-space: nowrap;
	border-radius:4px;
	margin-top:5px;
	margin-bottom:5px;
}
/*DFP IE11 support requires hard code of colour*/
.sideBarLinks:hover{
	color: white;
	background-color: #666666; /*var(--highlightColour); */
	text-decoration:none;
}
/*DFP IE11 support requires hard code of colour*/
.sidebarHighlight{
  color: white;
  background-color: #666666; /*var(--highlightColour); */
  text-decoration:none;
  margin-bottom:5px;
  margin-top:5px;
}

h1 {
	height: 52px;
	width: 100%;
	color: #1D374C;
	font-family: 'Salesforce Sans', 'Helvetica' !important;
	font-size: 40px;
	font-weight: bold;
	line-height: 52px;
}

.tsPgDate{
    height: 52px;
    width:auto;
    color: #1D374C;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 40px;
    font-weight: bold;
    line-height: 52px;
    float:left;
    padding-bottom:0px
}

.tsPgTotal{
    height: 52px;
    width:auto;
    color: #1D374C;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 40px;
    font-weight: bold;
    line-height: 52px;
    float:right;
    padding-bottom:0px;
}
.plcTable {
    height: 26pt;
    width: 100%;
    color: #1D374C;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 14pt;
    font-weight: bold;
    line-height: 20pt;
    padding-top:8pt;
    padding-bottom:8pt;
}

.mainTable {
    height: 26px;
    /*width: 100%;*/
    color: #1D374C;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 20px;
    font-weight: bold;
    line-height: 26px;
    /*padding-left:37px;*/
}

body .tsPgSubmit {
    min-height: 50px;
    min-width: 145px;
    border-radius: 3px;
    font-size: 16px;
    float: right;
    margin-right:43px;
    margin-left:28px;
}
body .mobAddExp{
    display:none;
}
body .mobAddExpClaim{
    display:none;
}
body .tsPgCreateExp {
    min-height: 50px;
    min-width: 145px;
    border-radius: 3px;
    font-size: 16px;
    float: right;
    margin-right:43px;
    margin-left:28px;
}

 .inputExpDate {
   /* margin-bottom:20pt !important;*/
   padding-left:8pt !important;
}
.inputExpDesc {
    /*margin-bottom: 20pt;*/
    width: 153pt;
    margin-left: 0pt;
    height:40pt;
}
.inputExpType {
    /*margin-bottom: 19pt;*/
    height: 37pt;
}
.inputExpAmt {
    /*margin-bottom: 20pt;*/
    width: 56pt;
    margin-left: 0pt;
}
.taxable{
    /*margin-bottom: 20pt;*/
    width: 20pt;
    margin-left: 0pt;
}

.expHomeTable {
    margin-top: 0pt;
}

h2 {
    height: 26px;
    width: 100%;
    color: #1D374C;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 20px;
    font-weight: bold;
    line-height: 26px;
    /*padding-left:37px;*/
}

h2 .boxHeading {
    height: 26px;
    width: 100%;
    color: #1D374C;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 20px;
    font-weight: bold;
    line-height: 26px;
}

h3 {
    height: 18px;
    width: 100%;
    color: #1D374C;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 16px;
    font-weight: bold;
    line-height: 16px;
}
.pageTurn{
    color:#1D374C;
    font-weight:bold !important;
    padding-top:12px;
    margin-left:130px;
}
body label {
  box-sizing: border-box;
  letter-spacing: 1px;
  color: #1D374C;
  cursor: default;
  display: inline;
  font-family: 'Salesforce Sans', 'Helvetica' !important;
  font-size: 14px;
  font-weight: bold;
  height: 18px;
  hyphens: auto;
  text-transform: uppercase;
  line-height: 18px;
  margin-bottom: 4px;
  margin-top: 8px;
  overflow-wrap: break-word;
  text-size-adjust: 100%;
  visibility: visible;
  width: auto;
  word-wrap: break-word;
  -webkit-box-direction: normal;
  -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
}

body .roText {
    height: 21px;
    width: 231px;
    color: #4C5E70;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 16px;
    line-height: 18px;
    padding-bottom:17px;
    padding-top:5px;
}

body .impMessage {
    height: 21px;
    width: 100%;
    color: #4C5E70;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 16px;
    line-height: 18px;
    padding-bottom:17px;
    padding-top:5px;
    font-style: italic;
    height:30pt;
}
body .vimpMessage {
    height: 21px;
    width: 100%;
    color: #FF0D19;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 15px;
    line-height: 18px;
    padding-bottom:10px;
    padding-top:5px;
    font-style: italic;
}
body .dataEntryErrorMsg {
    height: 9pt;
    /*width: 200pt;*/
    color: #FF0D19;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 8pt;
    line-height: 9pt;
    /*padding-bottom: 2pt;*/
    /*padding-top: 2pt;*/
    font-style: italic;
    /*margin-left: 17pt;*/
}
.vImpMsgBox
{
	border: 1px solid #FF0D19;
	padding-left:20px;
	padding-bottom:15px;
	margin-right: 300px;
}
/* Style the tab */
ul.tab {
    overflow: hidden;
    background-color: white;
	font-family: 'Salesforce Sans', 'Helvetica' !important;
	border-bottom: 1px solid #E7E9ED;
	padding-left:0px;
}

ul.tstab {
    display:block;
    overflow: hidden;
    background-color: white;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    padding-left:0px;
}

/* Style the buttons inside the tab */
ul.tab a {
    float: left;
    border: none;
    outline: none;
    cursor: pointer;
    padding-top: 14px;
    padding-bottom: 16px;
    transition: 0.1s;
	font-weight:bold;
	color: #1D374C;
	font-family: 'Salesforce Sans', 'Helvetica' !important;
	text-decoration:none;
	margin-right:31px;
}

ul.tstab a {
    float: left;
    border: none;
    outline: none;
    cursor: pointer;
    padding-top: 14px;
    /*padding-bottom: 16px;*/
    transition: 0.1s;
	font-weight:bold;
	color: #1D374C;
	font-family: 'Salesforce Sans', 'Helvetica' !important;
	text-decoration:none;
}

/* Change background color of buttons on hover */
ul.tab a:hover {
	color: #000000;
	border-bottom: 2px solid #000000;
	font-weight:bold;
	font-family: 'Salesforce Sans', 'Helvetica' !important;
}

/* Create an active/current tablink class */
ul.tab a:active {
	border-bottom: 2px solid #000000;
	color: #000000;
	font-weight:bold;
	font-family: 'Salesforce Sans', 'Helvetica' !important;
}
.w3-border-red {
    color: #000000;
}
/*the Timesheet tabs are special*/
.timeEntryTab {
    height: 130px;
    width: 100px;
    border: 1px solid #E7E9ED;
    background-color: #F3F9FF;
    padding-left: 27px;
    padding-top: 16px;
    padding-bottom: 22px;
}

.selectedTimeEntry {
	height: 130px;
	width: 100px;
	border: 1px solid #E7E9ED;
	background-color: #FFFFFF;
	border-bottom:0px;
	padding-left: 27px;
    padding-top: 16px;
}
.phHoliday {
    color:black;
    background-color:orange !important;
}
.phText{
    margin-top: -10pt;
    font-size: 8pt;
    margin-bottom: -24px;
}
.phText2{
    margin-top: 6pt;
    color: orange;
    font-size: 14pt;
}
.timeEntryTab .timeEntryDate {
    font-size:30px;
    color: #1D374C;
    font-weight:bold;
    line-height:39px;
}
.timeEntryTab .timeEntryDay {
	height: 19px;
	width: 27px;
	opacity: 0.55;
	color: #1D374C;
	font-size: 15px;
	line-height: 19px;
	font-weight:normal;
}

.timeEntryTab .timeEntryHrs {
	height: 21px;
	width: 62px;
	opacity: 0.5;
	color: #1D374C;
	font-size: 16px;
	font-weight: bold;
	line-height: 21px;
	padding-top:20px;
}

.selectedTimeEntry .timeEntryDate {
    font-size:30px;
    color: #000000;
    font-weight:bold;
    line-height:39px;
}
.selectedTimeEntry .timeEntryDay {
	height: 19px;
	width: 27px;
	opacity: 0.55;
	color: #000000;
	font-size: 15px;
	line-height: 19px;
	font-weight:normal;
}

.selectedTimeEntry .timeEntryHrs {
	height: 21px;
	width: 62px;
	color: #000000;
	font-size: 16px;
	opacity:1;
	font-weight: bold;
	line-height: 21px;
	padding-top:22px;
}
.inputTimeEntry{
    box-sizing: border-box;
    appearance: normal;
    box-shadow: 0 0 0 rgba(0, 0, 0, 0);
    border-radius: 0;
    border-radius: 3px;
    background-clip: padding-box;
    background-image: none;
    background-color: #FFFFFF;
    border: 1px solid #DFE1E5;
    color: #4C5E70;
    cursor: auto;
    display: inline-block;
    font-style: normal;
    font-weight: normal;
    letter-spacing: 0;
    line-height: 50px;
    overflow-wrap: break-word;
    padding: 2px;
    text-align: center;
    text-indent: 0;
    text-size-adjust: 100%;
    text-transform: none;
    transition-duration: 0.1s, 0.1s;
    transition-property: border, background-color;
    transition-timing-function: linear, linear;
    height: 50px;
    width: 48px;
}

.noteBoxText{
    padding-bottom: 10px;
}

.trimLongMessage{
    width:100px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis
}

.inputTimeNotes{
    box-sizing: border-box;
    appearance: normal;
    box-shadow: 0 0 0 rgba(0, 0, 0, 0);
    border-radius: 0;
    border-radius: 3px;
    background-clip: padding-box;
    background-image: none;
    background-color: #FFFFFF;
    border: 1px solid #DFE1E5;
    color: #4C5E70;
    cursor: auto;
    display: inline-block;
    font-style: normal;
    font-weight: normal;
    letter-spacing: 0;
    line-height: 50px;
    overflow-wrap: break-word;
    padding: 2px;
    text-align: left;
    text-indent: 0;
    text-size-adjust: 100%;
    text-transform: none;
    transition-duration: 0.1s, 0.1s;
    transition-property: border, background-color;
    transition-timing-function: linear, linear;
    height: 50px;
    width: 150px;
}

body .x-btn button,
body .btn,
body .btnImportant,
body .btnDisabled,
body .btnCancel,
body .menuButton .menuButtonButton,
body .menuButton .menuButtonMenu a,
body .menuButton .menuButtonMenu input.theOption,
h4,
h5,
h6 {
  font-family: 'Salesforce Sans', 'Helvetica' !important;
  /*  -webkit-appearance: none;*/
}

h4 {
    font-size: 10pt;
}

h5 {
    font-size: 10pt;
    font-weight:normal;
}

body img[src="/img/loading.gif"] {
  margin: 4px 8px;
  display: inline-block;
}

body input,
body select {
  font-family: 'Salesforce Sans', 'Helvetica' !important;
  font-size: 14px;
  margin-top:5px;
  margin-bottom:5px;
  /*  -webkit-appearance: none;*/
}

body input {
  min-width: 17px;
    /*  -webkit-appearance: none;*/
}
/*body textarea,
body input[type="text"],
body input[type="email"],
body input[type="password"],
body input[type="number"]*/
.pageInput {
    box-sizing: border-box;
    -moz-box-sizing: border-box;
    appearance: normal;
    -webkit-appearance: none;
    -moz-appearance: none;
    -webkit-box-shadow: 0 0 0 rgba(0, 0, 0, 0);
    -moz-box-shadow: 0 0 0 rgba(0, 0, 0, 0);
    box-shadow: 0 0 0 rgba(0, 0, 0, 0);
    -webkit-border-radius: 0;
    -moz-border-radius: 0;
    border-radius: 0;
    -webkit-border-radius: 3px;
    -moz-border-radius: 3px;
    border-radius: 3px;
    -moz-background-clip: padding;
    -webkit-background-clip: padding-box;
    -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
    background-clip: padding-box;
    background-image: none;
    background-color: #FFFFFF;
    border: 1px solid #DFE1E5;
    color: #4C5E70;
    cursor: auto;
    display: inline-block;
    font-style: normal;
    font-weight: normal;
    letter-spacing: 0;
    line-height: 50px;
    margin-top: 10px;
    margin-bottom:49px;
    margin-left:0px;
    margin-right:0px;
    min-height: 30px;
    overflow-wrap: break-word;
    padding: 0 22px 0 22px;
    text-align: start;
    text-indent: 0;
    text-size-adjust: 100%;
    text-transform: none;
    transition-duration: 0.1s, 0.1s;
    transition-property: border, background-color;
    transition-timing-function: linear, linear;
    min-width: 250pt;
}

body input,
body textarea:active,
body input[type="text"]:active,
body input[type="email"]:active,
body input[type="password"]:active,
body input[type="button"]:active,
body input[type="submit"]:active,
body input[type="number"]:active,
body textarea:focus,
body input[type="text"]:focus,
body input[type="email"]:focus,
body input[type="password"]:focus,
body input[type="button"]:focus,
body input[type="submit"]:focus,
body input[type="number"]:focus
{
    outline: 0;
    border: 1px solid #000000;
    background-color: #FFFFFF;
    box-shadow: inset 0 0px 0px 0 rgba(0,0,0,0.14);
}
body input[type="button"],
body input[type="submit"] {
    box-sizing: border-box;
    transition: all linear 150ms;
    position: relative;
    display: inline-block;
    background: transparent;
    background-clip: border-box;
    border: 1px solid transparent;
    line-height: 1.42857143;
    text-decoration: none;
    font-weight: normal;
    white-space: normal;
    user-select: none;
    padding-top: 6px;
    padding-bottom: 6px;
    padding-left: 1rem;
    padding-right: 1rem;
    border: 1px solid #dddbda;
    transition: border 0.15s linear;
    border-color: #dddbda;
    background-color: white;
    line-height: 21px;
    cursor: pointer;
    background-color: #000000;
    border-color: #000000;
    color: #FFFFFF;
    text-align: center;
    -moz-box-sizing: border-box;
    -moz-transition: all linear 150ms;
    -webkit-transition: all linear 150ms;
    -o-transition: all linear 150ms;
    -webkit-appearance: none;
    -webkit-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
}

input[type=number]::-webkit-outer-spin-button,
input[type=number]::-webkit-inner-spin-button {
    /*-webkit-appearance: none;*/
    margin: 0;
}

input[type=number] {
    -moz-appearance:textfield;
}

body .pageButton{
    vertical-align: middle;
    min-height: 50px;
    font-size: 16px;
    border-radius: 4px;
   /* margin-top:21px;*/
     /*  -webkit-appearance: none;*/
}
body .noteBoxButton{
    min-height: 30px;
    min-width: 50px;
    border-radius: 3px;
    font-size:14px;
    float:right;
}
body .noteBoxBtn2{
    min-height: 30px;
    min-width: 50px;
    border-radius: 4px;
    font-size:14px;
}
.logoBarIcons{
    font-size:21px;
    float:right;
    margin-right:23px;
    margin-top:23px;
    color: white;
}
.notifIcon {
    width:30px;
    height:30px;
    position:relative;
    float:right;
    font-size:21px;
    margin-right:23px;
    margin-top:23px;
    color: white;
}
.notifTxt {
    background:red;
    font-size:xx-small;
    position: absolute;
    bottom:19px;
    left:16px;
    border-radius:6px;
    padding-right:2px;
    padding-left:2px;
    height:15px;
    width:10px;
    line-height:15px;
    text-align:center;
}
a {
    color:#000000;
    text-decoration:none;
}

.iconMain{
   color:#000000;
   vertical-align:middle;
   float:left;
}
.iconHInv{
transform: rotate(180deg);
}
.iconVInv{
transform: rotate(90deg);
}

.icon-chevron:before {
content: '\e800';
} /* 'î €' */
.icon-note:before {
content: '\e802';
} /* 'î ‚' */
.icon-notifications:before {content: '\e803';} /* 'î ƒ' */
.icon-right-arrow:before {content: '\e804';} /* 'î „' */
.icon-left-arrow:before {content: '\e804';transform:rotate(180deg);} /* 'î „' */
.icon-search:before {content: '\e805';} /* 'î …' */
.icon-picklistarrow:before {content: '\e806';} /* 'î †' */
.icon-timesheetwhite:before {content: '\e807';} /* 'î ‡' */
.icon-timesheetgrey:before {content: '\e808';} /* 'î ˆ' */
.icon-profilewhite:before {content: '\e809';} /* 'î ‰' */
.icon-profilegrey:before {content: '\e80a';} /* 'î Š' */
.icon-paywhite:before {content: '\e80b';} /* 'î ‹' */
.icon-paygrey:before {content: '\e80c';} /* 'î Œ' */
.icon-homew:before {content: '\e80d';} /* 'î ' */
.icon-homegrey:before {content: '\e80e';} /* 'î Ž' */
.icon-expensewhite:before {content: '\e811';} /* 'î ‘' */
.icon-expensegrey:before {content: '\e812';} /* 'î ’' */
.icon-ContractG:before {content: '\e813';} /* 'î “' */
.icon-contractwhite:before {content: '\e814';} /* 'î ”' */
.icon-chevronblue:before {content: '\e815';} /* 'î •' */
.icon-down:before {content: '\e816';} /* 'î –' */
.icon-dots:before {content: '\e817';} /* 'î —' */



.icon-attach-1:before {
    content: '\e818';
} /* 'î ˜' */
.icon-attach-1:hover {
    color:white;
    background-color:#000000;
    border-radius:6px;
}
.icon-menu:before {content: '\e81a';} /* 'î š' */
.icon-spinner:before {
content: '\e839';
-moz-animation: spin 2s infinite linear;
  -o-animation: spin 2s infinite linear;
  -webkit-animation: spin 2s infinite linear;
  animation: spin 2s infinite linear;
  display: inline-block;
  } /* 'î ¹' */


.logoBarPhoto{
    height:40px;
    width:auto;
    float:right;
    margin-top:5px;
    margin-bottom:5px;
    border-radius:50%;
}
.logoBarLogo{
    height:40px;
    width:auto;
    left:50px;
    top: 5px;
    position:absolute;
}

.logoBarName {
    position:inherit;
    padding-left:210pt;
    line-height: 21px;
    padding-top:18px;
}
.footerImage{
    height:21px;
    float:right;
    width:auto;
    margin-bottom:30px;
    margin-right:31px;
}
.footerText{
    font-size:11px;
    margin-right:10px;
}

.status {
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 11px;
    font-weight: bold;
    line-height: 14px;
    text-align: center;
    text-transform:uppercase;
}

.statusNew {
    height: 23px;
    width: 84.62px;
    border-radius: 12.5px;
    padding-top:10px;
    background-color:rgba(255,102,0,0.14);
    color:#FF6600;
}
.statusApproved {
    height: 23px;
    width: 84.62px;
    border-radius: 12.5px;
    padding-top:10px;
    background-color:rgba(0,173,55,0.14);
    color:#00AD37;
}

.statusSubmitted {
    height: 23px;
    width: 84.62px;
    border-radius: 12.5px;
    padding-top:10px;
    background-color:rgba(13,138,255,0.14);
    color:#000000;
}
.statusRejected {
    height: 23px;
    width: 84.62px;
    border-radius: 12.5px;
    padding-top:10px;
    background-color:rgba(194, 0, 0,0.14);
    color:#C20000;
}

.tableStyle{
    border-collapse: collapse;
    margin-right:60px;
}

body th{
    height: 19px;
    width: 83px;
    opacity: 0.55;
    color: #1D374C;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 15px;
    line-height: 19px;
    /*text-align: center;*/
}
body tr{
    height:60px;
    width:1124px;
    margin-right:30px;
    margin-left:30px;
    border-bottom:1px solid #E7E9ED;
}
body td{
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 14px;
    margin-top:5px;
    margin-bottom:5px;

    /*max-width:330pt;*/
}

.expClaimTable {
    width:20%;
}

.expensesTable {
    width:12%;
}

td.imptd{
    font-weight:bold !important;
    color:#1D374C;
}
td.imptd_tse{
    font-weight:bold !important;
    color:#1D374C;
    min-width:112px;
    vertical-align:middle;
}

td.tse{
    min-width:112px !important;
}
th.tsStatusth{
    border-bottom:1px solid #E7E9ED;
    text-align:left;
    /*width:281px;
    text-align:center;*/
}

th.tsTableth{
    border-bottom:1px solid #E7E9ED;
    width:281px;
    text-align:left;
}

th.expTableth{
    border-bottom:1px solid #E7E9ED;
    width:281pt;
    text-align:left;
    font-size:10pt;
}

th.tsTableth_Button{
    border-bottom:1px solid #E7E9ED;
    max-width:80px;
    margin-left:1250px;
}

a.CancleCls{
	border-bottom:1px solid #E7E9ED;
    max-width:80px;
    margin-left:1250px;
}

.mobileTSinfoSE {
    display:none;
}

.mobileTSinfoJob {
  display:none;
}
.mobileTSinfoDate {
   display:none;
}
.mobileTSstatus{
    display:none;
}
.tsMobPgTotal{
    display:none;
}
.tsMobPgTotalW{
    display:none;
}
.mobileTSEtabT {
   display:none;
}
.mobileTSEtabD {
   display:none;
}
.mobileTSE{
    display:none;
}
.mobExpTable {
    display:none;
}
.mobExpTable2 {
    display:none;
}
.clientMob {
    display:none;
}
.allDays {
    display:none;
}

.tsTabM {
    display:none;
}

.tsDayMenu {
    display:none;
}
.tsTabBack {
    display:none;
}
.mobExpROtext {
display:none;
}
.mobExpROtext2 {
display:none;
}
.mobAddExp2{
display:none;
}
.onlyMob{
display:none;
}
.addRemButton {
    float:left;
    margin-right: 0pt;
    margin-left:0pt;
    border-radius: 3pt;
    max-height: 18pt;
    min-width: 18pt;
    margin-top: 0pt;
    padding-top: 0pt !important;
    padding-bottom: 0pt !important;
    background-color: #F3F9FF !important;
    color: #000000 !important;
    font-size: 8pt;
    padding-left: 4pt !important;
    padding-right: 4pt !important;
    font-weight:bold !important;
}
/*.addRemExpButton {
    float:left;
    margin-right: 10pt;
    border-radius: 3pt;
    max-height: 18pt;
    min-width: 18pt;
    margin-top: 0pt;
    padding-top: 0pt !important;
    padding-bottom: 0pt !important;
    background-color: #F3F9FF !important;
    color: #000000 !important;
    font-size: 18pt;
    padding-left: 4pt !important;
    padding-right: 4pt !important;
    font-weight:bold !important;
}*/

td.wider {
    min-width:200pt;
}

body input[type="button"]:hover,
body input[type="submit"]:hover,
body input[type="button"]:active,
body input[type="submit"]:active,
body input[type="button"]:focus,
body input[type="submit"]:focus {
    outline: 0;
    border-color: #000000;
    background-color: #ffffff;
    box-shadow: 0 0 3px #000000;
    color: #000000;
    -webkit-box-shadow: 0 0 3px rgba(13, 138, 255, 1) inset;
    -moz-box-shadow: 0 0px 3px rgba(13, 138, 255, 1) inset;
}
body input[type="button"]:active,
body input[type="submit"]:active {
    box-shadow: 0 1px 7px rgba(0, 0, 0, 0.25) inset;
    -webkit-box-shadow: 0 1px 7px rgba(0, 0, 0, 0.25) inset;
    -moz-box-shadow: 0 1px 7px rgba(0, 0, 0, 0.25) inset;
}
     body .tsPgDelExp {
        margin-top: 5pt;
        font-weight:normal !important;
        min-height: 35pt;
        max-width: 110pt;
        border-radius: 3pt;
        margin-right: 31pt;
        margin-bottom:20pt;

    }

body input[type="button"] + input.btn,
body input[type="submit"] + input.btn,
body input[type="button"] + input[type="button"],
body input[type="submit"] + input[type="button"],
body input[type="button"] + input[type="submit"],
body input[type="submit"] + input[type="submit"] {
    margin-left: 4px;

}

body input[type="radio"],
body input[type="checkbox"], .largerRadioBox
 {
    margin-top: 9px;
    margin-bottom: 9px;
    min-width: 10px;
    height:30px;
    width:30px;
    vertical-align:middle;
}

.clickable { cursor: pointer; }
.hide {display:none;}


body select {
    box-sizing: border-box;
    -moz-box-sizing: border-box;
    -webkit-border-radius: 4px;
    border-radius: 4px;
    -moz-border-radius: 4px;
    background-clip: padding-box;
    -moz-background-clip: padding;
    -webkit-background-clip: padding-box;
    background: none;
    width: auto;
    border: 1px solid #d8dde6;
    height: 34px;
    top: auto;
    padding: 0 40px 0 10px;

}
body select[multiple="multiple"] {
  height: auto;
  min-height: 110px;
  padding-right: 10px;
}
body select[multiple="multiple"] optgroup:first-child {
  padding-top: 7px;
}
body.hasMotif {
  margin: 0;
}
body .outer td.oRight {
  padding-top: 9px;
}
body .message {
  -webkit-border-radius: 0;
  -moz-border-radius: 0;
  border-radius: 0;
  -moz-background-clip: padding;
  -webkit-background-clip: padding-box;
  background-clip: padding-box;
  background-color: rgba(0, 0, 120, 0.05);
  border-width: 0;
  border-top-width: 3px;
  margin-left: 0;
  margin-right: 0;
  width:250pt;
}
body .message td {
  vertical-align: middle;
}
body .message.errorM6,
body .message.errorM4,
body .message.errorM3,
body .message.errorM2,
body .message.errorS1 {
  background-color: rgba(120, 0, 0, 0.05);
}

hr {
    height: 0.5px;
    width: 1129px;
    transform: scaleY(-0.5);
    border: solid 1px #E7E9ED;
    margin-left:0px;
}

body .note{
    font-weight:normal;
    font-size:14px;
    font-style:italic;
    width:100%;
}

body .linkText{
    font-weight:normal;
    font-size:14px;
    font-style:normal;
    color:#000000;
}

input:disabled{
  color:#000000 !important
      opacity: .5;
      width: 13px;
      height: 13px;
}

.notificationBox
 {
 	border: 1px solid #E7E9ED;
 	padding-left:100px;
 	padding-bottom:15px;
 	padding-top:15px;
 	padding-right:100px;
 	margin-top: 30px;
 	margin-right: 30px;
 	margin-left:0px;
 	margin-bottom:30px;
 }
 .smallnotificationBox
 {
 	border: 1px solid #E7E9ED;
 	padding-left:300px;
 	padding-bottom:15px;
 	padding-top:15px;
 	padding-right:300px;
 	margin-top: 30px;
 	margin-right: 30px;
 	margin-left:0px;
 	margin-bottom:30px;
 }
 /*DFP IE11 support requires hard code of colour*/
.dropDownItem{
    display:none;
    font-size: 12px;
    color: white;
    margin-left: 15px;
    font-style: normal;
    margin-top: -5px;
    background-color: #666666; /*var(--highlightColour);*/
    padding:5px;
    border-radius:10px;
    margin-bottom:7px;
}
.dropDown:hover .dropDownItem {
    display: block;
    float:left;
}
body input[type="button"].nextArrowBox,
body input[type="submit"].nextArrowBox {
    height: 34px;
    width: 55px;
    border: 1px solid #DFE1E5;
    border-radius: 0 3px 3px 0;
    background-color: #F3F9FF;
    color:#4C5E70;
    font-size: 14px;
    float:left;
      /*  -webkit-appearance: none;*/
}

body input[type="button"].disabledArrowBox,
body input[type="submit"].disabledArrowBox  {
	height: 34px;
	width: 55px;
	border: 1px solid #DFE1E5;
	border-radius: 3px 0 0 3px;
	background-color: white;
	color:#DFE1E5;
	font-size: 14px;
	float:left;
	/*transform: rotate(540deg);*/
	  /*  -webkit-appearance: none;*/
}

div.fileinputs {
	min-height:80px;
	margin-top:15px;
}

input.file {
	position: relative;
    text-align: right;
    opacity: 10;
    z-index: 2;
    font-family: 'Salesforce Sans', 'Helvetica' !important;
    font-size: 16px;
    border-color: white;
    margin-right:15px;
}

/* Autocomplete
----------------------------------*/
.ui-autocomplete { position: absolute; cursor: default; }
.ui-autocomplete-loading { background: white url('images/ui-anim_basic_16x16.gif') right center no-repeat; }

/* workarounds */
* html .ui-autocomplete { width:1px; } /* without this, the menu expands to 100% in IE6 */


/* Menu
----------------------------------*/
.ui-helper-hidden-accessible {
       border: 0;
       clip: rect(0 0 0 0);
       height: 1px;
       margin: -1px;
       overflow: hidden;
       padding: 0;
       position: absolute;
       width: 1px;
}
.ui-menu {
        list-style:none;
        padding: 0.5px;
        margin: 0;
        display:block;
        font-family: 'Salesforce Sans', 'Helvetica' !important;
        font-size: 14px;
        width:295pt;
        border: 1px solid #000000;
}
.ui-menu .ui-menu {
        margin-top: -3px;
        border: 1px solid #000000;
        padding:0.5pt;
        width:295pt;
}
.ui-menu .ui-menu-item {
        margin:0;
        padding: 0.5pt;
        width: 294pt;
        background-color: #F3F9FF;
        color:#000000;
}
.ui-menu .ui-menu-item a {
        text-decoration:none;
        display:block;
        /*padding:.2em .4em;*/
        line-height:1.5;
        zoom:1;
        background-color: #F3F9FF;
        color:#000000;
        width: 294pt;
        margin:0.2pt;
}
.ui-menu .ui-menu-item a.ui-state-hover,
.ui-menu .ui-menu-item a.ui-state-active {
        margin:0.2pt;
        font-weight:bold;
        width: 294pt;
}

/*
   Animation, for spinners - you can spin any image or icon
*/
.animate-spin {
  -moz-animation: spin 2s infinite linear;
  -o-animation: spin 2s infinite linear;
  -webkit-animation: spin 2s infinite linear;
  animation: spin 2s infinite linear;
  display: inline-block;
}
.input-toggler, .menu, .menu-item {
    display:none;
}

@media only screen and (max-width:900px){

.onlyMob{
    display:block;
}

    .input-toggler, .menu, .menu-item
    {
        display:block;
    }
    body
    {
        color: #4C5E70;
        font-family: 'Salesforce Sans', 'Helvetica' !important;
        font-size: 9pt;
        line-height: 11pt;
        background: none !important;
        width:380pt;
        height:auto;
        padding-top:0pt;
        padding-left:0pt;
        overflow-x: hidden;
    }
    body th {
        height: 19px;
        width: 83px;
        opacity: 0.55;
        color: #1D374C;
        font-family: 'Salesforce Sans', 'Helvetica' !important;
        font-size: 11px;
        line-height: 19px;
        /*text-align: left;*/
    }
    body td
    {
        font-family: 'Salesforce Sans' !important;
        font-size: 14pt;
        margin-top:5pt;
        margin-bottom:5pt;
        /*text-align:center;*/
        width:250pt;/*180pt;*/
    }

    body .tseLabel {
      box-sizing: border-box;
      letter-spacing: 1pt;
      color: #1D374C;
      cursor: default;
      display: inline;
      font-family: 'Salesforce Sans', 'Helvetica' !important;
      font-size: 9pt;
      font-weight: normal;
      height: 18pt;
      hyphens: auto;
      text-transform: uppercase;
      line-height: 18pt;
      margin-bottom: 0;
      margin-top: 0;
      overflow-wrap: break-word;
      text-size-adjust: 100%;
      visibility: visible;
      width: auto;
      word-wrap: break-word;
      margin-left:18pt;
    }
    body .note{
        font-weight:normal;
        font-size:11pt;
        font-style:italic;
        width:100%;
        padding-top:10pt;
    }
    .mobileLabel{
        padding-right:147pt;
    }
    .vImpMsgBox
    {
    	border: 1pt solid #FF0D19;
    	padding-left:20pt;
    	padding-bottom:0pt;
    	margin-right: 116pt;
    }
    body .roText {
        height: 21pt;
        width: 231pt;
        color: #4C5E70;
        font-family: 'Salesforce Sans', 'Helvetica' !important;
        font-size: 12pt;
        line-height: 18pt;
        padding-bottom:17pt;
        padding-top:5pt;
        padding-right:100pt;
    }
    body .dataEntryErrorMsg {
        height: 9pt;
        width: 200pt;
        color: #FF0D19;
        font-family: 'Salesforce Sans', 'Helvetica' !important;
        font-size: 8pt;
        line-height: 9pt;
        padding-bottom: 2pt;
        padding-top: 2pt;
        font-style: italic;
        margin-left: 17pt;
    }
    .iconEllipses {
        color:#000000;
        float:right;
        margin-top:-6pt;
        font-size:27pt;
        position:absolute;
    }
    .iconMain{
       color:#000000;
       vertical-align:middle;
       float:left;
       font-size:14pt;
    }
    .mobileEditChkbox {
        position:absolute;
        opacity:0;
    }
    .notificationBox
     {
     	border: 1pt solid #E7E9ED;
     	padding:10pt;
     	margin-top: 8pt;
     	margin-right: 25pt;
     	margin-left:-8pt;
     	margin-bottom:5pt;
     	width:250pt;
     }
     .smallnotificationBox
     {
     	border: 1px solid #E7E9ED;
     	padding-left:300px;
     	padding-bottom:15px;
     	padding-top:15px;
     	padding-right:300px;
     	margin-top: 30px;
     	margin-right: 30px;
     	margin-left:0px;
     	margin-bottom:30px;
     }
     .tsPgTotal{
         height: 52px;
         width:auto;
         color: #1D374C;
         font-family: 'Salesforce Sans', 'Helvetica' !important;
         font-size: 40px;
         font-weight: bold;
         line-height: 52px;
         float:right;
         padding-bottom:0px;
     }

    .tseView {
        position:relative;
        background-color:aliceblue;
        border:0.5pt solid lightgrey;
        margin-left:-15pt;
        min-width:300pt;
        padding-top:10pt;
    }

    .tseMobCancel{
        margin-right: -28pt;
        max-height: 21pt;
        max-width: 100pt;
        margin-top: -18pt;
        padding-top: 0pt !important;
        background-color: aliceblue !important;
        color: red !important;
        font-size: 11pt;
        border: 0 !important;
        box-shadow:none;
        float:right;
    }

    .tseMobDelete {
        margin-left: 6pt;
        max-height: 21pt;
        max-width: 100pt;
        margin-top: -18pt;
        padding-top: 0pt !important;
        background-color: aliceblue !important;
        color: red !important;
        font-size: 11pt;
        border: 0 !important;
        box-shadow:none;
        float:left;
    }

    .tseMobDelete:focus {
        box-shadow:none !important;
    }
    .tseMobDelete:hover {
        box-shadow:none !important;
    }
    .tseMobCancel:focus {
        box-shadow:none !important;
    }
    .tseMobCancel:hover {
        box-shadow:none !important;
    }

    .addRemButton {
        float:left;
        margin-right: 10pt;
        border-radius: 3pt;
        max-height: 18pt;
        min-width: 18pt;
        margin-top: 0pt;
        padding-top: 0pt !important;
        padding-bottom: 0pt !important;
        background-color: #F3F9FF !important;
        color: #000000 !important;
        font-size: 18pt;
        padding-left: 4pt !important;
        padding-right: 4pt !important;
        font-weight:bold !important;
    }
    .dropdownM {
        height:34pt;
        width:250pt;
        background-color:white;
        margin-left:18pt;
    }
    .dropdownM table tr td{
        display:block;
        margin-top:30pt;
    }
    .inputTimeEntryHrs{
        box-sizing: border-box;
        appearance: normal;
        box-shadow: 0 0 0 rgba(0, 0, 0, 0);
        border-radius: 3pt;
        background-clip: padding-box;
        background-image: none;
        background-color: #FFFFFF;
        border: 0.5pt solid #DFE1E5 !important;
        color: #4C5E70;
        cursor: auto;
        display: inline-block;
        font-style: normal;
        font-weight: normal;
        letter-spacing: 0;
        line-height: 50pt;
        overflow-wrap: break-word;
        padding: 2pt;
        text-align: center;
        text-indent: 0;
        text-size-adjust: 100%;
        text-transform: none;
        transition-duration: 0.1s, 0.1s;
        transition-property: border, background-color;
        transition-timing-function: linear, linear;
        height: 40pt;
        width: 40pt;
        margin-left:18pt;
    }
    .inputTimeEntryMin{
        box-sizing: border-box;
        appearance: normal;
        box-shadow: 0 0 0 rgba(0, 0, 0, 0);
        border-radius: 3pt;
        background-clip: padding-box;
        background-image: none;
        background-color: #FFFFFF;
        border: 0.5pt solid #DFE1E5 !important;
        color: #4C5E70;
        cursor: auto;
        display: inline-block;
        font-style: normal;
        font-weight: normal;
        letter-spacing: 0;
        line-height: 50pt;
        overflow-wrap: break-word;
        padding: 2pt;
        text-align: center;
        text-indent: 0;
        text-size-adjust: 100%;
        text-transform: none;
        transition-duration: 0.1s, 0.1s;
        transition-property: border, background-color;
        transition-timing-function: linear, linear;
        height: 40pt;
        width: 40pt;
        margin-left:0pt;
        cursor:pointer;
    }

    .noteBoxText{
        padding-bottom: 10px;
    }
    .selectButton{
        margin-right:60pt;
        float:right;
    }

    .trimLongMessage{
        width:100px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis
    }

    .messageText {
        font-size: 12pt;
        line-height:18pt;
        margin-left:18pt;
    }

    .inputTimeNotes{
        box-sizing: border-box;
        appearance: normal;
        box-shadow: 0 0 0 rgba(0, 0, 0, 0);
        border-radius: 0;
        border-radius: 3pt;
        background-clip: padding-box;
        background-image: none;
        background-color: #FFFFFF;
        border: 1px solid #DFE1E5;
        color: #4C5E70;
        cursor: auto;
        display: inline-block;
        font-style: normal;
        font-weight: normal;
        letter-spacing: 0;
        line-height: 12pt;
        overflow-wrap: break-word;
        padding: 2pt;
        text-align: left;
        text-indent: 0;
        text-size-adjust: 100%;
        text-transform: none;
        transition-duration: 0.1s, 0.1s;
        transition-property: border, background-color;
        transition-timing-function: linear, linear;
        height:60pt;
        width: 250pt;
    }
    .pageContent{
    	background-color: white;
    	display: block;
    	margin-top:76pt;
    	margin-left:8pt;
    }
    h1 {
        height: 52pt;
        width: 100%;
        color: #1D374C;
        font-size: 23pt;
        font-weight: bold;
        line-height: 30pt;
        font-family: 'Salesforce Sans', 'Helvetica' !important;
        margin-top:5pt;
        margin-bottom:5pt;
    }
    p {
        max-width:250pt;
    }
    h2 {
        height: 26pt;
        max-width: 255pt;
        color: #1D374C;
        font-family: 'Salesforce Sans', 'Helvetica' !important;
        font-size: 15pt;
        font-weight: bold;
        line-height: 21pt;
        padding-bottom:5pt;
    }

    .clientMob {
        display:block;
        padding-bottom:0pt !important;
        margin-right:110pt !important;
        font-size: 11pt;
        font-weight: bold;
        color: #1D374C;
    }

    h3 {
        height: 18pt;
        width: 250pt;
        color: #1D374C;
        font-family: 'Salesforce Sans', 'Helvetica' !important;
        font-size: 13pt;
        font-weight: bold;
        line-height: 16pt;
    }

    /* Style the buttons inside the tab */
    ul.tab a {
        float: left;
        border: none;
        outline: none;
        cursor: pointer;
        padding-top: 0pt;
        padding-bottom: 14pt;
        transition: 0.1s;
    	font-weight:bold;
    	color: #1D374C;
    	font-family: 'Salesforce Sans', 'Helvetica' !important;
    	text-decoration:none;
    	margin-right:18pt;
    	font-size:11pt;
    	line-height:13pt;
    }

    ul.tstab a {
        float: left;
        border: none;
        outline: none;
        cursor: pointer;
        padding-top: 14pt;
        transition: 0.1s;
    	font-weight:bold;
    	color: #1D374C;
    	font-family: 'Salesforce Sans', 'Helvetica' !important;
    	text-decoration:none;
    }

    /* Change background color of buttons on hover */
    ul.tab a:hover {
    	color: #000000;
    	border-bottom: 2pt solid #000000;
    	font-weight:bold;
    	font-family: 'Salesforce Sans', 'Helvetica' !important;
    }

    /* Create an active/current tablink class */
    ul.tab a:active {
    	border-bottom: 2pt solid #000000;
    	color: #000000;
    	font-weight:bold;
    	font-family: 'Salesforce Sans', 'Helvetica' !important;
    }
    th.tsStatusth, th.tsTableth, .tableHeader, .dtInfo{
        display:none;
    }
    td.imptd {
       font-weight: bold !important;
       color: #1D374C;
       padding-top: 12pt;
    }
    td.tse {
        text-align:left;
    }
    .prjCode {
        font-weight:bold;
        color:#1D374C;
        display:block;
        font-size: 11pt;
        padding-top: 5pt;
        max-width:120pt;
    }
    .mobileTSinfoSE {
        font-weight:normal;
        font-size: 11pt;
        min-width:120pt;
        /*padding-top:0pt;*/
        margin-bottom:0pt;
    }
    .mobileTSTotHrs {
        font-weight: bold;
        font-size: 14pt;
        /*min-width: 110pt;*/
        text-align: right;
        padding-bottom:0pt;
        color:#1D374C;
    }
    .mobileTSinfoJob {
        display:block;
        font-weight:normal;
        font-size: 11pt;
        padding-bottom: 9pt;
        padding-top: 5pt;
        min-width:180pt;
    }
    .mobileTSinfoDate {
        display:block;
        font-weight:normal;
        font-size: 14pt;
        padding-bottom: 10pt;
        min-width:180pt;
    }

    .mobileHrs{
        width: 65pt;
        font-size: 12pt;
        font-weight: normal;
        padding-bottom: 8pt;
    }

    .selectedTimeEntry .timeEntryDate{
        font-size: 18pt;
        color: #1D374C;
        font-weight: bold;
        line-height: 18pt;
    }
    .timeEntryTab .timeEntryDate {
        font-size: 14pt;
        color: #1D374C;
        font-weight: bold;
        line-height: 16pt;
    }

    .timeEntryDate{
        color: #1D374C;
        font-size: 18pt;
        padding-top: 10pt;
        padding-bottom: 10pt;
    }
    .timeEntryTot {
        display:block;
        float:right;
        font-size: 14pt;
        color: #1D374C;
        font-weight: bold;
        line-height: 18pt;
        margin-top: 5pt;
        margin-right:45pt;
    }
    .timeEntryTotE {
        display:block;
        float:left;
        font-size: 14pt;
        color: #1D374C;
        font-weight: bold;
        line-height: 18pt;
        margin-top: 5pt;
        margin-left:0pt;
        width:90pt;
        height:14pt;
    }

    .mobileTSstatus{
        display:block;
        width:140pt;
        padding-top:12pt;
    }
    .mobileTSEtabT {
        display:block;
        float:right;
        font-size: 14pt;
        color: #1D374C;
        font-weight: bold;
        line-height: 18pt;
        margin-top: 0;
        margin-right:5pt;
    }
    .mobileTSEbutton  {
        margin-top: 10pt;
        width: 250pt;
        border-radius: 6pt;
        height: 40pt;
    }
    .mobileTSEbuttonSave  {
       margin-left:18pt;
    }

    .left18 {
        margin-left:18pt;
    }

    .mobileTSEbuttonAdd  {
       width: 80pt;
       border-radius:6px;
       font-size:9pt;
       margin-top:10pt;
    }

    .mobileTSEtabD {
       display:block;
       float:right;
       margin-right:70pt;
       font-size: 16pt;
       color: #1D374C;
       font-weight: bold;
       line-height: 18pt;
       margin-top: 0;
    }
    .mobileTSE{
        display:block;
        top:0;
        left:0;
        z-index:4;
    }
    .tableStyle{
        border-collapse:collapse;
        max-width:300pt;
    }

    th.tsTableth{
        border-bottom:1px solid #E7E9ED;
        width:160px;
        text-align:left;
    }

    .tstabM {
        display:block;
        margin:0;
        padding:0;
    }

    .tsTabMHide {
        display:none;
    }

    .tsTabBack {
        display:block;
    }

    .allDays {
        display:block;
    }

    .tsDayMenu {
        display:block;
    }
    body .linkText {
        font-weight: normal;
        font-size: 11pt;
        font-style: normal;
        color: #000000;
        padding-bottom: 10pt;
    }
    .tsPgDate {
        height:22pt;
        width:300pt;
        color:#1D374C;
        font-size:16pt;
        font-weight:bold;
        line-height:18pt;
        font-family:'Salesforce Sans', 'Helvetica' !important;
        padding-bottom:0px;
        margin-top:5pt;
        margin-bottom:0pt;
    }

    .tsLeftText {
        float:left;
        width:160pt;
    }
    .tsRightText {
        float:right;
        height:26pt;
        line-height:45pt;
    }
    .tsMobPgTotal{
        display:block;
    }
    .tsMobPgTotalW{
        display:block;
        margin-left:45pt;
    }

    .timeEntryTab, .selectedTimeEntry {
        height: 20pt;
        width: 230pt;
        /*border: 1pt solid #E7E9ED;*/
        border-top:1pt solid #E7E9ED;
        border-left:1pt solid #E7E9ED;
        border-right:1pt solid #E7E9ED;
        background-color: white;
        padding-top:12pt;
        padding-bottom:12pt;
        padding-right:6pt;
        padding-left:6pt;

    }

    body .tsPgSubmit {
        min-height: 40pt;
        min-width: 165pt;
        border-radius: 3pt;
        font-size: 12pt;
        margin-right:206pt;
        margin-left:0pt;
    }

    body .tsPgCreateExp {
        min-height: 40pt;
        min-width: 250pt;
        border-radius: 6pt;
        margin-right:121pt;
        margin-left:0pt;
        margin-top:-12pt;
    }

    body .tsPgSubmitExp {
        min-height: 40pt;
        min-width: 250pt !important;
        border-radius: 6pt;
        margin-right: 328pt !important;
        margin-left: 0pt;
        margin-top: -90pt;
    }


     body .tsPgDelExp {
        margin-top: 78pt;
        font-weight:normal !important;
        min-height: 40pt;
        min-width: 250pt !important;
        border-radius: 6pt;
        margin-right: 326pt !important;
        margin-left: 0pt;
        margin-bottom:20pt;
    }

    .expHomeTable {
        margin-top: 50pt;
    }
    .mobExpTable {
        display:block;
        float:left;
    }
    .mobExpTable2 {
        display:block;
        float:right;
        margin-top:-90pt;
    }
    .mobExpId{
        margin-bottom: 18pt;
        font-size: 14pt;
        color: #1D374C;
        font-weight:bold;
    }
    .mobExpLabel {
        font-size: 10pt;
        font-weight: bold;
        color: ;
        padding: 0;
        margin: 0;
        height: 10pt;
        line-height: 10.5pt;
    }
    .mobExpROtext {
        display:block;
        font-size: 13pt;
        margin-bottom: 10pt;
        margin-top: 4pt;
        max-width: 160pt;
    }
    .mobExpROtext2 {
        display:block;
        font-size: 13pt;
        margin-bottom: 20pt;
        margin-top: 14pt;
        max-width: 160pt;
        margin-right:9pt;
        text-align:right;
        margin-left:0pt;
    }
    .mobAddExp2{
        margin-top: 0pt;
        font-size: 11pt;
        min-width: 48pt;
        min-height: 30pt;
        margin-right: 85pt;
        float: right;
        margin-bottom: 0pt;
    }

body    .mobAddExp{
        display:block;
        margin-top:-5pt;
        font-size:11pt;
        min-width:110pt;
        min-height:30pt;
        margin-right:62pt;
        float:right;
        margin-bottom:10pt;
    }
    body .mobAddExpClaim{
        display:block;
    }
    .inputExpDate {
        max-width:110pt;
        margin-top:10pt;
        margin-bottom:19pt;
        font-size:12pt;
        padding-left:8pt;
    }
    .inputExpDesc {
        margin-bottom: 20pt;
        width: 250pt;
        margin-left: 0pt;
        height:40pt;
    }
    .inputExpType {
        margin-bottom: 19pt;
        height: 20pt;
        margin-top:10pt;
    }

    .taxable{
        margin-bottom: 20pt;
        width: 20pt;
        margin-left: 0pt;
    }
    .sideBar {
        display:none;
    }

    .loginPanel {
        background-color:white;
        width: 250pt;
        height:auto;
        padding:0px;
    }
    .loginWindow{
        background-color:white;
        width:250pt;
        height:auto;
        padding:10pt;
    }
    /*DFP IE11 support requires hard code of colour*/
    .logoBar {
    	height: 56pt;
    	width: 380pt;
    	background-color: #000000; /*var(--logoBarColour);*/
    	color:white;
        box-shadow: inset 0 1px 2px 0 rgba(0,0,0,0.14);
        position: fixed;
        z-index: 4;
        margin-top: 0;
        top: 0;
        left: 0;
    }
    .logoBarLogo{
        height:40pt;
        width:auto;
        left:105pt;
        top: 5pt;
        position:center;
    }
    .logoBarName {
        display:none;
    }
    .logoBarPhoto {
        display:none;
    }
    .logoBarIcons{
       display:none;
    }
    .notifIcon {
       display:none;
    }
    .notifTxt {
        display:none;
    }

    .mobileMyProfileMenuItem {
        margin:0;
        color:#4C5E70;
        font-size:14pt;
        line-height:18pt;
    }
    /*DFP IE11 support requires hard code of colour*/
    .mobileLogoBar {
        display:block;
        height: 56pt;
        width:330pt;
        background-color: #000000; /*var(--logoBarColour);*/
        color:white;
        box-shadow: inset 0 1px 2px 0 rgba(0,0,0,0.14);
        position: absolute;
        top: 0;
        left: 0;
        margin-bottom:20pt;
    }
    .mobileLogoBarPhoto {
        height: 40pt;
        width: auto;
        margin-top: 2.5pt;
        border-radius: 50%;
        margin-left:18pt;
        float:left;
    }
    .mobileLogoBarName {
        position: inherit;
        padding-left: 85pt;
        line-height: 21pt;
        padding-top: 18pt;
        font-size:11pt;
        color:white;
    }
    .mobileLogoBarIcons{
        font-size:21pt;
        float:right;
        margin-right:110pt;
        margin-top:23pt;
        color: white;
    }
    .mobileNotifIcon {
        width:30pt;
        height:30pt;
        font-size:21pt;
        float:right;
        margin-right:200pt;
        margin-top:18pt;
        color: white;
        left:150pt;
        position:absolute;
    }
    .mobileNotifTxt {
        background:red;
        font-size:xx-small;
        position: relative;
        bottom:25pt;
        left:16pt;
        border-radius:6pt;
        padding:0pt;
        height:15pt;
        width:10pt;
        line-height:15pt;
        text-align:center;
    }
    .dropDown {
        display:none;
    }
    .pwrdBy{
        width:330pt;
        border:0pt;
        text-align:right;
        margin-right:85pt;
        font-size:9pt;
        font-weight:lighter;
    }
    .pwrdByLogo{
        margin-top:15pt;
        margin-right:80pt;
        height:30pt;
        width:auto;
    }

/* CSS for the mobile slidey menu thingy*/
    :root{
        --sidebar-width:330pt;
        --sidebarTSE-width:330pt;
        --toggler-size:30px;
        --tseToggler-size:230pt;
    }
    .sidebar {
      -webkit-transition: all .25s ease-out;
      transition: all .25s ease-out;
    }

    .sidebar {
      width: var(--sidebar-width);
      -webkit-transform: translateX(calc(var(--sidebar-width) * -1));
      transform: translateX(calc(var(--sidebar-width) * -1));
      background: #000000;/*var(--sideBarColour);*//*-webkit-linear-gradient(top left, var(--sideBarColour), white);*/
      display: -webkit-box;
      display: -ms-flexbox;
      display: flex;
      -webkit-box-pack: center;
      -ms-flex-pack: center;
      justify-content: center;
      -webkit-box-align: center;
      -ms-flex-align: center;
      align-items: center;
      position: absolute;
      top: 0;
      height: 100vh;
      opacity: 0.75;
    }

    .menu {
        list-style-type: none;
        padding:0pt;
        margin-top:20pt;
        margin-right:55pt;
    }
    .menu__link {

        font-size: 16pt;
        line-height:44pt;
        outline: 0;
        height:33pt;
        width: 150pt;
        padding-left: 0pt;
        padding-top: 9pt;
        padding-bottom: 9pt;
        vertical-align: middle;
        text-decoration: none;
        color: #2F2F2F;
        background-color: white;
        text-align: left;
        cursor: pointer;
        white-space: nowrap;
        border-radius:4pt;
        margin-top:5pt;
        margin-bottom:5pt;
        padding-right:9pt;
        -webkit-transition: all .25s ease-out;
        transition: all .25s ease-out;
    }

    .menu__link:hover, .menu__link:focus, .menu__link:active { color: var(--highlightColour); }

    .menu-toggler {
      display: block;
      width: var(--toggler-size);
      height: var(--toggler-size);
      position: fixed;
      top: 10px;
      left: 10px;
      cursor: pointer;
      z-index: 1;
    }
    .menu-toggler__line {
      height: calc(var(--toggler-size) / 6.5);
      background: white;
      position: absolute;
      left: 0;
      right: 0;
      border-radius: 6pt;
      -webkit-transition: all .25s ease-out;
      transition: all .25s ease-out;
    }

    .menu-toggler__line:nth-child(2) {  top: calc(var(--toggler-size) / 5 * 2);
    }

    .menu-toggler__line:nth-child(3) {  top: calc(var(--toggler-size) / 5 * 4);
    }

    .input-toggler {
      position: absolute;
      left: -100%;
    }
    .input-toggler:checked ~ .menu-toggler .menu-toggler__line { background: white; }

    .input-toggler:checked ~ .menu-toggler .menu-toggler__line:nth-child(1) {  -webkit-transform: translateY(calc(var(--toggler-size) / 5 * 2)) rotate(45deg);
     transform: translateY(calc(var(--toggler-size) / 5 * 2)) rotate(45deg);
    }

    .input-toggler:checked ~ .menu-toggler .menu-toggler__line:nth-child(2) { opacity: 0; }

    .input-toggler:checked ~ .menu-toggler .menu-toggler__line:nth-child(3) {  -webkit-transform: translateY(calc(var(--toggler-size) / 5 * -2)) rotate(-45deg);
     transform: translateY(calc(var(--toggler-size) / 5 * -2)) rotate(-45deg);
    }

    .input-toggler:checked ~ .sidebar {
      -webkit-transform: translateX(0);
      transform: translateX(0);
      opacity: .96;
    }
}


