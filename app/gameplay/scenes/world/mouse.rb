module RatGame
    class Mouse < Sprites
        attr_accessor :collision_blocks
        def initialize(x, y)
            @x = x
            @y = y
            @w = 16
            @h = 16
            @dx = 0
            @dy = 0
            @xremainder = 0.0
            @yremainder = 0.0
            @dxmovement = 0
            @dymovement = 0
            @gravity = 0
            @gravity_max = 3
            @jump = 0
            @jump_max = 14
            @jump_power = 3
            @jump_count = 0
            @jump_count_max = 2
            @speed = 1.2
            @path = Globals.atlas
            @tile_x = 0
            @tile_y = 0
            @tile_w = 16
            @tile_h = 16
            @flip_horizontally = false
            @collision_blocks = []
        end

        ###########
        # ANIMATION
        ###########
        # TODO: REIMPLEMENT THE ANIMATION WALK LOOP AND ANIMATION JUMP WITH YOUR OWN METHOD

        def animation_flip_horizontally
            if @dx > 0
                @flip_horizontally = false
            elsif @dx < 0
                @flip_horizontally = true
            end
        end

        def animation_walk_loop
            start_looping_at = 0
            number_of_sprites = 4
            sprites_interval = 4
            sprite_loop = true

            sprite_index = start_looping_at.frame_index(number_of_sprites, sprites_interval, sprite_loop)

            sprite_index ||= 0

            if @dx != 0 && @dy == 0
                @tile_x = (2 * 16) + (sprite_index * 16)
            elsif @dx == 0 && @dy == 0
                @tile_x = 0
            end
        end

        def animation_jump
            if @dy != 0
                @tile_x = 1 * @tile_w
            end
        end

        def animation
            animation_flip_horizontally
            animation_walk_loop
            animation_jump
        end

        ###########
        # MOVEMENT
        ###########

        def move_jump
            if Globals::Inputs.a_down && @jump_count > 0
                @jump = @jump_max
                @jump_count -= 1
            end

            if @jump > 0
                @jump -= 1
                @dymovement = @jump_power 
                if !Globals::Inputs.a
                    @jump = 0
                end
            end
        end

        def move_gravity
            if !is_grounded? && @jump == 0
                @gravity += 0.25 unless @gravity >= @gravity_max
                @jump_count = 1 if @jump_count > 1
                @dymovement = -@gravity
            elsif is_grounded? && @jump == 0
                @jump_count = @jump_count_max
                @gravity = 0
                @dymovement = 0
            end

            if @jump != 0
                @gravity = 0
            end
        end

        def move_x(amount, on_collide = nil)
            @xremainder += amount
            move = @xremainder.round()
            if move != 0
                @xremainder -= move
                sign = move.sign
                while move != 0
                    if !collide_at([@x + sign, @y])
                        @x += sign
                        move -= sign
                    else
                        if on_collide != nil
                            on_collide
                        end
                        break
                    end
                end
            end
        end

        def move_y(amount, on_collide = nil)
            @yremainder += amount
            move = @yremainder.round()
            if move != 0
                @yremainder -= move
                sign = move.sign
                while move != 0
                    if !collide_at([@x, @y + sign])
                        @y += sign
                        move -= sign
                    else
                        if on_collide != nil
                            on_collide
                        end
                        break
                    end
                end
            end
        end

        def move_input_left_right
            @dxmovement = 1 * @speed if Globals::Inputs.right
            @dxmovement = -1 * @speed if Globals::Inputs.left
            @dxmovement = 0 if !Globals::Inputs.right && !Globals::Inputs.left
        end

        def move_inside_wall
            @collision_blocks.each do |block|
                if Globals.geometry.intersect_rect?(block, {
                    x: hitbox.x,
                    y: hitbox.y,
                    w: hitbox.w,
                    h: hitbox.h})
                    block_center = [block.x + block.w / 2, block.y + block.h / 2]
                    player_center = [hitbox.x + hitbox.w / 2, hitbox.y + hitbox.h / 2]
                    if player_center.y > block_center.y
                        move_y(1)
                    elsif player_center.y < block_center.y
                        move_y(-1)
                    end

                    if player_center.x > block_center.x
                        move_x(1)
                    elsif player_center.x < block_center.x
                        move_x(-1)
                    end
                end
            end

        end

        def move_move
            @dx = @dxmovement
            @dy = @dymovement
            # @dy = -1

            move_x(@dx)
            move_y(@dy)
            # @y += @dy
        end

        def move
            move_input_left_right
            move_jump
            move_gravity
            move_move
            move_inside_wall
        end

        ##########
        # MAIN
        ##########

        def update
            super
            move
        end

        def draw
            super
            animation
            Globals.outputs.debug << "#{is_falling?}"
            Globals.outputs[:batch].sprites << self
        end

        ###########
        # UTILS
        ###########

        def is_jumping?
            if @jump > 0
                return true
            else
                return false
            end
        end

        def is_falling?
            if @gravity > 0
                return true
            else
                return false
            end
        end
        
        def collide_at(pos)
            @collision_blocks.any? do |block|
                Globals.geometry.intersect_rect?(block, {
                    x: pos.x,
                    y: pos.y,
                    w: hitbox.w,
                    h: hitbox.h
                })
            end
        end

        def is_grounded?
            @collision_blocks.any? do |block|
                Globals.geometry.intersect_rect?(block, {
                    x: hitbox.x,
                    y: hitbox.y - 1,
                    w: hitbox.w,
                    h: hitbox.h
                })
            end
        end
        
        def hitbox
            {
                x: @x + 1,
                y: @y,
                w: @w - 2,
                h: @h / 2
            }
        end

    end
end