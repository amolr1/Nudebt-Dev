var __8x8Chat = {

        uuid: "script_13685593155b61fe5b773ba6.83689219",

        tenant: "c3RyYXRlZ2ljZmluYW5jaWExMDE",

        channel: "Chat Test Channel",

        domain: "https://vcc-na10.8x8.com",

        path: "/.",

        buttonContainerId: "__8x8-chat-button-container-script_13685593155b61fe5b773ba6.83689219",

        align: "right",
        
       onInit: function(bus) {

          // Message bus created and ready to be used
            window.bus = bus;
            
            bus.publish("customer:set-info", {
               "First Name": 'FirstName',
                "Last Name": 'last name'
               
            });
        }
        

    };
	(function() {

        var se = document.createElement("script");

        se.type = "text/javascript";

        se.async = true;

        se.src = __8x8Chat.domain + __8x8Chat.path + "/CHAT/common/js/chat.js";

        var os = document.getElementsByTagName("script")[0];

        os.parentNode.insertBefore(se, os);

    })();
