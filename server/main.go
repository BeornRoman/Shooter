package main

import (
	"fmt"
	"net/http"
)

const (
	SERVER_HOST = "localhost"
	SERVER_PORT = "8080"
	SERVER_TYPE = "tcp"
)

func serveHome(w http.ResponseWriter, r *http.Request) {
	fmt.Println(r.URL)
}

func serveWebsocket(hub *Hub, w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		fmt.Println(err)
		return
	}
	client := &Client{hub: hub, conn: conn}
	fmt.Println("Client connected:", client.conn.RemoteAddr())
	client.hub.register <- client
}

func main() {
	address := SERVER_HOST + ":" + SERVER_PORT

	hub := newHub()
	go hub.run()

	serveWebsocket := func(w http.ResponseWriter, r *http.Request) {
		serveWebsocket(hub, w, r)
	}

	http.HandleFunc("/", serveHome)
	http.HandleFunc("/ws", serveWebsocket)

	fmt.Println("Listening on:", address)
	http.ListenAndServe(address, nil)
}
