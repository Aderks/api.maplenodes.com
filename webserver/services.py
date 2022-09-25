from flask import Flask, url_for, jsonify, request, Response
from flask_caching import Cache
import requests
import json
import os
import subprocess
import base58

config = {
    "DEBUG": False,
    "CACHE_TYPE": "FileSystemCache",
    "CACHE_DIR": "/services/tmp"
}
app = Flask(__name__)

app.config.from_mapping(config)
cache = Cache(app)

app.config['JSON_SORT_KEYS'] = False

# All requests require this header
headers = {'Content-Type': 'application/json',}

# Error Handling
@app.errorhandler(400)
def bad_request_error(error):
	response = jsonify({
		'code': 1004,
		'error': 'Bad Request: Incorrect or no data parameters present'
		})
	return response


@app.errorhandler(500)
def internal_server_error(error):
	response = jsonify({
		'code': 1002,
		'error': 'Internal Server Error: failed to connect to node'
		})
	return response


@app.errorhandler(401)
def unauthorized_error(error):
	response = jsonify({
		'code': 1001,
		'error': 'Unauthorized User Access'
		})
	return response

# API

#4chanBoards
@app.route('/v1/4chanBoards', methods = ['POST'])
def api_4chanBoards():

	url = 'https://a.4cdn.org/boards.json'

	response = requests.get(url)
	return response.json()


#btc_getrawmempoolcount
@app.route('/v1/btc_getrawmempoolcount', methods = ['GET','POST'])
def api_btc_getrawmempoolcount():

	r = requests.get('https://api.maplenodes.com/v1/btc_getrawmempool')
	data = r.json()

	data_count = len(data)

	response = '{"tx_mempool_count": '+str(data_count)+'}'
	
	try:
		return response
	except:
		return bad_request_error


#WorldCurrencyList
@app.route('/v1/WorldCurrencyList', methods = ['POST'])
def api_WorldCurrencyList():

	response = subprocess.check_output("/services/scripts/currencylist.sh", shell=False)

	try:
		return response
	except:
		return bad_request_error


#BitlyURLShortener
@app.route('/v1/BitlyURLShortener', methods = ['POST'])
def api_BitlyURLShortener():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	url_long = payload[0]

	response = subprocess.check_output(['/services/scripts/bitly.sh', url_long], shell=False)

	try:
		return response
	except:
		return bad_request_error


#CurrencyExchangeRate
@app.route('/v1/CurrencyExchangeRate', methods = ['POST'])
def api_CurrencyExchangeRate():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	currency1 = payload[0]
	currency2 = payload[1]

	response = subprocess.check_output(['/services/scripts/currencyconverter.sh', currency1, currency2], shell=False)

	try:
		return response
	except:
		return bad_request_error


#LiveSportsOddsList
@app.route('/v1/LiveSportsOddsList', methods = ['POST'])
def api_LiveSportsOddsList():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	active = payload[0]

	response = subprocess.check_output(['/services/scripts/livesportsoddslist.sh', active], shell=False)

	try:
		return response
	except:
		return bad_request_error


#LiveSportsOdds
@app.route('/v1/LiveSportsOdds', methods = ['POST'])
def api_LiveSportsOdds():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	sport = payload[0]
	region = payload[1]

	response = subprocess.check_output(['/services/scripts/livesportsodds.sh', sport, region], shell=False)

	try:
		return response
	except:
		return bad_request_error


#GlobalStockLatestInfo
@app.route('/v1/GlobalStockLatestInfo', methods = ['POST'])
def api_GlobalStockLatestInfo():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	symbol = payload[0]
	apikey= ''

	url = 'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol='+symbol+'&apikey='+apikey+''

	response = requests.get(url)

	try:
		return response.json()
	except:
		return bad_request_error


#GlobalStockSymbolSearch
@app.route('/v1/GlobalStockSymbolSearch', methods = ['POST'])
def api_GlobalStockSymbolSearch():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	keyword = payload[0]
	apikey= ''

	url = 'https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords='+keyword+'&apikey='+apikey+''

	response = requests.get(url)

	try:
		return response.json()
	except:
		return bad_request_error


