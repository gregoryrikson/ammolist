Spree::Product.class_eval do
    belongs_to :ammunition, class_name: 'Spree::Ammunition'
    has_many :questions
end
