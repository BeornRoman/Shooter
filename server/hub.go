package main

import (
	"fmt"
)

// Hub maintains the set of active clients and broadcasts messages to the
// clients.

type Session struct {
	playerA *Client

	playerB *Client
}
type Hub struct {
	register chan *Client

	unregister chan *Client

	sessions []*Session
}

func newHub() *Hub {
	return &Hub{
		register:   make(chan *Client),
		unregister: make(chan *Client),
		sessions:   make([]*Session, 0),
	}
}

func (h *Hub) run() {
	for {
		select {
		case client := <-h.register:

			// Поиск существующей сессии для игры
			emptySession := h.findEmptySession()

			// Если сессии нет, создаем комнату и выходим
			if emptySession == nil {
				client.session = &Session{
					playerA: client,
				}
				h.sessions = append(h.sessions, client.session)

				go client.readPump()
				break
			}

			// Если сессия есть, конектим в ней игроков и рассылаем уведомления по готовности
			if emptySession.playerA == nil {
				emptySession.playerA = client
				client.session = emptySession
			} else if emptySession.playerB == nil {
				emptySession.playerB = client
				client.session = emptySession
			}

			go client.readPump()

		case client := <-h.unregister:

			client.session = nil
			clientSession := h.findSessionOfClient(client)
			if clientSession.playerA == client {
				clientSession.playerA = nil
			}
			if clientSession.playerB == client {
				clientSession.playerB = nil
			}
			if clientSession.playerA == nil && clientSession.playerB == nil {
				if len(h.sessions) > 0 {
					h.sessions = h.sessions[:len(h.sessions)-1]
				}
			}
		}
		for _, session := range h.sessions {
			fmt.Printf("Sessions: %+v %+v\n", session.playerA, session.playerB)
		}
	}
}

func (h *Hub) findEmptySession() *Session {
	for _, session := range h.sessions {
		if session.playerA == nil && session.playerB != nil {
			return session
		}
		if session.playerB == nil && session.playerA != nil {
			return session
		}
	}
	return nil
}

func (h *Hub) findSessionOfClient(c *Client) *Session {
	for _, session := range h.sessions {
		if session.playerA == c || session.playerB == c {
			return session
		}
	}
	return nil
}
