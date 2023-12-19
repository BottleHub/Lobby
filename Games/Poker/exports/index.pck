GDPC                �                                                                         T   res://.godot/exported/133200997/export-0eaf90f903c31d0ef3e1bbc972671151-Metamask.scn�A             ��^$��|�XB��    X   res://.godot/exported/133200997/export-c803d6be45b3a850ac84b25eac1fd77a-TestScene.scn   @q      �      �?lS�.�%5N��H�	    ,   res://.godot/global_script_class_cache.cfg  ��      �       \���A��q!�+y    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex �      �      �Yz=������������       res://.godot/uid_cache.bin   �      �       ެ3˗o�7"tt��B�    ,   res://addons/metamask/Metamask.tscn.remap   ��      e       Cb㊀R�_2j���c�    (   res://addons/metamask/convert_util.gd           �      (3���C�?ފ���"    $   res://addons/metamask/metamask.gd   �      �4      �L�Љ��ش�%�>z        res://addons/metamask/plugin.gd �D      �       ����	[�2n��p�    (   res://exports/index.apple-touch-icon.png�E              ��ُ ��	���B~       res://exports/index.icon.png�E              ��ُ ��	���B~       res://exports/index.png �E              ��ُ ��	���B~       res://icon.svg  @�      �      C��=U���^Qu��U3       res://icon.svg.import   ��      �       �b�Q��q���V.�*U       res://project.binary �      �      �7؃ƿ���F��߿        res://scenes/test/TestScene.gd  �E      �+      �>/$��s����q    (   res://scenes/test/TestScene.tscn.remap   �      f       �3�/�c_h� �
�4        extends Node
class_name JavaScriptConvert

# Credit to GodotTutorial for the "protected" variable trick
# https://www.youtube.com/watch?v=NkEQyYXHyEk
var _document = JavaScriptBridge.get_interface("document")
var _window = JavaScriptBridge.get_interface("window")

enum Wei {
	to_Gwei,
	to_Eth
   }
var _wei_convert = {
	Wei.to_Gwei: float("1e9"),
	Wei.to_Eth: float("1e18")
}

func _protectedSet(_val):
	push_error("cannot access protected variable")

func _protectedGet():
	push_error("cannot access protected variable")

func _ready():
	_convert_util_script()

func _convert_util_script():
	var script_txt = "function convert_util(obj) { return Object.entries(obj); }"
	var script_block = _document.createElement('script')
	script_block.id = "convertUtil"
	var text_block = _document.createTextNode(script_txt)
	script_block.appendChild(text_block)
	_document.head.appendChild(script_block)

func _convert_arr(arr):
	var ret = []
	var n = arr.length
	for i in n:
		ret.append(to_GDScript(arr[i]))
	return ret

func _convert_obj(obj):
	# Get the javascript keys
	var ret = {}
	# Returns Array of [key, val] pairs
	var entries = _window.convert_util(obj)
	var n = entries.length
	for i in n:
		var key_val = entries[i]
		ret[key_val[0]] = to_GDScript(key_val[1])
	return ret

func to_GDScript(val):
	match typeof(val):
		# JavaScriptObject is TYPE_OBJECT
		TYPE_OBJECT:
			# Use the constructor name to split between array and object
			if val.constructor.name == 'Array':
				return _convert_arr(val)
			elif val.constructor.name == 'Object':
				return _convert_obj(val)
			# Only other case is a function, and we should keep that a JavaScriptObject...
			return val
		_:
			# Primitives are already converted to GDscript types
			return val

# Convert from GDScript Array to JavaScript Array
func arr_to_js(arr: Array) -> JavaScriptObject:
	var val = JavaScriptBridge.create_object('Array', len(arr))
	for i in range(len(arr)):
		val[i] = arr[i]
	return val

# Convert from GDScript Dictionary to JavaScript Dictionary
func dict_to_js(dict: Dictionary) -> JavaScriptObject:
	var val = JavaScriptBridge.create_object('Object')
	for key in dict:
		val[key] = dict[key]
	return val

# Convert hex string to 64bit signed int
func hex_to_int(hex: String) -> int:
	# Save hex in temp variable
	var val = hex
	# If begins with 0x, strip it off
	if val.begins_with("0x"):
		val = val.right(2)
	# TODO - Make sure the result can even be stored in a 64bit signed int...
	# How many hex digits we are trying to handle at a time
	# hex_to_int returns a 32bit signed int, so most we can do is 28bits aka 7 chars
	var step = 7
	# Do the first step
	var num: int = str("0x" + val.substr(0, step)).hex_to_int()
	var ind = step
	# Until we surpass the string
	while ind <= len(val):
		# Get up to step characters from the string
		# Can be less characters if there aren't enough in the string
		var sub = val.substr(ind, step)
		# convert to 32bit signed int
		var hexed = ("0x"+sub).hex_to_int()
		# Shift num as many steps as we have
		num = num << (4*len(sub))
		# Add hexed to num
		num = num | hexed
		# Increment index
		ind += step
	return num

