module LineNotifyHelper
  def send_line_notify(message)
    require 'net/http'
    require 'uri'
    token = ENV['LINE_NOTIFY_TOKEN']
    uri = URI.parse('https://notify-api.line.me/api/notify')
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path)
    req['Authorization'] = "Bearer #{token}"
    req.set_form_data(message: message)
    res = https.request(req)
    res.body
  end
end
