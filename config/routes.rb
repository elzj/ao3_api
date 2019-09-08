Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  devise_for :users

  namespace :api do
    namespace :v3 do
      resources :tags
    end
  end
end
