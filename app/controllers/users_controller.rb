class UsersController < ApplicationController
  def edit
    @user = params[:id] == current_user_id ? current_user : User.find(params[:id])
    authorize! :update, @user
    
    @bank_options = Syrup.institutions.map {|institution| [institution.name, institution.id] }
    @bank_options[0, 0] = [["None", ""]]
  end
  
  def update
    @user = params[:id] == current_user_id ? current_user : User.find(params[:id])
    authorize! :update, @user
    
    if @user.update_attributes(params[:user])
      redirect_to edit_user_url(@user), notice: 'Your account was successfully updated.'
    else
      @bank_options = Syrup.institutions.map {|institution| [institution.name, institution.id] }
      @bank_options[0, 0] = [["None", ""]]
      
      render action: "edit"
    end
  end
end
