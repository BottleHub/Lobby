package logger

import "Server/packages/peer-logger/peers"

type Logger struct {
	Peers []peers.Peer
}

func (l *Logger) AddPeer(peer peers.Peer) {
	peers := l.Peers
	peers = append(peers, peer)

	l.Peers = peers
}

func (l *Logger) RemovePeer(peer peers.Peer) {
	peers := l.Peers
	for i, p := range peers {
		if p == peer {
			peers = append(peers[:i], peers[i+1:]...)
		}
	}

	l.Peers = peers
}

func (l *Logger) GetPeers() []peers.Peer {
	return l.Peers
}
