Admin::VariantsController.class_eval do
  
  def index
    @product = Product.find_by_permalink(params[:product_id])
    @variants = Variant.where( ["product_id = ? AND is_master = ? AND deleted_at is NULL", @product.id, false] ).order( "position ASC" ).all.paginate :page => params[:page]
  end
  
  def regenerate
    product = Product.find_by_permalink(params[:product_id])
    product.do_create_variants(:recreate)
    redirect_to :action => :index, :product_id => params[:product_id]
  end
end