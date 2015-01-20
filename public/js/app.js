(function(){
	if ( garage.vms ) {
		for (var n = 0; n < garage.vms.length; n++) {
			var vm_id  = '#vm-' + garage.vms[n].id;
			var elem = document.querySelector( vm_id );
			elem.onclick = function() {
				garage.selected_vm = garage.search(this.id.replace('vm-',''));
				var detail_panel = document.querySelector('#vm-detail div div');
				detail_panel.querySelector('.vm-detail-ID').innerText = garage.selected_vm.id;
			}
		}
	}

	$('.destroy-vm-btn').click(function(){
		garage.destroy( garage.selected_vm.id );
	});

	$('#vagrantfile-save-btn').click(function(){
		garage.new_vm();
	});

	$('.vagrant-up-btn').click(function(){
		var selected_index = $(this).find('.vagrantfile-data-index').val();
		garage.up( garage.files[selected_index] );
	});

	$(document).ready(function(){

		$("select").select2({dropdownCssClass: 'dropdown-inverse'});

		var $slider = $("#slider");
		if ($slider.length > 0) {
		  $slider.slider({
		    min: 0,
		    max: 4,
		    value: 2,
		    orientation: "horizontal",
		    range: "min",
		    change: function(event, slider) {
		    	$("#form-vm-memory").val(slider.value * 256);
		    }
		  });
		}
	});
})();