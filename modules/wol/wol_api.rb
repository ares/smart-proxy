require 'socket'

class Proxy::WolApi < Sinatra::Base
  helpers ::Proxy::Helpers
  authorize_with_trusted_hosts
  authorize_with_ssl_client

  post "/" do
    content_type :json
    
    mac_address = params[:mac_address]
    
    # Validate MAC address
    unless mac_address && valid_mac_address?(mac_address)
      log_halt 400, "Invalid MAC address provided"
    end
    
    # Send Wake-on-LAN magic packet
    begin
      send_magic_packet(mac_address)
      
      # Log the attempt
      logger.info "Wake-on-LAN packet sent to MAC address: #{mac_address}"
      
      { :status => "success", :message => "Wake-on-LAN packet sent successfully", :mac_address => mac_address }.to_json
    rescue => e
      logger.error "Failed to send Wake-on-LAN packet to #{mac_address}: #{e.message}"
      log_halt 500, "Failed to send Wake-on-LAN packet: #{e.message}"
    end
  end

  private

  def valid_mac_address?(mac)
    # Check if MAC address is in valid format (supports both : and - separators)
    mac.to_s.match(/^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/)
  end

  def send_magic_packet(mac_address)
    # Clean up MAC address and convert to binary
    mac_bytes = mac_address.gsub(/[:-]/, '').scan(/../).map { |hex| hex.to_i(16) }
    
    # Create magic packet: 6 bytes of 0xFF followed by 16 repetitions of MAC address
    magic_packet = [0xFF] * 6 + mac_bytes * 16
    
    # Convert to binary string
    packet = magic_packet.pack('C*')
    
    # Send UDP broadcast on port 9 (WoL standard port)
    socket = UDPSocket.new
    socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    socket.send(packet, 0, '255.255.255.255', 9)
    socket.close
  end
end 