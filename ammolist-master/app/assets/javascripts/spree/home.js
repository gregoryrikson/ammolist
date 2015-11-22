$(document).ready(function () {
	var table = null;
	$("#add-to-cart-button").hide();
	$("#loading-time").hide();
	$("#loading-icon").hide();
	$("#step_1").show(0, blinkElement("#step_1"));
	$("#step_2").hide();
	$("#email-me").hide();

	var properties = {
	  5: ["quantity", "Quantity"],
	  6: ["manufacturer", "Manufacturer"],
	  7: ["use_type", "Use Type"],
	  8: ["bullet_type", "Bullet Type"],
	  9: ["bullet_weight", "Bullet Weight"],
	  10: ["ammo_casing", "Ammo Casing"],
	  11: ["primer_type", "Primer Type"],
	  12: ["condition", "Condition"]
	};

	var selectedTaxons = [];
	var appliedProperties = [];
	var priceColumnIdx = 2;
	var inStockColumnIdx = 13;
	var inStockColumnName = "in_stock";
	var existedTaxons = [];
	var taxonColumnId = 14;
	var taxonColumnName = "taxon_id";
	var timerStart = Date.now();

	var numbersRange = [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,8],[8,9],[9,10]];
	var tensRange = $.map( numbersRange, function( value, id ) { return [$.map( value, function( val, i ) { return val * 10; })]; });
	var hundredsRange = $.map( numbersRange, function( value, id ) { return [$.map( value, function( val, i ) { return val * 100; })]; });
	var thousandsRange = $.map( numbersRange, function( value, id ) { return [$.map( value, function( val, i ) { return val * 1000; })]; });

	var dollarTensRangeRegex = [/^\$(\d(\.\d+)*|10(\.0+)*)$/, /^\$(1\d(\.\d+)*|20(\.0+)*)$/, /^\$(2\d(\.\d+)*|30(\.0+)*)$/, /^\$(3\d(\.\d+)*|40(\.0+)*)$/, /^\$(4\d(\.\d+)*|50(\.0+)*)$/, /^\$(5\d(\.\d+)*|60(\.0+)*)$/, /^\$(6\d(\.\d+)*|70(\.0+)*)$/, /^\$(7\d(\.\d+)*|80(\.0+)*)$/, /^\$(8\d(\.\d+)*|90(\.0+)*)$/, /^\$(9\d(\.\d+)*|100(\.0+)*)$/];
	var dollarHundredsRangeRegex = [/^\$(\d{1,2}(\.\d+)*|100(\.0+)*)$/, /^\$(1\d\d(\.\d+)*|200(\.0+)*)$/, /^\$(2\d\d(\.\d+)*|300(\.0+)*)$/, /^\$(3\d\d(\.\d+)*|400(\.0+)*)$/, /^\$(4\d\d(\.\d+)*|500(\.0+)*)$/, /^\$(5\d\d(\.\d+)*|600(\.0+)*)$/, /^\$(6\d\d(\.\d+)*|700(\.0+)*)$/, /^\$(7\d\d(\.\d+)*|800(\.0+)*)$/, /^\$(8\d\d(\.\d+)*|900(\.0+)*)$/, /^\$(9\d\d(\.\d+)*|1000(\.0+)*)$/];
	var dollarThousandsRangeRegex = [/^\$(\d{1,3}(\.\d+)*|1000(\.0+)*)$/, /^\$(1\d\d\d(\.\d+)*|2000(\.0+)*)$/, /^\$(2\d\d\d(\.\d+)*|3000(\.0+)*)$/, /^\$(3\d\d\d(\.\d+)*|4000(\.0+)*)$/, /^\$(4\d\d\d(\.\d+)*|5000(\.0+)*)$/, /^\$(5\d\d\d(\.\d+)*|6000(\.0+)*)$/, /^\$(6\d\d\d(\.\d+)*|7000(\.0+)*)$/, /^\$(7\d\d\d(\.\d+)*|8000(\.0+)*)$/, /^\$(8\d\d\d(\.\d+)*|9000(\.0+)*)$/, /^\$(9\d\d\d(\.\d+)*|10000(\.0+)*)$/];


	function initFilter(){
	  getUserAmmolist();
	  setTimeout(function(){
	    if (selectedTaxons.length > 0){
	      $.each(selectedTaxons, function( index, value ) {
	        $(".taxon_check#taxon_ids_"+value).prop('checked', true);
	      });
	      initRows();
	    }
	  }, 1500);
	}

	initFilter();

	function reloadFilter(){  
	  if (appliedProperties.length > 0){  
	    if (appliedProperties[inStockColumnIdx]){
	      table.column(inStockColumnIdx).search("1");
	    }
	    redrawTableByAllProperties();
	    redrawTableByPrice();
	  }
	}

	function blinkElement(elemID){
	  for(i=0;i < 10;i++) {
	    $(elemID).fadeTo('fast', 0.5).fadeTo('fast', 1).delay(500);
	  }
	}

	function generatePriceFilter(priceData){  
	  if (appliedProperties[priceColumnIdx]){
	    var inText = "<h2 class='home-h2'>Price Range</h2>";
	    inText = inText + "<ul>";
	    $.each(appliedProperties[priceColumnIdx], function( index, value ) {
	      inText = inText + "<li><input name='filter' id='"+index+"' class='filter_price' type='checkbox' data-value='"+value[0]+"' data-display='"+value[1]+"' checked/><h3 class='home-h3'>"+value[1]+"</h3>";
	    });
	    inText = inText + "</ul>";
	    $("#list-properties").append(inText);
	  }else{
	    //slice currency '$'
	    var data = $.map( priceData, function( value, id ) { return ( value.slice(1) ); });
	    var maxPrice = Math.max.apply(Math, data);
	    var priceRange = tensRange;
	    var regexRange = dollarTensRangeRegex;
	    if (maxPrice > 1000){
	      priceRange = thousandsRange;
	      regexRange = dollarThousandsRangeRegex;
	    }else if (maxPrice > 100){
	      priceRange = hundredsRange;
	      regexRange = dollarHundredsRangeRegex;
	    }

	    var filteredPriceRange = [];
	    $.each(priceRange, function( index, value ) {
	      $.each(data, function( id, val ) {
	        if (value[0]<= val && val <= value[1]){
	          filteredPriceRange[index] = value;
	          return false;
	        }
	      });
	    });
	    //array exclude empty string
	    var filteredPriceRangeCopy = filteredPriceRange.slice();
	    var validFilteredPriceRange = $.grep(filteredPriceRangeCopy, function(n, i){
	      return (n != "undefined" && n != null && n != "");
	    });
	    var inText = "";
	    var hadTitle = false;
	    $.each(filteredPriceRange, function( index, value ) {
	      if (value != null){
	        if (!hadTitle){
	          inText = inText + "<h2 class='home-h2'>Price Range</h2>";
	          inText = inText + "<ul>";
	          if (validFilteredPriceRange.length > 1){
	            inText = inText + "<li><input name='filter_all' class='all_price_filter' type='checkbox' value='all'/><h3 class='home-h3'><b>All Prices Filter</b></h3></li>";
	          }
	          hadTitle = true;
	        }

	        inText = inText + "<li><input name='filter' id='"+index+"' class='filter_price' type='checkbox' data-value='"+regexRange[index]+"' data-display='$"+value[0].toFixed(2)+" - $"+value[1].toFixed(2)+"'/><h3 class='home-h3'>$"+value[0].toFixed(2)+" - $"+value[1].toFixed(2)+"</h3>";
	        inText = inText + "</li>";    
	      }  
	    });
	    if (hadTitle){
	      inText = inText + "</ul>";
	    }
	    $("#list-properties").append(inText);
	  }
	}

	function filterChangeEvent(){
	  $.each(properties, function( index, value ) {
	    var columnName = value[0];
	    $("."+columnName).bind("change", function(){
	      timerStart = Date.now();
	      redrawTableByProperty(index, columnName);
	      setLoadingTime();
	      uncheckAllPropertyFilter(index);
	      updateUserAmmolist();
	    });
	  });

	  $(".filter_price").bind("change", function(){
	    timerStart = Date.now();
	    redrawTableByPrice();
	    setLoadingTime();
	    uncheckAllPriceFilter();
	    updateUserAmmolist();
	  });

	  $(".property_filter").bind("change", function(){
	    timerStart = Date.now();
	    var propertyIdx = $(this).val();
	    var columnName = properties[propertyIdx][0];
	    if($(this).is(":checked")) {
	      $("."+columnName).each(function() {
	        $(this).prop('checked', true);
	      });
	    }else{
	      $("."+columnName).each(function() {
	        $(this).prop('checked', false);
	      });
	    }
	    redrawTableByProperty(propertyIdx, columnName); 
	    setLoadingTime();
	    updateUserAmmolist();
	  });

	  $(".all_price_filter").bind("change", function(){
	    timerStart = Date.now();
	    if($(this).is(":checked")) {
	      $(".filter_price").each(function() {
	        $(this).prop('checked', true);
	      });
	    }else{
	      $(".filter_price").each(function() {
	        $(this).prop('checked', false);
	      });
	    }
	    redrawTableByPrice();
	    setLoadingTime();
	    updateUserAmmolist();
	  });

	  $(".in_stock_filter").bind("change", function(){
	    timerStart = Date.now();
	    var val = "";
	    if($(this).is(":checked")) {
	      val = 1;
	      appliedProperties[inStockColumnIdx] = val;
	    }else{      
	      delete appliedProperties[inStockColumnIdx];
	    }    
	    table.column(inStockColumnIdx).search(val).draw();
	    setLoadingTime();
	    updateUserAmmolist();
	  });

	}

	function redrawTableByProperty(index, columnName){
	  removeFilter(index);
	  var regex = '';
	  var number = 0;
	  appliedProperties[index] = [];
	  $("."+columnName).each(function() {
	    if($(this).is(":checked")) {
	      var value = $.fn.dataTable.util.escapeRegex($(this).val());
	      regex = regex + "^"+value+"$|";
	      appliedProperties[index][number] = $(this).val();
	      number++;
	    }
	  });

	  if (regex != ''){
	    //remove last "|" char
	    regex = regex.substr(0, regex.length-1); 
	    table.column(index).search(regex, true, false).draw();
	  }else{
	    removeFilter(index);
	  }
	}

	function redrawTableByAllProperties(){
	  $.each(properties, function( index, value ) {
	    var columnName = value[0];
	    redrawTableByProperty(index, columnName);
	  });
	}

	function redrawTableByPrice(){
	  var regex = '';
	  removeFilter(priceColumnIdx);
	  var number = 0;
	  appliedProperties[priceColumnIdx] = [];
	  $(".filter_price").each(function() {
	    if($(this).is(":checked")) {
	      var str = this.getAttribute('data-value');
	      appliedProperties[priceColumnIdx][number] = [];
	      regex = regex + "^"+str.substr(1, str.length-2)+"$|";
	      appliedProperties[priceColumnIdx][number][0] = str;
	      appliedProperties[priceColumnIdx][number][1] = this.getAttribute('data-display');
	      number++;
	    }
	  });
	  if (regex != ''){
	    //remove last "|" char
	    regex = regex.substr(0, regex.length-1);
	    table.column(priceColumnIdx).search(regex, true, false).draw();
	  }else{
	    removeFilter(priceColumnIdx);  
	  }
	}

	function redrawTableByTaxons(){
	  var regex = '';
	  removeFilter(taxonColumnId);
	  $.each(getSelectedTaxons(), function( index, value ) {
	    regex = regex + "^"+value+"$|";
	  });
	  if (regex != ''){
	    //remove last "|" char
	    regex = regex.substr(0, regex.length-1);
	    table.column(taxonColumnId).search(regex, true, false).draw();
	  }else{
	    var dummyId = 99999;
	    table.column(taxonColumnId).search(dummyId).draw();
	  }
	}

	function showTableProperties(){
	  $("#add-to-cart-button").show();
	  $("#loading-time").show();
	  $("#step_2").stop(true, true).hide();
	}

	function hideTableProperties(){
	  $("#add-to-cart-button").hide();
	  $("#loading-time").hide();
	}

	function changeFilterProperties(){
	  $("#step_1").stop(true, true).hide();
	  $("#step_2").show(0, blinkElement("#step_2"));
	}

	function uncheckAllPropertyFilter(index){
	  $(".property_filter").each(function() {
	    if ($(this).val() == index ){
	      $(this).prop('checked', false);
	    }
	  });
	}

	function uncheckAllPriceFilter(){
	  $(".all_price_filter").prop('checked', false);
	}

	function generateFilter(){
	  var productsData = table.data().toArray();
	  var hadFilter = false;

	  //clear area
	  $("#in_stock_filter").empty();
	  $("#list-properties").empty();
	  $("#email-me").hide();

	  $.each(properties, function( index, value ) {
	    var includedProperties = [];
	    var columnName = value[0];
	      if (productsData.length > 0){
	        $.each(productsData, function ( idx, val ) {
	          if (!(typeof val === "undefined") && (val[columnName] != null) && (val[columnName] != "") && (val[inStockColumnName] == 1)) {
	            includedProperties.push(val[columnName]);
	          };
	        });
	        if (includedProperties.length > 0){
	          var inText = "";
	          if (!hadFilter){
	            hadFilter = true;
	          }
	          inText = inText + "<h2 class='home-h2'>"+value[1]+"</h2>";
	          inText = inText + "<ul>";
	          var includedPropCopy = includedProperties.slice();
	          if (columnName == "quantity"){
	            var sortedPropCopy = includedPropCopy.sort((function(a, b){return a-b}));
	          }else if (columnName == "bullet_weight"){
	            regex = /\d{1,5}/
	            var sortedPropCopy = includedPropCopy.sort((function(a, b){return a.match(regex)-b.match(regex)}));
	          }else{            
	            var sortedPropCopy = includedPropCopy.sort();
	          }
	          var filterUniqueData = $.unique(sortedPropCopy);
	          if (filterUniqueData.length > 1){
	            var allChecked = "";
	            if (appliedProperties[index]){
	              if (filterUniqueData.length == appliedProperties[index].length){                  
	                allChecked = "checked";
	              }
	            }
	            inText = inText + "<li><input name='filter_all' class='property_filter' type='checkbox' value='"+index+"' "+allChecked+"/><h3 class='home-h3'><b>All "+value[1]+"</b></h3></li>";
	          }
	          $.each(filterUniqueData, function (idx, val) {
	            var thisChecked = "";
	            if (appliedProperties[index]){
	              if (appliedProperties[index].indexOf(val) != -1){
	                thisChecked = "checked";
	              }
	            }
	            inText = inText + "<li><input name='filter' class='"+columnName+"' type='checkbox' value='"+val+"' "+thisChecked+"/><h3 class='home-h3'>"+val+"</h3>";
	            
	            inText = inText + "</li>";
	          });
	          inText = inText + "</ul>";
	          $("#list-properties").append(inText);
	        }
	      }
	    });

	  //price filtering
	  if (productsData.length > 0){
	    var priceData = [];
	    var columnName = "price";
	      $.each(productsData, function ( idx, val ) {
	        if (!(typeof val === "undefined") && (val[columnName] != null) && (val[columnName] != "") && (val[inStockColumnName] == 1)) {
	          priceData.push(val[columnName]);
	        };
	      });
	    if (priceData.length > 0) {
	      if (!hadFilter){
	        hadFilter = true;
	      }
	      generatePriceFilter(priceData);
	    }
	  }

	  if (hadFilter){
	    changeFilterProperties();
	    //in-stock filtering
	    var inStockCheck = "";
	    if (appliedProperties[inStockColumnIdx]){
	      inStockCheck = "checked";
	    }
	    $("#in_stock_filter").append("<input name='in_stock' class='in_stock_filter' type='checkbox' value='"+inStockColumnName+"' "+inStockCheck+"/><h3 class='home-h3'><b>In Stock Ammunition</b></h3>");
	    filterChangeEvent();
	    $("#email-me").show();
	  }else{  
	    $('#products_list > tbody').html('<tr class="odd"><td class="dataTables_empty" colspan="5" valign="top"><h2><%= t(:ammunition_out_of_stock) %></h2></td></tr>');
	    $("#in_stock_filter").append("<h3 class='home-h3'><b><%= t(:ammunition_out_of_stock)%></b></h3>");
	  }

	  if (productsData.length > 0){
	    showTableProperties();
	  }
	}


	function removeFilter(index){
	  table.column(index).search("").draw();
	  delete appliedProperties[index];
	}

	function getSelectedTaxons() {
	  var taxons=[];
	  $(".taxon_check:checked").each(function(){
	    if ($.inArray(this.value, taxons) == -1){
	      taxons.push(this.value);
	    }
	  });
	  return taxons;
	}

	$(".taxon_check").bind('change', function(){
	  timerStart = Date.now();
	  if ($(this).is(":checked")) {
	    //check all same taxon_check
	    var checkedValue = $(this).val();
	    $(".taxon_check[value="+checkedValue+"]").prop('checked', true);
	    //add rows
	    addRows(checkedValue);
	  }else{
	    //uncheck all same taxon_check
	    $(".taxon_check[value="+$(this).val()+"]").prop('checked', false);
	    //redraw with selected taxons filter
	    redrawTableByTaxons();
	    setLoadingTime();
	  }
	  updateUserAmmolist();
	});

	function setLoadingTime(){  
	  var loadingTime = (Date.now() - timerStart)/1000;
	  $("#loading-time").find('span').html(loadingTime);
	}

	function addRows(taxon_id){
	  //if taxon data has existed
	  if(existedTaxons.length > 0 && $.inArray(taxon_id, existedTaxons) > -1) {
	    redrawTableByTaxons();
	    setLoadingTime();
	  }else{
	    $("#loading-icon").show();
	    $("#loading-time").hide();
	    //update taxon point
	    $.ajax({
	      url: Spree.routes.taxon_update_point, 
	      dataType: "script",
	      data: { id: taxon_id }
	    });

	    $("#step_2").stop(true, true).hide();

	    $.ajax({
	      url: Spree.routes.taxons_products, 
	      data: { 
	        id: taxon_id
	      },
	      dataType: "json",
	      success: function(data) {
	        generateData(data);
	        existedTaxons.push(taxon_id);
	        redrawTableByTaxons();
	        setLoadingTime();

	        hideTableProperties();
	        $("#loading-icon").hide();
	        setTimeout(function(){
	          generateFilter();
	        }, 1000);

	        return true;
	      }
	    });
	  }
	}

	function initRows(){
	  timerStart = Date.now();
	  $("#loading-icon").show();
	  $("#step_2").stop(true, true).hide();
	  $("#list-properties").empty();
	  $("#in_stock_filter").empty();

	  //update table products list
	  taxons = getSelectedTaxons();
	  if (taxons.length > 0){
	    $.ajax({
	      url: Spree.routes.taxons_products, 
	      data: { 
	        id: taxons
	      },
	      dataType: "json",
	      success: function(data) {
	        generateData(data);
	        $.each(taxons, function( index, value ) {
	          existedTaxons.push(value);
	        });
	        redrawTableByTaxons();
	        setLoadingTime();

	        hideTableProperties();
	        $("#loading-icon").hide();
	        setTimeout(function(){
	          generateFilter();
	        }, 1000);
	        return true;
	      }
	    });
	  }
	}

	function generateData(data){
	  if (table == null){
	    table = $('#products_list').DataTable({
	      "paging": false,
	      "data": data,
	      "columns": [
	        { 
	          "data": null,
	          "width": "7%",
	          "orderable": false,
	          "render": function ( data, type, full, meta ) {
	            return '<a class="ajax-popup-white-block" href="taxons/taxon_product_info?id='+data.id+'" title="Click here to enlarge image">'+data.mini_img_url+'</a>';
	          } 
	        },
	        { 
	          "data": null,
	          "width": "55%",
	          "render": function ( data, type, full, meta ) {
	            return '<a href="'+data.url+'">'+data.name+'</a>';
	          } 
	        },
	        {
	          "data": "price",
	          "width": "12%" 
	        },
	        { 
	          "data": "perround",
	          "width": "12%" 
	        },
	        { 
	          "data": null,
	          "width": "14%",
	          "render": function ( data, type, full, meta ) {
	            if (data.in_stock == 0 ){
	              return '<%= Spree.t(:out_of_stock) %>';
	            }else{
	              return '<input id="variant_id" name="variant_id['+data.id+']" type="hidden" value="'+data.master_id+'" /><input id="quantity" min="0" name="quantity['+data.id+']" type="number" value="0" class="list_item_quantity" /><div style="float: left;"><input type="button" value="+" class="qtyplus" field="quantity['+data.id+']" /><input type="button" value="-" class="qtyminus" field="quantity['+data.id+']" /></div>';
	            }
	          } 
	        },
	        { 
	          "name": properties[5][1],
	          "data": properties[5][0],
	          "visible": false
	        },
	        { 
	          "name": properties[6][1],
	          "data": properties[6][0],
	          "visible": false
	        },
	        { 
	          "name": properties[7][1],
	          "data": properties[7][0],
	          "visible": false
	        },
	        { 
	          "name": properties[8][1],
	          "data": properties[8][0],
	          "visible": false
	        },
	        { 
	          "name": properties[9][1],
	          "data": properties[9][0],
	          "visible": false
	        },
	        { 
	          "name": properties[10][1],
	          "data": properties[10][0],
	          "visible": false
	        },
	        { 
	          "name": properties[11][1],
	          "data": properties[11][0],
	          "visible": false
	        },
	        { 
	          "name": properties[12][1],
	          "data": properties[12][0],
	          "visible": false
	        },
	        { 
	          "data": inStockColumnName,
	          "visible": false
	        },
	        { 
	          "data": taxonColumnName,
	          "visible": false
	        }
	      ],
	      "order": [ [ 4, "asc" ], [ 2, "asc" ] ],
	      "initComplete": function(settings, json) {
	        hideTableProperties();
	        setTimeout(function(){
	          $('#step_1').stop(true, true).hide();
	          //restrict first filter is in stock
	          appliedProperties[inStockColumnIdx] = 1;
	          generateFilter();
	          //appliedProperties[inStockColumnIdx] = 1;
	          //table.column(inStockColumnIdx).search(1).draw();
	          reloadFilter();
	        }, 1000);
	      }
	    });

	    table.on('draw', function () {
	        $('.ajax-popup-white-block').magnificPopup({
	          type: 'ajax',
	          callbacks: {
	            parseAjax: function(mfpResponse) {
	              mfpResponse.data = '<div class="white-popup-block">'+mfpResponse.data+'</div>';
	            }
	          }
	        });
	    });
	  }else{
	    table.rows.add(data).draw();
	  }
	}

	function updateUserAmmolist(){
	  $.ajax({
	    url: Spree.routes.update_user_ammolist, 
	    data: { 
	      user_id: '<%= spree_current_user.id.to_json if spree_current_user %>',
	      user_email: '<%= spree_current_user.email if spree_current_user %>',
	      selected_taxons: JSON.stringify(getSelectedTaxons()),
	      applied_properties: JSON.stringify(appliedProperties)
	    }
	  });
	}

	function getUserAmmolist(){
	  $.ajax({
	    url: Spree.routes.get_user_ammolist, 
	    data: { 
	      user_id: '<%= spree_current_user.id.to_json if spree_current_user %>'
	    },
	    dataType: "json",
	    success: function(data) {
	      selectedTaxons = JSON.parse(data.taxons_id);
	      appliedProperties = JSON.parse(data.applied_properties);
	      return true;
	    }
	  });
	}

	$( "#ammolist-register" ).validate({
	    rules: {
	      email: {
	        required: true,
	        email: true
	      }
	    }
	  });
	  $('#ammolist-register').submit(function(e){
	    var isvalidate=$(this).valid();
	    if(isvalidate)
	    {
	      e.preventDefault();
	      //setup variables
	      var form = $(this),
	      formUrl = Spree.routes.subscribe_user_ammolist,
	      formMethod = form.attr('method'),
	      responseMsg = $('#register-response'),
	      formData = { 
	          user_id: '<%= spree_current_user.id.to_json if spree_current_user %>',
	          user_email: $('#ammolist-register input[id=email]').val(),
	          selected_taxons: JSON.stringify(getSelectedTaxons()),
	          applied_properties: JSON.stringify(appliedProperties)
	        }

	      //show response message - waiting
	      responseMsg.hide()
	                 .removeClass()
	                 .addClass('response-waiting')
	                 .text('Please Wait...')
	                 .fadeIn(200);

	      //send data to server
	      $.ajax({
	        url: formUrl,
	        type: formMethod,
	        data: formData,
	        success:function(data){
	          //setup variables
	          var jsonData = $.parseJSON(data);
	          responseData = jsonData[0];
	          var klass = '';
	          //response conditional
	          switch(responseData.status){
	              case 'error':
	                  klass = 'response-error';
	              break;
	              case 'success':
	                  klass = 'response-success';
	              break; 
	          }
	          //show reponse message
	          responseMsg.fadeIn(200,function(){
	              $(this).removeClass()
	                 .addClass(klass)
	                 .text(responseData.message)
	                 .fadeIn(200)
	          });
	        }
	      })

	      //prevent form from submitting
	      //return false;
	  }
	})
	  
	$('#products_list').on('click', '.qtyplus', function(e) {
	  e.preventDefault();
	  var currentVal, fieldName;
	  fieldName = $(this).attr('field');
	  currentVal = parseInt($('input[name=\'' + fieldName + '\']').val());
	  if (!isNaN(currentVal)) {
	    $('input[name=\'' + fieldName + '\']').val(currentVal + 1);
	  } else {
	    $('input[name=\'' + fieldName + '\']').val(0);
	  }
	});

	$('#products_list').on('click', '.qtyminus', function(e) {
	  e.preventDefault();
	  var currentVal, fieldName;
	  fieldName = $(this).attr('field');
	  currentVal = parseInt($('input[name=\'' + fieldName + '\']').val());
	  if (!isNaN(currentVal) && currentVal > 0) {
	    $('input[name=\'' + fieldName + '\']').val(currentVal - 1);
	  } else {
	    $('input[name=\'' + fieldName + '\']').val(0);
	  }
	});

});


$(window).scroll(function(e) {
  var $cart_el;
  var $search_el;
  $cart_el = $('.affix_add-to-cart');
  $search_el = $('#products_list_filter');
  if ($(this).scrollTop() > 75 && $cart_el.css('position') !== 'fixed') {
    $cart_el.css({
      'position': 'fixed',
      'top': '0px',
      'box-shadow': '0px 5px 5px -4px #bcbcbc'
    });
    $search_el.css({
      'position': 'fixed',
      'top': '40px'
    });

  }
  if ($(this).scrollTop() < 75 && $cart_el.css('position') === 'fixed') {
    $cart_el.css({
      'position': 'relative',
      'top': '0px',
      'box-shadow': 'none'
    });
    $search_el.css({
      'position': 'absolute',
      'top': '-40px'
    });
  }
});