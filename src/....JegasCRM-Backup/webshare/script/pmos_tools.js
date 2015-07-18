//------------------------------------------------
//----Created for Novo1 by Jegas, LLC 2009-06-28    
//------------------------------------------------
// Name: pmos_tools.js
// Purpose: Reusable code for Process Maker DynaForms
//          used to implement business logic.
//------------------------------------------------
//confirm('BEGIN pmos_tools');



//------------------------------------------
// Convert &amp; to & for the chars we "encoded" on the server in the AJAX call. 
// &amp; &quot; &apos; &gt; &lt;
//------------------------------------------
function sHTMLUnScrub(p_s){
  s=p_s.replace(/&amp;/g,"&");
  s=s.replace(/&apos;/g,"'");
  s=s.replace(/&quot;/g,'"');
  s=s.replace(/&lt;/g,'<');
  s=s.replace(/&gt;/g,'>');
  return s;
};
//------------------------------------------





  // BEGIN ============ PRODUCT TABLE INFO RETREIVAL
  // -----
  // Note: this block of code contains those ajax-based function calls and setup to 
  //       retrieve requested data elements from the product table on the server
  //
  //       the following three sets of comments demonstrate the setup for each of 
  //       the product group case variables add one element to the asProdFieldList 
  //       for each product db field you want to retieve:
  // -----          
          //var asProdFieldList=new Array();
          //asProdFieldList[0]='PRODM_Description';
          //asProdFieldList[1]='PRODM_Price';
          //gaoProdGrp[0]=new clsProdGrp("DSLpkg",asProdFieldList);
          //
          //var asProdFieldList=new Array();
          //asProdFieldList[0]='PRODM_Description';
          //asProdFieldList[1]='PRODM_Price';
          //gaoProdGrp[1]=new clsProdGrp("LDPlan",asProdFieldList);
          //
          //var asProdFieldList=new Array();
          //asProdFieldList[0]='PRODM_Description';
          //asProdFieldList[1]='PRODM_Price';
          //gaoProdGrp[2]=new clsProdGrp("LocalPlan",asProdFieldList);
  // -----          
  
  
  //ProductGroups ******************************************************************** BEGIN
  var gaoProdGrp = new Array();
  
  //------------------------------------------
  // CLASS - clsProdGrp
  //------------------------------------------
  function clsProdGrp(p_GroupName, p_ProductFieldNameArray){
    this.Name=p_GroupName;
    this.aoProductFieldNames=p_ProductFieldNameArray;//this are requested product fields
    this.aoProducts = new Array();
  };
  //------------------------------------------
     
  //------------------------------------------
  // Load Product Groups - CALLBACK   
  //------------------------------------------
  function callbackLoadProductGroups(doc){
    try{
      //confirm(doc);
      //confirm(doc.prodgroups[0].group.length);
      for(var t=0;t<doc.prodgroups[0].group.length;t++){
    //    confirm(doc.prodgroups[0].group[t].name);
        if(typeof(doc.prodgroups[0].group[t].product)!="undefined"){
          for(var w=0;w<doc.prodgroups[0].group[t].product.length;w++){
            gaoProdGrp[t].aoProducts[w]=doc.prodgroups[0].group[t].product[w];   
            //confirm(gaoProdGrp[t].aoProducts[w].code);   
            //confirm(gaoProdGrp[t].aoProducts[w].PRODM_Description);
          };
        };
      };
    }catch(e){
      confirm('200909020423 - pmos_tools.js.callbackLoadProductGroups error:'+e.message);
    };
  };
 
  // SAMPLE usage:
  //  for(var t=0;t<gaoProdGrp.length;t++){
  //    for(var w=0;w<gaoProdGrp[t].aoProducts.length;w++){
  //       confirm(gaoProdGrp[t].aoProducts[w].code);   
  //       confirm(gaoProdGrp[t].aoProducts[w].PRODM_Description);
  //    };
  //  };
  
  
  
  //------------------------------------------
      
  
  
  
  
  //------------------------------------------
  // Load Product Groups   
  //------------------------------------------
  function LoadProductGroups(){
    try{
      //confirm("LoadProductGroups Begin-------------------");
      // first remove chance of memleaks 
      if(gaoProdGrp.length >0){
        // Next perform the AJAX call
        //confirm("Prepping for ajax call");
        
        var sURL="";
        for(var t=0;t<gaoProdGrp.length;t++){  
          sURL=sURL+"&g"+t.toString()+"="+gaoProdGrp[t].Name;
          for(var s=0;s<gaoProdGrp[t].aoProductFieldNames.length;s++){
            sURL=sURL+"&p"+t.toString()+"f"+s.toString()+"="+gaoProdGrp[t].aoProductFieldNames[s];
          };
        };
        //confirm('Mfg URL:'+sURL);
        //sURL="http://pmos.wiimo2.com/novo1/custom.jas?Action=2013"+sURL;
        //sURL="http://pmos.wiimo2.com:81/?Action=2013"+sURL;
        //var sURL="http://pmos.wiimo2.com/novo1/sample_ajax_productsbygroup.xml";
        sURL=sProgramDir+"?Action=2013"+sURL;
        
        //confirm("Ajax call:" + sURL);
        iwfRequestSync(sURL,null,null,callbackLoadProductGroups);
        //confirm('Called IWF:'+sURL);
      };
      
      //confirm("LoadProductGroups End-------------------");
      
      return true;
    }catch(e){
      confirm('200909020424 - pmos_tools.js.LoadProductGroups error:'+e.message); 
    };
  
  };
  //------------------------------------------

  
  
  //-----------------------------------
  function InitializeProductInformation(){
  //-----------------------------------
    //confirm('init prod info');
    try{
      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      gaoProdGrp[0]=new clsProdGrp("DSLpkg",asProdFieldList);
      
      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      gaoProdGrp[1]=new clsProdGrp("LDPlan",asProdFieldList);
      
      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      gaoProdGrp[2]=new clsProdGrp("LocalPlan",asProdFieldList);
      
      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      gaoProdGrp[3]=new clsProdGrp("WirelessPhone",asProdFieldList);
 
      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      gaoProdGrp[4]=new clsProdGrp("WirelessBlackberryPhone",asProdFieldList);
      
      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      gaoProdGrp[5]=new clsProdGrp("WirelessDataPhone",asProdFieldList);

      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      gaoProdGrp[6]=new clsProdGrp("WirelessPDAPhone",asProdFieldList);

      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      gaoProdGrp[7]=new clsProdGrp("WirelessPlanNTN",asProdFieldList);
 
      var asProdFieldList=new Array();
      asProdFieldList[0]= 'PRODM_ProductCode';                           
      asProdFieldList[1]= 'PRODM_ProductCodeClient';                     
      asProdFieldList[2]= 'PRODM_Description';                           
      asProdFieldList[3]= 'PRODM_Price';                                 
      asProdFieldList[4]= 'PRODM_Price_Key';                             
      gaoProdGrp[8]=new clsProdGrp("WirelessPlanNFT",asProdFieldList);

      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      gaoProdGrp[9]=new clsProdGrp("WirelessPlanUTN",asProdFieldList);

      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      gaoProdGrp[10]=new clsProdGrp("WirelessPlanUFT",asProdFieldList);
      
      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      asProdFieldList[3]='PRODM_MobilePlanIncludedMinutes';
      asProdFieldList[4]='PRODM_MobilePlanIncludedMinutes_Key';
      asProdFieldList[5]='PRODM_MobilePlanNightsAndWeekendsRate';
      asProdFieldList[6]='PRODM_MobilePlanNightsAndWeekendsRate_Key';
      asProdFieldList[7]='PRODM_MobilePlanMobileToMobileRate';
      asProdFieldList[8]='PRODM_MobilePlanMobileToMobileRate_Key';
      asProdFieldList[9]='PRODM_MobilePlanOverageRate';
      asProdFieldList[10]='PRODM_MobilePlanOverageRate_Key';
      asProdFieldList[11]='PRODM_BroadbandSpeed';
      asProdFieldList[12]='PRODM_LDInterlataRate';
      asProdFieldList[13]='PRODM_LDInterlataRate_Key';
      asProdFieldList[14]='PRODM_LDIntralataRate';
      asProdFieldList[15]='PRODM_LDIntralataRate_Key';
      asProdFieldList[16]='PRODM_LDCallingCardInterlataRate';
      asProdFieldList[17]='PRODM_LDCallingCardInterlataRate_Key';
      asProdFieldList[18]='PRODM_LDCallingCardIntralataRate';
      asProdFieldList[19]='PRODM_LDCallingCardIntralataRate_Key';
      asProdFieldList[20]='PRODM_LDTollFreeInterlataRate';
      asProdFieldList[21]='PRODM_LDTollFreeInterlataRate_Key';
      asProdFieldList[22]='PRODM_LDTollFreeIntralataRate';
      asProdFieldList[23]='PRODM_LDTollFreeIntralataRate_Key';
      asProdFieldList[24]='PRODM_MonthlyRecurringCharges';
      asProdFieldList[25]='PRODM_MonthlyRecurringCharges_Key';
      gaoProdGrp[11]=new clsProdGrp("WirelessPlan",asProdFieldList);

      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      asProdFieldList[3]='PRODM_MobilePlanIncludedMinutes';
      asProdFieldList[4]='PRODM_MobilePlanIncludedMinutes_Key';
      asProdFieldList[5]='PRODM_MobilePlanNightsAndWeekendsRate';
      asProdFieldList[6]='PRODM_MobilePlanNightsAndWeekendsRate_Key';
      asProdFieldList[7]='PRODM_MobilePlanMobileToMobileRate';
      asProdFieldList[8]='PRODM_MobilePlanMobileToMobileRate_Key';
      asProdFieldList[9]='PRODM_MobilePlanOverageRate';
      asProdFieldList[10]='PRODM_MobilePlanOverageRate_Key';
      asProdFieldList[11]='PRODM_BroadbandSpeed';
      asProdFieldList[12]='PRODM_LDInterlataRate';
      asProdFieldList[13]='PRODM_LDInterlataRate_Key';
      asProdFieldList[14]='PRODM_LDIntralataRate';
      asProdFieldList[15]='PRODM_LDIntralataRate_Key';
      asProdFieldList[16]='PRODM_LDCallingCardInterlataRate';
      asProdFieldList[17]='PRODM_LDCallingCardInterlataRate_Key';
      asProdFieldList[18]='PRODM_LDCallingCardIntralataRate';
      asProdFieldList[19]='PRODM_LDCallingCardIntralataRate_Key';
      asProdFieldList[20]='PRODM_LDTollFreeInterlataRate';
      asProdFieldList[21]='PRODM_LDTollFreeInterlataRate_Key';
      asProdFieldList[22]='PRODM_LDTollFreeIntralataRate';
      asProdFieldList[23]='PRODM_LDTollFreeIntralataRate_Key';
      asProdFieldList[24]='PRODM_MonthlyRecurringCharges';
      asProdFieldList[25]='PRODM_MonthlyRecurringCharges_Key';
      gaoProdGrp[12]=new clsProdGrp("WirelessOption",asProdFieldList);

      var asProdFieldList=new Array();
      asProdFieldList[0]='PRODM_Description';
      asProdFieldList[1]='PRODM_Price';
      asProdFieldList[2]='PRODM_Price_Key';
      asProdFieldList[3]='PRODM_MobilePlanIncludedMinutes';
      asProdFieldList[4]='PRODM_MobilePlanIncludedMinutes_Key';
      asProdFieldList[5]='PRODM_MobilePlanNightsAndWeekendsRate';
      asProdFieldList[6]='PRODM_MobilePlanNightsAndWeekendsRate_Key';
      asProdFieldList[7]='PRODM_MobilePlanMobileToMobileRate';
      asProdFieldList[8]='PRODM_MobilePlanMobileToMobileRate_Key';
      asProdFieldList[9]='PRODM_MobilePlanOverageRate';
      asProdFieldList[10]='PRODM_MobilePlanOverageRate_Key';
      asProdFieldList[11]='PRODM_BroadbandSpeed';
      asProdFieldList[12]='PRODM_LDInterlataRate';
      asProdFieldList[13]='PRODM_LDInterlataRate_Key';
      asProdFieldList[14]='PRODM_LDIntralataRate';
      asProdFieldList[15]='PRODM_LDIntralataRate_Key';
      asProdFieldList[16]='PRODM_LDCallingCardInterlataRate';
      asProdFieldList[17]='PRODM_LDCallingCardInterlataRate_Key';
      asProdFieldList[18]='PRODM_LDCallingCardIntralataRate';
      asProdFieldList[19]='PRODM_LDCallingCardIntralataRate_Key';
      asProdFieldList[20]='PRODM_LDTollFreeInterlataRate';
      asProdFieldList[21]='PRODM_LDTollFreeInterlataRate_Key';
      asProdFieldList[22]='PRODM_LDTollFreeIntralataRate';
      asProdFieldList[23]='PRODM_LDTollFreeIntralataRate_Key';
      asProdFieldList[24]='PRODM_MonthlyRecurringCharges';
      asProdFieldList[25]='PRODM_MonthlyRecurringCharges_Key';
      gaoProdGrp[13]=new clsProdGrp("WirelessAirCard",asProdFieldList);

      var asProdFieldList=new Array();
      asProdFieldList[0]= 'PRODM_ProductCode';                           
      asProdFieldList[1]= 'PRODM_ProductCodeClient';                     
      asProdFieldList[2]= 'PRODM_Description';                           
      asProdFieldList[3]= 'PRODM_Price';                                 
      asProdFieldList[4]= 'PRODM_Price_Key';                             
      asProdFieldList[5]= 'PRODM_MobilePlanIncludedMinutes';             
      asProdFieldList[6]= 'PRODM_MobilePlanIncludedMinutes_Key';         
      asProdFieldList[7]= 'PRODM_MobilePlanNightsAndWeekendsRate';       
      asProdFieldList[8]= 'PRODM_MobilePlanNightsAndWeekendsRate_Key';   
      asProdFieldList[9]= 'PRODM_MobilePlanMobileToMobileRate';          
      asProdFieldList[10]='PRODM_MobilePlanMobileToMobileRate_Key';      
      asProdFieldList[11]='PRODM_MobilePlanOverageRate';                 
      asProdFieldList[12]='PRODM_MobilePlanOverageRate_Key';             
      asProdFieldList[13]='PRODM_BroadbandSpeed';                        
      asProdFieldList[14]='PRODM_LDInterlataRate';                       
      asProdFieldList[15]='PRODM_LDInterlataRate_Key';                   
      asProdFieldList[16]='PRODM_LDIntralataRate';                       
      asProdFieldList[17]='PRODM_LDIntralataRate_Key';                   
      asProdFieldList[18]='PRODM_LDCallingCardInterlataRate';            
      asProdFieldList[19]='PRODM_LDCallingCardInterlataRate_Key';        
      asProdFieldList[20]='PRODM_LDCallingCardIntralataRate';            
      asProdFieldList[21]='PRODM_LDCallingCardIntralataRate_Key';        
      asProdFieldList[22]='PRODM_LDTollFreeInterlataRate';               
      asProdFieldList[23]='PRODM_LDTollFreeInterlataRate_Key';           
      asProdFieldList[24]='PRODM_LDTollFreeIntralataRate';               
      asProdFieldList[25]='PRODM_LDTollFreeIntralataRate_Key';                      
      asProdFieldList[26]='PRODM_MonthlyRecurringCharges';               
      asProdFieldList[27]='PRODM_MonthlyRecurringCharges_Key';           
      gaoProdGrp[14]=new clsProdGrp("WirelessPlanUnity",asProdFieldList);
     
      LoadProductGroups();
      //for(var t=0;t<gaoProdGrp.length;t++){
      //
      //    for(var w=0;w<gaoProdGrp[t].aoProducts.length;w++){
      //      confirm('Pat '+'CODE:'+gaoProdGrp[t].aoProducts[w].code+' '+
      //              'PRODM_Description:'+gaoProdGrp[t].aoProducts[w].PRODM_Description+' '+
      //              'PRODM_Price:'+gaoProdGrp[t].aoProducts[w].PRODM_Price+' ');
      //    };
      //  };
    }catch(e){
      confirm('200909020425 - pmos_tools.js.InitializeProductInformation error:' + e.message);
    };  
    //confirm('done prod info');
  };
  //-----------------------------------
  
  // END ============ PRODUCT TABLE INFO RETREIVAL






