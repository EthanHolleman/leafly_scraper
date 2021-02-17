import requests
from bs4 import BeautifulSoup
import re
import json
from pathlib import Path

def get_soup_from_strain_page_num(page_num):
    base_url = 'https://www.leafly.com/strains?page={}'
    r = requests.get(base_url.format(page_num))
    return BeautifulSoup(r.content)

def extract_strain_json(soup):
    json_script = str(soup.find_all('script', id='__NEXT_DATA__'))
    clean_json = re.sub('<.*?>', '', json_script)
    return json.loads(clean_json).pop()  # want the dict in the list 

def json_has_strains(json_dict):
    if json_dict['props']['pageProps']['strains']:
        return True
    else:
        return False

def write_json(page_number, outdir, json_dict):
    write_path = Path(outdir).joinpath(f'{page_number}.json')
    with open(str(write_path), 'w') as handle:
        json.dump(json_dict, handle, indent=4)
    return write_path

current_page = 1
outdir = Path('json_files_2')
if not outdir.is_dir():
    outdir.mkdir()

while True:
    print(f'Downloading contents of strain page {current_page}')
    soup = get_soup_from_strain_page_num(current_page)
    page_json_dict = extract_strain_json(soup)
    if json_has_strains(page_json_dict):
        write_json(current_page, outdir, page_json_dict)
        current_page += 1
    else:
        break

print(f'Downloaded from {current_page} pages.')


