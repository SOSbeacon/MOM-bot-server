MsRobot.Views.UserChildren ||= {}

class MsRobot.Views.UserChildren.IndexView extends Backbone.View
  template: JST["backbone/templates/user_children/index"]

  initialize: () ->
    @options.userChildren.bind('reset', @addAll)

  addAll: () =>
    @options.userChildren.each(@addOne)

  addOne: (userChild) =>
    view = new MsRobot.Views.UserChildren.UserChildView({model : userChild})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(userChildren: @options.userChildren.toJSON() ))
    @addAll()

    return this
