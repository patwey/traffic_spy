class App < ActiveRecord::Base
  validates_presence_of :identifier, :root_url
end
