require 'rails_helper'

RSpec.describe TaskPolicy do

  let(:agency) {FactoryGirl.create(:agency)}
  let(:job_developer) {FactoryGirl.create(:job_developer, :agency => agency)}
  let(:job_developer1) {FactoryGirl.create(:job_developer, :agency => agency)}
  let(:case_manager) {FactoryGirl.create(:case_manager, :agency => agency)}
  let(:task) {FactoryGirl.create(:task, :owner => job_developer)}
  let(:task_job_developers) {FactoryGirl.create(:task, :owner => nil, :owner_agency_role => :JD, :owner_agency => agency)}


  permissions :in_progress? do

    it 'denies access if user that is not the owner' do
      expect(TaskPolicy).not_to permit(case_manager, task)
    end

    it 'allows access if user is the owner' do
      expect(TaskPolicy).to permit(job_developer, task)
    end

  end

  permissions :done? do

    it 'denies access if user that is not the owner' do
      expect(TaskPolicy).not_to permit(case_manager, task)
    end

    it 'allows access if user is the owner' do
      expect(TaskPolicy).to permit(job_developer, task)
    end

  end

  permissions :assign? do
    context "single user owner" do
      it 'denies access if user that is not the owner' do
        expect(TaskPolicy).not_to permit(case_manager, task)
      end

      it 'allows access if user is the owner' do
        expect(TaskPolicy).to permit(job_developer, task)
      end
    end
    context "group of users" do
      it 'denies access if user is not in the group of the ownwers' do
        expect(TaskPolicy).not_to permit(case_manager, task_job_developers)
      end

      it 'allows access if user is in the group of the ownwers' do
        expect(TaskPolicy).to permit(job_developer, task_job_developers)
      end
    end
  end

  permissions :tasks? do
    it 'denies access if user is not logged in' do
      expect(TaskPolicy).not_to permit(nil, task)
    end

    it 'allows access if user is logged in' do
      expect(TaskPolicy).to permit(job_developer, task)
    end
  end
end
