require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe 'GET #about' do
    it 'renders the :about view' do
      get :about
      expect(response).to render_template :about
    end
  end

  describe '#contact' do
    it 'renders the contact view' do
      get :contact
      expect(response).to render_template(:contact)
    end
    it 'POST request renders contact view' do
      xhr :post, :contact
      expect(response).to render_template(:contact)
    end
    it 'shows success with valid captcha' do
      xhr :post, :contact, params: {
        full_name:'myfullname',
        surname: 'mysurname',
        email: 'myemail@email.com',
        message:'message',
        'g-recaptcha-response' => 'myresponse'
      }
      expect(response).to render_template(:contact)
    end
  end
end
