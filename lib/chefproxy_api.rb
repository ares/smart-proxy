require 'proxy/chefproxy'
require 'proxy/authentication'

class SmartProxy
  post "/facts" do
    Proxy::Authentication::Chef.new.authenticated(request) do |content|
        Proxy::ChefProxy::Facts.new.post_facts(content)
    end
  end

  post "/reports" do
      Proxy::Authentication::Chef.new.authenticated(request) do |content|
        Proxy::ChefProxy::Reports.new.post_report(content)
      end
  end
end
