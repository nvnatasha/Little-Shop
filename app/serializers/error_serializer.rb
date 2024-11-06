class ErrorSerializer
  include JSONAPI::Serializer
  def self.format_error(exception)
    {
      message: "your query could not be completed",
      errors: [exception.message]
    }
  end
end