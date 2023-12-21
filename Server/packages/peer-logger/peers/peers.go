package peers

import (
	"github.com/charmbracelet/bubbles/stopwatch"
)

type Peer struct {
	URL         string
	Connections int
	Time        string
	Elapsed     int
	Maximum     int
}

func (p *Peer) CreatePeer(url, time string, connections, maximum int) {
	p.URL = url
	p.Connections = connections
	p.Time = time
	p.Maximum = maximum

	timer := stopwatch.New()
	timer.Start()
	p.Elapsed = int(timer.Elapsed().Hours())
}

func (p *Peer) AddConnection() {
	p.Connections++
}

func (p *Peer) RemoveConnection() {
	p.Connections--
}