# Convert Wei int to another base
func convert_wei(wei: int, factor: int = Wei.to_Eth) -> float:
	return wei / _wei_convert[factor]
         extends Node

# Signal to get result of request_accounts call
# response: Response[Array[String]] - Result is an array of addresses that the wallet now has permission to use
# NOTE - At this moment, this will always be of size 0 or 1
signal request_accounts_finished(response)
# Signal to get result of switch_to_chain call
# response: Response[null] - Result is null if call succeeded
signal switch_chain_finished(response)
# Signal to get result of client_version call
# response: Response[String] - Result is a string of the client's version
signal client_version_finished(response)
# Signal to get result of wallet_balance call
# Response[Int] - Result is the integer value of wallet balance in wei
signal wallet_balance_finished(response) 
# Signal to get result of token_balance call
# Response[Int] - Result is the integer value of the token associated to the address
signal token_balance_finished(response)
# Signal to get result of add_eth_chain call
# Response[null] - Result is null if call succeeded
signal add_eth_chain_finished(response)
# Signal to get result of add_custom_token call
# Response[null] - Result is null if call succeeded
signal add_custom_token_finished(response)
# Signal to get result of current_gas_price call
# Response[Int] - Result is the integer value of current gas price in wei
signal current_gas_price_finished(response)
# Signal to get result of send_token call
# Response[String] - Result is a hex encoded transaction hash
signal send_token_finished(response)
# Signal to get result of send_eth call
# Response[String] - Result is a hex encoded transaction hash
signal send_eth_finished(response)

# Signal when user changes their active accounts
# Currently only one account is active at a time but can potentially be more in the future
# New Accounts - Array of accounts user has changed to AND Application has permissions to see
signal accounts_changed(new_accounts)
# Signal when user changes their connected chain
# New Chain Id - String corresponding to the new Chain's ID
# See https://chainlist.org/ for list of each chain and their ID
signal chain_changed(new_chain_id)
# Signal when Metamask connects to the active chain
# chain_id: String - Id of chain Metamask has connected to
signal chain_connected(chain_id)
# Signal when Metamask disconnects from the active chain
# error: Dict - Contains "code" and "message" fields describing the error that occurred
signal chain_disconnected(error)
# Signal when a message is received by Metamask
# message: Dict - Contains "type" and "data" fields 
signal message_received(message)

@onready var convert_util: JavaScriptConvert = $JavaScriptConvert

# Credit to GodotTutorial for the 'protected' variable trick
# https://www.youtube.com/watch?v=NkEQyYXHyEk
var _base_property = 'plugins/metamask/' 
var _property_defaults = {
	'use_application_icon': false,
} 

var _document = JavaScriptBridge.get_interface('document') 
var _window = JavaScriptBridge.get_interface('window') 
var _ethereum = JavaScriptBridge.get_interface('ethereum') 

# Request Callbacks
var _eth_success_callback = JavaScriptBridge.create_callback(Callable(self, "_eth_request_success")) 
var _eth_failure_callback = JavaScriptBridge.create_callback(Callable(self, "_eth_request_failure")) 
var _convert_success_result_hti_callback = JavaScriptBridge.create_callback(Callable(self, "_convert_success_result_hex_to_int")) 

# Event Callbacks
var _accounts_callback = JavaScriptBridge.create_callback(Callable(self, "_on_accounts_changed")) 
var _chain_callback = JavaScriptBridge.create_callback(Callable(self, "_on_chain_changed")) 
var _connected_callback = JavaScriptBridge.create_callback(Callable(self, "_on_chain_connected")) 
var _disconnected_callback = JavaScriptBridge.create_callback(Callable(self, "_on_chain_disconnected")) 
var _message_callback = JavaScriptBridge.create_callback(Callable(self, "_on_message_received")) 

var _events_to_callbacks: Dictionary = {
	'accountsChanged': _accounts_callback,
	'chainChanged': _chain_callback,
	'connect': _connected_callback,
	'disconnect': _disconnected_callback,
	'message': _message_callback
} 

func _protectedSet(_val):
	push_error('cannot access protected variable')

func _protectedGet():
	push_error('cannot access protected variable')

func _ready():
	_create_request_wrapper()
	_load_config()
	_create_event_listeners()

func _create_request_wrapper():
	# TODO - See if there's a good way of importing this at run time
	var script_txt = "async function requestWrapper(requestBody, signal, success, failure) { try { result = await ethereum.request(requestBody); console.log(result); success(signal, result); } catch (e) { console.error(e); err_dict = { 'code': e.code, 'message': e.message }; failure(signal, err_dict); }}"
	# Create the block
	var script_block = _document.createElement('script')
	script_block.id = 'requestWrapper'
	var text_block = _document.createTextNode(script_txt)
	script_block.appendChild(text_block)
	_document.head.appendChild(script_block)

