module MicroService
  class Factory
    def self.create(name)
      Object::const_get(name)
    rescue NameError => e
      nil
    end
  end
end
