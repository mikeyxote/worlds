class ManagementsController < ApplicationController
  
  def create
    user = User.find(params[:followed_id])
    current_user.manage(user)
    redirect_to user
  end

  def destroy
    user = Management.find(params[:id]).managed
    current_user.release(user)
    redirect_to user
  end
end
