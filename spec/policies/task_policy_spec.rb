require 'rails_helper'

RSpec.describe TaskPolicy do

  let(:agency) {FactoryGirl.create(:agency)}
  let(:company) {FactoryGirl.create(:company)}
  let(:job_developer) {FactoryGirl.create(:job_developer, :agency => agency)}
  let(:job_seeker) {FactoryGirl.create(:job_seeker)}
  let(:job_developer1) {FactoryGirl.create(:job_developer, :agency => agency)}
  let(:case_manager) {FactoryGirl.create(:case_manager, :agency => agency)}
  let(:agency_admin) {FactoryGirl.create(:agency_admin, :agency => agency)}

  let(:company_admin) {FactoryGirl.create(:company_admin, :company => company)}
  let(:company_contact) {FactoryGirl.create(:company_contact, :company => company)}
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

  permissions :index?, :tasks? do
    it 'denies access if user not logged in' do
      expect(TaskPolicy).not_to permit(nil, task)
    end
    it 'denies access if user is a job seeker' do
      expect(TaskPolicy).not_to permit(job_seeker, task)
    end
    context "agency people" do
      it 'allow access if user is a job developer' do
        expect(TaskPolicy).to permit(job_developer, task)
      end
      it 'allow access if user is a case manager' do
        expect(TaskPolicy).to permit(case_manager, task)
      end
      it 'allow access if user is a agency admin' do
        expect(TaskPolicy).to permit(agency_admin, task)
      end
    end
    context "company people" do
      it 'allow access if user is a company contact' do
        expect(TaskPolicy).to permit(company_contact, task)
      end
      it 'allow access if user is a company admin' do
        expect(TaskPolicy).to permit(company_admin, task)
      end
    end
  end
end
