class JobsController < ApplicationController
	before_action :find_job,	only: [:show, :edit, :update]

	def index
	end	

	def new
		@job = Job.new 
	end

	def create
	end

	def show
	end

	def edit
	end

	def update
	end


	private 
		def find_job
			@job = Job.find(params[:id])
		end

		def job_params
			params.require(:job).permit()
		end


end