#4chanThreads
@app.route('/v1/4chanThreads', methods = ['POST'])
def api_4chanThreads():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	board = payload[0]

	response = subprocess.check_output(['/services/scripts/4chanthreads.sh', board], shell=False)

	try:
		return response
	except:
		return bad_request_error



#4chanThreadViewer
@app.route('/v1/4chanThreadViewer', methods = ['POST'])
def api_4chanThreadViewer():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	board = payload[0]
	thread = payload[1]

	response = subprocess.check_output(['/services/scripts/4chanthreadviewer.sh', board, thread], shell=False)

	try:
		return response
	except:
		return bad_request_error


#4chanThreadViewerPrice
@app.route('/v1/4chanThreadViewerPrice', methods = ['POST'])
def api_4chanThreadViewerPrice():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 4:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 4'
		})
		return payload_error

	board = payload[0]
	thread = payload[1]
	ticker = payload[2]
	currency = payload[3]

	response = subprocess.check_output(['/services/scripts/4chanthreadviewer.sh', board, thread, ticker, currency], shell=False)

	try:
		return response
	except:
		return bad_request_error


#dxGet24hrTradeHistory
@app.route('/v1/dxGet24hrTradeHistory', methods = ['POST'])
def api_dxGet24hrTradeHistory():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	show_all = payload[0]

	response = subprocess.check_output(['/services/scripts/dxget24hrtradehistory.sh', show_all], shell=False)

	try:
		return response
	except:
		return bad_request_error


#dxGet24hrTradeSummary
@app.route('/v1/dxGet24hrTradeSummary', methods = ['POST'])
def api_dxGet24hrTradeSummary():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	show_all = payload[0]

	response = subprocess.check_output(['/services/scripts/dxget24hrtradesummary.sh', show_all], shell=False)

	try:
		return response
	except:
		return bad_request_error


#dxGetOrders
@app.route('/v1/dxGetOrders', methods = ['POST'])
def api_dxGetOrders():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	maker = payload[0]
	taker = payload[1]

	response = subprocess.check_output(['/services/scripts/dxgetorders.sh', maker, taker], shell=False)

	try:
		return response
	except:
		return bad_request_error


#TwitterSearch
@app.route('/v1/TwitterSearch', methods = ['POST'])
def api_TwitterSearch():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 3:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 3'
		})
		return payload_error

	search = payload[0]
	result_type = payload[1]
	tweet_count = payload[2]

	response = subprocess.check_output(['/services/scripts/twitter.sh', search, result_type, tweet_count], shell=False)

	try:
		return response
	except:
		return bad_request_error


#CCMultiPrice
@app.route('/v1/CCMultiPrice', methods = ['POST'])
def api_CCMultiPrice():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	tickers = payload[0]
	currency = payload[1]

	response = subprocess.check_output(['/services/scripts/cc_multi_price.sh', tickers, currency], shell=False)

	try:
		return response
	except:
		return bad_request_error


#CCSinglePrice
@app.route('/v1/CCSinglePrice', methods = ['POST'])
def api_CCSinglePrice():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	tickers = payload[0]
	currency = payload[1]

	response = subprocess.check_output(['/services/scripts/cc_single_price.sh', tickers, currency], shell=False)

	try:
		return response
	except:
		return bad_request_error


#CCTopListVolume24H
@app.route('/v1/CCTopListVolume24H', methods = ['POST'])
def api_CCTopListVolume24H():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	limit = payload[0]
	currency = payload[1]

	response = subprocess.check_output(['/services/scripts/cc_top24hr_volume.sh', limit, currency], shell=False)

	try:
		return response
	except:
		return bad_request_error


#CCTopExchangesVolumeByPair
@app.route('/v1/CCTopExchangesVolumeByPair', methods = ['POST'])
def api_CCTopExchangesVolumeByPair():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	ticker = payload[0]
	currency = payload[1]

	response = subprocess.check_output(['/services/scripts/cc_topexchanges_volume_bypair.sh', ticker, currency], shell=False)

	try:
		return response
	except:
		return bad_request_error


