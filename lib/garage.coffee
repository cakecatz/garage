fs = require 'fs'
p = require 'prettyput'
exec = require('child_process').exec
path = require 'path'

module.exports = {
	init: (settings)->
		# TODO: I think should not make direcotry here
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

	removeFromGaragefile: (uuid)->
		setting = this.load_setting_file this._getProjectRoot() + '/setting.json'
		vfile_list = this.status setting
		target_index = undefined
		for v,i in vfile_list.vms
			if v.uuid == uuid
				target_index = i
		if target_index != undefined
			vfile_list.vms.splice(target_index, 1)
			this.update_garagefile this.garagefile_path(setting), vfile_list

	new_vm: (setting, data)->
		garage_status = this.status setting
		garage_status.vms.push(data)
		this.update_garagefile this.garagefile_path(setting), garage_status

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
	deleteVfile: (vfile, res)->
		exec 'rm -rf ' + this._rel2abs(vfile.path) ,(err, stdout, stderr) =>
			p.e err
			p.p stdout
			this.removeFromGaragefile vfile.uuid
			res.send 'ok'

	_rel2abs: (path)->
		return this._getProjectRoot() + path.replace('.','')

	_getProjectRoot: ()->
		return path.dirname require.main.filename

}
