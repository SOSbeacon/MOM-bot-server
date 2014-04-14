# -*- encoding : utf-8 -*-

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json, :html

  before_filter :authenticate_scope!, :only => [:update]
  before_filter :configure_permitted_parameters, if: :devise_controller?
  skip_before_filter :verify_authenticity_token
  skip_before_action  :verify_authenticity_token

  def create
    build_resource(sign_up_params)

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => respond_to?(:new_user_session) ? root_path : "/users/sign_in"
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def update
    if !params[:user][:password].blank?
      successfully_updated = resource.update_with_password(resource_params)
    else
      successfully_updated = resource.update_without_password(resource_params)
    end

    if successfully_updated
      #sign_in resource, :bypass => true

      respond_to do |format|
        format.json { render :json =>  resource.as_json, :status => :created }
      end
    else  ## error when save
      respond_to do |format|
        format.json { render json: resource.errors.full_messages, :status => :bad_request }
      end
    end

  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation) }

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:first_name, :last_name, :password, :password_confirmation)
    end
  end

  def resource_params
    params.require(:user).permit(:first_name, :last_name, :password, :password_confirmation, :current_password)
  end
  private :resource_params

end
