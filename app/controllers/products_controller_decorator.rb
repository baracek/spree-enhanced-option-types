ProductsController.class_eval do
  def update_price
    variant = nil; quantity = nil;

    params[:option_values].each_pair do |product_id, otov|
      quantity = params[:quantity].to_i if !params[:quantity].is_a?(Array)
      quantity = params[:quantity][variant_id].to_i if params[:quantity].is_a?(Array)
      option_value_ids = otov.map{|option_type_id, option_value_id| option_value_id}
      variant_list = Variant.by_option_value_ids(option_value_ids, product_id)
      variant = variant_list ? variant_list.first : nil
    end if params[:option_values]

    @current_variant = variant
    puts @current_variant ? @current_variant.id : "object null"
    render :partial => 'update_price'
  end
  
  def show_with_variant_override
    @product = Product.find_by_permalink!(params[:id])
    return unless @product

#    @variants = Variant.active.includes([:option_values, :images]).where(:product_id => @product.id)
    @product_properties = ProductProperty.includes(:property).where(:product_id => @product.id)
#    @selected_variant = @variants.detect { |v| v.available? }

    referer = request.env['HTTP_REFERER']

    if referer && referer.match('/^https?:\/\/[^\/]+\/t\/([a-z0-9\-\/]+)$/')
      @taxon = Taxon.find_by_permalink($1)
    end

    respond_with(@product)
  end 
  
  alias_method_chain :show, :variant_override
  
end
