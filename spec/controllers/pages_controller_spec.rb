require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe 'GET #about' do
    it 'renders the :about view' do
      get :about
      expect(response).to render_template :about
    end
  end

  describe 'GET #contact' do
    it 'renders the contact view' do
      get :contact
      expect(response).to render_template(:contact)
    end
  end
end
