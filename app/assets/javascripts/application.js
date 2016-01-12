// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui/datepicker
//= require jquery_ujs
//= require turbolinks
//= require_tree .
//= require foundation

$(document).foundation();
$(function() {
  $('#start_date').datepicker( {
    onSelect: function(date) {
      $(this).val(date)
    }
  });

  $('#end_date').datepicker( {
    onSelect: function(date) {
      $(this).val(date)
    }
  });

  $(function() {
    $("#next").on("click", function() {
      bow = $("#bow").text();
      eow = $("#eow").text();
      week_dates = { next: true, bow: bow, eow: eow }

      debugger;
      $.ajax({
        method: 'GET',
        url: $("#controls").data("url"),
        data: { week_dates: week_dates },
        success: function(data) {
          $($("#controls").data("refresh-container")).html(data);
        }
      });
    });
  });
});
