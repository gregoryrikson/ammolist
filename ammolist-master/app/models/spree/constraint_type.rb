module Spree
  class ConstraintType < Spree::Base
    has_many :shipping_constraints, inverse_of: :shipping_method
    has_many :shipping_methods, through: :shipping_constraints
    accepts_nested_attributes_for :shipping_constraints
    attr_accessor :total
  end
end