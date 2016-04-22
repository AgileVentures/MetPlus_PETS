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
       ActionMailer::Base.deliveries.clear
       @jobseeker_hash = FactoryGirl.attributes_for(:job_seeker).
              merge(FactoryGirl.attributes_for(:user)).
              merge(FactoryGirl.attributes_for(:job_seeker_status))
       post :create, job_seeker: @jobseeker_hash
     end

     it 'sets flash message' do
        expect(flash[:notice]).to eq "A message with a confirmation and link has been sent to your email address. Please follow the link to activate your account."
     end

     it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
     end
     it 'redirects to root page' do
       expect(response).to redirect_to(root_path)
     end
     describe "confirmation email" do
       # Include email_spec modules here, not in rails_helper because they
       # conflict with the capybara-email#open_email method which lets us
       # call current_email.click_link below.
       # Re: https://github.com/dockyard/capybara-email/issues/34#issuecomment-49528389
       include EmailSpec::Helpers
       include EmailSpec::Matchers

       # open the most recent email sent to user_email
       subject { open_email(@jobseeker_hash[:email]) }

       # Verify email details
       it { is_expected.to deliver_to(@jobseeker_hash[:email]) }
       it { is_expected.to have_body_text(/Welcome #{@jobseeker_hash[:first_name]} #{@jobseeker_hash[:last_name]}!/) }
       it { is_expected.to have_body_text(/You can confirm your account/) }
       it { is_expected.to have_body_text(/users\/confirmation\?confirmation/) }
       it { is_expected.to have_subject(/Confirmation instructions/) }
     end
    end

    context "valid attributes and resume file upload" do
     before(:each) do
       stub_request(:post, CruncherService.service_url + '/authenticate').
          to_return(body: "{\"token\": \"12345\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

       stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

       ActionMailer::Base.deliveries.clear
       @jobseeker_hash = FactoryGirl.attributes_for(:job_seeker,
              resume: fixture_file_upload('files/Janitor-Resume.doc')).
              merge(FactoryGirl.attributes_for(:user)).
              merge(FactoryGirl.attributes_for(:job_seeker_status))
     end

     it 'saves job seeker' do
       expect{ post :create, job_seeker: @jobseeker_hash }.
          to change(JobSeeker, :count).by(+1)
     end
     it 'saves resume record' do
       expect{ post :create, job_seeker: @jobseeker_hash }.
          to change(Resume, :count).by(+1)
     end
    end

    context 'invalid attributes' do
     before(:each) do
       @jobseeker = FactoryGirl.create(:job_seeker)
       @user = FactoryGirl.create(:user)
       @jobseekerstatus = FactoryGirl.create(:job_seeker_status)
       @jobseeker.assign_attributes(year_of_birth: '198')
       @user.assign_attributes(first_name: 'John', last_name: 'Smith',
                               phone: '890-789-9087')
       @jobseekerstatus.assign_attributes(description: 'MyText')
       @jobseeker.valid?
       jobseeker1_hash = FactoryGirl.attributes_for(:job_seeker,
            year_of_birth: '198',
            resume: fixture_file_upload('files/Janitor-Resume.doc')).
            merge(FactoryGirl.attributes_for(:user, first_name: 'John',
                   last_name: 'Smith', phone: '890-789-9087')).
            merge(FactoryGirl.attributes_for(:job_seeker_status,
                   value=nil, description:'MyText'))
       post :create, job_seeker: jobseeker1_hash

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
   context "valid attributes and initial résumé upload" do
     before(:each) do

       stub_request(:post, CruncherService.service_url + '/authenticate').
          to_return(body: "{\"token\": \"12345\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

       stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

       @jobseeker =  FactoryGirl.create(:job_seeker)
     end

     it 'sets flash message' do
        patch :update, id: @jobseeker,
            job_seeker: FactoryGirl.attributes_for(:job_seeker,
                resume: fixture_file_upload('files/Janitor-Resume.doc')).
            merge(FactoryGirl.attributes_for(:job_seeker_status))
        expect(flash[:notice]).to eq "Jobseeker was updated successfully."
     end
     it 'returns redirect status' do
        patch :update, id: @jobseeker,
            job_seeker: FactoryGirl.attributes_for(:job_seeker,
                resume: fixture_file_upload('files/Janitor-Resume.doc')).
            merge(FactoryGirl.attributes_for(:job_seeker_status))
        expect(response).to have_http_status(:redirect)
     end
     it 'redirects to mainpage' do
        patch :update, id: @jobseeker,
            job_seeker: FactoryGirl.attributes_for(:job_seeker,
                resume: fixture_file_upload('files/Janitor-Resume.doc')).
            merge(FactoryGirl.attributes_for(:job_seeker_status))
        expect(response).to redirect_to(root_path)
     end
     it 'saves resume record' do
       expect{ patch :update, id: @jobseeker,
            job_seeker: FactoryGirl.attributes_for(:job_seeker,
                resume: fixture_file_upload('files/Janitor-Resume.doc')).
            merge(FactoryGirl.attributes_for(:job_seeker_status)) }.
          to change(Resume, :count).by(+1)
     end
   end

   context "valid attributes and résumé file update" do
     before(:each) do

       stub_request(:post, CruncherService.service_url + '/authenticate').
          to_return(body: "{\"token\": \"12345\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

       stub_request(:post, CruncherService.service_url + '/curriculum/upload').
          to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
          :headers => {'Content-Type'=> 'application/json'})

       @jobseeker_hash = FactoryGirl.attributes_for(:job_seeker,
              resume: fixture_file_upload('files/Janitor-Resume.doc')).
              merge(FactoryGirl.attributes_for(:user)).
              merge(FactoryGirl.attributes_for(:job_seeker_status))

       post :create, job_seeker: @jobseeker_hash

       @jobseeker = JobSeeker.find(1)

       patch :update, id: @jobseeker,
            job_seeker: FactoryGirl.attributes_for(:job_seeker,
                resume: fixture_file_upload('files/Admin-Assistant-Resume.pdf')).
            merge(FactoryGirl.attributes_for(:job_seeker_status))

       @jobseeker.reload
     end

     it 'updates resume record' do
       expect(@jobseeker.resumes[0].file_name).
              to eq 'Admin-Assistant-Resume.pdf'
     end
     it 'sets flash message' do
       expect(flash[:notice]).to eq "Jobseeker was updated successfully."
     end
   end

   context "valid attributes without password change" do
     before(:each) do
       @jobseeker =  FactoryGirl.create(:job_seeker)
       @jobseekerstatus =  FactoryGirl.create(:job_seeker_status)
       @jobseeker.valid?
       @password = @jobseeker.encrypted_password
       patch :update, job_seeker:FactoryGirl.attributes_for(:job_seeker, year_of_birth: '1980',
                                                            first_name: 'John', last_name: 'Smith',
                                                            password: '', password_confirmation: '',
                                                            phone: '780-890-8976',
                                                            job_seeker_status: @jobseekerstatus),
             id:@jobseeker
       @jobseeker.reload
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
     it 'sets a jobseeker status' do
        expect(@jobseekerstatus.value) == ("Employedlooking")
     end
     it 'dont change password' do
        expect(@jobseeker.encrypted_password).to eq (@password)
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
      stub_request(:post, CruncherService.service_url + '/authenticate').
         to_return(body: "{\"token\": \"12345\"}", status: 200,
         :headers => {'Content-Type'=> 'application/json'})

      stub_request(:post, CruncherService.service_url + '/curriculum/upload').
         to_return(body: "{\"resultCode\":\"SUCCESS\"}", status: 200,
         :headers => {'Content-Type'=> 'application/json'})

      @jobseeker_hash = FactoryGirl.attributes_for(:job_seeker,
             resume: fixture_file_upload('files/Janitor-Resume.doc')).
             merge(FactoryGirl.attributes_for(:user)).
             merge(FactoryGirl.attributes_for(:job_seeker_status))

      post :create, job_seeker: @jobseeker_hash

      @jobseeker = JobSeeker.find(1)

      get :edit, id: @jobseeker
    end

    it 'assigns jobseeker and current_resume for view' do
      expect(assigns(:jobseeker)).to eq @jobseeker
      expect(assigns(:current_resume)).to eq @jobseeker.resumes[0]
    end
    it "renders edit template" do
      expect(response).to render_template 'edit'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #home" do
    before(:each) do
      @jobseeker = FactoryGirl.create(:job_seeker)
      get :home, id: @jobseeker
    end

    it "renders homepage template" do
      expect(response).to render_template 'home'
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns jobs posted since last login" do
      @newjob = FactoryGirl.create(:job)
      @newjob.assign_attributes(created_at: Time.now)
      @oldjob = FactoryGirl.create(:job)
      @oldjob.update_attributes(created_at: Time.now - 2.weeks)
      @jobseeker.assign_attributes(last_sign_in_at: (Time.now - 1.week))
      expect(Job.new_jobs(@jobseeker.last_sign_in_at)).to include(@newjob)
      expect(Job.new_jobs(@jobseeker.last_sign_in_at)).not_to include(@oldjob)
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

  describe "DELETE #destroy" do
    before(:each) do
      @jobseeker = FactoryGirl.create(:job_seeker)
      delete :destroy, id: @jobseeker
    end
    it "sets flash message" do
        expect(flash[:notice]).to eq "Jobseeker was deleted successfully."
    end
    it "returns redirect status" do
       expect(response).to have_http_status(:redirect)
    end
  end
end
