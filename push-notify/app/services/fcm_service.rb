class FcmService
    def initialize
      @fcm = FCM.new(
        ENV['API_TOKEN'],
        ENV['GOOGLE_APPLICATION_CREDENTIALS_PATH'],
        ENV['PROJECT_ID']
      ) 
    end
  
    def send_notification(token, title, body)
        message = {
            'token': token,
            'data': {
              payload: {
                data: {
                  id: 1
                }
              }.to_json
            },
            'notification': {
              title: title,
              body: body,
            },
            'android': {},
            'apns': {
              payload: {
                aps: {
                  sound: "default",
                  category: "#{Time.zone.now.to_i}"
                }
              }
            },
            'fcm_options': {
              analytics_label: 'Label'
            }
          }
      response = @fcm.send_v1(message)
      JSON.parse(response[:body])
    end
end