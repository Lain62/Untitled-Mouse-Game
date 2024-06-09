module RatGame
    class Spawn < EntityWithSprites
        def initialize(data, level)
            super(data)
            @level = level
            @path = Globals.atlas
            @tile_x = 0
            @tile_y = 8 * 16
            @tile_w = 16
            @tile_h = 16

        end

        def ui
            Globals.state.scene.world.ui
        end

        def update
            super
            if @level.mouse == nil
                @level.mouse = Mouse.new(@x, @y, @level)
            end

            return if @level.mouse == nil

            if @level.mouse.is_dead? && @level.mouse.spawn_point == 0
                if ui.death.time == 1
                    @level.mouse.x = @x
                    @level.mouse.y = @y
                    @level.mouse.revive
                end
            end
        end

        def draw
            super
            Globals.outputs[:batch].sprites << self
            
        end
    end
end