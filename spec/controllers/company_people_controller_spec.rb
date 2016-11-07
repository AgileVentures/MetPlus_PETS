require 'rails_helper'
include CompanyPeopleViewer

RSpec.describe CompanyPeopleController, type: :controller do
  let(:agency)         { FactoryGirl.create(:agency, name: 'Metplus') }
  let(:another_agency) { FactoryGirl.create(:agency) }
  let(:company)        { FactoryGirl.create(:company, agencies: [agency]) }
  let!(:company_bayer) do
    FactoryGirl.create(:company, name: 'Bayer-Raynor',
                                 agencies: [another_agency])
  end
  let(:company_person) { FactoryGirl.create(:company_person, company: company) }
  let(:company_admin) { FactoryGirl.create(:company_admin, company: company) }
  let(:company_contact) { FactoryGirl.create(:company_contact, company: company) }
  let(:agency_admin)   { FactoryGirl.create(:agency_admin, agency: agency) }
  let(:job_developer)  { FactoryGirl.create(:job_developer, agency: agency) }
  let(:case_manager)   { FactoryGirl.create(:case_manager, agency: agency) }
  let(:agency_person) { FactoryGirl.create(:agency_person, agency: agency) }
  let(:ca_bayer) { FactoryGirl.create(:company_admin, company: company_bayer) }
  let(:cc_bayer) { FactoryGirl.create(:company_contact, company: company_bayer) }
  let(:admin_bayer) { FactoryGirl.create(:agency_admin, agency: another_agency) }
  let(:job_seeker) { FactoryGirl.create(:job_seeker) }

  describe 'GET #edit_profile' do
    describe 'authorized access' do
      context 'company admin' do
        before(:each) do
          @company_admin = FactoryGirl.create(:company_admin)
          sign_in @company_admin
          get :edit_profile, id: @company_admin
        end

        it 'renders edit_profile template' do
          expect(response).to render_template 'edit_profile'
        end
        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'company contact' do
        before(:each) do
          @company_contact = FactoryGirl.create(:company_contact)
          sign_in @company_contact
          get :edit_profile, id: @company_contact
        end

        it 'renders edit_profile template' do
          expect(response).to render_template 'edit_profile'
        end
        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'unauthorized access' do
      context 'not logged in' do
        context 'company_admin' do
          let(:request) { get :edit_profile, id: company_admin }
          it_behaves_like 'unauthenticated request'
        end
        context 'company_contact' do
          let(:request) { get :edit_profile, id: company_contact }
          it_behaves_like 'unauthenticated request'
        end
      end

      context 'Agency people' do
        let(:request) { get :edit_profile, id: company_person }

        it_behaves_like 'unauthorized request' do
          let(:user) { agency_admin }
        end
        it_behaves_like 'unauthorized request' do
          let(:user) { job_developer }
        end
        it_behaves_like 'unauthorized request' do
          let(:user) { case_manager }
        end
      end

      context 'Job Seeker' do
        let(:request) { get :edit_profile, id: company_person }

        it_behaves_like 'unauthorized request' do
          let(:user) { job_seeker }
        end
      end

      context 'Company admin' do
        let(:request) { get :edit_profile, id: company_contact }

        it_behaves_like 'unauthorized request' do
          let(:user) { company_admin }
        end
      end

      context 'Company contact' do
        let(:request) { get :edit_profile, id: company_admin }
        it_behaves_like 'unauthorized request' do
          let(:user) { company_contact }
        end
      end
    end
  end

  describe 'GET #home' do
    describe 'authorized access' do
      before(:each) do
        sign_in company_person
        get :home, id: company_person
      end

      it 'instance vars for view' do
        expect(assigns(:company)).to eq company_person.company
        expect(assigns(:task_type)).to eq 'mine-open'
        expect(assigns(:company_all)).to eq 'company-all'
        expect(assigns(:company_new)).to eq 'company-new'
        expect(assigns(:company_closed)).to eq 'company-closed'
        expect(assigns(:job_type)).to eq 'my-company-all'
        expect(assigns(:people_type)).to eq 'my-company-all'
      end
      it 'renders edit_profile template' do
        expect(response).to render_template 'home'
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    describe 'unauthorized access' do
      let(:request) { get :home, id: company_person }

      context 'job developer' do
        it_behaves_like 'unauthorized request' do
          let(:user) { job_developer }
        end
      end

      context 'case manager' do
        it_behaves_like 'unauthorized request' do
          let(:user) { case_manager }
        end
      end

      context 'agency admin not related to the company' do
        it_behaves_like 'unauthorized request' do
          let(:user) { admin_bayer }
        end
      end

      context 'company people not related to the company' do
        it_behaves_like 'unauthorized request' do
          let(:user) { cc_bayer }
        end

        it_behaves_like 'unauthorized request' do
          let(:user) { ca_bayer }
        end
      end

      context 'job seeker' do
        let(:user) { job_seeker }
      end
    end
  end

  describe 'PATCH #update_profile' do
    describe 'authorized access' do
      context 'valid attributes' do
        before(:each) do
          sign_in company_person
          company_person.company_roles <<
            FactoryGirl.create(:company_role, role: CompanyRole::ROLE[:CA])
          company_person.save
          patch :update_profile, id: company_person, company_person: FactoryGirl.attributes_for(:user)
        end

        it 'sets flash message' do
          expect(flash[:notice]).to eq 'Your profile was updated successfully.'
        end
        it 'returns redirect status' do
          expect(response).to have_http_status(:redirect)
        end
        it 'redirects to company person home page' do
          expect(response).to redirect_to company_person
        end
      end
      context 'valid attributes without password change' do
        before(:each) do
          @company_person = FactoryGirl.create(:company_admin,
                                               password: 'testing.....',
                                               password_confirmation: 'testing.....')
          @password = @company_person.encrypted_password
          sign_in @company_person
          patch :update_profile, company_person: FactoryGirl.attributes_for(:company_person,
                                                                            first_name: 'John',
                                                                            last_name: 'Smith',
                                                                            phone: '780-890-8976',
                                                                            title: 'Line Manager',
                                                                            password: '',
                                                                            password_confirmation: ''),
                                 id: @company_person
          @company_person.reload
        end
        it 'sets a title' do
          expect(@company_person.title).to eq 'Line Manager'
        end
        it 'sets a firstname' do
          expect(@company_person.first_name).to eq 'John'
        end
        it 'sets a lastname' do
          expect(@company_person.last_name).to eq 'Smith'
        end
        it 'dont change password' do
          expect(@company_person.encrypted_password).to eq @password
        end
        it 'sets flash message' do
          expect(flash[:notice]).to eq 'Your profile was updated successfully.'
        end
        it 'returns redirect status' do
          expect(response).to have_http_status(:redirect)
        end
        it 'redirects to company person home page' do
          expect(response).to redirect_to @company_person
        end
      end
    end

    describe 'unauthorized access' do
      context 'not logged in' do
        context 'company_admin' do
          let(:request) { patch :update_profile, id: company_admin }
          it_behaves_like 'unauthenticated request'
        end
        context 'company_contact' do
          let(:request) { patch :update_profile, id: company_contact }
          it_behaves_like 'unauthenticated request'
        end
      end

      context 'Agency people' do
        context 'company_admin' do
          let(:request) { patch :update_profile, id: company_admin }
          it_behaves_like 'unauthorized request' do
            let(:user) { agency_admin }
          end
          it_behaves_like 'unauthorized request' do
            let(:user) { job_developer }
          end
          it_behaves_like 'unauthorized request' do
            let(:user) { case_manager }
          end
        end

        context 'company_contact' do
          let(:request) { patch :update_profile, id: company_contact }
          it_behaves_like 'unauthorized request' do
            let(:user) { agency_admin }
          end
          it_behaves_like 'unauthorized request' do
            let(:user) { job_developer }
          end
          it_behaves_like 'unauthorized request' do
            let(:user) { case_manager }
          end
        end
      end

      context 'Job Seeker' do
        context 'Company admin' do
          let(:request) { patch :update_profile, id: company_admin }

          it_behaves_like 'unauthorized request' do
            let(:user) { job_seeker }
          end
        end

        context 'Company contact' do
          let(:request) { patch :update_profile, id: company_contact }

          it_behaves_like 'unauthorized request' do
            let(:user) { job_seeker }
          end
        end
      end

      context 'Company admin' do
        let(:request) { patch :update_profile, id: company_contact }
        it_behaves_like 'unauthorized request' do
          let(:user) { company_admin }
        end
      end

      context 'Company contact' do
        let(:request) { patch :update_profile, id: company_admin }
        it_behaves_like 'unauthorized request' do
          let(:user) { company_contact }
        end
      end
    end
  end

  describe 'GET #show' do
    describe 'authorized access' do
      before(:each) do
        sign_in company_admin
        get :show, id: company_admin
      end

      it 'renders show template' do
        expect(response).to render_template 'show'
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET #edit' do
    describe 'authorized access' do
      before(:each) do
        sign_in company_admin
        get :edit, id: company_admin
      end

      it 'renders show template' do
        expect(response).to render_template 'edit'
      end
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'PATCH #destroy' do
    describe 'authorized access' do
      before(:each) do
        sign_in company_admin
        patch :destroy, id: company_person
      end

      it 'sets flash message' do
        expect(flash[:notice]).to eq "Person '#{assigns(:company_person).full_name(last_name_first: false)}' deleted."
      end
      it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
      end
      it 'redirects to current_user home page' do
        expect(response).to redirect_to home_company_person_path(assigns('current_user').id)
      end
    end
  end

  describe 'PATCH #update' do
    context 'valid roles' do
      before(:each) do
        updated_fields = company_admin.attributes.
          merge(company_admin.user.attributes)
        sign_in company_admin
        patch :update, id: company_admin, company_person: updated_fields
      end

      it 'sets flash message' do
        expect(flash[:notice]).to eq 'Company person was successfully updated.'
      end
      it 'returns redirect status' do
        expect(response).to have_http_status(:redirect)
      end
      it 'redirects to company person page' do
        expect(response).to redirect_to company_admin
      end
    end

    context 'invalid roles' do
      before(:each) do
        updated_fields = company_admin.attributes.
          merge(company_admin.user.attributes)
        updated_fields[:company_role_ids] = []
        sign_in company_admin
        patch :update, id: company_admin, company_person: updated_fields
      end

      it 'adds sole company admin error to error hash' do
        expect(assigns(:company_person).errors[:company_admin]).
          to include('cannot be unset for sole company admin.')
      end
      it 'sets company_roles to include CA' do
        expect(assigns(:company_person).company_roles.pluck(:role)).
          to include('Company Admin')
      end
      it 'renders edit template' do
        expect(response).to render_template 'edit'
      end
    end
  end
end
