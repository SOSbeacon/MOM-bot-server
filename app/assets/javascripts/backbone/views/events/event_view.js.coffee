MsRobot.Views.Events ||= {}

class MsRobot.Views.Events.EventViewApp extends Backbone.View
  template: JST["backbone/templates/events/event"]
  className: "eventview"

  initialize: =>
    @collection = new MsRobot.Collections.EventsCollection()
    @session = new MsRobot.Models.Session()
    @collection.bind('add', @addOne, this)
    @collection.bind('reset', @reset, this)
    @collection.bind('all', @show, this)
    @calendarList = ""

  events: =>
    "click .fc-button-prev" : "prevMonth"
    "click .fc-button-next" : "nextMonth"
    "change #choose-parent select" : "renderBody"

  render: ->
    $(@el).html(@template( ))
    @renderParent()
    return this

  renderEvent: =>
    startTime = @calendarList.fullCalendar("getView").start
    endTime = @calendarList.fullCalendar("getView").end

    @collection.url = =>
      "/event/list_event_on_range_date.json?query_start=#{startTime}&query_end=#{endTime}&auth_token=#{@session.get('authentication_token')}&user_id=#{$.cookie('user_id')}"

    @collection.fetch({
      cache: false,
      async: false,
      success: (response) =>
        console.log response
      error: (jqXHR, textStatus, errorThrown) =>
        console.log textStatus
    })

  renderParent: =>
    listParent = new MsRobot.Collections.UsersCollection()
    listParent.url = =>
      "/users/list_parent.json?auth_token=#{@session.get('authentication_token')}"

    listParent.fetch({
      cache: false,
      async: false
    })

    if listParent.length > 0
      listParent.each((model, index) =>
        @$("#choose-parent select").append(
          $("<option></option>").attr("value", model.get('id')).html(model.get('first_name') + ' ' + model.get('last_name'))
        )
      )
      if $.cookie('user_id')
        @$("#choose-parent option").each ->
          if parseInt($(this).attr("value")) == parseInt($.cookie('user_id'))
            $(this).attr 'selected', 'selected'

      @$(".chosen-select").chosen()
      @renderBody()
    else
      @$("#calendar").html("<h1 class='blue'>You need to create parent first.</h1>")

  renderBody: =>
    user_id = @$("#choose-parent select").val()
    $.cookie('user_id', user_id)
    @$("#calendar").html ""

    setTimeout(( =>
      @renderCalendar()
      @renderEvent()
    ), 100)

  prevMonth: =>
#    @calendarList.fullCalendar('prev')
    @renderEvent()

  nextMonth: =>
#    @calendarList.fullCalendar('next')
    @renderEvent()

  addAll: ->
    @collection.each(@addOne)

  addOne: (event) ->
    if event.get("type_event") == 'daily' || event.get("type_event") == 'weekly'
      event.set("allDay", false)

    @$("#calendar").fullCalendar 'renderEvent', event.toJSON()

  reset: =>
    @addAll()

  renderCalendar: () =>
    that = this
    @calendarList = @$("#calendar").fullCalendar(
      buttonText:
        prev: "<i class=\"icon-chevron-left\"></i>"
        next: "<i class=\"icon-chevron-right\"></i>"

      header:
        left: "prev,next today"
        center: "title"
        right: "month,agendaWeek,agendaDay"

      editable: true
      droppable: true # this allows things to be dropped onto the calendar !!!

      selectable: true
      selectHelper: true
      select: (start, end, allDay) ->
        model = new MsRobot.Models.Event({start: moment(start).format("MM-DD-YYYY"), end: moment(end).format("MM-DD-YYYY"), days_of_week: new Array()})
        console.log model
        view = new MsRobot.Views.Events.FormEvent({calendarEvent: that.calendarList, allDay: allDay, model:model})
        $("body").append(view.render().el)
        return

      eventClick: (calEvent, jsEvent, view) ->
        model = new MsRobot.Models.Event(calEvent)
        view = new MsRobot.Views.Events.FormEvent({calendarEvent: that.calendarList, model:model})
        $("body").append(view.render().el)
#        form = $("<form class='form-inline'><label>Change event name &nbsp;</label></form>")
#        form.append "<input class='middle' autocomplete=off type=text value='" + calEvent.title + "' /> "
#        form.append "<button type='submit' class='btn btn-sm btn-success'><i class='icon-ok'></i> Save</button>"
#        div = bootbox.dialog(
#          message: form
#          buttons:
#            delete:
#              label: "<i class='icon-trash'></i> Delete Event"
#              className: "btn-sm btn-danger"
#              callback: ->
#                that.calendarList.fullCalendar "removeEvents", (ev) ->
#                  ev._id is calEvent._id
#
#                return
#
#            close:
#              label: "<i class='icon-remove'></i> Close"
#              className: "btn-sm"
#        )
#        form.on "submit", ->
#          calEvent.title = form.find("input[type=text]").val()
#          that.calendarList.fullCalendar "updateEvent", calEvent
#          div.modal "hide"
#          false

        return
    )

  close: =>
    this.remove()
    this.unbind()

