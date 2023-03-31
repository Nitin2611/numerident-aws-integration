({
    init : function(cmp, event, helper) {
        helper.getTeeth(cmp);
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
        if(!component.get("v.isDoneRendering")){
            console.log('#Entering On Render');
            component.set("v.isDoneRendering", true);
            /* COF - 220218 processing done in the controller because the event="aura:doneRendering" is called before the helper functions are initialized */
            for(var i = 0; i <= 48; i++){
                
                var svg = component.find("svg_"+i.toString());
                //var svg = document.getElementById(component.get("v.field") + "svg_"+i.toString());
                if(svg != null){
                    if(svg.getElement() != null){
                    	var value = svg.getElement().innerText;
                    	value = value.replace("<![CDATA[", "").replace("]]>", "");
                    	svg.getElement().innerHTML = value;  
                    }
                }
                
            }       
            var teeth = component.get("v.Dents");
            var F = component.get("v.field");
        	if(teeth != null && teeth != ''){
            	for(var i=0; i<teeth.length; i++){
                	// On ajoute la classe "Selected" à l'élément
                	//console.log(document.getElementById(teeth[i]));
                	var tooth = document.getElementById(F+teeth[i]);
                	//console.log("TEMP__"+i);
                	if(tooth != null){
                    	var svgElement = tooth.getElementsByClassName("dent")[0];
                    	if(svgElement != null)svgElement.setAttribute("fill", "rgba(0, 161, 223,1)");
                	}
            	}
        	}
        }
    },
    
    initSelectedTooth : function(cmp, event, helper) { 
        helper.initTeeth(cmp);
    },
    
    addTooth : function(cmp, event, helper) {
        var actif = cmp.get("v.actif");
        if(actif){
        	var teeth = cmp.get("v.Dents");
        	var F = cmp.get("v.field");
        	console.log("click on " + F+event.target.id);
        	var tooth =  document.getElementById(F+event.target.id);
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
        	helper.saveTeeth(cmp);	
        }else{
            alert("La commande a été validée ! Elle n'est plus modifiable.");
            /*cmp.find('notif').showNotice({
            	"variant": "error",
            	"header": "La commande a été validée !",
            	"message": "Elle n'est plus modifiable.",
            	closeCallback: function() {
                	alert('You closed the alert!');
            	}
        	});*/
        }
        
    },
    
    save : function(cmp, event, helper) {  
        var teeth = cmp.get("v.Dents");     
        helper.saveTeeth(cmp);	
    },
    
    handleShowNotice : function(component, event, helper) {
            cmp.find('notif').showNotice({
            "variant": "error",
            "header": "La commande a été validée !",
            "message": "Elle n'est plus modifiable.",
            closeCallback: function() {
                alert('You closed the alert!');
            }
        });
    }
})