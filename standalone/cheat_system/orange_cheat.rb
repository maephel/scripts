#------------------------------------------------------------
#------------------------------------------------------------
#-------------------  ORANGE CHEAT SYSTEM  ------------------
#------------------------------------------------------------
#------------------------------------------------------------
#
# Script created by Hudell (www.hudell.com)
# You're free to use this script on any project
#
# Requires Orange Input
#
module OrangeCheats
  # Main_Key = :tab
  Main_Key = nil
  # If this is true, the script will wait for the player to release the main key before running a cheat
  Wait_For_Main_Key_Release = true
  
  # 'cheat_code' => switch_id
  Cheat_Switch_List = {
  }
  # 'cheat_code' => common_event_id
  Cheat_Event_List = {
  }

  def self.get_key_description(key)
    sym = OrangeInput.key_symbol(OrangeInput.last_triggered_key)
    if sym.nil?
      ''
    else
      sym.to_s
    end
  end

  def self.check_typed_cheat
    Cheat_Switch_List.keys.each do |key|
      if @last_cheat.end_with?(key)
        @last_cheat = ""

        $game_switches[Cheat_Switch_List[key]] = true
        return
      end
    end

    if SceneManager.scene.is_a? Scene_Map
      Cheat_Event_List.keys.each do |key|
        if @last_cheat.end_with?(key)
          @last_cheat = ""
          $game_temp.reserve_common_event(Cheat_Event_List[key])
          return
        end
      end
    end
  end

  def self.check_input
    @last_cheat = "" if @last_cheat.nil?

    if Wait_For_Main_Key_Release && !Main_Key.nil?
      if OrangeInput.release?(Main_Key)
        check_typed_cheat
        @last_cheat = ""
      end
    end

    if Main_Key.nil? || OrangeInput.press?(Main_Key)
      if OrangeInput.triggered_any?
        @last_cheat += get_key_description(OrangeInput.last_triggered_key)
        check_typed_cheat unless !Main_Key.nil? && Wait_For_Main_Key_Release
      end
    else
      @last_cheat = ""
    end
  rescue NameError
    raise "Orange Cheats Error - Did you include Orange Input?"
  end
end

class Scene_Base
  alias :hudell_orange_cheats_update :update
  def update
    hudell_orange_cheats_update

    OrangeCheats.check_input
  end
end

unless OrangeCheats::Main_Key.nil?
  module Input
    class << self
      alias :hudell_press? :press?
      alias :hudell_trigger? :trigger?
    end

    def self.press?(key)
      if OrangeInput.press?(OrangeCheats::Main_Key)
        false
      else
        hudell_press?(key)
      end
    end

    def self.trigger?(key)
      if OrangeInput.press?(OrangeCheats::Main_Key)
        false
      else
        hudell_trigger?(key)
      end
    end
  end
end
