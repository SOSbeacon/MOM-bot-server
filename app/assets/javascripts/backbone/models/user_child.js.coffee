class MsRobot.Models.UserChild extends Backbone.Model
  paramRoot: 'user_child'

  defaults:
    id: null
    email: null
    created_at: null
    updated_at: null

class MsRobot.Collections.UserChildrenCollection extends Backbone.Collection
  model: MsRobot.Models.UserChild
  url: '/user_children.json'
