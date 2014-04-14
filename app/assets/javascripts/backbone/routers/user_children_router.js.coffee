class MsRobot.Routers.UserChildrenRouter extends Backbone.Router
  initialize: (options) ->
    console.log "ngon"
    console.log options.userChildren
    @user = new MsRobot.Models.UserChild(options.userChildren)
#    menuView = new MsRobot.Views.Menu.MenuView({model:@user})

#    @userChildren = new MsRobot.Collections.UserChildrenCollection()
#    @userChildren.reset options.userChildren

  routes:
    "new"      : "newUserChild"
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  newUserChild: ->
    @view = new MsRobot.Views.UserChildren.NewView(collection: @user_children)
    $("#user_children").html(@view.render().el)

  index: ->
#    @view = new MsRobot.Views.UserChildren.IndexView(user_children: @user_children)
    $("#page-wrapper").html("Backbone dashboard")

  show: (id) ->
    user_child = @user_children.get(id)

    @view = new MsRobot.Views.UserChildren.ShowView(model: user_child)
    $("#user_children").html(@view.render().el)

  edit: (id) ->
    user_child = @user_children.get(id)

    @view = new MsRobot.Views.UserChildren.EditView(model: user_child)
    $("#user_children").html(@view.render().el)
