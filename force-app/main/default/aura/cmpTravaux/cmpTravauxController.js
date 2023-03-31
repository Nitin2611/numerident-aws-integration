({
    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
    visibiliyImplants: function(component, event, helper) {
        var Marque = component.get("v.Ligne.Marque_d_implant__c");
  		helper.visibiliyImplants(component,Marque);
    },
    init : function(cmp, event, helper) {
        console.log('Init Start');
    	helper.init(cmp, "Couronne__c", "Alliage__c");
        //var ListOfDependentFields = Map[cmp.get("v.Ligne.Type__c")];
        //helper.fetchDepValues(cmp, ListOfDependentFields);
    	//helper.fetchPicklistValues(cmp, "Type__c", "Alliage__c");
        //helper.getTeeth(cmp);
        console.log('Init Done');
    },
    
    /*afterRender: function(component, helper) {
        this.superAfterRender();
            console.log('test = ');
        var svg = component.find("svg_18");
        if(svg != null){            
            var value = svg.getElement().innerText;
            value = value.replace("<![CDATA[", "").replace("]]>", "");
            console.log('value = '+value);
            svg.getElement().innerHTML = value;  
            
        }  
    },*/
    
    onRender: function(component, helper) {
        if(component.get("v.isDoneRendering")){
            console.log('#Entering On Render');
            component.set("v.isDoneRendering", false);
            /* COF - 220218 processing done in the controller because the event="aura:doneRendering" is called before the helper functions are initialized */
            for(var i = 0; i <= 48; i++){
                
                var svg = component.find("svg_"+i.toString());
                //var svg = document.getElementById(component.get("v.field") + "svg_"+i.toString());
                if(svg != null){
                    if (svg.getElement() != null){
                    	var value = svg.getElement().innerText;
                    	value = value.replace("<![CDATA[", "").replace("]]>", "");
                    	svg.getElement().innerHTML = value;  
                    }
                }
                var svg2 = component.find("svg_"+i.toString()+"_2");
                //var svg = document.getElementById(component.get("v.field") + "svg_"+i.toString());
                if(svg2 != null){
                    if (svg2.getElement() != null){
                    	var value = svg2.getElement().innerText;
                    	value = value.replace("<![CDATA[", "").replace("]]>", "");
                    	svg2.getElement().innerHTML = value;  
                    }
                }
                
            }       
            var teeth = component.get("v.Dents");
            var F = component.get("v.field");
            if(teeth != null && teeth != ''){
            	for(var i=0; i<teeth.length; i++){
            		// On ajoute la classe "Selected" à l'élément
            		//console.log(document.getElementById(teeth[i]));
            		var tooth = document.getElementById(teeth[i]);
            		//console.log("TEMP__"+i);
            		if(tooth != null){
            			var svgElement = tooth.getElementsByClassName("dent")[0];
            			if(svgElement != null)svgElement.setAttribute("fill", "rgba(0, 161, 223,1)");
            		}
            	}
            }
            var teeth2 = component.get("v.Dents2");
            var F = component.get("v.field");
            if(teeth2 != null && teeth2 != ''){
            	for(var i=0; i<teeth2.length; i++){
            		// On ajoute la classe "Selected" à l'élément
            		//console.log(document.getElementById(teeth[i]));
            		var tooth = document.getElementById(teeth2[i] + "_2");
            		//console.log("TEMP__"+i);
            		if(tooth != null){
            			var svgElement = tooth.getElementsByClassName("dent")[0];
            			if(svgElement != null)svgElement.setAttribute("fill", "rgba(0, 161, 223,1)");
            		}
            	}
            }
        }
        console.log('End Render');
    },
    
    initSelectedTooth : function(cmp, event, helper) { 
        helper.initTeeth(cmp);
    },
    
    cloneTeeth : function(cmp) {
    	cmp.set("v.Dents2",cmp.get("v.Dents"));
        var teeth2 = cmp.get("v.Dents2");
            if(teeth2 != null && teeth2 != ''){
            	for(var i=0; i<teeth2.length; i++){
            		// On ajoute la classe "Selected" à l'élément
            		//console.log(document.getElementById(teeth[i]));
            		var tooth = document.getElementById(teeth2[i] + "_2");
            		//console.log("TEMP__"+i);
            		if(tooth != null){
            			var svgElement = tooth.getElementsByClassName("dent")[0];
            			if(svgElement != null){
            				svgElement.setAttribute("fill", "rgba(0, 161, 223,1)");
            			}
           			}else{
            			var svgElement = tooth.getElementsByClassName("dent")[0];
            			if(svgElement != null){
            				svgElement.setAttribute("fill", "transparent");
            			}
            		}
            	}
            }
    },
    
    addTooth : function(cmp, event, helper) {
        var teeth = cmp.get("v.Dents");
        var F = cmp.get("v.field");
        console.log("click on " + event.target.id);
        var tooth =  document.getElementById(event.target.id);
        var svgElement = tooth.getElementsByClassName("dent")[0];
        if(teeth.includes(event.target.id)){
            // On retire la classe
            /*
             * tooth.classList.remove('Selected');
             */
            svgElement.setAttribute("fill", "transparent");
            
            
            // On enleve la valeur en question du tableau
            for(var i = 0; i < teeth.length; i++) {
                if(teeth[i] === event.target.id) {
                    teeth.splice(i, 1);
                }
            }
            console.log("tooth removed ! " + event.target.id); 
        }else{
            // On ajoute la classe "Selected" à l'élément
            /*
            * tooth.classList.add('Selected');
            */
            
            svgElement.setAttribute("fill", "rgba(0, 161, 223,1)");
            teeth.push(event.target.id);
            //On ajoute la valeur au tableau
            
            console.log("tooth added !");
        }
        //helper.saveTeeth(cmp);	
        console.log("fin du add");
        
    },

    addTooth2 : function(cmp, event, helper) {
        var teeth = cmp.get("v.Dents2");
        var F = cmp.get("v.field");
        console.log("click on " + event.target.id);
        var tooth =  document.getElementById(event.target.id);
        var svgElement = tooth.getElementsByClassName("dent")[0];
        var numDent = event.target.id.replace("_2","");
        if(teeth.includes(numDent)){
            // On retire la classe
            /*
             * tooth.classList.remove('Selected');
             */
            svgElement.setAttribute("fill", "transparent");
            
            
            // On enleve la valeur en question du tableau
            for(var i = 0; i < teeth.length; i++) {
                if(teeth[i] === numDent) {
                    teeth.splice(i, 1);
                }
            }
            console.log("tooth removed ! " + event.target.id); 
        }else{
            // On ajoute la classe "Selected" à l'élément
            /*
            * tooth.classList.add('Selected');
            */
            
            svgElement.setAttribute("fill", "rgba(0, 161, 223,1)");
            teeth.push(numDent);
            //On ajoute la valeur au tableau
            
            console.log("tooth added !");
        }
        //helper.saveTeeth(cmp);	
        console.log("fin du add");
        
    },
    
    save : function(cmp, event, helper) {  
        var teeth = cmp.get("v.Dents");     
        helper.saveTeeth(cmp);	
    },
  
    saveLigne : function(cmp, event, helper) {  
    	console.log('Save ligne');
        var valide=true;
        var implant=cmp.get("v.Ligne.LibTravaux1__c");
        if((implant=="Implants")||(implant=="Planification implantaire")||(implant=="Implants - Travaux")){
            var marque = cmp.get("v.Ligne.Marque_d_implant__c"); 
            if(!marque){
            	valide = false;
        	}
            if((marque=="ETK")||(marque=="BIOTECH")){
	            if(marque=="ETK"){
    	        	var reference = cmp.get("v.Ligne.Ref_Diametre__c");
	    	        if(!reference){
    	    	    	valide = false;
        			}
            	}
            	if(marque=="BIOTECH"){
            		var reference = cmp.get("v.Ligne.Ref_Diametre_BIOTECH__c");
	            	if(!reference){
    	        		valide = false;
        			}
            	}
            }else{
		        var diametre = cmp.get("v.Ligne.Diam_tre__c");
           		var reference = cmp.get("v.Ligne.R_f_rence_d_implant__c");
                if((diametre==null)||(!diametre.trim())||(reference==null)||(!reference.trim())){
                	valide = false;
                }
            }
	        var empreinte = cmp.get("v.Ligne.Type_d_empreinte_sur_implant__c");
          	if(!empreinte){
        		valide = false;
   			}
        }
    	if(!valide){
            alert('Merci d\'indiquer l\'ensemble des informations implantaires : marque, référence, diamètre et type d\'empreinte sur implant.');
        }else {
        var teeth = cmp.get("v.Dents");     
        helper.saveLigne(cmp);	
            	console.log("redirect");
            	/*var navEvt = $A.get("e.force:navigateToSObject");
            	navEvt.setParams({
            		"recordId": cmp.get("v.Ligne.Ordonnance__c"),
            		"slideDevName": "detail"
            	});
            	$A.get('e.force:refreshView').fire();
            	navEvt.fire();*/
            	window.parent.location = '/labo/' + cmp.get("v.Ligne.Ordonnance__c");
            	console.log("redirect done - controller");
    }},

    deleteLigne : function(cmp, event, helper) {  
    	console.log('Delete ligne');
        helper.deleteLigne(cmp);	
            	window.parent.location = '/labo/' + cmp.get("v.Ligne.Ordonnance__c");
            	console.log("redirect done - controller");
    },
    cancelLigne : function(cmp, event, helper) {  
    	console.log('Cancel ligne');
        helper.cancelLigne(cmp);	
            	console.log("redirect");
        
            	var navEvt = $A.get("e.force:navigateToSObject");
            	navEvt.setParams({
            		"recordId": cmp.get("v.Ligne.Ordonnance__c"),
            		"slideDevName": "detail"
            	});
            	navEvt.fire();
            	console.log("redirect done - controller");
    },
  
  // function call on change tha controller field  
   onControllerFieldChange: function(component, event, helper) {
      //alert(event.getSource().get("v.value"));
      console.log(event.getSource().get("v.value"))
      // get the selected value
      var controllerValueKey = event.getSource().get("v.value");
 
      // get the map values   
      var Map = component.get("v.depnedentFieldMap");
 
      // check if selected value is not equal to None then call the helper function.
      // if controller field value is none then make dependent field value is none and disable field
      if (controllerValueKey != '--- None ---') {
 
         // get dependent values for controller field by using map[key].  
         // for i.e "India" is controllerValueKey so in the map give key Name for get map values like 
         // map['India'] = its return all dependent picklist values.
         var ListOfDependentFields = Map[controllerValueKey];
         helper.fetchDepValues(component, ListOfDependentFields);
 
      } else {
         var defaultVal = [{
            class: "optionClass",
            label: '--- None ---',
            value: '--- None ---'
         }];
         component.find('conState').set("v.options", defaultVal);
         component.set("v.isDependentDisable", true);
      }
   },
 
   // function call on change tha Dependent field    
   onDependentFieldChange: function(component, event, helper) {
      console.log(event.getSource().get("v.value"));
   }  ,  
    
    onPicklistChange: function(component, event, helper) {
        // get the value of select option
        console.log(event.getSource().get("v.value"));
    },
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "File "+fileName+" Uploaded successfully."
        });
        toastEvent.fire();
       
    }
 })