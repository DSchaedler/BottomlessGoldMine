def tick args
  #Main Loop
  
  #Init
  unless args.state.init_complete
    init(args)
  end
  
  #Logic
  time(args)        #Track time played in Seconds and Minutes, with Announcements for minutes.
  calculations(args)
  game_logic(args)
  
  #UI
  define_ui(args)
  draw_ui(args)
  
end

def init args
  
  #Define state trackers
  
  #Gold
  args.state.total_gold_count = 0
  
  #Pickaxes
  args.state.pickaxe_durability = 20
  args.state.pickaxe_price = 5
  args.state.pickaxe_durability_total = 20
  
  #Pickaxe Upgrade
  args.state.pickaxe_level = 1
  args.state.pickaxe_upgrade_multiplier = 100
  
  #workers
  args.state.worker_number = 0
  args.state.worker_wages = 300
  args.state.worker_wear = 1
  args.state.worker_morale = 0.5
  
  #Manager
  args.state.manager_wage = 1000
  args.state.manager_owned = false
  args.state.manager_price_multiplier = 1
  
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

def calculations args
  args.state.upgrade_pickaxe_price = args.state.pickaxe_level * args.state.pickaxe_upgrade_multiplier
end

def game_logic args

  if args.state.pickaxe_durability_total > 0
    can_dig = true
  else
    can_dig = false
  end
  
  if args.state.second_tick
  
    #Manager buys pickaxes
    if args.state.manager_owned == true
      while args.state.pickaxe_durability_total < ((args.state.worker_number + 1) * args.state.pickaxe_durability)
        if args.state.total_gold_count >= (args.state.pickaxe_price * args.state.manager_price_multiplier)
          args.state.total_gold_count -= (args.state.pickaxe_price * args.state.manager_price_multiplier)
          args.state.pickaxe_durability_total += args.state.pickaxe_durability
        else
          break
        end
      end
    end

    #Auto Dig
    if args.state.worker_number > 0 && args.state.pickaxe_durability_total >= (args.state.worker_number * args.state.worker_wear)
      args.state.total_gold_count += args.state.worker_number
      args.state.pickaxe_durability_total -= args.state.worker_wear * args.state.worker_number
    end
    
  end
  
  #On Mouse Click
  if args.inputs.mouse.click
    #Store click location
    click_location = [args.inputs.mouse.x, args.inputs.mouse.y, 1, 1]
    
    #Add Gold if mined manually
    if (click_location.intersect_rect? args.state.game_button_box[:mine_gold]) && can_dig
      args.state.total_gold_count += args.state.pickaxe_level
      args.state.pickaxe_durability_total -= 1
    end
    
    #Buy more pickaxe_durability
    if (click_location.intersect_rect? args.state.game_button_box[:buy_pickaxe]) && (args.state.total_gold_count >= args.state.pickaxe_price)
      args.state.total_gold_count -= args.state.pickaxe_price
      args.state.pickaxe_durability_total += args.state.pickaxe_durability
    end
    
    # Buy Worker
    if (click_location.intersect_rect? args.state.game_button_box[:hire_worker]) && (args.state.total_gold_count >= args.state.worker_wages + args.state.pickaxe_price)
      args.state.total_gold_count -= args.state.worker_wages
      args.state.worker_number += 1
    end
    
    #Buy Manager
    if (args.state.game_button_box[:hire_manager]) && (click_location.intersect_rect? args.state.game_button_box[:hire_manager]) && (args.state.total_gold_count >= args.state.manager_wage + args.state.pickaxe_price) && (args.state.manager_owned == false)
      args.state.total_gold_count -= args.state.manager_wage
      args.state.manager_owned = true
    end
    
    #Update checkboxes if clicked
    args.state.game_checkbox_dictionary.each {|key, value| #Iterate through all checkboxes in container
      if (args.state.game_checkbox_visual[key]) && (click_location.intersect_rect? args.state.game_checkbox_visual[key]) #if the current checkbox was clicked
        args.state.game_checkbox_dictionary[key] = !args.state.game_checkbox_dictionary[key] #flip the boolean value
      end
    }
    
  end
  
end

