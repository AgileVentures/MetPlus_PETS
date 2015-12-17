class CompaniesController < ApplicationController

  def new
    @comany = Company.new
  end

  def create
    @company = Company.new
  end

  private

end
