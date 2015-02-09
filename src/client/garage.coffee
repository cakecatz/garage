window.garage = {
	selected_vm: {}
	vms: {}
	current_page: 'index'
	search: (vm_id)->
		if garage.vms
			for i in [0...garage.vms.length]
				if garage.vms[i].id == vm_id
					return garage.vms[i]

		return false

	reload: ->
		garage.changeStatusbarText 'Check and Update Lists'
		garage._reloadInnerVmList ->
			garage._updateVmListView()
			garage._reloadVfileList()
		garage._clickPanelEvent()

	_updateVmListView: ->
		# TODO: use diff
		body = ''
		for i in [0...garage.vms.length]
			body += garage.create_machine_panel garage.vms[i]
		if body == ''
			body = '<div class="panel panel-default"><div class="panel-body">No Virtual Machines</div></div>'
		garage._vmPanelRewrite body

	_reloadInnerVmList: (callback)->
		garage._order '/refresh', (data)->
			garage._updateGarageData( JSON.parse(data) )
		if callback then callback()

	_reloadVfileList: ()->
		body = ''
		for i in [0...garage.vfiles.length]
			body += '<div class="panel panel-default panel-mouseover" id="vagrantfile-panels"><div class="panel-body machine-detail">'
			+ '<p>Name : ' + garage.vfiles[i].name + '</p><p>Box : ' + garage.vfiles[i].box + '</p><p>Memory : ' + garage.vfiles[i].memory + ' MB</p>'
			+ '<p><button class="btn btn-inverse vagrant-up-btn" data-select-index="' + i + '">Vagrant up</button>'
			+ '<button class="btn btn-default delete-vfile-btn" data-select-index="' + i + '">Delete</button></p></div></div>'

		if body == ''
			body = '<div class="panel panel-default"><div class="panel-body">No Vagrantfiles</div></div>'
		garage._vfilePanelRewrite body

	_updateGarageData: (data)->
		garage.vfiles = data.vfile
		garage.vms = data.vms

	create_machine_panel: (machineInfo)->
		body = '<div class="panel panel-' + this._vm_state_class(machineInfo.state) + ' panel-mouseover" id="vm-'+machineInfo.id+'"><div class="panel-heading">'
		+ '<h3 class="panel-title">' + machineInfo.name + ' [ ' + machineInfo.id + ' ] ' + machineInfo.state + '</h3></div><div class="panel-body"><p>'
		+ '<button class="btn btn-inverse">Provision</button> <button class="btn btn-inverse">Reload</button> <button class="btn btn-inverse">Halt</button>'
		+ '</p><p><button class="btn btn-danger" data-toggle="modal" data-target="#destroy-modal">Destroy</button> </p></div></div>'
		return body

	_clickPanelEvent: ()->
		$('#machine-panels > .panel').mouseover ->
			garage.selected_vm = garage.search this.id.replace('vm-','')

	_vm_state_class: (state)->
		switch state
			when 'running' then return 'success'
			else return 'default'

	_vmPanelRewrite: (body)->
		body = body || ''
		selector = '#machine-panels'
		$(selector).html body

	_vfilePanelRewrite: (body)->
		body = body || ''
		selector = '#vfile-panels'
		$(selector).html body

	_remove_vmdata: (vm_id)->
		if garage.vms
			for i in [0...garage.vms.length]
				if garage.vms[i].id == vm_id
					remove_index = i

		garage.vms.splice remove_index, i

	destroy: (vm_id)->
		garage._order "/" + vm_id + "/destroy", (data)->
			if data == 'failed'
				garage._pushAlert "failed X(", 'error'
			else
				garage._pushAlert "Success :)"

	_pushAlert: (message, type)->
		type = type || 'success'
		n = noty {
			text: message,
			type: type,
			timeout: 5000,
			theme: 'relax'
    }

	_rand_int: ->
		return parseInt( Math.random() * (999999 - 1) + 1 )

	_removing: '',

	_startProcess: ->
		garage.stopMonitoring()
		$("#loading-icon").removeClass "stop-process"

	_stopProcess: ->
		$("#loading-icon").addClass "stop-process"
		if garage.current_page == 'index'
			garage.startMonitoring()

	_successProcess: ->
		garage._pushAlert "Success :)"

	_failedProcess: ->
		garage._pushAlert "failed X(", 'error'

	up: (v_file)->
		garage._order '/vagrantfile/' + v_file.uuid + '/up', (data)->
			garage.reload()

	deleteVfile: (vagrantFile)->
		garage._order '/vagrantfile/' + vagrantFile.uuid + '/delete', (data)->
			garage.reload()

	newVfile: ->
		garage._startProcess()
		vfile = {}
		vfile.name = $("#form-vm-name").val() || 'default'
		vfile.box = $("#select2-chosen-2").text()
		vfile.memory = $("#form-vm-memory").val()
		vfile.ports = []
		$('.bootstrap-tagsinput span.tag').each ->
			vfile.ports.push $(this).text()

		vfile.sh = $('#bootstrap-sh-form').val()

		$.post '/vagrantfile/new', vfile, (data)->
			garage._stopProcess()
			if data < 0
				garage._failedProcess()
			else
				garage._successProcess()

	_order: (url, callback, post_data)->
		garage._startProcess()
		switch url
			when 'test' then console.log 'test'
			else
				$.get url, (data)->
						callback data
				.always ->
					garage._stopProcess()
					garage.clearStatusbarText()

	_convertVmArr: (arr)->
		if arr.length <= 0 then return []
		result = []
		for i in [0...arr.length]
			result.push {
				id: arr[i][0]
				name: arr[i][1]
				provider: arr[i][2]
				state: arr[i][3]
				directory: arr[i][4]
      }
		return result

	startMonitoring: ->
		garage._monitor = setInterval garage.reload, 5000

	stopMonitoring: ->
		clearInterval garage._monitor

	changeStatusbarText: (text)->
		document.querySelector("#garage-status-bar-text").innerHTML = text

	clearStatusbarText: (text)->
		document.querySelector("#garage-status-bar-text").innerHTML = ''

	_monitor: {}
}
