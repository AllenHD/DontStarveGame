require("class")

HIBERNATE = "hibernate"
SLEEP = "sleep"

----------------------------------------------------------------------------------
local coroutine = coroutine
local debug = debug


-------------------------------
local taskguid = 0
local Task = Class( function(self, fn, id, param)
    self.guid = taskguid
    taskguid = taskguid + 1    
    self.param = param
    
    self.id = id
    self.fn = fn
    self.co = coroutine.create(fn)
    self.list = nil
    
end)

function Task:__tostring()
    return string.format("TASK %s:", tostring(self.id))
end

function Task:SetList(list)
    if self.list then
        self.list[self.guid] = nil
    end
    if list then
        list[self.guid] = self
    end
    self.list = list
end

-------------------------------
Periodic = Class(function(self, fn, period, limit, ...)
    self.fn = fn
    self.period = period
    self.limit = limit
    self.list = nil
    self.onfinish = nil
    self.arg = arg
end)

function Periodic:Cancel()
    self.limit = 0
    if self.list then
        self.list[self] = nil
    end
    
    if self.onfinish then
        self.onfinish(false)
    end
    
end

function Periodic:__tostring()
    return string.format("PERIODIC %s: %f", tostring(self.id), self.period)
end
-------------------------------

local listrecycler = {}
local function GetNewList()
    local list = nil
    local numre = #listrecycler
    if  numre > 0 then
        list = listrecycler[numre]
        table.remove(listrecycler)
    else
        list = {}
    end
    return list
end
-------------------------------


local Scheduler = Class( function(self)
   
    self.tasks = {}
    self.running = {}
	self.waitingfortick = {}
	self.waking = {}
    self.hibernating = {}
    self.attime = {}
end)

function Scheduler:__tostring()
    
    local numrun = 0
    local numtasks = 0
    
    for k, v in pairs(self.running) do
        numrun = numrun + 1
    end

    for k, v in pairs(self.tasks) do
        numtasks = numtasks + 1
    end
    
    local str = string.format("Running Tasks: %d/%d", numrun, numtasks)
    
    return str
end

function Scheduler:KillTask(task)
    task:SetList(nil)
    if task.co then
        self.tasks[task.co] = nil
        task.co = nil
    end
end

function Scheduler:AddTask(fn, id, param)
	local task = Task(fn, id, param)
	if task.co == nil then
	    print("TASK.CO is nil!")
	    for k,v in pairs(task) do
	        print(k,v)
	    end
	end
    self.tasks[task.co] = task
    task:SetList(self.running)
    return task
end


function Scheduler:OnTick(tick)

    for k,v in pairs(self.waitingfortick) do
		assert (k >= tick)
    end
    


    if self.waitingfortick[tick] ~= nil then
        for k, v in pairs(self.waitingfortick[tick]) do
            v:SetList(self.waking)
        end
        local list = self.waitingfortick[tick]
        table.insert(listrecycler, list)
        self.waitingfortick[tick] = nil
    end
    
    
    --do our at time callbacks!
    if self.attime[tick] ~= nil then
        for k,v in pairs(self.attime[tick]) do
            if v then
                local already_dead = k.limit and k.limit == 0
                    
                if not already_dead and k.fn then
                    k.fn(unpack(k.arg))
                end
                
                if k.limit then
                    k.limit = k.limit - 1
                end
                
                if not k.limit or k.limit > 0 then
                    local list = self:GetListForTimeFromNow(k.period)
                    list[k] = true
                    k.list = list
                else
                    if k.onfinish and not already_dead then
                        k.onfinish(true)
                    end
                end
            end
            
        end
        self.attime[tick] = nil
    end
end



function Scheduler:Run()

	for k, v in pairs(self.waking) do
		v:SetList(self.running)
	end
	self.waking = {}


	for k, v in pairs(self.running) do
    
		if coroutine.status(v.co) == "dead" then
			--The task is finished. kill it!
            task:SetList(nil)
            self.tasks[v.co] = nil
		else
 
			local success, yieldtype, yieldparam = coroutine.resume(v.co, v.param)

			if success and coroutine.status(v.co) ~= "dead" then
				if yieldtype == HIBERNATE then
                    v:SetList(self.hibernating)
                elseif yieldtype == SLEEP then
                    yieldparam = math.floor(yieldparam)
                    local list = self.waitingfortick[yieldparam]
                    if not list then
                        list = GetNewList()
                        self.waitingfortick[yieldparam] = list
                    end
                    v:SetList(list)
				end
			else
                v:SetList(nil)
                v.retval = yieldtype
                if not success then
                    print (debug.traceback(v.co, "\nCOROUTINE "..tostring(v.id).." SCRIPT CRASH:\n".. tostring(yieldtype)))
                    TheSim:DebugPause()
                    self:KillTask(v)
                    return
                end
                self:KillTask(v)
                
			end
		end
	end
