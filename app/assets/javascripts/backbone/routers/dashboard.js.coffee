class MsRobot.Routers.DashboardRouter extends Backbone.Router
  el: ("#content")

  initialize: (options) =>
    @session = new MsRobot.Models.Session()
    @session.save({"user_id" : options.user.id, "authentication_token" : options.user.authentication_token, "type_user": options.user.type_user})
    @user = new MsRobot.Models.User(options.user)

    menuView = new MsRobot.Views.Menu.MenuView({model:@user})
    $("#menu-bar").html(menuView.render().el)

    menuLeft = new MsRobot.Views.Menu.MenuLeftView({user:@user})
    $("#nav-custom").html menuLeft.render().el

  routes:
    "" : "showIndex"
    "parents" : "showParent"
    "events" : "showEvent"
    "profile" : "showProfile"
    "group_contacts" : "showGroupContact"
    "group_contacts/:id" : "showGroupDetail"

  swap: (newView, args) =>
    if @currentView
      @currentView.close()

    @currentView = new newView(args)
    $(@el).html(@currentView.render().el)

  showIndex: =>
    @swap(MsRobot.Views.Index.IndexViewApp)

  showParent: =>
    @swap(MsRobot.Views.Users.ParentViewApp)

  showEvent: =>
    @swap(MsRobot.Views.Events.EventViewApp)

  showProfile: =>
    @swap(MsRobot.Views.Users.ProfileApp, @user)

  showGroupContact: =>
    @swap(MsRobot.Views.GroupContacts.GroupContactViewApp)

  showGroupDetail: (id) =>
    @swap(MsRobot.Views.Contacts.ContactViewApp, {id:id})
