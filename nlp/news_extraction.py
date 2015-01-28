from lxml import etree as ET
import sqlite3
import newspaper
import requests
import json
import time
import chardet
import jieba
from time import gmtime, strftime
import news_validate_checking

headers = {'content-type':'application/json'}
f = open('rss_url', 'r')
China_url = f.readline()
len_china = len(China_url)
China_url = China_url[6:len_china-1]

World_url = f.readline()
len_world = len(World_url)
World_url = World_url[6:len_world-1]

Zonghe_url = f.readline()
len_zong = len(Zonghe_url)
Zonghe_url = Zonghe_url[6:len_zong-1]

Kejix_url = f.readline()
len_keji = len(Kejix_url)
Kejix_url = Kejix_url[6:len_keji-1]

Sport_url = f.readline()
len_Sport = len(Sport_url)
Sport_url = Sport_url[6:len_Sport-1]

Milit_url = f.readline()
len_Milit = len(Milit_url)
Milit_url = Milit_url[6:len_Milit-1]

Autos_url = f.readline()
len_Autos = len(Autos_url)
Autos_url = Autos_url[6:len_Autos-1]

Educa_url = f.readline()
len_Educa = len(Educa_url)
Educa_url = Educa_url[6:len_Educa-1]

f.close()
def run_it():
	#print "run_it"
	conn = sqlite3.connect('news_source.db')
	c = conn.cursor()
	try:
		tree = ET.parse(China_url)#Chinese News
	except Exception, e:
		return "xml_china"
	root = tree.getroot()
	for item in root[0][10:]:
		title_len = len(item[0].text)
		title = item[0].text[5:title_len-4].encode('utf-8')
		url = item[1].text.encode('utf-8')
		if item[5].text is None:
			item[5].text = strftime("%Y-%m-%d %H:%M:%S", gmtime())
		time = item[5].text.encode('utf-8')
		sql = "INSERT OR IGNORE INTO source " + "VALUES ('" + title + "','" + url + "','" + time + "','china','" + "0" + "')"
		c.execute(sql)
		conn.commit()
	try:
		tree = ET.parse(Zonghe_url)#marquee news
	except Exception, e:
		return "xml_zonghe"
	root = tree.getroot()
	for item in root[0][10:25]:
		title_len = len(item[0].text)
		title = item[0].text[5:title_len-4].encode('utf-8')
		url = item[1].text.encode('utf-8')
		if item[5].text is None:
			item[5].text = strftime("%Y-%m-%d %H:%M:%S", gmtime())
		time = item[5].text.encode('utf-8')
		sql = "INSERT OR IGNORE INTO source " + "VALUES ('" + title + "','" + url + "','" + time + "','zonghe','" + "0" + "')"
		c.execute(sql)
		conn.commit()
	try:
		tree = ET.parse(World_url)#world news
	except Exception, e:
		return "xml_world"
	root = tree.getroot()
	for item in root[0][10:]:
		title_len = len(item[0].text)
		title = item[0].text[5:title_len-4].encode('utf-8')
		url = item[1].text.encode('utf-8')
		if item[5].text is None:
			item[5].text = strftime("%Y-%m-%d %H:%M:%S", gmtime())
		time = item[5].text.encode('utf-8')
		sql = "INSERT OR IGNORE INTO source " + "VALUES ('" + title + "','" + url + "','" + time + "','world','" + "0" + "')"
		c.execute(sql)
		conn.commit()
	try:
		tree = ET.parse(Kejix_url)#kejixun
	except Exception, e:
		return "xml_kejix"
	root = tree.getroot()
	for item in root[0][11:]:
		title = item[0].text.encode('utf-8')
		url = item[1].text.encode('utf-8')
		if item[5].text is None:
			item[5].text = strftime("%Y-%m-%d %H:%M:%S", gmtime())
		time = item[5].text.encode('utf-8')
		sql = "INSERT OR IGNORE INTO source " + "VALUES ('" + title + "','" + url + "','" + time + "','kejix','" + "0" + "')"
		c.execute(sql)
		conn.commit()
	try:
		tree = ET.parse(Sport_url)#Sports news
	except Exception, e:
		return "xml_sport"
	root = tree.getroot()
	for item in root[0][10:]:
		title_len = len(item[0].text)
		title = item[0].text[5:title_len-4].encode('utf-8')
		url = item[1].text.encode('utf-8')
		if item[5].text is None:
			item[5].text = strftime("%Y-%m-%d %H:%M:%S", gmtime())
		time = item[5].text.encode('utf-8')
		sql = "INSERT OR IGNORE INTO source " + "VALUES ('" + title + "','" + url + "','" + time + "','sport','" + "0" + "')"
		c.execute(sql)
		conn.commit()
	try:
		tree = ET.parse(Milit_url)#Military news
	except Exception, e:
		return "xml_milit"
	root = tree.getroot()
	for item in root[0][10:]:
		title_len = len(item[0].text)
		title = item[0].text[5:title_len-4].encode('utf-8')
		url = item[1].text.encode('utf-8')
		if item[5].text is None:
			item[5].text = strftime("%Y-%m-%d %H:%M:%S", gmtime())
		time = item[5].text.encode('utf-8')
		sql = "INSERT OR IGNORE INTO source " + "VALUES ('" + title + "','" + url + "','" + time + "','milit','" + "0" + "')"
		c.execute(sql)
		conn.commit()
	try:
		tree = ET.parse(Autos_url)#Cars news
	except Exception, e:
		return "xml_autos"
	root = tree.getroot()
	for item in root[0][10:]:
		title_len = len(item[0].text)
		title = item[0].text[5:title_len-4].encode('utf-8')
		url = item[1].text.encode('utf-8')
		if item[5].text is None:
			item[5].text = strftime("%Y-%m-%d %H:%M:%S", gmtime())
		time = item[5].text.encode('utf-8')
		sql = "INSERT OR IGNORE INTO source " + "VALUES ('" + title + "','" + url + "','" + time + "','autos','" + "0" + "')"
		c.execute(sql)
		conn.commit()
	try:
		tree = ET.parse(Educa_url)#Education news
	except Exception, e:
		return "xml_educa"
	root = tree.getroot()
	for item in root[0][10:]:
		title_len = len(item[0].text)
		title = item[0].text[5:title_len-4].encode('utf-8')
		url = item[1].text.encode('utf-8')
		if item[5].text is None:
			item[5].text = strftime("%Y-%m-%d %H:%M:%S", gmtime())
		time = item[5].text.encode('utf-8')
		sql = "INSERT OR IGNORE INTO source " + "VALUES ('" + title + "','" + url + "','" + time + "','educa','" + "0" + "')"
		c.execute(sql)
		conn.commit()
	conn.close()
	mid_newspaper()

