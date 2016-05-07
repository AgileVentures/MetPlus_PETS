require 'rails_helper'

class TestClass
  extend UserParameters
end

RSpec.describe UserParameters do

  describe '#handle_user_form_parameters' do
    let(:no_password)    {{:first_name => 'John', :last_name => 'Smith',
                           :password_confirmation => ''}}
    let(:empty_password) {{:first_name => 'John', :last_name => 'Smith',
                           :password => '', :password_confirmation=> ''}}
    let(:only_password_confirmation) {{:first_name => 'John', :last_name => 'Smith',
                                       :password => '', :password_confirmation => 'bammmm'}}
    let(:with_password)  {{:first_name => 'John', :last_name => 'Smith',
                           :password => 'bammm', :password_confirmation => ''}}
    it 'no password present' do
      expect(TestClass.handle_user_form_parameters no_password).to eq({:first_name => 'John',
                                                                             :last_name => 'Smith'})
    end
    it 'empty password empty confirmation' do
      expect(TestClass.handle_user_form_parameters empty_password).to eq({:first_name => 'John',
                                                                                :last_name => 'Smith'})
    end
    it 'empty password not empty confirmation' do
      expect(TestClass.handle_user_form_parameters only_password_confirmation).to eq({:first_name => 'John',
                                                                                            :last_name => 'Smith'})
    end
    it 'password present' do
      expect(TestClass.handle_user_form_parameters with_password).to eq({:first_name => 'John',
                                                                               :last_name => 'Smith',
                                                                               :password => 'bammm',
                                                                               :password_confirmation => ''})
    end
  end
end
