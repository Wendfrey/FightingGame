extends Node

const DummyAdaptor = preload("res://addons/godot-rollback-netcode/DummyNetworkAdaptor.gd")

onready var ip_field = $CanvasLayer/ConnectionPanel/GridContainer/IPLineEdit
onready var port_field = $CanvasLayer/ConnectionPanel/GridContainer/PortLineEdit
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
	_set_default_network_adaptor()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(int(port_field.text))
	get_tree().network_peer = peer
	connection_panel.visible = false
	message_label.text = "Listening..."

func _on_ClientButton_pressed():
	_set_default_network_adaptor()
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
	
	$World/ServerPlayer.set_network_master(1)
	if(SyncManager.network_adaptor.is_network_host()):
		$World/ClientPlayer.set_network_master(peer_id)
	else:
		$World/ClientPlayer.set_network_master(SyncManager.network_adaptor.get_network_unique_id())
	
	if(SyncManager.network_adaptor.is_network_host()):
		message_label.text = "Starting..."
		$StartTimer.start()


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
	file_directory += "%0000d%00d%00d-%00d_%00d_%00d" % [
		time["year"],
		time["month"],
		time["day"],
		time["hour"],
		time["minute"],
		time["second"]	]
	file_directory += "_server" if SyncManager.network_adaptor.is_network_host() else "_client"
	
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


func _on_StartTimer_timeout():
	SyncManager.start()


func _on_LocalButton_pressed():
	connection_panel.visible = false
	SyncManager.set_network_adaptor(DummyAdaptor.new())
	SyncManager.start()

func _set_default_network_adaptor():
	SyncManager.set_network_adaptor(SyncManager._create_class_from_project_settings('network/rollback/classes/network_adaptor', SyncManager.DEFAULT_NETWORK_ADAPTOR_PATH))
