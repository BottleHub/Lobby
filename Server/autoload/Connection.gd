extends Node

func new_connection(port: int):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	return peer

func kill_connection(peer: MultiplayerPeer):
	peer.close()
