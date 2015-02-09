$ ->
	$('[data-toggle="tooltip"]').tooltip()

$('.destroy-vm-btn').click ->
	garage.destroy garage.selected_vm.id

$('#vagrantfile-save-btn').click ->
	garage.new_vfile()

$('.vagrant-up-btn').click ->
	garage.up garage.vfiles[ this.dataset.selectIndex ]

$('.delete-vfile-btn').click ->
	garage.delete_vfile garage.vfiles[ this.dataset.selectIndex ]

$(document).ready ->

	$("select").select2 {
    dropdownCssClass: 'dropdown-inverse'
  }

	$slider = $("#slider")
	if $slider.length > 0
	  $slider.slider {
	    min: 0,
	    max: 4,
	    value: 2,
	    orientation: "horizontal",
	    range: "min",
	    change: (event, slider) ->
	    	$("#form-vm-memory").val slider.value * 256
	  }

# init garage
if garage.current_page == 'index'
	garage.startMonitoring()
	garage._clickPanelEvent()
