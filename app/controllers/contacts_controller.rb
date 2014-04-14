class ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => [:create, :destroy, :update]
  before_action :check_user_type


  # GET /contacts
  # GET /contacts.json
  def index
    contacts = Contact.where(:group_id => params[:group_id])

    if contacts.count > 0
      if check_permission_user(contacts[0]["user_id"])
        respond_to do |format|
          format.html
          format.json { render json:  contacts, :status => :ok }
        end
      end
    end
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    if @contact
      if check_permission_user(@contact.user_id)
        respond_to do |format|
          format.json {render :json => @contact.response_contact, :status => :ok}
        end
      end
    else
      respond_to do |format|
        format.json {render :json => { :error => "contact not found" }, :status => :bad_request}
      end
    end
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    contact = Contact.new(contact_params)

    respond_to do |format|
      if contact.save
        format.html
        format.json { render action: 'show', status: :created, json: contact }
      else
        format.html
        format.json { render json: contact.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    if @contact
      if check_permission_user(@contact.user_id)
        respond_to do |format|
          if @contact.update(contact_params)
            format.html
            format.json { render json: @contact, status: :created }
          else
            format.html
            format.json { render json: @contact.errors.full_messages, status: :unprocessable_entity }
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

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    if @contact
      if check_permission_user(@contact.user_id)
        @contact.destroy
        respond_to do |format|
          format.html
          format.json { head :no_content }
        end
      end
    else
      respond_to do |format|
        format.html
        format.json { render json: {:error => 'contact not found'}, :status => :bad_request }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:name, :email, :phone, :group_id, :user_id)
    end
end
