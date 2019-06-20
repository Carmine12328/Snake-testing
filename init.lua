
function startup()
  print("Run..")
  dofile("main.lua")
end

tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