#CCTopListMarketCap
@app.route('/v1/CCTopListMarketCap', methods = ['POST'])
def api_CCTopListMarketCap():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	limit = payload[0]
	currency = payload[1]

	response = subprocess.check_output(['/services/scripts/cc_toplist_marketcap.sh', limit, currency], shell=False)

	try:
		return response
	except:
		return bad_request_error


#CCTopListVolumeByPair
@app.route('/v1/CCTopListVolumeByPair', methods = ['POST'])
def api_CCTopListVolumeByPair():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	ticker = payload[0]

	response = subprocess.check_output(['/services/scripts/cc_toplist_pairvolume.sh', ticker], shell=False)

	try:
		return response
	except:
		return bad_request_error


#TwilioSendSMS
@app.route('/v1/TwilioSendSMS', methods = ['POST'])
def api_TwilioSendSMS():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	your_number = payload[0]
	message = payload[1]

	response = subprocess.check_output(['/services/scripts/sendsms.sh', your_number, message], shell=False)

	try:
		return response
	except:
		return bad_request_error


#TwilioSMSStatus
@app.route('/v1/TwilioSMSStatus', methods = ['POST'])
def api_TwilioSMSStatus():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	sid = payload[0]

	response = subprocess.check_output(['/services/scripts/smsstatus.sh', sid], shell=False)

	try:
		return response
	except:
		return bad_request_error


#CurrentWeatherData
@app.route('/v1/CurrentWeatherData', methods = ['POST'])
def api_CurrentWeatherData():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	location = payload[0]
	units = payload[1]
	apikey= ''

	url = 'http://api.openweathermap.org/data/2.5/weather?q='+location+'&units='+units+'&appid='+apikey+''

	response = requests.get(url)

	try:
		return response.json()
	except:
		return bad_request_error


#TrollBox
@app.route('/v1/TrollBox', methods = ['POST'])
def api_TrollBox():

	response = subprocess.check_output(['/services/trollbox/trollbox.sh'], shell=False)

	try:
		return response
	except:
		return bad_request_error


#TrollBoxMsg
@app.route('/v1/TrollBoxMsg', methods = ['POST'])
def api_TrollBoxMsg():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	user = payload[0]
	message = payload[1]

	response = subprocess.check_output(['/services/trollbox/trollboxmsg.sh', user, message], shell=False)

	try:
		return response
	except:
		return bad_request_error


#TelegramUserRegistration
@app.route('/v1/TelegramUserRegistration', methods = ['POST'])
def api_TelegramUserRegistration():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	username = payload[0]

	response = subprocess.check_output(['/services/telegram/telegramuserregistration.sh', username], shell=False)

	try:
		return response
	except:
		return bad_request_error


#TelegramSendMsg
@app.route('/v1/TelegramSendMsg', methods = ['POST'])
def api_TelegramSendMsg():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 2:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 2'
		})
		return payload_error

	authorize_user = payload[0]
	message = payload[1]

	response = subprocess.check_output(['/services/telegram/telegramsendmessage.sh', authorize_user, message], shell=False)

	try:
		return response
	except:
		return bad_request_error


#BlackJack
@app.route('/v1/BlackJack', methods = ['POST'])
def api_BlackJack():

	response = subprocess.check_output(['/services/blackjack/blackjack.sh'], shell=False)

	try:
		return response
	except:
		return bad_request_error


#BlackJackHIT
@app.route('/v1/BlackJackHIT', methods = ['POST'])
def api_BlackJackHIT():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	round_id = payload[0]

	response = subprocess.check_output(['/services/blackjack/blackjack_hit.sh', round_id], shell=False)

	try:
		return response
	except:
		return bad_request_error


#BlackJackSTAND
@app.route('/v1/BlackJackSTAND', methods = ['POST'])
def api_BlackJackSTAND():

	payload = request.json
	payload_count = len(payload)

	if len(payload) == 1:
		print (payload)
	else:
		payload_error = jsonify({
		'code': 1025,
		'error': 'Received parameters count '+str(payload_count)+' do not match expected 1'
		})
		return payload_error

	round_id = payload[0]

	response = subprocess.check_output(['/services/blackjack/blackjack_stand.sh', round_id], shell=False)

	try:
		return response
	except:
		return bad_request_error


