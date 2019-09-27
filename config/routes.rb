Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  devise_for :users,
             module: 'users',
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations',
               passwords: 'users/passwords'
             },
             path_names: {
               sign_in: 'login',
               sign_out: 'logout'
             }

  namespace :api do
    namespace :v3 do
      resources :drafts
      resources :pseuds
      resources :tags
      resources :works
    end
  end

  root to: 'home#index'
end