func _load_config():
	# Setup defaults for values if they are not already there
	for property in _property_defaults:
		if not ProjectSettings.has_setting(_base_property + property):
			ProjectSettings.set_setting(_base_property + property, _property_defaults[property])
	# Application Icon
	if ProjectSettings.get_setting(_base_property + 'use_application_icon'):
		_create_application_icon()

# Make your Application's icon show as the icon in the MetaMask popup
func _create_application_icon():
	var gd_icon = _document.getElementById('-gd-engine-icon')
	var metamaskIcon = _document.createElement('link')
	metamaskIcon.id = 'metamaskIcon'
	metamaskIcon.rel = 'shortcut icon'
	metamaskIcon.href = gd_icon.href
	_document.head.appendChild(metamaskIcon)

func _create_event_listeners():
	for event in _events_to_callbacks:
		var callback = _events_to_callbacks[event]
		_ethereum.on(event, callback)

func _exit_tree():
	for event in _events_to_callbacks:
		var callback = _events_to_callbacks[event]
		_ethereum.removeListener(event, callback)

func _on_accounts_changed(new_accounts):
	var val = convert_util.to_GDScript(new_accounts[0])
	emit_signal("accounts_changed", val)

func _on_chain_changed(new_chain):
	var val = convert_util.to_GDScript(new_chain[0])
	emit_signal("chain_changed", val)

func _on_chain_connected(chain):
	var val = convert_util.to_GDScript(chain[0])
	emit_signal("chain_connected", val)

func _on_chain_disconnected(error):
	var val = convert_util.to_GDScript(error[0])
	emit_signal("chain_disconnected", val)

func _on_message_received(message):
	var val = convert_util.to_GDScript(message[0])
	emit_signal("message_received", val)

# Helper method for building the request body for RPC calls
func _build_request_body(method: String, params = null, wrap_in_array = true) -> JavaScriptObject:
	var request_body = JavaScriptBridge.create_object('Object')
	request_body['method'] = method
	match typeof(params):
		TYPE_NIL:
			# If params is null, just continue
			pass
		TYPE_ARRAY:
			request_body['params'] = convert_util.arr_to_js(params)
		TYPE_DICTIONARY:
			var params_body = convert_util.dict_to_js(params)
			if wrap_in_array:
				request_body['params'] = JavaScriptBridge.create_object('Array', params_body)
			else:
				request_body['params'] = params_body
		_:
			# If we give just a single primitive, give it in an array
			# Looking at you eth_getBalance
			if wrap_in_array:
				request_body['params'] = JavaScriptBridge.create_object('Array', 1)
				request_body['params'][0] = params
			else:
				request_body['params'] = params
	return request_body

# Request wrapper so we can have default arguments
func _request_wrapper(request_body: JavaScriptObject,
						signal_name: String,
						success: JavaScriptObject = _eth_success_callback,
						failure: JavaScriptObject = _eth_failure_callback):
	# Since we are doing dynamic signal emitting, we better make sure that it actually exists
	if not self.has_signal(signal_name):
		push_error("Unknown signal name: " + signal_name)
		return
	_window.requestWrapper(request_body, signal_name, success, failure)

func _eth_request_success(args):
	var signal_name = args[0]
	var result = convert_util.to_GDScript(args[1])
	emit_signal(signal_name, {'result': result, 'error': null})

func _eth_request_failure(args):
	var signal_name = args[0]
	var error = convert_util.to_GDScript(args[1])
	emit_signal(signal_name, {'result': null, 'error': error})

func _convert_success_result_hex_to_int(args):
	var signal_name = args[0]
	var result = convert_util.to_GDScript(args[1])
	var result_as_int = convert_util.hex_to_int(result)
	emit_signal(signal_name, {'result': result_as_int, 'error': null})

# Checks if client has Metamask installed
# NOTE - This is not 100% accurate.  Because it is checking a JS property, this can be faked by another wallet provider.
# See https://docs.metamask.io/guide/ethereum-provider.html#ethereum-isconnected for details
func has_metamask() -> bool:
	return _ethereum != null && _ethereum.isMetaMask

# Checks if Metamask can talk to the current chain
func is_network_connected() -> bool:
	return _ethereum.isConnected()

# Gets the current connected chain id
func current_chain() -> String:
	return _ethereum.chainId

# Gets the active account address or null if no account is connected
func selected_account() -> String:
	return _ethereum.selectedAddress