@app.route('/graph/indexer/<indexer_id>', methods = ['POST', 'GET'])
@cache.cached(timeout=60)
def api_graph_rewards(indexer_id):

		data = subprocess.check_output(['/services/scripts/graph_rewards.sh', indexer_id], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Indexer-ID does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/testnet/indexer/<indexer_id>', methods = ['POST', 'GET'])
@cache.cached(timeout=60)
def api_graph_testnet_rewards(indexer_id):

		data = subprocess.check_output(['/services/scripts/graph_rewards_testnet.sh', indexer_id], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Indexer-ID does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/indexers/', methods = ['POST', 'GET'])
@cache.cached(timeout=86400)
def api_graph_indexers():

		data = subprocess.check_output(['/services/scripts/graph_indexers.sh'], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Indexers does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/testnet/indexers/', methods = ['POST', 'GET'])
@cache.cached(timeout=86400)
def api_graph_testnet_indexers():

		data = subprocess.check_output(['/services/scripts/graph_indexers_testnet.sh'], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Indexers does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/network/', methods = ['POST', 'GET'])
def api_graph_network():

		data = subprocess.check_output(['/services/scripts/graph_network.sh'], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/testnet/network/', methods = ['POST', 'GET'])
def api_graph_testnet_network():

		data = subprocess.check_output(['/services/scripts/graph_network_testnet.sh'], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/ens/<indexer_id>', methods = ['POST', 'GET'])
@cache.cached(timeout=86400)
def api_graph_ens(indexer_id):

		data = subprocess.check_output(['/services/scripts/graph_ens.sh', indexer_id], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Indexer-ID does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/allocations/<indexer_id>', methods = ['POST', 'GET'])
@cache.cached(timeout=60)
def api_graph_allocations(indexer_id):

		data = subprocess.check_output(['/services/scripts/graph_allocations.sh', indexer_id], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Indexer-ID does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/allocations/info/<indexer_id>', methods = ['POST', 'GET'])
@cache.cached(timeout=60)
def api_graph_allocations_info(indexer_id):

		data = subprocess.check_output(['/services/scripts/graph_allocations_with_id.sh', indexer_id], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Indexer-ID does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/testnet/allocations/info/<indexer_id>', methods = ['POST', 'GET'])
@cache.cached(timeout=60)
def api_graph_testnet_allocations_info(indexer_id):

		data = subprocess.check_output(['/services/scripts/graph_allocations_with_id_testnet.sh', indexer_id], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Indexer-ID does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/IPFS/<subgraph_id>', methods = ['POST', 'GET'])
@cache.cached(timeout=86400)
def api_graph_ipfs(subgraph_id):

		ipfs_hash = base58.b58encode(bytes.fromhex("1220"+(subgraph_id)[2:])).decode('utf-8')

		response = jsonify({
			'ipfs_hash': ipfs_hash
			})

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Subgraph-ID does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/subgraphs/', methods = ['POST', 'GET'])
@cache.cached(timeout=60)
def api_graph_subgraphs():

		data = subprocess.check_output(['/services/scripts/graph_subgraphs.sh'], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Subgraphs do not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/indexers/kpi/', methods = ['POST', 'GET'])
@cache.cached(timeout=60)
def api_graph_indexer_kpi():

		data = subprocess.check_output(['/services/scripts/graph_kpi.sh'], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/subgraphs/active/', methods = ['POST', 'GET'])
@cache.cached(timeout=30)
def api_graph_subgraphs_active():

		data = subprocess.check_output(['/services/scripts/graph_subgraphs_active.sh'], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Subgraphs do not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/subgraph/trace/<ipfs_hash>', methods = ['POST', 'GET'])
@cache.cached(timeout=86400)
def api_graph_subgraph_trace(ipfs_hash):

		data = subprocess.check_output(['/services/scripts/graph_trace.sh', ipfs_hash], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Subgraph does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/network/stake/', methods = ['POST', 'GET'])
def api_graph_network_stake():

		data = subprocess.check_output(['/services/scripts/graph_network_stake.sh'], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/graph/testnet/network/stake/', methods = ['POST', 'GET'])
def api_graph_testnet_network_stake():

		data = subprocess.check_output(['/services/scripts/graph_network_stake_testnet.sh'], shell=False)

		response = Response(response=data,
						status=200,
						mimetype="application/json")

		if response == "":
			error = jsonify({
			'code': 1004,
			'error': 'Does not exist'
			})
			return error

		try:
			return response
		except:
			return bad_request_error


@app.route('/ethereum/gas/', methods = ['POST', 'GET'])
@cache.cached(timeout=30)
def api_ethereum_gas():

		url = 'https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=xxx'

		response = requests.get(url)

		try:
			return response.json()
		except:
			return bad_request_error


@app.route('/evmos/account/transactions/<address>/page=<page>', methods = ['POST', 'GET'])
@cache.cached(timeout=900)
def api_evmos_account_transactions(address, page):

                data = subprocess.check_output(['/services/scripts/evmos_transactions.sh', address, page], shell=False)

                response = Response(response=data,
                                                status=200,
                                                mimetype="application/json")

                if response == "":
                        error = jsonify({
                        'code': 1004,
                        'error': 'Address does not exist'
                        })
                        return error

                try:
                        return response
                except:
                        return bad_request_error


@app.route('/evmos/apr/', methods = ['POST', 'GET'])
@cache.cached(timeout=30)
def api_evmos_apr():

                data = subprocess.check_output(['/services/scripts/evmos_apr.sh'], shell=False)

                response = Response(response=data,
                                                status=200,
                                                mimetype="application/json")

                if response == "":
                        error = jsonify({
                        'code': 1004,
                        'error': 'Does not exist'
                        })
                        return error

                try:
                        return response
                except:
                        return bad_request_error


@app.route('/graph/failedSubgraph/<subgraph>/<block>/<indexer>', methods = ['POST', 'GET'])
@cache.cached(timeout=60)
def api_graph_failedSubgraph(subgraph, block, indexer):

                data = subprocess.check_output(['/services/scripts/graph_failed_subgraph.sh', subgraph, block, indexer], shell=False)

                response = Response(response=data,
                                                status=200,
                                                mimetype="application/json")

                if response == "":
                        error = jsonify({
                        'code': 1004,
                        'error': 'Bad data'
                        })
                        return error

                try:
                        return response
                except:
                        return bad_request_error


@app.route('/evmos/account/evm/transactions/<address>', methods = ['POST', 'GET'])
@cache.cached(timeout=60)
def api_evmos_account_evm_transactions(address):

                data = subprocess.check_output(['/services/scripts/evmos_evm_transactions.sh', address], shell=False)

                response = Response(response=data,
                                                status=200,
                                                mimetype="application/json")

                if response == "":
                        error = jsonify({
                        'code': 1004,
                        'error': 'Address does not exist'
                        })
                        return error

                try:
                        return response
                except:
                        return bad_request_error


@app.route('/evmos/account/evm/tokentransfers/<address>', methods = ['POST', 'GET'])
@cache.cached(timeout=60)
def api_evmos_account_evm_tokentransfers(address):

                data = subprocess.check_output(['/services/scripts/evmos_evm_token_transfers.sh', address], shell=False)

                response = Response(response=data,
                                                status=200,
                                                mimetype="application/json")

                if response == "":
                        error = jsonify({
                        'code': 1004,
                        'error': 'Address does not exist'
                        })
                        return error

                try:
                        return response
                except:
                        return bad_request_error


@app.route('/graph/testnet/subgraphs/active/', methods = ['POST', 'GET'])
@cache.cached(timeout=30)
def api_graph_testnet_subgraphs_active():

                data = subprocess.check_output(['/services/scripts/graph_subgraphs_active_testnet.sh'], shell=False)

                response = Response(response=data,
                                                status=200,
                                                mimetype="application/json")

                if response == "":
                        error = jsonify({
                        'code': 1004,
                        'error': 'Subgraphs do not exist'
                        })
                        return error

                try:
                        return response
                except:
                        return bad_request_error

# Web Server is listening on 0.0.0.0:8192
if __name__ == '__main__':
	app.run(host= '0.0.0.0', port= 8192)
