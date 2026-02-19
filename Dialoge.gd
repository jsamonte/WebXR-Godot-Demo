extends Node3D  # ← Change root to Node3D (the panel holder)

const Dialogue_File = preload("res://testDialogue.dialogue")

@onready var sub_viewport: SubViewport = $"../Text Bubble/Sprite3D/SubViewportContainer/SubViewport"
@onready var dialogue_label: RichTextLabel = $"../Text Bubble/Sprite3D/SubViewportContainer/SubViewport/DialogueUI/DialogueLabel"
@onready var choices_container: Container = $"../Text Bubble/Sprite3D/SubViewportContainer/SubViewport/DialogueUI/ChoicesContainer"

var current_dialogue_line: DialogueLine

func _ready() -> void:
	start_dialogue("start")

func start_dialogue(dialogue_func: String) -> void:
	current_dialogue_line = await DialogueManager.get_next_dialogue_line(Dialogue_File, dialogue_func)
	show_dialogue()

func show_dialogue() -> void:
	if current_dialogue_line == null:
		dialogue_label.text = "[center]Conversation ended[/center]"
		clear_choices()
		return

	dialogue_label.text = "[center]" + current_dialogue_line.text + "[/center]"

	clear_choices()

	if current_dialogue_line.responses.size() > 0:
		for response in current_dialogue_line.responses:
			var button := Button.new()
			button.text = response.text
			button.add_theme_font_size_override("font_size", 24)
			button.custom_minimum_size = Vector2(0, 60)  # better spacing/touch area
			button.pressed.connect(func(): _on_choice_pressed(response))
			choices_container.add_child(button)
	else:
		var next_button := Button.new()
		next_button.text = "Next →"
		next_button.add_theme_font_size_override("font_size", 24)
		next_button.custom_minimum_size = Vector2(0, 60)
		next_button.pressed.connect(_on_next_pressed)
		choices_container.add_child(next_button)

func clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

func _on_choice_pressed(response) -> void:
	current_dialogue_line = await DialogueManager.get_next_dialogue_line(Dialogue_File, response.next_id)
	show_dialogue()

func _on_next_pressed() -> void:
	current_dialogue_line = await DialogueManager.get_next_dialogue_line(Dialogue_File, current_dialogue_line.next_id)
	show_dialogue()
