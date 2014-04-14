MsRobot.Views.Users ||= {}

class MsRobot.Views.Users.ProfileApp extends Backbone.View
  template: JST["backbone/templates/users/profile"]
  className: "profile"

  initialize: (options) =>
    @model = options
    @alert = new MsRobot.Views.Common.AlertView()

  events:
    "click #updateProfile" : "updateProfile"


  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this

  updateProfile: =>
    @alert.hideAlert()
    first_name = @$("#first-name").val().trim()
    last_name = @$("#last-name").val().trim()
    current_password = @$("#current-password").val().trim()
    new_pass = @$("#new-pass").val().trim()
    confirm_password = @$("#confirm-password").val().trim()

    if new_pass.length > 0
      if new_pass != confirm_password
        @alert.showAlert("", "New password and confirm password don't match", "alert-danger", "profile-alert")
        return this

      @model.save({
          password: new_pass
          password_confirmation: confirm_password
        },
        success: (response) =>
          @alert.showAlert("", "Update password successfully", "alert-success", "profile-alert")

        error: (jqXHR, textStatus, errorThrown) =>
          console.log textStatus
          if textStatus.status == 422
            @alert.showAlert("", "Current password is invalid", "alert-danger", "profile-alert")
          else if textStatus.status == 400
            @alert.showAlert("", textStatus.responseText, "alert-danger", "profile-alert")
      )

    else
      if !first_name
        @alert.showAlert("", "First name can't be blank", "alert-danger", "profile-alert")
        return this

      if !last_name
        @alert.showAlert("", "Last name can't be blank", "alert-danger", "profile-alert")
        return this

      @model.save({
        first_name: first_name
        last_name: last_name
      },
        success: (response) =>
          @alert.showAlert("", "Update profile successfully", "alert-success", "profile-alert")

        error: (jqXHR, textStatus, errorThrown) =>
          console.log textStatus
          if textStatus.status == 422
            @alert.showAlert("", "Current password is invalid", "alert-danger", "profile-alert")
      )

  close: =>
    this.remove()
    this.unbind()