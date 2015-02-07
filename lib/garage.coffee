fs		= require 'fs'
p			= require 'prettyput'
exec	= require('child_process').exec
path	= require 'path'
uuid	= require 'node-uuid'
ejs		= require 'ejs'

module.exports = {
	init: (settings)->
		# TODO: I think should not make direcotry here
		if !fs.existsSync(settings.garageFilePath)
			fs.mkdirSync(settings.garageFilePath)

	status: (settings)->
		garageFilePath = this.garageFilePath settings
		if !fs.existsSync(garageFilePath)
			fs.writeFileSync garageFilePath ,'{"vms":[]}'
		garagefile = fs.readFileSync garageFilePath, {
			encoding: "UTF-8"
		}
		return JSON.parse garagefile

	garageFilePath: (settings)->
		settings.garageFilePath + '/garagefile.json'

	removeFromGaragefile: (uuid)->
		setting = this.load_setting_file this._getProjectRoot() + '/setting.json'
		vfile_list = this.status setting
		target_index = undefined
		for v,i in vfile_list.vms
			if v.uuid == uuid
				target_index = i
		if target_index != undefined
			vfile_list.vms.splice(target_index, 1)
			this.updateGarageFile this.garageFilePath(setting), vfile_list

	addMachine2GarageFile: (setting, data)->
		garageStatus = this.status setting
		garageStatus.vms.push(data)
		this.updateGarageFile this.garageFilePath(setting), garageStatus

	updateGarageFile: (path, data)->
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

	deleteVfile: (vagrantFilePath, uuid, callback)->
		exec 'rm -rf ' + vagrantFilePath ,(err, stdout, stderr) =>
			p.e err
			p.p stdout
			this.removeFromGaragefile uuid
			callback '0'

	_getProjectRoot: ()->
		return path.dirname require.main.filename

	newVagrantFile: (data, settings, callback)->
		template = fs.readFileSync './template/default_vagrantfile.ejs', {
			encoding: "UTF-8"
		}
		data.uuid = uuid.v4()
		data.path = settings.garageFilePath + '/' + data.uuid
		data.sh = data.sh.split("\n")
		body = ejs.render template, data
		fs.mkdirSync data.path
		fs.writeFile data.path + '/Vagrantfile',body, (err)->
			callback(err, data)

}
