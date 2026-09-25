assert not user_exists('retired'); assert not P('/home/retired').exists(); assert read('/home/active/keep') == 'keep'
