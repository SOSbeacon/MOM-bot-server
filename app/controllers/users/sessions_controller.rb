class Users::SessionsController < Devise::SessionsController
  # prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
  # prepend_before_filter :allow_params_authentication!, :only => :create
  # prepend_before_filter { request.env["devise.skip_timeout"] = true }

  ##TODO: After doing payment --> Need to be approved before logging in
  skip_before_filter  :verify_authenticity_token, :only => [:create, :destroy]

  def create
    respond_to do |format|
      format.html do
        super
      end

      format.json do
        resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")

        set_flash_message(:notice, :signed_in) if is_navigational_format?
        sign_in(resource_name, resource)

        render :json => {:auth_token => current_user.authentication_token, :user => current_user}.to_json, :status => :ok
      end
    end
  end

  def destroy
    if current_user
      current_user.reset_authentication_token!
    end

    super

  end

end
