express = require 'express'
vagrant = require './lib/vagrant'
garage = require './lib/garage'
bodyParser = require 'body-parser'
app = express()

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

vagrant.init setting

app.get '/', (req, res)->
	vagrant.status (vms)->
		vfile = garage.status setting
		res.render 'index', {
			title: setting.name
			vm: vms
			vfile: vfile.vms
		}

app.get '/refresh', (req, res)->
	vagrant.status (vms)->
		vfile = garage.status setting
		res.send JSON.stringify {
			vms: vms
			vfile: vfile.vms
		}

app.get '/new', (req, res)->
	vagrant.box_list (box_list)->
		res.render 'new', {
				title: setting.name
				boxes: box_list
			}

app.get '/:id([0-9a-z]+)/destroy', (req, res)->
	vagrant.destroy req.params.id, (result)->
		res.send result

app.get '/vagrantfile/:uuid([0-9a-z\-]+)/:control([a-z]+)', (req, res)->
	v_file = garage.find req.params.uuid, setting
	switch req.params.control
		when 'up'
			vagrant.up v_file, res
		when 'delete'
			garage.deleteVfile v_file, res
		else
			res.send '-2'

app.post '/vagrantfile', (req, res)->
	vagrant.new_vagrantfile req.body, setting, (err, data)->
		garage.new_vm setting, data
		if err
			res.send '-1'
		else
			res.send '0'

app.listen setting.port
