DeadDrop::Engine.routes.draw do
  match '/:token' => 'dead_drop#index', via: [:get], as: :pick
end
