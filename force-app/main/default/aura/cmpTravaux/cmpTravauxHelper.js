({
    visibiliyImplants: function(component, Marque) {
  		var ETKs = document.getElementById("ETK");
  		if (Marque === "ETK") {
    		ETKs.style.display = "block";
  		} else {
    		ETKs.style.display = "none";
  		}
  		var STDs = document.getElementById("STD");
  		if ((Marque != "ETK")&&(Marque != "BIOTECH")){
    		STDs.style.display = "block";
  		} else {
    		STDs.style.display = "none";
  		}
  		var BIOs = document.getElementById("BIOTECH");
  		if (Marque === "BIOTECH") {
    		BIOs.style.display = "block";
  		} else {
    		BIOs.style.display = "none";
  		}
    },
	helperFun : function(component,event,secId) {
	  var acc = component.find(secId);
        	for(var cmp in acc) {
        	$A.util.toggleClass(acc[cmp], 'slds-show');  
        	$A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
	},
    init : function(cmp, controllerField, dependentField) {
        var action1 = cmp.get("c.getLigne");
        action1.setParams({ 
            recordId : cmp.get("v.recordId")
        });
        var action2 = cmp.get("c.getDependentOptionsImpl");
        action2.setParams({
         'objApiName': cmp.get("v.objInfo"),
         'contrfieldApiName': controllerField,
         'depfieldApiName': dependentField,
         'recordId' : cmp.get("v.recordId")
        });
        var action3 = cmp.get("c.getselectOptions");
        action3.setParams({
            "objObject": "{sobjectType : 'Ligne__c'}",
            "fld": "Finition__c"
        });
        var opts = [];
        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
                console.log('component is valid and state is SUCCESS');
                var res = response.getReturnValue();
                var str = res.Dents__c;
                if(str != null){ 
                	cmp.set("v.Dents",str.split(";"));
                }
                var str2 = res.Dents2__c;
                if(str2 != null){ 
                	cmp.set("v.Dents2",str2.split(";"));
                }
                cmp.set("v.Ligne",res);
                $A.enqueueAction(action2);
            }else if (state === "ERROR") {
            	console.log("Action 1 KO");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
      
      action2.setCallback(this, function(response) {
         if (response.getState() == "SUCCESS") {
            //store the return response from server (map<string,List<string>>)  
            var StoreResponse = response.getReturnValue();
 
            // once set #StoreResponse to depnedentFieldMap attribute 
            cmp.set("v.depnedentFieldMap", StoreResponse);
 
            // create a empty array for store map keys(@@--->which is controller picklist values) 
 
            var listOfkeys = []; // for store all map keys (controller picklist values)
            var ControllerField = []; // for store controller picklist value to set on ui field. 
 
            // play a for loop on Return map 
            // and fill the all map key on listOfkeys variable.
            for (var singlekey in StoreResponse) {
               listOfkeys.push(singlekey);
            }
 
            //set the controller field value for ui:inputSelect  
            if (listOfkeys != undefined && listOfkeys.length > 0) {
               ControllerField.push({
                  class: "optionClass",
                  label: "--- None ---",
                  value: "--- None ---"
               });
            }
 
            for (var i = 0; i < listOfkeys.length; i++) {
               ControllerField.push({
                  class: "optionClass",
                  label: listOfkeys[i],
                  value: listOfkeys[i]
               });
            }
            // set the ControllerField variable values to country(controller picklist field)
            if(cmp.find('conCountry') != undefined){
            	cmp.find('conCountry').set("v.options", ControllerField);
            	cmp.find('conCountry').set("v.value", cmp.get("v.Ligne.Couronne__c"));
            	if (cmp.get("v.Ligne.Couronne__c") != null) {
 
            		// get dependent values for controller field by using map[key].  
            		// for i.e "India" is controllerValueKey so in the map give key Name for get map values like 
            		// map['India'] = its return all dependent picklist values.
            		var Map = cmp.get("v.depnedentFieldMap");
            		var ListOfDependentFields = Map[cmp.get("v.Ligne.Couronne__c")];
            		this.fetchDepValues(cmp, ListOfDependentFields);
            	}            
            }
            console.log('Lancement Finition');
            $A.enqueueAction(action3);
            }else if (response.getState() === "ERROR") {
            	console.log("Action 2 KO");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
      });

        action3.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
            	console.log('Finition OK');
                var allValues = response.getReturnValue();
 
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                //cmp.find("Finition").set("v.options", opts);
                //cmp.find('Finition').set("v.value", cmp.get("v.Ligne.Finition__c"));
                cmp.set("v.isDoneRendering", true);
                 var optFinitions = [];
                var optLiaison = [];
                optFinitions.push({class: "optionClass", label: "--- None ---",value: "" });
                 console.log('LibCnt OK ' + cmp.get("v.Ligne.LibCnt2__c"));
                 console.log('RecordType ' + cmp.get("v.Ligne.RecordType.DeveloperName"));
 			
          if(cmp.get("v.Ligne.ShowOptions__c")){
                if(cmp.get("v.Ligne.Occlusion__c")!=null){
                var optPrefLiaison = [];
   	            	optPrefLiaison.push({class: "optionClass", label: "Sous occlusion",value: "Sous occlusion" });
       	        	optPrefLiaison.push({class: "optionClass", label: "Normale",value: "Normale" });
           	    	optPrefLiaison.push({class: "optionClass", label: "Forte",value: "Forte" });
               		cmp.find("PrefLiaison").set("v.options", optPrefLiaison);
               		cmp.find("PrefLiaison").set("v.value", cmp.get("v.Ligne.Occlusion__c")); 
                }
                if(cmp.get("v.Ligne.Point_de_contact__c")!=null){
                	var optPointContact = [];
   	            	optPointContact.push({class: "optionClass", label: "Léger",value: "Léger" });
       	        	optPointContact.push({class: "optionClass", label: "Surface de contact",value: "Surface de contact" });
           	    	optPointContact.push({class: "optionClass", label: "Fort",value: "Fort" });
               		cmp.find("PointContact").set("v.options", optPointContact);
               		cmp.find("PointContact").set("v.value", cmp.get("v.Ligne.Point_de_contact__c")); 
                }
                    if(cmp.get("v.Ligne.Maquillage__c")!=null){
                	var optMaquillage = [];
       	        	optMaquillage.push({class: "optionClass", label: "Sans",value: "Sans" });
   	            	optMaquillage.push({class: "optionClass", label: "Léger",value: "Léger" });
           	    	optMaquillage.push({class: "optionClass", label: "Foncé",value: "Foncé" });
               		cmp.find("Maquillage").set("v.options", optMaquillage);
               		cmp.find("Maquillage").set("v.value", cmp.get("v.Ligne.Maquillage__c"));
                    }
                if(cmp.get("v.Ligne.Bandeau_m_tallique__c")!=null){ 
                	var optBandeau = [];
       	        	optBandeau.push({class: "optionClass", label: "Sans",value: "Sans" });
   	            	optBandeau.push({class: "optionClass", label: "Avec",value: "Avec" });
               		cmp.find("Bandeau").set("v.options", optBandeau);
               		cmp.find("Bandeau").set("v.value", cmp.get("v.Ligne.Bandeau_m_tallique__c")); 
                }
               if(cmp.get("v.Ligne.Embrasure__c")!=null){  
                	var optEmbrasure = [];
       	        	optEmbrasure.push({class: "optionClass", label: "Fermée",value: "Fermée" });
   	            	optEmbrasure.push({class: "optionClass", label: "Ouverte",value: "Ouverte" });
               		cmp.find("Embrasure").set("v.options", optEmbrasure);
               		cmp.find("Embrasure").set("v.value", cmp.get("v.Ligne.Embrasure__c")); 
               }
                if(cmp.get("v.Ligne.Profil_d_mergence__c")!=null){ 
                	var optProfilEmergence = [];
       	        	optProfilEmergence.push({class: "optionClass", label: "Juxta gingival",value: "Juxta gingival" });
   	            	optProfilEmergence.push({class: "optionClass", label: "Sous gingival de 1 mm",value: "Sous gingival de 1 mm" });
   	            	optProfilEmergence.push({class: "optionClass", label: "Supra gingival",value: "Supra gingival" });
               		cmp.find("ProfilEmergence").set("v.options", optProfilEmergence);
               		cmp.find("ProfilEmergence").set("v.value", cmp.get("v.Ligne.Profil_d_mergence__c")); 
                }
                if(cmp.get("v.Ligne.Trac_de_stellite__c")!=null){
                	var optTraceStellite = [];
       	        	optTraceStellite.push({class: "optionClass", label: "Oui",value: "Oui" });
   	            	optTraceStellite.push({class: "optionClass", label: "-",value: "-" });
           	    	optTraceStellite.push({class: "optionClass", label: "Non",value: "Non" });
               		cmp.find("TraceStellite").set("v.options", optTraceStellite);
               		cmp.find("TraceStellite").set("v.value", cmp.get("v.Ligne.Trac_de_stellite__c")); 
                }
                if(cmp.get("v.Ligne.Perforation__c")!=null){
                	var optPerforation = [];
   	            	optPerforation.push({class: "optionClass", label: "Avec",value: "Avec" });
       	        	optPerforation.push({class: "optionClass", label: "Sans",value: "Sans" });
               		cmp.find("Perforation").set("v.options", optPerforation);
               		cmp.find("Perforation").set("v.value", cmp.get("v.Ligne.Perforation__c")); 
                 }
          }
                    console.log('Preferences');

                if(cmp.get("v.Ligne.LibCnt2__c")=='Couronne'){
                	optFinitions.push({class: "optionClass", label: 'Essayage armature',value: 'Essayage armature'});
                	//optFinitions.push({class: "optionClass", label: 'Essayage biscuit',value: 'Essayage biscuit'});
                	optFinitions.push({class: "optionClass", label: 'Essayage armature + montage céramique (biscuit)',value: 'Essayage armature + montage céramique (biscuit)'});
                	//optFinitions.push({class: "optionClass", label: 'Montage céramique (biscuit)',value: 'Montage céramique (biscuit)'});
                	//optFinitions.push({class: "optionClass", label: 'Montage céramique et finition',value: 'Montage céramique et finition'});
                	//optFinitions.push({class: "optionClass", label: 'Finition',value: 'Finition'});
                	optFinitions.push({class: "optionClass", label: 'Finition directe',value: 'Finition directe'});
                	console.log('Bedore Liaison');
                	optLiaison.push({class: "optionClass", label: "--- None ---",value: "" });
                	optLiaison.push({class: "optionClass", label: "Unitaire",value: "Unitaire" });
                	optLiaison.push({class: "optionClass", label: "Solidarisé",value: "Solidarisé" });
                	optLiaison.push({class: "optionClass", label: "Bridge",value: "Bridge" });
                	console.log('After options Liaison');
                	cmp.find("Liaison").set("v.options", optLiaison);
                	cmp.find("Liaison").set("v.value", cmp.get("v.Ligne.Liaison__c")); 
                	console.log("Liaison - "+ cmp.get("v.Ligne.Liaison__c")); 
                	console.log("Liaison");
                }
                if(cmp.get("v.Ligne.LibHaut__c")=='PEI / Cire'){
                	optLiaison.push({class: "optionClass", label: "--- None ---",value: "" });
                	optLiaison.push({class: "optionClass", label: "Porte Empreinte Individuel (PEI)",value: "Porte Empreinte Individuel (PEI)" });
                	optLiaison.push({class: "optionClass", label: "Cire d'occlusion",value: "Cire d'occlusion" });
                	optLiaison.push({class: "optionClass", label: "Cire d'occlusion base résine",value: "Cire d'occlusion base résine" });
                	optLiaison.push({class: "optionClass", label: "PEI + Cire d'occlusion",value: "PEI + Cire d'occlusion" });
                	optLiaison.push({class: "optionClass", label: "PEI + Cire d'occlusion base résine",value: "PEI + Cire d'occlusion base résine" });
                	optLiaison.push({class: "optionClass", label: "Guide radiologique",value: "Guide radiologique" });
                	optLiaison.push({class: "optionClass", label: "Guide chirurgical (sur empreinte physique)",value: "Guide chirurgical (sur empreinte physique)" });
                	optLiaison.push({class: "optionClass", label: "Clé en plâtre",value: "Clé en plâtre" });
                	optLiaison.push({class: "optionClass", label: "Cire d’occlusion vissée sur l’ensemble des piliers",value: "Cire d’occlusion vissée sur 2 piliers provisoires" });
                	optLiaison.push({class: "optionClass", label: "Coulée des empreintes + choix des piliers coniques",value: "Coulée des empreintes + choix des piliers coniques" });
                	optLiaison.push({class: "optionClass", label: "Modèles en plâtre",value: "Modèles en plâtre" });
                	cmp.find("Liaison").set("v.options", optLiaison);
                	cmp.find("Liaison").set("v.value", cmp.get("v.Ligne.Type__c")); 
                	console.log("Liaison - "+ cmp.get("v.Ligne.Type__c")); 
                	console.log("Liaison");
                	cmp.find('Arcades').set("v.value", cmp.get("v.Ligne.Arcade__c"));
                }
                if(cmp.get("v.Ligne.RecordType.DeveloperName")=='Gouttiere'){
                	optLiaison.push({class: "optionClass", label: "--- None ---",value: "" });
                	//optLiaison.push({class: "optionClass", label: "Gouttière thermoformée souple",value: "Gouttière thermoformée souple" });
                	optLiaison.push({class: "optionClass", label: "Gouttière de contention",value: "Gouttière de contention" });
                	optLiaison.push({class: "optionClass", label: "Gouttière de bruxisme dure",value: "Gouttière de bruxisme dure" });
                	optLiaison.push({class: "optionClass", label: "Gouttière semi-rigide",value: "Gouttière semi-rigide" });
                	optLiaison.push({class: "optionClass", label: "Gouttière de blanchiment",value: "Gouttière de blanchiment" });
                	optLiaison.push({class: "optionClass", label: "Gouttière de fluoration",value: "Gouttière de fluoration" });
                	optLiaison.push({class: "optionClass", label: "Gouttière hémostatique",value: "Gouttière hémostatique" });
                	optLiaison.push({class: "optionClass", label: "Gouttière de sport",value: "Gouttière de sport" });
                	//optLiaison.push({class: "optionClass", label: "Gouttière extra fine dure",value: "Gouttière extra fine dure" });
                	// optLiaison.push({class: "optionClass", label: "Gouttière de bruxisme dure (SUR EMPREINTE NUMÉRIQUE)",value: "Gouttière de bruxisme dure (SUR EMPREINTE NUMÉRIQUE)" });
                	// optLiaison.push({class: "optionClass", label: "Gouttière semi-rigide (SUR EMPREINTE NUMÉRIQUE)",value: "Gouttière semi-rigide (SUR EMPREINTE NUMÉRIQUE)" });
                	cmp.find("Liaison").set("v.options", optLiaison);
                	cmp.find("Liaison").set("v.value", cmp.get("v.Ligne.Type__c")); 
                	console.log("Liaison - "+ cmp.get("v.Ligne.Type__c")); 
                	console.log("Liaison");
                	cmp.find('Arcades').set("v.value", cmp.get("v.Ligne.Arcade__c"));
                }
                if(cmp.get("v.Ligne.RecordType.DeveloperName")=='Resine'){
                	optLiaison.push({class: "optionClass", label: "--- None ---",value: "" });
                	optLiaison.push({class: "optionClass", label: "Résine standard",value: "Résine standard" });
                	optLiaison.push({class: "optionClass", label: "Valplast",value: "Valplast" });
                	cmp.find("Liaison").set("v.options", optLiaison);
                	cmp.find("Liaison").set("v.value", cmp.get("v.Ligne.Liaison__c")); 
                	optFinitions.push({class: "optionClass", label: 'Montage dents sur cire',value: 'Montage dents sur cire'});
                	optFinitions.push({class: "optionClass", label: 'Finition directe',value: 'Finition directe'});
                	console.log('Fin Résine');
                }
                if(cmp.get("v.Ligne.RecordType.DeveloperName")=='ResineSansAffectation'){
                	optLiaison.push({class: "optionClass", label: "--- None ---",value: "" });
                	optLiaison.push({class: "optionClass", label: "Résine standard",value: "Résine standard" });
                	optLiaison.push({class: "optionClass", label: "Valplast",value: "Valplast" });
                	cmp.find("Liaison").set("v.options", optLiaison);
                	cmp.find("Liaison").set("v.value", cmp.get("v.Ligne.Liaison__c")); 
                	optFinitions.push({class: "optionClass", label: 'Montage dents sur cire',value: 'Montage dents sur cire'});
                	optFinitions.push({class: "optionClass", label: 'Finition directe',value: 'Finition directe'});
                	optFinitions.push({class: "optionClass", label: 'Finition (Montage des dents déjà réalisé)',value: 'Finition (Montage des dents déjà réalisé)'});
                	console.log('Fin Résine');
                }
                if(cmp.get("v.Ligne.RecordType.DeveloperName")=='Stellite'){
                	optFinitions.push({class: "optionClass", label: 'Essayage plaque nue',value: 'Essayage plaque nue'});
                	optFinitions.push({class: "optionClass", label: 'Plaque + Cire d\'occlusion',value: 'Plaque + Cire d\'occlusion'});
                	optFinitions.push({class: "optionClass", label: 'Plaque + Montage des dents',value: 'Plaque + Montage des dents'});
                	optFinitions.push({class: "optionClass", label: 'Finition directe',value: 'Finition directe'});
                	optFinitions.push({class: "optionClass", label: 'Montage des dents (Plaque déjà réalisée)',value: 'Montage des dents (Plaque déjà réalisée)'});
                	optFinitions.push({class: "optionClass", label: 'Montage des dents + finition (Plaque déjà réalisée)',value: 'Montage des dents + finition (Plaque déjà réalisée)'});
                	optFinitions.push({class: "optionClass", label: 'Finition (Plaque + montage des dents déjà réalisé)',value: 'Finition (Plaque + montage des dents déjà réalisé)'});
                	console.log('Fin Stellite');
                }
                if(cmp.get("v.Ligne.RecordType.DeveloperName")=='Ortho'){
                	optLiaison.push({class: "optionClass", label: "--- None ---",value: "" });
                	optLiaison.push({class: "optionClass", label: "Modèle d'étude",value: "Modèle d'étude" });
                	optLiaison.push({class: "optionClass", label: "Fil de contention",value: "Fil de contention" });
                	cmp.find("Liaison").set("v.options", optLiaison);
                	cmp.find("Liaison").set("v.value", cmp.get("v.Ligne.Type__c")); 
                	console.log("Liaison - "+ cmp.get("v.Ligne.Type__c")); 
                	console.log("Liaison");
                	cmp.find('Arcades').set("v.value", cmp.get("v.Ligne.Arcade__c"));
                }
                if(cmp.get("v.Ligne.RecordType.DeveloperName")=='Facette'){
                	optLiaison.push({class: "optionClass", label: "--- None ---",value: "" });
                	optLiaison.push({class: "optionClass", label: "EMAX : Céramique monolithique (hors zircone)",value: "EMAX : Céramique monolithique (hors zircone)" });
                	optLiaison.push({class: "optionClass", label: "CCZ : Céramo-céramique",value: "CCZ : Céramo-céramique" });
                	cmp.find("Liaison").set("v.options", optLiaison);
                	cmp.find("Liaison").set("v.value", cmp.get("v.Ligne.Type__c")); 
                	optFinitions.push({class: "optionClass", label: 'Essayage biscuit',value: 'Essayage biscuit'});
                	//optFinitions.push({class: "optionClass", label: 'Montage céramique (biscuit)',value: 'Montage céramique (biscuit)'});
                	optFinitions.push({class: "optionClass", label: 'Finition',value: 'Finition'});
                	optFinitions.push({class: "optionClass", label: 'Finition directe',value: 'Finition directe'});
                }
                if(cmp.get("v.Ligne.RecordType.DeveloperName")=='Services'){
                	optLiaison.push({class: "optionClass", label: "--- None ---",value: "" });
                	optLiaison.push({class: "optionClass", label: "Résine",value: "Résine" });
                	optLiaison.push({class: "optionClass", label: "Stellite",value: "Stellite" });
                	cmp.find("Liaison").set("v.options", optLiaison);
                	cmp.find("Liaison").set("v.value", cmp.get("v.Ligne.Type__c")); 
                	optFinitions.push({class: "optionClass", label: 'Adjonction d’une dent',value: 'Adjonction d’une dent'});
                	optFinitions.push({class: "optionClass", label: 'Adjonction de 2 ou 3 dents',value: 'Adjonction de 2 ou 3 dents'});
                	optFinitions.push({class: "optionClass", label: 'Adjonction de plus de 3 dents',value: 'Adjonction de plus de 3 dents'});
                	optFinitions.push({class: "optionClass", label: 'Rebasage',value: 'Rebasage'});
                	optFinitions.push({class: "optionClass", label: 'Adjonction de crochet métal',value: 'Adjonction de crochet métal'});
                	optFinitions.push({class: "optionClass", label: 'Adjonction de crochet flexible rose',value: 'Adjonction de crochet flexible rose'});
                	optFinitions.push({class: "optionClass", label: 'Adjonction de crochet transparent',value: 'Adjonction de crochet transparent'});
                	optFinitions.push({class: "optionClass", label: 'Adjonction de crochet acetal',value: 'Adjonction de crochet acetal'});
                	optFinitions.push({class: "optionClass", label: 'Réparation Cassure',value: 'Réparation Cassure'}); 
                }
                if(cmp.get("v.Ligne.RecordType.DeveloperName")=='Wax_up'){ 
                	optLiaison.push({class: "optionClass", label: "--- None ---",value: "" });
                	optLiaison.push({class: "optionClass", label: "Wax-up",value: "Wax-up" });
                	cmp.find("Liaison").set("v.options", optLiaison);
                	cmp.find("Liaison").set("v.value", cmp.get("v.Ligne.Type__c")); 
                }
                if(cmp.get("v.Ligne.RecordType.DeveloperName")=='Inlay_onlay'){
                	optLiaison.push({class: "optionClass", label: "--- None ---",value: "" });
                	optLiaison.push({class: "optionClass", label: "Composite",value: "Composite" });
                	optLiaison.push({class: "optionClass", label: "EMAX : Céramique monolithique (hors zircone)",value: "EMAX : Céramique monolithique (hors zircone)" });
                	optLiaison.push({class: "optionClass", label: " Full Zr Multilayer : Céramique monolithique Zircone",value: " Full Zr Multilayer : Céramique monolithique Zircone" });
                	optLiaison.push({class: "optionClass", label: "Metal",value: "Metal" });
                	optLiaison.push({class: "optionClass", label: "ENAMIC",value: "ENAMIC" });
                	cmp.find("Liaison").set("v.options", optLiaison);
                	cmp.find("Liaison").set("v.value", cmp.get("v.Ligne.Type__c")); 
                	optFinitions.push({class: "optionClass", label: 'Finition directe',value: 'Finition directe'});
                }
                if(cmp.get("v.Ligne.RecordType.DeveloperName")=='Superstructure_et_barres'){ 
                	optFinitions.push({class: "optionClass", label: 'Essayage esthétique et fonctionnel',value: 'Essayage esthétique et fonctionnel'});
                	optFinitions.push({class: "optionClass", label: 'Choix des piliers coniques + PEI',value: 'Choix des piliers coniques + PEI'});
                	optFinitions.push({class: "optionClass", label: 'clef de validation en plâtre + cire d’occlusion transvissée',value: 'clef de validation en plâtre + cire d’occlusion transvissée'});
                	// optFinitions.push({class: "optionClass", label: 'Essayage de la barre',value: 'Essayage de la barre'});
                	optFinitions.push({class: "optionClass", label: 'Fabrication de la barre + montage des dents',value: 'Fabrication de la barre + montage des dents'});
                	// optFinitions.push({class: "optionClass", label: 'Finition directe',value: 'Finition directe'});
                	optFinitions.push({class: "optionClass", label: 'Finition',value: 'Finition'});
                }
               if(cmp.get("v.Ligne.RecordType.DeveloperName")=='Planification_implantaire'){ 
     /*           	optLiaison.push({class: "optionClass", label: "--- None ---",value: "" });
                	optLiaison.push({class: "optionClass", label: "Appui dentaire",value: "Appui dentaire" });
                	optLiaison.push({class: "optionClass", label: "Appui muqueux",value: "Appui muqueux" });
                	cmp.find("Liaison").set("v.options", optLiaison);
                	cmp.find("Liaison").set("v.value", cmp.get("v.Ligne.Liaison__c")); */
                	optFinitions.push({class: "optionClass", label: 'Planification implantaire et impression du guide',value: 'Planification implantaire et impression du guide'});
                	//optFinitions.push({class: "optionClass", label: 'Planification du guide',value: 'Planification du guide'});
                	//optFinitions.push({class: "optionClass", label: 'Impression du guide',value: 'Impression du guide'});
                    cmp.find("SsType1").set("v.value", cmp.get("v.Ligne.Type_de_couronne__c")); 
                }
                 cmp.find("Finition").set("v.options", optFinitions);
                cmp.find('Finition').set("v.value", cmp.get("v.Ligne.Finition__c"));
                
                if((cmp.get("v.Ligne.RecordType.DeveloperName")!='Couronne_sur_implants')&&(cmp.get("v.Ligne.RecordType.DeveloperName")!='Superstructure_et_barres')){
                	cmp.find("Type1").set("v.value", cmp.get("v.Ligne.Type__c")); 
                   if(cmp.get("v.Ligne.RecordType.DeveloperName")!='Planification_implantaire'){
 	                	cmp.find("SsType1").set("v.value", cmp.get("v.Ligne.Alliage_Inlay_core__c")); 
                   }
                }else{
                	cmp.find("Type1").set("v.value", cmp.get("v.Ligne.Accastillage__c")); 
                	cmp.find("SsType1").set("v.value", cmp.get("v.Ligne.Type_de_couronne__c")); 
                }
                
/*                cmp.find("PrefLiaison").set("v.value", cmp.get("v.Ligne.Occlusion__c")); 
                cmp.find("PointContact").set("v.value", cmp.get("v.Ligne.Point_de_contact__c")); 
                cmp.find("Maquillage").set("v.value", cmp.get("v.Ligne.Maquillage__c")); 
                cmp.find("MaquillageSillon").set("v.value", cmp.get("v.Ligne.Maquillage_sillon__c")); 
                cmp.find("Bandeau").set("v.value", cmp.get("v.Ligne.Bandeau_m_tallique__c")); 
                cmp.find("TypePreparation").set("v.value", cmp.get("v.Ligne.Type_de_pr_paration__c")); */

                var Marque = cmp.get("v.Ligne.Marque_d_implant__c");
		  		var ETKs = document.getElementById("ETK");
  				if (Marque === "ETK") {
    				ETKs.style.display = "block";
  				} else {
    				ETKs.style.display = "none";
  				}
  				var STDs = document.getElementById("STD");
  				if ((Marque != "ETK")&&(Marque != "BIOTECH")){
    				STDs.style.display = "block";
  				} else {
    				STDs.style.display = "none";
  				}
  				var BIOs = document.getElementById("BIOTECH");
  				if (Marque === "BIOTECH") {
    				BIOs.style.display = "block";
  				} else {
    				BIOs.style.display = "none";
  				}

                
            	}else if (response.getState() === "ERROR") {
            	console.log("Action 3 KO");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action1); 


        
    },
    
    getTeeth : function(cmp) {
        var action = cmp.get("c.getTeeth");
        action.setParams({ 
            recordId : cmp.get("v.recordId"),
            FieldId : cmp.get("v.field")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
                console.log('component is valid and state is SUCCESS');
                var str = response.getReturnValue();
                var res = "";
                if(str != null)res = str.split(";");
                cmp.set("v.Dents",res);
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action); 
    },
    
    getCleanPicklistValue : function(cmp,PId){
    	if(cmp.find(PId) == undefined){
    		return null;
    	}else{
    		var str = cmp.find(PId).get("v.value");
    		if(str == '--- None ---'){
    			return null;
    		}else{
    			return str;
    		}
    	}
    },
    
	saveLigne : function(cmp) {
        var action = cmp.get("c.ServersaveLigne");
        var j =JSON.stringify(cmp.get("v.Dents"));
        var j2 =JSON.stringify(cmp.get("v.Dents2"));
/*        var tp1 = (cmp.find('Type1') == undefined)?null:cmp.find('Type1').get("v.value"); // cmp.find('Type1').get("v.value");
        var stp1 = (cmp.find('SsType1') == undefined)?null:cmp.find('SsType1').get("v.value"); // cmp.find('SsType1').get("v.value");
        var tp2 = (cmp.find('conCountry') == undefined)?null:cmp.find('conCountry').get("v.value"); //cmp.find('conCountry').get("v.value");
        var stp2 = (cmp.find('conState') == undefined)?null:cmp.find('conState').get("v.value"); //cmp.find('conState').get("v.value");
        var li = (cmp.find('Liaison') == undefined)?null:cmp.find('Liaison').get("v.value"); //cmp.find('Liaison').get("v.value");
        var fi = (cmp.find('Finition') == undefined)?null:cmp.find('Finition').get("v.value"); //cmp.find('Finition').get("v.value");
        console.log("helper save ORD-" + cmp.get("v.Ligne.Ordonnance__c"));
        var PL = (cmp.find('PrefLiaison') == undefined)?null:cmp.find('PrefLiaison').get("v.value");
        var PC = (cmp.find('PointContact') == undefined)?null:cmp.find('PointContact').get("v.value");
        var Ma = (cmp.find('Maquillage') == undefined)?null:cmp.find('Maquillage').get("v.value");
        var MS = (cmp.find('MaquillageSillon') == undefined)?null:cmp.find('MaquillageSillon').get("v.value");
        var Ba = (cmp.find('Bandeau') == undefined)?null:cmp.find('Bandeau').get("v.value");
        var TP = (cmp.find('TypePreparation') == undefined)?null:cmp.find('TypePreparation').get("v.value");
        var Ar = (cmp.find('Arcades') == undefined)?null:cmp.find('Arcades').get("v.value");*/
        action.setParams({ 
            teethValues : j,
            teethValues2 : j2,
//            recordId : cmp.get("v.recordId"),
            l : cmp.get("v.Ligne"),
            Type1 : this.getCleanPicklistValue(cmp,'Type1'),
            SsType1 : this.getCleanPicklistValue(cmp,'SsType1'),
            Liaison : this.getCleanPicklistValue(cmp,'Liaison'),
            Type2 : this.getCleanPicklistValue(cmp,'conCountry'),
            SsType2 : this.getCleanPicklistValue(cmp,'conState'),
            Finition : this.getCleanPicklistValue(cmp,'Finition'),
            Arcade : this.getCleanPicklistValue(cmp,'Arcades'),
            PrefLiaison : this.getCleanPicklistValue(cmp,'PrefLiaison'),
            PointContact : this.getCleanPicklistValue(cmp,'PointContact'),
            Maquillage : this.getCleanPicklistValue(cmp,'Maquillage'),
            MaquillageSillon : this.getCleanPicklistValue(cmp,'MaquillageSillon'),
            Bandeau : this.getCleanPicklistValue(cmp,'Bandeau'),
            TypePreparation : this.getCleanPicklistValue(cmp,'TypePreparation'),
            Embrasure : this.getCleanPicklistValue(cmp,'Embrasure'),
            Perforation : this.getCleanPicklistValue(cmp,'Perforation'),
            ProfilEmergence : this.getCleanPicklistValue(cmp,'ProfilEmergence'),
            TraceStellite : this.getCleanPicklistValue(cmp,'TraceStellite')
            //Options : cmp.get("v.optObj")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action); 
        
        

	},
	deleteLigne : function(cmp) {
        var action = cmp.get("c.ServerDeleteLigne");
        console.log("helper delete");
        action.setParams({ 
            recordId : cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action); 
        
        

	},
	cancelLigne : function(cmp) {
        var action = cmp.get("c.ServerCancelLigne");
        console.log("helper cancel");
        action.setParams({ 
            recordId : cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action); 
        
        

	},
	saveTeeth : function(cmp) {
        var action = cmp.get("c.saveTeeth");
        var j =JSON.stringify(cmp.get("v.Dents"));

        action.setParams({ 
            teethValues : j,
            recordId : cmp.get("v.recordId"),
            FieldId : cmp.get("v.field")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action); 
        
        

	},
    
    initTeeth : function(cmp){
        var teeth = cmp.get("v.Dents");
        var F = cmp.get("v.field");
        if(teeth != null && teeth != ''){
            for(var i=0; i<teeth.length; i++){
                var tooth = document.getElementById(F+teeth[i]);
                if(tooth != null){
                    var svgElement = tooth.getElementsByClassName("dent")[0];
                    if(svgElement != null)svgElement.setAttribute("fill", "rgba(0, 161, 223,1)");
                }
            }
        }

    }, 
    
   fetchPicklistValues: function(component, controllerField, dependentField) {
      // call the server side function  
      console.log("before everything");
      var action = component.get("c.getDependentOptionsImpl");
      // pass paramerters [object name , contrller field name ,dependent field name] -
      // to server side function 
 
      action.setParams({
         'objApiName': component.get("v.objInfo"),
         'contrfieldApiName': controllerField,
         'depfieldApiName': dependentField
      });
      //set callback   
      console.log("before callback");
      action.setCallback(this, function(response) {
         if (response.getState() == "SUCCESS") {
            //store the return response from server (map<string,List<string>>)  
            var StoreResponse = response.getReturnValue();
 
            // once set #StoreResponse to depnedentFieldMap attribute 
            component.set("v.depnedentFieldMap", StoreResponse);
 
            // create a empty array for store map keys(@@--->which is controller picklist values) 
 
            var listOfkeys = []; // for store all map keys (controller picklist values)
            var ControllerField = []; // for store controller picklist value to set on ui field. 
 
            // play a for loop on Return map 
            // and fill the all map key on listOfkeys variable.
            for (var singlekey in StoreResponse) {
               listOfkeys.push(singlekey);
            }
 
            //set the controller field value for ui:inputSelect  
            if (listOfkeys != undefined && listOfkeys.length > 0) {
               ControllerField.push({
                  class: "optionClass",
                  label: "--- None ---",
                  value: "--- None ---"
               });
            }
 
            for (var i = 0; i < listOfkeys.length; i++) {
               ControllerField.push({
                  class: "optionClass",
                  label: listOfkeys[i],
                  value: listOfkeys[i]
               });
            }
            // set the ControllerField variable values to country(controller picklist field)
            component.find('conCountry').set("v.options", ControllerField);
         }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
      });
      $A.enqueueAction(action);
   },
 
 
   fetchDepValues: function(component, ListOfDependentFields) {
      // create a empty array var for store dependent picklist values for controller field)  
      var dependentFields = [];
 
      if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
         dependentFields.push({
            class: "optionClass",
            label: "--- None ---",
            value: "--- None ---"
         });
 
      }
      for (var i = 0; i < ListOfDependentFields.length; i++) {
         dependentFields.push({
            class: "optionClass",
            label: ListOfDependentFields[i],
            value: ListOfDependentFields[i]
         });
      }
      // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
      component.find('conState').set("v.options", dependentFields);
      // make disable false for ui:inputselect field 
      component.set("v.isDependentDisable", false);
      component.find('conState').set("v.value", component.get("v.Ligne.Alliage__c"));
   },    
   
})