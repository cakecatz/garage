fs = require 'fs'
p = require 'prettyput'

module.exports = {
	init: (settings)->
		# TODO: I think should not use mkdir here
		if !fs.existsSync(settings.garage_dir)
			fs.mkdirSync(settings.garage_dir)

	status: (settings)->
		garagefile_path = this.garagefile_path settings
		if !fs.existsSync(garagefile_path)
			fs.writeFileSync garagefile_path ,'{"vms":[]}'
		garagefile = fs.readFileSync garagefile_path, {
			encoding: "UTF-8"
		}
		return JSON.parse garagefile

	garagefile_path: (settings)->
		settings.garage_dir + '/garagefile.json'

	new_vm: (settings, data)->
		garage_status = this.status settings
		garage_status.vms.push(data)
		this.update_garagefile this.garagefile_path(settings), garage_status

	update_garagefile: (path, data)->
		body = JSON.stringify data
		fs.writeFile path, body, (err)->
			p.e err
			p.p 'update garagefile'
	find: (uuid, settings)->
		garage_status = this.status settings
		for v in garage_status.vms
			if v.uuid == uuid
				return v
		return false
	load_setting_file: (path)->
		file_body = fs.readFileSync path, {
			encoding: "UTF-8"
		}
		return JSON.parse file_body
}