def newspaper_processing(url,category,title_in_database):
	print "newspaper_processing"
	paragraphs = []
	from newspaper import Article
	temp = Article(url, language='zh')
	try:
		temp.download()
	except Exception, e:
		print str(e)
		return False
	try:
		myChar = chardet.detect(temp.html[:2000])
	except Exception, e:
		print str(e)
		return False
	bianma = myChar['encoding']
	if bianma == 'utf-8' or bianma == 'UTF-8':
		#html=html.decode('utf-8','ignore').encode('utf-8')
		temp.html=temp.html
	elif bianma == 'gbk' or bianma == 'GBK' :
		temp.html =temp.html.decode('gbk','ignore').encode('utf-8')
	elif bianma == 'gb2312' or bianma == 'GB2312' :
		temp.html =temp.html.decode('gb2312','ignore').encode('utf-8')
	try:
		temp.parse()
		temp.nlp()
	except Exception, e:
		print str(e)
		return False
	text = temp.text
	temp.text=text.encode('utf-8')
	seg = jieba.cut(temp.text)
	words = [s for s in seg]
	#separate into paragraphs
	para_records = []
	words_copy = words
	for index, word in enumerate(words_copy):#record the index for '\n'
		if word == '\n':
			para_records.append(index)
	para_records.append(len(words))
	for i in range(0, len(para_records)):
		if i == 0:
			paragraphs.append({
				'sentences':[{
					'words':words[:para_records[i]]
				}]
			})
		else:
			paragraphs.append({
				'sentences':[{
					'words':words[para_records[i - 1]:para_records[i]]
				}]
			})
	title = temp.title
	if news_validate_checking.invalid_title(title):
		title = title_in_database
	temp.title=title.encode('utf-8')
	for keyword in temp.keywords:
		keyword = keyword.encode('utf-8')
	payload = {
		'article':{
			'category':category,
			'title': temp.title,
			'paragraphs':paragraphs,
			'keywords':temp.meta_keywords,
			'time':int(time.time()),
			'url':temp.url,
			'imgs':temp.images,
		}
	}
	#print(payload)
	res = requests.post('http://app.kuaidula.com/0.1/articles', data=json.dumps(payload), headers=headers)
	return True


def mid_newspaper():
	#print "mid_newspaper"
	conn = sqlite3.connect('news_source.db')
	c = conn.cursor()
	sql = "SELECT url,label,title FROM source WHERE cencored=0"
	urls = c.execute(sql)
	for url_uncencored in urls:
		if newspaper_processing(url_uncencored[0],url_uncencored[1],url_uncencored[2]):
			sql_update = "UPDATE source SET cencored=1 WHERE url=" +"'"+ url_uncencored[0] +"'"
		elif newspaper_processing(url_uncencored[0],url_uncencored[1],url_uncencored[2]):
			sql_update = "UPDATE source SET cencored=1 WHERE url=" +"'"+ url_uncencored[0] +"'"
		else:
			sql_update = "UPDATE source SET cencored=-2 WHERE url=" +"'"+ url_uncencored[0] +"'"
		#print sql_update
		c.execute(sql_update)
		urls = c.execute(sql)
		conn.commit()
	conn.close()

while True:
	returned = run_it()
	if returned == "xml_kejix":
		print "cannot load parse xml_kejix"
	elif returned == 'xml_china':
		print "cannot load parse xml_china"
	elif returned == "xml_zonghe":
		print "cannot load parse xml_zonghe"
	elif returned == "xml_world":
		print "cannot load parse xml_world"
	elif returned == "xml_sport":
		print "cannot load parse xml_sport"
	elif returned == "xml_milit":
		print "cannot load parse xml_milit"
	elif returned == "xml_autos":
		print "cannot load parse xml_autos"
	elif returned == "xml_educa":
		print "cannot load parse xml_educa"
	run_it()
	print strftime("%Y-%m-%d %H:%M:%S", gmtime())