module Proxy::Authentication
  class Chef
    require 'chef'
    require 'digest/sha2'
    require 'base64'
    require 'openssl'

    def verify_signature_request(client_name,signature,body)
        #We need to retrieve node public key
        #to verify signature
        chefurl = SETTINGS.chefserver_url
        client_name = SETTINGS.smartproxy_clientname
        key = SETTINGS.smartproxy_privatekey

        rest = ::Chef::REST.new(chefurl,client_name,key)
        public_key = OpenSSL::PKey::RSA.new(rest.get_rest("/clients/#{client_name}").public_key)
        #signature is base64 encoded
        decoded_signature = Base64.decode64(signature)
        hash_body = Digest::SHA256.hexdigest(body)
        public_key.verify(OpenSSL::Digest::SHA256.new,decoded_signature,hash_body)
    end

    def authenticated(request, &block)
        client_name = request.env['HTTP_X_FOREMAN_CLIENT']
        signature   = request.env['HTTP_X_FOREMAN_SIGNATURE']
        content     = request.env["rack.input"].read

        auth = true
        auth = verify_signature_request(client_name,signature,content) if SETTINGS.authenticate_nodes
        if auth
          block.call(content)
        else
         log_halt 401, "Failed to authenticate node"
        end
    end
  end
end
