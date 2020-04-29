public class SFSPortal_PushNotificationController {
    
    Public Static String appId = '77fc100c-4cd4-4f40-b38b-4f591600a752';
    
    Public Static String apiKey = 'ZmY5M2E0YTctNDIxMS00MDA2LThhMTctMDEwMjBkNjA5MWQy';
        
    public static void pushNotification(String playerId, String contents, String headings, String app_url) {
        
        Organization companyInfo = SFSPortal_Utility.getOrgInfo();
        if (companyInfo.IsSandbox) {
                        
            appId = 'fca7e8ae-f9a7-4bea-883e-04fb1b4e0db8';
            apiKey = 'ODRiYzE3NWYtYzIxYi00NWFmLWFmMTgtZTgyNGI4MzA2Y2M3';
        }
        String finalEndpoint = 'https://onesignal.com/api/v1/notifications';
        HttpRequest requestToSend = new HttpRequest();
        requestToSend.setEndpoint(finalEndpoint);
        requestToSend.setMethod('POST');
        requestToSend.setHeader('Authorization', 'Basic ' + apiKey);
        requestToSend.setHeader('Content-Type', 'application/json');
        SFSPortal_PushNotificationController.NotificationsWrapper notificationWrap = new SFSPortal_PushNotificationController.NotificationsWrapper();
        notificationWrap.app_id = appId;
        //notificationWrap.app_url = 'https://onesignal.com';
        
        if (playerId != null && playerId.contains(', ')) {
        
            List<String> playerIds = playerId.split(', ');
            notificationWrap.include_player_ids.addAll(playerIds );
        } else {
        
            notificationWrap.include_player_ids.add(playerId);
        }
        notificationWrap.contents.put('en', contents);
        notificationWrap.headings.put('en', headings);
        requestToSend.setBody(JSON.serialize(notificationWrap));
        Http httpToSend = new Http();
        HttpResponse response = new HttpResponse();
        response = httpToSend.send(requestToSend);
    }
    public class NotificationsWrapper {
    
        public String app_id {get; set;}
        
        public String app_url {get; set;}
        
        public List<String> include_player_ids = new List<String>();
        
        public List<String> included_segments = new List<String>();
        
        public List<String> excluded_segments{get; set;}
        
        public Map<String, String> data = new Map<String, String>();
        
        public Map<String, String> contents = new Map<String, String>();
        
        public Map<String, String> headings = new Map<String, String>();
    }
}