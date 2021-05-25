Rails.application.routes.draw do
  resources :authors
  resources :books

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  post 'books/:id/bind', action: :bind, controller: 'books'
end
