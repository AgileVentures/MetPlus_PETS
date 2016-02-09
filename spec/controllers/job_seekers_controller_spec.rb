require 'rails_helper'

RSpec.describe JobSeekersController, type: :controller do

  describe "GET #new" do
    
    it "renders new template" do
      get :new
      expect(response).to render_template 'new'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "POST #create" do
      
   context "valid attributes" do
     before(:each) do
       @jobseeker = FactoryGirl.create(:job_seeker)
       @user = FactoryGirl.create(:user)
       @jobseekerstatus = FactoryGirl.create(:job_seeker_status)
       jobseeker_hash = FactoryGirl.attributes_for(:job_seeker).merge(FactoryGirl.attributes_for(:user)).merge(FactoryGirl.attributes_for(:job_seeker_status))
       post :create, job_seeker: jobseeker_hash 
     end
        
     it 'sets flash message' do
        expect(flash[:notice]).to eq "A message with a confirmation and link has been sent to your email address. Please follow the link to activate your account."
     end
                
     it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
     end
     it 'redirects to mainpage' do
       expect(response).to redirect_to(root_path)
     end
          
   end
   context 'invalid attributes' do
     before(:each) do
       @jobseeker = FactoryGirl.create(:job_seeker)
       @user = FactoryGirl.create(:user)
       @jobseekerstatus = FactoryGirl.create(:job_seeker_status)
       @jobseeker.assign_attributes(year_of_birth: '198')
       @user.assign_attributes(first_name:'John',last_name:'Smith',phone:'890-789-9087')
       @jobseekerstatus.assign_attributes(description:'MyText')
       @jobseeker.valid?
       jobseeker1_hash = FactoryGirl.attributes_for(:job_seeker, year_of_birth: '198').merge(FactoryGirl.attributes_for(:user,first_name:'John',last_name:'Smith', phone:'890-789-9087')).merge(FactoryGirl.attributes_for(:job_seeker_status, value=nil, description:'MyText'))
       post :create, job_seeker: jobseeker1_hash 
        
     end
     it 'assigns @model_errors for error display in layout' do
       expect(assigns(:model_errors).full_messages).to eq @jobseeker.errors.full_messages
     end
     it 'renders new template' do
        expect(response).to render_template('new')
     end
     it "returns http success" do
        expect(response).to have_http_status(:success)
     end
    end
 end
  
 describe "PATCH #update" do
               
   context "valid attributes" do
     before(:each) do
       @jobseeker =  FactoryGirl.create(:job_seeker)
       @jobseekerstatus =  FactoryGirl.create(:job_seeker_status)
       patch :update, id: @jobseeker,job_seeker: FactoryGirl.attributes_for(:job_seeker).
merge(FactoryGirl.attributes_for(:job_seeker_status))
      
     end
            
     it 'sets flash message' do
        expect(flash[:notice]).to eq "Jobseeker was updated successfully."
     end
     it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
     end
     it 'redirects to mainpage' do
        expect(response).to redirect_to(root_path)
     end
    end
    
    context "valid attributes without password change" do
      before(:each) do
        @jobseeker =  FactoryGirl.create(:job_seeker)
        @user =  FactoryGirl.create(:user)
        @jobseekerstatus =  FactoryGirl.create(:job_seeker_status)
        @jobseeker.valid? 
        patch :update, job_seeker:FactoryGirl.attributes_for(:job_seeker, year_of_birth: '1980').
merge(FactoryGirl.attributes_for(:user, first_name:'John',last_name:'Smith',password:nil,password_confirmation:nil,phone:'780-890-8976')).
merge(FactoryGirl.attributes_for(:job_seeker_status,value:'Employedlooking')),id:@jobseeker
        @jobseeker.reload
        @user.reload
        @jobseekerstatus.reload
        
      end
     it 'sets a firstname' do
        expect(@jobseeker.first_name).to eq ("John")
     end
     it 'sets a lastname' do
        expect(@jobseeker.last_name).to eq ("Smith")
     end
     it 'sets a yearofbirth' do
        expect(@jobseeker.year_of_birth).to eq ("1980")
     end
     it 'sets a  value' do
        expect(@jobseekerstatus.value) == ("Employedlooking")
     end
     it 'sets flash message' do
        expect(flash[:notice]).to eq "Jobseeker was updated successfully."
     end
     it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
     end
     it 'redirects to mainpage' do
       expect(response).to redirect_to(root_path)
     end
    end

       
   context 'invalid attributes' do
     before(:each) do
       @jobseeker = FactoryGirl.create(:job_seeker)
       @jobseeker.assign_attributes(year_of_birth: '198')
       @jobseeker.valid?
       patch :update, job_seeker:FactoryGirl.attributes_for(:job_seeker, year_of_birth: '198',resume:''),id:@jobseeker
     end
     it 'assigns @model_errors for error display in layout' do
        expect(assigns(:model_errors).full_messages).to eq @jobseeker.errors.full_messages
     end
     it 'renders edit template' do
        expect(response).to render_template('edit')
     end
     it "returns http success" do
        expect(response).to have_http_status(:success)
     end
  end
 end

  describe "GET #edit" do
    before(:each) do
      @jobseeker = FactoryGirl.create(:job_seeker)
      get :edit, id: @jobseeker
    end
    
    it "renders edit template" do
      expect(response).to render_template 'edit'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #index" do
    it "renders the index template" do
      get :index
      expect(response.body).to render_template 'index'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    
  end

  describe "GET #show" do
    before(:each) do
      @jobseeker = FactoryGirl.create(:job_seeker)
      get :show, id: @jobseeker
    end
    it "it renders  the show template" do
      expect(response).to render_template 'show'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

end







  
