Rails.application.routes.draw do
  namespace :admin do
    root "dashboard#show"

    resource :dashboard, only: :show
    resources :job_logs, only: %i[ index show ]
    resource :settings, only: %i[ show update ]
    resources :templates
  end

  resource :registration, only: %i[ new create ]
  resource :session, only: %i[ new create destroy ]
  resources :passwords, only: %i[ new create edit update ], param: :token

  resources :resumes do
    member do
      get :download
      post :export
    end

    resources :sections, only: %i[ create update destroy ] do
      member do
        patch :move
      end

      resources :entries, only: %i[ create update destroy ] do
        member do
          patch :move
          post :improve
        end
      end
    end
  end

  root "home#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

end
