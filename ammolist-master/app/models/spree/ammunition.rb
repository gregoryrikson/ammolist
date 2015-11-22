class Spree::Ammunition < ActiveRecord::Base
  #default_scope -> { order("position ASC") }

  validates_presence_of :title
  validates_presence_of :body

  has_many :product, class_name: 'Spree::Product'

end