end


function Scheduler:KillAll()
	self.tasks = {}
    self.hibernating = {}
    self.running = {}
    self.waitingfortick = {}
	self.waking = {}
    self.attime = {}
    
end

local function removeif(tab, fn)
    for k, v in pairs(tab) do
        if fn(v) then 
            tab[k] = nil
        end
    end
end

function Scheduler:ExecuteInTime(timefromnow, fn, ...)
    return self:ExecutePeriodic(timefromnow, fn, 1, nil, ...)
end

function Scheduler:GetListForTimeFromNow(dt)
    local nowtick = GetTick()
    local wakeuptick = math.floor( (GetTime()+dt)/GetTickTime() )
    if wakeuptick <= nowtick then
        wakeuptick = nowtick+1
    end
    
    local list = scheduler.attime[wakeuptick]
    if not list then
        list = {}
        scheduler.attime[wakeuptick] = list
    end
    return list
end

function Scheduler:ExecutePeriodic(period, fn, limit, initialdelay, ...)
    local periodic = Periodic(fn, period, limit, ...)

    local list = self:GetListForTimeFromNow(initialdelay or period)
    list[periodic] = true
    periodic.list = list
    return periodic
end



function Scheduler:KillTasksWithID(id)
    local function pred(task) return task.id == id end

    removeif(self.tasks, pred)
    removeif(self.hibernating, pred)
    removeif(self.running, pred)
    removeif(self.waking, pred)
    
    for k, v in pairs( self.waitingfortick ) do
        removeif(v, pred)
    end
    
end


function Scheduler:GetCurrentTask()
    local co = coroutine.running ()
    local task = self.tasks[co]
    return task
end

------------------------------------------------------------------------------------

scheduler = Scheduler()


------------------------------------------------------------------------------------



--These are to be called from within a thread

function Wake()
    local task = scheduler:GetCurrentTask()
    if task then
        task:SetList(scheduler.running)
    end
end

function Hibernate()
    coroutine.yield(HIBERNATE)
end

function Yield()
    coroutine.yield()
end

function Sleep(time)
    local desttick = math.ceil((GetTime() + time)/GetTickTime())
	if GetTick() < desttick then
        coroutine.yield(SLEEP, desttick)
    else
        coroutine.yield()
    end
end


function KillThread(task)
    scheduler:KillTask(task)
end

------

function WakeTask(task)
    if task then
        task:SetList(scheduler.running)
    end
end

--This is to start a thread
function StartThread(fn, id, param)

    if id == nil then
        local task = scheduler:GetCurrentTask()
        if task ~= nil then
            id = task.id
        end
    end
	return scheduler:AddTask(fn, id, param)
end


function RunScheduler(tick)
    TheSim:ProfilerPush("scheduler:OnTick")
    scheduler:OnTick(tick)
    TheSim:ProfilerPop()
    
    TheSim:ProfilerPush("scheduler:Run")
    scheduler:Run()
    TheSim:ProfilerPop()
end

function KillThreadsWithID(id)
    scheduler:KillTasksWithID(id)
end

function StopAllThreads()
    scheduler:KillAll()
end


local print_loggers = {}

function addprintlogger( fn )
    table.insert(print_loggers, fn)
end

global("CWD")  
local dir = CWD or ""
dir = string.gsub(dir, "\\", "/")
local oldprint = print
print = function(...)
    local info = debug.getinfo(2, "Sl")
    local source = info.source
    if info.source and string.sub(info.source,1,1)=="@" then
        source = source:sub(2)
    end
    
    for i,v in ipairs(print_loggers) do
        v(...)
    end

    local defline = string.format("%s(%d,1)", tostring(source), info.currentline)
    oldprint(defline, ...)
end
