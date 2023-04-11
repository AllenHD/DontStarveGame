function clockpostinit(inst)

	--create the colour for the fullmoon
	inst.fullColour = Point(120/255, 120/255, 160/255)

	--save the original function
	inst.StartNightPre = inst.StartNight

	--override a class function, and call the original function first
	--doing it this way allows the game to change while still keeping your own edits
	inst.StartNight = function(self,inst)

		self:StartNightPre(inst)
	    if self.phase ~= self.previous_phase then
	        self.previous_phase = self.phase
	        if self:GetMoonPhase() == "full" then
	          self:LerpAmbientColour(self.currentColour, self.fullColour, instant and 0 or 8)
	        else
	          self:LerpAmbientColour(self.currentColour, self.nightColour, instant and 0 or 8)
	        end
		end
	end

end

AddComponentPostInit("clock", clockpostinit)