# Requests permission to view user's accounts. Fires request_accounts_finished when complete
# Currently only returns the active account in Metamask, but passes back an Array for future proofing
func request_accounts():
	var request_body = _build_request_body('eth_requestAccounts')
	_request_wrapper(request_body, 'request_accounts_finished')

# Sends notification to user to switch to the chain with the provided ID
func switch_to_chain(chain_id: String):
	var request_body = _build_request_body('wallet_switchEthereumChain', {'chainId': chain_id})
	_request_wrapper(request_body, 'switch_chain_finished')

# Request the version of the client we are using
func client_version():
	var request_body = _build_request_body('web3_clientVersion')
	_request_wrapper(request_body, 'client_version_finished')

# Get the balance of wallet at address in wei
func wallet_balance(address: String):
	var request_body = _build_request_body('eth_getBalance', address)
	_request_wrapper(request_body, 'wallet_balance_finished', _convert_success_result_hti_callback)

# Get the balance of a token for an address
func token_balance(token_address: String, address: String):
	var action = "0x70a08231" + "0".repeat(24) + address.right(2)
	var request_body = _build_request_body('eth_call', {'to': token_address, 'data': action})
	_request_wrapper(request_body, 'token_balance_finished', _convert_success_result_hti_callback)

# Add a custom ethereum based chain to your wallet
func add_eth_chain(chain_id: String, chain_name: String, rpc_url: String,
					currency_symbol = null, block_explorer_url = null):
	var request_dict = {
		'chainId': chain_id,
		'chainName': chain_name,
		'rpcUrls': convert_util.arr_to_js([rpc_url]),
	}
	if currency_symbol != null:
		request_dict['nativeCurrency'] = convert_util.dict_to_js({'symbol': currency_symbol, 'decimals': 18})
	if block_explorer_url != null:
		request_dict['blockExplorerUrls'] = convert_util.arr_to_js([block_explorer_url])
	var request_body = _build_request_body('wallet_addEthereumChain', request_dict)
	_request_wrapper(request_body, 'add_eth_chain_finished')

# Tell Metamask to track a specified ERC20 token in the connected account
func add_custom_token(token_address: String, token_symbol: String, image_url: String):
	var request_body = _build_request_body('wallet_watchAsset', {
		'type': 'ERC20',
		'options': convert_util.dict_to_js({
			'address': token_address,
			'symbol': token_symbol,
			'decimals': 18,
			'image': image_url,
		}),
	}, false)
	_request_wrapper(request_body, 'add_custom_token_finished')

# Get the current gas price in Wei
func current_gas_price():
	var request_body = _build_request_body('eth_gasPrice')
	_request_wrapper(request_body, 'current_gas_price_finished', _convert_success_result_hti_callback)

# Send some amount of an ERC20 token from one account to another
func send_token(from_address: String, recipient_address: String, token_address: String, amount: float,
				gas_limit = null, gas_price = null):
	var amount_hex = '%x' % (amount * float('1e18'))
	# Transfer action hex
	var action = '0xa9059cbb' + "0".repeat(24) + recipient_address.right(2) + "0".repeat(64-len(amount_hex)) + amount_hex
	var request_dict = {
		'from': from_address,
		'to': token_address,
		'data': action,
	}
	if gas_limit != null:
		request_dict["gas"] = '%x' % gas_limit
	if gas_price != null:
		request_dict['gasPrice'] = '%x' % (gas_price * float('1e9'))
	var request_body = _build_request_body('eth_sendTransaction', request_dict)
	_request_wrapper(request_body, 'send_token_finished')

# Send some amount of ETH from one account to another
func send_eth(from_address: String, recipient_address: String, amount: float, gas_limit: int = 21000, gas_price = null):
	var amount_hex = '%x' % (amount * float('1e18'))
	var gas_hex = '%x' % gas_limit
	var request_dict = {
		'from': from_address,
		'to': recipient_address,
		'value': amount_hex,
		'gas': gas_hex,
	}
	if gas_price != null:
		request_dict['gasPrice'] = '%x' % (gas_price * float('1e9'))
	var request_body = _build_request_body('eth_sendTransaction', request_dict)
	_request_wrapper(request_body, 'send_eth_finished')
             RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script "   res://addons/metamask/metamask.gd ��������   Script &   res://addons/metamask/convert_util.gd ��������      local://PackedScene_w178a V         PackedScene          	         names "      	   Metamask    script    Node    JavaScriptConvert    	   variants                                node_count             nodes        ��������       ����                            ����                   conn_count              conns               node_paths              editable_instances              version             RSRC@tool
extends EditorPlugin

func _enter_tree():
	if OS.get_name() == "HTML5" or Engine.is_editor_hint():
		add_autoload_singleton("Metamask", "res://addons/metamask/Metamask.tscn")


func _exit_tree():
	remove_autoload_singleton("Metamask")
               extends Control

