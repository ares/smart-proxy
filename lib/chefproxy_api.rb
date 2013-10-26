require 'proxy/chefproxy'

class SmartProxy

  post "/facts" do
      facts = request.env["rack.input"].read
      Proxy::Chefproxy::Facts.post_facts(facts)
  end

  post "/reports" do
      report = request.env["rack.input"].read
      Proxy::Chefproxy::Reports.post_report(report)
  end
end
