module ActAsUser

  def self.included(base)
    base.extend(ClassMethods)
  end

  def method_missing(name, *args, &block)
    self.user = User.new if self.user.nil?    
    begin
      super
    rescue NoMethodError
      self.user.send(name, *args, &block)
    end 
  end

  def assign_attributes(new_attributes)
    self.user = User.new if self.user.nil?
    password = new_attributes.delete('password')
    model_attributes = new_attributes.select do |key, value|
      has_attribute? key
    end
    user_model_attributes = new_attributes.select do |key, value|
      self.user.has_attribute? key
    end
    super(model_attributes)
    self.user.assign_attributes(user_model_attributes)
    self.password = password
  end

  def is_a?(clazz)
    return true if clazz == User
    super(clazz)
  end

  def user_type
    self.class.name
  end
  
  module ClassMethods
    def method_missing(name, *args, &block)
      begin
        super
      rescue NoMethodError
        User.send(name, *args, &block)
      end
    end
  end
end