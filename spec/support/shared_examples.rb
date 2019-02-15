RSpec.shared_examples 'unauthorized request' do
  before :each do
    warden.set_user user
    request
  end

  it 'returns http unauthorized' do
    expect(response).to have_http_status(302)
  end

  it 'redirects to the home page' do
    expect(request).to redirect_to(root_path)
  end

  it 'sets the flash' do
    expect(flash[:alert]).to match(/^You are not authorized to/)
  end
end

RSpec.shared_examples 'unauthorized XHR request' do
  before :each do
    warden.set_user user
    request
  end

  it 'returns http unauthorized' do
    expect(response).to have_http_status(403)
  end

  it 'check content' do
    expect(response.body).to eq(
      { message: 'You are not authorized to perform this action.' }.to_json
    )
  end
end

RSpec.shared_examples 'unauthenticated request' do
  before do
    request
  end

  it 'redirects to the home page' do
    expect(response).to redirect_to(root_path)
  end

  it 'sets the flash' do
    expect(flash[:alert]).to match(/You need to login to/)
  end
end

RSpec.shared_examples 'unauthenticated XHR request' do
  before do
    request
  end

  it 'returns http unauthorized' do
    expect(response).to have_http_status(401)
  end

  it 'check content' do
    expect(response.body).to eq(
      { message: 'You need to login to perform this action.' }.to_json
    )
  end
end

module Helpers
  def assign_role(role)
    let(:agency) { FactoryBot.create(:agency) }
    let(:company) { FactoryBot.create(:company, agencies: [agency]) }
    case role
    when 'job_seeker'
      let(:person) { FactoryBot.create(:job_seeker) }
    when 'company_person', 'company_admin', 'company_contact'
      let(:person) { FactoryBot.send(:create, role.to_sym, company: company) }
    when 'agency_person', 'job_developer', 'case_manager', 'agency_admin'
      let(:person) { FactoryBot.send(:create, role.to_sym, agency: agency) }
    else
      let(:person) { nil }
    end
  end
end
RSpec.configure { |c| c.extend Helpers }

RSpec.shared_examples 'unauthorized' do |role|
  assign_role(role)
  before :each do
    warden.set_user person
    request
  end
  it { expect(response).to have_http_status(:redirect) }
  it 'sets flash[:alert] message' do
    expect(flash[:alert]).to match('You are not authorized to')
      .or eq('You need to login to perform this action.')
  end
end

RSpec.shared_examples 'unauthorized XHR' do |role|
  assign_role(role)
  before :each do
    warden.set_user person
    request
  end

  it 'returns http unauthorized' do
    expect(response).to have_http_status(403)
  end

  it 'check content' do
    expect(response.body).to match(/You are not authorized to/)
  end
end

RSpec.shared_examples 'return success and render' do |action|
  it { expect(response).to have_http_status(:success) }
  it { expect(response).to render_template action.to_s }
end
