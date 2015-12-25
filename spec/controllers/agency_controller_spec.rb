require 'rails_helper'

RSpec.describe AgencyController, type: :controller do

  describe "GET #home" do
    
    let(:agency) { FactoryGirl.create(:agency) }
    
    before :each do
      get :home, id: agency
    end
    
    it 'assigns @agency for form' do
      expect(assigns(:agency)).to eq agency
    end
    
    it 'renders home template' do
      expect(response).to render_template('home')
    end
    
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

end