class MsRobot.Views.Events.FormEvent extends Backbone.View
  template: JST["backbone/templates/events/form"]
  className: "form-event"

  initialize: (options) =>
    @calendar = options.calendarEvent
    @allDay = options.allDay
    @alert = new MsRobot.Views.Common.AlertView()
    @daysOfWeek = @model.get("days_of_week")

  events:
    "click .close-modal" : "destroyModal"
    "mouseover .date-picker" : "createDatePicker"
    "click #confirm" : "createEvent"
    "click #event-checkbox-repeat" : "checkBox"
    "click .weekly-repeat" : "weeklyRepeat"
    "click #remove" : "removeEvent"
    "change #event-loop-type" : "changeTypeEvent"
    "change #event-start-hour" : "changeStartHour"

  render: =>
    console.log @model
    $(@el).html @template(@model.toJSON())

    if @model.get("_id")
      @$("#remove").show()

      if @model.get('type_event') == 'daily' || @model.get('type_event') == 'weekly'
        @$("#event-checkbox-repeat").click()
        @$(".event-loop").show()

      if @model.get('type_event') == 'weekly'
        @$("#event-loop-type option[value='" + @model.get('type_event') + "']").attr("selected", "selected");
        @$("#repeat-on").show()
        @$(".weekly-repeat").each((index, obj) =>
          number = $(obj).attr("data-value")
          if $.inArray(number.toString(), @model.get("days_of_week")) >= 0
            $(obj).attr("checked","checked")
        )

    @$("#modal").modal("show")
    that = this
    setTimeout(( =>
      @$("#event-start-hour").timepicker({
        minuteStep: 15,
        showSeconds: false,
        showMeridian: false
      })

      @$("#event-end-hour").timepicker({
        minuteStep: 15,
        showSeconds: false,
        showMeridian: false
      })

      @$('#event-start-hour').timepicker('setTime', moment(that.model.get('start')).hour() + ":" + moment(that.model.get('start')).minute())
      @$('#event-end-hour').timepicker('setTime', moment(that.model.get('end')).hour()+ ":" + moment(that.model.get('end')).minute())

      @$("#event-start-hour").timepicker().on "hide.timepicker", (e) ->
        end_time = that.$("#event-end-hour").val()
        if e.time.hours > parseInt(end_time)
          that.$('#event-end-hour').timepicker('setTime', (e.time.hours + 1) + "");

      @$("#event-end-hour").timepicker().on "hide.timepicker", (e) ->
        start_time = that.$("#event-start-hour").val()
        if e.time.hours < parseInt(start_time)
          that.$('#event-start-hour').timepicker('setTime', (e.time.hours - 1) + "");

    ), 100)
#    @renderHour()

