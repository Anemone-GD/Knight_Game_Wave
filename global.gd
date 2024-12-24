extends Node

var gameStarted: bool

var playerBody: CharacterBody2D
var playerWeaponEquipped: bool

var playerAlive: bool
var playerDamageZone: Area2D
var playerDamageAmount: int

var eyeDamageZone: Area2D
var eyeDamageAmount: int

var mushDamageZone: Area2D
var mushDamageAmount: int

var current_wave: int
var moving_to_next_wave: bool 
