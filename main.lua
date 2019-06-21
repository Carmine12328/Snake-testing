local display = require("tm1640")
local button = { }

local go_phrase = {0x7e, 0x81, 0xa1, 0x60, 0x0, 0xff, 0x81, 0xff}
local void = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}
local first_position_player = {0x1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}
local cross = {0x81, 0x42, 0x24, 0x18, 0x18, 0x24, 0x42, 0x81}

local btn1 = 0
local btn2 = 6

local btn_val = 1
local btn_val2 = 1

local cont_top_down = 1
local cont_left_right = 1

local game_status = 0 -- 0 = not in game
local top_down = false
local left_right = true

print("===== Main =====\n")

print("Set button for input\n")
gpio.mode(btn1,gpio.INPUT)
gpio.mode(btn2,gpio.INPUT)


print("Write Go on led matrix\n")
display.init(7,5)
display.brightness(7)
display.write(go_phrase)

tmr.create():alarm(600, tmr.ALARM_AUTO, function()
    print("Sono top_down")
    if(top_down == true) then
        if gpio.read(btn1) == 0 then
            tmr.create():alarm(50, tmr.ALARM_SINGLE, function()
                if(gpio.read(btn1) == 0) then
                    btn_val = 0
                    top_down = false
                    left_right = true
                end
            end)
        else
            btn_val = 1
        end
        if gpio.read(btn2) == 0 then
            tmr.create():alarm(50, tmr.ALARM_SINGLE, function()
                if(gpio.read(btn2) == 0) then
                    btn_val2 = 0
                    top_down = false
                    left_right = true
                end
            end)
        else
            btn_val2 = 1
        end
    end

    if(left_right == true) then
        print("Sono left_right")
        if gpio.read(btn1) == 0 then
            tmr.create():alarm(50, tmr.ALARM_SINGLE, function()
                if(gpio.read(btn1) == 0) then
                    btn_val = 0
                    left_right = false
                    top_down = true
                end
            end)
        else
            btn_val = 1
        end
        if gpio.read(btn2) == 0 then
            tmr.create():alarm(50, tmr.ALARM_SINGLE, function()
                if(gpio.read(btn2) == 0) then
                    btn_val2 = 0
                    left_right = false
                    top_down = true
                end
            end)
        else
            btn_val2 = 1
        end
    end
end)

tmr.create():alarm(600, tmr.ALARM_AUTO, function()
    if (btn_val == 0 or btn_val2 == 0) and game_status == 0 then 
        print("Void led matrix\n")
        display.write(void)

        tmr.delay(10000)
        print("Print player led\n")
        display.write(first_position_player)
        game_status = game_status+1
    end
end)

tmr.create():alarm(800, tmr.ALARM_AUTO, function()
    if(game_status > 0)then

        if(top_down == true) then 
            --Movimento dall'alto verso il basso, aumenta lo stesso valore esadecimale moltiplicando x2 
            first_position_player[cont_top_down] = first_position_player[cont_top_down]*2
            print(first_position_player[cont_top_down])
            display.write(first_position_player)
            if first_position_player[cont_top_down] > 128 then
                game_status = 0
                display.write(cross)
            end
        end

        if(left_right == true) then 
            --Movimento da sinisgtra verso destra, vieni shiftato verso destra(da fondo verso cima) il bite
            --con valore diverso da 0 es( 0x01 viene spostato a destra e la sua posizione viene occupata con 0x00)
            print(first_position_player[cont_left_right])
            print(first_position_player[cont_left_right]+1)
            first_position_player[cont_left_right+1] = first_position_player[cont_left_right]
            first_position_player[cont_left_right] = 0x00
            cont_top_down = cont_top_down+1
            cont_left_right = cont_left_right+1
        end
        
    end    
end)