import asherah from 'asherah'

asherah.setup('static', 'memory', null, null, null, null, null, 'TestService', 'TestProduct', null, true, true)

var data = Buffer.from('mysecretdata', 'utf8');

var encrypted = asherah.encrypt('partition', data);
console.log(encrypted);

var decrypted = asherah.decrypt('partition', encrypted);

console.log("Decrypted: " + decrypted.toString('utf8'));
