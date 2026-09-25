put('/work/run.sh','#!/bin/sh\nexit 0\n'); put('/work/data','keep'); os.chmod('/work/data',0o644); os.chmod('/work/run.sh',0o777 if adversarial else 0o600)
