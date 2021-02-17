import json
import sys
from pathlib import Path
import pandas as pd

WRITE_PATH = 'strains.csv'
JSON_DIR = 'json_files_2'


def extract_strain_terps_from_json(json_path):
    pass


def get_strains_from_json_dict(json_dict):
    return json_dict['props']['pageProps']['strains']


def get_terps_from_strain_dict(strain_dict):
    terps_dict = strain_dict['terps']
    # are only interested in the terp name and the score
    parsed_terp_dict = {}
    for terp_name, attributes in terps_dict.items():
        parsed_terp_dict[terp_name] = attributes['score']
    return parsed_terp_dict


def get_effects_from_strain_dict(strain_dict):
    effect_dict = strain_dict['effects']
    parsed_effect_dict = {}
    for effect_name, attributes in effect_dict.items():
        parsed_effect_dict[effect_name] = attributes['score']
    return parsed_effect_dict


def get_misc_layer_one_data(strain_dict):
    # get numeric data that does not have extra layers
    misc = {}
    for key, val in strain_dict.items():
        if type(val) != list and type(val) != dict:
            # if type(val) == str:
            #     val.replace('\n', '')
            misc[key] = val

    return misc


def extract_all_json_data_from_strain_dict(strain_dict):
    parsed_dict = {}
    parsed_dict.update(get_effects_from_strain_dict(strain_dict))
    parsed_dict.update(get_terps_from_strain_dict(strain_dict))
    parsed_dict.update(get_misc_layer_one_data(strain_dict))
    return parsed_dict


def extract_strain_data_from_json(json_path):
    strain_data = []
    with open(str(json_path)) as handle:
        json_dict = json.load(handle)
        assert json_dict
        strains = get_strains_from_json_dict(json_dict)
        # print(strains, len(strains), type(strains))
        # input('Continue?')
        for each_strain in strains:
            parsed_strain = extract_all_json_data_from_strain_dict(each_strain)
            assert parsed_strain
            strain_data.append(parsed_strain)
    return strain_data


def write_strain_data(filepath, all_strain_data):
    df = pd.DataFrame.from_dict(all_strain_data)
    df.to_csv(filepath)
    return filepath


def main():
    if not JSON_DIR:
        print('Please set a JSON_DIR path')
        sys.exit()  # lazy avoiding argparse
    all_strain_data = []
    for each_file in Path(JSON_DIR).iterdir():
        if each_file.suffix == '.json':
            all_strain_data += extract_strain_data_from_json(each_file)

    write_strain_data(WRITE_PATH, all_strain_data)


if __name__ == '__main__':
    main()
