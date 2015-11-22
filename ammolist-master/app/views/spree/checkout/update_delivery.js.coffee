partial = "<%=j render :partial => 'shipping_upgrade_form', :format => :html, :locals => { :ship_id => @shipment.id, :ship_form_id => @ship_form_index, :ship_upgrade_opts => @shipment.shipment_upgrades_options } %>"
elem = ($ '#shipping_upgrade_<%= @ship_form_index %>')
replace_delivery_part(elem, partial)