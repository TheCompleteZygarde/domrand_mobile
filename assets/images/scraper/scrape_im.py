import requests

with open('List of cards - Dominion Strategy Wiki.htm', 'r', encoding="utf8") as file:
    lines = [line for line in file if line.find('card-popup') != -1]

for line in lines:
    url = line[line.find('thumb')+5:]
    url = url[:url[6:].find('/')+6]
    print(url)
    result = requests.get('https://wiki.dominionstrategy.com/images' + url)
    if result.status_code != 200:
        print(result.status_code)
        continue
    name = line[line.find('title=')+7:]
    name = name[:name.find('"')]
    print(name)
    f = open('cards/' + name + '.jpg', 'wb')
    f.write(result.content)
    f.close()

