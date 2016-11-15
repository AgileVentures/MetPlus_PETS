require 'rails_helper'

RSpec.shared_examples 'unauthorized' do
 before :each do
   warden.set_user user
   my_request
 end
 it 'returns http unauthorized' do
   expect(response).to have_http_status(302)
 end
 it 'check content' do
   expect(response).to redirect_to(root_path)
 end
 it 'sets the message' do
   expect(flash[:alert]).to match(/^You are not authorized to/)
 end
end
RSpec.shared_examples 'unauthorized all' do
  let(:company) { FactoryGirl.create(:company)}
  
  context 'company admin' do 
    it_behaves_like 'unauthorized' do
      let(:user) { FactoryGirl.create(:company_admin, company: company)}
    end
  end
   
  context 'company company contact' do 
     it_behaves_like 'unauthorized' do
       let(:user) { FactoryGirl.create(:company_contact, company: company)}
     end
   end
end

RSpec.shared_examples'unauthorized agency people and jobseeker' do
 let(:agency)  { FactoryGirl.create(:agency) }
 let(:company) { FactoryGirl.create(:company)}
  
 context 'Case manager' do 
   it_behaves_like 'unauthorized' do
     let(:user) { FactoryGirl.create(:case_manager, agency: agency)}
   end
 end
 
 context 'Job developer' do 
   it_behaves_like 'unauthorized' do
     let(:user) { FactoryGirl.create(:job_developer, agency: agency)}
   end
 end
 
 context 'Job seeker' do 
   it_behaves_like 'unauthorized' do
     let(:user) { FactoryGirl.create(:job_seeker)}
   end
 end
 
end


