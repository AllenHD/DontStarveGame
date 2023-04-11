Task = Class(function(self, id, data)
	--print("Task ",id)
	--dumptable(room_choices)
	self.id = id
	
	-- what locks this task
	self.locks = data.locks
	if type(self.locks) ~= "table" then
		self.locks = { self.locks }
	end
	-- the key that this task provides
	self.keys_given = data.keys_given
	if type(self.keys_given) ~= "table" then
		self.keys_given = { self.keys_given }
	end
	
	self.entrance_room = data.entrance_room
	self.entrance_room_chance = data.entrance_room_chance
	self.room_choices = data.room_choices
	self.room_choices_special = data.room_choices_special
	self.room_bg = data.room_bg
	self.background_room = data.background_room
	self.colour = data.colour
end)



