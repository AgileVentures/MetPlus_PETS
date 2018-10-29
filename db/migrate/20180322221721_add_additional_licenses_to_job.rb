class AddAdditionalLicensesToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :additional_licenses, :text
  end
end
