assert os.readlink('/work/current') == '/work/releases/v2'; assert read('/work/releases/v1/data') == 'v1'; assert read('/work/current/data') == 'v2'