//DROPDOWNLISTS ******************************************************************** BEGIN
//------------------------------------------------
// Global "Drop Down Lists" from WIIMO_DC MySQL
// Catalog, table: wiimo2_list. AJAX used 
// to populate. AJAX implemented in Jegas App Svr.
// URL hardcoded below.  
//------------------------------------------------
var gaoDLists = new Array();
//NOTE: To Instantiate, in PMOS Onload event of dynaform
// do this:
//      gaoDLists[0]=new clsDList("CONTD_WantStaticOrDynamic");  
//      gaoDLists[1]=new clsDList("CONTD_DslPackage");
//
// The parameters are the names of the DropDown lists in the database - case sensitive BTW :)
//------------------------------------------------
    
//------------------------------------------
// CLASS - clsList
//------------------------------------------
function clsDList(p_Name, p_DListItemArray){
  this.Name=p_Name;
  this.aoDItems = p_DListItemArray;
  //confirm('clsList init successful');
};
//------------------------------------------
    
//------------------------------------------
// CLASS - clsListItem
//------------------------------------------
function clsDListItem(p_Caption, p_Value, p_Criteria){
  this.Caption=p_Caption;
  this.Value = p_Value;
  this.Criteria = p_Criteria;
};
//------------------------------------------
//********************************************************************
    


