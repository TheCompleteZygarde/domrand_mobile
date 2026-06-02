from bs4 import BeautifulSoup, Tag
from bs4.element import NavigableString
import json
import unicodedata
import re

def extract_text(cell, top_level=True):
  parts = []
  for node in cell.children:
    if isinstance(node, NavigableString):
      s = str(node)
      if cell.get("style") == "font-size: 0":
        s = s.replace("D", "DBT")
      parts.append(str(node))

    elif node.name == "img":
      text = node.get("alt", "")
      text = text.replace("D", "DBT")
      if text == "VP":
        parts.append(text)

    elif node.name == "br":
      parts.append(".")

    elif node.name == "p" or (node.name == "b" and top_level):
      inner = extract_text(node, top_level=False)
      if inner:
        parts.append(inner + ".")

    else:
      parts.append(extract_text(node, top_level=False))
  return "".join(parts)

def clean_text(text: str):
  text = text.replace("\xa0", " ")
  text = unicodedata.normalize("NFKC", text)
  text = text.encode("ascii", errors="ignore").decode("ascii")
  text = re.sub(r"\.(\s*\.)+", ".", text)
  text = re.sub(r"[ \t]+", " ", text)
  text = re.sub(r"\s*\.\s*", ". ", text)
  text = re.sub(r"\s*\,\s*", ", ", text)
  text = text.strip()
  text = text.replace(' VP', 'VP')
  indexes = set()
  for i, c in enumerate(text):
    if c == '.' and i < len(text) -3:
      if text[i+1] != ' ' or text[i+2].islower():
        print(text[i:i+3])
        print(text)
        indexes.add(i)
  new = ''.join([c for i, c in enumerate(text) if i not in indexes])
  if new != text:
    text = new
    print(text)
  
  if 'VP' in text:
    pass
    #print(text)
  return text

def parse_card(row):
  cells = row.find_all("td")

  values = []
  for cell in cells:
    v = clean_text(extract_text(cell))
    if len(values) != 4:
      v = v.replace(".", "")
    values.append(v)

  card = dict(zip(headers, values))

#set
  card["set"] = card["set"].replace("Base", "Dominion")
  if card["set"] in sets_with_editions:
    card["set"] = card["set"] + ", 1E, 2E"
  elif ',' in card['set']:
    card['set'] = card['set'][:card["set"].find(',')].strip() + card["set"][card['set'].find(','):]
    if 'Cornucopia & Guilds' in card['set'] and '1' in card['set']:
      if card['name'] in guilds_e1_cards:
        card['set'] = 'Guilds'
      else:
        card['set'] = 'Cornucopia'

  card["types"] = [elem.strip() for elem in card["types"].split("-")]

  card['text'] = card['text'].replace('\u00a0', ' ')

#setup
  if card["text"].find("Setup:") != -1:
    card["setup"] = card["text"][card["text"].find("Setup:") + 7:]
  else:
    card["setup"] = ""

#Categories
  if card['name'] in basic_cards:
    card["categories"] = ['Basic']
  elif 'Shelter' in card['types'] or card['name'] in ['Potion', 'Colony', 'Platinum']:
    card["categories"] = ['SetBasic']
  elif 'Split pile' not in card['types'] and (
    card['name'] in non_standard_kingdom_cards or any(
      map(lambda t: t in non_standard_kingdom_types, card['types']))):
    card['categories'] = ['Non-standard kingdom']
  elif '*' in card['cost'] and card['name'] not in special_cost:
    card['categories'] = ['Not in supply']
  elif any(map(lambda t: t in landscape_types, card['types'])):
    card['categories'] = ['Landscape']
  else:
    card["categories"] = []
  
  return card

def parse_table(table):
  if table is None:
    print('No table found')
    exit(404)

  cards = []

  for row in table.find_all("tr")[1:]:
    cards.append(parse_card(row))

  with open('cards_not_in_html.json') as file:
    split_piles = json.load(file)
  cards += split_piles

  return cards

headers = [
  "name",
  "set",
  "types",
  "cost",
  "text",
  "actionsVillagers",
  "cards",
  "buys",
  "coinsCoffers",
  "trashReturn",
  "exile",
  "junk",
  "gain",
  "victoryPoints",
  "setup",
  "categories"
]

# Where to add editions
sets_with_editions = [
  "Dominion",
  "Intrigue",
  "Seaside",
  "Prosperity",
  "Cornucopia",
  "Hinterlands",
  "Guilds",
  "Cornucopia & Guilds",
]

# Where to add categories
basic_cards = ['Copper', 'Silver', 'Gold', 'Estate', 'Duchy', 'Province', 'Curse']
non_standard_kingdom_cards = [
  'Bustling Village',
  'Catapult',
  'Emporium',
  'Encampment',
  'Fortune',
  'Gladiator',
  'Patrician',
  'Plunder',
  'Rocks',
  'Settlers'
]

non_standard_kingdom_types = [
  'Ruins',
  'Knight',
  'Castle',
  'Zombie',
  'Heirloom',
  'Townsfolk',
  'Augur',
  'Clash',
  'Fort',
  'Odyssey',
  'Wizard',
]

landscape_types = [
  'Event',
  'Landmark',
  'Boon',
  'Hex',
  'State',
  'Artifact',
  'Project',
  'Way',
  'Ally',
  'Prophecy',
]

#Xards with * in cost but still in supply
special_cost = [
  'Grand Market',
  'Peddler',
  'Animal Fair',
  'Destrier',
  'Fisherman',
  'Wayfarer'
]

guilds_e1_cards = [
  'Doctor',
  'Masterpiece',
  'Taxman'
]

if __name__ == "__main__":
  with open('List of cards - Dominion Strategy Wiki.html', 'r', encoding="utf-8") as file:
      soup = BeautifulSoup(file, "html.parser")

  table = soup.find("table", class_="wikitable")

  cards = parse_table(table)

  with open("test.json", "w") as fd:
    json.dump(cards, fd, indent=4)