RSpec.describe CompaniesController, type: :controller do
  let(:agency)   { FactoryGirl.create(:agency) }
  let(:admin)  { FactoryGirl.create(:agency_admin, agency: agency)}
  let(:company)   { FactoryGirl.create(:company) }
  let(:company_admin) { FactoryGirl.create(:company_admin, company: company) }
  let(:company_contact) { FactoryGirl.create(:company_contact, company: company)} 
  let(:jd)     { FactoryGirl.create(:job_developer, agency: agency)}
  let(:cm)     { FactoryGirl.create(:case_manager, agency: agency)}
  let(:js)     { FactoryGirl.create(:job_seeker)}

  before(:each) do
    sign_in company_admin
  end

  describe "GET #show" do
    before(:each) do
      get :show, id: company
    end
    it 'assigns @company for view' do
      expect(assigns(:company)).to eq company
    end
    it 'renders show template' do
      expect(response).to render_template('show')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #edit" do

    before(:each) do
      get :edit, id: company
    end
    it 'assigns @company for form' do
      expect(assigns(:company)).to eq company
    end
    it 'renders edit template' do
      expect(response).to render_template('edit')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "DELETE #destroy" do
   
    before(:each) do
      sign_in admin
      delete :destroy, id: company
    end
   
   it "returns http success" do
      expect(response).to have_http_status(:redirect)
    end

  end

  describe 'GET #list_people' do
    
    let!(:cp1) { FactoryGirl.create(:company_admin,   company: company) }
    let!(:cp2) { FactoryGirl.create(:company_contact, company: company) }
    let!(:cp3) { FactoryGirl.create(:company_contact, company: company) }
    let!(:cp4) { FactoryGirl.create(:company_contact, company: company) }

    before(:each) do
      sign_in cp1
      xhr :get, :list_people, id: company,
                people_type: 'my-company-all'
    end
    it 'assigns @people to collection of all company people' do
      expect(assigns(:people)).to include cp1, cp2, cp3, cp4
    end
    it 'renders company_people/list_people template' do
      expect(response).to render_template('company_people/_list_people')
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
   
    let(:hash_params) do
      company.attributes.merge(addresses_attributes:
                      {'0' => attributes_for(:address)})
    end

    context 'valid attributes' do

      it 'locates the requested company' do
        patch :update, id: company, company: hash_params
        expect(assigns(:company)).to eq(company)
      end

      it 'changes the company attributes' do
        params_hash = attributes_for(:company,
          email: 'info@widgets.com', fax:'510 555-1212',
          job_email: 'humanresources@widgets.com').
          merge(addresses_attributes:
                          {'0' => attributes_for(:address),
                           '1' => attributes_for(:address) })

        patch :update, id: company, company: params_hash
        company.reload
        expect(company.email).to eq('info@widgets.com')
        expect(company.fax).to eq('510 555-1212')
        expect(company.job_email).to eq('humanresources@widgets.com')
        expect(company.addresses.count).to eq 2
      end
      it 'deletes company address' do
        hash_params[:addresses_attributes]['0']['_destroy'] = true

        patch :update, id: company, company: hash_params
        company.reload
        expect(company.addresses.count).to eq 0
      end
    end
  end
 
  describe 'action authorization' do
     context '#edit' do
       it 'authorizes company admin' do 
         allow(controller).to receive(:current_user).and_return(company_admin)
         get :edit, id: company
         expect(subject).to_not receive(:user_not_authorized)
        end
       it 'authorizes agency admin' do 
         allow(controller).to receive(:current_user).and_return(admin)
         get :edit, id: company
         expect(subject).to_not receive(:user_not_authorized)
        end
       it_behaves_like 'unauthorized agency people and jobseeker' do
          let(:my_request) {get :edit, id: company }
        end
      end
      context '#update' do
       it 'authorizes company admin' do 
         allow(controller).to receive(:current_user).and_return(company_admin)
         params_hash = attributes_for(:company,
          email: 'info@widgets.com', fax:'510 555-1212',
          job_email: 'humanresources@widgets.com').
          merge(addresses_attributes:
                          {'0' => attributes_for(:address),
                           '1' => attributes_for(:address) })

        patch :update, id: company, company: params_hash
         expect(subject).to_not receive(:user_not_authorized)
        end
        it 'authorizes agency admin' do 
         allow(controller).to receive(:current_user).and_return(admin)
         params_hash = attributes_for(:company,
         email: 'info@widgets.com', fax:'510 555-1212',
         job_email: 'humanresources@widgets.com').
          merge(addresses_attributes:
                          {'0' => attributes_for(:address),
                          '1' => attributes_for(:address) })

        patch :update, id: company, company: params_hash
         expect(subject).to_not receive(:user_not_authorized)
        end
        it_behaves_like 'unauthorized agency people and jobseeker' do
          let(:my_request) {params_hash = attributes_for(:company,
         email: 'info@widgets.com', fax:'510 555-1212',
         job_email: 'humanresources@widgets.com').
          merge(addresses_attributes:
                          {'0' => attributes_for(:address),
                          '1' => attributes_for(:address) })

        patch :update, id: company, company: params_hash }
        end
      end
      context '#show' do
       it 'authorizes company admin' do 
         allow(controller).to receive(:current_user).and_return(company_admin)
         get :show, id: company
         expect(subject).to_not receive(:user_not_authorized)
        end
        
        it 'authorizes agency admin' do 
         allow(controller).to receive(:current_user).and_return(admin)
         get :show, id: company
         expect(subject).to_not receive(:user_not_authorized)
        end
        it_behaves_like 'unauthorized agency people and jobseeker' do
          let(:my_request) {get :show, id: company }
        end
      end
      context '#destroy' do
       it 'authorizes agency admin' do 
         allow(controller).to receive(:current_user).and_return(admin)
          delete :destroy, id: company
         expect(subject).to_not receive(:user_not_authorized)
        end
        
        it_behaves_like 'unauthorized agency people and jobseeker' do
          let(:my_request) {delete :destroy, id: company }

        end
        
        it_behaves_like 'unauthorized all' do
          let(:my_request) {delete :destroy, id: company }

        end
        
      end
      context '#list-people' do
        it 'authorizes agency admin' do 
          allow(controller).to receive(:current_user).and_return(admin)
          xhr :get, :list_people, id: company,
                people_type: 'my-company-all'
          expect(subject).to_not receive(:user_not_authorized)
        end
        it 'authorizes company admin' do 
          allow(controller).to receive(:current_user).and_return(company_admin)
          xhr :get, :list_people, id: company,
                people_type: 'my-company-all'
          expect(subject).to_not receive(:user_not_authorized)
        end
        it 'authorizes company contact' do 
         allow(controller).to receive(:current_user).and_return(company_contact)
         xhr :get, :list_people, id: company,
                people_type: 'my-company-all'
         expect(subject).to_not receive(:user_not_authorized)
        end
        it 'denies access to job developer' do 
          allow(controller).to receive(:current_user).and_return(jd)
          xhr :get, :list_people, id: company,
                people_type: 'my-company-all'
          expect(response).to have_http_status 403
          expect(JSON.parse(response.body)).
            to eq({'message' =>
                "You are not authorized to view the people."}
)
        end
        it 'denies access to case manager' do 
          allow(controller).to receive(:current_user).and_return(cm)
          xhr :get, :list_people, id: company,
                people_type: 'my-company-all'
          expect(response).to have_http_status 403
          expect(JSON.parse(response.body)).
            to eq({'message' =>
                "You are not authorized to view the people."}
)
        end
        it 'denies access to job seeker' do 
          allow(controller).to receive(:current_user).and_return(js)
          xhr :get, :list_people, id: company,
                people_type: 'my-company-all'
          expect(response).to have_http_status 403
          expect(JSON.parse(response.body)).
            to eq({'message' =>
                "You are not authorized to view the people."}
)
        end
      end              
   end   
      
end
