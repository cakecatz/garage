garage = {
	selected_vm: {},
	vms: {},
	cuurent_page: 'index',
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
		garage.changeStatusbarText('Check and Update Lists');
		garage._reloadInnerVmList( garage._updateVmListView );
	},
	_updateVmListView: function() {
		// TODO: use diff
		var body = '';
		for(var i = 0;i < garage.vms.length;i++) {
			body += garage.create_machine_panel(garage.vms[i]);
		}
		if (body === '') {
			body = '<div class="panel panel-default"><div class="panel-body">No Virtual Machines</div></div>';
		}
		garage._panel_rewrite(body);
	},
	_reloadInnerVmList: function(callback) {
		this._order('/refresh', function(data){
			garage._updateGarageData( JSON.parse(data) );
		});
		if (callback) {
			callback();
		}
	},
	_updateGarageData: function(data) {
		garage.vfile = data.vfile;
		garage.vms = garage._convertVmArr(data.vms);
	},
	create_machine_panel: function(vm_info) {
		var body = '<div class="panel panel-' + this._vm_state_class(vm_info.state) + ' panel-mouseover" id="vm-'+vm_info.id+'"><div class="panel-heading">\
			<h3 class="panel-title">' + vm_info.name + ' [ ' + vm_info.id + ' ] ' + vm_info.state + '</h3></div><div class="panel-body"><p>\
			<button class="btn btn-inverse">Provision</button> <button class="btn btn-inverse">Reload</button> <button class="btn btn-inverse">Halt</button>\
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
		this._order("/" + vm_id + "/destroy", function(data){
			garage.reload();
			if (data === 'failed') {
				garage._push_alert("failed X(", 'error');
			} else {
				garage._push_alert("Success :)");
			}
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
	_startProcess: function() {
		this.stopMonitoring();
		$("#loading-icon").removeClass("stop-process");
	},
	_stopProcess: function() {
		$("#loading-icon").addClass("stop-process");
		this.startMonitoring();
	},
	_success_process: function() {
		garage._push_alert("Success :)");
	},
	_failed_process: function() {
		garage._push_alert("failed X(", 'error');
	},
	up: function(v_file) {
		this._order('/vagrantfile/' + v_file.uuid + '/up', function(data){
			garage.reload();
		});
	},
	delete_vfile: function(v_file) {
		this._order('/vagrantfile/' + v_file.uuid + '/delete', function(data){
			console.log(data);
			garage.reload();
		});
	},
	new_vm: function() {
		garage._startProcess();
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
			garage._stopProcess();
			if ( data < 0 ) {
				garage._failed_process();
			} else {
				garage._success_process();
			}
		});
	},
	_order: function(path, callback, post_data) {
		garage._startProcess();
		switch (path) {
			case 'aa':
				console.log(11);
			default:
				$.get(path, function(data){
					callback(data);
					garage._stopProcess();
					garage.clearStatusbarText();
				});
		}
	},
	_convertVmArr: function(arr) {
		if (arr.length <= 0) return [];
		var result = [];
		for (var i=0;i<arr.length;i++) {
			result.push({
				id: arr[i][0],
				name: arr[i][1],
				provider: arr[i][2],
				state: arr[i][3],
				directory: arr[i][4]
			});
		}
		return result;
	},
	startMonitoring: function() {
		this._monitor = setInterval( garage.reload, 5000 );
	},
	stopMonitoring: function() {
		clearInterval( this._monitor );
	},
	changeStatusbarText: function(text) {
		document.querySelector("#garage-status-bar-text").innerHTML = text;
	},
	clearStatusbarText: function(text) {
		document.querySelector("#garage-status-bar-text").innerHTML = '';
	},
	_monitor: {}
};
