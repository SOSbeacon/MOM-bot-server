class UserChildrenController < ApplicationController
  respond_to :json, :html

  before_filter :authenticate_user!, :except => [:show]

  def index
    puts "show index child"
  end

  def show
    puts "121231231231231231212123123123123123121212312312312312312121231231231231231212123123123123123121212312312312312312"
    puts current_user_child.to_json
    #respond_to do |format|
    #  format.json {render :json => {:user => current_user_child, :status => :ok, :ngon => "rat ngon"}}
    #end
  end

  def destroy
    puts "show index child"
  end
end
