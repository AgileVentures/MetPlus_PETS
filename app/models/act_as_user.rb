module ActAsUser

  def self.included(base)
    base.extend(ClassMethods)
  end

  def method_missing(name, *args, &block)
    @user = User.new if @user.nil?    
    begin
      super
    rescue NoMethodError
      @user.send(name, *args, &block)
    end 
  end

  def assign_attributes(new_attributes)
    @user = User.new if @user.nil?
    model_attributes = new_attributes.select do |key, value|
      has_attribute? key
    end
    user_model_attributes = new_attributes.select do |key, value|
      @user.has_attribute? key
    end
    super(model_attributes)
    @user = User.new if user.nil?
    @user.assign_attributes(user_model_attributes)
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