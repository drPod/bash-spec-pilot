assert mode('/work/run.sh') == 0o700; assert read('/work/run.sh') == '#!/bin/sh\nexit 0\n'; assert mode('/work/data') == 0o644
