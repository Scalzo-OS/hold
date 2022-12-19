function love.load()
    math.randomseed(os.time())
    love.window.setFullscreen(true)
    window = {}
    window.x, window.y = love.graphics.getDimensions()
    window.scale = 3

    world = {}
    world.x, world.y = window.x/window.scale, window.y/window.scale

    p = {}
    p.x, p.y = 10, world.y/2
    p.speed = 0
    p.max = 0.1
    score = 0
    timer = 0
    blast = 0
    gameover = false

    love.graphics.setDefaultFilter('nearest', 'nearest')
    canvas = love.graphics.newCanvas(window.x/window.scale, window.y/window.scale)

    coins = {}
    particles = {}
    enemies = {}
    bg = {}
end

function keydown(key)
    return love.keyboard.isDown(key)
end

function todt(n)
    return n*60
end

function torad(d)
    return d*math.pi/180
end

function round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end

function love.update(dt)
    if not gameover then
        timer = timer + dt + dt*blast
        score = score + 0.0001 + 0.001*blast
        if math.random(1, 60-(40*(2/math.pi))*math.atan(timer/30)) == 1 then
            if math.random(1, 5) ~= 5 then
                table.insert(coins, {world.x+20, math.random(10, world.y-10), 2, 1, {1, 1, 0}})
            else
                table.insert(coins, {world.x+20, math.random(10, world.y-10), 7, 5, {0.8, 0.8, 0.8}})
            end
        end
        
        for i=1, math.random(1, math.floor(0.5+timer/60)) do
            if math.random(1, 60-(60*(2/math.pi))*math.atan(timer/30)) == 1 then
                table.insert(enemies, {world.x+20, math.random(10, world.y-10)})
            end
        end
        
        table.insert(bg, {world.x+10, math.random(0, world.y), math.random(2.5, 4.5), math.random(0.1, 5)})

        for i=#bg, 1, -1 do
            if bg[i][1] < 0 then
                table.remove(bg, i)
            else
                bg[i][1] = bg[i][1] - todt(bg[i][3]+blast)*dt
            end
        end

        if keydown('w') and blast < 5 then
            blast = blast + 0.1
        elseif not keydown('w') and blast > 0 then
            blast = blast - 0.3
        elseif blast < 0 then blast = 0 end

        for i=#coins, 1, -1 do
            if math.sqrt((p.x - coins[i][1])^2+(p.y-coins[i][2])^2) < 15 then
                for _=1, math.random(10, 40) do
                    if coins[i][4] == 1 then
                        table.insert(particles, {
                            x = coins[i][1],
                            y = coins[i][2],
                            s = math.random()*math.random(1, 3),
                            dir = torad(math.random(0, 360)),
                            colour = {math.random(0.9, 1), math.random(0.9, 1), 0},
                            r = math.random(1, 5)
                        })
                    else
                        local a = math.random(0.7, 0.9)
                        table.insert(particles, {
                            x = coins[i][1],
                            y = coins[i][2],
                            s = math.random()*math.random(1, 3),
                            dir = torad(math.random(0, 360)),
                            colour = {a, a, a},
                            r = math.random(1, 5)
                        })
                    end
                end
                score = score + coins[i][4]
                table.remove(coins, i)
            elseif coins[i][1] < 0 then
                table.remove(coins, i)
            else
                coins[i][1] = coins[i][1] - todt(coins[i][3]+blast)*dt
            end
        end

        for i=#enemies, 1, -1 do
            if enemies[i][1] < 0 then
                table.remove(enemies, i)
            elseif math.sqrt((p.x-enemies[i][1])^2+(p.y-enemies[i][2])^2) < 15 then
                table.remove(enemies, i)
                gameover = true
            else
                enemies[i][1] = enemies[i][1] - todt(2+blast)*dt
            end
        end

        if keydown('space') and p.speed < todt(5) then
            p.speed = p.speed + todt(p.max)
        elseif not keydown('space') and p.speed > todt(-5) then
            p.speed = p.speed - todt(p.max)
        end

        if (p.speed < 0 and p.y < world.y-10) or (p.speed > 0 and p.y > 10) then
            p.y = p.y - p.speed*dt
        else
            p.speed = 0
        end

        for i=#particles, 1, -1 do
            if particles[i].x < 1 or particles[i].x > world.x or particles[i].s < 1/1000 or
            particles[i].y < 0 or particles[i].y > world.y then
                table.remove(particles, i)
            else
                particles[i].x = particles[i].x + todt(particles[i].s)*dt*math.cos(particles[i].dir) - 10*(particles[i].x/world.x)
                particles[i].y = particles[i].y + todt(particles[i].s)*dt*math.sin(particles[i].dir)
                particles[i].s = particles[i].s - particles[i].s/100
                particles[i].r = particles[i].r - particles[i].r/100
            end
        end
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    if not gameover then
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.print(round(score, 3), world.x/2)

        love.graphics.setFont(love.graphics.newFont(40))
        love.graphics.setColor(1, 1, 1, 0.5-(0.5*(2/math.pi)*math.atan(timer)))
        love.graphics.printf('space to go up', 0, world.y/2-100, world.x, 'center')
        love.graphics.printf('w to boost', 0, world.y/2, world.x, 'center')
        love.graphics.printf('esc to escape', 0, world.y/2+100, world.x, 'center')

        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineStyle('rough')

        
        for i=1, #particles do
            love.graphics.setColor(particles[i].colour[1], particles[i].colour[2], particles[i].colour[3])
            love.graphics.circle('fill', particles[i].x, particles[i].y, particles[i].r)
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.circle('fill', p.x, p.y, 10)

        love.graphics.setColor(1, 1, 1, 0.3)

        for i=1, #bg do
            love.graphics.line(bg[i][1]-bg[i][4], bg[i][2], bg[i][1]+bg[i][4], bg[i][2])
        end

        for i=1, #coins do
            love.graphics.setColor(coins[i][5][1], coins[i][5][2], coins[i][5][3])
            love.graphics.circle('fill', coins[i][1], coins[i][2], 5)
        end

        love.graphics.setColor(1, 0, 0)
        for i=1, #enemies do
            love.graphics.circle('fill', enemies[i][1], enemies[i][2], 5)
        end
    else
        
        --love.graphics.printf(text, x, y, limit, align)
        love.graphics.setFont(love.graphics.newFont(50))
        love.graphics.printf('game over', 0, world.y/2-100, world.x, 'center')

        love.graphics.setFont(love.graphics.newFont(30))
        love.graphics.printf('your score was: '..round(score), 0, world.y/2+50, world.x, 'center')
        love.graphics.printf('press r to restart', 0, world.y/2+90, world.x, 'center')
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(canvas, 0, 0, 0, window.scale, window.scale)
    love.graphics.setBlendMode('alpha')
end

function love.keypressed(key)
    if key == 'escape' then love.event.quit() end 
    if key == 'a' then p.max = p.max + 0.1 end
    if key == 's' then p.max = p.max - 0.1 end
    if key == 'r' and gameover then love.load() end
end