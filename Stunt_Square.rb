require 'ruby2d'

set background: '#FCF5B9'
set width: 900
set height: 650
BALL_SIZE=8
SQUARE_SIZE=20
class Game
  attr_writer :direction # allows edit direction
  attr_reader :direction
  attr_reader :array_direction # allows to read in the array outside class
  attr_writer :level # allows to change level
  attr_reader :level
  attr_reader :x # allows to read the x coordinates value of the square
  attr_reader :y # allows to read the y coordinates value of the sqauare
  attr_writer :level_complete
  attr_writer :time
  attr_reader :time
  attr_writer :num_color
  attr_reader :num_color
  def initialize(speed)
    @direction=nil # set direction to null
    @array_direction=[] # array to hold the directions on a specific frame
    @x_speed=speed # set speed of the square through the x-axis
    @y_speed=speed # set speed of the square through the y-axis
    @level=0 # the level you are currently on 1-5
    $level_bounds=[[]] # out of bounds for each level
    $sharp_triangles=[[],[],[]]#sharp triangles for each level
    for a in 0..16 # create sharp triangles for level 2 these are icicles
      $sharp_triangles[1].push(175)
      $sharp_triangles[1].push(175)
      $sharp_triangles[1].push(210)
    end
    $time_descent=[[],[60,200,90,30,20,300,250,150,130,260,300,120,90,60,150,90,140]]# start time for an object to start falling for each level
    $time_fall=[[],[],[],[]] #indicate the right time for an object to start falling
    for a in 0..9
      $time_fall[1].push(false) # stop objects from falling
    end
    $keys=[[],[false]]#keys to open a door that will lead to the finish line
    $random_colors_maze_1=[]# colors for level 3 obstacle
    $random_colors_maze_2=[]
    $square_position_start=[[100,105],[90,75],[50,40],[50,50],[75,80]]#start position of the square for each level
    @x= $square_position_start[@level-1][0]# starting position of the square - x-axis
    @y=$square_position_start[@level-1][1] # starting position of the square - y-axis
    $balls_speed_x=[[4,4],[],[],[5,5,5,5,5,5,5,5,5]] # adjust speed of ball x-axis
    $balls_speed_y=[[3,4],[],[],[5,5,5,5,5,5,5,5,5]] # adjust ball speed for each level in row and for each ball in the level
    $balls_array_x_pos=[[215,215],[],[],[235]]# x position of the balls for each level in each row
    $balls_array_y_pos=[[200,225],[],[],[250]]# y position of the balls for each level in each row
    $finish_colors=[[0],[0],[0],[0],[0]] # colors the indicate the checkered flag at the end
    $lines_array=[100,50,600,50]# array obstacle for level 4
    $enemy_squares_x=[[],[],[],[],[]] # positions of the enemy squares on the x-axis
    $enemy_squares_y=[[],[],[],[],[]] # positions of the enemy squares on the y-axis
    $enemy_speed_x=[[],[],[],[],[]] # speed of the enemy squares on the x-axis
    $enemy_speed_y=[[],[],[],[],[]] # speed of the enemy squares on the y-axis
    $chase_mode=[[],[],[],[],[]] # check if the squares are in chase mode
    @inbound=false # checks if the square is in bounds of the arena
    @level_complete=false # check if level was completed
    @level_1_start=false # start level 1
    @level_2_start=false # start level 2
    @level_3_start=false # start level 3
    @level_4_start=false # start level 4
    @level_5_start=false # start level 5
    @time=0 # time passed at the start
    @num_color=0# indicates color choice
    @enemy_direction=0 # random enemy direction
    @survival_time=0 # time to survive a round

  end
  def level_1 # level 1 arena
    if @level_1_start==false # if the level hasnt started
      @x=$square_position_start[@level-1][0]  # start the square at this position
      @y=$square_position_start[@level-1][1]
      @level_1_start=true # start the level
    end
    hero=Square.new(x:@x,y:@y,color:'#FF32DF',size:SQUARE_SIZE) # the square used to move around the arena
    $balls_array_x_pos[0][0]=225 # position of the first ball
    for a in 0..8 # create 9 balls together with same y-axis but adjusting the x-axis each iteration
      Circle.new(x: $balls_array_x_pos[0][0], y: $balls_array_y_pos[0][0], radius: BALL_SIZE, sectors: 32, color: 'fuchsia',opacity:0.4)# create a ball with its x and y-axis
      if death_square?($balls_array_x_pos[0][0],$balls_array_y_pos[0][0],hero,BALL_SIZE) # if the square is dead/touches a circle
        reset_square # reset the Square's position
      end
      $balls_array_x_pos[0][0]+=55# adjusting the x-axis of a new ball each iteration
    end
    Circle.new(x: $balls_array_x_pos[0][1], y: $balls_array_y_pos[0][1], radius: BALL_SIZE, sectors: 32, color: 'fuchsia',opacity:0.4)
    if death_square?($balls_array_x_pos[0][1],$balls_array_y_pos[0][1],hero,BALL_SIZE)
      reset_square
    end
    $balls_array_x_pos[0][1]+=$balls_speed_x[0][1] # make this second ball go diagonally around the middle
    for a in 0..$balls_array_y_pos[0].size-1 # 2 balls
      $balls_array_y_pos[0][a]+=$balls_speed_y[0][a] # add different speeds for each ball in the array
    end

    Rectangle.new(x:50,y:100,width:150,height:200,color:'#FF80BB',opacity:0.2) # start area
    Rectangle.new(x:200,y:100,width:500,height:200,color:'#A5FFC5',opacity:0.2) # middle/action area
    rec = Rectangle.new(x:700,y:100,width:150,height:200,color:'#FF80BB',opacity:0.2) # end area
    if rec.contains?(@x,@y) # end the level if the square has touched the finish line
      finish_level
    end
    $level_bounds=[[50,100,150,200],[200,100,500,200],[700,100,150,200]] # array to hold the boundaries of the arena
    bounce_ball_side(200,700,1,2) # bounce the ball of the side
    bounce_ball_bottom(300-BALL_SIZE,1) # bounce off the bottom with the length of arena bottom
    bounce_ball_top(100+BALL_SIZE,1)# bounce off the top with the length of arena top
  end
  def level_2
    if @level_2_start==false
      @x=$square_position_start[@level-1][0]
      @y=$square_position_start[@level-1][1]
      @level_2_start=true
    end
    hero=Square.new(x:@x,y:@y,color:'#010101',size:SQUARE_SIZE) # the square used to move around the arena
    if $keys[@level-1][0]==false
      Image.new('key.png',x:450,y:320) # show key if it hasnt been collected
    end
    Rectangle.new(x:50,y:70,width:75,height:50,color:'#01C7FF',opacity:0.2) # start area
    Rectangle.new(x:50,y:120,width:75,height:250,color:'#01C7FF',opacity:0.1) # start area
    Rectangle.new(x:125,y:330,width:100,height:40,color:'#01C7FF',opacity:0.1) # start area
    Rectangle.new(x:225,y:175,width:500,height:350,color:'#01C7FF',opacity:0.1) # start area
    Rectangle.new(x:725,y:320,width:75,height:40,color:'#01C7FF',opacity:0.1) # start area
    Rectangle.new(x:800,y:320,width:40,height:300,color:'#01C7FF',opacity:0.1) # start area
    Rectangle.new(x:100,y:580,width:700,height:40,color:'#01C7FF',opacity:0.1) # start area
    key=Square.new(x:450,y:320,size:50,color:'red',opacity:0)
    $level_bounds=[[50,70,75,50],[50,120,75,250],[125,330,100,40],[225,175,500,350],
                   [800,320,40,300],[100,580,700,40]] # array for out of bounds(rectangles)
    if key.contains?(@x,@y)
      $keys[@level-1][0]=true # mark the key as collected
    end

    color_array=['white','black'] # array to hold the colors of the finish line
    if @time%60==0
      $finish_colors[@level-1][0]+=1 #change colors every second
    end
    for a in 0..1 # for loop to display finish line
      Square.new(x:80,y:580,color:color_array[($finish_colors[@level-1][0]+a+1)%2],size:20)
      Square.new(x:60,y:580,color:color_array[($finish_colors[@level-1][0]+a)%2],size:20)
      Square.new(x:80,y:580+20,color:color_array[($finish_colors[@level-1][0]+a)%2],size:20)
      Square.new(x:60,y:580+20,color:color_array[($finish_colors[@level-1][0]+a+1)%2],size:20)
      finish =Square.new(x:80,y:580,color:'red',size:40,opacity:0)
      if finish.contains?(@x,@y)
        finish_level
      end
    end
    color_array=['green','orange','red'] # array to hold  colors
    cth=0 # change triangle height for each iteration upon creation
    for a in 0..6 # for loop for first obstacle
      t1=Triangle.new(x1: 50,  y1: 130+cth, x2: 80, y2: 140+cth, x3: 50,   y3: 150+cth, color: color_array[@num_color%3]) #create triangle
      t2=Triangle.new(x1: 125,  y1: 130+cth, x2: 90, y2: 140+cth, x3: 125,   y3: 150+cth, color: color_array[@num_color%3])#create spikes
      kill_rec_t1 = Rectangle.new(x:50,y:130+cth,width:35,height:20,color:'blue',opacity:0) # kill box if the square touches spikes
      kill_rec_t2 = Rectangle.new(x:90,y:130+cth,width:35,height:20,color:'blue',opacity:0) # kill box if the square touches spikes
      if color_array[@num_color%3]=='red' &&(death_square?(@x,@y,kill_rec_t1,BALL_SIZE) ||death_square?(@x,@y,kill_rec_t2,BALL_SIZE))
        reset_square # kill the player when the spikes are of color red
      end
      cth+=30 # increment to spread out sharp triangles that kill the square
    end
    cth=0
    i=0 # index to go over each triangle
    for a in 0..16 #second obstacle
      t3 = Triangle.new(x1: 225+cth,  y1: $sharp_triangles[@level-1][i], x2: 250+cth, y2: $sharp_triangles[@level-1][i+1], x3: 237.5+cth,   y3: $sharp_triangles[@level-1][i+2], color: '#01DAFF')
      if @time%$time_descent[@level-1][a]==0 # if the time has reached this second,make the object fall
        $time_fall[@level-1][a]=true
      end

      if $time_fall[@level-1][a]==true # add speed to falling objects if they have reached their time
        $sharp_triangles[@level-1][i]+=5
        $sharp_triangles[@level-1][i+1]+=5
        $sharp_triangles[@level-1][i+2]+=5
      end
      if $sharp_triangles[@level-1][i] >= Window.height # if they go out of bound reset them to original position
        $sharp_triangles[@level-1][i]=175
        $sharp_triangles[@level-1][i+1]=175
        $sharp_triangles[@level-1][i+2]=210
      end

      cth+=30
      i+=3
      if $keys[@level-1][0]==true # unlock the door when key is collected
        $level_bounds.push([725,320,75,40])
      else
        Rectangle.new(x:725,y:320,width:75,height:40,color:'black',opacity:0.1) # locked door
      end
      if death_square?(@x,@y,t3,BALL_SIZE)
        reset_square
        $keys[@level-1][0]=false # key is shown again once square is dead
      end
    end
  end
  def populate_maze# populates random numbers into array
    for a in 0..20
      $random_colors_maze_1.push(rand(2))
      $random_colors_maze_2.push(rand(2))
    end
  end
  def level_3 # start level 3
    if @level_3_start==false
      @x=$square_position_start[@level-1][0]
      @y=$square_position_start[@level-1][1]
      @level_3_start=true
      populate_maze
    end
    hero=Square.new(x:@x,y:@y,color:'#FE4602',size:SQUARE_SIZE) # the square used to move around the arena
    Rectangle.new(x:50,y:40,width:30,height:30,color:'#01C7FF',opacity:0.2) # arena course
    Rectangle.new(x:50,y:70,width:600,height:510,color:'#01C7FF',opacity:0.2)
    finish=Square.new(x:650,y:550,color:'#750698',size:30) # finish line
    if finish.contains?(@x+SQUARE_SIZE,@y)
        finish_level # finish level if square has crossed this line
    end

    #Rectangle.new(x:650,y:550,width:30,height:30,color:'#01C7FF',opacity:0.2)
    $level_bounds=[[50,40,30,30],[50,70,600,510],[650,550,30,30]] # bounds for the square
    y=100
    rec_x=0
    colors_array=['red','lime'] # colors for the lines

    if @time%60==0 # shuffling array every second
      $random_colors_maze_1.shuffle!
      $random_colors_maze_2.shuffle!
    end
    for a in 0..15 #for loop to draw the lines that randomly switch between red and green
      x=30
      for b in 0..18
        l= Line.new(x1: 20+x, y1: y, x2: 80+x, y2: y, width: 2, color: colors_array[$random_colors_maze_1[b]])
        if (l.contains?(@x,@y) || l.contains?(@x,@y+20))&& colors_array[$random_colors_maze_1[b]]=='red'
          reset_square # reset square to original position if it touches the red line
        end
        x+=30
      end
      y+=30
    end
    x=80
    for a in 0..18
      y=70
      for b in 0..16
        l=Line.new(x1: x, y1: y, x2: x, y2: y+30, width: 2, color: colors_array[$random_colors_maze_2[b]])
        if (l.contains?(@x,@y) || l.contains?(@x+20,@y))&& colors_array[$random_colors_maze_2[b]]=='red'
          reset_square
        end
        y+=30
      end
      x+=30
    end
  end

  def level_4
    if @level_4_start==false
      @x=$square_position_start[@level-1][0] # starting position of the square
      @y=$square_position_start[@level-1][1]
      @level_4_start=true
      $time_fall[@level-1][0]=true # indicates which way the line will fall
      array_balls_position_x=[]
      array_balls_position_y=[]
      for a in 0..8
        array_balls_position_x.push(rand(101..500)) # random positions of the circles that will bounce around the arena
        array_balls_position_y.push(rand(101..500))
      end
      $balls_array_x_pos[@level-1]=array_balls_position_x
      $balls_array_y_pos[@level-1]=array_balls_position_y
    end
    hero=Square.new(x:@x,y:@y,color:'#FFCC00',size:SQUARE_SIZE) # the square used to move around the arena
    Rectangle.new(x:50,y:50,width:50,height:30,color:'#AEFFCF',opacity:0.2) # arena course
    Rectangle.new(x:100,y:50,width:500,height:500,color:'#AEFFCF',opacity:0.2) # arena course
    Rectangle.new(x:50,y:200,width:50,height:50,color:'#AEFFCF',opacity:0.2) # arena course
    Rectangle.new(x:50,y:200,width:50,height:50,color:'#AEFFCF',opacity:0.2) # arena course
    finish =Rectangle.new(x:600,y:510,width:40,height:40,color:'#AEFFCF',opacity:0.1) # arena course

    colors =['black','white']

    $level_bounds=[[50,50,50,30],[100,50,500,500],[50,200,50,50],[600,510,40,40]] # boundaries of level 4
    color_lines=['red','lime']
    if @time%60==0
      @num_color+=1 # change color every second
    end
    if finish.contains?(@x,@y)
      finish_level # end the level
    end
    Square.new(x:600,y:510,color:colors[@num_color%2],size:20) # these squares represent the finish line
    Square.new(x:600,y:530,color:colors[(@num_color+1)%2],size:20)
    Square.new(x:620,y:510,color:colors[(@num_color+1)%2],size:20)
    Square.new(x:620,y:530,color:colors[@num_color%2],size:20)



    l=Line.new(x1: $lines_array[0], y1: $lines_array[1], x2: $lines_array[2], y2: $lines_array[3], width: 2, color: color_lines[@num_color%2])
    if $lines_array[1]>=550 # create lines that change color every second and do not go out of bounds
      $time_fall[@level-1][0]=false
    elsif
      $lines_array[1]<=50
        $time_fall[@level-1][0]=true
    end

    if $time_fall[@level-1][0]==true
      for a in 0..3
        if a%2==1
          $lines_array[a]+=2
        end
      end
    else
      for a in 0..3
        if a%2==1
          $lines_array[a]-=2
        end
      end
    end
    if (l.contains?(@x,@y+(SQUARE_SIZE/2)) ||  l.contains?(@x,@y-(SQUARE_SIZE/2)))&& color_lines[@num_color%2]=='red' # if square crosses red line
      reset_square # square is dead and returned to start
    end
    square_y_position=100
    for a in 0..8 # create 9 circles that bounce around the arena
      enemy=Circle.new(x: $balls_array_x_pos[@level-1][a], y: $balls_array_y_pos[@level-1][a], radius: BALL_SIZE, sectors: 32, color: 'fuchsia')
      $balls_array_x_pos[@level-1][a]+=$balls_speed_x[@level-1][a]
      $balls_array_y_pos[@level-1][a]+=$balls_speed_y[@level-1][a]
      bounce_ball_side(100,600,@level,a)
      if death_square?($balls_array_x_pos[@level-1][a],$balls_array_y_pos[@level-1][a],hero,BALL_SIZE)
        reset_square
      end
    end
    for a in 0..6# create up to 50 squares that act as obstacles
      square_x_position=130
      for b in 0..8
        shape=Square.new(x:square_x_position,y:square_y_position,color:'red',size:20)
        for c in 0..8 # bounce off circles if they touch a square
          if shape.contains?($balls_array_x_pos[@level-1][c],$balls_array_y_pos[@level-1][c]-BALL_SIZE)
            $balls_speed_x[@level-1][c]*=-1
          elsif shape.contains?($balls_array_x_pos[@level-1][c]+BALL_SIZE,$balls_array_y_pos[@level-1][c])
            $balls_speed_y[@level-1][c]*=-1
          elsif shape.contains?($balls_array_x_pos[@level-1][c]-BALL_SIZE,$balls_array_y_pos[@level-1][c])
            $balls_speed_x[@level-1][c]*=-1
          elsif shape.contains?($balls_array_x_pos[@level-1][c],$balls_array_y_pos[@level-1][c]+BALL_SIZE)
            $balls_speed_x[@level-1][c]*=-1
          end
        end
        obstacle_bounce(shape) # squares that act as obstacles
        square_x_position+=50
      end
      square_y_position+=60
    end
    bounce_ball_bottom(550,@level) # bounce balls of the bottom
    bounce_ball_top(50,@level)# bounce balls of the top
  end

  def level_5
    if @level_5_start==false
      @x=$square_position_start[@level-1][0] # starting position of the square
      @y=$square_position_start[@level-1][1]
      @level_5_start=true
      enemy_square_x=[]
      enemy_square_y=[] # random positions of enemy squares at the start of each round
      @survival_time=300
      for a in 0..9
        enemy_square_x.push(rand(165..500))
        enemy_square_y.push(rand(165..500))
        $enemy_speed_x[@level-1].push(3)
        $enemy_speed_y[@level-1].push(3)
        random_chase = rand(2)
        if random_chase==0 # force the enemy squares into chase mode
          $chase_mode[@level-1].push(false)
        else
          $chase_mode[@level-1].push(true)
        end
      end
      $enemy_squares_x[@level-1]= enemy_square_x
      $enemy_squares_y[@level-1]= enemy_square_y
    end
    #Text.new("Survive for #{@survival_time} seconds!",color:'red')
    hero=Square.new(x:@x,y:@y,color:'#FFCC00',size:SQUARE_SIZE) # the square used to move around the arena
    middle=Rectangle.new(x:70,y:70,width:650,height:500,color:'#A70909',opacity:0.1) # arena course
    time_remaining=Rectangle.new(x:70,y:20,width:@survival_time,height:20,color:'#8F0000',opacity:0.1) # arena course
    obstacle_1=Rectangle.new(x:140,y:100,width:20,height:100,color:'#8F0000',opacity:0.1) # obstacle
    obstacle_2=Rectangle.new(x:640,y:100,width:20,height:100,color:'#8F0000',opacity:0.1) # arena course
    obstacle_3=Rectangle.new(x:140,y:450,width:20,height:100,color:'#8F0000',opacity:0.1) # arena course
    obstacle_4=Rectangle.new(x:640,y:450,width:20,height:100,color:'#8F0000',opacity:0.1) # arena course
    obstacle_5=Rectangle.new(x:325,y:300,width:100,height:20,color:'#8F0000',opacity:0.1) # arena course
    $level_bounds=[[70,70,650,500]] # bounds for the arena
    for a in 0..9 # create 10 enemy squares
      enemy=Square.new(x:$enemy_squares_x[@level-1][a],y:$enemy_squares_y[@level-1][a],color:'#010101',size:SQUARE_SIZE)
      if obstacle_1.contains?($enemy_squares_x[@level-1][a],$enemy_squares_y[@level-1][a]) # square will bounce off this obstacle
        $enemy_speed_x[@level-1][a]*=-1
        $enemy_speed_y[@level-1][a]*=-1
      elsif  obstacle_2.contains?($enemy_squares_x[@level-1][a],$enemy_squares_y[@level-1][a])
          $enemy_speed_x[@level-1][a]*=-1
          $enemy_speed_y[@level-1][a]*=-1
      elsif  obstacle_3.contains?($enemy_squares_x[@level-1][a],$enemy_squares_y[@level-1][a])
        $enemy_speed_x[@level-1][a]*=-1
        $enemy_speed_y[@level-1][a]*=-1
      elsif  obstacle_4.contains?($enemy_squares_x[@level-1][a],$enemy_squares_y[@level-1][a])
        $enemy_speed_x[@level-1][a]*=-1
        $enemy_speed_y[@level-1][a]*=-1
      elsif  obstacle_5.contains?($enemy_squares_x[@level-1][a],$enemy_squares_y[@level-1][a])
        $enemy_speed_x[@level-1][a]*=-1
        $enemy_speed_y[@level-1][a]*=-1
      end
      if death_square?(@x,@y,enemy,20)
        reset_square
        @level_5_start=false # restart round if hero dies
      end
      obstacle_bounce(obstacle_1)
      obstacle_bounce(obstacle_2)
      obstacle_bounce(obstacle_3)
      obstacle_bounce(obstacle_4)
      obstacle_bounce(obstacle_5) # bounce the hero off an obstacle

    end
    if @time%180==0
      rand_direction = rand(3)
      @enemy_direction+=rand_direction # change enemy square direction every 3 seconds
    end
    if @time%12==0
      @survival_time-=1 # decrease time limit every 0.2 seconds
      if @survival_time==0
        finish_level # end the level if hero survives a full minute
      end
    end
    if @time%60==0
      for a in 0..9
        chase = rand(2)
        if chase==0 # randomize chase mode  array every second
          $chase_mode[@level-1][a]=false
        else
          $chase_mode[@level-1][a]=true
        end
      end
    end


    bounce_square_top(68) # boundary limit
    for a in 0..9
      bounce_square_side(68,718,a)
      if $chase_mode[@level-1][a]==false # squares will act in random direction if not in chase mode
        case @enemy_direction%3
        when 0
          $enemy_squares_x[@level-1][a]-=$enemy_speed_x[@level-1][a]
        when 1
          $enemy_squares_y[@level-1][a]-=$enemy_speed_y[@level-1][a]
        when 2
          $enemy_squares_x[@level-1][a]-=$enemy_speed_x[@level-1][a]
          $enemy_squares_y[@level-1][a]-=$enemy_speed_y[@level-1][a]
        end
      end
    end
    bounce_square_bottom(570)

    for a in 0..9 # squares chase the hero around if in chase mode
      if $chase_mode[@level-1][a]
      if $enemy_squares_x[@level-1][a]>=@x-$enemy_speed_x[@level-1][a]&&$enemy_squares_x[@level-1][a]<=@x+$enemy_speed_x[@level-1][a]
        if $enemy_squares_x[@level-1][a]>=@x
          $enemy_squares_y[@level-1][a]+=$enemy_speed_y[@level-1][a]
        else
          $enemy_squares_y[@level-1][a]-=$enemy_speed_y[@level-1][a]
        end
      elsif $enemy_squares_y[@level-1][a]>=@y-$enemy_speed_y[@level-1][a]&&$enemy_squares_y[@level-1][a]<=@y+$enemy_speed_y[@level-1][a]
        if $enemy_squares_y[@level-1][a]>= @y
          $enemy_squares_x[@level-1][a]-=$enemy_speed_x[@level-1][a]
        else
          $enemy_squares_x[@level-1][a]+=$enemy_speed_x[@level-1][a]
        end
      else
        if $enemy_squares_y[@level-1][a]>@y
          if $enemy_squares_x[@level-1][a]>@x
            case @enemy_direction%3
            when 0
              $enemy_squares_x[@level-1][a]-=$enemy_speed_x[@level-1][a]
            when 1
              $enemy_squares_y[@level-1][a]-=$enemy_speed_y[@level-1][a]
            when 2
              $enemy_squares_x[@level-1][a]-=$enemy_speed_x[@level-1][a]
              $enemy_squares_y[@level-1][a]-=$enemy_speed_y[@level-1][a]
            end
          else
            case @enemy_direction%3
            when 0
              $enemy_squares_x[@level-1][a]+=$enemy_speed_x[@level-1][a]
            when 1
              $enemy_squares_y[@level-1][a]+=$enemy_speed_y[@level-1][a]
            when 2
              $enemy_squares_x[@level-1][a]+=$enemy_speed_x[@level-1][a]
              $enemy_squares_y[@level-1][a]+=$enemy_speed_y[@level-1][a]
            end

          end
        elsif $enemy_squares_y[@level-1][a]<@y
          if $enemy_squares_x[@level-1][a]>@x
            case @enemy_direction%3
            when 0
              $enemy_squares_x[@level-1][a]-=$enemy_speed_x[@level-1][a]
            when 1
              $enemy_squares_y[@level-1][a]-=$enemy_speed_y[@level-1][a]
            when 2
              $enemy_squares_x[@level-1][a]-=$enemy_speed_x[@level-1][a]
              $enemy_squares_y[@level-1][a]-=$enemy_speed_y[@level-1][a]
            end
          else
            case @enemy_direction%3
            when 0
              $enemy_squares_x[@level-1][a]+=$enemy_speed_x[@level-1][a]
            when 1
              $enemy_squares_y[@level-1][a]+=$enemy_speed_y[@level-1][a]
            when 2
              $enemy_squares_x[@level-1][a]+=$enemy_speed_x[@level-1][a]
              $enemy_squares_y[@level-1][a]+=$enemy_speed_y[@level-1][a]
            end

          end
        end
      end
      end
    end
  end

  def bounce_square_bottom(height_bottom)
    for a in 0..$enemy_squares_y[@level-1].size-1 # level of that the ball is in
      if $enemy_squares_y[@level-1][a]+SQUARE_SIZE>=height_bottom # check if ball is out of bounds
        $enemy_speed_y[@level-1][a]*=-1 # make the ball go the opposite direction
      end
    end
  end
  def bounce_square_top(height_top)
    for a in 0..$enemy_squares_y[@level-1].size-1
      if $enemy_squares_y[@level-1][a]<=height_top # check if ball is out of bounds
        $enemy_speed_y[@level-1][a]*=-1 # make the ball go the opposite direction
      end
    end
  end
  def bounce_square_side(x1,x2,square_num)
    if $enemy_squares_x[@level-1][square_num]-1 <=x1|| $enemy_squares_x[level-1][square_num]+SQUARE_SIZE+1 >=x2 #check bounds
      $enemy_speed_x[@level-1][square_num]*=-1 # opposite direction for this ball
    end
  end

  def bounce_ball_bottom(height_bottom,level)
    for a in 0..$balls_array_y_pos[level-1].size-1 # level of that the ball is in
      if $balls_array_y_pos[level-1][a]+BALL_SIZE>=height_bottom # check if ball is out of bounds
        $balls_speed_y[level-1][a]*=-1 # make the ball go the opposite direction
      end
    end
  end
  def bounce_ball_top(height_top,level)
    for a in 0..$balls_array_y_pos[level-1].size-1
      if $balls_array_y_pos[level-1][a]-BALL_SIZE<=height_top # check if ball is out of bounds
        $balls_speed_y[level-1][a]*=-1 # make the ball go the opposite direction

      end
    end
  end
  def bounce_ball_side(x1,x2,level,ball_number) # bounce the ball of the side of the arena
    if $balls_array_x_pos[level-1][ball_number-1] <=x1+BALL_SIZE|| $balls_array_x_pos[level-1][ball_number-1] >=x2-BALL_SIZE #check bounds
      $balls_speed_x[level-1][ball_number-1]*=-1 # opposite direction for this ball
    end
  end
  def level_complete?# check if level is completer
    @level_complete
  end
  def finish_level
    @level_complete=true # set  the level as finished
  end

  def obstacle_bounce(shape) # do not let the square pass through an obstacle

    if (shape.contains?(@x,@y+20) ||shape.contains?(@x+20,@y+20))#down
      @y-=3
      @x-=2
    end
    if shape.contains?(@x,@y)||shape.contains?(@x,@y+20)#left
      @x+=3

    end
    if shape.contains?(@x+20,@y)||shape.contains?(@x+20,@y+20)#right
      @x-=3

    end

    if shape.contains?(@x+20,@y)||shape.contains?(@x,@y)#up
      @y+=3
      @x+=2
      print 'up'
    end
  end
  def death_square?(x,y,shape,kill_radius) # check if the square touches a circle or a square touches a shape's boundary
    if shape.contains?(x+kill_radius,y)||shape.contains?(x-kill_radius,y)||
      shape.contains?(x,y+kill_radius)||shape.contains?(x,y-kill_radius)
      return true
    end
    return false
  end

  def reset_square # reset the square to its original position in the level after its death
    @x=$square_position_start[@level-1][0]
    @y=$square_position_start[@level-1][1]
  end
  def check_out_of_bounds_right(right) # check if the ball goes out of bounds to the right
    @inbound=false
    for a in 0..$level_bounds.size-1 # create a rectangle for each  boundary
      rec= Rectangle.new(x:$level_bounds[a][0],y:$level_bounds[a][1],width:$level_bounds[a][2],height:$level_bounds[a][3],color:'#FF80BB',opacity:0)
      if rec.contains?(right,@y) # if the square is inside the boundary, return true
        @inbound=true
      end
    end
    @inbound # return false if the square is outside the right boundary
  end
  def check_out_of_bounds_left(left)#check if the ball goes out of bounds to the right
    @inbound=false
    for a in 0..$level_bounds.size-1   # create a rectangle for each  boundary
      rec= Rectangle.new(x:$level_bounds[a][0],y:$level_bounds[a][1],width:$level_bounds[a][2],height:$level_bounds[a][3],color:'#FF80BB',opacity:0)
      if rec.contains?(left,@y)# if the square is inside the boundary, return true
        @inbound=true
      end
    end
    @inbound  # return false if the square is outside the right boundary
  end
  def check_out_of_bounds_down(down)#check if the ball goes out of bounds to the right
    @inbound=false
    for a in 0..$level_bounds.size-1 # create a rectangle for each  boundary
      rec= Rectangle.new(x:$level_bounds[a][0],y:$level_bounds[a][1],width:$level_bounds[a][2],height:$level_bounds[a][3],color:'#FF80BB',opacity:0)
      if rec.contains?(@x,down) # if the square is inside the boundary, return true
        @inbound=true
      end
    end
    @inbound # return false if the square is outside the right boundary
  end
  def check_out_of_bounds_up(up)# check if outside the 'up' boundary
    @inbound=false
    for a in 0..$level_bounds.size-1
      rec= Rectangle.new(x:$level_bounds[a][0],y:$level_bounds[a][1],width:$level_bounds[a][2],height:$level_bounds[a][3],color:'#FF80BB',opacity:0)
      if rec.contains?(@x,up)
        @inbound=true
      end
    end
    @inbound
  end

  def check_out_of_bounds_left_up(left,up)# check if outside the  boundary
    @inbound=false
    for a in 0..$level_bounds.size-1
      rec= Rectangle.new(x:$level_bounds[a][0],y:$level_bounds[a][1],width:$level_bounds[a][2],height:$level_bounds[a][3],color:'#FF80BB',opacity:0)
      if rec.contains?(left,up)
        @inbound=true
      end
    end
    @inbound
  end
  def check_out_of_bounds_left_down(left,down)
    @inbound=false
    for a in 0..$level_bounds.size-1
      rec= Rectangle.new(x:$level_bounds[a][0],y:$level_bounds[a][1],width:$level_bounds[a][2],height:$level_bounds[a][3],color:'#FF80BB',opacity:0)
      if rec.contains?(left,down)
        @inbound=true
      end
    end
    @inbound
  end
  def check_out_of_bounds_right_up(right,up)
    @inbound=false
    for a in 0..$level_bounds.size-1
      rec= Rectangle.new(x:$level_bounds[a][0],y:$level_bounds[a][1],width:$level_bounds[a][2],height:$level_bounds[a][3],color:'#FF80BB',opacity:0)
      if rec.contains?(right,up)
        @inbound=true
      end
    end
    @inbound
  end
  def check_out_of_bounds_right_down(right,down)
    @inbound=false
    for a in 0..$level_bounds.size-1
      rec= Rectangle.new(x:$level_bounds[a][0],y:$level_bounds[a][1],width:$level_bounds[a][2],height:$level_bounds[a][3],color:'#FF80BB',opacity:0)
      if rec.contains?(right,down)
        @inbound=true
      end
    end
    @inbound
  end

  def change_direction(f)  # window frame as parameter
    move_down =  @y+@y_speed+SQUARE_SIZE
    move_up = @y-@y_speed
    move_left = @x-@x_speed
    move_right = @x+@x_speed + SQUARE_SIZE
    if @array_direction[f-1].size ==2 # check if two keys are pressed together
      arr=@array_direction[f-1] # access the array position where the two keys were pressed at the same frame
      if arr[0]=='left'&&arr[1]=='up' # set boundary for diagonal movements of square
        if check_out_of_bounds_left_up(move_left,move_up)
          @x-=@x_speed
          @y-=@y_speed
        else
          if check_out_of_bounds_left(move_left) # allows to move diagonally left-up so the square doesnt get stuck
            @x-=@x_speed
          end
          if check_out_of_bounds_up(move_up)
            @y-=@y_speed
          end
        end
      elsif arr[0]=='left'&&arr[1]=='down'
        if check_out_of_bounds_left_down(move_left,move_down)
          @y+=@y_speed
          @x-=@x_speed
        else
          if check_out_of_bounds_left(move_left)
            @x-=@x_speed
          end
          if check_out_of_bounds_down(move_down)
            @y+=@y_speed
          end
        end
      elsif arr[0]=='right'&&arr[1]=='up'
        if check_out_of_bounds_right_up(move_right,move_up)
          @y-=@y_speed
          @x+=@x_speed
        else
          if check_out_of_bounds_right(move_right)
            @x+=@x_speed
          end
          if check_out_of_bounds_up(move_up)
            @y-=@y_speed
          end
        end
      else
        if check_out_of_bounds_right_down(move_right,move_down)
          @y+=@y_speed
          @x+=@x_speed
        else
          if check_out_of_bounds_right(move_right)
            @x+=@x_speed
          end
          if check_out_of_bounds_down(move_down)
            @y+=@y_speed
          end
        end
      end
    else
      case @direction # else,set direction depending on the key pressed
      when 'down'
        if check_out_of_bounds_down(move_down)
          @y+=@y_speed # if the square is inside the boundary add this speed
        end
      when 'up'
        if check_out_of_bounds_up(move_up)
          @y-=@y_speed # if the square is inside the boundary add this speed
        end
      when 'left'
        if check_out_of_bounds_left(move_left)
          @x-=@x_speed # if the square is inside the boundary add this speed
        end
      when 'right'
        if check_out_of_bounds_right(move_right)
          @x+=@x_speed # if the square is inside the boundary add this speed
        end
      end
    end
  end

