require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "migrate"),
    ActionHandler(ACTIONS.WALKTO, "migrate"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.EAT, "eat_loop"),
}


local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("doattack", function(inst)
                                local nstate = "attack"
                                if inst.sg:HasStateTag("running") then
                                    nstate = "runningattack"
                                end
                                if inst.components.health and not inst.components.health:IsDead()
                                   and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
                                    inst.sg:GoToState(nstate)
                                end
                            end),

    EventHandler("locomote", function(inst)
                                local is_attacking = inst.sg:HasStateTag("attack") or inst.sg:HasStateTag("runningattack")
                                local is_busy = inst.sg:HasStateTag("busy")
                                local is_idling = inst.sg:HasStateTag("idle")
                                local is_moving = inst.sg:HasStateTag("moving")
                                local is_running = inst.sg:HasStateTag("running") or inst.sg:HasStateTag("runningattack")

                                if is_attacking or is_busy then return end

                                local should_move = inst.components.locomotor:WantsToMoveForward()
                                local should_run = inst.components.locomotor:WantsToRun()
                                
                                if is_moving and not should_move then
                                    if is_running then
                                        inst.sg:GoToState("run_stop")
                                    else
                                        inst.sg:GoToState("walk_stop")
                                    end
                                elseif (not is_moving and should_move) or (is_moving and should_move and is_running ~= should_run) then
                                    if should_run then
                                        inst.sg:GoToState("run_start")
                                    else
                                        inst.sg:GoToState("walk_start")
                                    end
                                end 
                            end),
}

