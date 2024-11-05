class Api::V1::ItemsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    items = Item.getItems(params)
    if items.is_a?(String)
      render json: { message: "your query could not be completed", errors: [items] }, status: 404
    else
      render json: ItemSerializer.format_items(items)
    end
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.format_single_item(item)
  end

  def create
    begin
      item = Item.create!(item_params)
      render json: ItemSerializer.new(item), status: :created
    rescue ActiveRecord::RecordInvalid => errors
      render json: error_messages(errors.record.errors.full_messages, 422), status: :unprocessable_entity
    end
  end

  def update
    begin
      item = Item.find(params[:id])
      item.update!(item_params)
      render json: ItemSerializer.format_single_item(item)
    rescue ActiveRecord::RecordNotFound => error
      render json: error_messages([error.message], 404), status: :not_found
    rescue ActiveRecord::RecordInvalid => errors
      render json: error_messages(errors.record.errors.full_messages, 422), status: :unprocessable_entity
    end
  end

  def destroy
    begin
      item = Item.find(params[:id])
      item.destroy
      head :no_content # Respond with no content on successful deletion
    rescue ActiveRecord::RecordNotFound => error
      render json: { message: "your query could not be completed", errors: [error.message] }, status: 404
    end
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