OptionValue.class_eval do
  validates_numericality_of :amount, :allow_nil => true
  
  after_update :adjust_variant_prices, :if => :amount_changed?

  def adjust_variant_prices
    Variant.without_callback( :touch_product ) do
      variants.each{|v| v.update_attribute(:price, v.calculate_price ) }
    end
  end
end