end

game = Game.new(3) # set speed of the square to 3
game.level=3
frame =0
update do
  clear # clear the screen each frame
  game.time+=1
  if game.time%120==0
    game.num_color+=1
  end
  game.array_direction.push([]) # push an empty array to this array to take note of the position
  game.change_direction(frame)
  frame+=1 # update the frame count
  if game.level==1
    game.level_1
  elsif game.level==2
    set background: '#EAF5FE'
    game.level_2
  elsif game.level==3
    set background: '#FFA07F'
    game.level_3
  elsif game.level==4
    set background: '#05BF7A'
    game.level_4
  elsif game.level==5
    set background: '#FBEDED'
    game.level_5

  end
  if game.level_complete?
    game.level+=1
    game.level_complete=false
  end
  if game.level==6
    Text.new("Congratulations! You made it! Press 'R' to play again",x:200,y:50,color:'red')
  end
end

on :key_down do |event|
  if game.level==6 and event.key=='r'
    game.level=1
  end
end

on :key_held do |event| # when a key is held down
  if ['up','down','left','right'].include?(event.key) # if these keys have been pressed
    game.direction =event.key # set the direction to the key that has been pressed
    k= frame
    game.array_direction[k-1].push(event.key)# array to hold in which keys were pressed at a specific frame
  end
end

on :key_up do |event|
  game.direction =nil # reset direction to null when key is released
end

on :mouse_down do |event|
  print event.x," ",event.y,"\n"
end

show
