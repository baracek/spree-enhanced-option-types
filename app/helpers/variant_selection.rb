module VariantSelection
  # Returns array of arrays of ids of option values,
  # that represent all possible combinations of option _values
  # sorted by option type position in that product.
  # 
  def options_values_combinations(product)
    product.variants.map{|v| # we get all variants from product
      # then we take all option_values
      v.option_values.sort_by{|ov|
        # then sort them by position of option value in product
        ProductOptionType.find(:first, :conditions => {
            :option_type_id => ov.option_type_id,
            :product_id => product.id
          }).position
      }.map(&:id) # and get the id
    }
  end

  # checks if there's a possible combination
  def possible_combination?(all_combinations, values)
    all_combinations.any?{|combination|
      values.enum_for(:each_with_index).all?{|v, i| combination[i] == v}
    }
  end

  def find_variant_with_option_values(option_values)
    
  end
end