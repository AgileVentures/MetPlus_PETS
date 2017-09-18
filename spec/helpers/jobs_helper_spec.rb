require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the JobsHelper. For example:
#
# describe JobsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe JobsHelper, type: :helper do
  let!(:skill1) { FactoryGirl.create(:skill) }
  let!(:skill2) { FactoryGirl.create(:skill, name: 'skill2') }
  let!(:skill3) { FactoryGirl.create(:skill, name: 'skill3') }

  let(:company1) { FactoryGirl.create(:company) }
  let(:company2) { FactoryGirl.create(:company, name: 'Company 2') }

  3.times do |n|
    let("cmpy_skill#{n}".to_sym) do
      skill = FactoryGirl.create(:skill, name: "cmpy_skill#{n}")
      skill.organization = company1
      skill.save
      skill
    end
  end

  let(:job) { FactoryGirl.create(:job, min_salary: 15, max_salary: 25,
                                 pay_period: 'Hourly') }

  describe '#sort_instruction' do
    it 'returns string if count > 1' do
      expect(sort_instruction(2)).to eq ' Click on any column title to sort.'
    end

    it 'returns nil otherwise' do
      expect(sort_instruction(1)).to be_nil
    end
  end

  describe '#skills_for_company' do
    it 'returns agency skills for company without company-specific skills' do
      expect(skills_for_company(company2)).to contain_exactly(skill1, skill2, skill3)
    end

    it 'returns agency and company skills' do
      expect(skills_for_company(company1))
        .to contain_exactly(skill1, skill2, skill3,
                            cmpy_skill0, cmpy_skill1, cmpy_skill2)
    end
  end

  describe '#job_salary_details' do
    it 'returns min, max and pay period' do
      expect(job_salary_details(job)).to eq 'Minimum Salary: $15.00, ' +
        'Maximum Salary: $25.00, Pay Period: Hourly'
    end
    it 'omits max salary if missing' do
      job.max_salary = nil
      expect(job_salary_details(job)).to eq 'Minimum Salary: $15.00, ' +
        'Pay Period: Hourly'
    end
    it 'returns not-specified if min salary not specified' do
      job.min_salary = nil
      expect(job_salary_details(job)).to eq '(not specified)'
    end
  end
end
