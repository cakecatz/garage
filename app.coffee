express = require 'express'
vagrant = require 'vagrant.js'
garage = require './lib/garage'
bodyParser = require 'body-parser'
app = express()
path  = require 'path'

setting = garage.load_setting_file './setting.json'

garage.init setting

# for development
p = console.log

## setup express
app.use bodyParser.json()
app.use bodyParser.urlencoded {
	extended: true
}
app.set 'views', './public'
app.set 'view engine', 'ejs'
app.use express.static (__dirname + '/public')

app.get '/', (req, res)->
	vagrant.status (statusArr)->
		vfile = garage.status setting
		res.render 'index', {
			title: setting.name
			vm: statusArr
			vfile: vfile.vms
		}

app.get '/refresh', (req, res)->
	vagrant.status (statusArr)->
		vfile = garage.status setting
		res.send JSON.stringify {
			vms: statusArr
			vfile: vfile.vms
		}

app.get '/new', (req, res)->
	vagrant.boxList (boxList)->
		res.render 'new', {
				title: setting.name
				boxes: boxList
			}

app.get '/:id([0-9a-z]+)/destroy', (req, res)->
	vagrant.destroy req.params.id, (result)->
		res.send result

app.get '/vagrantfile/:uuid([0-9a-z\-]+)/:control([a-z]+)', (req, res)->
	vagrantFilePath = path.join __dirname, setting.garageFilePath, req.params.uuid
	switch req.params.control
		when 'up'
			vagrant.up vagrantFilePath, (stdout, stderr)->
				res.send '0'
		when 'delete'
			garage.deleteVfile vagrantFilePath, req.params.uuid, (result)->
				res.send result
		else
			res.send '-2'

app.post '/vagrantfile/new', (req, res)->
	garage.newVagrantFile req.body, setting, (err, data)->
		garage.addMachine2GarageFile setting, data
		if err
			res.send '-1'
		else
			res.send '0'

p 'localhost:' + setting.port

app.listen setting.port
