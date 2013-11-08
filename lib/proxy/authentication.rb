module Proxy::Authentication 
  class Chef
    require 'chef'
    require 'digest/sha2'
    require 'base64'
    require 'openssl'
    require 'helpers'

    def verify_signature_request(client_name,signature,body)
        #We need to retrieve node public key
        #to verify signature
        chefurl = SETTINGS.chefserver_url
        client_name = SETTINGS.smartproxy_clientname
        key = SETTINGS.smartproxy_privatekey

        rest = ::Chef::REST.new(chefurl,client_name,key)
        begin
          public_key = OpenSSL::PKey::RSA.new(rest.get_rest("/clients/#{client_name}").public_key)
        rescue
          return false
        end
        #signature is base64 encoded
        decoded_signature = Base64.decode64(signature)
        hash_body = Digest::SHA256.hexdigest(body)
        public_key.verify(OpenSSL::Digest::SHA256.new,decoded_signature,hash_body)
    end

    def authenticated(request, &block)
        content     = request.env["rack.input"].read

        auth = true
        if SETTINGS.authenticate_nodes
          client_name = request.env['HTTP_X_FOREMAN_CLIENT']
          signature   = request.env['HTTP_X_FOREMAN_SIGNATURE']
          raise "401 Failed to authenticate node. Missing some headers" if client_name.nil? or signature.nil?
          auth = verify_signature_request(client_name,signature,content)
        end

        if auth
          raise "400 Body is empty" if content.nil?
          block.call(content)
        else
          raise "401 Failed to authenticate node"
        end
    end
  end
end
