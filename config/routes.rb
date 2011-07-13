Rails.application.routes.draw do
  namespace :admin do
    resources :products do
      
      member do
        get :update_price
      end
      
      resources :variants do
        collection do
          post :regenerate
        end
      end
    end
  end
end
