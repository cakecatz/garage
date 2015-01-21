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
		garage_data = garage.status setting
		res.render 'index', {
			title: setting.name
			vm: vms
			garage_data: garage_data.vms
		}

app.get '/reload-vm', (req, res)->
	vagrant.status (vms)->
		res.send JSON.stringify vms

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
	switch req.params.control
		when 'up'
			v_file = garage.find req.params.uuid, setting
			vagrant.up v_file, (result)->
				res.send result
		when 'delete'
			res.send '-3'
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
