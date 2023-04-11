require("stategraphs/commonstates")

local actionhandlers = 
{
}


local events=
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}

local states=
{
     State{
        
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle_loop", true)
            else
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
        end,
        
        timeline = 
        {
		    TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/idle") end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

   State{
        name = "taunt",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,
        
        timeline = 
        {
		    TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/voice") end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    }
}

CommonStates.AddWalkStates(states,
{
    starttimeline = 
    {
	    TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end ),
    },
	walktimeline = {
		    TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end ),
            TimeEvent(7*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/bounce")
                inst.components.locomotor:WalkForward()
            end ),
            TimeEvent(20*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/land")
                inst.Physics:Stop()
            end ),
	},
}, nil, true)

CommonStates.AddSleepStates(states,
{
    starttimeline = 
    {
		TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/liedown") end ),
    },
    
	sleeptimeline = {
        TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/sleep") end),
	},
})

CommonStates.AddCombatStates(states,
{
    attacktimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/charge") end),
        TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shoot") end),
        TimeEvent(24*FRAMES, function(inst) inst.components.combat:DoAttack() end),
    },
    hittimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/hurt") end),
    },
    deathtimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/death") end),
    },
})

CommonStates.AddFrozenStates(states)

    
return StateGraph("bishop", states, events, "idle", actionhandlers)

