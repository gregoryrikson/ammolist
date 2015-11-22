partial = "<%=j render :partial => 'summary', :format => :html, :locals => { :order => @order } %>"
elem = ($ "[data-hook='checkout_summary_box']")
replace_delivery_part(elem, partial)