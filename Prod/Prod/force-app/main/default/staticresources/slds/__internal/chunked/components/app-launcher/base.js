var SLDS=webpackJsonpSLDS([1,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123],{0:function(e,l){e.exports=React},33:function(e,l,a){"use strict";function s(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(l,"__esModule",{value:!0}),l.states=l.AppLauncherTile=void 0;var t=s(a(0)),r=s(a(2)),d=(a(11),a(6)),n=s(a(1)),i=l.AppLauncherTile=function(e){return t.default.createElement("a",{"aria-describedby":e.draggable?e.referenceId:null,draggable:e.draggable,href:"javascript:void(0);",className:(0,n.default)("slds-app-launcher__tile slds-text-link_reset",e.className,{"slds-is-draggable":e.draggable,"slds-app-launcher__tile_small":"small"===e.flavor,"slds-is-grabbed":e.grabbed})},t.default.createElement("div",{className:(0,n.default)("slds-app-launcher__tile-figure",{"slds-app-launcher__tile-figure_small":"small"===e.flavor})},e.symbol?t.default.createElement(r.default,{className:"slds-icon slds-icon-standard-"+e.symbol+" slds-icon_large",sprite:"standard",symbol:e.symbol}):t.default.createElement(d.Avatar,{className:"slds-avatar_large"},t.default.createElement("abbr",{className:(0,n.default)("slds-avatar__initials",e.figureClass),title:"company name"},e.objectInitials)),e.draggable?t.default.createElement("span",{className:"slds-icon_container",title:"Drag item to a new location"},t.default.createElement(r.default,{className:"slds-icon slds-icon_x-small slds-icon-text-default",sprite:"utility",symbol:"rows"})):null),t.default.createElement("div",{className:(0,n.default)("slds-app-launcher__tile-body",{"slds-app-launcher__tile-body_small":"small"===e.flavor})},e.children))};l.default=t.default.createElement("div",{className:"demo-only",style:{width:"20rem"}},t.default.createElement(i,{objectInitials:"SC",figureClass:"slds-icon-custom-27"},t.default.createElement("h2",{className:"slds-text-link"},"Sales Cloud"),t.default.createElement("p",null,"The primary internal Salesforce org. Used to run our...",t.default.createElement("span",{className:"slds-text-link"},"More"))));l.states=[{id:"draggable",label:"Draggable",element:t.default.createElement("div",{className:"demo-only",style:{width:"20rem"}},t.default.createElement(i,{objectInitials:"SC",figureClass:"slds-icon-custom-27",draggable:!0},t.default.createElement("h2",{className:"slds-text-link"},"Sales Cloud"),t.default.createElement("p",null,"The primary internal Salesforce org. Used to run our...",t.default.createElement("span",{className:"slds-text-link"},"More"))))},{id:"grabbed",label:"Grabbed",element:t.default.createElement("div",{className:"demo-only",style:{width:"20rem"}},t.default.createElement(i,{objectInitials:"SC",figureClass:"slds-icon-custom-27",draggable:!0,grabbed:!0},t.default.createElement("h2",{className:"slds-text-link"},"Sales Cloud"),t.default.createElement("p",null,"The primary internal Salesforce org. Used to run our...",t.default.createElement("span",{className:"slds-text-link"},"More"))))}]},51:function(e,l,a){"use strict";function s(e){return e&&e.__esModule?e:{default:e}}Object.defineProperty(l,"__esModule",{value:!0}),l.states=void 0;var t=s(a(0)),r=s(a(2)),d=a(11),n=a(33),i=a(24),c=(s(a(1)),function(e){return t.default.createElement(d.Modal,{className:"slds-modal_large slds-app-launcher","aria-labelledby":"header43"},t.default.createElement(d.ModalHeader,{className:"slds-app-launcher__header slds-grid slds-grid_align-spread slds-grid_vertical-align-center"},t.default.createElement("h2",{id:"header43",className:"slds-text-heading_medium"},"App Launcher"),t.default.createElement("div",{className:"slds-app-launcher__header-search"},t.default.createElement("div",{className:"slds-form-element"},t.default.createElement("label",{htmlFor:"app-launcher-search",className:"slds-form-element__label slds-assistive-text"},"Find an app"),t.default.createElement("div",{className:"slds-form-element__control slds-input-has-icon slds-input-has-icon_left"},t.default.createElement(r.default,{className:"slds-input__icon",sprite:"utility",symbol:"search"}),t.default.createElement("input",{type:"search",className:"slds-input",id:"app-launcher-search",placeholder:"Find an app"})))),t.default.createElement("button",{className:"slds-button slds-button_neutral"},"App Exchange")),t.default.createElement(d.ModalContent,{className:"slds-app-launcher__content slds-p-around_medium"},t.default.createElement(i.Section,{className:"slds-is-open"},t.default.createElement(i.SectionTitle,null,t.default.createElement(i.SectionTitleAction,{isOpen:!0,referenceId:"appsContent"},"All Apps")),t.default.createElement(i.SectionContent,{isOpen:!0,referenceId:"appsContent"},t.default.createElement("div",{className:"slds-assistive-text",id:"drag-live-region","aria-live":"assertive"},e.dragDropLiveRegion),t.default.createElement("div",{className:"slds-assistive-text",id:e.dragDropId},e.dragDropInstructions),t.default.createElement("ul",{className:"slds-grid slds-grid_pull-padded slds-wrap"},e.appTiles.map(function(e,l){return t.default.createElement("li",{className:"slds-p-horizontal_small slds-size_1-of-1 slds-medium-size_1-of-3",key:l},t.default.createElement(n.AppLauncherTile,{draggable:!0,figureClass:e.figureClass,grabbed:e.grabbed,objectInitials:e.initials,referenceId:e.dragDropId},t.default.createElement("span",{className:"slds-text-link"},e.label),t.default.createElement("p",null,e.description,t.default.createElement("span",{className:"slds-text-link"},"More"))))})))),t.default.createElement("hr",null),t.default.createElement(i.Section,{className:"slds-is-open"},t.default.createElement(i.SectionTitle,null,t.default.createElement(i.SectionTitleAction,{isOpen:!0,referenceId:"itemsContent"},"All Items")),t.default.createElement(i.SectionContent,{isOpen:!0,referenceId:"itemsContent"},t.default.createElement("ul",{className:"slds-grid slds-grid_pull-padded slds-wrap"},e.itemTiles.map(function(e,l){return t.default.createElement("li",{className:"slds-p-horizontal_small slds-size_xx-small",key:l},t.default.createElement(n.AppLauncherTile,{flavor:"small",symbol:e.symbol},t.default.createElement("p",{className:"slds-truncate slds-text-link",title:e.label},e.label)))}))))))}),o="drag-instructions",m=[{label:"Accounts",symbol:"account"},{label:"Announcements",symbol:"announcement"},{label:"Approvals",symbol:"approval"},{label:"Campaigns",symbol:"campaign"},{label:"Cases",symbol:"case"},{label:"Coaching",symbol:"coaching"},{label:"Contacts",symbol:"contact"}],u=[{description:"The primary internal Salesforce org. Used to run our...",dragDropId:o,figureClass:"slds-icon-custom-27",grabbed:!1,initials:"SC",label:"Sales Cloud"},{description:"Salesforce Marketing Cloud lets businesses of any size...",dragDropId:o,figureClass:"slds-icon-custom-59",grabbed:!1,initials:"MC",label:"Marketing Cloud"},{description:"Community for managing employee benefits and time off.",dragDropId:o,figureClass:"slds-icon-custom-10",grabbed:!1,initials:"HR",label:"HR Concierge"},{description:"Manage your finances across multiple financial platforms...",dragDropId:o,figureClass:"slds-icon-custom-6",grabbed:!1,initials:"MM",label:"My Money"},{description:"The key to call center and contact center management is more...",dragDropId:o,figureClass:"slds-icon-custom-91",grabbed:!1,initials:"CC",label:"Call Center"},{description:"Areas of Focus are used to track customer support for your...",dragDropId:o,figureClass:"slds-icon-custom-50",grabbed:!1,initials:"CS",label:"Customer Support Communitiy"}],p=function(e,l,a){var s=e.slice(0);return s.splice(a,0,s.splice(l,1)[0]),s},f=u.slice(0);f[0]=Object.assign({},f[0],{grabbed:!0});var g=p(u,0,2);g[2]=Object.assign({},g[2],{grabbed:!0});var b=p(u,0,3);l.default=t.default.createElement("div",{className:"demo-only",style:{height:"800px"}},t.default.createElement(c,{appTiles:u,dragDropId:o,dragDropInstructions:"Press space bar to move this app within the list.",dragDropLiveRegion:"",itemTiles:m}),t.default.createElement("div",{className:"slds-backdrop slds-backdrop_open"}));l.states=[{id:"grabbed",label:"Tile grabbed",element:t.default.createElement("div",{className:"demo-only",style:{height:"800px"}},t.default.createElement(c,{appTiles:f,dragDropId:o,dragDropInstructions:"",dragDropLiveRegion:"Sales Cloud: current position 1 of 6. Use the up and down arrows to move this app",grabbed:!0,itemTiles:m}),t.default.createElement("div",{className:"slds-backdrop slds-backdrop_open"}))},{id:"moved",label:"Tile moved in list",element:t.default.createElement("div",{className:"demo-only",style:{height:"800px"}},t.default.createElement(c,{appTiles:g,dragDropId:o,dragDropInstructions:"",dragDropLiveRegion:"Sales Cloud: new position 3 of 6.",itemTiles:m}),t.default.createElement("div",{className:"slds-backdrop slds-backdrop_open"}))},{id:"dropped",label:"Tile dropped",element:t.default.createElement("div",{className:"demo-only",style:{height:"800px"}},t.default.createElement(c,{appTiles:b,dragDropId:o,dragDropInstructions:"Press space bar to move this app within the list.",dragDropLiveRegion:"Sales Cloud: final position 4 of 6.",itemTiles:m}),t.default.createElement("div",{className:"slds-backdrop slds-backdrop_open"}))}]}},[51]);