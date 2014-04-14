MsRobot.Views.Users ||= {}

class MsRobot.Views.Users.ParentItem extends MsRobot.Views.Skel.ListItemView
  template: JST["backbone/templates/users/parent-item"]

  events:
    "click .edit-parent" : "editParent"
    "click .delete-parent" : "deleteParent"

  editParent: =>
    console.log @model
    view = new MsRobot.Views.Users.ParentFormView({model: @model, collection: @collection})
    $('body').append(view.render().el)
    $("#modal-form-parent").modal("show")

  deleteParent: =>
    proceed = confirm('Are you sure you want to delete?  This cannot be undone.')
    if proceed
      @model.url = =>
        "/users/#{@model.get('id')}.json?auth_token=#{@session.get('authentication_token')}"

      @model.destroy({
        success: =>
          @alert.hideAlert()
          @alert.showAlert("", "Delete group successfully", "alert-success")
      })

class MsRobot.Views.Users.ParentListHeader extends MsRobot.Views.Skel.ListItemHeader
  template: JST["backbone/templates/users/parent-list-header"]


class MsRobot.Views.Users.ParentShowView extends MsRobot.Views.Skel.ListView
  template: JST["backbone/templates/users/show-parent"]
  itemView: MsRobot.Views.Users.ParentItem
  headerView: MsRobot.Views.Users.ParentListHeader


class MsRobot.Views.Users.ParentFormView extends Backbone.View
  template: JST["backbone/templates/users/form"]
  className: "modal"
  id: "modal-form-parent"

  initialize: (options) =>
    @session = new MsRobot.Models.Session()
    @alert = new MsRobot.Views.Common.AlertView()
    @collection = options.collection
    $("#modal-form-parent").remove()

  events:
    "click #submit" : "createNewParent"
    "click .change_password" : "enablePassword"

  render: =>
    $(@el).html(@template(@model.toJSON()))
    return this

  enablePassword: =>
    if @model.get("id")
      @$("#password").removeAttr("disabled").focus()

  createNewParent: (e) =>
    first_name = @$("#first_name").val().trim()
    last_name = @$("#last_name").val().trim()
    email = @$("#email").val().trim()
    password = @$("#password").val().trim()

    if !first_name
      @alert.hideAlert()
      @alert.showAlert("", "First Name can't be blank", "alert-danger", "parent-alert")
      return this

    if !email
      @alert.hideAlert()
      @alert.showAlert("", "Email can't be blank", "alert-danger", "parent-alert")
      return this

    if !validateEmail(email)
      @alert.hideAlert()
      @alert.showAlert("", "Email invalid format", "alert-danger", "parent-alert")
      return this

    that = this
    if @model.get("id")
      data_url = "/users/#{@model.get('id')}.json?auth_token=#{@session.get('authentication_token')}"
      data_type = "PUT"

      data_post = {
        user: {
          email: email
          password: password
          first_name: first_name
          last_name: last_name
        }
      }

      $.ajax
        type: data_type
        url: data_url
        data: data_post
        success: (response) ->
          that.model.set(response)
          $("#modal-form-parent").modal("hide")
          that.alert.hideAlert()
          that.alert.showAlert("", "Update parent successfully", "alert-success")

        error: (jqXHR, textStatus, errorThrown) ->
          that.alert.hideAlert()
          that.alert.showAlert("", JSON.parse(jqXHR.responseText), "alert-danger", "parent-alert")

    else
      data_url = "/users/create_parent.json?auth_token=#{@session.get('authentication_token')}"
      data_type = "POST"

      if !password
        @alert.hideAlert()
        @alert.showAlert("", "Password can't be blank", "alert-danger", "parent-alert")
        return this

      data_post = {
        user: {
          email: email
          password: password
          first_name: first_name
          last_name: last_name
        }
      }

      $.ajax
        type: data_type
        url: data_url
        data: data_post
        success: (response) ->
          that.model.set(response)
          that.collection.add(that.model)
          $("#modal-form-parent").modal("hide")
          that.alert.hideAlert()
          that.alert.showAlert("", "Create parent successfully", "alert-success")

        error: (jqXHR, textStatus, errorThrown) ->
          that.alert.hideAlert()
          that.alert.showAlert("", JSON.parse(jqXHR.responseText), "alert-danger", "parent-alert")


class MsRobot.Views.Users.ParentViewApp extends MsRobot.Views.Skel.CollectionView
  template: JST["backbone/templates/users/parent"]

  initialize: =>
    @session = new MsRobot.Models.Session()
    @alert = new MsRobot.Views.Common.AlertView()
    @collection = new MsRobot.Collections.UsersCollection()
    @collection.url = =>
      "/users/list_parent.json?auth_token=#{@session.get('authentication_token')}"

    @listView = new MsRobot.Views.Users.ParentShowView({collection:@collection})

  events:
    "click #create-parent" : "showModal"

  showModal: =>
    model = new MsRobot.Models.User()
    view = new MsRobot.Views.Users.ParentFormView({model:model, collection:@collection})

    $(@el).append(view.render().el)
    $("#modal-form-parent").modal("show")