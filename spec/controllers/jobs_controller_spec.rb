require 'rails_helper'

RSpec.describe JobsController, type: :controller do
  
  describe "Route => index" do
    it { should route(:get, "/jobs")
              .to(action: :index) }
  end

  describe "Route => new" do
    it { should route(:get, "/jobs/new")
              .to(action: :new) }
  end

  describe "Route => show" do
    it { should route(:get, "/jobs/1")
              .to(action: :show, id: 1) }
  end

  describe "Route => edit" do
    it{ should route(:get, "/jobs/1")
            .to(action: :show, id: 1) }
  end

  describe 'GET #index' do
    before { get :index }
    it { should_not set_flash }
  end

  describe 'GET #edit' do
    let(:job){FactoryGirl.create(:job)}
    before { patch :edit, :id => job.id }
    it { should_not set_flash }
  end

  describe 'DELETE #destroy' do
    let(:job){ FactoryGirl.create(:job)}
    before{ delete :destroy, :id => job.id}  
    it { should set_flash }
  end

  describe 'GET #show' do
    before { get :show, :id => 2 }
    it { should_not set_flash }
  end

  describe 'POST #create' do
    before { post :create }
    xit { should set_flash }
  end

  describe 'PATCH #update' do
    let(:job){FactoryGirl.create(:job)}
    before { get :update, :id => job.id }
    xit { should set_flash }
  end
  
end
