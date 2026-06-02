import json
from functools import cmp_to_key

expansionMap = {
  'Dominion': 0,
  'Intrigue': 1,
  'Dark Ages': 2,
  'Alchemy': 3,
  'Adventures': 4,
  'Empires': 5,
  'Nocturne': 6,
  'Rising Sun': 7,
  'Seaside': 8,
  'Prosperity': 9,
  'Cornucopia & Guilds': 10,
  'Cornucopia': 10,
  'Hinterlands': 11,
  'Guilds': 12,
  'Renaissance': 13,
  'Menagerie': 14,
  'Allies': 15,
  'Promo': 17,
  'Plunder': 16,
};

def comp(a, b):
  a_end = a['set'].find(',')
  if a_end == -1:
    a_end = len(a['set'])
  b_end = b['set'].find(',')
  if b_end == -1:
    b_end = len(b['set'])
  setdiff = expansionMap[a['set'][:a_end]] - expansionMap[b['set'][:b_end]]
  if setdiff != 0:
    return setdiff
  if a['name'] < b['name']:
    return -1
  return 1

def sorter(filename):
  with open(filename, 'r') as file:
    data = json.load(file)
  
  data = sorted(data, key=cmp_to_key(comp))

  with open('sorted_' + filename, 'w') as file:
    json.dump(data, file, indent=4)

if __name__ == "__main__":
  sorter("test.json")