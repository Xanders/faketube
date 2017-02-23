Rails.application.routes.draw do
  root to: 'videos#index'
  post '/', to: 'videos#create'
  get '/sa:id', to: 'videos#show'
  patch '/sa:id', to: 'videos#update'
end