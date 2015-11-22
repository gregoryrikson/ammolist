partial = "<%=j render :partial => 'form', :locals => { :order => @order } %>"
parent = ($ '#cart_items')
replace_line_items(parent, partial)