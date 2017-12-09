require 'rails_helper'

RSpec.describe ApplicationPolicy do
  subject { described_class }
  let(:js) { FactoryBot.create(:job_seeker) }
  [%i[index? not], %i[create? not], %i[new? not], %i[update? not],
   %i[edit? not], %i[destroy? not], [:allow?]].each do |method, not_allow|
    permissions method do
      it "does #{not_allow} allow #{method} on application" do
        if not_allow
          expect(ApplicationPolicy).not_to permit
        else
          expect(ApplicationPolicy).to permit
        end
      end
    end
  end
end
