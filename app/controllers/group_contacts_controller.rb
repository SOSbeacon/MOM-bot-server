class GroupContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group_contact, only: [:show, :edit, :update, :destroy]
  before_action :check_user_type, only: [:create, :update, :destroy]
  before_action :check_valid_contact_id, only: [:create, :update]

  # GET /group_contacts
  # GET /group_contacts.json
  def index
    if current_user.type_user == USER_TYPE_NORMAL
      group_contacts = GroupContact.where(:user_id => params[:user_id].to_i).as_json
    elsif current_user.type_user == USER_TYPE_PARENT
      group_contacts = GroupContact.where(:user_id => current_user.id).as_json
    end

    if group_contacts.count > 0
      if check_permission_user(group_contacts[0]["user_id"])
        respond_to do |format|
          format.html
          format.json { render json:  group_contacts, :status => :ok }
        end
        return
      end
    end
    #if params.has_key?(:except)
    #  @group_contacts = GroupContact.where('id not in (?) AND user_id ?', params[:except], current_user.id)
    #else
    #  @group_contacts = GroupContact.where(:user_id => current_user.id)
    #end

  end

  # GET /group_contacts/1
  # GET /group_contacts/1.json
  def show
    group_contact = GroupContact.find_by_id(params[:id].to_i)

    if check_permission_user(group_contact.user_id)
      respond_to do |format|
        format.html
        format.json { render action: 'show', status: :ok, json: group_contact.response_format_with_contact }
      end
    end
  end

  # GET /group_contacts/new
  def new
    @group_contact = GroupContact.new
  end

  # GET /group_contacts/1/edit
  def edit
  end

  # POST /group_contacts
  # POST /group_contacts.json
  def create
    contacts_id = params[:group_contact][:contacts_id]
    group_contact = GroupContact.new(group_contact_params)
    if group_contact_params[:user_id] == nil
      group_contact.user_id = current_user.id
    end

    respond_to do |format|
      if group_contact.save
        if params[:group_contact].has_key?(:contacts_id) and contacts_id
          contacts_id.each do |c|
            contact = Contact.where(:id => c.to_i, user_id: current_user.id).last
            contact.update({:group_id => group_contact.id})
          end
        end

        format.html
        format.json { render action: 'show', status: :created, json: group_contact.as_json }
      else
        format.html
        format.json { render json: group_contact.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /group_contacts/1
  # PATCH/PUT /group_contacts/1.json
  def update
    contacts_id = params[:group_contact][:contacts_id]
    group_contact = GroupContact.find_by_id(params[:id].to_i)

    if group_contact
      if check_permission_user(group_contact.user_id)
        respond_to do |format|
          if group_contact.update(group_contact_params)
            # update group id in contact
            if params[:group_contact].has_key?(:contacts_id)
              contacts = group_contact.contacts
              if contacts_id
                contacts.each do |c|
                  if contacts_id.include? c.id.to_s
                    contacts_id.delete(c.to_s)
                  else
                    c.update({:group_id => nil})
                  end
                end

                contacts_id.each do |c|
                  contact = Contact.where(:id => c.to_i, :user_id => current_user.id).last
                  contact.update({:group_id => params[:id].to_i})
                end
              else
                contacts.each do |c|
                  c.update({:group_id => nil})
                end
              end
            end

            format.html
            format.json { render json: group_contact.as_json, :status => :created }
          else
            format.html
            format.json { render json: group_contact.errors.full_messages, status: :unprocessable_entity }
          end
        end
      end
    else
      respond_to do |format|
        format.html
        format.json { render json: {:error => 'group contact not found'}, :status => :bad_request }
      end
    end
  end

  # DELETE /group_contacts/1
  # DELETE /group_contacts/1.json
  def destroy
    group_contact = GroupContact.find_by_id(params[:id].to_i)

    if group_contact
      if check_permission_user(group_contact.user_id)
        contacts = Contact.where(:group_id => params[:id].to_i)

        contacts.each do |c|
          c.update(:group_id => nil)
        end

        group_contact.destroy
        respond_to do |format|
          format.html
          format.json { head :no_content }
        end
      end
    else
      respond_to do |format|
        format.html
        format.json { render json: {:error => 'group contact not found'}, :status => :bad_request }
      end
    end


  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group_contact
      @group_contact = GroupContact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_contact_params
      params.require(:group_contact).permit(:name, :user_id)
    end

    def check_valid_contact_id
      if params[:group_contact].has_key?(:contacts_id)
        contacts_id = params[:group_contact][:contacts_id]
        errors = []

        if contacts_id
          contacts_id.each do |c|
            contact = Contact.where(:id => c.to_i).last
            if !contact
              errors.push("Contact with id #{c.to_i} not exits")
            end
          end
        end

        if errors.count > 0
          respond_to do |format|
            format.html
            format.json { render json: {errors: errors}, :status => :bad_request }
          end
          return
        end
      end
    end
end
