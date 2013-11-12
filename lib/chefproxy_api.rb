require 'proxy/chefproxy'
require 'proxy/authentication'

class SmartProxy
  post "/facts" do
    begin
      Proxy::Authentication::Chef.new.authenticated(request) do |content|
          Proxy::ChefProxy::Facts.new.post_facts(content)
      end
    rescue Proxy::Error::Error400, Proxy::Error::Error401 => e
      handle_error(e)
    end
  end

  post "/reports" do
    begin
      Proxy::Authentication::Chef.new.authenticated(request) do |content|
        Proxy::ChefProxy::Reports.new.post_report(content)
      end
    rescue Proxy::Error::Error400, Proxy::Error::Error401 => e
      handle_error(e)
    end
  end
end
