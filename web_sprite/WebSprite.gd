tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("WebSprite", "Sprite", preload("WSprite.gd"), preload("icon.png"))


func _exit_tree():
	remove_custom_type("WebSprite")
