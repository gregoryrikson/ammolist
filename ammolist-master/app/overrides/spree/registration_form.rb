Deface::Override.new(
  :virtual_path       => 'spree/checkout/registration',
  :name               => 'registration_future',
  :set_attributes     => '.columns.eight',
  :attributes         => {:class => 'six columns'})