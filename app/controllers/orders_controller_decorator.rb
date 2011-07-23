OrdersController.class_eval do
  def populate
    params[:option_values].each_pair do |product_id, otov|
      quantity = params[:quantity].to_i if !params[:quantity].is_a?(Array)
      quantity = params[:quantity][variant_id].to_i if params[:quantity].is_a?(Array)
      option_value_ids = otov.map{|option_type_id, option_value_id| option_value_id}
      params[:variants] = Hash[ Variant.by_option_value_ids(option_value_ids, product_id).first.id, quantity ]
    end if params[:option_values]

    @order = current_order(true)

    params[:products].each do |product_id,variant_id|
      quantity = params[:quantity].to_i if !params[:quantity].is_a?(Hash)
      quantity = params[:quantity][variant_id].to_i if params[:quantity].is_a?(Hash)
      @order.add_variant(Variant.find(variant_id), quantity) if quantity > 0
    end if params[:products]

    params[:variants].each do |variant_id, quantity|
      quantity = quantity.to_i
      @order.add_variant(Variant.find(variant_id), quantity) if quantity > 0
    end if params[:variants]

    respond_with(@order) { |format| format.html { redirect_to cart_path } }
  end

  respond_override :create => { :html => { :failure => :redirector_for_failure } }
    
  def redirector_for_failure
    if flash[:error].blank?
      redirect_to edit_order_url(@order)
    else
      redirect_to :back
    end
  end
    
end
