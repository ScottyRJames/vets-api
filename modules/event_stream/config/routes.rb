# frozen_string_literal: true

EventStream::Engine.routes.draw do
  namespace :v0, defaults: { format: 'json' } do
    post 'events', to: 'events#create'
  end
end
