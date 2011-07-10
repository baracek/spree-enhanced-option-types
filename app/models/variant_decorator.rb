Variant.class_eval do
  after_update :adjust_variant_prices, :if => lambda{|r| r.price_changed? && r.is_master}

  def self.by_option_value_ids(option_value_ids, product_id)
    Variant.find_by_sql([' 
        SELECT
          b.*
        FROM
          option_values_variants a inner join variants b on a.variant_id = b.id
        WHERE
          a.option_value_id IN ( ? ) 
            AND
          b.product_id = ?
        GROUP BY
          a.variant_id
        HAVING
          COUNT(a.variant_id) = ?',
        option_value_ids, product_id, option_value_ids.length] )
  end

  def calculate_price(master_price=nil)
    price = (master_price || product ? product.master.price : 0 ).to_f
    price+= OptionValue.sum( :amount, :joins => :variants, :conditions => { :variants => { :id => id } } )
    price > 0 ? price : 0
  end

  # Ensures a new variant takes the product master price when price is not supplied
  def check_price
    if self.price.blank?
      raise "Must supply price for variant or master.price for product." if self.is_master
      self.price = calculate_price
    end
  end

  def adjust_variant_prices
    Variant.without_callback( :touch_product ) do
      product.variants.each{|v| v.update_attribute(:price, v.calculate_price(self.price))}
    end
    touch_product
  end

  def self.without_callback( callback, &block )
    method = self.send( :instance_method, callback )
    self.send( :remove_method, callback )
    self.send( :define_method, callback ) {true}
    yield
    self.send( :remove_method, callback )
    self.send( :define_method, callback, method )
  end
end
