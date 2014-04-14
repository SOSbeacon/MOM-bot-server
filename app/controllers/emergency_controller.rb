class EmergencyController < ApplicationController

  before_filter :authenticate_user!, :except => [:show_message]
  skip_before_filter :verify_authenticity_token, :only => [:emergency, :update_message, :delete_message, :show_message]
  before_action :check_params, :except => [:show_message]
  before_action :set_message, :only => [:update_message, :delete_message]

  def show_message
    @message = Message.find_by_id(params[:id])

    if !@message
      @notice = "Message not found"
    else
      @message
    end
  end

  def emergency
    if current_user.type_user == USER_TYPE_PARENT
      user_id = current_user.id
      groups = GroupContact.where(:user_id => user_id)
    elsif  current_user.type_user == USER_TYPE_NORMAL
      user_id = params[:user_id]
      groups = GroupContact.where(:user_id => user_id)
    end

    message = Message.new(message_params)
    message.user_id = user_id

    respond_to do |format|
      if message.save
        groups.each do |group|
          group.update({:message_id => message.id})
          contacts = Contact.where(:group_id => group.id)

          if contacts
            contacts.each do |contact|
              if contact.email
                Resque.enqueue(SentEmail, contact.user_id, contact.email, message.id)
              end
              if contact.phone
                Resque.enqueue(SentSMS, contact.user_id, contact.phone, message.id)
              end
            end
          end
        end
        format.json {render :json => message, :status => :created}
      else
        format.json {render :json => message.errors.full_messages, :status => :bad_request}
      end
    end
  end

  def update_message
    if @message
      if check_permission_user(@message.user_id)
        respond_to do |format|
          if @message.update(message_params)
            format.html
            format.json { render json: @message, status: :created }
          else
            format.html
            format.json { render json: @message.errors.full_messages, status: :unprocessable_entity }
          end
        end
      end
    else
      respond_to do |format|
        format.html
        format.json { render json: {:error => 'contact not found'}, :status => :bad_request }
      end
    end
  end

  def delete_message
    if @message
      if check_permission_user(@message.user_id)
        groups = @message.group_contacts
        groups.each do |group|
          group.update({:message_id => nil})
        end
        @message.destroy
        respond_to do |format|
          format.html
          format.json { head :no_content }
        end
      end
    else
      respond_to do |format|
        format.html
        format.json { render json: {:error => 'message not found'}, :status => :bad_request }
      end
    end
  end

  private
    def check_params
      if current_user.type_user == USER_TYPE_NORMAL
        if !params.has_key?(:user_id)
          respond_to do |format|
            format.html
            format.json { render json: {:error => "missing user_id paramater"}, status: :bad_request }
          end
          return
        end
      end
    end

    def set_message
      @message = Message.find(params[:id])
    end

    def message_params
      params.require(:message).permit(:text, :photo_url, :audio_url, :lat, :lng)
    end

end