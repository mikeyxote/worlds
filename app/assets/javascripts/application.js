// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require bootstrap-datepicker
//= require underscore
//= require gmaps/google
//= require turbolinks



//= require_tree .

$(document).ready(function(){
    $('.dropdown').mouseenter(function(){
        $(event.currentTarget).find('.dropdown-menu').toggle();
    })
    $('.dropdown').mouseleave(function() {
        $(event.currentTarget).find('.dropdown-menu').hide();
    })
    $('.dropdown-menu').mouseleave(function(){
        $('dropdown-menu').hide();
    })
  $("#segment_search").on("keyup", function() {
    var value = $(this).val().toLowerCase();
    $("#segment_table tr").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
  });
  $(function() {
    $('a#eventBuilder').click(function(event) {
     event.preventDefault();
     $('div#eventBuilder').toggle(1500);
    });
  });
 $(function() {
     $('a#edit-toggle').click(function(event) {
      event.preventDefault();
      $('div#show-event').toggle(1000);   
      $('div#edit-event').toggle(1000);
     });
 })
});

