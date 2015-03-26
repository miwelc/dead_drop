Rails.application.routes.draw do

  mount DeadDrop::Engine => "/dead_drop"
end
