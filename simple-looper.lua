-- variables
local recording = false
local current_position = 0
local record_arm = false

-- grid init
local g = grid.connect()
local g = grid.connect()
function grid_init()
  g:led(1, 8, 4)
  for i=1,6 do
    g:led(1, i, 4)
  end
  g:refresh()
end

local function reset_loop()
  softcut.buffer_clear(1)
  -- params:set("sample", "-")
  params:set("loop_start", 0)
  params:set("loop_end", 350.0)
  softcut.position(1, 0)
  -- current_position = 0
end

local function record_start()
  reset_loop()
  softcut.rec(1, 1)
  recording = true
  redraw()
end

local function record_stop()
  params:set("loop_end", current_position)
  softcut.rec(1, 0)
  recording = false
  softcut.play(1, 1)
  softcut.loop(1, 1)
  softcut.loop_start(1, 1)
  -- softcut.loop_end(1, 5)
  redraw()
end

local function set_loop_start(v)
  v = util.clamp(v, 0, params:get("loop_end") - .01)
  softcut.loop_start(1, v)
end

local function set_loop_end(v)
  v = util.clamp(v, params:get("loop_start") + .01, 350.0)
  softcut.loop_end(1, v)
end

local function update_positions(voice,position)
  current_position = position
end

function init()
  -- softcut initialize
  audio.level_cut(1)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  softcut.level(1,1)
  softcut.level_slew_time(1, 0.1)
  softcut.level_input_cut(1, 1, 1.0)
  softcut.level_input_cut(2, 1, 1.0)
  softcut.pan(1, 0.5)
  softcut.play(1, 0)
  softcut.rate(1, 1)
  softcut.rate_slew_time(1, 0.1)
  softcut.loop_start(1, 0)
  softcut.loop_end(1, 350)
  softcut.fade_time(1, 0.1)
  softcut.rec(1, 0)
  softcut.rec_level(1, 1)
  softcut.pre_level(1, 1)
  softcut.position(1, 0)
  softcut.buffer(1, 1)
  softcut.enable(1, 1)
  softcut.filter_dry(1, 1)

  -- softcut phase poll
  softcut.phase_quant(1, .01)
  softcut.event_phase(update_positions)
  softcut.poll_start_phase()

  position = 0
  counter = metro.init()
  counter.time = 0.5
  counter.count = -1
  counter.event = count
  counter:start()

  grid_init()
  redraw()
end

function key(n,z)
  if n == 2 and z == 1 then
    -- start recording
    if recording == false then
      record_start()
    else
      record_stop()
    end
    -- update screen to stop
  elseif n == 3 and z == 1 then
    softcut.buffer_clear()
  end
end

function enc(n, d)
  if n == 3 then
    params:delta("loop_end", d * .005)
  end
  if n == 2 then
    params:delta("loop_start", d * .005)
  end
  redraw()
end

function clock_init()
  -- initiate clock
  position = 0
  counter = metro.init()
  counter.time = 0.5
  counter.count = -1
  counter.event = count
  counter:start()
end

function count(c)
  position = position + 1
  print(position)
  blink()
  g:refresh()
end

function blink()
  if position % 2 == 0 then
    g:led(1, 1, 15)
    -- g:refresh()
  else
    g:led(1, 1, 4)
    -- g:refresh()
  end
end


g.key = function(x,y,z)
  if (x == 1 and y == 8 and z == 1) then
    g:led(1, 8, 15)
    rec_arm = true
  end
  if rec_arm then
    if (x == 1 and (y>=1 or y<=6) and z == 1) then
      print("on")
      blink()
    end
  end
  g:refresh()
end

-- function grid_redraw()
--   -- g:led(15, 1, 15)
--   -- grid_init()
--   g:refresh()
-- end

-- parameters
-- sample start controls
params:add_control("loop_start", "loop start", controlspec.new(0.0, 349.99, "lin", .01, 0, "secs"))
params:set_action("loop_start", function(x) set_loop_start(x) end)
-- sample end controls
params:add_control("loop_end", "loop end", controlspec.new(.01, 350, "lin", .01, 350, "secs"))
params:set_action("loop_end", function(x) set_loop_end(x) end)

function redraw()
  -- k2 button
  screen.aa(0)
  screen.clear()
  screen.level(4)
  screen.move(0, 48)
  if recording then
    screen.text("stop")
  else
    screen.text("record")
  end
  -- k3 button
  screen.move(128, 48)
  screen.text_right("clear buffer")
  -- loops params
  screen.move(0, 24)
  screen.text("start : " .. string.format("%.2f", params:get("loop_start")))
  screen.move(128, 24)
  screen.text_right("stop : " .. string.format("%.2f", params:get("loop_end")))
  screen.update()
end