//------------------------------------------
// Load Lists - CALLBACK   
//------------------------------------------
function callbackLoadDLists(doc){
//  confirm('BEGIN callbackLoadDLists');
  
  try{
    //confirm('doc.lists[0].list.length:'+doc.lists[0].list.length);

    for(var t=0;t<doc.lists[0].list.length;t++){      
      for(var w=0;w<gaoDLists.length;w++){      
        if(doc.lists[0].list[t].name===gaoDLists[w].Name){      
          gaoDLists[w] = new clsDList(doc.lists[0].list[t].name, new Array());
          for(var s=0;s<doc.lists[0].list[t].li.length;s++){
            gaoDLists[w].aoDItems[gaoDLists[w].aoDItems.length]=new clsDListItem(sHTMLUnScrub(doc.lists[0].list[t].li[s].caption), sHTMLUnScrub(doc.lists[0].list[t].li[s].value), sHTMLUnScrub(doc.lists[0].list[t].li[s].criteria));
          };
        };
      };
    };
  }catch(err){
    confirm('200909031939 - pmos_tools.js.callbackLoadDLists -  - error:'+ e.errDescription);
  };
      
      
  // Attempt to use loaded data in a List Field Pair (one is html select, other html hidden field)
  // (actually use the data from the hidden field and make the list have one item in it that matches
  // the data that was saved originally.)
  var bGotMatch=false;
  for(var t=0;t<gaoDLists.length;t++){
    for(var s=0;s<gaoDLists[t].aoDItems.length;s++){    
      var ctlHidden=document.getElementById(gaoDLists[t].Name+'_hidden');
      if(ctlHidden != undefined){
        if(gaoDLists[t].aoDItems[s].Value === ctlHidden.value){
          var ctlList = document.getElementById('form['+p_name+']');
          if(ctlList!=undefined){
            var optn = document.createElement("OPTION");
            optn.text = gaoDLists[t].aoDItems[s].Caption;
            optn.value =gaoDLists[t].aoDItems[s].Value;
            optn.selected="selected";
            ctlList.options.add(optn);
          };
        };
      };
    };
  };  
  
  
  //---SAMPLE CODE Iterating through the arrays of classes
  //  for(var t=0;t<gaoDLists.length;t++){
  //    confirm(gaoDLists[t].Name);
  //    for(var s=0;s<gaoDLists[t].aoDItems.length;s++){    
  //      confirm("Caption:" + gaoDLists[t].aoDItems[s].Caption + " Value:" + gaoDLists[t].aoDItems[s].Value + " Criteria:" + gaoDLists[t].aoDItems[s].Criteria);
  //    };
  //  };
//  confirm('END callbackLoadDLists');
};
//------------------------------------------
    


