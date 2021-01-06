({
    handleOnClick : function(component, event, helper) {
        var currentText = component.get("v.selectedTypes");
        if (currentText = null) {
            currentText = component.get(event.srcElement.value);
        //component.set( "v.selectedTypes", v.selectedTypes + ',' + event.srcElement.value );
            component.set ("v.selectedTypes", currentText);

        }
        else {
            currentText = component.get("v.selectedTypes") + "," + event.srcElement.value;
        //component.set( "v.selectedTypes", v.selectedTypes + ',' + event.srcElement.value );
            component.set ("v.selectedTypes", currentText);
        }
        
    }
})