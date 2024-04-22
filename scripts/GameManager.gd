extends Node

@export var location: Resource
@export var personagens: Resource
@export var cena_atual: Resource

var timeline_index: int
var fala_index: int

# Called when the node enters the scene tree for the first time.
func _ready():
	limpar_personagens()
	atualizar_cena()
	
	$"../Textbox/Control/TextoHolder/Button".pressed.connect(proxima_timeline)

func atualizar_cena():
	var local = cena_atual.data.local
	var location_ref = location.data[local]
	$"../Background/VBoxContainer/TextureRect".texture = load("res://imgs/" + location_ref)
	$"../Background/VBoxContainer/TextureRect".texture_filter = 1
	timeline_index = 0
	fala_index = 0
	atualizar_timeline()
	
func atualizar_timeline():
	var atual = cena_atual.data.timeline[timeline_index]
	
	if atual.type == "acao":
		if atual.acao == "entra":
			entrar_personagem(atual.personagem)
			proxima_timeline()
		elif atual.acao == "sai":
			sair_personagem(atual.personagem)
			proxima_timeline()
		elif atual.acao == "cena":
			cena_atual = ResourceLoader.load("res://" + atual.cena)
			atualizar_cena()
		elif atual.acao == "escolha":
			mostrar_escolha(atual.escolhas)
	else:
		mostrar_fala(atual)

func proxima_timeline():
	var atual = cena_atual.data.timeline[timeline_index]
	if atual.type == "fala" and fala_index < atual.textos.size() - 1:
		fala_index += 1
	else:
		fala_index = 0
		timeline_index += 1
	atualizar_timeline()

func mostrar_fala(fala_data):
	var personagem = fala_data.personagem
	var personagem_data = personagens.data[personagem]
	var fala = fala_data.textos[fala_index]
	
	$"../Textbox/Control/PortraitHolder/Portrait".texture = load("res://" + personagem_data.portrait)
	$"../Textbox/Control/PortraitHolder/Portrait".texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	$"../Textbox/Control/TextoHolder/TextoLabel".text = fala
	$"../Textbox/Control/NomeLabel".text = personagem_data.nome

func entrar_personagem(personagem: String):
	var personagem_data = personagens.data[personagem]
	var portrait = TextureRect.new()
	portrait.texture = load ("res://imgs/" + personagem_data.stand)
	portrait.name = personagem_data.nome
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	
	$"../Characters/PersonagensHolder".add_child(portrait)

func sair_personagem(personagem: String):
	var personagem_data = personagens.data[personagem]
	var nome = personagem_data.nome
	var portrait = $"../Characters/PersonagensHolder".get_node(nome)
	portrait.queue_free()

func limpar_personagens():
	var parent = $"../Characters/PersonagensHolder"
	for N in parent.get_children():
		N.queue_free()

func mostrar_escolha(opcoes):
	
