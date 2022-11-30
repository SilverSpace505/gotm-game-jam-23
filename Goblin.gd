extends KinematicBody2D

export (float) var speed = 0.5
var vel = Vector2.ZERO
var idleTarget = position
var timer = 0
var health = 2
var hit = 0
var cooldown = 0

func _ready():
	idleTarget = position
#	$nav.set_target_location(get_parent().get_parent().get_node("YSort/Player").position)

func _process(delta):
	hit -= delta
	cooldown -= delta
	$Health.value += (100-health/2.0*100.0-$Health.value)/5
	if health <= 0 and not $CollisionShape2D.disabled:
		$CollisionShape2D.disabled = true
		$Extra.play("Die")
		yield(get_tree().create_timer(0.5), "timeout")
		queue_free()
#	timer += delta
	#$nav.global_position += ($nav/nav2.get_next_location()-$nav.global_position)
	var target = idleTarget
	var targetName = "none"
	if get_parent().get_node("Player").position.distance_to(position) < 300 and position.distance_to(idleTarget) < 800:
		target = get_parent().get_node("Player").position
		targetName = "player"
	if target.distance_to(position) > 25 and hit < -0.25:
		$nav.set_target_location(target)
		target = $nav.get_next_location()
		
		vel += position.direction_to(target)*speed
	if (position.direction_to(target)*speed).x > 0:
		$Goblin.scale.x = 4
	else:
		$Goblin.scale.x = -4
		
	var anim = "Idle"
	if vel.length() > speed*5:
		anim = "Run"
	if $AnimationPlayer.current_animation != "Attack":
		if get_parent().get_node("Player").position.distance_to(position) < 50 and targetName == "player" and cooldown < 0:
			cooldown = 1
			anim = "Attack"
			var proj = load("res://Projectile.tscn").instance()
			proj.texture = load("res://slash.png")
			proj.lifetime = 0.1
			proj.speed = 10
			proj.scale *= 6
			if $Goblin.scale.x > 0:
				proj.dir = 0
			else:
				proj.dir = 180
			proj.position = position+Vector2($Goblin.scale.x*5, 0)
			proj.name = "slash-goblin"
			proj.ignore = ["Goblin"]
			get_parent().add_child(proj)
		$AnimationPlayer.play(anim)
	vel *= 0.95
	move_and_slide(vel)
#	if target.x > position.x:
#		position.x += speed
#	if target.x < position.x:
#		position.x -= speed
#
#	if target.y > position.y:
#		position.y += speed
#	if target.y < position.y:
#		position.y -= speed
