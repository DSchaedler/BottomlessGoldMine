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

  if args.state.pickaxe_durability > 0
    can_dig = true
  else
    can_dig = false
  end
  
  #Every Second
  if args.state.second_tick
  
    #Auto Dig
    if args.state.game_checkbox_dictionary[:auto_dig] && can_dig
      args.state.total_gold_count += args.state.auto_dig_income
      args.state.pickaxe_durability -= args.state.auto_dig_wear
    end
  end
  
  #On Mouse Click
  if args.inputs.mouse.click
    #Store click location
    click_location = [args.inputs.mouse.x, args.inputs.mouse.y, 1, 1]
    
    #Add Gold if mined manually
    if (click_location.intersect_rect? args.state.game_button_box[:mine_gold]) && can_dig
      args.state.total_gold_count += 1
      args.state.pickaxe_durability -= 1
    end
    
    #Buy more pickaxe_durability
    if ((click_location.intersect_rect? args.state.game_button_box[:buy_pickaxe]) && (args.state.total_gold_count >= args.state.pickaxe_price))
      args.state.total_gold_count -= args.state.pickaxe_price
      args.state.pickaxe_durability += args.state.pickaxe_durability
    end
    
    #Update checkboxes if clicked
    args.state.game_checkbox_dictionary.each {|key, value| #Iterate through all checkboxes in container
      if click_location.intersect_rect? args.state.game_checkbox_visual[key] #if the current checkbox was clicked
        args.state.game_checkbox_dictionary[key] = !args.state.game_checkbox_dictionary[key] #flip the boolean value
      end
    }
  end
  
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
  args.state.game_button_text = Hash.new
  args.state.game_button_box = Hash.new
  
  #total_gold_count label
  args.state.game_labels <<  [left_label_margin, args.grid.top - top_margin, "Gold: #{args.state.total_gold_count}"]
  top_margin += line_spacing
  
  # pickaxes label
  pickaxes = (args.state.pickaxe_durability / 20).ceil
  args.state.game_labels << [left_label_margin, args.grid.top - top_margin, "Pickaxes: #{pickaxes} (#{args.state.pickaxe_durability} durability)"]
  
  top_margin += line_spacing
  top_margin += line_spacing
  
  #auto_dig checkbox and label
  args.state.game_checkbox_visual = {:auto_dig => [left_checkbox_margin, args.grid.top - top_margin - checkbox_size, checkbox_size, checkbox_size, 0, 0, 0]}
  args.state.game_labels << [left_label_margin, args.grid.top - top_margin, "Auto Dig?: - #{args.state.auto_dig_wear} durability"]
  
  top_margin += line_spacing
  
  # Mine Gold button
  args.state.game_button_text[:mine_gold] = "Mine Gold: +1 Gold"
  mine_gold_text_size = args.gtk.calcstringbox(args.state.game_button_text[:mine_gold])
  args.state.game_button_box[:mine_gold] = [left_label_margin, args.grid.top - top_margin - mine_gold_text_size[1] - ( button_text_margin * 2), mine_gold_text_size[0] + (button_text_margin*2), mine_gold_text_size[1] + ( button_text_margin * 2)]
  args.state.game_labels << [left_label_margin + button_text_margin, args.grid.top - top_margin - button_text_margin, args.state.game_button_text[:mine_gold]]
  
  top_margin += line_spacing + mine_gold_text_size[1]
  
  # Buy Pickaxe button
  args.state.game_button_text[:buy_pickaxe] = "Buy Pickaxe: -5 Gold"
  buy_pickaxe_text_size = args.gtk.calcstringbox(args.state.game_button_text[:buy_pickaxe])
  args.state.game_button_box[:buy_pickaxe] = [left_label_margin, args.grid.top - top_margin - buy_pickaxe_text_size[1] - ( button_text_margin * 2), buy_pickaxe_text_size[0] + (button_text_margin*2), buy_pickaxe_text_size[1] + ( button_text_margin * 2)]
  args.state.game_labels << [left_label_margin + button_text_margin, args.grid.top - top_margin - button_text_margin, args.state.game_button_text[:buy_pickaxe]]
  
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

def init args
  
  #Define state trackers
  
  #Gold
  args.state.total_gold_count = 0
  
  #Pickaxes
  args.state.pickaxe_durability = 20
  args.state.pickaxe_price = 5
  args.state.pickaxe_durability = 20
  
  #Atuo Dig
  args.state.auto_dig_income = 1
  args.state.auto_dig_wear = 2
  
  #Time
  args.state.second_clock = 0
  args.state.minute_clock = 0
  
  args.state.second_tick = false
  args.state.minute_tick = false
  
  checkbox_init(args)
  
  #Mark Init Complete
  args.state.init_complete = true
end

def checkbox_init args
  #Default Checkbox values
  args.state.game_checkbox_dictionary = {:auto_dig => false} #auto Digs
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

def reset
  $gtk.reset()
end