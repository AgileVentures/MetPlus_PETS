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
          company_job_id: 'RT123'
        }
      }
      should permit(:description, :shift, :title, 
                    :company_job_id, :fulltime).
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
          company_job_id: 'RT123'
        }
      }
      should permit(:description, :shift, :title, 
                    :company_job_id, :fulltime).
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
          company_job_id: 'RT123'
        }
      }
      should_not permit(:description, :shift, :title, 
                        :company_job_id, :fulltime, :name).
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
          company_job_id: 'RT123'
        }
      }
      should_not permit(:description, :shift, :title, 
                        :company_job_id, :fulltime, :name).
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

  describe "Route => new" do
    it { should route(:get, "/jobs/new")
              .to(action: :new) }
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

  describe 'GET #new' do
    before(:example){ get :new }

    it "is a success" do 
      expect(response).to have_http_status(:ok)
    end

    it "renders 'new' template" do
      expect(response).to render_template('new')
    end

    it { should_not set_flash }
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

  describe 'GET #edit' do
    
    before(:example){ patch :edit, :id => @job.id }

    it "is a success" do 
      expect(response).to have_http_status(:ok)
    end

    it "renders 'edit' template" do
      expect(response).to render_template('edit')
    end

    it { should_not set_flash }
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

  describe 'POST #create' do

    it "has 1 jobs at the start" do 
      expect(Job.count).to eq(1)
    end

    it 'redirects to the jobs index and increased by 1 count' do
      post :create, :job => {:title => "Ruby on Rails", 
                             :fulltime => true, description: "passionate",
                             :shift => "Evening", company_job_id: "WERRR123"}
      should set_flash 
      expect(response).to redirect_to(:action => 'index')
      expect(Job.count).to eq(2)
      expect(response.status).to  eq(302) 
    end 

    it 'unsuccessful POST' do
      post :create, :job => {:title => "  ", :fulltime => true,
                             description: "passionate",
                             :shift => "Evening", company_job_id: "WERRR123"}
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
                             :shift => "Evening", company_job_id: "WERRR123"}
     
      expect(response).to redirect_to(:action => 'show')
      should set_flash 
      expect(Job.count).to eq(1)
      expect(response.status).to  eq(302)

     end 

     it 'unsuccessful PATCH' do
      patch :update, id: @job.id , :job => {:title => " ", 
                             :fulltime => true, description: "passionate",
                             :shift => "Evening", company_job_id: "WERRR123"}
      
      expect(response).to render_template('edit')
      expect(Job.count).to eq(1)
      expect(response.status).to  eq(200)
     end 
  end
  
end