//------------------------------------------
// Load Lists   
//------------------------------------------
function LoadDLists(){
//  confirm("LoadDLists Begin");
  
  // first remove chance of memleaks 
  if(gaoDLists.length >0){
    //confirm("WE are in LoadDLists and the gaoDLists.length:"+gaoDLists.length);
    for(var t=0;t<gaoDLists.length;t++){var yyy='y';
      if(gaoDLists[t].aoDItems!=null){
      //  for(var s=0;t<gaoDLists[t].aoDItems.length;s++){
      //    delete gaoDLists[t].aoDItems[s];
      //    //gaoDLists[t].aoDItems.splice(s,1);
      //  };
        delete gaoDLists[t].aoDItems;
      };
      gaoDLists[t].aoDItems=new Array();
    };
    //confirm("arrays cleared - rest - fresh - new");
    //confirm('making some Mr. Clean Ajax Calls');
    
    // Note: - Keeping Array of Lists - as these are going to serve
    // as our AJAX parameter "list" - so don't uncomment the stuff below.
    //delete gaoDLists[t]; 
    //gaoDLists.splice(t,1);
    
    // Next perform the AJAX call
    //confirm("Prepping for ajax call");
    
    //var sURL="http://pmos.wiimo2.com/novo1/sample_ajax_response.xml";
    //var sURL="http://pmos.wiimo2.com/novo1/custom.jas?Action=2009";
    //var sURL="/novo1/eleven.xml";

    sURL=sProgramDir+'?Action=2009';
    for(var t=0;t<gaoDLists.length;t++){  
      sURL=sURL+"&d="+gaoDLists[t].Name;
    };
    //confirm("Ajax call:" + sURL);
    iwfRequestSync(sURL,null,null,callbackLoadDLists);
    //confirm('Called IWF:'+sURL);
  }else{
    //confirm("gaoDLists.length:"+gaoDLists.length+' Nothing to do.');
  };
  
  //confirm("LoadDLists End");
  
  return true;
};
//------------------------------------------