def define_ui args

  #Label Container - used in functions called by this one - here so that it only gets called once per tick
  args.state.game_labels = []
  args.state.game_button_text = []
  args.state.game_button_box = Hash.new
  
  #Define initial vertical offset (10) - resets every tick
  args.state.offset = 10
  
  #Elements are spaced by 25
  #Checkboxes are 20 square
  #Checkboxes left margin is 10
  #Labels are left alligned to allow space for checkboxes (30)
  #Text in Buttons is Margined from the border by 10
  
  # ---LABELS---
  
  #total_gold_count label
  string = "Gold: #{args.state.total_gold_count}"
  new_label(args, string)
  
  #pickaxes label
  pickaxes = (args.state.pickaxe_durability_total / 20).ceil
  string = "Pickaxes: #{pickaxes} (#{args.state.pickaxe_durability_total} Durability)" 
  new_label(args, string)
  
  #pickaxe_level label
  string = "Pickaxe Level: #{args.state.pickaxe_level}"
  new_label(args, string)
  
  # Workers Label
  if args.state.worker_number > 0
    string = "Workers: #{args.state.worker_number}"
    new_label(args, string)
  end
  
  # ---BUTTONS---
  
  # Mine Gold button
  button_symbol = :mine_gold
  main_string  = "Mine Gold"
  alt_string = "+1 Gold, -1 Durability"
  new_button(args, button_symbol, main_string, alt_string)
  
  #Buy Pickaxe Button
  button_symbol = :buy_pickaxe
  main_string = "Buy Pickaxe"
  alt_string = "-#{args.state.pickaxe_price} Gold | +#{args.state.pickaxe_durability} Durability"
  new_button(args, button_symbol, main_string, alt_string)
  
  #Upgrade Pickaxe Button
  button_symbol = :upgrade_pickaxe
  main_string = "Upgrade Pickaxe"
  #alt_string = "
  
  #Hire Worker Button
  button_symbol = :hire_worker
  main_string = "Hire Worker"
  alt_string = "-#{args.state.worker_wages} Gold | +1 Gold, -#{args.state.worker_wear} Durability / Second"
  new_button(args, button_symbol, main_string, alt_string)
  
  #Hire Manager Button
  button_symbol = :hire_manager
  main_string = "Hire Manager"
  if args.state.manager_price_multiplier > 1
    alt_string "-#{args.state.manager_wage} Gold | Auto Buy Pickaxes at #{args.state.manager_price_multiplier}x cost"
  else
    alt_string = "-#{args.state.manager_wage} Gold | Auto Buy Pickaxes"
  end
  new_button(args, button_symbol, main_string, alt_string)
  
end

def new_label(args, label_string)
  #ARGS: args, string to display
  #Function Abstracts label creation because they're all alligned. 
  
  #Define margins and element sizes
  left_label_margin = 40
  line_spacing = 25
  
  #Add element to draw hash
  args.state.game_labels <<  [left_label_margin, args.grid.top - args.state.offset, label_string]
  args.state.offset += line_spacing
end

def new_button(args, button_symbol, main_string, alt_string)
  #ARGS: args, string to display
  #Function Abstracts button creation because they're all alligned.
  
  #Define margins and element sizes
  left_button_margin = 40
  button_text_margin = 10
  line_spacing = 25
  
  #Mouse Loctaion for Mouse Overs
  mouse_location = [args.inputs.mouse.x, args.inputs.mouse.y, 1, 1]
  
  main_string_text_size = args.gtk.calcstringbox(main_string)
  main_string_button_box = [left_button_margin, args.grid.top - args.state.offset - main_string_text_size[1] - ( button_text_margin * 2), main_string_text_size[0] + (button_text_margin * 2), main_string_text_size[1] + ( button_text_margin * 2)]
  
  alt_string_text_size = args.gtk.calcstringbox(alt_string)
  alt_string_button_box = [left_button_margin, args.grid.top - args.state.offset - alt_string_text_size[1] - ( button_text_margin * 2), alt_string_text_size[0] + (button_text_margin * 2), alt_string_text_size[1] + ( button_text_margin * 2)]
  
  if mouse_location.intersect_rect? main_string_button_box
    args.state.game_button_box[button_symbol] = alt_string_button_box
    alt_string_label = [left_button_margin + button_text_margin, args.grid.top - args.state.offset - button_text_margin, alt_string]
    args.state.game_labels << alt_string_label
  else
    args.state.game_button_box[button_symbol] = main_string_button_box
    main_string_label = [left_button_margin + button_text_margin, args.grid.top - args.state.offset - button_text_margin, main_string]
    args.state.game_labels << main_string_label
  end
    
  args.state.offset += line_spacing + main_string_text_size[1]
  
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

def reset
  $gtk.reset()
end

def debug args
  
  # framerate label
  framerate = args.gtk.current_framerate.round
  args.state.game_labels << [args.grid.right - 20, args.grid.top, "#{framerate}"]
end