# System Checks
@onready var installed_check_box: CheckBox = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/InstalledCheckBox
@onready var connected_check_box: CheckBox = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ConnectedCheckBox
@onready var connect_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ConnectButton
# Switching Chains
@onready var chain_id_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ChainIdLineEdit
@onready var switch_chain_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/SwitchChainButton
# Eth Balance
@onready var balance_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/BalanceLineEdit
@onready var balance_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/BalanceButton
# Token Balance
@onready var token_balance_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TokenBalanceAddressLineEdit
@onready var wallet_token_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/WalletTokenBalanceLineEdit
@onready var token_balance_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TokenBalanceButton
# Custom Chain
@onready var add_binance_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/AddBinanceButton
@onready var add_matic_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/AddMaticButton
# Custom Token
@onready var add_enjin_token_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/AddEnjinTokenButton
# Gas Price
@onready var get_gas_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/GetGasButton
# Transfer ERC20
@onready var transfer_from_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TransferFromLineEdit
@onready var transfer_token_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TransferTokenLineEdit
@onready var transfer_to_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TransferToLineEdit
@onready var transfer_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TransferButton
@onready var transfer_amount_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/TransferAmountLineEdit
# Output
@onready var output_text_edit: TextEdit = $PanelSplitContainer/OutputPanelContainer/MarginContainer/VBoxContainer/OutputTextEdit

func _ready():
	# First check if Metamask is installed
	var installed = Metamask.has_metamask()
	#installed_check_box.pressed = installed
	if not installed:
		_print("Metamask is not installed...")
		_fail_init()
		return
	_print("Metamask is installed...")
	# Check if Metamask is connected
	var connected = Metamask.is_network_connected()
	#connected_check_box.pressed = connected
	if not connected:
		_print("Metamask is not connected...")
		_fail_init()
		return
	_print("Metamask is connected...")
	# Get information on Metamask connection
	_print("Current Chain: " + Metamask.current_chain())
	_print("Connected Account: " + str(Metamask.selected_account()))
	get_client_version()
	# Connect signals
# warning-ignore:return_value_discarded
	Metamask.connect("request_accounts_finished", _on_Metamask_request_accounts_finished)
# warning-ignore:return_value_discarded
	Metamask.connect("accounts_changed", _on_Metamask_accounts_changed)
# warning-ignore:return_value_discarded
	Metamask.connect("chain_changed", _on_Metamask_chain_changed)
# warning-ignore:return_value_discarded
	Metamask.connect("switch_chain_finished", _on_Metamask_switch_chain_finished)
# warning-ignore:return_value_discarded
	Metamask.connect("chain_connected", _on_Metamask_chain_connected)
# warning-ignore:return_value_discarded
	Metamask.connect("chain_disconnected", _on_Metamask_chain_disconnected)
# warning-ignore:return_value_discarded
	Metamask.connect("message_received", _on_Metamask_message_received)
# warning-ignore:return_value_discarded
	Metamask.connect("wallet_balance_finished", _on_Metamask_wallet_balance_finished)
# warning-ignore:return_value_discarded
	Metamask.connect("token_balance_finished", _on_Metamask_token_balance_finished)
# warning-ignore:return_value_discarded
	Metamask.connect("add_eth_chain_finished", _on_Metamask_add_eth_chain_finished)
# warning-ignore:return_value_discarded
	Metamask.connect("add_custom_token_finished", _on_Metamask_add_custom_token_finished)
# warning-ignore:return_value_discarded
	Metamask.connect("send_token_finished", _on_Metamask_send_token_finished)

func _print(text: String):
	output_text_edit.text += text + "\n"

func _fail_init():
	_print("Aborting remaining checks")
	connect_button.disabled = true

# Example of inline handling of the signal from an RPC call
func get_client_version():
	Metamask.client_version()
	var response = await Metamask.client_version_finished
	if response.error != null:
		# The call failed
		_print("Client Version Request Failed...")
		_print("Reason: " + response.error.message)
		return
	# The call succeeded
	_print("Client Version: " + response.result)

func _on_ConnectButton_pressed():
	_print("Attempting Request Accounts")
	connect_button.disabled = true
	Metamask.request_accounts()

func _on_Metamask_request_accounts_finished(response):
	connect_button.disabled = false
	if response.error != null:
		# The call failed
		_print("Accounts Request Failed...")
		_print("Reason: " + response.error.message)
		return
	# The call succeeded
	_print("Accounts Request Succeeded...")
	_print("Addresses:")
	for addr in response.result:
		_print("\t" + addr)

func _on_Metamask_accounts_changed(new_accounts):
	_print("User Accounts changed to " + new_accounts[0])

func _on_Metamask_chain_changed(new_chain_id):
	_print("User Connected Chain changed to " + new_chain_id)

