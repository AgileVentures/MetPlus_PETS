require 'rails_helper'
include ServiceStubHelpers::Cruncher

RSpec.describe JobsHelper, type: :helper do
  let!(:skill1) { FactoryBot.create(:skill) }
  let!(:skill2) { FactoryBot.create(:skill, name: 'skill2') }
  let!(:skill3) { FactoryBot.create(:skill, name: 'skill3') }

  let(:company1) { FactoryBot.create(:company) }
  let(:company2) { FactoryBot.create(:company, name: 'Company 2') }

  3.times do |n|
    let("cmpy_skill#{n}".to_sym) do
      skill = FactoryBot.create(:skill, name: "cmpy_skill#{n}")
      skill.organization = company1
      skill.save
      skill
    end
  end

  let(:job) do
    FactoryBot.create(:job, min_salary: 15, max_salary: 25,
                            pay_period: 'Hourly')
  end

  before(:each) do
    stub_cruncher_authenticate
    stub_cruncher_job_create
  end

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
      expect(job_salary_details(job)).to eq 'Minimum Salary: $15.00, ' \
                                            'Maximum Salary: $25.00, Pay Period: Hourly'
    end
    it 'omits max salary if missing' do
      job.max_salary = nil
      expect(job_salary_details(job)).to eq 'Minimum Salary: $15.00, ' \
                                            'Pay Period: Hourly'
    end
    it 'returns not-specified if min salary not specified' do
      job.min_salary = nil
      expect(job_salary_details(job)).to eq '(not specified)'
    end
  end
end
