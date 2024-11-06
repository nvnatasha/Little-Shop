class Api::V1::ItemsController < ApplicationController

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
    begin
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
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end