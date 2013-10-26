#require "proxy/util"
require 'net/http'
require 'net/https'
require 'uri'

def foreman_request(path, body)
  uri              = URI.parse(SETTINGS.foreman_url.to_s)
  http             = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl     = uri.scheme == 'https'
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  if http.use_ssl?
    if SETTINGS.foreman_ssl_ca && !SETTINGS.foreman_ssl_ca.to_s..empty?
      http.ca_file     = options[:foreman_ssl_ca]
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    if SETTINGS.foreman_ssl_cert && !SETTINGS.foreman_ssl_cert.to_s.empty? && SETTINGS.foreman_ssl_key && !SETTINGS.foreman_ssl_key.to_s.empty?
      http.cert = OpenSSL::X509::Certificate.new(File.read(options[:foreman_ssl_cert]))
      http.key  = OpenSSL::PKey::RSA.new(File.read(options[:foreman_ssl_key]), nil)
    end
  end

  req = Net::HTTP::Post.new("#{uri.path}/#{path}")
  req.add_field('Accept', 'application/json,version=2')
  req.content_type = 'application/json'
  req.body         = body
  response         = http.request(req)
end

module Proxy::Chefproxy

  class Facts

    def self.post_facts facts
      foreman_request('/api/hosts/facts',facts)
    end
  end

  class Reports

    def self.post_report report
      foreman_request('/api/reports',report)
    end
  end
end
