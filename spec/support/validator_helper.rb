module ValidatorHelper
  def test_model_class
    Class.new do
      include ActiveModel::Validations

      attr_accessor :test_attr

      def self.model_name
        ActiveModel::Name.new(self, nil, 'TestModel')
      end
    end
  end
end
