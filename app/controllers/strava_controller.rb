class StravaController < ApplicationController
  def download
    @user = User.find_by(id: params['user_id'])
    strava_id = params['strava_id']
    @user.fetch_activity(strava_id.to_s)
    respond_to do |format|
      format.html { redirect_to @user, notice: 'Activity was successfully Loaded.' }
      format.js
    end
  end
end
