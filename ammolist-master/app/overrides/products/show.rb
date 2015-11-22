Deface::Override.new(virtual_path: 'spree/products/show',
                     name: 'add_qna_to_product',
                     insert_bottom: '[data-hook="product_right_part"]',
                     partial: 'spree/products/qna')
