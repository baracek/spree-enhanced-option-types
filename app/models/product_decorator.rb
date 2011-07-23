Product.class_eval do
  attr_accessor :create_variants
  after_create :do_create_variants

  has_many :option_types, :through => :product_option_types, :order => "product_option_types.position ASC"

  def do_create_variants(force = false)
    if (create_variants == "1" || force)      
      Variant.update_all  [ 'updated = ?', false ], ['product_id = ? AND is_master = ? AND deleted_at is NULL', self.id, false]
      if ( self.option_types.length > 0 )
        Variant.without_callback( :touch_product ) do
          generate_variant_combinations.each_with_index do |option_values, index|
            variant_temp_sku = self.sku.blank? ? "#{self.name.to_url[0..3]}" : "#{self.sku}"
            option_values.each do | ov |
               if ov.skupartial && ov.skupartial != ""
                 variant_temp_sku = "#{variant_temp_sku}-#{ov.skupartial}"
               end
            end
            v = Variant.by_option_value_ids(option_values, self.id).first
            v = v ? v : Variant.create({
                :product => self,
                :option_values => option_values,
                :is_master => false,
                :sku => variant_temp_sku
              })
              v.update_attributes( { :sku => variant_temp_sku, :price => v.calculate_price(self.price), :position => index, :updated => true, :weight => self.master.weight, :height => self.master.height, :width => self.master.width, :depth => self.master.depth } )
          end
        end
      end
      Variant.update_all ['updated = ?, deleted_at = ?', true, Time.now() ], ['product_id = ? AND updated = ? AND is_master = ?', self.id, false, false]
      self.reload
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
