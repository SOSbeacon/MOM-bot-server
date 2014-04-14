class HomeController < ApplicationController
  #before_action authenticate_user!
  before_filter :authenticate_user!

  def index
    @user = current_user.as_json.merge!(
      {
        :id => current_user.id,
        :email => current_user.email,
        :creator_id => current_user.creator_id,
        ## TODO
        :created_at => current_user.created_at,
        :updated_at => current_user.updated_at,
        :authentication_token => current_user.authentication_token,
      }
    )
  end
end