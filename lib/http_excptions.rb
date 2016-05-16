module HttpExcptions
  class HttpError < StandardError
    attr_reader :record
    attr_reader :errors

    def initialize(options = {})
      if options.is_a? String
        @errors = [options]
      else
        @record = options[:record]
        @errors = @record.nil? ? @record.errors : options[:errors]
      end
      
      message = @errors
      super(message)
    end

  end

  # HTTP-CODE 400
  class BadRequest < HttpError

    def initialize(options = "bad request")
      super(options)
    end

  end

  # HTTP-CODE 401
  class NotAuthourized < HttpError

    def initialize(options = "not authourized")
      super(options)
    end

  end

  # HTTP-CODE 403
  class Forbidden < HttpError

    def initialize(options = "Forbidden")
      super(options)
    end

  end

  # HTTP-CODE 404
  class NotFound < HttpError

    def initialize(options = "not found")
      super(options)
    end

  end

  # HTTP-CODE 500
  class InternalServerError < HttpError

    def initialize(options = "Internal Server Error")
      super(options)
    end

  end

end