Product.class_eval do
  attr_accessor :create_variants
  after_create :do_create_variants

  has_many :option_types, :through => :product_option_types, :order => "product_option_types.position ASC"

  def do_create_variants(force = false)
    if (create_variants == "1" || force) && self.option_types.length > 0
      Variant.without_callback( :touch_product ) do
        generate_variant_combinations.each_with_index do |option_values, index|
          variant_temp_sku = self.sku.blank? ? "#{self.name.to_url[0..3]}" : "#{self.sku}"
          option_values.each do | ov |
             if ov.skupartial && ov.skupartial != ""
               variant_temp_sku = "#{variant_temp_sku}-#{ov.skupartial}"
             end
          end
          v = Variant.create({
              :product => self,
              :option_values => option_values,
              :is_master => false,
              :sku => variant_temp_sku
            })
          v.update_attribute(:price, v.calculate_price(self.price))
        end
      end
    end
  end

  #performance, don't load all the variants since there could be thousands
  def has_variants_with_fault_override?
    value = Variant.count( :conditions => ["product_id=? AND deleted_at IS NULL AND is_master = 0", id] );
    value > 0
  end

  alias_method_chain :has_variants?, :fault_override

  def default_variant
    variants.first
  end

  def generate_variant_combinations(option_values = nil)
    option_values ||= self.option_types.map{|ot| ot.option_values}
    if option_values.length == 1
      option_values.first.map{|v| [v]}
    else
      result = []
      option_values.first.each do |value|
        result += generate_variant_combinations(option_values[1..-1]).map{|rv| rv.push(value) }
      end
      result
    end
  end
end
