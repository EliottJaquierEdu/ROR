Rails.application.routes.draw do
  devise_for :people, controllers: {
    registrations: 'people/registrations',
    sessions: 'people/sessions'
  }

  root "home#index"

  concern :archivable do
    member do
      patch :archive
      patch :unarchive
    end
  end

  resources :grades, concerns: :archivable
  resources :examinations, concerns: :archivable
  resources :subjects, concerns: :archivable
  resources :courses, concerns: :archivable
  resources :rooms, concerns: :archivable
  resources :school_classes, concerns: :archivable do
    resources :students, only: [:new, :create, :destroy], controller: 'school_class_students'
  end

  resources :people, concerns: :archivable
  resources :students, controller: 'people', concerns: :archivable
  resources :teachers, controller: 'people', concerns: :archivable
  resources :deans, controller: 'people', concerns: :archivable
  resources :addresses, concerns: :archivable

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
