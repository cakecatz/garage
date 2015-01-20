garage = {
	selected_vm: {},
	vms: {},
	search: function(vm_id) {
		if ( garage.vms ) {
			for (var i = 0; i < garage.vms.length; i++) {
				if ( garage.vms[i].id === vm_id ) {
					return garage.vms[i];
				}
			}
		}
		return false;
	},
	reload: function() {
		// TODO: use diff
		var body = '';
		for(var i = 0;i < this.vms.length;i++) {
			body += this.create_machine_panel(this.vms[i]);
		}
		this._panel_rewrite(body);
	},
	create_machine_panel: function(vm_info) {
		var body = '<div class="panel panel-' + this._vm_state_class(vm_info.state) + ' panel-mouseover" id="vm-'+vm_info.id+'"><div class="panel-heading">\
			<h3 class="panel-title">' + vm_info.name + ' [ ' + vm_info.id + ' ] ' + vm_info.state + '</h3></div><div class="panel-body"><p>\
			<button class="btn btn-inverse">Provision</button> <button class="btn btn-inverse">Reload</button> <button class="btn btn-warning">Halt</button>\
			</p><p><button class="btn btn-danger" data-toggle="modal" data-target="#destroy-modal">Destroy</button> </p></div></div>';
		return body;
	},
	_vm_state_class: function(state) {
		switch (state) {
			case 'running':
				return 'success';
			default:
				return 'default';
		}
	},
	_panel_rewrite: function(body) {
		var body = typeof body !== 'undefined' ? body : '';
		var selector = '#machine-panels';
		$(selector).html(body);
	},
	_remove_vmdata: function(vm_id) {
		var remove_index = undefined;
		if ( garage.vms ) {
			for (var i = 0; i < garage.vms.length; i++) {
				if ( garage.vms[i].id === vm_id ) {
					remove_index = i;
				}
			}
		}
		garage.vms.splice(remove_index, i);
	},
	destroy: function(vm_id) {
		garage._start_process();
		garage._removing = vm_id;
		$.get("/" + vm_id + "/destroy", function(data){
			if (data === 'failed') {
				garage._push_alert("failed X(", 'error');
				garage._removing = '';
			} else {
				garage._push_alert("Success :)");
				garage._remove_vmdata( garage._removing );
			}
			garage.reload();
			garage._stop_process();
		});
	},
	_push_alert: function(message, type) {
		var type = typeof type !== 'undefined' ? type : 'success';
		var n = noty({
			text: message,
			type: type,
			timeout: 5000,
			theme: 'relax'
		});
	},
	_rand_int: function() {
		return parseInt( Math.random() * (999999 - 1) + 1 );
	},
	_removing: '',
	_start_process: function() {
		$("#loading-icon").removeClass("stop-process");
	},
	_stop_process: function() {
		$("#loading-icon").addClass("stop-process");
	},
	_success_process: function() {
		garage._push_alert("Success :)");
	},
	_failed_process: function() {
		garage._push_alert("failed X(", 'error');
	},
	up: function(v_file) {
		garage._start_process();
		$.get('/vagrantfile/' + v_file.uuid + '/up', function(data){
			console.log (data);
			garage._stop_process();
		});
	},
	new_vm: function() {
		garage._start_process();
		vagrantfile = {};
		var vm_name = $("#form-vm-name").val();
		if (vm_name === "") vm_name = 'default';
		vagrantfile.name = vm_name;
		vagrantfile.box = $("#select2-chosen-2").text();
		vagrantfile.memory = $("#form-vm-memory").val();
		vagrantfile.ports = [];
		$('.bootstrap-tagsinput span.tag').each(function(){
			vagrantfile.ports.push( $(this).text() );
		});

		$.post('/vagrantfile', vagrantfile, function(data) {
			garage._stop_process();
			if ( data < 0 ) {
				garage._failed_process();
			} else {
				garage._success_process();
			}
		});
	}
};