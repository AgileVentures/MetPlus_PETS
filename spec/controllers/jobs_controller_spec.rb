require 'rails_helper'

RSpec.describe JobsController, type: :controller do

  before(:example) do

      @company_person = FactoryGirl.create(:company_person)
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in @company_person
      @job =  FactoryGirl.create(:job)
      @job_2 = FactoryGirl.create(:job)
      @address = FactoryGirl.create(:address)
      @skill = FactoryGirl.create(:skill)
  end

  describe "permit params to create and update job" do

    it do
      params = {

        job: {
          description: @job.description,
          shift: @job.shift,
          fulltime: @job.fulltime,
          title: @job.title,
          company_id: @company_person.company.id,
          company_job_id: @job.company_job_id,
          company_person_id:  @company_person.id,
          address_id: @address.id,
          job_skills_attributes: {
            '0' => {skill_id: @skill.id, required: 1,
                  min_years: 2, max_years: 5, _destroy: false}
          }
        }
      }
      should permit(:description, :shift, :title, :company_person_id,
                    :company_job_id, :fulltime, :company_id, :address_id,
                    job_skills_attributes: [:id, :_destroy, :skill_id,
                          :required, :min_years, :max_years] ).
        for(:create, params: params).
        on(:job)
    end


    it do
      params = {
          id: @job.id,
          job: {
            description: @job.description,
            shift: @job.shift,
            fulltime: @job.fulltime,
            title: @job.title,
            company_id: @company_person.company.id,
            company_job_id: @job.company_job_id,
            company_person_id:  @company_person.id,
            address_id: @address.id,
            job_skills_attributes: {
              '0' => {skill_id: @skill.id, required: 1,
                    min_years: 2, max_years: 5, _destroy: false}
            }
        }
      }
      should permit(:description, :shift, :title, :address_id,
                    :company_job_id, :company_id, :company_person_id, :fulltime,
                    job_skills_attributes: [:id, :_destroy, :skill_id,
                          :required, :min_years, :max_years] ).
        for(:update, params: params).on(:job)
    end
  end

   describe "not permit params to create and update job" do
    it do
      params = {

          job: {
            description: @job.description,
            shift: @job.shift,
            fulltime: @job.fulltime,
            title: @job.title,
            company_id: @company_person.company.id,
            company_job_id: @job.company_job_id,
            company_person_id:  @company_person.id,
            address_id: @address.id
        }
      }
      should_not permit(:description, :shift, :title, :company_person_id,
                        :company_job_id, :company_id, :fulltime, :address_id, :name).
        for(:create, params: params).
        on(:job)
    end


    it do
      params = {
        id: @job.id,
        job: {
          description: @job.description,
          shift: @job.shift,
          fulltime: @job.fulltime,
          title: @job.title,
          company_id: @company_person.company.id,
          company_job_id: @job.company_job_id,
          company_person_id:  @company_person.id,
          address_id: @address.id


        }
      }
      should_not permit(:description, :shift, :title,:company_person_id,
                        :company_job_id, :company_id, :fulltime,:address_id, :name).
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
    before(:example) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in FactoryGirl.create(:user)
    end

    it do
      expect(subject.current_user).to_not eq(nil)
    end

    it"should not post job" do
      request.env["HTTP_REFERER"] = '/'
      get :new
      redirect_to '/'
      should set_flash.to( "Sorry, You are not permitted to post, edit or delete a job!")
    end
  end

  describe "authorized user" do
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

  describe 'GET #list_search_jobs' do

    let(:job1) { FactoryGirl.create(:job,
                      title: 'Customer Manager',
                      description: 'Provide resposive customer service') }

    let(:job2) { FactoryGirl.create(:job) }

    let!(:job_skill1) { FactoryGirl.create(:job_skill, job: job1) }
    let!(:job_skill2) { FactoryGirl.create(:job_skill, job: job2,
                        skill: FactoryGirl.create(:skill, name: 'New Skill')) }

    before(:each) do
      get :list_search_jobs,
          {q: {'title_cont_any': 'customer manager',
               'description_cont_any': 'responsive service'}}
    end

    it 'returns success status' do
      expect(response).to have_http_status(:ok)
    end

    it "renders 'list_search_jobs' template" do
      expect(response).to render_template('list_search_jobs')
    end

    it 'assigns title words for view' do
      expect(assigns(:title_words)).
            to match ['customer', 'manager']
    end

    it 'assigns description words for view' do
      expect(assigns(:description_words)).
            to match ['responsive', 'service']
    end

    it 'assigns matching job' do
      expect(assigns(:jobs)[0]).to eq job1
    end

    it 'does not assign non-matching job' do
      expect(assigns(:jobs)[0]).to_not eq job2
    end

  end

  describe 'GET #edit authorized user' do

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

    it "has 2 jobs and 0 job_skills at the start" do
      expect(Job.count).to eq(2)
      expect(JobSkill.count).to eq(0)
    end

    it 'redirects to index, increase job and job_skills by 1' do

      @skill = FactoryGirl.create(:skill, name: 'Expert at chess')

      post :create, :job => {:title => "Ruby on Rails",
                             :fulltime => true,
                             description: "passionate",
                             company_id: '3',
                             address_id: '2',
                             company_person_id: 3,
                             :shift => "Evening",
                             company_job_id: "WERRR123",
                             job_skills_attributes: {
                               '0' => {skill_id: @skill.id,
                                       required: 1, min_years: 2,
                                       max_years: 5, _destroy: false}} }

      expect(response).to redirect_to(:action => 'index')
      should set_flash
      expect(Job.count).to eq(3)
      expect(JobSkill.count).to eq(1)
      expect(response.status).to  eq(302)
    end

    it 'unsuccessful POST #create' do
      post :create, :job => {:title => "  ", :fulltime => true,
                             description: "passionate",
                             company_id: '3',
                             :shift => "Evening", company_job_id: "WERRR123" }
      expect(response).to render_template('new')
      expect(Job.count).to eq(2)
      expect(response.status).to  eq(200)
    end
  end

  describe 'PATCH #update' do

    let(:skill)     { FactoryGirl.create(:skill, name: 'test skill') }
    let!(:job_skill) { FactoryGirl.create(:job_skill, skill: skill)}

    it 'has 3 jobs and 1 job_skill at the start' do
      expect(Job.count).to eq(3)
      expect(JobSkill.count).to eq(1)
    end

    it 'add job_skill: redirects to show, increase job_skills by 1' do

      patch :update, id: @job.id ,
                  :job => {title: "Ruby on Rails",
                           fulltime: true,
                           description: "passionate",
                           shift: "Evening",
                           company_job_id: "WERRR123",
                           job_skills_attributes: {
                               '0' => {skill_id: @skill.id,
                                       required: 1, min_years: 2,
                                       max_years: 5, _destroy: false}} }

      expect(response).to redirect_to(:action => 'show')
      should set_flash
      expect(Job.count).to eq(3)
      expect(JobSkill.count).to eq(2)
      expect(response.status).to  eq(302)
     end


     it 'remove job_skill: redirects to show, decrease job_skills by 1' do

       expect(JobSkill.count).to eq(1)

       patch :update, id: job_skill.job.id ,
            :job => job_skill.job.attributes.
                 merge(job_skills_attributes: {'0' =>
                    {id: job_skill.id.to_s, _destroy: '1'}})

       expect(response).to redirect_to(:action => 'show')
       should set_flash
       expect(JobSkill.count).to eq(0)
       expect(response.status).to  eq(302)
      end

     it 'unsuccessful PATCH' do
      patch :update, id: @job.id , :job => {:title => " ",
                             :fulltime => true, description: "passionate",
                             company_id: '3',
                             :shift => "Evening", company_job_id: "WERRR123"}

      expect(response).to render_template('edit')
      expect(Job.count).to eq(3)
      expect(response.status).to  eq(200)
     end
  end

  describe 'DELETE #destroy' do
    let!(:skill)     { FactoryGirl.create(:skill, name: 'test skill') }
    let!(:job_skill) { FactoryGirl.create(:job_skill, skill: skill) }

    it 'destroys job and associated job_skill' do
      expect { delete :destroy, :id => job_skill.job.id }.
        to change(Job, :count).by -1
    end

  end

  describe 'DELETE #destroy sad path, for different company_person ' do

    before(:example){ delete :destroy, :id => @job.id}

    it "is a success" do
      expect(response).to have_http_status(302)
    end

    it "renders 'delete' template" do
      expect(response).not_to render_template(' ')
    end

    it { should set_flash }


    before(:example) do
      sign_out @company_person
      @company_person = FactoryGirl.create(:company_person)
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in @company_person.acting_as
    end

    before(:example){ delete :destroy, :id => @job_2.id}

    it "is a success" do
      expect(response).to have_http_status(302)
    end

    it "renders 'delete' template" do
      expect(response).not_to render_template(' ')
    end

    it do
     should set_flash.to("Sorry, you can't edit or delete #{@job.company.name} job!")
    end

  end


  describe 'DELETE #destroy sad path, jobseeker' do

    before(:example){ delete :destroy, :id => @job.id}

    it "is a success" do
      expect(response).to have_http_status(302)
    end

    it "renders 'delete' template" do
      expect(response).not_to render_template(' ')
    end

    it { should set_flash }


    before(:example) do
      sign_out @company_person
      @job_seeker = FactoryGirl.create(:job_seeker)
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in @job_seeker.acting_as
    end

    before(:example){ delete :destroy, :id => @job_2.id}

    it "is a success" do
      expect(response).to have_http_status(302)
    end

    it "renders 'delete' template" do
      expect(response).not_to render_template(' ')
    end

    it do
     should set_flash.to("Sorry, You are not permitted to post, edit or delete a job!" )
    end

  end

  describe 'successful POST #create' do

    before(:example) do
      sign_out @company_person
      agency = FactoryGirl.create(:agency)
      @job_developer = FactoryGirl.create(:job_developer, :agency => agency)
      @request.env["devise.mapping"] = Devise.mappings[:user]
      FactoryGirl.create(:company)
      FactoryGirl.create(:address)
      sign_in @job_developer.acting_as
    end

    it "has 2 jobs at the start" do
      expect(Job.count).to eq(2)
    end

    it 'redirects to the jobs index and increased by 1 count' do

      post :create, :job => {:title => "Ruby on Rails",
                             :fulltime => true,
                             description: "passionate",
                             :shift => "Evening",
                             :company_id => 1,
                             :address_id => 1,
                             company_person_id: nil,
                             company_job_id: "WERRR123"}

      expect(response).to redirect_to(:action => 'index')
      should set_flash
      expect(Job.count).to eq(3)
      expect(response.status).to  eq(302)
    end

    it 'unsuccessful POST #create' do
      post :create, :job => {:title => "  ", :fulltime => true,
                             description: "passionate",
                             company_id: '3',
                             :shift => "Evening", company_job_id: "WERRR123" }
      expect(response).to render_template('new')
      expect(Job.count).to eq(2)
      expect(response.status).to  eq(200)
    end

    it "has 2 jobs at the start" do
      expect(Job.count).to eq(2)
    end

    it 'should have 2 jobs after update and redirects to the show page' do
      patch :update, id: @job.id , :job => {:title => "Ruby on Rails",
                             :fulltime => true, description: "passionate",
                             company_id: '3',
                             address_id: '2',
                             company_person_id: nil,
                             :shift => "Evening", company_job_id: "WERRR123"}

      expect(response).to redirect_to(:action => 'show')
      should set_flash
      expect(Job.count).to eq(2)
      expect(response.status).to  eq(302)

    end

    describe do
      before(:example){ delete :destroy, :id => @job.id}

      it "is a success" do
        expect(response).to have_http_status(302)
      end
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

  describe 'GET #apply' do
    let!(:job_seeker){FactoryGirl.create(:job_seeker)}
    before :each do
      agency = FactoryGirl.create(:agency)
    end
    describe 'unknown job' do
      before :each do
        allow(controller).to receive(:current_user).and_return(job_seeker)
        get :apply, {:job_id => 1000, :user_id => job_seeker.id}
      end
      it "is a redirect" do
        expect(controller.current_user).not_to be_nil
        expect(response).to have_http_status(:redirect)
      end
      it "redirected to list of jobs" do
        expect(response).to redirect_to(:action => 'index')
      end
      it 'check set flash' do
        should set_flash
        expect(flash[:alert]).to eq "Unable to find the job the user is trying to apply to."
      end
    end
    describe 'unknown job seeker' do
      before :each do
        allow(controller).to receive(:current_user).and_return(job_seeker)
        get :apply, :job_id => @job.id, :user_id => 10000
      end
      it "is a redirect" do
        expect(response).to have_http_status(:redirect)
      end
      it "redirected to the job" do
        expect(response).to redirect_to(:action => 'show', :id => @job.id)
      end
      it 'check set flash' do
        should set_flash
        expect(flash[:alert]).to eq "Unable to find the user who wants to apply."
      end
    end
    describe 'successful application' do
      before :each do
        allow(Event).to receive(:create).and_call_original
        allow(controller).to receive(:current_user).and_return(job_seeker)
        get :apply, :job_id => @job.id, :user_id => job_seeker.id
      end
      it "is a success" do
        expect(response).to have_http_status(:ok)
      end
      it "render template" do
        expect(response).to render_template('jobs/apply')
      end
      it 'check set flash' do
        should_not set_flash
      end
      it 'job should have one applicant' do
        @job.reload
        expect(@job.job_seekers).to include job_seeker
      end
      it 'creates :JS_APPLY event' do
        application = @job.job_applications[0]
        expect(Event).to have_received(:create).with(:JS_APPLY, application)
      end
    end
    describe 'error applications' do
      let!(:job) { Job.new } # no lazy load, executed right away, no need to mock
      before :each do
        expect(Job).to receive(:find_by_id).and_return(job)
        expect(job).to receive(:save!).and_raise(Exception)
        expect(job).to receive(:id).exactly(4).times.and_return(1)
        allow(controller).to receive(:current_user).and_return(job_seeker)
        get :apply, :job_id => @job.id, :user_id => job_seeker.id
      end
      it "is a redirect" do
        expect(response).to have_http_status(:redirect)
      end
      it "redirected to the job" do
        expect(response).to redirect_to(:action => 'show', :id => @job.id)
      end
      it 'check set flash' do
        should set_flash
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to eq "Unable to apply at this moment, please try again."
      end
    end
    describe 'user not logged in' do
      let!(:job) { FactoryGirl.create(:job) } # no lazy load, executed right away, no need to mock
      before :each do
        get :apply, :job_id => job.id, :user_id => job_seeker.id
      end
      it "is a redirect" do
        expect(response).to have_http_status(:redirect)
      end
      it "redirected to the job" do
        expect(response).to redirect_to(root_path)
      end
      it 'check set flash' do
        should set_flash
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to eq "You are not authorized to perform this action."
      end
    end
    describe 'logged in as company person' do
      let!(:job) { FactoryGirl.create(:job) } # no lazy load, executed right away, no need to mock
      before :each do
        company = FactoryGirl.create(:company)
        @ca = FactoryGirl.create(:company_admin, :company => company)
        allow(controller).to receive(:current_user).and_return(@ca)
        get :apply, :job_id => job.id, :user_id => job_seeker.id
      end
      it "is a redirect" do
        expect(response).to have_http_status(:redirect)
      end
      it "redirected to the job" do
        expect(response).to redirect_to(root_path)
      end
      it 'check set flash' do
        should set_flash
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to eq "You are not authorized to perform this action."
      end
    end
  end
end
