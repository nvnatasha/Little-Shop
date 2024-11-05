class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    items = Item.getItems(params)
    if items.is_a?(String)
      render json: {  message: "your query could not be completed", errors: [items]  }, status: 404
    else
      render json: ItemSerializer.format_items(items)
    end
  end

  def create
    item = Item.new(item_params)
    if item.save
      render json: ItemSerializer.format_single_item(item), status: :created
    else
      render json: { "message": "your query could not be completed", "errors": item.errors.full_messages }, status: 422
    end
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.format_single_item(item)
  end
  
  def destroy
    item = Item.find(params[:id])
    item.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound => error
    render json: { "message": "your query could not be completed", "errors": ["#{error.message}"] }, status: 404
  end

  private
  
  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end  

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
  
  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
  
  def not_found_response(exception)
    render json: ErrorSerializer.format_error(exception, "404"), status: :not_found
  end  

  def error_messages(messages, status)
    {
      message: "your request could not be completed",
      errors: messages,
      status: status
    }
  end
end