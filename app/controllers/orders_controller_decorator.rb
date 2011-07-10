OrdersController.class_eval do
  def populate_with_option_types
    params[:option_values].each_pair do |product_id, otov|
      quantity = params[:quantity].to_i if !params[:quantity].is_a?(Array)
      quantity = params[:quantity][variant_id].to_i if params[:quantity].is_a?(Array)
      option_value_ids = otov.map{|option_type_id, option_value_id| option_value_id}
      params[:variants] = Hash[ Variant.by_option_value_ids(option_value_ids, product_id).first.id, quantity ]
    end if params[:option_values]

    populate_without_option_types
  end

  alias_method_chain :populate, :option_types

  respond_override :create => { :html => { :failure => :redirector_for_failure } }
    
  def redirector_for_failure
    if flash[:error].blank?
      redirect_to edit_order_url(@order)
    else
      redirect_to :back
    end
  end
    
end
