def tick args
  
  #Run Init
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
  
  #Every Second
  if args.state.second_tick
    if args.state.game_checkbox_dictionary[:auto_digs]
      args.state.total_gold_count += 1
    end
  end
  
  #On Mouse Click
  if args.inputs.mouse.click
    #Store click location
    click_location = [args.inputs.mouse.x, args.inputs.mouse.y, 1, 1]
    
    #Add Gold if mined manually
    if click_location.intersect_rect? args.state.game_button_box[:mine_gold_button]
      args.state.total_gold_count += 1
    end
    
    #Update checkboxes if clicked
    args.state.game_checkbox_dictionary.each {|key, value| #Iterate through all checkboxes in container
      if click_location.intersect_rect? args.state.game_checkbox_visual[key] #if the current checkbox was clicked
        args.state.game_checkbox_dictionary[key] = !args.state.game_checkbox_dictionary[key] #flip the boolean value
      end
    }
  end
  
end

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
  
  #Define state trackers
  args.state.total_gold_count = 0
  
  #Define Time trackers
  args.state.second_clock = 0
  args.state.minute_clock = 0
  
  args.state.second_tick = false
  args.state.minute_tick = false
  
  checkbox_init(args)
  
  #Mark Init Complete
  args.state.init_complete = true
end

def checkbox_init args
  
  args.state.game_checkbox_dictionary = {:auto_digs => false} #auto Digs
end

def define_ui args
  
  #Define margins and element sizes
  
  checkbox_size = 20
  left_checkbox_margin = 10
  
  left_label_margin = left_checkbox_margin + checkbox_size + 10
  
  button_text_margin = 10
  
  top_margin = 10
  line_spacing = 25
  
  
  #Label Container
  args.state.game_labels = []
  
  #total_gold_count label
  args.state.total_gold_count_label = [left_label_margin, args.grid.top - top_margin, "Total Gold Reserves: #{args.state.total_gold_count}"]
  args.state.game_labels << args.state.total_gold_count_label
  
  top_margin += line_spacing
  
  
  #auto_digs checkbox and label
  args.state.game_checkbox_visual = {:auto_digs => [left_checkbox_margin, args.grid.top - top_margin - checkbox_size, checkbox_size, checkbox_size, 0, 0, 0]}
  args.state.game_labels << [left_label_margin, args.grid.top - top_margin, "Auto Dig?: #{args.state.game_checkbox_dictionary[:auto_digs]}"]
  
  top_margin += line_spacing
  
  # Mine Gold button
  args.state.game_button_text = {:mine_gold_button => "Mine Gold"}
  mine_gold_text_size = args.gtk.calcstringbox(args.state.game_button_text[:mine_gold_button])
  args.state.game_button_box = {:mine_gold_button => [left_label_margin, args.grid.top - top_margin - mine_gold_text_size[1] - ( button_text_margin * 2), mine_gold_text_size[0] + (button_text_margin*2), mine_gold_text_size[1] + ( button_text_margin * 2)]}
  args.state.game_labels << [left_label_margin + button_text_margin, args.grid.top - top_margin - button_text_margin, args.state.game_button_text[:mine_gold_button]]
  
end

def draw_ui args
  #Draw Game Labels
  args.state.game_labels.each {|label|
    args.outputs.labels << label
  }
  
  #Draw Game Buttons
  args.state.game_button_box.each {|key, box|
    args.outputs.borders << box
  }
  
  #Determine Checkbox State, draw as appropriate
  args.state.game_checkbox_dictionary.each {|key, value| #check all values in the check values container
    if value #if checked
      args.outputs.solids << args.state.game_checkbox_visual[key] #filled
    else
      args.outputs.borders << args.state.game_checkbox_visual[key] #empty
    end
  }
end