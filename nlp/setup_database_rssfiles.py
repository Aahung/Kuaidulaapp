import sqlite3
conn = sqlite3.connect('news_source.db')
c = conn.cursor()

# Create table
c.execute('''CREATE TABLE source
             (title text, url text NOT NULL UNIQUE, time text, label text, cencored integer)''')

conn.commit()
conn.close()
f = open('rss_url', 'w')
f.write('China:http://rss.sina.com.cn/news/china/focus15.xml\n')
f.write('World:http://rss.sina.com.cn/news/world/focus15.xml\n')
f.write('Zongh:http://rss.sina.com.cn/news/marquee/ddt.xml\n')
f.write('Kejix:http://www.kejixun.com/index.php?m=content&c=rss&rssid=9')
f.close()