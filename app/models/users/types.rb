module Users
  module Types
    module ClassMethods
      def job_seeker?(user)
        user.type == 'JobSeeker'
      end

      def agency_person?(user)
        job_developer?(user) || case_manager?(user) || agency_admin?(user)
      end

      def company_person?(user)
        company_contact?(user) || company_admin?(user)
      end
    end

    module InstanceMethods
      def type
        actable_type
      end

      def pets_user
        try(:actable).nil? ? self : actable
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end
  end
end
