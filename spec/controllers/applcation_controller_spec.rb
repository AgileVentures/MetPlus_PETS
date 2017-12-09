require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let!(:agency_admin) { FactoryBot.create(:agency_admin) }
  let!(:company_admin) { FactoryBot.create(:company_admin) }
  let!(:job_seeker) { FactoryBot.create(:job_seeker) }

  describe 'after_sign_in_path_for(resource) method' do
    it 'redirects to the job seeker home path' do
      expect(controller.after_sign_in_path_for(job_seeker))
        .to eq home_job_seeker_path(job_seeker)
    end

    it 'redirects to the company person home path' do
      expect(controller.after_sign_in_path_for(company_admin))
        .to eq home_company_person_path(company_admin)
    end

    it 'redirects to the agency admin home path' do
      expect(controller.after_sign_in_path_for(agency_admin))
        .to eq home_agency_person_path(agency_admin)
    end
  end
end
