extends Node


onready var ip_field = $CanvasLayer/ConnectionPanel/GridContainer/IPLineEdit
onready var port_field = $CanvasLayer/ConnectionPanel/GridContainer/PortLineEdit
#onready var server_button = $CanvasLayer/ConnectionPanel/GridContainer/ServerButton
#onready var client_button = $CanvasLayer/ConnectionPanel/GridContainer/ClientButton
onready var message_label = $CanvasLayer/MessageLabel
onready var connection_panel = $CanvasLayer/ConnectionPanel
onready var sync_lost_label = $CanvasLayer/LostSyncLabel

export(bool) var generate_logs

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	
	SyncManager.connect("sync_started", self, "_on_SyncManager_sync_started")
	SyncManager.connect("sync_stopped", self, "_on_SyncManager_sync_stopped")
	SyncManager.connect("sync_lost", self, "_on_SyncManager_sync_lost")
	SyncManager.connect("sync_regained", self, "_on_SyncManager_sync_regained")
	SyncManager.connect("sync_error", self, "_on_SyncManager_sync_error")

func _on_ServerButton_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(int(port_field.text))
	get_tree().network_peer = peer
	connection_panel.visible = false
	message_label.text = "Listening..."

func _on_ClientButton_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip_field.text, int(port_field.text))
	get_tree().network_peer = peer
	connection_panel.visible = false
	message_label.text = "Connecting to host..."

	
func _on_ResetButton_pressed():
	SyncManager.stop()
	SyncManager.clear_peers()
	var peer: NetworkedMultiplayerENet = get_tree().network_peer
	if peer:
		peer.close_connection()
	get_tree().reload_current_scene()
	
#Tree connection signals
func _on_network_peer_connected(peer_id: int ):
	message_label.text = "Connected!"
	SyncManager.add_peer(peer_id)
	
	$Spatial/ServerPlayer.set_network_master(1)
	if(get_tree().is_network_server()):
		$Spatial/ClientPlayer.set_network_master(peer_id)
	else:
		$Spatial/ClientPlayer.set_network_master(get_tree().get_network_unique_id())
	
	if(get_tree().is_network_server()):
		message_label.text = "Starting..."
		yield(get_tree().create_timer(2.0), "timeout")
		SyncManager.start()


func _on_network_peer_disconnected(peer_id: int):
	message_label.text = "Disconnected"
	SyncManager.remove_peer(peer_id)
	
func _on_server_disconnected():
	_on_network_peer_disconnected(1)
	
#SyncManager signals
func _on_SyncManager_sync_started():
	message_label.text = "Started!"
	var time = OS.get_datetime()
	var file_directory = "./logs/log_peer_"
	file_directory += "server_" if get_tree().is_network_server() else "client_"
	file_directory += String(time["year"]) + String(time["month"]) + String(time["day"]) + "_" + String(time["hour"]) + "-" + String(time["minute"]) + "-" + String(time["second"])
	file_directory += ".log"
	if generate_logs:
		SyncManager.start_logging(file_directory)

func _on_SyncManager_sync_stopped():
	SyncManager.stop_logging()
	print("Sync stopped")


func _on_SyncManager_sync_lost():
	sync_lost_label.visible = true


func _on_SyncManager_sync_regained():
	sync_lost_label.visible = false


func _on_SyncManager_sync_error(msg):
	message_label.text = "Fatal error sync: " + msg
	sync_lost_label.visible = false
	
	var peer: NetworkedMultiplayerENet = get_tree().network_peer
	if peer:
		peer.close_connection()
		
	SyncManager.clear_peers()
	

