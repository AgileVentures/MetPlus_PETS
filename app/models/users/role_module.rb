module Users
  module RoleModule
    module ClassMethods
      def job_developer?(user)
        agency_role?(user, :JD)
      end

      def case_manager?(user)
        agency_role?(user, :CM)
      end

      def agency_admin?(user)
        agency_role?(user, :AA)
      end

      def company_admin?(user)
        company_role?(user, :CA)
      end

      def company_contact?(user)
        company_role?(user, :CC)
      end

      private

      def company_role?(user, role)
        return false if user.nil?
        return false unless user.type == 'CompanyPerson'

        !user.pets_user.company_roles.filter do |company_role|
          company_role.role == CompanyRole::ROLE[role]
        end.empty?
      end

      def agency_role?(user, role)
        return false unless user.type == 'AgencyPerson'

        !user.pets_user.agency_roles.filter do |agency_role|
          agency_role.role == AgencyRole::ROLE[role]
        end.empty?
      end
    end

    module InstanceMethods
      def job_seeker?
        false
      end

      def job_developer?(_agency)
        false
      end

      def case_manager?(_agency)
        false
      end

      def agency_admin?(_agency)
        false
      end

      def agency_person?(_agency)
        false
      end

      def company_admin?(_company)
        false
      end

      def company_contact?(_company)
        false
      end

      def company_person?(_company)
        false
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end
  end
end
