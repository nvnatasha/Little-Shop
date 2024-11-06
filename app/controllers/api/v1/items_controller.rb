class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record_response
  
  def index
    items = Item.getItems(params)
    if items.is_a?(String)
      render json: {  message: "your query could not be completed", errors: [items]  }, status: 404
    else
      render json: ItemSerializer.format_items(items)
    end
  end

  def show
    begin
      item = Item.find(params[:id])
      render json: ItemSerializer.format_single_item(item)
    rescue ActiveRecord::RecordNotFound => error
      error_response(error, :not_found) 
    end
  end

  def create
      item = Item.create!(item_params)
      render json: ItemSerializer.format_single_item(item), status: :created
    rescue ActiveRecord::RecordInvalid => error
      error_response(error, :unprocessable_entity) 
    end
  end
  
  def destroy
    begin
      Item.find(params[:id]).destroy
      head :no_content
    rescue ActiveRecord::RecordNotFound => error
      error_response(error, :not_found) 
      render json: ItemSerializer.format_single_item(item), status: 201
  end

  def update
    item = Item.find(params[:id])
    item.update!(item_params)
    render json: ItemSerializer.format_single_item(item)
  end

  def destroy
      item = Item.find(params[:id])
      item.destroy
  end

  def find_all
    items = Item.find_all(params)
    if items.is_a?(Hash)
      render json: {
        message: "your request could not be completed",
        errors: [
          {
            status: "405",
            title: "you can't ask for both"
          }
        ]
      }, status: 405
    else 
      render json: ItemSerializer.format_items(items)
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end  

  def invalid_record_response(exception)
    render json: error_messages([exception.message], 422), status: 422
  end

  def error_messages(messages, status)
    {
      message: "your request could not be completed",
      errors: messages,
      status: status
    }
  end
end