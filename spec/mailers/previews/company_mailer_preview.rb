# Preview all emails at http://localhost:3000/rails/mailers/company_mailer
class CompanyMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/company_mailer/pending_approval
  def pending_approval
    company = FactoryGirl.build(:company)
    company.agencies << FactoryGirl.create(:agency)
    company.save
    company_person = FactoryGirl.create(:company_person, company: company)
    CompanyMailer.pending_approval(company_person)
  end

end