// Client function call to populate a list (selection input element type)
//------------------------------------------
// Populate a List
//------------------------------------------
function PopulateList(p_name){ // Dropdown Control
//  confirm('PopulateList - Enter');
  var ctlList=document.getElementById('form['+p_name+']');
  var ctlHidden=document.getElementById('form['+p_name+'_hidden]');

  if (p_name=='CNTAC_D_WantsSimplelinkOrCBS'){
//    confirm('Control Value:'+ctlList.value+' ListName:'+p_name);
  };
  // dev note: first list on DYNAFORM_ENGAGE is named: CNTAC_D_WantsSimplelinkOrCBS
  for(var w=0;w<gaoDLists.length;w++){
    if(p_name===gaoDLists[w].Name){
      //save the existing selected options value for use in potentially resetting it at end of this routine
      var selectedIndexValue = ctlList.options[ctlList.selectedIndex].value;
      var selectedCaption = ctlList.options[ctlList.selectedIndex].text;
      ctlList.options.length=0;
      
      //--this bit makes a empty first option entry in the pulldown
      //var optn = document.createElement("OPTION");
      //optn.text = "";
      //optn.value = "";
      //ctlList.options.add(optn);
      
      try{
        for(var t=0;t<gaoDLists[w].aoDItems.length;t++){
          if (eval(gaoDLists[w].aoDItems[t].Criteria)) {
            var optn = document.createElement("OPTION");
            optn.text = gaoDLists[w].aoDItems[t].Caption;
            optn.value =gaoDLists[w].aoDItems[t].Value;
            if(ctlHidden != undefined){
              if(ctlHidden.value===gaoDLists[w].aoDItems[t].Value){
                optn.selected="selected";
              };
            };
            ctlList.options.add(optn);
          };
        };
      }catch(err){
        //--- UNCOMMENT to Debug Lists
        //confirm('catch (in pmos_tools.PopulateList function)= ' + err.description+' p_name:'+p_name+
        //' w:' + w + 
        //' selectedIndexValue:' + selectedIndexValue+
        //' gaoDLists.length:'+gaoDLists.length
        //  
        //);
        //--- UNCOMMENT to Debug Lists
          
        // ' gaoDLists[w].aoDItems.length:'+gaoDLists[w].aoDItems.length 

      };
    };
  };
  //loop through each ctlList.options and see if it's Value is equal selectedIndexValue and if so, make it the selectedIndex  
  if (p_name=='CNTAC_D_WantsSimplelinkOrCBS'){
    var sMsg="selectedIndexValue:" + selectedIndexValue;
    sMsg+=' selectedCaption:'+selectedCaption;
    sMsg+=' The VALUE (caption I think) of control itself:' + ctlList.value;
    //confirm(sMsg);
    //confirm(ctlList.innerHTML);
  };
  for(var y=0;y<ctlList.options.length;y++){
    if (ctlList.options[y].value == selectedIndexValue) {
      ctlList.selectedIndex = y;
    };
  };
  
//  confirm('PopulateList - Exit');
  
};
//---End Populate A List-----------------------------------------


//---related processmaker list GUI effect to compensate for lack of a true combo box in this system
//--- and how dynamically populated lists can't persist data in processmaker correctly.
function listonclick(p_name){
  try{
    var ctlList = document.getElementById('form['+p_name+']');
    var ctlHidden = document.getElementById('form['+p_name+'_hidden]');
    ctlHidden.value=ctlList.value;
    //confirm(ctlList.display);
  }catch(e){
    confirm('200909032024 - pmos_tools.js.listonclick -  error:'+e.message);
  };
};
//DROPDOWNLISTS ******************************************************************** END

    
    
 






//GetStateRates ******************************************************************** BEGIN
var giGetStateRateResult=0;
//------------------------------------------
// Load Lists - CALLBACK   
//------------------------------------------
function callbackGetStateRate(doc){
  //confirm(doc.rate[0].value);
  giGetStateRateResult=doc.rate[0].value*1;
};
//------------------------------------------

