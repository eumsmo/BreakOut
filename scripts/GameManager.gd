extends Node

@export var location: Resource
@export var personagens: Resource
@export var cena_atual: Resource
@export var prefab_button: Resource
@export var prefab_window: Resource
var botao_proximo

var caminho_atual: String
var timeline_index: int
var fala_index: int

var caminho_alternativo


var cena_fim = preload("res://scenes/fim.tscn").instantiate()
var cena_breakout = preload("res://scenes/cena.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	botao_proximo = $"../Textbox/Control/TextoHolder/Button"
	botao_proximo.visible = true
	caminho_atual = "padrao"
	limpar_personagens()
	atualizar_cena()
	
	$"../Textbox/Control/TextoHolder/Button".pressed.connect(proxima_timeline)
	

func atualizar_cena():
	var local = cena_atual.data.local
	var location_ref = location.data[local]
	$"../Background/VBoxContainer/TextureRect".texture = load("res://imgs/" + location_ref)
	$"../Background/VBoxContainer/TextureRect".texture_filter = 1
	caminho_atual = "padrao"
	timeline_index = 0
	fala_index = 0
	mostrar_escolha([])
	atualizar_timeline()
	
func atualizar_timeline():
	var atual = cena_atual.data.timeline[timeline_index]
	
	if caminho_atual == "alternativo":
		atual = caminho_alternativo[timeline_index]
	
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
		elif atual.acao == "pular":
			pular_para(atual.para)
		elif atual.acao == "animacao":
			tocar_animacao()
		elif atual.acao == "botao":
			if atual.esconder:
				some_botao()
			else:
				aparece_botao()
		elif atual.acao == "breakout":
			get_tree().change_scene_to_file("res://scenes/cena.tscn")
		elif atual.acao == "fim":
			get_tree().change_scene_to_file("res://scenes/fim.tscn")
		elif atual.acao == "encerrar":
			get_tree().quit()
	else:
		mostrar_fala(atual)

func proxima_timeline():
	var atual = cena_atual.data.timeline[timeline_index]
	if caminho_atual == "alternativo":
		atual = caminho_alternativo[timeline_index]
	
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
	if opcoes.size() > 0:
		botao_proximo.visible = false
	
	var pai = $"../Choice/BotaoHolder"
	var quant = opcoes.size()
	
	for filho in pai.get_children():
		filho.queue_free()
	
	for i in range(quant):
		var novo_botao = prefab_button.instantiate()
		pai.add_child(novo_botao)
		novo_botao.text = opcoes[i].texto
		novo_botao.pressed.connect(func():
			for filho in pai.get_children():
				filho.queue_free()
			
			botao_proximo.visible = true
			ir_para_escolha(opcoes[i].caminho)
		)
		
func ir_para_escolha(caminho):
	print(caminho)
	caminho_atual = "alternativo"
	timeline_index = 0
	fala_index = 0
	caminho_alternativo = cena_atual.data.alternativo[caminho]
	atualizar_timeline()

func pular_para(identificador):
	var index = -1
	for i in range(cena_atual.data.timeline.size()):
		var fala = cena_atual.data.timeline[i]
		if "identificador" in fala and fala.identificador == identificador:
			index = i
			break
			
	caminho_atual = "padrao"
	timeline_index = index
	fala_index = 0
	atualizar_timeline()

func tocar_animacao():
	var window = prefab_window.instantiate()
	add_child(window)
	proxima_timeline()

func some_botao():
	botao_proximo.visible = false
	proxima_timeline()

func aparece_botao():
	botao_proximo.visible = true
	proxima_timeline()
