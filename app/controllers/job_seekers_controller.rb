class JobSeekersController < ApplicationController
<<<<<<< HEAD
  
  def new
    @jobseeker = JobSeeker.new
  end
  
=======

  def new
    @jobseeker = JobSeeker.new
  end

>>>>>>> 046b2346dd578d4756310fe19bea4ea2d0445b5b
  def create
    @jobseeker = JobSeeker.new(jobseeker_params)
    if @jobseeker.save
       flash[:notice] = "A message with a confirmation and link has been sent to your email address. Please follow the link to activate your account."
<<<<<<< HEAD
      redirect_to root_path
    else
      @model_errors = @jobseeker.errors
      render 'new'
    end
    
=======
       redirect_to root_path
    else
     render 'new'
    end

>>>>>>> 046b2346dd578d4756310fe19bea4ea2d0445b5b
  end

  def edit
    @jobseeker = JobSeeker.find(params[:id])
<<<<<<< HEAD
  end
 
  def update
    @jobseeker = JobSeeker.find(params[:id])

    if @jobseeker.update_attributes(jobseeker_params)
=======


  end

  def update
    debugger
    @jobseeker = JobSeeker.find(params[:id])

    person_params = jobseeker_params
    if person_params['password'].empty?
        person_params.delete('password')
        person_params.delete('password_confirmation')
    end

    if @jobseeker.update_attributes(person_params)
>>>>>>> 046b2346dd578d4756310fe19bea4ea2d0445b5b
      sign_in :user, @jobseeker.user, bypass: true
      flash[:notice] = "Jobseeker was updated successfully."
      redirect_to root_path
    else
      @model_errors = @jobseeker.errors
      render 'edit'
    end
  end

  def index
    @jobseeker = JobSeeker.all
<<<<<<< HEAD
=======

>>>>>>> 046b2346dd578d4756310fe19bea4ea2d0445b5b
  end

  def show
    @jobseeker = JobSeeker.find(params[:id])
<<<<<<< HEAD
     
=======


>>>>>>> 046b2346dd578d4756310fe19bea4ea2d0445b5b
  end

  def destroy
    @jobseeker = Jobseeker.find(params[:id])
<<<<<<< HEAD
    @jobseeker.destroy
    flash[:notice] = "Jobseeker was deleted successfully."
    redirect_to root_path
  end

  private 
   def jobseeker_params
     params.require(:job_seeker).permit(:first_name,:last_name,:email,:phone,:password,:password_confirmation,:year_of_birth,:resume)
   end
 
=======
    @jobseeker.destrory
    redirect_to root_path
  end

  private
   def jobseeker_params
     params.require(:job_seeker).permit(:first_name,
            :last_name, :email, :phone,
            :password,
            :password_confirmation,
            :year_of_birth,
            :resume)
   end

>>>>>>> 046b2346dd578d4756310fe19bea4ea2d0445b5b
end
