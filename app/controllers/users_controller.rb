class UsersController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token, :only => [:create_parent, :update, :destroy]
  before_action :set_user, :only => [:show, :update, :destroy]
  respond_to :json
  require "resque"

  def list_parent
    users = User.where(:creator_id => current_user.id.to_s)

    respond_to do |format|
      format.json {render :json => users, :status => :ok}
    end
  end

  def create_parent
    user = User.new(:creator_id => current_user.id.to_s, :email => params[:user]['email'],
                    :password => params[:user]['password'], :confirmed_at => Time.now,
                    :type_user => USER_TYPE_PARENT,
                    :last_name => params[:user]['last_name'],
                    :first_name => params[:user]['first_name'])

    if user.save
      respond_to do |format|
        format.json { render json: user, status: :created }
      end
    else
      respond_to do |format|
        format.json {render :json => user.errors.full_messages, :status => 400}
      end
    end
  end

  # show
  def show
    if @user
      if check_permission_user(@user.creator_id)
        respond_to do |format|
          format.json { render json: @user, status: :ok }
        end
      end
    elsif
      respond_to do |format|
        format.json {render :json => @user.errors.full_message, :status => :bad_request}
      end
    end
  end

  def update
    if @user
      if check_permission_user(@user.creator_id)
        if !params[:user][:password].blank?
          successfully_updated = @user.update_with_password(user_params)
        else
          successfully_updated = @user.update_without_password(user_params)
        end

        if successfully_updated
          #sign_in resource, :bypass => true

          respond_to do |format|
            format.json { render :json =>  @user.as_json, :status => :created }
          end
        else  ## error when save
          respond_to do |format|
            format.json { render json: @user.errors.full_messages, :status => :bad_request }
          end
        end
      end
    else
      respond_to do |format|
        format.json { render json: {:error => @user.errors.full_message}, :status => :bad_request }
      end
    end
  end

  def destroy
    if @user
      if check_permission_user(@user.creator_id)
        @user.destroy
        respond_to do |format|
          format.json { head :no_content }
        end
      end
    else
      respond_to do |format|
        format.json { render json: {:error => @user.errors.full_message}, :status => :bad_request }
      end
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :name, :phone, :last_name, :first_name, :password)
    end

end