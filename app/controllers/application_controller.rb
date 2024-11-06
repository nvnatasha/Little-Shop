class ApplicationController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
    
    private

    def error_response(exception, code)
        render json: ErrorSerializer.format_error(exception), status: code
    end  
end
