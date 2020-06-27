def tick args
  
  #Run Init
  args.state.init_complete ||= false
  unless args.state.init_complete
    init(args)
  end
    
  #Run Game Logic
  time(args)
  game_logic(args)
  
  #Update UI 
  define_ui(args)
  
  #Draw all UI Elements
  #Last command run in main loop
  draw_ui(args)
  
end

def game_logic args
  
  #runs every second
  if args.state.second_tick
    if args.state.player_digs_value
      args.state.total_gold_count += 1
    end
  end
  
  #Handle Mouse Clicks - fires on Mouse Up
  if args.inputs.mouse.up
    click_location = [args.inputs.mouse.click.x, args.inputs.mouse.click.y, 1, 1]
    puts click_location
    
    if click_location.intersect_rect? args.state.player_digs_checkbox
      args.state.player_digs_value = !args.state.player_digs_value
    end
  end
end

=begin
iter = 0
    puts args.state.game_checkbox_visual[iter]
    for i in args.state.game_checkbox_values
      if click_location.intersect_rect? args.state.game_checkbox_visual[iter]
        i = !i
        iter +=1
      end
    end
=end

def time args
  #reset clock booleans to 0
  args.state.second_tick = false
  args.state.minute_tick = false
  
  #Once 1 Second (60 frames) has passed, increment the second_clock, put out a second_tick, and reset the frame_clock
  if args.state.tick_count % 60 == 0
    args.state.second_clock += 1
    args.state.second_tick = true
  end
  
  if args.state.second_clock >= 60
    args.state.minute_clock += 1
    args.state.minute_tick = true
    args.state.second_clock = 0
  end
  
end

def init args
  #Checkbox Values Container
  args.state.game_checkbox_values ||= []
  
  #Define state trackers
  args.state.total_gold_count ||= 0
  args.state.player_digs_value ||= true
  
  #Define Time trackers
  args.state.second_clock ||= 0
  args.state.minute_clock ||= 0
  
  args.state.second_tick ||= false
  args.state.minute_tick ||= false
  
  args.state.init_complete = true
end

def define_ui args
  
  #Define margins and element sizes
  
  checkbox_size = 20
  
  left_checkbox_margin = 10
  left_label_margin = left_checkbox_margin + checkbox_size + 10
  top_margin = 10
  line_spacing = 25
  
  
  #Create UI Elements
  
  #Label Container
  args.state.game_labels = []
  
  #Checkbox Visuals Container
  args.state.game_checkbox_visual = []
  
  #total_gold_count label
  args.state.total_gold_count_label = [left_label_margin, args.grid.top - top_margin, "Total Gold Reserves: #{args.state.total_gold_count}"]
  args.state.game_labels << args.state.total_gold_count_label
  
  #Increment top margin to allow for spacing
  top_margin += line_spacing
  
  #player_digs checkbox
  args.state.player_digs_checkbox = [left_checkbox_margin, args.grid.top - top_margin - checkbox_size, checkbox_size, checkbox_size, 0, 0, 0]
  args.state.game_checkbox_values << args.state.player_digs_value
  args.state.game_checkbox_visual << args.state.player_digs_checkbox
  
  #player_digs label
  args.state.player_digs_label = [left_label_margin, args.grid.top - top_margin, "Player Digs?: #{args.state.player_digs_value}"]
  args.state.game_labels << args.state.player_digs_label
  
  #Increment top margin to allow for spacing
  top_margin += line_spacing
end

def draw_ui args
  #Draw Game Labels
  for i in args.state.game_labels
    args.outputs.labels << i
  end
  
  #Determine Checkbox State, draw as appropriate
  iter = 0
  for i in args.state.game_checkbox_values
    if i #if checked
      args.outputs.solids << args.state.game_checkbox_visual[iter]
      iter += 1
    else
      args.outputs.borders << args.state.game_checkbox_visual[iter]
      iter += 1
    end
  end
end