//------------------------------------------
// get state rate
//------------------------------------------
function GetStateRate(p_StateTerm, p_Lines){    // stateterm=IL1&lines=2
    //var sURL="http://pmos.wiimo2.com/novo1/custom.jas?Action=2010&stateterm="+p_StateTerm+'&lines='+p_Lines.toString();
    var sURL=sProgramDir+"?Action=2010&stateterm="+p_StateTerm+'&lines='+p_Lines.toString();
    //confirm("Ajax call:" + sURL);
    iwfRequestSync(sURL,null,null,callbackGetStateRate);
    //confirm('Called IWF:'+sURL);
    return giGetStateRateResult;
};
//------------------------------------------
//GetStateRates ******************************************************************** END








//Inform VICI that WIIMO Agent is Available ******************************************************************** BEGIN
function callbackWiimoAgentIsAvailable(doc){

};

function WiimoAgentIsAvailable(p_JUserID){
  var sURL=sProgramDir+"?Action=2014&aid="+p_JUserID;
  iwfRequestSync(sURL,null,null,callbackWiimoAgentIsAvailable);
};
//Inform VICI that WIIMO Agent is Available ******************************************************************** END







// BEGIN ====================== NAVIGATION FUNCTIONS 
//-----------------------------------
// Not used right now 200909202248 - Jason
function callbackSetWorkflowState(doc){
//-----------------------------------
  try{
    document.forms[0].submit();
  }catch(e){
    confirm('200909020438 - pmos_tools.js.callbackSetWorkflowState error:'+e.message);
  };
};
//-----------------------------------

//-----------------------------------
function SetWorkflowState(p_sState){
//-----------------------------------
  try{
    //confirm('201006111611 - About to Set the Workflow State: '+p_sState);
    document.getElementById('form[DC_S_Workflow_State]').value=p_sState;
    //confirm('201006111612 - The WorkflowState should be in this form element ID "form[DC_S_Workflow_State]": '+document.getElementById('form[DC_S_Workflow_State]').value+ ' And Next we are going to Submit this form so it should navigate or derivate accordingly.');
    document.forms[0].submit();// remove if using ajax call back, as above it 
    // will submit on AJAX return - which ins't used right now 200909202248 - Jason
    
    // This method writes to the database, but I managed to get the save trigger to work
    // properly, alieviating this issue. Now we just need to optimize the TRIGGER_SAVE_CONTACT to not 
    // write ALL FIELDS each go around.
    
    //var sCaseGUID = document.getElementById('form[CASEGUID]').value;
    //sCaseGUID = sCaseGUID.replace(/\"/g,"");
    //var sURL=sProgramDir+'?action=2011&CASEGUID='+sCaseGUID+'&STATE='+p_sState;
    //iwfRequestSync(sURL,null,null,callbackSetWorkflowState);
  }catch(e){
    confirm('200909020439 - pmos_tools.js.SetWorkflowState error:'+e.message);
  };
  return true; 
}
//-----------------------------------
// END ====================== NAVIGATION FUNCTIONS 






// BEGIN ====================== Promotion FUNCTIONS 

var gaoPromoGrp = new Array();

//------------------------------------------
// CLASS - clsPromoGrp
//------------------------------------------
function clsPromoGrp(p_Name, p_Desc, p_PromoArray){
  this.Name=p_Name;
  this.Desc=p_Desc;
  this.aoPromo = p_PromoArray;

};
//------------------------------------------
    
//------------------------------------------
// CLASS - clsPromo
//------------------------------------------
function clsPromo(p_Name, p_Desc, p_Value, p_Criteria, p_DiscountPCT, p_Caption, p_PromoProdArray){
  this.Name=p_Name;
  this.Desc=p_Desc;
  this.Value=p_Value;
  this.Criteria=p_Criteria;
  this.DiscountPCT=p_DiscountPCT;
  this.Caption=p_Caption;
  this.PromoProdArray=p_PromoProdArray;
};
//------------------------------------------


