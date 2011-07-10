Rails.application.routes.draw do
  # Add your extension routes here
  match "/products/update_price/:id" => "products#update_price"
end
