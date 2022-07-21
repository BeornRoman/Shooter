package main

import (
	"fmt"
	"strconv"
	"strings"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

type Position struct {
	x float64
	y float64
}

type Grid struct {
	x      float64
	y      float64
	width  float64
	height float64
}

// Client is a middleman between the websocket connection and the hub.
type Client struct {
	isNotified bool
	session    *Session
	hub        *Hub
	conn       *websocket.Conn
	name       string
	position   Position
	grid       Grid
}

func (client *Client) readPump() {
	defer func() {
		enemyClient := client.getEnemyClient()
		if enemyClient != nil {
			enemyClient.isNotified = false
			enemyClient.notifyEnemyDisconnected()
		}
		client.hub.unregister <- client
		fmt.Println("Debug: Client Unregistered")
		client.conn.Close()
		fmt.Println("Debug: Connection closed")
	}()
	client.conn.SetReadLimit(1024)
	for {
		_, m, err := client.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				fmt.Printf("error: %v", err)
			}
			break
		}

		parts := strings.Split(string(m), ":")
		key := parts[0]
		components := strings.Split(parts[1], ",")

		fmt.Println("Recieved:", key, components)

		enemyClient := client.getEnemyClient()

		if key == "data" {
			client.store(components)
			client.notifyPosition()
		}

		if enemyClient == nil {
			fmt.Println("Debug: No Enemy Yet")
			continue
		}

		if !client.isNotified {
			client.isNotified = true
			client.notifyEnemyConnected()
		}
		if !enemyClient.isNotified {
			enemyClient.isNotified = true
			enemyClient.notifyEnemyConnected()
		}

		if key == "move" {
			side := components[0]

			dx := client.grid.width / 1000
			if side == "right" {
				newX := client.position.x + dx
				if newX+20 <= client.grid.width {
					client.position.x = newX
				}
			}
			if side == "left" {
				newX := client.position.x - dx
				if newX-20 >= 0 {
					client.position.x = newX
				}
			}

			client.notifyPosition()
			enemyClient.notifyEnemyPosition()
		}
	}
}

func (c *Client) write(message []byte) {
	w, err := c.conn.NextWriter(websocket.TextMessage)
	if err != nil {
		return
	}
	w.Write(message)
	if err := w.Close(); err != nil {
		return
	}
}

func (c *Client) getEnemyClient() *Client {
	if c.session.playerA == c {
		return c.session.playerB
	} else if c.session.playerB == c {
		return c.session.playerA
	}
	return nil
}

func (client *Client) store(components []string) {
	client.name = components[0]
	x := getFloat(components[1])
	y := getFloat(components[2])
	width := getFloat(components[3])
	height := getFloat(components[4])
	client.grid = Grid{x, y, width, height}
	client.position.x = width / 2
	client.position.y = 3 * height / 4
}

func (client *Client) notifyEnemyConnected() {
	enemyClient := client.getEnemyClient()
	enemyDx := enemyClient.grid.width / 1000
	dx := client.grid.width / 1000
	response := makeResponse("enemyConnected", []string{
		enemyClient.name,
		getString((enemyClient.grid.width - enemyClient.position.x) * dx / enemyDx),
		getString(client.grid.height * 0.2),
	})
	client.write([]byte(response))
}

func (client *Client) notifyEnemyDisconnected() {
	response := makeResponse("enemyDisconnected", []string{})
	client.write([]byte(response))
}

func (client *Client) notifyEnemyPosition() {
	enemyClient := client.getEnemyClient()
	enemyDx := enemyClient.grid.width / 1000
	dx := client.grid.width / 1000
	response := makeResponse("enemyPosition", []string{
		enemyClient.name,
		getString((enemyClient.grid.width - enemyClient.position.x) * dx / enemyDx),
		getString(client.grid.height * 0.2),
	})
	client.write(response)
}

func (client *Client) notifyPosition() {
	response := makeResponse("myPosition", []string{
		client.name,
		getString(client.position.x),
		getString(client.position.y),
	})
	client.write(response)
}

func makeResponse(key string, components []string) []byte {
	values := strings.Join(components, ",")
	parts := []string{key, values}
	response := strings.Join(parts, ":")
	return []byte(response)
}

func getFloat(s string) float64 {
	result, _ := strconv.ParseFloat(s, 64)
	return result
}

func getString(f float64) string {
	result := fmt.Sprintf("%f", f)
	return result
}
