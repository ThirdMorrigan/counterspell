extends Node3D

const PORT = 6969
const Player = preload("res://!proto/proto_character.tscn")
var enet_peer = ENetMultiplayerPeer.new()

@onready var main_menu = $CanvasLayer/proto_main_menu
@onready var join_address = $CanvasLayer/proto_main_menu/MarginContainer/VBoxContainer/join_address



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_join_button_pressed():
	main_menu.hide()
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	print("player joins")

func _on_host_button_pressed():
	main_menu.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	add_player(multiplayer.get_unique_id())
	print("player hosts")
	
func add_player(peer_id):
	print("creating player type:", name, "id: ", peer_id)
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
