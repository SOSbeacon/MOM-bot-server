class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  #before_filter :authenticate_user_child!


  def convert_millisecond_to_date(milisecond)
    t = Time.at(milisecond/1000)
    DateTime.parse(t.to_s)
  end

  def convert_date_to_millisecond(date_input)
    d = date_input.to_s.to_datetime
    d.strftime("%Q")
  end

  def get_date_from_number(date, number)
    n = date.to_datetime.strftime("%w")
    d = date + (number.to_i - n.to_i).days
  end

  def check_permission_user(user_id)
    user = User.find_by_id(user_id)
    if current_user.id == user.creator_id.to_i
      return true
    elsif current_user.id == user.id
      return true
    end

    respond_to do |format|
      format.html
      format.json { render status: :bad_request, json: {:error => 'You do not have permission'} }
    end
    return
  end

  def check_user_type
    if current_user.type_user == USER_TYPE_PARENT
      respond_to do |format|
        format.html
        format.json { render json: {:error => 'You do not have permission'}, :status => :bad_request }
      end
      return
    end
  end

end