//------------------------------------------
// CLASS - clsPromoProd
//------------------------------------------
function clsPromoProd(
  p_Code                               , 
  p_Price                              ,
  p_Criteria                           ,
  p_DiscountPCT                        ,
  p_MobilePlanIncludedMinutes          ,
  p_MobilePlanNightsAndWeekendsRate    ,
  p_MobilePlanMobileToMobileRate       ,
  p_MobilePlanOverageRate              ,
  p_BroadbandSpeed                     ,
  p_LDInterlataRate                    ,
  p_LDIntralataRate                    ,
  p_LDCallingCardInterlataRate         ,
  p_LDCallingCardIntralataRate         ,
  p_LDTollFreeInterlataRate            ,
  p_LDTollFreeIntralataRate            ,
  p_MonthlyRecurringCharges            ,
  p_Price_Key                          ,
  p_MobilePlanIncludedMinutes_Key      ,
  p_MobilePlanNightsAndWeekendsRate_Key,
  p_MobilePlanMobileToMobileRate_Key   ,
  p_MobilePlanOverageRate_Key          ,
  p_LDInterlataRate_Key                ,
  p_LDIntralataRate_Key                ,
  p_LDCallingCardInterlataRate_Key     ,
  p_LDCallingCardIntralataRate_Key     ,
  p_LDTollFreeInterlataRate_Key        ,
  p_LDTollFreeIntralataRate_Key        ,
  p_MonthlyRecurringCharges_Key        
){
  this.Code                                = p_Code;
  this.Price                               = p_Price;
  this.Criteria                            = p_Criteria;
  this.DiscountPCT                         = p_DiscountPCT;
  this.MobilePlanIncludedMinutes           = p_MobilePlanIncludedMinutes;
  this.MobilePlanNightsAndWeekendsRate     = p_MobilePlanNightsAndWeekendsRate;
  this.MobilePlanMobileToMobileRate        = p_MobilePlanMobileToMobileRate;
  this.MobilePlanOverageRate               = p_MobilePlanOverageRate;
  this.BroadbandSpeed                      = p_BroadbandSpeed;
  this.LDInterlataRate                     = p_LDInterlataRate;
  this.LDIntralataRate                     = p_LDIntralataRate;
  this.LDCallingCardInterlataRate          = p_LDCallingCardInterlataRate;
  this.LDCallingCardIntralataRate          = p_LDCallingCardIntralataRate;
  this.LDTollFreeInterlataRate             = p_LDTollFreeInterlataRate;
  this.LDTollFreeIntralataRate             = p_LDTollFreeIntralataRate;
  this.MonthlyRecurringCharges             = p_MonthlyRecurringCharges;
  this.Price_Key                           = p_Price_Key;
  this.MobilePlanIncludedMinutes_Key       = p_MobilePlanIncludedMinutes_Key;
  this.MobilePlanNightsAndWeekendsRate_Key = p_MobilePlanNightsAndWeekendsRate_Key;
  this.MobilePlanMobileToMobileRate_Key    = p_MobilePlanMobileToMobileRate_Key;
  this.MobilePlanOverageRate_Key           = p_MobilePlanOverageRate_Key;
  this.LDInterlataRate_Key                 = p_LDInterlataRate_Key;
  this.LDIntralataRate_Key                 = p_LDIntralataRate_Key;
  this.LDCallingCardInterlataRate_Key      = p_LDCallingCardInterlataRate_Key;
  this.LDCallingCardIntralataRate_Key      = p_LDCallingCardIntralataRate_Key;
  this.LDTollFreeInterlataRate_Key         = p_LDTollFreeInterlataRate_Key;
  this.LDTollFreeIntralataRate_Key         = p_LDTollFreeIntralataRate_Key;
  this.MonthlyRecurringCharges_Key         = p_MonthlyRecurringCharges_Key;
};
//------------------------------------------


//-----------------------------------
function callbackLoadPromos(doc){
//-----------------------------------
  try{
    //confirm(doc);
			//confirm("doc.promogroups[0].promogroup.length "+doc.promogroups[0].promogroup.length);
    for(var t=0;t<doc.promogroups[0].promogroup.length;t++){
      //confirm(doc.promogroups[0].promogroup[t].name);
      //confirm(doc.promogroups[0].promogroup[t].description[0]);
      if(doc.promogroups[0].promogroup[t].promotions[0].promotion.length>0){
        var aPromoArray = new Array();
        for(var s=0;s<doc.promogroups[0].promogroup[t].promotions[0].promotion.length;s++){
         //confirm(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].name);
          var aPromoProd = new Array();
          if ( doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product === undefined ){
            //undefined? skip it! :) (No products for this promo)
          }else{
            for(var d=0;d<doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product.length;d++){
              //confirm(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].code);
              aPromoProd[d] = new clsPromoProd(
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].code), 
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].price), 
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].criteria),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].DiscountPCT),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].MobilePlanIncludedMinutes),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].MobilePlanNightsAndWeekendsRate),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].MobilePlanMobileToMobileRate),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].MobilePlanOverageRate),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].BroadbandSpeed),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDInterlataRate),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDIntralataRate),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDCallingCardInterlataRate),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDCallingCardIntralataRate),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDTollFreeInterlataRate),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDTollFreeIntralataRate),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].MonthlyRecurringCharges),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].Price_Key),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].MobilePlanIncludedMinutes_Key),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].MobilePlanNightsAndWeekendsRate_Key),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].MobilePlanMobileToMobileRate_Key),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].MobilePlanOverageRate_Key),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDInterlataRate_Key),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDIntralataRate_Key),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDCallingCardInterlataRate_Key),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDCallingCardIntralataRate_Key),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDTollFreeInterlataRate_Key),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].LDTollFreeIntralataRate_Key),
                sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].products[0].product[d].MonthlyRecurringCharges_Key)
              );
            };
          };
          aPromoArray[s] = new clsPromo(
            sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].name), 
            sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].description), 
            sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].value), 
            sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].criteria), 
            sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].discountpct), 
            sHTMLUnScrub(doc.promogroups[0].promogroup[t].promotions[0].promotion[s].caption), 
            aPromoProd
          );
        };
      };
      gaoPromoGrp[t] = new clsPromoGrp(doc.promogroups[0].promogroup[t].name, doc.promogroups[0].promogroup[t].description, aPromoArray);
    };
  
    // BEGIN ----------------------------------------- SAMPLE
    // NOTE: See testpromo.html in folder containing this 
    //       file for a working example of accessing this 
    //       data in javascript once the classes have been 
    //       populated with data after the AJAX call.  
    // END ----------------------------------------- SAMPLE
  }catch(e){
    confirm('200910290041 - pmos_tools.js.callbackLoadPromos error:'+e.message);
  };
};
//-----------------------------------



