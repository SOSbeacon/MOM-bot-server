MsRobot.Views.Menu ||= {}

class MsRobot.Models.MenuLeftItem extends Backbone.Model
  defaults:
    icon: null
    link: null
    text: null

class MsRobot.Collections.MenuLeftConllection extends Backbone.Collection
  model: MsRobot.Models.MenuLeftItem

class MsRobot.Views.Menu.MenuLeftItem extends Backbone.View
  template: JST["backbone/templates/menus/menuleftitem"]
  tagName: "li"

  events:
    "click" : "active"

  render: =>
    $(@el).html(@template(@model.toJSON()))
    return this

  active: (e) =>
    $("#nav-custom").find("li").removeClass("active")
    $(@el).addClass("active")

class MsRobot.Views.Menu.MenuLeftView extends Backbone.View
  template: JST["backbone/templates/menus/menuleft"]
  tagName: "ul"
  className: "nav nav-list"

  initialize: (options) ->
    @user = options.user
    if @user.get("type_user") == "parent"
      @collectionMenu = new MsRobot.Collections.MenuLeftConllection(MENU_LEFT_PARENT)
      @collectionMenu.bind("change", @render, this)
    else if @user.get("type_user") == "normal" || @user.get("type_user") == null
      @collectionMenu = new MsRobot.Collections.MenuLeftConllection(MENU_LEFT_USER)
      @collectionMenu.bind("change", @render, this)

  render: =>
    $(@el).html(@template())
    @collectionMenu.each((model, index) =>
      view = new MsRobot.Views.Menu.MenuLeftItem({model:model})
      $(@el).append(view.render().el)
    )

    setTimeout((=>
      if location.hash != ''
        $('a[href="'+location.hash+'"]').parent().addClass("active")
    ), 100)
    return this


class MsRobot.Views.Menu.MenuView extends Backbone.View
  template: JST['backbone/templates/menus/menu']
  className: "menu-view"

  render: =>
    $(@el).html(@template(@model.toJSON()))
    return this



