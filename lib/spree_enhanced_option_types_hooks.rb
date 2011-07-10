class SpreeEnhancedOptionTypesHooks < Spree::ThemeSupport::HookListener
  replace :cart_item_description, 'hooked/cart_item_description'
  replace :product_images, 'hooked/product_images'
end