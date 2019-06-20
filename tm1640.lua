local Tm1640 = { }

local MOSI = 7
local SCLK = 5
local BITDELAY = 10
local TM1640_CMD1 = 0x40   -- data command
local TM1640_CMD2 = 0xC0   -- address command
local TM1640_CMD3 = 0x80   -- display control command
local TM1640_DSP_ON = 0x08 -- display on


function send_start()
    gpio.write(MOSI, gpio.LOW)
    tmr.delay(BITDELAY)
    gpio.write(SCLK, gpio.LOW)
    tmr.delay(BITDELAY)
end

function send_end()
    gpio.write(MOSI, gpio.LOW)
    tmr.delay(BITDELAY)
    gpio.write(SCLK, gpio.HIGH)
    tmr.delay(BITDELAY)
    gpio.write(MOSI, gpio.HIGH)
end

function write_byte(data, len)
    for i = 0, (len * 8) - 1, 1 do
        if bit.isset(data, i) then
            gpio.write(MOSI, gpio.HIGH)
        else
            gpio.write(MOSI, gpio.LOW)
        end
        tmr.delay(BITDELAY)
        gpio.write(SCLK, gpio.HIGH)
        tmr.delay(BITDELAY)
        gpio.write(SCLK, gpio.LOW)
        tmr.delay(BITDELAY)
    end
end

function cmd()
    send_start()
    write_byte(TM1640_CMD1, 1)
    send_end()
end

function dsp_ctrl(brightness)
    send_start()
    write_byte(bit.bor(TM1640_CMD3, TM1640_DSP_ON, brightness), 1)
    send_end()
end

function Tm1640.off(brightness)
    send_start()
    write_byte(bit.bor(TM1640_CMD3), 1)
    send_end()
end

function Tm1640.brightness(val)
    cmd()
    dsp_ctrl(val)
end

function Tm1640.write(rows)
    cmd()
    send_start()
    write_byte(TM1640_CMD2, 1)
    if rows == nil then
        return
    end
    for i,v in ipairs(rows) do
        write_byte(v, 1)
    end
    send_end()
end

function Tm1640.write_pos(rows, pos)
    cmd()
    send_start()
    write_byte(bit.bor(TM1640_CMD2, pos), 1)
    for i,v in ipairs(rows) do
    write_byte(v, 1)
    end
    send_end()
end

function Tm1640.init(mosi, sclk)
    MOSI = mosi
    SCLK = sclk
    gpio.mode(MOSI, gpio.OUTPUT)
    gpio.mode(SCLK, gpio.OUTPUT)
    gpio.write(MOSI, gpio.LOW)
    gpio.write(SCLK, gpio.LOW)
    tmr.delay(BITDELAY)
    cmd()
    dsp_ctrl(0)
end

return Tm1640
