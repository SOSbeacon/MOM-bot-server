MsRobot.Views.Common ||= {}

class MsRobot.Views.Common.AlertView extends Backbone.View
  template: JST["backbone/templates/_commons/_alert"]
  className: "alertview"

  showAlert: (title, message, className, customClass) =>
    classCustom = customClass || ""
    if classCustom
      top_el = $("body").find('.' + classCustom)
    else
      top_el = $("body").find('.top-alert')

    @model = {
      'title': title,
      'message': message,
      'className': className
    }

    top_el.html(@template(@model))
    return this

  hideAlert: =>
#    $("body").find('.alert').hide()
    $("body").find('.top-alert').empty()
    $("body").find('.pj-alert').empty()

  showErrors: (errors) =>
    _.each errors, ((error) =>
      controlGroup = $("." + error.name)
      controlGroup.addClass('has-error')
      controlGroup.find(".help-inline").text error.message
    ), this

  hideErrors: =>
    $(".form-group").removeClass('has-error')
    $(".form-group").find('.help-inline').text ''
