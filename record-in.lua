-- explorations taken from justmat/sam
local function reset_loop()
  softcut.buffer_clear(1)
  -- params:set("sample", "-")
  -- params:set("loop_start", 0)
  -- params:set("loop_end", 350.0)
  softcut.position(1, 0)
  current_position = 0
end

-- variables
local buffer = 1;
local save_time = 2
local start_time = nil
local current_position = 0

g = grid.connect()

-- tape functions
function record_on()
  reset_loop()
  softcut.rec(1, 1)
  recording = true
  start_time = util.time()
end

function record_stopped()
  softcut.rec(1,0)
  softcut.position(1, 0)
  recording = false
  playing = true
  softcut.play(1, 1)
  softcut.loop(1, 1)
end

function play_buffer()
  softcut.play(1, 0)
  playing = false
end

-- function set_loop_start(v)
--   v = util.clamp(v, 0, params:get("loop_end") - .01)
--   softcut.loop_start(1, v)
-- end


-- function set_loop_end(v)
--   v = util.clamp(v, params:get("loop_start") + .01, 350.0)
--   softcut.loop_end(1, v)
-- end


function grid_init()
  g:led(1,8,15)
  g:refresh()
end


g.key = function(x,y,z)
  if x == 1 and y == 8 and z == 1 then
    record_on()
  else
    record_stopped()
  end

  redraw()
end

function init()
  -- softcut setup
  audio.level_cut(1)
  audio.level_adc_cut(1)
  audio.level_eng_cut(1)
  softcut.level(1,1)
  softcut.level_slew_time(1,0.1)
  softcut.level_input_cut(1, 1, 1.0)
  softcut.level_input_cut(2, 1, 1.0)
  softcut.pan(1, 0.5)
  softcut.play(1, 0)
  softcut.rate(1, 1)
  softcut.rate_slew_time(1,0.1)
  softcut.loop_start(1, 0)
  softcut.loop_end(1, 350)
  softcut.loop(1, 1)
  softcut.fade_time(1, 0.1)
  softcut.rec(1, 0)
  softcut.rec_level(1, 1)
  softcut.pre_level(1, 1)
  softcut.position(1, 0)
  softcut.buffer(1,1)
  softcut.enable(1, 1)
  softcut.filter_dry(1, 1)
  grid_init()
  redraw()
end

function key(n, z)
  if n == 2 and z == 1 then
    if recording == false then
      record_on()
    else
    --   -- params:set("loop_end", current_position)
      record_stopped()
    end
  elseif n == 3 and z == 1 then
    -- if alt then
    --   save_time = util.time()
    --   write_buffer()
    -- else
      if recording then
        -- do nothing
      else
        if playing == true then
          softcut.play(1, 0)
          playing = false
        else
          softcut.position(1, 0)
          softcut.play(1, 1)
          playing = true
        end
      end
    -- end
  end
  redraw()
end

function redraw()
  screen.aa(0)
  screen.clear()
  screen.move(64, 12)
  screen.level(4)
  -- screen.text_center("hello!")
  if recording then
    screen.text_center("recording...")
    screen.update()
  -- elseif playing then
  --   screen.text_center("looping " .. "(" .. string.format("%.2f", current_position) .. ")")
  else
    screen.move(64, 24)
    screen.text_right("stopped")
  end
  screen.update()
end