func _on_Metamask_chain_connected(chain_id):
	_print("Metamask connected to chain: " + chain_id)

func _on_Metamask_chain_disconnected(error):
	_print("Metamask was disconnected from current chain")
	_print("Reason: " + error.message)

func _on_Metamask_message_received(message):
	_print("Metamask received message of type " + message.type)
	_print("Message : " + str(message.data))

func _on_SwitchChainButton_pressed():
	var new_chain_id = chain_id_line_edit.text
	_print("Attempting to Switch Chain to " + new_chain_id)
	switch_chain_button.disabled = true
	Metamask.switch_to_chain(new_chain_id)

func _on_Metamask_switch_chain_finished(response):
	switch_chain_button.disabled = false
	if response.error != null:
		_print("Chain Switch Failed...")
		_print("Reason: " + response.error.message)
		return
	_print("Chain Switch Succeeded...")

func _on_BalanceButton_pressed():
	var addr = balance_line_edit.text
	_print("Attempting to get balance of wallet at " + addr)
	balance_button.disabled = true
	Metamask.wallet_balance(addr)

func _on_Metamask_wallet_balance_finished(response):
	balance_button.disabled = false
	if response.error != null:
		_print("Wallet Balance Failed...")
		_print("Reason: " + response.error.message)
		return
	_print("Wallet Balance Succeeded...")
	# Whatever operations you wish to do with the balance (like aggregate wallet balances)
	# it's better to do it all in Wei, then when you want to display it convert it to a friendlier amount
	var wei_balance = response.result
	var eth_balance = Metamask.convert_util.convert_wei(wei_balance, Metamask.convert_util.Wei.to_Eth)
	_print("Wallet balance - " + str(eth_balance) + " eth")

func _on_TokenBalanceButton_pressed():
	var token_address = token_balance_line_edit.text
	var wallet_address = wallet_token_line_edit.text
	token_balance_button.disabled = true
	Metamask.token_balance(token_address, wallet_address)

func _on_Metamask_token_balance_finished(response):
	token_balance_button.disabled = false
	if response.error != null:
		_print("Token Balance Failed...")
		_print("Reason: " + response.error.message)
		return
	_print("Token Balance Succeeded...")
	_print("Token Balance - " + str(response.result))

func _on_AddBinanceButton_pressed():
	add_binance_button.disabled = true
	# Required variables
	var chain_id = '0x38' # 56 in hex
	var chain_name = 'Binance Smart Chain Mainnet'
	var rpc_url = 'https://bsc-dataseed1.binance.org'
	# Optional variables
	var currency_symbol = 'BNB'
	var blockscan_url = 'https://bscscan.com'
	Metamask.add_eth_chain(chain_id, chain_name, rpc_url, currency_symbol, blockscan_url)

func _on_AddMaticButton_pressed():
	add_matic_button.disabled = true
	# Required variables
	var chain_id = '0x89' # 137 in hex
	var chain_name = 'Matic Mainnet'
	var rpc_url = 'https://polygon-rpc.com/'
	# Optional variables
	var currency_symbol = 'MATIC'
	var blockscan_url = 'https://polygonscan.com/'
	Metamask.add_eth_chain(chain_id, chain_name, rpc_url, currency_symbol, blockscan_url)

func _on_Metamask_add_eth_chain_finished(response):
	add_binance_button.disabled = false
	add_matic_button.disabled = false
	if response.error != null:
		_print("Add Eth Chain Failed...")
		_print("Reason: " + response.error.message)
		return
	_print("Add Eth Chain Succeeded...")

func _on_AddEnjinTokenButton_pressed():
	add_enjin_token_button.disabled = true
	var token_address: String = '0xf629cbd94d3791c9250152bd8dfbdf380e2a3b9c'
	var token_symbol: String = 'ENJ'
	var image_url: String = 'https://cryptologos.cc/logos/enjin-coin-enj-logo.png'
	Metamask.add_custom_token(token_address, token_symbol, image_url)

func _on_Metamask_add_custom_token_finished(response):
	add_enjin_token_button.disabled = false
	if response.error != null:
		_print("Add Custom Token Failed...")
		_print("Reason: " + response.error.message)
		return
	_print("Add Custom Token Succeeded...")
	_print("Add Custom Token - " + str(response.result))

func _on_GetGasButton_pressed():
	get_gas_button.disabled = true
	Metamask.current_gas_price()
	var response = await Metamask.current_gas_price_finished
	if response.error != null:
		_print("Get Gas Price Failed...")
		_print("Reason: " + response.error.message)
		return
	var gwei_gas = Metamask.convert_util.convert_wei(response.result, Metamask.convert_util.Wei.to_Gwei)
	_print("Current Gas Price = %d gwei" % gwei_gas)
	get_gas_button.disabled = false
	

