Rails.application.routes.draw do
  resources :products do
      member do
        get :update_price
      end
  end
  
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
