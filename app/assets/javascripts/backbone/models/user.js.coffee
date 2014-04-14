class MsRobot.Models.User extends Backbone.Model
  paramRoot: 'user'
  url: '/users.json'

  defaults:
    id: null
    email: null
    type_user: null
    last_name: null
    first_name: null
    password: null

class MsRobot.Collections.UsersCollection extends Backbone.Collection
  model: MsRobot.Models.User
  url: '/users'
