class SmartProxy < Sinatra::Base

  helpers do
    # Accepts a html error code and a message, which is then returned to the caller after adding to the proxy log
    # OR  a block which is executed and its errors handled in a similar way.
    # If no code is supplied when the block is declared then the html error used is 400.
    def log_halt code=nil, exception=nil
      message = exception.is_a?(String) ? exception : exception.to_s
      begin
        if block_given?
          return yield
        end
      rescue => e
        message += e.message
        code     = code || 400
      end
      content_type :json if request.accept?("application/json")
      logger.error message
      logger.debug exception.backtrace.join("\n") if exception.is_a?(Exception)
      halt code, message
    end
  end

  def handle_error(error)
    if error.instance_of? Proxy::Error::Error400
    log_halt(400, "Bad request : "+error.message )
    elsif error.instance_of? Proxy::Error::Error401
      log_halt(401, "Unauthorized : "+error.message )
    end
  end
end
