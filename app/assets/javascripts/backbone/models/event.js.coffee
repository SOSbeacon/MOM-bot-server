class MsRobot.Models.Event extends Backbone.Model
  paramRoot: 'event'
  url: '/events.json'

  defaults:
    _id: null
    title: null
    start: moment().format("MM-DD-YYYY")
    end: moment().format("MM-DD-YYYY")
    end_date: moment().format("MM-DD-YYYY")
    allDay: false
    content: null
    days_of_week: []

  parse: (response) =>
    response.start = new Date(response.start)
    response.end = new Date(response.end)
    return response

class MsRobot.Collections.EventsCollection extends Backbone.Collection
  model: MsRobot.Models.Event
  url: '/events'
