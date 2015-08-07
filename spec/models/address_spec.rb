require 'rails_helper'

RSpec.describe Address, type: :model do
  subject { FactoryGirl.build(:address) }
  describe 'Validate state' do
    it { should_not allow_value('asd', 'asd', 'asdasdadaosijaosdmaosdinausdnaosndasd')
                        .for(:state) }
    it { should allow_value('MS', 'OH', 'AL')
                        .for(:state) }
  end
  describe 'Check states small names' do
    it {expect(Address.states_small_name.length).to be(Address.us_states.length)}
    it {expect(Address.states_small_name.length).to be > 0}
    it {expect(Address.states_small_name).to include('OH', 'AL', 'WI')}
  end
  describe 'Check states complete names' do
    it {expect(Address.states_full_name.length).to be(Address.us_states.length)}
    it {expect(Address.states_full_name.length).to be > 0}
    it {expect(Address.states_full_name).to include('New Mexico', 'Maine', 'California')}
  end
end
