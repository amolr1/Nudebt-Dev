// Your renderer method overrides go here
({
    afterRender: function(component, helper) {
        this.superAfterRender();
        var c = component.find("username_loginForm").get("v.value");
        c.getElement().addEventListener('paste', function() {
            console.log('pasted');
        });
    }
})