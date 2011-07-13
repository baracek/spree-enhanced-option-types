Rails.application.routes.draw do
  match "/products/update_price/:id" => "products#update_price"  
  
  namespace :admin do
    resources :products do
      resources :variants do
        collection do
          post :regenerate
        end
      end
    end
  end
end