#    @dateRangePicker()
    return this

  renderHour:() =>
    i = 0
    @$("#event-start-hour").html ""
    @$("#event-end-hour").html ""
    console.log @model
    while (LIST_HOUR.length > i)
      if moment(@model.get('start')).format("HH:mm") == LIST_HOUR[i]
        @$("#event-start-hour").append('<option selected="selected">' + LIST_HOUR[i] + '</option>')
        j = i+2
        while (LIST_HOUR.length > j)
          @$("#event-end-hour").append('<option>' + LIST_HOUR[j] + '</option>')
          j++
      else
        @$("#event-start-hour").append('<option>' + LIST_HOUR[i] + '</option>')
      i++

  changeStartHour: (e) =>
    index = @$("#event-start-hour")[0].selectedIndex + 2
    @$("#event-end-hour").html ""
    while (LIST_HOUR.length > index)
      @$("#event-end-hour").append('<option>' + LIST_HOUR[index] + '</option>')
      index++

  createDatePicker: (e) =>
    that = this
    $(e.currentTarget).datepicker({
      autoclose: true
      startDate: that.model.get('start')
    }).on 'changeDate', (e) ->
      if e.currentTarget.id == "event-start-time"
        end_time = moment(e.date).format("MM-DD-YYYY")
        that.$("#event-end-time").val(end_time)

  weeklyRepeat: (e) =>
    startTime = @$("#event-start-time").val()
    startTime = new Date(startTime + " " + @$("#event-start-hour option:selected").text())
    value = $(e.target).attr("data-value")

    if e.currentTarget.checked
      @daysOfWeek.push(value )
    else
      index = @daysOfWeek.indexOf(value)
      @daysOfWeek.splice(index,1)

    console.log @daysOfWeek

  removeEvent: =>
    that = this
    postAjax 'DELETE', "", '/events/' + @model.get("_id") + ".json", (callback) =>
      app = new MsRobot.Views.Events.EventViewApp()
      $("#content").html(app.render().el)
      that.$("#modal").modal("hide")

  createEvent: =>
    @$(".loading").show()
    @$("#confirm").attr("disabled","disabled")
    @$("#cancel").attr("disabled","disabled")

    title = @$("#event-title").val()
    content = @$("#event-content").val()
    startTime = @$("#event-start-time").val()
    endTime = @$("#event-end-time").val()

    if !title
      @alert.showAlert("", "Title can't be blank", "alert-danger", "event-alert")
      return this

    if !startTime
      @alert.showAlert("", "Start date can't be blank", "alert-danger", "event-alert")
      return this

    startTime = new Date(startTime + " " + @$("#event-start-hour").val())
    endTime = new Date(endTime + " " + @$("#event-end-hour").val())
    typeEvent = "norepeat"
    endDate = ""

    if @$("#event-checkbox-repeat").is(":checked")
      typeEvent = @$("#event-loop-type option:selected").attr("value")
      repeatEvery = parseInt(@$("#event-every option:selected").attr("value"))
      endDate = @$("#event-end-date").val()

      if endDate
        endDate = new Date(endDate + " 23:59")

    data = {
      event: {
        title: title
        type_event: typeEvent
        content: content
        start_time: startTime
        end_time: endTime
        repeat_interval: repeatEvery
        days_of_week: @daysOfWeek
        end_date: endDate
        user_id: $(".chosen-select option:selected").val()
      }
    }

    that = this
    console.log data
    if @model.get("_id")
      postAjax 'PUT', data, '/events/' + @model.get("_id") + ".json", (callback) =>
        console.log callback
        if callback.status == 400
          errorStatus = JSON.parse(callback.responseText)
          @alert.hideAlert()
          @alert.showAlert("", errorStatus, "alert-danger", "event-alert")
        else if callback.status == 500
          @alert.hideAlert()
          @alert.showAlert("", "Server error, try again later", "alert-danger", "event-alert")
        else
          app = new MsRobot.Views.Events.EventViewApp()
          $("#content").html(app.render().el)
          that.$("#modal").modal("hide")
    else
      postAjax "POST", data, URL_CREATE_EVENT, (callback) =>
        if callback.status == 400
          errorStatus = JSON.parse(callback.responseText)
          @alert.hideAlert()
          @alert.showAlert("", errorStatus, "alert-danger", "event-alert")
        else if callback.status == 500
          @alert.hideAlert()
          @alert.showAlert("", "Server error, try again later", "alert-danger", "event-alert")
        else
          that.$("#modal").modal("hide")
          that.alert.hideAlert()
          that.alert.showAlert("", "Create parent successfully", "alert-success")
          view = new MsRobot.Views.Events.EventViewApp()
          $("#content").html(view.render().el)

  checkBox: (e) =>
    if e.currentTarget.checked
      @$(".event-loop").show()
    else
      @$(".event-loop").hide()

  changeTypeEvent: (e) =>
    value = $(e.target).val()
    if value == "daily"
      textChange = 'days'
    else if value == "weekly"
      textChange = 'weeks'
      @$("#repeat-on").show()
    else if value == "monthly"
      textChange = 'months'
    @$(".event-type-every").html textChange

  destroyModal: =>
    that = this
    @$("#modal").on "hidden.bs.modal", (e) ->
      that.remove()