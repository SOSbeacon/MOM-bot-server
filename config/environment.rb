# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

INTERVAL_DAILY = 86400000
INTERVAL_WEEKLY = 604800000
USER_TYPE_PARENT = 'parent'
USER_TYPE_NORMAL = 'normal'

TWILIO_SID = '***'
TWILIO_TOKEN = '***'
TWILIO_NUMBER = '***'


BASE_URL = "http://162.242.174.218/"