func _on_TransferButton_pressed():
	transfer_button.disabled = true
	var from = transfer_from_line_edit.text
	var token = transfer_token_line_edit.text
	var recipient = transfer_to_line_edit.text
	var amount = int(transfer_amount_line_edit.text)
	Metamask.send_token(from, token, recipient, amount)

func _on_Metamask_send_token_finished(response):
	transfer_button.disabled = false
	if response.error != null:
		_print("Send Token Failed...")
		_print("Reason: " + response.error.message)
		return
	_print("Send Token Succeeded...")
	_print("Transaction Hash - " + str(response.result))
         RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://scenes/test/TestScene.gd ��������      local://PackedScene_0a3ju          PackedScene          	         names "   A      Test    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control    PanelSplitContainer    HSplitContainer    UserPanelContainer    size_flags_horizontal    PanelContainer    MarginContainer    UserContainer    VBoxContainer    InstalledCheckBox 	   disabled    text 	   CheckBox    ConnectedCheckBox    ConnectButton    Button    HSeparator    ChainIdLineEdit    placeholder_text 	   LineEdit    SwitchChainButton    HSeparator2    BalanceLineEdit    BalanceButton    HSeparator3    TokenBalanceAddressLineEdit    WalletTokenBalanceLineEdit    TokenBalanceButton    HSeparator4    AddBinanceButton    AddMaticButton    HSeparator5    AddEnjinTokenButton    HSeparator6    GetGasButton    HSeparator7    TransferFromLineEdit    TransferTokenLineEdit    TransferToLineEdit    TransferAmountLineEdit    TransferButton    OutputPanelContainer    OutputLabel    Label    OutputTextEdit    size_flags_vertical 	   TextEdit    _on_ConnectButton_pressed    pressed    _on_SwitchChainButton_pressed    _on_BalanceButton_pressed    _on_TokenBalanceButton_pressed    _on_AddBinanceButton_pressed    _on_AddMaticButton_pressed     _on_AddEnjinTokenButton_pressed    _on_GetGasButton_pressed    _on_TransferButton_pressed    	   variants                        �?                                   User has Metamask installed?       Metamask is connected to chain       Connect to MetaMask       New Chain ID       Switch Chain       Wallet Address       Get Wallet Balance       Token Address       Get Token Balance       Add Binance Chain       Add Matic Chain       Add Enjin Token       Get Current Gas Price       Transfer Source Address       Address of Token to Transfer       Transfer Recipient       Transfer Amount    	   Transfer       Output Log       node_count    $         nodes     �  ��������       ����                                                          
   	   ����                                      ����                                 ����                          ����                          ����                                      ����                                      ����            	                    ����                          ����                   
                    ����                                ����                          ����                                       ����                                 ����                       !   ����                             "   ����                             #   ����                             $   ����                       %   ����                             &   ����                             '   ����                       (   ����                             )   ����                       *   ����                             +   ����                       ,   ����                             -   ����                             .   ����                             /   ����                             0   ����                             1   ����                                 ����                           ����             !       3   2   ����                   !       6   4   ����         5                 conn_count    	         conns     ?          8   7              
       8   9                     8   :                     8   ;                     8   <                     8   =                     8   >                     8   ?                     8   @                    node_paths              editable_instances              version             RSRC       GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح����mow�*��f�&��Cp�ȑD_��ٮ}�)� C+���UE��tlp�V/<p��ҕ�ig���E�W�����Sթ�� ӗ�A~@2�E�G"���~ ��5tQ#�+�@.ݡ�i۳�3�5�l��^c��=�x�Н&rA��a�lN��TgK㼧�)݉J�N���I�9��R���$`��[���=i�QgK�4c��%�*�D#I-�<�)&a��J�� ���d+�-Ֆ
