class ManagementsController < ApplicationController
  before_action :logged_in_user
  
  def create
    @user = User.find(params[:managed_id])
    current_user.manage(@user)
    respond_to do |format|
      format.html { redirect_to users_path }
      format.js
    end
  end

  def destroy
    # puts "Destroy Params:"
    # puts params.to_yaml
    user = User.find_by(id: params[:managed_id])
    current_user.release(user)
    respond_to do |format|
      format.html { redirect_to users_path }
      format.js
    end
  end
end