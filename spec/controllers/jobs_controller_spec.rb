require 'rails_helper'

RSpec.describe JobsController, type: :controller do

  before(:context) do 
    @job =  FactoryGirl.create(:job)
  end

  describe "permit params to create and update job" do 
    it do
      params = {
        job: {
          description: 'ruby',
          shift: 'Day',
          fulltime: false,
          title: 'swt',
          company_id: '3',
          company_job_id: 'RT123'
        }
      }
      should permit(:description, :shift, :title, 
                    :company_job_id, :fulltime, :company_id).
        for(:create, params: params).
        on(:job)
    end


    it do
      params = {
        id: @job.id, 
        job: {
          description: 'ruby',
          shift: 'Day',
          fulltime: false,
          title: 'swt',
          company_id: '3',
          company_job_id: 'RT123'
        }
      }
      should permit(:description, :shift, :title, 
                    :company_job_id, :company_id, :fulltime).
        for(:update, params: params).
        on(:job)
    end
  end

   describe "not permit params to create and update job" do 
    it do
      params = {
        job: {
          description: 'ruby',
          shift: 'Day',
          fulltime: false,
          title: 'swt',
          company_id: '3',
          company_job_id: 'RT123'
        }
      }
      should_not permit(:description, :shift, :title, 
                        :company_job_id, :company_id, :fulltime, :name).
        for(:create, params: params).
        on(:job)
    end


    it do
      params = {
        id: @job.id, 
        job: {
          description: 'ruby',
          shift: 'Day',
          fulltime: false,
          title: 'swt',
           company_id: '3',
          company_job_id: 'RT123'
        }
      }
      should_not permit(:description, :shift, :title, 
                        :company_job_id, :company_id, :fulltime, :name).
        for(:update, params: params).
        on(:job)
    end
  end

  describe "Route => index" do
    it { should route(:get, "/jobs")
      .to(action: :index) }            
  end

  describe "Route => index, sad path" do
    it { should_not route(:get, "/jobs/new")
      .to(action: :index) }            
  end

  describe "unauthorized user  " do
    before(:each) do 
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in FactoryGirl.create(:user)
    end

    it do 
      expect(subject.current_user).to_not eq(nil)
    end

    it"shoud not post job" do 
      request.env["HTTP_REFERER"] = '/'
      get :new 
      redirect_to '/'
      should set_flash.to("Sorry, You are not allowed to post or edit a job!") 
    end
  end

  describe "authorized user" do

    before do 
      company_person = FactoryGirl.create(:company_person) 
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in company_person.acting_as 
    end

    it do 
      expect(subject.current_user).to_not eq(nil)
    end

    it do 
       get :new
       expect(response).to have_http_status(200)
       expect(response).to render_template('new')
       should_not set_flash 
    end

  end

  describe "Route => new, sad path" do
    it { should_not route(:get, "/jobs")
              .to(action: :new) }
  end

  describe "Route => show" do
    it { should route(:get, "/jobs/1")
              .to(action: :show, id: 1) }
  end

  describe "Route => show, sad path" do
    it { should_not route(:get, "/jobs/new")
              .to(action: :show, id: 1) }
  end

  describe "Route => edit" do
    it{ should route(:get, "/jobs/1/edit")
            .to(action: :edit, id: 1) }
  end

  describe "Route => edit, sad path" do
    it{ should_not route(:get, "/jobs/1/edit")
            .to(action: :show, id: 1) }
  end

  describe "Route => edit, sad path" do
    it{ should route(:get, "/jobs/new")
            .to(action: :new) }
  end

  describe 'GET #index' do
    before(:example){ get :index }

    it "is a success" do 
      expect(response).to have_http_status(:ok)
    end

    it "renders 'index' template" do
      expect(response).to render_template('index')
    end

    it { should_not set_flash }

  end

  describe 'GET #edit authorized user' do
     before do 
      company_person = FactoryGirl.create(:company_person) 
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in company_person.acting_as
    end
  
    before(:example){ patch :edit, :id => @job.id }

    it "is a success" do 
      expect(subject.current_user).to_not eq(nil)
      expect(response).to have_http_status(:ok)
    end

    it "renders 'edit' template" do
      expect(response).to render_template('edit')
    end

    it { should_not set_flash }
  end

  describe 'GET #edit unauthorized user' do
     before do 
      request.env["HTTP_REFERER"] = '/jobs'
      user = FactoryGirl.create(:user) 
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end
  
    before(:example){ patch :edit, :id => @job.id }

    it "redirect to jobs" do 
      expect(subject.current_user).to_not eq(nil)
      redirect_to '/jobs'
      should set_flash
    end 
  end

  describe 'DELETE #destroy' do
    
    before(:example){ delete :destroy, :id => @job.id} 

    it "is a success" do 
      expect(response).to have_http_status(302)
    end

    it "renders 'delete' template" do
      expect(response).not_to render_template(' ')
    end 

    it { should set_flash }

  end

  describe 'GET #show' do
   
    before(:example) { get :show, :id => @job.id }

    it "is a success" do 
      expect(response).to have_http_status(:ok)
    end

    it "renders 'show' template" do
      expect(response).to render_template('show')
    end

    it { should_not set_flash }

  end

  describe 'successful POST #create' do

    it "has 1 jobs at the start" do 
      expect(Job.count).to eq(1)
    end

    it 'redirects to the jobs index and increased by 1 count' do
      post :create, :job => {:title => "Ruby on Rails", 
                             :fulltime => true, description: "passionate", 
                             company_id: '3',
                             :shift => "Evening", company_job_id: "WERRR123"}
      expect(response).to redirect_to(:action => 'index')
      should set_flash 
      expect(Job.count).to eq(2)
      expect(response.status).to  eq(302) 
    end 

    it 'unsuccessful POST #create' do
      post :create, :job => {:title => "  ", :fulltime => true,
                             description: "passionate",
                             company_id: '3',
                             :shift => "Evening", company_job_id: "WERRR123" }
      expect(response).to render_template('new')
      expect(Job.count).to eq(1)
      expect(response.status).to  eq(200) 
    end 
  end

  describe 'PATCh #update' do

     it "has 1 jobs at the start" do 
      expect(Job.count).to eq(1)
    end

    it 'should have 1 jobs after update and redirects to the show page' do
      patch :update, id: @job.id , :job => {:title => "Ruby on Rails", 
                             :fulltime => true, description: "passionate",
                             company_id: '3',
                             :shift => "Evening", company_job_id: "WERRR123"}
     
      expect(response).to redirect_to(:action => 'show')
      should set_flash 
      expect(Job.count).to eq(1)
      expect(response.status).to  eq(302)

     end 

     it 'unsuccessful PATCH' do
      patch :update, id: @job.id , :job => {:title => " ", 
                             :fulltime => true, description: "passionate",
                             company_id: '3',
                             :shift => "Evening", company_job_id: "WERRR123"}
      
      expect(response).to render_template('edit')
      expect(Job.count).to eq(1)
      expect(response.status).to  eq(200)
     end 
  end

  describe 'GET #list' do

    before :each do
      agency = FactoryGirl.create(:agency)
      company = FactoryGirl.create(:company)
      @ca = FactoryGirl.create(:company_admin, :company => company)
      company1 = FactoryGirl.create(:company)
      @ca1 = FactoryGirl.create(:company_admin, :company => company1)
      @job.destroy
      31.times.each do |i|
        FactoryGirl.create(:job, :title => "Awesome job #{i}", :company => company, :company_person => @ca)
      end
      4.times.each do |i|
        FactoryGirl.create(:job, :title => "Awesome new job #{i}", :company => company1, :company_person => @ca1)
      end
    end

    describe 'first page' do

      before :each do
        sign_in @ca
        xhr :get, :list, :job_type => 'my-company-all'
      end

      it "is a success" do
        expect(response).to have_http_status(:ok)
      end

      it "renders 'jobs/_list_all' template" do

        expect(response).to render_template('jobs/_list_all')
      end

      it 'check job_type' do
        expect(assigns(:job_type)).to eq 'my-company-all'
      end

      it 'check jobs' do
        # Next line added to ensure the query is done and that the
        # paginate is also called
        assigns(:jobs).each do end
        expect(assigns(:jobs).all.size).to be 10
        expect(assigns(:jobs).first.title).to eq 'Awesome job 0'
        expect(assigns(:jobs).last.title).to eq 'Awesome job 9'
      end

      it { should_not set_flash }
    end
    describe 'last page' do
      before :each do
        sign_in @ca
        xhr :get, :list, :job_type => 'my-company-all', :jobs_page => 4
      end

      it "is a success" do
        expect(response).to have_http_status(:ok)
      end

      it "renders 'jobs/_list_all' template" do

        expect(response).to render_template('jobs/_list_all')
      end

      it 'check job_type' do
        expect(assigns(:job_type)).to eq 'my-company-all'
      end

      it 'check jobs' do
        # Next line added to ensure the query is done and that the
        # paginate is also called
        assigns(:jobs).each do end
        expect(assigns(:jobs).first.title).to eq 'Awesome job 30'
        expect(assigns(:jobs).size).to be 1
      end

      it { should_not set_flash }
    end

    describe 'only page different company' do

      before :each do
        sign_in @ca1
        xhr :get, :list, :job_type => 'my-company-all'
      end

      it "is a success" do
        expect(response).to have_http_status(:ok)
      end

      it "renders 'jobs/_list_all' template" do

        expect(response).to render_template('jobs/_list_all')
      end

      it 'check job_type' do
        expect(assigns(:job_type)).to eq 'my-company-all'
      end

      it 'check jobs' do
        # Next line added to ensure the query is done and that the
        # paginate is also called
        assigns(:jobs).each do end
        expect(assigns(:jobs).all.size).to be 4
        expect(assigns(:jobs).first.title).to eq 'Awesome new job 0'
        expect(assigns(:jobs).last.title).to eq 'Awesome new job 3'
      end

      it { should_not set_flash }
    end
  end
end