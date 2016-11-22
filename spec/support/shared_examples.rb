RSpec.shared_examples 'unauthorized request' do
  before :each do
    warden.set_user user
    request
  end

  it 'returns http unauthorized' do
    expect(response).to have_http_status(302)
  end

  it 'redirects to the home page' do
    expect(response).to redirect_to(root_path)
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
