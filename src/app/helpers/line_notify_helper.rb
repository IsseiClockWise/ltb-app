module LineNotifyHelper
  require 'net/http'

  def send_line_notification(message)
    token = ENV['LINE_NOTIFY_TOKEN']
    uri = URI.parse("https://notify-api.line.me/api/notify")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Authorization"] = "Bearer #{token}"
    request.set_form_data({message: message})

    response = http.request(request)
    puts response.body
  end
end
