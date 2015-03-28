module DeadDrop
  class Engine < ::Rails::Engine
    isolate_namespace DeadDrop

    initializer 'dead_drop.initialize_cache', :before => "initialize_cache" do
      DeadDrop.cache = ActiveSupport::Cache.lookup_store(DeadDrop.cache_store)
    end
  end
end