��Ζ���Ut��(Q�h:�K��xZ�-��b��ٞ%+�]�p�yFV�F'����kd�^���:[Z��/��ʡy�����EJo�񷰼s�ɿ�A���N�O��Y��D��8�c)���TZ6�7m�A��\oE�hZ�{YJ�)u\a{W��>�?�]���+T�<o�{dU�`��5�Hf1�ۗ�j�b�2�,%85�G.�A�J�"���i��e)!	�Z؊U�u�X��j�c�_�r�`֩A�O��X5��F+YNL��A��ƩƗp��ױب���>J�[a|	�J��;�ʴb���F�^�PT�s�)+Xe)qL^wS�`�)%��9�x��bZ��y
Y4�F����$G�$�Rz����[���lu�ie)qN��K�<)�:�,�=�ۼ�R����x��5�'+X�OV�<���F[�g=w[-�A�����v����$+��Ҳ�i����*���	�e͙�Y���:5FM{6�����d)锵Z�*ʹ�v�U+�9�\���������P�e-��Eb)j�y��RwJ�6��Mrd\�pyYJ���t�mMO�'a8�R4��̍ﾒX��R�Vsb|q�id)	�ݛ��GR��$p�����Y��$r�J��^hi�̃�ūu'2+��s�rp�&��U��Pf��+�7�:w��|��EUe�`����$G�C�q�ō&1ŎG�s� Dq�Q�{�p��x���|��S%��<
\�n���9�X�_�y���6]���մ�Ŝt�q�<�RW����A �y��ػ����������p�7�l���?�:������*.ո;i��5�	 Ύ�ș`D*�JZA����V^���%�~������1�#�a'a*�;Qa�y�b��[��'[�"a���H�$��4� ���	j�ô7�xS�@�W�@ ��DF"���X����4g��'4��F�@ ����ܿ� ���e�~�U�T#�x��)vr#�Q��?���2��]i�{8>9^[�� �4�2{�F'&����|���|�.�?��Ȩ"�� 3Tp��93/Dp>ϙ�@�B�\���E��#��YA 7 `�2"���%�c�YM: ��S���"�+ P�9=+D�%�i �3� �G�vs�D ?&"� !�3nEФ��?Q��@D �Z4�]�~D �������6�	q�\.[[7����!��P�=��J��H�*]_��q�s��s��V�=w�� ��9wr��(Z����)'�IH����t�'0��y�luG�9@��UDV�W ��0ݙe)i e��.�� ����<����	�}m֛�������L ,6�  �x����~Tg����&c�U��` ���iڛu����<���?" �-��s[�!}����W�_�J���f����+^*����n�;�SSyp��c��6��e�G���;3Z�A�3�t��i�9b�Pg�����^����t����x��)O��Q�My95�G���;w9�n��$�z[������<w�#�)+��"������" U~}����O��[��|��]q;�lzt�;��Ȱ:��7�������E��*��oh�z���N<_�>���>>��|O�׷_L��/������զ9̳���{���z~����Ŀ?� �.݌��?�N����|��ZgO�o�����9��!�
Ƽ�}S߫˓���:����q�;i��i�]�t� G��Q0�_î!�w��?-��0_�|��nk�S�0l�>=]�e9�G��v��J[=Y9b�3�mE�X�X�-A��fV�2K�jS0"��2!��7��؀�3���3�\�+2�Z`��T	�hI-��N�2���A��M�@�jl����	���5�a�Y�6-o���������x}�}t��Zgs>1)���mQ?����vbZR����m���C��C�{�3o��=}b"/�|���o��?_^�_�+��,���5�U��� 4��]>	@Cl5���w��_$�c��V��sr*5 5��I��9��
�hJV�!�jk�A�=ٞ7���9<T�gť�o�٣����������l��Y�:���}�G�R}Ο����������r!Nϊ�C�;m7�dg����Ez���S%��8��)2Kͪ�6̰�5�/Ӥ�ag�1���,9Pu�]o�Q��{��;�J?<�Yo^_��~��.�>�����]����>߿Y�_�,�U_��o�~��[?n�=��Wg����>���������}y��N�m	n���Kro�䨯rJ���.u�e���-K��䐖��Y�['��N��p������r�Εܪ�x]���j1=^�wʩ4�,���!�&;ج��j�e��EcL���b�_��E�ϕ�u�$�Y��Lj��*���٢Z�y�F��m�p�
�Rw�����,Y�/q��h�M!���,V� �g��Y�J��
.��e�h#�m�d���Y�h�������k�c�q��ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[          [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://c5hxy80jgruwv"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                [remap]

path="res://.godot/exported/133200997/export-0eaf90f903c31d0ef3e1bbc972671151-Metamask.scn"
           [remap]

path="res://.godot/exported/133200997/export-c803d6be45b3a850ac84b25eac1fd77a-TestScene.scn"
          list=Array[Dictionary]([{
"base": &"Node",
"class": &"JavaScriptConvert",
"icon": "",
"language": &"GDScript",
"path": "res://addons/metamask/convert_util.gd"
}])
             <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
             8�N��c#   res://addons/metamask/Metamask.tscn���B'r(   res://exports/index.apple-touch-icon.png�i����/   res://exports/index.icon.pngg�d��S�   res://exports/index.png���vU>Z    res://scenes/test/TestScene.tscn�;�ҭ_   res://icon.svg        ECFG      application/config/name         Lobby      application/run/main_scene(          res://scenes/test/TestScene.tscn   application/config/features   "         4.2    Mobile     application/config/icon         res://icon.svg     autoload/Metamask,      $   *res://addons/metamask/Metamask.tscn   editor_plugins/enabled0   "      !   res://addons/metamask/plugin.cfg    #   rendering/renderer/rendering_method         gl_compatibility   