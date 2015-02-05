garage = {
	selected_vm: {},
	vms: {},
	current_page: 'index',
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
		garage._reloadInnerVmList( function() {
			garage._updateVmListView();
			garage._reloadVfileList();
		});
		garage._clickPanelEvent();
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
		garage._vmPanelRewrite(body);
	},
	_reloadInnerVmList: function(callback) {
		this._order('/refresh', function(data){
			garage._updateGarageData( JSON.parse(data) );
		});
		if (callback) {
			callback();
		}
	},
	_reloadVfileList: function() {
		var body = '';
		for(var i=0;i < garage.vfiles.length;i++) {
			body += '<div class="panel panel-default panel-mouseover" id="vagrantfile-panels"><div class="panel-body machine-detail">\
				<p>Name : ' + garage.vfiles[i].name + '</p><p>Box : ' + garage.vfiles[i].box + '</p><p>Memory : ' + garage.vfiles[i].memory + ' MB</p>\
				<p><button class="btn btn-inverse vagrant-up-btn" data-select-index="' + i + '">Vagrant up</button>\
				<button class="btn btn-default delete-vfile-btn" data-select-index="' + i + '">Delete</button></p></div></div>';

		}
		if (body === '') {
			body = '<div class="panel panel-default"><div class="panel-body">No Vagrantfiles</div></div>';
		}
		garage._vfilePanelRewrite(body);
	},
	_updateGarageData: function(data) {
		garage.vfiles = data.vfile;
		garage.vms = data.vms;
	},
	create_machine_panel: function(machineInfo) {
		var body = '<div class="panel panel-' + this._vm_state_class(machineInfo.state) + ' panel-mouseover" id="vm-'+machineInfo.id+'"><div class="panel-heading">\
			<h3 class="panel-title">' + machineInfo.name + ' [ ' + machineInfo.id + ' ] ' + machineInfo.state + '</h3></div><div class="panel-body"><p>\
			<button class="btn btn-inverse">Provision</button> <button class="btn btn-inverse">Reload</button> <button class="btn btn-inverse">Halt</button>\
			</p><p><button class="btn btn-danger" data-toggle="modal" data-target="#destroy-modal">Destroy</button> </p></div></div>';
		return body;
	},
	_clickPanelEvent: function() {
		$('#machine-panels > .panel').mouseover(function(){
			garage.selected_vm = garage.search(this.id.replace('vm-',''));
		});
	},
	_vm_state_class: function(state) {
		switch (state) {
			case 'running':
				return 'success';
			default:
				return 'default';
		}
	},
	_vmPanelRewrite: function(body) {
		var body = typeof body !== 'undefined' ? body : '';
		var selector = '#machine-panels';
		$(selector).html(body);
	},
	_vfilePanelRewrite: function(body) {
		var body = typeof body !== 'undefined' ? body : '';
		var selector = '#vfile-panels';
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
		if (garage.current_page === 'index') {
			garage.startMonitoring();
		}
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
			garage.reload();
		});
	},
	new_vfile: function() {
		garage._startProcess();
		vfile = {};
		var vm_name = $("#form-vm-name").val();
		if (vm_name === "") vm_name = 'default';
		vfile.name = vm_name;
		vfile.box = $("#select2-chosen-2").text();
		vfile.memory = $("#form-vm-memory").val();
		vfile.ports = [];
		$('.bootstrap-tagsinput span.tag').each(function(){
			vfile.ports.push( $(this).text() );
		});

		vfile.sh = $('#bootstrap-sh-form').val();

		$.post('/vagrantfile/new', vfile, function(data) {
			garage._stopProcess();
			if ( data < 0 ) {
				garage._failed_process();
			} else {
				garage._success_process();
			}
		});
	},
	_order: function(url, callback, post_data) {
		garage._startProcess();
		switch (url) {
			case 'aa':
				console.log(11);
			default:
				$.get(url,function(data){
						callback(data);
				}).always(function(){
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
