class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => [:create, :destroy, :update]
  before_action :authenticate_user!, :except => [:index]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)

    if current_user.type_user == USER_TYPE_PARENT
      @event.user_id = current_user.id
    elsif current_user.type_user == USER_TYPE_NORMAL
      if params[:event][:user_id]
        @event.user_id = params[:event][:user_id].to_i
      else
        respond_to do |format|
          format.html
          format.json { render json: {:error => "Missing params user_id"}, :status => :bad_request }
        end
        return
      end
    end

    if @event.type_event == 'weekly'
      @event.days_of_week = params[:event][:days_of_week]
    end

    #debugger
    respond_to do |format|
      if @event.save
        start_time = event_params[:start_time].to_datetime
        repeat_interval = params[:event][:repeat_interval].to_i

        if @event.type_event == 'daily'
          @eventMeta = EventMeta.new(:event_id => @event.id, :repeat_start => start_time,
                                     :repeat_interval => repeat_interval*INTERVAL_DAILY, :user_id => @event.user_id)
          @eventMeta.save
        elsif @event.type_event == 'weekly'
          days_of_week = params[:event][:days_of_week]

          days_of_week.each do |interval|
            time_start = get_date_from_number(@event.start_time, interval)
            @eventMeta = EventMeta.new(:event_id => @event.id, :repeat_start => time_start,
                                       :repeat_interval => repeat_interval, :user_id => @event.user_id)
            @eventMeta.save
          end
        end

        #debugger
        #date_response = {
        #  id: @event.id,
        #  title: @event.title,
        #  type_event: @event.type_event,
        #  content: @event.content,
        #  created_at: @event.created_at,
        #  updated_at: @event.updated_at,
        #  start_time: @event.start_time,
        #  end_time: @event.end_time
        #}

        format.html
        format.json { render :json => @event.query_event(DateTime.now.end_of_month, @event.start_time), status: :created, location: @event }
      else
        format.html
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    if @event
      if check_permission_user(@event.user_id)
        respond_to do |format|
          if @event.update(event_params)
            start_time = event_params[:start_time].to_datetime
            repeat_interval = params[:event][:repeat_interval].to_i
            #debugger
            if @event.type_event == 'daily'
              eventMeta = EventMeta.where(:event_id => @event.id).first
              eventMeta.update_attributes({:repeat_interval => repeat_interval*INTERVAL_DAILY, :repeat_start => start_time})

              #@eventMeta.save
            elsif @event.type_event == 'weekly'
              days_of_week = params[:event][:days_of_week]

              event_metas = EventMeta.where(:event_id => @event.id)

              event_metas.each do |em|
                if days_of_week.include? em.repeat_start.to_datetime.strftime("%w")
                  em.update_attributes({:repeat_interval => repeat_interval})
                  days_of_week.delete(em.repeat_start.to_datetime.strftime("%w"))
                else
                  em.destroy
                end
              end
              days_of_week.each do |interval|
                time_start = get_date_from_number(@event.start_time, interval)
                event_meta = EventMeta.new(:event_id => @event.id, :repeat_start => time_start,
                                           :repeat_interval => repeat_interval, :user_id => current_user.id)
                event_meta.save
              end

            end

            format.html
            format.json { render :json => @event.query_event(DateTime.now.end_of_month, DateTime.now.beginning_of_month), :status => :created }
          else
            format.html
            format.json { render json: @event.errors, status: :unprocessable_entity }
          end
        end
      end
    else
      respond_to do |format|
        format.html
        format.json { render json: {:error => "you don't have permission to update this event or event not found"}, :status => :bad_request }
      end
    end

  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    if @event
      if check_permission_user(@event.user_id)
        @event.destroy
        respond_to do |format|
          format.html
          format.json { render json: {:success => "delete event successfully"}, :status => :no_content }
        end
      end
    else
      respond_to do |format|
        format.html
        format.json { render json: {:error => @event.errors.full_message}, :status => :bad_request }
      end
    end
  end

  def get_event_from_date_to_date
    if !params.has_key?(:query_start) || !params.has_key?(:query_end)
      respond_to do |format|
        format.html
        format.json { render json: {:error => "missing query_start or query_end paramater"}, status: :bad_request }
      end
      return
    end

    if current_user.type_user == USER_TYPE_PARENT
      user_id = current_user.id
    elsif current_user.type_user == USER_TYPE_NORMAL
      user_id = params[:user_id].to_i
    end

    if check_permission_user(user_id)
      query_start = Time.parse(params[:query_start]).in_time_zone.to_datetime
      query_end = Time.parse(params[:query_end]).in_time_zone.to_datetime
      events_response = Array.new

      if query_start.strftime("%Q") == query_end.strftime("%Q")
        events = Event.where("start_time BETWEEN ? AND ? AND user_id = ?", DateTime.now.beginning_of_day,
                             DateTime.now.end_of_day, user_id)
      else
        events = Event.where(:user_id => user_id)
        #end
      end

      #debugger
      events.each do |event|
        # check xem co phai repeat hay khong
        # neu repeat thi tinh xem no repeat bao nhieu lan tu start day den end day
        #
        events_response += event.query_event(query_end, query_start)
      end

      respond_to do |format|
        format.html {}
        format.json { render json: events_response, status: :ok }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:title, :type_event, :content, :start_time, :end_time, :end_date, :days_of_week)
  end
end
