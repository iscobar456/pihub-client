import requests
import json
import hashlib
import time


current_time = time.time()
vhash = hashlib.sha256()
vhash.update(pubkey)
vhash.update(current_time)
vhash.update(privkey)
verification_data = {
    'public_key': pubkey,
    'time': current_time,
    'vhash': vhash.hexdigest()
}
verify_response = requests.post('http://pihub.site/api/verify-device', verification_data)
if verify_response.status_code == 200:
    keys = json.dumps({'public': pubkey, 'private': privkey})
    keys_file = open('/opt/pihub-client/keys.json', 'w+')
    keys_file.write(keys)
    keys_file.close()
    return 1
else:
    return 2