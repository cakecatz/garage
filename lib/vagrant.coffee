exec = require('child_process').exec
p = require 'prettyput'
fs = require 'fs'
ejs = require 'ejs'
uuid = require 'node-uuid'

module.exports = {
	vms: []
	init: ()->
		exec 'vagrant global-status', (err, stdout, stderr) =>
			p.e err
			vm_arr = this._parse_status stdout
			for v in vm_arr
				this.vms.push {
					id: v[0]
					name: v[1]
					provider: v[2]
					state: v[3]
					dir: v[4]
				}

	status: (callback)->
		exec 'vagrant global-status --prune', (err, stdout, stderr) =>
			p.e err
			callback this._parse_status stdout

	_parse_status: (plain_text)->
		if plain_text.search(/---\nT/m) > 0
			return []
		parsed_text = plain_text.replace /id[\s\S]*---\n/, ''
		parsed_text = parsed_text.replace /The above[\s\S]*/, ''
		status_arr = parsed_text.split "\n"
		vm_arr = []
		for v in status_arr
			if v and v != "\n" and v != ' '
				vm_arr.push this._remove_whitespace v.split ' '
		return vm_arr

	_remove_whitespace: (arr)->
		fix_arr = []
		for v in arr
			if v and v != "\n"
				fix_arr.push v
		return fix_arr

	vm_search: (vm_id)->
		for v in this.vms
			if v.id is vm_id
				return v
		return false

	destroy: (vm_id, callback)->
		target = this.vm_search vm_id
		if target
			exec 'vagrant destroy -f ' + target.id, (err, stdout, stderr) =>
				p.e err
				p.e stderr
				callback stdout
		else
			callback 'failed'

	box_list: (callback)->
		exec 'vagrant box list --machine-readable', (err, stdout, stderr)=>
			p.e err
			callback this._parse_boxlist_txt stdout

	_parse_boxlist_txt: (text)->
		box_list = []
		box_arr = this._split_multiline text
		for i in [0...(box_arr.length / 3)]
			box_list.push {
				name: box_arr[ 0 + (3 * i) ].split(',')[3]
				provider: box_arr[ 1 + (3 * i) ].split(',')[3]
				version: box_arr[ 2 + (3 * i) ].split(',')[3]
			}
		return box_list

	_split_multiline: (text)->
		pre_arr = text.split "\n"
		new_arr = []
		for v in pre_arr
			if v isnt undefined and v isnt ""
				new_arr.push v
		return new_arr

	new_vagrantfile: (data, settings, callback)->
		template = fs.readFileSync './template/default_vagrantfile.ejs', {
			encoding: "UTF-8"
		}
		data.uuid = uuid.v4()
		data.path = settings.garage_dir + '/' + data.uuid
		data.sh = data.sh.split("\n")
		body = ejs.render template, data
		fs.mkdirSync data.path
		fs.writeFile data.path + '/Vagrantfile',body, (err)->
			callback(err, data)

	up: (v_file, res)->
		exec 'cd ' + v_file.path + ' && vagrant up', (err, stdout, stderr) =>
			p.e err
			p.p stdout
			p.e stderr
			if err or stderr
				res.send '-1'
			else
				res.send '0'

}
