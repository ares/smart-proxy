require 'proxy/chefproxy'
require 'proxy/authentication'

class SmartProxy
  post "/facts" do
    begin
      Proxy::Authentication::Chef.new.authenticated(request) do |content|
          Proxy::ChefProxy::Facts.new.post_facts(content)
      end
    rescue => e
      log_halt(e.message[/^\d+/].to_i , e.message[/\D+/])
    end
  end

  post "/reports" do
    begin
      Proxy::Authentication::Chef.new.authenticated(request) do |content|
        Proxy::ChefProxy::Reports.new.post_report(content)
      end
    rescue => e
      log_halt(e.message[/^\d+/].to_i , e.message[/\D+/])
    end
  end
end
