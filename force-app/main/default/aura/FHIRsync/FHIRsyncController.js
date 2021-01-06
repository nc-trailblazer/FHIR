({
	handleClick : function(component, event, helper) {
      
        console.log("Call Controller");
        let action = component.get("c.getToken");
        console.log("Called Controller");
        action.setCallback(this, function(response) {
            let state = response.getStte();
            if (state === 'SUCCESS') {
                console.log("In Success");
                
                
            }
            else {
                console.log("Error");
            }
        });
        $A.enqueueAction(action);
        
       
    }
})