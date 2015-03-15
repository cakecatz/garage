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

  $('[data-toggle="tooltip"]').tooltip()

  $('.destroy-vm-btn').click ->
  	garage.destroy garage.selected_vm.id

  $('#vagrantfile-save-btn').click ->
  	garage.newVagrantFile()

  $('.vagrant-up-btn').click ->
  	garage.up garage.vfiles[ this.dataset.selectIndex ]

  $('.delete-vfile-btn').click ->
  	garage.deleteVfile garage.vfiles[ this.dataset.selectIndex ]
  	garage._reloadVfileList()

# init garage
if garage.current_page == 'index'
	garage.startMonitoring()
	garage._clickPanelEvent()