//-----------------------------------
function LoadPromos(p_Promo_Grp_ID){
//-----------------------------------
  var sURL=sProgramDir+'?Action=2022&PROMOGRP='+p_Promo_Grp_ID;
  //confirm("Ajax call:" + sURL);
  iwfRequestSync(sURL,null,null,callbackLoadPromos);
  //confirm('Called IWF:'+sURL);
  return true;
}
//-----------------------------------

// END ======================== Promotion FUNCTIONS


// BEGIN ======================== TPV VICI Remote Control
//-----------------------------------
function callbackTPV(doc){
//-----------------------------------
  // NO OPERATION
  //confirm('callbackTPV:'+doc);
};
//-----------------------------------

//-----------------------------------
// Put Customer On Hold and Dial TPV
function TPVAGC(p_s){
//-----------------------------------
  var sAGCURL="/jws/protocall/";
  // var sAGCURL="http://10.0.0.149/agc/";
  var sAGCFile="calltpv.php";

  //var sAGCArg="?function=park_call&value=PARK_CUSTOMER&agent_user=agent1";
  //var sAGCArg="?function=transfer_conference&value=PARK_CUSTOMER_DIAL&phone_number=914432783320&dial_override=YES&callid="+p_s;
  //var sAGCArg="?function=park_call&value=GRAB_CUSTOMER&agent_user=agent1";
  //var sAGCArg="?function=transfer_conference&value=HANGUP_XFER
  var sAGCArg="?function=transfer_conference&value=DIAL_WITH_CUSTOMER&phone_number=914432783320&dial_override=YES&callid="+p_s;
  
  var sInvocationURL=sAGCURL+sAGCFile+sAGCArg;
  //confirm('201006180219 - pmos_tools.js.TPVAGC Param in:'+p_s+' TPVAGC - About to Make AJAX Call:'+sInvocationURL);
  iwfRequestSync(sInvocationURL,null,null,callbackTPV);
  //confirm('201006180220 - pmos_tools.js.TPVAGC Called IWF:'+sURL);
  return true;
}
//-----------------------------------




//-----------------------------------
function callbackTPV_OFFHOLD(doc){
//-----------------------------------
  // NO OPERATION
  //confirm('callbackTPV_OFFHOLD:'+doc);
};
//-----------------------------------

//-----------------------------------
function TPVAGC_OFFHOLD(p_s){
//-----------------------------------
  var sAGCURL="/jws/protocall/";
  // var sAGCURL="http://10.0.0.149/agc/";
  var sAGCFile="calltpv.php";

  //var sAGCArg="?function=park_call&value=PARK_CUSTOMER&agent_user=agent1";
  //var sAGCArg="?function=transfer_conference&value=PARK_CUSTOMER_DIAL&phone_number=914432783320&dial_override=YES&agent_user=agent1";
  var sAGCArg="?function=park_call&value=GRAB_CUSTOMER&callid="+p_s;
  //var sAGCArg="?function=transfer_conference&value=HANGUP_XFER
  
  var sInvocationURL=sAGCURL+sAGCFile+sAGCArg;
//  confirm('201006180217 - pmos_tools.js.callbackTPV_OFFHOLD Param in:'+p_s+' TPVAGC_OFFHOLD - About to Make AJAX Call:'+sInvocationURL);
  iwfRequestSync(sInvocationURL,null,null,callbackTPV_OFFHOLD);
//  confirm('201006180218 - pmos_tools.js.callbackTPV_OFFHOLD Called IWF:'+sURL);
  return true;
}
//-----------------------------------






//-----------------------------------
function callbackTPV_HANGUP(doc){
//-----------------------------------
  // NO OPERATION
  confirm('201006180221 - pmos_tools.js.callbackTPV_HANGUP:'+doc);
};
//-----------------------------------

//-----------------------------------
function TPVAGC_HANGUP(p_s){
//-----------------------------------
  var sAGCURL="/jws/protocall/";
  // var sAGCURL="http://10.0.0.149/agc/";
  var sAGCFile="calltpv.php";

  //var sAGCArg="?function=park_call&value=PARK_CUSTOMER&agent_user=agent1";
  //var sAGCArg="?function=transfer_conference&value=PARK_CUSTOMER_DIAL&phone_number=914432783320&dial_override=YES&agent_user=agent1";
  //var sAGCArg="?function=park_call&value=GRAB_CUSTOMER&callid="+p_s;
  var sAGCArg="?function=transfer_conference&value=HANGUP_XFER&callid="+p_s;
  
  var sInvocationURL=sAGCURL+sAGCFile+sAGCArg;
//  confirm('201006180222 - pmos_tools.js.TPVAGC_HANGUP Param in:'+p_s+' TPVAGC_HANGUP - About to Make AJAX Call:'+sInvocationURL);
  iwfRequestSync(sInvocationURL,null,null,callbackTPV_HANGUP);
//  confirm('201006180223 - pmos_tools.js.TPVAGC_HANGUPCalled IWF:'+sURL);
  return true;
}
//-----------------------------------


// END   ======================== TPV VICI Remote Control

function ToggleContent(){
  var el=document.getElementById('ToggleContentWrap');
  if(el.style==''){
    el.style='display: none;';
  }else{
      el.style='';
  };
};




// confirm('END pmos_tools');



