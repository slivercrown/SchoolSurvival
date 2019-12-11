extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 8

var players = { }
var self_data = { name = '', position = Vector2(randi()%360, randi()%360 )}

var world = load('res://World.tscn').instance()

signal player_disconnected
signal server_disconnected

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')

func create_server(player_nickname):
	self_data.name = player_nickname
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)

func connect_to_server(player_nickname):
	self_data.name = player_nickname
	#get_tree().connect('connected_to_server', self, '_connected_to_server')
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	get_tree().connect('connected_to_server', self, '_connected_to_server')

func _connected_to_server():
	var local_player_id = get_tree().get_network_unique_id()
	players[local_player_id] = self_data
	rpc('_send_player_info', local_player_id, self_data) #server에 접속하자 마자 캐릭터 생성 -> 때문에 서버만 생성되었을때 아무화면도 없다. 나 자신의 캐릭터와 world를 나 의외에 서버와 클라들에게 전송.
	print("_connected_to_server")

func _on_player_disconnected(id):
	print("plyaer conneted :",get_tree().get_network_connected_peers())
	print("plyaer conneted, is true? :",get_tree().has_network_peer())
	print(id)
	print("number of player:",get_tree().get_network_connected_peers().size())
	
	get_tree().get_root().get_node("/root/World").get_node(str(id)).queue_free()
	#rset_unreliable("np", get_tree().get_network_connected_peers().size()-1)
	
	
	if get_tree().get_network_connected_peers().size() == 1:
		rpc_id(get_tree().get_network_connected_peers()[0], "win")
		print("you win!")
	else:
		print("playing")
		
	players.erase(id)

func _on_player_connected(connected_player_id): #server든, client든 peer가 접속되면 발생.
	print("plyaer conneted :",get_tree().get_network_connected_peers())
	print("plyaer conneted type :",get_tree().get_network_connected_peers()[0])
	print("plyaer conneted, is true? :",get_tree().has_network_peer())
	print("number of player:",get_tree().get_network_connected_peers().size())
	
	#rset_unreliable("np", get_tree().get_network_connected_peers().size())
	#get_tree().get_root().get_node("/root/World").
	var local_player_id = get_tree().get_network_unique_id()
	if not(get_tree().is_network_server()): #if client
		rpc_id(1, '_request_player_info', local_player_id, connected_player_id) #서버에서 requestplayerinfo 호출. -> 보낸 정보는 server의 send player info로 인해 캐릭터로 생성된다.
		#problem
		print("player not made in server")
	else: #may be server
		print("pass")
		#rpc('_send_player_info', local_player_id, self_data)
	#server라면 아무것도 하지 않는다.

remote func _request_player_info(request_from_id, player_id):
	if get_tree().is_network_server(): #server라면
		#rpc("_test")
		#rpc_id(request_from_id, "_test")
		rpc_id(request_from_id, '_send_player_info', player_id, players[player_id]) #각 플레이어의 캐릭터들을 받을 때 마다 생성.
		#print("_request_player_info")

# A function to be used if needed. The purpose is to request all players in the current session.
remote func _request_players(request_from_id): #broadcast
	if get_tree().is_network_server():
		for peer_id in players:
			if( peer_id != request_from_id):
				rpc_id(request_from_id, '_send_player_info', peer_id, players[peer_id])  #current session
				#print("_request_players")

remote func _send_player_info(id, info):
	players[id] = info
	if get_tree().get_root().find_node("World", true, false):
		pass
	else:
		get_node("/root").add_child(world)
	var new_player = load('res://Player2.tscn').instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	get_tree().get_root().get_node("/root/World").add_child(new_player)
	print(get_tree().get_root().get_children())
	print("_send_player_info")
	#new_player.init(info.position)

func update_position(id, position):
	players[id].position = position