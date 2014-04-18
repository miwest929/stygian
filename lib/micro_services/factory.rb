module MicroService
  class Factory
    Dir["lib/micro_services/tasks/*"].each {|f| load f}

    def self.create(name)
      Object::const_get("MicroService::#{name}")
    rescue NameError => e
      nil
    end
  end
end
