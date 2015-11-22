Deface::Override.new(:virtual_path => 'spree/admin/products/_form',
  :name => 'add_sale_price_to_product_edit',
  :insert_after => "erb[loud]:contains('text_field :meta_description')",
  :text => "
    <div data-hook='admin_product_form_ammunition'>
        <%= f.field_container :ammunition, class: ['form-group'] do %>
          <%= f.label :ammunition_id, Spree.t(:ammunitions) %>
          <%= f.collection_select(:ammunition_id, @ammunitions, :id, :title, { include_blank: Spree.t('match_choices.none') }, { class: 'select2', disabled: (cannot? :edit, Spree::Ammunition) }) %>
          <%= f.error_message_on :ammunition %>
        <% end %>
    </div>
  ")