local states=
{
    State{  name = "idle",
            tags = {"idle", "canrotate"},
            onenter = function(inst, playanim)
                inst.Physics:Stop()
                inst.components.locomotor:Stop()
                inst.SoundEmitter:KillSound("loop")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/idle")
                if playanim then
                    inst.AnimState:PlayAnimation(playanim)
                    inst.AnimState:SetTime(math.random()*2)
                    inst.AnimState:PushAnimation("idle_loop", true)
                else
                    inst.AnimState:PlayAnimation("idle_loop", true)
                end
            end,
            
            timeline = 
            {
                --TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/idle") end ),
            },
            
            events=
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
            },
        },

    State{  name = "run_start",
            tags = {"moving", "running", "canrotate"},
            
            onenter = function(inst)
                inst.components.locomotor:RunForward()
                inst.AnimState:SetTime(math.random()*2)
                inst.SoundEmitter:KillSound("loop")
                if GetSeasonManager():IsWinter() then
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/land")
                else
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/land_dirt")
                end
                inst.AnimState:PlayAnimation("slide_bounce")
                inst.sg.mem.foosteps = 0
            end,

            events =
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
            },
            
            timeline=
            {
            },        
        },

    State{  name = "run",
            tags = {"moving", "running", "canrotate"},
            
            onenter = function(inst) 
                inst.components.locomotor:RunForward()
                inst.SoundEmitter:KillSound("loop")
                inst.AnimState:PlayAnimation("slide_loop")
                if GetSeasonManager():IsWinter() then
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/slide")
                else
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/slide_dirt")
                end
            end,
            
            timeline=
            {
            },
            
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
            },
        },
    
    State{  name = "run_stop",
            tags = {"canrotate", "idle"},
            
            onenter = function(inst) 
                inst.SoundEmitter:KillSound("loop")
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("slide_post")
            end,
            
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("walk_start") end ),        
            },
        },    

    
    State{  name = "walk_start",
            tags = {"moving", "canrotate"},
            
            onenter = function(inst)
                inst.SoundEmitter:KillSound("loop")
                inst.components.locomotor:WalkForward()
                inst.AnimState:SetTime(math.random()*2)
                inst.AnimState:PlayAnimation("walk")
            end,

            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
            },
        },      
    
    State{  name = "walk",
            tags = {"moving", "canrotate"},
            
            onenter = function(inst) 
                inst.components.locomotor:WalkForward()
                inst.AnimState:PlayAnimation("walk", true)
                inst.SoundEmitter:KillSound("loop")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/idle")
            end,
    
            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
            },

            timeline = {
                TimeEvent(5*FRAMES, function(inst)
                                        if GetSeasonManager():IsWinter() then
                                            inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep")
                                        else
                                            inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep_dirt")
                                        end
                                    end),
                TimeEvent(21*FRAMES, function(inst)
                                        if GetSeasonManager():IsWinter() then
                                            inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep")
                                        else
                                            inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep_dirt")
                                        end
                                    end),
            },
        },

    State{  name = "walk_stop",
            tags = {"canrotate", "idle"},
            
            onenter = function(inst) 
                inst.SoundEmitter:KillSound("loop")
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("idle_loop", true)
            end,

            events=
            {   
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
            },
        },   
    
    State{  name = "eat_pre",
            tags = {"busy"},
            onenter = function(inst)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("atk_pre", false)
                inst.SoundEmitter:KillSound("loop")
            end,

            timeline = 
            {
                TimeEvent(4*FRAMES, function(inst) 
                                        inst:PerformBufferedAction()
                                        --inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/bite")
                                     end ), --take food
            },        
            
            events = 
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("eat_loop") end)
            },

        },


    State{  name = "eat_loop",
            tags = {"busy"},
            onenter = function(inst)
                inst.Physics:Stop()
                inst.SoundEmitter:KillSound("loop")
                inst.AnimState:PlayAnimation("eat", true)
                inst.sg:SetTimeout(0.8+math.random())
            end,

            timeline = 
            {
            },

            events = 
            {
                EventHandler("attacked",
                             function(inst)
                                 inst.components.inventory:DropItem(inst:GetBufferedAction().target)
                                 inst.sg:GoToState("idle")
                             end) --drop food
            },
            
            ontimeout= function(inst)
                            inst.lastmeal = GetTime()
                            inst:PerformBufferedAction()
                            inst.sg:GoToState("idle", "walk")
                        end,
        }, 

    State{  name = "pickup",
            tags = {"busy"},
            onenter = function(inst)
                inst.SoundEmitter:KillSound("loop")
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", true)
                inst.sg:SetTimeout(0.2)
            end,

            timeline = 
            {
            },

            events = 
            {
                EventHandler("attacked",
                             function(inst)
                                 inst.components.inventory:DropItem(inst:GetBufferedAction().target)
                                 inst.sg:GoToState("idle")
                             end) --drop food
            },
            
            ontimeout= function(inst)
                            inst.lastmeal = GetTime()
                            inst:PerformBufferedAction()
                            inst.sg:GoToState("idle")
                        end,
        }, 

    State{  name = "action",
            onenter = function(inst, playanim)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("idle", true)
                inst:PerformBufferedAction()
            end,
            timeline = 
            {
                TimeEvent(GetRandomWithVariance(30,15)*FRAMES, function(inst)
                                        inst.sg:GoToState("walk_start") 
                                     end),
            },
            --[[
            events=
            {
                EventHandler("animover", function (inst)
                    inst.sg:GoToState("idle")
                end),
            }
            --]]
        },  

    State{  name = "migrate",
            onenter = function(inst, playanim)
                inst.SoundEmitter:KillSound("loop")
                inst:PerformBufferedAction()
                inst.components.locomotor:WalkForward()
                inst.AnimState:PlayAnimation("walk", true)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/idle")
            end,
            timeline = {
                TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep") end),
                TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/footstep") end),
            },
            events=
            {
                EventHandler("animover", function (inst)
                    inst.sg:GoToState("walk_start")
                end),
            }
        },  

	State{  name = "death",
            tags = {"busy"},
            
            onenter = function(inst)
                inst.SoundEmitter:KillSound("loop")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/death")
                inst.Physics:Stop()	
                inst.AnimState:PlayAnimation("death")
                inst.components.locomotor:StopMoving()
                inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
            end,
            
        },
    
    
    State{  name = "appear",
            tags = {"busy"},
            
            onenter = function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/splash")
                inst.Physics:Stop()	
                inst.AnimState:PlayAnimation("slide_pre")
            end,

            events =
            {
                EventHandler("animqueueover", function(inst) inst.sg:GoToState("landing") end),
            },
        },
        
    State{  name = "landing",
            tags = {"busy"},
            
            onenter = function(inst)
                inst.components.locomotor:RunForward()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/jumpin")
                inst.AnimState:PushAnimation("slide_loop", "loop")
            end,
            
            timeline = 
            {
                TimeEvent(GetRandomWithVariance(30,15)*FRAMES, function(inst)
                                        inst.sg:GoToState("walk_start") 
                                        --inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/slide")
                                     end),
            },
        },
        
   State{ name = "taunt",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/taunt")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{  name = "attack",
            tags = {"attack"},
            
            onenter = function(inst)
                inst.SoundEmitter:KillSound("loop")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/attack")
                inst.components.combat:StartAttack()
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
            end,
            
            timeline =
            {
                TimeEvent(15*FRAMES, function(inst)
                                        inst.components.combat:DoAttack()
                                     end),
            },
            
            events =
            {
                EventHandler("animqueueover", function(inst) inst.sg:GoToState("walk_start") end),
            },
        },

    State{  name = "runningattack",
            tags = {"runningattack"},
            
            onenter = function(inst)
                inst.SoundEmitter:KillSound("loop")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/attack")
                inst.components.combat:StartAttack()
                --inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("slide_bounce")
            end,
            
            timeline =
            {
                TimeEvent(1*FRAMES, function(inst)
                                        inst.components.combat:DoAttack()
                                     end),
            },
            
            events =
            {
                EventHandler("animqueueover", function(inst) inst.sg:GoToState("walk_start") end),
            },
        },
}

CommonStates.AddSleepStates(states,
    {
        starttimeline = 
        {
            -- TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/sleep") end ),
        },
        sleeptimeline = {
            TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/pengull/sleep") end),
        },
    })


CommonStates.AddSimpleState(states,"hit","hit", {"busy"})
    
return StateGraph("penguin", states, events, "idle", actionhandlers)


