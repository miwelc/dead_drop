DeadDrop::Engine.routes.draw do
  match '/:token' => 'dead_drop#index', via: [:get], as: :pick
  match '/:token/:filename' => 'dead_drop#index', via: [:get], as: :download
end
